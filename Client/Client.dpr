program Client;

uses
  Forms,
  client_main in 'client_main.pas' {Form1},
  about in 'about.pas' {AboutBox},
  RegExpr in 'RegExpr.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TAboutBox, AboutBox);
  Application.Run;
end.
