{
Vyvolává se po vyplnění výstupního řádku dokladu z vstupního řádku dokladu importovacím managerem
}
procedure AfterFillOutputRowFromInputRow_Hook(Self: TNxDocumentImportManager; AInputRow: TNxCustomBusinessObject; aOutputRow: TNxCustomBusinessObject);
begin
  if aOutputRow.GetMonikerForFieldCode(aOutputRow.GetFieldCode('PArent_ID')).BusinessObject.GetFieldValueAsString('DocQUeue_ID.Code') = 'FVE' then begin
    if aOutputRow.GetMonikerForFieldCode(aOutputRow.GetFieldCode('PArent_ID')).BusinessObject.GetFieldValueAsInteger('TradeType') = 2 then begin
      aOutputRow.SetFieldValueAsString('VATIndex_ID', '1T00000000');
    end;
  end;
end;


begin
end.