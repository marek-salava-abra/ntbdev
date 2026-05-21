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
  mAction.Hint := 'Sending email from credit note';
  mAction.Category := 'tabList';
  mAction.OnExecute := @SendEmail;
end;


Procedure SendEmail(Sender:tcomponent);
var
 mSite:TSiteForm;
 mCreditNoteList,mCNPrintList:TStringList;
 i,j, mResult:integer;
 mCreditNoteBO, mOrderBO, mPDMBO, mMailTextBO:TNxCustomBusinessObject;
 mOS:TNxCustomObjectSpace;
 mReceivedOrder_ID, mPDM_ID, mFileName, mSubject, mBody, mTO, mTemplate_ID, mICNForm_ID, mFirm_ID:string;
 mName, mOrderNumber, mTrackingNumber, mURL:string;
 mSameFirm:Boolean;
begin
 mSite:=TComponent(Sender).DynSite;
 mCreditNoteList:=TStringList.create;
 TDynSiteForm(mSite).List.GetSelectedId(mCreditNoteList);
 if mCreditNoteList.count>0 then begin
   mOS:=TDynSiteForm(mSite).BaseObjectSpace;
   //if NxMessageBox('Confirm', 'Generate emails?', mdConfirm, mdbYesNo, 1, nil, False, mSite) = mrYes then begin
   if true then begin
    mTO:='';
    mSameFirm:=True;
    for i:=0 to mCreditNoteList.count-1 do begin
      mCreditNoteBO:= mOS.CreateObject(Class_IssuedCreditNote);
      mCreditNoteBO.load(mCreditNoteList.strings[i],nil);
      mTO:=mCreditNoteBO.GetFieldValueAsString('Firm_ID.ElectronicAddress_ID.Email');
      if not(NxIsValidEMail(mTO,false)) then mTO:=mCreditNoteBO.GetFieldValueAsString('Firm_ID.ResidenceAddress_ID.Email');
      if i=0 then mFirm_ID:=mCreditNoteBO.GetFieldValueAsString('Firm_ID')
       else begin
         if mSameFirm then begin
           mSameFirm:=(mFirm_ID=mCreditNoteBO.GetFieldValueAsString('Firm_ID'));
         end
       end;
    end;
    if not(mSameFirm) then mTO:='';
    if GetTemplate_ID(mSite, mTemplate_ID, 3, mTO) then begin

     j:=mCreditNoteList.count;
     WaitWin.StartProgress('Please, wait ...', '', j);
        for i:=0 to mCreditNoteList.count-1 do begin
          mName:='';
          mOrderNumber:='';
          mTrackingNumber:='';
          mURL:='';
          mCreditNoteBO:=mOS.CreateObject(Class_IssuedCreditNote);
          mCreditNoteBO.load(mCreditNoteList.strings[i],nil);
          mName:=mCreditNoteBO.GetFieldValueAsString('FirmOffice_ID.Address_ID.Recipient');
          mCNPrintList:=TStringList.Create;
               mCNPrintList.add(mCreditNoteBO.OID);
               if mCNPrintList.Count>0 then begin
                  mFileName:=NxSearchReplace(mCreditNoteBO.DisplayName,'/','-',[srall])+'.pdf';
                  if not(NxIsValidEMail(mTO,false)) and not(mSameFirm) then
                   mTO:=mCreditNoteBO.GetFieldValueAsString('Firm_ID.ElectronicAddress_ID.Email');
                  //mTO:='odavidek@lipoelastic.com';
                  if not(NxIsValidEMail(mTO,false)) then mTO:=mCreditNoteBO.GetFieldValueAsString('Firm_ID.ResidenceAddress_ID.Email');
                  if not(NxIsValidEMail(mTO,false)) then mTO:='odavidek@lipoelastic.com';
                  mMailTextBO:=mos.CreateObject(Class_BO_EmailTemplates);
                  mMailTextBO.Load(mTemplate_ID,nil);
                  if not(NxIsEmptyOID(mMailTextBO.GetFieldValueAsString('X_Form_ID'))) then mICNForm_ID:=mMailTextBO.GetFieldValueAsString('X_Form_ID')
                   else mICNForm_ID:=cICNForm_ID;
                  mSubject:=mMailTextBO.GetFieldValueAsString('X_Subject');
                  mSubject:=NxSearchReplace(mSubject,'#InvoiceNumber#',mCreditNoteBO.DisplayName,[srAll]);
                  mBody:=mMailTextBO.GetFieldValueAsString('X_Note');
                  mBody:=NxSearchReplace(mBody,'#CN_NUMBER#',mCreditNoteBO.DisplayName,[srAll]);
                  mBody:=NxSearchReplace(mBody,'#Name#',mName,[srAll]);
                  mBody:=NxSearchReplace(mBody,'#INVOICE_NUMBER#',mCreditNoteBO.GetMonikerForFieldCode(mCreditNoteBO.GetFieldCode('Source_ID')).DisplayName,[srAll]);
                  mBody:=NxSearchReplace(mBody,'#INVOICE_VS#',mCreditNoteBO.GetMonikerForFieldCode(mCreditNoteBO.GetFieldCode('Source_ID')).BusinessObject.GetFieldValueAsString('VarSymbol'),[srAll]);
                  mBody:=NxSearchReplace(mBody,'#URL#',mURL,[srAll]);
                  mBody:=NxSearchReplace(mBody,'#TransportName#',mCreditNoteBO.GetFieldValueAsString('TransportationType_ID.X_NameForEmail'),[srAll]);
                  CFxReportManager.PrintByIDs(NxCreateContext(mOS),mCNPrintList,GetDynSource(mos,mICNForm_ID),mICNForm_ID,rtoFile,pekPDF,NxGetTempDir,mFileName);
                  SendInternalMail(mOS,cEmailAccount_ID,mTO,'','',
                                  mSubject,mBody,NxGetTempdir+'\'+mFileName,
                                  mCreditNoteBO.GetFieldValueAsString('Firm_ID'),'1000000101','','',mCreditNoteBO.OID,3);
                end;
               mCNPrintList.free;
          mCreditNoteBO.free;
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

begin
end.