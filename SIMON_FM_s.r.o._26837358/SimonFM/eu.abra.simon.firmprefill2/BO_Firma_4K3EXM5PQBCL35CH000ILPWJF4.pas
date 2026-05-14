
{
Vyvolává se po změně každé položky. A to pouze, pokud k této změně nedochází díky načítání objektu z databáze nebo díky vytváření kopie.
}
procedure AfterSetFieldValue_Hook(Self: TNxCustomBusinessObject; AFieldCode: Integer; AValue: TNxParameter; AOriginalValue: TNxParameter);
begin
 begin
  if self.GetFieldCode('U_blackList')=AFieldCode then begin
    if self.GetFieldValueAsBoolean('U_blacklist') then self.SetFieldValueAsDateTime('U_blacklistdate',now);
    if not(self.GetFieldValueAsBoolean('U_blacklist')) then self.SetFieldValueAsDateTime('U_blacklistdate',0);

  end;
end;
end;

procedure Prefill_Hook(Self: TNxCustomBusinessObject);
begin
  self.SetFieldValueAsFloat('Credit',0);
  self.SetFieldValueAsInteger('AfterDueTerm',0);
  self.SetFieldValueAsBoolean('AfterDueTermEnabled',true);
  self.SetFieldValueAsBoolean('CheckCredit',True);
  self.SetFieldValueAsFloat('PenaltyPercent',0.5);
  
end;


begin
end.