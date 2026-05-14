uses
  'ABRA.LUBI.Compute_Individual_Discounts.uIndividualDiscounts';

{
Vyvolává se po vyplnění hlavičky výstupního dokladu importovacím managerem
}
procedure AfterFillOptputHeader_Hook(Self: TNxDocumentImportManager);
begin
  UpdateCheckBox(self.OutputDocument.GetFieldValueAsBoolean('X_DONT_USE_MENUDISCOUNT'));
end;

begin
end.