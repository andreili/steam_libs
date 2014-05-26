object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 323
  ClientWidth = 653
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object TabbedNotebook1: TTabbedNotebook
    Left = 0
    Top = 0
    Width = 653
    Height = 323
    Align = alClient
    TabFont.Charset = DEFAULT_CHARSET
    TabFont.Color = clBtnText
    TabFont.Height = -11
    TabFont.Name = 'Tahoma'
    TabFont.Style = []
    TabOrder = 0
    object TTabPage
      Left = 4
      Top = 24
      Caption = 'Friends'
      object I_Friend1: TImage
        Left = 359
        Top = 32
        Width = 184
        Height = 184
      end
      object I_Friend2: TImage
        Left = 549
        Top = 32
        Width = 92
        Height = 92
      end
      object I_Friend3: TImage
        Left = 549
        Top = 130
        Width = 46
        Height = 46
      end
      object Btn_RefrFr: TButton
        Left = 8
        Top = 1
        Width = 75
        Height = 25
        Caption = 'Refresh'
        TabOrder = 0
        OnClick = Btn_RefrFrClick
      end
      object LW_Friends: TListView
        Left = 8
        Top = 32
        Width = 345
        Height = 200
        Columns = <
          item
            Caption = 'SteamID'
            Width = 150
          end
          item
            Caption = 'Nick'
            Width = 100
          end>
        TabOrder = 1
        ViewStyle = vsReport
        OnSelectItem = LW_FriendsSelectItem
      end
    end
    object TTabPage
      Left = 4
      Top = 24
      Caption = 'Clans'
      object I_Clan1: TImage
        Left = 352
        Top = 32
        Width = 184
        Height = 184
      end
      object I_Clan2: TImage
        Left = 542
        Top = 32
        Width = 92
        Height = 92
      end
      object I_Clan3: TImage
        Left = 542
        Top = 130
        Width = 46
        Height = 46
      end
      object LW_Clans: TListView
        Left = 8
        Top = 32
        Width = 330
        Height = 200
        Columns = <
          item
            Caption = 'SteamID'
            Width = 150
          end
          item
            Caption = 'Name'
            Width = 100
          end
          item
            Caption = 'Tag'
            Width = 75
          end>
        TabOrder = 0
        ViewStyle = vsReport
        OnSelectItem = LW_ClansSelectItem
      end
      object Btn_RefrClans: TButton
        Left = 8
        Top = 1
        Width = 75
        Height = 25
        Caption = 'Refresh'
        TabOrder = 1
        OnClick = Btn_RefrClansClick
      end
    end
  end
end
