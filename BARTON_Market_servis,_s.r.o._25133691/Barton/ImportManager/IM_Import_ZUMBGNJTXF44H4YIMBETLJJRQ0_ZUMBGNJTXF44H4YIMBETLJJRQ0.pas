{
Vyvolává se po vyplnění hlavičky výstupního dokladu importovacím managerem
}
procedure AfterFillOptputHeader_Hook(Self: TNxDocumentImportManager);
begin
  if(Self.OutputDocument.GetFieldValueAsString('Description') = '') then begin
    Self.OutputDocument.SetFieldValueAsString('Description',Self.SelectedHeader.GetFieldValueAsString('Description'));
  end;
end;

begin
end.