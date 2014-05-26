object PropertiesForm: TPropertiesForm
  Left = 0
  Top = 0
  BorderStyle = bsToolWindow
  Caption = '#Properties'
  ClientHeight = 269
  ClientWidth = 400
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
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 384
    Height = 13
    AutoSize = False
    Caption = '#File'
  end
  object Label2: TLabel
    Left = 8
    Top = 61
    Width = 91
    Height = 13
    Alignment = taRightJustify
    AutoSize = False
    Caption = '#Size'
  end
  object L_Size: TLabel
    Left = 105
    Top = 61
    Width = 112
    Height = 32
    AutoSize = False
    WordWrap = True
  end
  object Label4: TLabel
    Left = 223
    Top = 61
    Width = 91
    Height = 13
    Alignment = taRightJustify
    AutoSize = False
    Caption = '#Completion'
  end
  object L_Completion: TLabel
    Left = 320
    Top = 61
    Width = 72
    Height = 32
    AutoSize = False
  end
  object Ed_FileName: TEdit
    Left = 8
    Top = 27
    Width = 384
    Height = 21
    BevelOuter = bvRaised
    Color = clBtnFace
    Ctl3D = True
    ParentCtl3D = False
    ReadOnly = True
    TabOrder = 0
    Text = 'Ed_FileName'
  end
  object Panel1: TPanel
    Left = 0
    Top = 54
    Width = 400
    Height = 1
    TabOrder = 1
  end
  object Panel2: TPanel
    Left = 0
    Top = 105
    Width = 400
    Height = 1
    TabOrder = 2
  end
  object VLE_Fields: TValueListEditor
    Left = 8
    Top = 112
    Width = 384
    Height = 145
    TabOrder = 3
    TitleCaptions.Strings = (
      '#Flag'
      '#Value')
    ColWidths = (
      197
      181)
  end
end
