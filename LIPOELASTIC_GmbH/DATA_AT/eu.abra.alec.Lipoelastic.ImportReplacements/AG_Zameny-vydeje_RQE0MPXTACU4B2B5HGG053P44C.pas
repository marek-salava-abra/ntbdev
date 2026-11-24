const
  cACTION_NAME = 'actImportReplacementsXLSX';
  cACTION_CAPTION = '## Import replacements (XLSX) ##';
  cACTION_HINT =
    'Creates one outgoing and one linked incoming substitution for each batch difference';
  cACTION_CATEGORY = 'tabList';

  cSTORE_DIALOG_CAPTION = 'Select warehouse';
  cSTORE_LABEL_CAPTION = 'Warehouse:';
  cOK_BUTTON_CAPTION = 'OK';
  cCANCEL_BUTTON_CAPTION = 'Cancel';
  cSELECT_STORE_MESSAGE = 'Select a warehouse.';
  cSTORE_ROLL_TEXT_FIELD = 'Code';
  cSTORE_ROLL_CONNECTED_FIELD = 'Name';

  cSTORE_DIALOG_WIDTH = 520;
  cSTORE_DIALOG_HEIGHT = 150;
  cSTORE_LABEL_LEFT = 16;
  cSTORE_LABEL_TOP = 20;
  cSTORE_LABEL_WIDTH = 90;
  cSTORE_NAME_LABEL_LEFT = 230;
  cSTORE_NAME_LABEL_TOP = 20;
  cSTORE_NAME_LABEL_WIDTH = 260;
  cSTORE_ROLL_LEFT = 105;
  cSTORE_ROLL_TOP = 16;
  cSTORE_ROLL_WIDTH = 110;
  cOK_BUTTON_LEFT = 330;
  cCANCEL_BUTTON_LEFT = 415;
  cBUTTON_TOP = 65;
  cBUTTON_WIDTH = 75;

  cFIELD_ROWS = 'Rows';
  cFIELD_ROW_TYPE = 'RowType';
  cFIELD_STORE_ID = 'Store_ID';
  cFIELD_STORE_CARD_ID = 'StoreCard_ID';
  cFIELD_QUANTITY = 'Quantity';
  cFIELD_DOC_ROW_BATCHES = 'DocRowBatches';
  cFIELD_STORE_BATCH_ID = 'StoreBatch_ID';
  cFIELD_DOC_QUEUE_ID = 'DocQueue_ID';

  cEMPTY_STRING = '';
  cEMPTY_COUNT = 0;
  cFIRST_INDEX = 0;
  cSINGLE_ITEM_COUNT = 1;
  cPROGRESS_SEPARATOR = ' / ';
  cSTORE_ROW_TYPE = 3;
  cPIECE_QUANTITY = 1;
  cEAN_COLUMN = 1;
  cOLD_BATCH_COLUMN = 2;
  cNEW_BATCH_COLUMN = 3;
  cFIRST_WORKSHEET = 1;
  cFIRST_XLSX_ROW = 1;
  cOUTGOING_DOCUMENT_TYPE = '36';
  cINCOMING_DOCUMENT_TYPE = '37';
  cEAN_HEADER = 'ean';

  cOPEN_DIALOG_TITLE = 'Select XLSX file with batch replacements';
  cOPEN_DIALOG_FILTER = 'Excel workbook (*.xlsx)|*.xlsx';
  cEXCEL_PROG_ID = 'Excel.Application';
  cVALIDATION_PROGRESS_CAPTION = 'Validating XLSX';
  cCREATION_PROGRESS_CAPTION = 'Creating replacement documents';

  cERROR_NEW_DOCUMENT_HAS_ROWS = 'The new document already contains rows.';
  cERROR_LINKED_DOCUMENT_ROW_COUNT =
    'The linked document contains %d rows instead of one.';
  cERROR_DOCUMENT_ROW_BATCH_COUNT =
    'The document row contains %d batches instead of one.';
  cERROR_NO_INCOMING_QUEUE =
    'No default document queue is configured for incoming substitutions, ' +
    'and exactly one active queue could not be determined.';
  cERROR_INCOMING_NOT_CREATED =
    'The linked incoming substitution could not be created.';
  cERROR_EXCEL_NOT_INSTALLED = 'Microsoft Excel is not installed.';
  cERROR_MISSING_ROW_VALUE =
    'Row %d: EAN, original batch, or replacement batch is missing.';
  cERROR_STORE_CARD_NOT_FOUND =
    'Row %d: no store card was found for EAN "%s".';
  cERROR_OLD_BATCH_NOT_FOUND =
    'Row %d: original batch "%s" was not found for EAN "%s".';
  cERROR_NEW_BATCH_NOT_FOUND =
    'Row %d: replacement batch "%s" was not found for EAN "%s".';
  cERROR_SOURCE_ROW = 'Row %d (EAN "%s", batch "%s" -> "%s"): %s';
  cERROR_NO_OUTGOING_QUEUE =
    'No default document queue is configured for outgoing substitutions, ' +
    'and exactly one active queue could not be determined.';
  cERROR_XLSX_ROW = 'XLSX row %s: %s';
  cERROR_CREATION_ROLLED_BACK =
    'Document creation was cancelled and the transaction was rolled back: ';
  cERROR_IMPORT_FAILED = 'The import could not be completed: ';
  cRESULT_SUMMARY =
    'Created document pairs: %d, unchanged rows: %d, invalid rows: %d.';
  cRESULT_NO_DOCUMENTS = 'No documents were created.';

  cSQL_STORE_CARD_BY_EAN =
    ' SELECT SC.ID ' +
    ' FROM StoreCards SC ' +
    ' JOIN StoreUnits SU ON SU.Parent_ID = SC.ID ' +
    ' JOIN StoreEANs SE ON SE.Parent_ID = SU.ID ' +
    ' WHERE SC.Hidden = ''N'' ' +
    ' AND SE.EAN = %s';
  cSQL_STORE_BATCH_BY_NAME =
    ' SELECT ID FROM StoreBatches ' +
    ' WHERE Hidden = ''N'' ' +
    ' AND StoreCard_ID = %s ' +
    ' AND Name = %s';
  cSQL_SINGLE_ACTIVE_DOC_QUEUE =
    ' SELECT MIN(DQ.ID) ' +
    ' FROM DocQueues DQ ' +
    ' WHERE DQ.Hidden = ''N'' ' +
    ' AND DQ.DocumentType = %s ' +
    ' HAVING COUNT(*) = 1';


procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TBasicAction;
begin
  mAction:= Self.GetNewAction;
  mAction.Name:= cACTION_NAME;
  mAction.Caption:= cACTION_CAPTION;
  mAction.Hint:= cACTION_HINT;
  mAction.ShowControl:= True;
  mAction.ShowMenuItem:= True;
  mAction.Category:= cACTION_CATEGORY;
  mAction.OnExecute:= @ImportReplacements_XLSX;
end;


function SelectStoreDialog(ASite: TSiteForm; var AStore_ID: string): Boolean;
var
  mForm: TForm;
  mStoreLabel, mStoreNameLabel: TLabel;
  mStoreRoll: TRollComboEdit;
  mOKButton, mCancelButton: TButton;
  mModalResult: Integer;
begin
  Result:= False;
  AStore_ID:= cEMPTY_STRING;

  mForm:= TForm.Create(ASite);
  try
    mForm.BorderStyle:= bsDialog;
    mForm.Position:= poScreenCenter;
    mForm.Caption:= cSTORE_DIALOG_CAPTION;
    mForm.Width:= cSTORE_DIALOG_WIDTH;
    mForm.Height:= cSTORE_DIALOG_HEIGHT;

    mStoreLabel:= TLabel.Create(mForm);
    mStoreLabel.Parent:= mForm;
    mStoreLabel.Caption:= cSTORE_LABEL_CAPTION;
    mStoreLabel.Left:= cSTORE_LABEL_LEFT;
    mStoreLabel.Top:= cSTORE_LABEL_TOP;
    mStoreLabel.Width:= cSTORE_LABEL_WIDTH;

    mStoreNameLabel:= TLabel.Create(mForm);
    mStoreNameLabel.Parent:= mForm;
    mStoreNameLabel.Left:= cSTORE_NAME_LABEL_LEFT;
    mStoreNameLabel.Top:= cSTORE_NAME_LABEL_TOP;
    mStoreNameLabel.Width:= cSTORE_NAME_LABEL_WIDTH;

    mStoreRoll:= TRollComboEdit.Create(mForm);
    mStoreRoll.Parent:= mForm;
    mStoreRoll.ClassID:= Roll_Stores;
    mStoreRoll.Complete:= True;
    mStoreRoll.Prefilling:= pmNone;
    mStoreRoll.TextField:= cSTORE_ROLL_TEXT_FIELD;
    mStoreRoll.Left:= cSTORE_ROLL_LEFT;
    mStoreRoll.Top:= cSTORE_ROLL_TOP;
    mStoreRoll.Width:= cSTORE_ROLL_WIDTH;
    mStoreRoll.ConnectedControl:= mStoreNameLabel;
    mStoreRoll.ConnectedControlField:= cSTORE_ROLL_CONNECTED_FIELD;

    mOKButton:= TButton.Create(mForm);
    mOKButton.Parent:= mForm;
    mOKButton.Caption:= cOK_BUTTON_CAPTION;
    mOKButton.Default:= True;
    mOKButton.ModalResult:= mrOk;
    mOKButton.Left:= cOK_BUTTON_LEFT;
    mOKButton.Top:= cBUTTON_TOP;
    mOKButton.Width:= cBUTTON_WIDTH;

    mCancelButton:= TButton.Create(mForm);
    mCancelButton.Parent:= mForm;
    mCancelButton.Caption:= cCANCEL_BUTTON_CAPTION;
    mCancelButton.Cancel:= True;
    mCancelButton.ModalResult:= mrCancel;
    mCancelButton.Left:= cCANCEL_BUTTON_LEFT;
    mCancelButton.Top:= cBUTTON_TOP;
    mCancelButton.Width:= cBUTTON_WIDTH;

    repeat
      mModalResult:= mForm.ShowModal(ASite.GetParentForm);
      if mModalResult <> mrOk then
        exit;

      AStore_ID:= mStoreRoll.DataText;
      if Trim(AStore_ID) = cEMPTY_STRING then
        NxShowSimpleMessage(cSELECT_STORE_MESSAGE, mForm)
      else
        Result:= True;
    until Result;
  finally
    mForm.Free;
  end;
end;


procedure SetSingleReplacementRow(
  ADocumentBO: TNxCustomBusinessObject;
  AStore_ID, AStoreCard_ID, AStoreBatch_ID: string;
  ACreateRow: Boolean);
var
  mRowBO, mRowBatchBO: TNxCustomBusinessObject;
  mRows, mRowBatches: TNxCustomBusinessMonikerCollection;
begin
  mRows:= ADocumentBO.GetLoadedCollectionMonikerForFieldCode(
    ADocumentBO.GetFieldCode(cFIELD_ROWS));

  if ACreateRow then
  begin
    if mRows.Count <> cEMPTY_COUNT then
      RaiseException(cERROR_NEW_DOCUMENT_HAS_ROWS);

    mRowBO:= mRows.AddNewObject;
    mRowBO.Prefill;
  end else
  begin
    if mRows.Count <> cSINGLE_ITEM_COUNT then
      RaiseException(Format(
        cERROR_LINKED_DOCUMENT_ROW_COUNT,
        [mRows.Count]));
    mRowBO:= mRows.BusinessObject(cFIRST_INDEX);
  end;

  mRowBO.SetFieldValueAsInteger(cFIELD_ROW_TYPE, cSTORE_ROW_TYPE);
  mRowBO.SetFieldValueAsString(cFIELD_STORE_ID, AStore_ID);
  mRowBO.SetFieldValueAsString(cFIELD_STORE_CARD_ID, AStoreCard_ID);
  mRowBO.SetFieldValueAsFloat(cFIELD_QUANTITY, cPIECE_QUANTITY);

  mRowBatches:= mRowBO.GetLoadedCollectionMonikerForFieldCode(
    mRowBO.GetFieldCode(cFIELD_DOC_ROW_BATCHES));

  if mRowBatches.Count = cEMPTY_COUNT then
    mRowBatchBO:= mRowBatches.AddNewObject
  else
  begin
    if mRowBatches.Count <> cSINGLE_ITEM_COUNT then
      RaiseException(Format(
        cERROR_DOCUMENT_ROW_BATCH_COUNT,
        [mRowBatches.Count]));
    mRowBatchBO:= mRowBatches.BusinessObject(cFIRST_INDEX);
  end;

  mRowBatchBO.SetFieldValueAsString(cFIELD_STORE_BATCH_ID, AStoreBatch_ID);
  mRowBatchBO.SetFieldValueAsFloat(cFIELD_QUANTITY, cPIECE_QUANTITY);
end;


function CreateIncomingReplacement(
  AOS: TNxCustomObjectSpace;
  AOutgoingBO: TNxCustomBusinessObject;
  AStore_ID, AStoreCard_ID, ANewStoreBatch_ID: string): string;
var
  mParams: TNxParameters;
  mDIM: TNxDocumentImportManager;
  mIncomingBO: TNxCustomBusinessObject;
  mIncomingDocQueue_ID: string;
begin
  Result:= cEMPTY_STRING;
  mParams:= TNxParameters.Create;
  mDIM:= NxCreateDocumentImportManager(
    AOS, Class_OutgoingSubstitution, Class_IncomingSubstitution);
  try
    mDIM.AddInputDocument_1(AOutgoingBO);
    mDIM.SelectedHeader:= AOutgoingBO;
    mDIM.SaveParams(mParams);

    mParams.GetOrCreateParam(dtString, cFIELD_STORE_ID).AsString:= AStore_ID;

    // Use the user's default queue. If no default is configured, use an
    // active queue only when it can be determined unambiguously.
    mIncomingDocQueue_ID:=
      mParams.GetOrCreateParam(dtString, cFIELD_DOC_QUEUE_ID).AsString;
    if Trim(mIncomingDocQueue_ID) = cEMPTY_STRING then
      mIncomingDocQueue_ID:= AOS.SQLSelectFirstAsString(
        Format(
          cSQL_SINGLE_ACTIVE_DOC_QUEUE,
          [QuotedStr(cINCOMING_DOCUMENT_TYPE)]));

    if Trim(mIncomingDocQueue_ID) = cEMPTY_STRING then
      RaiseException(cERROR_NO_INCOMING_QUEUE);

    mParams.GetOrCreateParam(dtString, cFIELD_DOC_QUEUE_ID).AsString:=
      mIncomingDocQueue_ID;
    mDIM.LoadParams(mParams);
    mDIM.Execute;

    mIncomingBO:= mDIM.OutputDocument;
    if not Assigned(mIncomingBO) then
      RaiseException(cERROR_INCOMING_NOT_CREATED);

    mIncomingBO.ExplicitTransaction:= True;
    SetSingleReplacementRow(
      mIncomingBO,
      AStore_ID,
      AStoreCard_ID,
      ANewStoreBatch_ID,
      False);
    mIncomingBO.Save;
    Result:= mIncomingBO.OID;
  finally
    mDIM.Free;
    mParams.Free;
  end;
end;


procedure ImportReplacements_XLSX(Sender: TComponent);
var
  mSite: TSiteForm;
  mOS: TNxCustomObjectSpace;
  mOutgoingBO: TNxCustomBusinessObject;
  mOpenDialog: TOpenDialog;
  mLogList, mSourceRows, mStoreCardIDs: TStringList;
  mOldStoreBatchIDs, mNewStoreBatchIDs: TStringList;
  mExcel, mWorkbook, mWorksheet, mUsedRange: Variant;
  mFileName, mEAN, mOldBatchName, mNewBatchName: string;
  mStore_ID, mStoreCard_ID, mOldStoreBatch_ID, mNewStoreBatch_ID: string;
  mOutgoingDocQueue_ID: string;
  i, mRowCount, mCreated, mUnchanged, mSkipped: Integer;
  mShowResult, mProcessingFinished, mTransactionStarted: Boolean;
begin
  mSite:= TComponent(Sender).BusRollSite;
  mOS:= mSite.BaseObjectSpace;

  mStore_ID:= cEMPTY_STRING;
  if not SelectStoreDialog(mSite, mStore_ID) then
    exit;

  mLogList:= TStringList.Create;
  mSourceRows:= TStringList.Create;
  mStoreCardIDs:= TStringList.Create;
  mOldStoreBatchIDs:= TStringList.Create;
  mNewStoreBatchIDs:= TStringList.Create;
  mOutgoingDocQueue_ID:= cEMPTY_STRING;
  mCreated:= cEMPTY_COUNT;
  mUnchanged:= cEMPTY_COUNT;
  mSkipped:= cEMPTY_COUNT;
  mShowResult:= False;
  mProcessingFinished:= False;
  mTransactionStarted:= False;
  try
    mOpenDialog:= TOpenDialog.Create(mSite);
    try
      mOpenDialog.Title:= cOPEN_DIALOG_TITLE;
      mOpenDialog.Filter:= cOPEN_DIALOG_FILTER;
      if not mOpenDialog.Execute(mSite) then
        exit;
      mFileName:= mOpenDialog.FileName;
      mShowResult:= True;
    finally
      mOpenDialog.Free;
    end;

    try
      mExcel:= CreateOleObject(cEXCEL_PROG_ID);
    except
      mLogList.Add(cERROR_EXCEL_NOT_INSTALLED);
      exit;
    end;

    try
      mExcel.Visible:= False;
      mExcel.DisplayAlerts:= False;
      mWorkbook:= mExcel.Workbooks.Open(mFileName);
      mWorksheet:= mWorkbook.Worksheets[cFIRST_WORKSHEET];
      mUsedRange:= mWorksheet.UsedRange;
      mRowCount:= mUsedRange.Rows.Count;

      WaitWin.StartProgress(
        cVALIDATION_PROGRESS_CAPTION, cEMPTY_STRING, mRowCount);
      try
        // Column 1 = EAN, column 2 = original batch,
        // column 3 = replacement batch. An EAN header row is ignored.
        for i:= cFIRST_XLSX_ROW to mRowCount do
        begin
          try
            try
              mEAN:= Trim(VarToStr(
                mUsedRange.Cells[i, cEAN_COLUMN].Value));
              mOldBatchName:= Trim(VarToStr(
                mUsedRange.Cells[i, cOLD_BATCH_COLUMN].Value));
              mNewBatchName:= Trim(VarToStr(
                mUsedRange.Cells[i, cNEW_BATCH_COLUMN].Value));

              if (i = cFIRST_XLSX_ROW) and
                (LowerCase(mEAN) = cEAN_HEADER) then
                continue;

              if (mEAN = cEMPTY_STRING) and
                (mOldBatchName = cEMPTY_STRING) and
                (mNewBatchName = cEMPTY_STRING) then
                continue;

              if mOldBatchName = mNewBatchName then
              begin
                Inc(mUnchanged);
                continue;
              end;

              if (mEAN = cEMPTY_STRING) or
                (mOldBatchName = cEMPTY_STRING) or
                (mNewBatchName = cEMPTY_STRING) then
              begin
                mLogList.Add(Format(
                  cERROR_MISSING_ROW_VALUE,
                  [i]));
                Inc(mSkipped);
                continue;
              end;

              mStoreCard_ID:= mOS.SQLSelectFirstAsString(
                Format(cSQL_STORE_CARD_BY_EAN, [QuotedStr(mEAN)]));

              if NxIsEmptyOID(mStoreCard_ID) then
              begin
                mLogList.Add(Format(
                  cERROR_STORE_CARD_NOT_FOUND,
                  [i, mEAN]));
                Inc(mSkipped);
                continue;
              end;

              mOldStoreBatch_ID:= mOS.SQLSelectFirstAsString(Format(
                cSQL_STORE_BATCH_BY_NAME,
                [QuotedStr(mStoreCard_ID), QuotedStr(mOldBatchName)]));

              if NxIsEmptyOID(mOldStoreBatch_ID) then
              begin
                mLogList.Add(Format(
                  cERROR_OLD_BATCH_NOT_FOUND,
                  [i, mOldBatchName, mEAN]));
                Inc(mSkipped);
                continue;
              end;

              mNewStoreBatch_ID:= mOS.SQLSelectFirstAsString(Format(
                cSQL_STORE_BATCH_BY_NAME,
                [QuotedStr(mStoreCard_ID), QuotedStr(mNewBatchName)]));

              if NxIsEmptyOID(mNewStoreBatch_ID) then
              begin
                mLogList.Add(Format(
                  cERROR_NEW_BATCH_NOT_FOUND,
                  [i, mNewBatchName, mEAN]));
                Inc(mSkipped);
                continue;
              end;

              mSourceRows.Add(IntToStr(i));
              mStoreCardIDs.Add(mStoreCard_ID);
              mOldStoreBatchIDs.Add(mOldStoreBatch_ID);
              mNewStoreBatchIDs.Add(mNewStoreBatch_ID);
            except
              mLogList.Add(Format(
                cERROR_SOURCE_ROW,
                [i, mEAN, mOldBatchName, mNewBatchName, ExceptionMessage]));
              Inc(mSkipped);
            end;
          finally
            WaitWin.ChangeText(
              IntToStr(i) + cPROGRESS_SEPARATOR + IntToStr(mRowCount));
            WaitWin.StepIt;
          end;
        end;
      finally
        WaitWin.Stop;
      end;

      if mSourceRows.Count = cEMPTY_COUNT then
        mProcessingFinished:= True
      else
      begin
        try
          mOS.StartTransaction(taReadCommited);
          mTransactionStarted:= True;

          WaitWin.StartProgress(
            cCREATION_PROGRESS_CAPTION, cEMPTY_STRING, mSourceRows.Count);
          try
            for i:= cFIRST_INDEX to
              mSourceRows.Count - cSINGLE_ITEM_COUNT do
            begin
              mOutgoingBO:= nil;
              try
                try
                  mOutgoingBO:= mOS.CreateObject(Class_OutgoingSubstitution);
                  mOutgoingBO.ExplicitTransaction:= True;
                  mOutgoingBO.New;
                  mOutgoingBO.Prefill;

                  if Trim(mOutgoingDocQueue_ID) = cEMPTY_STRING then
                  begin
                    mOutgoingDocQueue_ID:=
                      mOutgoingBO.GetFieldValueAsString(cFIELD_DOC_QUEUE_ID);
                    if Trim(mOutgoingDocQueue_ID) = cEMPTY_STRING then
                      mOutgoingDocQueue_ID:= mOS.SQLSelectFirstAsString(
                        Format(
                          cSQL_SINGLE_ACTIVE_DOC_QUEUE,
                          [QuotedStr(cOUTGOING_DOCUMENT_TYPE)]));

                    if Trim(mOutgoingDocQueue_ID) = cEMPTY_STRING then
                      RaiseException(cERROR_NO_OUTGOING_QUEUE);
                  end;

                  mOutgoingBO.SetFieldValueAsString(
                    cFIELD_DOC_QUEUE_ID, mOutgoingDocQueue_ID);
                  SetSingleReplacementRow(
                    mOutgoingBO,
                    mStore_ID,
                    mStoreCardIDs[i],
                    mOldStoreBatchIDs[i],
                    True);
                  mOutgoingBO.Save;

                  CreateIncomingReplacement(
                    mOS,
                    mOutgoingBO,
                    mStore_ID,
                    mStoreCardIDs[i],
                    mNewStoreBatchIDs[i]);
                  Inc(mCreated);
                except
                  RaiseException(Format(
                    cERROR_XLSX_ROW,
                    [mSourceRows[i], ExceptionMessage]));
                end;
              finally
                if Assigned(mOutgoingBO) then
                  mOutgoingBO.Free;
              end;

              WaitWin.ChangeText(
                IntToStr(i + cSINGLE_ITEM_COUNT) + cPROGRESS_SEPARATOR +
                IntToStr(mSourceRows.Count));
              WaitWin.StepIt;
            end;
          finally
            WaitWin.Stop;
          end;

          mOS.Commit;
          mTransactionStarted:= False;
          mProcessingFinished:= True;
        except
          if mTransactionStarted then
          begin
            mOS.RollBack;
            mTransactionStarted:= False;
          end;
          mCreated:= cEMPTY_COUNT;
          mLogList.Add(cERROR_CREATION_ROLLED_BACK + ExceptionMessage);
        end;
      end;

      if mProcessingFinished and (mCreated > cEMPTY_COUNT) and
        (mSite is TDynSiteForm) then
        TDynSiteForm(mSite).ActiveDataSet.RefreshAndRestoreLastSelectedItem;
    except
      mLogList.Add(cERROR_IMPORT_FAILED + ExceptionMessage);
    end;
  finally
    try
      if not VarIsEmpty(mWorkbook) then
        mWorkbook.Close;
    except
    end;
    mWorkbook:= nil;
    mWorksheet:= nil;
    mUsedRange:= nil;

    try
      if not VarIsEmpty(mExcel) then
        mExcel.Quit;
    except
    end;
    mExcel:= nil;

    if mShowResult then
    begin
      if mProcessingFinished then
        mLogList.Insert(cFIRST_INDEX, Format(
          cRESULT_SUMMARY,
          [mCreated, mUnchanged, mSkipped]))
      else
        mLogList.Insert(cFIRST_INDEX, cRESULT_NO_DOCUMENTS);

      if mLogList.Count > cSINGLE_ITEM_COUNT then
        NxShowEditorSite(mSite.SiteContext, mLogList.Text, True)
      else
        NxShowSimpleMessage(mLogList[cFIRST_INDEX], mSite);
    end;

    mNewStoreBatchIDs.Free;
    mOldStoreBatchIDs.Free;
    mStoreCardIDs.Free;
    mSourceRows.Free;
    mLogList.Free;
  end;
end;


begin
end.
