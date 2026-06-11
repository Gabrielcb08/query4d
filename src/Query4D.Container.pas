unit Query4D.Container;

interface

uses
  Query4D.Controller.Interfaces,
  Query4D.View.Interfaces;

type
  TQuery4DContainer = class
  private
    class var FRegistered: Boolean;
  public
    class procedure RegisterServices;
  end;

procedure RegisterQuery4D;
function ResolveDialect(const ADialectName: string): IDialectView;
function NewQuery4DController(const ADialectName: string): IQuery4DController;

implementation

uses
  System.SysUtils,
  Spring.Container,
  Query4D.Shared.Exceptions,
  Query4D.View.MySQL,
  Query4D.View.PostgreSQL,
  Query4D.View.Firebird,
  Query4D.View.SQLite,
  Query4D.Controller;

function NormalizeDialectName(const ADialectName: string): string;
begin
  Result := LowerCase(Trim(ADialectName));
  if Result = 'mysql8' then
    Result := 'mysql';
  if Result = '' then
    Result := 'mysql';
end;

class procedure TQuery4DContainer.RegisterServices;
begin
  if FRegistered then
    Exit;

  GlobalContainer.RegisterType<TMySQL8View>    .Implements<IDialectView>('mysql')      .AsSingleton;
  GlobalContainer.RegisterType<TPostgreSQLView>.Implements<IDialectView>('postgresql') .AsSingleton;
  GlobalContainer.RegisterType<TFirebirdView>  .Implements<IDialectView>('firebird')   .AsSingleton;
  GlobalContainer.RegisterType<TSQLiteView>    .Implements<IDialectView>('sqlite')     .AsSingleton;

  GlobalContainer.Build;
  FRegistered := True;
end;

procedure RegisterQuery4D;
begin
  TQuery4DContainer.RegisterServices;
end;

function ResolveDialect(const ADialectName: string): IDialectView;
begin
  TQuery4DContainer.RegisterServices;
  try
    Result := GlobalContainer.Resolve<IDialectView>(NormalizeDialectName(ADialectName));
  except
    raise EDialectNotSupported.CreateFmt('Dialeto "%s" nao suportado', [ADialectName]);
  end;
end;

function NewQuery4DController(const ADialectName: string): IQuery4DController;
begin
  Result := TQuery4DController.New(ResolveDialect(ADialectName));
end;

end.
