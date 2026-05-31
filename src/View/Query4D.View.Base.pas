unit Query4D.View.Base;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,
  Query4D.Shared.Result,
  Query4D.Shared.Exceptions,
  Query4D.Model.Types,
  Query4D.Model.Query,
  Query4D.Model.Field,
  Query4D.Model.Where,
  Query4D.Model.Join,
  Query4D.Model.Order,
  Query4D.Model.Group,
  Query4D.Model.CTE,
  Query4D.Model.DML,
  Query4D.View.Interfaces;

type
  TBaseDialectView = class(TInterfacedObject, IDialectView)
  private
    FParams: TList<string>;

    function AddParam(const AValue: string): string;
    procedure ResetParams;
    function ParamsAsArray: TArray<string>;

    function RenderCTEBlock(const AModel: TQueryModel): string;
    function RenderSelectFields(const AModel: TQueryModel): string;
    function RenderFromClause(const AModel: TQueryModel): string;
    function RenderJoinClause(const AModel: TQueryModel): string;
    function RenderWhereClause(const AModel: TQueryModel): string;
    function RenderGroupClause(const AModel: TQueryModel): string;
    function RenderWhereGroup(const AGroup: TWhereGroupModel): string;
    function RenderWherePredicate(const APred: TWherePredicateModel): string;
    function RenderSetClause(const AModel: TQueryModel): string;
    function RenderInsertColumns(const AModel: TQueryModel): string;
    function RenderInsertValues(const AModel: TQueryModel): string;
    function RenderReturning(const AModel: TQueryModel): string;

    function BuildInsert(const AModel: TQueryModel): TResult<TQueryResult>;
    function BuildUpdate(const AModel: TQueryModel): TResult<TQueryResult>;
    function BuildDelete(const AModel: TQueryModel): TResult<TQueryResult>;

    function JoinTypeName(const AType: TJoinType): string;
  protected
    function BuildSelect(const AModel: TQueryModel): TResult<TQueryResult>; virtual;
    function RenderSelectKeyword(const AModel: TQueryModel): string; virtual;
    function RenderOrderByClause(const AModel: TQueryModel): string; virtual;
    function RenderPaginationClause(const AModel: TQueryModel): string; virtual; abstract;
    function WrapNullsFirst(const AColumn: string; const ADir: TOrderDirection): string; virtual;
    function WrapNullsLast(const AColumn: string; const ADir: TOrderDirection): string; virtual;
  public
    constructor Create;
    destructor Destroy; override;
    function Render(const AModel: TQueryModel): TResult<TQueryResult>;
    function SupportsFeature(const AFeature: TDialectFeature): Boolean; virtual; abstract;
    function QuoteIdentifier(const AName: string): string; virtual; abstract;
    function ParameterPlaceholder(const AIndex: Integer): string; virtual; abstract;
  end;

procedure AppendNonEmpty(const ABuilder: TStringBuilder; const APart: string);

implementation

{ TBaseDialectView }

constructor TBaseDialectView.Create;
begin
  inherited Create;
  FParams := TList<string>.Create;
end;

destructor TBaseDialectView.Destroy;
begin
  FParams.Free;
  inherited;
end;

function TBaseDialectView.AddParam(const AValue: string): string;
begin
  FParams.Add(AValue);
  Result := ParameterPlaceholder(FParams.Count);
end;

procedure TBaseDialectView.ResetParams;
begin
  FParams.Clear;
end;

function TBaseDialectView.ParamsAsArray: TArray<string>;
begin
  Result := FParams.ToArray;
end;

function TBaseDialectView.Render(const AModel: TQueryModel): TResult<TQueryResult>;
begin
  ResetParams;
  case AModel.QueryType of
    qtSelect: Result := BuildSelect(AModel);
    qtInsert: Result := BuildInsert(AModel);
    qtUpdate: Result := BuildUpdate(AModel);
    qtDelete: Result := BuildDelete(AModel);
  else
    Result := TResult<TQueryResult>.Fail('Tipo de query desconhecido');
  end;
end;

function TBaseDialectView.RenderCTEBlock(const AModel: TQueryModel): string;
var
  Parts: TStringBuilder;
  I: Integer;
  CTE: TCTEModel;
  Keyword: string;
begin
  if AModel.CTEs.IsEmpty then
    Exit('');
  if AModel.CTEs.HasRecursive then
    Keyword := 'WITH RECURSIVE'
  else
    Keyword := 'WITH';
  Parts := TStringBuilder.Create;
  try
    Parts.Append(Keyword);
    for I := 0 to AModel.CTEs.Count - 1 do
    begin
      CTE := AModel.CTEs.Item(I);
      if I > 0 then Parts.Append(',');
      Parts.AppendLine;
      Parts.Append('  ');
      Parts.Append(QuoteIdentifier(CTE.Name));
      Parts.Append(' AS (');
      Parts.AppendLine;
      if CTE.IsRecursive then
        Parts.AppendFormat('    %s%sUNION ALL%s    %s',
          [CTE.RecursiveAnchor, sLineBreak, sLineBreak, CTE.RecursiveMember])
      else
        Parts.Append('    ' + CTE.Query);
      Parts.AppendLine;
      Parts.Append('  )');
    end;
    Result := Parts.ToString + sLineBreak;
  finally
    Parts.Free;
  end;
end;

function TBaseDialectView.RenderSelectFields(const AModel: TQueryModel): string;
var
  SB: TStringBuilder;
  I: Integer;
  F: TFieldModel;
begin
  if AModel.Fields.IsEmpty then
    Exit('*');
  SB := TStringBuilder.Create;
  try
    for I := 0 to AModel.Fields.Count - 1 do
    begin
      F := AModel.Fields.Item(I);
      if I > 0 then SB.Append(', ');
      if F.HasAlias then
        SB.Append(F.Expression + ' AS ' + QuoteIdentifier(F.Alias))
      else
        SB.Append(F.Expression);
    end;
    Result := SB.ToString;
  finally
    SB.Free;
  end;
end;

function TBaseDialectView.RenderFromClause(const AModel: TQueryModel): string;
begin
  if AModel.Table = '' then
    Exit('');
  Result := 'FROM ' + AModel.Table;
  if AModel.HasAlias then
    Result := Result + ' AS ' + QuoteIdentifier(AModel.TableAlias);
end;

function TBaseDialectView.JoinTypeName(const AType: TJoinType): string;
begin
  case AType of
    jtInner:     Result := 'INNER JOIN';
    jtLeft:      Result := 'LEFT JOIN';
    jtRight:     Result := 'RIGHT JOIN';
    jtFullOuter: Result := 'FULL OUTER JOIN';
    jtCross:     Result := 'CROSS JOIN';
  else
    Result := 'JOIN';
  end;
end;

function TBaseDialectView.RenderJoinClause(const AModel: TQueryModel): string;
var
  SB: TStringBuilder;
  I: Integer;
  J: TJoinModel;
  Line: string;
begin
  if AModel.Joins.IsEmpty then
    Exit('');
  SB := TStringBuilder.Create;
  try
    for I := 0 to AModel.Joins.Count - 1 do
    begin
      J := AModel.Joins.Item(I);
      Line := JoinTypeName(J.JoinType) + ' ' + J.Table;
      if J.HasAlias then
        Line := Line + ' AS ' + QuoteIdentifier(J.Alias);
      if J.JoinType <> jtCross then
        Line := Line + ' ON ' + J.OnClause;
      if I > 0 then SB.AppendLine;
      SB.Append(Line);
    end;
    Result := SB.ToString;
  finally
    SB.Free;
  end;
end;

function TBaseDialectView.RenderWherePredicate(const APred: TWherePredicateModel): string;
var
  SB: TStringBuilder;
  I: Integer;
  Placeholder: string;
begin
  case APred.Op of
    woRaw:
      Result := APred.Column;

    woIsNull:
      Result := APred.Column + ' IS NULL';

    woIsNotNull:
      Result := APred.Column + ' IS NOT NULL';

    woIsTrue:
      Result := APred.Column + ' = 1';

    woIsFalse:
      Result := APred.Column + ' = 0';

    woIsIn, woIsNotIn:
    begin
      SB := TStringBuilder.Create;
      try
        for I := 0 to High(APred.Values) do
        begin
          if I > 0 then SB.Append(', ');
          SB.Append(AddParam(APred.Values[I]));
        end;
        Placeholder := '(' + SB.ToString + ')';
      finally
        SB.Free;
      end;
      if APred.Op = woIsIn then
        Result := APred.Column + ' IN ' + Placeholder
      else
        Result := APred.Column + ' NOT IN ' + Placeholder;
    end;

    woIsBetween:
      Result := APred.Column + ' BETWEEN ' +
        AddParam(APred.Value) + ' AND ' + AddParam(APred.ValueTo);

    woIsNotBetween:
      Result := APred.Column + ' NOT BETWEEN ' +
        AddParam(APred.Value) + ' AND ' + AddParam(APred.ValueTo);

    woExists:
      Result := 'EXISTS (' + APred.Column + ')';

    woNotExists:
      Result := 'NOT EXISTS (' + APred.Column + ')';

    woContainsCaseInsensitive:
    begin
      Placeholder := AddParam(APred.Value);
      Result := 'LOWER(' + APred.Column + ') LIKE LOWER(' + Placeholder + ')';
    end;

  else
    begin
      Placeholder := AddParam(APred.Value);
      case APred.Op of
        woEqual:              Result := APred.Column + ' = '        + Placeholder;
        woNotEqual:           Result := APred.Column + ' <> '       + Placeholder;
        woGreaterThan:        Result := APred.Column + ' > '        + Placeholder;
        woGreaterThanOrEqualTo: Result := APred.Column + ' >= '     + Placeholder;
        woLessThan:           Result := APred.Column + ' < '        + Placeholder;
        woLessThanOrEqualTo:  Result := APred.Column + ' <= '       + Placeholder;
        woContains:           Result := APred.Column + ' LIKE '     + Placeholder;
        woNotContains:        Result := APred.Column + ' NOT LIKE ' + Placeholder;
        woStartsWith:         Result := APred.Column + ' LIKE '     + Placeholder;
        woEndsWith:           Result := APred.Column + ' LIKE '     + Placeholder;
      else
        Result := APred.Column + ' = ' + Placeholder;
      end;
    end;
  end;
end;

function TBaseDialectView.RenderWhereGroup(const AGroup: TWhereGroupModel): string;
var
  SB: TStringBuilder;
  I: Integer;
  Node: TWhereNode;
  NodeSQL, LogicalStr: string;
begin
  SB := TStringBuilder.Create;
  try
    for I := 0 to AGroup.Count - 1 do
    begin
      Node := AGroup.Node(I);
      if Node.Kind = wnkPredicate then
        NodeSQL := RenderWherePredicate(Node.Predicate)
      else
        NodeSQL := '(' + RenderWhereGroup(Node.Group) + ')';

      if I = 0 then
        SB.Append(NodeSQL)
      else
      begin
        if Node.Logical = loAnd then
          LogicalStr := ' AND '
        else
          LogicalStr := ' OR ';
        SB.Append(LogicalStr + NodeSQL);
      end;
    end;
    Result := SB.ToString;
  finally
    SB.Free;
  end;
end;

function TBaseDialectView.RenderWhereClause(const AModel: TQueryModel): string;
begin
  if not AModel.Where.HasConditions then
    Exit('');
  Result := 'WHERE ' + RenderWhereGroup(AModel.Where.Root);
end;

function TBaseDialectView.RenderGroupClause(const AModel: TQueryModel): string;
var
  SB: TStringBuilder;
  I: Integer;
begin
  if AModel.Group.IsEmpty then
    Exit('');
  SB := TStringBuilder.Create;
  try
    for I := 0 to AModel.Group.ColumnCount - 1 do
    begin
      if I > 0 then SB.Append(', ');
      SB.Append(AModel.Group.Column(I));
    end;
    Result := 'GROUP BY ' + SB.ToString;
    if AModel.Group.HavingCount > 0 then
    begin
      SB.Clear;
      for I := 0 to AModel.Group.HavingCount - 1 do
      begin
        if I > 0 then SB.Append(' AND ');
        SB.Append(AModel.Group.Having(I));
      end;
      Result := Result + sLineBreak + 'HAVING ' + SB.ToString;
    end;
  finally
    SB.Free;
  end;
end;

function TBaseDialectView.RenderOrderByClause(const AModel: TQueryModel): string;
var
  SB: TStringBuilder;
  I: Integer;
  Item: TOrderItemModel;
  DirStr, OrderExpr: string;
begin
  if AModel.Order.IsEmpty then
    Exit('');
  SB := TStringBuilder.Create;
  try
    for I := 0 to AModel.Order.Count - 1 do
    begin
      Item := AModel.Order.Item(I);
      if Item.Direction = odAsc then DirStr := 'ASC' else DirStr := 'DESC';
      case Item.NullsOrder of
        noFirst: OrderExpr := WrapNullsFirst(Item.Column, Item.Direction);
        noLast:  OrderExpr := WrapNullsLast(Item.Column, Item.Direction);
      else
        OrderExpr := Item.Column + ' ' + DirStr;
      end;
      if I > 0 then SB.Append(', ');
      SB.Append(OrderExpr);
    end;
    Result := 'ORDER BY ' + SB.ToString;
  finally
    SB.Free;
  end;
end;

function TBaseDialectView.WrapNullsFirst(const AColumn: string; const ADir: TOrderDirection): string;
var
  DirStr: string;
begin
  if ADir = odAsc then DirStr := 'ASC' else DirStr := 'DESC';
  Result := AColumn + ' ' + DirStr + ' NULLS FIRST';
end;

function TBaseDialectView.WrapNullsLast(const AColumn: string; const ADir: TOrderDirection): string;
var
  DirStr: string;
begin
  if ADir = odAsc then DirStr := 'ASC' else DirStr := 'DESC';
  Result := AColumn + ' ' + DirStr + ' NULLS LAST';
end;

function TBaseDialectView.RenderSetClause(const AModel: TQueryModel): string;
var
  SB: TStringBuilder;
  I: Integer;
  SV: TSetValueModel;
begin
  SB := TStringBuilder.Create;
  try
    for I := 0 to AModel.SetValues.Count - 1 do
    begin
      SV := AModel.SetValues.Item(I);
      if I > 0 then SB.Append(', ');
      case SV.Kind of
        svkParam:   SB.Append(SV.Column + ' = ' + AddParam(SV.Value));
        svkLiteral: SB.Append(SV.Column + ' = ' + SV.Value);
        svkRaw:     SB.Append(SV.Column + ' = ' + SV.Value);
      end;
    end;
    Result := 'SET ' + SB.ToString;
  finally
    SB.Free;
  end;
end;

function TBaseDialectView.RenderInsertColumns(const AModel: TQueryModel): string;
var
  SB: TStringBuilder;
  I: Integer;
begin
  SB := TStringBuilder.Create;
  try
    for I := 0 to AModel.Insert.ColumnCount - 1 do
    begin
      if I > 0 then SB.Append(', ');
      SB.Append(AModel.Insert.ColumnName(I));
    end;
    Result := '(' + SB.ToString + ')';
  finally
    SB.Free;
  end;
end;

function TBaseDialectView.RenderInsertValues(const AModel: TQueryModel): string;
var
  RowSB, ValSB: TStringBuilder;
  I, J: Integer;
  Row: TInsertRowModel;
  Col: TInsertColumnModel;
begin
  RowSB := TStringBuilder.Create;
  try
    for I := 0 to AModel.Insert.RowCount - 1 do
    begin
      Row := AModel.Insert.Row(I);
      ValSB := TStringBuilder.Create;
      try
        for J := 0 to Row.Count - 1 do
        begin
          Col := Row.Column(J);
          if J > 0 then ValSB.Append(', ');
          case Col.Kind of
            svkParam:   ValSB.Append(AddParam(Col.Value));
            svkLiteral: ValSB.Append(Col.Value);
            svkRaw:     ValSB.Append(Col.Value);
          end;
        end;
        if I > 0 then RowSB.Append(',' + sLineBreak + '       ');
        RowSB.Append('(' + ValSB.ToString + ')');
      finally
        ValSB.Free;
      end;
    end;
    Result := 'VALUES ' + RowSB.ToString;
  finally
    RowSB.Free;
  end;
end;

function TBaseDialectView.RenderReturning(const AModel: TQueryModel): string;
var
  SB: TStringBuilder;
  I: Integer;
begin
  if AModel.Returning.IsEmpty then
    Exit('');
  SB := TStringBuilder.Create;
  try
    for I := 0 to AModel.Returning.Count - 1 do
    begin
      if I > 0 then SB.Append(', ');
      SB.Append(AModel.Returning.Column(I));
    end;
    Result := 'RETURNING ' + SB.ToString;
  finally
    SB.Free;
  end;
end;

function TBaseDialectView.RenderSelectKeyword(const AModel: TQueryModel): string;
begin
  Result := 'SELECT';
  if AModel.Distinct then Result := Result + ' DISTINCT';
end;

procedure AppendNonEmpty(const ABuilder: TStringBuilder; const APart: string);
begin
  if Trim(APart) <> '' then
  begin
    if ABuilder.Length > 0 then ABuilder.AppendLine;
    ABuilder.Append(APart);
  end;
end;

function TBaseDialectView.BuildSelect(const AModel: TQueryModel): TResult<TQueryResult>;
var
  SQL: TStringBuilder;
  Ret: string;
begin
  try
    SQL := TStringBuilder.Create;
    try
      AppendNonEmpty(SQL, RenderCTEBlock(AModel));
      AppendNonEmpty(SQL, RenderSelectKeyword(AModel) + ' ' + RenderSelectFields(AModel));
      AppendNonEmpty(SQL, RenderFromClause(AModel));
      AppendNonEmpty(SQL, RenderJoinClause(AModel));
      AppendNonEmpty(SQL, RenderWhereClause(AModel));
      AppendNonEmpty(SQL, RenderGroupClause(AModel));
      AppendNonEmpty(SQL, RenderOrderByClause(AModel));
      AppendNonEmpty(SQL, RenderPaginationClause(AModel));
      Ret := RenderReturning(AModel);
      if (Ret <> '') and SupportsFeature(dfReturning) then
        AppendNonEmpty(SQL, Ret);
      Result := TResult<TQueryResult>.Ok(TQueryResult.New(SQL.ToString, ParamsAsArray));
    finally
      SQL.Free;
    end;
  except
    on E: Exception do
      Result := TResult<TQueryResult>.Fail(E.Message);
  end;
end;

function TBaseDialectView.BuildUpdate(const AModel: TQueryModel): TResult<TQueryResult>;
var
  SQL: TStringBuilder;
  Ret: string;
begin
  if not AModel.Where.HasConditions then
    raise EUnsafeOperation.Create(
      'UPDATE sem WHERE e proibido. Use WhereRaw(''1=1'') para forca-lo explicitamente.');
  try
    SQL := TStringBuilder.Create;
    try
      SQL.Append('UPDATE ' + AModel.Table);
      AppendNonEmpty(SQL, RenderSetClause(AModel));
      AppendNonEmpty(SQL, RenderWhereClause(AModel));
      Ret := RenderReturning(AModel);
      if (Ret <> '') and SupportsFeature(dfReturning) then
        AppendNonEmpty(SQL, Ret);
      Result := TResult<TQueryResult>.Ok(TQueryResult.New(SQL.ToString, ParamsAsArray));
    finally
      SQL.Free;
    end;
  except
    on E: EUnsafeOperation do raise;
    on E: Exception do
      Result := TResult<TQueryResult>.Fail(E.Message);
  end;
end;

function TBaseDialectView.BuildDelete(const AModel: TQueryModel): TResult<TQueryResult>;
var
  SQL: TStringBuilder;
begin
  if not AModel.Where.HasConditions then
    raise EUnsafeOperation.Create(
      'DELETE sem WHERE e proibido. Use WhereRaw(''1=1'') para forca-lo explicitamente.');
  try
    SQL := TStringBuilder.Create;
    try
      SQL.Append('DELETE FROM ' + AModel.Table);
      AppendNonEmpty(SQL, RenderWhereClause(AModel));
      Result := TResult<TQueryResult>.Ok(TQueryResult.New(SQL.ToString, ParamsAsArray));
    finally
      SQL.Free;
    end;
  except
    on E: EUnsafeOperation do raise;
    on E: Exception do
      Result := TResult<TQueryResult>.Fail(E.Message);
  end;
end;

function TBaseDialectView.BuildInsert(const AModel: TQueryModel): TResult<TQueryResult>;
var
  SQL: TStringBuilder;
  Ret: string;
begin
  try
    SQL := TStringBuilder.Create;
    try
      SQL.Append('INSERT INTO ' + AModel.Table);
      SQL.Append(' ' + RenderInsertColumns(AModel));
      AppendNonEmpty(SQL, RenderInsertValues(AModel));
      Ret := RenderReturning(AModel);
      if (Ret <> '') and SupportsFeature(dfReturning) then
        AppendNonEmpty(SQL, Ret);
      Result := TResult<TQueryResult>.Ok(TQueryResult.New(SQL.ToString, ParamsAsArray));
    finally
      SQL.Free;
    end;
  except
    on E: Exception do
      Result := TResult<TQueryResult>.Fail(E.Message);
  end;
end;

end.
