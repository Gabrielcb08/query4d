unit Query4D.Container;

interface

uses
  Query4D.Controller.Interfaces,
  Query4D.View.Interfaces;

procedure RegisterQuery4D;
function ResolveDialect(const ADialectName: string): IDialectView;
function NewQuery4DController(const ADialectName: string): IQuery4DController;

implementation

uses
  System.SysUtils,
  System.Generics.Collections,
  Query4D.Shared.Exceptions,
  Query4D.View.MySQL,
  Query4D.View.PostgreSQL,
  Query4D.View.Firebird,
  Query4D.View.SQLite,
  Query4D.Controller;

type
  TDialectFactory = reference to function: IDialectView;

var
  GFactories: TDictionary<string, TDialectFactory>;
  GRegistered: Boolean = False;

function NormalizeDialectName(const ADialectName: string): string;
begin
  Result := LowerCase(Trim(ADialectName));
  if Result = 'mysql8' then
    Result := 'mysql';
  if Result = '' then
    Result := 'mysql';
end;

procedure RegisterQuery4D;
begin
  if GRegistered then
    Exit;

  GFactories.Add('mysql',      function: IDialectView begin Result := TMySQL8View.New; end);
  GFactories.Add('postgresql', function: IDialectView begin Result := TPostgreSQLView.New; end);
  GFactories.Add('firebird',   function: IDialectView begin Result := TFirebirdView.New; end);
  GFactories.Add('sqlite',     function: IDialectView begin Result := TSQLiteView.New; end);

  GRegistered := True;
end;

function ResolveDialect(const ADialectName: string): IDialectView;
var
  Key: string;
  Factory: TDialectFactory;
begin
  RegisterQuery4D;
  Key := NormalizeDialectName(ADialectName);
  if not GFactories.TryGetValue(Key, Factory) then
    raise EDialectNotSupported.CreateFmt('Dialeto "%s" nao suportado', [ADialectName]);
  Result := Factory();
end;

function NewQuery4DController(const ADialectName: string): IQuery4DController;
begin
  Result := TQuery4DController.New(ResolveDialect(ADialectName));
end;

initialization
  GFactories := TDictionary<string, TDialectFactory>.Create;

finalization
  GFactories.Free;

end.
