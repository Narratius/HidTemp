program hidtemp;

uses
  Forms,
  ht_main in 'ht_main.pas' {Form1};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
