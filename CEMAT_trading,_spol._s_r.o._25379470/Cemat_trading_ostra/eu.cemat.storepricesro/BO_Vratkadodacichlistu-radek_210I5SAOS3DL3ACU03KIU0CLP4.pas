
{
Vyvolává se bezprostředně před provedením softvalidace objektu.
}
procedure BeforeSoftValidate_Hook(Self: TNxCustomBusinessObject);
begin
  if not(NxIsEmptyOID(self.GetFieldValueAsString('SToreCard_ID'))) and (self.GetFieldValueAsFloat('X_UnitPrice_SRO')=0) then begin
     //NxShowSimpleMessage('jsem tu',nil);
     self.SetFieldValueAsFloat('X_UnitPrice_SRO', self.GetFieldValueAsFloat('StoreCard_ID.X_Price'));


  end;
end;

begin
end.