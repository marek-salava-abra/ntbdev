uses 'EU.Aabra.Mask.Validace.lib';
var
mdivision: string;



{
Vyvolává se bezprostředně po provedení softvalidace objektu.
}
procedure AfterSoftValidate_Hook(Self: TNxCustomBusinessObject);
begin
        if Self.GetFieldValueAsInteger('Rowtype')=3 then begin
              if NxIsEmptyOID(Self.GetFieldValueAsString('Division_id')) then begin
                  mdivision:=(Self.GetFieldValueAsString('Store_id.X_BusDivision_ID'));
                  Self.SetFieldValueAsString('Division_id',mdivision );
              end;
         end;
end;



procedure Prefill_Hook(Self: TNxCustomBusinessObject);
begin
Self.SetFieldValueAsString('Division_id','1000000101' );
end;

begin
end.
