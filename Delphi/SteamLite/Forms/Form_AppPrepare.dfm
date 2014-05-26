object AppPrepareForm: TAppPrepareForm
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsToolWindow
  Caption = '#AppPrepare'
  ClientHeight = 332
  ClientWidth = 579
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object P_AppType: TPanel
    Left = 8
    Top = 8
    Width = 297
    Height = 57
    BevelOuter = bvNone
    TabOrder = 0
    Visible = False
    object RB_TypeGCF: TRadioButton
      Left = 8
      Top = 8
      Width = 281
      Height = 17
      Caption = '#AppTypeGCF'
      Checked = True
      TabOrder = 0
      TabStop = True
    end
    object RB_TypeStandAlone: TRadioButton
      Left = 8
      Top = 31
      Width = 281
      Height = 17
      Caption = '#AppTypeStandAlone'
      TabOrder = 1
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 291
    Width = 579
    Height = 41
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    object Btn_Cancel: TButton
      Left = 496
      Top = 8
      Width = 75
      Height = 25
      Caption = '#Cancel'
      ModalResult = 2
      TabOrder = 0
    end
    object Btn_Next: TButton
      Left = 407
      Top = 8
      Width = 75
      Height = 25
      Caption = '#Next'
      TabOrder = 1
      OnClick = Btn_NextClick
    end
    object Btn_Prev: TButton
      Left = 326
      Top = 8
      Width = 75
      Height = 25
      Caption = '#Prev'
      Enabled = False
      TabOrder = 2
    end
  end
  object P_CalcSpace: TPanel
    Left = 8
    Top = 80
    Width = 297
    Height = 105
    BevelOuter = bvNone
    TabOrder = 2
    Visible = False
    object Label1: TLabel
      Left = 0
      Top = 0
      Width = 289
      Height = 97
      AutoSize = False
      Caption = '#VaitCalcSpace'
      WordWrap = True
    end
  end
  object P_SelDstDir: TPanel
    Left = 8
    Top = 198
    Width = 553
    Height = 87
    BevelOuter = bvNone
    TabOrder = 3
    Visible = False
    object Label2: TLabel
      Left = 8
      Top = 8
      Width = 521
      Height = 13
      AutoSize = False
      Caption = '#SelectDestinationDirectory'
    end
    object L_Info: TLabel
      Left = 8
      Top = 54
      Width = 57
      Height = 13
      Caption = '#SpaceInfo'
    end
    object Ed_Dst: TEdit
      Left = 8
      Top = 27
      Width = 457
      Height = 21
      TabOrder = 0
      Text = 'C:\'
      OnChange = Ed_DstChange
    end
    object Btn_Browse: TButton
      Left = 471
      Top = 27
      Width = 22
      Height = 22
      Caption = '...'
      TabOrder = 1
      OnClick = Btn_BrowseClick
    end
  end
  object P_Components: TPanel
    Left = 311
    Top = 8
    Width = 260
    Height = 66
    BevelOuter = bvNone
    BorderWidth = 5
    TabOrder = 4
    Visible = False
    object TV_Comp: TTreeView
      Left = 5
      Top = 5
      Width = 250
      Height = 56
      Align = alClient
      Indent = 19
      ReadOnly = True
      TabOrder = 0
      ExplicitLeft = 56
      ExplicitTop = 16
      ExplicitWidth = 121
      ExplicitHeight = 97
    end
  end
end
