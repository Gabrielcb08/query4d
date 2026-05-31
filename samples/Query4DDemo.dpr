program Query4DDemo;

uses
  Vcl.Forms,
  Query4D.Container,
  Form.Main in 'Forms\Form.Main.pas' {FormMain};

{$R *.res}

begin
  RegisterQuery4D;
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'Query4D Demo';
  Application.CreateForm(TFormMain, FormMain);
  Application.Run;
end.
