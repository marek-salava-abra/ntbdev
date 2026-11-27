{
Vyvolává se po vyplnění hlavičky výstupního dokladu importovacím managerem
}
procedure AfterFillOptputHeader_Hook(Self: TNxDocumentImportManager);
begin
  self.OutputDocument.SetFieldValueAsString('X_TargetEmail',self.OutputDocument.GetFieldValueAsString('Firm_ID.ElectronicAddress_ID.Email'));
end;

begin
end.