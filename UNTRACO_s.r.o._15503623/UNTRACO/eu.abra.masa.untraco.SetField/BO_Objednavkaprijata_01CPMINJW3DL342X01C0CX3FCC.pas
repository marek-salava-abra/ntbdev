{
Vyvolává se po změně každé položky. A to pouze, pokud k této změně nedochází díky načítání objektu z databáze nebo díky vytváření kopie.
}
procedure AfterSetFieldValue_Hook(Self: TNxCustomBusinessObject; AFieldCode: Integer; AValue: TNxParameter; AOriginalValue: TNxParameter);
begin
  //if CFxNxRuntime.NxGetEnvironmentType=reShell then begin
    if (AFieldCode=self.GetFieldCode('TransportationType_ID')) and not(avalue.AsString=AOriginalValue.AsString) then begin
       if self.GetFieldValueAsString('TransportationType_ID.Code') in ['06','02'] then begin
         self.SetFieldValueAsString('U_Stav_ID','1300000101');
       end;
    end;
  //end;
end;

begin
end.