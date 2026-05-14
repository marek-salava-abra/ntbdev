{
Vyvolává se po vyplnění výstupního řádku dokladu z vstupního řádku dokladu importovacím managerem
}
procedure AfterFillOutputRowFromInputRow_Hook(Self: TNxDocumentImportManager; AnInputRow: TNxCustomBusinessObject; aOutputRow: TNxCustomBusinessObject);
begin
     aOutputRow.SetFieldValueAsString('X_ProvideRow_ID',AnInputRow.oid);
end;

begin
end.