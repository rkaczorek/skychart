object f_search: Tf_search
  Left = 193
  Top = 133
  BorderStyle = bsToolWindow
  Caption = 'Search'
  ClientHeight = 401
  ClientWidth = 533
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -14
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 120
  TextHeight = 16
  object PlanetPanel: TPanel
    Left = 8
    Top = 286
    Width = 513
    Height = 50
    TabOrder = 4
    object Label2: TLabel
      Left = 16
      Top = 17
      Width = 41
      Height = 16
      Caption = 'Planet '
    end
    object PlanetBox: TComboBox
      Left = 108
      Top = 13
      Width = 141
      Height = 24
      ItemHeight = 16
      TabOrder = 0
    end
  end
  object NebNamePanel: TPanel
    Left = 8
    Top = 286
    Width = 513
    Height = 50
    TabOrder = 5
    object Label3: TLabel
      Left = 16
      Top = 17
      Width = 44
      Height = 16
      Caption = 'Nebula'
    end
    object NebNameBox: TComboBox
      Left = 108
      Top = 13
      Width = 365
      Height = 24
      ItemHeight = 16
      TabOrder = 0
    end
  end
  object StarNamePanel: TPanel
    Left = 8
    Top = 286
    Width = 513
    Height = 50
    TabOrder = 6
    object Label4: TLabel
      Left = 16
      Top = 17
      Width = 24
      Height = 16
      Caption = 'Star'
    end
    object StarNameBox: TComboBox
      Left = 108
      Top = 13
      Width = 357
      Height = 24
      ItemHeight = 16
      TabOrder = 0
    end
  end
  object ConstPanel: TPanel
    Left = 8
    Top = 286
    Width = 513
    Height = 50
    TabOrder = 7
    object Label5: TLabel
      Left = 16
      Top = 17
      Width = 77
      Height = 16
      Caption = 'Constellation'
    end
    object ConstBox: TComboBox
      Left = 108
      Top = 13
      Width = 357
      Height = 24
      ItemHeight = 16
      TabOrder = 0
    end
  end
  object IDPanel: TPanel
    Left = 8
    Top = 286
    Width = 513
    Height = 50
    TabOrder = 0
    object Label1: TLabel
      Left = 10
      Top = 17
      Width = 79
      Height = 16
      Caption = 'Object Name'
    end
    object DblPanel: TPanel
      Left = 258
      Top = 1
      Width = 90
      Height = 48
      TabOrder = 5
      object SpeedButton30: TSpeedButton
        Left = 0
        Top = 2
        Width = 44
        Height = 23
        Caption = 'ADS'
        OnClick = CatButtonClick
      end
      object SpeedButton31: TSpeedButton
        Left = 44
        Top = 2
        Width = 45
        Height = 23
        Caption = 'STF'
        OnClick = CatButtonClick
      end
    end
    object VarPanel: TPanel
      Left = 258
      Top = 1
      Width = 90
      Height = 48
      TabOrder = 4
      object SpeedButton21: TSpeedButton
        Left = 0
        Top = 2
        Width = 22
        Height = 23
        Caption = 'R'
        OnClick = NumButtonClick
      end
      object SpeedButton24: TSpeedButton
        Left = 22
        Top = 2
        Width = 22
        Height = 23
        Caption = 'S'
        OnClick = NumButtonClick
      end
      object SpeedButton25: TSpeedButton
        Left = 0
        Top = 25
        Width = 22
        Height = 22
        Caption = 'V'
        OnClick = NumButtonClick
      end
      object SpeedButton26: TSpeedButton
        Left = 44
        Top = 25
        Width = 45
        Height = 22
        Caption = 'NSV'
        OnClick = CatButtonClick
      end
      object SpeedButton27: TSpeedButton
        Left = 44
        Top = 2
        Width = 22
        Height = 23
        Caption = 'T'
        OnClick = NumButtonClick
      end
      object SpeedButton28: TSpeedButton
        Left = 66
        Top = 2
        Width = 23
        Height = 23
        Caption = 'U'
        OnClick = NumButtonClick
      end
      object SpeedButton29: TSpeedButton
        Left = 22
        Top = 25
        Width = 22
        Height = 22
        Caption = 'W'
        OnClick = NumButtonClick
      end
    end
    object StarPanel: TPanel
      Left = 258
      Top = 1
      Width = 90
      Height = 48
      TabOrder = 3
      object SpeedButton19: TSpeedButton
        Left = 0
        Top = 2
        Width = 44
        Height = 23
        Caption = 'TYC'
        OnClick = CatButtonClick
      end
      object SpeedButton20: TSpeedButton
        Left = 44
        Top = 2
        Width = 45
        Height = 23
        Caption = 'GSC'
        OnClick = CatButtonClick
      end
      object SpeedButton22: TSpeedButton
        Left = 0
        Top = 25
        Width = 44
        Height = 22
        Caption = 'HD'
        OnClick = CatButtonClick
      end
      object SpeedButton23: TSpeedButton
        Left = 44
        Top = 25
        Width = 45
        Height = 22
        Caption = 'BD'
        OnClick = CatButtonClick
      end
    end
    object Id: TEdit
      Left = 108
      Top = 12
      Width = 139
      Height = 24
      TabOrder = 0
      OnKeyDown = IdKeyDown
    end
    object NumPanel: TPanel
      Left = 354
      Top = 1
      Width = 158
      Height = 48
      BevelOuter = bvNone
      TabOrder = 1
      object SpeedButton1: TSpeedButton
        Left = 0
        Top = 2
        Width = 22
        Height = 23
        Caption = '1'
        OnClick = NumButtonClick
      end
      object SpeedButton2: TSpeedButton
        Left = 22
        Top = 2
        Width = 22
        Height = 23
        Caption = '2'
        OnClick = NumButtonClick
      end
      object SpeedButton3: TSpeedButton
        Left = 44
        Top = 2
        Width = 22
        Height = 23
        Caption = '3'
        OnClick = NumButtonClick
      end
      object SpeedButton4: TSpeedButton
        Left = 66
        Top = 2
        Width = 23
        Height = 23
        Caption = '4'
        OnClick = NumButtonClick
      end
      object SpeedButton5: TSpeedButton
        Left = 89
        Top = 2
        Width = 22
        Height = 23
        Caption = '5'
        OnClick = NumButtonClick
      end
      object SpeedButton6: TSpeedButton
        Left = 0
        Top = 25
        Width = 22
        Height = 22
        Caption = '6'
        OnClick = NumButtonClick
      end
      object SpeedButton7: TSpeedButton
        Left = 22
        Top = 25
        Width = 22
        Height = 22
        Caption = '7'
        OnClick = NumButtonClick
      end
      object SpeedButton8: TSpeedButton
        Left = 44
        Top = 25
        Width = 22
        Height = 22
        Caption = '8'
        OnClick = NumButtonClick
      end
      object SpeedButton9: TSpeedButton
        Left = 66
        Top = 25
        Width = 23
        Height = 22
        Caption = '9'
        OnClick = NumButtonClick
      end
      object SpeedButton10: TSpeedButton
        Left = 89
        Top = 25
        Width = 22
        Height = 22
        Caption = '0'
        OnClick = NumButtonClick
      end
      object SpeedButton11: TSpeedButton
        Left = 111
        Top = 2
        Width = 22
        Height = 23
        Caption = '<-'
        OnClick = SpeedButton11Click
      end
      object SpeedButton12: TSpeedButton
        Left = 111
        Top = 25
        Width = 44
        Height = 22
        Caption = ' '
        OnClick = NumButtonClick
      end
      object SpeedButton13: TSpeedButton
        Left = 133
        Top = 2
        Width = 22
        Height = 23
        Caption = 'C'
        OnClick = SpeedButton13Click
      end
    end
    object NebPanel: TPanel
      Left = 258
      Top = 1
      Width = 90
      Height = 48
      TabOrder = 2
      object SpeedButton14: TSpeedButton
        Left = 0
        Top = 2
        Width = 22
        Height = 23
        Caption = 'M'
        OnClick = CatButtonClick
      end
      object SpeedButton15: TSpeedButton
        Left = 22
        Top = 2
        Width = 44
        Height = 23
        Caption = 'NGC'
        OnClick = CatButtonClick
      end
      object SpeedButton16: TSpeedButton
        Left = 66
        Top = 2
        Width = 23
        Height = 23
        Caption = 'IC'
        OnClick = CatButtonClick
      end
      object SpeedButton17: TSpeedButton
        Left = 0
        Top = 25
        Width = 44
        Height = 22
        Caption = 'PGC'
        OnClick = CatButtonClick
      end
      object SpeedButton18: TSpeedButton
        Left = 44
        Top = 25
        Width = 45
        Height = 22
        Caption = 'PK'
        OnClick = CatButtonClick
      end
    end
  end
  object RadioGroup1: TRadioGroup
    Left = 8
    Top = 10
    Width = 513
    Height = 267
    Caption = 'Search for '
    Columns = 2
    ItemIndex = 0
    Items.Strings = (
      'Nebulae'
      'Nebula Common Name'
      'Stars'
      'Star Common Name'
      'Variable Stars'
      'Double Stars'
      'Comets'
      'Asteroids'
      'Planets'
      'Constellation'
      'Other Lines Catalogs')
    TabOrder = 1
    OnClick = RadioGroup1Click
  end
  object Button1: TButton
    Left = 158
    Top = 354
    Width = 92
    Height = 31
    Caption = 'Find'
    TabOrder = 2
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 286
    Top = 354
    Width = 92
    Height = 31
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 3
  end
end
