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
  mAction.Hint := 'Sending email from invoice (optionaly with tracking number)';
  mAction.Category := 'tabList';
  mAction.OnExecute := @SendEmail;

  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Name := 'actSendEmail2';
  mAction.Caption := '##Send reminder##';
  mAction.Hint := 'Sending Reminder email';
  mAction.Category := 'tabList';
  mAction.OnExecute := @SendEmail2;

  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Name := 'actSendGrouppedEmail';
  mAction.Caption := '##Send groupped reminder##';
  mAction.Hint := 'Sending  groupped reminder email';
  mAction.Category := 'tabList';
  mAction.OnExecute := @SendGrouppedEmail;

end;

// doplnit emailovou adresu pokud jedna firma, pokud více jak 20 invoices, zakázat cokoliv

Procedure SendEmail2(Sender:tcomponent);
var
 mSite:TSiteForm;
 mInvoiceList,mIIPrintList:TStringList;
 i,j, mResult:integer;
 mInvoiceBO, mOrderBO, mPDMBO, mMailTextBO:TNxCustomBusinessObject;
 mOS:TNxCustomObjectSpace;
 mReceivedOrder_ID, mPDM_ID, mFileName, mSubject, mBody, mTO, mTemplate_ID, mIIForm_ID, mFirm_ID:string;
 mName, mOrderNumber, mTrackingNumber, mURL:string;
 mSameFirm:Boolean;
begin
 mSite:=TComponent(Sender).DynSite;
 mInvoiceList:=TStringList.create;
 TDynSiteForm(mSite).List.GetSelectedId(mInvoiceList);
 if mInvoiceList.count>0 then begin
  // if NxMessageBox('Confirm', 'Generate emails?', mdConfirm, mdbYesNo, 1, nil, False, mSite) = mrYes then begin
  if true then begin
    mOS:=TDynSiteForm(mSite).BaseObjectSpace;
    mSameFirm:=True;
    for i:=0 to mInvoiceList.count-1 do begin
      mInvoiceBO:=mOS.CreateObject(Class_IssuedInvoice);
      mInvoiceBO.load(mInvoiceList.strings[i],nil);
      mTO:=mInvoiceBO.GetFieldValueAsString('Firm_ID.ElectronicAddress_ID.Email');
      if i=0 then mFirm_ID:=mInvoiceBO.GetFieldValueAsString('Firm_ID')
       else begin
         if mSameFirm then begin
           mSameFirm:=(mFirm_ID=mInvoiceBO.GetFieldValueAsString('Firm_ID'));
         end
       end;
    end;
    if not(mSameFirm) then mTO:='';
    if GetTemplate_ID(mSite, mTemplate_ID, 5, mTO) then begin
     mOS:=TDynSiteForm(mSite).BaseObjectSpace;
     j:=mInvoiceList.count;
     WaitWin.StartProgress('Please, wait ...', '', j);
        for i:=0 to mInvoiceList.count-1 do begin
          mName:='';
          mOrderNumber:='';
          mTrackingNumber:='';
          mURL:='';
          mInvoiceBO:=mOS.CreateObject(Class_IssuedInvoice);
          mInvoiceBO.load(mInvoiceList.strings[i],nil);
          if mInvoiceBO.GetFieldValueAsFloat('PaidAmount')<mInvoiceBO.GetFieldValueAsFloat('Amount') then begin
            mName:=mInvoiceBO.GetFieldValueAsString('FirmOffice_ID.Address_ID.Recipient');
            mIIPrintList:=TStringList.Create;
                 mIIPrintList.add(mInvoiceBO.OID);
                 if mIIPrintList.Count>0 then begin
                    mFileName:=NxSearchReplace(mInvoiceBO.DisplayName,'/','-',[srall])+'.pdf';
                    if not(mSameFirm) then mto:='';
                    if not(NxIsValidEMail(mTO,false)) then mTO:=mInvoiceBO.GetFieldValueAsString('Firm_ID.ElectronicAddress_ID.Email');
                    if not(NxIsValidEMail(mTO,false)) then mTO:=mInvoiceBO.GetFieldValueAsString('Firm_ID.ResidenceAddress_ID.Email');
                    if not(NxIsValidEMail(mTO,false)) then mTO:='odavidek@lipoelastic.com';
                    mMailTextBO:=mos.CreateObject(Class_BO_EmailTemplates);
                    mMailTextBO.Load(mTemplate_ID,nil);
                    if not(NxIsEmptyOID(mMailTextBO.GetFieldValueAsString('X_Form_ID'))) then mIIForm_ID:=mMailTextBO.GetFieldValueAsString('X_Form_ID')
                     else mIIForm_ID:=cIIForm_ID;
                    mSubject:=mMailTextBO.GetFieldValueAsString('X_Subject');
                    mBody:=mMailTextBO.GetFieldValueAsString('X_Note');
                    CFxReportManager.PrintByIDs(NxCreateContext(mOS),mIIPrintList,GetDynSource(mos,mIIForm_ID),mIIForm_ID,rtoFile,pekPDF,NxGetTempDir,mFileName);
                    SendInternalMail(mOS,cEmailAccount_ID,mTO,'','',
                                    mSubject,mBody,NxGetTempdir+'\'+mFileName,
                                    mInvoiceBO.GetFieldValueAsString('Firm_ID'),'1000000101','','',mInvoiceBO.OID,1);
                  end;
                 mIIPrintList.free;
            mInvoiceBO.free;
          end;
          WaitWin.ChangeText(IntToStr(i+1) + ' / ' + IntToStr(j));
          WaitWin.StepIt;
        end;
     WaitWin.stop;
    end else begin
      NxShowSimpleMessage('Empty email template, done.',msite);
    end;
   end;
 end;
end;


Procedure SendEmail(Sender:tcomponent);
var
 mSite:TSiteForm;
 mInvoiceList,mIIPrintList:TStringList;
 i,j, mResult:integer;
 mInvoiceBO, mOrderBO, mPDMBO, mMailTextBO:TNxCustomBusinessObject;
 mOS:TNxCustomObjectSpace;
 mReceivedOrder_ID, mPDM_ID, mFileName, mSubject, mBody, mTO, mTemplate_ID, mIIForm_ID, mFirm_ID:string;
 mName, mOrderNumber, mTrackingNumber, mURL:string;
 mSameFirm:Boolean;
begin
 mSite:=TComponent(Sender).DynSite;
 mInvoiceList:=TStringList.create;
 TDynSiteForm(mSite).List.GetSelectedId(mInvoiceList);
 if mInvoiceList.count>0 then begin
   //if NxMessageBox('Confirm', 'Generate emails?', mdConfirm, mdbYesNo, 1, nil, False, mSite) = mrYes then begin
   if true then begin
    mOS:=TDynSiteForm(mSite).BaseObjectSpace;
    mSameFirm:=True;
    for i:=0 to mInvoiceList.count-1 do begin
      mInvoiceBO:=mOS.CreateObject(Class_IssuedInvoice);
      mInvoiceBO.load(mInvoiceList.strings[i],nil);
      mTO:=mInvoiceBO.GetFieldValueAsString('Firm_ID.ElectronicAddress_ID.Email');
      if not(NxIsValidEMail(mTO,false)) then mTO:=mInvoiceBO.GetFieldValueAsString('Firm_ID.ResidenceAddress_ID.Email');
      if i=0 then mFirm_ID:=mInvoiceBO.GetFieldValueAsString('Firm_ID')
       else begin
         if mSameFirm then begin
           mSameFirm:=(mFirm_ID=mInvoiceBO.GetFieldValueAsString('Firm_ID'));
         end
       end;
    end;
    //NxShowSimpleMessage(mTO,mSite);
    if not(mSameFirm) then mTO:='';
    if GetTemplate_ID(mSite, mTemplate_ID, 1, mTO) then begin
     j:=mInvoiceList.count;
     WaitWin.StartProgress('Please, wait ...', '', j);
        for i:=0 to mInvoiceList.count-1 do begin
          mName:='';
          mOrderNumber:='';
          mTrackingNumber:='';
          mURL:='';
          mInvoiceBO:=mOS.CreateObject(Class_IssuedInvoice);
          mInvoiceBO.load(mInvoiceList.strings[i],nil);
          mReceivedOrder_ID:=mOS.SQLSelectFirstAsString('select distinct(sd2.provide_id) from storedocuments2 sd2 '+
                                                        'left join issuedinvoices2 ii2 on ii2.providerow_id=sd2.id where ii2.parent_id='+QuotedStr(mInvoiceBO.OID),'');
          if not(NxIsEmptyOID(mReceivedOrder_ID)) then begin
            mOrderBO:=mOS.CreateObject(Class_ReceivedOrder);
            mOrderBO.load(mReceivedOrder_ID,nil);
            mOrderNumber:=mOrderBO.GetFieldValueAsString('ExternalNumber');
             mPDM_ID:=mOS.SQLSelectFirstAsString('Select id from pdmissueddocs where x_externalnumber='+QuotedStr(mOrderBO.GetFieldValueAsString('ExternalNumber')),'');
             if NxIsEmptyOID(mPDM_ID) then mPDM_ID:=mOS.SQLSelectFirstAsString('Select id from pdmissueddocs where x_externalnumber='+QuotedStr(mOrderBO.DisplayName),'');
             if not(NxIsEmptyOID(mPDM_ID)) then begin
               mPDMBO:=mOS.CreateObject(Class_PDMIssuedDoc);
               mPDMBO.load(mPDM_ID,nil);
               mTrackingNumber:=mPDMBO.GetFieldValueAsString('X_TrackingNumber');
               mURL:=mPDMBO.GetFieldValueAsString('X_TrackingURL');
               mPDMBO.free;
             end;
            mOrderBO.free;
          end;
          mName:=mInvoiceBO.GetFieldValueAsString('FirmOffice_ID.Address_ID.Recipient');
          mIIPrintList:=TStringList.Create;
               mIIPrintList.add(mInvoiceBO.OID);
               if mIIPrintList.Count>0 then begin
                  mFileName:=NxSearchReplace(mInvoiceBO.DisplayName,'/','-',[srall])+'.pdf';
                  if not(NxIsValidEMail(mTO,false)) then
                   mTO:=mInvoiceBO.GetFieldValueAsString('Firm_ID.ElectronicAddress_ID.Email');
                  if not(NxIsValidEMail(mTO,false)) then mTO:=mInvoiceBO.GetFieldValueAsString('Firm_ID.ResidenceAddress_ID.Email');
                  if not(NxIsValidEMail(mTO,false)) then mTO:='odavidek@lipoelastic.com';
                  mMailTextBO:=mos.CreateObject(Class_BO_EmailTemplates);
                  mMailTextBO.Load(mTemplate_ID,nil);
                  if not(NxIsEmptyOID(mMailTextBO.GetFieldValueAsString('X_Form_ID'))) then mIIForm_ID:=mMailTextBO.GetFieldValueAsString('X_Form_ID')
                   else mIIForm_ID:=cIIForm_ID;
                  mSubject:=mMailTextBO.GetFieldValueAsString('X_Subject');
                  mSubject:=NxSearchReplace(mSubject,'#InvoiceNumber#',mInvoiceBO.DisplayName,[srAll]);
                  mBody:=mMailTextBO.GetFieldValueAsString('X_Note');
                  mBody:=NxSearchReplace(mBody,'#InvoiceNumber#',mInvoiceBO.DisplayName,[srAll]);
                  mBody:=NxSearchReplace(mBody,'#Name#',mName,[srAll]);
                  mBody:=NxSearchReplace(mBody,'#YourRef#',mOrderNumber,[srAll]);
                  mBody:=NxSearchReplace(mBody,'#TrackingNumber#',mTrackingNumber,[srAll]);
                  mBody:=NxSearchReplace(mBody,'#URL#',mURL,[srAll]);
                  mBody:=NxSearchReplace(mBody,'#TransportName#',mInvoiceBO.GetFieldValueAsString('TransportationType_ID.X_NameForEmail'),[srAll]);
                  CFxReportManager.PrintByIDs(NxCreateContext(mOS),mIIPrintList,GetDynSource(mos,mIIForm_ID),mIIForm_ID,rtoFile,pekPDF,NxGetTempDir,mFileName);
                  SendInternalMail(mOS,cEmailAccount_ID,mTO,'','',
                                  mSubject,mBody,NxGetTempdir+'\'+mFileName,
                                  mInvoiceBO.GetFieldValueAsString('Firm_ID'),'1000000101','','',mInvoiceBO.OID,1);
                end;
               mIIPrintList.free;
          mInvoiceBO.free;
          WaitWin.ChangeText(IntToStr(i+1) + ' / ' + IntToStr(j));
          WaitWin.StepIt;
        end;
     WaitWin.stop;
    end else begin
      NxShowSimpleMessage('Empty email template, done.',msite);
    end;
   end;
 end;
end;


Procedure SendGrouppedEmail(Sender:tcomponent);
var
  mSite: TSiteForm;
  mInvoiceList: TStringList;
  mFirmGroups: TStringList; // Key=Firm_ID, Objects[idx]=TStringList of InvoiceOIDs
  mIDsForFirm: TStringList;
  mOS: TNxCustomObjectSpace;
  mInvoiceBO, mMailTextBO: TNxCustomBusinessObject;
  i, idx, j, firmCount: Integer;
  mTemplate_ID, mIIForm_ID, firmOID, mTO, mSubject, mBody, mFileName, mEmailDocNum, mEmailID, mFirm_ID: string;
  mParams, mConditions: TNxParameters;
  mSameFirm:boolean;
  function GetOrCreateFirmList(const AFirmOID: string): TStringList;
  var k: Integer;
  begin
    k := mFirmGroups.IndexOf(AFirmOID);
    if k < 0 then begin
      Result := TStringList.Create;
      mFirmGroups.AddObject(AFirmOID, Result);
    end else
      Result := TStringList(mFirmGroups.Objects[k]);
  end;

begin
  mSite := TComponent(Sender).DynSite;
  mOS := TDynSiteForm(mSite).BaseObjectSpace;

  mInvoiceList := TStringList.Create;
  mFirmGroups := TStringList.Create;

  try
    TDynSiteForm(mSite).FillListWithSelectedRows(mInvoiceList);

    if mInvoiceList.Count = 0 then Exit;
    mOS:=TDynSiteForm(mSite).BaseObjectSpace;
    mSameFirm:=True;
    for i:=0 to mInvoiceList.count-1 do begin
      mInvoiceBO:=mOS.CreateObject(Class_IssuedInvoice);
      mInvoiceBO.load(mInvoiceList.strings[i],nil);
      mTO:=mInvoiceBO.GetFieldValueAsString('Firm_ID.ElectronicAddress_ID.Email');
      if not(NxIsValidEMail(mTO,false)) then mTO:=mInvoiceBO.GetFieldValueAsString('Firm_ID.ResidenceAddress_ID.Email');
      if i=0 then mFirm_ID:=mInvoiceBO.GetFieldValueAsString('Firm_ID')
       else begin
         if mSameFirm then begin
           mSameFirm:=(mFirm_ID=mInvoiceBO.GetFieldValueAsString('Firm_ID'));
         end;
      end;
    end;
    if not(mSameFirm) then begin
      mto:='';
    end;
    //if NxMessageBox('Confirm', 'Generate emails?', mdConfirm, mdbYesNo, 1, nil, False, mSite) <> mrYes then Exit;
    if not GetTemplate_ID(mSite, mTemplate_ID, 5, mTO) then begin
      NxShowSimpleMessage('Empty email template, done.', mSite);
      Exit;
    end;

    // 1) SESKUPENÍ faktur podle firmy (jen nezaplacené)
    WaitWin.StartProgress('Please, wait ...', 'Grouping invoices ...', mInvoiceList.Count);
    for i := 0 to mInvoiceList.Count - 1 do begin
      mInvoiceBO := mOS.CreateObject(Class_IssuedInvoice);
      try
        mInvoiceBO.Load(mInvoiceList.Strings[i], nil);

        if mInvoiceBO.GetFieldValueAsFloat('PaidAmount') < mInvoiceBO.GetFieldValueAsFloat('Amount') then begin
          firmOID := mInvoiceBO.GetFieldValueAsString('Firm_ID');
          mIDsForFirm := GetOrCreateFirmList(firmOID);
          mIDsForFirm.Add(mInvoiceBO.OID);
        end;

      finally
        mInvoiceBO.Free;
      end;

      WaitWin.ChangeText(IntToStr(i+1) + ' / ' + IntToStr(mInvoiceList.Count));
      WaitWin.StepIt;
    end;
    WaitWin.Stop;

    // 2) Načtení šablony jen jednou
    mMailTextBO := mOS.CreateObject(Class_BO_EmailTemplates);
    try
      mMailTextBO.Load(mTemplate_ID, nil);
      //TESTING
      //mIIForm_ID:= 'O700000001';

      if not NxIsEmptyOID(mMailTextBO.GetFieldValueAsString('X_Form_ID')) then
        mIIForm_ID := mMailTextBO.GetFieldValueAsString('X_Form_ID')
      else
        mIIForm_ID := cIIForm_ID;



      mSubject := mMailTextBO.GetFieldValueAsString('X_Subject');
      mBody    := mMailTextBO.GetFieldValueAsString('X_Note');

      // 3) ODESLÁNÍ: 1 mail na firmu
      firmCount := mFirmGroups.Count;
      WaitWin.StartProgress('Please, wait ...', 'Sending emails ...', firmCount);

      for idx := 0 to firmCount - 1 do begin
        firmOID := mFirmGroups.Strings[idx];
        mIDsForFirm := TStringList(mFirmGroups.Objects[idx]);
        mTO:='';
        if (mIDsForFirm = nil) or (mIDsForFirm.Count = 0) then begin
          WaitWin.StepIt;
          Continue;
        end;

        // Z prvního dokladu si vytáhni email (a případně další info)
        mInvoiceBO := mOS.CreateObject(Class_IssuedInvoice);
        try
          mInvoiceBO.Load(mIDsForFirm.Strings[0], nil);
          //TESTING
          //mTO:= 'alex.coufal@abra.eu';
          if not(NxIsValidEMail(mTO,false)) then
           mTO := mInvoiceBO.GetFieldValueAsString('Firm_ID.ElectronicAddress_ID.Email');
          if not NxIsValidEMail(mTO, false) then
            mTO := mInvoiceBO.GetFieldValueAsString('Firm_ID.ResidenceAddress_ID.Email');

          if not(NxIsValidEMail(mTO,false)) then
            mTO := 'odavidek@lipoelastic.com';

          if not NxIsValidEMail(mTO, false) then
          begin
            WaitWin.StepIt;
            Continue;
          end;

          // Jedno PDF pro celou firmu (multi-page)
          mFileName := 'LIPOELASTIC-Zahlungserinnerung' + '.pdf';

          mParams:= TNxParameters.Create;
          mConditions:= TNxParameters.Create;
          try
            mParams:= mConditions.NewFromDataType(dtList, 'ID').AsList;
            mParams.NewFromDataType(dtInteger, 'UsedKind').AsInteger:= ckList;
            mParams.NewFromDataType(dtString, 'ValueList').AsString:= NxStringsToCkListStr(mIDsForFirm);

            CFxReportManager.PrintByConditions(NxCreateContext(mOS), mConditions, GetDynSource(mOS, mIIForm_ID), mIIForm_ID, rtoFile, pekPDF, NxGetTempDir, mFileName);

            mEmailDocNum:= SendInternalMail(mOS, cEmailAccount_ID, mTO, '', '', mSubject, mBody, NxGetTempDir + '\' + mFileName, firmOID, '1000000101', '', '', '', 1);
            if NxIsBlank(mEmailDocNum) then
            begin
              NxShowSimpleMessage('Could not create e-mail. Terminating the process!', mSite);
              exit;
            end;

            mEmailID:= GetDocumentIDFromDisplayName(mOS, mEmailDocNum, 'EmailsSent');
            if NxIsEmptyOID(mEmailID) then
            begin
              NxShowSimpleMessage('Could not retrieve the email-sent ID. Terminating the process!', mSite);
              exit;
            end;

            if not CreateXRelationBatch(mOS, Class_IssuedInvoice, Class_EmailSent, mEmailID, mIDsForFirm, mSubject) then
            begin
              NxShowSimpleMessage('Relation creation failed. Terminating the process!', mSite);
              exit;
            end;

          finally
            mParams.Free;
            mConditions.Free;
          end;
        finally
          mInvoiceBO.Free;
        end;

        WaitWin.ChangeText(IntToStr(idx+1) + ' / ' + IntToStr(firmCount));
        WaitWin.StepIt;
      end;

      WaitWin.Stop;

    finally
      mMailTextBO.Free;
    end;

  finally
    // Uvolnit seznamy v objektech
    for i := 0 to mFirmGroups.Count - 1 do
      if mFirmGroups.Objects[i] <> nil then
        TStringList(mFirmGroups.Objects[i]).Free;

    mFirmGroups.Free;
    mInvoiceList.Free;
  end;
end;


function CreateXRelationBatch(AOS: TNxCustomObjectSpace; ASourceCLSID, ADestinationCLSID, ADestinationID: string; ASourceIDsList: TStringList; ADescription: string): Boolean;
var
  mRelBO: TNxCustomBusinessObject;
  i: integer;
begin
  Result:= True;

  mRelBO:= AOS.CreateObject(Class_UserXLink);
  try
    try
      for i:= 0 to ASourceIDsList.Count -1 do
      begin
        mRelBO.New;
        mRelBO.Prefill;
        mRelBO.SetFieldValueAsString('SourceCLSID', ASourceCLSID);
        mRelBO.SetFieldValueAsString('Source_ID', ASourceIDsList[i]);
        mRelBO.SetFieldValueAsString('DestinationCLSID', ADestinationCLSID);
        mRelBO.SetFieldValueAsString('Destination_ID', ADestinationID);
        mRelBO.SetFieldValueAsBoolean('DisplayAsSystem', True);
        mRelBO.SetFieldValueAsString('Description', ADescription);
        mRelBO.Save;
      end;
    except
      Result:= False;
      NxShowSimpleMessage('Could not create relation. Error: '+ExceptionMessage, nil);
      exit;
    end;
  finally
    mRelBO.Free;
  end;
end;

begin
end.