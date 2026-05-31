unit Query4D.Tests.Controller;

interface

uses
  DUnitX.TestFramework,
  Query4D.Shared.Result,
  Query4D.Shared.Exceptions,
  Query4D.Model.Types,
  Query4D.Model.Query,
  Query4D.View.Interfaces,
  Query4D.Controller.Interfaces,
  Query4D.Controller;

type
  // Mock minimo de IDialectView para testes de controller sem banco
  TMockDialectView = class(TInterfacedObject, IDialectView)
  public
    function Render(const AModel: TQueryModel): TResult<TQueryResult>;
    function SupportsFeature(const AFeature: TDialectFeature): Boolean;
    function QuoteIdentifier(const AName: string): string;
    function ParameterPlaceholder(const AIndex: Integer): string;
  end;

  [TestFixture]
  TQuery4DControllerTests = class
  private
    FDialect: IDialectView;
  public
    [Setup]
    procedure Setup;

    [Test]
    procedure Dado_SemDialeto_Quando_NewChamado_Entao_LancaEDialectNotInjected;
    [Test]
    procedure Dado_Dialeto_Quando_FromChamado_Entao_RetornaInterface;
    [Test]
    procedure Dado_MultiplasChamadas_Quando_EncadeadasFluentemente_Entao_RetornaController;
    [Test]
    procedure Dado_UpdateSemWhere_Quando_BuildChamado_Entao_LancaEUnsafeOperation;
    [Test]
    procedure Dado_DeleteSemWhere_Quando_BuildChamado_Entao_LancaEUnsafeOperation;
    [Test]
    procedure Dado_UpdateComWhere_Quando_BuildChamado_Entao_NaoLancaExcecao;
    [Test]
    procedure Dado_LimitNegativo_Quando_LimitChamado_Entao_LancaEInvalidQuery;
  end;

  [TestFixture]
  TWhereControllerTests = class
  private
    FDialect: IDialectView;
  public
    [Setup]
    procedure Setup;

    [Test]
    procedure Dado_OrBeginSemOrEnd_Quando_EndWhereChamado_Entao_LancaEInvalidQuery;
    [Test]
    procedure Dado_OrEndSemOrBegin_Quando_Chamado_Entao_LancaEInvalidQuery;
    [Test]
    procedure Dado_GrupoOrValido_Quando_EndWhereChamado_Entao_NaoLancaExcecao;
  end;

implementation

{ TMockDialectView }

function TMockDialectView.Render(const AModel: TQueryModel): TResult<TQueryResult>;
begin
  // Mock: sempre retorna SQL vazio com sucesso
  Result := TResult<TQueryResult>.Ok(TQueryResult.New('SELECT *', []));
end;

function TMockDialectView.SupportsFeature(const AFeature: TDialectFeature): Boolean;
begin
  Result := False;
end;

function TMockDialectView.QuoteIdentifier(const AName: string): string;
begin
  Result := '"' + AName + '"';
end;

function TMockDialectView.ParameterPlaceholder(const AIndex: Integer): string;
begin
  Result := '?';
end;

{ TQuery4DControllerTests }

procedure TQuery4DControllerTests.Setup;
begin
  FDialect := TMockDialectView.Create;
end;

procedure TQuery4DControllerTests.Dado_SemDialeto_Quando_NewChamado_Entao_LancaEDialectNotInjected;
begin
  Assert.WillRaise(
    procedure begin TQuery4DController.New(nil); end,
    EDialectNotInjected);
end;

procedure TQuery4DControllerTests.Dado_Dialeto_Quando_FromChamado_Entao_RetornaInterface;
var
  Q: IQuery4DController;
begin
  Q := TQuery4DController.New(FDialect);
  Assert.IsNotNull(Q.From('tabela'));
end;

procedure TQuery4DControllerTests.Dado_MultiplasChamadas_Quando_EncadeadasFluentemente_Entao_RetornaController;
var
  Q: IQuery4DController;
begin
  Q := TQuery4DController.New(FDialect)
    .From('pedidos', 'p')
    .Select(['p.id', 'p.nome'])
    .WhereEq('p.ativo', '1')
    .OrderBy('p.nome')
    .Limit(10);
  Assert.IsNotNull(Q);
end;

procedure TQuery4DControllerTests.Dado_UpdateSemWhere_Quando_BuildChamado_Entao_LancaEUnsafeOperation;
begin
  Assert.WillRaise(
    procedure
    begin
      TQuery4DController.New(FDialect)
        .Update('clientes')
        .SetValue('ativo', '0')
        .Build;
    end,
    EUnsafeOperation);
end;

procedure TQuery4DControllerTests.Dado_DeleteSemWhere_Quando_BuildChamado_Entao_LancaEUnsafeOperation;
begin
  Assert.WillRaise(
    procedure
    begin
      TQuery4DController.New(FDialect)
        .DeleteFrom('clientes')
        .Build;
    end,
    EUnsafeOperation);
end;

procedure TQuery4DControllerTests.Dado_UpdateComWhere_Quando_BuildChamado_Entao_NaoLancaExcecao;
begin
  Assert.WillNotRaise(
    procedure
    begin
      TQuery4DController.New(FDialect)
        .Update('clientes')
        .SetValue('ativo', '0')
        .WhereEq('id', '5')
        .Build;
    end);
end;

procedure TQuery4DControllerTests.Dado_LimitNegativo_Quando_LimitChamado_Entao_LancaEInvalidQuery;
begin
  Assert.WillRaise(
    procedure
    begin
      TQuery4DController.New(FDialect)
        .From('tabela')
        .Limit(-1);
    end,
    EInvalidQuery);
end;

{ TWhereControllerTests }

procedure TWhereControllerTests.Setup;
begin
  FDialect := TMockDialectView.Create;
end;

procedure TWhereControllerTests.Dado_OrBeginSemOrEnd_Quando_EndWhereChamado_Entao_LancaEInvalidQuery;
begin
  Assert.WillRaise(
    procedure
    begin
      TQuery4DController.New(FDialect)
        .From('tabela')
        .BeginWhere
          .Equal('col', 'val')
          .OrBegin
            .Equal('outro', 'x')
          // OrEnd nao chamado
        .EndWhere
        .Build;
    end,
    EInvalidQuery);
end;

procedure TWhereControllerTests.Dado_OrEndSemOrBegin_Quando_Chamado_Entao_LancaEInvalidQuery;
begin
  Assert.WillRaise(
    procedure
    begin
      TQuery4DController.New(FDialect)
        .From('tabela')
        .BeginWhere
          .Equal('col', 'val')
          .OrEnd  // sem OrBegin
        .EndWhere;
    end,
    EInvalidQuery);
end;

procedure TWhereControllerTests.Dado_GrupoOrValido_Quando_EndWhereChamado_Entao_NaoLancaExcecao;
begin
  Assert.WillNotRaise(
    procedure
    begin
      TQuery4DController.New(FDialect)
        .From('tabela')
        .BeginWhere
          .Equal('ativo', '1')
          .OrBegin
            .Equal('status', 'aprovado')
            .Equal('status', 'pendente')
          .OrEnd
        .EndWhere
        .Build;
    end);
end;

initialization
  TDUnitX.RegisterTestFixture(TQuery4DControllerTests);
  TDUnitX.RegisterTestFixture(TWhereControllerTests);

end.
