unit Query4D.Register;

{$R Query4D.dcr}

interface

uses
  System.Classes,
  Query4D.Controller.Interfaces;

type
  TQuery4DDialect = (dMySQL8, dPostgreSQL, dFirebird, dSQLite);

  /// <summary>
  ///   Componente n&#227;o-visual que expõe a API fluente do Query4D
  ///   diretamente no Form Designer do Delphi.
  ///   Solte no form, configure Dialect e chame NewQuery no código.
  /// </summary>
  TQuery4D = class(TComponent)
  private
    FDialect: TQuery4DDialect;
    function DialectName: string;
  public
    constructor Create(AOwner: TComponent); override;
    /// <summary>
    ///   Cria e retorna um novo controller pronto para construção de queries,
    ///   usando o dialeto configurado na propriedade Dialect.
    /// </summary>
    function NewQuery: IQuery4DController;
  published
    /// <summary>
    ///   Banco de dados alvo. Altera o dialeto de renderização SQL
    ///   automaticamente. Padrão: MySQL 8.
    /// </summary>
    property Dialect: TQuery4DDialect
      read  FDialect
      write FDialect
      default dMySQL8;
  end;

procedure Register;

implementation

uses
  Query4D.Container;

{ TQuery4D }

constructor TQuery4D.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FDialect := dMySQL8;
end;

function TQuery4D.DialectName: string;
begin
  case FDialect of
    dMySQL8:     Result := 'mysql';
    dPostgreSQL: Result := 'postgresql';
    dFirebird:   Result := 'firebird';
    dSQLite:     Result := 'sqlite';
  else
    Result := 'mysql';
  end;
end;

function TQuery4D.NewQuery: IQuery4DController;
begin
  Result := NewQuery4DController(DialectName);
end;

procedure Register;
begin
  RegisterQuery4D;
  RegisterComponents('ORData', [TQuery4D]);
end;

end.
