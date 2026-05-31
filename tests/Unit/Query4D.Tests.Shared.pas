unit Query4D.Tests.Shared;

interface

uses
  DUnitX.TestFramework,
  Query4D.Container,
  Query4D.View.Interfaces,
  Query4D.Controller.Interfaces,
  Query4D.Shared.Result,
  Query4D.Shared.Guard,
  Query4D.Shared.Exceptions;

type
  [TestFixture]
  TResultTests = class
  public
    [Test]
    procedure Dado_Valor_Quando_OkChamado_Entao_IsOkRetornaTrue;
    [Test]
    procedure Dado_Mensagem_Quando_FailChamado_Entao_IsFailRetornaTrue;
    [Test]
    procedure Dado_ResultOk_Quando_OnSuccessChamado_Entao_ActionExecutada;
    [Test]
    procedure Dado_ResultFail_Quando_OnFailureChamado_Entao_ActionExecutada;
    [Test]
    procedure Dado_ResultFail_Quando_OnSuccessChamado_Entao_ActionNaoExecutada;
  end;

  [TestFixture]
  TGuardTests = class
  public
    [Test]
    procedure Dado_ObjectNil_Quando_IsNotNilChamado_Entao_LancaEDialectNotInjected;
    [Test]
    procedure Dado_StringVazia_Quando_IsNotEmptyChamado_Entao_LancaEInvalidQuery;
    [Test]
    procedure Dado_ValorNegativo_Quando_IsPositiveChamado_Entao_LancaEInvalidQuery;
    [Test]
    procedure Dado_IdentificadorInvalido_Quando_IsValidIdentifierChamado_Entao_LancaEInvalidAlias;
    [Test]
    procedure Dado_IdentificadorValido_Quando_IsValidIdentifierChamado_Entao_NaoLancaExcecao;
  end;

  [TestFixture]
  TContainerTests = class
  public
    [Test]
    procedure Dado_RegistroContainer_Quando_ResolveDialeto_Entao_RetornaImplementacao;
    [Test]
    procedure Dado_NomeDialeto_Quando_NewQuery4DController_Entao_RetornaController;
  end;

implementation

{ TResultTests }

procedure TResultTests.Dado_Valor_Quando_OkChamado_Entao_IsOkRetornaTrue;
var
  R: TResult<Integer>;
begin
  R := TResult<Integer>.Ok(42);
  Assert.IsTrue(R.IsOk);
  Assert.AreEqual(42, R.Value);
  Assert.IsFalse(R.IsFail);
end;

procedure TResultTests.Dado_Mensagem_Quando_FailChamado_Entao_IsFailRetornaTrue;
var
  R: TResult<Integer>;
begin
  R := TResult<Integer>.Fail('erro teste', 'E001');
  Assert.IsTrue(R.IsFail);
  Assert.AreEqual('erro teste', R.Error.Message);
  Assert.AreEqual('E001', R.Error.Code);
end;

procedure TResultTests.Dado_ResultOk_Quando_OnSuccessChamado_Entao_ActionExecutada;
var
  R: TResult<string>;
  Executado: Boolean;
begin
  Executado := False;
  R := TResult<string>.Ok('ok');
  R.OnSuccess(procedure(V: string) begin Executado := True; end);
  Assert.IsTrue(Executado);
end;

procedure TResultTests.Dado_ResultFail_Quando_OnFailureChamado_Entao_ActionExecutada;
var
  R: TResult<string>;
  Executado: Boolean;
begin
  Executado := False;
  R := TResult<string>.Fail('falhou');
  R.OnFailure(procedure(E: TResultError) begin Executado := True; end);
  Assert.IsTrue(Executado);
end;

procedure TResultTests.Dado_ResultFail_Quando_OnSuccessChamado_Entao_ActionNaoExecutada;
var
  R: TResult<string>;
  Executado: Boolean;
begin
  Executado := False;
  R := TResult<string>.Fail('falhou');
  R.OnSuccess(procedure(V: string) begin Executado := True; end);
  Assert.IsFalse(Executado);
end;

{ TGuardTests }

procedure TGuardTests.Dado_ObjectNil_Quando_IsNotNilChamado_Entao_LancaEDialectNotInjected;
begin
  Assert.WillRaise(
    procedure begin TGuard.IsNotNil(nil, 'Teste'); end,
    EDialectNotInjected);
end;

procedure TGuardTests.Dado_StringVazia_Quando_IsNotEmptyChamado_Entao_LancaEInvalidQuery;
begin
  Assert.WillRaise(
    procedure begin TGuard.IsNotEmpty('', 'Teste'); end,
    EInvalidQuery);
end;

procedure TGuardTests.Dado_ValorNegativo_Quando_IsPositiveChamado_Entao_LancaEInvalidQuery;
begin
  Assert.WillRaise(
    procedure begin TGuard.IsPositive(-1, 'Teste'); end,
    EInvalidQuery);
end;

procedure TGuardTests.Dado_IdentificadorInvalido_Quando_IsValidIdentifierChamado_Entao_LancaEInvalidAlias;
begin
  Assert.WillRaise(
    procedure begin TGuard.IsValidIdentifier('123invalido', 'Teste'); end,
    EInvalidAlias);
  Assert.WillRaise(
    procedure begin TGuard.IsValidIdentifier('com espaco', 'Teste'); end,
    EInvalidAlias);
end;

procedure TGuardTests.Dado_IdentificadorValido_Quando_IsValidIdentifierChamado_Entao_NaoLancaExcecao;
begin
  Assert.WillNotRaise(
    procedure begin TGuard.IsValidIdentifier('campo_valido', 'Teste'); end);
  Assert.WillNotRaise(
    procedure begin TGuard.IsValidIdentifier('_tabela', 'Teste'); end);
end;

{ TContainerTests }

procedure TContainerTests.Dado_RegistroContainer_Quando_ResolveDialeto_Entao_RetornaImplementacao;
var
  Dialect: IDialectView;
begin
  RegisterQuery4D;
  Dialect := ResolveDialect('mysql');
  Assert.IsTrue(Assigned(Dialect));
end;

procedure TContainerTests.Dado_NomeDialeto_Quando_NewQuery4DController_Entao_RetornaController;
var
  Controller: IQuery4DController;
begin
  Controller := NewQuery4DController('postgresql');
  Assert.IsTrue(Assigned(Controller));
end;

initialization
  TDUnitX.RegisterTestFixture(TResultTests);
  TDUnitX.RegisterTestFixture(TGuardTests);
  TDUnitX.RegisterTestFixture(TContainerTests);

end.
