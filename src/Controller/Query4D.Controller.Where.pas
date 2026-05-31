unit Query4D.Controller.Where;

interface

uses
  System.Generics.Collections,
  Query4D.Model.Where,
  Query4D.Model.Types,
  Query4D.Controller.Interfaces;

type
  TWhereController = class(TInterfacedObject, IWhereController)
  private
    FOwner: IQuery4DController;
    FWhereModel: TWhereModel;
    FGroupStack: TStack<TWhereGroupModel>;
    FCurrentGroup: TWhereGroupModel;

    procedure AddPredicate(const APred: TWherePredicateModel);
  public
    constructor Create(const AOwner: IQuery4DController; const AModel: TWhereModel);
    destructor Destroy; override;

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

implementation

uses
  Query4D.Shared.Guard;

{ TWhereController }

constructor TWhereController.Create(
  const AOwner: IQuery4DController; const AModel: TWhereModel);
begin
  TGuard.IsNotNil(AOwner as IInterface, 'TWhereController.Owner');
  TGuard.IsNotNil(AModel, 'TWhereController.Model');
  inherited Create;
  FOwner        := AOwner;
  FWhereModel   := AModel;
  FGroupStack   := TStack<TWhereGroupModel>.Create;
  FCurrentGroup := AModel.Root;
end;

destructor TWhereController.Destroy;
begin
  FGroupStack.Free;
  inherited;
end;

procedure TWhereController.AddPredicate(const APred: TWherePredicateModel);
begin
  FCurrentGroup.AddPredicate(APred);
end;

function TWhereController.Equal(const AColumn, AValue: string): IWhereController;
begin
  AddPredicate(TWherePredicateModel.CreateSimple(AColumn, woEqual, AValue));
  Result := Self;
end;

function TWhereController.NotEqual(const AColumn, AValue: string): IWhereController;
begin
  AddPredicate(TWherePredicateModel.CreateSimple(AColumn, woNotEqual, AValue));
  Result := Self;
end;

function TWhereController.GreaterThan(const AColumn, AValue: string): IWhereController;
begin
  AddPredicate(TWherePredicateModel.CreateSimple(AColumn, woGreaterThan, AValue));
  Result := Self;
end;

function TWhereController.GreaterThanOrEqualTo(const AColumn, AValue: string): IWhereController;
begin
  AddPredicate(TWherePredicateModel.CreateSimple(AColumn, woGreaterThanOrEqualTo, AValue));
  Result := Self;
end;

function TWhereController.LessThan(const AColumn, AValue: string): IWhereController;
begin
  AddPredicate(TWherePredicateModel.CreateSimple(AColumn, woLessThan, AValue));
  Result := Self;
end;

function TWhereController.LessThanOrEqualTo(const AColumn, AValue: string): IWhereController;
begin
  AddPredicate(TWherePredicateModel.CreateSimple(AColumn, woLessThanOrEqualTo, AValue));
  Result := Self;
end;

function TWhereController.Contains(const AColumn, AValue: string): IWhereController;
begin
  AddPredicate(TWherePredicateModel.CreateSimple(AColumn, woContains, '%' + AValue + '%'));
  Result := Self;
end;

function TWhereController.NotContains(const AColumn, AValue: string): IWhereController;
begin
  AddPredicate(TWherePredicateModel.CreateSimple(AColumn, woNotContains, '%' + AValue + '%'));
  Result := Self;
end;

function TWhereController.StartsWith(const AColumn, AValue: string): IWhereController;
begin
  AddPredicate(TWherePredicateModel.CreateSimple(AColumn, woStartsWith, AValue + '%'));
  Result := Self;
end;

function TWhereController.EndsWith(const AColumn, AValue: string): IWhereController;
begin
  AddPredicate(TWherePredicateModel.CreateSimple(AColumn, woEndsWith, '%' + AValue));
  Result := Self;
end;

function TWhereController.ContainsCaseInsensitive(const AColumn, AValue: string): IWhereController;
begin
  AddPredicate(TWherePredicateModel.CreateSimple(AColumn, woContainsCaseInsensitive, '%' + AValue + '%'));
  Result := Self;
end;

function TWhereController.IsNull(const AColumn: string): IWhereController;
begin
  AddPredicate(TWherePredicateModel.CreateNullCheck(AColumn, True));
  Result := Self;
end;

function TWhereController.IsNotNull(const AColumn: string): IWhereController;
begin
  AddPredicate(TWherePredicateModel.CreateNullCheck(AColumn, False));
  Result := Self;
end;

function TWhereController.IsBetween(const AColumn, AFrom, ATo: string): IWhereController;
begin
  AddPredicate(TWherePredicateModel.CreateBetween(AColumn, AFrom, ATo));
  Result := Self;
end;

function TWhereController.IsNotBetween(const AColumn, AFrom, ATo: string): IWhereController;
begin
  AddPredicate(TWherePredicateModel.CreateBetween(AColumn, AFrom, ATo, True));
  Result := Self;
end;

function TWhereController.IsIn(
  const AColumn: string; const AValues: TArray<string>): IWhereController;
begin
  AddPredicate(TWherePredicateModel.CreateIn(AColumn, AValues));
  Result := Self;
end;

function TWhereController.IsNotIn(
  const AColumn: string; const AValues: TArray<string>): IWhereController;
begin
  AddPredicate(TWherePredicateModel.CreateIn(AColumn, AValues, True));
  Result := Self;
end;

function TWhereController.IsTrue(const AColumn: string): IWhereController;
begin
  AddPredicate(TWherePredicateModel.CreateSimple(AColumn, woIsTrue, ''));
  Result := Self;
end;

function TWhereController.IsFalse(const AColumn: string): IWhereController;
begin
  AddPredicate(TWherePredicateModel.CreateSimple(AColumn, woIsFalse, ''));
  Result := Self;
end;

function TWhereController.Exists(const ASubQuery: string): IWhereController;
begin
  AddPredicate(TWherePredicateModel.CreateSimple(ASubQuery, woExists, ''));
  Result := Self;
end;

function TWhereController.Raw(const AExpression: string): IWhereController;
begin
  AddPredicate(TWherePredicateModel.CreateRaw(AExpression));
  Result := Self;
end;

// Empilha o grupo atual e cria um sub-grupo com lógica OR
function TWhereController.OrBegin: IWhereController;
var
  OrGroup: TWhereGroupModel;
begin
  FGroupStack.Push(FCurrentGroup);
  OrGroup       := TWhereGroupModel.Create(loOr);
  FCurrentGroup := OrGroup;
  Result := Self;
end;

// Fecha o sub-grupo OR e o adiciona ao pai com AND
function TWhereController.OrEnd: IWhereController;
var
  ClosedGroup, Parent: TWhereGroupModel;
begin
  TGuard.IsTrue(FGroupStack.Count > 0, 'OrEnd chamado sem OrBegin correspondente');
  ClosedGroup := FCurrentGroup;
  Parent      := FGroupStack.Pop;
  Parent.AddGroup(ClosedGroup, loAnd);
  FCurrentGroup := Parent;
  Result := Self;
end;

// Empilha o grupo atual e cria um sub-grupo com lógica AND
function TWhereController.AndBegin: IWhereController;
var
  AndGroup: TWhereGroupModel;
begin
  FGroupStack.Push(FCurrentGroup);
  AndGroup      := TWhereGroupModel.Create(loAnd);
  FCurrentGroup := AndGroup;
  Result := Self;
end;

// Fecha o sub-grupo AND e o adiciona ao pai com AND
function TWhereController.AndEnd: IWhereController;
var
  ClosedGroup, Parent: TWhereGroupModel;
begin
  TGuard.IsTrue(FGroupStack.Count > 0, 'AndEnd chamado sem AndBegin correspondente');
  ClosedGroup := FCurrentGroup;
  Parent      := FGroupStack.Pop;
  Parent.AddGroup(ClosedGroup, loAnd);
  FCurrentGroup := Parent;
  Result := Self;
end;

function TWhereController.EndWhere: IQuery4DController;
begin
  TGuard.IsTrue(FGroupStack.Count = 0, 'OrBegin/AndBegin sem End correspondente');
  Result := FOwner;
end;

end.
