{
Vyvolává se před fyzickým uložením vlastních dat objektu do databáze.
}
procedure BeforeSave_Hook(Self: TNxCustomBusinessObject);
var
 mRows:TNxCustomBusinessMonikerCollection;
 i:integer;
 mBool:Boolean;
begin
  if not(CFxNxRuntime.NxGetEnvironmentType=reWebServices) then begin
  mBool:=False;
  mrows:=self.GetLoadedCollectionMonikerForFieldCode(Self.getfieldcode('Rows'));
  for i:=0 to mrows.Count-1 do begin
    if NxIsEmptyOID(mrows.BusinessObject[i].GetFieldValueAsString('BusTransaction_ID')) then mBool:=True;
  end;
  if mBool then NxShowSimpleMessage('Některý řádek nemá vyplněný obchodní případ',nil);
  end;
end;

begin
end.