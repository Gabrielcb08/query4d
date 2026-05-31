unit Query4D.Controller;

interface

uses
  Query4D.Shared.Guard,
  Query4D.Shared.Result,
  Query4D.Shared.Exceptions,
  Query4D.Model.Types,
  Query4D.Model.Query,
  Query4D.View.Interfaces,
  Query4D.Controller.Interfaces;

type
  TQuery4DController = class(TInterfacedObject, IQuery4DController)
  private
    FDialect: IDialectView;
    FModel: TQueryModel;
  public
    constructor Create(const ADialect: IDialectView);
    destructor Destroy; override;

    class function New(const ADialect: IDialectView): IQuery4DController;

    // FROM
    function From(const ATable: string): IQuery4DController; overload;
    function From(const ATable, AAlias: string): IQuery4DController; overload;

    // SELECT
    function Select(const AFields: array of string): IQuery4DController;
    function SelectAll: IQuery4DController;
    function Distinct: IQuery4DController;

    // Sub-builders
    function BeginFields: IFieldsController;
    function BeginWhere: IWhereController;
    function BeginJoins: IJoinsController;
    function BeginOrder: IOrderController;
    function BeginGroup: IGroupController;
    function BeginWith: ICTEController;

    // Atalhos WHERE
    function WhereEq(const AColumn, AValue: string): IQuery4DController;
    function WhereRaw(const AExpression: string): IQuery4DController;

    // Atalhos JOIN
    function Join(const ATable, AAlias, AOn: string): IQuery4DController;
    function LeftJoin(const ATable, AAlias, AOn: string): IQuery4DController;

    // Atalhos ORDER
    function OrderBy(const AColumn: string; const ADir: TOrderDirection = odAsc): IQuery4DController;

    // Atalhos GROUP
    function GroupBy(const AColumn: string): IQuery4DController;
    function Having(const AExpression: string): IQuery4DController;

    // Paginacao
    function Limit(const ACount: Integer): IQuery4DController;
    function Offset(const ACount: Integer): IQuery4DController;
    function First: IQuery4DController;

    // DML
    function DeleteFrom(const ATable: string): IQuery4DController;
    function Update(const ATable: string): IQuery4DController;
    function SetValue(const AColumn, AValue: string): IQuery4DController;
    function SetRaw(const AColumn, ARawExpr: string): IQuery4DController;
    function InsertInto(const ATable: string): IQuery4DController;
    function BeginRow: IQuery4DController;
    function Value(const AColumn, AVal: string): IQuery4DController;
    function Returning(const AColumns: array of string): IQuery4DController;

    // Build
    function Build: TResult<TQueryResult>;
  end;

implementation

uses
  Query4D.Model.Where,
  Query4D.Model.DML,
  Query4D.Controller.Fields,
  Query4D.Controller.Where,
  Query4D.Controller.Joins,
  Query4D.Controller.Order,
  Query4D.Controller.Group,
  Query4D.Controller.CTE;

{ TQuery4DController }

constructor TQuery4DController.Create(const ADialect: IDialectView);
begin
  TGuard.IsNotNil(ADialect, 'IDialectView');
  inherited Create;
  FDialect := ADialect;
  FModel   := TQueryModel.Create;
end;

destructor TQuery4DController.Destroy;
begin
  FModel.Free;
  inherited;
end;

class function TQuery4DController.New(const ADialect: IDialectView): IQuery4DController;
begin
  Result := TQuery4DController.Create(ADialect);
end;

function TQuery4DController.From(const ATable: string): IQuery4DController;
begin
  FModel.Table := ATable;
  Result := Self;
end;

function TQuery4DController.From(const ATable, AAlias: string): IQuery4DController;
begin
  FModel.Table      := ATable;
  FModel.TableAlias := AAlias;
  Result := Self;
end;

function TQuery4DController.Select(const AFields: array of string): IQuery4DController;
var
  F: string;
begin
  for F in AFields do
    FModel.Fields.Add(F);
  Result := Self;
end;

function TQuery4DController.SelectAll: IQuery4DController;
begin
  FModel.Fields.Clear;
  Result := Self;
end;

function TQuery4DController.Distinct: IQuery4DController;
begin
  FModel.Distinct := True;
  Result := Self;
end;

function TQuery4DController.BeginFields: IFieldsController;
begin
  Result := TFieldsController.Create(Self, FModel.Fields);
end;

function TQuery4DController.BeginWhere: IWhereController;
begin
  Result := TWhereController.Create(Self, FModel.Where);
end;

function TQuery4DController.BeginJoins: IJoinsController;
begin
  Result := TJoinsController.Create(Self, FModel.Joins);
end;

function TQuery4DController.BeginOrder: IOrderController;
begin
  Result := TOrderController.Create(Self, FModel.Order);
end;

function TQuery4DController.BeginGroup: IGroupController;
begin
  Result := TGroupController.Create(Self, FModel.Group);
end;

function TQuery4DController.BeginWith: ICTEController;
begin
  Result := TCTEController.Create(Self, FModel.CTEs);
end;

function TQuery4DController.WhereEq(const AColumn, AValue: string): IQuery4DController;
begin
  FModel.Where.Root.AddPredicate(
    TWherePredicateModel.CreateSimple(AColumn, woEqual, AValue));
  Result := Self;
end;

function TQuery4DController.WhereRaw(const AExpression: string): IQuery4DController;
begin
  FModel.Where.Root.AddPredicate(
    TWherePredicateModel.CreateRaw(AExpression));
  Result := Self;
end;

function TQuery4DController.Join(const ATable, AAlias, AOn: string): IQuery4DController;
begin
  FModel.Joins.Add(jtInner, ATable, AAlias, AOn);
  Result := Self;
end;

function TQuery4DController.LeftJoin(const ATable, AAlias, AOn: string): IQuery4DController;
begin
  FModel.Joins.Add(jtLeft, ATable, AAlias, AOn);
  Result := Self;
end;

function TQuery4DController.OrderBy(
  const AColumn: string; const ADir: TOrderDirection): IQuery4DController;
begin
  FModel.Order.Add(AColumn, ADir);
  Result := Self;
end;

function TQuery4DController.GroupBy(const AColumn: string): IQuery4DController;
begin
  FModel.Group.AddColumn(AColumn);
  Result := Self;
end;

function TQuery4DController.Having(const AExpression: string): IQuery4DController;
begin
  FModel.Group.AddHaving(AExpression);
  Result := Self;
end;

function TQuery4DController.Limit(const ACount: Integer): IQuery4DController;
begin
  FModel.Pagination.SetLimit(ACount);
  Result := Self;
end;

function TQuery4DController.Offset(const ACount: Integer): IQuery4DController;
begin
  FModel.Pagination.SetOffset(ACount);
  Result := Self;
end;

function TQuery4DController.First: IQuery4DController;
begin
  FModel.Pagination.SetFirstOnly;
  Result := Self;
end;

function TQuery4DController.DeleteFrom(const ATable: string): IQuery4DController;
begin
  FModel.QueryType := qtDelete;
  FModel.Table     := ATable;
  Result := Self;
end;

function TQuery4DController.Update(const ATable: string): IQuery4DController;
begin
  FModel.QueryType := qtUpdate;
  FModel.Table     := ATable;
  Result := Self;
end;

function TQuery4DController.SetValue(const AColumn, AValue: string): IQuery4DController;
begin
  FModel.SetValues.Add(AColumn, AValue, svkParam);
  Result := Self;
end;

function TQuery4DController.SetRaw(const AColumn, ARawExpr: string): IQuery4DController;
begin
  FModel.SetValues.Add(AColumn, ARawExpr, svkRaw);
  Result := Self;
end;

function TQuery4DController.InsertInto(const ATable: string): IQuery4DController;
begin
  FModel.QueryType := qtInsert;
  FModel.Table     := ATable;
  Result := Self;
end;

function TQuery4DController.BeginRow: IQuery4DController;
begin
  FModel.Insert.BeginRow;
  Result := Self;
end;

function TQuery4DController.Value(const AColumn, AVal: string): IQuery4DController;
begin
  FModel.Insert.AddValue(AColumn, AVal);
  Result := Self;
end;

function TQuery4DController.Returning(const AColumns: array of string): IQuery4DController;
var
  C: string;
begin
  for C in AColumns do
    FModel.Returning.Add(C);
  Result := Self;
end;

function TQuery4DController.Build: TResult<TQueryResult>;
begin
  TGuard.IsNotNil(FDialect, 'IDialectView');
  if (FModel.QueryType in [qtUpdate, qtDelete]) and not FModel.Where.HasConditions then
    raise EUnsafeOperation.Create(
      'UPDATE/DELETE sem WHERE e proibido. Use WhereRaw(''1=1'') para forca-lo.');
  Result := FDialect.Render(FModel);
end;

end.
