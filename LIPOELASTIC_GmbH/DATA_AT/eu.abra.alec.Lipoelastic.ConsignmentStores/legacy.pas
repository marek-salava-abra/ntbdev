function GetStoreCardIDFromTokens(AOS: TNxCustomObjectSpace; ATokenList: TStringList): string;
var
  mIndex: integer;
begin
  Result:= '';

  mIndex:= ATokenList.IndexOfName('01');
  if mIndex <> -1 then
  begin
    //Zkusíme s EANem tak jak je
    Result:= AOS.SQLSelectFirstAsString(Format(
      ' SELECT SU.Parent_ID FROM StoreEANs SE '+
      ' JOIN StoreUnits SU ON SU.ID = SE.Parent_ID '+
      ' WHERE SE.EAN = ''%s''', [ATokenList.ValueFromIndex(mIndex)]));

    //Zkusíme s EANem ořezeným o uvozující nuly
    if NxIsEmptyOID(Result) then
      Result:= AOS.SQLSelectFirstAsString(Format(
      ' SELECT SU.Parent_ID FROM StoreEANs SE '+
      ' JOIN StoreUnits SU ON SU.ID = SE.Parent_ID '+
      ' WHERE SE.EAN = ''%s''', [NxTrimL(ATokenList.ValueFromIndex(mIndex), '0')]));
  end;

  if NxIsEmptyOID(Result) then
  begin
    mIndex:= ATokenList.IndexOfName('10');
    if mIndex <> -1 then
      Result:= AOS.SQLSelectFirstAsString(Format('SELECT SB.StoreCard_ID FROM StoreBatches SB WHERE SB.Name = ''%s''', [ATokenList.ValueFromIndex(mIndex)]));
  end;

  if NxIsEmptyOID(Result) then
  begin
    mIndex:= ATokenList.IndexOfName('Code');
    if mIndex <> -1 then
      Result:= AOS.SQLSelectFirstAsString(Format('SELECT SC.ID FROM StoreCards SC WHERE SC.Code = ''%s''', [ATokenList.ValueFromIndex(mIndex)]));
  end;
end;


function GetStoreBatchIDFromTokens(AOS: TNxCustomObjectSpace; AStoreCard_ID: string; ATokenList: TStringList): string;
var
  mIndex: integer;
begin
  Result:= '';

  mIndex:= ATokenList.IndexOfName('10');
  if mIndex <> -1 then
    Result:= AOS.SQLSelectFirstAsString(Format('SELECT ID FROM StoreBatches WHERE StoreCard_ID = ''%s'' AND Name = ''%s''', [AStoreCard_ID, ATokenList.ValueFromIndex(mIndex)]));
end;


 {
      for i:= 0 to mList.Count -1 do
      begin
        //Protože chodí jako mix GS1 datamatrixů a interních kódů
        if IsGS1BarCode(mList.Names[i]) then
        begin
          mTokens := TokenizeGS1(SanitizeGS1String(mList.Names[i]), mAIMap);
          try
            AddBillOfDeliveryRow(mBoDRows, mStoreBO.OID, mTokens, NxIBStrToFloat(mList.ValueFromIndex[i]));
            mLog:= mLog + mTokens.Text + nxCrLf;
          finally
            mTokens.Free;
          end;
        end else
        begin
          BarcodeSpecialParse(mList.Names[i], mDataSet);
          try
            AddBillOfDeliveryRow(mBoDRows, mStoreBO.OID, mTokens, NxIBStrToFloat(mList.ValueFromIndex[i]));
            mLog:= mLog + mTokens.Text + nxCrLf;
          finally
            mTokens.Free;
          end;
        end;
      end;
      }

{
procedure ConsignmentStoresImport(Sender: TComponent);
var
  mSite: TSiteForm;
  mOS: TNxCustomObjectSpace;
  mStoreBO, mBoDBO, mBoDRow: TNxCustomBusinessObject;
  mBoDRows: TNxCustomBusinessMonikerCollection;
  mOpenDialog: TOpenDialog;
  mFileName, mFileExt, mLog: string;
  mList, mTokens, mAIMap: TStringList;
  mDataSet: TMemoryDataset;
  i: integer;
begin
  mSite:= Sender.Site;
  mOS:= mSite.BaseObjectSpace;

  mFileName:= '';
  mFileExt:= '';
  mLog:= '';

  mOpenDialog:= TOpenDialog.Create(mSite);
  try
    mOpenDialog.Filter := 'Soubor importu (*.xls,*.xlsx,*.txt,*.csv)|*.XLS;*.xlsx;*.txt;*.csv';
    if not mOpenDialog.Execute(mSite) then exit;

    mFileName:= mOpenDialog.FileName;
  finally
    mOpenDialog.Free;
  end;

  mAIMap := BuildAIMap;

  mStoreBO:= TBusRollSiteForm(mSite).CurrentObject;
  mDataSet:= TMemoryDataset.Create(nil);
  try
    //Připravíme DataSet
    PrepareDataSet(mDataSet, mLog);

    mDataSet.Open;
    //mDataSet.First;
    //mDataSet.Edit;

    //Importujeme základní data do datasetu
    mFileExt:= LowerCase(ExtractFileExt(mFileName));
    case mFileExt of
      '.xls', '.xlsx': LoadXLSXToList(mFileName, mDataSet);
      '.csv', '.txt': LoadCSVToList(mFileName, mDataSet);
    end;

    //Projdeme dataset a rozpadneme datamatrix na jednotlivé části
    mDataSet.First;
    while not mDataSet.Eof do
    begin
      if IsGS1BarCode(mDataSet.FieldByName('Barcode').AsString) then
      begin
        TokenizeGS1ToDataSet(SanitizeGS1String(mDataSet.FieldByName('Barcode').AsString), mAIMap, mDataSet);
        GetIDsAndFillDataSet(mOS, mDataSet);
      end else
      begin
        BarcodeSpecialParse(mDataSet.FieldByName('Barcode').AsString, mDataSet);
        GetIDsAndFillDataSet(mOS, mDataSet);
      end;

      mDataSet.Next;
    end;

    //Nachystáme dodací list a naplníme řádky
    mBoDBO:= mOS.CreateObject(Class_BillOfDelivery);
    try
      mBoDBO.New;
      mBoDBO.Prefill;
      mBoDRows:= mBoDBO.GetLoadedCollectionMonikerForFieldCode(mBoDBO.GetFieldCode('Rows'));

      mDataSet.First;
      while not mDataSet.Eof do
      begin
        AddBillOfDeliveryRow(mBoDRows, mStoreBO.OID, mDataSet);
        mDataSet.Next;
      end;

      //Zobrazíme doklad před uložením
      TDynSiteForm.ShowDynFormWithNewDocument(Site_BillOfDeliveries, mSite.SiteContext, mBoDBO, mSite);

    finally
      mBoDBO.Free;
    end;
    NxShowEditorSite(mSite.SiteContext, mLog, True);
  finally
    mAIMap.Free;
    mDataSet.Free;
  end;
end;
}

{
procedure AddBillOfDeliveryRow(var ARows: TNxCustomBusinessMonikerCollection; AStore_ID: string; var ADataset: TDataset);
var
  mBO, mRowBatch: TNxCustomBusinessObject;
  mDocRowBatches: TNxCustomBusinessMonikerCollection;
  mStoreCard_ID, mStoreBatch_ID: string;
  i: Integer;
  mRowFound: Boolean;
begin
  mStoreCard_ID:= ADataset.FieldByName('StoreCard_ID').AsString;
  if NxIsEmptyOID(mStoreCard_ID) then exit;

  ADataset.Edit;
  ADataset.FieldByName('StoreCard_ID').AsString:= mStoreCard_ID;
  ADataset.Post;

  if ADataset.FieldByName('Quantity').AsFloat <= 0 then exit;

  mRowFound:= false;

  for i:= 0 to ARows.Count -1 do
  begin
    if ARows.BusinessObject[i].GetFieldValueAsString('StoreCard_ID') = mStoreCard_ID then
    begin
      mBO:= ARows.BusinessObject[i];
      mBO.SetFieldValueAsFloat('Quantity', mBO.GetFieldValueAsFloat('Quantity') + ADataset.FieldByName('Quantity').AsFloat);
      mRowFound:= true;
      break;
    end;
  end;

  if not mRowFound then
  begin
    mBO:= ARows.AddNewObject;
    mBO.Prefill;
    mBO.SetFieldValueAsInteger('RowType', 3);
    mBO.SetFieldValueAsString('Store_ID', AStore_ID);
    mBO.SetFieldValueAsString('StoreCard_ID', mStoreCard_ID);
    mBO.SetFieldValueAsFloat('Quantity', ADataset.FieldByName('Quantity').AsFloat);
    mBO.SetFieldValueAsString('Division_ID', cDIVISION_ID);
  end;

  mStoreBatch_ID:= ADataset.FieldByName('StoreBatch_ID').AsString;
  if not NxIsEmptyOID(mStoreBatch_ID) then
  begin
    mDocRowBatches:= mBO.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('DocRowBatches'));
    mRowBatch:= mDocRowBatches.AddNewObject;
    mRowBatch.SetFieldValueAsString('StoreBatch_ID', mStoreBatch_ID);
    mRowBatch.SetFieldValueAsFloat('Quantity', ADataset.FieldByName('Quantity').AsFloat);
  end;
end;
}



begin
end.