uses '.lib';

procedure ImportStoreQuantities(Sender: TComponent);
var
  mSite: TSiteForm;
  mOS: TNxCustomObjectSpace;
  mStoreBO, mBoDBO: TNxCustomBusinessObject;
  mFileName, mFileExt, mLog, mSiteCLSID, mTableLog: string;
  mAIMap: TStringList;
  mImportedData, mStoreTable, mAggTable, mSourceForAggregation: TMemTable;
begin
  mSite:= Sender.Site;
  mOS:= mSite.BaseObjectSpace;

  mFileExt:= '';
  mLog:= '';
  mTableLog:= '';

  mBoDBO:= nil;
  mStoreTable:= nil;

  if not SelectImportFile(mSite, mFileName) then exit;

  WaitWin.StartProgress('Please, wait ...', '', 5);

  mAIMap := BuildAIMap;
  mStoreBO:= TBusRollSiteForm(mSite).CurrentObject;
  mImportedData:= TMemTable.Create(nil);

  try
    PrepareDataSet(mImportedData, mLog);
    mImportedData.Open;
    WaitWin.StepIt;

    //1. Importujeme základní data do datasetu
    mFileExt:= LowerCase(ExtractFileExt(mFileName));
    case mFileExt of
      '.xls', '.xlsx': LoadXLSXToList(mFileName, mImportedData);
      '.csv', '.txt': LoadCSVToList(mFileName, mImportedData);
    end;
    WaitWin.StepIt;
    //2. Parsujeme datamatrixy
    ParseAndFill(mOS, mAIMap, mImportedData, mLog);
    WaitWin.StepIt;

    //4.Vytvoř doklad
    mAggTable:= TMemTable.Create(nil);
    try
      PrepareDataSet(mAggTable, mLog);
      mAggTable.Open;
      WaitWin.StepIt;
      AggregateDataToMemTable_ImportStores(mImportedData, mAggTable, mTableLog);
      WaitWin.StepIt;

      //NxShowEditorSite(mSite.SiteContext, mTableLog, True);
      //WaitWin.Stop;
      WaitWin.Stop;
      //exit;

      CreateImportReceiptCards(mOS, mStoreBO.OID, mAggTable, mLog);
      WaitWin.Stop;

      if not NxIsBlank(mLog) then
        NxShowEditorSite(mSite.SiteContext, mLog, True);

    finally
      mAggTable.Free;
    end;
  finally
    if Assigned(mStoreTable) then
      mStoreTable.Free;
    mAIMap.Free;
    mImportedData.Free;
  end;
end;


procedure AggregateDataToMemTable_ImportStores(AStoreDataSet, AAggTable: TMemTable; var ATableLog: string;);
begin
  AStoreDataSet.First;

  while not AStoreDataSet.Eof do
  begin
    // hledáme kombinaci StoreCard_ID + StoreBatch_ID
    if AAggTable.Locate('StoreCard_ID;StoreBatchName',
      VarArrayOf([AStoreDataSet.FieldByName('StoreCard_ID').AsString,
                  AStoreDataSet.FieldByName('StoreBatchName').AsString]), [loCaseInsensitive]) then
    begin
      // už existuje -> sečti množství
      AAggTable.Edit;
      AAggTable.FieldByName('Quantity').AsFloat := AAggTable.FieldByName('Quantity').AsFloat + AStoreDataSet.FieldByName('Quantity').AsFloat;
      AAggTable.Post;
    end else
    begin
      // nový záznam
      AAggTable.Append;
      AAggTable.FieldByName('StoreCard_ID').AsString  :=  AStoreDataSet.FieldByName('StoreCard_ID').AsString;
      AAggTable.FieldByName('StoreBatch_ID').AsString :=  AStoreDataSet.FieldByName('StoreBatch_ID').AsString;
      AAggTable.FieldByName('StoreBatchName').AsString :=  AStoreDataSet.FieldByName('StoreBatchName').AsString;
      AAggTable.FieldByName('Quantity').AsFloat      :=   AStoreDataSet.FieldByName('Quantity').AsFloat;
      AAggTable.FieldByName('ExpireDate').AsDateTime:=    AStoreDataSet.FieldByName('ExpireDate').AsDateTime;
      AAggTable.FieldByName('ExpireDateStr').AsString:=    AStoreDataSet.FieldByName('ExpireDateStr').AsString;

      AAggTable.Post;
    end;
    AStoreDataSet.Next;
  end;

  AAggTable.First;
  while not AAggTable.Eof do
  begin
    ATableLog:= ATableLog +
      AAggTable.FieldByName('StoreCard_ID').AsString + '|' +
      AAggTable.FieldByName('StoreBatch_ID').AsString + '|' +
      AAggTable.FieldByName('StoreBatchName').AsString + '|' +
      FloatToStr(AAggTable.FieldByName('Quantity').AsFloat) + '|' +
      DateToStr(AAggTable.FieldByName('ExpireDate').AsDateTime) + '|' +
      AAggTable.FieldByName('ExpireDateStr').AsString + nxCrLf;
    AAggTable.next;
  end;

  // seřaď výslednou tabulku podle obou polí
  AAggTable.IndexFieldNames := 'StoreCard_ID;StoreBatchName';

end;


procedure CreateImportReceiptCards(AOS: TNxCustomObjectSpace; AStore_ID: string; ARowsTable: TMemTable; var ALog: string);
var
  mRowBatch, mRowBO, mBO: TNxCustomBusinessObject;
  mBoDRows, mDocRowBatches: TNxCustomBusinessMonikerCollection;
  mStoreCard_ID, mStoreBatch_ID: string;
  mQuantity: Extended;
  mCounter: Integer;
begin
  if (ARowsTable = nil) or ARowsTable.IsEmpty then
  begin
    NxShowSimpleMessage('Empty aggregated table', nil);
    Exit;
  end;

  ARowsTable.First;
  mCounter:= 0;

  try
    try
      mBO:= AOS.CreateObject(Class_ReceiptCard);

      mBO.New;
      mBO.Prefill;
      mBO.SetFieldValueAsString('Firm_ID', cDEFAULT_FIRM_ID);
      mBoDRows:= mBO.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('Rows'));

      while not ARowsTable.Eof do
      begin

        mStoreCard_ID:= ARowsTable.FieldByName('StoreCard_ID').AsString;
        if NxIsEmptyOID(mStoreCard_ID) then
        begin
          ALog:= ALog + Format('CreateReceiptCard - %s - storecard_id missing', [ARowsTable.FieldByName('StoreBatchName').AsString]) + nxCrLf;
          ARowsTable.Next;
          continue;
        end;

        mStoreBatch_ID:= ARowsTable.FieldByName('StoreBatch_ID').AsString;
        if NxIsEmptyOID(mStoreBatch_ID) then
        begin
          ALog:= ALog + Format('CreateReceiptCard - %s - storebatch_id missing', [ARowsTable.FieldByName('StoreBatchName').AsString]) + nxCrLf;
          ARowsTable.Next;
          continue;
        end;

        mQuantity:= 0;

        mRowBO:= mBoDRows.AddNewObject;
        mRowBO.Prefill;
        //mBO.SetFieldValueAsInteger('RowType', 3);
        mRowBO.SetFieldValueAsString('Store_ID', AStore_ID);
        mRowBO.SetFieldValueAsString('StoreCard_ID', mStoreCard_ID);
        mRowBO.SetFieldValueAsString('Division_ID', cDIVISION_ID);

        mDocRowBatches:= mRowBO.GetLoadedCollectionMonikerForFieldCode(mRowBO.GetFieldCode('DocRowBatches'));

        while not ARowsTable.Eof and (ARowsTable.FieldByName('StoreCard_ID').AsString = mStoreCard_ID) do
        begin
          if (ARowsTable.FieldByName('Quantity').AsFloat > 0) then
          begin
            mRowBatch:= mDocRowBatches.AddNewObject;

            if NxIsEmptyOID(ARowsTable.FieldByName('StoreBatch_ID').AsString) then
            begin
              mRowBatch.SetFieldValueAsBoolean('NewBatch', True);
              mRowBatch.SetFieldValueAsString('NewBatchName', ARowsTable.FieldByName('StoreBatchName').AsString);
              if ARowsTable.FieldByName('ExpireDate').AsDateTime > 0 then
                mRowBatch.SetFieldValueAsDateTime('NewBatchExpirationDate$DATE', ARowsTable.FieldByName('ExpireDate').AsDateTime);
            end else
              mRowBatch.SetFieldValueAsString('StoreBatch_ID', ARowsTable.FieldByName('StoreBatch_ID').AsString);
            mRowBatch.SetFieldValueAsFloat('Quantity', ARowsTable.FieldByName('Quantity').AsFloat);

            mQuantity:= mQuantity + ARowsTable.FieldByName('Quantity').AsFloat;
          end;

          {Inc(mCounter);
          if mCounter >= 500 then
          begin
            mRowBO.SetFieldValueAsFloat('Quantity', mQuantity);
            mBO.Save;
            mBO.Free;
            mRowBatch.Free;

            mBO:= AOS.CreateObject(Class_ReceiptCard);
            mBO.New;
            mBO.Prefill;
            mBO.SetFieldValueAsString('Firm_ID', cDEFAULT_FIRM_ID);
            mBoDRows:= mBO.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('Rows'));



            mCounter:= 0;
          end;   }
          ARowsTable.Next;
        end;

        mRowBO.SetFieldValueAsFloat('Quantity', mQuantity);
        Inc(mCounter);
        if mCounter >= 500 then
        begin
          mBO.save;

          mBO:= AOS.CreateObject(Class_ReceiptCard);
          mBO.New;
          mBO.Prefill;
          mBO.SetFieldValueAsString('Firm_ID', cDEFAULT_FIRM_ID);
          mBoDRows:= mBO.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('Rows'));
          mCounter:= 0;
        end;
      end;
      //if mCounter > 0 then
        mBO.Save;
    except
      NxShowSimpleMessage(ExceptionMessage, nil);
    end;
  finally
    mBO.Free;
  end;
end;


begin
end.