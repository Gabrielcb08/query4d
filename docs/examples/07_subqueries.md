# Exemplo 07 — Subqueries

## O que este exemplo demonstra

- Subquery no WHERE com `Exists` e `Raw`
- Subquery como "tabela" no FROM via `Raw`
- Subquery escalar no SELECT

## Quando usar

Use subqueries quando uma CTE seria excessiva para uma lógica de um único uso.
Para subqueries reutilizadas ou complexas, prefira CTE (mais legível).

> **Limitação atual:** o Query4D não tem um builder tipado de subqueries
> (`IsInSubquery` está reservado no enum mas não exposto). Para subqueries,
> use `Exists(string)` ou `Raw(string)` passando o SQL da subquery manualmente.

---

## EXISTS — verificar existência

```delphi
// Clientes que têm pelo menos um pedido aprovado
var R := TQuery4DController.New(TMySQL8View.New)
  .From('clientes', 'c')
  .Select(['c.id', 'c.nome'])
  .BeginWhere
    .Exists(
      'SELECT 1 FROM pedidos p ' +
      'WHERE p.cliente_id = c.id ' +
      '  AND p.status = ''aprovado'''
    )
  .EndWhere
  .Build;
```

SQL gerado:
```sql
SELECT c.id, c.nome
FROM clientes AS `c`
WHERE EXISTS (SELECT 1 FROM pedidos p WHERE p.cliente_id = c.id AND p.status = 'aprovado')
```

> **Atenção:** o valor `'aprovado'` está interpolado como literal na string da subquery.
> Para torná-lo parametrizado, use um JOIN com WHERE tipado em vez de subquery.

---

## IN com subquery via Raw

```delphi
// Produtos que aparecem em pelo menos um pedido do mês atual
var R := TQuery4DController.New(TPostgreSQLView.New)
  .From('produtos', 'pr')
  .SelectAll
  .BeginWhere
    .Raw('pr.id IN (SELECT DISTINCT produto_id FROM itens_pedido ip ' +
                  'INNER JOIN pedidos p ON p.id = ip.pedido_id ' +
                  'WHERE DATE_TRUNC(''month'', p.data) = DATE_TRUNC(''month'', NOW()))')
  .EndWhere
  .Build;
```

---

## Subquery no FROM (tabela derivada)

O Query4D não tem método específico para subquery no FROM.
Use a string da subquery diretamente no campo `From`:

```delphi
// Alternativa: use CTE (preferível)
// Mas se preferir subquery inline, construa via From + Raw nos campos

var InnerSQL :=
  'SELECT cliente_id, SUM(valor_total) AS total ' +
  'FROM pedidos WHERE status = ''aprovado'' ' +
  'GROUP BY cliente_id';

// Workaround: CTE é mais limpa e compatível
var R := TQuery4DController.New(TMySQL8View.New)
  .BeginWith
    .Add('totais', InnerSQL)
  .EndWith
  .From('totais', 't')
  .Select(['t.cliente_id', 't.total'])
  .BeginWhere
    .GreaterThan('t.total', '5000')
  .EndWhere
  .Build;
```

---

## Subquery escalar no SELECT

Passe a subquery como expressão dentro de `Select` ou `BeginFields.Add`:

```delphi
var R := TQuery4DController.New(TMySQL8View.New)
  .From('clientes', 'c')
  .BeginFields
    .Add('c.id')
    .Add('c.nome')
    .Add('(SELECT COUNT(*) FROM pedidos p WHERE p.cliente_id = c.id)')
    .AddAs(
      '(SELECT MAX(p.valor_total) FROM pedidos p WHERE p.cliente_id = c.id)',
      'maior_pedido')
  .EndFields
  .Build;
```

SQL gerado:
```sql
SELECT c.id, c.nome,
       (SELECT COUNT(*) FROM pedidos p WHERE p.cliente_id = c.id),
       (SELECT MAX(p.valor_total) FROM pedidos p WHERE p.cliente_id = c.id) AS "maior_pedido"
FROM clientes AS `c`
```

---

## Pontos de atenção

- Subqueries passadas como strings não são validadas — erros aparecem em runtime.
- Valores literais em subqueries não são parametrizados. Se vier de input do usuário,
  sanitize antes ou reestruture usando JOIN tipado.
- Para hierarquias, prefira CTE recursivo ([Exemplo 06](06_cte_recursivo.md)).
- Para `col IN (subquery)`, use CTE + JOIN para obter parametrização completa.

## Ver também

- [Exemplo 05 — CTE Simples](05_cte_simples.md)
- [Exemplo 03 — JOINs](03_joins_com_alias.md)
- [OPERATORS.md — Exists](../OPERATORS.md#expressão-crua)
