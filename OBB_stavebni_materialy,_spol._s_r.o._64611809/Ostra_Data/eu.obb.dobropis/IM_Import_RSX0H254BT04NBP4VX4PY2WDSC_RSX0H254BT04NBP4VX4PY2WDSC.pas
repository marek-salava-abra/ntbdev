


{
Vyvolává se po vyplnění výstupního řádku dokladu z vstupního řádku dokladu importovacím managerem
}
procedure AfterFillOutputRowFromInputRow_Hook(Self: TNxDocumentImportManager; AInputRow: TNxCustomBusinessObject; aOutputRow: TNxCustomBusinessObject);
begin
 if AInputRow.GetFieldValueAsInteger('RowType')=3 then begin
   aOutputRow.SetFieldValueAsFloat('UnitPrice', AInputRow.GetFieldValueAsFloat('TamountWithoutVAT')/(AInputRow.GetFieldValueAsFloat('Quantity')/AInputRow.GetFieldValueAsFloat('UnitRate')));
   aOutputRow.SetFieldValueAsFloat('RowDiscount',0);
 end;
end;

begin
end.