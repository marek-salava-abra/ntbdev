{
Vyvolává se po vyplnění hlavičky výstupního dokladu importovacím managerem
}
procedure AfterFillOptputHeader_Hook(Self: TNxDocumentImportManager);
begin
  self.OutputDocument.SetFieldValueAsString('U_extNumber',self.InputDocuments[0].GetFieldValueAsString('ExternalNumber'));
end;

begin
end.