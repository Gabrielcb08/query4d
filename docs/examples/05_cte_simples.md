# Exemplo 05 — CTE Simples

## O que este exemplo demonstra

- CTE não-recursivo com `WITH ... AS (...)`
- Uso da CTE como tabela na query principal
- Múltiplas CTEs

## Quando usar

Use CTE quando precisar nomear um subresultado para reutilizá-lo na query principal.
Melhora a legibilidade de queries que teriam subqueries aninhadas.

---

## CTE básica

```delphi
var R := TQuery4DController.New(TMySQL8View.New)
  .BeginWith
    .Add('resumo_mensal',
         'SELECT cliente_id, ' +
         '       MONTH(data_criacao) AS mes, ' +
         '       SUM(valor_total) AS total ' +
         'FROM pedidos ' +
         'WHERE YEAR(data_criacao) = 2024 ' +
         'GROUP BY cliente_id, MONTH(data_criacao)')
  .EndWith
  .From('resumo_mensal', 'rm')
  .Select(['rm.cliente_id', 'rm.mes', 'rm.total'])
  .BeginWhere
    .GreaterThan('rm.total', '1000')
  .EndWhere
  .OrderBy('rm.total', odDesc)
  .Build;
```

SQL gerado (MySQL):
```sql
WITH
  `resumo_mensal` AS (
    SELECT cliente_id, MONTH(data_criacao) AS mes, SUM(valor_total) AS total
    FROM pedidos
    WHERE YEAR(data_criacao) = 2024
    GROUP BY cliente_id, MONTH(data_criacao)
  )
SELECT rm.cliente_id, rm.mes, rm.total
FROM resumo_mensal AS `rm`
WHERE rm.total > ?
ORDER BY rm.total DESC
```
Params: `['1000']`

---

## Múltiplas CTEs

```delphi
var R := TQuery4DController.New(TPostgreSQLView.New)
  .BeginWith
    .Add('clientes_ativos',
         'SELECT id, nome FROM clientes WHERE ativo = 1')
    .Add('pedidos_2024',
         'SELECT cliente_id, COUNT(*) AS qtd, SUM(valor) AS total ' +
         'FROM pedidos WHERE YEAR(data) = 2024 ' +
         'GROUP BY cliente_id')
  .EndWith
  .From('clientes_ativos', 'ca')
  .Select(['ca.nome', 'p.qtd', 'p.total'])
  .Join('pedidos_2024', 'p', 'p.cliente_id = ca.id')
  .OrderBy('p.total', odDesc)
  .Limit(10)
  .Build;
```

SQL gerado (PostgreSQL):
```sql
WITH
  "clientes_ativos" AS (
    SELECT id, nome FROM clientes WHERE ativo = 1
  ),
  "pedidos_2024" AS (
    SELECT cliente_id, COUNT(*) AS qtd, SUM(valor) AS total
    FROM pedidos WHERE YEAR(data) = 2024
    GROUP BY cliente_id
  )
SELECT ca.nome, p.qtd, p.total
FROM clientes_ativos AS "ca"
INNER JOIN pedidos_2024 AS "p" ON p.cliente_id = ca.id
ORDER BY p.total DESC
LIMIT 10
```

---

## Pontos de atenção

- O corpo da CTE é uma string — não é validada pelo Query4D.
- O nome da CTE é delimitado com o quote do dialeto (`"` ou `` ` ``).
- CTE disponível a partir de: MySQL 8.0, PostgreSQL qualquer versão moderna,
  Firebird 2.1+, SQLite 3.8.3+.
- Para CTE recursivo (`WITH RECURSIVE`), veja o [Exemplo 06](06_cte_recursivo.md).

## Ver também

- [Exemplo 06 — CTE Recursivo](06_cte_recursivo.md)
- [API.md — CTE](../API.md#cte-with)
- [DIALECTS.md](../DIALECTS.md)
