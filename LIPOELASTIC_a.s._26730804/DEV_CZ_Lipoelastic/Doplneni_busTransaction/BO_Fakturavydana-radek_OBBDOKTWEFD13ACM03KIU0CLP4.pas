uses 'EU.Aabra.Mask.Validace.lib';
procedure AfterSetFieldValue_Hook(Self: TNxCustomBusinessObject; AFieldCode: Integer; AValue: TNxParameter; AOriginalValue: TNxParameter);

begin

end;



{
Vyvolává se bezprostředně po provedení softvalidace objektu.
}
procedure AfterSoftValidate_Hook(Self: TNxCustomBusinessObject);
var
  mCode: integer;
  mObchodni_pripad: string;
begin
        if Self.GetFieldValueAsInteger('Rowtype')=3 then begin
            if NxIsEmptyOID(Self.GetFieldValueAsString('BusTransaction_id')) then begin
                             mObchodni_pripad:=(Self.GetMonikerForFieldCode(Self.GetFieldCode('StoreCard_id')).BusinessObject.GetFieldValueAsString('X_Obchodni_pripad'));
                             Self.SetFieldValueAsString('BusTransaction_id',mObchodni_pripad );
            end;
        end;
end;

begin
end.
