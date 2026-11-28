{
Vyvolává se po vyplnění hlavičky výstupního dokladu importovacím managerem
}
procedure AfterFillOptputHeader_Hook(Self: TNxDocumentImportManager);
var
 mUser:TNxCustomBusinessObject;
 mOS:TNxCustomObjectSpace;
begin
if self.InputDocumentCount>0 then begin
  mOS:=self.InputDocuments[0].ObjectSpace;
  try
   mUser:=mOS.CreateObject(Class_SecurityUser);
   mUser.Load(NxGetActualUserID(mOS),nil);
   if not(NxIsEmptyOID(muser.GetFieldValueAsString('X_RBOD_ID'))) then
    self.OutputDocument.SetFieldValueAsString('StoreDocQueue_ID',muser.GetFieldValueAsString('X_RBOD_ID')) else
    self.OutputDocument.SetFieldValueAsString('StoreDocQueue_ID','');
   mUser.free;
  except
   //CFxLog.SaveLog(NxCreateContext(Self.InputDocument.ObjectSpace), 'LOG', 'Chyba', ExceptionMessage, ltScripting, Now);
  end;
 end;
end;

begin
end.