object Form1: TForm1
  Left = 0
  Top = 0
  Width = 477
  Height = 432
  Caption = 'LokiControl Client'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Menu = MainMenu1
  OldCreateOrder = False
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object GroupBox3: TGroupBox
    Left = 8
    Top = 272
    Width = 449
    Height = 105
    Caption = 'Status'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 4
    object Button2: TButton
      Left = 232
      Top = 24
      Width = 193
      Height = 25
      Caption = 'Kopieren'
      Enabled = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 0
      OnClick = Button2Click
    end
  end
  object GroupBox2: TGroupBox
    Left = 8
    Top = 128
    Width = 449
    Height = 129
    Caption = 'Scanner - Einstellungen'
    Enabled = False
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 3
    object Label1: TLabel
      Left = 8
      Top = 64
      Width = 94
      Height = 13
      Caption = 'JPEG Qualit'#228't (100)'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object filename: TLabeledEdit
      Left = 8
      Top = 32
      Width = 417
      Height = 21
      EditLabel.Width = 244
      EditLabel.Height = 13
      EditLabel.Caption = 'Scannen: Dateiname / Kopieren: Anzahl der Kopien'
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
    object jpegcompression: TTrackBar
      Left = 8
      Top = 80
      Width = 417
      Height = 30
      Max = 100
      Position = 100
      TabOrder = 1
      OnChange = jpegcompressionChange
    end
  end
  object GroupBox1: TGroupBox
    Left = 8
    Top = 8
    Width = 449
    Height = 105
    Caption = 'Verbindungseinstellungen'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 2
    object remotehost: TLabeledEdit
      Left = 8
      Top = 32
      Width = 417
      Height = 21
      EditLabel.Width = 205
      EditLabel.Height = 13
      EditLabel.Caption = 'Scanner-Host (IP-Adresse oder Hostname)'
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
    object port: TLabeledEdit
      Left = 8
      Top = 72
      Width = 97
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
      TabOrder = 1
    end
  end
  object Button1: TButton
    Left = 32
    Top = 296
    Width = 201
    Height = 25
    Caption = 'Scannen'
    Enabled = False
    TabOrder = 0
    OnClick = Button1Click
  end
  object Button3: TButton
    Left = 320
    Top = 72
    Width = 121
    Height = 25
    Caption = 'Verbindung herstellen'
    TabOrder = 1
    OnClick = Button3Click
  end
  object status: TEdit
    Left = 16
    Top = 344
    Width = 425
    Height = 21
    Enabled = False
    TabOrder = 5
  end
  object Client: TClientSocket
    Active = False
    ClientType = ctNonBlocking
    Port = 10089
    OnConnect = ClientConnect
    OnDisconnect = ClientDisconnect
    OnRead = ClientRead
    OnError = ClientError
    Left = 152
    Top = 72
  end
  object MainMenu1: TMainMenu
    Left = 192
    Top = 72
    object Datei1: TMenuItem
      Caption = 'Datei'
      object Beenden1: TMenuItem
        Caption = '&Beenden'
        ShortCut = 16499
        OnClick = Beenden1Click
      end
    end
    object Info1: TMenuItem
      Caption = 'Info...'
      OnClick = Info1Click
    end
  end
end
