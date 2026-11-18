procedure FormCreate_Hook(Self: TSiteForm);
var
  mAction: TMultiAction;
begin
  mAction := Self.GetNewMultiAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := 'Import z CSV';
  mAction.Items.Add('Import TXT (K.S. Rož.)');
  mAction.Hint := 'Import z textového souboru';
  mAction.Category := 'tabDetail';
  mAction.OnExecuteItem := @ImportTXT_OnExecute;
//  mAction.OnUpdate := @ImportTXT_OnUpdate;
end;


procedure ImportTXT_OnExecute(Sender : TComponent; Index : integer);
var
  mSite : TSiteForm;
  mOpenDlg : TOpenDialog;
  mList : TStringList;
  mBO : TNxCustomBusinessObject;
  mGRows : TMultiGrid;
begin
  mSite := NxFindSiteForm(TComponent(Sender));
  if not(TDynSiteForm(mSite).Edit) then begin
    NxShowSimpleMessage('Nejste ve stavu editace, řádky nepůjde vložit.',mSite);
    exit;
  end;
  mOpenDlg := TOpenDialog.Create(Sender);
  mOpenDlg.Title := 'Import dat...';
  mOpenDlg.Filter := 'Soubory CSV (*.csv)| *.csv';
  try
    if mOpenDlg.Execute then begin
      mList := TStringLIst.Create;
      try
        mList.LoadFromFile(mOpenDlg.FileName);
        //Import_AddRows(ARows : TNxCustomBusinessMonikerCollection; AList : TStringList; ADivision_ID : string; AStore_ID : string)
        mBO := TDynSiteForm(mSite).CurrentObject;
        if Index = 0 then
          Import_AddRows(mBO.GetCollectionMonikerForFieldCode(mBO.GetFieldCode('Rows')), mList, '1000000101', '2000000101');
        // po přidání řádku provedu refresh
        mGRows := TMultiGrid(NxFindChildControl(NxGetSiteAppForm(mSite), 'grdRows'));
        if Assigned(mGRows) then
            mGRows.DataSource.DataSet.Refresh;
      finally
        mList.Free;
      end;
      NxShowSimpleMessage('Import dokončen.',msite);
    end else
      NxShowSimpleMessage('Import přerušen.',msite);
  finally
    mOpenDlg.Free;
  end;
end;


procedure ImportTXT_OnUpdate(Sender : TComponent);
var
  mSite : TSiteForm;
begin
  if Sender is TComponent then begin
    mSite := NxFindSiteForm(TComponent(Sender));
    if Assigned(mSite) then begin
      if mSite is TDynSiteForm then begin
        TBasicAction(Sender).Enabled := TDynSiteForm(mSite).edit;
      end;
    end;
  end
end;




procedure Import_AddRows(ARows : TNxCustomBusinessMonikerCollection; AList : TStringList; ADivision_ID : string; AStore_ID : string);
var
  i : Integer;
  mRowBO,mprijemkaSN : TNxCustomBusinessObject;
  mprijemkarowsSN: TNxCustomBusinessMonikerCollection;
  mRowTxt, mStoreCard_ID, mStoreCardCode,mStoreCardType1,mStoreCardType2,mStoreCardName, mShortName,mStoreCode, mStore_ID : string;
  mBatchCode:String;
  mQuantity, mUnitPrice : double;
  mOS:TNxCustomObjectSpace;
begin
  for i := 0 to AList.Count - 1 do begin
    mRowTxt := Alist.strings[i];
    mShortName := NxTrapStr(mRowTxt, ';');
    mStoreCardCode := NxTrapStr(mRowTxt, ';');
    mStoreCardName := NxTrapStr(mRowTxt, ';');
    mStoreCardType1 := NxTrapStr(mRowTxt, ';');
    mStoreCardType2 := NxTrapStr(mRowTxt, ';');
    mQuantity:= NxIBStrToFloat(NxTrapStr(mRowTxt, ';'));
    mUnitPrice:= NxIBStrToFloat(NxTrapStr(mRowTxt, ';'));
    mStoreCode := NxTrapStr(mRowTxt, ';');
    mos:=arows.ObjectSpace;
    mStoreCard_ID:=scrGetOrder2_ID(mos,mShortName);
    if NxIsEmptyOID(mStoreCard_ID) then mStoreCard_ID:=scrGetOrder_ID(mos,mStoreCardCode);
    mStore_ID:=mOS.SQLSelectFirstAsString('Select id from stores where code='+QuotedStr(mStoreCode),'');
    if (mQuantity > 0) and not(NxIsEmptyOID(mstorecard_ID)) then begin
      mRowBO := ARows.AddNewObject;
      mRowBO.Prefill;
      mRowBO.SetFieldValueAsInteger('RowType', 3);
      if not(NxIsEmptyOID(mstore_id)) then
        mRowBO.SetFieldValueAsString('Store_ID', mStore_ID) else
       mRowBO.SetFieldValueAsString('Store_ID', AStore_ID);
      mRowBO.SetFieldValueAsString('StoreCard_ID', mStoreCard_ID);
      mRowBO.SetFieldValueAsString('Division_ID', ADivision_ID);
      mRowBO.SetFieldValueAsFloat('Quantity', mQuantity);
      mRowBO.SetFieldValueAsFloat('UnitPrice', mUnitPrice);
    end;
  end;
end;
function scrGetOrder_ID(AOS : TNxCustomObjectSpace; AFieldname : string) : string;
const
  cSQL = 'SELECT ID FROM StoreCards WHERE Code=''%s'' and hidden=''N''';
var
  mList : TStringList;
begin
  mList := TStringList.create;
  try
    AOS.SQLSelect(Format(cSQL, [AFieldName]), mList);
    if mList.Count > 0 then
      Result := mList.Strings[0]
      else Result:=''
  finally
    mList.Free;
  end;
end;

function scrGetOrder2_ID(AOS : TNxCustomObjectSpace; AFieldname : string) : string;
const
  cSQL = 'SELECT ID FROM StoreCards WHERE ShortName=''%s'' and hidden=''N''';
var
  mList : TStringList;
begin
  mList := TStringList.create;
  try
    AOS.SQLSelect(Format(cSQL, [AFieldName]), mList);
    if mList.Count > 0 then
      Result := mList.Strings[0]
      else Result:=''
  finally
    mList.Free;
  end;
end;

begin
end.
