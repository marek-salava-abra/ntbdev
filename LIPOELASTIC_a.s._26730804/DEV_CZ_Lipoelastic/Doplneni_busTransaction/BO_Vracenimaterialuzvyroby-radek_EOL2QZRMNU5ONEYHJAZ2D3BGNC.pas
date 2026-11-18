uses 'EU.Aabra.Mask.Validace.lib';
{
Vyvolává se bezprostředně po provedení softvalidace objektu.
}
procedure AfterSoftValidate_Hook(Self: TNxCustomBusinessObject);
var
  mCode: integer;
  mObchodni_pripad: string;
begin
  if NxIsEmptyOID(Self.GetFieldValueAsString('BusTransaction_id')) then begin
   mObchodni_pripad:=Self.GetFieldValueAsString('StoreCard_ID.X_Obchodni_pripad');
   Self.SetFieldValueAsString('BusTransaction_id',mObchodni_pripad );
  end;

end;

begin
end.
