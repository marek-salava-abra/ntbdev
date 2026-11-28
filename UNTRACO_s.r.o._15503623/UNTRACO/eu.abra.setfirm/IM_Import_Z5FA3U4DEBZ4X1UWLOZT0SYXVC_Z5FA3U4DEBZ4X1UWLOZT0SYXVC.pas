

{
Vyvolává se po vyplnění hlavičky výstupního dokladu importovacím managerem
}
procedure AfterFillOptputHeader_Hook(Self: TNxDocumentImportManager);
begin
  if NxIsEmptyOID(self.OutputDocument.GetFieldValueAsString('Firm_ID')) then
     self.OutputDocument.SetFieldValueAsString('firm_ID',self.InputDocument.GetFieldValueAsString('firm_ID'));
end;

begin
end.