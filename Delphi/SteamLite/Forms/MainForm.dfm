object Form_Main: TForm_Main
  Left = 0
  Top = 0
  Caption = '#SteamLite'
  ClientHeight = 406
  ClientWidth = 689
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  OnActivate = FormActivate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 689
    Height = 41
    Align = alTop
    BevelOuter = bvNone
    Caption = 'P_Header'
    TabOrder = 0
  end
  object Panel2: TPanel
    Left = 0
    Top = 365
    Width = 689
    Height = 41
    Align = alBottom
    BevelOuter = bvNone
    Caption = 'P_Footer'
    TabOrder = 1
  end
  object TabbedNotebook1: TTabbedNotebook
    Left = 0
    Top = 41
    Width = 689
    Height = 324
    Align = alClient
    TabFont.Charset = DEFAULT_CHARSET
    TabFont.Color = clBtnText
    TabFont.Height = -11
    TabFont.Name = 'Tahoma'
    TabFont.Style = []
    TabOrder = 2
    object TTabPage
      Left = 4
      Top = 24
      Caption = '#Games'
      object LV_Games: TListView
        Left = 0
        Top = 0
        Width = 681
        Height = 296
        Align = alClient
        Columns = <
          item
            Caption = '#Name'
            Width = 250
          end
          item
            Caption = '#Loaded'
            Width = 75
          end
          item
            Caption = '#Developer'
            Width = 100
          end
          item
            Caption = '#Status'
            Width = 150
          end>
        GridLines = True
        MultiSelect = True
        ReadOnly = True
        RowSelect = True
        PopupMenu = PM_Games
        TabOrder = 0
        ViewStyle = vsReport
        OnColumnClick = LV_GamesColumnClick
      end
    end
    object TTabPage
      Left = 4
      Top = 24
      Caption = '#Media'
    end
    object TTabPage
      Left = 4
      Top = 24
      Caption = '#Tools'
    end
    object TTabPage
      Left = 4
      Top = 24
      Caption = '#CacheFiles'
      object LV_Caches: TListView
        Left = 0
        Top = 0
        Width = 681
        Height = 296
        Align = alClient
        Columns = <
          item
            Caption = '#FileName'
            Width = 200
          end
          item
            Caption = '#ID'
          end
          item
            Caption = '#Loaded'
            Width = 75
          end
          item
            Caption = '#Version'
            Width = 75
          end
          item
            Caption = '#Size'
            Width = 75
          end
          item
            Caption = '#Status'
            Width = 150
          end>
        GridLines = True
        ReadOnly = True
        RowSelect = True
        PopupMenu = PM_Caches
        TabOrder = 0
        ViewStyle = vsReport
        OnColumnClick = LV_CachesColumnClick
      end
    end
  end
  object PM_Caches: TPopupMenu
    OnPopup = PM_CachesPopup
    Left = 304
    Top = 120
    object PM_Caches_Open: TMenuItem
      Caption = '#Open'
      Default = True
      OnClick = PM_Caches_OpenClick
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object PM_Caches_Downloading: TMenuItem
      Caption = '#Download'
      object PM_Caches_Down_Continue: TMenuItem
        Caption = '#Continue'
        OnClick = PM_Caches_Down_ContinueClick
      end
      object PM_Caches_Down_Stop: TMenuItem
        Caption = '#Stop'
        OnClick = PM_Caches_Down_StopClick
      end
    end
    object PM_Caches_Patching: TMenuItem
      Caption = '#Update'
      object PM_Caches_Patch_CreateArchive: TMenuItem
        Caption = '#CreateArchive'
        OnClick = PM_Caches_Patch_CreateArchiveClick
      end
      object PM_Caches_Patch_CreatePatch: TMenuItem
        Caption = '#CreateUpdate'
        OnClick = PM_Caches_Patch_CreatePatchClick
      end
      object PM_Caches_Patch_ApplyPatch: TMenuItem
        Caption = '#ApplyUpdate'
        OnClick = PM_Caches_Patch_ApplyPatchClick
      end
    end
    object N2: TMenuItem
      Caption = '-'
    end
    object PM_Caches_Stop: TMenuItem
      Caption = '#Stop'
      OnClick = PM_Caches_StopClick
    end
    object PM_Caches_Validate: TMenuItem
      Caption = '#Validate'
      OnClick = PM_Caches_ValidateClick
    end
    object PM_Caches_Correct: TMenuItem
      Caption = '#Correct'
      OnClick = PM_Caches_CorrectClick
    end
    object N3: TMenuItem
      Caption = '-'
    end
    object PM_Caches_Delete: TMenuItem
      Caption = '#Delete'
      OnClick = PM_Caches_DeleteClick
    end
    object PM_Caches_CreateMiniGCF: TMenuItem
      Caption = '#CreateMiniGCF'
      OnClick = PM_Caches_CreateMiniGCFClick
    end
    object N4: TMenuItem
      Caption = '-'
    end
    object PM_Caches_Properties: TMenuItem
      Caption = '#Properties'
    end
  end
  object PM_Games: TPopupMenu
    OnPopup = PM_GamesPopup
    Left = 416
    Top = 168
    object PM_Games_Launch: TMenuItem
      Caption = '#Launch'
      Default = True
      OnClick = PM_Games_LaunchClick
    end
    object PM_Games_s1: TMenuItem
      Caption = '-'
    end
    object PM_Games_CreateStandAlone: TMenuItem
      Caption = '#CreateStandAlone'
      OnClick = PM_Games_CreateStandAloneClick
    end
    object PM_Games_CreateGCF: TMenuItem
      Caption = '#CreateGCF'
      OnClick = PM_Games_CreateGCFClick
    end
    object PM_Games_s2: TMenuItem
      Caption = '-'
    end
    object PM_Games_Download: TMenuItem
      Caption = '#Download'
      object PM_Games_Loading_Continue: TMenuItem
        Caption = '#Continue'
        OnClick = PM_Games_Loading_ContinueClick
      end
      object PM_Games_Loading_Stop: TMenuItem
        Caption = '#Stop'
        OnClick = PM_Games_Loading_StopClick
      end
    end
    object PM_Games_Update: TMenuItem
      Caption = '#Update'
      object PM_Games_Update_CreateArchive: TMenuItem
        Caption = '#CreateArchive'
        OnClick = PM_Games_Update_CreateArchiveClick
      end
      object PM_Games_Update_CreateUpdate: TMenuItem
        Caption = '#CreateUpdate'
        OnClick = PM_Games_Update_CreateUpdateClick
      end
      object PM_Games_Update_ApplyUpdate: TMenuItem
        Caption = '#ApplyUpdate'
        OnClick = PM_Games_Update_ApplyUpdateClick
      end
    end
    object PM_Games_s3: TMenuItem
      Caption = '-'
    end
    object PM_Games_Stop: TMenuItem
      Caption = '#Stop'
      OnClick = PM_Games_StopClick
    end
    object PM_Games_Validate: TMenuItem
      Caption = '#Validate'
      OnClick = PM_Games_ValidateClick
    end
    object PM_Games_Correct: TMenuItem
      Caption = '#Correct'
      OnClick = PM_Games_CorrectClick
    end
    object PM_Games_s4: TMenuItem
      Caption = '-'
    end
    object PM_Games_Delete: TMenuItem
      Caption = '#Delete'
      OnClick = PM_Games_DeleteClick
    end
    object PM_Games_CreateMiniGCF: TMenuItem
      Caption = '#CreateMiniGCF'
      OnClick = PM_Games_CreateMiniGCFClick
    end
    object PM_Games_s5: TMenuItem
      Caption = '-'
    end
    object PM_Games_Properties: TMenuItem
      Caption = '#Properties'
      OnClick = PM_Games_PropertiesClick
    end
  end
end
