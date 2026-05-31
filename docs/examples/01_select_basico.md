# Exemplo 01 — SELECT Básico

## O que este exemplo demonstra

- SELECT com campos específicos vs SELECT *
- FROM com alias
- DISTINCT
- Campos com alias inline e via `BeginFields`

## Quando usar

Use SELECT básico quando precisar listar dados de uma tabela sem filtros complexos.
Use `BeginFields` quando precisar de alias tipados (string literal, sem risco de typo).

---

## SELECT com campos específicos

```delphi
uses Query4D.Controller, Query4D.View.MySQL;

var R := TQuery4DController.New(TMySQL8View.New)
  .From('pedidos', 'p')
  .Select(['p.id', 'p.numero', 'p.valor_total', 'p.status'])
  .Build;
```

SQL gerado (MySQL):
```sql
SELECT p.id, p.numero, p.valor_total, p.status
FROM pedidos AS `p`
```

---

## SELECT * (padrão)

```delphi
var R := TQuery4DController.New(TMySQL8View.New)
  .From('clientes')
  .SelectAll
  .Build;
```

SQL gerado:
```sql
SELECT *
FROM clientes
```

Quando nenhum campo é especificado, `SELECT *` é o padrão.

---

## SELECT com alias de campos (BeginFields)

```delphi
var R := TQuery4DController.New(TPostgreSQLView.New)
  .From('pedidos', 'p')
  .BeginFields
    .Add('p.id')
    .Add('p.numero')
    .AddAs('p.valor_total', 'valor')
    .AddAs('p.status', 'situacao')
  .EndFields
  .Build;
```

SQL gerado (PostgreSQL):
```sql
SELECT p.id, p.numero, p.valor_total AS "valor", p.status AS "situacao"
FROM pedidos AS "p"
```

---

## DISTINCT

```delphi
var R := TQuery4DController.New(TMySQL8View.New)
  .From('pedidos', 'p')
  .Select(['p.cliente_id'])
  .Distinct
  .Build;
```

SQL gerado:
```sql
SELECT DISTINCT p.cliente_id
FROM pedidos AS `p`
```

---

## Pontos de atenção

- `Select([...])` e `BeginFields` são mutuamente exclusivos — use um ou outro.
- `SelectAll` limpa qualquer lista de campos prévia.
- Alias de campos via `AddAs` são delimitados com o quote do dialeto (`"` ou `` ` ``).
- Expressões como `COUNT(*)` e `SUM(p.valor)` podem ser passadas diretamente como strings em `Select([...])`.

## Ver também

- [Exemplo 03 — JOINs com Alias](03_joins_com_alias.md)
- [API.md — SELECT](../API.md#select)
