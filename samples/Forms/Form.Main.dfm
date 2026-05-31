object FormMain: TFormMain
  Left = 0
  Top = 0
  Caption = 'Query4D Demo'
  ClientHeight = 620
  ClientWidth = 920
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  TextHeight = 15
  object Splitter: TSplitter
    Left = 450
    Top = 44
    Width = 6
    Height = 531
    Color = clBtnShadow
    ParentColor = False
  end
  object PanelTop: TPanel
    Left = 0
    Top = 0
    Width = 920
    Height = 44
    Align = alTop
    BevelOuter = bvNone
    Color = clWhite
    ParentBackground = False
    TabOrder = 0
    object BtnSelect: TButton
      Left = 8
      Top = 8
      Width = 80
      Height = 28
      Caption = 'SELECT'
      TabOrder = 0
      OnClick = BtnSelectClick
    end
    object BtnWhere: TButton
      Left = 96
      Top = 8
      Width = 80
      Height = 28
      Caption = 'WHERE'
      TabOrder = 1
      OnClick = BtnWhereClick
    end
    object BtnJoin: TButton
      Left = 184
      Top = 8
      Width = 80
      Height = 28
      Caption = 'JOIN'
      TabOrder = 2
      OnClick = BtnJoinClick
    end
    object BtnDML: TButton
      Left = 272
      Top = 8
      Width = 130
      Height = 28
      Caption = 'INSERT/UPDATE/DELETE'
      TabOrder = 3
      OnClick = BtnDMLClick
    end
    object BtnCTE: TButton
      Left = 410
      Top = 8
      Width = 80
      Height = 28
      Caption = 'CTE'
      TabOrder = 4
      OnClick = BtnCTEClick
    end
  end
  object PanelBottom: TPanel
    Left = 0
    Top = 575
    Width = 920
    Height = 45
    Align = alBottom
    BevelOuter = bvNone
    Color = clWhite
    ParentBackground = False
    TabOrder = 1
    object LabelDialect: TLabel
      Left = 8
      Top = 14
      Width = 40
      Height = 15
      Caption = 'Dialeto:'
    end
    object BtnExecute: TSpeedButton
      Left = 192
      Top = 9
      Width = 100
      Height = 26
      Caption = #9654' Executar'
      OnClick = BtnExecuteClick
    end
    object BtnClear: TSpeedButton
      Left = 300
      Top = 9
      Width = 80
      Height = 26
      Caption = #8634' Limpar'
      OnClick = BtnClearClick
    end
    object LabelStatus: TLabel
      Left = 400
      Top = 14
      Width = 36
      Height = 15
      Caption = 'Pronto'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clGray
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
    end
    object ComboDialect: TComboBox
      Left = 60
      Top = 10
      Width = 120
      Height = 23
      Style = csDropDownList
      TabOrder = 0
      OnChange = ComboDialectChange
    end
  end
  object PanelCode: TPanel
    Left = 0
    Top = 44
    Width = 450
    Height = 531
    Align = alLeft
    BevelOuter = bvNone
    TabOrder = 2
    object LabelCode: TLabel
      Left = 8
      Top = 6
      Width = 77
      Height = 15
      Caption = 'C'#243'digo Delphi'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clGray
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object MemoCode: TMemo
      Left = 0
      Top = 28
      Width = 450
      Height = 503
      Align = alBottom
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Courier New'
      Font.Style = []
      ParentFont = False
      ReadOnly = True
      ScrollBars = ssBoth
      TabOrder = 0
      WordWrap = False
    end
  end
  object PanelSQL: TPanel
    Left = 456
    Top = 44
    Width = 464
    Height = 531
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 3
    object LabelSQL: TLabel
      Left = 8
      Top = 6
      Width = 66
      Height = 15
      Caption = 'SQL Gerado'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clGray
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object MemoSQL: TMemo
      Left = 0
      Top = 28
      Width = 464
      Height = 503
      Align = alBottom
      Color = clInfoBk
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Courier New'
      Font.Style = []
      ParentFont = False
      ReadOnly = True
      ScrollBars = ssBoth
      TabOrder = 0
      WordWrap = False
    end
  end
  object QueryBuilder: TQuery4D
    Left = 40
    Top = 560
  end
end
