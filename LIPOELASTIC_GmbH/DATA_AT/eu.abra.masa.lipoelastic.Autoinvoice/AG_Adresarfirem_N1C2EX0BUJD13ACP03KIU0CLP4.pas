uses '.fce', '.const';


{
Vyvolává se po provedení inicializace agendy/formuláře. V tento okamžik je již na formuláři dostupný SiteContext.
}
procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TMultiAction;
begin
  mAction:= Self.GetNewMultiAction;
  mAction.Name:= 'actSendGrouppedReminders';
  mAction.Caption:= '##Send groupped reminder##';
  mAction.Items.Add('Send groupped reminders');
  mAction.Category:= 'tabList';
  mAction.OnExecuteItem:= @RemindersSwitch;
end;


procedure RemindersSwitch(Sender: TComponent; AIndex: integer);
begin
  case AIndex of
    0: SendGrouppedReminders(Sender);
  end;
end;


procedure SendGrouppedReminders(Sender: TComponent);
const
  cFallbackEmail = 'odavidek@lipoelastic.com';
var
  mSite: TSiteForm;
  mOS: TNxCustomObjectSpace;
  mFirmBO, mMailTextBO: TNxCustomBusinessObject;
  mInvoiceIDs: TStringList;
  mTemplate_ID, mIIForm_ID, mFirm_ID: string;
  mTO, mSubject, mBody, mFileName, mEmailDocNum, mEmailID: string;
  mParams, mConditions: TNxParameters;
begin
  mSite := Sender.Site;
  mOS := mSite.BaseObjectSpace;

  mFirmBO := TBusRollSiteForm(mSite).CurrentObject;

  if mFirmBO = nil then begin
    NxShowSimpleMessage('No current firm found.', mSite);
    Exit;
  end;

  mFirm_ID := mFirmBO.OID;

  mTO := GetEmailForFirmBO(mFirmBO);

  if not NxIsValidEMail(mTO, false) then
    mTO := cFallbackEmail;

  if not NxIsValidEMail(mTO, false) then begin
    NxShowSimpleMessage('Firm has no valid e-mail address.', mSite);
    Exit;
  end;

  mInvoiceIDs := GetUnpaidInvoicesForFirm_ID(mOS, mFirm_ID);
  try
    if (mInvoiceIDs.Count = 0) then begin
      NxShowSimpleMessage('No unpaid invoices found for current firm.', mSite);
      Exit;
    end;

    mTemplate_ID := '~000001PSW';

    if not GetTemplate_ID(mSite, mTemplate_ID, 5, mTO) then begin
      NxShowSimpleMessage('Empty email template, done.', mSite);
      Exit;
    end;

    mMailTextBO := mOS.CreateObject(Class_BO_EmailTemplates);
    try
      mMailTextBO.Load(mTemplate_ID, nil);

      if not NxIsEmptyOID(mMailTextBO.GetFieldValueAsString('X_Form_ID')) then
        mIIForm_ID := mMailTextBO.GetFieldValueAsString('X_Form_ID')
      else
        mIIForm_ID := cIIForm_ID;

      mSubject := mMailTextBO.GetFieldValueAsString('X_Subject');
      mBody    := mMailTextBO.GetFieldValueAsString('X_Note');

      mFileName := 'LIPOELASTIC-Zahlungserinnerung' + '.pdf';

      mConditions := TNxParameters.Create;
      try
        mParams := mConditions.NewFromDataType(dtList, 'ID').AsList;
        mParams.NewFromDataType(dtInteger, 'UsedKind').AsInteger := ckList;
        mParams.NewFromDataType(dtString, 'ValueList').AsString := NxStringsToCkListStr(mInvoiceIDs);

        CFxReportManager.PrintByConditions(NxCreateContext(mOS), mConditions, GetDynSource(mOS, mIIForm_ID), mIIForm_ID, rtoFile, pekPDF, NxGetTempDir, mFileName);

        mEmailDocNum := SendInternalMail(mOS, cEmailAccount_ID, mTO, '', '', mSubject, mBody, NxGetTempDir + '\' + mFileName, mFirm_ID, '1000000101', '', '', '', 1);

        if NxIsBlank(mEmailDocNum) then begin
          NxShowSimpleMessage('Could not create e-mail. Terminating the process!', mSite);
          Exit;
        end;

        mEmailID := GetDocumentIDFromDisplayName(mOS, mEmailDocNum, 'EmailsSent');

        if NxIsEmptyOID(mEmailID) then begin
          NxShowSimpleMessage('Could not retrieve the email-sent ID. Terminating the process!', mSite);
          Exit;
        end;

        if not CreateXRelationBatch(mOS, Class_IssuedInvoice, Class_EmailSent, mEmailID, mInvoiceIDs, mSubject) then begin
          NxShowSimpleMessage('Relation creation failed. Terminating the process!', mSite);
          Exit;
        end;

        NxShowSimpleMessage('Reminder e-mail created.', mSite);

      finally
        mConditions.Free;
      end;

    finally
      mMailTextBO.Free;
    end;

  finally
    mInvoiceIDs.Free;
  end;
end;


function GetUnpaidInvoicesForFirm_ID(AOS: TNxCustomObjectSpace; AFirm_ID: string): TStringList;
begin
  Result:= TStringList.Create;

  AOS.SQLSelect(Format(
    ' SELECT A.ID ' +
    ' FROM IssuedInvoices A ' +
    ' JOIN Firms F ON F.ID = A.Firm_ID ' +
    ' WHERE ' +
    '   ( ' +
    '     (F.ID = ''%s'') ' +
    '     OR ' +
    '     ( ' +
    '       (F.Firm_ID IS NOT NULL) ' +
    '       AND (F.Firm_ID = ''%s'') ' +
    '     ) ' +
    '   ) ' +
    '   AND ' +
    '   ( ' +
    '     ( ' +
    '       ( ' +
    '         (A.Amount >= 0) ' +
    '         AND (A.PaidAmount <= 0) ' +
    '         AND ((A.Amount + A.PaidCreditAmount - A.PaidAmount - A.CreditAmount) > 0) ' +
    '       ) ' +
    '       OR ' +
    '       ( ' +
    '         (A.Amount < 0) ' +
    '         AND (A.PaidAmount >= 0) ' +
    '         AND ((A.Amount + A.PaidCreditAmount - A.PaidAmount - A.CreditAmount) < 0) ' +
    '       ) ' +
    '     ) ' +
    '     OR ' +
    '     ( ' +
    '       ( ' +
    '         (A.Amount >= 0) ' +
    '         AND (A.PaidAmount > 0) ' +
    '         AND ((A.Amount + A.PaidCreditAmount - A.PaidAmount - A.CreditAmount) > 0) ' +
    '       ) ' +
    '       OR ' +
    '       ( ' +
    '         (A.Amount < 0) ' +
    '         AND (A.PaidAmount < 0) ' +
    '         AND ((A.Amount + A.PaidCreditAmount - A.PaidAmount - A.CreditAmount) < 0) ' +
    '       ) ' +
    '     ) ' +
    '     OR ' +
    '     ( ' +
    '       ( ' +
    '         (A.Amount >= 0) ' +
    '         AND ((A.Amount + A.PaidCreditAmount - A.PaidAmount - A.CreditAmount) < 0) ' +
    '       ) ' +
    '       OR ' +
    '       ( ' +
    '         (A.Amount < 0) ' +
    '         AND ((A.Amount + A.PaidCreditAmount - A.PaidAmount - A.CreditAmount) > 0) ' +
    '       ) ' +
    '     ) ' +
    '     OR ' +
    '     ( ' +
    '       (A.Amount + A.PaidCreditAmount - A.PaidAmount - A.CreditAmount) < 0 ' +
    '     ) ' +
    '   ) ',
    [AFirm_ID, AFirm_ID]), Result);
end;

function GetEmailForFirmBO(AFirmBO: TNxCustomBusinessObject): string;
begin
  Result := '';

  if AFirmBO = nil then Exit;

  Result := AFirmBO.GetFieldValueAsString('ElectronicAddress_ID.Email');

  if not NxIsValidEMail(Result, false) then
    Result := AFirmBO.GetFieldValueAsString('ResidenceAddress_ID.Email');

  if not NxIsValidEMail(Result, false) then
    Result := '';
end;


begin
end.