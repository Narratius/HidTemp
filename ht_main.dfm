object MainForm: TMainForm
  Left = 513
  Top = 441
  Caption = #1044#1072#1090#1095#1080#1082' '#1090#1077#1084#1087#1077#1088#1072#1090#1091#1088#1099
  ClientHeight = 510
  ClientWidth = 660
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Menu = MainMenu1
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object ChartTemp: TChart
    Left = 0
    Top = 41
    Width = 660
    Height = 469
    Legend.Visible = False
    Title.Text.Strings = (
      #1048#1079#1084#1077#1085#1077#1085#1080#1077' '#1090#1077#1084#1087#1077#1088#1072#1090#1091#1088#1099)
    BottomAxis.Title.Caption = #1042#1088#1077#1084#1103' '#1080#1079#1084#1077#1088#1077#1085#1080#1103
    LeftAxis.Automatic = False
    LeftAxis.AutomaticMaximum = False
    LeftAxis.AutomaticMinimum = False
    LeftAxis.Maximum = 425.000000000000000000
    LeftAxis.MaximumOffset = 10
    LeftAxis.Minimum = 25.000000000000000000
    LeftAxis.Title.Caption = #1043#1088#1072#1076#1091#1089#1099' '#1062#1077#1083#1100#1089#1080#1103
    Align = alClient
    TabOrder = 0
    DefaultCanvas = 'TGDIPlusCanvas'
    PrintMargins = (
      15
      11
      15
      11)
    ColorPaletteIndex = 13
    object Series1: TLineSeries
      ColorEachPoint = True
      Brush.BackColor = clDefault
      Pointer.InflateMargins = True
      Pointer.Style = psRectangle
      XValues.Name = 'X'
      XValues.Order = loAscending
      YValues.Name = 'Y'
      YValues.Order = loNone
      object TSmoothingFunction
        CalcByValue = False
        Period = 1.000000000000000000
        Factor = 8
      end
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 660
    Height = 41
    Align = alTop
    TabOrder = 1
    DesignSize = (
      660
      41)
    object Label1: TLabel
      Left = 8
      Top = 4
      Width = 48
      Height = 23
      Caption = #1052#1080#1085#1080#1084#1091#1084
    end
    object Label2: TLabel
      Left = 8
      Top = 19
      Width = 54
      Height = 13
      Caption = #1052#1072#1082#1089#1080#1084#1091#1084
    end
    object ComboInterval: TComboBox
      Left = 496
      Top = 8
      Width = 145
      Height = 21
      Style = csDropDownList
      Anchors = [akTop, akRight]
      TabOrder = 0
      OnChange = ComboIntervalChange
      Items.Strings = (
        #1079#1072' 1 '#1095#1072#1089
        #1079#1072' 2 '#1095#1072#1089#1072
        #1079#1072' 8 '#1095#1072#1089#1086#1074
        #1079#1072' '#1089#1091#1090#1082#1080
        #1074#1089#1077' '#1080#1079#1084#1077#1088#1077#1085#1080#1103)
    end
  end
  object Timer1: TTimer
    Interval = 30000
    OnTimer = Timer1Timer
    Left = 160
    Top = 16
  end
  object MainMenu1: TMainMenu
    Left = 424
    Top = 16
    object N1: TMenuItem
      Caption = #1060#1072#1081#1083
      object N2: TMenuItem
        Action = actConfig
      end
      object N3: TMenuItem
        Action = actExit
      end
    end
  end
  object ActionList1: TActionList
    Left = 376
    Top = 16
    object actExit: TAction
      Caption = ' '#1042#1099#1093#1086#1076
      OnExecute = actExitExecute
    end
    object actConfig: TAction
      Caption = #1053#1072#1089#1090#1088#1086#1081#1082#1080
    end
  end
  object XPManifest1: TXPManifest
    Left = 480
    Top = 305
  end
end
