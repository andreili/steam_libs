object Form_AppProperties: TForm_AppProperties
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsToolWindow
  Caption = '#ApplicationProperties'
  ClientHeight = 400
  ClientWidth = 570
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 570
    Height = 99
    Align = alTop
    AutoSize = True
    BevelOuter = bvNone
    BorderWidth = 5
    TabOrder = 0
    object Label1: TLabel
      Left = 8
      Top = 5
      Width = 119
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = '#Name'
    end
    object L_Name: TLabel
      Left = 133
      Top = 5
      Width = 429
      Height = 13
      AutoSize = False
    end
    object L_CommonPath: TLabel
      Left = 133
      Top = 24
      Width = 429
      Height = 13
      AutoSize = False
    end
    object Label4: TLabel
      Left = 8
      Top = 24
      Width = 119
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = '#CommonPath'
    end
    object L_Developer: TLabel
      Left = 133
      Top = 43
      Width = 429
      Height = 13
      AutoSize = False
    end
    object Label6: TLabel
      Left = 8
      Top = 43
      Width = 119
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = '#DeveloperEx'
    end
    object L_HomePage: TLabel
      Left = 133
      Top = 62
      Width = 429
      Height = 13
      AutoSize = False
    end
    object Label8: TLabel
      Left = 8
      Top = 62
      Width = 119
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = '#Homepage'
    end
    object L_AppID: TLabel
      Left = 133
      Top = 81
      Width = 119
      Height = 13
      AutoSize = False
    end
    object Label10: TLabel
      Left = 8
      Top = 81
      Width = 119
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = '#AppID'
    end
    object L_Size: TLabel
      Left = 383
      Top = 81
      Width = 119
      Height = 13
      AutoSize = False
    end
    object Label12: TLabel
      Left = 258
      Top = 81
      Width = 119
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = '#SizeEx'
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 99
    Width = 570
    Height = 2
    Align = alTop
    BevelOuter = bvLowered
    TabOrder = 1
    ExplicitTop = 105
  end
  object Panel3: TPanel
    Left = 0
    Top = 101
    Width = 570
    Height = 179
    Align = alClient
    AutoSize = True
    BevelOuter = bvNone
    BorderWidth = 5
    TabOrder = 2
    ExplicitHeight = 175
    object Label13: TLabel
      Left = 5
      Top = 5
      Width = 75
      Height = 13
      Align = alTop
      Caption = '#CacheFilesList'
    end
    object LV_Caches: TListView
      Left = 5
      Top = 18
      Width = 560
      Height = 150
      Align = alTop
      Columns = <
        item
          Caption = '#FileName'
          Width = 200
        end
        item
          Caption = '#ID'
        end
        item
          Caption = '#Size'
          Width = 75
        end
        item
          Caption = '#Version'
          Width = 100
        end
        item
          Caption = '#Loaded'
          Width = 100
        end>
      GridLines = True
      ReadOnly = True
      RowSelect = True
      TabOrder = 0
      ViewStyle = vsReport
      ExplicitLeft = 40
      ExplicitTop = 56
      ExplicitWidth = 250
    end
  end
  object Panel4: TPanel
    Left = 0
    Top = 282
    Width = 570
    Height = 118
    Align = alBottom
    BevelOuter = bvNone
    BorderWidth = 5
    TabOrder = 3
    object LV_UDR: TListView
      Left = 5
      Top = 5
      Width = 560
      Height = 108
      Align = alClient
      Columns = <
        item
          Caption = '#RecordName'
          Width = 150
        end
        item
          Caption = '#RecordValue'
          Width = 250
        end>
      GridLines = True
      ReadOnly = True
      RowSelect = True
      TabOrder = 0
      ViewStyle = vsReport
      ExplicitLeft = 64
      ExplicitTop = 32
      ExplicitWidth = 250
      ExplicitHeight = 150
    end
  end
  object Panel5: TPanel
    Left = 0
    Top = 280
    Width = 570
    Height = 2
    Align = alBottom
    BevelOuter = bvLowered
    TabOrder = 4
    ExplicitLeft = 192
    ExplicitTop = 296
    ExplicitWidth = 185
  end
end
