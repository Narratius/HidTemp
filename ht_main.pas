unit ht_main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

type
  TForm1 = class(TForm)
    ListBox1: TListBox;
    Timer1: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation
uses
 HIDFTDLL,
 TempDS{,
 GartimeDS};

{$R *.dfm}

procedure TForm1.FormCreate(Sender: TObject);
var
 l_DS : TTempDataSource;
 l_Cnt: Integer;
 l_Data : TTempRec;
 l_X: Double;
begin
 l_DS := TTempDataSource.Create;
 //l_DS.Put(Now, 25.1652);
 l_DS.QueryAll;
 l_Cnt := l_DS.QueryCount;
 l_Data := l_DS.QueryData[1];
 l_DS.Query(0, Now);
 l_Cnt := l_DS.QueryCount;
 l_Data := l_DS.QueryData[0];
 l_Data := l_DS.MaxTemp(0, Now);
 l_Data := l_DS.MinTemp(0, Now);
 l_DS.Free;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
var
 I, l_Count: Integer;
 l_Temp: Double;
begin
 //ListBox1.Clear;
 l_Count := EMyDetectDevice(0);
 for I := 0 to l_Count-1 do
 begin
  EMySetCurrentDev(I);
  Sleep(100);
  EMyInitConfig(True);
  Sleep(100);
  l_Temp := EMyReadTemp(True);
  ListBox1.Items.Add(Format('Device %d: Temp = %f', [I, l_Temp]));
  Application.ProcessMessages;
  EMyCloseDevice;
 end;
end;

end.
