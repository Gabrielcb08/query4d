# Query4D — Operadores WHERE

Referência completa de todos os operadores disponíveis em `IWhereController`
(acessado via `.BeginWhere`).

Todos os valores passados como parâmetros viram **bind params** na query gerada
— nunca são interpolados como string no SQL.

---

## Comparação

| Método | SQL gerado | Exemplo |
|--------|-----------|---------|
| `Equal(col, val)` | `col = ?` | `.Equal('p.status', 'ativo')` |
| `NotEqual(col, val)` | `col <> ?` | `.NotEqual('p.status', 'cancelado')` |
| `GreaterThan(col, val)` | `col > ?` | `.GreaterThan('p.valor', '100')` |
| `GreaterThanOrEqualTo(col, val)` | `col >= ?` | `.GreaterThanOrEqualTo('p.estoque', '1')` |
| `LessThan(col, val)` | `col < ?` | `.LessThan('p.desconto', '50')` |
| `LessThanOrEqualTo(col, val)` | `col <= ?` | `.LessThanOrEqualTo('p.preco', '999')` |

---

## Texto / LIKE

| Método | SQL gerado | Padrão gerado |
|--------|-----------|---------------|
| `Contains(col, val)` | `col LIKE ?` | param = `%val%` |
| `NotContains(col, val)` | `col NOT LIKE ?` | param = `%val%` |
| `StartsWith(col, val)` | `col LIKE ?` | param = `val%` |
| `EndsWith(col, val)` | `col LIKE ?` | param = `%val` |
| `ContainsCaseInsensitive(col, val)` | `LOWER(col) LIKE LOWER(?)` | param = `%val%` |

> Os wildcards `%` são **adicionados automaticamente** pelo controller.
> Você passa apenas o valor sem `%`. O param resultante inclui os wildcards.

Exemplo:
```delphi
.Contains('p.nome', 'Silva')
// SQL: p.nome LIKE ?
// Param: '%Silva%'
```

---

## Nulidade

| Método | SQL gerado |
|--------|-----------|
| `IsNull(col)` | `col IS NULL` |
| `IsNotNull(col)` | `col IS NOT NULL` |

Sem parâmetros — não geram bind params.

---

## Intervalo

| Método | SQL gerado |
|--------|-----------|
| `IsBetween(col, from, to)` | `col BETWEEN ? AND ?` |
| `IsNotBetween(col, from, to)` | `col NOT BETWEEN ? AND ?` |

Geram 2 params cada.

---

## Lista

| Método | SQL gerado |
|--------|-----------|
| `IsIn(col, values)` | `col IN (?, ?, ...)` |
| `IsNotIn(col, values)` | `col NOT IN (?, ?, ...)` |

`values` é `TArray<string>`. Gera um param por elemento.

```delphi
.IsIn('p.status', ['aprovado', 'pendente', 'em_analise'])
// SQL: p.status IN (?, ?, ?)
// Params: ['aprovado', 'pendente', 'em_analise']
```

---

## Booleano

| Método | SQL gerado | Uso típico |
|--------|-----------|-----------|
| `IsTrue(col)` | `col = 1` | Campos flag (0/1) |
| `IsFalse(col)` | `col = 0` | Campos flag (0/1) |

Sem parâmetros.

---

## Expressão crua

| Método | SQL gerado |
|--------|-----------|
| `Raw(expr)` | `expr` (verbatim) |
| `Exists(subquery)` | `EXISTS (subquery)` |

Use `Raw` quando nenhum operador tipado servir. Os valores dentro da expressão
**não** viram params — cuidado com SQL injection ao usar `Raw`.

```delphi
.Raw('YEAR(p.data_criacao) = 2024')
.Exists('SELECT 1 FROM logs WHERE logs.pedido_id = p.id')
```

---

## Agrupamento lógico

Por padrão, predicados encadeados são combinados com `AND`.
Para combinar com `OR`, use grupos:

### `OrBegin` / `OrEnd`

Abre e fecha um grupo cujos predicados internos são unidos por `OR`.
O grupo em si é conectado ao contexto externo por `AND`.

```delphi
.BeginWhere
  .Equal('p.ativo', '1')           // AND
  .OrBegin
    .Equal('p.canal', 'web')       // OR
    .Equal('p.canal', 'app')       // OR
    .Equal('p.canal', 'api')       // OR
  .OrEnd                           // grupo fechado, conectado com AND
.EndWhere
```

SQL gerado:
```sql
WHERE p.ativo = ?
  AND (p.canal = ? OR p.canal = ? OR p.canal = ?)
```

### `AndBegin` / `AndEnd`

Abre e fecha um subgrupo explicitamente AND — útil para agrupar condições
dentro de um contexto OR.

```delphi
.BeginWhere
  .OrBegin
    .AndBegin
      .Equal('p.tipo', 'fisico')
      .GreaterThan('p.peso', '0')
    .AndEnd
    .Equal('p.tipo', 'digital')
  .OrEnd
.EndWhere
```

SQL gerado:
```sql
WHERE ((p.tipo = ? AND p.peso > ?) OR p.tipo = ?)
```

---

## Regras de balanceamento

| Regra | Exceção lançada |
|-------|----------------|
| `OrEnd` sem `OrBegin` correspondente | `EInvalidQuery` |
| `AndEnd` sem `AndBegin` correspondente | `EInvalidQuery` |
| `EndWhere` com grupo aberto | `EInvalidQuery` |

---

## Enum interno `TWhereOperator`

Para referência: os valores do enum interno que o modelo usa.
Não é necessário usá-los diretamente — os métodos acima os encapsulam.

```delphi
TWhereOperator = (
  woEqual, woNotEqual, woGreaterThan, woGreaterThanOrEqualTo,
  woLessThan, woLessThanOrEqualTo,
  woContains, woNotContains, woStartsWith, woEndsWith, woContainsCaseInsensitive,
  woIsNull, woIsNotNull,
  woIsBetween, woIsNotBetween,
  woIsIn, woIsNotIn, woIsInSubquery, woIsNotInSubquery,
  woIsTrue, woIsFalse,
  woExists, woNotExists, woRaw
);
```
