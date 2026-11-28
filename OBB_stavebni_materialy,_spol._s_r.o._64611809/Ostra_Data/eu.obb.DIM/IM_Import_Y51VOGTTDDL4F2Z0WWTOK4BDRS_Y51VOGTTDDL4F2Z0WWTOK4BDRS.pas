{
Vyvolává se po vyplnění hlavičky výstupního dokladu importovacím managerem
}
procedure AfterFillOptputHeader_Hook(Self: TNxDocumentImportManager);
begin
  self.OutputDocument.SetFieldValueAsInteger('TotalRounding',257);
end;

begin
end.