uses 'eu.abra.mavy.libs.common', '.lib';

{
Vyvolává se po uložení vlastních dat objektu do databáze.
}
procedure AfterSave_Hook(Self: TNxCustomBusinessObject);
var
 mImportMan:TNxDocumentImportManager;
 mInputParams:TNxParameters;
 mParam:TNxParameter;
 mOrder_ID, mPrinterName, mAllPrinter, mForm_ID, mDefaultPrinter:string;
 mIIList, mInvList, mBODlist2, mList, mVATDocList:TStringList;
 mQueryList, mBODList, mErrList:tstringlist;
 i, mcount:integer;
 mCountMessage, mBody, mFileName2, mVATDoc_ID:string;
 mCurrBO:TNxCustomBusinessObject;
 mPrinterExists:boolean;
begin
   if (self.GetFieldValueAsString('DocQueue_ID')='U200000101') then begin
     if (self.GetFieldValueAsString('PMState_ID')='SDDEF00000') and (CFxNxRuntime.NxGetEnvironmentType=reWebServices) then begin
        mForm_ID:=Self.GetFieldValueAsString('Firm_ID.X_FormDL_ID');
        if not(NxIsEmptyOID(mForm_ID)) then begin
          mBODList2:=tstringlist.Create;
          mBODlist2.Add(self.OID);
          CFxReportManager.PrintByIDs(NxCreateContext(self.ObjectSpace),mBODlist2,GetDynSource(self.ObjectSpace,mForm_ID),mForm_ID,rtoPrint,pekPDF,'canon_sklad', '',2);
        end;
     end;
   end;

  if (self.GetFieldValueAsString('DocQueue_ID')='8RC0000101') then begin
   if self.GetFieldValueAsString('PMState_ID')='SDDEF00000' then begin
    try
                      mDefaultPrinter:='samsung_eshop';
                      mPrinterExists:=false;
                      Printer.PrinterIndex := -1; // select default printer
                      mPrinterName := Printer.Printers[ Printer.PrinterIndex ];
                      for i:=0 to Printer.Printers.Count-1 do begin
                        mAllPrinter:=mAllPrinter+', '+Printer.Printers[i];
                        if not(mPrinterExists) and (printer.Printers[i]=mDefaultPrinter) then mPrinterExists:=true;
                      end;
                      mInvList:=TStringList.Create;
                      Self.ObjectSpace.SQLSelect('SELECT id FROM issuedinvoices2 WHERE Provide_ID = '+QuotedStr(self.OID),mInvList);
                      if mInvList.count=0 then begin
                      mIIList:=TStringList.create;
                      mQueryList:=TStringList.Create;
                      Self.ObjectSpace.SQLSelect('SELECT Provide_ID FROM StoreDocuments2 WHERE Parent_ID = '+QuotedStr(self.OID)+' AND Provide_ID IS NOT NULL',mQueryList);
                      if mQueryList.count>0 then mOrder_ID:=mQueryList.strings[0];
                      mInputParams := TNxParameters.Create;
                      mParam := mInputParams.GetOrCreateParam(dtString, 'DocQueue_ID');
                      mParam.AsString := '1Z10000101';
                      if not(NxIsEmptyOID(mOrder_ID)) then begin
                       mParam := mInputParams.GetOrCreateParam(dtString, 'SelectedHeader');
                       mParam.AsString := mOrder_ID;
                      end else begin
                       mParam := mInputParams.GetOrCreateParam(dtString, 'SelectedHeader');
                       mParam.AsString := self.OID;
                      end;
                      mImportMan:=NxCreateDocumentImportManager(self.ObjectSpace,Class_BillOfDelivery,Class_IssuedInvoice);
                      mImportMan.AddInputDocument(self.OID);
                      mImportMan.LoadParams(mInputParams);
                      mImportMan.Execute;
                      mImportMan.OutputDocument.SetFieldValueAsString('DocQueue_ID', '1Z10000101');
                      mImportMan.OutputDocument.SetFieldValueAsString('Firm_ID',self.GetFieldValueAsString('Firm_ID'));
                      mImportMan.OutputDocument.SetFieldValueAsString('FirmOffice_ID',self.GetFieldValueAsString('FirmOffice_ID'));
                      if mImportMan.OutputDocument.GetFieldValueAsString('TransportationType_ID.Code')='O1'
                                               then mImportMan.OutputDocument.SetFieldValueAsDateTime('DueDate$Date',Date+7);
                      mImportMan.OutputDocument.SetFieldValueAsString('CreatedBy_ID',self.GetFieldValueAsString('CorrectedBy_ID'));
                      if not(NxIsEmptyOID(mOrder_ID)) then mImportMan.OutputDocument.SetFieldValueAsString('VarSymbol',mImportMan.InputHeaders[0].GetFieldValueAsString('ExternalNumber'));
                      //if not(mImportMan.OutputDocument.GetFieldValueAsString('TransportationType_ID')='00000O1000') then begin
                      mImportMan.OutputDocument.save;
                      UsageAllDeposit(mImportMan.OutputDocument);
                      mIIList.Add(mImportMan.OutputDocument.OID);
                      mVATDoc_ID:=self.ObjectSpace.SQLSelectFirstAsString('select distinct VATDeposit_ID from issuedinvoices2 where parent_id='+QuotedStr(mImportMan.OutputDocument.OID)+' and vatdeposit_id is not null','');
                      NxScriptingLog.WriteEvent(logInfo, 'Název tiskárny '+mPrinterName+'   seznam '+mAllPrinter);
                       //CFxReportManager.PrintByIDs(NxCreateContext(self.ObjectSpace),mIIList,GetDynSource(self.ObjectSpace,'4N70000101'),'4N70000101',rtoPrint,pekPDF,'HP M527 Eshop', '');
                      try
                       if mPrinterExists then begin
                        CFxReportManager.PrintByIDs(NxCreateContext(self.ObjectSpace),mIIList,GetDynSource(self.ObjectSpace,'4N70000101'),'4N70000101',rtoPrint,pekPDF,mDefaultPrinter, '');
                        NxScriptingLog.WriteEvent(logInfo,'doklad se vytiskl');
                       end else begin
                        NxScriptingLog.WriteEvent(logInfo,'Nenašel jsem tiskárnu '+mDefaultPrinter);
                       end;
                      except
                       NxScriptingLog.WriteEvent(logInfo,'Vyjímka'+#13#13+ExceptionMessage);
                      end;
                      NxScriptingLog.WriteEvent(logInfo,'Po tisku faktury');
                      //CFxReportManager.PrintByIDs(NxCreateContext(self.ObjectSpace),mIIList,GetDynSource(self.ObjectSpace,'4N70000101'),'4N70000101',rtoPrint,pekPDF,mPrinterName, '');
                      if (mImportMan.OutputDocument.GetFieldValueAsString('PaymentType_ID') in ['1000000101','6000000101']) and
                        (mImportMan.OutputDocument.GetFieldValueAsString('TransportationType_ID')='00000O1000') then begin
                        mBODList2:=tstringlist.Create;
                        mBODlist2.Add(self.OID);
                        mVATDocList:=TStringList.create;
                        if not(NxIsEmptyOID(mVATDoc_ID)) then begin
                          mVATDocList.add(mVATDoc_ID);
                          if mPrinterExists then
                           CFxReportManager.PrintByIDs(NxCreateContext(self.ObjectSpace),mVATDocList,GetDynSource(self.ObjectSpace,'FH00000001'),'FH00000001',rtoPrint,pekPDF,mDefaultPrinter, '');
                        end;
                        //CFxReportManager.PrintByIDs(NxCreateContext(self.ObjectSpace),mBODlist2,GetDynSource(self.ObjectSpace,'4200000101'),'4200000101',rtoPrint,pekPDF,'HP M527 Eshop', '');
                        if mPrinterExists then
                         CFxReportManager.PrintByIDs(NxCreateContext(self.ObjectSpace),mBODlist2,GetDynSource(self.ObjectSpace,'4200000101'),'4200000101',rtoPrint,pekPDF,mDefaultPrinter, '');
                      end;
                      if (mImportMan.OutputDocument.GetFieldValueAsString('TransportationType_ID')='00000O1000') then begin
                        NxScriptingLog.WriteEvent(logInfo,'jsem ve smyčce pro mail');
                        self.ObjectSpace.SQLExecute('Update receivedorders set  PMState_ID=''7010000101'' where id='+QuotedStr(mOrder_ID));
                        mCurrBO:=self.ObjectSpace.CreateObject(Class_ReceivedOrder);
                        mCurrBO.Load(mOrder_ID,nil);
                        mCurrBO.SetFieldValueAsString('U_OrderState_ID','9C92000101');
                        mCurrBO.save;
                        NxScriptingLog.WriteEvent(logInfo,mCurrBO.DisplayName);
                        mBody:=mCurrBO.GetFieldValueAsString('U_OrderState_ID.X_Note');
                        mBody:=NxSearchReplace(mBody,'#CISOBJ#',mCurrBO.GetFieldValueAsString('ExternalNumber'),[srAll]);
                        mList:=TStringList.Create;
                        mlist.Add(mCurrBO.OID);
                        mFileName2:=NxSearchReplace(mCurrBO.DisplayName,'/','-',[srAll]);
                        NxScriptingLog.WriteEvent(logInfo,mFileName2);
                        //CFxReportManager.PrintByIDs(NxCreateContext_1(mCurrBO), mList, GetDynSource(self.ObjectSpace,'4VD0000101'), '4VD0000101', rtoFile, pekPDF, NxGetTempDir, mFileName2 + '.pdf');
                        NxScriptingLog.WriteEvent(logInfo,'po tisku, před mailem');
                        SendInternalMail(mCurrBO.ObjectSpace,mCurrBO.GetFieldValueAsString('FirmOffice_id.Address_id.Email'),
                                           '','',
                                           mCurrBO.GetFieldValueAsString('ExternalNumber')+' '+mCurrBO.GetFieldValueAsString('U_OrderState_ID.Name') ,
                                           mBody,'','', mCurrBO.GetFieldValueAsString('Firm_ID'),
                                           '1400000101','','1300000101',mCurrBO.OID,mCurrBO.GetFieldValueAsString('U_OrderState_ID'));
                        NxScriptingLog.WriteEvent(logInfo,'po mailu');
                        //DeleteFile(NxGetTempDir+'\'+ mFileName2 + '.pdf');


                      end;
                      //end;
                      //po uložení dokladu na osobní odběr udělat email jako STOBJ05
                      {if not(NxIsEmptyOID(mOrder_ID)) and
                        (mImportMan.OutputDocument.GetFieldValueAsString('TransportationType_ID')='00000O1000') then begin
                        mCurrBO:=self.ObjectSpace.CreateObject(Class_ReceivedOrder);
                        mCurrBO.Load(mOrder_ID,nil);
                        mCurrBO.SetFieldValueAsString('U_OrderState_ID','9C92000101');
                        mCountMessage:='';
                        mCount:=self.ObjectSpace.SQLSelectFirstAsInteger('Select count(id) from EmailsSent where X_receivedorderID='+QuotedStr(mCurrBO.OID)+' and x_OrderState_ID='+QuotedStr(mCurrBO.GetFieldValueAsString('U_OrderState_ID')),0);
                        if mCount>0 then mCountMessage:=#13#10+'(počet již odeslaných zpráv k objednávce se stavem '+mCurrBO.GetFieldValueAsString('U_OrderState_ID.Code')+' je '+IntToStr(mCount)+')';
                           mBody:=mCurrBO.GetFieldValueAsString('U_OrderState_ID.X_Note');
                           mBody:=NxSearchReplace(mBody,'#CISOBJ#',mCurrBO.GetFieldValueAsString('ExternalNumber'),[srAll]);
                           if mCurrBO.GetFieldValueAsString('U_OrderState_ID.Code')in ['STOBJ05'] then begin
                            self.ObjectSpace.SQLExecute('Update receivedorders set  PMState_ID=''7010000101'' where id='+QuotedStr(mCurrBO.oid));
                            mList:=TStringList.Create;
                            mlist.Add(mCurrBO.OID);
                            mFileName2:=NxSearchReplace(mCurrBO.DisplayName,'/','-',[srAll]);
                            CFxReportManager.PrintByIDs(NxCreateContext_1(mCurrBO), mList, '40V53DORW3DL342X01C0CX3FCC', '4VD0000101', rtoFile, pekPDF, NxGetTempDir, mFileName2 + '.pdf');
                            SendInternalMail(mCurrBO.ObjectSpace,mCurrBO.GetFieldValueAsString('FirmOffice_id.Address_id.Email'),
                                           '','',
                                           mCurrBO.GetFieldValueAsString('ExternalNumber')+' '+mCurrBO.GetFieldValueAsString('U_OrderState_ID.Name') ,
                                           mBody,NxGetTempDir+'\'+ mFileName2 + '.pdf','', mCurrBO.GetFieldValueAsString('Firm_ID'),
                                           '1400000101','','1300000101',mCurrBO.OID);
                             DeleteFile(NxGetTempDir+'\'+ mFileName2 + '.pdf');
                           end else begin
                            SendInternalMail(mCurrBO.ObjectSpace,mCurrBO.GetFieldValueAsString('FirmOffice_id.Address_id.Email'),
                                           '','',
                                           mCurrBO.GetFieldValueAsString('ExternalNumber')+' '+mCurrBO.GetFieldValueAsString('U_OrderState_ID.Name') ,
                                           mBody,'','', mCurrBO.GetFieldValueAsString('Firm_ID'),
                                           '1400000101','','1300000101',mCurrBO.OID);
                           end;
                         mCurrBO.save;
                         mCurrBO.free;
                      end;             }
                      mIIList.free;
                      mQueryList.free;
                      end;
      except
       mErrList:=tstringlist.create;
       mErrList.Add(ExceptionMessage);
       mErrList.SaveToFile('f:\logy\err\'+NxSearchReplace(self.DisplayName,'/','-',[srall])+'.txt');
      end;
    end;
  end;
end;

procedure UsageAllDeposit(AFV_HeaderBO: TNxCustomBusinessObject);
var
  mImportMan: TNxDocumentImportManager;
  mInputParams: TNxParameters;
  mParam: TNxParameter;
  mZLV_List, mDZLV_List: TStringList;
  mOS: TNxCustomObjectSpace;
  i, x: integer;
  mOPRS_OID, mDZLV_OID, mSQL, mRowOID: string;
  mSumDZLVAmount, mMaxAmount, mDZLVAmount: Extended;

  mIssuedDepositInvoice, mIssuedInvoice, mIssuedDepositUsage, mHeaderBO: TNxCustomBusinessObject;
  mDataset: TMemoryDataset;
  mRecOrder_OID, mZLV_OID: string;
begin
  OutputDebugString('UsageAllDeposit - start');
  // nejdrive dohledam zdrohjovou OP - jen jedna pro jednu FV - musi zde platit
  mOS := AFV_HeaderBO.ObjectSpace;
  mSQL:= 'SELECT DISTINCT B.Provide_ID FROM IssuedInvoices2 A'+
       ' JOIN StoreDocuments2 B on B.ID = A.ProvideRow_ID'+
       ' WHERE A.Parent_ID = ''%s'' AND B.Provide_ID IS NOT NULL';
  mSQL := Format(mSQL, [AFV_HeaderBO.OID]);
  mRecOrder_OID := SQLSingleSelect(mOS, mSQL);
  OutputDebugString('UsageAllDeposit - mRecOrder_OID: ' + mRecOrder_OID);
  if not NxIsEmptyOID(mRecOrder_OID) then begin
    mZLV_List := TStringList.Create;
    mDZLV_List := TStringList.Create;
    try
      //mExist_DZLV := False;
      //mSQL := 'select distinct ID from IssuedDInvoices where ReceivedOrder_ID = ''%s'' and Amount - UsedAmount > 0';
      mSQL := 'select distinct ID from IssuedDInvoices where ReceivedOrder_ID = ''%s'''; // jinak by to nefungovalo pro DZLV - je tim uz ZLV vycerpany
      mSQL := Format(mSQL, [mRecOrder_OID]);
      OutputDebugString('UsageAllDeposit - dohledani ZLV mSQL: ' + mSQL);
      mOS.SQLSelect(mSQL, mZLV_List);
      OutputDebugString('UsageAllDeposit - mZLV_List.Text: ' + mZLV_List.Text);
      for i := 0 to mZLV_List.Count - 1 do begin
        mZLV_OID := mZLV_List.Strings[i];
        // pokusim se dohledat pripadne DZLV pripojene k ZLV - pokud DZLV k ZLV najdu, neresim dlae castku daneho ZLV ale jen castku DZLV
        // ZLV se na FV zucotovava (nema vliv na castku FV), pokud je DZLV, tak se castka DZLV od castky FV odecita (DZLV ma vliv na castku FV)
        mSQL := 'select distinct DZLV.ID as DZLV_ID from IssuedDInvoices ZLV ' +
                'join IssuedDepositUsages IDU on IDU.DepositDocument_ID = ZLV.ID ' +
                'join VATIssuedDInvoices DZLV on IDU.PDocument_ID = DZLV.ID ' +
                'where ZLV.ID = ''%s''';
        mSQL := Format(mSQL, [mZLV_OID]);
        mDZLV_List.Clear;
        OutputDebugString('UsageAllDeposit - dohledani DZLV mSQL: ' + mSQL);
        mOS.SQLSelect(mSQL, mDZLV_List);
        OutputDebugString('UsageAllDeposit - mDZLV_List.Text: ' + mDZLV_List.Text);
        if mDZLV_List.Count > 0 then begin
          OutputDebugString('UsageAllDeposit - resim zuctovani ZLV');
          for x := 0 to mDZLV_List.Count - 1 do begin
            mDZLV_OID := mDZLV_List.Strings[x];
            // az zde otestuji, jestli je DZLV cerpatelny, pokud neni, nic nedelam
            mSQL := 'select AmountWithoutVAT - UsedAmountWithoutVAT from VATIssuedDInvoices where ID = ''%s''';
            mSQL := Format(mSQL, [mDZLV_OID]);
            OutputDebugString('UsageAllDeposit - castka DZLV mSQL: ' + mSQL);
            mDZLVAmount := GetFirstFloatRecordFromSQL(mOS, mSQL);
            if mDZLVAmount > 0 then begin
              mMaxAmount := AFV_HeaderBO.GetFieldValueAsFloat('Amount') - AFV_HeaderBO.GetFieldValueAsFloat('RoundingAmount'); // lubi ?? je ok ?
              mSumDZLVAmount := 0;
              mDataset := TMemoryDataset.Create(nil);
              try
                // pro jeden DZLV muzeme zuctovavat vice radek DZLV, po jednom, jinak to nefunguje
                mSQL := 'select (TAmountWithoutVAT - UsedAmountWithoutVAT - CreditAmountWithoutVAT) as SumAmount, ID as RowOID from VATIssuedDInvoices2 where RowType = 4 and Parent_ID = ''%s'' order by PosIndex';
                mSQL := Format(mSQL, [mDZLV_OID]);
                mOS.SQLSelect2(mSQL, mDataset);
                if mDataset.Active then begin
                  mDataset.First;
                  while not mDataset.Eof do begin
                    mDZLVAmount := mDataset.FieldByName('SumAmount').AsFloat;
                    mRowOID := mDataset.FieldByName('RowOID').AsString;
                    if mSumDZLVAmount >= mMaxAmount then begin
                      OutputDebugString('zuctovani DZLV castka je komplet zuctovana dle predpisu FV - vyskakuji');
                      Exit;
                    end;
                    mSumDZLVAmount := mSumDZLVAmount + mDZLVAmount;
                    if mSumDZLVAmount > mMaxAmount then begin
                      mDZLVAmount := mMaxAmount - (mSumDZLVAmount - mDZLVAmount);
                      OutputDebugString('zuctovani DZLV mohu zuctovat jen castecnou castku DZLV, prekrocila by predpis FV: ' + FloatToStr(mDZLVAmount));
                    end
                    else begin
                      OutputDebugString('zuctovani DZLV mohu zuctovat komplet castku radku DZLV: ' + FloatToStr(mDZLVAmount));
                    end;
                    mHeaderBO := mOS.CreateObject(Class_IssuedInvoice);
                    try
                      mHeaderBO.Load(AFV_HeaderBO.OID, nil); // znovunecteni FV kvuli osSaving
                      // pripravim si vstupni parametry pro ImportMana
                      mInputParams := TNxParameters.Create;
                      try
                        OutputDebugString('zuctovani DZLV do nove FV Nastavuji input params importmanageru');
                        mParam := mInputParams.GetOrCreateParam(dtString, 'DocQueue_ID');
                        mParam.AsString := AFV_HeaderBO.GetFieldValueAsString('DocQueue_ID');
                        OutputDebugString('mDZLVImportList.Text neni list: ' + mDZLV_OID);
                        OutputDebugString('DepositAmounts mDZLVAmount: ' + FloatToStr(mDZLVAmount));
                        mParam := mInputParams.GetOrCreateParam(dtString, 'DepositAmounts');
                        mParam.AsString := FloatToStr(mDZLVAmount);
                        mParam := mInputParams.GetOrCreateParam(dtString, 'SelectedRows');
                        mParam.AsString := mRowOID;
                        mImportMan := NxCreateDocumentImportManager(mOS, Class_VATIssuedDepositInvoice, Class_IssuedInvoice);
                        try
                          //mImportMan.AddInputDocuments(mDZLVImportList); nefunguje... takze po jednom..
                          mImportMan.AddInputDocument(mDZLV_OID);
                          mImportMan.OutputDocument := mHeaderBO; // opravuji existujici FV
                          mImportMan.LoadParams(mInputParams);
                          mImportMan.Execute;
                          mImportMan.CheckOutputDocument;
                          OutputDebugString('Zuctovani DZLV do FV Ukladani FV pomoci ImportMana - start');
                          mImportMan.OutputDocument.Save;
                          OutputDebugString('Zuctovani DZLV do FV Ukladani FV pomoci ImportMana - ulozeno ok');
                        finally
                          mImportMan.Free;
                        end;
                      finally
                        mInputParams.Free;
                      end;
                    finally
                      mHeaderBO.Free;
                    end;
                    mDataset.Next;
                  end;
                end;
              finally
                mDataset.Free;
              end;
            end;
          end;
        end
        else begin
          OutputDebugString('UsageAllDeposit - resim zuctovani ZLV');
          mIssuedDepositInvoice := mOS.CreateObject(Class_IssuedDepositInvoice);
          try
            mIssuedDepositInvoice.Load(mZLV_OID, nil);
            mIssuedInvoice := mOS.CreateObject(Class_IssuedInvoice);
            try
              mIssuedInvoice.Load(AFV_HeaderBO.OID, nil);
              if mIssuedDepositInvoice.GetFieldValueAsFloat('Amount') - mIssuedDepositInvoice.GetFieldValueAsFloat('UsedAmount') > 0 then begin
                mIssuedDepositUsage := NxCreateDepositUsage(mIssuedDepositInvoice, mIssuedInvoice);
                try
                  mIssuedDepositUsage.SetFieldValueAsFloat('LocalAmount', mIssuedDepositInvoice.GetFieldValueAsFloat('LocalAmount') - mIssuedDepositInvoice.GetFieldValueAsFloat('LocalUsedAmount'));
                  mIssuedDepositUsage.SetFieldValueAsFloat('Amount', mIssuedDepositInvoice.GetFieldValueAsFloat('Amount') - mIssuedDepositInvoice.GetFieldValueAsFloat('UsedAmount'));
                  mIssuedDepositUsage.Save;
                  OutputDebugString('UsageAllDeposit - zuctovani ZLV ulozeno');
                finally
                  mIssuedDepositUsage.Free;
                end;
              end
              else
                OutputDebugString('UsageAllDeposit - ZLV nelze zucotvat, je uz plne cerpany');
            finally
              mIssuedInvoice.Free;
            end;
          finally
            mIssuedDepositInvoice.Free;
          end;
        end;
      end;
    finally
      mZLV_List.Free;
      mDZLV_List.Free;
    end;
  end;
end;

function GetFirstFloatRecordFromSQL(AOS: TNxCustomObjectSpace; ASQL: String): Extended;
var
  mDataset: TMemoryDataset;
begin
  Result := 0;
  mDataset := TMemoryDataset.Create(nil);
  try
    AOS.SQLSelect2(ASQL, mDataset);
    if mDataset.Active then begin
      mDataset.First;
      Result := mDataset.FieldList.Fields[0].AsFloat;
    end;
  finally
    mDataset.Free;
  end;
end;



begin
end.