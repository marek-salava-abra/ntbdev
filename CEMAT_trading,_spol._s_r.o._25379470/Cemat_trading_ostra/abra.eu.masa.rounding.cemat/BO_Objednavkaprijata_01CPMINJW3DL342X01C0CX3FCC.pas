{
Vyvolává se po změně každé položky. A to pouze, pokud k této změně nedochází díky načítání objektu z databáze nebo díky vytváření kopie.
}
procedure AfterSetFieldValue_Hook(Self: TNxCustomBusinessObject; AFieldCode: Integer; AValue: TNxParameter; AOriginalValue: TNxParameter);
begin
  if AFieldCode=Self.getfieldcode('Currency_id') then begin
        if self.GetFieldValueAsString('Currency_id')='0000CZK000' then self.SetFieldValueAsInteger('VatRounding',0);
        if self.GetFieldValueAsString('Currency_id')='0000CZK000' then self.SetFieldValueAsInteger('TotalRounding',257);
        if self.GetFieldValueAsString('Currency_id')='0000EUR000' then self.SetFieldValueAsInteger('VatRounding',0);
        if self.GetFieldValueAsString('Currency_id')='0000EUR000' then self.SetFieldValueAsInteger('TotalRounding',0);
  
  end;
end;

begin
end.