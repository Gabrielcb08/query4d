unit Query4D.Shared.Result;

interface

uses
  System.SysUtils;

type
  TResultError = record
    Code: string;
    Message: string;
    class function New(const AMessage: string; const ACode: string = ''): TResultError; static;
  end;

  TResult<T> = record
  private
    FValue: T;
    FError: TResultError;
    FHasError: Boolean;
    FIsOk: Boolean;
  public
    class function Ok(const AValue: T): TResult<T>; static;
    class function Fail(const AMessage: string; const ACode: string = ''): TResult<T>; static;

    function IsOk: Boolean;
    function IsFail: Boolean;

    procedure OnSuccess(const Action: TProc<T>);
    procedure OnFailure(const Action: TProc<TResultError>);

    property Value: T read FValue;
    property Error: TResultError read FError;
  end;

implementation

{ TResultError }

class function TResultError.New(const AMessage, ACode: string): TResultError;
begin
  Result.Message := AMessage;
  Result.Code    := ACode;
end;

{ TResult<T> }

class function TResult<T>.Ok(const AValue: T): TResult<T>;
begin
  Result.FValue    := AValue;
  Result.FIsOk     := True;
  Result.FHasError := False;
end;

class function TResult<T>.Fail(const AMessage, ACode: string): TResult<T>;
begin
  Result.FError    := TResultError.New(AMessage, ACode);
  Result.FIsOk     := False;
  Result.FHasError := True;
end;

function TResult<T>.IsOk: Boolean;
begin
  Result := FIsOk;
end;

function TResult<T>.IsFail: Boolean;
begin
  Result := not FIsOk;
end;

procedure TResult<T>.OnSuccess(const Action: TProc<T>);
begin
  if FIsOk then
    Action(FValue);
end;

procedure TResult<T>.OnFailure(const Action: TProc<TResultError>);
begin
  if not FIsOk then
    Action(FError);
end;

end.
