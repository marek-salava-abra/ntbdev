{
Vyvolává se po vyplnění výstupního řádku dokladu z vstupního řádku dokladu importovacím managerem
}
procedure AfterFillOutputRowFromInputRow_Hook(Self: TNxDocumentImportManager; AnInputRow: TNxCustomBusinessObject; aOutputRow: TNxCustomBusinessObject);

begin
  if (AnInputRow.GetFieldValueAsFloat('U_cenasdph2')>0)  and not(aOutputRow.GetFieldValueAsInteger('Rowtype')=1)then begin
     aOutputRow.SetFieldValueAsFloat('UnitPrice',AnInputRow.GetFieldValueAsFloat('U_cenasdph2')/((100+aOutputRow.GetFieldValueAsFloat('VatRate'))/100));

  end;
  if (AnInputRow.GetFieldValueAsFloat('U_cenasdph2')>0)  and (aOutputRow.GetFieldValueAsInteger('Rowtype')=1) then begin
     aOutputRow.SetFieldValueAsFloat('TotalPrice',AnInputRow.GetFieldValueAsFloat('U_cenasdph2')/((100+21)/100));
     aOutputRow.SetFieldValueAsString('VatRate_ID','02100X0000');
     aOutputRow.SetFieldValueAsString('VatIndex_ID','6521000000');
     aOutputRow.SetFieldValueAsString('IncomeType_ID','2100000101');
     aOutputRow.SetFieldValueAsString('Text',NxLeft(AnInputRow.GetFieldValueAsString('Text'), NxSearch(AnInputRow.GetFieldValueAsString('Text'),'  ',[srAll],0)));


  end;
end;

begin
end.