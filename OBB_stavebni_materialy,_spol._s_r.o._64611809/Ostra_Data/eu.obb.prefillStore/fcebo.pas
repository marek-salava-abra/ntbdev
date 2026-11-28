procedure AfterSetFieldValue_Hook(Self: TNxCustomBusinessObject; AFieldCode: Integer; AValue: TNxParameter; AOriginalValue: TNxParameter);
begin
  if AFieldCode=self.GetFieldCode('StoreCard_ID') then begin
  if not(NxIsEmptyOID(self.GetFieldValueAsString('Parent_ID.FirmOffice_ID.X_BusTransaction_ID'))) and NxIsEmptyOID(self.GetFieldValueAsString('BusTransaction_ID')) then
    self.SetFieldValueAsString('BusTransaction_ID',self.GetFieldValueAsString('Parent_ID.FirmOffice_ID.X_BusTransaction_ID'));
  if not(NxIsEmptyOID(self.GetFieldValueAsString('Parent_ID.Firm_ID.X_BusTransaction_ID'))) and NxIsEmptyOID(self.GetFieldValueAsString('BusTransaction_ID')) then
    self.SetFieldValueAsString('BusTransaction_ID',self.GetFieldValueAsString('Parent_ID.Firm_ID.X_BusTransaction_ID'));

  end;
end;

begin
end.