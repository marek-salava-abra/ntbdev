uses '.datamatrix', 'eu.abra.masa.lipoelastic.ImportQuantity.API';

procedure ConsignmentImport(Sender: TComponent; AMethod: string);
var
  mSite: TSiteForm;
  mOS: TNxCustomObjectSpace;
  mStoreBO, mBoDBO: TNxCustomBusinessObject;
  mFileName, mFileExt, mLog, mSiteCLSID: string;
  mAIMap: TStringList;
  mImportedData, mStoreTable, mAggTable, mSourceForAggregation: TMemTable;
begin
  mSite:= Sender.Site;
  mOS:= mSite.BaseObjectSpace;

  mFileExt:= '';
  mLog:= '';
  mBoDBO:= nil;
  mStoreTable:= nil;

  if not SelectImportFile(mSite, mFileName) then exit;

  mAIMap := BuildAIMap;
  mStoreBO:= TBusRollSiteForm(mSite).CurrentObject;
  mImportedData:= TMemTable.Create(nil);

  try
    PrepareDataSet(mImportedData, mLog);
    mImportedData.Open;

    //1. Importujeme základní data do datasetu
    mFileExt:= LowerCase(ExtractFileExt(mFileName));
    case mFileExt of
      '.xls', '.xlsx': LoadXLSXToList(mFileName, mImportedData);
      '.csv', '.txt': LoadCSVToList(mFileName, mImportedData);
    end;

    //2. Parsujeme datamatrixy
    ParseAndFill(mOS, mAIMap, mImportedData, mLog);

    mSourceForAggregation:= mImportedData;

    //3. Když je o inventuru skladu. Method = 'inventory'
    if AMethod = cIMPORT_METHOD_INVENTORY then
    begin
      mStoreTable:= TMemTable.Create(nil);
      GetCurrentInventoryToMemTable(mOS, mStoreBO.OID, mStoreTable);
      mStoreTable.IndexFieldNames:= 'KeyValue';
      CompareAndSubtractImportedQuantities(mImportedData, mStoreTable);
      mSourceForAggregation:= mStoreTable;
    end;

    mSiteCLSID:= Site_BillOfDeliveries;

    if AMethod = cIMPORT_METHOD_RECEIPTCARD then
      mSiteCLSID:= Site_ReceiptCards;

    //4.Vytvoř doklad
    mAggTable:= TMemTable.Create(nil);
    try
      PrepareDataSet(mAggTable, mLog);
      mAggTable.Open;

      AggregateDataToMemTable(mSourceForAggregation, mAggTable);

      if AMethod = cIMPORT_METHOD_RECEIPTCARD then
        CreateReceiptCard(mOS, mStoreBO.OID, mAggTable, mLog)
      else
      begin
        mBoDBO:= CreateBillOfDelivery(mOS, mStoreBO.OID, mAggTable);
        TDynSiteForm.ShowDynFormWithNewDocument(mSiteCLSID, mSite.SiteContext, mBoDBO, mSite);
      end;


      try
        if not NxIsBlank(mLog) then
          NxShowEditorSite(mSite.SiteContext, mLog, True);
        //Zobrazíme doklad před uložením
        //TDynSiteForm.ShowDynFormWithNewDocument(mSiteCLSID, mSite.SiteContext, mBoDBO, mSite);
      finally
        mBoDBO.Free;
      end;
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


procedure LoadXLSXToList(const AFileName: string; ADataSet: TDataset);
var
  mExcel, mWorkbook, mWorksheet, mUsedRange: Variant;
  mRowCount, i: Integer;
  mCode, mQty: string;
begin
  try
    try
      mExcel:= CreateOleObject('Excel.Application');
    except
      NxShowSimpleMessage('Excel application is not installed!', nil);
      exit;
    end;

    try
      mExcel.Visible:= false;
      mWorkbook:= mExcel.Workbooks.Open(AFileName);
      try
        mWorksheet := mWorkbook.Worksheets[1];
        mUsedRange := mWorksheet.UsedRange;
        mRowCount := mUsedRange.Rows.Count;

        for i:= 1 to mRowCount do
        begin
          mCode:= Trim(VarToStr(mUsedRange.Cells[i, 1].Value));
          mQty:= Trim(VarToStr(mUsedRange.Cells[i, 2].Value));

          //Nevím jestli budu dostávat sloupec s množstvím a nebo jen sloupec s datamatrixy
          if Trim(VarToStr(mUsedRange.Cells[i, 2].Value)) = '' then
            mQty:= '1';

          if (mQty = '') or (not NxIsNumeric(mQty)) then
            mQty:= '0';

          if (mCode <> '') and (mQty <> '') then
          begin
            ADataSet.Append;
            ADataSet.FieldByName('Barcode').AsString:= mCode;
            ADataSet.FieldByName('Quantity').AsFloat:= NxIBStrToFloat(mQty);
            ADataSet.Post;
          end;
        end;
      finally
        if not VarIsEmpty(mWorkbook) then
          mWorkbook.Close;
        mWorkbook:= nil;
      end;
    except
      NxShowSimpleMessage('Error while reading the file', nil);
      exit;
    end;
  finally
    if not VarIsEmpty(mExcel) then
      mExcel.Quit;
    mExcel := nil;
    mWorksheet:= nil;
  end;
end;


procedure LoadCSVToList(const AFileName: string; ADataset: TDataset);
var
  mLines: TStringList;
  mLine, mCode, mQty: string;
  mSeparator: Char;
  i: Integer;
begin
  mLines := TStringList.Create;
  try
    mLines.LoadFromFile(AFileName);

    mSeparator:= ',';

    for i := 0 to mLines.Count - 1 do
    begin
      mLine := Trim(mLines[i]);
      if mLine = '' then
        Continue;

      mCode:= NxTrapStrTrim(mLine, mSeparator);
      mQty:=  NxTrapStrTrim(mLine, mSeparator);

      //Nevím jestli budu dostávat sloupec s množstvím a nebo jen sloupec s datamatrixy
      if mQty = '' then
        mQty:= '1';


      if (mQty = '') or (not NxIsNumeric(mQty)) then
        mQty:= '0';

      if (mCode <> '') and (mQty <> '') then
      begin
        ADataset.Append;
        ADataset.FieldByName('Barcode').AsString:= mCode;
        ADataset.FieldByName('Quantity').AsFloat:= NxIBStrToFloat(mQty);
        ADataset.Post;
      end;
    end;
  finally
    mLines.Free;
  end;
end;


procedure BarcodeSpecialParse(ABarcode: string; ADataSet: TDataSet);
var
  mSeparator, mTempBarcode, mStoreCardCode, mBatchName, mExpireDate, mExpireDateShort, mFormatDate: string;
begin
  mSeparator:= ';';
  mTempBarcode:= ABarcode;

  mStoreCardCode:=    NxTrapStrTrim(mTempBarcode, mSeparator);
  mBatchName:=        NxTrapStrTrim(mTempBarcode, mSeparator);
  mExpireDate:=       NxTrapStrTrim(mTempBarcode, mSeparator);
  mExpireDateShort:=  NxTrapStrTrim(mTempBarcode, mSeparator);

  case Length(mExpireDate) of
    6: mFormatDate:= 'yymmdd';
    8: mFormatDate:= 'yyyymmdd';
  end;

  ADataSet.Edit;
  ADataSet.FieldByName('StoreCardCode').AsString:= mStoreCardCode;
  ADataSet.FieldByName('StoreBatchName').AsString:= mBatchName;
  if Length(mExpireDate) > 5 then
    ADataSet.FieldByName('ExpireDate').AsDateTime:= CFxDate.StrToDateEx(mExpireDate, mFormatDate);
  ADataSet.Post;
end;


procedure GetIDsAndFillDataSet(AOS: TNxCustomObjectSpace; ADataSet: TDataSet; var ALog: string);
var
  mStoreCard_ID, mStoreBatch_ID: String;
  mEAN, mStoreBatchName, mStoreCardCode: string;
  mInputJSON, mOutputJSON: TJSONSuperObject;
  mDate: TDateTime;
  mVersion: string;
begin
  mEAN:=            ADataSet.FieldByName('EAN').AsString;
  mStoreBatchName:= ADataSet.FieldByName('StoreBatchName').AsString;
  mStoreCardCode:=  ADataSet.FieldByName('StoreCardCode').AsString;

  mDate:= 0;
  mVersion:= '';

  //Zkusíme s EANem tak jak je
  if not NxIsBlank(mEAN) then
  begin
    mStoreCard_ID:= AOS.SQLSelectFirstAsString(Format(
      ' SELECT SU.Parent_ID FROM StoreEANs SE '+
      ' JOIN StoreUnits SU ON SU.ID = SE.Parent_ID '+
      ' WHERE SE.EAN = ''%s''', [mEAN]));

    //Zkusíme s EANem ořezeným o uvozující nuly
    if NxIsEmptyOID(mStoreCard_ID) then
      mStoreCard_ID:= AOS.SQLSelectFirstAsString(Format(
      ' SELECT SU.Parent_ID FROM StoreEANs SE '+
      ' JOIN StoreUnits SU ON SU.ID = SE.Parent_ID '+
      ' WHERE SE.EAN = ''%s''', [NxTrimL(mEAN, '0')]));
  end;

  if NxIsEmptyOID(mStoreCard_ID) then
    mStoreCard_ID:= AOS.SQLSelectFirstAsString(Format('SELECT SB.StoreCard_ID FROM StoreBatches SB WHERE SB.Name = ''%s''', [mStoreBatchName]));

  if NxIsEmptyOID(mStoreCard_ID) then
    mStoreCard_ID:= AOS.SQLSelectFirstAsString(Format('SELECT SC.ID FROM StoreCards SC WHERE SC.Code = ''%s''', [mStoreCardCode]));

  if NxIsEmptyOID(mStoreCard_ID) then
    ALog:= ALog + Format('GetIDsAndFillDataSet - Storecard not found - barcode: %s - storebatch: %s - storecardcode: %s - EAN: %s'+ nxCrLf, [ADataSet.FieldByName('Barcode').AsString, mStoreBatchName, mStoreCardCode, mEAN]);

  //Dohledáme si Storebatch_id
  mStoreBatch_ID:= AOS.SQLSelectFirstAsString(Format(
    ' SELECT ID FROM StoreBatches '+
    ' WHERE StoreCard_ID = ''%s'' AND Name = ''%s''',
    [mStoreCard_ID, mStoreBatchName]));

  if NxIsEmptyOID(mStoreBatch_ID) then
    mStoreBatch_ID:= AOS.SQLSelectFirstAsString(Format(
    ' SELECT ID FROM StoreBatches '+
    ' WHERE StoreCard_ID = ''%s'' AND Name = ''%s''',
    [mStoreCard_ID, NxRight(mStoreBatchName, 12)]));

  if NxIsEmptyOID(mStoreBatch_ID) then
    mStoreBatch_ID:= AOS.SQLSelectFirstAsString(Format(
    ' SELECT ID FROM StoreBatches '+
    ' WHERE StoreCard_ID = ''%s'' AND Name = ''%s''',
    [mStoreCard_ID, NxTrimL(mStoreBatchName, '0')]));

  if NxIsEmptyOID(mStoreBatch_ID) and not(NxIsEmptyOID(mStoreCard_ID)) then
  begin
    mInputJSON:= TJSONSuperObject.Create;
    try
      mInputJSON.S['ean']:= NxTrimL(mEAN, '0');
      mInputJSON.S['batchCode']:= NxRight(mStoreBatchName, 12);
      mOutputJSON:= API_POST(mInputJSON, 'GetDataFromBatch', true);
      if mOutputJSON.N['status'].DataType <> jtNull then
      begin
        if mOutputJSON.S['status']= 'ok' then
        begin
          mDate:= mOutputJSON.DT8601['expirationDate'];
          mVersion:= mOutputJSON.S['version'];
          mStoreBatch_ID:= GetBatch_ID(AOS, mStoreCard_ID, NxRight(mStoreBatchName, 12), mDate, mVersion);
        end;
      end;
    finally
      mInputJSON.Free;
      mOutputJSON.Free;
    end;
    //if mDate > 0 then
      //mStoreBatch_ID:= GetBatch_ID(AOS, mStoreCard_ID, NxRight(mStoreBatchName, 12), mDate, mVersion);
  end;

  //if NxIsEmptyOID(mStoreBatch_ID) then
    //ALog:= ALog + Format('GetIDsAndFillDataSet - StoreBatch_ID not found - storebatch: %s - storecardcode: %s - EAN: %s'+ nxCrLf, [mStoreBatchName, mStoreCardCode, mEAN]);

  //Doplníme do datasetu
  ADataSet.Edit;
  ADataSet.FieldByName('StoreCard_ID').AsString:= mStoreCard_ID;
  ADataSet.FieldByName('StoreBatch_ID').AsString:= mStoreBatch_ID;
  ADataSet.FieldByName('ExpireDate').AsDateTime:= mDate;
  ADataSet.FieldByName('KeyValue').AsString:= mStoreCard_ID + ':' + mStoreBatch_ID;
  ADataSet.Post;
end;


procedure PrepareDataSet(ADataSet: TDataSet; var ALog: string);
var
  mFieldDef: TFieldDef;
  mField: TField;
begin
  try
    AddField(ADataSet, 'StoreCard_ID', ftString, 300001, 10);
    AddField(ADataSet, 'Store_ID', ftString, 300002, 10);
    AddField(ADataSet, 'StoreBatch_ID', ftString, 300003, 10);
    AddField(ADataSet, 'StoreBatchName', ftString, 300004, 100);
    AddField(ADataSet, 'Quantity', ftFloat, 300005);
    AddField(ADataSet, 'ExpireDate', ftDateTime, 300006);
    AddField(ADataSet, 'Barcode', ftString, 300007, 100);
    AddField(ADataSet, 'StoreCardCode', ftString, 300008, 100);
    AddField(ADataSet, 'EAN', ftString, 300009, 14);
    AddField(ADataSet, 'KeyValue', ftString, 300010, 64);
    AddField(ADataSet, 'ExpireDateStr', ftString, 300011);

  except
    ALog:= ALog + Format('PrepareDataSet - Vyskytla se chyba při přípravě datasetu %s', [ExceptionMessage])+ nxCrLf;
    exit;
  end;
end;

procedure AddField(ADataSet: TDataSet; const AFieldName: string; AFieldType: TFieldType; AFieldCode: integer; ASize: Integer = 0;);
var
  mFieldDef: TFieldDef;
begin
  mFieldDef := TFieldDef.Create(ADataSet.FieldDefs, AFieldName, AFieldType, ASize, False, AFieldCode);
  with mFieldDef.CreateField(ADataSet, nil, 'x' + AFieldName, False) do
  begin
    if ASize > 0 then
      Size := ASize;
    FieldKind := fkData;
    FieldName := AFieldName;
  end;
end;


procedure GetCurrentInventoryToMemTable(AOS: TNxCustomObjectSpace; AStore_ID: string; AMemTable: TMemTable);
var
  mParams: TNxParameters;
begin
  mParams:= TNxParameters.Create;
  try
    mParams.GetOrCreateParam(dtString, 'Store_ID').AsString:= AStore_ID;

    AOS.SQLSelect2(
      ' SELECT '+
      ' (SSC.StoreCard_ID || '':'' || SB.ID) AS KeyValue, '+
      ' SSC.StoreCard_ID AS StoreCard_ID, '+
      ' SSC.Store_ID AS Store_ID, '+
      ' SB.ID AS StoreBatch_ID, '+
      ' SB.Name AS StoreBatchName, '+
      ' SSB.Quantity AS Quantity, '+
      ' SB.ExpirationDate$Date AS ExpireDate, '+
      ' CAST('''' AS VARCHAR(100)) AS Barcode, '+
      ' CAST('''' AS VARCHAR(100)) AS StoreCardCode, '+
      ' CAST('''' AS VARCHAR(14)) AS EAN '+
      ' FROM StoreSubCards SSC '+
      ' JOIN StoreSubBatches SSB ON SSB.StoreCard_ID = SSC.StoreCard_ID '+
      ' JOIN StoreBatches SB ON SB.ID = SSB.StoreBatch_ID '+
      ' WHERE SSB.Quantity > 0 '+
      ' AND SSC.Store_ID = :Store_ID '+
      ' AND SSB.Store_ID = :Store_ID ',
      AMemTable, mParams
    );
  finally
    mParams.Free;
  end;
end;


function SelectImportFile(ASite: TSiteForm; var AFileName: string):Boolean;
var
  mOpenDialog: TOpenDialog;
begin
  Result:= False;
  AFileName:= '';

  mOpenDialog:= TOpenDialog.Create(ASite);
  try
    mOpenDialog.Filter := 'Soubor importu (*.xls,*.xlsx,*.txt,*.csv)|*.XLS;*.xlsx;*.txt;*.csv';
    if not mOpenDialog.Execute(ASite) then exit;

    AFileName:= mOpenDialog.FileName;
    Result:= True;
  finally
    mOpenDialog.Free;
  end;
end;


procedure ParseAndFill(AOS: TNxCustomObjectSpace; AIMap: TStringList; ADataSet: TDataSet; var ALog: string{; var ATableLog: string});
begin
  ADataSet.First;
  while not ADataSet.Eof do
  begin
    if IsGS1BarCode(ADataSet.FieldByName('Barcode').AsString) then
    begin
      TokenizeGS1ToDataSet(SanitizeGS1String(ADataSet.FieldByName('Barcode').AsString), AIMap, ADataSet);
      GetIDsAndFillDataSet(AOS, ADataSet, ALog);
    end else
    begin
      BarcodeSpecialParse(ADataSet.FieldByName('Barcode').AsString, ADataSet);
      GetIDsAndFillDataSet(AOS, ADataSet, ALog);
    end;
    //NxShowSimpleMessage(ADataSet.FieldByName('Barcode').AsString, nil);
    //exit;
    //ATableLog:= ATableLog +
    //  ADataSet.FieldByName('StoreBatchName').AsString + '|' +
    //  ADataSet.FieldByName('ExpireDateStr').AsString + nxCrLf;
      {
       AddField(ADataSet, 'StoreCard_ID', ftString, 300001, 10);
    AddField(ADataSet, 'Store_ID', ftString, 300002, 10);
    AddField(ADataSet, 'StoreBatch_ID', ftString, 300003, 10);
    AddField(ADataSet, 'StoreBatchName', ftString, 300004, 100);
    AddField(ADataSet, 'Quantity', ftFloat, 300005);
    AddField(ADataSet, 'ExpireDate', ftDateTime, 300006);
    AddField(ADataSet, 'Barcode', ftString, 300007, 100);
    AddField(ADataSet, 'StoreCardCode', ftString, 300008, 100);
    AddField(ADataSet, 'EAN', ftString, 300009, 14);
    AddField(ADataSet, 'KeyValue', ftString, 300010, 64);
    AddField(ADataSet, 'ExpireDateStr', ftString, 300011);
    }
    ADataSet.Next;
  end;
end;


procedure CompareAndSubtractImportedQuantities(AImportedDataSet, AStoreDataSet: TDataSet);
begin
  AImportedDataSet.First;
  while not AImportedDataSet.Eof do
  begin
    if AStoreDataSet.Locate('KeyValue', AImportedDataSet.FieldByName('KeyValue').AsString, [loCaseInsensitive]) then
    begin
      AStoreDataSet.Edit;
      AStoreDataSet.FieldByName('Quantity').AsFloat:= AStoreDataSet.FieldByName('Quantity').AsFloat - AImportedDataSet.FieldByName('Quantity').AsFloat;
      AStoreDataSet.Post;
    end;

    AImportedDataSet.Next;
  end;
end;


procedure AggregateDataToMemTable(AStoreDataSet, AAggTable: TMemTable);
begin
  AStoreDataSet.First;

  while not AStoreDataSet.Eof do
  begin
    // hledáme kombinaci StoreCard_ID + StoreBatch_ID
    if AAggTable.Locate('StoreCard_ID;StoreBatch_ID',
      VarArrayOf([AStoreDataSet.FieldByName('StoreCard_ID').AsString,
                  AStoreDataSet.FieldByName('StoreBatch_ID').AsString]), [loCaseInsensitive]) then
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
      AAggTable.FieldByName('Quantity').AsFloat      :=   AStoreDataSet.FieldByName('Quantity').AsFloat;
      AAggTable.FieldByName('ExpireDate').AsDateTime:=    AStoreDataSet.FieldByName('ExpireDate').AsDateTime;
      AAggTable.Post;
    end;
    AStoreDataSet.Next;
  end;

  // seřaď výslednou tabulku podle obou polí
  AAggTable.IndexFieldNames := 'StoreCard_ID;StoreBatch_ID';

end;


function CreateBillOfDelivery(AOS: TNxCustomObjectSpace; AStore_ID: string; ARowsTable: TMemTable): TNxCustomBusinessObject;
var
  mRowBatch, mBO: TNxCustomBusinessObject;
  mBoDRows, mDocRowBatches: TNxCustomBusinessMonikerCollection;
  mStoreCard_ID: string;
  mQuantity: Extended;
begin
  Result:= nil;

  if (ARowsTable = nil) or ARowsTable.IsEmpty then
  begin
    NxShowSimpleMessage('Empty aggregated table', nil);
    Exit;
  end;

  ARowsTable.First;

  try
    Result:= AOS.CreateObject(Class_BillOfDelivery);

    Result.New;
    Result.Prefill;
    Result.SetFieldValueAsString('DocQueue_ID', cBILL_OF_DELIVERY_DOCQUEUE_ID);
    mBoDRows:= Result.GetLoadedCollectionMonikerForFieldCode(Result.GetFieldCode('Rows'));

    while not ARowsTable.Eof do
    begin
      mStoreCard_ID:= ARowsTable.FieldByName('StoreCard_ID').AsString;

      mQuantity:= 0;

      mBO:= mBoDRows.AddNewObject;
      mBO.Prefill;
      mBO.SetFieldValueAsInteger('RowType', 3);
      mBO.SetFieldValueAsString('Store_ID', AStore_ID);
      mBO.SetFieldValueAsString('StoreCard_ID', mStoreCard_ID);
      mBO.SetFieldValueAsString('Division_ID', cDIVISION_ID);

      mDocRowBatches:= mBO.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('DocRowBatches'));

      while not ARowsTable.Eof and (ARowsTable.FieldByName('StoreCard_ID').AsString = mStoreCard_ID) do
      begin
        if ARowsTable.FieldByName('Quantity').AsFloat > 0 then
        begin
          mRowBatch:= mDocRowBatches.AddNewObject;
          mRowBatch.SetFieldValueAsString('StoreBatch_ID', ARowsTable.FieldByName('StoreBatch_ID').AsString);
          mRowBatch.SetFieldValueAsFloat('Quantity', ARowsTable.FieldByName('Quantity').AsFloat);
          mQuantity:= mQuantity + ARowsTable.FieldByName('Quantity').AsFloat;
        end;
        ARowsTable.Next;
      end;
      mBO.SetFieldValueAsFloat('Quantity', mQuantity);
    end;
  except
    NxShowSimpleMessage(ExceptionMessage, nil);
  end;
end;


procedure CreateReceiptCard(AOS: TNxCustomObjectSpace; AStore_ID: string; ARowsTable: TMemTable; var ALog: string);
var
  mRowBatch, mRowBO, mBO: TNxCustomBusinessObject;
  mBoDRows, mDocRowBatches: TNxCustomBusinessMonikerCollection;
  mStoreCard_ID: string;
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
          ALog:= ALog + 'CreateReceiptCard - storecard_id missing' + nxCrLf;
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
          if (ARowsTable.FieldByName('Quantity').AsFloat > 0) and (not(NxIsBlank(ARowsTable.FieldByName('StoreBatchName').AsString))) then
          begin
            mRowBatch:= mDocRowBatches.AddNewObject;
            if NxIsEmptyOID(ARowsTable.FieldByName('StoreBatch_ID').AsString) and (not(NxIsBlank(ARowsTable.FieldByName('StoreBatchName').AsString))) then
            begin
              mRowBatch.SetFieldValueAsBoolean('NewBatch', True);
              mRowBatch.SetFieldValueAsString('NewBatchName', ARowsTable.FieldByName('StoreBatchName').AsString);
              if ARowsTable.FieldByName('ExpireDate').AsDateTime > 0 then
                mRowBatch.SetFieldValueAsDateTime('NewBatchExpirationDate$DATE', ARowsTable.FieldByName('ExpireDate').AsDateTime);
            end else
              mRowBatch.SetFieldValueAsString('StoreBatch_ID', ARowsTable.FieldByName('StoreBatch_ID').AsString);
            mRowBatch.SetFieldValueAsFloat('Quantity', ARowsTable.FieldByName('Quantity').AsFloat);

            mQuantity:= mQuantity + ARowsTable.FieldByName('Quantity').AsFloat;
          end else
            mQuantity:= 1;

          Inc(mCounter);
          if mCounter >= 500 then
          begin
            mRowBO.SetFieldValueAsFloat('Quantity', mQuantity);
            mBO.Save;

            mBO:= AOS.CreateObject(Class_ReceiptCard);
            mBO.New;
            mBO.Prefill;
            mBO.SetFieldValueAsString('Firm_ID', cDEFAULT_FIRM_ID);
            mBoDRows:= mBO.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('Rows'));

            mCounter:= 0;
          end;

          ARowsTable.Next;
        end;
        mRowBO.SetFieldValueAsFloat('Quantity', mQuantity);
      end;
      if mCounter > 0 then
        mBO.Save;
    except
      NxShowSimpleMessage(ExceptionMessage, nil);
    end;
  finally
    mBO.Free;
  end;
end;

Function GetBatch_ID(var aOS:TNxCustomObjectSpace;var aStoreCard_ID, aBatchCode:string;var aDate:Extended;var aVersion:string):string;
var
 mBO:TNxCustomBusinessObject;
 mStoreBatch_ID:string;
begin
 Result:='';
 mStoreBatch_ID:=aOS.SQLSelectFirstAsString('Select id from storebatches where storecard_id='+QuotedStr(aStoreCard_ID)+' and name='+QuotedStr(aBatchCode),'');
 {if not(NxIsEmptyOID(mStoreBatch_ID)) then begin
    mBO:=aOS.CreateObject(Class_StoreBatch);
    mBO.Load(mStoreBatch_ID,nil);
    mBO.SetFieldValueAsDateTime('ExpirationDate$DATE',aDate);
    mBO.SetFieldValueAsString('X_Verze',aVersion);
    mBO.save;
    mbo.free;
 end else begin    }
  if NxIsEmptyOID(mStoreBatch_ID) then
  begin
    mBO:=aOS.CreateObject(Class_StoreBatch);
    mBO.New;
    mBO.prefill;
    mBO.SetFieldValueAsString('StoreCard_ID',aStoreCard_ID);
    mBO.SetFieldValueAsString('Name',aBatchCode);
    mBO.SetFieldValueAsDateTime('ExpirationDate$DATE',aDate);
    mBO.SetFieldValueAsString('X_Verze',aVersion);
    mBO.save;
    mStoreBatch_ID:=mBO.OID;
    mbo.free;
 end;
 Result:=mStoreBatch_ID;
end;


function CreateReceivedOrderAndBillOfDelivery(AOS: TNxCustomObjectSpace; AStore_ID: string; ARowsTable: TMemTable): TNxCustomBusinessObject;
var
  mRowBatch, mBO, mOutRow, mROBO: TNxCustomBusinessObject;
  mRORows, mBoDRows, mDocRowBatches: TNxCustomBusinessMonikerCollection;
  mStoreCard_ID: string;
  mQuantity: Extended;
  mImportManager: TNxDocumentImportManager;
  mParams: TNxParameters;
  i: integer;
begin
  Result:= nil;

  if (ARowsTable = nil) or ARowsTable.IsEmpty then
  begin
    NxShowSimpleMessage('Empty aggregated table', nil);
    Exit;
  end;

  ARowsTable.First;
  AOS.StartTransaction(taReadCommited);
  try
    mROBO:= AOS.CreateObject(Class_ReceivedOrder);
    try

      mROBO.New;
      mROBO.Prefill;
      mROBO.SetFieldValueAsString('DocQueue_ID', cRECEIVED_ORDER_DOCQUEUE_ID);
      mRORows:= mROBO.GetLoadedCollectionMonikerForFieldCode(mROBO.GetFieldCode('Rows'));

      while not ARowsTable.Eof do
      begin
        mStoreCard_ID:= ARowsTable.FieldByName('StoreCard_ID').AsString;

        mQuantity:= 0;

        mBO:= mRORows.AddNewObject;
        mBO.Prefill;
        mBO.SetFieldValueAsInteger('RowType', 3);
        mBO.SetFieldValueAsString('Store_ID', AStore_ID);
        mBO.SetFieldValueAsString('StoreCard_ID', mStoreCard_ID);
        mBO.SetFieldValueAsString('Division_ID', cDIVISION_ID);

        while not ARowsTable.Eof and (ARowsTable.FieldByName('StoreCard_ID').AsString = mStoreCard_ID) do
        begin
          if ARowsTable.FieldByName('Quantity').AsFloat > 0 then
          begin
            mQuantity:= mQuantity + ARowsTable.FieldByName('Quantity').AsFloat;
          end;
          ARowsTable.Next;
        end;
        mBO.SetFieldValueAsFloat('Quantity', mQuantity);

        //ARowsTable.Next;
      end;

      mROBO.Save;

      mParams:= TNxParameters.Create;
      mImportManager:= NxCreateDocumentImportManager(AOS, Class_ReceivedOrder, Class_BillOfDelivery);
      try
        mParams.GetOrCreateParam(dtString, 'DocQueue_ID').AsString:= cBILL_OF_DELIVERY_DOCQUEUE_ID;

        mImportManager.AddInputDocument_1(mROBO);
        mImportManager.SelectedHeader:= mROBO;
        mImportManager.LoadParams(mParams);
        mImportManager.Execute;

        mBoDRows:= mImportManager.OutputDocument.GetLoadedCollectionMonikerForFieldCode(mImportManager.OutputDocument.GetFieldCode('Rows'));
        for i:= 0 to mBoDRows.Count -1 do
        begin
          mOutRow:= mBoDRows.BusinessObject[i];
          mDocRowBatches:= mOutRow.GetLoadedCollectionMonikerForFieldCode(mOutRow.GetFieldCode('DocRowBatches'));

          ARowsTable.First;
          while not ARowsTable.Eof do
          begin
            if (ARowsTable.FieldByName('StoreCard_ID').AsString = mOutRow.GetFieldValueAsString('StoreCard_ID')) and (ARowsTable.FieldByName('Quantity').AsFloat > 0) then
            begin
              mRowBatch:= mDocRowBatches.AddNewObject;
              mRowBatch.SetFieldValueAsString('StoreBatch_ID', ARowsTable.FieldByName('StoreBatch_ID').AsString);
              mRowBatch.SetFieldValueAsFloat('Quantity', ARowsTable.FieldByName('Quantity').AsFloat);
            end;
            ARowsTable.Next;
          end;
        end;

        Result:= mImportManager.OutputDocument;
      finally
        mParams.Free;
        mImportManager.Free;
      end;
      AOS.Commit;
    finally
      mROBO.Free;
    end;
  except
    AOS.RollBack;
    NxShowSimpleMessage(ExceptionMessage, nil);
  end;
end;



begin
end.