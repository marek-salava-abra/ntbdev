function Loopback(Self:TNxWebServicesHelper;x:String) : String;
begin
  Result:=x;
end;

function QueryTableCsv(
        Self:TNxWebServicesHelper;
        tableName:String;
        columnNames: TStringDynArray)
        : TStringDynArray;
var
    query, columnPart: string;
    columnName: string;
    i: integer;
    res: TStringDynArray;
begin

     if (not IsInjectionSafe(tableName)) then begin
        RaiseException('Table name [' + tableName + '] is not injection-safe.');
        exit;
     end;
  
     if (Length(columnNames) = 0) then columnPart := '*'
     else begin
       columnPart := '';
       for i:= 0 to Length(columnNames) - 1 do begin
         columnName := columnNames[i];
         if (not IsInjectionSafe(columnName)) then begin
                RaiseException('Column name [' + columnName + '] is not injection-safe.');
                exit;
         end;
         if (i = 0) then columnPart := columnName
         else columnPart := columnPart + ', ' + columnName;
       end;
     end;
   
     query := 'SELECT ' + columnPart + ' FROM ' + tableName;
   
     res := SqlSelectCsvInternal(Self, query);
     Result := res;
end;

function SqlSelectCsv(
        Self:TNxWebServicesHelper;
        query:String)
        : TStringDynArray;
begin
  Result := SqlSelectCsvInternal(Self, query);
end;


{Utilities}

function SqlSelectCsvInternal(
        Self:TNxWebServicesHelper;
        query:String)
        : TStringDynArray;
var
  strings: TStringList;
  res: array of String;
  i: Integer;
begin
  strings := TStringList.Create;

  try
        Self.Context.SQLSelect(query, strings);
        
        SetLength(res, strings.Count);
        for i := 0 to strings.Count - 1 do res[i] := strings[i];

        Result := res;
  finally
       strings.Free;
  end;
end;


function IsInjectionSafe(str: String) : Boolean;
var i: integer; ch: Char; res: Boolean;
begin
  res := True;

  for i:= 1 to Length(str) do begin
     ch := str[i];
     if NOT (
     (ch in ['A'..'Z']) OR
     (ch in ['a'..'z']) OR
     (ch in ['0'..'9']) OR
     (ch = '_'))
     then begin
        res := false;
        break;
     end;
  end;

  Result := res;

end;




begin
end.