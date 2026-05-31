unit Form.Main;

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.ComCtrls, Vcl.ExtCtrls, Vcl.Buttons,
  Query4D.Register,
  Query4D.Controller.Interfaces,
  Query4D.Model.Types,
  Query4D.Shared.Result;

type
  TScenarioProc = reference to procedure(const Q: IQuery4DController);

  TFormMain = class(TForm)
    // ── layout ──
    PanelTop:     TPanel;
    PanelBottom:  TPanel;
    PanelCode:    TPanel;
    PanelSQL:     TPanel;
    Splitter:     TSplitter;
    // ── painel superior (cenários) ──
    BtnSelect:    TButton;
    BtnWhere:     TButton;
    BtnJoin:      TButton;
    BtnDML:       TButton;
    BtnCTE:       TButton;
    // ── memos ──
    LabelCode:    TLabel;
    MemoCode:     TMemo;
    LabelSQL:     TLabel;
    MemoSQL:      TMemo;
    // ── painel inferior (controles) ──
    LabelDialect: TLabel;
    ComboDialect: TComboBox;
    BtnExecute:   TSpeedButton;
    BtnClear:     TSpeedButton;
    LabelStatus:  TLabel;
    // ── componente não-visual (visível no designer com ícone) ──
    QueryBuilder: TQuery4D;
  private
    FCurrentScenario: TScenarioProc;

    procedure SetScenario(const ACode: string; AProc: TScenarioProc);
    procedure UpdateDialect;
    procedure Execute;
    procedure ShowSuccess(const ASQL: string; const AParams: TArray<string>);
    procedure ShowError(const AMessage: string);

    // cenários
    procedure ScenarioSelect;
    procedure ScenarioWhere;
    procedure ScenarioJoin;
    procedure ScenarioDML;
    procedure ScenarioCTE;

  public
    procedure AfterConstruction; override;
  published
    procedure BtnSelectClick(Sender: TObject);
    procedure BtnWhereClick(Sender: TObject);
    procedure BtnJoinClick(Sender: TObject);
    procedure BtnDMLClick(Sender: TObject);
    procedure BtnCTEClick(Sender: TObject);
    procedure BtnExecuteClick(Sender: TObject);
    procedure BtnClearClick(Sender: TObject);
    procedure ComboDialectChange(Sender: TObject);
  end;

var
  FormMain: TFormMain;

implementation

{$R *.dfm}

uses
  Query4D.View.Interfaces;

const
  CODE_SELECT =
    'TQuery4DController.New(Dialect)' + sLineBreak +
    '  .From(''pedidos'', ''p'')' + sLineBreak +
    '  .Select([''p.id'', ''p.numero'', ''p.valor_total''])' + sLineBreak +
    '  .BeginWhere' + sLineBreak +
    '    .Equal(''p.status'', ''aprovado'')' + sLineBreak +
    '    .GreaterThan(''p.valor_total'', ''100'')' + sLineBreak +
    '    .IsNotNull(''p.data_entrega'')' + sLineBreak +
    '  .EndWhere' + sLineBreak +
    '  .OrderBy(''p.data_criacao'', odDesc)' + sLineBreak +
    '  .Limit(20)' + sLineBreak +
    '  .Build';

  CODE_WHERE =
    'TQuery4DController.New(Dialect)' + sLineBreak +
    '  .From(''produtos'', ''pr'')' + sLineBreak +
    '  .SelectAll' + sLineBreak +
    '  .BeginWhere' + sLineBreak +
    '    .GreaterThan(''pr.preco'', ''10'')' + sLineBreak +
    '    .LessThanOrEqualTo(''pr.preco'', ''500'')' + sLineBreak +
    '    .IsNotNull(''pr.categoria_id'')' + sLineBreak +
    '    .Contains(''pr.nome'', ''Kit'')' + sLineBreak +
    '    .IsIn(''pr.status'', [''ativo'', ''promocao''])' + sLineBreak +
    '    .IsBetween(''pr.estoque'', ''1'', ''999'')' + sLineBreak +
    '    .OrBegin' + sLineBreak +
    '      .Equal(''pr.destaque'', ''1'')' + sLineBreak +
    '      .Equal(''pr.lancamento'', ''1'')' + sLineBreak +
    '    .OrEnd' + sLineBreak +
    '  .EndWhere' + sLineBreak +
    '  .Build';

  CODE_JOIN =
    'TQuery4DController.New(Dialect)' + sLineBreak +
    '  .From(''pedidos'', ''p'')' + sLineBreak +
    '  .Select([''p.id'', ''c.nome'', ''e.descricao''])' + sLineBreak +
    '  .BeginJoins' + sLineBreak +
    '    .InnerJoin(''clientes'', ''c'', ''c.id = p.cliente_id'')' + sLineBreak +
    '    .LeftJoin(''enderecos'', ''e'', ''e.id = p.endereco_id'')' + sLineBreak +
    '  .EndJoins' + sLineBreak +
    '  .BeginWhere' + sLineBreak +
    '    .Equal(''p.ano'', ''2024'')' + sLineBreak +
    '  .EndWhere' + sLineBreak +
    '  .Build';

  CODE_DML =
    '// INSERT' + sLineBreak +
    'TQuery4DController.New(Dialect)' + sLineBreak +
    '  .InsertInto(''pedidos'')' + sLineBreak +
    '  .BeginRow' + sLineBreak +
    '    .Value(''cliente_id'', ''42'')' + sLineBreak +
    '    .Value(''valor_total'', ''199.90'')' + sLineBreak +
    '    .Value(''status'', ''pendente'')' + sLineBreak +
    '  .Build;' + sLineBreak +
    '' + sLineBreak +
    '// UPDATE (WHERE obrigatório)' + sLineBreak +
    'TQuery4DController.New(Dialect)' + sLineBreak +
    '  .Update(''pedidos'')' + sLineBreak +
    '  .SetValue(''status'', ''aprovado'')' + sLineBreak +
    '  .WhereEq(''id'', ''42'')' + sLineBreak +
    '  .Build';

  CODE_CTE =
    '// CTE simples: top 10 clientes por valor' + sLineBreak +
    'TQuery4DController.New(Dialect)' + sLineBreak +
    '  .BeginWith' + sLineBreak +
    '    .Add(''top_clientes'',' + sLineBreak +
    '         ''SELECT cliente_id, SUM(valor) AS total '' +' + sLineBreak +
    '         ''FROM pedidos GROUP BY cliente_id'')' + sLineBreak +
    '  .EndWith' + sLineBreak +
    '  .From(''top_clientes'', ''tc'')' + sLineBreak +
    '  .Select([''tc.cliente_id'', ''tc.total''])' + sLineBreak +
    '  .OrderBy(''tc.total'', odDesc)' + sLineBreak +
    '  .Limit(10)' + sLineBreak +
    '  .Build';

{ TFormMain }

procedure TFormMain.AfterConstruction;
begin
  inherited;
  ComboDialect.Items.AddStrings(['MySQL 8', 'PostgreSQL', 'Firebird', 'SQLite']);
  ComboDialect.ItemIndex := 0;
  BtnSelectClick(nil);
end;

procedure TFormMain.UpdateDialect;
begin
  case ComboDialect.ItemIndex of
    0: QueryBuilder.Dialect := dMySQL8;
    1: QueryBuilder.Dialect := dPostgreSQL;
    2: QueryBuilder.Dialect := dFirebird;
    3: QueryBuilder.Dialect := dSQLite;
  end;
end;

procedure TFormMain.SetScenario(const ACode: string; AProc: TScenarioProc);
begin
  MemoCode.Text    := ACode;
  MemoSQL.Text     := '';
  LabelStatus.Caption := 'Pronto — clique em Executar';
  LabelStatus.Font.Color := clGray;
  FCurrentScenario := AProc;
end;

procedure TFormMain.Execute;
begin
  if not Assigned(FCurrentScenario) then Exit;
  UpdateDialect;
  FCurrentScenario(QueryBuilder.NewQuery);
end;

procedure TFormMain.ShowSuccess(const ASQL: string; const AParams: TArray<string>);
var
  ParamStr: string;
  I: Integer;
begin
  MemoSQL.Text := ASQL;
  if Length(AParams) > 0 then
  begin
    ParamStr := '';
    for I := 0 to High(AParams) do
    begin
      if I > 0 then ParamStr := ParamStr + ', ';
      ParamStr := ParamStr + '''' + AParams[I] + '''';
    end;
    MemoSQL.Lines.Add('');
    MemoSQL.Lines.Add('-- Params: [' + ParamStr + ']');
  end;
  LabelStatus.Caption    := Format('● Compilado com sucesso  |  Params: %d', [Length(AParams)]);
  LabelStatus.Font.Color := clGreen;
end;

procedure TFormMain.ShowError(const AMessage: string);
begin
  MemoSQL.Text           := '';
  LabelStatus.Caption    := '● Erro: ' + AMessage;
  LabelStatus.Font.Color := clRed;
end;

{ Cenários }

procedure TFormMain.ScenarioSelect;
var
  R: TResult<TQueryResult>;
begin
  R := QueryBuilder.NewQuery
    .From('pedidos', 'p')
    .Select(['p.id', 'p.numero', 'p.valor_total'])
    .BeginWhere
      .Equal('p.status', 'aprovado')
      .GreaterThan('p.valor_total', '100')
      .IsNotNull('p.data_entrega')
    .EndWhere
    .OrderBy('p.data_criacao', odDesc)
    .Limit(20)
    .Build;
  if R.IsOk then ShowSuccess(R.Value.SQL, R.Value.Params)
  else ShowError(R.Error.Message);
end;

procedure TFormMain.ScenarioWhere;
var
  R: TResult<TQueryResult>;
begin
  R := QueryBuilder.NewQuery
    .From('produtos', 'pr')
    .SelectAll
    .BeginWhere
      .GreaterThan('pr.preco', '10')
      .LessThanOrEqualTo('pr.preco', '500')
      .IsNotNull('pr.categoria_id')
      .Contains('pr.nome', 'Kit')
      .IsIn('pr.status', ['ativo', 'promocao'])
      .IsBetween('pr.estoque', '1', '999')
      .OrBegin
        .Equal('pr.destaque', '1')
        .Equal('pr.lancamento', '1')
      .OrEnd
    .EndWhere
    .Build;
  if R.IsOk then ShowSuccess(R.Value.SQL, R.Value.Params)
  else ShowError(R.Error.Message);
end;

procedure TFormMain.ScenarioJoin;
var
  R: TResult<TQueryResult>;
begin
  R := QueryBuilder.NewQuery
    .From('pedidos', 'p')
    .Select(['p.id', 'c.nome', 'e.descricao'])
    .BeginJoins
      .InnerJoin('clientes', 'c', 'c.id = p.cliente_id')
      .LeftJoin('enderecos', 'e', 'e.id = p.endereco_id')
    .EndJoins
    .BeginWhere
      .Equal('p.ano', '2024')
    .EndWhere
    .Build;
  if R.IsOk then ShowSuccess(R.Value.SQL, R.Value.Params)
  else ShowError(R.Error.Message);
end;

procedure TFormMain.ScenarioDML;
var
  R: TResult<TQueryResult>;
begin
  // Demonstra UPDATE (INSERT está no CODE_DML como comentário)
  R := QueryBuilder.NewQuery
    .Update('pedidos')
    .SetValue('status', 'aprovado')
    .SetValue('data_aprovacao', 'NOW()')
    .WhereEq('id', '42')
    .Build;
  if R.IsOk then ShowSuccess(R.Value.SQL, R.Value.Params)
  else ShowError(R.Error.Message);
end;

procedure TFormMain.ScenarioCTE;
var
  R: TResult<TQueryResult>;
begin
  R := QueryBuilder.NewQuery
    .BeginWith
      .Add('top_clientes',
           'SELECT cliente_id, SUM(valor) AS total FROM pedidos GROUP BY cliente_id')
    .EndWith
    .From('top_clientes', 'tc')
    .Select(['tc.cliente_id', 'tc.total'])
    .OrderBy('tc.total', odDesc)
    .Limit(10)
    .Build;
  if R.IsOk then ShowSuccess(R.Value.SQL, R.Value.Params)
  else ShowError(R.Error.Message);
end;

{ Handlers }

procedure TFormMain.BtnSelectClick(Sender: TObject);
begin
  SetScenario(CODE_SELECT,
    procedure(const Q: IQuery4DController) begin ScenarioSelect; end);
end;

procedure TFormMain.BtnWhereClick(Sender: TObject);
begin
  SetScenario(CODE_WHERE,
    procedure(const Q: IQuery4DController) begin ScenarioWhere; end);
end;

procedure TFormMain.BtnJoinClick(Sender: TObject);
begin
  SetScenario(CODE_JOIN,
    procedure(const Q: IQuery4DController) begin ScenarioJoin; end);
end;

procedure TFormMain.BtnDMLClick(Sender: TObject);
begin
  SetScenario(CODE_DML,
    procedure(const Q: IQuery4DController) begin ScenarioDML; end);
end;

procedure TFormMain.BtnCTEClick(Sender: TObject);
begin
  SetScenario(CODE_CTE,
    procedure(const Q: IQuery4DController) begin ScenarioCTE; end);
end;

procedure TFormMain.BtnExecuteClick(Sender: TObject);
begin
  Execute;
end;

procedure TFormMain.BtnClearClick(Sender: TObject);
begin
  MemoSQL.Text           := '';
  LabelStatus.Caption    := 'Pronto — clique em Executar';
  LabelStatus.Font.Color := clGray;
end;

procedure TFormMain.ComboDialectChange(Sender: TObject);
begin
  UpdateDialect;
end;

end.
