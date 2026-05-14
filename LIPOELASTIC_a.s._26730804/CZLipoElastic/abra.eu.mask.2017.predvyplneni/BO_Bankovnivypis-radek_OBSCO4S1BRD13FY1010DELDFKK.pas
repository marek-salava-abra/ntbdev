uses 'abra.eu.mask.2017.predvyplneni.funkce', 'EU.Aabra.Mask.Validace.lib';
procedure AfterSetFieldValue_Hook(Self: TNxCustomBusinessObject; AFieldCode: Integer; AValue: TNxParameter; AOriginalValue: TNxParameter);
var
  mCode: integer;
  mdivision: string;
begin
         if AFieldCode = Self.GetFieldCode('BusOrder_id') then begin
               if not nxisemptyoid(Self.GetFieldValueAsString('BusOrder_ID.X_BusProject_ID')) then
               Self.SetFieldValueAsString('BusProject_id',Self.GetFieldValueAsString('BusOrder_ID.X_BusProject_ID'));
         end;

         if AFieldCode = Self.GetFieldCode('BusProject_ID') then begin
               if not nxisemptyoid(Self.GetFieldValueAsString('BusProject_ID.Division_ID')) then
               Self.SetFieldValueAsString('Division_id',Self.GetFieldValueAsString('BusProject_ID.Division_ID'));
         end;

end;


{
Vyvolává se při předvyplňování hodnot daného objektu.
}
procedure Prefill_Hook(Self: TNxCustomBusinessObject);
begin
   Self.SetFieldValueAsString('Division_ID','1N00000101');
end;

begin
end.