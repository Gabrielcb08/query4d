unit Query4D.Model.Group;

interface

uses
  System.Generics.Collections,
  Query4D.Shared.Guard;

type
  TGroupModel = class
  private
    FColumns: TList<string>;
    FHavingClauses: TList<string>;
  public
    constructor Create;
    destructor Destroy; override;
    procedure AddColumn(const AColumn: string);
    procedure AddHaving(const AExpression: string);
    function ColumnCount: Integer;
    function HavingCount: Integer;
    function IsEmpty: Boolean;
    function Column(const AIndex: Integer): string;
    function Having(const AIndex: Integer): string;
  end;

implementation

uses
  System.SysUtils;

{ TGroupModel }

constructor TGroupModel.Create;
begin
  inherited Create;
  FColumns       := TList<string>.Create;
  FHavingClauses := TList<string>.Create;
end;

destructor TGroupModel.Destroy;
begin
  FColumns.Free;
  FHavingClauses.Free;
  inherited;
end;

procedure TGroupModel.AddColumn(const AColumn: string);
begin
  TGuard.IsNotEmpty(AColumn, 'Group.Column');
  FColumns.Add(Trim(AColumn));
end;

procedure TGroupModel.AddHaving(const AExpression: string);
begin
  TGuard.IsNotEmpty(AExpression, 'Having.Expression');
  FHavingClauses.Add(Trim(AExpression));
end;

function TGroupModel.ColumnCount: Integer;
begin
  Result := FColumns.Count;
end;

function TGroupModel.HavingCount: Integer;
begin
  Result := FHavingClauses.Count;
end;

function TGroupModel.IsEmpty: Boolean;
begin
  Result := FColumns.Count = 0;
end;

function TGroupModel.Column(const AIndex: Integer): string;
begin
  Result := FColumns[AIndex];
end;

function TGroupModel.Having(const AIndex: Integer): string;
begin
  Result := FHavingClauses[AIndex];
end;

end.
