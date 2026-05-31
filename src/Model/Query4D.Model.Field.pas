unit Query4D.Model.Field;

interface

uses
  System.Generics.Collections,
  Query4D.Shared.Guard;

type
  TFieldModel = class
  private
    FExpression: string;
    FAlias: string;
  public
    constructor Create(const AExpression: string; const AAlias: string = '');
    function HasAlias: Boolean;
    property Expression: string read FExpression;
    property Alias: string read FAlias;
  end;

  TFieldListModel = class
  private
    FItems: TObjectList<TFieldModel>;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Add(const AExpression: string); overload;
    procedure AddAs(const AExpression, AAlias: string); overload;
    function Count: Integer;
    function IsEmpty: Boolean;
    function Item(const AIndex: Integer): TFieldModel;
    procedure Clear;
  end;

implementation

uses
  System.SysUtils;

{ TFieldModel }

constructor TFieldModel.Create(const AExpression, AAlias: string);
begin
  TGuard.IsNotEmpty(AExpression, 'Field.Expression');
  inherited Create;
  FExpression := Trim(AExpression);
  FAlias      := Trim(AAlias);
end;

function TFieldModel.HasAlias: Boolean;
begin
  Result := FAlias <> '';
end;

{ TFieldListModel }

constructor TFieldListModel.Create;
begin
  inherited Create;
  FItems := TObjectList<TFieldModel>.Create(True);
end;

destructor TFieldListModel.Destroy;
begin
  FItems.Free;
  inherited;
end;

procedure TFieldListModel.Add(const AExpression: string);
begin
  FItems.Add(TFieldModel.Create(AExpression));
end;

procedure TFieldListModel.AddAs(const AExpression, AAlias: string);
begin
  FItems.Add(TFieldModel.Create(AExpression, AAlias));
end;

function TFieldListModel.Count: Integer;
begin
  Result := FItems.Count;
end;

function TFieldListModel.IsEmpty: Boolean;
begin
  Result := FItems.Count = 0;
end;

function TFieldListModel.Item(const AIndex: Integer): TFieldModel;
begin
  Result := FItems[AIndex];
end;

procedure TFieldListModel.Clear;
begin
  FItems.Clear;
end;

end.
