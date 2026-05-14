uses 'eu.simon.PS.fce';

procedure BeforeSave_Hook(Self: TNxCustomBusinessObject);
var
 mRows:TNxCustomBusinessMonikerCollection;
 mRowBO,mZLVBO:TNxCustomBusinessObject;
 i, mMailCount:integer;
 mAvailableQuantity,mOrderedQuantity, mStorePrice: Extended;
 mNotOnStore, mZapornaMarze: Boolean;
 mOrigPMState_ID, mZLV_ID, mAccount_ID,mTO, mSubject, mBody,mFileName,mFileName2:string;
 mList,mFileList:TStringList;
 mLogList:TStringList;
 mLogFileName:string;
begin
   mLogList:=TStringList.Create;
   if self.GetFieldValueAsString('DocQueue_ID')='1W10000101' then begin
     if self.GetFieldValueAsString('U_OrderState_ID.Code')='STOBJ06' then begin
      self.SetFieldValueAsString('PMState_ID','9010000101');
      if NxIsBlank(self.GetFieldValueAsString('Description')) then
        Self.SetFieldValueAsString('Description','Storno');
     end;
     if (osNew in self.state) or (self.GetFieldValueAsString('PMState_ID') in ['RODEF00000','1010000101','2030000101']) then begin
      mLogFileName:=self.GetFieldValueAsString('ExternalNumber')+'_'+FormatDateTime('yyyymmddhhmm',Now);

      self.GetOriginalValue('PMState_ID',mOrigPMState_ID);
      mNotOnStore:=False;
      mZapornaMarze:=False;
      mLogList.Add('Kontrola '+self.GetFieldValueAsString('ExternalNumber')+' úhrada '+self.GetFieldValueAsString('PaymentType_ID.Code')+'  stav objednávky '+
                   self.GetFieldValueAsString('U_orderState_ID.code')+'  procesní stav '+self.GetFieldValueAsString('PMState_ID.Code'));
      mRows:=self.GetLoadedCollectionMonikerForFieldCode(self.GetFieldCode('Rows'));
        for i:=0 to mrows.Count-1 do begin
          mRowBO:=mRows.BusinessObject[i];
          if mRowBO.GetFieldValueAsInteger('RowType')=3 then begin
           if not(mNotOnStore) then begin
            mAvailableQuantity:=GetAvailableQuantity(self.ObjectSpace,mRowBO.GetFieldValueAsString('Store_ID'), mRowBO.GetFieldValueAsString('StoreCard_ID'))
                               {+GetAvailableQuantity(self.ObjectSpace,'4P00000101', mRowBO.GetFieldValueAsString('StoreCard_ID'))
                               +GetAvailableQuantity(self.ObjectSpace,'1E00000101', mRowBO.GetFieldValueAsString('StoreCard_ID'))
                               +GetAvailableQuantity(self.ObjectSpace,'2D00000101', mRowBO.GetFieldValueAsString('StoreCard_ID'))} ;
            mOrderedQuantity:=GetOrderedQuantity(Self.ObjectSpace,mRowBO.GetFieldValueAsString('StoreCard_ID'), mRowBO.OID,mRowBO.GetFieldValueAsString('Store_ID'), Self.GetFieldValueAsDateTime('CreatedAt$DATE'));
            if (mAvailableQuantity-mOrderedQuantity-mRowBO.GetFieldValueAsFloat('Quantity'))<0 then mNotOnStore:=True;
           end;
           if not mZapornaMarze then begin
             mStorePrice:=GetStorePrice(self.ObjectSpace,mRowBO.GetFieldValueAsString('Store_ID'), mRowBO.GetFieldValueAsString('StoreCard_ID'));
             if mStorePrice>mRowBO.GetFieldValueAsFloat('UnitPrice') then mZapornaMarze:=True;
           end;
          end;
          mLogList.add('Kontrola řádku '+IntToStr(mRowBO.GetFieldValueAsInteger('PosIndex'))+' karta '+mRowBO.GetFieldValueAsString('StoreCard_ID.name')+
                       '   Příznak není skladem '+BoolToStr(mNotOnStore,true)+'   Příznak záporná marže '+BoolToStr(mZapornaMarze,true));
        end;
        if not(mNotOnStore) then self.SetFieldValueAsString('PMState_ID','2000000101');
        mLogList.add('Řádek 49 procesní stav '+self.GetFieldValueAsString('PMState_ID.Code'));
        if mZapornaMarze then self.SetFieldValueAsString('PMState_ID','1010000101');
         mLogList.add('Řádek 51 procesní stav '+self.GetFieldValueAsString('PMState_ID.Code'));
        if GetValidSKPostcode(self.GetFieldValueAsString('FirmOffice_ID.Address_ID.PostCode')) then self.SetFieldValueAsString('PMState_ID','1010000101');
         mLogList.add('Řádek 53 procesní stav '+self.GetFieldValueAsString('PMState_ID.Code'));
        if not(GetValidCZPhonenumber(self.GetFieldValueAsString('FirmOffice_ID.Address_ID.PhoneNumber1'))) then self.SetFieldValueAsString('PMState_ID','1010000101');
        // if self.GetFieldValueAsString('TransportationType_ID')='5100000101' then self.SetFieldValueAsString('PMState_ID','1010000101');  //zakomentováno dne 20.6.2024
         mLogList.add('Řádek 56 procesní stav '+self.GetFieldValueAsString('PMState_ID.Code'));
        if (self.GetFieldValueAsString('PaymentType_ID')='6000000101') and
         not((Self.GetFieldValueAsString('U_orderState_ID')='IURB000101') or  (Self.GetFieldValueAsString('U_orderState_ID')='90F7000101')      //doplnění stavů 02 a 08 dne 18.10.2024
         or (Self.GetFieldValueAsString('U_orderState_ID')='6C92000101') or (Self.GetFieldValueAsString('U_orderState_ID')='70T5000101')) then
         self.SetFieldValueAsString('PMState_ID','1010000101');
         mLogList.add('Řádek 60 procesní stav '+self.GetFieldValueAsString('PMState_ID.Code'));
        if (self.GetFieldValueAsString('PaymentType_ID')='1000000101') then self.SetFieldValueAsString('PMState_ID','1010000101');  //doplněn dne 5.4.2024
         mLogList.add('Řádek 62 procesní stav '+self.GetFieldValueAsString('PMState_ID.Code'));
        //if (self.GetFieldValueAsString('PaymentType_ID')='1000000101') and (mNotOnStore) then self.SetFieldValueAsString('PMState_ID','1010000101');
        if {(mOrigPMState_ID='2030000101') and} mNotOnStore then self.SetFieldValueAsString('PMState_ID','2030000101');
        mLogList.add('Řádek 65 procesní stav '+self.GetFieldValueAsString('PMState_ID.Code'));
        if not(self.GetFieldValueAsString('X_AES_Description')='') then self.SetFieldValueAsString('PMState_ID','1010000101');
         mLogList.add('Řádek 67 procesní stav '+self.GetFieldValueAsString('PMState_ID.Code'));
        mZLV_ID:=self.ObjectSpace.SQLSelectFirstAsString('Select id from issueddinvoices where receivedorder_id='+QuotedStr(self.OID),'');
          if not(mNotOnStore) and (self.GetFieldValueAsString('PaymentType_ID')='1000000101') and not(NxIsEmptyOID(mZLV_ID)) {not (self.GetFieldValueAsString('PMSTate_ID')='1010000101')}
          and NxIsBlank(self.GetFieldValueAsString('X_AES_Description')) and not(mZapornaMarze) then begin
          mLogList.add('Řádek 70 procesní stav '+self.GetFieldValueAsString('PMState_ID.Code'));
          self.SetFieldValueAsString('PMState_ID','5010000101');
          self.SetFieldValueAsString('U_orderState_ID','7C92000101');
          mLogList.add('Řádek 73 procesní stav '+self.GetFieldValueAsString('PMState_ID.Code'));
          //kolotoč ze stavu STOBJ03

          //doplnit kontrolu na odeslaný email pro procestní stav 7C92000101
             if not(NxIsEmptyOID(mZLV_ID)) and not(self.GetFieldValueAsBoolean('U_ZLVSent')) then begin
              //kontrola na email existenc
              mMailCount:=self.ObjectSpace.SQLSelectFirstAsInteger('select count(id) from emailssent where X_ReceivedorderID='+QuotedStr(Self.oid)+' and X_OrderState_ID='+QuotedStr(self.GetFieldValueAsString('U_orderState_ID')),0);
              if mMailCount=0 then begin
                  mAccount_id:='1300000101';
                  mList:=TStringList.create;
                  mFileList:=TStringList.Create;
                  mZLVBO:=self.ObjectSpace.CreateObject(Class_IssuedDepositInvoice);
                  mZLVBO.Load(mZLV_ID,nil);
                  if mZLVBO.GetFieldValueAsFloat('Amount')>0 then begin
                    mTO:=mZLVBO.GetFieldValueAsString('FirmOffice_ID.Address_ID.Email');
                    //mTO:='marek.salava@abra.eu';
                    mSubject:='Zálohový list #CISLO# k přijaté objednávce #CISOB# ';
                    mBody:=self.GetFieldValueAsString('U_ORDERSTATE_ID.X_Note');
                    mSubject:=NxSearchReplace(mSubject,'#CISLO#',mZLVBO.DisplayName,[srAll]);
                    mSubject:=NxSearchReplace(mSubject,'#CISOB#',self.GetFieldValueAsString('ExternalNumber'),[srAll]);
                    mBody:=NxSearchReplace(mBody,'#CISOBJ#',self.GetFieldValueAsString('ExternalNumber'),[srAll]);
                    mBody:=NxSearchReplace(mBody,'#CISLOFAKTURY#',mZLVBO.DisplayName,[srAll]);
                    mBody:=NxSearchReplace(mBody,'#VARSYMBOL#',mZLVBO.GetFieldValueAsString('VarSymbol'),[srall]);
                    mBody:=NxSearchReplace(mBody,'#DATUMVYSTAVENI#',FormatDateTime('d.m.yyyy',mZLVBO.GetFieldValueAsdateTime('DocDate$Date')),[srall]);
                    mBody:=NxSearchReplace(mBody,'#DATUMSPLATNOSTI#',FormatDateTime('d.m.yyyy',mZLVBO.GetFieldValueAsdateTime('DueDate$Date')),[srall]);
                    mBody:=NxSearchReplace(mBody,'#CASTKA#',FormatFloat('0.00,',mZLVBO.GetFieldValueAsFloat('amount')),[srall]);
                    mBody:=NxSearchReplace(mBody,'#TEMP#','',[srall]);
                    mZLVBO.Load(mZLV_ID,nil);
                    mlist.Add(mZLVBO.OID);
                    mFileName:=NxSearchReplace(mZLVBO.DisplayName,'/','-',[srAll]);
                    mFileName2:=NxSearchReplace(Self.DisplayName,'/','-',[srAll]);
                    CFxReportManager.PrintByIDs(NxCreateContext_1(mZLVBO), mList, 'S4STXJVRM3DL35J301C0CX3F40', '3O70000101', rtoFile, pekPDF, NxGetTempDir, mFileName + '.pdf');
                    mList.Clear;
                    mlist.Add(self.OID);
                    CFxReportManager.PrintByIDs(NxCreateContext_1(self), mList, '40V53DORW3DL342X01C0CX3FCC', '4VD0000101', rtoFile, pekPDF, NxGetTempDir, mFileName2 + '.pdf');
                    SendInternalMail(self.ObjectSpace, mTO,'','',
                                       mSubject,mBody,
                                       NxGetTempDir+'\'+ mFileName + '.pdf',NxGetTempDir+'\'+ mFileName2 + '.pdf',mZLVBO.GetFieldValueAsString('Firm_ID'),
                                       mZLVBO.GetLoadedCollectionMonikerForFieldCode(mZLVBO.GetFieldCode('Rows')).BusinessObject[0].GetFieldValueAsString('Division_ID'),
                                       mZLVBO.GetLoadedCollectionMonikerForFieldCode(mZLVBO.GetFieldCode('Rows')).BusinessObject[0].GetFieldValueAsString('BusTransaction_ID'),
                                       mAccount_ID, self.OID,self.GetFieldValueAsString('U_OrderState_ID'));
                    DeleteFile(NxGetTempDir+'\'+ mFileName + '.pdf');
                    DeleteFile(NxGetTempDir+'\'+ mFileName2 + '.pdf');
                    mlist.Free;
                   end;
              end;
              self.SetFieldValueAsBoolean('U_ZLVSent',true);
             end;
          //konec kolotoče
        end;
      end;
      if not(CFxNxRuntime.NxGetEnvironmentType=reRuntimeExe) then begin
       try
        mLogList.SaveToFile('d:\wamp\www\kontrola_opes\'+mLogFileName+'.txt');
       except
        mLogList.add(ExceptionMessage);
        mloglist.savetofile('F:\logy\ps\'+mLogFileName+'.txt');
       end;
      end;
   end;
end;




procedure AfterSave_Hook(Self: TNxCustomBusinessObject);
var
 mImportMan:TNxDocumentImportManager;
 mInputParams:TNxParameters;
 mParam:TNxParameter;
 mList:TStringList;
 mBO:TNxCustomBusinessObject;
begin
 if not(self.GetFieldValueAsString('DocQueue_ID') in ['1W10000101','7RQ0000101']) then begin
  mBO:= Self.ObjectSpace.CreateObject(Class_ReceivedOrder);
  mBO.Load(Self.OID, nil);
    if mBO.GetFieldValueAsString('PMState_ID')='RODEF00000' then begin
     if not (osSaving in mBO.InternalState) then mBO.PMChangeState('6010000101');
    end;
  end;
  if self.GetFieldValueAsString('DocQueue_ID')='7RQ0000101' then begin
  mBO:= Self.ObjectSpace.CreateObject(Class_ReceivedOrder);
  mBO.Load(Self.OID, nil);
    if mBO.GetFieldValueAsString('PMState_ID')='RODEF00000' then begin
     if not (osSaving in mBO.InternalState) then mBO.PMChangeState('1060000101');
    end;
  end;
 if (self.GetFieldValueAsString('DocQueue_ID')='1W10000101') and not(self.GetFieldValueAsString('Description')='Storno') then begin
  mList:=TStringList.Create;
  self.ObjectSpace.SQLSelect(format('select id from storedocuments2 where provide_id=''%s'' ',[self.oid]),mlist);
  if mlist.count=0 then begin
  if self.GetFieldValueAsString('PMState_ID')='2000000101' then begin
     try
                      mInputParams := TNxParameters.Create;
                      mParam := mInputParams.GetOrCreateParam(dtString, 'DocQueue_ID');
                      mParam.AsString := '8RC0000101';
                      mParam := mInputParams.GetOrCreateParam(dtString, 'SelectedHeader');
                      mParam.AsString := self.OID;
                      mImportMan:=NxCreateDocumentImportManager(self.ObjectSpace,Class_ReceivedOrder,Class_BillOfDelivery);
                      mImportMan.AddInputDocument(self.OID);
                      mImportMan.LoadParams(mInputParams);
                      mImportMan.Execute;
                      mImportMan.OutputDocument.SetFieldValueAsString('DocQueue_ID', '8RC0000101');
                      mImportMan.OutputDocument.SetFieldValueAsString('Firm_ID',self.GetFieldValueAsString('Firm_ID'));
                      mImportMan.OutputDocument.SetFieldValueAsString('FirmOffice_ID',self.GetFieldValueAsString('FirmOffice_ID'));
                      mImportMan.OutputDocument.save;

         Except
          CFxLog.SaveLog(NxCreateContext_1(self),'ERR','chyba tvorby DL',self.DisplayName+#13#10+ExceptionMessage,2,Now);
         end;

   end;
  end;
  end;
end;

begin
end.