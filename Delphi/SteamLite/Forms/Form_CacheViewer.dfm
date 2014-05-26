object CacheViewerForm: TCacheViewerForm
  Left = 0
  Top = 0
  Caption = '#CacheViewerForm'
  ClientHeight = 320
  ClientWidth = 595
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Menu = MainMenu1
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Splitter1: TSplitter
    Left = 121
    Top = 0
    Height = 320
    ExplicitLeft = 144
    ExplicitTop = 64
    ExplicitHeight = 100
  end
  object TV_Folders: TTreeView
    Left = 0
    Top = 0
    Width = 121
    Height = 320
    Align = alLeft
    Indent = 19
    PopupMenu = PM_Folders
    ReadOnly = True
    TabOrder = 0
    OnChange = TV_FoldersChange
  end
  object LV_Files: TListView
    Left = 124
    Top = 0
    Width = 471
    Height = 320
    Align = alClient
    Columns = <
      item
        Caption = '#FileName'
        Width = 150
      end
      item
        Caption = '#FileExt'
        Width = 75
      end
      item
        Caption = '#FileSize'
        Width = 100
      end
      item
        Caption = '#ExtDescr'
      end>
    LargeImages = IL_Large
    MultiSelect = True
    ReadOnly = True
    RowSelect = True
    PopupMenu = PM_Files
    SmallImages = IL_Small
    TabOrder = 1
    ViewStyle = vsReport
  end
  object MainMenu1: TMainMenu
    Left = 16
    Top = 16
  end
  object OD: TOpenDialog
    Filter = '*.GCF,*.NCF|*.gcf;*.ncf'
    Options = [ofHideReadOnly, ofFileMustExist, ofCreatePrompt, ofEnableSizing]
    Left = 16
    Top = 112
  end
  object IL_Small: TImageList
    Left = 16
    Top = 160
  end
  object IL_Large: TImageList
    Height = 32
    Width = 32
    Left = 72
    Top = 160
  end
  object PM_Files: TPopupMenu
    OnPopup = PM_FilesPopup
    Left = 16
    Top = 64
    object PM_Prev: TMenuItem
      Caption = '#Preview'
      OnClick = PM_PrevClick
    end
    object N2: TMenuItem
      Caption = '-'
    end
    object PM_Extract: TMenuItem
      Caption = '#Extract'
      OnClick = PM_ExtractClick
    end
    object PM_Import: TMenuItem
      Caption = '#Import'
      OnClick = PM_ImportClick
    end
    object PM_Validate: TMenuItem
      Caption = '#Validate'
      OnClick = PM_ValidateClick
    end
    object N3: TMenuItem
      Caption = '-'
    end
    object PM_Properties: TMenuItem
      Caption = '#Properties'
      OnClick = PM_PropertiesClick
    end
  end
  object SD: TSaveDialog
    Left = 72
    Top = 112
  end
  object PM_Folders: TPopupMenu
    Left = 72
    Top = 64
    object PM_F_Extract: TMenuItem
      Caption = '#Extract'
      OnClick = PM_F_ExtractClick
    end
    object PM_F_Validate: TMenuItem
      Caption = '#Validate'
      OnClick = PM_F_ValidateClick
    end
    object MenuItem5: TMenuItem
      Caption = '-'
    end
    object PM_F_Properties: TMenuItem
      Caption = '#Properties'
      OnClick = PM_F_PropertiesClick
    end
  end
end
