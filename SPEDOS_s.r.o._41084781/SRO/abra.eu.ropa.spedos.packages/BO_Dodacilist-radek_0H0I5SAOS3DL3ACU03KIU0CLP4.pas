uses 'abra.eu.ropa.spedos.packages.lib';


{
Vyvolává se před fyzickým uložením vlastních dat objektu do databáze.
}
procedure BeforeSave_Hook(Self: TNxCustomBusinessObject);
var
  i, j : integer;
  mRows, mBatches : TNxCustomBusinessMonikerCollection;
  mRow, mDocBatch : TNxCustomBusinessObject;
  mStoreCardMon, mBatchMon : TNxBusinessMoniker;
  mPackage_ID : string;
begin
  // potřebuji projít všechny řádky kolekce DocRowBatches a pro každá SN najít balíky....
  // co je BatchStatus
//  ShowMessage('dej radky');
//  mRows := Self.GetCollectionMonikerForFieldCode(Self.GetFieldCode('Rows'));
//  ShowMessage('mam radky');
//  if not Assigned(mRows) then
//    exit;
//  for i := 0 to mRows.Count - 1 do begin
    mRow := Self;
    if (mRow.GetFieldValueAsInteger('RowType') = 3) then begin
      mStoreCardMon := mRow.GetMonikerForFieldCode(mRow.GetFieldCode('StoreCard_ID'));
      if mStoreCardMon.BusinessObject.GetFieldValueAsInteger('Category') = 1 then begin // řádek obsahuje kartu se seriovym cislem
        mBatches :=  mRow.GetCollectionMonikerForFieldCode(mRow.GetFieldCode('DocRowBatches'));
        if Assigned(mBatches) then begin
          for j := 0 to mBatches.Count - 1 do begin
            mDocBatch := mBatches.BusinessObject[j];
            if assigned(mDocBatch) then begin
              mBatchMon := mDocBatch.GetMonikerForFieldCode(mDocBatch.GetFieldCode('StoreBatch_ID'));
              if not Assigned(mBatchMon) then
                ShowMessage('Neexistuje moniker pro StoreBatch')
              else begin
                UpdatePatches(Self.ObjectSpace, mBatchMon.BusinessObject.GetFieldValueAsString('X_Package1_ID')) ;
                UpdatePatches(Self.ObjectSpace, mBatchMon.BusinessObject.GetFieldValueAsString('X_Package2_ID')) ;
                UpdatePatches(Self.ObjectSpace, mBatchMon.BusinessObject.GetFieldValueAsString('X_Package3_ID')) ;
                UpdatePatches(Self.ObjectSpace, mBatchMon.BusinessObject.GetFieldValueAsString('X_Package4_ID')) ;
                UpdatePatches(Self.ObjectSpace, mBatchMon.BusinessObject.GetFieldValueAsString('X_Package5_ID')) ;
                UpdatePatches(Self.ObjectSpace, mBatchMon.BusinessObject.GetFieldValueAsString('X_Package6_ID')) ;
                UpdatePatches(Self.ObjectSpace, mBatchMon.BusinessObject.GetFieldValueAsString('X_Package7_ID')) ;
                UpdatePatches(Self.ObjectSpace, mBatchMon.BusinessObject.GetFieldValueAsString('X_Package8_ID')) ;
                UpdatePatches(Self.ObjectSpace, mBatchMon.BusinessObject.GetFieldValueAsString('X_Package9_ID')) ;
                UpdatePatches(Self.ObjectSpace, mBatchMon.BusinessObject.GetFieldValueAsString('X_Package10_ID')) ;
              end;
            end;
          end;
        end;
      end;
    end;
end;




begin
end.