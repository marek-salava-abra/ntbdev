{
Vyvolává se před vyplněním hlavičky výstupního dokladu importovacím managerem
}
procedure BeforeFillOptputHeader_Hook(Self: TNxDocumentImportManager);
begin
  Self.OutputDocument.SetFieldValueAsBoolean('ActualizeSuppliers',true);
end;

begin
end.