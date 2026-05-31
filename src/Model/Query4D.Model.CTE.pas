unit Query4D.Model.CTE;

interface

uses
  System.Generics.Collections,
  Query4D.Shared.Guard;

type
  TCTEModel = class
  private
    FName: string;
    FQuery: string;
    FRecursive: Boolean;
    FRecursiveAnchor: string;
    FRecursiveMember: string;
  public
    constructor CreateSimple(const AName, AQuery: string);
    constructor CreateRecursive(
      const AName, AAnchorQuery, ARecursiveMember: string);
    function IsRecursive: Boolean;
    property Name: string read FName;
    property Query: string read FQuery;
    property RecursiveAnchor: string read FRecursiveAnchor;
    property RecursiveMember: string read FRecursiveMember;
  end;

  TCTEListModel = class
  private
    FItems: TObjectList<TCTEModel>;
  public
    constructor Create;
    destructor Destroy; override;
    procedure AddSimple(const AName, AQuery: string);
    procedure AddRecursive(
      const AName, AAnchorQuery, ARecursiveMember: string);
    function Count: Integer;
    function IsEmpty: Boolean;
    function Item(const AIndex: Integer): TCTEModel;
    function HasRecursive: Boolean;
  end;

implementation

uses
  System.SysUtils;

{ TCTEModel }

constructor TCTEModel.CreateSimple(const AName, AQuery: string);
begin
  TGuard.IsNotEmpty(AName,  'CTE.Name');
  TGuard.IsNotEmpty(AQuery, 'CTE.Query');
  inherited Create;
  FName      := Trim(AName);
  FQuery     := Trim(AQuery);
  FRecursive := False;
end;

constructor TCTEModel.CreateRecursive(
  const AName, AAnchorQuery, ARecursiveMember: string);
begin
  TGuard.IsNotEmpty(AName,          'CTE.Name');
  TGuard.IsNotEmpty(AAnchorQuery,   'CTE.AnchorQuery');
  TGuard.IsNotEmpty(ARecursiveMember, 'CTE.RecursiveMember');
  inherited Create;
  FName            := Trim(AName);
  FRecursiveAnchor := Trim(AAnchorQuery);
  FRecursiveMember := Trim(ARecursiveMember);
  FRecursive       := True;
end;

function TCTEModel.IsRecursive: Boolean;
begin
  Result := FRecursive;
end;

{ TCTEListModel }

constructor TCTEListModel.Create;
begin
  inherited Create;
  FItems := TObjectList<TCTEModel>.Create(True);
end;

destructor TCTEListModel.Destroy;
begin
  FItems.Free;
  inherited;
end;

procedure TCTEListModel.AddSimple(const AName, AQuery: string);
begin
  FItems.Add(TCTEModel.CreateSimple(AName, AQuery));
end;

procedure TCTEListModel.AddRecursive(
  const AName, AAnchorQuery, ARecursiveMember: string);
begin
  FItems.Add(TCTEModel.CreateRecursive(AName, AAnchorQuery, ARecursiveMember));
end;

function TCTEListModel.Count: Integer;
begin
  Result := FItems.Count;
end;

function TCTEListModel.IsEmpty: Boolean;
begin
  Result := FItems.Count = 0;
end;

function TCTEListModel.Item(const AIndex: Integer): TCTEModel;
begin
  Result := FItems[AIndex];
end;

function TCTEListModel.HasRecursive: Boolean;
var
  I: Integer;
begin
  for I := 0 to FItems.Count - 1 do
    if FItems[I].IsRecursive then
      Exit(True);
  Result := False;
end;

end.
