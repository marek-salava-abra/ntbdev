{
Vyvolává se po vyplnění výstupního řádku dokladu z vstupního řádku dokladu importovacím managerem
}
procedure AfterFillOutputRowFromInputRow_Hook(Self: TNxDocumentImportManager; AInputRow: TNxCustomBusinessObject; aOutputRow: TNxCustomBusinessObject);
begin
  if AInputRow.GetFieldValueAsString('Text')='Dopravné' then aOutputRow.SetFieldValueAsString('IncomeType_ID','1500000101');
end;

begin
end.