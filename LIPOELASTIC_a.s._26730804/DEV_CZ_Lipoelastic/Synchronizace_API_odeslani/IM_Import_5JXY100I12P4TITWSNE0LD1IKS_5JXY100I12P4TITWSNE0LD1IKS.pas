{
Vyvolává se po vyplnění výstupního řádku dokladu z vstupního řádku dokladu importovacím managerem
}
{
Vyvolává se po vyplnění hlavičky výstupního dokladu importovacím managerem
}
procedure AfterFillOptputHeader_Hook(Self: TNxDocumentImportManager);
begin

  self.OutputDocument.SetFieldValueAsString('X_Identifikace',self.InputDocuments[0].GetFieldValueAsString('X_Identifikace'));
  if trim(self.OutputDocument.getFieldValueAsString('X_ExternalDocument'))='' then begin
      self.OutputDocument.SetFieldValueAsString('X_ExternalDocument',self.InputDocuments[0].GetFieldValueAsString('X_ExternalDocument'));
  end;

end;

procedure AfterFillOutputRowFromInputRow_Hook(Self: TNxDocumentImportManager; AInputRow: TNxCustomBusinessObject; aOutputRow: TNxCustomBusinessObject);
begin
  aOutputRow.SetFieldValueAsString('X_ProvideRow_ID',AInputRow.getFieldValueAsString('X_ProvideRow_ID'));
end;


begin
end.