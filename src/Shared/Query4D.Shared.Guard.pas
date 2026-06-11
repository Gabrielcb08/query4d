unit Query4D.Shared.Guard;

interface

uses
  System.SysUtils,
  Query4D.Shared.Exceptions;

type
  TGuard = class
  public
    class procedure IsNotNil(const Instance: TObject; const ContextName: string); overload;
    class procedure IsNotNil(const Intf: IInterface; const ContextName: string); overload;
    class procedure IsNotEmpty(const Value: string; const ContextName: string);
    class procedure IsPositive(const Value: Integer; const ContextName: string);
    class procedure IsTrue(const Condition: Boolean; const Message: string);
    class procedure IsValidIdentifier(const Value: string; const ContextName: string);
  end;

implementation

uses
  System.RegularExpressions;

{ TGuard }

class procedure TGuard.IsNotNil(const Instance: TObject; const ContextName: string);
begin
  if not Assigned(Instance) then
    raise EGuardViolation.CreateFmt('[Guard] %s nao pode ser nil', [ContextName]);
end;

class procedure TGuard.IsNotNil(const Intf: IInterface; const ContextName: string);
begin
  if not Assigned(Intf) then
    raise EGuardViolation.CreateFmt('[Guard] %s nao pode ser nil', [ContextName]);
end;

class procedure TGuard.IsNotEmpty(const Value, ContextName: string);
begin
  if Trim(Value) = '' then
    raise EInvalidQuery.CreateFmt('[Guard] %s nao pode ser vazio', [ContextName]);
end;

class procedure TGuard.IsPositive(const Value: Integer; const ContextName: string);
begin
  if Value <= 0 then
    raise EInvalidQuery.CreateFmt('[Guard] %s deve ser positivo (recebido: %d)', [ContextName, Value]);
end;

class procedure TGuard.IsTrue(const Condition: Boolean; const Message: string);
begin
  if not Condition then
    raise EInvalidQuery.Create(Message);
end;

class procedure TGuard.IsValidIdentifier(const Value, ContextName: string);
begin
  if not TRegEx.IsMatch(Value, '^[a-zA-Z_][a-zA-Z0-9_]*$') then
    raise EInvalidAlias.CreateFmt(
      '[Guard] %s contem caracteres invalidos: "%s"', [ContextName, Value]);
end;

end.
