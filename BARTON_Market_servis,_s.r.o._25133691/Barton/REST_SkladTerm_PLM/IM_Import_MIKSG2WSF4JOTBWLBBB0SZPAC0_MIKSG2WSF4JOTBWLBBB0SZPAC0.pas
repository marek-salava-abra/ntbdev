

{
Vyvolává se po vyplnění výstupního řádku dokladu z vstupního řádku dokladu importovacím managerem
}
procedure AfterFillOutputRowFromInputRow_Hook(Self: TNxDocumentImportManager; AInputRow: TNxCustomBusinessObject; aOutputRow: TNxCustomBusinessObject);
begin
  aOutputRow.SetFieldValueAsString('Text', AInputRow.GetFieldValueAsString('ID'));
end;

begin
end.