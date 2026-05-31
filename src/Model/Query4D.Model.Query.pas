unit Query4D.Model.Query;

interface

uses
  Query4D.Model.Types,
  Query4D.Model.Field,
  Query4D.Model.Where,
  Query4D.Model.Join,
  Query4D.Model.Order,
  Query4D.Model.Group,
  Query4D.Model.CTE,
  Query4D.Model.Pagination,
  Query4D.Model.DML;

type
  TQueryModel = class
  private
    FQueryType: TQueryType;
    FTable: string;
    FTableAlias: string;
    FFields: TFieldListModel;
    FJoins: TJoinListModel;
    FWhere: TWhereModel;
    FOrder: TOrderModel;
    FGroup: TGroupModel;
    FCTEs: TCTEListModel;
    FPagination: TPaginationModel;
    FSetValues: TSetValueListModel;
    FInsert: TInsertModel;
    FReturning: TReturningModel;
    FDistinct: Boolean;
  public
    constructor Create;
    destructor Destroy; override;

    property QueryType: TQueryType   read FQueryType  write FQueryType;
    property Table: string           read FTable      write FTable;
    property TableAlias: string      read FTableAlias write FTableAlias;
    property Distinct: Boolean       read FDistinct   write FDistinct;

    property Fields: TFieldListModel    read FFields;
    property Joins: TJoinListModel      read FJoins;
    property Where: TWhereModel         read FWhere;
    property Order: TOrderModel         read FOrder;
    property Group: TGroupModel         read FGroup;
    property CTEs: TCTEListModel        read FCTEs;
    property Pagination: TPaginationModel read FPagination;
    property SetValues: TSetValueListModel read FSetValues;
    property Insert: TInsertModel       read FInsert;
    property Returning: TReturningModel read FReturning;

    function HasAlias: Boolean;
  end;

implementation

{ TQueryModel }

constructor TQueryModel.Create;
begin
  inherited Create;
  FQueryType  := qtSelect;
  FDistinct   := False;
  FFields     := TFieldListModel.Create;
  FJoins      := TJoinListModel.Create;
  FWhere      := TWhereModel.Create;
  FOrder      := TOrderModel.Create;
  FGroup      := TGroupModel.Create;
  FCTEs       := TCTEListModel.Create;
  FPagination := TPaginationModel.Create;
  FSetValues  := TSetValueListModel.Create;
  FInsert     := TInsertModel.Create;
  FReturning  := TReturningModel.Create;
end;

destructor TQueryModel.Destroy;
begin
  FFields.Free;
  FJoins.Free;
  FWhere.Free;
  FOrder.Free;
  FGroup.Free;
  FCTEs.Free;
  FPagination.Free;
  FSetValues.Free;
  FInsert.Free;
  FReturning.Free;
  inherited;
end;

function TQueryModel.HasAlias: Boolean;
begin
  Result := FTableAlias <> '';
end;

end.
