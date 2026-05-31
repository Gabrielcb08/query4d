# Boss

[Boss](https://github.com/HashLoad/boss) is the recommended package manager for installing and updating Query4D.

## Install

```bash
# Pin to a release tag (recommended for production projects)
boss install https://github.com/gabrielcb08/query4d@v1.0.0

# Latest commit on default branch (only for experimentation)
boss install https://github.com/gabrielcb08/query4d
```

Boss clones the repo into `./modules/query4d` and patches your project's search paths so `uses Query4D.Controller;` works out of the box.

Query4D has **zero external runtime dependencies** — no transitive packages are pulled in.

## Update

```bash
# Refresh to the latest commit / tagged version declared in boss.json
boss update https://github.com/gabrielcb08/query4d
```

To move to a different pinned version, edit `boss.json` and re-run `boss install`.

## Validate from a Clean Consumer Project

```bash
mkdir query4d-smoke
cd query4d-smoke
boss init -q
boss install https://github.com/gabrielcb08/query4d@v1.0.0
```

Then drop a 10-line `.dpr` importing `Query4D.Controller` to confirm the integration:

```delphi
program Smoke;
{$APPTYPE CONSOLE}
uses
  System.SysUtils,
  Query4D.Controller,
  Query4D.View.MySQL;
var
  R : TResult<TQueryResult>;
begin
  R := TQuery4DController.New(TMySQL8View.New)
         .From('users')
         .WhereEq('active', '1')
         .Build;
  Writeln(R.Value.SQL);
end.
```

If it compiles and prints `SELECT * FROM users WHERE active = ?`, the install is good.

## Package metadata

Package metadata is declared in `boss.json` at the repo root:

```json
{
  "name": "query4d",
  "description": "Fluent SQL query builder for Delphi with pluggable dialects (MySQL, PostgreSQL, Firebird, SQLite), safety guards and zero external dependencies.",
  "version": "1.0.0",
  "homepage": "https://github.com/gabrielcb08/query4d",
  "mainsrc": "packages/Delphi12",
  "projects": [
    "./packages/Delphi12/Query4D.dproj",
    "./packages/Delphi12/dclQuery4D.dproj",
    "./samples/Query4DDemo.dproj",
    "./tests/Unit/Query4DTests.dproj"
  ],
  "dependencies": {}
}
```

## Release Workflow

Use semantic tags in the format `vX.Y.Z`, always aligned with the `version` field in `boss.json`.

```bash
# 1) Update version + changelog, then commit
git add boss.json CHANGELOG.md docs/CHANGELOG.md README.md README.pt-BR.md docs/BOSS.md
git commit -m "release: v1.0.0"

# 2) Create an annotated tag
git tag -a v1.0.0 -m "Query4D v1.0.0"

# 3) Push branch and tags
git push origin main
git push origin --tags
```

## Publish Checklist

1. Bump `version` in `boss.json`.
2. Move the corresponding section in [CHANGELOG.md](../CHANGELOG.md) and [docs/CHANGELOG.md](CHANGELOG.md) out of `Unreleased`, dating it with the release day.
3. Run the full test suite (`Query4DTests.exe --console`) — must return `0`.
4. Build all sample projects to catch any compile breakage from API changes.
5. Commit the release changes.
6. Tag (annotated) with `vX.Y.Z`.
7. Push branch + tags.
8. Validate `boss install https://github.com/gabrielcb08/query4d@<tag>` from a clean workspace.
9. Cut a GitHub Release pointing at the tag and pasting the changelog block as the release notes.
