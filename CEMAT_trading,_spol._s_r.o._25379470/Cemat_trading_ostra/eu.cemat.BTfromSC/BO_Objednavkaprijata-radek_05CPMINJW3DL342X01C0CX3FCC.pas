{
Vyvolává se po změně každé položky. A to pouze, pokud k této změně nedochází díky načítání objektu z databáze nebo díky vytváření kopie.
}
procedure AfterSetFieldValue_Hook(Self: TNxCustomBusinessObject; AFieldCode: Integer; AValue: TNxParameter; AOriginalValue: TNxParameter);
begin
  //if AFieldCode=self.GetFieldCode('RowType') then self.SetFieldValueAsString('BusTransaction_ID','0000000000');
  if (AFieldCode=self.GetFieldCode('StoreCard_ID')) and not(AValue.AsString=AOriginalValue.AsString) {and NxIsEmptyOID(self.GetFieldValueAsString('BusTransaction_ID'))} then begin
    //if not(NxIsEmptyOID(self.GetFieldValueAsString('StoreCard_ID.U_obchodni_pripad'))) then
     self.SetFieldValueAsString('BusTransaction_ID',self.GetFieldValueAsString('StoreCard_ID.U_obchodni_pripad'));

  end;
end;



begin
end.