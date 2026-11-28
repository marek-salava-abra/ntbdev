{
Vyvolává se po změně každé položky. A to pouze, pokud k této změně nedochází díky načítání objektu z databáze nebo díky vytváření kopie.
}
procedure AfterSetFieldValue_Hook(Self: TNxCustomBusinessObject; AFieldCode: Integer; AValue: TNxParameter; AOriginalValue: TNxParameter);
begin
 if osNew in self.state then begin
  if (AFieldCode=self.GetFieldCode('X_PayByCard')) and not(AValue.AsBoolean=AOriginalValue.AsBoolean) then begin
    if self.GetFieldValueAsBoolean('X_PayByCard') then self.SetFieldValueAsInteger('TotalRounding',-33554175);
    if not(self.GetFieldValueAsBoolean('X_PayByCard')) then self.SetFieldValueAsInteger('TotalRounding',257);
  end;
 end;
end;

begin
end.