# Changelog

All notable changes to this project are documented here. The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and the project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-05-01

### Added

- **SELECT** with fields, inline aliases, expressions, `DISTINCT`, and `SelectAll`.
- **Typed field sub-builder** (`BeginFields` / `AddAs`).
- **WHERE operators** — full set:
  - Comparison: `Equal`, `NotEqual`, `GreaterThan`, `GreaterThanOrEqualTo`, `LessThan`, `LessThanOrEqualTo`.
  - Text/LIKE: `Contains`, `NotContains`, `StartsWith`, `EndsWith`, `ContainsCaseInsensitive`.
  - Nullity: `IsNull`, `IsNotNull`.
  - Range: `IsBetween`, `IsNotBetween`.
  - List: `IsIn`, `IsNotIn`.
  - Boolean: `IsTrue`, `IsFalse`.
  - Raw / sub-query: `Raw`, `Exists`.
- **Logical groups**: `OrBegin`/`OrEnd`, `AndBegin`/`AndEnd` (nestable).
- **JOINs**: INNER, LEFT, RIGHT, FULL OUTER, CROSS — with alias support.
- **ORDER BY** with `NULLS FIRST` / `NULLS LAST` (native or dialect-emulated).
- **GROUP BY + HAVING**.
- **Pagination**: `Limit`, `Offset`, `First`.
- **CTE** (`WITH ... AS`) — simple and recursive (`AddRecursive`).
- **INSERT** simple and bulk (multiple `BeginRow` calls).
- **UPDATE** with `SetValue` (parameterized) and `SetRaw` (raw expression).
- **DELETE** — both raise `EUnsafeOperation` when no WHERE is present.
- **RETURNING** clause (PostgreSQL and SQLite 3.35+; silently ignored elsewhere).
- **`TResult<T>` monad** — `.Build` returns `TResult<TQueryResult>`, no render-time exceptions.
- **`TGuard`** — validates pre-conditions at all public entry points.
- **4 dialects**: MySQL 8 (`TMySQL8View`), PostgreSQL (`TPostgreSQLView`), Firebird (`TFirebirdView`), SQLite (`TSQLiteView`).
- **Non-visual component** `TQuery4D` for the Delphi Form Designer (palette: **ORData**).
- **Zero external runtime dependencies** — no VCL/FMX/FireDAC in the core library.
- DUnitX unit test suite (naming convention: `Dado_Quando_Entao`).
- Boss packaging metadata.

### Planned (future versions)

- Oracle dialect (`ROWNUM`, quotes `[col]`).
- SQL Server dialect (`TOP`, quotes `[col]`).
- Typed `IsInSubquery` receiving `IQuery4DController` as parameter.
- Native `ILIKE` in the PostgreSQL dialect.
