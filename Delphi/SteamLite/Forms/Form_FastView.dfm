object FastViewForm: TFastViewForm
  Left = 0
  Top = 0
  Caption = '#FastViewForm'
  ClientHeight = 453
  ClientWidth = 605
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Menu = MainMenu1
  OldCreateOrder = False
  Position = poOwnerFormCenter
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object KHexEditor1: TKHexEditor
    Left = 8
    Top = 8
    Width = 589
    Height = 41
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Courier New'
    Font.Pitch = fpFixed
    Font.Style = []
    TabOrder = 0
    Visible = False
  end
  object Memo1: TMemo
    Left = 8
    Top = 55
    Width = 589
    Height = 50
    ScrollBars = ssBoth
    TabOrder = 1
    Visible = False
  end
  object MainMenu1: TMainMenu
    Left = 192
    Top = 8
    object View1: TMenuItem
      Caption = '#View'
      object MM_Hex: TMenuItem
        Caption = '#HexView'
        OnClick = MM_HexClick
      end
      object MM_Text: TMenuItem
        Caption = '#TextView'
        OnClick = MM_TextClick
      end
      object MM_HTML: TMenuItem
        Caption = '#HTMLVView'
        Enabled = False
        OnClick = MM_HTMLClick
      end
      object MM_Media: TMenuItem
        Caption = '#MediaView'
        OnClick = MM_MediaClick
      end
      object MM_Unicode: TMenuItem
        Caption = '#UnicodeView'
        OnClick = MM_UnicodeClick
      end
      object MM_UTF8: TMenuItem
        Caption = '#UTF8View'
        OnClick = MM_UTF8Click
      end
      object N1: TMenuItem
        Caption = '-'
      end
      object MM_CodeWin: TMenuItem
        Caption = '#CodePageWin'
        OnClick = MM_CodeWinClick
      end
      object MM_CodeDOS: TMenuItem
        Caption = '#CodePageDos'
        OnClick = MM_CodeDOSClick
      end
    end
  end
end
