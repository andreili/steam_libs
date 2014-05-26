object ExtractForm: TExtractForm
  Left = 0
  Top = 0
  BorderStyle = bsToolWindow
  Caption = '#Extraction'
  ClientHeight = 156
  ClientWidth = 644
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnActivate = FormActivate
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 73
    Height = 13
    Alignment = taRightJustify
    AutoSize = False
    Caption = '#From'
  end
  object Label2: TLabel
    Left = 8
    Top = 31
    Width = 73
    Height = 13
    Alignment = taRightJustify
    AutoSize = False
    Caption = '#To'
  end
  object L_From: TLabel
    Left = 87
    Top = 8
    Width = 549
    Height = 13
    AutoSize = False
    Caption = 'L_From'
  end
  object L_To: TLabel
    Left = 87
    Top = 31
    Width = 549
    Height = 13
    AutoSize = False
    Caption = 'Label3'
  end
  object L_Progress: TLabel
    Left = 8
    Top = 96
    Width = 249
    Height = 13
    AutoSize = False
    Caption = 'L_Progress'
  end
  object L_Time: TLabel
    Left = 387
    Top = 96
    Width = 249
    Height = 13
    AutoSize = False
    Caption = 'L_Time'
  end
  object P_File: TProgressBar
    Left = 8
    Top = 50
    Width = 628
    Height = 17
    TabOrder = 0
  end
  object P_All: TProgressBar
    Left = 8
    Top = 73
    Width = 628
    Height = 17
    TabOrder = 1
  end
  object Timer1: TTimer
    Enabled = False
    Interval = 500
    OnTimer = Timer1Timer
    Left = 296
    Top = 96
  end
end
