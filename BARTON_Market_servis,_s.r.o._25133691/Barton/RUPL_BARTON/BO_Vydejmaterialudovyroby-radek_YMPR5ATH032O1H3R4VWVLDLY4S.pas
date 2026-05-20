Uses 'RUPL_BARTON.Functions_Rows_OUT';

{
Vyvolává se po uložení vlastních dat objektu do databáze.
}
procedure AfterSave_Hook(Self: TNxCustomBusinessObject);
   // Doklad VMV neví nic o šaržích... Protože tam dopisuju šarže a jejich počet, tak spočítám stav booked šarží a přepočítám ho...
var
   mSQL: String;
   mSQLResult: TStringList;

   mDocRowBatches: TNxCustomBusinessMonikerCollection;
   mDocRowBatch: TNxCustomBusinessObject;
   mStoreSubBatch: TNxCustomBusinessObject;

   mSumQuantity,mBookedQuantity: Double;
   j: Integer;
begin
   if Self.GetFieldValueAsInteger('RowType') = 3 then
   if Not NxIsEmptyOID(Self.GetFieldValueAsString('StoreCard_ID')) then
   if Not NxIsEmptyOID(Self.GetFieldValueAsString('Store_ID')) then
   if Self.GetFieldValueAsInteger('StoreCard_ID.Category') = 2 then
   begin
      mDocRowBatches:= Self.GetLoadedCollectionMonikerForFieldCode(Self.GetFieldCode('DocRowBatches'));
      mSQLResult:= TStringList.Create;
      try
         // Test, jestli už nejsou šarže doplněny
         mSumQuantity:= 0;
         For j:= 0 to mDocRowBatches.Count - 1 do
         begin
            mDocRowBatch:= mDocRowBatches.BusinessObject[j];
            mSQL:= 'SELECT '+
                   '  SUM( '+
                   '    DocRowBatches.Quantity *  '+
                   '    CASE PMStates.SystemState  '+
                   '      WHEN 2 THEN  '+
                   '        CASE StoreDocuments2.FlowSign  '+
                   '          WHEN -1 THEN 1  '+
                   '          ELSE 0   '+
                   '        END  '+
                   '      ELSE 0   '+
                   '    END  '+
                   '  ) AS BookedQuantity  '+
                   'FROM StoreDocuments2   '+
                   'JOIN StoreDocuments ON StoreDocuments.ID = StoreDocuments2.Parent_ID  '+
                   'JOIN PMStates ON StoreDocuments2.PMState_ID = PMStates.ID  '+
                   'JOIN DocRowBatches ON DocRowBatches.Parent_ID = StoreDocuments2.ID  '+
                   'JOIN StoreCards ON StoreCards.ID = StoreDocuments2.StoreCard_ID  '+
                   'WHERE  '+
                   '  StoreDocuments2.RowType = 3 AND  '+
                   '  StoreCards.NonStockType = ''N'' and  '+
                   '  StoreCards.ID = '+QuotedStr(Self.GetFieldValueAsString('StoreCard_ID'))+' and '+
                   '  StoreDocuments2.Store_ID = '+QuotedStr(Self.GetFieldValueAsString('Store_ID'))+' and '+
                   '  DocRowBatches.StoreBatch_ID = '+QuotedStr(mDocRowBatch.GetFieldValueAsString('StoreBatch_ID'));
            Self.ObjectSpace.SQLSelect(mSQL,mSQLResult);
            if mSQLResult.Count > 0 then
            begin
               mBookedQuantity:= StrToFloat(mSQLResult[0]);
               mSQL:= 'Select ID '+
                      'From StoreSubBatches '+
                      'Where '+
                      '  StoreBatch_ID = '+QuotedStr(mDocRowBatch.GetFieldValueAsString('StoreBatch_ID'))+' and '+
                      '  Store_ID = '+QuotedStr(Self.GetFieldValueAsString('Store_ID'));
               Self.ObjectSpace.SQLSelect(mSQL,mSQLResult);
               if mSQLResult.Count > 0 then
               begin
                  mStoreSubBatch:= Self.ObjectSpace.CreateObject(Class_StoreSubBatch);
                  try
                     mStoreSubBatch.Load(mSQLResult[0],nil);
                     if osNew in Self.State then
                     begin
                        if mStoreSubBatch.GetFieldValueAsFloat('BookedQuantity') <> mBookedQuantity then
                        begin
                           mStoreSubBatch.SetFieldValueAsFloat('BookedQuantity',mBookedQuantity);
                           if mStoreSubBatch.NeedSave then mStoreSubBatch.Save;
                           OutputDebugString(Self.GetFieldValueAsString('StoreCard_ID.Code')+' - NEW Přepočítávám šarži AfterSave_Hook');

                          //mSQL:= 'Update StoreSubBatches Set BookedQuantity = '+NxFloatToIBStr(mBookedQuantity)+' Where ID = '+QuotedStr(mStoreSubBatch.OID) ;
                          //Self.ObjectSpace.SQLExecute(mSQL);
                        end;
                     end
                     else
                     begin
                        OutputDebugString(Self.GetFieldValueAsString('StoreCard_ID.Code')+' - OLD Přepočítávám šarži AfterSave_Hook');
                        mStoreSubBatch.Save; // Nakonec stačí load a save a ABRA si vše dopočte sama...
                     end;

                     {
                     // 27.1.2023 JIFR (Přičteno množství na řádku.. dělalo chybu při ukládání)
                     if Self.GetFieldValueAsString('Parent_ID.PMState_ID')<>'2010000101' then  mBookedQuantity:= mBookedQuantity + mDocRowBatch.GetFieldValueAsFloat('Quantity');

                     mStoreSubBatch.SetFieldValueAsFloat('BookedQuantity',mBookedQuantity);
                     if mStoreSubBatch.NeedSave then mStoreSubBatch.Save;

                     if mStoreSubBatch.GetFieldValueAsFloat('BookedQuantity') <> mBookedQuantity then
                     begin


                       //mSQL:= 'Update StoreSubBatches Set BookedQuantity = '+NxFloatToIBStr(mBookedQuantity)+' Where ID = '+QuotedStr(mStoreSubBatch.OID) ;
                       //Self.ObjectSpace.SQLExecute(mSQL);
                     end;
                     }
                  finally
                     mStoreSubBatch.Free;
                  end;
               end;
            end;
         end;

      finally
         mSQLResult.Free;
      end;
   end;

end;

begin
end.