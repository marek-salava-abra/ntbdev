{
Vyvolává se po změně každé položky. A to pouze, pokud k této změně nedochází díky načítání objektu z databáze nebo díky vytváření kopie.
}
procedure AfterSetFieldValue_Hook(Self: TNxCustomBusinessObject; AFieldCode: Integer; AValue: TNxParameter; AOriginalValue: TNxParameter);
begin
  if self.GetFieldValueAsBoolean('Parent_ID.U_prenos') then begin
   if AFieldCode=self.GetFieldCode('BusOrder_ID') then begin
    self.SetFieldValueAsString('X_BusOrder_ID',self.GetFieldValueAsString('BusOrder_ID'));
   end;
  end;
end;

begin
end.