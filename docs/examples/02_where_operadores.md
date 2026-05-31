# Exemplo 02 — WHERE com Operadores

## O que este exemplo demonstra

- Todos os operadores de comparação, texto, nulidade, intervalo e lista
- Grupos lógicos OR com `OrBegin`/`OrEnd`
- Atalhos `WhereEq` e `WhereRaw` para casos simples

## Quando usar

Sempre que precisar filtrar linhas. Use `BeginWhere` para queries com múltiplos
predicados. Use `WhereEq` para o caso mais comum de um único `col = val`.

---

## Comparação completa

```delphi
var R := TQuery4DController.New(TMySQL8View.New)
  .From('produtos', 'pr')
  .SelectAll
  .BeginWhere
    .GreaterThan('pr.preco', '10')
    .LessThan('pr.preco', '500')
    .GreaterThanOrEqualTo('pr.estoque', '1')
    .LessThanOrEqualTo('pr.desconto', '30')
    .NotEqual('pr.status', 'inativo')
  .EndWhere
  .Build;
```

SQL gerado:
```sql
SELECT *
FROM produtos AS `pr`
WHERE pr.preco > ?
  AND pr.preco < ?
  AND pr.estoque >= ?
  AND pr.desconto <= ?
  AND pr.status <> ?
```
Params: `['10', '500', '1', '30', 'inativo']`

---

## Texto / LIKE

```delphi
.BeginWhere
  .Contains('pr.nome', 'Kit')            // pr.nome LIKE ?  → param='%Kit%'
  .StartsWith('pr.codigo', 'PRD')        // pr.codigo LIKE ? → param='PRD%'
  .EndsWith('pr.sku', '-BR')             // pr.sku LIKE ?    → param='%-BR'
  .NotContains('pr.descricao', 'teste')  // pr.descricao NOT LIKE ? → param='%teste%'
.EndWhere
```

> Os wildcards `%` são adicionados automaticamente. Você passa o valor limpo.

---

## Nulidade

```delphi
.BeginWhere
  .IsNull('pr.foto_url')       // pr.foto_url IS NULL
  .IsNotNull('pr.categoria_id')// pr.categoria_id IS NOT NULL
.EndWhere
```

---

## Intervalo

```delphi
.BeginWhere
  .IsBetween('pr.preco', '100', '999')
  .IsNotBetween('pr.estoque', '0', '5')
.EndWhere
```

SQL:
```sql
WHERE pr.preco BETWEEN ? AND ?
  AND pr.estoque NOT BETWEEN ? AND ?
```
Params: `['100', '999', '0', '5']`

---

## Lista de valores

```delphi
.BeginWhere
  .IsIn('pr.status', ['ativo', 'promocao', 'lancamento'])
  .IsNotIn('pr.categoria_id', ['99', '100'])
.EndWhere
```

SQL:
```sql
WHERE pr.status IN (?, ?, ?)
  AND pr.categoria_id NOT IN (?, ?)
```

---

## Booleano (flag 0/1)

```delphi
.BeginWhere
  .IsTrue('pr.destaque')    // pr.destaque = 1
  .IsFalse('pr.descontinuado') // pr.descontinuado = 0
.EndWhere
```

---

## Grupos OR

```delphi
var R := TQuery4DController.New(TMySQL8View.New)
  .From('pedidos', 'p')
  .SelectAll
  .BeginWhere
    .Equal('p.ativo', '1')
    .OrBegin
      .Equal('p.canal', 'web')
      .Equal('p.canal', 'app')
      .Equal('p.canal', 'api')
    .OrEnd
    .IsNotNull('p.data_entrega')
  .EndWhere
  .Build;
```

SQL gerado:
```sql
SELECT *
FROM pedidos AS `p`
WHERE p.ativo = ?
  AND (p.canal = ? OR p.canal = ? OR p.canal = ?)
  AND p.data_entrega IS NOT NULL
```

---

## Atalho WhereEq (sem abrir BeginWhere)

```delphi
var R := TQuery4DController.New(TMySQL8View.New)
  .From('clientes')
  .WhereEq('ativo', '1')
  .Limit(10)
  .Build;
```

Útil para o caso mais comum: um único `col = val` sem outros predicados.

---

## Expressão crua (Raw)

```delphi
.BeginWhere
  .Raw('YEAR(p.data_criacao) = 2024')
  .Raw('DAY(p.data_criacao) <= 15')
.EndWhere
```

> Atenção: valores em `Raw` **não** são parametrizados. Use apenas para
> expressões que não envolvem dados do usuário.

## Ver também

- [OPERATORS.md](../OPERATORS.md) — referência completa de todos os operadores
- [API.md — BeginWhere](../API.md#where-atalhos-no-controller-principal)
