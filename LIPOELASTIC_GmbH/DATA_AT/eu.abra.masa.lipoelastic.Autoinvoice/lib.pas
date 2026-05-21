uses '.const', '.fce';

procedure GenerateInvoice(OS: TNxCustomObjectSpace;  var Success: Boolean; var LogInfoStr: String);
var
 mLogs, mFirmList, mBODList, mQBODList, mIIPrintList:TStringList;
 i,j,k,l:integer;
 mFriday, m15, mLastDay:Boolean;
 mMessage, mFileName, mTO, mIIForm_ID, mSubject, mBody, mMailNumber, mFirmOffice_ID:string;
 mImportManager: TNxDocumentImportManager;
 mInputParams: TNxParameters;
 mParam: TNxParameter;
 mReceivedOrder_ID, mTypeString:string;
 mFirmBO, mMailTextBO:TNxCustomBusinessObject;
begin
  {  1 on 15th and last day
     2 every Friday
     3 last day of month}
  mFriday:=False;
  m15:=False;
  mLastDay:=False;
  if DayOfWeek(Date)=6 then mFriday:=True;
  if DayOfTheMonth(Date)=15 then m15:=True;
  if DayOfTheMonth(Date+1)=1 then mLastDay:=True;
  mLogs:=TStringList.create;
  mLogs.Add('__________________________________________________________');
  mLogs.Add(DateTimeToStr(Now)+' - start of autoinvoice');
  mLogs.Add('‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾');
  mLogs.Add(DateTimeToStr(Now)+' Day of week '+IntToStr(DayOfWeek(Date))+' Day of Month '+IntToStr(DayOfTheMonth(Date)));
  mFirmList:=TStringList.create;
  OS.SQLSelect('Select id from firms where hidden=''N'' and firm_id is null and X_InvoicingType>0', mFirmList);
  if mFirmList.count>0 then begin
    mLogs.Add(DateTimeToStr(Now)+' - Count of firms for autoinvoice: '+IntToStr(mFirmList.count));
    for i:=0 to mFirmList.count-1 do begin
      mFirmBO:=OS.CreateObject(Class_Firm);
      mFirmBO.Load(mFirmList.Strings[i],nil);
        case mFirmBO.GetFieldValueAsInteger('X_InvoicingType') of
          1: mTypeString:='on 15th and last day';
          2: mTypeString:='every Friday';
          3: mTypeString:='last day of month';
        end;
      mLogs.add(DateTimeToStr(Now)+' - Firm: '+mFirmBO.GetFieldValueAsString('Name')+'   invoicing type: '+IntToStr(mFirmBO.GetFieldValueAsInteger('X_InvoicingType'))+' '+mTypeString);

      mBODList:=TStringList.Create;
      OS.SQLSelect('SELECT a.ID FROM StoreDocuments A JOIN Firms F ON F.ID=A.Firm_ID WHERE A.DocumentType=''21'' '+
                   'AND ((A.DocDate$DATE >= 45931) AND (F.ID='+QuotedStr(mFirmBO.OID)+' OR ((F.Firm_ID IS NOT NULL) AND (F.Firm_ID='+QuotedStr(mFirmBO.OID)+'))) '+
                   'AND (((''A'' = ''A'') AND ((A.Finished = ''N'') AND (A.IsAvailableForDelivery = ''A''))) OR ((''A'' = ''N'') AND ((A.Finished = ''A'') OR (A.IsAvailAbleForDelivery = ''N''))))) ',mBODList);
      mLogs.add(DateTimeToStr(Now)+' - Count of delivery notes for firm: '+IntToStr(mBODList.Count));
      if mShouldRun(mFirmBO.GetFieldValueAsInteger('X_InvoicingType'), mFriday, m15, mlastDay) and (mBODList.Count>0) then begin
        mLogs.Add('__________________________________________________________');
        mLogs.add(DateTimeToStr(Now)+' - match the conditions');
        mLogs.Add('‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾');
        mQBODList:=TStringList.Create;
        for l:=0 to mBODList.count-1 do begin
          mQBODList.Add(QuotedStr(mBODList.Strings[l]));
        end;
        mReceivedOrder_ID:=OS.SQLSelectFirstAsString('Select RO.ID from storedocuments2 sd2 left join receivedorders ro on ro.id=sd2.provide_id where sd2.parent_id in ('
                                                     +mQBODList.DelimitedText+') order by ro.docdate$date desc','');
          mLogs.add(DateTimeToStr(Now)+' - Order_ID '+mReceivedOrder_ID);
          try
            mIIPrintList:=TStringList.Create;
            mInputParams := TNxParameters.Create;
            mParam := mInputParams.GetOrCreateParam(dtString, 'DocQueue_ID');
            mParam.AsString := cIIDocQueue_ID;
            if not(NxIsEmptyOID(mReceivedOrder_ID)) then begin
               mFirmOffice_ID:=OS.SQLSelectFirstAsString('Select FirmOffice_ID from receivedorders where id='+QuotedStr(mReceivedOrder_ID),'');
               mParam := mInputParams.GetOrCreateParam(dtString, 'SelectedHeader');
               mParam.AsString := mReceivedOrder_ID;
              end else begin
               mFirmOffice_ID:=OS.SQLSelectFirstAsString('Select FirmOffice_ID from StoreDocuments where id='+QuotedStr(mBODList.Strings[0]),'');
               mParam := mInputParams.GetOrCreateParam(dtString, 'SelectedHeader');
               mParam.AsString := mBODList.Strings[0];
              end;
            mImportManager := NxCreateDocumentImportManager(OS, Class_BillOfDelivery, Class_IssuedInvoice);
            mImportManager.AddInputDocuments(mBODList);
            mImportManager.LoadParams(mInputParams);
            mImportManager.Execute;
            mImportManager.CheckOutputDocument;
            mImportManager.OutputDocument.SetFieldValueAsString('DocQueue_ID', cIIDocQueue_ID);
            if not(NxIsEmptyOID(mFirmOffice_ID)) then
             mImportManager.OutputDocument.SetFieldValueAsString('FirmOffice_ID', mFirmOffice_ID);
            mImportManager.OutputDocument.Save;
            mLogs.add(DateTimeToStr(Now)+' - Invoice Number '+mImportManager.OutputDocument.DisplayName);
            mIIPrintList.add(mImportManager.OutputDocument.OID);
            if mIIPrintList.Count>0 then begin
              mFileName:=NxSearchReplace(mImportManager.OutputDocument.DisplayName,'/','-',[srall])+'.pdf';

              mTO:=mImportManager.OutputDocument.GetFieldValueAsString('Firm_ID.ElectronicAddress_ID.Email');
              if not(NxIsValidEMail(mTO,false)) then mTO:=mImportManager.OutputDocument.GetFieldValueAsString('Firm_ID.ResidenceAddress_ID.Email');
              if not(NxIsValidEMail(mTO,false)) then mTO:='odavidek@lipoelastic.com';
              mMailTextBO:=os.CreateObject(Class_BO_EmailTemplates);
              mMailTextBO.Load('~000001R6D',nil);
              if not(NxIsEmptyOID(mMailTextBO.GetFieldValueAsString('X_Form_ID'))) then mIIForm_ID:=mMailTextBO.GetFieldValueAsString('X_Form_ID')
                 else mIIForm_ID:=cIIForm_ID;
              mSubject:=mMailTextBO.GetFieldValueAsString('X_Subject');
              mSubject:=NxSearchReplace(mSubject,'#InvoiceNumber#',mImportManager.OutputDocument.DisplayName,[srAll]);
              mBody:=mMailTextBO.GetFieldValueAsString('X_Note');
              mBody:=NxSearchReplace(mBody,'#InvoiceNumber#',mImportManager.OutputDocument.DisplayName,[srAll]);
              mBody:=NxSearchReplace(mBody,'#Name#',mImportManager.OutputDocument.GetFieldValueAsString('FirmOffice_ID.Address_ID.Recipient'),[srAll]);
              //mBody:=NxSearchReplace(mBody,'#YourRef#',mOrderBO.GetFieldValueAsString('ExternalNumber'),[srAll]);
              //mBody:=NxSearchReplace(mBody,'#TrackingNumber#',mPDMBO.GetFieldValueAsString('X_TrackingNumber'),[srAll]);
              //mBody:=NxSearchReplace(mBody,'#URL#',mPDMBO.GetFieldValueAsString('X_TrackingURL'),[srAll]);
              //mBody:=NxSearchReplace(mBody,'#TransportName#',mImportManager.OutputDocument.GetFieldValueAsString('TransportationType_ID.X_NameForEmail'),[srAll]);
              CFxReportManager.PrintByIDs(NxCreateContext(OS),mIIPrintList,GetDynSource(os,mIIForm_ID),mIIForm_ID,rtoFile,pekPDF,NxGetTempDir,mFileName);
              mMailNumber:=SendInternalMail(OS,cEmailAccount_ID,mTO,'','',
                              mSubject,mBody,NxGetTempdir+'\'+mFileName,
                              mImportManager.OutputDocument.GetFieldValueAsString('Firm_ID'),'1000000101','','',mImportManager.OutputDocument.OID,1);
              mLogs.Add(DateTimeToStr(Now)+' - email to: '+mTO+'  Email number: '+mMailNumber);
            end;
            mImportManager.free;
          except
            mLogs.add(DateTimeToStr(Now)+' - except: '+ExceptionMessage);
          end;
      end else begin
        mLogs.add(DateTimeToStr(Now)+' - does not match the conditions');
      end;
      mBODList.free;
      mFirmBO.free;
    end;
  end;
  mLogs.Add('__________________________________________________________');
  mLogs.Add(DateTimeToStr(Now)+' - end of autoinvoice');
  mLogs.Add('‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾');
  Success := True;
  LogInfoStr := ''+#13#10+mLogs.Text;
end;


procedure GenerateInvoiceFromPDMDocOnlyB2C(OS: TNxCustomObjectSpace;  var Success: Boolean; var LogInfoStr: String);
var
 mPDMList, mLogs, mRORowList, mIIPrintList, mBODList, mTempPDMList:TStringList;
 i,j:integer;
 mRowQuantity:Extended;
 mRODocQueueCode, mReceivedOrder_ID,mBillOfDelivery_ID, mExternalNumber:string;
 mOrderBO, mPDMBO, mTempPDMBO, mMailTextBO:TNxCustomBusinessObject;
 mImportManager: TNxDocumentImportManager;
 mInputParams: TNxParameters;
 mParam: TNxParameter;
 mInvoiceSent:Boolean;
 mFileName, mSubject, mBody, mTO, mMailNumber,mIIForm_ID:string;
 mRows:TNxCustomBusinessMonikerCollection;
begin
 mPDMList:=TStringList.Create;
 mLogs:=TStringList.Create;
 mLogs.Add('__________________________________________________________');
 mLogs.Add(DateTimeToStr(Now)+' - start of autoinvoice from PDM');
 mLogs.Add('‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾');
 OS.SQLSelect('Select id from pdmissueddocs where X_GenerateInvoice=''A'' and X_InvoiceSent=''N'' ', mPDMList);
 mLogs.Add(DateTimeToStr(Now)+' - Count of PMDDocs for autoinvoice: '+IntToStr(mPDMList.count));
 if mPDMList.count>0 then begin
   for i:=0 to mPDMList.count-1 do begin
     mPDMBO:=OS.CreateObject(Class_PDMIssuedDoc);
     mPDMBO.load(mPDMList.strings[i],nil);
     if not(mPDMBO.GetFieldValueAsBoolean('X_InvoiceSent')) then begin
      mBillOfDelivery_ID:=OS.SQLSelectFirstAsString('Select rightside_id from relations where rel_def=1438 and leftside_id='+QuotedStr(mPDMBO.OID),'');
      mReceivedOrder_ID:=OS.SQLSelectFirstAsString('Select ro.id from receivedorders ro left join storedocuments2 sd2 on sd2.provide_id=ro.id where sd2.Parent_ID='+QuotedStr(mBillOfDelivery_ID) ,'');
      if not(NxIsEmptyOID(mReceivedOrder_ID)) then begin
        mBODList:=TStringList.create;
        mbodlist.Clear;
        OS.SQLSelect('select distinct(sd2.parent_id) from storedocuments2 sd2 '+
                     'join relations r on r.rightside_id=sd2.parent_id '+
                     'join pdmissueddocs pdm on pdm.id=r.leftside_id '+
                     ' where sd2.provide_id='+QuotedStr(mReceivedOrder_ID)+' and r.rel_def=1438 and pdm.X_generateinvoice='+QuotedStr('A')+' and pdm.X_InvoiceSent='+QuotedStr('N'),mBODList);
        mOrderBO:=OS.CreateObject(Class_ReceivedOrder);
        mORderBO.Load(mReceivedOrder_ID,nil);
         mLogs.Add(DateTimeToStr(Now)+' - SendCloud: '+mPDMBO.DisplayName);
         mLogs.Add(DateTimeToStr(Now)+' - Order: '+mOrderBO.DisplayName);
         mLogs.Add(DateTimeToStr(Now)+' - OrderQueue: '+mOrderBO.GetFieldValueAsString('DocQueue_ID.Code')+
                                      '   Invoicing type: '+IntToStr(mOrderBO.GetFieldValueAsInteger('Firm_ID.X_InvoicingType'))+
                                      '   Firm: '+mOrderBO.GetFieldValueAsString('Firm_ID.Name'));
         if (mOrderBO.GetFieldValueAsString('DocQueue_ID.Code')=cRODocQueueCode) or (mOrderBO.GetFieldValueAsInteger('Firm_ID.X_InvoicingType')=0) then begin

                    mInvoiceSent:=false;
                    {mRORowList:=TStringList.Create;
                    mRORowList.Clear;
                    OS.SQLSelect('Select ro2.id from receivedorders2 ro2 where ro2.parent_id='+QuotedStr(mOrderBO.OID)+' and exists(select sd2.id from storedocuments2 sd2 where sd2.providerow_id=ro2.id)',mRORowList);
                    if mRORowList.count>0 then begin }
                    if true then begin
                          mInputParams := TNxParameters.Create;
                          mParam := mInputParams.GetOrCreateParam(dtString, 'DocQueue_ID');
                          mParam.AsString := cIIDocQueue_ID;
                          if not(NxIsEmptyOID(mReceivedOrder_ID)) then begin
                             mParam := mInputParams.GetOrCreateParam(dtString, 'SelectedHeader');
                             mParam.AsString := mReceivedOrder_ID;
                            end else begin
                             mParam := mInputParams.GetOrCreateParam(dtString, 'SelectedHeader');
                             mParam.AsString := mBillOfDelivery_ID;
                            end;
                          mImportManager := NxCreateDocumentImportManager(OS, Class_BillOfDelivery, Class_IssuedInvoice);
                          try
                            mIIPrintList:=TStringList.Create;
                            mImportManager.AddInputDocuments(mBODList);
                            mImportManager.LoadParams(mInputParams);
                            mImportManager.Execute;
                            mImportManager.CheckOutputDocument;
                            mImportManager.OutputDocument.SetFieldValueAsString('DocQueue_ID', cIIDocQueue_ID);
                            mRows:=mImportManager.OutputDocument.GetLoadedCollectionMonikerForFieldCode(mImportManager.OutputDocument.GetFieldCode('Rows'));
                            if mRows.CountOfNotDeleted>0 then begin
                                mImportManager.OutputDocument.save;
                                UsageAllDeposit(mImportManager.OutputDocument);
                                mIIPrintList.Add(mImportManager.OutputDocument.OID);
                                mLogs.Add(DateTimeToStr(Now)+' - Invoice: '+mImportManager.OutputDocument.DisplayName);
                                if mIIPrintList.Count>0 then begin
                                  mFileName:=NxSearchReplace(mImportManager.OutputDocument.DisplayName,'/','-',[srall])+'.pdf';

                                  mTO:=mImportManager.OutputDocument.GetFieldValueAsString('Firm_ID.ElectronicAddress_ID.Email');
                                  if not(NxIsValidEMail(mTO,false)) then mTO:=mImportManager.OutputDocument.GetFieldValueAsString('Firm_ID.ResidenceAddress_ID.Email');
                                  if not(NxIsValidEMail(mTO,false)) then mTO:='odavidek@lipoelastic.com';
                                  mMailTextBO:=os.CreateObject(Class_BO_EmailTemplates);
                                  mMailTextBO.Load('~000000TR0',nil);
                                  if not(NxIsEmptyOID(mMailTextBO.GetFieldValueAsString('X_Form_ID'))) then mIIForm_ID:=mMailTextBO.GetFieldValueAsString('X_Form_ID')
                                     else mIIForm_ID:=cIIForm_ID;
                                  mSubject:=mMailTextBO.GetFieldValueAsString('X_Subject');
                                  mSubject:=NxSearchReplace(mSubject,'#InvoiceNumber#',mImportManager.OutputDocument.DisplayName,[srAll]);
                                  mBody:=mMailTextBO.GetFieldValueAsString('X_Note');
                                  mBody:=NxSearchReplace(mBody,'#InvoiceNumber#',mImportManager.OutputDocument.DisplayName,[srAll]);
                                  mBody:=NxSearchReplace(mBody,'#Name#',mImportManager.OutputDocument.GetFieldValueAsString('FirmOffice_ID.Address_ID.Recipient'),[srAll]);
                                  mBody:=NxSearchReplace(mBody,'#YourRef#',mOrderBO.GetFieldValueAsString('ExternalNumber'),[srAll]);
                                  mBody:=NxSearchReplace(mBody,'#TrackingNumber#',mPDMBO.GetFieldValueAsString('X_TrackingNumber'),[srAll]);
                                  mBody:=NxSearchReplace(mBody,'#URL#',mPDMBO.GetFieldValueAsString('X_TrackingURL'),[srAll]);
                                  mBody:=NxSearchReplace(mBody,'#TransportName#',mImportManager.OutputDocument.GetFieldValueAsString('TransportationType_ID.X_NameForEmail'),[srAll]);
                                  CFxReportManager.PrintByIDs(NxCreateContext(OS),mIIPrintList,GetDynSource(os,mIIForm_ID),mIIForm_ID,rtoFile,pekPDF,NxGetTempDir,mFileName);
                                  mMailNumber:=SendInternalMail(OS,cEmailAccount_ID,mTO,'','',
                                                  mSubject,mBody,NxGetTempdir+'\'+mFileName,
                                                  mOrderBO.GetFieldValueAsString('Firm_ID'),'1000000101','','',mImportManager.OutputDocument.OID,1);
                                  mLogs.Add(DateTimeToStr(Now)+' - email to: '+mTO+'  Email number: '+mMailNumber);
                                  mInvoiceSent:=true;
                                end;
                            end;
                            mImportManager.free;
                            mIIPrintList.free;
                          except
                           if NxSearch(ExceptionMessage,'Žádný z vybraných dokladů neobsahuje čerpatelné řádky',[srAll],0) then begin
                            mLogs.Add(DateTimeToStr(Now)+' - našel jsem text');
                            mInvoiceSent:=true; // nastaveno na True proto aby vypadl PDM doklad z fronty
                           end;
                           mLogs.Add(DateTimeToStr(Now)+' - '+ExceptionMessage);
                          end;


                   end;
         end;
        mOrderBO.free;
      end;
      if mInvoiceSent then begin
       mPDMBO.SetFieldValueAsBoolean('X_InvoiceSent',true);
       mPDMBO.save;
       if mBODList.count>1 then begin
         mTempPDMList:=TStringList.create;
         OS.SQLSelect('select distinct(pdm.ID) from storedocuments2 sd2 '+
                     'join relations r on r.rightside_id=sd2.parent_id '+
                     'join pdmissueddocs pdm on pdm.id=r.leftside_id '+
                     ' where sd2.provide_id='+QuotedStr(mReceivedOrder_ID)+' and r.rel_def=1438 and pdm.X_generateinvoice='+QuotedStr('A')+' and pdm.X_InvoiceSent='+QuotedStr('N'),mTempPDMList);
         mLogs.Add(DateTimeToStr(Now)+' - Procesing other PDM docs, count '+IntToStr(mTempPDMList.count));
         for j:=0 to mTempPDMList.Count-1 do begin
            mTempPDMBO:=OS.CreateObject(Class_PDMIssuedDoc);
            mTempPDMBO.load(mTempPDMList.Strings[j],nil);
            mTempPDMBO.SetFieldValueAsBoolean('X_InvoiceSent',true);
            mTempPDMBO.save;
            mTempPDMBO.free;
          end;
         mTempPDMList.free;
       end;
      end;
     end;
     mPDMBO.free;
   end;
 end;
 mLogs.Add('__________________________________________________________');
 mLogs.Add(DateTimeToStr(Now)+' - end of autoinvoice from PDM');
 mLogs.Add('‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾');
 Success := True;
 LogInfoStr := ''+#13#10+mLogs.Text;
end;

procedure GenerateDailyInvoice(OS: TNxCustomObjectSpace;  var Success: Boolean; var LogInfoStr: String);
var
 mLogs, mFirmList, mBODList, mQBODList, mIIPrintList, mTempBODList:TStringList;
 i,j,k,l:integer;
 mFriday, m15, mLastDay:Boolean;
 mMessage, mFileName, mTO, mIIForm_ID, mSubject, mBody, mMailNumber, mFirm_ID:string;
 mImportManager: TNxDocumentImportManager;
 mInputParams: TNxParameters;
 mParam: TNxParameter;
 mReceivedOrder_ID, mTypeString, mPDM_ID, mTemplate_ID, mExternalNumber, mTrackNumber, mTrackURL, mBankAccount_ID:string;
 mFirmBO, mMailTextBO, mPDMBO, mTempPDMBO,mOrderBO:TNxCustomBusinessObject;
 mRows:TNxCustomBusinessMonikerCollection;
 mInvoiceSent:Boolean;
begin
 mLogs:=TStringList.Create;
 mLogs.Add('__________________________________________________________');
 mLogs.Add(DateTimeToStr(Now)+' - start of daily autoinvoice');
 mLogs.Add('‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾');
 //první dohledat firmu, pak všechny DL, hromadně fakturovat
         mBODList:=TStringList.Create;
         OS.SQLSelect('SELECT A.ID FROM StoreDocuments A join firms f on f.id=a.firm_id WHERE A.DocumentType=''21'' '+
                      'AND A.DOCQUEUE_ID IN (''9000000101'',''~000000504'') '+
                      'AND (A.DocDate$DATE >= 45931) '+
                      'AND (((''A'' = ''A'') AND ((A.Finished = ''N'') AND (A.IsAvailableForDelivery = ''A''))) OR ((''A'' = ''N'') '+
                      'AND ((A.Finished = ''A'') OR (A.IsAvailAbleForDelivery = ''N'')))) AND not(f.X_invoicingType>0) ',mBODList);
         mLogs.Add('Count of BOD: '+IntToStr(mBODList.Count));
         if mBODList.count>0 then begin
          for i:=0 to mBODList.Count-1 do begin
            mQBODList:=TStringList.Create;
            mQBODList.Add(mBODList.strings[i]);
            mInvoiceSent:=False;
            mExternalNumber:='';
            mTrackURL:='';
            mTrackNumber:='';
            mFirm_ID:='';
            mReceivedOrder_ID:=OS.SQLSelectFirstAsString('Select RO.ID from storedocuments2 sd2 left join receivedorders ro on ro.id=sd2.provide_id where sd2.parent_id='
                                                       +QuotedStr(mBODList.Strings[i])+' order by ro.docdate$date desc','');
            mLogs.add(DateTimeToStr(Now)+' - Order_ID '+mReceivedOrder_ID);
            mPDM_ID:=OS.SQLSelectFirstAsString('SELECT R.LeftSide_ID FROM Relations R WHERE R.REL_DEF = 1438 AND R.RightSide_ID = '+QuotedStr(mBODList.Strings[i]));
            mLogs.add(DateTimeToStr(Now)+' - PDM_ID '+mPDM_ID);
            mBankAccount_ID:='2000000101';
            if not(NxIsEmptyOID(mReceivedOrder_ID)) then begin
              mOrderBO:=OS.CreateObject(Class_ReceivedOrder);
              mORderBO.Load(mReceivedOrder_ID,nil);
              if NxIsEmptyOID(mFirm_ID) then mFirm_ID:=mOrderBO.GetFieldValueAsString('Firm_ID');
              mExternalNumber:=mOrderBO.GetFieldValueAsString('ExternalNumber');
              if mOrderBO.GetFieldValueAsString('DocQueue_ID.Code')='ASOC' then mBankAccount_ID:='~000000101';
              mOrderBO.free;
            end;
            if not(NxIsEmptyOID(mPDM_ID)) then begin
              mPDMBO:=OS.CreateObject(Class_PDMIssuedDoc);
              mPDMBO.Load(mPDM_ID,nil);
              if NxIsEmptyOID(mFirm_ID) then mFirm_ID:=mPDMBO.GetFieldValueAsString('Firm_ID');
              mTrackURL:=mPDMBO.GetFieldValueAsString('X_TrackingURL');
              mTrackNumber:=mPDMBO.GetFieldValueAsString('X_TrackingNumber');
              mPDMBO.free;
            end;
            mLogs.add(DateTimeToStr(Now)+' - PDM tracking URL '+mTrackURL);
            if not(NxIsBlank(mTrackURL)) then mTemplate_ID:='~000000TR0' else mTemplate_ID:='~000001R6D';
             //check na další DL z toho samého dne na firmu z DL
              mTempBODList:=TStringList.Create;
              mTempBODList.clear;
              OS.SQLSelect('SELECT A.ID FROM StoreDocuments A join firms f on f.id=a.firm_id WHERE A.DocumentType=''21'' '+
                      'AND A.DOCQUEUE_ID IN (''9000000101'',''~000000504'') '+
                      'AND (A.DocDate$DATE >= 45931) '+
                      'AND (((''A'' = ''A'') AND ((A.Finished = ''N'') AND (A.IsAvailableForDelivery = ''A''))) OR ((''A'' = ''N'') '+
                      'AND ((A.Finished = ''A'') OR (A.IsAvailAbleForDelivery = ''N'')))) AND f.id='+QuotedStr(mFirm_ID) ,mTempBODList);
             //konec check
              // začátek tvorby faktury
                                  mInputParams := TNxParameters.Create;
                                  mParam := mInputParams.GetOrCreateParam(dtString, 'DocQueue_ID');
                                  mParam.AsString := cIIDocQueue_ID;
                                  if not(NxIsEmptyOID(mReceivedOrder_ID)) then begin
                                     mParam := mInputParams.GetOrCreateParam(dtString, 'SelectedHeader');
                                     mParam.AsString := mReceivedOrder_ID;
                                    end else begin
                                     mParam := mInputParams.GetOrCreateParam(dtString, 'SelectedHeader');
                                     mParam.AsString := mBODList.Strings[i];
                                    end;
                                  mImportManager := NxCreateDocumentImportManager(OS, Class_BillOfDelivery, Class_IssuedInvoice);
                                  try
                                    mIIPrintList:=TStringList.Create;
                                    mLogs.add(DateTimeToStr(Now)+' - Count of BOD '+IntToStr(mTempBODList.count));
                                    if mTempBODList.count>0 then mImportManager.AddInputDocuments(mTempBODList) else
                                     mImportManager.AddInputDocuments(mQBODList);
                                    mImportManager.LoadParams(mInputParams);
                                    mImportManager.Execute;
                                    mImportManager.CheckOutputDocument;
                                    mImportManager.OutputDocument.SetFieldValueAsString('DocQueue_ID', cIIDocQueue_ID);
                                    if NxIsEmptyOID(mImportManager.OutputDocument.GetFieldValueAsString('BankAccount_ID')) then
                                     mImportManager.OutputDocument.SetFieldValueAsString('BankAccount_ID',mBankAccount_ID);
                                    mRows:=mImportManager.OutputDocument.GetLoadedCollectionMonikerForFieldCode(mImportManager.OutputDocument.GetFieldCode('Rows'));
                                    if mRows.CountOfNotDeleted>0 then begin
                                        mImportManager.OutputDocument.save;
                                        UsageAllDeposit(mImportManager.OutputDocument);
                                        mIIPrintList.Add(mImportManager.OutputDocument.OID);
                                        mLogs.Add(DateTimeToStr(Now)+' - Invoice: '+mImportManager.OutputDocument.DisplayName);
                                        if mIIPrintList.Count>0 then begin
                                          mFileName:=NxSearchReplace(mImportManager.OutputDocument.DisplayName,'/','-',[srall])+'.pdf';

                                          mTO:=mImportManager.OutputDocument.GetFieldValueAsString('Firm_ID.ElectronicAddress_ID.Email');
                                          if not(NxIsValidEMail(mTO,false)) then mTO:=mImportManager.OutputDocument.GetFieldValueAsString('Firm_ID.ResidenceAddress_ID.Email');
                                          if not(NxIsValidEMail(mTO,false)) then mTO:='odavidek@lipoelastic.com';
                                          mMailTextBO:=os.CreateObject(Class_BO_EmailTemplates);
                                          mMailTextBO.Load(mTemplate_ID,nil);
                                          if not(NxIsEmptyOID(mMailTextBO.GetFieldValueAsString('X_Form_ID'))) then mIIForm_ID:=mMailTextBO.GetFieldValueAsString('X_Form_ID')
                                             else mIIForm_ID:=cIIForm_ID;
                                          mSubject:=mMailTextBO.GetFieldValueAsString('X_Subject');
                                          mSubject:=NxSearchReplace(mSubject,'#InvoiceNumber#',mImportManager.OutputDocument.DisplayName,[srAll]);
                                          mBody:=mMailTextBO.GetFieldValueAsString('X_Note');
                                          mBody:=NxSearchReplace(mBody,'#InvoiceNumber#',mImportManager.OutputDocument.DisplayName,[srAll]);
                                          mBody:=NxSearchReplace(mBody,'#Name#',mImportManager.OutputDocument.GetFieldValueAsString('FirmOffice_ID.Address_ID.Recipient'),[srAll]);
                                          mBody:=NxSearchReplace(mBody,'#YourRef#',mExternalNumber,[srAll]);
                                          mBody:=NxSearchReplace(mBody,'#TrackingNumber#',mTrackNumber,[srAll]);
                                          mBody:=NxSearchReplace(mBody,'#URL#',mTrackURL,[srAll]);
                                          mBody:=NxSearchReplace(mBody,'#TransportName#',mImportManager.OutputDocument.GetFieldValueAsString('TransportationType_ID.X_NameForEmail'),[srAll]);
                                          CFxReportManager.PrintByIDs(NxCreateContext(OS),mIIPrintList,GetDynSource(os,mIIForm_ID),mIIForm_ID,rtoFile,pekPDF,NxGetTempDir,mFileName);
                                          mMailNumber:=SendInternalMail(OS,cEmailAccount_ID,mTO,'','',
                                                          mSubject,mBody,NxGetTempdir+'\'+mFileName,
                                                          mImportManager.OutputDocument.GetFieldValueAsString('Firm_ID'),'1000000101','','',mImportManager.OutputDocument.OID,1);
                                          mLogs.Add(DateTimeToStr(Now)+' - email to: '+mTO+'  Email number: '+mMailNumber);
                                          mInvoiceSent:=true;
                                        end;
                                    end;
                                    mImportManager.free;
                                    mIIPrintList.free;
                                  except
                                   if NxSearch(ExceptionMessage,'Žádný z vybraných dokladů neobsahuje čerpatelné řádky',[srAll],0) then begin
                                    mLogs.Add(DateTimeToStr(Now)+' - našel jsem text');
                                    mInvoiceSent:=true; // nastaveno na True proto aby vypadl PDM doklad z fronty
                                   end;
                                   mLogs.Add(DateTimeToStr(Now)+' - '+ExceptionMessage);
                                  end;
                                  mTempBODList.free;
              // konec tvorby faktury
              if mInvoiceSent and not(NxIsEmptyOID(mPDM_ID)) then begin
                mPDMBO:=OS.CreateObject(Class_PDMIssuedDoc);
                mPDMBO.Load(mPDM_ID,nil);
                mPDMBO.SetFieldValueAsBoolean('X_InvoiceSent',true);
                mPDMBO.save;
                mPDMBO.free;
              end;
          end;
         end;
 mLogs.Add('__________________________________________________________');
 mLogs.Add(DateTimeToStr(Now)+' - end of dialy autoinvoice');
 mLogs.Add('‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾');
 Success := True;
 LogInfoStr := ''+#13#10+mLogs.Text;
end;

begin
end.