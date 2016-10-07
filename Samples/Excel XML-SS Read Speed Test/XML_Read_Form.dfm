object Form17: TForm17
  Left = 0
  Top = 0
  Caption = #1063#1090#1077#1085#1080#1077' Excel-XML '#1092#1072#1081#1083#1086#1074
  ClientHeight = 450
  ClientWidth = 716
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  DesignSize = (
    716
    450)
  PixelsPerInch = 96
  TextHeight = 13
  object lblElapsed: TLabel
    Left = 17
    Top = 409
    Width = 113
    Height = 33
    Anchors = [akLeft, akBottom]
    AutoSize = False
    Layout = tlCenter
  end
  object edtOpen: TJvFilenameEdit
    Left = 17
    Top = 17
    Width = 532
    Height = 21
    OnAfterDialog = edtOpenAfterDialog
    OnDropFiles = edtOpenDropFiles
    Anchors = [akLeft, akTop, akRight]
    ReadOnly = True
    TabOrder = 0
    Text = 'd:\Imports_Formats\XML\ALVIZ_OJSC ('#1086#1090#1095#1077#1090#1085#1086#1089#1090#1100' '#1087#1086' '#1054#1057#1053')-.xml'
  end
  object rgMethod: TRadioGroup
    Left = 17
    Top = 49
    Width = 241
    Height = 102
    Caption = ' '#1055#1072#1088#1089#1077#1088' '
    Items.Strings = (
      'Microsoft XML Lite  (pull-'#1087#1086#1090#1086#1082')'
      'TXMLDocument - MS XML 6 ( XPath+DOM )'
      'OmniXML project ( XPath+DOM )')
    TabOrder = 1
    OnClick = rgMethodClick
  end
  object rgSheet: TRadioGroup
    Left = 17
    Top = 157
    Width = 241
    Height = 200
    Anchors = [akLeft, akTop, akBottom]
    Caption = ' '#1051#1080#1089#1090' '
    TabOrder = 2
    OnClick = rgSheetClick
  end
  object chkGridVisible: TCheckBox
    Left = 17
    Top = 369
    Width = 241
    Height = 17
    Anchors = [akLeft, akBottom]
    Caption = ' '#1047#1072#1087#1086#1083#1085#1103#1090#1100' '#1075#1088#1080#1076' '
    TabOrder = 3
    OnClick = chkGridVisibleClick
  end
  object btnShowSheet: TButton
    Left = 147
    Top = 409
    Width = 111
    Height = 33
    Anchors = [akLeft, akBottom]
    Caption = #1055#1086#1082#1072#1079#1072#1090#1100
    TabOrder = 4
    OnClick = btnShowSheetClick
  end
  object gridSheet: TStringGrid
    Left = 278
    Top = 49
    Width = 430
    Height = 393
    Anchors = [akLeft, akTop, akRight, akBottom]
    DrawingStyle = gdsClassic
    FixedCols = 0
    RowCount = 1
    FixedRows = 0
    TabOrder = 5
  end
end
