unit Query4D.Controller.Fields;

interface

uses
  Query4D.Model.Field,
  Query4D.Controller.Interfaces;

type
  TFieldsController = class(TInterfacedObject, IFieldsController)
  private
    FOwner: IQuery4DController;
    FModel: TFieldListModel;
  public
    constructor Create(const AOwner: IQuery4DController; const AModel: TFieldListModel);
    function Add(const AExpression: string): IFieldsController;
    function AddAs(const AExpression, AAlias: string): IFieldsController;
    function EndFields: IQuery4DController;
  end;

implementation

uses
  Query4D.Shared.Guard;

{ TFieldsController }

constructor TFieldsController.Create(
  const AOwner: IQuery4DController; const AModel: TFieldListModel);
begin
  TGuard.IsNotNil(AOwner as IInterface, 'TFieldsController.Owner');
  TGuard.IsNotNil(AModel, 'TFieldsController.Model');
  inherited Create;
  FOwner := AOwner;
  FModel := AModel;
end;

function TFieldsController.Add(const AExpression: string): IFieldsController;
begin
  FModel.Add(AExpression);
  Result := Self;
end;

function TFieldsController.AddAs(const AExpression, AAlias: string): IFieldsController;
begin
  FModel.AddAs(AExpression, AAlias);
  Result := Self;
end;

function TFieldsController.EndFields: IQuery4DController;
begin
  Result := FOwner;
end;

end.
