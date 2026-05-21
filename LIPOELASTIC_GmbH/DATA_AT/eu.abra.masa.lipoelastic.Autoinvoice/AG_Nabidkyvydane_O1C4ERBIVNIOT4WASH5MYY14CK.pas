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
  mAction.Hint := 'Sending email from issued offer';
  mAction.Category := 'tabList';
  mAction.OnExecute := @SendEmail;
end;


Procedure SendEmail(Sender:tcomponent);
var
 mSite:TSiteForm;
 mIssuedOfferList,mIOPrintList:TStringList;
 i,j, mResult:integer;
 mIssuedOfferBO, mMailTextBO:TNxCustomBusinessObject;
 mOS:TNxCustomObjectSpace;
 mReceivedOrder_ID, mPDM_ID, mFileName, mSubject, mBody, mTO, mTemplate_ID, mIOForm_ID, mFirm_ID:string;
 mName, mOrderNumber, mTrackingNumber, mURL:string;
 mSameFirm:Boolean;
begin
 mSite:=TComponent(Sender).DynSite;
 mIssuedOfferList:=TStringList.create;
 TDynSiteForm(mSite).List.GetSelectedId(mIssuedOfferList);
 if mIssuedOfferList.count>0 then begin
   //if NxMessageBox('Confirm', 'Generate emails?', mdConfirm, mdbYesNo, 1, nil, False, mSite) = mrYes then begin
   if true then begin
    mOS:=TDynSiteForm(mSite).BaseObjectSpace;
    mSameFirm:=True;
    for i:=0 to mIssuedOfferList.count-1 do begin
      mIssuedOfferBO:=mOS.CreateObject(Class_IssuedOffer);
      mIssuedOfferBO.load(mIssuedOfferList.strings[i],nil);
      mTO:=mIssuedOfferBO.GetFieldValueAsString('Firm_ID.ElectronicAddress_ID.Email');
      if not(NxIsValidEMail(mTO,false)) then mTO:=mIssuedOfferBO.GetFieldValueAsString('Firm_ID.ResidenceAddress_ID.Email');
      if i=0 then mFirm_ID:=mIssuedOfferBO.GetFieldValueAsString('Firm_ID')
       else begin
         if mSameFirm then begin
           mSameFirm:=(mFirm_ID=mIssuedOfferBO.GetFieldValueAsString('Firm_ID'));
         end
       end;
    end;
    if not(mSameFirm) then mTO:='';
    if GetTemplate_ID(mSite, mTemplate_ID, 4, mTO) then begin
     j:=mIssuedOfferList.count;
     WaitWin.StartProgress('Please, wait ...', '', j);
        for i:=0 to mIssuedOfferList.count-1 do begin
          mName:='';
          mOrderNumber:='';
          mTrackingNumber:='';
          mURL:='';
          mIssuedOfferBO:=mOS.CreateObject(Class_IssuedOffer);
          mIssuedOfferBO.load(mIssuedOfferList.strings[i],nil);
          mName:=mIssuedOfferBO.GetFieldValueAsString('FirmOffice_ID.Address_ID.Recipient');
          mIOPrintList:=TStringList.Create;
               mIOPrintList.add(mIssuedOfferBO.OID);
               if mIOPrintList.Count>0 then begin
                  mFileName:=NxSearchReplace(mIssuedOfferBO.DisplayName,'/','-',[srall])+'.pdf';

                  mTO:=mIssuedOfferBO.GetFieldValueAsString('Firm_ID.ElectronicAddress_ID.Email');
                  //mTO:='odavidek@lipoelastic.com';
                  if not(NxIsValidEMail(mTO,false)) then mTO:=mIssuedOfferBO.GetFieldValueAsString('Firm_ID.ResidenceAddress_ID.Email');
                  if not(NxIsValidEMail(mTO,false)) then mTO:='odavidek@lipoelastic.com';
                  mMailTextBO:=mos.CreateObject(Class_BO_EmailTemplates);
                  mMailTextBO.Load(mTemplate_ID,nil);
                  if not(NxIsEmptyOID(mMailTextBO.GetFieldValueAsString('X_Form_ID'))) then mIOForm_ID:=mMailTextBO.GetFieldValueAsString('X_Form_ID')
                   else mIOForm_ID:=cIOForm_ID;
                  mSubject:=mMailTextBO.GetFieldValueAsString('X_Subject');
                  mSubject:=NxSearchReplace(mSubject,'#OfferNumber#',mIssuedOfferBO.DisplayName,[srAll]);
                  mBody:=mMailTextBO.GetFieldValueAsString('X_Note');
                  mBody:=NxSearchReplace(mBody,'#OfferNumber#',mIssuedOfferBO.DisplayName,[srAll]);
                  mBody:=NxSearchReplace(mBody,'#Name#',mName,[srAll]);
                  mBody:=NxSearchReplace(mBody,'#URL#',mURL,[srAll]);
                  mBody:=NxSearchReplace(mBody,'#TransportName#',mIssuedOfferBO.GetFieldValueAsString('TransportationType_ID.X_NameForEmail'),[srAll]);
                  mBody:=NxSearchReplace(mBody,'#DocumentDate#', FormatDateTime('DD/MM/YYYY', mIssuedOfferBO.GetFieldValueAsDateTime('DocDate$DATE')), [srAll]);
                  CFxReportManager.PrintByIDs(NxCreateContext(mOS),mIOPrintList,GetDynSource(mos,mIOForm_ID),mIOForm_ID,rtoFile,pekPDF,NxGetTempDir,mFileName);
                  SendInternalMail(mOS,cEmailAccount_ID,mTO,'','',
                                  mSubject,mBody,NxGetTempdir+'\'+mFileName,
                                  mIssuedOfferBO.GetFieldValueAsString('Firm_ID'),'1000000101','','',mIssuedOfferBO.OID,4);
                end;
               mIOPrintList.free;
          mIssuedOfferBO.free;
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