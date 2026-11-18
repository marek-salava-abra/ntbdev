{
Vyvolává se po změně každé položky. A to pouze, pokud k této změně nedochází díky načítání objektu z databáze nebo díky vytváření kopie.
}
procedure AfterSetFieldValue_Hook(Self: TNxCustomBusinessObject; AFieldCode: Integer; AValue: TNxParameter; AOriginalValue: TNxParameter);
begin
  if (AFieldCode=self.getfieldcode('DocQueue_ID')) and (self.GetFieldValueAsString('DocQueue_ID.Code')='FVJ') then begin
    self.SetFieldValueAsBoolean('VatDocument',False);

  end;
end;

begin
end.