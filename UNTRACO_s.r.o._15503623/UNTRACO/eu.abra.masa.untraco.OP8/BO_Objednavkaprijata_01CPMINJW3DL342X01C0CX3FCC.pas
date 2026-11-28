{
Vyvolává se po změně každé položky. A to pouze, pokud k této změně nedochází díky načítání objektu z databáze nebo díky vytváření kopie.
}
procedure AfterSetFieldValue_Hook(Self: TNxCustomBusinessObject; AFieldCode: Integer; AValue: TNxParameter; AOriginalValue: TNxParameter);
begin
  if CFxNxRuntime.NxGetEnvironmentType=reRuntimeExe then begin
    if (AFieldCode=self.GetFieldCode('DocQueue_ID')) and not(AValue.AsString=AOriginalValue.AsString) then begin
       if not(NxIsEmptyOID(self.GetFieldValueAsString('DocQueue_ID'))) then begin
          if self.GetFieldValueAsString('DocQueue_ID')='J410000101' then
           Self.SetFieldValueAsString('U_Stav_ID','1300000101') else self.SetFieldValueAsString('U_Stav_ID','');
       end;
    end;
  end;
end;

begin
end.