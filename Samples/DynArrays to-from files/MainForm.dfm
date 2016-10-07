object fmMain: TfmMain
  Left = 0
  Top = 0
  ClientHeight = 593
  ClientWidth = 655
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
  object mmoData: TMemo
    AlignWithMargins = True
    Left = 8
    Top = 84
    Width = 639
    Height = 501
    Margins.Left = 8
    Margins.Top = 8
    Margins.Right = 8
    Margins.Bottom = 8
    Align = alClient
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Consolas'
    Font.Pitch = fpFixed
    Font.Style = []
    Lines.Strings = (
      'mmoData')
    ParentFont = False
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 0
  end
  object pnl1: TPanel
    Left = 0
    Top = 0
    Width = 655
    Height = 76
    Align = alTop
    BevelInner = bvLowered
    BevelOuter = bvNone
    Caption = 'pnl1'
    ShowCaption = False
    TabOrder = 1
    object btnRead: TButton
      Left = 268
      Top = 12
      Width = 160
      Height = 56
      Caption = 'Read Sample XML'
      TabOrder = 0
      OnClick = btnReadClick
    end
    object btnSave: TButton
      Left = 32
      Top = 12
      Width = 160
      Height = 56
      Caption = 'Create Sample XML'
      TabOrder = 1
      OnClick = btnSaveClick
    end
  end
end
