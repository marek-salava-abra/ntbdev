{
Vyvolává se po vyplnění hlavičky výstupního dokladu importovacím managerem
}
procedure AfterFillOptputHeader_Hook(Self: TNxDocumentImportManager);
begin
  if Self.InputDocumentCount > 0 then
    Self.OutputDocument.SetFieldValueAsString('X_ExternalNumber',Self.InputDocuments[0].GetFieldValueAsString('X_ExternalNumber'));
end;

begin
end.