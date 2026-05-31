program Query4DTests;

uses
  Vcl.Forms,
  System.SysUtils,
  System.Classes,
  Winapi.Windows,
  DUnitX.TestFramework,
  DUnitX.TestRunner,
  DUnitX.Extensibility,
  DUnitX.Loggers.Console,
  Query4D.Tests.Shared    in 'Query4D.Tests.Shared.pas',
  Query4D.Tests.Model     in 'Query4D.Tests.Model.pas',
  Query4D.Tests.Controller in 'Query4D.Tests.Controller.pas',
  Query4D.Tests.Dialects  in 'Query4D.Tests.Dialects.pas',
  Query4D.Tests.UI.VisualLogger in 'UI\Query4D.Tests.UI.VisualLogger.pas',
  Query4D.Tests.UI.MainForm in 'UI\Query4D.Tests.UI.MainForm.pas' {frmTestRunner};

{$R *.res}

function HasSwitch(const ASwitch: string): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 1 to ParamCount do
    if SameText(ParamStr(I), ASwitch) then
      Exit(True);
end;

procedure EnsureConsoleInitialized;
begin
  if not AttachConsole(ATTACH_PARENT_PROCESS) then
    AllocConsole;

  {$I-}
  AssignFile(Input, '');
  Reset(Input);
  AssignFile(Output, '');
  Rewrite(Output);
  AssignFile(ErrOutput, '');
  Rewrite(ErrOutput);
  {$I+}
end;

procedure RunConsoleTests;
var
  Runner: ITestRunner;
  Results: IRunResults;
  Logger: ITestLogger;
begin
  EnsureConsoleInitialized;

  Writeln('Query4D - Test Suite (Console Mode)');
  Writeln('');

  Runner := TDUnitX.CreateRunner;
  Runner.UseRTTI := True;
  Logger := TDUnitXConsoleLogger.Create(False);
  Runner.AddLogger(Logger);

  try
    Results := Runner.Execute;

    if Results.AllPassed then
    begin
      Writeln(Format('Success: %d tests passed', [Results.TestCount]));
      ExitCode := 0;
    end
    else
    begin
      Writeln(Format('FAILED: %d passed, %d failed, %d errors', [Results.PassCount, Results.FailureCount, Results.ErrorCount]));
      ExitCode := 1;
    end;
  except
    on E: Exception do
    begin
      Writeln('ERROR: ' + E.Message);
      ExitCode := 1;
    end;
  end;

  if HasSwitch('--pause') then
  begin
    Writeln('');
    Writeln('Done... Press <Enter> to close.');
    Readln;
  end;
end;

begin
  ReportMemoryLeaksOnShutdown := HasSwitch('--console') and HasSwitch('--leaks');

  if HasSwitch('--console') then
  begin
    RunConsoleTests;
    Exit;
  end;

  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'Query4D - Test Runner';
  Application.CreateForm(TfrmTestRunner, frmTestRunner);
  Application.Run;
end.
