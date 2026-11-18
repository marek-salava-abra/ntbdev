uses 'EU.Aabra.Mask.Validace.lib';
{
Vyvolává se bezprostředně před provedením softvalidace objektu.
}
procedure BeforeSoftValidate_Hook(Self: TNxCustomBusinessObject);
var
  mdivision: string;
begin
          if NxIsEmptyOID(Self.GetFieldValueAsString('Division_id')) then begin
                  mdivision:=(Self.GetFieldValueAsString('Store_id.X_BusDivision_ID'));
                  Self.SetFieldValueAsString('Division_id',mdivision );
          end;

 end;


procedure Prefill_Hook(Self: TNxCustomBusinessObject);
begin
//Self.SetFieldValueAsString('Division_id','1000000101' );
end;

begin
end.
