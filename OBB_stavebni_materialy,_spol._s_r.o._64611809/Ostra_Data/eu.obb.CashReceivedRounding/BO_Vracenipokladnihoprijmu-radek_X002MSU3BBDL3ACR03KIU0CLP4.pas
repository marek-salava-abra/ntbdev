

{
Vyvolává se po změně každé položky. A to pouze, pokud k této změně nedochází díky načítání objektu z databáze nebo díky vytváření kopie.

procedure AfterSetFieldValue_Hook(Self: TNxCustomBusinessObject; AFieldCode: Integer; AValue: TNxParameter; AOriginalValue: TNxParameter);
begin
 if osNew in self.state then begin
  if (AFieldCode=self.GetFieldCode('UnitPrice')) and not(AValue.AsFloat<AOriginalValue.AsFloat) then begin
    NxShowSimpleMessage('změnila se', nil);
    self.SetFieldValueAsInteger('Parent_ID.TotalRounding',259);
  end;
 end;
end; }

begin
end.