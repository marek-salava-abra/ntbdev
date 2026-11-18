{
Vyvolává se po vyplnění hlavičky výstupního dokladu importovacím managerem
}
procedure AfterFillOptputHeader_Hook(Self: TNxDocumentImportManager);
begin
  if (self.OutputDocument.GetFieldValueAsInteger('FirmOffice_ID.U_splatnost')>0) then
  self.OutputDocument.SetFieldValueAsDateTime('DueDate$Date',date+self.OutputDocument.GetFieldValueAsInteger('FirmOffice_ID.U_splatnost'));
end;

begin
end.