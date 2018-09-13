unit ht_main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, VclTee.TeeGDIPlus, VCLTee.TeEngine,
  VCLTee.TeeProcs, VCLTee.Chart, VCLTee.Series, System.Actions, Vcl.ActnList,
  Vcl.Menus, TempDS, VCLTee.TeeSpline, Vcl.XPMan, autorunner;

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
    Label1: TLabel;
    Label2: TLabel;
    XPManifest1: TXPManifest;
    procedure FormCreate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure N2Click(Sender: TObject);
    procedure actExitExecute(Sender: TObject);
    procedure ComboIntervalChange(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
    f_DS : TTempDataSource;

    procedure AddTemperature;
    procedure AddToAutoRun;
    procedure RedrawChart;
    function GetTemperature: Double;
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation
uses
 DateUtils,
 HIDFTDLL;

{$R *.dfm}

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
 f_DS.Put(l_Date, l_Temp);
 Panel1.Caption:= Format('%f C', [l_Temp]);
 RedrawChart;
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
  f_DS.Free;
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
 AddToAutoRun;
 ComboInterval.ItemIndex:= 1;
 f_DS := TTempDataSource.Create;
 Timer1.Interval:= 1000*3*60;
 AddTemperature;
end;

function TMainForm.GetTemperature: Double;
var
 I, l_Count: Integer;
begin
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

procedure TMainForm.N2Click(Sender: TObject);
begin
  Close
end;

procedure TMainForm.RedrawChart;
var
 l_From, l_To: TDateTime;
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
  if l_Rec.rTemp < 22 then
   l_Color:= clBlue
  else
  if l_Rec.rTemp > 24 then
   l_Color:= clRed
  else
   l_Color:= clGreen;
  Series1.Add(l_Rec.rTemp, TimeToStr(l_Rec.rDateTime, l_FS), l_Color);
 end;
 l_rec:= f_DS.MaxTemp(l_From, l_To);
 Label2.Caption:= Format('Максимум: %f в %s', [l_rec.rTemp, TimeToStr(l_rec.rDateTime)]);
 ChartTemp.LeftAxis.Maximum:= l_rec.rTemp+1;
 l_rec:= f_DS.MinTemp(l_From, l_To);
 Label1.Caption:= Format('Минимум : %f в %s', [l_rec.rTemp, TimeToStr(l_rec.rDateTime)]);
 ChartTemp.LeftAxis.Minimum:= l_Rec.rTemp-1;
end;

procedure TMainForm.Timer1Timer(Sender: TObject);
begin
 AddTemperature;
end;

end.
