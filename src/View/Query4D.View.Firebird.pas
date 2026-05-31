unit Query4D.View.Firebird;

interface

uses
  Query4D.Model.Types,
  Query4D.Model.Order,
  Query4D.Model.Query,
  Query4D.View.Base,
  Query4D.View.Interfaces;

type
  TFirebirdView = class(TBaseDialectView)
  protected
    function RenderPaginationClause(const AModel: TQueryModel): string; override;
    function RenderSelectKeyword(const AModel: TQueryModel): string; override;
    function RenderOrderByClause(const AModel: TQueryModel): string; override;
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
  System.SysUtils,
  Query4D.Model.Pagination;

{ TFirebirdView }

class function TFirebirdView.New: IDialectView;
begin
  Result := TFirebirdView.Create;
end;

function TFirebirdView.QuoteIdentifier(const AName: string): string;
begin
  Result := '"' + AName + '"';
end;

function TFirebirdView.ParameterPlaceholder(const AIndex: Integer): string;
begin
  Result := '?';
end;

function TFirebirdView.SupportsFeature(const AFeature: TDialectFeature): Boolean;
begin
  case AFeature of
    dfCTE, dfRecursiveCTE, dfFirstSkip, dfBulkInsert: Result := True;
  else
    Result := False;
  end;
end;

// Firebird FIRST/SKIP fica no SELECT keyword — RenderSelectKeyword injeta isso.
function TFirebirdView.RenderPaginationClause(const AModel: TQueryModel): string;
begin
  Result := ''; // paginacao ja embutida no SELECT keyword
end;

// Injeta FIRST n SKIP n no keyword SELECT, antes dos campos
function TFirebirdView.RenderSelectKeyword(const AModel: TQueryModel): string;
var
  Kw: string;
begin
  Kw := 'SELECT';
  if AModel.Distinct then Kw := Kw + ' DISTINCT';
  if AModel.Pagination.IsFirstOnly then
    Kw := Kw + ' FIRST 1'
  else
  begin
    if AModel.Pagination.HasLimit then
      Kw := Kw + ' FIRST ' + IntToStr(AModel.Pagination.LimitValue);
    if AModel.Pagination.HasOffset then
      Kw := Kw + ' SKIP ' + IntToStr(AModel.Pagination.OffsetValue);
  end;
  Result := Kw;
end;

// Override do ORDER BY para nao ter NULLS FIRST/LAST nativo — usa IIF
function TFirebirdView.RenderOrderByClause(const AModel: TQueryModel): string;
begin
  // Firebird 2.0+ suporta NULLS FIRST/LAST nativamente, mas a spec pede emulacao IIF
  // Reutilizamos o base que ja chama WrapNullsFirst/WrapNullsLast com nosso override
  Result := inherited RenderOrderByClause(AModel);
end;

// Emulacao via IIF: IIF(col IS NULL, 0, 1) ASC = NULLS FIRST (NULL vira 0, primeiro no ASC)
function TFirebirdView.WrapNullsFirst(const AColumn: string; const ADir: TOrderDirection): string;
var
  DirStr: string;
begin
  if ADir = odAsc then DirStr := 'ASC' else DirStr := 'DESC';
  Result := Format('IIF(%s IS NULL, 0, 1) ASC, %s %s', [AColumn, AColumn, DirStr]);
end;

// IIF(col IS NULL, 1, 0) ASC = NULLS LAST (NULL vira 1, vai por ultimo no ASC)
function TFirebirdView.WrapNullsLast(const AColumn: string; const ADir: TOrderDirection): string;
var
  DirStr: string;
begin
  if ADir = odAsc then DirStr := 'ASC' else DirStr := 'DESC';
  Result := Format('IIF(%s IS NULL, 1, 0) ASC, %s %s', [AColumn, AColumn, DirStr]);
end;

end.
