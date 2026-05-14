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
  mLabel: TLabel;
  mOIDs   : TStringList;
  mCol: TNxMultiGridCustomColumn;
  mBoolCol: TNxMultiGridBooleanColumn;
  i: integer;
  mLog, mFirm_ID: string;
  mBookMark: TBookmark;
begin
  mSite := Sender.Site;

  mLog:= '';
  mFirm_ID:= '';

  mGrdRows:= TMultiGrid(mSite.FindChildControl('grdRows'));
  if not Assigned(mGrdRows) then exit;

  mFirm_ID:= mGrdRows.DataSource.DataSet.FieldByName('Firm_ID').AsString;
  if NxIsEmptyOID(mFirm_ID) then
  begin
    NxShowSimpleMessage('Please select the company in the bank statement row.', mSite);
    exit;
  end;

  mForm := TForm.Create(mSite);
  try
    mForm.Caption := 'Výběr dokladů';
    mForm.Position := poScreenCenter;
    mForm.Width := 800;
    mForm.Height := 500;

    mMemTable := TMemTable.Create(mForm);
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
      mMemTable.FieldByName('Amount').AsFloat:= mSQLMemTable.FieldByName('Amount').AsFloat;
      mMemTable.FieldByName('Selected').AsBoolean:= False;
      mMemTable.Post;

      mSQLMemTable.Next;
    end;

    mPanel:= TPanel.Create(mForm);
    mPanel.Parent:= mForm;
    mPanel.Name:= 'mPanel';
    mPanel.Caption:= '';
    mPanel.Top:= 0;
    mPanel.Left:= 0;
    mPanel.Height:= 60;
    mPanel.Width:= 800;
    mPanel.Align:= alTop;

    mLabel := TLabel.Create(mForm);
    mLabel.Parent := mPanel;
    mLabel.Left := 8;
    mLabel.Top := 8;
    mLabel.Font.Style:= [fsBold];
    mLabel.Font.Size:= 12;
    mLabel.Name := 'lblSummary';
    mLabel.Caption := 'Selected: 0   |   Sum of selected: 0,00';

    mGrid := TMultiGrid.Create(mForm);
    mGrid.Parent := mForm;
    mGrid.Align := alClient;
    mGrid.DataSource := mDataSource;
    mGrid.Options := [goHeaders, goRowLines, goColLines, goRowSelect, goAlwaysShowSelection];

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
    mCol.Caption:= 'Document';
    mCol.FieldName := 'DocumentNumber';
    mCol.Name:= 'xDocumentNumber';
    mCol.Width:= 100;
    mCol.Order:= 2;
    mCol.ReadOnly:= True;
    mGrid.AddColumn(mCol);
    mCol.ReadOnly:= True;

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
    mCol.Caption:= 'VarSymbol';
    mCol.FieldName := 'VarSymbol';
    mCol.Name:= 'xVarSymbol';
    mCol.Width:= 100;
    mCol.Order:= 3;
    mCol.ReadOnly:= True;
    mGrid.AddColumn(mCol);
    mCol.ReadOnly:= True;

    mCol:= TNxMultiGridCustomColumn.Create(mGrid);
    mCol.Caption:= 'Amount';
    mCol.FieldName := 'Amount';
    mCol.Name:= 'xAmount';
    mCol.Width:= 150;
    mCol.Elastic:= true;
    mCol.Order:= 4;
    mGrid.AddColumn(mCol);
    mCol.ReadOnly:= True;

    // tlačítka
    mBtnCancel := TButton.Create(mForm);
    mBtnCancel.Parent := mForm;
    mBtnCancel.Caption := 'Cancel';
    mBtnCancel.ModalResult := mrCancel;
    mBtnCancel.Align := alBottom;

    mBtnOK := TButton.Create(mForm);
    mBtnOK.Parent := mForm;
    mBtnOK.Caption := 'OK';
    mBtnOK.ModalResult := mrOk;
    mBtnOK.Align := alBottom;

    mMemTable.FieldByName('ID').ReadOnly:= True;
    mMemTable.FieldByName('Amount').ReadOnly:= True;
    mMemTable.FieldByName('VarSymbol').ReadOnly:= True;
    mMemTable.FieldByName('DocumentNumber').ReadOnly:= True;
    mMemTable.FieldByName('DocumentType').ReadOnly:= True;
    mMemTable.FieldByName('Amount').Alignment:= taRightJustify;

    mGrid.OnDblClick:= @MyOnDoubleClick;
    mGrid.OnGetBackgroundColor:= @My_OnGetBackgroudColor;

    if mForm.ShowModal(mSite) = mrOk then
    begin
      mOIDs := TStringList.Create;
      try
        mMemTable.First;

        while not mMemTable.Eof do
        begin
          if mMemTable.FieldByName('Selected').AsBoolean then
            mOIDs.Add(mMemTable.FieldByName('ID').AsString);
          mMemTable.Next;
        end;

        ProcessSelected(mSite.BaseObjectSpace, mOIDs);
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
  mSelectedField.AsBoolean := not mSelectedField.AsBoolean;
  mDataSet.Post;

  TMultiGrid(Sender).Invalidate;

  mLabel := TLabel(TMultiGrid(Sender).Owner.FindComponent('lblSummary'));
  if mLabel <> nil then
    UpdateSelectionSummary(mDataSet, mLabel);
end;

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


procedure UpdateSelectionSummary(ATable: TDataSet; ALabel: TLabel);
var
  OldRecNo: Integer;
  Cnt: Integer;
  Sum: Double;
begin
  if (ATable = nil) or (ALabel = nil) or (not ATable.Active) or ATable.IsEmpty then
    Exit;

  OldRecNo := ATable.RecNo;
  Cnt := 0;
  Sum := 0;

  ATable.DisableControls;
  try
    ATable.First;
    while not ATable.Eof do
    begin
      if ATable.FieldByName('Selected').AsBoolean then
      begin
        Inc(Cnt);
        Sum := Sum + ATable.FieldByName('Amount').AsFloat;
      end;
      ATable.Next;
    end;
  finally
    ATable.EnableControls;
    if (OldRecNo > 0) and (OldRecNo <= ATable.RecordCount) then
      ATable.RecNo := OldRecNo;
  end;

  ALabel.Caption :=
    Format('Selected: %d   |   Sum of selected: %0.2f', [Cnt, Sum]);
end;


procedure FillTable(ObjectSpace: TNxCustomObjectSpace; AMem: TMemTable; AFirm_ID: string;);
begin
  try
    ObjectSpace.SQLSelect2(Format(
      ' select II.ID AS ID, '+
      ' DQ.Code || ''-'' || II.OrdNumber || ''/'' || PE.Code as DocumentNumber, '+
      ' DQ.DocumentType AS DocumentType, '+
      ' II.VarSymbol as VarSymbol, '+
      ' II.Amount as Amount '+
      ' from IssuedInvoices II'+
      ' JOIN DocQueues DQ ON DQ.ID = II.DocQueue_ID '+
      ' JOIN Periods PE ON PE.ID = II.Period_ID '+
      ' WHERE (Amount - PaidAmount + CreditAmount - PaidCreditAmount > 0) '+
      ' AND II.Firm_ID = ''%s'' ', [AFirm_ID]), AMem);
  except
    NxShowSimpleMessage('Cannot fill table', nil);
  end;
end;

procedure ProcessSelected(AOS: TNxCustomObjectSpace; AList: TStringList);
begin
  NxShowSimpleMessage(AList.text, nil);
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
    AddField(ADataSet, 'Amount', ftFloat, 300005);
    AddField(ADataSet, 'Selected', ftBoolean, 300006);

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