{
Vyvolává se po změně každé položky. A to pouze, pokud k této změně nedochází díky načítání objektu z databáze nebo díky vytváření kopie.
}
procedure AfterSetFieldValue_Hook(Self: TNxCustomBusinessObject; AFieldCode: Integer; AValue: TNxParameter; AOriginalValue: TNxParameter);
begin
  //if (AFieldCode=self.GetFieldCode('U_datum_fakturace')) and (self.GetFieldValueAsDateTime('U_datum_fakturace')>0)
  // then self.SetFieldValueAsInteger('U_stav',2);
end;

begin
end.