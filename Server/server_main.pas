unit server_main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ScktComp, StdCtrls, EzTWAIN, dib, ExtCtrls, JPEG, inifiles, ShellAPI, printers, RegExpr;

type
  TStringDynArray = array of string;
  TForm2 = class(TForm)
    Server: TServerSocket;
    statusbox: TGroupBox;
    Einstellungen: TGroupBox;
    port: TLabeledEdit;
    Befehle: TGroupBox;
    activateserver: TButton;
    refreshini: TButton;
    sendtotray: TButton;
    clients: TListBox;
    totalremotes: TLabel;
    status: TEdit;
    Label1: TLabel;
    Button1: TButton;
    Button2: TButton;
    procedure Button2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure refreshiniClick(Sender: TObject);
    procedure ServerClientDisconnect(Sender: TObject; Socket: TCustomWinSocket);
    procedure ServerClientConnect(Sender: TObject; Socket: TCustomWinSocket);
    procedure activateserverClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ServerClientRead(Sender: TObject; Socket: TCustomWinSocket);
    procedure scan(filename:string; jpegcompression:integer; socket:TCustomWinSocket);
    procedure copyscan(anzahl:integer; socket:TCustomWinSocket);
  private
  public
    { Public declarations }

  end;

var
  Form2: TForm2;
  logfilename,localdir,sendbackdir: string;
  forcedcompression,clientsconnected: integer;
  locked: boolean;

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

procedure TForm2.ServerClientRead(Sender: TObject; Socket: TCustomWinSocket);
var
  daten: TStringDynArray;
  incoming: string;
  logfile: TextFile;
  today:TDateTime;
begin
  if locked = false then begin
  incoming := Socket.ReceiveText;
  daten := explode('||',incoming);

  {LOGFILE}
  today := now;
  AssignFile(logfile,logfilename);
  if not FileExists(logfilename) then
    ReWrite(logfile);
  Append(logfile);
  WriteLn(logfile,'['+DateToStr(today)+' @ '+TimeToStr(today)+'] '+daten[0]+' for '+daten[2]+' from '+Socket.RemoteHost+':'+inttostr(Socket.LocalPort)+' {'+daten[3]+'}');
  CloseFile(logfile);
  {END LOGFILE}

  status.Text := daten[2]+' von '+Socket.RemoteHost+' empfangen!';

  // Entscheiden, was der Request von uns will
  if daten[0] = 'REQUEST' then begin
    if daten[1] = APPVERSION then begin
      if daten[2] = 'RQ_SCAN' then
        scan(daten[3],strtoint(daten[4]),Socket);
      if daten[2] = 'RQ_COPY' then
        copyscan(strtoint(daten[3]),Socket);
    end;
  end else
    Socket.SendText('REPLY||'+APPVERSION+'||RE_ERROR||Server/Client Version sind nicht gleich! [Server v'+APPVERSION+']||RESET');

  end else
    Socket.SendText('REPLY||'+APPVERSION+'||RE_ERROR||Server ist zur Zeit beschäftigt!||RESET');
end;

procedure TForm2.scan(filename:string; jpegcompression:integer; socket:TCustomWinSocket);
var
  tmp:Cardinal;
  jpeg:TJPEGImage;
  image:TBitmap;
begin
if TWAIN_IsAvailable = 1 then
begin
  locked := true;
  socket.SendText('REPLY||'+APPVERSION+'||RE_SCAN_RUNNING||'+inttostr(Random(100000)));
  TWAIN_SetHideUI(1);

  status.Text := 'Scanvorgang für '+socket.RemoteHost+' nach '+filename;
  tmp := TWAIN_AcquireNative(0,0);

  if tmp<>0 then begin
      image := TBitmap.Create;
      load_dib_into_bitmap(tmp,image);
      TWAIN_FreeNative(tmp);
      jpeg := TJPEGImage.Create;
      if forcedcompression = -1 then
      begin
        jpeg.CompressionQuality := jpegcompression;
      end else
        jpeg.CompressionQuality := forcedcompression;
      jpeg.Assign(image);
     {if not ExecRegExpr('^(?:[^\/\\:*?""<>|]+)\.jpg$',LowerCase(filename)) then}
        filename := filename+'.jpg';
      while FileExists(localdir+filename) do
        begin
          filename := Copy(filename,0,length(filename)-(length(ExtractFileExt(localdir+filename))))+inttostr(Random(10))+ExtractFileExt(localdir+filename);
        end;
      jpeg.SaveToFile(localdir+filename);
      image.Free;
      jpeg.Free;
      socket.SendText('REPLY||'+APPVERSION+'||RE_SCAN_COMPLETE||'+sendbackdir+filename);
      filename := '';
      status.Text := 'Scan für '+socket.RemoteHost+' fertig!';
      TWAIN_CloseSource;
    end else
      socket.SendText('REPlY||'+APPVERSION+'||RE_ERROR||Das Gerät hat kein gültiges Bild zurückgegeben!||RESET');
  end else
    socket.SendText('REPLY||'+APPVERSION+'||RE_ERROR||TWAIN ist nicht installiert!||RESET');

  locked := false;
end;

procedure TForm2.copyscan(anzahl:integer; socket:TCustomWinSocket);
var
copytemp:Cardinal;
copyimage:TBitmap;
strechrect:TRect;
x:integer;
begin
if TWAIN_IsAvailable = 1 then
begin
  locked := true;
  socket.SendText('REPLY||'+APPVERSION+'||RE_COPY_RUNNING||'+inttostr(Random(100000)));
  TWAIN_SetHideUI(1);
  status.Text := 'Kopiervorgang für '+socket.RemoteHost+' ('+inttostr(anzahl)+' Kopien)';
  copytemp := TWAIN_AcquireNative(0,0);

  if copytemp<>0 then begin
      copyimage := TBitmap.Create;
      load_dib_into_bitmap(copytemp,copyimage);
      TWAIN_FreeNative(copytemp);

      { druckprozess }
      strechrect.Top := 0;
      strechrect.Left := 0;
      strechrect.Right := Printer.PageWidth;
      strechrect.Bottom := Printer.PageHeight;
      with Printer do begin
      for x:=1 to anzahl do
        begin
          BeginDoc;
          Canvas.StretchDraw(strechrect,copyimage);
          EndDoc;
        end;
      end;
      { / druckprozess }
      
      copyimage.Free;
      socket.SendText('REPLY||'+APPVERSION+'||RE_COPY_COMPLETE||'+inttostr(anzahl));

      status.Text := 'Kopiervorgang für '+socket.RemoteHost+' fertig ('+inttostr(anzahl)+' Kopien)!';
    end else
      socket.SendText('REPlY||'+APPVERSION+'||RE_ERROR||Das Gerät hat kein gültiges Bild zurückgegeben!||RESET');
  end else
    socket.SendText('REPLY||'+APPVERSION+'||RE_ERROR||TWAIN ist nicht installiert!||RESET');

  locked := false;
end;

procedure TForm2.FormCreate(Sender: TObject);
var
  ini:TIniFile;
begin
  ini := TIniFile.Create(ChangeFileExt(Application.ExeName,'.ini'));
  logfilename := ini.ReadString('misc','logfile',ChangeFileExt(Application.ExeName,'.log'));
  localdir := ini.ReadString('speicher','dir1','');
  sendbackdir := ini.ReadString('speicher','dir2','');
  if ini.ReadString('scanner','jpegcompression','') = '' then
    begin forcedcompression := -1; end
  else
    forcedcompression := strtoint(ini.ReadString('scanner','jpegcompression',''));
  if ini.ReadInteger('misc','autoenable',1) = 1 then
    activateserverClick(Sender);
  ini.Free;
  { free twain source }
  Button2Click(Sender);
end;

procedure TForm2.activateserverClick(Sender: TObject);
begin
  if Server.Active = False then
  begin
    if port.Text = '' then
      port.text := '10089';
    Server.Port := strtoint(port.Text);
    Server.Active := True;
    { free open twain sources }
    Button2Click(Sender);
    activateserver.Caption := 'Server deaktivieren';
    port.Enabled := False;
    refreshini.Enabled := False;
  end else
  begin
    Server.Active := False;
    clients.Items.Clear;
    activateserver.Caption := 'Server aktivieren';
    port.enabled := true;
    clientsconnected := 0;
    totalremotes.Caption := 'Insgesamt sind 0 Clients verbunden!';
    refreshini.Enabled := True;
  end;
end;

procedure TForm2.ServerClientConnect(Sender: TObject; Socket: TCustomWinSocket);
begin
  clients.Items.Add(Socket.RemoteHost);
  clientsconnected := clientsconnected+1;
  totalremotes.Caption := 'Insgesamt sind '+inttostr(clientsconnected)+' Clients verbunden!';
end;

procedure TForm2.ServerClientDisconnect(Sender: TObject;
  Socket: TCustomWinSocket);
begin
  clients.Items.Delete(clients.Items.IndexOf(Socket.RemoteHost));
  clientsconnected := clientsconnected-1;
  totalremotes.Caption := 'Insgesamt sind '+inttostr(clientsconnected)+' Clients verbunden!';
end;

procedure TForm2.refreshiniClick(Sender: TObject);
begin
  FormCreate(Sender);
  messagedlg('Die Datei '+ChangeFileExt(Application.ExeName,'.ini')+' wurde neu eingelesen!',mtInformation,[mbOK],0);
end;

procedure TForm2.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if clientsconnected > 0 then begin
    if messagedlg('Es sind noch '+inttostr(clientsconnected)+' Clients mit dem Server verbunden. Soll trotzdem beendet werden?',mtWarning,[mbYes,mbNo],0) = mrNo then
    begin
      CanClose := false;
    end else
      Application.Terminate;
  end;
end;

procedure TForm2.Button1Click(Sender: TObject);
var
  data:string;
  clientini:TextFile;
begin
  data := '; LokiControl Client Configfile'+#13#10#13#10
         +'[verbindung]'+#13#10
         +'remotehost='+GetEnvironmentVariable('COMPUTERNAME')+#13#10
         +'port='+port.Text;
  showmessage(data+#13#10#13#10+'gespeichert nach '+ExtractFileDir(Application.ExeName)+'\client.ini');
  AssignFile(clientini,'client.ini');
  ReWrite(clientini);
  WriteLn(clientini,data);
  CloseFile(clientini);
end;

procedure TForm2.Button2Click(Sender: TObject);
begin
  TWAIN_DisableSource;
  TWAIN_CloseSource;
  locked := false;
end;

end.
