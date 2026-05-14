
{
Vyvolává se před změnou každé položky. A to pouze, pokud k této změně nedochází díky načítání objektu z databáze nebo díky vytváření kopie.
}
procedure AfterSetFieldValue_PreHook(Self: TNxCustomBusinessObject; AFieldCode: Integer; AValue: TNxParameter);
Var
 mShow:Boolean;
begin
  mShow:=True;
  if osNew in self.State then begin
   if (AFieldCode=self.GetFieldCode('Firm_ID'))  then begin
     if self.GetFieldValueAsBoolean('Firm_id.U_stop_fakturace') or self.GetFieldValueAsBoolean('Firm_id.U_blacklist') then begin
      NxShowSimpleMessage('Na tuto firmu nejde udělat faktura, doklad nepůjde uložit ',nil);
      mShow:=false;
     end;
   end;
  end;
end;

begin
end.