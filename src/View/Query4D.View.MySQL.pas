unit Query4D.View.MySQL;

interface

uses
  Query4D.Model.Types,
  Query4D.Model.Order,
  Query4D.Model.Query,
  Query4D.View.Base,
  Query4D.View.Interfaces;

type
  TMySQL8View = class(TBaseDialectView)
  protected
    function RenderPaginationClause(const AModel: TQueryModel): string; override;
    function WrapNullsFirst(const AColumn: string; const ADir: TOrderDirection): string; override;
    function WrapNullsLast(const AColumn: string; const ADir: TOrderDirection): string; override;
  public
    function SupportsFeature(const AFeature: TDialectFeature): Boolean; override;
    function QuoteIdentifier(const AName: string): string; override;
    function ParameterPlaceholder(const AIndex: Integer): string; override;

    class function New: IDialectView;
  end;

implementation

uses
  System.SysUtils;

{ TMySQL8View }

class function TMySQL8View.New: IDialectView;
begin
  Result := TMySQL8View.Create;
end;

function TMySQL8View.QuoteIdentifier(const AName: string): string;
begin
  Result := '`' + AName + '`';
end;

function TMySQL8View.ParameterPlaceholder(const AIndex: Integer): string;
begin
  Result := '?';
end;

function TMySQL8View.SupportsFeature(const AFeature: TDialectFeature): Boolean;
begin
  case AFeature of
    dfCTE, dfRecursiveCTE, dfLimitOffset,
    dfBulkInsert, dfWindowFunctions: Result := True;
  else
    Result := False;
  end;
end;

function TMySQL8View.RenderPaginationClause(const AModel: TQueryModel): string;
begin
  if AModel.Pagination.IsEmpty then
    Exit('');

  if AModel.Pagination.IsFirstOnly then
    Exit('LIMIT 1');

  Result := '';
  if AModel.Pagination.HasLimit then
    Result := 'LIMIT ' + IntToStr(AModel.Pagination.LimitValue);
  if AModel.Pagination.HasOffset then
  begin
    if Result <> '' then Result := Result + ' ';
    Result := Result + 'OFFSET ' + IntToStr(AModel.Pagination.OffsetValue);
  end;
end;

// MySQL nao suporta NULLS FIRST/LAST nativamente — emula com (col IS NULL)
// (col IS NULL) = 1 para NULL, 0 para nao-NULL
// DESC coloca 1 antes de 0 => NULLs first
// ASC  coloca 0 antes de 1 => NULLs last

function TMySQL8View.WrapNullsFirst(const AColumn: string; const ADir: TOrderDirection): string;
var
  DirStr: string;
begin
  if ADir = odAsc then DirStr := 'ASC' else DirStr := 'DESC';
  Result := Format('(%s IS NULL) DESC, %s %s', [AColumn, AColumn, DirStr]);
end;

function TMySQL8View.WrapNullsLast(const AColumn: string; const ADir: TOrderDirection): string;
var
  DirStr: string;
begin
  if ADir = odAsc then DirStr := 'ASC' else DirStr := 'DESC';
  Result := Format('(%s IS NULL) ASC, %s %s', [AColumn, AColumn, DirStr]);
end;

end.
