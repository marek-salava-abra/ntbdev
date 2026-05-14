
{
Vyvolává se po vyplnění výstupního řádku dokladu z vstupního řádku dokladu importovacím managerem
}
procedure AfterFillOutputRowFromInputRow_Hook(Self: TNxDocumentImportManager; AnInputRow: TNxCustomBusinessObject; aOutputRow: TNxCustomBusinessObject);
begin
  if (AnInputRow.GetFieldValueAsString('Parent_ID.Docqueue_ID')='1710000101') then aOutputRow.SetFieldValueAsString('ExpenseType_ID','1V00000101');
end;

begin
end.