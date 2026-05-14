uses 'eu.masa.import.progress';


{procedure FormCreate_Hook(Self: TSiteForm);
var
  mAction: TMultiAction;
begin
  mAction := Self.GetNewMultiAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := 'Import CSV';
  mAction.Items.Add('Ze skladu');
  mAction.Hint := 'Import z textového souboru';
  mAction.Category := 'tabDetail';
  mAction.OnExecuteItem := @ImportTXT_OnExecute;
end;   }


procedure ImportTXT_OnExecute(Sender : TComponent; Index : integer);
var
  mSite : TSiteForm;
  mOpenDlg : TOpenDialog;
  mList : TStringList;
  mBO : TNxCustomBusinessObject;
  mGRows : TMultiGrid;
  mStore_ID : string;
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
        Import_AddRows(mBO.GetCollectionMonikerForFieldCode(mBO.GetFieldCode('Rows')), mList, mSite);
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


function scrStorecard_ID(AOS : TNxCustomObjectSpace; AOrderRow_ID : string) : string;
const
  cSQL = 'SELECT ID FROM Storecards where code=''%s'' and hidden=''N'' ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    Result:='';
    AOS.SQLSelect(Format(cSQL, [AOrderRow_ID]), mList);
    if mList.Count > 0 then
      Result := mList.Strings[0]
  finally
    mList.Free;
  end;
end;

function scrStore_ID(AOS : TNxCustomObjectSpace; AOrderRow_ID : string) : string;
const
  cSQL = 'SELECT ID FROM Stores where code=''%s'' and hidden=''N'' ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    Result:='';
    AOS.SQLSelect(Format(cSQL, [AOrderRow_ID]), mList);
    if mList.Count > 0 then
      Result := mList.Strings[0]
  finally
    mList.Free;
  end;
end;

procedure Import_AddRows(ARows : TNxCustomBusinessMonikerCollection; AList : TStringList; aSite:TSiteForm);
var
  i : Integer;
  mRowBO : TNxCustomBusinessObject;
  mRowTxt, mStoreCard_ID, mStoreCard_Code, mStore_ID, mdivision_id : string;
  mQuantity, mprice : double;
begin
  ProgressInit(aSite, 'import položek...', aList.count);
  for i := 0 to AList.Count - 1 do begin
    mRowTxt := Alist.strings[i];
    mStore_ID:= NxTrapStrTrim(mRowTxt, ';');
    mStoreCard_id:= NxTrapStrTrim(mRowTxt, ';');
    mQuantity := NxIBStrToFloat(NxToken(mRowTxt, ';'));
    mDivision_ID:= NxTrapStrTrim(mRowTxt, ';');
    if (mQuantity > 0) and not(NxIsEmptyOID(mStoreCard_ID))then begin
      mRowBO := ARows.AddNewObject;
      mRowBO.Prefill;
      //mRowBO.SetFieldValueAsInteger('RowType', 3);
      mRowBO.SetFieldValueAsString('Store_ID', mStore_ID);
      mRowBO.SetFieldValueAsString('StoreCard_ID', mStoreCard_ID);
      mRowBO.SetFieldValueAsFloat('Quantity', mQuantity);
      mRowBO.SetFieldValueAsString('Division_ID',mdivision_id);
    end;
  ProgressSetPos(i+1);
  end;
  ProgressDispose();
end;

begin
end..