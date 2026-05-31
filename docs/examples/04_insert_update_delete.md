# Exemplo 04 — INSERT, UPDATE e DELETE

## O que este exemplo demonstra

- INSERT simples e bulk (múltiplas linhas)
- UPDATE com SetValue (parametrizado) e SetRaw (expressão literal)
- DELETE com WHERE obrigatório
- Guard de segurança: UPDATE/DELETE sem WHERE lança `EUnsafeOperation`

## Quando usar

Use estes métodos quando precisar modificar dados. O guard de segurança
é intencional — protege contra atualizações/exclusões acidentais em toda a tabela.

---

## INSERT simples

```delphi
var R := TQuery4DController.New(TMySQL8View.New)
  .InsertInto('pedidos')
  .BeginRow
    .Value('cliente_id', '42')
    .Value('valor_total', '199.90')
    .Value('status', 'pendente')
  .Build;
```

SQL gerado (MySQL):
```sql
INSERT INTO pedidos (cliente_id, valor_total, status)
VALUES (?, ?, ?)
```
Params: `['42', '199.90', 'pendente']`

---

## INSERT bulk (múltiplas linhas)

```delphi
var R := TQuery4DController.New(TMySQL8View.New)
  .InsertInto('itens_pedido')
  .BeginRow
    .Value('pedido_id', '100')
    .Value('produto_id', '10')
    .Value('quantidade', '2')
  .BeginRow
    .Value('pedido_id', '100')
    .Value('produto_id', '15')
    .Value('quantidade', '1')
  .BeginRow
    .Value('pedido_id', '100')
    .Value('produto_id', '22')
    .Value('quantidade', '3')
  .Build;
```

SQL gerado:
```sql
INSERT INTO itens_pedido (pedido_id, produto_id, quantidade)
VALUES (?, ?, ?),
       (?, ?, ?),
       (?, ?, ?)
```
Params: 9 valores na ordem declarada.

> **Atenção Firebird:** múltiplas linhas VALUES não é suportado nativamente.
> Use `BeginRow` separado por INSERT individual ou use `EXECUTE BLOCK`.

---

## INSERT com RETURNING (PostgreSQL / SQLite 3.35+)

```delphi
var R := TQuery4DController.New(TPostgreSQLView.New)
  .InsertInto('pedidos')
  .BeginRow
    .Value('cliente_id', '42')
    .Value('status', 'pendente')
  .Returning(['id', 'criado_em'])
  .Build;
```

SQL gerado (PostgreSQL):
```sql
INSERT INTO pedidos (cliente_id, status)
VALUES ($1, $2)
RETURNING id, criado_em
```

Em MySQL, `RETURNING` é ignorado silenciosamente.

---

## UPDATE

```delphi
var R := TQuery4DController.New(TMySQL8View.New)
  .Update('pedidos')
  .SetValue('status', 'aprovado')         // parametrizado: SET status = ?
  .SetRaw('data_aprovacao', 'NOW()')      // literal:        SET data_aprovacao = NOW()
  .SetRaw('updated_at', 'CURRENT_TIMESTAMP')
  .WhereEq('id', '42')
  .Build;
```

SQL gerado:
```sql
UPDATE pedidos
SET status = ?, data_aprovacao = NOW(), updated_at = CURRENT_TIMESTAMP
WHERE id = ?
```
Params: `['aprovado', '42']`

---

## UPDATE com WHERE composto

```delphi
var R := TQuery4DController.New(TMySQL8View.New)
  .Update('produtos')
  .SetValue('preco', '159.90')
  .BeginWhere
    .IsIn('categoria_id', ['5', '7', '12'])
    .Equal('ativo', '1')
  .EndWhere
  .Build;
```

SQL:
```sql
UPDATE produtos
SET preco = ?
WHERE categoria_id IN (?, ?, ?)
  AND ativo = ?
```

---

## DELETE

```delphi
var R := TQuery4DController.New(TMySQL8View.New)
  .DeleteFrom('sessoes')
  .WhereEq('usuario_id', '99')
  .Build;
```

SQL:
```sql
DELETE FROM sessoes
WHERE usuario_id = ?
```

---

## Guard de segurança — EUnsafeOperation

UPDATE ou DELETE sem WHERE lança `EUnsafeOperation` **antes** de renderizar:

```delphi
try
  var R := TQuery4DController.New(TMySQL8View.New)
    .Update('clientes')
    .SetValue('ativo', '0')
    // sem .WhereEq ou .BeginWhere
    .Build;
except
  on E: EUnsafeOperation do
    ShowMessage('Bloqueado: ' + E.Message);
    // '[Guard] UPDATE/DELETE sem WHERE e proibido.'
end;
```

Para forçar explicitamente um UPDATE/DELETE em toda a tabela (raro, perigoso):

```delphi
.Update('cache_temporario')
  .SetValue('processado', '1')
  .WhereRaw('1=1')   // sinaliza explicitamente a intenção
  .Build;
```

---

## Pontos de atenção

- `SetValue` parametriza o valor. `SetRaw` insere literalmente — use apenas com
  expressões da engine (NOW(), DEFAULT, CURRENT_TIMESTAMP), nunca com dados do usuário.
- A ordem dos params em UPDATE é: valores do SET primeiro, depois valores do WHERE.
- `RETURNING` em UPDATE também é suportado (PostgreSQL/SQLite).

## Ver também

- [API.md — DML](../API.md#dml--insert)
- [Exemplo 08 — Dialetos Comparados](08_dialetos_comparados.md)
