procedure AfterSetFieldValue_Hook(Self: TNxCustomBusinessObject; AFieldCode: Integer; AValue: TNxParameter; AOriginalValue: TNxParameter);
begin
  if (CFxNxRuntime.NxGetEnvironmentType=reRuntimeExe) and (osNew in self.State) then begin
    if (AFieldCode=self.GetFieldCode('Firm_ID')) and not(AValue.AsString=AOriginalValue.AsString) then begin
      if not(NxIsEmptyOID(self.GetFieldValueAsString('Firm_ID'))) then begin
        if not(NxIsEmptyOID(self.GetFieldValueAsString('Firm_ID.X_IntrastatDeliveryTerm_ID'))) and NxIsEmptyOID(self.GetFieldValueAsString('IntrastatDeliveryTerm_ID')) then begin
         if self.GetFieldValueAsInteger('Firm_ID.X_TradeType')>0 then self.SetFieldValueAsInteger('TradeType',self.GetFieldValueAsInteger('Firm_ID.X_TradeType'))
          else self.SetFieldValueAsInteger('TradeType',2);
         if self.GetFieldValueAsInteger('TradeType')=2 then begin
           self.SetFieldValueAsString('IntrastatDeliveryTerm_ID',self.GetFieldValueAsString('Firm_ID.X_IntrastatDeliveryTerm_ID'));
           self.SetFieldValueAsString('IntrastatTransportationType_ID',self.GetFieldValueAsString('Firm_ID.X_IntrastatTransportationType_'));
           self.SetFieldValueAsString('IntrastatTransactionType_ID',self.GetFieldValueAsString('Firm_ID.X_IntrastatTransactionType_ID'));
         end;
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