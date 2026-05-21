
procedure FindMatchingDoc(Sender: TComponent);
var
  mSite: TSiteForm;
  mForm: TForm;
  mRowsControl: TControl;
  mRowsDataSource: TDataSource;
  mOS: TNxCustomObjectSpace;
  mBO: TNxCustomBusinessObject;
  mRows: TNxCustomBusinessMonikerCollection;
  i: integer;
begin
  mSite:= Sender.Site;
  mOS:= mSite.BaseObjectSpace;

  mForm := NxGetSiteAppForm(mSite);
  mRowsControl := NxFindChildControl(mForm, 'grdRows');
  mRowsDataSource := TMultiGrid(mRowsControl).DataSource;

  mBO:= TDynSiteForm(mSite).CurrentObject;
  try
    mRows:= mBO.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('Rows'));

    for i:= 0 to mRows.Count -1 do
    begin
      MatchRow(mRows.BusinessObject[i]);
    end;

    mRowsDataSource.DataSet.Refresh;

    NxShowSimpleMessage('Matching complete', mSite);
  finally
    mBO.Free;
  end;
end;


procedure MatchRow(ARowBO: TNxCustomBusinessObject);
const
  cEMPTY_FIRM_ID = 'AAA1000000';
var
  mFirm_ID, mDocType, mDocument_ID: string;
  mCredit: boolean;
  mAmount: Extended;
begin
  if not NxIsEmptyOID(ARowBO.GetFieldValueAsString('PDocument_ID')) then exit;
  if ARowBO.GetFieldValueAsString('Firm_ID') = cEMPTY_FIRM_ID then exit;

  mFirm_ID:= ARowBO.GetFieldValueAsString('Firm_ID');
  mAmount:= ARowBO.GetFieldValueAsFloat('Amount');
  mCredit:= ARowBO.GetFieldValueAsBoolean('Credit');

  if GetUnpaidDocument(ARowBO.ObjectSpace, mFirm_ID, mAmount, mCredit, mDocType, mDocument_ID) then
  begin
    ARowBO.SetFieldValueAsString('PDocumentType', mDocType);
    ARowBO.SetFieldValueAsString('PDocument_ID', mDocument_ID);
  end;
end;


function GetUnpaidDocument(AOS: TNxCustomObjectSpace; AFirm_ID: string; AAmount: Extended; ACredit: boolean; var ADocumentType: string; var ADocument_ID: string):Boolean;
const
  cSQL_ISSUEDINVOICES =
    ' SELECT CAST(II.ID AS VARCHAR) + ''|'' + CAST(DQ.DocumentType AS VARCHAR) FROM IssuedInvoices II '+
    ' JOIN DocQueues DQ ON DQ.ID = II.DocQueue_ID '+
    ' WHERE ((II.Amount - II.PaidAmount) > 0) '+
    ' AND II.Firm_ID = ''%s'' '+
    ' AND II.Amount = %s ';
  cSQL_ISSUEDCREDITNOTES =
    ' SELECT CAST(ICN.ID AS VARCHAR) + ''|'' + CAST(DQ.DocumentType AS VARCHAR) FROM IssuedCreditNotes ICN '+
    ' JOIN DocQueues DQ ON DQ.ID = ICN.DocQueue_ID '+
    ' WHERE ((ICN.Amount - ICN.PaidAmount) > 0) '+
    ' AND ICN.Firm_ID = ''%s'' '+
    ' AND ICN.Amount = %s ';
var
  mTempStr: string;
begin
  Result:= false;

  case ACredit of
    true: mTempStr:= AOS.SQLSelectFirstAsString(Format(cSQL_ISSUEDINVOICES, [AFirm_ID, CFxFloat.FloatToStr(AAmount, '.')]));
    false: mTempStr:= AOS.SQLSelectFirstAsString(Format(cSQL_ISSUEDCREDITNOTES, [AFirm_ID, CFxFloat.FloatToStr(AAmount, '.')]));
  end;

  if NxIsBlank(mTempStr) then exit;

  ADocument_ID:= NxTrapStr(mTempStr, '|');
  ADocumentType:= mTempStr;
  Result:= True;
end;

begin
end.