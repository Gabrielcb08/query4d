unit Query4D.View.Interfaces;

interface

uses
  Query4D.Shared.Result,
  Query4D.Model.Query,
  Query4D.Model.Types;

type
  TQueryResult = record
    SQL: string;
    Params: TArray<string>;
    class function New(const ASQL: string; const AParams: TArray<string>): TQueryResult; static;
  end;

  IDialectView = interface
    ['{A1B2C3D4-E5F6-7890-ABCD-EF1234567890}']
    function Render(const AModel: TQueryModel): TResult<TQueryResult>;
    function SupportsFeature(const AFeature: TDialectFeature): Boolean;
    function QuoteIdentifier(const AName: string): string;
    function ParameterPlaceholder(const AIndex: Integer): string;
  end;

implementation

{ TQueryResult }

class function TQueryResult.New(
  const ASQL: string; const AParams: TArray<string>): TQueryResult;
begin
  Result.SQL    := ASQL;
  Result.Params := AParams;
end;

end.
