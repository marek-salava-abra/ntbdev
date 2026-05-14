uses 'abra.eu.mask.2017.predvyplneni.funkce', 'EU.Aabra.Mask.Validace.lib';

procedure AfterSetFieldValue_Hook(Self: TNxCustomBusinessObject; AFieldCode: Integer; AValue: TNxParameter; AOriginalValue: TNxParameter);
var
  mCode: integer;
  mdivision: string;
begin
         if AFieldCode = Self.GetFieldCode('CreditBusOrder_ID') then begin
               if not nxisemptyoid(Self.GetFieldValueAsString('CreditBusOrder_ID.X_BusProject_ID')) then
               Self.SetFieldValueAsString('CreditBusProject_id',Self.GetFieldValueAsString('CreditBusOrder_ID.X_BusProject_ID'));
         end;
         if AFieldCode = Self.GetFieldCode('DebitBusOrder_ID') then begin
               if not nxisemptyoid(Self.GetFieldValueAsString('DebitBusOrder_ID.X_BusProject_ID')) then
               Self.SetFieldValueAsString('DebitBusProject_id',Self.GetFieldValueAsString('DebitBusOrder_ID.X_BusProject_ID'));
         end;

         if AFieldCode = Self.GetFieldCode('CreditBusProject_ID') then begin
               if not nxisemptyoid(Self.GetFieldValueAsString('CreditBusProject_ID.Division_ID')) then
               Self.SetFieldValueAsString('CreditDivision_ID',Self.GetFieldValueAsString('CreditBusProject_ID.Division_ID'));
         end;

         if AFieldCode = Self.GetFieldCode('DebitBusProject_ID') then begin
               if not nxisemptyoid(Self.GetFieldValueAsString('DebitBusProject_ID.Division_ID')) then
               Self.SetFieldValueAsString('DebitDivision_ID',Self.GetFieldValueAsString('DebitBusProject_ID.Division_ID'));
         end;

end;


{
Vyvolává se při předvyplňování hodnot daného objektu.
}
procedure Prefill_Hook(Self: TNxCustomBusinessObject);
begin
   Self.SetFieldValueAsString('CreditDivision_ID','1N00000101');
   Self.SetFieldValueAsString('DebitDivision_ID','1N00000101');
end;

begin
end.