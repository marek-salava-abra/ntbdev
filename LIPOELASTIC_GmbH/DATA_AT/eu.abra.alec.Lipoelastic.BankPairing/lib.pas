// Druh skriptu: Agenda -> [tvoje agenda]
// Self je TSiteForm (resp. TDynSiteForm), viz help.



procedure RunSelectDocs(Sender: TComponent);
var
  mSite   : TSiteForm;
  mForm      : TForm;
  mDataSource     : TDataSource;
  mMemTable, mSQLMemTable: TMemTable;
  mGrid, mGrdRows: TMultiGrid;
  mBtnOK, mBtnCancel: TButton;
  mPanel: TPanel;
  mLabel, mRowAmountLabel: TLabel;
  mEdSelected, mEdSumSelected, mEdSumToPair, mEdRowAmount, mEdSumToClear: TNumEdit;
  mOIDs   : TStringList;
  mCol: TNxMultiGridCustomColumn;
  mDateCol: TNxMultiGridDateColumn;
  mBoolCol: TNxMultiGridBooleanColumn;
  i, mNumberSign: integer;
  mLog, mFirm_ID: string;
  mBookMark: TBookmark;
begin
  mSite := Sender.Site;

  mLog:= '';
  mFirm_ID:= '';

  mNumberSign:= 1;

  mGrdRows:= TMultiGrid(mSite.FindChildControl('grdRows'));
  if not Assigned(mGrdRows) then exit;

  {
  if mGrdRows.DataSource.DataSet.FieldByName('Credit').AsBoolean = False then
  begin
    mNumberSign:= -1;
    NxShowSimpleMessage('This functionality is not available for debit rows.', mSite);
    exit;
  end;
  }

  mFirm_ID:= mGrdRows.DataSource.DataSet.FieldByName('Firm_ID').AsString;
  if NxIsEmptyOID(mFirm_ID) then
  begin
    NxShowSimpleMessage('Please select the company in the bank statement row.', mSite);
    exit;
  end;

  mForm := TForm.Create(mSite);
  try
    mForm.Caption := 'Select documents';
    mForm.Position := poScreenCenter;
    mForm.Width := 900;
    mForm.Height := 600;
    mForm.Tag:= ObjToInt(mSite);

    mMemTable := TMemTable.Create(mForm);
    mMemTable.Name := 'memDocs';
    mSQLMemTable:= TMemTable.Create(mForm);

    mDataSource := TDataSource.Create(mForm);
    mDataSource.DataSet := mMemTable;

    PrepareDataSet(mMemTable, mLog);

    FillTable(mSite.BaseObjectSpace, mSQLMemTable, mFirm_ID);
    if not mSQLMemTable.Active then
    begin
      NxShowSimpleMessage('No document for pairing found', mSite);
      exit;
    end;

    mMemTable.Open;

    mSQLMemTable.First;
    while not mSQLMemTable.Eof do
    begin
      mMemTable.Append;
      mMemTable.FieldByName('ID').AsString:= mSQLMemTable.FieldByName('ID').AsString;
      mMemTable.FieldByName('DocumentNumber').AsString:= mSQLMemTable.FieldByName('DocumentNumber').AsString;
      mMemTable.FieldByName('DocumentType').AsString:= mSQLMemTable.FieldByName('DocumentType').AsString;
      mMemTable.FieldByName('VarSymbol').AsString:= mSQLMemTable.FieldByName('VarSymbol').AsString;
      mMemTable.FieldByName('DocDate').AsFloat:= mSQLMemTable.FieldByName('DocDate').AsFloat;
      mMemTable.FieldByName('Amount').AsFloat:= mSQLMemTable.FieldByName('Amount').AsFloat * mNumberSign;
      mMemTable.FieldByName('AlreadyPaid').AsFloat:= mSQLMemTable.FieldByName('AlreadyPaid').AsFloat;
      mMemTable.FieldByName('PaidAmount').AsFloat:= 0;
      mMemTable.FieldByName('Selected').AsBoolean:= False;
      mMemTable.FieldByName('NumberSign').AsInteger:= mNumberSign;
      mMemTable.Post;
      mSQLMemTable.Next;
    end;

    mPanel:= TPanel.Create(mForm);
    mPanel.Parent:= mForm;
    mPanel.Name:= 'mPanel';
    mPanel.Caption:= '';
    mPanel.Top:= 0;
    mPanel.Left:= 0;
    mPanel.Height:= 100;
    mPanel.Width:= 900;
    mPanel.Align:= alTop;


    mLabel := TLabel.Create(mForm);
    mLabel.Parent := mPanel;
    mLabel.Left := 8;
    mLabel.Top := 60;
    //mLabel.Font.Style:= [fsBold];
    mLabel.Font.Size:= 10;
    mLabel.Caption := 'Note: '+mGrdRows.DataSource.DataSet.FieldByName('Text').AsString;


      // Selected
    mLabel := TLabel.Create(mForm);
    mLabel.Parent := mPanel;
    mLabel.Left := 8;
    mLabel.Top := 8;
    mLabel.Caption := 'Selected:';

    mEdSelected := TNumEdit.Create(mForm);
    mEdSelected.Parent := mPanel;
    mEdSelected.Left := mLabel.Left + 70;
    mEdSelected.Top := mLabel.Top - 2;
    mEdSelected.ReadOnly := True;
    mEdSelected.Name := 'neSelected';
    mEdSelected.Value := 0;

    // Sum of selected
    mLabel := TLabel.Create(mForm);
    mLabel.Parent := mPanel;
    mLabel.Left := mEdSelected.Left + 150;
    mLabel.Top := 8;
    mLabel.Caption := 'Sum of selected:';

    mEdSumSelected := TNumEdit.Create(mForm);
    mEdSumSelected.Parent := mPanel;
    mEdSumSelected.Left := mLabel.Left + 110;
    mEdSumSelected.Top := mLabel.Top - 2;
    mEdSumSelected.ReadOnly := True;
    mEdSumSelected.Name := 'neSumSelected';
    mEdSumSelected.Value := 0;

    // Sum to pair
    mLabel := TLabel.Create(mForm);
    mLabel.Parent := mPanel;
    mLabel.Left := mEdSumSelected.Left + 150;
    mLabel.Top := 8;
    mLabel.Caption := 'Sum to pair:';

    mEdSumToPair := TNumEdit.Create(mForm);
    mEdSumToPair.Parent := mPanel;
    mEdSumToPair.Left := mLabel.Left + 80;
    mEdSumToPair.Top := mLabel.Top - 2;
    mEdSumToPair.ReadOnly := True;
    mEdSumToPair.Name := 'neSumToPair';
    mEdSumToPair.Value := 0;

    mRowAmountLabel:= TLabel.Create(mForm);
    mRowAmountLabel.Parent := mPanel;
    mRowAmountLabel.Left := 8;
    mRowAmountLabel.Top := 30;
    //mRowAmountLabel.Font.Style:= [fsBold];
    mRowAmountLabel.Font.Size:= 8;
    mRowAmountLabel.Name := 'lblRowAmount';
    mRowAmountLabel.Caption := 'Row amount: ';

    mEdRowAmount:= TNumEdit.Create(mForm);
    mEdRowAmount.Parent:= mPanel;
    mEdRowAmount.Left := mRowAmountLabel.Left + 70;
    mEdRowAmount.Top := 30;
    mEdRowAmount.ReadOnly:= True;
    mEdRowAmount.Name:= 'neRowAmount';
    mEdRowAmount.Value:= mGrdRows.DataSource.DataSet.FieldByName('Amount').AsFloat;

    // Sum to clear
    mLabel := TLabel.Create(mForm);
    mLabel.Parent := mPanel;
    mLabel.Left := mEdRowAmount.Left + 150;
    mLabel.Top := 30;
    mLabel.Caption := 'Sum to clear:';

    mEdSumToClear := TNumEdit.Create(mForm);
    mEdSumToClear.Parent := mPanel;
    mEdSumToClear.Left := mEdSumSelected.Left;
    mEdSumToClear.Top := 30;
    mEdSumToClear.ReadOnly := True;
    mEdSumToClear.Name := 'neSumToClear';
    mEdSumToClear.Value := mEdRowAmount.Value - mEdSumToPair.Value;

    mGrid := TMultiGrid.Create(mForm);
    mGrid.Parent := mForm;
    mGrid.Align := alClient;
    mGrid.DataSource := mDataSource;
    mGrid.Name := 'grdBankPay';
    mGrid.Options:= mGrid.Options - [goAllowAppend, goAllowInsert, goAllowDelete];
    //mGrid.Options := [goHeaders, goRowLines, goColLines, goEditing, goAlwaysShowEditor_1, goAlwaysShowEditor, goRowSelect];            //goAlwaysShowSelection

    mCol:= TNxMultiGridCustomColumn.Create(mGrid);
    mCol.Caption:= 'ID';
    mCol.FieldName := 'ID';
    mCol.Name:= 'ID';
    mCol.Width:= 60;
    mCol.Visible:= False;
    mGrid.AddColumn(mCol);
    mCol.ReadOnly:= True;

    mBoolCol:= TNxMultiGridBooleanColumn.Create(mGrid);
    mBoolCol.Caption:= 'Use';
    mBoolCol.FieldName := 'Selected';
    mBoolCol.Name:= 'xSelected';
    mBoolCol.Width:= 50;
    mBoolCol.Order:= 0;
    mGrid.AddColumn(mBoolCol);

    mCol:= TNxMultiGridCustomColumn.Create(mGrid);
    mCol.Caption:= 'Doc. Type';
    mCol.FieldName := 'DocumentType';
    mCol.Name:= 'xDocumentType';
    mCol.Width:= 80;
    mCol.Elastic:= false;
    mCol.Order:= 1;
    mCol.ReadOnly:= True;
    //mCol.Visible:= false;
    mGrid.AddColumn(mCol);
    mCol.ReadOnly:= True;

    mCol:= TNxMultiGridCustomColumn.Create(mGrid);
    mCol.Caption:= 'Document';
    mCol.FieldName := 'DocumentNumber';
    mCol.Name:= 'xDocumentNumber';
    mCol.Width:= 100;
    mCol.Order:= 2;
    mCol.ReadOnly:= True;
    mGrid.AddColumn(mCol);
    mCol.ReadOnly:= True;

    mCol:= TNxMultiGridCustomColumn.Create(mGrid);
    mCol.Caption:= 'VarSymbol';
    mCol.FieldName := 'VarSymbol';
    mCol.Name:= 'xVarSymbol';
    mCol.Width:= 100;
    mCol.Order:= 3;
    mCol.ReadOnly:= True;
    mGrid.AddColumn(mCol);
    mCol.ReadOnly:= True;

    mDateCol:= TNxMultiGridDateColumn.Create(mGrid);
    mDateCol.Caption:= 'DocDate';
    mDateCol.FieldName := 'DocDate';
    mDateCol.Name:= 'xDocDate';
    mDateCol.Width:= 80;
    mDateCol.Elastic:= false;
    mDateCol.Order:= 4;
    mGrid.AddColumn(mDateCol);
    mDateCol.ReadOnly:= True;

    mCol:= TNxMultiGridCustomColumn.Create(mGrid);
    mCol.Caption:= 'Amount';
    mCol.FieldName := 'Amount';
    mCol.Name:= 'xAmount';
    mCol.Width:= 100;
    mCol.Elastic:= false;
    mCol.Order:= 5;
    mGrid.AddColumn(mCol);
    mCol.ReadOnly:= True;

    mCol:= TNxMultiGridCustomColumn.Create(mGrid);
    mCol.Caption:= 'Already paid';
    mCol.FieldName := 'AlreadyPaid';
    mCol.Name:= 'xAlreadyPaid';
    mCol.Width:= 100;
    mCol.Elastic:= false;
    mCol.Order:= 6;
    mGrid.AddColumn(mCol);
    mCol.ReadOnly:= True;

    mCol:= TNxMultiGridCustomColumn.Create(mGrid);
    mCol.Caption:= 'Paid amount';
    mCol.FieldName := 'PaidAmount';
    mCol.Name:= 'xPaidAmount';
    mCol.Width:= 100;
    mCol.Elastic:= false;
    mCol.Order:= 7;
    mCol.ReadOnly:= false;
    mGrid.AddColumn(mCol);

    // tlačítka
    mBtnCancel := TButton.Create(mForm);
    mBtnCancel.Parent := mForm;
    mBtnCancel.Caption := 'Cancel';
    mBtnCancel.ModalResult := mrCancel;
    mBtnCancel.Align := alBottom;

    mBtnOK := TButton.Create(mForm);
    mBtnOK.Parent := mForm;
    mBtnOK.Caption := 'OK';
    //mBtnOK.ModalResult := mrOk;
    mBtnOK.ModalResult := mrNone;
    mBtnOK.Align := alBottom;
    mBtnOK.OnClick:= @MyOnClick;

    mMemTable.FieldByName('ID').ReadOnly:= True;
    mMemTable.FieldByName('Amount').ReadOnly:= True;
    mMemTable.FieldByName('VarSymbol').ReadOnly:= True;
    mMemTable.FieldByName('DocumentNumber').ReadOnly:= True;
    mMemTable.FieldByName('DocumentType').ReadOnly:= True;
    mMemTable.FieldByName('DocDate').ReadOnly:= True;
    //mMemTable.FieldByName('PaidAmount').ReadOnly:= True;
    mMemTable.FieldByName('Selected').ReadOnly:= True;
    mMemTable.FieldByName('NumberSign').ReadOnly:= True;
    //mMemTable.FieldByName('Amount').Alignment:= taRightJustify;
    //mMemTable.FieldByName('AlreadyPaid').ReadOnly:= True;

    mGrid.OnDblClick:= @MyOnDoubleClick;
    mGrid.OnGetBackgroundColor:= @My_OnGetBackgroudColor;

    mMemTable.AfterPost:= @MyAfterPost;

    if mForm.ShowModal(mSite) = mrOk then
    begin
      mOIDs := TStringList.Create;
      try
        mMemTable.First;

        while not mMemTable.Eof do
        begin
          if mMemTable.FieldByName('Selected').AsBoolean then
            mOIDs.Add(mMemTable.FieldByName('ID').AsString+';'+
                      mMemTable.FieldByName('DocumentType').AsString+';'+
                      NxFloatToIBStr(mMemTable.FieldByName('PaidAmount').AsFloat)+';'+
                      IntToStr(mMemTable.FieldByName('NumberSign').AsInteger));
          mMemTable.Next;
        end;

        ProcessSelected(mSite.BaseObjectSpace, mOIDs, mSite);
      finally
        mOIDs.Free;
      end;
    end;

  finally
    mMemTable.Free;
    mSQLMemTable.Free;
    mForm.Free;
  end;
end;

procedure MyOnDoubleClick(Sender: TObject);
var
  mDataSet: TDataSet;
  mSelectedField : TField;
  mLabel: TLabel;
begin
  mDataSet := TMultiGrid(Sender).DataSource.DataSet;
  if (mDataSet = nil) or mDataSet.IsEmpty then Exit;

  mSelectedField := mDataSet.FieldByName('Selected');
  if mSelectedField = nil then Exit;

  mDataSet.Edit;
  mDataSet.FieldByName('Selected').ReadOnly:= false;

  mSelectedField.AsBoolean := not mSelectedField.AsBoolean;
  if mSelectedField.AsBoolean then
  begin
    //mDataSet.FieldByName('PaidAmount').ReadOnly:= false;
    mDataSet.FieldByName('PaidAmount').AsFloat:= mDataSet.FieldByName('Amount').AsFloat;
  end else
  begin
    mDataSet.FieldByName('PaidAmount').AsFloat:= 0;
    //mDataSet.FieldByName('PaidAmount').ReadOnly:= True;
  end;
  mDataSet.FieldByName('Selected').ReadOnly:= True;

  mDataSet.Post;

  TMultiGrid(Sender).Invalidate;

  //mLabel := TLabel(TMultiGrid(Sender).Owner.FindComponent('lblSummary'));
  //if mLabel <> nil then
    UpdateSelectionSummary(mDataSet);
end;


procedure MyOnClick(Sender: TObject);
var
  mForm: TForm;
  mMemTable: TMemTable;
  mEdRowAmount, mEdSumToPair: TNumEdit;
  mSite: TSiteForm;
  mRowAmount, mSumToPair: Double;
  mBookmark: TBookmarkStr;
begin
  if not (Sender is TButton) then Exit;

  mForm := TForm(TButton(Sender).Owner);
  if mForm = nil then
    Exit;

  // site z Tagu formuláře (uloženo v RunSelectDocs)
  //mSite := TSiteForm(mForm.Tag);

  mEdRowAmount:= TNumEdit(mForm.FindComponent('neRowAmount'));
  mEdSumToPair:= TNumEdit(mForm.FindComponent('neSumToPair'));

  if (mEdRowAmount = nil) or (mEdSumToPair = nil) then
    exit;

  mRowAmount := mEdRowAmount.Value;
  mSumToPair := mEdSumToPair.Value;

  if Abs(mRowAmount - mSumToPair) > 0.01 then
  begin
    NxShowSimpleMessage(Format('Row amount (%.2f) is not equal to Sum to pair (%.2f).', [mRowAmount, mSumToPair]), mForm);
    Exit; // dialog zůstane otevřený, user může opravovat
  end;

  mForm.ModalResult := mrOk;
end;


procedure MyAfterPost(DataSet: TDataSet);
var
  L: TLabel;
begin
    UpdateSelectionSummary(DataSet);
end;

{
procedure UpdateSumIfSelected(ATable: TDataSet);
var
  mForm: TForm;
  OldRecNo: Integer;
  Total: Double;
  mEdSumToPair: TNumEdit;
  mBookmark: TBookmarkStr;
begin
  if (ATable = nil) or (not ATable.Active) or ATable.IsEmpty then
    Exit;

  mForm:= TForm(ATable.Owner);
  if mForm = nil then
    exit;

  mEdSumToPair:= TNumEdit(mForm.FindComponent('neSumToPair'));
  if mEdSumToPair = nil then
    exit;

  Total := 0;
  //OldRecNo := ATable.RecNo;

  mBookmark:= ATable.GetBookmark;
  ATable.DisableControls;
  try
    ATable.First;
    while not ATable.Eof do
    begin
      if ATable.FieldByName('Selected').AsBoolean then
        Total := Total + ATable.FieldByName('PaidAmount').AsFloat;

      ATable.Next;
    end;
    if ATable.BookmarkValid(mBookmark) then
      ATable.GotoBookmark(mBookmark);
  finally
    ATable.EnableControls;
    ATable.FreeBookmark(mBookmark);
    //if (OldRecNo > 0) and (OldRecNo <= ATable.RecordCount) then
    //  ATable.RecNo := OldRecNo;
  end;
  mEdSumToPair.Value:= Total;
  //ASummaryLabel.Caption := Format('Sum to pair: %0.2f', [Total]);
end;
}


procedure My_OnGetBackgroudColor(Sender : TObject; AColumn: TNxMultiGridCustomColumn; const AIndex: Integer; const AMultiSelect: Boolean; const
ASelectedActiveRow: Boolean; var ABckColor: TColor);
var
  mDataSet: TDataset;
begin
  if Sender is TMultiGrid then begin
    mDataSet := TMultiGrid(Sender).DataSource.DataSet;
    if mDataSet.RecordCount > 0 then begin
      if mDataSet.FieldByName('Selected').AsBoolean = True then
        ABckColor :=  StringToColor('#de4b9a');    //#fc2192    #a9e394
    end;
  end;
end;


procedure UpdateSelectionSummary(ATable: TDataSet{; ALabel: TLabel});
var
  mForm: TForm;
  OldRecNo: Integer;
  Cnt: Integer;
  Sum, mPairSum, mRowAmount: Double;
  mEdSelected, mEdSumSelected, mEdSumToPair, mEdRowAmount, mEdSumToClear: TNumEdit;
  mBookmark: TBookmarkStr;
begin
  if (ATable = nil) {or (ALabel = nil)} or (not ATable.Active) or ATable.IsEmpty then
    Exit;

  // owner datasetu je mForm (mMemTable := TMemTable.Create(mForm))
  mForm := TForm(ATable.Owner);
  if mForm = nil then
  begin
    NxShowSimpleMessage('UpdateSelectionSummary - Form not found', nil);
    Exit;
  end;

  mEdSelected    := TNumEdit(mForm.FindComponent('neSelected'));
  mEdSumSelected := TNumEdit(mForm.FindComponent('neSumSelected'));
  mEdSumToPair   := TNumEdit(mForm.FindComponent('neSumToPair'));
  mEdRowAmount   := TNumEdit(mForm.FindComponent('neRowAmount'));
  mEdSumToClear  := TNumEdit(mForm.FindComponent('neSumToClear'));

  if (mEdSelected = nil) or (mEdSumSelected = nil) or (mEdSumToPair = nil) or (mEdRowAmount = nil) or (mEdSumToClear = nil) then
  begin
    NxShowSimpleMessage('UpdateSelectionSummary - NumEdits not found', nil);
    Exit;
  end;

  //OldRecNo := ATable.RecNo;
  Cnt := 0;
  Sum := 0;
  mPairSum:= 0;

  mBookmark:= ATable.GetBookmark;
  ATable.DisableControls;
  try
    ATable.First;
    while not ATable.Eof do
    begin
      if ATable.FieldByName('Selected').AsBoolean then
      begin
        Inc(Cnt);
        Sum := Sum + ATable.FieldByName('Amount').AsFloat;
        mPairSum:= mPairSum + ATable.FieldByName('PaidAmount').AsFloat;
      end;
      ATable.Next;
    end;
    if ATable.BookmarkValid(mBookmark) then
      ATable.GotoBookmark(mBookmark);
  finally
    ATable.EnableControls;
    ATable.FreeBookmark(mBookmark);
  end;

  mEdSelected.Value    := Cnt;
  mEdSumSelected.Value := Sum;
  mEdSumToPair.Value   := mPairSum;

  mRowAmount := mEdRowAmount.Value;
  mEdSumToClear.Value := mRowAmount - mPairSum;
end;

procedure FillTable(ObjectSpace: TNxCustomObjectSpace; AMem: TMemTable; AFirm_ID: string);
var
  mParams: TNxParameters;
begin
  mParams:= TNxParameters.Create;
  try
    try
      mParams.GetOrCreateParam(dtString, 'FirmID').AsString:= AFirm_ID;

      ObjectSpace.SQLSelect2(
        ' select II.ID AS ID, '+
        ' DQ.Code || ''-'' || cast(II.OrdNumber as varchar) || ''/'' || PE.Code as DocumentNumber, '+
        ' DQ.DocumentType AS DocumentType, '+
        ' II.VarSymbol as VarSymbol, '+
        ' (II.Amount - II.PaidAmount) as Amount, '+
        ' II.DocDate$Date as DocDate, '+
        ' II.PaidAmount as AlreadyPaid '+
        ' from IssuedInvoices II'+
        ' JOIN DocQueues DQ ON DQ.ID = II.DocQueue_ID '+
        ' JOIN Periods PE ON PE.ID = II.Period_ID '+
        ' join Firms F on F.ID=II.Firm_ID '+
        //' WHERE (Amount - PaidAmount + CreditAmount - PaidCreditAmount <> 0) '+    //Upraveno 10.2.2026 ALEC - na přání EZGI
        ' WHERE ((II.Amount - II.PaidAmount) <> 0) '+
        ' AND (F.ID = :FirmID OR ((F.Firm_ID IS NOT NULL) AND (F.Firm_ID = :FirmID))) '+

        ' UNION ALL '+

        ' select II.ID AS ID, '+
        ' DQ.Code || ''-'' || cast(II.OrdNumber as varchar) || ''/'' || PE.Code as DocumentNumber, '+
        ' DQ.DocumentType AS DocumentType, '+
        ' II.VarSymbol as VarSymbol, '+
        ' -II.Amount as Amount, '+
        ' II.DocDate$Date as DocDate, '+
        ' II.PaidAmount AS AlreadyPaid '+
        ' from IssuedCreditNotes II'+
        ' JOIN DocQueues DQ ON DQ.ID = II.DocQueue_ID '+
        ' JOIN Periods PE ON PE.ID = II.Period_ID '+
        ' join Firms F on F.ID=II.Firm_ID '+
        ' WHERE ((II.Amount - II.PaidAmount) <> 0) '+    //10.2.2026 ALEC    upraveno z < na <> a přidány závorky kolem součtu
        ' AND (F.ID = :FirmID OR ((F.Firm_ID IS NOT NULL) AND (F.Firm_ID = :FirmID))) '+

        ' UNION ALL '+

        ' select II.ID AS ID, '+
        ' DQ.Code || ''-'' || cast(II.OrdNumber as varchar) || ''/'' || PE.Code as DocumentNumber, '+
        ' DQ.DocumentType AS DocumentType, '+
        ' II.VarSymbol as VarSymbol, '+
        ' (II.Amount - II.PaidAmount) as Amount, '+
        ' II.DocDate$Date as DocDate, '+
        ' II.PaidAmount as AlreadyPaid '+
        ' FROM IssuedDInvoices II'+
        ' JOIN DocQueues DQ ON DQ.ID = II.DocQueue_ID '+
        ' JOIN Periods PE ON PE.ID = II.Period_ID '+
        ' JOIN Firms F on F.ID = II.Firm_ID '+
        ' WHERE ((II.Amount - II.PaidAmount) <> 0) '+
        ' AND (F.ID = :FirmID OR ((F.Firm_ID IS NOT NULL) AND (F.Firm_ID = :FirmID))) '+

        ' ORDER BY DocDate ',
        AMem, mParams);

    except
      NxShowSimpleMessage('Cannot fill table', nil);
    end;
  finally
    mParams.Free;
  end;
end;

procedure ProcessSelected(AOS: TNxCustomObjectSpace; AList: TStringList; aSite:TSiteForm);
var
 mSite:TSiteForm;
 mGrdRows:TMultiGrid;
 mDataset: TNxCustomObjectDataSet;
 mControl:TControl;
 mRow, mNewRow:TNxCustomBusinessObject;
 mTempStr, mDocID, mDocType:string;
 mAmount:Extended;
 i, mNumberSign:integer;
begin
  mSite:=aSite;
  mControl:= mSite.FindChildControl('tabRows.grdRows');
  mDataset := TNxRowsObjectDataSet(TMultiGrid(mControl).DataSource.DataSet);
  if (not Assigned(mDataset.CurrentObject)) then RaiseException('None row of bank statement is selected');
  mRow := mDataset.CurrentObject;
  if AList.count>0 then begin
   mDataSet.DisableControls;
   if AList.count=1 then begin
     mTempStr:=AList.Strings[0];
     mDocID:=NxTrapStrTrim(mTempStr,';');
     mDocType:=NxTrapStrTrim(mTempStr,';');
     mAmount:=NxIBStrToFloat(NxTrapStrTrim(mTempStr,';'));
     mNumberSign:= StrToInt(NxTrapStrTrim(mTempStr,';'));
     mRow.SetFieldValueAsString('PDocumentType', mDocType);
     mRow.SetFieldValueAsString('PDocument_ID', mDocID);
     mDataset.RefreshCurrentItem;
   end else begin
     mRow.SetFieldValueAsString('PDocument_ID', '');
     mRow.SetFieldValueAsString('PDocumentType', '');
     mRow.SetFieldValueAsBoolean('IsMultiPaymentRow', true);
     for i:=0 to AList.count-1 do begin
       mTempStr:=AList.Strings[i];
       mDocID:=NxTrapStrTrim(mTempStr,';');
       mDocType:=NxTrapStrTrim(mTempStr,';');
       mAmount:=NxIBStrToFloat(NxTrapStrTrim(mTempStr,';'));
       mNumberSign:= StrToInt(NxTrapStrTrim(mTempStr,';'));
        mNewRow := mDataset.CreateBusinessObject;
        mNewRow.Prefill;
        mNewRow.SetFieldValueAsString('BankStatementRow_ID', mRow.OID);
        if (mAmount > 0) then
         mNewRow.SetFieldValueAsBoolean('Credit', true) else mNewRow.SetFieldValueAsBoolean('Credit', false);
        if (mNumberSign = -1) then
          mNewRow.SetFieldValueAsBoolean('Credit', false);
        mNewRow.SetFieldValueAsDateTime('DocDate$DATE', mRow.GetFieldValueAsDateTime('DocDate$DATE'));
        mNewRow.SetFieldValueAsString('Currency_ID', mRow.GetFieldValueAsString('Currency_ID'));
        mNewRow.SetFieldValueAsString('Text', mRow.GetFieldValueAsString('Text'));
        mNewRow.SetFieldValueAsString('Division_ID', mRow.GetFieldValueAsString('Division_ID'));
        if mAmount>0 then mNewRow.SetFieldValueAsFloat('Amount', mAmount) else mNewRow.SetFieldValueAsFloat('Amount', -mAmount);
        if mAmount>0 then mNewRow.SetFieldValueAsFloat('PAmount', mAmount) else mNewRow.SetFieldValueAsFloat('PAmount', -mAmount);
        mNewRow.SetFieldValueAsString('PDocumentType', mDocType);
        mNewRow.SetFieldValueAsString('PDocument_ID', mDocID);
     end;
    TButton(mSite.FindChildControl('btnDetailRows')).Click;
   end;
   TDynSiteForm(mSite).ActiveDataSet.UpdateFields; //Aby se o změně dozvěděl hlavičkový dataset
   mDataSet.EnableControls;
  end;

  //NxShowSimpleMessage(AList.text+NxCrLf+mRow.OID, nil);
end;


procedure PrepareDataSet(ADataSet: TMemTable; var ALog: string;);
var
  mFieldDef: TFieldDef;
  mField: TField;
begin
  try
    AddField(ADataSet, 'ID', ftString, 300001, 10);
    AddField(ADataSet, 'DocumentNumber', ftString, 300002, 30);
    AddField(ADataSet, 'DocumentType', ftString, 300003, 2);
    AddField(ADataSet, 'VarSymbol', ftString, 300004, 15);
    AddField(ADataSet, 'DocDate', ftDateTime, 300005);
    AddField(ADataSet, 'Amount', ftFloat, 300006);
    AddField(ADataSet, 'Selected', ftBoolean, 300007);
    AddField(ADataSet, 'PaidAmount', ftFloat, 300008);
    AddField(ADataSet, 'AlreadyPaid', ftFloat, 300009);
    AddField(ADataSet, 'NumberSign', ftInteger, 300010);

  except
    ALog:= ALog + Format('PrapareDataSet - Vyskytla se chyba při přípravě datasetu %s', [ExceptionMessage])+ nxCrLf;
    RaiseException(Format('PrapareDataSet - Vyskytla se chyba při přípravě datasetu %s', [ExceptionMessage]));
    exit;
  end;
end;

procedure AddField(ADataSet: TMemTable; const AFieldName: string; AFieldType: TFieldType; AFieldCode: integer; ASize: Integer = 0;);
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



begin
end.