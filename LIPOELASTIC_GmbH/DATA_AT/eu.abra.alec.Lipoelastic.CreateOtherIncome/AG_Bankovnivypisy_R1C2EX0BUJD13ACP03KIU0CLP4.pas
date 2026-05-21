const
  cOTHER_INCOME_DOCQUEUE_ID = '~000000905';

procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TBasicAction;
begin
  mAction := Self.GetNewAction;
  mAction.Name:= 'actCreateOtherIncome';
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := '## Create/Draw Other income ##';
  mAction.Category := 'tabDetail';
  mAction.OnExecute := @CreateOtherIncome;
  mAction.OnUpdate := @My_OnUpdate;
end;

procedure My_OnUpdate(Sender: TControl);
var
  mSite: TSiteForm;
begin
  mSite := NxFindSiteForm(Sender);
  if Assigned(mSite) then begin
    if mSite is TDynSiteForm then begin
      TBasicAction(Sender).Enabled := TDynSiteForm(mSite).Edit;
    end;
  end;
end;

procedure CreateOtherIncome(Sender: TComponent);
var
  mSite: TSiteForm;
  mOS: TNxCustomObjectSpace;
  mGrid: TMultiGrid;
  mDataset: TNxCustomObjectDataSet;
  mSRowBO, mIncomeBO, mIRowBO: TNxCustomBusinessObject;
  mIncomeRows: TNxCustomBusinessMonikerCollection;
  mIncome_ID, mDocType: string;
begin
  mSite:= Sender.Site;
  mOS:= mSite.BaseObjectSpace;

  mIncome_ID:= '';

  mGrid:= TMultiGrid(mSite.FindChildControl('grdRows'));

  if not Assigned(mGrid) then exit;
  if not (mGrid is TMultiGrid) then exit;
  try
    mDataset := TNxRowsObjectDataSet(mGrid.DataSource.DataSet);
    mSRowBO:= mDataset.CurrentObject;
    if (not Assigned(mDataset.CurrentObject)) then RaiseException('None row of bank statement is selected');
    if NxIsEmptyOID(mSRowBO.GetFieldValueAsString('Firm_ID')) then
    begin
      NxShowSimpleMessage('Please assign a company to the bank statement row', mSite);
      exit;
    end;
    if mSRowBO.GetFieldValueAsBoolean('IsMultiPaymentRow') then
    begin
      NxShowSimpleMessage('Cannot create other income, selected bank statment row is already paired', mSite);
      exit;
    end;
    if not NxIsEmptyOID(mSRowBO.GetFieldValueAsString('PDocument_ID')) then
    begin
      NxShowSimpleMessage('Cannot create other income, selected bank statment row is already paired', mSite);
      exit;
    end;

    if not mSRowBO.GetFieldValueAsBoolean('Credit') then
    begin
      mIncome_ID:= GetOtherIncomeID(mOS, mSRowBO.GetFieldValueAsString('Firm_ID'), mSRowBO.GetFieldValueAsFloat('Amount'));
      if NxIsEmptyOID(mIncome_ID) then
      begin
        NxShowSimpleMessage('Cannot pair the line to the other income. No other income document found', mSite);
        exit;
      end;
      mSRowBO.SetFieldValueAsString('PDocumentType', '01');
      mSRowBO.SetFieldValueAsString('PDocument_ID', mIncome_ID);
      exit;
    end;

    mDataSet.DisableControls;
    mIncomeBO:= mOS.CreateObject(Class_OtherIncome);
    try
      mIncomeBO.New;
      mIncomeBO.Prefill;
      mIncomeBO.SetFieldValueAsBoolean('VATDocument', false);
      mIncomeBO.SetFieldValueAsString('DocQueue_ID', cOTHER_INCOME_DOCQUEUE_ID);
      mIncomeBO.SetFieldValueAsString('Firm_ID', mSRowBO.GetFieldValueAsString('Firm_ID'));
      mIncomeRows:= mIncomeBO.GetLoadedCollectionMonikerForFieldCode(mIncomeBO.GetFieldCode('Rows'));

      mIRowBO:= mIncomeRows.AddNewObject;
      mIRowBO.SetFieldValueAsFloat('TAmount', mSRowBO.GetFieldValueAsFloat('Amount'));
      mIRowBO.SetFieldValueAsString('Division_ID',  mSRowBO.GetFieldValueAsString('Division_ID'));

      mIncome_ID:= mIncomeBO.OID;
      mIncomeBO.Save;
    finally
      mIncomeBO.Free;
    end;

    mSRowBO.SetFieldValueAsString('PDocumentType', '01');
    mSRowBO.SetFieldValueAsString('PDocument_ID', mIncome_ID);
  finally
    TDynSiteForm(mSite).ActiveDataSet.UpdateFields(True, true);
    mDataset.RefreshCurrentItem;
    //mGrid.DataSource.DataSet.Refresh;
    //mGrid.
    mDataSet.EnableControls;
  end;

end;


function GetOtherIncomeID(AOS: TNxCustomObjectSpace; AFirm_ID: string; AAmount: Extended): string;
var
  mPaymentsCount: Integer;
begin
  Result:= '';
  mPaymentsCount:= AOS.SQLSelectFirstAsInteger(Format(
    ' SELECT COUNT(P.ID) FROM OtherIncomes OI '+
    ' JOIN Payments P ON P.PDocument_ID = OI.ID '+
    ' WHERE P.DocumentType = ''09'' '+
    ' AND P.PDocumentType = ''01'' '+
    ' AND OI.firm_id = ''%s'' '+
    ' AND OI.Amount > 0',
    [AFirm_ID]));

  if mPaymentsCount > 1 then exit;

  Result:= AOS.SQLSelectFirstAsString(Format(
    ' SELECT OI.ID FROM OtherIncomes OI '+
    ' JOIN Payments P ON P.PDocument_ID = OI.ID '+
    ' WHERE P.DocumentType = ''09'' '+
    ' AND P.PDocumentType = ''01'' '+
    ' AND OI.firm_id = ''%s'' '+
    ' AND OI.Amount = %s ',
    [AFirm_ID, NxFloatToIBStr(AAmount)]));
end;

begin
end.