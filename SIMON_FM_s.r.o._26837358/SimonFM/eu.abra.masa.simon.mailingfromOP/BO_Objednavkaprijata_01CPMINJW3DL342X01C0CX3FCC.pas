uses '.fce';

{
Vyvolává se po uložení vlastních dat objektu do databáze.
}
procedure AfterSave_Hook(Self: TNxCustomBusinessObject);
Var
 mOrigValue, mBody, mTO, mAccount_ID:String;
 mOS:TNxCustomObjectSpace;
 mBO, mZLVBO, mResBO:TNxCustomBusinessObject;
 mFileList, mList:TStringList;
 mFileName, mZLV_ID, mSubject, mFileName2, mReservation_ID, mCountMessage:string;
 mInputParams:TNxParameters;
 mParam:TNxParameter;
 mImportMan:TNxDocumentImportManager;
 mRows:TNxCustomBusinessMonikerCollection;
 i, mCount:Integer;
begin
 if CFxNxRuntime.NxGetEnvironmentType=reRuntimeExe then begin
  if self.GetFieldValueAsString('Firm_ID')='27Y2000101s' then begin
     mOS:=self.ObjectSpace;
     self.GetOriginalValue('U_orderstate_ID',mOrigValue);
     if not(mOrigValue=self.GetFieldValueAsString('U_OrderState_ID')) then begin
       if (self.GetFieldValueAsString('U_OrderState_ID.Code') in ['STOBJ06']) then begin
        if NxMessageBox('Dotaz','Přejete si stornovat objednávku '+self.DisplayName+'?' , mdConfirm, mdbYesNo, 0, 0, False, nil)= mrYes then begin
          if NxIsBlank(self.GetFieldValueAsString('Description')) then
            self.SetFieldValueAsString('Description','STORNO');
              mrows:=self.GetLoadedCollectionMonikerForFieldCode(self.GetFieldCode('Rows'));
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
          mZLV_ID:=GetZLV_ID(mOS,Self.OID);
          if not(NxIsEmptyOID(mZLV_ID)) then begin
              mZLVBO:=mOS.CreateObject(Class_IssuedDepositInvoice);
              mZLVBO.Load(mZLV_ID,nil);
              mZLVBO.SetFieldValueAsString('Description','STORNO');
              mRows:=mZLVBO.GetLoadedCollectionMonikerForFieldCode(mZLVBO.GetFieldCode('Rows'));
              for i:=0 to mRows.count-1 do begin
                if mRows.BusinessObject[i].GetFieldValueAsInteger('RowType')=4 then
                   mRows.BusinessObject[i].SetFieldValueAsFloat('TAmount',0);
              end;
              mZLVBO.save;
              mzlvbo.free;
          end;
        end;
       end;
      if (self.GetFieldValueAsString('U_OrderState_ID.Code') in ['STOBJ02','STOBJ08','STOBJ09']) then begin
        mCountMessage:='';
        mCount:=mOS.SQLSelectFirstAsInteger('Select count(id) from EmailsSent where X_receivedorderID='+QuotedStr(self.OID)+' and x_OrderState_ID='+QuotedStr(self.GetFieldValueAsString('U_OrderState_ID')),0);
        if mCount>0 then mCountMessage:=#13#10+'(počet již odeslaných zpráv k objednávce se stavem '+self.GetFieldValueAsString('U_OrderState_ID.Code')+' je '+IntToStr(mCount)+')';
        if NxMessageBox('Dotaz','Přejete si odeslat email '+self.DisplayName+'?'+mCountMessage , mdConfirm, mdbYesNo, 0, 0, False, nil)= mrYes then begin
           mBody:=self.GetFieldValueAsString('U_OrderState_ID.X_Note');
           mBody:=NxSearchReplace(mBody,'#CISOBJ#',self.GetFieldValueAsString('ExternalNumber'),[srAll]);
           if self.GetFieldValueAsString('U_OrderState_ID.Code')='STOBJ08' then begin
            mList:=TStringList.Create;
            mlist.Add(self.OID);
            mFileName2:=NxSearchReplace(self.DisplayName,'/','-',[srAll]);
            CFxReportManager.PrintByIDs(NxCreateContext_1(self), mList, '40V53DORW3DL342X01C0CX3FCC', '4VD0000101', rtoFile, pekPDF, NxGetTempDir, mFileName2 + '.pdf');
            SendInternalMail(self.ObjectSpace,self.GetFieldValueAsString('Firm_id.ResidenceAddress_id.Email'),
                           '','',
                           self.GetFieldValueAsString('ExternalNumber')+' '+self.GetFieldValueAsString('U_OrderState_ID.Name') ,
                           mBody,NxGetTempDir+'\'+ mFileName2 + '.pdf','', self.GetFieldValueAsString('Firm_ID'),
                           '1400000101','','1300000101',self.OID,self.GetFieldValueAsString('U_OrderState_ID'));
             DeleteFile(NxGetTempDir+'\'+ mFileName2 + '.pdf');
           end else begin
            SendInternalMail(self.ObjectSpace,self.GetFieldValueAsString('Firm_id.ResidenceAddress_id.Email'),
                           '','',
                           self.GetFieldValueAsString('ExternalNumber')+' '+self.GetFieldValueAsString('U_OrderState_ID.Name') ,
                           mBody,'','', self.GetFieldValueAsString('Firm_ID'),
                           '1400000101','','1300000101',self.OID,self.GetFieldValueAsString('U_OrderState_ID'));
           end;
        end;
      end;

      if self.GetFieldValueAsString('U_OrderState_ID.Code')='STOBJ03' then begin
        if NxMessageBox('Dotaz','Přejete si vygenerovat ZLVE a odeslat email '+self.DisplayName+'?' , mdConfirm, mdbYesNo, 0, 0, False, nil)= mrYes then begin
           mBO:=Self;
           mZLV_ID:=GetZLV_ID(mOS,mBO.OID);
           if NxIsEmptyOID(mZLV_ID) then begin
             try
              mInputParams := TNxParameters.Create;
              mParam := mInputParams.GetOrCreateParam(dtString, 'DocQueue_ID');
              mParam.AsString := '2920000101';
              mImportMan := NxCreateDocumentImportManager(self.ObjectSpace, Class_ReceivedOrder, Class_IssuedDepositInvoice);
              try
                mImportMan.AddInputDocument(self.OID);
                mImportMan.LoadParams(mInputParams);
                mImportMan.Execute;
                mImportMan.CheckOutputDocument;
                if Assigned(mImportMan.OutputDocument) then begin
                  mImportMan.OutputDocument.SetFieldValueAsString('DocQueue_ID', '2920000101');
                  mImportMan.OutputDocument.SetFieldValueAsString('ReceivedOrder_ID',self.OID);
                  mImportMan.OutputDocument.SetFieldValueAsString('PaymentType_ID', self.GetFieldValueAsString('PaymentType_ID'));
                  mImportMan.OutputDocument.SetFieldValueAsString('TransportationType_ID', self.GetFieldValueAsString('TransportationType_ID'));
                  mImportMan.OutputDocument.SetFieldValueAsString('Firm_ID',self.GetFieldValueAsString('Firm_ID'));
                  mImportMan.OutputDocument.SetFieldValueAsString('VarSymbol',self.GetFieldValueAsString('ExternalNumber'));
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
              mSubject:='Zálohový list #CISLO# k přijaté objednávce #CISOB# .';
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
           self.SetFieldValueAsString('PMSTate_ID','5010000101');
        end;
      end;
     end;
  end;
 end;
end;

begin
end.