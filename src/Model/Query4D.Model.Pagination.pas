unit Query4D.Model.Pagination;

interface

uses
  Query4D.Shared.Guard;

type
  TPaginationModel = class
  private
    FLimitValue: Integer;
    FOffsetValue: Integer;
    FFirstOnly: Boolean;
    FHasLimit: Boolean;
    FHasOffset: Boolean;
  public
    constructor Create;
    procedure SetLimit(const AValue: Integer);
    procedure SetOffset(const AValue: Integer);
    procedure SetFirstOnly;
    function HasLimit: Boolean;
    function HasOffset: Boolean;
    function IsFirstOnly: Boolean;
    function IsEmpty: Boolean;
    property LimitValue: Integer read FLimitValue;
    property OffsetValue: Integer read FOffsetValue;
  end;

implementation

{ TPaginationModel }

constructor TPaginationModel.Create;
begin
  inherited Create;
  FHasLimit  := False;
  FHasOffset := False;
  FFirstOnly := False;
end;

procedure TPaginationModel.SetLimit(const AValue: Integer);
begin
  TGuard.IsPositive(AValue, 'Pagination.Limit');
  FLimitValue := AValue;
  FHasLimit   := True;
  FFirstOnly  := False;
end;

procedure TPaginationModel.SetOffset(const AValue: Integer);
begin
  TGuard.IsPositive(AValue, 'Pagination.Offset');
  FOffsetValue := AValue;
  FHasOffset   := True;
end;

procedure TPaginationModel.SetFirstOnly;
begin
  FFirstOnly := True;
  FLimitValue := 1;
  FHasLimit  := True;
end;

function TPaginationModel.HasLimit: Boolean;
begin
  Result := FHasLimit;
end;

function TPaginationModel.HasOffset: Boolean;
begin
  Result := FHasOffset;
end;

function TPaginationModel.IsFirstOnly: Boolean;
begin
  Result := FFirstOnly;
end;

function TPaginationModel.IsEmpty: Boolean;
begin
  Result := not FHasLimit and not FHasOffset;
end;

end.
