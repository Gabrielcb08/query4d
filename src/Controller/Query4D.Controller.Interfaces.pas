unit Query4D.Controller.Interfaces;

interface

uses
  Query4D.Shared.Result,
  Query4D.Model.Types,
  Query4D.View.Interfaces;

type
  IQuery4DController = interface;
  IFieldsController  = interface;
  IWhereController   = interface;
  IJoinsController   = interface;
  IOrderController   = interface;
  IGroupController   = interface;
  ICTEController     = interface;

  // ── campos SELECT ──────────────────────────────────────────────────────────
  IFieldsController = interface
    ['{F1E2D3C4-B5A6-7890-F1E2-D3C4B5A67890}']
    function Add(const AExpression: string): IFieldsController;
    function AddAs(const AExpression, AAlias: string): IFieldsController;
    function EndFields: IQuery4DController;
  end;

  // ── predicados WHERE ───────────────────────────────────────────────────────
  IWhereController = interface
    ['{A1B2C3D4-E5F6-7890-A1B2-C3D4E5F67890}']
    // Comparação
    function Equal(const AColumn, AValue: string): IWhereController;
    function NotEqual(const AColumn, AValue: string): IWhereController;
    function GreaterThan(const AColumn, AValue: string): IWhereController;
    function GreaterThanOrEqualTo(const AColumn, AValue: string): IWhereController;
    function LessThan(const AColumn, AValue: string): IWhereController;
    function LessThanOrEqualTo(const AColumn, AValue: string): IWhereController;
    // Texto
    function Contains(const AColumn, AValue: string): IWhereController;
    function NotContains(const AColumn, AValue: string): IWhereController;
    function StartsWith(const AColumn, AValue: string): IWhereController;
    function EndsWith(const AColumn, AValue: string): IWhereController;
    function ContainsCaseInsensitive(const AColumn, AValue: string): IWhereController;
    // Nulidade
    function IsNull(const AColumn: string): IWhereController;
    function IsNotNull(const AColumn: string): IWhereController;
    // Intervalo
    function IsBetween(const AColumn, AFrom, ATo: string): IWhereController;
    function IsNotBetween(const AColumn, AFrom, ATo: string): IWhereController;
    // Lista
    function IsIn(const AColumn: string; const AValues: TArray<string>): IWhereController;
    function IsNotIn(const AColumn: string; const AValues: TArray<string>): IWhereController;
    // Booleano
    function IsTrue(const AColumn: string): IWhereController;
    function IsFalse(const AColumn: string): IWhereController;
    // Misc
    function Exists(const ASubQuery: string): IWhereController;
    function Raw(const AExpression: string): IWhereController;
    // Agrupamento lógico
    function OrBegin: IWhereController;
    function OrEnd: IWhereController;
    function AndBegin: IWhereController;
    function AndEnd: IWhereController;
    function EndWhere: IQuery4DController;
  end;

  // ── JOINs ──────────────────────────────────────────────────────────────────
  IJoinsController = interface
    ['{B2C3D4E5-F6A7-8901-B2C3-D4E5F6A78901}']
    function InnerJoin(const ATable, AAlias, AOn: string): IJoinsController;
    function LeftJoin(const ATable, AAlias, AOn: string): IJoinsController;
    function RightJoin(const ATable, AAlias, AOn: string): IJoinsController;
    function FullOuterJoin(const ATable, AAlias, AOn: string): IJoinsController;
    function CrossJoin(const ATable: string; const AAlias: string = ''): IJoinsController;
    function EndJoins: IQuery4DController;
  end;

  // ── ORDER BY ───────────────────────────────────────────────────────────────
  IOrderController = interface
    ['{C3D4E5F6-A7B8-9012-C3D4-E5F6A7B89012}']
    function Asc(const AColumn: string; const ANulls: TNullsOrder = noDefault): IOrderController;
    function Desc(const AColumn: string; const ANulls: TNullsOrder = noDefault): IOrderController;
    function EndOrder: IQuery4DController;
  end;

  // ── GROUP BY / HAVING ──────────────────────────────────────────────────────
  IGroupController = interface
    ['{D4E5F6A7-B8C9-0123-D4E5-F6A7B8C90123}']
    function By(const AColumn: string): IGroupController;
    function Having(const AExpression: string): IGroupController;
    function EndGroup: IQuery4DController;
  end;

  // ── CTEs ───────────────────────────────────────────────────────────────────
  ICTEController = interface
    ['{E5F6A7B8-C9D0-1234-E5F6-A7B8C9D01234}']
    function Add(const AName, AQuery: string): ICTEController;
    function AddRecursive(const AName, AAnchor, AMember: string): ICTEController;
    function EndWith: IQuery4DController;
  end;

  // ── Query principal ────────────────────────────────────────────────────────
  IQuery4DController = interface
    ['{00112233-4455-6677-8899-AABBCCDDEEFF}']

    // FROM
    function From(const ATable: string): IQuery4DController; overload;
    function From(const ATable, AAlias: string): IQuery4DController; overload;

    // SELECT simples
    function Select(const AFields: array of string): IQuery4DController;
    function SelectAll: IQuery4DController;
    function Distinct: IQuery4DController;

    // Sub-builders fluentes
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

end.
