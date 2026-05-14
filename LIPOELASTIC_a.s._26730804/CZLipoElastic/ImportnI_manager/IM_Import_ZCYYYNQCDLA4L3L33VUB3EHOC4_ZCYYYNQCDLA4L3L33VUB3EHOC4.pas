{
Vyvolává se po vyplnění hlavičky výstupního dokladu importovacím managerem
}
procedure AfterFillOptputHeader_Hook(Self: TNxDocumentImportManager);
begin
     self.OutputDocument.setFieldValueAsString('Description', self.InputDocuments[0].GetFieldValueAsString('Description')) ;
end;

begin
end.