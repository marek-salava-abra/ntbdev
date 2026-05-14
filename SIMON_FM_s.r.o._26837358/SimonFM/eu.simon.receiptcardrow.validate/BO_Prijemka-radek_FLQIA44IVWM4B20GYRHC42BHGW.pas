{
Vyvolává se bezprostředně po provedení softvalidace objektu.
}
procedure AfterSoftValidate_Hook(Self: TNxCustomBusinessObject);
begin
  if (NxLeft(self.GetFieldValueAsString('StoreCard_ID.code'),3)='KK0') and not(self.GetFieldValueAsString('Store_ID')='1I00000101') then
   NxShowSimpleMessage('Pozor, naskladnění KK0x mimo sklad 09',nil);
end;

begin
end.