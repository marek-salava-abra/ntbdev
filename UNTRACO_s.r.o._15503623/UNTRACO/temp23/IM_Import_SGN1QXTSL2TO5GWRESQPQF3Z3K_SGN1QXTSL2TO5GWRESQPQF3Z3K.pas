{
Vyvolává se po vyplnění řádků výstupního dokladu importovacím managerem
}
procedure AfterFillOptputRows_Hook(Self: TNxDocumentImportManager);
var
 mList:TStringList;
 mInputParams:TNxParameters;
 i:integer;
begin
 mList:=TStringList.Create;
 mInputParams:=TNxParameters.Create;
 self.GetParamNames(mList);
 for i:=0 to mList.Count-1 do begin
    NxShowSimpleMessage(mList.strings[i],nil);
 end;
end;

begin
end.