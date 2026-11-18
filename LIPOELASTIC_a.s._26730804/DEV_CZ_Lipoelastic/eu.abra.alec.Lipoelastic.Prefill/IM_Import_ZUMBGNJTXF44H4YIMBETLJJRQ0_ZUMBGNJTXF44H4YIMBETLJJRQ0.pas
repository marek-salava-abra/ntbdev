{
Vyvolává se po vyplnění výstupního řádku dokladu z vstupního řádku dokladu importovacím managerem
}
procedure AfterFillOutputRowFromInputRow_Hook(Self: TNxDocumentImportManager; AInputRow: TNxCustomBusinessObject; aOutputRow: TNxCustomBusinessObject);
begin
  if Self.OutputDocument.GetFieldValueAsDateTime('VATAdmitDate$DATE') < AInputRow.GetFieldValueAsDateTime('Parent_ID.DocDate$DATE') then
    Self.OutputDocument.SetFieldValueAsDateTime('VATAdmitDate$DATE', AInputRow.GetFieldValueAsDateTime('Parent_ID.DocDate$DATE'));
end;

begin
end.