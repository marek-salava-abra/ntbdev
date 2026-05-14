{
Vyvolává se po vyplnění výstupního řádku dokladu z vstupního řádku dokladu importovacím managerem
}
procedure AfterFillOutputRowFromInputRow_Hook(Self: TNxDocumentImportManager; AnInputRow: TNxCustomBusinessObject; aOutputRow: TNxCustomBusinessObject);
begin
  if aOutputRow.GetFieldValueAsString('Parent_id.DocQueue_ID.code')='PVV' then begin
       aOutputRow.SetFieldValueAsString('BusProject_ID','');
        aOutputRow.SetFieldValueAsString('BusOrder_ID','');
   end;
end;

begin
end.