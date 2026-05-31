# Exemplo 08 — Dialetos Comparados

## O que este exemplo demonstra

- A mesma query gerando SQL diferente para cada dialeto
- Diferenças de placeholder, quote, paginação e NULLS
- Como trocar de dialeto sem mudar a lógica de negócio

---

## A mesma query — 4 dialetos

```delphi
// Função utilitária para demonstração
function BuildQuery(const ADialect: IDialectView): string;
var
  R: TResult<TQueryResult>;
begin
  R := TQuery4DController.New(ADialect)
    .From('pedidos', 'p')
    .Select(['p.id', 'p.numero', 'p.valor_total'])
    .Join('clientes', 'c', 'c.id = p.cliente_id')
    .BeginWhere
      .Equal('p.status', 'aprovado')
      .GreaterThan('p.valor_total', '100')
    .EndWhere
    .BeginOrder
      .Desc('p.data_criacao', noFirst)  // NULLS FIRST no DESC
    .EndOrder
    .Limit(10)
    .Offset(20)
    .Build;

  if R.IsOk then Result := R.Value.SQL
  else Result := '-- ERRO: ' + R.Error.Message;
end;
```

### MySQL 8

```sql
SELECT p.id, p.numero, p.valor_total
FROM pedidos AS `p`
INNER JOIN clientes AS `c` ON c.id = p.cliente_id
WHERE p.status = ?
  AND p.valor_total > ?
ORDER BY (p.data_criacao IS NULL) DESC, p.data_criacao DESC
LIMIT 10 OFFSET 20
```

Params: `['aprovado', '100']` (sempre `?`)

### PostgreSQL

```sql
SELECT p.id, p.numero, p.valor_total
FROM pedidos AS "p"
INNER JOIN clientes AS "c" ON c.id = p.cliente_id
WHERE p.status = $1
  AND p.valor_total > $2
ORDER BY p.data_criacao DESC NULLS FIRST
LIMIT 10 OFFSET 20
```

Params: `['aprovado', '100']` (indexados `$1`, `$2`…)

### Firebird

```sql
SELECT FIRST 10 SKIP 20 p.id, p.numero, p.valor_total
FROM pedidos AS "p"
INNER JOIN clientes AS "c" ON c.id = p.cliente_id
WHERE p.status = ?
  AND p.valor_total > ?
ORDER BY IIF(p.data_criacao IS NULL, 0, 1) ASC, p.data_criacao DESC
```

Params: `['aprovado', '100']`

### SQLite

```sql
SELECT p.id, p.numero, p.valor_total
FROM pedidos AS "p"
INNER JOIN clientes AS "c" ON c.id = p.cliente_id
WHERE p.status = ?
  AND p.valor_total > ?
ORDER BY p.data_criacao DESC NULLS FIRST
LIMIT 10 OFFSET 20
```

Params: `['aprovado', '100']`

---

## Diferenças resumidas

| Aspecto | MySQL | PostgreSQL | Firebird | SQLite |
|---------|-------|------------|----------|--------|
| Quote | `` `col` `` | `"col"` | `"col"` | `"col"` |
| Placeholder | `?` | `$1`, `$2`… | `?` | `?` |
| Paginação | LIMIT/OFFSET | LIMIT/OFFSET | FIRST n SKIP m | LIMIT/OFFSET |
| Posição paginação | Fim | Fim | Logo após SELECT | Fim |
| NULLS FIRST nativo | ❌ | ✅ | ❌ | ✅ |
| NULLS FIRST emulado | `(col IS NULL) DESC, col` | — | `IIF(col IS NULL, 0, 1) ASC, col` | — |

---

## Trocando dialeto via componente

```delphi
// No form: QueryBuilder: TQuery4D (Dialect = dMySQL8 no designer)

// Em runtime, antes de executar:
case ComboDialecto.ItemIndex of
  0: QueryBuilder.Dialect := dMySQL8;
  1: QueryBuilder.Dialect := dPostgreSQL;
  2: QueryBuilder.Dialect := dFirebird;
  3: QueryBuilder.Dialect := dSQLite;
end;

var R := QueryBuilder.NewQuery
  .From('pedidos', 'p')
  .WhereEq('status', 'aprovado')
  .Limit(10)
  .Build;
```

A mesma chamada de negócio, SQL diferente para cada dialeto — sem `if`s.

---

## Pontos de atenção

- PostgreSQL é o único onde params são numerados. Ao passar o array `Params`
  para o FireDAC ou UniDAC, a ordem no array corresponde à ordem dos `$N`.
- Firebird coloca `FIRST`/`SKIP` **antes** dos campos — não `FIRST` e depois `SELECT`.
  Drivers que esperam `LIMIT` no fim precisam do dialeto correto.
- NULLS FIRST emulado no MySQL pode ter comportamento diferente do nativo em edge cases
  com índices compostos — teste com seus dados reais se performance for crítica.

## Ver também

- [DIALECTS.md](../DIALECTS.md) — tabela completa de paridade
- [CONTRIBUTING.md — Adicionar dialeto](../CONTRIBUTING.md#como-adicionar-um-novo-dialeto)
