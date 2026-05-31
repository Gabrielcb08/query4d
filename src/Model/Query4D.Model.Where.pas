unit Query4D.Model.Where;

interface

uses
  System.Generics.Collections,
  Query4D.Shared.Guard,
  Query4D.Model.Types;

type
  TWhereGroupModel = class;

  TWhereNodeKind = (wnkPredicate, wnkGroup);

  TWherePredicateModel = class
  private
    FColumn: string;
    FOperator: TWhereOperator;
    FValue: string;
    FValues: TArray<string>;
    FValueTo: string;
    FLogical: TLogicalOperator;
  public
    constructor CreateSimple(
      const AColumn: string; const AOp: TWhereOperator;
      const AValue: string; const ALogical: TLogicalOperator = loAnd);
    constructor CreateIn(
      const AColumn: string; const AValues: TArray<string>;
      const ANegate: Boolean = False; const ALogical: TLogicalOperator = loAnd);
    constructor CreateBetween(
      const AColumn, AFrom, ATo: string;
      const ANegate: Boolean = False;
      const ALogical: TLogicalOperator = loAnd);
    constructor CreateNullCheck(
      const AColumn: string; const AIsNull: Boolean;
      const ALogical: TLogicalOperator = loAnd);
    constructor CreateRaw(
      const AExpression: string;
      const ALogical: TLogicalOperator = loAnd);
    property Column: string read FColumn;
    property Op: TWhereOperator read FOperator;
    property Value: string read FValue;
    property Values: TArray<string> read FValues;
    property ValueTo: string read FValueTo;
    property Logical: TLogicalOperator read FLogical;
  end;

  TWhereNode = class
  private
    FKind: TWhereNodeKind;
    FPredicate: TWherePredicateModel;
    FGroup: TWhereGroupModel;
    FLogical: TLogicalOperator;
  public
    constructor CreateFromPredicate(
      const APred: TWherePredicateModel;
      const ALogical: TLogicalOperator = loAnd);
    constructor CreateFromGroup(
      const AGroup: TWhereGroupModel;
      const ALogical: TLogicalOperator = loAnd);
    destructor Destroy; override;
    property Kind: TWhereNodeKind read FKind;
    property Predicate: TWherePredicateModel read FPredicate;
    property Group: TWhereGroupModel read FGroup;
    property Logical: TLogicalOperator read FLogical;
  end;

  TWhereGroupModel = class
  private
    FNodes: TObjectList<TWhereNode>;
    FDefaultLogical: TLogicalOperator;
  public
    constructor Create(const ADefaultLogical: TLogicalOperator = loAnd);
    destructor Destroy; override;
    procedure AddPredicate(const APred: TWherePredicateModel);
    procedure AddGroup(const AGroup: TWhereGroupModel; const ALogical: TLogicalOperator = loAnd);
    function Count: Integer;
    function IsEmpty: Boolean;
    function Node(const AIndex: Integer): TWhereNode;
    property DefaultLogical: TLogicalOperator read FDefaultLogical;
  end;

  TWhereModel = class
  private
    FRoot: TWhereGroupModel;
  public
    constructor Create;
    destructor Destroy; override;
    function HasConditions: Boolean;
    property Root: TWhereGroupModel read FRoot;
  end;

implementation

{ TWherePredicateModel }

constructor TWherePredicateModel.CreateSimple(
  const AColumn: string; const AOp: TWhereOperator;
  const AValue: string; const ALogical: TLogicalOperator);
begin
  TGuard.IsNotEmpty(AColumn, 'Where.Column');
  inherited Create;
  FColumn   := AColumn;
  FOperator := AOp;
  FValue    := AValue;
  FLogical  := ALogical;
end;

constructor TWherePredicateModel.CreateIn(
  const AColumn: string; const AValues: TArray<string>;
  const ANegate: Boolean; const ALogical: TLogicalOperator);
begin
  TGuard.IsNotEmpty(AColumn, 'Where.Column');
  inherited Create;
  FColumn := AColumn;
  if ANegate then FOperator := woIsNotIn else FOperator := woIsIn;
  FValues  := AValues;
  FLogical := ALogical;
end;

constructor TWherePredicateModel.CreateBetween(
  const AColumn, AFrom, ATo: string;
  const ANegate: Boolean; const ALogical: TLogicalOperator);
begin
  TGuard.IsNotEmpty(AColumn, 'Where.Column');
  inherited Create;
  FColumn   := AColumn;
  if ANegate then FOperator := woIsNotBetween else FOperator := woIsBetween;
  FValue    := AFrom;
  FValueTo  := ATo;
  FLogical  := ALogical;
end;

constructor TWherePredicateModel.CreateNullCheck(
  const AColumn: string; const AIsNull: Boolean; const ALogical: TLogicalOperator);
begin
  TGuard.IsNotEmpty(AColumn, 'Where.Column');
  inherited Create;
  FColumn := AColumn;
  if AIsNull then FOperator := woIsNull else FOperator := woIsNotNull;
  FLogical := ALogical;
end;

constructor TWherePredicateModel.CreateRaw(
  const AExpression: string; const ALogical: TLogicalOperator);
begin
  TGuard.IsNotEmpty(AExpression, 'Where.RawExpression');
  inherited Create;
  FColumn   := AExpression;
  FOperator := woRaw;
  FLogical  := ALogical;
end;

{ TWhereNode }

constructor TWhereNode.CreateFromPredicate(
  const APred: TWherePredicateModel; const ALogical: TLogicalOperator);
begin
  inherited Create;
  FKind      := wnkPredicate;
  FPredicate := APred;
  FLogical   := ALogical;
end;

constructor TWhereNode.CreateFromGroup(
  const AGroup: TWhereGroupModel; const ALogical: TLogicalOperator);
begin
  inherited Create;
  FKind    := wnkGroup;
  FGroup   := AGroup;
  FLogical := ALogical;
end;

destructor TWhereNode.Destroy;
begin
  FPredicate.Free;
  FGroup.Free;
  inherited;
end;

{ TWhereGroupModel }

constructor TWhereGroupModel.Create(const ADefaultLogical: TLogicalOperator);
begin
  inherited Create;
  FDefaultLogical := ADefaultLogical;
  FNodes := TObjectList<TWhereNode>.Create(True);
end;

destructor TWhereGroupModel.Destroy;
begin
  FNodes.Free;
  inherited;
end;

procedure TWhereGroupModel.AddPredicate(const APred: TWherePredicateModel);
var
  LogicalOp: TLogicalOperator;
begin
  if FNodes.Count = 0 then
    LogicalOp := loAnd
  else
    LogicalOp := FDefaultLogical;
  FNodes.Add(TWhereNode.CreateFromPredicate(APred, LogicalOp));
end;

procedure TWhereGroupModel.AddGroup(
  const AGroup: TWhereGroupModel; const ALogical: TLogicalOperator);
begin
  FNodes.Add(TWhereNode.CreateFromGroup(AGroup, ALogical));
end;

function TWhereGroupModel.Count: Integer;
begin
  Result := FNodes.Count;
end;

function TWhereGroupModel.IsEmpty: Boolean;
begin
  Result := FNodes.Count = 0;
end;

function TWhereGroupModel.Node(const AIndex: Integer): TWhereNode;
begin
  Result := FNodes[AIndex];
end;

{ TWhereModel }

constructor TWhereModel.Create;
begin
  inherited Create;
  FRoot := TWhereGroupModel.Create(loAnd);
end;

destructor TWhereModel.Destroy;
begin
  FRoot.Free;
  inherited;
end;

function TWhereModel.HasConditions: Boolean;
begin
  Result := not FRoot.IsEmpty;
end;

end.
