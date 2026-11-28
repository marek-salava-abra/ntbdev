{
Vyvolává se po vyplnění řádků výstupního dokladu importovacím managerem
}
procedure AfterFillOptputRows_Hook(Self: TNxDocumentImportManager);
begin
  self.OutputDocument.SetFieldValueAsString('Firm_ID',self.InputHeaders[0].GetFieldValueAsString('Firm_ID'));
  self.OutputDocument.SetFieldValueAsString('FirmOffice_ID',self.InputHeaders[0].GetFieldValueAsString('FirmOffice_ID'));
  self.OutputDocument.SetFieldValueAsString('ExternalNumber',self.InputHeaders[0].GetFieldValueAsString('ExternalNumber'));
end;

begin
end.