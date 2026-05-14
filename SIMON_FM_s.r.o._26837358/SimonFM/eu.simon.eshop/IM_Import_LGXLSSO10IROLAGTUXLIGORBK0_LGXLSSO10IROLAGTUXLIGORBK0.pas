{
Vyvolává se po vyplnění hlavičky výstupního dokladu importovacím managerem
}
procedure AfterFillOptputHeader_Hook(Self: TNxDocumentImportManager);
begin
  if (self.OutputDocument.GetFieldValueAsString('DocQueue_ID')='1Z10000101') and
  ((self.OutputDocument.GetFieldValueAsString('PaymentType_ID')='4000000101') or (self.OutputDocument.GetFieldValueAsString('PaymentType_ID')='3100000101')) then begin
    self.OutputDocument.SetFieldValueAsString('VarSymbol',self.InputHeaders[0].GetFieldValueAsString('ExternalNumber'));
  end;
  if (self.OutputDocument.GetFieldValueAsString('DocQueue_ID.Code')='FVES')
   and (self.OutputDocument.GetFieldValueAsString('TransportationType_ID.Code')='O1')
   then self.OutputDocument.SetFieldValueAsDateTime('DueDate$Date',Date+7);
end;


begin
end.