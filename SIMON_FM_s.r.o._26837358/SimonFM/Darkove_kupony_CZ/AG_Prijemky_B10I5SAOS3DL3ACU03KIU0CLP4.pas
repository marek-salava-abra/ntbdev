procedure FormCreate_Hook(Self: TSiteForm);
var
  mAction: TMultiAction;
begin
  mAction := Self.GetNewMultiAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := 'Import  SN z TXT';
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
  mOpenDlg := TOpenDialog.Create(Sender);
  try
    if mOpenDlg.Execute then begin
      mList := TStringLIst.Create;
      try
        mList.LoadFromFile(mOpenDlg.FileName);
        //Import_AddRows(ARows : TNxCustomBusinessMonikerCollection; AList : TStringList; ADivision_ID : string; AStore_ID : string)
        mBO := TDynSiteForm(mSite).CurrentObject;
        if Index = 0 then
          Import_AddRows(mBO.GetCollectionMonikerForFieldCode(mBO.GetFieldCode('Rows')), mList, '3100000101', '1400000101');
        // po přidání řádku provedu refresh
        mGRows := TMultiGrid(NxFindChildControl(NxGetSiteAppForm(mSite), 'grdRows'));
        if Assigned(mGRows) then
            mGRows.DataSource.DataSet.Refresh;
      finally
        mList.Free;
      end;
      ShowMessage('Import dokončen.');
    end else
      ShowMessage('Import přerušen.');
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
  mRowTxt, mStoreCard_ID, mStoreCardCode : string;
  mBatchCode:String;
  mQuantity : double;
  mOS:TNxCustomObjectSpace;
begin
  for i := 0 to AList.Count - 1 do begin
    mRowTxt := Alist.strings[i];
    mBatchCode:= NxToken(mRowTxt, ';');
    mStoreCardCode := 'DPB0100S';
    mos:=arows.ObjectSpace;
    mStoreCard_ID:=scrGetOrder_ID(mos,mStoreCardCode);
    mQuantity := 1;

    if (mQuantity > 0) and not(NxIsEmptyOID(mstorecard_ID)) and not(NxIsBlank(mBatchCode)) then begin
      mRowBO := ARows.AddNewObject;
      mRowBO.Prefill;
      mRowBO.SetFieldValueAsInteger('RowType', 3);
      mRowBO.SetFieldValueAsString('Store_ID', AStore_ID);
      mRowBO.SetFieldValueAsString('StoreCard_ID', mStoreCard_ID);
      mRowBO.SetFieldValueAsString('Division_ID', ADivision_ID);
      mRowBO.SetFieldValueAsFloat('Quantity', mQuantity);
      mprijemkarowsSN:=mRowBO.GetCollectionMonikerForFieldCode(mRowBO.GetFieldCode('DocRowBatches'));
      mprijemkaSN:=mprijemkarowsSN.AddNewObject;
      mprijemkaSN.Prefill;
      mprijemkasn.SetFieldValueAsBoolean('NewBatch',true);
      mprijemkaSN.SetFieldValueAsString('NewBatchName',mBatchCode);
      mRowBO.SetFieldValueAsBoolean('CompletePrices',true);
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

begin
end.
