unit Query4D.View.PostgreSQL;

interface

uses
  Query4D.Model.Types,
  Query4D.Model.Order,
  Query4D.Model.Query,
  Query4D.View.Base,
  Query4D.View.Interfaces;

type
  TPostgreSQLView = class(TBaseDialectView)
  protected
    function RenderPaginationClause(const AModel: TQueryModel): string; override;
  public
    function SupportsFeature(const AFeature: TDialectFeature): Boolean; override;
    function QuoteIdentifier(const AName: string): string; override;
    function ParameterPlaceholder(const AIndex: Integer): string; override;

    class function New: IDialectView;
  end;

implementation

uses
  System.SysUtils;

{ TPostgreSQLView }

class function TPostgreSQLView.New: IDialectView;
begin
  Result := TPostgreSQLView.Create;
end;

function TPostgreSQLView.QuoteIdentifier(const AName: string): string;
begin
  Result := '"' + AName + '"';
end;

// PostgreSQL usa $1, $2, $3 ...
function TPostgreSQLView.ParameterPlaceholder(const AIndex: Integer): string;
begin
  Result := '$' + IntToStr(AIndex);
end;

function TPostgreSQLView.SupportsFeature(const AFeature: TDialectFeature): Boolean;
begin
  case AFeature of
    dfReturning, dfCTE, dfRecursiveCTE, dfNullsFirstLast,
    dfLimitOffset, dfBulkInsert, dfILike, dfWindowFunctions: Result := True;
  else
    Result := False;
  end;
end;

// PostgreSQL tem NULLS FIRST/LAST nativo — usa o padrao da base
// WrapNullsFirst e WrapNullsLast sao herdados de TBaseDialectView sem override

function TPostgreSQLView.RenderPaginationClause(const AModel: TQueryModel): string;
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

end.
