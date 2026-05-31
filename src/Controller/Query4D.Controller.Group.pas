unit Query4D.Controller.Group;

interface

uses
  Query4D.Model.Group,
  Query4D.Controller.Interfaces;

type
  TGroupController = class(TInterfacedObject, IGroupController)
  private
    FOwner: IQuery4DController;
    FModel: TGroupModel;
  public
    constructor Create(const AOwner: IQuery4DController; const AModel: TGroupModel);
    function By(const AColumn: string): IGroupController;
    function Having(const AExpression: string): IGroupController;
    function EndGroup: IQuery4DController;
  end;

implementation

uses
  Query4D.Shared.Guard;

{ TGroupController }

constructor TGroupController.Create(
  const AOwner: IQuery4DController; const AModel: TGroupModel);
begin
  TGuard.IsNotNil(AOwner as IInterface, 'TGroupController.Owner');
  TGuard.IsNotNil(AModel, 'TGroupController.Model');
  inherited Create;
  FOwner := AOwner;
  FModel := AModel;
end;

function TGroupController.By(const AColumn: string): IGroupController;
begin
  FModel.AddColumn(AColumn);
  Result := Self;
end;

function TGroupController.Having(const AExpression: string): IGroupController;
begin
  FModel.AddHaving(AExpression);
  Result := Self;
end;

function TGroupController.EndGroup: IQuery4DController;
begin
  Result := FOwner;
end;

end.
