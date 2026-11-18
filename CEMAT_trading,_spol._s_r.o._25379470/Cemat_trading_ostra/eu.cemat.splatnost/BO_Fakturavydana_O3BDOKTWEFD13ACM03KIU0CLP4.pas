{
Vyvolává se po změně každé položky. A to pouze, pokud k této změně nedochází díky načítání objektu z databáze nebo díky vytváření kopie.
}
procedure AfterSetFieldValue_Hook(Self: TNxCustomBusinessObject; AFieldCode: Integer; AValue: TNxParameter; AOriginalValue: TNxParameter);
begin
  if ((AFieldCode=self.GetFieldCode('FirmOFfice_ID')) or (AFieldCode=self.GetFieldCode('DocDate$Date'))) and (self.GetFieldValueAsInteger('FirmOffice_ID.U_Splatnost')>0) then begin
    self.SetFieldValueAsDateTime('DueDate$Date',self.GetFieldValueAsDateTime('DocDate$Date')+self.GetFieldValueAsInteger('FirmOffice_ID.U_Splatnost'));

  end;
end;

begin
end.