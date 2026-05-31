unit Query4D.Model.Join;

interface

uses
  System.Generics.Collections,
  Query4D.Shared.Guard,
  Query4D.Model.Types;

type
  TJoinModel = class
  private
    FJoinType: TJoinType;
    FTable: string;
    FAlias: string;
    FOnClause: string;
  public
    // AOnClause pode ser vazio para CROSS JOIN
    constructor Create(
      const AJoinType: TJoinType;
      const ATable, AAlias, AOnClause: string);
    function HasAlias: Boolean;
    property JoinType: TJoinType read FJoinType;
    property Table: string read FTable;
    property Alias: string read FAlias;
    property OnClause: string read FOnClause;
  end;

  TJoinListModel = class
  private
    FItems: TObjectList<TJoinModel>;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Add(
      const AJoinType: TJoinType;
      const ATable, AAlias, AOnClause: string);
    function Count: Integer;
    function IsEmpty: Boolean;
    function Item(const AIndex: Integer): TJoinModel;
  end;

implementation

uses
  System.SysUtils;

{ TJoinModel }

constructor TJoinModel.Create(
  const AJoinType: TJoinType;
  const ATable, AAlias, AOnClause: string);
begin
  TGuard.IsNotEmpty(ATable, 'Join.Table');
  if AJoinType <> jtCross then
    TGuard.IsNotEmpty(AOnClause, 'Join.OnClause');
  inherited Create;
  FJoinType := AJoinType;
  FTable    := Trim(ATable);
  FAlias    := Trim(AAlias);
  FOnClause := Trim(AOnClause);
end;

function TJoinModel.HasAlias: Boolean;
begin
  Result := FAlias <> '';
end;

{ TJoinListModel }

constructor TJoinListModel.Create;
begin
  inherited Create;
  FItems := TObjectList<TJoinModel>.Create(True);
end;

destructor TJoinListModel.Destroy;
begin
  FItems.Free;
  inherited;
end;

procedure TJoinListModel.Add(
  const AJoinType: TJoinType;
  const ATable, AAlias, AOnClause: string);
begin
  FItems.Add(TJoinModel.Create(AJoinType, ATable, AAlias, AOnClause));
end;

function TJoinListModel.Count: Integer;
begin
  Result := FItems.Count;
end;

function TJoinListModel.IsEmpty: Boolean;
begin
  Result := FItems.Count = 0;
end;

function TJoinListModel.Item(const AIndex: Integer): TJoinModel;
begin
  Result := FItems[AIndex];
end;

end.
