uses 'abra.eu.mask.2017.predvyplneni.funkce','EU.Aabra.Mask.Validace.lib';

procedure AfterSetFieldValue_Hook(Self: TNxCustomBusinessObject; AFieldCode: Integer; AValue: TNxParameter; AOriginalValue: TNxParameter);
var
  mCode: integer;
  mdivision: string;
  mObchodni_pripad:string;
begin
       if AFieldCode = Self.GetFieldCode('Storecard_ID') then begin
                             mObchodni_pripad:=(Self.GetFieldValueAsString('StoreCard_id.X_Obchodni_pripad'));
                             Self.SetFieldValueAsString('BusTransaction_id',mObchodni_pripad );
                             if not nxisemptyoid(Self.GetFieldValueAsString('BusOrder_ID.X_BusProject_ID')) then
                                    Self.SetFieldValueAsString('BusProject_id',Self.GetFieldValueAsString('BusOrder_ID.X_BusProject_ID'));

        end;

end;

{
Vyvolává se při předvyplňování hodnot daného objektu.
}
procedure Prefill_Hook(Self: TNxCustomBusinessObject);
begin
   Self.SetFieldValueAsString('Division_ID','~000000402');
end;

begin
end.