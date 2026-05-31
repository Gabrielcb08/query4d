# Testing

Query4D ships a DUnitX-based test suite that exercises every layer of the architecture without requiring a database connection. All tests are pure unit tests — they verify SQL generation, not query execution.

## Framework

- **[DUnitX](https://github.com/VSoftTechnologies/DUnitX)** — vendored under `modules/DUnitX/` (or resolved by Boss).
- The test project is a Delphi 12 VCL application that also runs as a console runner (`--console`).
- Memory leak reporting is opt-in via `--leaks` (combine with `--console`).

## Project layout

```
tests/
└─ Unit/
   ├─ Query4D.Tests.Controller.SelectTest.pas      ← SELECT, DISTINCT, fields, aliases
   ├─ Query4D.Tests.Controller.WhereTest.pas        ← all WHERE operators, logical groups
   ├─ Query4D.Tests.Controller.JoinTest.pas         ← INNER/LEFT/RIGHT/FULL/CROSS joins
   ├─ Query4D.Tests.Controller.OrderGroupTest.pas   ← ORDER BY (NULLS), GROUP BY, HAVING
   ├─ Query4D.Tests.Controller.PaginationTest.pas   ← Limit, Offset, First
   ├─ Query4D.Tests.Controller.CteTest.pas          ← simple and recursive CTEs
   ├─ Query4D.Tests.Controller.DmlTest.pas          ← INSERT, bulk, UPDATE, DELETE, RETURNING
   ├─ Query4D.Tests.Controller.GuardTest.pas        ← EUnsafeOperation, EInvalidQuery
   ├─ Query4D.Tests.View.DialectTest.pas            ← dialect-specific SQL rendering
   └─ Query4D.Tests.Shared.ResultTest.pas           ← TResult<T> monad behavior
```

## Coverage

The test suite covers:

- **SELECT** — `SelectAll`, field lists, aliases, `DISTINCT`, `BeginFields`/`AddAs`.
- **WHERE operators** — all comparison, LIKE, nullity, range, list, boolean, and raw operators.
- **Logical groups** — `OrBegin`/`OrEnd`, `AndBegin`/`AndEnd`, nesting, unbalanced groups → `EInvalidQuery`.
- **JOINs** — all five join types, alias handling, multiple joins.
- **ORDER BY** — ASC/DESC, `NULLS FIRST`/`NULLS LAST` (native and emulated).
- **GROUP BY + HAVING**.
- **Pagination** — `Limit`, `Offset`, `First`, `Limit < 1` → `EInvalidQuery`.
- **CTE** — simple, multiple CTEs, recursive (anchor + recursive member).
- **INSERT** — single row, bulk rows, column alignment.
- **UPDATE** — `SetValue`, `SetRaw`, missing WHERE → `EUnsafeOperation`.
- **DELETE** — missing WHERE → `EUnsafeOperation`.
- **RETURNING** — included in PostgreSQL/SQLite output, omitted in MySQL/Firebird.
- **Dialects** — same query renders differently across MySQL 8, PostgreSQL, Firebird, SQLite.
- **`TResult<T>`** — `IsOk`, `IsFail`, `OnSuccess`, `OnFailure`, chaining.
- **Guards** — `TGuard` pre-condition checks at public entry points.

## Running the tests

### Inside the IDE

Open `tests/Unit/Query4DTests.dproj` in RAD Studio 12 and run (F9). The VCL form lets you tick fixtures and run subsets.

### Headless (CI-friendly)

```powershell
# Build
msbuild tests\Unit\Query4DTests.dproj `
        /t:Build /p:Config=Debug /p:Platform=Win32 /v:minimal

# Run in console mode
tests\Unit\build\Win32\Debug\Query4DTests.exe --console
```

Expected tail:

```
Done testing.
Tests Found   : N
Tests Ignored : 0
Tests Passed  : N
Tests Failed  : 0
Tests Errored : 0
Success: N tests passed
```

Exit code is `0` on full success, `1` on any failure — usable directly from CI scripts.

### Flags

| Flag         | Effect                                                                |
| ------------ | --------------------------------------------------------------------- |
| `--console`  | Run the suite as a console process (no VCL form), prints DUnitX log. |
| `--leaks`    | Enable `ReportMemoryLeaksOnShutdown` (combine with `--console`).     |
| `--pause`    | Wait for ENTER after console output.                                  |

## Adding a new test fixture

Tests follow the **BDD naming convention** `Dado_Quando_Entao` (Given_When_Then):

```delphi
unit Query4D.Tests.Controller.MyOperatorTest;

interface

uses
  DUnitX.TestFramework;

type
  [TestFixture]
  TMyOperatorTest = class
  public
    [Test]
    procedure DadoUmaColunaQuandoUsarMyOperatorEntaoGeraSQL;
  end;

implementation

uses
  Query4D.Controller,
  Query4D.View.MySQL;

procedure TMyOperatorTest.DadoUmaColunaQuandoUsarMyOperatorEntaoGeraSQL;
var
  R : TResult<TQueryResult>;
begin
  R := TQuery4DController.New(TMySQL8View.New)
         .From('t')
         .WhereEq('t.col', 'value')
         .Build;

  Assert.IsTrue(R.IsOk);
  Assert.AreEqual('SELECT * FROM t WHERE t.col = ?', R.Value.SQL);
  Assert.AreEqual('value', R.Value.Params[0]);
end;

initialization
  TDUnitX.RegisterTestFixture(TMyOperatorTest);

end.
```

Add the new unit to **both** `Query4DTests.dpr` and `Query4DTests.dproj`.

## Adding tests for a new dialect

When implementing a new dialect, add a fixture to `Query4D.Tests.View.DialectTest.pas`
that verifies at minimum:

1. Identifier quoting (`QuoteIdentifier`).
2. Parameter placeholder (`?` vs `$N`).
3. Pagination rendering (`LIMIT`/`FIRST`/`TOP`).
4. NULLS order handling (native vs emulated).

See [docs/CONTRIBUTING.md](CONTRIBUTING.md) for the 5-step dialect addition guide.

## Conventions

- **No database connection** — all tests assert on the generated SQL string and params array.
- **One assertion per behavior** — each test method covers exactly one scenario.
- **Naming** — `Dado_Quando_Entao` (BDD): `DadoWhereComDoisCamposQuandoUsarOrBeginEntaoGeraParenteses`.
- **No mocks for dialects** — use the real dialect classes; they are pure functions and cheap to instantiate.
