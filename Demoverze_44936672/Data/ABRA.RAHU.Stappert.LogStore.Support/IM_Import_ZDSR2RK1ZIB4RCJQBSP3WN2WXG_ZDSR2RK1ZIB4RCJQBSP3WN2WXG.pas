{
Vyvolává se po vyplnění řádků výstupního dokladu importovacím managerem
}
procedure AfterFillOptputRows_Hook(Self: TNxDocumentImportManager);
var
  iInputRow: Integer;
  iOutputRow: Integer;

  boInputDoc: TNxCustomBusinessObject;
  boOutputDoc: TNxCustomBusinessObject;

  boInputRow: TNxCustomBusinessObject;
  boOutputRow: TNxCustomBusinessObject;

  mcInputDoc: TNxCustomBusinessMonikerCollection;
  mcOutputDoc: TNxCustomBusinessMonikerCollection;

begin
  //OutputDebugString('AfterFillOptputRows_Hook');

  // přenos řádkových UDF OP -> PP (neexistuje systémová vazba, nespouští se vůbec funkce AfterFillOutputRowFromInputRow_Hook)
  // vážeme pouze přes ID skladových karet - v případě, že je na více řádcích OP stejná skladová karta, přenesou se UDF je z jednoho z nich

  // načtení dokladů
  boInputDoc := Self.InputDocuments(0);  // vazba OP -> PP podporuje jen jeden vstupní doklad
  mcInputDoc := boInputDoc.GetLoadedCollectionMonikerForFieldCode(boInputDoc.GetFieldCode('Rows'));
  boOutputDoc := Self.OutputDocument;
  mcOutputDoc := boOutputDoc.GetLoadedCollectionMonikerForFieldCode(boOutputDoc.GetFieldCode('Rows'));

  boOutputDoc.SetFieldValueAsString('Firm_ID', boInputDoc.GetFieldValueAsString('Firm_ID'));

  // pro všechny řádky PP hledáme řádek OP a přenášíme UDF
  for iOutputRow := 0 to mcOutputDoc.Count - 1 do
  begin
    boOutputRow:= mcOutputDoc.BusinessObject(iOutputRow);
    for iInputRow := 0 to mcInputDoc.Count - 1 do
    begin
      boInputRow:= mcInputDoc.BusinessObject(iInputRow);
      if boInputRow.GetFieldValueAsString('StoreCard_ID') = boOutputRow.GetFieldValueAsString('StoreCard_ID') then
      begin
        if boOutputRow.GetFieldValueAsString('X_InterniPoznamka') <> '' then
        begin
          boOutputRow.SetFieldValueAsString('X_InterniPoznamka', NxLeft(boOutputRow.GetFieldValueAsString('X_InterniPoznamka') + ' // ', 100));
        end;
        boOutputRow.SetFieldValueAsString('X_InterniPoznamka', NxLeft(boOutputRow.GetFieldValueAsString('X_InterniPoznamka') + boInputRow.GetFieldValueAsString('X_InterniPoznamka'), 100));

        if boOutputRow.GetFieldValueAsString('X_InterniPozadavek') <> '' then
        begin
          boOutputRow.SetFieldValueAsString('X_InterniPozadavek', NxLeft(boOutputRow.GetFieldValueAsString('X_InterniPozadavek') + ' // ', 100));
        end;
        boOutputRow.SetFieldValueAsString('X_InterniPozadavek', NxLeft(boOutputRow.GetFieldValueAsString('X_InterniPozadavek') + boInputRow.GetFieldValueAsString('X_InterniPozadavek'), 100));
      end;
    end;
  end;

end;

begin
end.