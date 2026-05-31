unit Query4D.Controller.Joins;

interface

uses
  Query4D.Model.Join,
  Query4D.Model.Types,
  Query4D.Controller.Interfaces;

type
  TJoinsController = class(TInterfacedObject, IJoinsController)
  private
    FOwner: IQuery4DController;
    FModel: TJoinListModel;
  public
    constructor Create(const AOwner: IQuery4DController; const AModel: TJoinListModel);
    function InnerJoin(const ATable, AAlias, AOn: string): IJoinsController;
    function LeftJoin(const ATable, AAlias, AOn: string): IJoinsController;
    function RightJoin(const ATable, AAlias, AOn: string): IJoinsController;
    function FullOuterJoin(const ATable, AAlias, AOn: string): IJoinsController;
    function CrossJoin(const ATable: string; const AAlias: string = ''): IJoinsController;
    function EndJoins: IQuery4DController;
  end;

implementation

uses
  Query4D.Shared.Guard;

{ TJoinsController }

constructor TJoinsController.Create(
  const AOwner: IQuery4DController; const AModel: TJoinListModel);
begin
  TGuard.IsNotNil(AOwner as IInterface, 'TJoinsController.Owner');
  TGuard.IsNotNil(AModel, 'TJoinsController.Model');
  inherited Create;
  FOwner := AOwner;
  FModel := AModel;
end;

function TJoinsController.InnerJoin(const ATable, AAlias, AOn: string): IJoinsController;
begin
  FModel.Add(jtInner, ATable, AAlias, AOn);
  Result := Self;
end;

function TJoinsController.LeftJoin(const ATable, AAlias, AOn: string): IJoinsController;
begin
  FModel.Add(jtLeft, ATable, AAlias, AOn);
  Result := Self;
end;

function TJoinsController.RightJoin(const ATable, AAlias, AOn: string): IJoinsController;
begin
  FModel.Add(jtRight, ATable, AAlias, AOn);
  Result := Self;
end;

function TJoinsController.FullOuterJoin(const ATable, AAlias, AOn: string): IJoinsController;
begin
  FModel.Add(jtFullOuter, ATable, AAlias, AOn);
  Result := Self;
end;

function TJoinsController.CrossJoin(const ATable, AAlias: string): IJoinsController;
begin
  FModel.Add(jtCross, ATable, AAlias, '');
  Result := Self;
end;

function TJoinsController.EndJoins: IQuery4DController;
begin
  Result := FOwner;
end;

end.
