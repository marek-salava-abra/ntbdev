uses 'eu.simon.ESFunkce.mail';

procedure GenMailLP (OS: TNxCustomObjectSpace;
  var Success: Boolean; var LogInfoStr: String);

var
 mMailList, mPrintList, mInvList:TStringList;
 mFirmMail,mDivisionMail, mDateString, mReplyTo, mReminderEmail:String;
 mSQL:String;
 mIIBO,mPDMBO, mTextBO, mROBO:TNxCustomBusinessObject;
 mIIRow:TNxCustomBusinessMonikerCollection;
 mBusOrder_id, mDivision_ID, mRO_ID:String;
 i,j,k :Integer;
 fName, mText_ID:String;
 mIDList, mTextList:TStringList;
 mMailText, mMena, mForm_ID, mSubject:string;
begin
      mTextBO:=OS.CreateObject('PKVPDHXNS3L4DE0DC0XUE1FP2K');
      mTextBO.Load('8C92000101',nil);
      mIDList:=TStringList.Create;
        OS.SQLSelect('SELECT A.ID FROM PDMIssuedDocs A '+
                            'left join PDMPostProviders B on b.id=a.PostProvider_ID '+
                            'WHERE a.X_MailSent='+Quotedstr('N')+' and A.X_LP_State_ID = '
                            +QuotedStr('A0S5000101')+' and a.X_LP_IsInClosingDay=''A'' and a.X_LP_SourceCLSID='
                            +QuotedStr('050I5SAOS3DL3ACU03KIU0CLP4'),mIDList);
        for i:=0 to mIDList.count-1 do begin
           mPrintList:=TStringList.Create;
           mDivision_ID:='';
           mDivisionMail:='';
           mBusOrder_id:='';
           mReminderEmail:='Prázdný';
           mPDMBO:= OS.CreateObject(Class_PDMIssuedDoc);
           mMailText:=mTextBO.GetFieldValueAsString('X_note');
           mPDMBO.Load(mIDList.Strings[i],nil);
           //mForm_ID:='4N70000101';
           mInvList:=TStringList.create;
           os.SQLSelect(format('select first 1 ii2.parent_id from issuedinvoices2 ii2 left join storedocuments2 sd2 on sd2.id=ii2.providerow_id where sd2.parent_id=''%s'' ',[mPDMBO.GetFieldValueAsString('X_LP_Source_ID')]),mInvList);
           if mInvList.count=0 then os.SQLSelect(format('select id from issuedinvoices where id=''%s'' ',[mPDMBO.GetFieldValueAsString('X_LP_Source_ID')]),mInvList);
           if mInvList.Count=1 then begin
               mIIBO:=os.CreateObject(Class_IssuedInvoice);
               mIIBO.Load(mInvList.strings[0],nil);

               if (mIIBO.GetFieldValueAsString('Paymenttype_id.code') in ['PK','U1','Z1']) and not(miibo.GetFieldValueAsString('TransportationType_ID')='00000O1000') then begin
                 mRO_ID:=GetRO_ID(OS,mPDMBO.GetFieldValueAsString('X_LP_OrderNumber'));
                 mROBO:=OS.CreateObject(Class_ReceivedOrder);
                 mROBO.Load(mRO_ID,nil);
                 mPrintList.Add(mIIBO.OID);
                     if mIIBO.GetFieldValueAsString('Currency_ID.Code')='CZK' then mMena:='Kč' else mMena:=mIIBO.GetFieldValueAsString('Currency_ID.Code');
                     mMailText:=NxSearchReplace(mMailText,'#CISLOFAKTURY#',mIIBO.DisplayName,[srAll]);
                     mMailText:=NxSearchReplace(mMailText,'#CISOBJ#',mPDMBO.GetFieldValueAsString('X_LP_OrderNumber'),[srAll]);
                     mMailText:=NxSearchReplace(mMailText,'#URL#',mPDMBO.GetFieldValueAsString('X_LP_Tracking_URL'),[srAll]);
                     mMailText:=NxSearchReplace(mMailText,'#TrackingNumber#',mPDMBO.GetFieldValueAsString('X_LP_BarCode'),[srAll]);
                     mMailText:=NxSearchReplace(mMailText,'#CASTKA_MENA#',NxFormatNumeric('0.00,',mIIBO.GetFieldValueAsFloat('Amount'))+' '+mMena,[srAll]);
                 mFirmMail:=mPDMBO.GetFieldValueAsString('TargetAddress_ID.Email');
                 //mMailText:=NxSearchReplace(mMailText,'#TEMP#','email by byl odeslán na adresu :'+mFirmMail,[srall]);
                 //mSubject:=NxSearchReplace(mTextBO.GetFieldValueAsString('X_Subject'),'#CISLO#',mPDMBO.GetFieldValueAsString('X_LP_OrderNumber'),[srAll]);
                 mSubject:='Objednávka '+mPDMBO.GetFieldValueAsString('X_LP_OrderNumber')+' odeslána - faktura v příloze';
                 if not(NxIsValidEMail(mFirmMail,false)) then mFirmMail:='eshop@naradi-simon.cz';
                 fname:=NxSearchReplace(mIIBO.DisplayName,'/','-',[srall])+'.pdf';
                 CFxReportManager.PrintByIDs(NxCreateContext_1(mIIBO),mPrintList,GetDynSource(os,'4N70000101'),'4N70000101',rtoFile,pekPDF,NxGetTempDir,fName);
                 mROBO.SetFieldValueAsString('U_OrderState_ID','8C92000101');
                 mROBO.SetFieldValueAsString('PMState_ID','6010000101');
                 mROBO.save;
                 SendInternalMail(OS, {'jana.novotna@naradi-simon.cz'} mFirmMail,'','',
                                     mSubject{+' email by byl odeslán na '+mFirmMail},mMailText,
                                     NxGetTempdir+'\'+fName,'',mPDMBO.GetFieldValueAsString('Firm_ID'),mPDMBO.GetFieldValueAsString('Division_ID'),mPDMBO.GetFieldValueAsString('BusOrder_ID'),'1300000101', mROBO.OID);
                 DeleteFile(NxGetTempdir+'\'+fName);
                 //LogInfoStr:=LogInfoStr+'Doklad '+Miibo.DisplayName+' '+ mIIBO.GetFieldValueAsString('Firm_ID.name')+' email pro upomínky '+mFirmMail+Chr(10)+Chr(13);
                 mROBO.free;
                 mPrintList.free;
               end;

               if (mIIBO.GetFieldValueAsString('Paymenttype_id.code') in ['D1','D2','D3']) and not(miibo.GetFieldValueAsString('TransportationType_ID')='00000O1000') then begin
                 mRO_ID:=GetRO_ID(OS,mPDMBO.GetFieldValueAsString('X_LP_OrderNumber'));
                 mROBO:=OS.CreateObject(Class_ReceivedOrder);
                 mROBO.Load(mRO_ID,nil);
                 mPrintList.Add(mROBO.OID);
                     if mIIBO.GetFieldValueAsString('Currency_ID.Code')='CZK' then mMena:='Kč' else mMena:=mIIBO.GetFieldValueAsString('Currency_ID.Code');
                     mMailText:=NxSearchReplace(mMailText,'#CISLOFAKTURY#',mIIBO.DisplayName,[srAll]);
                     mMailText:=NxSearchReplace(mMailText,'#CISOBJ#',mPDMBO.GetFieldValueAsString('X_LP_OrderNumber'),[srAll]);
                     mMailText:=NxSearchReplace(mMailText,'#URL#',mPDMBO.GetFieldValueAsString('X_LP_Tracking_URL'),[srAll]);
                     mMailText:=NxSearchReplace(mMailText,'#TrackingNumber#',mPDMBO.GetFieldValueAsString('X_LP_BarCode'),[srAll]);
                     mMailText:=NxSearchReplace(mMailText,'#CASTKA_MENA#',NxFormatNumeric('0.00,',mIIBO.GetFieldValueAsFloat('Amount'))+' '+mMena,[srAll]);
                 mFirmMail:=mPDMBO.GetFieldValueAsString('TargetAddress_ID.Email');
                 //mMailText:=NxSearchReplace(mMailText,'#TEMP#','email by byl odeslán na adresu :'+mFirmMail,[srall]);
                 //mSubject:=NxSearchReplace(mTextBO.GetFieldValueAsString('X_Subject'),'#CISLO#',mPDMBO.GetFieldValueAsString('X_LP_OrderNumber'),[srAll]);
                 mSubject:='Objednávka '+mPDMBO.GetFieldValueAsString('X_LP_OrderNumber')+' odeslána';
                 if not(NxIsValidEMail(mFirmMail,false)) then mFirmMail:='eshop@naradi-simon.cz';
                 fname:=NxSearchReplace(mROBO.DisplayName,'/','-',[srall])+'.pdf';
                 CFxReportManager.PrintByIDs(NxCreateContext_1(mIIBO),mPrintList,GetDynSource(os,'4VD0000101'),'4VD0000101',rtoFile,pekPDF,NxGetTempDir,fName);
                 mROBO.SetFieldValueAsString('U_OrderState_ID','8C92000101');
                 mROBO.SetFieldValueAsString('PMState_ID','6010000101');
                 mROBO.save;
                 SendInternalMail(OS, {'jana.novotna@naradi-simon.cz'} mFirmMail,'','',
                                     mSubject{+' email by byl odeslán na '+mFirmMail},mMailText,
                                     NxGetTempdir+'\'+fName,'',mPDMBO.GetFieldValueAsString('Firm_ID'),mPDMBO.GetFieldValueAsString('Division_ID'),mPDMBO.GetFieldValueAsString('BusOrder_ID'),'1300000101', mROBO.OID);
                 DeleteFile(NxGetTempdir+'\'+fName);
                 //LogInfoStr:=LogInfoStr+'Doklad '+Miibo.DisplayName+' '+ mIIBO.GetFieldValueAsString('Firm_ID.name')+' email pro upomínky '+mFirmMail+Chr(10)+Chr(13);
                 mROBO.free;
                 mPrintList.free;
               end;
               mIIBO.Free;


               mPDMBO.SetFieldValueAsBoolean('X_MailSent',True);
               mPDMBO.save;
               mPDMBO.free;
           end;
           mInvList.free;


      end;
     LogInfoStr:='Zpracoval jsem '+IntToStr(mIDList.count)+' záznamů odeslané pošty';
     mIDList.free;
end;

procedure GenMailLPOrder (OS: TNxCustomObjectSpace;
  var Success: Boolean; var LogInfoStr: String);

var
 mMailList, mPrintList, mInvList:TStringList;
 mFirmMail,mDivisionMail, mDateString, mReplyTo, mReminderEmail:String;
 mSQL:String;
 mIIBO,mPDMBO, mTextBO, mROBO:TNxCustomBusinessObject;
 mIIRow:TNxCustomBusinessMonikerCollection;
 mBusOrder_id, mDivision_ID, mRO_ID:String;
 i,j,k :Integer;
 fName, mText_ID:String;
 mIDList, mTextList:TStringList;
 mMailText, mMena, mForm_ID, mSubject:string;
begin
      mTextBO:=OS.CreateObject('PKVPDHXNS3L4DE0DC0XUE1FP2K');
      mTextBO.Load('8C92000101',nil);
      mIDList:=TStringList.Create;
        OS.SQLSelect('SELECT A.ID FROM PDMIssuedDocs A '+
                            'left join PDMPostProviders B on b.id=a.PostProvider_ID '+
                            'WHERE a.X_MailSent='+Quotedstr('N')+' and A.X_LP_State_ID = '
                            +QuotedStr('A0S5000101')+' and a.X_LP_IsInClosingDay=''A'' and a.X_LP_SourceCLSID='
                            +QuotedStr('01CPMINJW3DL342X01C0CX3FCC'),mIDList);
        for i:=0 to mIDList.count-1 do begin
           mPrintList:=TStringList.Create;
           mDivision_ID:='';
           mDivisionMail:='';
           mBusOrder_id:='';
           mReminderEmail:='Prázdný';
           mPDMBO:= OS.CreateObject(Class_PDMIssuedDoc);
           mMailText:=mTextBO.GetFieldValueAsString('X_note');
           mPDMBO.Load(mIDList.Strings[i],nil);
           //mForm_ID:='4N70000101';
           mInvList:=TStringList.create;
           os.SQLSelect(format('select first 1 ii2.parent_id from issuedinvoices2 ii2 left join storedocuments2 sd2 on sd2.id=ii2.providerow_id where sd2.provide_id=''%s'' ',[mPDMBO.GetFieldValueAsString('X_LP_Source_ID')]),mInvList);
           if mInvList.count=0 then os.SQLSelect(format('select id from issuedinvoices where id=''%s'' ',[mPDMBO.GetFieldValueAsString('X_LP_Source_ID')]),mInvList);
           if mInvList.Count=1 then begin
               mIIBO:=os.CreateObject(Class_IssuedInvoice);
               mIIBO.Load(mInvList.strings[0],nil);

               if mIIBO.GetFieldValueAsString('Paymenttype_id.code') in ['PK','U1','Z1']  then begin
                 mRO_ID:=GetRO_ID(OS,mPDMBO.GetFieldValueAsString('X_LP_OrderNumber'));
                 mROBO:=OS.CreateObject(Class_ReceivedOrder);
                 mROBO.Load(mRO_ID,nil);
                 mPrintList.Add(mIIBO.OID);
                     if mIIBO.GetFieldValueAsString('Currency_ID.Code')='CZK' then mMena:='Kč' else mMena:=mIIBO.GetFieldValueAsString('Currency_ID.Code');
                     mMailText:=NxSearchReplace(mMailText,'#CISLOFAKTURY#',mIIBO.DisplayName,[srAll]);
                     mMailText:=NxSearchReplace(mMailText,'#CISOBJ#',mPDMBO.GetFieldValueAsString('X_LP_OrderNumber'),[srAll]);
                     mMailText:=NxSearchReplace(mMailText,'#URL#',mPDMBO.GetFieldValueAsString('X_LP_Tracking_URL'),[srAll]);
                     mMailText:=NxSearchReplace(mMailText,'#TrackingNumber#',mPDMBO.GetFieldValueAsString('X_LP_BarCode'),[srAll]);
                     mMailText:=NxSearchReplace(mMailText,'#CASTKA_MENA#',NxFormatNumeric('0.00,',mIIBO.GetFieldValueAsFloat('Amount'))+' '+mMena,[srAll]);
                 mFirmMail:=mPDMBO.GetFieldValueAsString('TargetAddress_ID.Email');
                 //mMailText:=NxSearchReplace(mMailText,'#TEMP#','email by byl odeslán na adresu :'+mFirmMail,[srall]);
                 //mSubject:=NxSearchReplace(mTextBO.GetFieldValueAsString('X_Subject'),'#CISLO#',mPDMBO.GetFieldValueAsString('X_LP_OrderNumber'),[srAll]);
                 mSubject:='Objednávka '+mPDMBO.GetFieldValueAsString('X_LP_OrderNumber')+' odeslána - faktura v příloze';
                 if not(NxIsValidEMail(mFirmMail,false)) then mFirmMail:='eshop@naradi-simon.cz';
                 fname:=NxSearchReplace(mIIBO.DisplayName,'/','-',[srall])+'.pdf';
                 CFxReportManager.PrintByIDs(NxCreateContext_1(mIIBO),mPrintList,GetDynSource(os,'4N70000101'),'4N70000101',rtoFile,pekPDF,NxGetTempDir,fName);
                 mROBO.SetFieldValueAsString('U_OrderState_ID','8C92000101');
                 mROBO.save;
                 SendInternalMail(OS, {'jana.novotna@naradi-simon.cz'} mFirmMail,'','',
                                     mSubject{+' email by byl odeslán na '+mFirmMail},mMailText,
                                     NxGetTempdir+'\'+fName,'',mPDMBO.GetFieldValueAsString('Firm_ID'),mPDMBO.GetFieldValueAsString('Division_ID'),mPDMBO.GetFieldValueAsString('BusOrder_ID'),'1300000101',mROBO.OID);
                 DeleteFile(NxGetTempdir+'\'+fName);
                 //LogInfoStr:=LogInfoStr+'Doklad '+Miibo.DisplayName+' '+ mIIBO.GetFieldValueAsString('Firm_ID.name')+' email pro upomínky '+mFirmMail+Chr(10)+Chr(13);

                 mROBO.free;
                 mPrintList.free;
               end;

               if mIIBO.GetFieldValueAsString('Paymenttype_id.code') in ['D1','D2','D3']  then begin
                 mRO_ID:=GetRO_ID(OS,mPDMBO.GetFieldValueAsString('X_LP_OrderNumber'));
                 mROBO:=OS.CreateObject(Class_ReceivedOrder);
                 mROBO.Load(mRO_ID,nil);
                 mPrintList.Add(mROBO.OID);
                     if mIIBO.GetFieldValueAsString('Currency_ID.Code')='CZK' then mMena:='Kč' else mMena:=mIIBO.GetFieldValueAsString('Currency_ID.Code');
                     mMailText:=NxSearchReplace(mMailText,'#CISLOFAKTURY#',mIIBO.DisplayName,[srAll]);
                     mMailText:=NxSearchReplace(mMailText,'#CISOBJ#',mPDMBO.GetFieldValueAsString('X_LP_OrderNumber'),[srAll]);
                     mMailText:=NxSearchReplace(mMailText,'#URL#',mPDMBO.GetFieldValueAsString('X_LP_Tracking_URL'),[srAll]);
                     mMailText:=NxSearchReplace(mMailText,'#TrackingNumber#',mPDMBO.GetFieldValueAsString('X_LP_BarCode'),[srAll]);
                     mMailText:=NxSearchReplace(mMailText,'#CASTKA_MENA#',NxFormatNumeric('0.00,',mIIBO.GetFieldValueAsFloat('Amount'))+' '+mMena,[srAll]);
                 mFirmMail:=mPDMBO.GetFieldValueAsString('TargetAddress_ID.Email');
                 //mMailText:=NxSearchReplace(mMailText,'#TEMP#','email by byl odeslán na adresu :'+mFirmMail,[srall]);
                 //mSubject:=NxSearchReplace(mTextBO.GetFieldValueAsString('X_Subject'),'#CISLO#',mPDMBO.GetFieldValueAsString('X_LP_OrderNumber'),[srAll]);
                 mSubject:='Objednávka '+mPDMBO.GetFieldValueAsString('X_LP_OrderNumber')+' odeslána';
                 if not(NxIsValidEMail(mFirmMail,false)) then mFirmMail:='eshop@naradi-simon.cz';
                 fname:=NxSearchReplace(mROBO.DisplayName,'/','-',[srall])+'.pdf';
                 CFxReportManager.PrintByIDs(NxCreateContext_1(mIIBO),mPrintList,GetDynSource(os,'4VD0000101'),'4VD0000101',rtoFile,pekPDF,NxGetTempDir,fName);
                 mROBO.SetFieldValueAsString('U_OrderState_ID','8C92000101');
                 mROBO.save;
                 SendInternalMail(OS, {'jana.novotna@naradi-simon.cz'} mFirmMail,'','',
                                     mSubject{+' email by byl odeslán na '+mFirmMail},mMailText,
                                     NxGetTempdir+'\'+fName,'',mPDMBO.GetFieldValueAsString('Firm_ID'),mPDMBO.GetFieldValueAsString('Division_ID'),mPDMBO.GetFieldValueAsString('BusOrder_ID'),'1300000101',mROBO.OID);
                 DeleteFile(NxGetTempdir+'\'+fName);
                 //LogInfoStr:=LogInfoStr+'Doklad '+Miibo.DisplayName+' '+ mIIBO.GetFieldValueAsString('Firm_ID.name')+' email pro upomínky '+mFirmMail+Chr(10)+Chr(13);
                 mROBO.free;
                 mPrintList.free;
               end;
               mIIBO.Free;


               mPDMBO.SetFieldValueAsBoolean('X_MailSent',True);
               mPDMBO.save;
               mPDMBO.free;
           end;
           mInvList.free;


      end;
     LogInfoStr:='Zpracoval jsem '+IntToStr(mIDList.count)+' záznamů odeslané pošty';
     mIDList.free;
end;


procedure GenMailLPInvoice (OS: TNxCustomObjectSpace;
  var Success: Boolean; var LogInfoStr: String);

var
 mMailList, mPrintList, mInvList:TStringList;
 mFirmMail,mDivisionMail, mDateString, mReplyTo, mReminderEmail:String;
 mSQL:String;
 mIIBO,mPDMBO, mTextBO, mROBO:TNxCustomBusinessObject;
 mIIRow:TNxCustomBusinessMonikerCollection;
 mBusOrder_id, mDivision_ID, mRO_ID:String;
 i,j,k :Integer;
 fName, mText_ID:String;
 mIDList, mTextList:TStringList;
 mMailText, mMena, mForm_ID, mSubject:string;
begin
      mTextBO:=OS.CreateObject('PKVPDHXNS3L4DE0DC0XUE1FP2K');
      mTextBO.Load('8C92000101',nil);
      mIDList:=TStringList.Create;
        OS.SQLSelect('SELECT A.ID FROM PDMIssuedDocs A '+
                            'left join PDMPostProviders B on b.id=a.PostProvider_ID '+
                            'WHERE a.X_MailSent='+Quotedstr('N')+' and A.X_LP_State_ID = '
                            +QuotedStr('A0S5000101')+' and a.X_LP_IsInClosingDay=''A'' and a.X_LP_SourceCLSID='
                            +QuotedStr('O3BDOKTWEFD13ACM03KIU0CLP4'),mIDList);
        for i:=0 to mIDList.count-1 do begin
           mPrintList:=TStringList.Create;
           mDivision_ID:='';
           mDivisionMail:='';
           mBusOrder_id:='';
           mReminderEmail:='Prázdný';
           mPDMBO:= OS.CreateObject(Class_PDMIssuedDoc);
           mMailText:=mTextBO.GetFieldValueAsString('X_note');
           mPDMBO.Load(mIDList.Strings[i],nil);
           //mForm_ID:='4N70000101';
           //mInvList:=TStringList.create;
           //os.SQLSelect(format('select first 1 ii2.parent_id from issuedinvoices2 ii2 left join storedocuments2 sd2 on sd2.id=ii2.providerow_id where sd2.provide_id=''%s'' ',[mPDMBO.GetFieldValueAsString('X_LP_Source_ID')]),mInvList);
           //if mInvList.count=0 then os.SQLSelect(format('select id from issuedinvoices where id=''%s'' ',[mPDMBO.GetFieldValueAsString('X_LP_Source_ID')]),mInvList);
           if true then begin
               mIIBO:=os.CreateObject(Class_IssuedInvoice);
               mIIBO.Load(mPDMBO.GetFieldValueAsString('X_LP_Source_ID'),nil);

               if true  then begin
                 mRO_ID:=GetRO_ID(OS,mPDMBO.GetFieldValueAsString('X_LP_OrderNumber'));
                if not(NxIsEmptyOID(mRO_ID)) then begin
                 mROBO:=OS.CreateObject(Class_ReceivedOrder);
                 mROBO.Load(mRO_ID,nil);
                 mPrintList.Add(mIIBO.OID);
                     if mIIBO.GetFieldValueAsString('Currency_ID.Code')='CZK' then mMena:='Kč' else mMena:=mIIBO.GetFieldValueAsString('Currency_ID.Code');
                     mMailText:=NxSearchReplace(mMailText,'#CISLOFAKTURY#',mIIBO.DisplayName,[srAll]);
                     mMailText:=NxSearchReplace(mMailText,'#CISOBJ#',mPDMBO.GetFieldValueAsString('X_LP_OrderNumber'),[srAll]);
                     mMailText:=NxSearchReplace(mMailText,'#URL#',mPDMBO.GetFieldValueAsString('X_LP_Tracking_URL'),[srAll]);
                     mMailText:=NxSearchReplace(mMailText,'#TrackingNumber#',mPDMBO.GetFieldValueAsString('X_LP_BarCode'),[srAll]);
                     mMailText:=NxSearchReplace(mMailText,'#CASTKA_MENA#',NxFormatNumeric('0.00,',mIIBO.GetFieldValueAsFloat('Amount'))+' '+mMena,[srAll]);
                 mFirmMail:=mPDMBO.GetFieldValueAsString('TargetAddress_ID.Email');
                 //mMailText:=NxSearchReplace(mMailText,'#TEMP#','email by byl odeslán na adresu :'+mFirmMail,[srall]);
                 //mSubject:=NxSearchReplace(mTextBO.GetFieldValueAsString('X_Subject'),'#CISLO#',mPDMBO.GetFieldValueAsString('X_LP_OrderNumber'),[srAll]);
                 mSubject:='Faktura '+mPDMBO.GetFieldValueAsString('X_LP_OrderNumber')+' odeslána - faktura v příloze';
                 if not(NxIsValidEMail(mFirmMail,false)) then mFirmMail:='eshop@naradi-simon.cz';
                 fname:=NxSearchReplace(mIIBO.DisplayName,'/','-',[srall])+'.pdf';
                 CFxReportManager.PrintByIDs(NxCreateContext_1(mIIBO),mPrintList,GetDynSource(os,'4N70000101'),'4N70000101',rtoFile,pekPDF,NxGetTempDir,fName);
                 mRO_ID:=GetRO_ID(OS,mPDMBO.GetFieldValueAsString('X_LP_OrderNumber'));
                 mROBO.SetFieldValueAsString('U_OrderState_ID','8C92000101');
                 mROBO.save;
                 SendInternalMail(OS, {'jana.novotna@naradi-simon.cz'} mFirmMail,'','',
                                     mSubject{+' email by byl odeslán na '+mFirmMail},mMailText,
                                     NxGetTempdir+'\'+fName,'',mPDMBO.GetFieldValueAsString('Firm_ID'),mPDMBO.GetFieldValueAsString('Division_ID'),mPDMBO.GetFieldValueAsString('BusOrder_ID'),'1300000101', mRO_ID);
                 DeleteFile(NxGetTempdir+'\'+fName);
                 //LogInfoStr:=LogInfoStr+'Doklad '+Miibo.DisplayName+' '+ mIIBO.GetFieldValueAsString('Firm_ID.name')+' email pro upomínky '+mFirmMail+Chr(10)+Chr(13);

                 mROBO.free;
                 mPrintList.free;
                end;
               end;

              mIIBO.Free;


               mPDMBO.SetFieldValueAsBoolean('X_MailSent',True);
               mPDMBO.save;
               mPDMBO.free;
           end;
           mInvList.free;


      end;
     LogInfoStr:='Zpracoval jsem '+IntToStr(mIDList.count)+' záznamů odeslané pošty';
     mIDList.free;
end;


begin
end.