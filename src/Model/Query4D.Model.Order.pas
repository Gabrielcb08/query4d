unit Query4D.Model.Order;

interface

uses
  System.Generics.Collections,
  Query4D.Shared.Guard,
  Query4D.Model.Types;

type
  TOrderItemModel = class
  private
    FColumn: string;
    FDirection: TOrderDirection;
    FNullsOrder: TNullsOrder;
  public
    constructor Create(
      const AColumn: string;
      const ADirection: TOrderDirection = odAsc;
      const ANullsOrder: TNullsOrder = noDefault);
    property Column: string read FColumn;
    property Direction: TOrderDirection read FDirection;
    property NullsOrder: TNullsOrder read FNullsOrder;
  end;

  TOrderModel = class
  private
    FItems: TObjectList<TOrderItemModel>;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Add(
      const AColumn: string;
      const ADirection: TOrderDirection = odAsc;
      const ANullsOrder: TNullsOrder = noDefault);
    function Count: Integer;
    function IsEmpty: Boolean;
    function Item(const AIndex: Integer): TOrderItemModel;
  end;

implementation

uses
  System.SysUtils;

{ TOrderItemModel }

constructor TOrderItemModel.Create(
  const AColumn: string;
  const ADirection: TOrderDirection;
  const ANullsOrder: TNullsOrder);
begin
  TGuard.IsNotEmpty(AColumn, 'Order.Column');
  inherited Create;
  FColumn     := Trim(AColumn);
  FDirection  := ADirection;
  FNullsOrder := ANullsOrder;
end;

{ TOrderModel }

constructor TOrderModel.Create;
begin
  inherited Create;
  FItems := TObjectList<TOrderItemModel>.Create(True);
end;

destructor TOrderModel.Destroy;
begin
  FItems.Free;
  inherited;
end;

procedure TOrderModel.Add(
  const AColumn: string;
  const ADirection: TOrderDirection;
  const ANullsOrder: TNullsOrder);
begin
  FItems.Add(TOrderItemModel.Create(AColumn, ADirection, ANullsOrder));
end;

function TOrderModel.Count: Integer;
begin
  Result := FItems.Count;
end;

function TOrderModel.IsEmpty: Boolean;
begin
  Result := FItems.Count = 0;
end;

function TOrderModel.Item(const AIndex: Integer): TOrderItemModel;
begin
  Result := FItems[AIndex];
end;

end.
