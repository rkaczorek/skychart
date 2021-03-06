object Form1: TForm1
  Left = 207
  Top = 121
  Caption = 'Guide Star Catalogue  conversion utility'
  ClientHeight = 394
  ClientWidth = 427
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = True
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 52
    Width = 130
    Height = 13
    Caption = 'Source FITS format CD-rom'
  end
  object Label2: TLabel
    Left = 8
    Top = 84
    Width = 77
    Height = 13
    Caption = 'Destination path'
  end
  object Label3: TLabel
    Left = 56
    Top = 16
    Width = 344
    Height = 16
    Caption = 'I/220  The HST Guide Star Catalog (Lasker+ 1992)'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label4: TLabel
    Left = 336
    Top = 52
    Width = 25
    Height = 13
    Caption = 'Zone'
  end
  object SpeedButton1: TSpeedButton
    Left = 304
    Top = 48
    Width = 20
    Height = 20
    Caption = '...'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    OnClick = SpeedButton1Click
  end
  object SpeedButton2: TSpeedButton
    Left = 304
    Top = 80
    Width = 20
    Height = 20
    Caption = '...'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    OnClick = SpeedButton2Click
  end
  object Button1: TButton
    Left = 16
    Top = 192
    Width = 75
    Height = 25
    Caption = 'Conversion'
    TabOrder = 5
    OnClick = Button1Click
  end
  object Edit1: TEdit
    Left = 144
    Top = 48
    Width = 161
    Height = 21
    TabOrder = 0
    Text = 'E:\GSC'
  end
  object Edit2: TEdit
    Left = 144
    Top = 80
    Width = 161
    Height = 21
    TabOrder = 2
    Text = 'C:\ciel\cat\gsc'
  end
  object Edit3: TEdit
    Left = 200
    Top = 192
    Width = 217
    Height = 21
    TabStop = False
    Color = clBtnFace
    ReadOnly = True
    TabOrder = 7
  end
  object Button2: TButton
    Left = 112
    Top = 192
    Width = 75
    Height = 25
    Caption = 'Exit'
    TabOrder = 6
    OnClick = Button2Click
  end
  object Panel1: TPanel
    Left = 8
    Top = 144
    Width = 409
    Height = 33
    TabOrder = 4
    object nonstellar: TCheckBox
      Left = 248
      Top = 8
      Width = 153
      Height = 17
      Caption = 'Remove non stellar objects'
      TabOrder = 1
    end
    object multiple: TCheckBox
      Left = 8
      Top = 8
      Width = 217
      Height = 17
      Caption = 'Remove multipe entries for the same star'
      TabOrder = 0
    end
  end
  object Memo1: TMemo
    Left = 4
    Top = 224
    Width = 425
    Height = 177
    Lines.Strings = (
      
        'This program convert the HST Guide Star Catalogue from the origi' +
        'nal FITS format '
      'CD-rom for use with "Cartes du Ciel" / "Sky Charts" program. '
      
        'You may run this utility only if you want to put the Guide Star ' +
        'on hard disk, otherwise '
      '"Sky Chart" might use the CD-rom directly. '
      
        'The GSC Compact version must be used directly by Cartes du Ciel ' +
        'but not by this '
      'program.'
      
        'In the first field enter the complete directory path to the zone' +
        ' directory of the original '
      'catalogue.'
      'In the second the individual zone to convert.'
      
        'In the third field enter the path where to install the converted' +
        ' catalog , '
      'I suggest you keep the default: <Sky Chart path>\cat\gsc'
      
        'For the complete catalogue you must have 480 MB free disk space ' +
        'on the '
      'destination '
      'directory but less if you convert only a few declination zones.'
      
        'If you check the box "Remove multiple entries" then only the fir' +
        'st occurence of stars '
      
        'with the "multiple" flag will be keep, this save aproximately 30' +
        '% of space without '
      'effect on chart quality.'
      
        'If you check the box "Remove non stellar objects" then all objec' +
        't with the "class" '
      
        'code different from 0 or 2 will be rejected, this save 15% of sp' +
        'ace but may cause the '
      'rejection of real stars in crowded fields.'
      'When the two options are checked this save globaly 40% of space.'
      'Press "Conversion" key and be patient... '
      
        'Each zone may take from five to thirty minutes to complete, depe' +
        'nding on your '
      'machine. '
      'When it finish press "Exit" key.')
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 8
  end
  object RadioGroup1: TRadioGroup
    Left = 8
    Top = 104
    Width = 409
    Height = 33
    Columns = 3
    ItemIndex = 0
    Items.Strings = (
      'Individual zone'
      'All Northern zones'
      'All Southern zones')
    TabOrder = 3
    OnClick = RadioGroup1Click
  end
  object Edit4: TEdit
    Left = 368
    Top = 48
    Width = 49
    Height = 21
    TabOrder = 1
    Text = 'N0000'
  end
end
