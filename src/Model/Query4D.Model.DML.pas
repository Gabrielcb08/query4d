unit Query4D.Model.DML;

interface

uses
  System.Generics.Collections,
  Query4D.Shared.Guard,
  Query4D.Model.Types;

type
  TSetValueModel = class
  private
    FColumn: string;
    FValue: string;
    FKind: TSetValueKind;
  public
    constructor Create(
      const AColumn, AValue: string;
      const AKind: TSetValueKind = svkParam);
    property Column: string read FColumn;
    property Value: string read FValue;
    property Kind: TSetValueKind read FKind;
  end;

  TSetValueListModel = class
  private
    FItems: TObjectList<TSetValueModel>;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Add(
      const AColumn, AValue: string;
      const AKind: TSetValueKind = svkParam);
    function Count: Integer;
    function IsEmpty: Boolean;
    function Item(const AIndex: Integer): TSetValueModel;
  end;

  TInsertColumnModel = record
    ColumnName: string;
    Value: string;
    Kind: TSetValueKind;
  end;

  TInsertRowModel = class
  private
    FColumns: TList<TInsertColumnModel>;
  public
    constructor Create;
    destructor Destroy; override;
    procedure AddColumn(
      const AColumnName, AValue: string;
      const AKind: TSetValueKind = svkParam);
    function Count: Integer;
    function Column(const AIndex: Integer): TInsertColumnModel;
  end;

  TInsertModel = class
  private
    FRows: TObjectList<TInsertRowModel>;
    FColumnNames: TList<string>;
  public
    constructor Create;
    destructor Destroy; override;
    procedure BeginRow;
    procedure AddValue(
      const AColumnName, AValue: string;
      const AKind: TSetValueKind = svkParam);
    function RowCount: Integer;
    function IsEmpty: Boolean;
    function Row(const AIndex: Integer): TInsertRowModel;
    function ColumnName(const AIndex: Integer): string;
    function ColumnCount: Integer;
  end;

  TReturningModel = class
  private
    FColumns: TList<string>;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Add(const AColumn: string);
    function Count: Integer;
    function IsEmpty: Boolean;
    function Column(const AIndex: Integer): string;
  end;

implementation

uses
  System.SysUtils;

{ TSetValueModel }

constructor TSetValueModel.Create(
  const AColumn, AValue: string; const AKind: TSetValueKind);
begin
  TGuard.IsNotEmpty(AColumn, 'SetValue.Column');
  inherited Create;
  FColumn := Trim(AColumn);
  FValue  := AValue;
  FKind   := AKind;
end;

{ TSetValueListModel }

constructor TSetValueListModel.Create;
begin
  inherited Create;
  FItems := TObjectList<TSetValueModel>.Create(True);
end;

destructor TSetValueListModel.Destroy;
begin
  FItems.Free;
  inherited;
end;

procedure TSetValueListModel.Add(
  const AColumn, AValue: string; const AKind: TSetValueKind);
begin
  FItems.Add(TSetValueModel.Create(AColumn, AValue, AKind));
end;

function TSetValueListModel.Count: Integer;
begin
  Result := FItems.Count;
end;

function TSetValueListModel.IsEmpty: Boolean;
begin
  Result := FItems.Count = 0;
end;

function TSetValueListModel.Item(const AIndex: Integer): TSetValueModel;
begin
  Result := FItems[AIndex];
end;

{ TInsertRowModel }

constructor TInsertRowModel.Create;
begin
  inherited Create;
  FColumns := TList<TInsertColumnModel>.Create;
end;

destructor TInsertRowModel.Destroy;
begin
  FColumns.Free;
  inherited;
end;

procedure TInsertRowModel.AddColumn(
  const AColumnName, AValue: string; const AKind: TSetValueKind);
var
  Col: TInsertColumnModel;
begin
  TGuard.IsNotEmpty(AColumnName, 'Insert.ColumnName');
  Col.ColumnName := AColumnName;
  Col.Value      := AValue;
  Col.Kind       := AKind;
  FColumns.Add(Col);
end;

function TInsertRowModel.Count: Integer;
begin
  Result := FColumns.Count;
end;

function TInsertRowModel.Column(const AIndex: Integer): TInsertColumnModel;
begin
  Result := FColumns[AIndex];
end;

{ TInsertModel }

constructor TInsertModel.Create;
begin
  inherited Create;
  FRows        := TObjectList<TInsertRowModel>.Create(True);
  FColumnNames := TList<string>.Create;
end;

destructor TInsertModel.Destroy;
begin
  FRows.Free;
  FColumnNames.Free;
  inherited;
end;

procedure TInsertModel.BeginRow;
begin
  FRows.Add(TInsertRowModel.Create);
end;

procedure TInsertModel.AddValue(
  const AColumnName, AValue: string; const AKind: TSetValueKind);
begin
  TGuard.IsTrue(FRows.Count > 0, 'AddValue requer BeginRow antes');
  FRows.Last.AddColumn(AColumnName, AValue, AKind);
  if not FColumnNames.Contains(AColumnName) then
    FColumnNames.Add(AColumnName);
end;

function TInsertModel.RowCount: Integer;
begin
  Result := FRows.Count;
end;

function TInsertModel.IsEmpty: Boolean;
begin
  Result := FRows.Count = 0;
end;

function TInsertModel.Row(const AIndex: Integer): TInsertRowModel;
begin
  Result := FRows[AIndex];
end;

function TInsertModel.ColumnName(const AIndex: Integer): string;
begin
  Result := FColumnNames[AIndex];
end;

function TInsertModel.ColumnCount: Integer;
begin
  Result := FColumnNames.Count;
end;

{ TReturningModel }

constructor TReturningModel.Create;
begin
  inherited Create;
  FColumns := TList<string>.Create;
end;

destructor TReturningModel.Destroy;
begin
  FColumns.Free;
  inherited;
end;

procedure TReturningModel.Add(const AColumn: string);
begin
  TGuard.IsNotEmpty(AColumn, 'Returning.Column');
  FColumns.Add(Trim(AColumn));
end;

function TReturningModel.Count: Integer;
begin
  Result := FColumns.Count;
end;

function TReturningModel.IsEmpty: Boolean;
begin
  Result := FColumns.Count = 0;
end;

function TReturningModel.Column(const AIndex: Integer): string;
begin
  Result := FColumns[AIndex];
end;

end.
