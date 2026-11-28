{
Vyvolává se po změně každé položky. A to pouze, pokud k této změně nedochází díky načítání objektu z databáze nebo díky vytváření kopie.
}
procedure AfterSetFieldValue_Hook(Self: TNxCustomBusinessObject; AFieldCode: Integer; AValue: TNxParameter; AOriginalValue: TNxParameter);
begin
 //if CFxNxRuntime.NxGetEnvironmentType=reRuntimeExe then begin
  if (osNew in self.State) and (AFieldCode=self.GetFieldCode('Firm_ID')) and not(AValue.AsString=AOriginalValue.AsString) then begin
    if not(NxIsEmptyOID(self.GetFieldValueAsString('Firm_ID'))) then begin
      if (self.GetFieldValueAsFloat('Firm_ID.DealerDiscount')>0) and (self.GetFieldValueAsInteger('Firm_ID.DealerDiscountKind')=3) then begin
        self.SetFieldValueAsFloat('DocumentDiscount',self.GetFieldValueAsFloat('Firm_ID.DealerDiscount'));
      end;
    end;

  end;
 //end;
end;

begin
end.