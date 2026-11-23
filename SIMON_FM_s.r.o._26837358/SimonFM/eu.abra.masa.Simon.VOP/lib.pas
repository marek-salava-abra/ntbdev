uses '.fce';
//kontrola objednávek řada OPV, stav VO Vyřízeno tvorba převodky výdej do PVCT s cílovým skladem 01-VO


procedure AddTransferRowIfMissing(AList: TStringList; AStore_ID, AStoreCard_ID: string; AQuantity: Extended);
var
  i: Integer;
  mTempStr, mExistingStore_ID, mExistingStoreCard_ID: string;
begin
  for i := 0 to AList.Count - 1 do begin
    mTempStr := AList.Strings[i];
    mExistingStore_ID := NxTrapStrTrim(mTempStr, ';');
    mExistingStoreCard_ID := NxTrapStrTrim(mTempStr, ';');
    if (mExistingStore_ID <> '') and (mExistingStoreCard_ID = AStoreCard_ID) then
      Exit;
  end;
  AList.Add(AStore_ID + ';' + AStoreCard_ID + ';' + FloatToStr(AQuantity));
end;

procedure CreateDL03(OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
 var
  mList, mLogs:TStringList;
  i,j,k:integer;
  mAvailableQuantity,mOrderedQuantity, mQuantityMO, mQuantity05, mQuantityLogStore,mDodano, mRowQ, mQuantity, mUnpaidAmount, mQuantityRO:Extended;
  mOrderBO, mRowBO, mOrderBOForPMState:TNxCustomBusinessObject;
  mRows:TNxCustomBusinessMonikerCollection;
  mNotOnStore, mRowAdded, mNextStore, mUnpaidZLV:Boolean;
  mNotLogisticStoreList, mLogisticStoreList:TStringList;
  mResult, mDestinationStore_ID, mDivision_ID,mHorizontalSplitter:String;
  mImportMan:TNxDocumentImportManager;
  mInputParams:TNxParameters;
  mParam:TNxParameter;
  mLog_ID, mTempResult:String;
  mLogBO:TNxCustomBusinessObject;
begin
  mResult:='';
  mList:=TStringList.Create;
  OS.SQLSelect('select id from receivedorders where docqueue_id=''7RQ0000101'' and ((pmstate_id=''2060000101'') or (pmstate_id=''8060000101'') or (pmstate_id=''3060000101'')) '+
               ' and Closed=''N'' and IsAvailableForDelivery=''A'' order by CreatedAt$Date ',mList);
  if mList.Count>0 then begin
    for i:=0 to mList.Count-1 do begin
      // vnitřek listu
        mDestinationStore_ID:='';
        mDivision_ID:='';
        mNotOnStore:=False;
        mLogisticStoreList:=TStringList.Create;
        mNotLogisticStoreList:=TStringList.create;
        mLogisticStoreList.Clear;
        mNotLogisticStoreList.Clear;
        mUnpaidZLV:=False;
        mUnpaidAmount:=0;
        mLogs:=TStringList.Create;
        mTempResult:='';
        mHorizontalSplitter:=GetHorizontalSplitter(50);
        mOrderBO:=OS.CreateObject(Class_ReceivedOrder);
        mOrderBO.Load(mlist.Strings[i],nil);
        mRows:=mOrderBO.GetLoadedCollectionMonikerForFieldCode(mOrderBO.GetFieldCode('Rows'));
            for j:=0 to mrows.Count-1 do begin
              mRowBO:=mRows.BusinessObject[j];
               if mRowBO.GetFieldValueAsInteger('RowType')=3 then begin
                if NxIsEmptyOID(mDestinationStore_ID) then mDestinationStore_ID:=mRowBO.GetFieldValueAsString('Store_ID');
                if NxIsEmptyOID(mDivision_ID) then mDivision_ID:=mRowBO.GetFieldValueAsString('Division_ID');
                mAvailableQuantity:=GetAvailableQuantity(OS,mRowBO.GetFieldValueAsString('Store_ID'), mRowBO.GetFieldValueAsString('StoreCard_ID'));
                mquantityRO:=OS.sqlselectFirstAsExtended('select sum(quantity) from receivedorders2 where parent_id='+
                                            Quotedstr(mOrderBO.OID)+' and storecard_id='+QuotedStr(mRowBO.GetFieldValueAsString('StoreCard_ID')));
                mQuantity:=GetQuantity(OS,mRowBO.GetFieldValueAsString('Store_ID'), mRowBO.GetFieldValueAsString('StoreCard_ID'));
                mOrderedQuantity:=GetOrderedQuantity(OS,mRowBO.GetFieldValueAsString('StoreCard_ID'), mRowBO.OID,mRowBO.GetFieldValueAsString('Store_ID'),
                                  mOrderBO.GetFieldValueAsDateTime('CreatedAt$DATE'));
                if (mAvailableQuantity-mOrderedQuantity-mQuantityRO)<0 then begin
                  mRowQ:=mQuantityRO;
                  mNotOnStore:=True;
                  if mRowQ>mQuantity then begin
                      mQuantity05:=GetAvailableQuantity(OS,'2D00000101', mRowBO.GetFieldValueAsString('StoreCard_ID')) //sklad 05
                      -NxEvalObjectExprAsFloatDef(mRowBO,'NxGetReservedQuantity('+Quotedstr(mRowBO.GetFieldValueAsString('StoreCard_ID'))+','+QuotedStr('2D00000101')+')',0);
                      mQuantityMO:=GetAvailableQuantity(OS,'1E00000101', mRowBO.GetFieldValueAsString('StoreCard_ID')) //sklad MO
                      -NxEvalObjectExprAsFloatDef(mRowBO,'NxGetReservedQuantity('+Quotedstr(mRowBO.GetFieldValueAsString('StoreCard_ID'))+','+QuotedStr('1E00000101')+')',0);
                      mQuantityLogStore:=GetAvailableQuantity(OS,'1L00000101', mRowBO.GetFieldValueAsString('StoreCard_ID'))//sklad 555
                      -NxEvalObjectExprAsFloatDef(mRowBO,'NxGetReservedQuantity('+Quotedstr(mRowBO.GetFieldValueAsString('StoreCard_ID'))+','+QuotedStr('1L00000101')+')',0);
                      mLogs.add(mRowBO.GetFieldValueAsString('StoreCard_ID.code')+' '+ mRowBO.GetFieldValueAsString('StoreCard_ID.Name')+#13#10+
                                                                                         'mQuantity05 '+FloatToStr(mQuantity05)+#13#10+
                                                                                         'mQuantityMO '+FloatToStr(mQuantityMO)+#13#10+
                                                                                         'mQuantityLogStore '+FloatToStr(mQuantityLogStore)+#13#10+
                                                                                         'bez rezervace '+FloatToStr(GetAvailableQuantity(OS,'1L00000101', mRowBO.GetFieldValueAsString('StoreCard_ID')))+#13#10+
                                                                                         'rezervace '+FloatToStr(NxEvalObjectExprAsFloatDef(mRowBO,'NxGetReservedQuantity('+Quotedstr(mRowBO.GetFieldValueAsString('StoreCard_ID'))+','+QuotedStr('1L00000101')+')',0)));
                      if ((mQuantity05+mQuantityMO+mQuantityLogStore)>0)  and ((mRowQ-mQuantity)<=(mQuantity05+mQuantityMO+mQuantityLogStore)) then begin
                         mDodano:=0;
                         mNextStore:=True;
                       if (mQuantity05>0) and (mRowQ-mQuantity-mDodano>0) and mNextStore then begin
                            if mQuantity05>=(mRowQ-mDodano) then begin
                                 AddTransferRowIfMissing(mNotLogisticStoreList,'2D00000101',mRowBO.GetFieldValueAsString('StoreCard_ID'),mRowQ-mQuantity-mDodano);
                                 mNextStore:=false;
                                 mDodano:=mDodano+(mRowQ-mDodano);
                            end else begin
                                 AddTransferRowIfMissing(mNotLogisticStoreList,'2D00000101',mRowBO.GetFieldValueAsString('StoreCard_ID'),mQuantity05);
                                 mNextStore:=True;
                                 mDodano:=mDodano+mQuantity05;
                            end;
                            mLogs.add('Dodáno :'+FloatToStr(mDodano)+'       ze skladu 05');
                            mLogs.add(mHorizontalSplitter);
                         end;
                         if (mQuantityMO>0) and (mRowQ-mQuantity-mDodano>0) and mNextStore then begin
                            if mQuantityMO>=(mRowQ-mDodano) then begin
                                 AddTransferRowIfMissing(mNotLogisticStoreList,'1E00000101',mRowBO.GetFieldValueAsString('StoreCard_ID'),mRowQ-mQuantity-mDodano);
                                 mNextStore:=false;
                                 mDodano:=mDodano+(mRowQ-mDodano);
                            end else begin
                                 AddTransferRowIfMissing(mNotLogisticStoreList,'1E00000101',mRowBO.GetFieldValueAsString('StoreCard_ID'),mQuantityMO);
                                 mNextStore:=True;
                                 mDodano:=mDodano+mQuantityMO;
                            end;
                            mLogs.add('Dodáno :'+FloatToStr(mDodano)+'       ze skladu MO-II');
                            mLogs.add(mHorizontalSplitter);
                         end;
                         if (mQuantityLogStore>0) and (mRowQ-mQuantity-mDodano>0) and mNextStore then begin
                            if mQuantityLogStore>=(mRowQ-mDodano) then begin
                                 AddTransferRowIfMissing(mLogisticStoreList,'1L00000101',mRowBO.GetFieldValueAsString('StoreCard_ID'),mRowQ-mQuantity-mDodano);
                                 mNextStore:=false;
                                 mDodano:=mDodano+(mRowQ-mDodano);
                            end else begin
                                 AddTransferRowIfMissing(mLogisticStoreList,'1L00000101',mRowBO.GetFieldValueAsString('StoreCard_ID'),mQuantityLogStore);
                                 mNextStore:=True;
                                 mDodano:=mDodano+mQuantityLogStore;
                            end;
                            mLogs.add('Dodáno :'+FloatToStr(mDodano)+'       ze skladu 555');
                            mLogs.add(mHorizontalSplitter);
                         end;
                      end;
                   end;
                end;
              end;
            end;
        if (mNotOnStore) then begin
          if mOrderBO.GetFieldValueAsBoolean('Firm_ID.U_blackList') then begin
            mResult:=mResult+#13#10+'firma je na černé listině:  '+mOrderBO.GetFieldValueAsString('Firm_ID.Name');
            if not (osSaving in mOrderBO.InternalState) then mOrderBO.PMChangeState('2070000101');
          end else begin
           if mOrderBO.GetFieldValueAsBoolean('U_NotCreateTransfer') then begin
              mResult:=mResult+#13#10+'Zboží nebylo skladem, a netvoříme převody '+mOrderBO.DisplayName;
              if not (osSaving in mOrderBO.InternalState) then mOrderBO.PMChangeState('3060000101');
           end else begin
            mResult:=mResult+#13#10+'Zboží nebylo skladem, kontrola jestli něco spadlo do převodů '+mOrderBO.DisplayName;
            if ((mNotLogisticStoreList.Count+mLogisticStoreList.Count)=0) then begin
               if not (osSaving in mOrderBO.InternalState) then mOrderBO.PMChangeState('3060000101');
            end;
            if mNotLogisticStoreList.count>0 then begin
              mNotLogisticStoreList.SaveToFile('f:\logy\OutgoingTransfers\'+NxSearchReplace(mOrderBO.DisplayName,'/','-',[srAll])+'_nonlog.txt');
              mResult:=mResult+#13#10+'Výdej z nepolohovaných skladů '+mOrderBO.DisplayName;
              for k:=0 to mNotLogisticStoreList.Count-1 do begin
                mResult:=mResult+#13#10+mNotLogisticStoreList.Strings[k];
              end;
              mtempresult:=CreateTransfer(OS,mOrderBO,mNotLogisticStoreList,'6RB0000101',mDestinationStore_ID, mDivision_ID);
              mResult:=mResult+#13#10+mtempResult;
            end;
            if mLogisticStoreList.count>0 then begin
              mResult:=mResult+#13#10+'Výdej z polohovaného skladů '+mOrderBO.DisplayName;
              mLogisticStoreList.SaveToFile('f:\logy\OutgoingTransfers\'+NxSearchReplace(mOrderBO.DisplayName,'/','-',[srAll])+'_log.txt');
              for k:=0 to mLogisticStoreList.Count-1 do begin
                mResult:=mResult+#13#10+mLogisticStoreList.Strings[k];
              end;
              mTempResult:=CreateTransfer(OS,mOrderBO,mLogisticStoreList,'6RC0000101',mDestinationStore_ID, mDivision_ID);
              mResult:=mResult+#13#10+mtempresult;
            end;
           end;
          end;
         mlogs.add('Výsledek: '+#13#10+mTempResult);
        end else begin
          mUnpaidAmount:=OS.SQLSelectFirstAsExtended('Select amount-paidamount from issueddinvoices where amount>0 and receivedorder_id='+QuotedStr(mOrderBO.OID),0);
          if mUnpaidAmount>0 then mUnpaidZLV:=True;
          if mOrderBO.GetFieldValueAsBoolean('Firm_ID.U_blackList') or mOrderBO.GetFieldValueAsBoolean('Firm_ID.U_stop_fakturace') or mUnpaidZLV then begin
            mResult:=mResult+#13#10+'firma je na černé listině nebo má stop fakturace :  '+mOrderBO.GetFieldValueAsString('Firm_ID.Name');
            if not (osSaving in mOrderBO.InternalState) then mOrderBO.PMChangeState('2070000101');
          end else begin
            mResult:=mResult+#13#10+'Máme všechno děláme DL  '+mOrderBO.DisplayName;
            try
                        mInputParams := TNxParameters.Create;
                        mParam := mInputParams.GetOrCreateParam(dtString, 'DocQueue_ID');
                        mParam.AsString := 'U200000101';
                        mParam := mInputParams.GetOrCreateParam(dtString, 'SelectedHeader');
                        mParam.AsString := mOrderBO.OID;
                        mImportMan:=NxCreateDocumentImportManager(OS,Class_ReceivedOrder,Class_BillOfDelivery);
                        mImportMan.AddInputDocument(mOrderBO.OID);
                        mImportMan.LoadParams(mInputParams);
                        mImportMan.Execute;
                        mImportMan.OutputDocument.SetFieldValueAsString('DocQueue_ID', 'U200000101');
                        mImportMan.OutputDocument.SetFieldValueAsString('Firm_ID',mOrderBO.GetFieldValueAsString('Firm_ID'));
                        mImportMan.OutputDocument.SetFieldValueAsString('FirmOffice_ID',mOrderBO.GetFieldValueAsString('FirmOffice_ID'));
                        mImportMan.OutputDocument.save;
                        mResult:=mResult+#13#10+'Nový DL '+mImportMan.OutputDocument.DisplayName;
                        mOrderBOForPMState:=OS.CreateObject(Class_ReceivedOrder);
                        mOrderBOForPMState.Load(mOrderBO.OID,nil);
                        mOrderBOForPMState.PMChangeState('5060000101');
            Except
              mResult:=mResult+#13#10+'##################'+#13#10+ExceptionMessage;
            end;

          end;
        end;
       if mlogs.Count>0 then begin
         mLog_ID:=OS.SQLSelectFirstAsString('select pl.id from prflogs pl where pl.docqueue_id='+QuotedStr('6RW0000101')+' and pl.code='+QuotedStr('Převod k '+morderBO.DisplayName),'');
         if NxIsEmptyOID(mLog_ID) then
          CFxLog.SaveLog(NxCreateContext(OS),'LPV', 'Převod k '+mOrderBO.DisplayName, mLogs.text,ltScripting,now)
         else begin
           mLogBO:=OS.CreateObject(Class_PRFLog);
           mLogBO.Load(mLog_ID,nil);
           mLogBO.SetFieldValueAsString('Note',mLogBO.GetFieldValueAsString('Note')+nxCrLf+mLogs.Text);
           mLogBO.save;
           mLogBO.free;
         end; 
        //CFxLog.SaveLog(NxCreateContext(OS),'LPV', 'Převod k '+mOrderBO.DisplayName, mLogs.text,ltScripting,now);
        mLogs.free;
       end;
      //konec vnitřku
    end;
  end;
  Success := True;
  LogInfoStr := 'Počet záznamů '+IntToStr(mlist.Count)+#13#10+mResult;
end;

procedure CheckVOStop(OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
var
 mList:TStringList;
 mOrderBO:TNxCustomBusinessObject;
 mUnpaidAmount:Extended;
 i:integer;
begin
 mList:=TStringList.create;
 OS.SQLSelect('select id from receivedorders where docqueue_id=''7RQ0000101'' and (pmstate_id=''2070000101'') '+
               ' and Closed=''N'' and IsAvailableForDelivery=''A'' order by CreatedAt$Date ',mList);
  if mList.Count>0 then begin
    for i:=0 to mList.Count-1 do begin
        mOrderBO:=OS.CreateObject(Class_ReceivedOrder);
        mOrderBO.Load(mlist.Strings[i],nil);
        mUnpaidAmount:=OS.SQLSelectFirstAsExtended('Select amount-paidamount from issueddinvoices where amount>0 and receivedorder_id='+QuotedStr(mOrderBO.OID),1);
        if mUnpaidAmount=0 then mOrderBO.PMChangeState('2060000101');
    end;
  end;
end;

function GetHorizontalSplitter(aLength: Integer): string;
var
  i: Integer;
begin
  Result := '';
  for i := 1 to aLength do
    Result := Result + '─';
end;

begin
end.
