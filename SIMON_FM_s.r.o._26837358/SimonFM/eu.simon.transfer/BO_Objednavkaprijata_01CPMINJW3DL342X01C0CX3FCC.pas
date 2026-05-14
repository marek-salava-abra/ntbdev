const
  cLogStoreDocQueue_ID = '7RE0000101';
  cStoreGateWay_ID = '1000000101';

procedure AfterSave_Hook(Self: TNxCustomBusinessObject);
Var
 mList:TStringList;
  i,j,k:integer;
  mAvailableQuantity,mOrderedQuantity, mQuantityMO, mQuantity05, mQuantityLogStore,mDodano, mRowQ, mQuantity, mUnpaidAmount:Extended;
  mRowBO, mOrderBOForPMState:TNxCustomBusinessObject;
  mRows:TNxCustomBusinessMonikerCollection;
  mNotOnStore, mRowAdded, mNextStore, mUnpaidZLV:Boolean;
  mNotLogisticStoreList, mLogisticStoreList:TStringList;
  mResult, mDestinationStore_ID, mDivision_ID:String;
  mImportMan:TNxDocumentImportManager;
  mInputParams:TNxParameters;
  mParam:TNxParameter;
  OS:TNxCustomObjectSpace;
begin
 OS:=self.ObjectSpace;
 try
   if (osnew in self.state) and (self.GetFieldValueAsString('DocQueue_ID')='1W10000101') then begin
     try
      mResult:='';
      NxScriptingLog.EnterSection('Převodka výdej',logInfo);
      NxScriptingLog.WriteEvent(logInfo,'Tvorba převodky výdej pro doklad '+self.DisplayName);
      mLogisticStoreList:=TStringList.Create;
      mNotLogisticStoreList:=TStringList.create;
      mLogisticStoreList.Clear;
      mNotLogisticStoreList.Clear;
      mRows:=self.GetLoadedCollectionMonikerForFieldCode(self.GetFieldCode('Rows'));
      for j:=0 to mrows.Count-1 do begin
              mRowBO:=mRows.BusinessObject[j];
               if mRowBO.GetFieldValueAsInteger('RowType')=3 then begin
                if NxIsEmptyOID(mDestinationStore_ID) then mDestinationStore_ID:=mRowBO.GetFieldValueAsString('Store_ID');
                if NxIsEmptyOID(mDivision_ID) then mDivision_ID:=mRowBO.GetFieldValueAsString('Division_ID');
                mAvailableQuantity:=GetAvailableQuantity(OS,mRowBO.GetFieldValueAsString('Store_ID'), mRowBO.GetFieldValueAsString('StoreCard_ID'));
                mQuantity:=GetQuantity(OS,mRowBO.GetFieldValueAsString('Store_ID'), mRowBO.GetFieldValueAsString('StoreCard_ID'));
                mOrderedQuantity:=GetOrderedQuantity(OS,mRowBO.GetFieldValueAsString('StoreCard_ID'), mRowBO.OID,mRowBO.GetFieldValueAsString('Store_ID'),
                                  self.GetFieldValueAsDateTime('CreatedAt$DATE'));
                NxScriptingLog.WriteEvent(logInfo,'Karta '+mRowBO.GetFieldValueAsString('StoreCard_ID.Code')+' '+mRowBO.GetFieldValueAsString('StoreCard_ID.Name')+
                                                  '   AvailableQuantity: '+FloatToStr(mAvailableQuantity)+
                                                  '   Quantity: '+FloatToStr(mQuantity)+
                                                  '   mOrderedQuantity: '+FloatToStr(mOrderedQuantity)+
                                                  '   RowQuantity: '+FloatToStr(mRowBO.GetFieldValueAsFloat('Quantity')));
                if (mAvailableQuantity-mOrderedQuantity-mRowBO.GetFieldValueAsFloat('Quantity'))<0 then begin
                NxScriptingLog.WriteEvent(logInfo,'Karta '+mRowBO.GetFieldValueAsString('StoreCard_ID.Code')+' výsledek '+FloatToStr((mAvailableQuantity-mOrderedQuantity-mRowBO.GetFieldValueAsFloat('Quantity'))));
                  mRowQ:=mRowBO.GetFieldValueAsFloat('Quantity');
                  mNotOnStore:=True;
                  if mRowQ>mQuantity then begin
                      mQuantity05:=GetAvailableQuantity(OS,'2D00000101', mRowBO.GetFieldValueAsString('StoreCard_ID')); //sklad 05
                      mQuantityMO:=GetAvailableQuantity(OS,'1E00000101', mRowBO.GetFieldValueAsString('StoreCard_ID')); //sklad MO
                      mQuantityLogStore:=GetAvailableQuantity(OS,'4P00000101', mRowBO.GetFieldValueAsString('StoreCard_ID'))//sklad VO
                      -NxEvalObjectExprAsFloatDef(mRowBO,'NxGetReservedQuantity('+Quotedstr(mRowBO.GetFieldValueAsString('StoreCard_ID'))+','+QuotedStr('4P00000101')+')',0);
                      NxScriptingLog.WriteEvent(logInfo,mRowBO.GetFieldValueAsString('StoreCard_ID.code')+' '+
                                                  mRowBO.GetFieldValueAsString('StoreCard_ID.Name')+#13#10+
                                                 'mQuantity05 '+FloatToStr(mQuantity05)+#13#10+
                                                 'mQuantityMO '+FloatToStr(mQuantityMO)+#13#10+
                                                 'mQuantityLogStore '+FloatToStr(mQuantityLogStore)+#13#10+
                                                 'bez rezervace '+FloatToStr(GetAvailableQuantity(OS,'4P00000101', mRowBO.GetFieldValueAsString('StoreCard_ID')))+#13#10+
                                                 'rezervace '+FloatToStr(NxEvalObjectExprAsFloatDef(mRowBO,'NxGetReservedQuantity('+Quotedstr(mRowBO.GetFieldValueAsString('StoreCard_ID'))+','+QuotedStr('4P00000101')+')',0)));
                      {CFxLog.SaveLog(NxCreateContext_1(mRowBO),'ERR',mOrderBO.DisplayName,mRowBO.GetFieldValueAsString('StoreCard_ID.code')+' '+
                                                                                          mRowBO.GetFieldValueAsString('StoreCard_ID.Name')+#13#10+
                                                                                         'mQuantity05 '+FloatToStr(mQuantity05)+#13#10+
                                                                                         'mQuantityMO '+FloatToStr(mQuantityMO)+#13#10+
                                                                                         'mQuantityLogStore '+FloatToStr(mQuantityLogStore)+#13#10+
                                                                                         'bez rezervace '+FloatToStr(GetAvailableQuantity(OS,'1L00000101', mRowBO.GetFieldValueAsString('StoreCard_ID')))+#13#10+
                                                                                         'rezervace '+FloatToStr(NxEvalObjectExprAsFloatDef(mRowBO,'NxGetReservedQuantity('+Quotedstr(mRowBO.GetFieldValueAsString('StoreCard_ID'))+','+QuotedStr('1L00000101')+')',0))
                                                                                         ,2,now);}
                      if ((mQuantity05+mQuantityMO+mQuantityLogStore)>0)  and ((mRowQ-mQuantity)<=(mQuantity05+mQuantityMO+mQuantityLogStore)) then begin
                         mDodano:=0;
                         mNextStore:=True;
                       if (mQuantityLogStore>0) and (mRowQ-mQuantity-mDodano>0) and mNextStore then begin
                            if mQuantityLogStore>=(mRowQ-mDodano) then begin
                                 mLogisticStoreList.add('4P00000101'+';'+mRowBO.GetFieldValueAsString('StoreCard_ID')+';'+FloatToStr(mRowQ-mQuantity-mDodano));
                                 mNextStore:=false;
                                 mDodano:=mDodano+(mRowQ-mDodano);
                            end else begin
                                 mLogisticStoreList.add('4P00000101'+';'+mRowBO.GetFieldValueAsString('StoreCard_ID')+';'+FloatToStr(mQuantityLogStore));
                                 mNextStore:=True;
                                 mDodano:=mDodano+mQuantityLogStore;
                            end;
                           NxScriptingLog.WriteEvent(logInfo,'Dodáno :'+FloatToStr(mDodano)+'       4P00000101');
                       end;
                       if (mQuantity05>0) and (mRowQ-mQuantity-mDodano>0) and mNextStore then begin
                            if mQuantity05>=(mRowQ-mDodano) then begin
                                 mNotLogisticStoreList.add('2D00000101'+';'+mRowBO.GetFieldValueAsString('StoreCard_ID')+';'+FloatToStr(mRowQ-mQuantity-mDodano));
                                 mNextStore:=false;
                                 mDodano:=mDodano+(mRowQ-mDodano);
                            end else begin
                                 mNotLogisticStoreList.add('2D00000101'+';'+mRowBO.GetFieldValueAsString('StoreCard_ID')+';'+FloatToStr(mQuantity05));
                                 mNextStore:=True;
                                 mDodano:=mDodano+mQuantity05;
                            end;
                           NxScriptingLog.WriteEvent(logInfo,'Dodáno :'+FloatToStr(mDodano)+'       2D00000101');
                         end;
                         if (mQuantityMO>0) and (mRowQ-mQuantity-mDodano>0) and mNextStore then begin
                            if mQuantityMO>=(mRowQ-mDodano) then begin
                                 mNotLogisticStoreList.add('1E00000101'+';'+mRowBO.GetFieldValueAsString('StoreCard_ID')+';'+FloatToStr(mRowQ-mQuantity-mDodano));
                                 mNextStore:=false;
                                 mDodano:=mDodano+(mRowQ-mDodano);
                            end else begin
                                 mNotLogisticStoreList.add('1E00000101'+';'+mRowBO.GetFieldValueAsString('StoreCard_ID')+';'+FloatToStr(mQuantityMO));
                                 mNextStore:=True;
                                 mDodano:=mDodano+mQuantityMO;
                            end;
                            NxScriptingLog.WriteEvent(logInfo,'Dodáno :'+FloatToStr(mDodano)+'       1E00000101');
                         end;
                      end;
                   end;
                end;
              end;
           end;
           if mNotLogisticStoreList.count>0 then begin
              try
               mNotLogisticStoreList.SaveToFile('f:\logy\OutgoingTransfers\'+NxSearchReplace(self.DisplayName,'/','-',[srAll])+'_nonlog.txt');
              Except
               NxScriptingLog.WriteEvent(logInfo,'chyba řádek 99'+#13#10+ExceptionMessage);
              end;
              mResult:=mResult+#13#10+'Výdej z nepolohovaných skladu '+self.DisplayName;
              for k:=0 to mNotLogisticStoreList.Count-1 do begin
                mResult:=mResult+#13#10+mNotLogisticStoreList.Strings[k];
              end;
              mResult:=mResult+#13#10+CreateTransfer(OS,self,mNotLogisticStoreList,'6RB0000101',mDestinationStore_ID, mDivision_ID, False);
            end;
            if mLogisticStoreList.count>0 then begin
              mResult:=mResult+#13#10+'Výdej z polohovaného skladu '+self.DisplayName;
              try
               mLogisticStoreList.SaveToFile('f:\logy\OutgoingTransfers\'+NxSearchReplace(self.DisplayName,'/','-',[srAll])+'_log.txt');
              except
                NxScriptingLog.WriteEvent(logInfo,'chyba řádek 112'+#13#10+ExceptionMessage);
              end;
              for k:=0 to mLogisticStoreList.Count-1 do begin
                mResult:=mResult+#13#10+mLogisticStoreList.Strings[k];
              end;
              mResult:=mResult+#13#10+CreateTransfer(OS,self,mLogisticStoreList,'Z200000101',mDestinationStore_ID, mDivision_ID, True);
            end;
     NxScriptingLog.WriteEvent(logInfo,'Výsledek: '+#13#10+mResult);
     NxScriptingLog.LeaveSection('Převodka výdej',logInfo);
    Except
      NxScriptingLog.WriteEvent(logInfo,'Chyba mResult:'+#13#10+mResult+#13#10+ExceptionMessage);
      NxScriptingLog.LeaveSection('Převodka výdej',logInfo);
    end;
 end;

 except

 end;


end;

{
Vyvolává se bezprostředně před provedením softvalidace objektu.
}
procedure BeforeSoftValidate_Hook(Self: TNxCustomBusinessObject);
begin
  if (osnew in self.state) and (self.GetFieldValueAsString('DocQueue_ID')='1W10000101') then self.SetFieldValueAsInteger('TotalRounding',257);
end;

function GetAvailableQuantity(AOS : TNxCustomObjectSpace; aStore_ID, aStoreCard_ID : string) : Extended;
const
  cSQL = 'SELECT Sum(Quantity-Bookedquantity) FROM StoreSubCards WHERE Store_ID=''%s'' and StoreCard_ID=''%s'' ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    AOS.SQLSelect(Format(cSQL, [aStore_ID, aStoreCard_ID]), mList);
    if mList.Count > 0 then
      Result := NxIBStrToFloat(mList.Strings[0])
      else Result:=0;
  finally
    mList.Free;
  end;
end;
function GetQuantity(AOS : TNxCustomObjectSpace; aStore_ID, aStoreCard_ID : string) : Extended;
const
  cSQL = 'SELECT Sum(Quantity) FROM StoreSubCards WHERE Store_ID=''%s'' and StoreCard_ID=''%s'' ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    AOS.SQLSelect(Format(cSQL, [aStore_ID, aStoreCard_ID]), mList);
    if mList.Count > 0 then
      Result := NxIBStrToFloat(mList.Strings[0])
      else Result:=0;
  finally
    mList.Free;
  end;
end;

function GetOrderedQuantity(AOS : TNxCustomObjectSpace; aStoreCard_ID, ARow_ID, aStore_ID : string; ADate: Extended) : Extended;
const
  DecimalSeparator= '.';
  cSQL = 'SELECT SUM(Quantity-deliveredQuantity) FROM ReceivedOrders2 RO2 LEFT JOIN ReceivedOrders RO ON RO.ID = RO2.Parent_ID '+
          'WHERE RO.Confirmed = ''A'' and RO.Closed = ''N'' and RO2.StoreCard_ID = ''%s'' and RO2.ID <> ''%s'' and RO2.Store_ID = ''%s'' and CreatedAt$Date < %s  ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    AOS.SQLSelect(Format(cSQL, [aStoreCard_ID, ARow_ID, aStore_ID ,NxFloatToIBStr(ADate)]), mList);
    if mList.Count > 0 then
      Result := NxIBStrToFloat(mList.Strings[0])
      else Result:=0;
  finally
    mList.Free;
  end;
end;

function CreateTransfer(var AOS:TNxCustomObjectSpace; var aOrderBO:TNxCustomBusinessObject;
           var aList:TStringList;var aDocQueue_ID, aDestStore_ID, aDivision_ID:string;var aCreateVPZ:Boolean):String;
var
 mOTBO, mOTRowBO, mUserXLink, mTempBO:TNxCustomBusinessObject;
 i,j:Integer;
 mRelation_ID:string;
 mRows:TNxCustomBusinessMonikerCollection;
 mStore_ID, mStoreCard_ID, mTempStr, mITPMState_ID:string;
 mQuantity:Extended;
 mOTList:TStringList;
 mMessage, mVPZ_ID:string;
 mImportMan:TNxDocumentImportManager;
 mInputParams : TNxParameters;
 mParam: TNxParameter;
begin
  mMessage:='';
  mRelation_ID:=''; //převody pro eshop, dělají se jen při osNew
  if NxIsEmptyOID(mRelation_ID) then begin
      mOTBO:=aos.CreateObject(Class_OutgoingTransfer);
      mOTBO.New;
      mOTBO.prefill;
      mOTBO.SetFieldValueAsString('DocQueue_ID',aDocQueue_ID);
      mOTBO.SetFieldValueAsString('Firm_ID',aOrderBO.GetFieldValueAsString('Firm_ID'));
      mOTBO.SetFieldValueAsString('Description',aOrderBO.DisplayName);
      mOTBO.SetFieldValueAsString('U_DestinationStore',aDestStore_ID);
      mRows:=mOTBO.GetLoadedCollectionMonikerForFieldCode(mOTBO.GetFieldCode('Rows'));
      for i:=0 to aList.count-1 do begin
        mTempStr:=aList.Strings[i];
        mStore_ID:=NxTrapStrTrim(mTempStr,';');
        mStoreCard_ID:=NxTrapStrTrim(mTempStr,';');
        mQuantity:=NxIBStrToFloat(NxTrapStrTrim(mTempStr,';'));
        mOTRowBO:=mRows.AddNewObject;
        mOTRowBO.Prefill;
        mOTRowBO.SetFieldValueAsInteger('RowType',3);
        mOTRowBO.SetFieldValueAsString('Store_ID',mStore_ID);
        mOTRowBO.SetFieldValueAsString('StoreCard_ID',mStoreCard_ID);
        mOTRowBO.SetFieldValueAsString('Division_ID',aDivision_ID);
        mOTRowBO.SetFieldValueAsFloat('Quantity',mQuantity);
      end;
      mOTBO.save;
      if aCreateVPZ then begin
         mVPZ_ID:=AOS.SQLSelectFirstAsString('Select id from logstoredocuments where storedocument_id='+Quotedstr(mOTBO.OID),'');
          if NxIsEmptyOID(mVPZ_ID) then begin
              try
                mInputParams := TNxParameters.Create;
                mParam := mInputParams.GetOrCreateParam(dtString, 'StoreGateWay_ID');
                mParam.AsString := cStoreGateWay_ID;
                mParam := mInputParams.GetOrCreateParam(dtString,'DocQueue_ID');
                mParam.AsString := cLogStoreDocQueue_ID;
                mParam := mInputParams.GetOrCreateParam(dtString, 'SelectedHeader');
                mParam.AsString := mOTBO.OID;
                mParam := mInputParams.GetOrCreateParam(dtBoolean, 'AutoPrefillPosition');
                mParam.AsBoolean := True;
                mParam := mInputParams.GetOrCreateParam(dtInteger, 'PrefillType');
                mParam.AsInteger := 0;
                mImportMan := NxCreateDocumentImportManager(AOS, Class_OutgoingTransfer, Class_LogStoreOutput);
                mImportMan.AddInputDocument(mOTBO.oid);
                mImportMan.LoadParams(mInputParams);
                mImportMan.Execute;
                mImportMan.OutputDocument.Save;
                mImportMan.free;
              except
                mMessage:=mMessage+#13#10+ExceptionMessage;
                //NxShowSimpleMessage(ExceptionMessage,nil);
              end;
         end;
      end;
      mUserXLink := AOS.CreateObject(Class_UserXLink);
      try
        mUserXLink.New;
        mUserXLink.Prefill;
        mUserXLink.SetFieldValueAsString('SourceCLSID', Class_ReceivedOrder);
        mUserXLink.SetFieldValueAsString('Source_ID', aOrderBO.OID);
        mUserXLink.SetFieldValueAsString('DestinationCLSID', Class_OutgoingTransfer);
        mUserXLink.SetFieldValueAsString('Destination_ID', mOTBO.OID);
        mUserXLink.SetFieldValueAsBoolean('DisplayAsSystem', True);
        mUserXLink.SetFieldValueAsString('Description','Převodka pro objednávku '+aOrderBO.DisplayName);
        mUserXLink.Save;
      finally
        mUserXLink.Free;
      end;
    mMessage:=mMessage+#13#10+'Nová '+mOTBO.DisplayName;
  end;
  Result:=mMessage;
end;


begin
end.