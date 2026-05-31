unit Query4D.Shared.Escaper;

interface

type
  TSQLEscaper = class
  public
    class function EscapeString(const Value: string): string;
    class function IsReservedWord(const Word: string): Boolean;
  end;

implementation

uses
  System.SysUtils;

const
  ReservedWords: array[0..81] of string = (
    'SELECT','FROM','WHERE','AND','OR','NOT','IN','IS','NULL','AS',
    'JOIN','INNER','LEFT','RIGHT','FULL','OUTER','CROSS','ON',
    'GROUP','BY','ORDER','HAVING','DISTINCT','ALL','UNION',
    'INSERT','INTO','VALUES','UPDATE','SET','DELETE',
    'CREATE','DROP','ALTER','TABLE','INDEX','VIEW',
    'WITH','RECURSIVE',
    'LIMIT','OFFSET','FIRST','SKIP','TOP',
    'ASC','DESC','NULLS','LAST',
    'BETWEEN','LIKE','ILIKE','EXISTS','ANY','SOME',
    'CASE','WHEN','THEN','ELSE','END',
    'CAST','COALESCE','NULLIF',
    'COUNT','SUM','AVG','MIN','MAX',
    'PRIMARY','KEY','FOREIGN','REFERENCES','UNIQUE','CHECK',
    'DEFAULT','CONSTRAINT',
    'TRANSACTION','BEGIN','COMMIT','ROLLBACK',
    'RETURNING','EXECUTE','BLOCK'
  );

class function TSQLEscaper.EscapeString(const Value: string): string;
begin
  Result := StringReplace(Value, '''', '''''', [rfReplaceAll]);
end;

class function TSQLEscaper.IsReservedWord(const Word: string): Boolean;
var
  Upper: string;
  I: Integer;
begin
  Upper := UpperCase(Trim(Word));
  for I := Low(ReservedWords) to High(ReservedWords) do
    if ReservedWords[I] = Upper then
      Exit(True);
  Result := False;
end;

end.
