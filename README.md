# Query4D

> Biblioteca Delphi para construção de queries SQL de forma **fluente, tipada e segura** —
> sem concatenação de strings, sem SQL injection.

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Delphi 10.3+](https://img.shields.io/badge/Delphi-10.3%2B-red.svg)](https://www.embarcadero.com)
[![Dialects](https://img.shields.io/badge/dialects-MySQL%20%7C%20PostgreSQL%20%7C%20Firebird%20%7C%20SQLite-green.svg)](docs/DIALECTS.md)
[![Architecture](https://img.shields.io/badge/architecture-MVC%20%2F%20Clean-orange.svg)](docs/ARCHITECTURE.md)

[English](README.md) · [Português (BR)](README.pt-BR.md)

---

## Índice

- [O que é](#o-que-é)
- [Por que usar](#por-que-usar)
- [Instalação](#instalação)
- [Início rápido](#início-rápido)
- [Recursos](#recursos)
- [Guia de uso completo](#guia-de-uso-completo)
  - [SELECT / FROM](#select--from)
  - [WHERE e operadores](#where-e-operadores)
  - [Agrupamento lógico (AND/OR)](#agrupamento-lógico-andor)
  - [JOINs](#joins)
  - [ORDER BY / GROUP BY / HAVING](#order-by--group-by--having)
  - [Paginação](#paginação)
  - [CTE (WITH) — simples e recursivo](#cte-with--simples-e-recursivo)
  - [INSERT](#insert)
  - [UPDATE](#update)
  - [DELETE](#delete)
  - [RETURNING](#returning)
  - [Build e tratamento de resultado](#build-e-tratamento-de-resultado)
- [Dialetos suportados](#dialetos-suportados)
- [Segurança](#segurança)
- [Arquitetura](#arquitetura)
- [Estrutura do repositório](#estrutura-do-repositório)
- [Exemplos e demo](#exemplos-e-demo)
- [Documentação](#documentação)
- [Roadmap](#roadmap)
- [Como contribuir](#como-contribuir)
- [Licença](#licença)

---

## O que é

Query4D é um **query builder** — uma API fluente que constrói SQL dinamicamente
via encadeamento de métodos. Inspirado no [Knex.js](https://knexjs.org/), traz a
mesma ergonomia para o ecossistema Delphi.

**Não é um ORM:** não mapeia objetos para tabelas, não gerencia conexões e não
executa queries. Ele entrega apenas o `SQL` e os `Params` prontos para você passar
ao seu data access preferido (FireDAC, UniDAC, dbExpress, etc.).

Use sempre que precisar montar queries SQL **condicionalmente**, de forma legível
e segura, sem cair na armadilha de concatenar strings.

---

## Por que usar

| Problema com SQL em string | Solução do Query4D |
|----------------------------|--------------------|
| SQL injection por concatenação | Todo valor vira **bind param** (`?` / `$N`) |
| `UPDATE`/`DELETE` sem WHERE apagando tudo | `EUnsafeOperation` lançada antes de renderizar |
| SQL diferente por banco espalhado no código | Mesma query → 4 dialetos, troca em 1 linha |
| Queries condicionais com `if`/concat ilegíveis | API fluente encadeável e autoexplicativa |
| Sem checagem de pré-condições | `TGuard` valida toda entrada pública |

- **Zero dependências externas** — sem VCL/FMX/FireDAC no núcleo da biblioteca.
- **Componente não-visual** `TQuery4D` para arrastar no Form Designer.
- **Tratamento de erro funcional** com `TResult<T>` — sem exceções na renderização.

---

## Instalação

### Via Boss (recomendado)

```bash
boss install https://github.com/gabrielcb08/query4d@v1.0.0
```

### Manual (IDE)

1. Baixe ou clone este repositório.
2. Abra `packages/Delphi12/Query4D.dpk` na IDE do Delphi.
3. Clique em **Compile** e depois em **Install**.
4. O componente `TQuery4D` aparece na paleta **ORData**.

### Adicionando ao seu projeto

Em **Project → Options → Delphi Compiler → Search Path**, adicione os caminhos de `src\`:

```
..\Query4D\src
..\Query4D\src\Shared
..\Query4D\src\Model
..\Query4D\src\View
..\Query4D\src\Controller
```

Então basta declarar nas units:

```delphi
uses
  Query4D.Controller,   // TQuery4DController
  Query4D.View.MySQL;   // TMySQL8View (ou PostgreSQL, Firebird, SQLite)
```

---

## Início rápido

```delphi
uses
  Query4D.Controller,
  Query4D.View.MySQL;

var
  R := TQuery4DController.New(TMySQL8View.New)
    .From('pedidos', 'p')
    .Select(['p.id', 'p.numero', 'p.valor_total'])
    .BeginWhere
      .Equal('p.status', 'aprovado')
      .GreaterThan('p.valor_total', '100')
    .EndWhere
    .OrderBy('p.data_criacao', odDesc)
    .Limit(20)
    .Build;

if R.IsOk then
  MinhaConexao.Execute(R.Value.SQL, R.Value.Params);
```

SQL gerado (MySQL):

```sql
SELECT p.id, p.numero, p.valor_total
FROM pedidos AS `p`
WHERE p.status = ?
  AND p.valor_total > ?
ORDER BY p.data_criacao DESC
LIMIT 20
```

### Via componente no Form Designer

Solte um `TQuery4D` no form, configure a propriedade `Dialect` no Object Inspector
e chame `NewQuery` no código — sem precisar importar units de dialeto:

```delphi
// QueryBuilder: TQuery4D (no form, Dialect = dPostgreSQL)
var R := QueryBuilder.NewQuery
  .From('clientes')
  .WhereEq('ativo', '1')
  .Limit(10)
  .Build;
```

---

## Recursos

- [x] **SELECT** com campos, alias inline, expressões, `DISTINCT` e `SelectAll`
- [x] **Sub-builder de campos** tipado (`BeginFields` / `AddAs`)
- [x] **WHERE** com todos os operadores: comparação, LIKE, nulidade, intervalo, lista, booleano e expressão crua
- [x] **Grupos lógicos**: `OrBegin`/`OrEnd`, `AndBegin`/`AndEnd` (aninháveis)
- [x] **JOINs**: INNER, LEFT, RIGHT, FULL OUTER, CROSS — com alias
- [x] **ORDER BY** com `NULLS FIRST` / `NULLS LAST` (nativo ou emulado por dialeto)
- [x] **GROUP BY + HAVING**
- [x] **Paginação**: `Limit`, `Offset`, `First`
- [x] **CTE** (`WITH ... AS`) simples e **recursivo**
- [x] **INSERT** simples e **bulk** (múltiplas linhas)
- [x] **UPDATE** e **DELETE** com guard obrigatório de WHERE
- [x] **RETURNING** (PostgreSQL e SQLite 3.35+)
- [x] **Parâmetros tipados** — nunca interpolação de string
- [x] **Componente não-visual** `TQuery4D` para o Form Designer
- [x] **`TResult<T>`** — tratamento de erros funcional, sem exceções na render
- [x] **4 dialetos**: MySQL 8, PostgreSQL, Firebird, SQLite
- [x] **Zero dependências externas** no núcleo

---

## Guia de uso completo

> Referência resumida. Para a referência completa de cada método veja [docs/API.md](docs/API.md);
> para todos os operadores WHERE, [docs/OPERATORS.md](docs/OPERATORS.md).

### SELECT / FROM

```delphi
.From('pedidos')             // FROM pedidos
.From('pedidos', 'p')        // FROM pedidos AS `p`  (delimitador conforme dialeto)

.Select(['p.id', 'p.nome', 'COUNT(*) AS total'])
.SelectAll                   // SELECT *  (padrão se nada for informado)
.Select(['p.status']).Distinct   // SELECT DISTINCT p.status

// Sub-builder de campos com alias tipado:
.BeginFields
  .Add('p.id')
  .AddAs('p.valor_total', 'valor')
.EndFields
```

### WHERE e operadores

Atalhos rápidos no controller principal:

```delphi
.WhereEq('status', 'ativo')              // WHERE status = ?   (param: 'ativo')
.WhereRaw('YEAR(criado_em) = 2024')      // expressão crua (NÃO parametrizada)
```

Sub-builder completo via `.BeginWhere` … `.EndWhere`:

| Categoria | Métodos |
|-----------|---------|
| **Comparação** | `Equal`, `NotEqual`, `GreaterThan`, `GreaterThanOrEqualTo`, `LessThan`, `LessThanOrEqualTo` |
| **Texto / LIKE** | `Contains`, `NotContains`, `StartsWith`, `EndsWith`, `ContainsCaseInsensitive` |
| **Nulidade** | `IsNull`, `IsNotNull` |
| **Intervalo** | `IsBetween`, `IsNotBetween` |
| **Lista** | `IsIn`, `IsNotIn` |
| **Booleano** | `IsTrue`, `IsFalse` |
| **Cru / sub-query** | `Raw`, `Exists` |

```delphi
.BeginWhere
  .Equal('p.status', 'ativo')
  .GreaterThanOrEqualTo('p.estoque', '1')
  .Contains('p.nome', 'Silva')           // LIKE ?  → param '%Silva%'
  .IsIn('p.canal', ['web', 'app', 'api'])  // IN (?, ?, ?)
  .IsBetween('p.criado_em', '2026-01-01', '2026-12-31')
  .IsNotNull('p.email')
.EndWhere
```

> Os wildcards `%` dos operadores LIKE são **adicionados automaticamente** —
> você passa só o valor. Valores dentro de `Raw`/`WhereRaw` **não** são
> parametrizados; use com cuidado.

### Agrupamento lógico (AND/OR)

Predicados encadeados são unidos por `AND` por padrão. Para `OR`, abra um grupo:

```delphi
.BeginWhere
  .Equal('p.ativo', '1')           // AND
  .OrBegin
    .Equal('p.canal', 'web')       // OR
    .Equal('p.canal', 'app')       // OR
  .OrEnd
.EndWhere
// WHERE p.ativo = ? AND (p.canal = ? OR p.canal = ?)
```

Grupos `AndBegin`/`AndEnd` podem ser aninhados dentro de um `OrBegin`/`OrEnd`:

```delphi
.OrBegin
  .AndBegin
    .Equal('p.tipo', 'fisico')
    .GreaterThan('p.peso', '0')
  .AndEnd
  .Equal('p.tipo', 'digital')
.OrEnd
// ((p.tipo = ? AND p.peso > ?) OR p.tipo = ?)
```

> Grupos desbalanceados (`OrEnd` sem `OrBegin`, `EndWhere` com grupo aberto…)
> lançam `EInvalidQuery`.

### JOINs

```delphi
// Atalhos:
.Join('clientes', 'c', 'c.id = p.cliente_id')       // INNER JOIN
.LeftJoin('enderecos', 'e', 'e.id = p.endereco_id')  // LEFT JOIN

// Sub-builder completo:
.BeginJoins
  .InnerJoin('clientes', 'c', 'c.id = p.cliente_id')
  .LeftJoin('enderecos', 'e', 'e.id = p.endereco_id')
  .RightJoin('categorias', 'cat', 'cat.id = p.categoria_id')
  .CrossJoin('configuracoes', 'cfg')
.EndJoins
```

### ORDER BY / GROUP BY / HAVING

```delphi
.OrderBy('p.nome')                  // ASC implícito
.OrderBy('p.data_criacao', odDesc)  // DESC

// Com NULLS FIRST/LAST (nativo ou emulado por dialeto):
.BeginOrder
  .Asc('p.nome', noFirst)
  .Desc('p.data', noLast)
.EndOrder

// GROUP BY + HAVING:
.BeginGroup
  .By('p.cliente_id')
  .By('p.status')
  .Having('SUM(p.valor) > 1000')
.EndGroup
```

`TNullsOrder`: `noDefault`, `noFirst`, `noLast`.

### Paginação

```delphi
.Limit(20)     // LIMIT 20  — lança EInvalidQuery se < 1
.Offset(40)    // OFFSET 40
.First         // LIMIT 1 (Firebird: SELECT FIRST 1 …)
```

### CTE (WITH) — simples e recursivo

```delphi
.BeginWith
  .Add('resumo',
    'SELECT cliente_id, SUM(valor) AS total FROM pedidos GROUP BY cliente_id')
  .AddRecursive('hierarquia',
    'SELECT id, pai_id, 0 AS nivel FROM categorias WHERE pai_id IS NULL',
    'SELECT c.id, c.pai_id, h.nivel + 1 FROM categorias c ' +
    'INNER JOIN hierarquia h ON h.id = c.pai_id')
.EndWith
```

### INSERT

```delphi
TQuery4DController.New(TMySQL8View.New)
  .InsertInto('pedidos')
  .BeginRow
    .Value('cliente_id', '42')
    .Value('valor_total', '199.90')
    .Value('status', 'pendente')
  .Build;
// INSERT INTO pedidos (cliente_id, valor_total, status) VALUES (?, ?, ?)
```

**Bulk insert** — múltiplos `BeginRow`:

```delphi
.InsertInto('itens')
  .BeginRow.Value('pedido_id', '1').Value('produto', 'A')
  .BeginRow.Value('pedido_id', '1').Value('produto', 'B')
  .Build;
// INSERT INTO itens (pedido_id, produto) VALUES (?, ?), (?, ?)
```

### UPDATE

```delphi
.Update('pedidos')
  .SetValue('status', 'aprovado')      // parametrizado
  .SetRaw('data_aprovacao', 'NOW()')   // expressão crua (não parametrizada)
  .WhereEq('id', '42')
  .Build;
// UPDATE pedidos SET status = ?, data_aprovacao = NOW() WHERE id = ?
```

> ⚠️ `Build` lança **`EUnsafeOperation`** se não houver `WHERE`.

### DELETE

```delphi
.DeleteFrom('sessoes')
  .WhereEq('usuario_id', '10')
  .Build;
// DELETE FROM sessoes WHERE usuario_id = ?
```

> ⚠️ `Build` lança **`EUnsafeOperation`** se não houver `WHERE`.

### RETURNING

Suportado em PostgreSQL e SQLite 3.35+. Silenciosamente ignorado nos dialetos
que não suportam (MySQL, Firebird).

```delphi
.InsertInto('pedidos')
  .BeginRow.Value('status', 'pendente')
  .Returning(['id', 'criado_em'])
  .Build;
// PostgreSQL: INSERT INTO pedidos (status) VALUES ($1) RETURNING id, criado_em
// MySQL:      INSERT INTO pedidos (status) VALUES (?)      ← RETURNING omitido
```

### Build e tratamento de resultado

`.Build` retorna `TResult<TQueryResult>` — **não lança** exceções de renderização
(erros de render viram `Result.Fail(...)`).

```delphi
var R := Q.Build;
if R.IsOk then
  ExecuteQuery(R.Value.SQL, R.Value.Params)
else
  ShowMessage(R.Error.Message);

// Ou via callbacks encadeados:
R.OnSuccess(procedure(V: TQueryResult)
   begin ExecuteQuery(V.SQL, V.Params); end)
 .OnFailure(procedure(E: TResultError)
   begin LogError(E.Message, E.Code); end);
```

`TQueryResult`:

| Propriedade | Tipo | Descrição |
|-------------|------|-----------|
| `SQL` | `string` | SQL com placeholders (`?` ou `$N`) |
| `Params` | `TArray<string>` | Valores na mesma ordem dos placeholders |

**Exceções lançadas *antes* de renderizar:**
`EUnsafeOperation` (UPDATE/DELETE sem WHERE), `EDialectNotInjected` (dialeto nil),
`EInvalidQuery` (grupo lógico desbalanceado, `Limit < 1`).

---

## Dialetos suportados

| Recurso | MySQL 8 | PostgreSQL | Firebird | SQLite |
|---------|:-------:|:----------:|:--------:|:------:|
| Paginação | `LIMIT/OFFSET` | `LIMIT/OFFSET` | `FIRST/SKIP` | `LIMIT/OFFSET` |
| Placeholder | `?` | `$1`, `$2`… | `?` | `?` |
| Quote identificador | `` `col` `` | `"col"` | `"col"` | `"col"` |
| RIGHT / FULL JOIN | ✅ | ✅ | ✅ | ❌ |
| CTE / CTE recursivo | ✅ | ✅ | ✅ 2.1+ | ✅ 3.8.3+ |
| INSERT bulk | ✅ | ✅ | ⚠️ | ✅ |
| RETURNING | ❌ | ✅ | ❌ | ✅ 3.35+ |
| NULLS FIRST/LAST | Emulado | Nativo | Emulado (IIF) | Nativo |

Classes de dialeto:

| Classe | Unit |
|--------|------|
| `TMySQL8View.New` | `Query4D.View.MySQL` |
| `TPostgreSQLView.New` | `Query4D.View.PostgreSQL` |
| `TFirebirdView.New` | `Query4D.View.Firebird` |
| `TSQLiteView.New` | `Query4D.View.SQLite` |

**A mesma query gera SQL diferente para cada banco**, sem mudar a lógica:

```delphi
TQuery4DController.New(TPostgreSQLView.New). ... .Build;   // direto
QueryBuilder.Dialect := dSQLite;                            // via componente
```

Detalhes, limitações e emulações por banco em [docs/DIALECTS.md](docs/DIALECTS.md).

---

## Segurança

- Todo valor passado a predicados WHERE/SET vira **parâmetro bind** (`?` ou `$N`) —
  nunca é interpolado como string no SQL.
- `UPDATE` e `DELETE` sem `WHERE` lançam **`EUnsafeOperation`** na camada Controller,
  antes de chegar ao dialeto (proteção garantida mesmo com mocks em testes).
- `TGuard` valida pré-condições em todos os pontos de entrada públicos.
- Hierarquia de exceções tipadas: `EQuery4D` → `EInvalidQuery`, `EUnsafeOperation`,
  `EDialectNotInjected`, `EInvalidAlias`.

---

## Arquitetura

Padrão **MVC** com regras de dependência estritas (Clean Architecture):

| Camada | Responsabilidade |
|--------|------------------|
| **Model** | Estado da query: campos, WHERE, JOINs, ORDER, GROUP, CTEs, paginação, DML |
| **View** | Renderiza o Model em SQL para um dialeto específico (`IDialectView`) |
| **Controller** | API fluente que o usuário chama; manipula o Model e delega ao View no `Build` |

**Extensibilidade (Open/Closed):** para adicionar um dialeto, implemente `IDialectView`
(ou herde de `TBaseDialectView` e sobrescreva só o que difere: `QuoteIdentifier`,
`ParameterPlaceholder`, `RenderPaginationClause`). Nenhuma linha existente muda.

Detalhes em [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md).

---

## Estrutura do repositório

```
Query4D/
├─ src/
│  ├─ Shared/        TResult<T>, TGuard, exceções, utilitários
│  ├─ Model/         TQueryModel e sub-models (estado da query)
│  ├─ View/          IDialectView + implementações dos 4 dialetos
│  └─ Controller/    TQuery4DController (fluent) + sub-controllers
├─ tests/
│  ├─ Unit/          testes sem banco (nomenclatura Dado_Quando_Entao)
│  └─ Fixtures/
├─ samples/          aplicação demo VCL (Query4DDemo)
├─ docs/             documentação completa
├─ packages/Delphi12/Query4D.dpk    package instalável (componente TQuery4D)
└─ Query4D.groupproj                group: lib + testes
```

---

## Exemplos e demo

- **Aplicação demo** (VCL): abra `samples/Query4DDemo.dpr` na IDE — explora
  interativamente cada recurso e mostra o SQL gerado por dialeto.
- **Exemplos comentados** em [docs/examples/](docs/examples/), do simples ao avançado:

  | # | Exemplo |
  |---|---------|
  | 01 | [SELECT básico](docs/examples/01_select_basico.md) |
  | 02 | [WHERE e operadores](docs/examples/02_where_operadores.md) |
  | 03 | [JOINs com alias](docs/examples/03_joins_com_alias.md) |
  | 04 | [INSERT / UPDATE / DELETE](docs/examples/04_insert_update_delete.md) |
  | 05 | [CTE simples](docs/examples/05_cte_simples.md) |
  | 06 | [CTE recursivo](docs/examples/06_cte_recursivo.md) |
  | 07 | [Subqueries](docs/examples/07_subqueries.md) |
  | 08 | [Dialetos comparados](docs/examples/08_dialetos_comparados.md) |

---

## Documentação

| Arquivo | Conteúdo |
|---------|----------|
| [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) | Decisões de design, padrão MVC, regras de dependência |
| [docs/API.md](docs/API.md) | Referência completa de todos os métodos |
| [docs/OPERATORS.md](docs/OPERATORS.md) | Todos os operadores WHERE documentados |
| [docs/DIALECTS.md](docs/DIALECTS.md) | Diferenças e limitações por banco de dados |
| [docs/CONTRIBUTING.md](docs/CONTRIBUTING.md) | Como contribuir e como adicionar um dialeto |
| [docs/BOSS.md](docs/BOSS.md) | Instalação via Boss, workflow de release |
| [docs/CHANGELOG.md](docs/CHANGELOG.md) | Histórico de versões |

---

## Roadmap

Planejado para versões futuras (veja [docs/CHANGELOG.md](docs/CHANGELOG.md)):

- [ ] Dialeto **Oracle** (`ROWNUM`, quotes `[col]`)
- [ ] Dialeto **SQL Server** (`TOP`, quotes `[col]`)
- [ ] `IsInSubquery` tipado recebendo `IQuery4DController` como parâmetro
- [ ] `ILIKE` nativo no dialeto PostgreSQL

---

## Como contribuir

Contribuições são bem-vindas! Veja [docs/CONTRIBUTING.md](docs/CONTRIBUTING.md)
para padrões de código, convenção de testes (`Dado_Quando_Entao`) e o passo a passo
de como adicionar um novo dialeto. Abra uma issue antes de PRs grandes.

---

## Licença

[MIT](LICENSE) — livre para uso comercial e open source. Copyright (c) 2026 OurSoft.
