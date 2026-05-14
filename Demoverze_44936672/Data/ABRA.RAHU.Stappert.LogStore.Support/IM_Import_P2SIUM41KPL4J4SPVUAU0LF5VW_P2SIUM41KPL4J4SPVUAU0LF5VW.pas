// !!! zkusit tlačítkem v obsahu
// !!! zkusit po uložení dokladu (na uloženém dokladu)
// !!! nutno počítat s existujícím neprovedenými NPZ

uses
  'ABRA.RAHU.Stappert.LogStore.Support.Common';

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

  mcInputDocRows: TNxCustomBusinessMonikerCollection;
  mcOutputDocRows: TNxCustomBusinessMonikerCollection;

begin
  // přenos řádkových PR -> NPZ (neexistuje systémová vazba, nespouští se vůbec funkce AfterFillOutputRowFromInputRow_Hook)

  // načtení dokladů
  boInputDoc := Self.InputDocuments(0);  // vazba PR -> NPZ podporuje jen jeden vstupní doklad
  mcInputDocRows := boInputDoc.GetLoadedCollectionMonikerForFieldCode(boInputDoc.GetFieldCode('Rows'));
  boOutputDoc := Self.OutputDocument;
  mcOutputDocRows := boOutputDoc.GetLoadedCollectionMonikerForFieldCode(boOutputDoc.GetFieldCode('Rows'));

  for iOutputRow := 0 to mcOutputDocRows.Count - 1 do
  begin
    boOutputRow := mcOutputDocRows.BusinessObject(iOutputRow);
{
    SetLogStorePositions(boOutputDoc, boOutputRow);
}
{
    boOutputRow.SetFieldValueAsString('StorePosition_ID', 'D810000101');
    boOutputRow.SetFieldValueAsFloat('Quantity', 4000);
    boOutputRow.SetFieldValueAsFloat('InPositionQuantity', 4000);
//    boOutputRow.SetFieldValueAsFloat('RestQuantity', 0);
}
  end;
end;

////////////////////////////////////////////////////////////////////////////////

begin
end.