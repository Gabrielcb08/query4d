# Como Contribuir ao Query4D

Obrigado pelo interesse! Este guia cobre tudo que você precisa saber
para contribuir com código, testes ou documentação.

---

## Antes de abrir um PR

- [ ] Leu [ARCHITECTURE.md](ARCHITECTURE.md) completo
- [ ] Novos métodos seguem a nomenclatura de [OPERATORS.md](OPERATORS.md) (sem abreviações)
- [ ] Todos os testes unitários passam sem banco de dados: `tests\Unit\Query4DTests.dpr`
- [ ] Novo código não introduz dependência de VCL, FMX ou FireDAC no núcleo (`src\`)
- [ ] Novo dialeto tem testes de renderização em `tests\Unit\Query4D.Tests.Dialects.pas`

---

## Configurando o ambiente

1. Delphi 10.3 ou superior (testado com Delphi 12.1)
2. Clone o repositório
3. Abra `Query4D.groupproj` no Delphi IDE
4. Compile o pacote `Query4DLib.dpk`
5. Execute os testes via `tests\Unit\Query4DTests.dpr` com **Shift+Ctrl+F9**
   (sem debugger — evita paradas em exceções intencionais nos testes)

---

## Padrões de código

### Nomenclatura

- **Identificadores em inglês** no código-fonte (métodos, variáveis, tipos)
- **Sem abreviações** em métodos públicos: `GreaterThan`, não `Gt`; `Equal`, não `Eq`
- Nomenclatura BDD nos testes: `Dado_..._Quando_..._Entao_...`
- Interfaces antes de implementações: `IWhereController` antes de `TWhereController`

### Estrutura

- Cada classe em seu próprio arquivo com a unidade correspondente
- Arquivos de interface (`*.Interfaces.pas`) não dependem de implementações
- `TGuard` para validar pré-condições — não use asserts ou ifs inline
- Sem comentários explicativos de "o que" — apenas "por que" quando não óbvio

### Testes

- Testes unitários não usam banco de dados
- Um teste por comportamento (`[Test]` separado, não `Assert` múltiplos no mesmo teste)
- Use `Assert.WillRaise` e `Assert.WillNotRaise` para exceções
- Nomenclatura: `Dado_Cenario_Quando_Acao_Entao_Resultado`

---

## Como adicionar um novo operador WHERE

1. **`src\Model\Query4D.Model.Types.pas`**: adicionar o valor ao enum `TWhereOperator`
2. **`src\Controller\Query4D.Controller.Interfaces.pas`**: declarar o método em `IWhereController`
3. **`src\Controller\Query4D.Controller.Where.pas`**: implementar o método
4. **`src\View\Query4D.View.Base.pas`**: adicionar o `case` no método `RenderWherePredicate`
5. **`tests\Unit\Query4D.Tests.Model.pas`** ou **Tests.Dialects.pas**: testes do SQL gerado
6. **`docs\OPERATORS.md`**: documentar o novo operador com exemplo e SQL gerado

---

## Como adicionar um novo dialeto

### 1. Criar o arquivo de implementação

```
src\View\Query4D.View.NomeDialeto.pas
```

Herde de `TBaseDialectView` e sobrescreva apenas o que difere:

```delphi
unit Query4D.View.NomeDialeto;

interface

uses
  Query4D.Model.Types,
  Query4D.Model.Order,
  Query4D.Model.Query,
  Query4D.View.Base,
  Query4D.View.Interfaces;

type
  TNomeDialetoView = class(TBaseDialectView)
  protected
    function RenderPaginationClause(const AModel: TQueryModel): string; override;
    function WrapNullsFirst(const AColumn: string; const ADir: TOrderDirection): string; override;
    function WrapNullsLast(const AColumn: string; const ADir: TOrderDirection): string; override;
  public
    function SupportsFeature(const AFeature: TDialectFeature): Boolean; override;
    function QuoteIdentifier(const AName: string): string; override;
    function ParameterPlaceholder(const AIndex: Integer): string; override;
    class function New: IDialectView;
  end;
```

### 2. Adicionar ao enum `TQuery4DDialect`

Em `src\Query4D.Register.pas`:
```delphi
TQuery4DDialect = (dMySQL8, dPostgreSQL, dFirebird, dSQLite, dNomeDialeto);
```

E no `case` de `CreateDialectView`:
```delphi
dNomeDialeto: Result := TNomeDialetoView.New;
```

### 3. Adicionar ao pacote

Em `Query4DLib.dpk`, adicionar:
```
Query4D.View.NomeDialeto in 'src\View\Query4D.View.NomeDialeto.pas',
```

### 4. Escrever testes

Em `tests\Unit\Query4D.Tests.Dialects.pas`, adicionar um `[TestFixture]`
com pelo menos:
- SELECT simples
- WHERE com parâmetro (verifica placeholder correto)
- Paginação (LIMIT/OFFSET ou equivalente)
- `QuoteIdentifier`
- `SupportsFeature(dfReturning)`
- NULLS FIRST/LAST (se diferente do base)

### 5. Documentar

Em `docs\DIALECTS.md`, adicionar:
- Linha na tabela de paridade
- Seção com detalhes do dialeto
- Versão mínima recomendada
- Limitações conhecidas (sem eufemismos)

---

## Como reportar um bug

Abra uma issue incluindo obrigatoriamente:

- **Dialeto afetado**: MySQL 8 / PostgreSQL / Firebird / SQLite
- **Código Delphi que reproduz**: mínimo que demonstra o problema
- **SQL esperado** vs **SQL gerado**
- **Versão do Delphi** e versão do Query4D (tag/commit)

Sem essas informações, o issue pode ser fechado sem resposta.

---

## Roadmap de contribuições bem-vindas

- [ ] Suporte a `ILIKE` nativo no dialeto PostgreSQL (via override de `RenderWherePredicate`)
- [ ] Dialeto Oracle (ROWNUM pagination, `"` quotes)
- [ ] Dialeto SQL Server (TOP pagination, `[` quotes)
- [ ] Suporte a subqueries tipadas (`IsInSubquery` com `IQuery4DController`)
- [ ] Benchmark comparativo (geração de SQL vs interpolação manual)

---

## Licença

Contribuições aceitas sob MIT.
Ao abrir um PR, você concorda que sua contribuição será distribuída
sob a mesma licença do projeto.
