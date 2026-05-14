uses '.fce';
procedure FormCreate_Hook(Self: TSiteForm);
var
  mAction: TBasicAction;
begin
   mAction := Self.GetNewAction;
   mAction.ShowControl := True;
   mAction.ShowMenuItem := True;
   mAction.Caption := 'Import CSV';
   mAction.Hint := 'Import CSV, struktura kód;množství;koeficient';
   mAction.Category := 'tabDetail';
   mAction.OnExecute := @ImportData;
   mAction.OnUpdate := @OnUpdate;
end;


procedure ImportData(Sender : TComponent);
var
  mSite : TSiteForm;
  mOpenDlg : TOpenDialog;
  mList : TStringList;
  mBO : TNxCustomBusinessObject;
  mGRows : TMultiGrid;
  mStore_ID, mDivision_ID : string;
begin

  mSite := TComponent(Sender).DynSite;
  mOpenDlg := TOpenDialog.Create(Sender);
  try
   if GetData(msite, mStore_ID, mDivision_ID) then begin
    if mOpenDlg.Execute then begin
      mList := TStringLIst.Create;
      try
        mList.LoadFromFile(mOpenDlg.FileName);
        //Import_AddRows(ARows : TNxCustomBusinessMonikerCollection; AList : TStringList; ADivision_ID : string; AStore_ID : string)
        mBO := TDynSiteForm(mSite).CurrentObject;
          Import_AddRows(mBO.GetCollectionMonikerForFieldCode(mBO.GetFieldCode('Rows')), mList, mDivision_ID, mStore_ID);
        mGRows := TMultiGrid(NxFindChildControl(NxGetSiteAppForm(mSite), 'grdRows'));
        if Assigned(mGRows) then
            mGRows.DataSource.DataSet.Refresh;
      finally
        mList.Free;
      end;
      ShowMessage('Import dokončen.');
    end else
      ShowMessage('Import přerušen.');
   end;
  finally
    mOpenDlg.Free;
  end;
end;


procedure Import_AddRows(ARows : TNxCustomBusinessMonikerCollection; AList : TStringList; ADivision_ID : string; AStore_ID : string);
var
  i : Integer;
  mRowBO : TNxCustomBusinessObject;
  mRowTxt, mStoreCard_ID, mStoreCard_Code : string;
  mQuantity, mKoef : double;
  mTotalKoef:Extended;
begin
  mTotalKoef:=100;
  for i := 1 to AList.Count - 1 do begin
    mRowTxt := Alist.strings[i];
    mStoreCard_Code:= NxTrapStrTrim(mRowTxt,';');
    mQuantity := 0;
    mQuantity := NxIBStrToFloat(NxTrapStrTrim(mRowTxt,';'));
    mkoef := 0;
    mKoef := NxIBStrToFloat(NxTrapStrTrim(mRowTxt,';'));
    if Length(mStoreCard_Code)=4 then mStoreCard_Code:='0'+mStoreCard_Code;
    mStoreCard_ID:=scrStorecard_ID(arows.ObjectSpace, mstorecard_code);
    if (mQuantity > 0) and not(NxIsEmptyOID(mStoreCard_ID))then begin
      mRowBO := ARows.AddNewObject;
      mRowBO.Prefill;
      //mRowBO.SetFieldValueAsInteger('RowType', 3);
      mTotalKoef:=mTotalKoef-mKoef;
      mRowBO.SetFieldValueAsString('Store_ID', AStore_ID);
      mRowBO.SetFieldValueAsString('StoreCard_ID', mStoreCard_ID);
      mRowBO.SetFieldValueAsString('Division_ID', ADivision_ID);
      mRowBO.SetFieldValueAsFloat('Quantity', mQuantity);
      if (NxGetActualUserID(ARows.ObjectSpace)='SUPER00000') then
       NxShowSimpleMessage('počet records '+IntToStr(AList.count)+' hodnota i: '+IntToStr(i)+nxCrLf+'mKoef: '+FloatToStr(mKoef)+' mTotalKoef: '+FloatToStr(mTotalKoef),nil);
      if i<alist.count-1 then
      mrowbo.SetFieldValueAsFloat('PercentPriceTransformationCoef',mKoef)
      else begin
       if mTotalKoef=0 then
        mrowbo.SetFieldValueAsFloat('PercentPriceTransformationCoef',mKoef)
        else
        mrowbo.SetFieldValueAsFloat('PercentPriceTransformationCoef',mTotalKoef);
      end;
     // mRowBO.SetFieldValueAsFloat('UnitPrice',0);
     // mrowbo.SetFieldValueAsFloat('TotalPRice',mprice);
    end;
  end;
end;

function scrStorecard_ID(AOS : TNxCustomObjectSpace; aCode : string) : string;
const
  cSQL = 'SELECT ID FROM Storecards where code=''%s'' and hidden=''N'' ';
var
  mList : TStringList;
begin
  mList := TStringList.create;
  try
    Result:='';
    AOS.SQLSelect(Format(cSQL, [aCode]), mList);
    if mList.Count > 0 then
      Result := mList.Strings[0]
  finally
    mList.Free;
  end;
end;

begin
end.