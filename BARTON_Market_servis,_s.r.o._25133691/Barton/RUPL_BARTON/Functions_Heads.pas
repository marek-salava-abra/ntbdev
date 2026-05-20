
{
Umožňuje ovlivnit validaci.
}
procedure Validate_Hook(Self: TNxCustomBusinessObject; var AResult: Boolean);
var
   i,j: Integer;
   mRows: TNxCustomBusinessMonikerCollection;
   mRow: TNxCustomBusinessObject;

   mDocRowBatches: TNxCustomBusinessMonikerCollection;
   mDocRowBatch: TNxCustomBusinessObject;

   mSumQuantity: Double;
begin
   mRows:= Self.GetLoadedCollectionMonikerForFieldCode(Self.GetFieldCode('Rows'));
   For i:= 0 to mRows.Count - 1 do
   begin
      mRow:= mRows.BusinessObject[i];
      if NOT (osMarkForDelete in mRow.State) then
      if mRow.GetFieldValueAsInteger('RowType') = 3 then
      if mRow.GetFieldValueAsInteger('StoreCard_ID.Category') = 2 then
      begin
         mSumQuantity:= 0;

         mDocRowBatches:= mRow.GetLoadedCollectionMonikerForFieldCode(mRow.GetFieldCode('DocRowBatches'));
         For j:= 0 to mDocRowBatches.Count - 1 do
         begin
            mDocRowBatch:= mDocRowBatches.BusinessObject[j];
            mSumQuantity:= mSumQuantity + mDocRowBatch.GetFieldValueAsFloat('Quantity');
         end;

         if mSumQuantity <> mRow.GetFieldValueAsFloat('Quantity') then
         begin
            Self.AddValidateError(Self.GetFieldCode('Rows'),'Řádek č. '+mRow.GetFieldValueAsString('PosIndex')+' nemá doplněny šarže. Doklad nelze uložit.');
            AResult:= False;
         end;
      end;
   end;
end;

begin
end.