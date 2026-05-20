{
Umožňuje ovlivnit validaci.
}
procedure Validate_Hook(Self: TNxCustomBusinessObject; var AResult: Boolean);
var
   mSQL: String;
   mSQLResult: TStringList;

   mDocRowBatches: TNxCustomBusinessMonikerCollection;
   mDocRowBatch: TNxCustomBusinessObject;

   mSumQuantity: Double;
   j: Integer;
begin
   if Self.GetFieldValueAsInteger('RowType') = 3 then
   if Not NxIsEmptyOID(Self.GetFieldValueAsString('StoreCard_ID')) then
   if Not NxIsEmptyOID(Self.GetFieldValueAsString('Store_ID')) then
   if Self.GetFieldValueAsInteger('StoreCard_ID.Category') = 2 then
   begin
      mDocRowBatches:= Self.GetLoadedCollectionMonikerForFieldCode(Self.GetFieldCode('DocRowBatches'));

      // Test, jestli už nejsou šarže doplněny
      mSumQuantity:= 0;
      For j:= 0 to mDocRowBatches.Count - 1 do
      begin
         mDocRowBatch:= mDocRowBatches.BusinessObject[j];
         mSumQuantity:= mSumQuantity + mDocRowBatch.GetFieldValueAsFloat('Quantity');
      end;

      // Samotné vkládání, pokud ještě nejsou doplněny
      if mSumQuantity <> Self.GetFieldValueAsFloat('Quantity') then
      begin
         if mSumQuantity > 0 then
         begin
            // Na šaržích už nějaké množství je...
            if mDocRowBatches.Count = 1 then // Mám jen jednu šarži, budu upravovat, jinak nechám na uživatele...
            begin
               mDocRowBatch:= mDocRowBatches.BusinessObject[0];
               mDocRowBatch.SetFieldValueAsFloat('Quantity', Self.GetFieldValueAsFloat('Quantity'));
            end;
         end
         else
         begin
            mSQLResult:= TStringList.Create;
            try
               //Nejprve validovat zda existuje pouze jedna šarže a tu vyplnit včetně množství dle řádku
               mSQL:= 'Select SB.ID '+
                      'From StoreBatches SB '+
                      'Where Hidden = ''N'' and SB.StoreCard_ID = '+QuotedStr(Self.GetFieldValueAsString('StoreCard_ID'));
               Self.ObjectSpace.SQLSelect(mSQL,mSQLResult);
               if mSQLResult.Count = 1 then
               begin
                  mDocRowBatch:= mDocRowBatches.AddNewObject;
                  mDocRowBatch.SetFieldValueAsString('StoreBatch_ID',mSQLResult[0]);
                  mDocRowBatch.SetFieldValueAsString('Quantity',Self.GetFieldValueAsString('Quantity'));
               end
               else
               begin
                  //Pokud je více šarží, ale pouze jedna je na skladu tak opět tu vybrat včetně množství na řádku
                  mSQL:= 'Select SB.ID '+
                         'From StoreBatches SB '+
                         'Join StoreSubBatches SSB on SB.ID = SSB.StoreBatch_ID '+
                         'Where SB.Hidden = ''N'' and SB.StoreCard_ID = '+QuotedStr(Self.GetFieldValueAsString('StoreCard_ID'))+' and Store_ID = '+QuotedStr(Self.GetFieldValueAsString('Store_ID'))+' and SSB.Quantity > 0';

                  Self.ObjectSpace.SQLSelect(mSQL,mSQLResult);
                  if mSQLResult.Count = 1 then
                  begin
                     mDocRowBatches:= Self.GetLoadedCollectionMonikerForFieldCode(Self.GetFieldCode('DocRowBatches'));
                     mDocRowBatch:= mDocRowBatches.AddNewObject;
                     mDocRowBatch.SetFieldValueAsString('StoreBatch_ID',mSQLResult[0]);
                     mDocRowBatch.SetFieldValueAsString('Quantity',Self.GetFieldValueAsString('Quantity'));
                  end;
               end;
            finally
               mSQLResult.Free;
            end;
         end;
      end;
      Self.SetFieldValueAsInteger('BatchStatus',2);
   end;
end;

{
Vyvolává se po změně každé položky. A to pouze, pokud k této změně nedochází díky načítání objektu z databáze nebo díky vytváření kopie.
}
procedure AfterSetFieldValue_Hook(Self: TNxCustomBusinessObject; AFieldCode: Integer; AValue: TNxParameter; AOriginalValue: TNxParameter);
var
   mSQL: String;
   mSQLResult: TStringList;

   mDocRowBatches: TNxCustomBusinessMonikerCollection;
   mDocRowBatch: TNxCustomBusinessObject;

   mSumQuantity: Double;
   j: Integer;
begin
   if (Self.GetFieldCode('UnitQuantity') = AFieldCode) or (Self.GetFieldCode('Quantity') = AFieldCode) then
   if AValue.AsString <> AOriginalValue.AsString then
   if Self.GetFieldValueAsInteger('RowType') = 3 then
   if Not NxIsEmptyOID(Self.GetFieldValueAsString('StoreCard_ID')) then
   if Not NxIsEmptyOID(Self.GetFieldValueAsString('Store_ID')) then
   if Self.GetFieldValueAsInteger('StoreCard_ID.Category') = 2 then
   begin
      mDocRowBatches:= Self.GetLoadedCollectionMonikerForFieldCode(Self.GetFieldCode('DocRowBatches'));

      // Test, jestli už nejsou šarže doplněny
      mSumQuantity:= 0;
      For j:= 0 to mDocRowBatches.Count - 1 do
      begin
         mDocRowBatch:= mDocRowBatches.BusinessObject[j];
         mSumQuantity:= mSumQuantity + mDocRowBatch.GetFieldValueAsFloat('Quantity');
      end;

      if mSumQuantity > 0 then
      begin
         // Na šaržích už nějaké množství je...
         if mDocRowBatches.Count = 1 then // Mám jen jednu šarži, budu upravovat, jinak nechám na uživatele...
         begin
            mDocRowBatch:= mDocRowBatches.BusinessObject[0];
            mDocRowBatch.SetFieldValueAsFloat('Quantity', Self.GetFieldValueAsFloat('Quantity'));
         end;
      end;
      Self.SetFieldValueAsInteger('BatchStatus',2);
   end;
end;

begin
end.