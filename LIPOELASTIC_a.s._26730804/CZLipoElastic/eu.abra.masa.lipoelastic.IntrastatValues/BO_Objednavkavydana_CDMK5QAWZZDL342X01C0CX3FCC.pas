{
Vyvolává se po změně každé položky. A to pouze, pokud k této změně nedochází díky načítání objektu z databáze nebo díky vytváření kopie.
}
procedure AfterSetFieldValue_Hook(Self: TNxCustomBusinessObject; AFieldCode: Integer; AValue: TNxParameter; AOriginalValue: TNxParameter);
begin
  if (CFxNxRuntime.NxGetEnvironmentType=reRuntimeExe) and (osNew in self.State) then begin
    if (AFieldCode=self.GetFieldCode('Firm_ID')) and not(AValue.AsString=AOriginalValue.AsString) then begin
      if not(NxIsEmptyOID(self.GetFieldValueAsString('Firm_ID'))) then begin
        if not(NxIsEmptyOID(self.GetFieldValueAsString('Firm_ID.X_IntrastatDeliveryTerm_ID'))) and NxIsEmptyOID(self.GetFieldValueAsString('IntrastatDeliveryTerm_ID')) then begin
         self.SetFieldValueAsInteger('TradeType',6);
         self.SetFieldValueAsString('IntrastatDeliveryTerm_ID',self.GetFieldValueAsString('Firm_ID.X_IntrastatDeliveryTerm_ID'));
         self.SetFieldValueAsString('IntrastatTransportationType_ID',self.GetFieldValueAsString('Firm_ID.X_IntrastatTransportationType_'));
         self.SetFieldValueAsString('IntrastatTransactionType_ID',self.GetFieldValueAsString('Firm_ID.X_IntrastatTransactionType_ID'));
         self.SetFieldValueAsString('Country_ID',self.ObjectSpace.SQLSelectFirstAsString('Select id from countries where code='+QuotedStr(self.GetFieldValueAsString('Firm_ID.ResidenceAddress_ID.CountryCode')),''));
        end else begin
         self.SetFieldValueAsInteger('TradeType',1);
        end;
      end;
    end;
  end;
end;

begin
end.