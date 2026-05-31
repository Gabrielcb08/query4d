unit Query4D.Tests.Model;

interface

uses
  DUnitX.TestFramework,
  Query4D.Model.Field,
  Query4D.Model.Where,
  Query4D.Model.Join,
  Query4D.Model.Order,
  Query4D.Model.Group,
  Query4D.Model.CTE,
  Query4D.Model.Pagination,
  Query4D.Model.Types,
  Query4D.Shared.Exceptions;

type
  [TestFixture]
  TFieldModelTests = class
  public
    [Test]
    procedure Dado_ExpressionVazia_Quando_FieldModelCriado_Entao_LancaEInvalidQuery;
    [Test]
    procedure Dado_ExpressionValida_Quando_FieldModelCriado_Entao_PropriedadesCorretas;
    [Test]
    procedure Dado_ExpressionEAlias_Quando_FieldModelCriado_Entao_HasAliasRetornaTrue;
    [Test]
    procedure Dado_ListaVazia_Quando_IsEmptyChamado_Entao_RetornaTrue;
    [Test]
    procedure Dado_FieldAdicionado_Quando_CountChamado_Entao_Retorna1;
  end;

  [TestFixture]
  TWhereModelTests = class
  public
    [Test]
    procedure Dado_SemCondicoes_Quando_HasConditionsChamado_Entao_RetornaFalse;
    [Test]
    procedure Dado_PredicadoAdicionado_Quando_HasConditionsChamado_Entao_RetornaTrue;
    [Test]
    procedure Dado_ColunaVazia_Quando_CreateSimpleChamado_Entao_LancaEInvalidQuery;
    [Test]
    procedure Dado_GrupoOR_Quando_NodesAdicionados_Entao_DefaultLogicalEhOr;
    [Test]
    procedure Dado_ListaValores_Quando_CreateInChamado_Entao_OperadorEhWoIn;
    [Test]
    procedure Dado_ListaValoresNegado_Quando_CreateInChamado_Entao_OperadorEhWoNotIn;
  end;

  [TestFixture]
  TJoinModelTests = class
  public
    [Test]
    procedure Dado_TabelaVazia_Quando_JoinModelCriado_Entao_LancaEInvalidQuery;
    [Test]
    procedure Dado_OnClauseVazia_Quando_JoinInnerCriado_Entao_LancaEInvalidQuery;
    [Test]
    procedure Dado_CrossJoinSemOn_Quando_Criado_Entao_NaoLancaExcecao;
    [Test]
    procedure Dado_JoinComAlias_Quando_HasAliasChamado_Entao_RetornaTrue;
  end;

  [TestFixture]
  TPaginationModelTests = class
  public
    [Test]
    procedure Dado_LimitNegativo_Quando_SetLimitChamado_Entao_LancaEInvalidQuery;
    [Test]
    procedure Dado_Limit10_Quando_SetLimitChamado_Entao_HasLimitTrue;
    [Test]
    procedure Dado_FirstOnly_Quando_SetFirstOnlyChamado_Entao_LimitValue1;
    [Test]
    procedure Dado_SemPaginacao_Quando_IsEmptyChamado_Entao_RetornaTrue;
  end;

implementation

{ TFieldModelTests }

procedure TFieldModelTests.Dado_ExpressionVazia_Quando_FieldModelCriado_Entao_LancaEInvalidQuery;
begin
  Assert.WillRaise(
    procedure begin TFieldModel.Create(''); end,
    EInvalidQuery);
end;

procedure TFieldModelTests.Dado_ExpressionValida_Quando_FieldModelCriado_Entao_PropriedadesCorretas;
var
  F: TFieldModel;
begin
  F := TFieldModel.Create('p.nome');
  try
    Assert.AreEqual('p.nome', F.Expression);
    Assert.IsFalse(F.HasAlias);
  finally
    F.Free;
  end;
end;

procedure TFieldModelTests.Dado_ExpressionEAlias_Quando_FieldModelCriado_Entao_HasAliasRetornaTrue;
var
  F: TFieldModel;
begin
  F := TFieldModel.Create('p.nome', 'nome_cliente');
  try
    Assert.IsTrue(F.HasAlias);
    Assert.AreEqual('nome_cliente', F.Alias);
  finally
    F.Free;
  end;
end;

procedure TFieldModelTests.Dado_ListaVazia_Quando_IsEmptyChamado_Entao_RetornaTrue;
var
  L: TFieldListModel;
begin
  L := TFieldListModel.Create;
  try
    Assert.IsTrue(L.IsEmpty);
    Assert.AreEqual(0, L.Count);
  finally
    L.Free;
  end;
end;

procedure TFieldModelTests.Dado_FieldAdicionado_Quando_CountChamado_Entao_Retorna1;
var
  L: TFieldListModel;
begin
  L := TFieldListModel.Create;
  try
    L.Add('campo');
    Assert.AreEqual(1, L.Count);
    Assert.IsFalse(L.IsEmpty);
  finally
    L.Free;
  end;
end;

{ TWhereModelTests }

procedure TWhereModelTests.Dado_SemCondicoes_Quando_HasConditionsChamado_Entao_RetornaFalse;
var
  W: TWhereModel;
begin
  W := TWhereModel.Create;
  try
    Assert.IsFalse(W.HasConditions);
  finally
    W.Free;
  end;
end;

procedure TWhereModelTests.Dado_PredicadoAdicionado_Quando_HasConditionsChamado_Entao_RetornaTrue;
var
  W: TWhereModel;
begin
  W := TWhereModel.Create;
  try
    W.Root.AddPredicate(TWherePredicateModel.CreateSimple('col', woEqual, 'val'));
    Assert.IsTrue(W.HasConditions);
  finally
    W.Free;
  end;
end;

procedure TWhereModelTests.Dado_ColunaVazia_Quando_CreateSimpleChamado_Entao_LancaEInvalidQuery;
begin
  Assert.WillRaise(
    procedure begin TWherePredicateModel.CreateSimple('', woEqual, 'val'); end,
    EInvalidQuery);
end;

procedure TWhereModelTests.Dado_GrupoOR_Quando_NodesAdicionados_Entao_DefaultLogicalEhOr;
var
  G: TWhereGroupModel;
begin
  G := TWhereGroupModel.Create(loOr);
  try
    Assert.AreEqual(Ord(loOr), Ord(G.DefaultLogical));
  finally
    G.Free;
  end;
end;

procedure TWhereModelTests.Dado_ListaValores_Quando_CreateInChamado_Entao_OperadorEhWoIn;
var
  P: TWherePredicateModel;
begin
  P := TWherePredicateModel.CreateIn('col', ['a', 'b']);
  try
    Assert.AreEqual(Ord(woIsIn), Ord(P.Op));
    Assert.AreEqual(2, Length(P.Values));
  finally
    P.Free;
  end;
end;

procedure TWhereModelTests.Dado_ListaValoresNegado_Quando_CreateInChamado_Entao_OperadorEhWoNotIn;
var
  P: TWherePredicateModel;
begin
  P := TWherePredicateModel.CreateIn('col', ['a'], True);
  try
    Assert.AreEqual(Ord(woIsNotIn), Ord(P.Op));
  finally
    P.Free;
  end;
end;

{ TJoinModelTests }

procedure TJoinModelTests.Dado_TabelaVazia_Quando_JoinModelCriado_Entao_LancaEInvalidQuery;
begin
  Assert.WillRaise(
    procedure begin TJoinModel.Create(jtInner, '', '', 'a.id = b.id'); end,
    EInvalidQuery);
end;

procedure TJoinModelTests.Dado_OnClauseVazia_Quando_JoinInnerCriado_Entao_LancaEInvalidQuery;
begin
  Assert.WillRaise(
    procedure begin TJoinModel.Create(jtInner, 'tabela', 't', ''); end,
    EInvalidQuery);
end;

procedure TJoinModelTests.Dado_CrossJoinSemOn_Quando_Criado_Entao_NaoLancaExcecao;
begin
  Assert.WillNotRaise(
    procedure
    var J: TJoinModel;
    begin
      J := TJoinModel.Create(jtCross, 'tabela', '', '');
      J.Free;
    end);
end;

procedure TJoinModelTests.Dado_JoinComAlias_Quando_HasAliasChamado_Entao_RetornaTrue;
var
  J: TJoinModel;
begin
  J := TJoinModel.Create(jtLeft, 'pedidos', 'p', 'c.id = p.cliente_id');
  try
    Assert.IsTrue(J.HasAlias);
    Assert.AreEqual('p', J.Alias);
  finally
    J.Free;
  end;
end;

{ TPaginationModelTests }

procedure TPaginationModelTests.Dado_LimitNegativo_Quando_SetLimitChamado_Entao_LancaEInvalidQuery;
var
  P: TPaginationModel;
begin
  P := TPaginationModel.Create;
  try
    Assert.WillRaise(
      procedure begin P.SetLimit(-5); end,
      EInvalidQuery);
  finally
    P.Free;
  end;
end;

procedure TPaginationModelTests.Dado_Limit10_Quando_SetLimitChamado_Entao_HasLimitTrue;
var
  P: TPaginationModel;
begin
  P := TPaginationModel.Create;
  try
    P.SetLimit(10);
    Assert.IsTrue(P.HasLimit);
    Assert.AreEqual(10, P.LimitValue);
  finally
    P.Free;
  end;
end;

procedure TPaginationModelTests.Dado_FirstOnly_Quando_SetFirstOnlyChamado_Entao_LimitValue1;
var
  P: TPaginationModel;
begin
  P := TPaginationModel.Create;
  try
    P.SetFirstOnly;
    Assert.IsTrue(P.IsFirstOnly);
    Assert.AreEqual(1, P.LimitValue);
  finally
    P.Free;
  end;
end;

procedure TPaginationModelTests.Dado_SemPaginacao_Quando_IsEmptyChamado_Entao_RetornaTrue;
var
  P: TPaginationModel;
begin
  P := TPaginationModel.Create;
  try
    Assert.IsTrue(P.IsEmpty);
  finally
    P.Free;
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TFieldModelTests);
  TDUnitX.RegisterTestFixture(TWhereModelTests);
  TDUnitX.RegisterTestFixture(TJoinModelTests);
  TDUnitX.RegisterTestFixture(TPaginationModelTests);

end.
