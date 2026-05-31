# Query4D — Dialetos Suportados

## Tabela de paridade

| Recurso | MySQL 8 | PostgreSQL | Firebird | SQLite |
|---------|---------|------------|----------|--------|
| SELECT básico | ✅ | ✅ | ✅ | ✅ |
| Paginação | LIMIT/OFFSET | LIMIT/OFFSET | FIRST/SKIP | LIMIT/OFFSET |
| Placeholder param | `?` | `$1`, `$2`… | `?` | `?` |
| Quote identificador | `` `col` `` | `"col"` | `"col"` | `"col"` |
| DISTINCT | ✅ | ✅ | ✅ | ✅ |
| INNER / LEFT JOIN | ✅ | ✅ | ✅ | ✅ |
| RIGHT / FULL OUTER JOIN | ✅ | ✅ | ✅ | ❌ SQLite não tem RIGHT/FULL |
| CROSS JOIN | ✅ | ✅ | ✅ | ✅ |
| GROUP BY + HAVING | ✅ | ✅ | ✅ | ✅ |
| CTE (`WITH`) | ✅ | ✅ | ✅ 2.1+ | ✅ 3.8.3+ |
| CTE Recursivo | ✅ | ✅ | ✅ | ✅ 3.8.3+ |
| INSERT simples | ✅ | ✅ | ✅ | ✅ |
| INSERT bulk (múltiplas linhas) | ✅ | ✅ | ⚠️ ver nota | ✅ |
| RETURNING | ❌ | ✅ | ❌ | ✅ 3.35+ |
| NULLS FIRST / LAST | Emulado | Nativo | Emulado (IIF) | Nativo |
| `ILIKE` (case-insensitive LIKE) | Emulado (`LOWER`) | `ILIKE` nativo | Emulado (`LOWER`) | Emulado (`LOWER`) |
| Window functions (`OVER`) | ✅ 8.0+ | ✅ | ✅ 3.0+ | ✅ 3.25+ |

---

## Detalhes por dialeto

### MySQL 8 — `TMySQL8View`

**Paginação:** `LIMIT n OFFSET m`. Quando `.First` é chamado, gera `LIMIT 1` sem OFFSET.

**Placeholders:** sempre `?`. O array `Params` mantém a ordem dos valores.

**Identificadores:** delimitados com backtick: `` `nome_coluna` ``.

**NULLS FIRST / LAST:** MySQL não suporta nativamente. Emulado com:
```sql
-- NULLS FIRST ASC:
(coluna IS NULL) DESC, coluna ASC
-- NULLS LAST DESC:
(coluna IS NULL) ASC, coluna DESC
```

**RETURNING:** não suportado. A cláusula é silenciosamente ignorada.

**Limitações conhecidas:**
- Subqueries correlacionadas no UPDATE são limitadas pela engine do MySQL.
- CTE disponível a partir do MySQL 8.0.

---

### PostgreSQL — `TPostgreSQLView`

**Paginação:** `LIMIT n OFFSET m`.

**Placeholders:** numerados: `$1`, `$2`, `$3`… O índice incrementa a cada param adicionado, na ordem de aparição na query (WHERE, SET, etc.).

**Identificadores:** delimitados com aspas duplas: `"nome_coluna"`.

**NULLS FIRST / LAST:** suportado nativamente:
```sql
ORDER BY coluna ASC NULLS FIRST
ORDER BY coluna DESC NULLS LAST
```

**RETURNING:** totalmente suportado em INSERT, UPDATE e DELETE.

**ILIKE:** PostgreSQL suporta `ILIKE` nativamente para busca case-insensitive.
O método `ContainsCaseInsensitive` usa `LOWER(col) LIKE LOWER(?)` na base — em dialetos futuros,
o PostgreSQL pode sobrescrever para usar `ILIKE` diretamente.

**Limitações conhecidas:** nenhuma limitação funcional dentro do escopo do Query4D.

---

### Firebird — `TFirebirdView`

**Paginação:** Firebird usa `FIRST` e `SKIP` no lugar de `LIMIT`/`OFFSET`.
A posição é **antes dos campos**, após `SELECT`:
```sql
SELECT FIRST 10 SKIP 20 p.id, p.nome FROM pedidos AS "p"
```
`.First` gera `SELECT FIRST 1`.

**Placeholders:** sempre `?`.

**Identificadores:** aspas duplas: `"nome_coluna"`.

**NULLS FIRST / LAST:** emulado com `IIF`:
```sql
-- NULLS FIRST ASC:
IIF(coluna IS NULL, 0, 1) ASC, coluna ASC
-- NULLS LAST DESC:
IIF(coluna IS NULL, 1, 0) ASC, coluna DESC
```

**RETURNING:** não suportado pelo renderer atual. Em Firebird, `RETURNING` existe
em INSERT/UPDATE/DELETE mas com sintaxe diferente da usada pelo Query4D.

**INSERT bulk:** Firebird não suporta `INSERT INTO ... VALUES (...),(...)` na sintaxe padrão.
Para múltiplas linhas, use `EXECUTE BLOCK` ou múltiplos INSERTs individuais.
O Query4D gera múltiplas linhas VALUES — se isso falhar no seu Firebird,
use `BeginRow` uma vez por insert ou use `EXECUTE BLOCK` via `WhereRaw`/Raw.

**Versão mínima recomendada:** Firebird 2.1 para CTE; 2.5+ para melhor suporte a window functions.

---

### SQLite — `TSQLiteView`

**Paginação:** `LIMIT n OFFSET m`.

**Placeholders:** sempre `?`.

**Identificadores:** aspas duplas: `"nome_coluna"`.

**NULLS FIRST / LAST:** suportado nativamente desde SQLite 3.30.0:
```sql
ORDER BY coluna ASC NULLS FIRST
ORDER BY coluna DESC NULLS LAST
```

**RETURNING:** disponível a partir do SQLite **3.35.0** (2021-03-12).
Em versões anteriores, a cláusula é gerada mas o SQLite lança erro de sintaxe.
O Query4D não verifica a versão do SQLite em runtime — verifique a versão
da sua biblioteca `sqlite3.dll` antes de usar `Returning`.

**RIGHT / FULL OUTER JOIN:** SQLite não suporta `RIGHT JOIN` nem `FULL OUTER JOIN`.
Use `LEFT JOIN` com as tabelas invertidas.

**Limitações conhecidas:**
- Sem stored procedures ou funções definidas pelo usuário na query builder.
- Window functions disponíveis a partir de SQLite 3.25.0.

---

## Como trocar de dialeto em runtime

```delphi
// Direto — instanciar o view desejado
var Q := TQuery4DController.New(TPostgreSQLView.New);

// Via componente no form — mudar a propriedade Dialect
QueryBuilder.Dialect := dSQLite;
var Q := QueryBuilder.NewQuery;

// A mesma query gera SQL diferente para cada banco
// sem nenhuma mudança na lógica de negócio
```

---

## Adicionando um novo dialeto

Veja [CONTRIBUTING.md](CONTRIBUTING.md#como-adicionar-um-novo-dialeto).
