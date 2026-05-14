

{
Vyvolává se po změně každé položky. A to pouze, pokud k této změně nedochází díky načítání objektu z databáze nebo díky vytváření kopie.
}
procedure AfterSetFieldValue_Hook(Self: TNxCustomBusinessObject; AFieldCode: Integer; AValue: TNxParameter; AOriginalValue: TNxParameter);

begin
  if AFieldCode=self.GetFieldCode('StoreCard_ID') then begin

   //if self.GetFieldValueAsString('Storecard_ID')='1FO0000101' then self.SetFieldValueAsString('Division_ID','4100000101');
   //if self.GetFieldValueAsString('Storecard_ID')='1MZ1000101' then self.SetFieldValueAsString('Division_ID','4100000101');
   self.SetFieldValueAsString('BusTransaction_ID',
    self.GetMonikerForFieldCode(self.GetFieldCode('Parent_ID')).BusinessObject.GetMonikerForFieldCode(self.GetMonikerForFieldCode(self.GetFieldCode('Parent_ID')).BusinessObject.GetFieldCode('Firm_id')).BusinessObject.GetFieldValueAsString('U_BusTransaction_ID')
    );
   end;
end;




begin
end.