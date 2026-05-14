{
Vyvolává se po vyplnění výstupního řádku dokladu z vstupního řádku dokladu importovacím managerem
}
procedure AfterFillOutputRowFromInputRow_Hook(Self: TNxDocumentImportManager; AInputRow: TNxCustomBusinessObject; aOutputRow: TNxCustomBusinessObject);
begin
  aOutputRow.SetFieldValueAsString('X_ProvideRow_ID',AInputRow.getFieldValueAsString('X_ProvideRow_ID'));
end;

procedure AfterFillOptputHeader_Hook(Self: TNxDocumentImportManager);
begin
  self.OutputDocument.SetFieldValueAsString('X_Identifikace',self.InputDocuments[0].GetFieldValueAsString('X_Identifikace'));
end;


begin
end.