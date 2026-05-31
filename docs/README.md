# Query4D Documentation

Welcome to the Query4D documentation. The main entry points are the project [README](../README.md) (English) and [README.pt-BR](../README.pt-BR.md) (Portuguese). This folder holds the deeper material.

## Index

| Document                              | What's inside                                                         |
| ------------------------------------- | --------------------------------------------------------------------- |
| [ARCHITECTURE.md](ARCHITECTURE.md)   | MVC pattern, layer responsibilities, dependency rules, extensibility. |
| [API.md](API.md)                      | Complete reference for all public methods.                            |
| [OPERATORS.md](OPERATORS.md)         | All WHERE operators with examples and generated SQL.                  |
| [DIALECTS.md](DIALECTS.md)           | Per-dialect differences, limitations, and emulation strategies.       |
| [CONTRIBUTING.md](CONTRIBUTING.md)   | Coding standards, how to add a dialect, PR checklist.                 |
| [BOSS.md](BOSS.md)                   | Install/update via Boss, release workflow, publish checklist.         |
| [CHANGELOG.md](CHANGELOG.md)         | Version-by-version change log (mirrors the root one).                 |

## Quick links

- **Public API surface** — `TQuery4DController` (fluent entry point), `TResult<TQueryResult>` (result type), dialect view classes.
- **Non-visual component** — `TQuery4D` in the **ORData** palette after installing `packages/Delphi12/Query4D.dpk`.
- **Examples**: [docs/examples/](examples/) — 8 numbered Markdown files from basic SELECT to recursive CTEs and dialect comparison.
- **Tests**: [tests/Unit/](../tests/Unit/) — DUnitX unit test suite (no database required).
- **Demo app**: [samples/Query4DDemo.dpr](../samples/Query4DDemo.dpr) — interactive VCL application.

## Project status

Query4D is at **stable release** (`1.0.0`). The public API is stable; the [roadmap](../README.md#roadmap) lists planned additions.

Bug reports and feature requests are welcome — see [CONTRIBUTING.md](CONTRIBUTING.md).
