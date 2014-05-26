object Form_Loading: TForm_Loading
  Left = 0
  Top = 0
  BorderIcons = []
  BorderStyle = bsToolWindow
  Caption = '#LoadingForm'
  ClientHeight = 60
  ClientWidth = 418
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
  object L_Operation: TLabel
    Left = 10
    Top = 8
    Width = 400
    Height = 13
    AutoSize = False
  end
  object ProgressBar1: TProgressBar
    Left = 8
    Top = 27
    Width = 400
    Height = 17
    TabOrder = 0
  end
end
