{
Vyvolává se bezprostředně před provedením softvalidace objektu.
}
procedure BeforeSoftValidate_Hook(Self: TNxCustomBusinessObject);
var
 mRows:TNxCustomBusinessMonikerCollection;
 i:integer;
 mBO:TNxCustomBusinessObject;
begin
 if CFxNxRuntime.NxGetEnvironmentType=reRuntimeExe then begin
  mBO:=self.GetMonikerForFieldCode(self.GetFieldCode('Parent_ID')).BusinessObject;
  mrows:=mBO.GetLoadedCollectionMonikerForFieldCode(mbo.GetFieldCode('Rows'));
  for i:=0 to mrows.count-1 do begin
    if not(self.oid=mrows.BusinessObject[i].OID) then begin
      if not(NxIsEmptyOID(self.GetFieldValueAsString('StoreCard_ID'))) then begin
       if self.GetFieldValueAsString('StoreCard_ID')=mrows.BusinessObject[i].GetFieldValueAsString('StoreCard_ID') then begin
       NxShowSimpleMessage('Duplicita položky '+self.GetFieldValueAsString('StoreCard_ID.Code')+' aktuálního řádku s řádkem '+IntToStr(mrows.BusinessObject[i].GetFieldValueAsInteger('PosIndex')),nil);
       end;
      end;
    end;
  end;
 end;
end;

begin
end.