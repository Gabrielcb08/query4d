unit Query4D.View.SQLite;

interface

uses
  Query4D.Model.Types,
  Query4D.Model.Query,
  Query4D.View.Base,
  Query4D.View.Interfaces;

type
  TSQLiteView = class(TBaseDialectView)
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

{ TSQLiteView }

class function TSQLiteView.New: IDialectView;
begin
  Result := TSQLiteView.Create;
end;

function TSQLiteView.QuoteIdentifier(const AName: string): string;
begin
  Result := '"' + AName + '"';
end;

function TSQLiteView.ParameterPlaceholder(const AIndex: Integer): string;
begin
  Result := '?';
end;

function TSQLiteView.SupportsFeature(const AFeature: TDialectFeature): Boolean;
begin
  case AFeature of
    dfCTE, dfRecursiveCTE, dfNullsFirstLast, dfLimitOffset,
    dfReturning: Result := True;  // RETURNING desde SQLite 3.35
  else
    Result := False;
  end;
end;

function TSQLiteView.RenderPaginationClause(const AModel: TQueryModel): string;
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
