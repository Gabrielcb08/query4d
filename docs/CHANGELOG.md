# Changelog

Todas as mudanças notáveis neste projeto são documentadas aqui.

Formato baseado em [Keep a Changelog](https://keepachangelog.com/pt-BR/1.0.0/).
Versionamento segue [Semantic Versioning](https://semver.org/lang/pt-BR/).

---

## [Unreleased]

### Planejado
- Dialeto Oracle (ROWNUM, `[col]` quotes)
- Dialeto SQL Server (TOP, `[col]` quotes)
- `IsInSubquery` tipado com `IQuery4DController` como parâmetro
- `ILIKE` nativo no dialeto PostgreSQL

---

## [1.0.0] — 2026-05

### Adicionado
- **Componente não-visual `TQuery4D`** — registrado na paleta `ORData` do Delphi IDE
  com ícone próprio e propriedade `Dialect` configurável no Object Inspector
- **Operadores WHERE completos** com nomenclatura autoexplicativa:
  `Equal`, `NotEqual`, `GreaterThan`, `GreaterThanOrEqualTo`, `LessThan`, `LessThanOrEqualTo`,
  `Contains`, `NotContains`, `StartsWith`, `EndsWith`, `ContainsCaseInsensitive`,
  `IsNull`, `IsNotNull`, `IsBetween`, `IsNotBetween`, `IsIn`, `IsNotIn`,
  `IsTrue`, `IsFalse`, `Exists`, `Raw`
- **Agrupamento lógico** `OrBegin`/`OrEnd` e `AndBegin`/`AndEnd`
- **SELECT** com campos, alias tipado (`BeginFields`), DISTINCT, `SelectAll`
- **FROM** com alias
- **JOIN** — INNER, LEFT, RIGHT, FULL OUTER, CROSS — via `BeginJoins` e atalhos
- **ORDER BY** com suporte a `NULLS FIRST`/`NULLS LAST` (nativo ou emulado por dialeto)
- **GROUP BY + HAVING** via `BeginGroup` e atalhos
- **Paginação** — `Limit`, `Offset`, `First`
- **INSERT** simples e bulk (múltiplas linhas via múltiplos `BeginRow`)
- **UPDATE** e **DELETE** com guard obrigatório de WHERE (`EUnsafeOperation`)
- **CTE** simples e recursivo via `BeginWith`
- **RETURNING** para PostgreSQL e SQLite 3.35+
- **Quatro dialetos**: MySQL 8, PostgreSQL, Firebird, SQLite
- **`TResult<T>`** — tipo monad para tratamento de erros sem exceções na camada View
- **`TGuard`** — validações de pré-condição com exceções tipadas
- Hierarquia de exceções: `EQuery4D` → `EInvalidQuery`, `EUnsafeOperation`,
  `EDialectNotInjected`, `EInvalidAlias`
- Documentação completa: README, API, OPERATORS, DIALECTS, CONTRIBUTING, exemplos

### Segurança
- Todos os valores de predicados WHERE viram parâmetros bind — sem interpolação de string
- `UPDATE`/`DELETE` sem `WHERE` lançam `EUnsafeOperation` na camada Controller
  (antes de chegar ao dialeto, garantindo proteção mesmo com mocks em testes)

---

## Legenda

- **Adicionado** — nova funcionalidade
- **Modificado** — mudança em funcionalidade existente
- **Descontinuado** — será removido em versão futura
- **Removido** — funcionalidade removida
- **Corrigido** — correção de bug
- **Segurança** — correção de vulnerabilidade
