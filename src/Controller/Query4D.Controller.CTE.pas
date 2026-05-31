unit Query4D.Controller.CTE;

interface

uses
  Query4D.Model.CTE,
  Query4D.Controller.Interfaces;

type
  TCTEController = class(TInterfacedObject, ICTEController)
  private
    FOwner: IQuery4DController;
    FModel: TCTEListModel;
  public
    constructor Create(const AOwner: IQuery4DController; const AModel: TCTEListModel);
    function Add(const AName, AQuery: string): ICTEController;
    function AddRecursive(const AName, AAnchor, AMember: string): ICTEController;
    function EndWith: IQuery4DController;
  end;

implementation

uses
  Query4D.Shared.Guard;

{ TCTEController }

constructor TCTEController.Create(
  const AOwner: IQuery4DController; const AModel: TCTEListModel);
begin
  TGuard.IsNotNil(AOwner as IInterface, 'TCTEController.Owner');
  TGuard.IsNotNil(AModel, 'TCTEController.Model');
  inherited Create;
  FOwner := AOwner;
  FModel := AModel;
end;

function TCTEController.Add(const AName, AQuery: string): ICTEController;
begin
  FModel.AddSimple(AName, AQuery);
  Result := Self;
end;

function TCTEController.AddRecursive(const AName, AAnchor, AMember: string): ICTEController;
begin
  FModel.AddRecursive(AName, AAnchor, AMember);
  Result := Self;
end;

function TCTEController.EndWith: IQuery4DController;
begin
  Result := FOwner;
end;

end.
