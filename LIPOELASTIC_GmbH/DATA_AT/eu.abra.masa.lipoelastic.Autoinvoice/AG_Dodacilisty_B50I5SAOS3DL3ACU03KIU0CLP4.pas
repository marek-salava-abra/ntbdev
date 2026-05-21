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
 mBODList,mBODPrintList:TStringList;
 i,j, mResult:integer;
 mBODBO, mOrderBO, mPDMBO, mMailTextBO:TNxCustomBusinessObject;
 mOS:TNxCustomObjectSpace;
 mReceivedOrder_ID, mPDM_ID, mFileName, mSubject, mBody, mTO, mTemplate_ID, mBODForm_ID, mFirm_ID:string;
 mName, mOrderNumber, mTrackingNumber, mURL:string;
 mSameFirm:Boolean;
begin
 mSite:=TComponent(Sender).DynSite;
 mBODList:=TStringList.create;
 TDynSiteForm(mSite).List.GetSelectedId(mBODList);
 if mBODList.count>0 then begin
   mOS:=TDynSiteForm(mSite).BaseObjectSpace;
   //if NxMessageBox('Confirm', 'Generate emails?', mdConfirm, mdbYesNo, 1, nil, False, mSite) = mrYes then begin
   if true then begin
    mTO:='';
    mSameFirm:=True;
    for i:=0 to mBODList.count-1 do begin
      mBODBO:= mOS.CreateObject(Class_BillOfDelivery);
      mBODBO.load(mBODList.strings[i],nil);
      mTO:=mBODBO.GetFieldValueAsString('Firm_ID.ElectronicAddress_ID.Email');
      if not(NxIsValidEMail(mTO,false)) then mTO:=mBODBO.GetFieldValueAsString('Firm_ID.ResidenceAddress_ID.Email');
      if i=0 then mFirm_ID:=mBODBO.GetFieldValueAsString('Firm_ID')
       else begin
         if mSameFirm then begin
           mSameFirm:=(mFirm_ID=mBODBO.GetFieldValueAsString('Firm_ID'));
         end
       end;
    end;
    if not(mSameFirm) then mTO:='';
    if GetTemplate_ID(mSite, mTemplate_ID, 6, mTO) then begin

     j:=mBODList.count;
     WaitWin.StartProgress('Please, wait ...', '', j);
        for i:=0 to mBODList.count-1 do begin
          mName:='';
          mOrderNumber:='';
          mTrackingNumber:='';
          mURL:='';
          mBODBO:=mOS.CreateObject(Class_BillOfDelivery);
          mBODBO.load(mBODList.strings[i],nil);
          mName:=mBODBO.GetFieldValueAsString('FirmOffice_ID.Address_ID.Recipient');
          mBODPrintList:=TStringList.Create;
               mBODPrintList.add(mBODBO.OID);
               if mBODPrintList.Count>0 then begin
                  mFileName:=NxSearchReplace(mBODBO.DisplayName,'/','-',[srall])+'.pdf';
                  if not(NxIsValidEMail(mTO,false)) then
                   mTO:=mBODBO.GetFieldValueAsString('Firm_ID.ElectronicAddress_ID.Email');
                  //mTO:='odavidek@lipoelastic.com';
                  if not(NxIsValidEMail(mTO,false)) then mTO:=mBODBO.GetFieldValueAsString('Firm_ID.ResidenceAddress_ID.Email');
                  if not(NxIsValidEMail(mTO,false)) then mTO:='odavidek@lipoelastic.com';
                  mMailTextBO:=mos.CreateObject(Class_BO_EmailTemplates);
                  mMailTextBO.Load(mTemplate_ID,nil);
                  if not(NxIsEmptyOID(mMailTextBO.GetFieldValueAsString('X_Form_ID'))) then mBODForm_ID:=mMailTextBO.GetFieldValueAsString('X_Form_ID')
                   else mBODForm_ID:=cBODForm_ID;
                  mSubject:=mMailTextBO.GetFieldValueAsString('X_Subject');
                  mSubject:=NxSearchReplace(mSubject,'#InvoiceNumber#',mBODBO.DisplayName,[srAll]);
                  mBody:=mMailTextBO.GetFieldValueAsString('X_Note');
                  //mBody:=NxSearchReplace(mBody,'#CN_NUMBER#',mBODBO.DisplayName,[srAll]);
                  //mBody:=NxSearchReplace(mBody,'#Name#',mName,[srAll]);
                  //mBody:=NxSearchReplace(mBody,'#INVOICE_NUMBER#',mBODBO.GetMonikerForFieldCode(mBODBO.GetFieldCode('Source_ID')).DisplayName,[srAll]);
                  //mBody:=NxSearchReplace(mBody,'#INVOICE_VS#',mBODBO.GetMonikerForFieldCode(mBODBO.GetFieldCode('Source_ID')).BusinessObject.GetFieldValueAsString('VarSymbol'),[srAll]);
                  //mBody:=NxSearchReplace(mBody,'#URL#',mURL,[srAll]);
                  //mBody:=NxSearchReplace(mBody,'#TransportName#',mBODBO.GetFieldValueAsString('TransportationType_ID.X_NameForEmail'),[srAll]);
                  CFxReportManager.PrintByIDs(NxCreateContext(mOS),mBODPrintList,GetDynSource(mos,mBODForm_ID),mBODForm_ID,rtoFile,pekPDF,NxGetTempDir,mFileName);
                  SendInternalMail(mOS,cEmailAccount_ID,mTO,'','',
                                  mSubject,mBody,NxGetTempdir+'\'+mFileName,
                                  mBODBO.GetFieldValueAsString('Firm_ID'),'1000000101','','',mBODBO.OID,6);
                end;
               mBODPrintList.free;
          mBODBO.free;
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