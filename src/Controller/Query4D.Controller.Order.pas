unit Query4D.Controller.Order;

interface

uses
  Query4D.Model.Order,
  Query4D.Model.Types,
  Query4D.Controller.Interfaces;

type
  TOrderController = class(TInterfacedObject, IOrderController)
  private
    FOwner: IQuery4DController;
    FModel: TOrderModel;
  public
    constructor Create(const AOwner: IQuery4DController; const AModel: TOrderModel);
    function Asc(const AColumn: string; const ANulls: TNullsOrder = noDefault): IOrderController;
    function Desc(const AColumn: string; const ANulls: TNullsOrder = noDefault): IOrderController;
    function EndOrder: IQuery4DController;
  end;

implementation

uses
  Query4D.Shared.Guard;

{ TOrderController }

constructor TOrderController.Create(
  const AOwner: IQuery4DController; const AModel: TOrderModel);
begin
  TGuard.IsNotNil(AOwner as IInterface, 'TOrderController.Owner');
  TGuard.IsNotNil(AModel, 'TOrderController.Model');
  inherited Create;
  FOwner := AOwner;
  FModel := AModel;
end;

function TOrderController.Asc(const AColumn: string; const ANulls: TNullsOrder): IOrderController;
begin
  FModel.Add(AColumn, odAsc, ANulls);
  Result := Self;
end;

function TOrderController.Desc(const AColumn: string; const ANulls: TNullsOrder): IOrderController;
begin
  FModel.Add(AColumn, odDesc, ANulls);
  Result := Self;
end;

function TOrderController.EndOrder: IQuery4DController;
begin
  Result := FOwner;
end;

end.
