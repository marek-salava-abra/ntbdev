uses '.fce', '.const';

procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TBasicAction;
begin
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Name := 'actSendEmail';
  mAction.Caption := '##Send e-mail##';
  mAction.Category := 'tabList';
  mAction.OnExecute := @SendEmail;
end;

Procedure SendEmail(Sender: TComponent);
const
  cTEMPLATE_TYPE_ORDER_IN = 2;
var
  mSite: TSiteForm;
  mDocumentsList, mPrintList: TStringList;
  i, j, mResult:integer;
  mInvoiceBO, mOrderBO, mPDMBO, mMailTextBO: TNxCustomBusinessObject;
  mOS: TNxCustomObjectSpace;
  mReceivedOrder_ID, mPDM_ID, mFileName, mSubject, mBody, mTO, mTemplate_ID:string;
  mName, mOrderNumber, mTrackingNumber, mURL, mRecipientEmail, mForm_ID, mFirm_ID:string;
  mSameFirm:Boolean;
begin
  mSite:= Sender.DynSite;
  mOS:= mSite.BaseObjectSpace;

  mDocumentsList:= TStringList.create;
  try
    TDynSiteForm(mSite).FillListWithSelectedRows(mDocumentsList);
    if mDocumentsList.Count = 0 then
      exit;

    //if NxMessageBox('Confirm', 'Generate emails?', mdConfirm, mdbYesNo, 1, nil, False, mSite) = mrNo then
    //  exit;
    mSameFirm:=True;
    for i:=0 to mDocumentsList.count-1 do begin
      mOrderBO:= mOS.CreateObject(Class_ReceivedOrder);
      mOrderBO.load(mDocumentsList.strings[i],nil);
      mTO:=mOrderBO.GetFieldValueAsString('Firm_ID.ElectronicAddress_ID.Email');
      if not(NxIsValidEMail(mTO,false)) then mTO:=mOrderBO.GetFieldValueAsString('Firm_ID.ResidenceAddress_ID.Email');
      if i=0 then mFirm_ID:=mOrderBO.GetFieldValueAsString('Firm_ID')
       else begin
         if mSameFirm then begin
           mSameFirm:=(mFirm_ID=mOrderBO.GetFieldValueAsString('Firm_ID'));
         end
       end;
    end;
    if not(mSameFirm) then mTO:='';
    if not GetTemplate_ID(mSite, mTemplate_ID, cTEMPLATE_TYPE_ORDER_IN, mTO) then
    begin
      NxShowSimpleMessage('Empty email template, task cannot proceed.', msite);
      exit;
    end;

    WaitWin.StartProgress('Please, wait ...', '', mDocumentsList.Count);
    mOrderBO:= mOS.CreateObject(Class_ReceivedOrder);
    try
      for i:= 0 to mDocumentsList.Count -1 do
      begin
        mOrderBO.Load(mDocumentsList[i], nil);
        mOrderNumber:= mOrderBO.DisplayName;
        mName:= mOrderBO.GetFieldValueAsString('FirmOffice_ID.Address_ID.Recipient');
        mRecipientEmail:=mTO;
        {GetEmailAddress(mOrderBO, mRecipientEmail);

        mRecipientEmail:= InputBox('Confirm email - '+mOrderBO.DisplayName, 'Please confirm recipients email', mRecipientEmail, mSite);
        if not NxIsValidEMail(mRecipientEmail, false) then
        begin
          NxShowSimpleMessage('The email entered is not valid', msite);
          exit;
        end; }

        mPrintList:= TStringList.Create;
        try
          mPrintList.Add(mOrderBO.OID);
          mFirm_ID:= mOrderBO.GetFieldValueAsString('Firm_ID');
          mFileName:= NxSearchReplace(mOrderBO.DisplayName,'/','-',[srall])+'.pdf';

          GetEmailTemplateData(mOS, mTemplate_ID, mBody, mSubject, mForm_ID);

          ReplacePlaceholderText(mOrderBO, mBody);

          CFxReportManager.PrintByIDs(NxCreateContext(mOS),mPrintList, GetDynSource(mOS, mForm_ID), mForm_ID, rtoFile, pekPDF, NxGetTempDir, mFileName);

          SendInternalMail(mOS, cEmailAccount_ID, mRecipientEmail, '', '', mSubject, mBody, NxGetTempdir+'\'+mFileName, mFirm_ID, '1000000101', '', '', mOrderBO.OID, 2);

        finally
          mPrintList.Free;
        end;

        WaitWin.ChangeText(IntToStr(i + 1) + ' / ' + IntToStr(mDocumentsList.Count));
        WaitWin.StepIt;
      end;

    finally
      mOrderBO.Free;
      WaitWin.stop;
    end;
  finally
    mDocumentsList.Free;
  end;
end;


procedure GetEmailAddress(ABO: TNxCustomBusinessObject; var RecipientEmail:string);
begin
  RecipientEmail := ABO.GetFieldValueAsString('Firm_ID.ElectronicAddress_ID.Email');

  if not(NxIsValidEMail(RecipientEmail, false)) then
    RecipientEmail:= ABO.GetFieldValueAsString('Firm_ID.ResidenceAddress_ID.Email');

  if not(NxIsValidEMail(RecipientEmail, false)) then
    RecipientEmail:= 'odavidek@lipoelastic.com';
end;


procedure GetEmailTemplateData(AOS: TNxCustomObjectSpace; ATemplate_ID: string; var ABody, ASubject, AForm_ID: string);
var
  mTemplateBO: TNxCustomBusinessObject;
begin
  mTemplateBO:= AOS.CreateObject(Class_BO_EmailTemplates);
  try
    mTemplateBO.Load(ATemplate_ID, nil);
    ASubject:= mTemplateBO.GetFieldValueAsString('X_Subject');
    ABody:= mTemplateBO.GetFieldValueAsString('X_Note');
    AForm_ID:= mTemplateBO.GetFieldValueAsString('X_Form_ID');
  finally
    mTemplateBO.Free;
  end;
end;


procedure ReplacePlaceholderText(ABO: TNxCustomBusinessObject; var AText: string);
begin
  if ABO.HasField('ExternalNumber') then
  begin
    if NxIsBlank(ABO.GetFieldValueAsString('ExternalNumber')) then
      AText:= NxSearchReplace(AText, '#Auftragsnummer#', ABO.DisplayName, [srAll])
    else
      AText:= NxSearchReplace(AText, '#Auftragsnummer#', ABO.GetFieldValueAsString('ExternalNumber'), [srAll]);
  end;
end;


begin
end.