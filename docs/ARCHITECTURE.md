# Query4D — Arquitetura MVC

## Visão geral

Query4D é uma biblioteca de construção de queries SQL fluente para Delphi 10.3+,
sem dependências de framework (VCL/FMX/FireDAC não requeridos no núcleo).

## Padrão MVC aplicado

| Camada     | Responsabilidade |
|------------|-----------------|
| **Model**  | Estado da query: campos, predicados WHERE, JOINs, ORDER, GROUP, CTEs, paginação, DML |
| **View**   | Renderiza o Model em SQL para um dialeto específico (`IDialectView`) |
| **Controller** | API fluente que o usuário chama; manipula o Model e delega ao View no `Build` |

## Regra de dependência

```
Controller → Model
Controller → View (interfaces)
View (impl) → Model
View (impl) → Shared
Controller → Shared
Model → Shared
```

## Estrutura de pastas

```
src/
  Shared/      — TResult<T>, TGuard, exceções, utilitários
  Model/       — TQueryModel e sub-models (estado da query)
  View/        — IDialectView + implementações dos 4 dialetos
  Controller/  — TQuery4DController (fluent) + sub-controllers
tests/
  Unit/        — testes sem banco, nomenclatura Dado_Quando_Entao
```

## Uso básico

```delphi
uses
  Query4D.Controller,
  Query4D.View.MySQL;

var
  Result := TQuery4DController.New(TMySQL8View.New)
    .From('pedidos', 'p')
    .Select(['p.id', 'p.nome', 'p.status'])
    .BeginWhere
      .Equal('p.ativo', '1')
      .OrBegin
        .Equal('p.status', 'aprovado')
        .Equal('p.status', 'pendente')
      .OrEnd
    .EndWhere
    .OrderBy('p.nome')
    .Limit(20)
    .Build;

if Result.IsOk then
  ExecuteSQL(Result.Value.SQL, Result.Value.Params);
```

## Trocar dialeto

```delphi
// Mesma query, dialeto PostgreSQL — ou via componente no form designer:
// QueryBuilder.Dialect := dPostgreSQL;
// QueryBuilder.NewQuery. ...
TQuery4DController.New(TPostgreSQLView.New)
  ...
  .Build;

// Dialeto Firebird (FIRST/SKIP gerado automaticamente)
TQuery4DController.New(TFirebirdView.New)
  ...
  .Limit(10).Offset(20)
  .Build;
// Gera: SELECT FIRST 10 SKIP 20 ...
```

## Segurança

- Todos os valores passados aos predicados WHERE viram parâmetros (`?` ou `$N`)
- `UPDATE` e `DELETE` sem `WHERE` lançam `EUnsafeOperation` antes de renderizar
- `TGuard` valida pré-condições em todo ponto de entrada público

## Extensibilidade (Open/Closed)

Para adicionar um novo dialeto, basta implementar `IDialectView` (ou herdar de `TBaseDialectView`
e sobrescrever apenas o que difere: `QuoteIdentifier`, `ParameterPlaceholder`, `RenderPaginationClause`).
Nenhuma linha existente precisa ser alterada.
