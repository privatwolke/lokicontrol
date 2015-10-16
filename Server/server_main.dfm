object Form2: TForm2
  Left = 0
  Top = 0
  Width = 347
  Height = 400
  Caption = 'LokiControl Server'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object statusbox: TGroupBox
    Left = 8
    Top = 8
    Width = 321
    Height = 177
    Caption = 'Status'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 0
    object totalremotes: TLabel
      Left = 8
      Top = 152
      Width = 175
      Height = 13
      Caption = 'Insgesamt sind 0 Clients verbunden!'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsItalic]
      ParentFont = False
    end
    object Label1: TLabel
      Left = 8
      Top = 56
      Width = 93
      Height = 13
      Caption = 'Verbundene Clients'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object clients: TListBox
      Left = 8
      Top = 72
      Width = 305
      Height = 73
      Hint = 'Zeigt die aktuell verbundenen Clients an'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ItemHeight = 13
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 0
    end
    object status: TEdit
      Left = 8
      Top = 24
      Width = 305
      Height = 21
      Enabled = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 1
    end
  end
  object Einstellungen: TGroupBox
    Left = 8
    Top = 192
    Width = 321
    Height = 73
    Caption = 'Einstellungen'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 1
    object port: TLabeledEdit
      Left = 8
      Top = 32
      Width = 105
      Height = 21
      EditLabel.Width = 20
      EditLabel.Height = 13
      EditLabel.Caption = 'Port'
      EditLabel.Font.Charset = DEFAULT_CHARSET
      EditLabel.Font.Color = clWindowText
      EditLabel.Font.Height = -11
      EditLabel.Font.Name = 'Tahoma'
      EditLabel.Font.Style = []
      EditLabel.ParentFont = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 0
    end
    object Button1: TButton
      Left = 200
      Top = 16
      Width = 105
      Height = 25
      Caption = 'erstelle Client.ini'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 1
      OnClick = Button1Click
    end
    object Button2: TButton
      Left = 200
      Top = 40
      Width = 105
      Height = 25
      Caption = 'reset TWAIN'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 2
      OnClick = Button2Click
    end
  end
  object Befehle: TGroupBox
    Left = 8
    Top = 272
    Width = 321
    Height = 97
    Caption = 'Befehle'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 2
    object activateserver: TButton
      Left = 16
      Top = 24
      Width = 113
      Height = 25
      Caption = 'Server aktivieren'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 0
      OnClick = activateserverClick
    end
    object refreshini: TButton
      Left = 192
      Top = 24
      Width = 113
      Height = 25
      Caption = '.ini Datei neu einlesen'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 1
      OnClick = refreshiniClick
    end
    object sendtotray: TButton
      Left = 104
      Top = 56
      Width = 113
      Height = 25
      Caption = 'Fenster verstecken'
      Enabled = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 2
    end
  end
  object Server: TServerSocket
    Active = False
    Port = 10089
    ServerType = stNonBlocking
    OnClientConnect = ServerClientConnect
    OnClientDisconnect = ServerClientDisconnect
    OnClientRead = ServerClientRead
    Left = 144
    Top = 216
  end
end
