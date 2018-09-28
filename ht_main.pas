unit ht_main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, VclTee.TeeGDIPlus, VCLTee.TeEngine,
  VCLTee.TeeProcs, VCLTee.Chart, VCLTee.Series, System.Actions, Vcl.ActnList,
  Vcl.Menus, TempDS, VCLTee.TeeSpline, Vcl.XPMan, autorunner, OneInstance,
  IdBaseComponent, IdComponent, IdCustomTCPServer, IdCustomHTTPServer,
  IdHTTPServer, IdContext, Web.HTTPApp, Web.HTTPProd,
  Propertys;

type
  TMainForm = class(TForm)
    Timer1: TTimer;
    ChartTemp: TChart;
    Series1: TLineSeries;
    MainMenu1: TMainMenu;
    Panel1: TPanel;
    N1: TMenuItem;
    N2: TMenuItem;
    ActionList1: TActionList;
    actExit: TAction;
    actConfig: TAction;
    N3: TMenuItem;
    ComboInterval: TComboBox;
    XPManifest1: TXPManifest;
    OneInstance1: TOneInstance;
    IdHTTPServer1: TIdHTTPServer;
    PageProducer1: TPageProducer;
    Image1: TImage;
    procedure FormCreate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure N2Click(Sender: TObject);
    procedure actExitExecute(Sender: TObject);
    procedure ComboIntervalChange(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure IdHTTPServer1CommandGet(AContext: TIdContext;
      ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
    procedure actConfigExecute(Sender: TObject);
  private
    { Private declarations }
    f_DS : TTempDataSource;
    f_Config: TProperties;
    procedure AddTemperature;
    procedure AddToAutoRun;
    procedure RedrawChart;
    function GetTemperature: Double;
    procedure ConvertBMP2JPEG;
    procedure CreateConfig;
    procedure DestroyConfig;
    procedure SetDefaultValues;
    function ConfigFileName: String;
    procedure LoadConfig;
    procedure SaveConfig;
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation
uses
 Jpeg, ClipBrd,
 DateUtils, Math,
 PropertyUtils, ddLogFile,
 HIDFTDLL;

{$R *.dfm}

procedure TMainForm.actConfigExecute(Sender: TObject);
begin
  if ShowPropDialog('Настройки', f_Config) then
  begin
   SaveConfig;
   RedrawChart;
  end;
end;

procedure TMainForm.actExitExecute(Sender: TObject);
begin
  Close;
end;

procedure TMainForm.AddTemperature;
var
 l_Date: TDateTime;
 l_Temp: Double;
 l_Color: TColor;
begin
 l_Date:= Now;
 l_Temp:= GetTemperature;
 if l_Temp <> MinDouble then
 begin
  f_DS.Put(l_Date, l_Temp);
  ChartTemp.Title.Text.Text:= Format('%f C', [l_Temp]);
  RedrawChart;
 end;
end;

procedure TMainForm.AddToAutoRun;
begin
 with TAutoRunner.Create(nil) do
 try
   AppName:= 'HIDTemp';
   AutoRun:= True;
 finally
   Free;
 end;
end;

procedure TMainForm.ComboIntervalChange(Sender: TObject);
begin
 RedrawChart;
end;

procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  IdHTTPServer1.Active:= False;
  DestroyConfig;
  f_DS.Free;
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
 CreateConfig;
 AddToAutoRun;
 ComboInterval.ItemIndex:= 1;
 f_DS := TTempDataSource.Create;
 AddTemperature;
 Timer1.Interval:= 1000*f_Config.Values['Interval'];
 IdHTTPServer1.DefaultPort:= f_Config.Values['HTTPPort'];
 idHTTPServer1.Active:= True;
end;

function TMainForm.GetTemperature: Double;
var
 I, l_Count: Integer;
begin
 Result:= MinDouble;
 l_Count := EMyDetectDevice(0);
 for I := 0 to l_Count-1 do
 begin
  EMySetCurrentDev(I);
  Sleep(100);
  EMyInitConfig(True);
  Sleep(100);
  Result := EMyReadTemp(True);
  EMyCloseDevice;
 end;
end;



function TMainForm.ConfigFileName: String;
begin
 Result:= ChangeFileExt(Application.ExeName, '.config');
end;

procedure TMainForm.ConvertBMP2JPEG;
// converts a bitmap, the graphic of a TChart for example, to a jpeg
var
 jpgImg: TJPEGImage;
 tmpRect: TRect;
begin
  tmpRect.Left:= 0;
  tmpRect.Top:= 0;
  tmpRect.Width:= f_Config.Values['Width'];
  tmpRect.Height:= f_Config.Values['Height'];
  try
  // copy bitmap to clipboard
  ChartTemp.CopyToClipboardBitmap(tmpRect);
  // get clipboard and load it to Image1
  Image1.Picture.Bitmap.LoadFromClipboardFormat(cf_BitMap, ClipBoard.GetAsHandle(cf_Bitmap), 0);
  // create the jpeg-graphic
  jpgImg := TJPEGImage.Create;
  // assign the bitmap to the jpeg, this converts the bitmap
  jpgImg.Assign(Image1.Picture.Bitmap);
  // and save it to file
  jpgImg.SaveToFile(ChangeFileExt(Application.ExeName, '.jpg'));
 except
  Msg2Log('Ошибка преобразования графика')
 end;
end;

procedure TMainForm.CreateConfig;
begin
 f_Config:= TProperties.Create(nil);
 with f_Config do
 begin
   DefineInteger('Interval', 'Интервал измерений, сек');
   DefineInteger('HTTPPort', 'HTTPPort');
   DefineDivider('Зона комфортной температуры');
   DefineInteger('HighTemp', 'Верхняя граница');
   DefineInteger('LowTemp', 'Нижняя граница');
   DefineDivider('Размер изображения');
   DefineInteger('Width', 'Ширина');
   DefineInteger('Height', 'Высота');
 end;
 if FileExists(ConfigFileName) then
  LoadConfig
 else
  SetDefaultValues;
end;

procedure TMainForm.DestroyConfig;
begin
 FreeAndNil(f_Config);
end;

procedure TMainForm.IdHTTPServer1CommandGet(AContext: TIdContext;
  ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
var
 I: Integer;
 RequestedDocument, l_FileName, CheckFileName: string;
 l_Stream: TStream;
begin
 AResponseInfo.Server := '1.0' ; AResponseInfo.CacheControl := 'no-cache' ;
 AResponseInfo.ContentType:= 'image/jpeg';
 // requested document
 RequestedDocument := aRequestInfo.Document;
 // log request
// Log('Client: ' + aRequestInfo.RemoteIP + ' request for: ' + RequestedDocument);
 // 001
 ConvertBMP2JPEG;
 l_FileName:= ChangeFileExt(Application.ExeName, '.jpg');
 if FileExists(l_FileName) then
   aResponseInfo.ContentStream:= TFileStream.Create(l_FileName, fmOpenRead);
end;

procedure TMainForm.LoadConfig;
begin
  LoadFromFile(ConfigFileName, f_Config, False);
end;

procedure TMainForm.N2Click(Sender: TObject);
begin
  Close
end;

procedure TMainForm.RedrawChart;
var
 l_From, l_To: TDateTime;
 l_MinTemp, l_MaxTemp: Double;
 i: Integer;
 l_rec: TTempRec;
 l_Color: TColor;
 l_FS: TFormatSettings;
begin
 Series1.Clear;
 //series1.Smoothed:= True;
 l_To:= Now;
  case ComboInterval.ItemIndex of
    0: l_From:= IncHour(l_To, -1); // 1
    1: l_From:= IncHour(l_To, -2); // 2
    2: l_From:= IncHour(l_To, -8); // 8
    3: l_From:= IncHour(l_To, -24); // day
    4: l_From:= 0; // all
  end;
 f_DS.Query(l_From, l_To);
 l_FS:= TFormatSettings.Create;
 l_FS.LongTimeFormat:= 'HH:mm';
 for I := 0 to f_DS.QueryCount-1 do
 begin
  l_Rec:= f_DS.QueryData[i];
  if l_Rec.rTemp < f_Config.Values['LowTemp'] then
   l_Color:= clBlue
  else
  if l_Rec.rTemp > f_Config.Values['HighTemp'] then
   l_Color:= clRed
  else
   l_Color:= clGreen;
  Series1.Add(l_Rec.rTemp, TimeToStr(l_Rec.rDateTime, l_FS), l_Color);
 end;
 ChartTemp.SubTitle.Text.Clear;
 l_rec:= f_DS.MaxTemp(l_From, l_To);
 l_MaxTemp:= l_Rec.rTemp;
 ChartTemp.SubTitle.Text.Add(Format('Максимум: %f в %s', [IfThen(l_MaxTemp = MaxInt, 0, l_MaxTemp), TimeToStr(l_rec.rDateTime)]));
 l_rec:= f_DS.MinTemp(l_From, l_To);
 l_MinTemp:= l_rec.rTemp;
 ChartTemp.SubTitle.Text.Add(Format('Минимум : %f в %s', [IfThen(l_MinTemp = MaxInt, 0, l_MinTemp), TimeToStr(l_rec.rDateTime)]));
 if l_MinTemp < l_MaxTemp then
 begin
  ChartTemp.LeftAxis.Minimum:= l_MinTemp-0.5;
  ChartTemp.LeftAxis.Maximum:= l_MaxTemp+0.5;
 end;
end;

procedure TMainForm.SaveConfig;
begin
 SaveToFile(ConfigFileName, f_Config, False);
end;

procedure TMainForm.SetDefaultValues;
begin
  with f_Config do
  begin
   Values['HTTPPort']:= 8011;
   Values['HighTemp']:= 24;
   Values['LowTemp']:= 22;
   Values['Interval']:=180;
   Values['Width']:= 1280;
   Values['Height']:= 1024;
  end;
end;

procedure TMainForm.Timer1Timer(Sender: TObject);
begin
 AddTemperature;
end;

end.
