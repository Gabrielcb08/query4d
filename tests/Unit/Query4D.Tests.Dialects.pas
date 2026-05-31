unit Query4D.Tests.Dialects;

interface

uses
  DUnitX.TestFramework,
  Query4D.Shared.Result,
  Query4D.Shared.Exceptions,
  Query4D.View.Interfaces,
  Query4D.View.MySQL,
  Query4D.View.PostgreSQL,
  Query4D.View.Firebird,
  Query4D.View.SQLite,
  Query4D.Controller,
  Query4D.Controller.Interfaces,
  Query4D.Model.Types;

type
  [TestFixture]
  TMySQL8ViewTests = class
  private
    FDialect: IDialectView;
    function Build(const AQuery: IQuery4DController): string;
  public
    [Setup]
    procedure Setup;

    [Test]
    procedure Dado_SelectSimples_Quando_Compilado_Entao_GeraSelectCorreto;
    [Test]
    procedure Dado_SelectComWhere_Quando_Compilado_Entao_GeraParamsCorretos;
    [Test]
    procedure Dado_SelectComLimit_Quando_Compilado_Entao_GeraLimitNoFim;
    [Test]
    procedure Dado_QuoteIdentifier_Quando_Chamado_Entao_UsaBacktick;
    [Test]
    procedure Dado_ParameterPlaceholder_Quando_Chamado_Entao_RetornaInterrogacao;
    [Test]
    procedure Dado_NullsFirst_Quando_OrderByCompilado_Entao_UsaIsNullEmulado;
    [Test]
    procedure Dado_SupportsFeature_Quando_Returning_Entao_RetornaFalse;
  end;

  [TestFixture]
  TPostgreSQLViewTests = class
  private
    FDialect: IDialectView;
    function Build(const AQuery: IQuery4DController): string;
  public
    [Setup]
    procedure Setup;

    [Test]
    procedure Dado_SelectComWhere_Quando_Compilado_Entao_UsaDolarPlaceholder;
    [Test]
    procedure Dado_MultiploParams_Quando_Compilado_Entao_IncrementaIndice;
    [Test]
    procedure Dado_SupportsFeature_Quando_Returning_Entao_RetornaTrue;
    [Test]
    procedure Dado_NullsFirstNativo_Quando_OrderBy_Entao_UsaNullsFirst;
    [Test]
    procedure Dado_QuoteIdentifier_Quando_Chamado_Entao_UsaAspasDuplas;
  end;

  [TestFixture]
  TFirebirdViewTests = class
  private
    FDialect: IDialectView;
    function Build(const AQuery: IQuery4DController): string;
  public
    [Setup]
    procedure Setup;

    [Test]
    procedure Dado_SelectComFirst_Quando_Compilado_Entao_GeraFIRST1AposSelect;
    [Test]
    procedure Dado_SelectComLimitEOffset_Quando_Compilado_Entao_GeraFIRSTeSKIP;
    [Test]
    procedure Dado_NullsFirstEmulado_Quando_OrderBy_Entao_UsaIIF;
    [Test]
    procedure Dado_QuoteIdentifier_Quando_Chamado_Entao_UsaAspasDuplas;
  end;

  [TestFixture]
  TSQLiteViewTests = class
  private
    FDialect: IDialectView;
    function Build(const AQuery: IQuery4DController): string;
  public
    [Setup]
    procedure Setup;

    [Test]
    procedure Dado_SelectComLimit_Quando_Compilado_Entao_GeraLimitNoFim;
    [Test]
    procedure Dado_SupportsFeature_Quando_Returning_Entao_RetornaTrue;
    [Test]
    procedure Dado_NullsFirstNativo_Quando_OrderBy_Entao_UsaNullsFirst;
  end;

implementation

uses
  System.SysUtils;

{ Helpers }

function ContainsText(const AStr, ASubStr: string): Boolean;
begin
  Result := Pos(UpperCase(ASubStr), UpperCase(AStr)) > 0;
end;

{ TMySQL8ViewTests }

procedure TMySQL8ViewTests.Setup;
begin
  FDialect := TMySQL8View.New;
end;

function TMySQL8ViewTests.Build(const AQuery: IQuery4DController): string;
var
  R: TResult<TQueryResult>;
begin
  R := AQuery.Build;
  Assert.IsTrue(R.IsOk, 'Build falhou: ' + R.Error.Message);
  Result := R.Value.SQL;
end;

procedure TMySQL8ViewTests.Dado_SelectSimples_Quando_Compilado_Entao_GeraSelectCorreto;
var
  SQL: string;
begin
  SQL := Build(
    TQuery4DController.New(FDialect)
      .From('pedidos', 'p')
      .Select(['p.id', 'p.nome']));
  Assert.IsTrue(ContainsText(SQL, 'SELECT'), 'Deve conter SELECT');
  Assert.IsTrue(ContainsText(SQL, 'FROM pedidos'), 'Deve conter FROM pedidos');
  Assert.IsTrue(ContainsText(SQL, 'p.id'), 'Deve conter p.id');
end;

procedure TMySQL8ViewTests.Dado_SelectComWhere_Quando_Compilado_Entao_GeraParamsCorretos;
var
  R: TResult<TQueryResult>;
begin
  R := TQuery4DController.New(FDialect)
    .From('clientes')
    .WhereEq('status', 'ativo')
    .Build;
  Assert.IsTrue(R.IsOk);
  Assert.IsTrue(ContainsText(R.Value.SQL, 'WHERE'));
  Assert.IsTrue(ContainsText(R.Value.SQL, '?'));
  Assert.AreEqual(1, Length(R.Value.Params));
  Assert.AreEqual('ativo', R.Value.Params[0]);
end;

procedure TMySQL8ViewTests.Dado_SelectComLimit_Quando_Compilado_Entao_GeraLimitNoFim;
var
  SQL: string;
begin
  SQL := Build(
    TQuery4DController.New(FDialect)
      .From('tabela')
      .Limit(10)
      .Offset(20));
  Assert.IsTrue(ContainsText(SQL, 'LIMIT 10'));
  Assert.IsTrue(ContainsText(SQL, 'OFFSET 20'));
  // LIMIT deve aparecer DEPOIS de FROM (nao antes)
  Assert.IsTrue(Pos('LIMIT', UpperCase(SQL)) > Pos('FROM', UpperCase(SQL)));
end;

procedure TMySQL8ViewTests.Dado_QuoteIdentifier_Quando_Chamado_Entao_UsaBacktick;
begin
  Assert.AreEqual('`campo`', FDialect.QuoteIdentifier('campo'));
end;

procedure TMySQL8ViewTests.Dado_ParameterPlaceholder_Quando_Chamado_Entao_RetornaInterrogacao;
begin
  Assert.AreEqual('?', FDialect.ParameterPlaceholder(1));
  Assert.AreEqual('?', FDialect.ParameterPlaceholder(99));
end;

procedure TMySQL8ViewTests.Dado_NullsFirst_Quando_OrderByCompilado_Entao_UsaIsNullEmulado;
var
  SQL: string;
begin
  SQL := Build(
    TQuery4DController.New(FDialect)
      .From('tabela')
      .BeginOrder
        .Asc('nome', noFirst)
      .EndOrder);
  Assert.IsTrue(ContainsText(SQL, 'IS NULL'), 'MySQL deve emular NULLS FIRST com IS NULL');
end;

procedure TMySQL8ViewTests.Dado_SupportsFeature_Quando_Returning_Entao_RetornaFalse;
begin
  Assert.IsFalse(FDialect.SupportsFeature(dfReturning));
end;

{ TPostgreSQLViewTests }

procedure TPostgreSQLViewTests.Setup;
begin
  FDialect := TPostgreSQLView.New;
end;

function TPostgreSQLViewTests.Build(const AQuery: IQuery4DController): string;
var
  R: TResult<TQueryResult>;
begin
  R := AQuery.Build;
  Assert.IsTrue(R.IsOk, 'Build falhou: ' + R.Error.Message);
  Result := R.Value.SQL;
end;

procedure TPostgreSQLViewTests.Dado_SelectComWhere_Quando_Compilado_Entao_UsaDolarPlaceholder;
var
  SQL: string;
begin
  SQL := Build(
    TQuery4DController.New(FDialect)
      .From('clientes')
      .WhereEq('status', 'ativo'));
  Assert.IsTrue(ContainsText(SQL, '$1'), 'PostgreSQL deve usar $1 como placeholder');
end;

procedure TPostgreSQLViewTests.Dado_MultiploParams_Quando_Compilado_Entao_IncrementaIndice;
var
  SQL: string;
begin
  SQL := Build(
    TQuery4DController.New(FDialect)
      .From('clientes')
      .WhereEq('status', 'ativo')
      .WhereEq('pais', 'BR'));
  Assert.IsTrue(ContainsText(SQL, '$1'));
  Assert.IsTrue(ContainsText(SQL, '$2'));
end;

procedure TPostgreSQLViewTests.Dado_SupportsFeature_Quando_Returning_Entao_RetornaTrue;
begin
  Assert.IsTrue(FDialect.SupportsFeature(dfReturning));
end;

procedure TPostgreSQLViewTests.Dado_NullsFirstNativo_Quando_OrderBy_Entao_UsaNullsFirst;
var
  SQL: string;
begin
  SQL := Build(
    TQuery4DController.New(FDialect)
      .From('tabela')
      .BeginOrder
        .Asc('nome', noFirst)
      .EndOrder);
  Assert.IsTrue(ContainsText(SQL, 'NULLS FIRST'), 'PostgreSQL deve usar NULLS FIRST nativo');
end;

procedure TPostgreSQLViewTests.Dado_QuoteIdentifier_Quando_Chamado_Entao_UsaAspasDuplas;
begin
  Assert.AreEqual('"campo"', FDialect.QuoteIdentifier('campo'));
end;

{ TFirebirdViewTests }

procedure TFirebirdViewTests.Setup;
begin
  FDialect := TFirebirdView.New;
end;

function TFirebirdViewTests.Build(const AQuery: IQuery4DController): string;
var
  R: TResult<TQueryResult>;
begin
  R := AQuery.Build;
  Assert.IsTrue(R.IsOk, 'Build falhou: ' + R.Error.Message);
  Result := R.Value.SQL;
end;

procedure TFirebirdViewTests.Dado_SelectComFirst_Quando_Compilado_Entao_GeraFIRST1AposSelect;
var
  SQL: string;
  PosSelect, PosFirst, PosFrom: Integer;
begin
  SQL := Build(
    TQuery4DController.New(FDialect)
      .From('tabela')
      .First);
  PosSelect := Pos('SELECT', UpperCase(SQL));
  PosFirst  := Pos('FIRST', UpperCase(SQL));
  PosFrom   := Pos('FROM', UpperCase(SQL));
  Assert.IsTrue(PosFirst > PosSelect, 'FIRST deve aparecer apos SELECT');
  Assert.IsTrue(PosFirst < PosFrom, 'FIRST deve aparecer antes de FROM');
end;

procedure TFirebirdViewTests.Dado_SelectComLimitEOffset_Quando_Compilado_Entao_GeraFIRSTeSKIP;
var
  SQL: string;
begin
  SQL := Build(
    TQuery4DController.New(FDialect)
      .From('tabela')
      .Limit(10)
      .Offset(20));
  Assert.IsTrue(ContainsText(SQL, 'FIRST 10'));
  Assert.IsTrue(ContainsText(SQL, 'SKIP 20'));
  // Deve estar antes do FROM
  Assert.IsTrue(Pos('FIRST', UpperCase(SQL)) < Pos('FROM', UpperCase(SQL)));
end;

procedure TFirebirdViewTests.Dado_NullsFirstEmulado_Quando_OrderBy_Entao_UsaIIF;
var
  SQL: string;
begin
  SQL := Build(
    TQuery4DController.New(FDialect)
      .From('tabela')
      .BeginOrder
        .Asc('nome', noFirst)
      .EndOrder);
  Assert.IsTrue(ContainsText(SQL, 'IIF'), 'Firebird deve emular NULLS FIRST com IIF');
end;

procedure TFirebirdViewTests.Dado_QuoteIdentifier_Quando_Chamado_Entao_UsaAspasDuplas;
begin
  Assert.AreEqual('"campo"', FDialect.QuoteIdentifier('campo'));
end;

{ TSQLiteViewTests }

procedure TSQLiteViewTests.Setup;
begin
  FDialect := TSQLiteView.New;
end;

function TSQLiteViewTests.Build(const AQuery: IQuery4DController): string;
var
  R: TResult<TQueryResult>;
begin
  R := AQuery.Build;
  Assert.IsTrue(R.IsOk, 'Build falhou: ' + R.Error.Message);
  Result := R.Value.SQL;
end;

procedure TSQLiteViewTests.Dado_SelectComLimit_Quando_Compilado_Entao_GeraLimitNoFim;
var
  SQL: string;
begin
  SQL := Build(
    TQuery4DController.New(FDialect)
      .From('tabela')
      .Limit(5));
  Assert.IsTrue(ContainsText(SQL, 'LIMIT 5'));
  Assert.IsTrue(Pos('LIMIT', UpperCase(SQL)) > Pos('FROM', UpperCase(SQL)));
end;

procedure TSQLiteViewTests.Dado_SupportsFeature_Quando_Returning_Entao_RetornaTrue;
begin
  Assert.IsTrue(FDialect.SupportsFeature(dfReturning));
end;

procedure TSQLiteViewTests.Dado_NullsFirstNativo_Quando_OrderBy_Entao_UsaNullsFirst;
var
  SQL: string;
begin
  SQL := Build(
    TQuery4DController.New(FDialect)
      .From('tabela')
      .BeginOrder
        .Desc('criado_em', noLast)
      .EndOrder);
  Assert.IsTrue(ContainsText(SQL, 'NULLS LAST'));
end;

initialization
  TDUnitX.RegisterTestFixture(TMySQL8ViewTests);
  TDUnitX.RegisterTestFixture(TPostgreSQLViewTests);
  TDUnitX.RegisterTestFixture(TFirebirdViewTests);
  TDUnitX.RegisterTestFixture(TSQLiteViewTests);

end.
