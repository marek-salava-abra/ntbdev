
{
Vyvolává se před změnou každé položky. A to pouze, pokud k této změně nedochází díky načítání objektu z databáze nebo díky vytváření kopie.
}
procedure AfterSetFieldValue_PreHook(Self: TNxCustomBusinessObject; AFieldCode: Integer; AValue: TNxParameter);
Var
 mShow:Boolean;
begin
  mShow:=True;
  if (osNew in self.State) and (CFxNxRuntime.NxGetEnvironmentType=reRuntimeExe) then begin
   if (AFieldCode=self.GetFieldCode('Firm_ID'))  and not(self.GetFieldValueAsString('Docqueue_ID')='1X10000101') then begin
     if self.GetFieldValueAsBoolean('Firm_id.U_stop_fakturace') or self.GetFieldValueAsBoolean('Firm_id.U_blacklist') then begin
      NxShowSimpleMessage('Na tuto firmu nejde udělat dodací list, doklad nepůjde uložit ',nil);
      mShow:=false;
     end;
   end;
  end;
end;

begin
end.