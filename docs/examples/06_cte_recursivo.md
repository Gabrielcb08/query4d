# Exemplo 06 — CTE Recursivo

## O que este exemplo demonstra

- `WITH RECURSIVE` para hierarquias (árvores de categorias, organogramas)
- Anchor member (caso base) + Recursive member (passo recursivo)
- Uso prático: navegar uma hierarquia de profundidade variável

## Quando usar

Use CTE recursivo quando precisar navegar estruturas hierárquicas armazenadas
como adjacency list (`id`, `pai_id`). É mais eficiente que múltiplos SELECTs
ou stored procedures para hierarquias de profundidade desconhecida.

---

## Hierarquia de categorias

Estrutura da tabela:
```sql
CREATE TABLE categorias (
  id       INTEGER PRIMARY KEY,
  pai_id   INTEGER REFERENCES categorias(id),
  nome     VARCHAR(100)
);
```

Query: trazer toda a hierarquia a partir de uma categoria raiz.

```delphi
var R := TQuery4DController.New(TPostgreSQLView.New)
  .BeginWith
    .AddRecursive('hierarquia',
      // Anchor: categoria raiz
      'SELECT id, pai_id, nome, 0 AS nivel, nome AS caminho ' +
      'FROM categorias WHERE pai_id IS NULL',
      // Recursive: filhos
      'SELECT c.id, c.pai_id, c.nome, h.nivel + 1, ' +
      '       h.caminho || '' > '' || c.nome ' +
      'FROM categorias c ' +
      'INNER JOIN hierarquia h ON h.id = c.pai_id')
  .EndWith
  .From('hierarquia', 'h')
  .Select(['h.id', 'h.nivel', 'h.caminho', 'h.nome'])
  .OrderBy('h.caminho')
  .Build;
```

SQL gerado (PostgreSQL):
```sql
WITH RECURSIVE
  "hierarquia" AS (
    SELECT id, pai_id, nome, 0 AS nivel, nome AS caminho
    FROM categorias WHERE pai_id IS NULL
    UNION ALL
    SELECT c.id, c.pai_id, c.nome, h.nivel + 1,
           h.caminho || ' > ' || c.nome
    FROM categorias c
    INNER JOIN hierarquia h ON h.id = c.pai_id
  )
SELECT h.id, h.nivel, h.caminho, h.nome
FROM hierarquia AS "h"
ORDER BY h.caminho ASC
```

---

## Organograma (funcionários e gerentes)

```delphi
var R := TQuery4DController.New(TMySQL8View.New)
  .BeginWith
    .AddRecursive('org',
      'SELECT id, gerente_id, nome, cargo, 1 AS nivel ' +
      'FROM funcionarios WHERE gerente_id IS NULL',
      'SELECT f.id, f.gerente_id, f.nome, f.cargo, o.nivel + 1 ' +
      'FROM funcionarios f ' +
      'INNER JOIN org o ON o.id = f.gerente_id')
  .EndWith
  .From('org')
  .Select(['org.nivel', 'org.nome', 'org.cargo'])
  .OrderBy('org.nivel')
  .OrderBy('org.nome')
  .Build;
```

---

## Pontos de atenção

- `WITH RECURSIVE` é gerado automaticamente quando `AddRecursive` é usado.
  Misturar `Add` e `AddRecursive` na mesma query resulta em `WITH RECURSIVE`
  aplicado a toda a cláusula (correto por todos os dialetos suportados).
- O separador entre anchor e recursive é sempre `UNION ALL` — gerado pelo View.
- Sem LIMIT, CTEs recursivos em hierarquias circulares entram em loop infinito.
  Adicione um campo `nivel` e filtre por ele (`WHERE nivel <= 10`) para prevenir.
- Compatibilidade: MySQL 8.0+, PostgreSQL qualquer versão, Firebird 2.1+, SQLite 3.8.3+.

## Ver também

- [Exemplo 05 — CTE Simples](05_cte_simples.md)
- [API.md — CTE](../API.md#cte-with)
