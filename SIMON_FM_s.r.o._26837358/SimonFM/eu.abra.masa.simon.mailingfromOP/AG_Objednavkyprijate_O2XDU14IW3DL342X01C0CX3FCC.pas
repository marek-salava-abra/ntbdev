uses '.fce';

procedure _AfterSave_PostHook(Self: TDynSiteForm);
Var
 mOrigValue, mBody, mTO, mAccount_ID:String;
 mOS:TNxCustomObjectSpace;
 mBO, mZLVBO, mResBO,mCurrBO, mDLBO, mVPZBO:TNxCustomBusinessObject;
 mFileList, mList, mDLList:TStringList;
 mFileName, mZLV_ID, mSubject, mFileName2, mReservation_ID, mCountMessage, mVPZ_ID:string;
 mInputParams:TNxParameters;
 mParam:TNxParameter;
 mImportMan:TNxDocumentImportManager;
 mRows:TNxCustomBusinessMonikerCollection;
 i,j, mCount:Integer;
begin
  mCurrBO:=TDynSiteForm(Self).CurrentObject;
   if (mCurrBO.GetFieldValueAsString('DocQueue_ID.Code')='OPES') then begin
  if true then begin
  // if mCurrBO.GetFieldValueAsString('Firm_ID')='27Y2000101' then begin
     mOS:=mCurrBO.ObjectSpace;
     mCurrBO.GetOriginalValue('U_orderstate_ID',mOrigValue);
     if true then begin
     //if not(mOrigValue=mCurrBO.GetFieldValueAsString('U_OrderState_ID')) then begin
       if (mCurrBO.GetFieldValueAsString('U_OrderState_ID.Code') in ['STOBJ06']) then begin
        mCount:=mOS.SQLSelectFirstAsInteger('Select count(sd.id) from storedocuments sd left join storedocuments2 sd2 on sd2.parent_id=sd.id where sd2.provide_id='+QuotedStr(mCurrBO.OID)+
                                            ' and sd.Documenttype='+QuotedStr('21')+' and sd.PMState_ID='+QuotedStr('SDDEF00000'),0);
        if mCount>0 then begin
          NxShowSimpleMessage('Objednávka '+mCurrBO.DisplayName+' má již k sobě dodací listy ve stavu vyřízeno. Nelze stornovat',Self);
          exit;
        end;
        if NxMessageBox('Dotaz','Přejete si stornovat objednávku '+mCurrBO.DisplayName+'?' , mdConfirm, mdbYesNo, 0, 0, False, nil)= mrYes then begin
          mDLList:=TStringList.Create;
          mOS.SQLSelect('Select distinct(sd.id) from storedocuments sd left join storedocuments2 sd2 on sd2.parent_id=sd.id where sd2.provide_id='+QuotedStr(mCurrBO.OID)+
                                            ' and sd.Documenttype='+QuotedStr('21')+' and sd.PMState_ID='+QuotedStr('2000000001'),mDLList);
          if mDLList.count>0 then begin
            for j:=0 to mDLList.count-1 do begin
                  mDLBO:= mOS.CreateObject(Class_BillOfDelivery);
                  mDLBO.Load(mDLList.Strings[j], nil);
                  //najdi VPZ, pokud nperovedeno, smaž
                   mVPZ_ID:=mOS.SQLSelectFirstAsString('Select id from logstoredocuments where storedocument_id='+Quotedstr(mDLBO.oid)+' and executed='+QuotedStr('N'),'');
                   if not(NxIsEmptyOID(mVPZ_ID)) then begin
                     mVPZBO:=mOS.CreateObject(Class_LogStoreOutput);
                     mVPZBO.load(mVPZ_ID,nil);
                     mVPZBO.Delete;
                   end;
                  //konec najdi vpz
                  if not (osSaving in mDLBO.InternalState) then mDLBO.PMChangeState('3000000001');
                  //NxShowSimpleMessage(mDLBO.DisplayName,Self);
                  mDLBO.Delete;
                  mDLBO.free;
            end;
          end;
          if NxIsBlank(mCurrBO.GetFieldValueAsString('Description')) then begin
            //mos.SQLExecute('Update receivedorders set description=''Storno'', PMState_ID=''9010000101'' where id='+QuotedStr(mCurrBO.oid));
            //mCurrBO.PMChangeState('9010000101');
         end;
         mZLV_ID:=GetZLV_ID(mOS,mCurrBO.OID);
          if not(NxIsEmptyOID(mZLV_ID)) then begin
              mZLVBO:=mOS.CreateObject(Class_IssuedDepositInvoice);
              mZLVBO.Load(mZLV_ID,nil);
              if (mZLVBO.GetFieldValueAsFloat('LocalUsedAmount')>0) then NxShowSimpleMessage('Zálohový list '+mZLVBO.DisplayName+' je již zúčtován.',Self);
              mZLVBO.SetFieldValueAsString('Description','STORNO');
              mRows:=mZLVBO.GetLoadedCollectionMonikerForFieldCode(mZLVBO.GetFieldCode('Rows'));
              for i:=0 to mRows.count-1 do begin
                if mRows.BusinessObject[i].GetFieldValueAsInteger('RowType')=4 then
                   mRows.BusinessObject[i].SetFieldValueAsFloat('TAmount',0);
              end;
              mZLVBO.save;
              mzlvbo.free;
              mrows:=mCurrBO.GetLoadedCollectionMonikerForFieldCode(mCurrBO.GetFieldCode('Rows'));
              for i:=0 to mrows.count-1 do begin
                 mReservation_ID:=mOS.SQLSelectFirstAsString('Select id from reservations where ownerkind=0 and owner_id='+QuotedStr(mrows.BusinessObject[i].OID),'');
                 if not(NxIsEmptyOID(mReservation_ID)) then begin
                    mResBO:=mOS.CreateObject(Class_Reservation);
                    mresbo.Load(mReservation_ID,nil);
                    mResBO.SetFieldValueAsFloat('Reserved',0);
                    mresbo.save;
                    mresbo.Free;
                 end;
              end;
          end;
        end;
       end;
      if (mCurrBO.GetFieldValueAsString('U_OrderState_ID.Code') in ['STOBJ02','STOBJ08','STOBJ09']) then begin
        mCountMessage:='';
        mCount:=mOS.SQLSelectFirstAsInteger('Select count(id) from EmailsSent where X_receivedorderID='+QuotedStr(mCurrBO.OID)+' and x_OrderState_ID='+QuotedStr(mCurrBO.GetFieldValueAsString('U_OrderState_ID')),0);
        if mCount>0 then mCountMessage:=#13#10+'(počet již odeslaných zpráv k objednávce se stavem '+mCurrBO.GetFieldValueAsString('U_OrderState_ID.Code')+' je '+IntToStr(mCount)+')';
        if NxMessageBox('Dotaz','Přejete si odeslat email '+mCurrBO.DisplayName+'?'+mCountMessage , mdConfirm, mdbYesNo, 0, 0, False, nil)= mrYes then begin
           mBody:=mCurrBO.GetFieldValueAsString('U_OrderState_ID.X_Note');
           mBody:=NxSearchReplace(mBody,'#CISOBJ#',mCurrBO.GetFieldValueAsString('ExternalNumber'),[srAll]);
           if mCurrBO.GetFieldValueAsString('U_OrderState_ID.Code')in ['STOBJ02','STOBJ08'] then begin
            mList:=TStringList.Create;
            mlist.Add(mCurrBO.OID);
            mFileName2:=NxSearchReplace(mCurrBO.DisplayName,'/','-',[srAll]);
            CFxReportManager.PrintByIDs(NxCreateContext_1(mCurrBO), mList, '40V53DORW3DL342X01C0CX3FCC', '4VD0000101', rtoFile, pekPDF, NxGetTempDir, mFileName2 + '.pdf');
            SendInternalMail(mCurrBO.ObjectSpace,mCurrBO.GetFieldValueAsString('FirmOffice_id.Address_id.Email'),
                           '','',
                           mCurrBO.GetFieldValueAsString('ExternalNumber')+' '+mCurrBO.GetFieldValueAsString('U_OrderState_ID.Name') ,
                           mBody,NxGetTempDir+'\'+ mFileName2 + '.pdf','', mCurrBO.GetFieldValueAsString('Firm_ID'),
                           '1400000101','','1300000101',mCurrBO.OID,mCurrBO.GetFieldValueAsString('U_OrderState_ID'));
             DeleteFile(NxGetTempDir+'\'+ mFileName2 + '.pdf');
           end else begin
            SendInternalMail(mCurrBO.ObjectSpace,mCurrBO.GetFieldValueAsString('FirmOffice_id.Address_id.Email'),
                           '','',
                           mCurrBO.GetFieldValueAsString('ExternalNumber')+' '+mCurrBO.GetFieldValueAsString('U_OrderState_ID.Name') ,
                           mBody,'','', mCurrBO.GetFieldValueAsString('Firm_ID'),
                           '1400000101','','1300000101',mCurrBO.OID,mCurrBO.GetFieldValueAsString('U_OrderState_ID'));
           end;
        end;
      end;
      if (mCurrBO.GetFieldValueAsString('U_OrderState_ID.Code') in ['STOBJ05']) and (mCurrBO.GetFieldValueAsString('TransportationType_ID.Code')='O1') then begin
        mCountMessage:='';
        mCount:=mOS.SQLSelectFirstAsInteger('Select count(id) from EmailsSent where X_receivedorderID='+QuotedStr(mCurrBO.OID)+' and x_OrderState_ID='+QuotedStr(mCurrBO.GetFieldValueAsString('U_OrderState_ID')),0);
        if mCount>0 then mCountMessage:=#13#10+'(počet již odeslaných zpráv k objednávce se stavem '+mCurrBO.GetFieldValueAsString('U_OrderState_ID.Code')+' je '+IntToStr(mCount)+')';
        if NxMessageBox('Dotaz','Přejete si odeslat email '+mCurrBO.DisplayName+' o osobním odběru?'+mCountMessage , mdConfirm, mdbYesNo, 0, 0, False, nil)= mrYes then begin
           mBody:=mCurrBO.GetFieldValueAsString('U_OrderState_ID.X_Note');
           mBody:=NxSearchReplace(mBody,'#CISOBJ#',mCurrBO.GetFieldValueAsString('ExternalNumber'),[srAll]);
           if mCurrBO.GetFieldValueAsString('U_OrderState_ID.Code')in ['STOBJ05'] then begin
            mos.SQLExecute('Update receivedorders set  PMState_ID=''7010000101'' where id='+QuotedStr(mCurrBO.oid));
            mList:=TStringList.Create;
            mlist.Add(mCurrBO.OID);
            mFileName2:=NxSearchReplace(mCurrBO.DisplayName,'/','-',[srAll]);
            CFxReportManager.PrintByIDs(NxCreateContext_1(mCurrBO), mList, '40V53DORW3DL342X01C0CX3FCC', '4VD0000101', rtoFile, pekPDF, NxGetTempDir, mFileName2 + '.pdf');
            SendInternalMail(mCurrBO.ObjectSpace,mCurrBO.GetFieldValueAsString('FirmOffice_id.Address_id.Email'),
                           '','',
                           mCurrBO.GetFieldValueAsString('ExternalNumber')+' '+mCurrBO.GetFieldValueAsString('U_OrderState_ID.Name') ,
                           mBody,NxGetTempDir+'\'+ mFileName2 + '.pdf','', mCurrBO.GetFieldValueAsString('Firm_ID'),
                           '1400000101','','1300000101',mCurrBO.OID,mCurrBO.GetFieldValueAsString('U_OrderState_ID'));
             DeleteFile(NxGetTempDir+'\'+ mFileName2 + '.pdf');
           end else begin
            SendInternalMail(mCurrBO.ObjectSpace,mCurrBO.GetFieldValueAsString('FirmOffice_id.Address_id.Email'),
                           '','',
                           mCurrBO.GetFieldValueAsString('ExternalNumber')+' '+mCurrBO.GetFieldValueAsString('U_OrderState_ID.Name') ,
                           mBody,'','', mCurrBO.GetFieldValueAsString('Firm_ID'),
                           '1400000101','','1300000101',mCurrBO.OID,mCurrBO.GetFieldValueAsString('U_OrderState_ID'));
           end;
        end;
      end;

      if mCurrBO.GetFieldValueAsString('U_OrderState_ID.Code')='STOBJ03' then begin
        if NxMessageBox('Dotaz','Přejete si vygenerovat ZLVE a odeslat email '+mCurrBO.DisplayName+'?' , mdConfirm, mdbYesNo, 0, 0, False, nil)= mrYes then begin
           mBO:=mCurrBO;
           mZLV_ID:=GetZLV_ID(mOS,mBO.OID);
           if NxIsEmptyOID(mZLV_ID) then begin
             try
              mInputParams := TNxParameters.Create;
              mParam := mInputParams.GetOrCreateParam(dtString, 'DocQueue_ID');
              mParam.AsString := '2920000101';
              mImportMan := NxCreateDocumentImportManager(mCurrBO.ObjectSpace, Class_ReceivedOrder, Class_IssuedDepositInvoice);
              try
                mImportMan.AddInputDocument(mCurrBO.OID);
                mImportMan.LoadParams(mInputParams);
                mImportMan.Execute;
                mImportMan.CheckOutputDocument;
                if Assigned(mImportMan.OutputDocument) then begin
                  mImportMan.OutputDocument.SetFieldValueAsString('DocQueue_ID', '2920000101');
                  mImportMan.OutputDocument.SetFieldValueAsString('ReceivedOrder_ID',mCurrBO.OID);
                  mImportMan.OutputDocument.SetFieldValueAsString('PaymentType_ID', mCurrBO.GetFieldValueAsString('PaymentType_ID'));
                  mImportMan.OutputDocument.SetFieldValueAsString('TransportationType_ID', mCurrBO.GetFieldValueAsString('TransportationType_ID'));
                  mImportMan.OutputDocument.SetFieldValueAsString('Firm_ID',mCurrBO.GetFieldValueAsString('Firm_ID'));
                  mImportMan.OutputDocument.SetFieldValueAsString('VarSymbol',mCurrBO.GetFieldValueAsString('ExternalNumber'));
                  mImportMan.OutputDocument.Save;
                  mZLV_ID:=mImportMan.OutputDocument.OID;
                end;
              finally
                mImportMan.Free;
              end;
             finally

             end;


           end;
           if not(NxIsEmptyOID(mZLV_ID)) then begin
              mAccount_id:='1300000101';
              mList:=TStringList.create;
              mFileList:=TStringList.Create;
              mZLVBO:=mOS.CreateObject(Class_IssuedDepositInvoice);
              mZLVBO.Load(mZLV_ID,nil);
              mTO:=mZLVBO.GetFieldValueAsString('FirmOffice_ID.Address_ID.Email');
              //mTO:='marek.salava@abra.eu';
              mSubject:='Zálohový list #CISLO# k přijaté objednávce #CISOB# ';
              mBody:=mbo.GetFieldValueAsString('U_ORDERSTATE_ID.X_Note');
              mSubject:=NxSearchReplace(mSubject,'#CISLO#',mZLVBO.DisplayName,[srAll]);
              mSubject:=NxSearchReplace(mSubject,'#CISOB#',mBO.GetFieldValueAsString('ExternalNumber'),[srAll]);
              mBody:=NxSearchReplace(mBody,'#CISOBJ#',mBO.GetFieldValueAsString('ExternalNumber'),[srAll]);
              mBody:=NxSearchReplace(mBody,'#CISLOFAKTURY#',mZLVBO.DisplayName,[srAll]);
              mBody:=NxSearchReplace(mBody,'#VARSYMBOL#',mZLVBO.GetFieldValueAsString('VarSymbol'),[srall]);
              mBody:=NxSearchReplace(mBody,'#DATUMVYSTAVENI#',FormatDateTime('d.m.yyyy',mZLVBO.GetFieldValueAsdateTime('DocDate$Date')),[srall]);
              mBody:=NxSearchReplace(mBody,'#DATUMSPLATNOSTI#',FormatDateTime('d.m.yyyy',mZLVBO.GetFieldValueAsdateTime('DueDate$Date')),[srall]);
              mBody:=NxSearchReplace(mBody,'#CASTKA#',FormatFloat('0.00,',mZLVBO.GetFieldValueAsFloat('amount')),[srall]);
              mBody:=NxSearchReplace(mBody,'#TEMP#','',[srall]);
              mZLVBO.Load(mZLV_ID,nil);
              mlist.Add(mZLVBO.OID);
              mFileName:=NxSearchReplace(mZLVBO.DisplayName,'/','-',[srAll]);
              mFileName2:=NxSearchReplace(mBO.DisplayName,'/','-',[srAll]);
              CFxReportManager.PrintByIDs(NxCreateContext_1(mZLVBO), mList, 'S4STXJVRM3DL35J301C0CX3F40', '3O70000101', rtoFile, pekPDF, NxGetTempDir, mFileName + '.pdf');
              mList.Clear;
              mlist.Add(mBO.OID);
              CFxReportManager.PrintByIDs(NxCreateContext_1(mBO), mList, '40V53DORW3DL342X01C0CX3FCC', '4VD0000101', rtoFile, pekPDF, NxGetTempDir, mFileName2 + '.pdf');
              SendInternalMail(mOS, mTO,'','',
                                 mSubject,mBody,
                                 NxGetTempDir+'\'+ mFileName + '.pdf',NxGetTempDir+'\'+ mFileName2 + '.pdf',mZLVBO.GetFieldValueAsString('Firm_ID'),
                                 mZLVBO.GetLoadedCollectionMonikerForFieldCode(mZLVBO.GetFieldCode('Rows')).BusinessObject[0].GetFieldValueAsString('Division_ID'),
                                 mZLVBO.GetLoadedCollectionMonikerForFieldCode(mZLVBO.GetFieldCode('Rows')).BusinessObject[0].GetFieldValueAsString('BusTransaction_ID'),
                                 mAccount_ID, mBO.OID,mBO.GetFieldValueAsString('U_OrderState_ID'));
              DeleteFile(NxGetTempDir+'\'+ mFileName + '.pdf');
              DeleteFile(NxGetTempDir+'\'+ mFileName2 + '.pdf');
              mlist.Free;
           end;
           mCurrBO.PMChangeState('5010000101');
        end;
      end;
     end;
  end;
 end;
end;

begin
end.