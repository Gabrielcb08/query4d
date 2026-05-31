# Query4D — Referência da API

Documentação completa de todos os métodos públicos.

---

## TQuery4DController

Ponto de entrada da API fluente. Obtido via `TQuery4DController.New(dialect)`
ou via `TQuery4D.NewQuery` (componente no form designer).

### Criação

#### `.New(ADialect: IDialectView): IQuery4DController`

Cria um novo controller com o dialeto informado.

```delphi
var Q := TQuery4DController.New(TMySQL8View.New);
```

Lança `EDialectNotInjected` se `ADialect` for `nil`.

---

## FROM

### `.From(ATable: string): IQuery4DController`

Define a tabela principal da query sem alias.

```delphi
.From('pedidos')
// SQL: FROM pedidos
```

### `.From(ATable, AAlias: string): IQuery4DController`

Define a tabela com alias. O alias é delimitado conforme o dialeto.

```delphi
.From('pedidos', 'p')
// MySQL:      FROM pedidos AS `p`
// PostgreSQL: FROM pedidos AS "p"
```

---

## SELECT

### `.Select(AFields: array of string): IQuery4DController`

Define campos específicos. Pode conter expressões e alias inline.

```delphi
.Select(['p.id', 'p.nome', 'COUNT(*) AS total'])
```

### `.SelectAll: IQuery4DController`

Gera `SELECT *`. É o padrão quando nenhum campo é especificado.

### `.Distinct: IQuery4DController`

Adiciona `DISTINCT` após `SELECT`.

```delphi
.Select(['p.status']).Distinct
// SQL: SELECT DISTINCT p.status
```

### `.BeginFields: IFieldsController`

Sub-builder para campos com alias tipado.

```delphi
.BeginFields
  .Add('p.id')
  .Add('p.nome')
  .AddAs('p.valor_total', 'valor')
.EndFields
```

---

## WHERE (atalhos no controller principal)

### `.WhereEq(AColumn, AValue: string): IQuery4DController`

Atalho rápido para `Equal`. Útil em chains simples sem abrir `BeginWhere`.

```delphi
.WhereEq('status', 'ativo')
// SQL: WHERE status = ?  |  Param: 'ativo'
```

### `.WhereRaw(AExpression: string): IQuery4DController`

Injeta expressão crua no WHERE. Os valores dentro da expressão não são parametrizados.

```delphi
.WhereRaw('YEAR(criado_em) = 2024')
```

### `.BeginWhere: IWhereController`

Abre o sub-builder de WHERE com todos os operadores tipados.
Veja [OPERATORS.md](OPERATORS.md) para a referência completa.

```delphi
.BeginWhere
  .Equal('status', 'ativo')
  .IsNotNull('email')
.EndWhere
```

---

## JOIN

### `.Join(ATable, AAlias, AOn: string): IQuery4DController`

Atalho para INNER JOIN.

```delphi
.Join('clientes', 'c', 'c.id = p.cliente_id')
```

### `.LeftJoin(ATable, AAlias, AOn: string): IQuery4DController`

Atalho para LEFT JOIN.

### `.BeginJoins: IJoinsController`

Sub-builder para todos os tipos de JOIN.

```delphi
.BeginJoins
  .InnerJoin('clientes', 'c', 'c.id = p.cliente_id')
  .LeftJoin('enderecos', 'e', 'e.id = p.endereco_id')
  .RightJoin('categorias', 'cat', 'cat.id = p.categoria_id')
  .CrossJoin('configuracoes', 'cfg')
.EndJoins
```

---

## ORDER BY

### `.OrderBy(AColumn: string; ADir: TOrderDirection = odAsc): IQuery4DController`

Atalho para ordenação simples.

```delphi
.OrderBy('p.nome')                    // ASC implícito
.OrderBy('p.data_criacao', odDesc)   // DESC
```

### `.BeginOrder: IOrderController`

Sub-builder com suporte a `NULLS FIRST`/`NULLS LAST`.

```delphi
.BeginOrder
  .Asc('p.nome', noFirst)     // NULLS FIRST (nativo ou emulado)
  .Desc('p.data', noLast)     // NULLS LAST
.EndOrder
```

`TNullsOrder`: `noDefault`, `noFirst`, `noLast`.

---

## GROUP BY / HAVING

### `.GroupBy(AColumn: string): IQuery4DController`

Atalho para GROUP BY.

### `.Having(AExpression: string): IQuery4DController`

Adiciona cláusula HAVING como expressão crua.

### `.BeginGroup: IGroupController`

Sub-builder para GROUP BY + HAVING.

```delphi
.BeginGroup
  .By('p.cliente_id')
  .By('p.status')
  .Having('SUM(p.valor) > 1000')
.EndGroup
```

---

## PAGINAÇÃO

### `.Limit(ACount: Integer): IQuery4DController`

Define o número máximo de linhas. Lança `EInvalidQuery` se `ACount < 1`.

### `.Offset(ACount: Integer): IQuery4DController`

Define o deslocamento de linhas.

### `.First: IQuery4DController`

Atalho para `LIMIT 1`. Ignora `Offset`.

```delphi
.First     // MySQL: LIMIT 1  |  Firebird: SELECT FIRST 1 ...
```

---

## CTE (WITH)

### `.BeginWith: ICTEController`

Sub-builder para CTEs.

```delphi
.BeginWith
  .Add('resumo', 'SELECT cliente_id, SUM(valor) AS total FROM pedidos GROUP BY cliente_id')
  .AddRecursive('hierarquia',
    'SELECT id, pai_id, 0 AS nivel FROM categorias WHERE pai_id IS NULL',
    'SELECT c.id, c.pai_id, h.nivel + 1 FROM categorias c INNER JOIN hierarquia h ON h.id = c.pai_id')
.EndWith
```

---

## DML — INSERT

### `.InsertInto(ATable: string): IQuery4DController`

Inicia um INSERT.

### `.BeginRow: IQuery4DController`

Inicia uma linha de valores (suporta múltiplas linhas para bulk insert).

### `.Value(AColumn, AVal: string): IQuery4DController`

Adiciona um par coluna/valor à linha atual.

```delphi
TQuery4DController.New(TMySQL8View.New)
  .InsertInto('pedidos')
  .BeginRow
    .Value('cliente_id', '42')
    .Value('valor_total', '199.90')
    .Value('status', 'pendente')
  .Build
// INSERT INTO pedidos (cliente_id, valor_total, status) VALUES (?, ?, ?)
```

---

## DML — UPDATE

### `.Update(ATable: string): IQuery4DController`

Inicia um UPDATE.

### `.SetValue(AColumn, AValue: string): IQuery4DController`

Define um par coluna/valor como parâmetro.

### `.SetRaw(AColumn, ARawExpr: string): IQuery4DController`

Define um par coluna/expressão sem parametrizar (útil para `NOW()`, `DEFAULT`, etc.).

```delphi
.Update('pedidos')
  .SetValue('status', 'aprovado')
  .SetRaw('data_aprovacao', 'NOW()')
  .WhereEq('id', '42')
  .Build
// UPDATE pedidos SET status = ?, data_aprovacao = NOW() WHERE id = ?
```

> **Atenção:** `Build` lança `EUnsafeOperation` se não houver `WHERE`.

---

## DML — DELETE

### `.DeleteFrom(ATable: string): IQuery4DController`

Inicia um DELETE.

```delphi
.DeleteFrom('sessoes')
  .WhereEq('usuario_id', '10')
  .Build
// DELETE FROM sessoes WHERE usuario_id = ?
```

> **Atenção:** `Build` lança `EUnsafeOperation` se não houver `WHERE`.

---

## RETURNING

### `.Returning(AColumns: array of string): IQuery4DController`

Adiciona cláusula RETURNING. Ignorada silenciosamente em dialetos que não suportam
(`dfReturning = False`). Compatível com PostgreSQL e SQLite 3.35+.

```delphi
.InsertInto('pedidos')
  .BeginRow.Value('status', 'pendente')
  .Returning(['id', 'criado_em'])
  .Build
// PostgreSQL: INSERT INTO pedidos (status) VALUES ($1) RETURNING id, criado_em
// MySQL: INSERT INTO pedidos (status) VALUES (?)   ← RETURNING omitido
```

---

## BUILD

### `.Build: TResult<TQueryResult>`

Renderiza o SQL. Valida pré-condições antes de delegar ao dialeto.

Retorna `TResult<TQueryResult>` — nunca lança exceções de renderização
(erros de render viram `Result.Fail(...)`).

**Exceções que podem ser lançadas antes de renderizar:**
- `EUnsafeOperation` — UPDATE/DELETE sem WHERE
- `EDialectNotInjected` — dialeto nil (impossível via `New`, possível se dialeto foi substituído)

```delphi
var R := Q.Build;
if R.IsOk then
  ExecuteQuery(R.Value.SQL, R.Value.Params)
else
  ShowMessage(R.Error.Message);

// Ou via callbacks:
R.OnSuccess(procedure(V: TQueryResult)
  begin
    ExecuteQuery(V.SQL, V.Params);
  end)
 .OnFailure(procedure(E: TResultError)
  begin
    LogError(E.Message, E.Code);
  end);
```

---

## TQueryResult

Resultado do `Build` quando bem-sucedido.

| Propriedade | Tipo | Descrição |
|-------------|------|-----------|
| `SQL` | `string` | SQL com placeholders (`?` ou `$N`) |
| `Params` | `TArray<string>` | Valores na mesma ordem dos placeholders |

---

## Dialetos disponíveis

| Classe | Unit | Dialeto |
|--------|------|---------|
| `TMySQL8View.New` | `Query4D.View.MySQL` | MySQL 8.x |
| `TPostgreSQLView.New` | `Query4D.View.PostgreSQL` | PostgreSQL (qualquer versão moderna) |
| `TFirebirdView.New` | `Query4D.View.Firebird` | Firebird 2.1+ |
| `TSQLiteView.New` | `Query4D.View.SQLite` | SQLite 3.8.3+ |
