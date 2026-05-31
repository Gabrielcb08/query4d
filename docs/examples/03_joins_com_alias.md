# Exemplo 03 — JOINs com Alias

## O que este exemplo demonstra

- INNER JOIN com alias nas duas tabelas
- LEFT JOIN para dados opcionais
- Múltiplos JOINs encadeados
- Atalhos `.Join` e `.LeftJoin` vs `BeginJoins`

## Quando usar

Use JOIN quando precisar combinar dados de tabelas relacionadas numa única query.
Use LEFT JOIN quando a tabela joined pode não ter registros correspondentes
(ex: cliente sem endereço cadastrado).

---

## INNER JOIN simples

```delphi
var R := TQuery4DController.New(TMySQL8View.New)
  .From('pedidos', 'p')
  .Select(['p.id', 'p.numero', 'c.nome', 'c.email'])
  .Join('clientes', 'c', 'c.id = p.cliente_id')
  .WhereEq('p.status', 'aprovado')
  .Build;
```

SQL gerado (MySQL):
```sql
SELECT p.id, p.numero, c.nome, c.email
FROM pedidos AS `p`
INNER JOIN clientes AS `c` ON c.id = p.cliente_id
WHERE p.status = ?
```

---

## LEFT JOIN — dados opcionais

```delphi
var R := TQuery4DController.New(TPostgreSQLView.New)
  .From('clientes', 'c')
  .Select(['c.id', 'c.nome', 'e.logradouro', 'e.cidade'])
  .LeftJoin('enderecos', 'e', 'e.cliente_id = c.id')
  .Build;
```

SQL gerado (PostgreSQL):
```sql
SELECT c.id, c.nome, e.logradouro, e.cidade
FROM clientes AS "c"
LEFT JOIN enderecos AS "e" ON e.cliente_id = c.id
```

Linhas de clientes sem endereço retornam com `e.logradouro` e `e.cidade` nulos.

---

## Múltiplos JOINs encadeados

```delphi
var R := TQuery4DController.New(TMySQL8View.New)
  .From('pedidos', 'p')
  .Select(['p.id', 'c.nome', 'e.descricao', 'v.razao_social'])
  .BeginJoins
    .InnerJoin('clientes',   'c', 'c.id = p.cliente_id')
    .LeftJoin('enderecos',   'e', 'e.id = p.endereco_entrega_id')
    .LeftJoin('vendedores',  'v', 'v.id = p.vendedor_id')
  .EndJoins
  .BeginWhere
    .GreaterThan('p.valor_total', '0')
    .Equal('p.ano', '2024')
  .EndWhere
  .OrderBy('p.data_criacao', odDesc)
  .Limit(100)
  .Build;
```

SQL gerado:
```sql
SELECT p.id, c.nome, e.descricao, v.razao_social
FROM pedidos AS `p`
INNER JOIN clientes AS `c` ON c.id = p.cliente_id
LEFT JOIN enderecos AS `e` ON e.id = p.endereco_entrega_id
LEFT JOIN vendedores AS `v` ON v.id = p.vendedor_id
WHERE p.valor_total > ?
  AND p.ano = ?
ORDER BY p.data_criacao DESC
LIMIT 100
```

---

## Tipos de JOIN disponíveis

| Método | SQL |
|--------|-----|
| `InnerJoin(table, alias, on)` | `INNER JOIN` |
| `LeftJoin(table, alias, on)` | `LEFT JOIN` |
| `RightJoin(table, alias, on)` | `RIGHT JOIN` |
| `FullOuterJoin(table, alias, on)` | `FULL OUTER JOIN` |
| `CrossJoin(table, alias)` | `CROSS JOIN` (sem cláusula ON) |

> **Atenção SQLite:** RIGHT JOIN e FULL OUTER JOIN não são suportados pelo SQLite.
> Reescreva como LEFT JOIN com as tabelas invertidas.

---

## Pontos de atenção

- A cláusula `ON` é sempre uma string — não é validada pelo Query4D.
  Erros de sintaxe no `ON` resultam em erro SQL em runtime.
- Para JOINs com condição extra além da chave (ex: `c.id = p.cliente_id AND c.ativo = 1`),
  passe a expressão completa como string na cláusula `ON`.
- CROSS JOIN não aceita cláusula `ON` — passar uma string no parâmetro `AOn`
  é ignorado silenciosamente.

## Ver também

- [Exemplo 02 — WHERE com Operadores](02_where_operadores.md)
- [Exemplo 07 — Subqueries](07_subqueries.md)
- [API.md — JOIN](../API.md#join)
