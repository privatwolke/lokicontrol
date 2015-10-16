program Server;

uses
  Forms,
  EZTWAIN in 'EZTWAIN.PAS',
  dib in 'dib.pas',
  server_main in 'server_main.pas' {Form2},
  RegExpr in 'RegExpr.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm2, Form2);
  Application.Run;
end.
