{
Triggered after the initialization of an agenda/form. SiteContext is already available for the form at that moment.
}
procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TBasicAction;
begin
  mAction:= Self.GetNewAction;
  mAction.Name:= 'actLoadInventoryXLSX';
  mAction.Caption:= '##Load inventory (XLSX)##';
  mAction.Category:= 'tablist';
  mAction.OnExecute:= @LoadInventory_XLSX;
end;


procedure LoadInventory_XLSX(Sender: TComponent);
var
  mSite: TSiteForm;
  mOS: TNxCustomObjectSpace;
  mSCBO: TNxCustomBusinessObject;
  i, mRowCount, mSC_Category: integer;
  mFileName: string;
  mExcel, mWorkbook, mWorksheet, mUsedRange: variant;
  mDIPBO, mMIPBO, mDIPRowBO: TNxCustomBusinessObject;
  mEAN, mBatchName, mQUnit, mStoreCard_ID, mStoreBatch_ID, mMIPRow_ID, mDIPRow_ID: string;
  mQuantity: Extended;
  mLogList, mIDsList: TStringList;
begin
mSite:= Sender.Site;
  mOS:= mSite.BaseObjectSpace;

  if not SelectImportFile(mSite, mFileName) then exit;

  try
    mExcel:= CreateOleObject('Excel.Application');
  except
    NxShowSimpleMessage('Excel not installed', nil);
    exit;
  end;

  mLogList:= TStringList.Create;
  mDIPBO:= TDynSiteForm(mSite).CurrentObject;
  try
    mExcel.Visible:= false;
    mWorkbook:= mExcel.Workbooks.Open(mFileName);

    try
      mWorksheet := mWorkbook.Worksheets[1];
      mUsedRange := mWorksheet.UsedRange;
      mRowCount := mUsedRange.Rows.Count;
      WaitWin.StartProgress('Import', 'Import', mRowCount);
      for i:= 2 to mRowCount do
      begin
        mEAN:= Trim(VarToStr(mUsedRange.Cells[i, 1].Value));
        mBatchName:= Trim(VarToStr(mUsedRange.Cells[i, 2].Value));
        //mQuantity:= StrToFloat(Trim(VarToStr(mUsedRange.Cells[i, 3].Value)));

        if not TryStrToFloat(Trim(VarToStr(mUsedRange.Cells[i, 3].Value)), mQuantity) then
        begin
          mLogList.Add(Format('Row %d: not valid quantity', [i]));
          Continue;
        end;

        mStoreCard_ID:= mOS.SQLSelectFirstAsString(Format(
          ' SELECT A.ID as ID ' +//, B.ID as UnitID, C.ID as EANID '+
          ' FROM StoreCards A, StoreUnits B, StoreEANs C '+
          ' WHERE '+
          ' (B.Parent_ID = A.ID) and (C.Parent_ID = B.ID) and (C.EAN = ''%s'') and (A.Hidden = ''N'') ',
          [mEAN]));

        if NxIsEmptyOID(mStoreCard_ID) then
        begin
          mLogList.Add(mEAN + ' - StoreCard not found.');
          continue;
        end;

        mSCBO:= mOS.CreateObject(Class_StoreCard);
        try
          mSCBO.Load(mStoreCard_ID, nil);
          mQUnit:= mSCBO.GetFieldValueAsString('MainUnitCode');
          mSC_Category:= mSCBO.GetFieldValueAsInteger('Category');
        finally
          mSCBO.Free;
        end;

        mDIPRow_ID:= '';

        mIDsList:= TStringList.Create;
        try
          TNxPartialInvProtocol(mDIPBO).StoreCards_Find(mStoreCard_ID, '', mIDsList);
          if mIDsList.Count = 0 then
          begin
            if mSC_Category in [1,2] then
              mDIPRow_ID:= TNxPartialInvProtocol(mDIPBO).StoreCards_Add(mStoreCard_ID)
            else
              mDIPRow_ID:= TNxPartialInvProtocol(mDIPBO).StoreCards_Add(mStoreCard_ID, '', mQuantity);
          end else
          begin
            mDIPRow_ID:= mIDsList[0];
          end;
        finally
          mIDsList.Free;
        end;

        if mSC_Category in [1,2] then
        begin
          mStoreBatch_ID:= mOS.SQLSelectFirstAsString(Format(
            ' SELECT ID FROM StoreBatches WHERE StoreCard_ID = ''%s'' AND Name = ''%s'' AND Hidden = ''N'' ',
            [mStoreCard_ID, mBatchName]));

          if NxIsEmptyOID(mStoreBatch_ID) then
          begin
            mLogList.Add(mBatchName + ' - StoreBatch not found.');
            continue;
          end;

          mDIPRowBO:= mOS.CreateObject(Class_PartialInvProtocolRow);
          try
            mDIPRowBO.Load(mDIPRow_ID, nil);
            TNxPartialInvProtocolRow(mDIPRowBO).StoreBatches_Add(mStoreBatch_ID, '', mQuantity);
          finally
            mDIPRowBO.Free;
          end;
        end;
        WaitWin.StepIt;
      end;
      if mLogList.Count > 0 then
        NxShowEditorSite(mSite.SiteContext, mLogList.Text, True);
    finally
      WaitWin.Stop;
      if not VarIsEmpty(mWorkbook) then
        mWorkbook.Close;
      mWorkbook:= nil;
    end;
  finally
    mDIPBO.Free;
    mLogList.Free;

    if not VarIsEmpty(mExcel) then
      mExcel.Quit;
    mExcel := nil;
    mWorksheet:= nil;
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
    mOpenDialog.Filter := 'file (*.xls,*.xlsx)|*.XLS;*.xlsx;';
    if not mOpenDialog.Execute(ASite) then exit;

    AFileName:= mOpenDialog.FileName;
    Result:= True;
  finally
    mOpenDialog.Free;
  end;
end;



begin
end.