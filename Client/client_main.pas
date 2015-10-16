unit client_main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ScktComp, ComCtrls, ExtCtrls, inifiles, Menus, About, RegExpr;

type
  TStringDynArray = array of string;
  TForm1 = class(TForm)
    Client: TClientSocket;
    Button1: TButton;
    Button3: TButton;
    MainMenu1: TMainMenu;
    Datei1: TMenuItem;
    Beenden1: TMenuItem;
    Info1: TMenuItem;
    GroupBox1: TGroupBox;
    remotehost: TLabeledEdit;
    port: TLabeledEdit;
    GroupBox2: TGroupBox;
    filename: TLabeledEdit;
    jpegcompression: TTrackBar;
    Label1: TLabel;
    GroupBox3: TGroupBox;
    status: TEdit;
    Button2: TButton;
    procedure Info1Click(Sender: TObject);
    procedure ClientError(Sender: TObject; Socket: TCustomWinSocket;
      ErrorEvent: TErrorEvent; var ErrorCode: Integer);
    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure Beenden1Click(Sender: TObject);
    procedure jpegcompressionChange(Sender: TObject);
    procedure ClientDisconnect(Sender: TObject; Socket: TCustomWinSocket);
    procedure ClientConnect(Sender: TObject; Socket: TCustomWinSocket);
    procedure Button3Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure ClientRead(Sender: TObject; Socket: TCustomWinSocket);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  scanid: integer;

const
  APPVERSION = '1.0';

implementation

{$R *.dfm}

function Explode(const Separator, S: string; Limit: Integer = 0):
  TStringDynArray;
var
  SepLen       : Integer;
  F, P         : PChar;
  ALen, Index  : Integer;
begin
  SetLength(Result, 0);
  if (S = '') or (Limit < 0) then
    Exit;
  if Separator = '' then
  begin
    SetLength(Result, 1);
    Result[0] := S;
    Exit;
  end;
  SepLen := Length(Separator);
  ALen := Limit;
  SetLength(Result, ALen);

  Index := 0;
  P := PChar(S);
  while P^ <> #0 do
  begin
    F := P;
    P := StrPos(P, PChar(Separator));
    if (P = nil) or ((Limit > 0) and (Index = Limit - 1)) then
      P := StrEnd(F);
    if Index >= ALen then
    begin
      Inc(ALen, 5); // mehrere auf einmal um schneller arbeiten zu können
      SetLength(Result, ALen);
    end;
    SetString(Result[Index], F, P - F);
    Inc(Index);
    if P^ <> #0 then
      Inc(P, SepLen);
  end;
  if Index < ALen then
    SetLength(Result, Index); // wirkliche Länge festlegen
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  if filename.Text = '' then filename.Text := 'networkscan.jpg';
{  if ExecRegExpr('^(?:[^\/\\:*?""<>|]+)$',filename.Text) then begin}
    Client.Socket.SendText('REQUEST||'+APPVERSION+'||RQ_SCAN||'+filename.Text+'||'+inttostr(jpegcompression.Position));
{end else
    messagedlg('Der eingegebene Dateiname ist nicht gültig!',mtError,[mbOK],0);}
end;

procedure TForm1.ClientRead(Sender: TObject; Socket: TCustomWinSocket);
var
  daten: TStringDynArray;
begin
  daten := Explode('||',Socket.ReceiveText);
  if daten[0] = 'REPLY' then begin
    if daten[1] = APPVERSION then begin

      {bestätigung für rq_scan}
      if daten[2] = 'RE_SCAN_RUNNING' then begin
        scanid := strtoint(daten[3]);
        button1.Enabled := false;
        button2.Enabled := false;
        status.Text := 'Scanvorgang läuft... Bitte warten!';
      end;
      if daten[2] = 'RE_SCAN_COMPLETE' then begin
        button1.Enabled := true;
        button2.Enabled := true;
        status.Text := 'Scanvorgang abgeschlossen (gespeichert nach '+daten[3]+')';
      end;

      {bestätigung für rq_copy}
      if daten[2] = 'RE_COPY_RUNNING' then begin
        scanid := strtoint(daten[3]);
        button1.Enabled := false;
        button2.Enabled := false;
        status.Text := 'Kopiervorgang läuft... Bitte warten!';
      end;
      if daten[2] = 'RE_COPY_COMPLETE' then begin
        button1.enabled := true;
        button2.Enabled := true;
        status.text := 'Kopiervorgang abgeschlossen.';
      end;

    end else
      messagedlg('Die Antwort konnte nicht verarbeitet werden, weil die Versionen von Server/Client nicht übereinstimmen (Server v'+daten[2]+', Client v'+APPVERSION+')!',mtError,[mbOK],0);
    end;
  if daten[2] = 'RE_ERROR' then begin
    messagedlg('Der Server meldete folgenden Fehler: '+daten[3],mtError,[mbOK],0);
    if daten[4] = 'RESET' then begin
      button1.Enabled := true;
      status.Text := 'Server-Fehler: '+daten[3];
    end;
  end;
end;

procedure TForm1.Button2Click(Sender: TObject);
var
  anzahl: integer;
begin
  anzahl := StrToIntDef(filename.Text,1);
  Client.Socket.SendText('REQUEST||'+APPVERSION+'||RQ_COPY||'+inttostr(anzahl)+'||'+inttostr(jpegcompression.position));
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  if Client.Active = False then begin
  if remotehost.Text = '' then begin
    messagedlg('Es muss ein Hostname angegeben werden!',mtInformation,[mbOK],0);
  end else begin
    if port.Text = '' then
      port.Text := '10089';
    Client.Host := remotehost.Text;
    Client.Port := strtoint(port.Text);
    Client.Active := true;
   end;
  end else
    Client.Active := False;
end;

procedure TForm1.ClientConnect(Sender: TObject; Socket: TCustomWinSocket);
begin
  GroupBox1.Enabled := False;
  Button3.Caption := 'Verbindung trennen';
  GroupBox2.Enabled := True;
  GroupBox3.Enabled := True;
  Button1.Enabled := True;
  BUtton2.Enabled := true;
  status.Text := 'Verbindung zu '+Client.Host+':'+inttostr(Client.Port)+' hergestellt!';
end;

procedure TForm1.ClientDisconnect(Sender: TObject; Socket: TCustomWinSocket);
begin
  GroupBox1.Enabled := True;
  Button3.Caption := 'Verbindung herstellen';
  GroupBox2.Enabled := False;
  GroupBox3.Enabled := False;
  Button1.Enabled := False;
  status.Text := 'Verbindung zu '+Client.Host+':'+inttostr(Client.Port)+' getrennt!';
end;

procedure TForm1.jpegcompressionChange(Sender: TObject);
begin
  label1.Caption := 'JPEG Qualität ('+inttostr(jpegcompression.Position)+')';
end;


procedure TForm1.Beenden1Click(Sender: TObject);
begin
  Form1.Close;
end;

procedure TForm1.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if Client.Active = true then begin
    if messagedlg('Es besteht eine Verbindung mit dem Server. Soll das Programm beendet werden?',mtWarning,[mbYes,mbNo],0) = mrNo then CanClose := false;
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
var
  ini:TIniFile;
begin
  ini := TIniFile.Create(ChangeFileExt(Application.ExeName,'.ini'));
  remotehost.Text := ini.ReadString('verbindung','remotehost','');
  port.Text := ini.ReadString('verbindung','port','');
  ini.Free;
end;

procedure TForm1.ClientError(Sender: TObject; Socket: TCustomWinSocket;
  ErrorEvent: TErrorEvent; var ErrorCode: Integer);
begin
  messagedlg('Bei der Verbindung trat ein Fehler auf!',mtError,[mbOK],0);
  ErrorCode := 0;
end;

procedure TForm1.Info1Click(Sender: TObject);
begin
  aboutbox.ShowModal;
end;

end.
