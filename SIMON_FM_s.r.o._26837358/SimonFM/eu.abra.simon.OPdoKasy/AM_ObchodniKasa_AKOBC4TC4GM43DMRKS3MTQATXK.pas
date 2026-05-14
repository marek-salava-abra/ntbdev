{
Vyvolá se po nastavení firmy.
}
procedure AfterSetFirm_Hook(AContext: TNxContext; aDocument: TNxCustomBusinessObject);
begin
  if not(NxIsEmptyOID(aDocument.GetMonikerForFieldCode(aDocument.GetFieldCode('Firm_ID')).BusinessObject.GetFieldValueAsString('U_BusTransaction_ID'))) then
  aDocument.SetFieldValueAsString('BusTransaction_ID',aDocument.GetMonikerForFieldCode(aDocument.GetFieldCode('Firm_ID')).BusinessObject.GetFieldValueAsString('U_BusTransaction_ID'));
end;

begin
end.