

{
Vyvolává se bezprostředně před provedením softvalidace objektu.
}
procedure BeforeSoftValidate_Hook(Self: TNxCustomBusinessObject);
begin
  if not(NxIsEmptyOID(self.GetFieldValueAsString('StoreCard_ID'))) then begin
    if AnsiRightStr(self.GetFieldValueAsString('StoreCard_id.code'),3)='DOP' then NxShowSimpleMessage('Toto je karta doprodeje neobjednávat',nil);

  end;
end;

begin
end.