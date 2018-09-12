program hidtemp;

uses
  Forms,
  ht_main in 'ht_main.pas' {MainForm};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
