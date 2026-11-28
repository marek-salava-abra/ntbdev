uses 'eu.untraco.tris.doc';
procedure QueueIN(OS: TNxCustomObjectSpace; var ProcessContinue: Boolean; Directory: string; FileName: string);
var
 mXMLHead:TNxScriptingXMLWrapper;
 i,j,k:integer;
 mDocCode, mOrdNumber, mPeriodCode, mKodObjednavky, mIssuedOrder_ID, RCDocQueue_ID, mStore_ID:string;
 mIssuedOrderBO, mIORowBO,mRowBO, mRCBO, mTempBO:TNxCustomBusinessObject;
 mRows:TNxCustomBusinessMonikerCollection;
 mConfirmedQuantity:Extended;
 mImportMan: TNxDocumentImportManager;
 mInputParams: TNxParameters;
 mParam: TNxParameter;
 mCislo:string;
 mBool, mStoreCardNotFound:Boolean;
 mStoreDoc_ID,mSarzeString, mDate:string;
 mStoreDocBO, mStoreDocRowBO:TNxCustomBusinessObject;
 mFirm_ID, mFirmOffice_ID, mDoc_ID:string;
 mReceivedOrder_ID, mOutGoingTransfer_ID, mIncomingStore_ID, mIncomingTransfer_ID, mTempCode, mStoreCardCode, mStoreCard_ID:string;
 mReceivedOrderBO:TNxCustomBusinessObject;
 mTempList:TStringList;
begin
  mXMLHead := TNxScriptingXMLWrapper.Create;
  mXMLHead.loadFromFile(Directory+'\'+filename);
  mKodObjednavky:=mXMLHead.getElementAsString('KOD_OBJEDNAVKY');
  mTempCode:=mKodObjednavky;
  if AnsiLeftStr(mKodObjednavky,3)='INP' then begin
    mDocCode:=NxTrapStr(mKodObjednavky,'-');
    mOrdNumber:=NxTrapStr(mKodObjednavky,'/');
    mPeriodCode:=NxTrim(mKodObjednavky,';');
    mStoreDoc_ID:=GetStoreDoc_ID(OS,mDocCode,mOrdNumber,mPeriodCode,'25');
    if not(NxIsEmptyOID(mStoreDoc_ID)) then begin
       try
        mBool:=False;
        mStoreDocBO:=OS.CreateObject(Class_InventoryOverplus);
        mStoreDocBO.Load(mStoreDoc_ID,nil);
        mRows:=mStoreDocBO.GetLoadedCollectionMonikerForFieldCode(mStoreDocBO.GetFieldCode('Rows'));
        for i:=0 to mXMLHead.getElementsCountInArray('POLOZKY.POLOZKA')-1 do begin
          mConfirmedQuantity:=NxIBStrToFloat(mXMLHead.getElementAsString('POLOZKY.POLOZKA['+IntToStr(i)+'].MNOZSTVI'));
          for j:=0 to mRows.Count-1 do begin
            mStoreDocRowBO:=mRows.BusinessObject[j];
            //if mIORowBO.GetFieldValueAsInteger('RowType')=3 then begin
              if mStoreDocRowBO.GetFieldValueAsString('StoreCard_ID.Code')=mXMLHead.getElementAsString('POLOZKY.POLOZKA['+IntToStr(i)+'].ID_POLOZKY') then
                  mStoreDocRowBO.SetFieldValueAsFloat('X_ConfirmedQuantity',mConfirmedQuantity);

            end;
          //end;
        end;
          for j:=0 to mRows.Count-1 do begin
          mStoreDocRowBO:=mRows.BusinessObject[j];
            if not(mBool) then begin
              if not(mStoreDocRowBO.GetFieldValueAsFloat('UnitQuantity')=mStoreDocRowBO.GetFieldValueAsFloat('X_ConfirmedQuantity')) then mBool:=True;
            end;
          end;
        if mBool then mStoreDocBO.SetFieldValueAsInteger('X_TrisState',3) else mStoreDocBO.SetFieldValueAsInteger('X_TrisState',2);
        mStoreDocBO.save;

       Except
       end;
    end;
  end;
  if AnsiLeftStr(mKodObjednavky,2)='VR' then begin
    mDocCode:=NxTrapStr(mKodObjednavky,'-');
    mOrdNumber:=NxTrapStr(mKodObjednavky,'/');
    mPeriodCode:=NxTrim(mKodObjednavky,';');
    mStoreDoc_ID:=GetStoreDoc_ID(OS,mDocCode,mOrdNumber,mPeriodCode,'23');
    if not(NxIsEmptyOID(mStoreDoc_ID)) then begin
       try
        mBool:=False;
        mStoreDocBO:=OS.CreateObject(Class_RefundedBillOfDelivery);
        mStoreDocBO.Load(mStoreDoc_ID,nil);
        mRows:=mStoreDocBO.GetLoadedCollectionMonikerForFieldCode(mStoreDocBO.GetFieldCode('Rows'));
        for i:=0 to mXMLHead.getElementsCountInArray('POLOZKY.POLOZKA')-1 do begin
          mConfirmedQuantity:=NxIBStrToFloat(mXMLHead.getElementAsString('POLOZKY.POLOZKA['+IntToStr(i)+'].MNOZSTVI'));
          for j:=0 to mRows.Count-1 do begin
            mStoreDocRowBO:=mRows.BusinessObject[j];
            //if mIORowBO.GetFieldValueAsInteger('RowType')=3 then begin
              if mStoreDocRowBO.GetFieldValueAsString('StoreCard_ID.Code')=mXMLHead.getElementAsString('POLOZKY.POLOZKA['+IntToStr(i)+'].ID_POLOZKY') then
                  mStoreDocRowBO.SetFieldValueAsFloat('X_ConfirmedQuantity',mConfirmedQuantity);

            end;
          //end;
        end;
          for j:=0 to mRows.Count-1 do begin
          mStoreDocRowBO:=mRows.BusinessObject[j];
            if not(mBool) then begin
              if not(mStoreDocRowBO.GetFieldValueAsFloat('UnitQuantity')=mStoreDocRowBO.GetFieldValueAsFloat('X_ConfirmedQuantity')) then mBool:=True;
            end;
          end;
        if mBool then mStoreDocBO.SetFieldValueAsInteger('X_TrisState',3) else mStoreDocBO.SetFieldValueAsInteger('X_TrisState',2);
        mStoreDocBO.save;

       Except
       end;
    end;
  end;
  if AnsiLeftStr(mKodObjednavky,2)='OV' then begin
    mDocCode:=NxTrapStr(mKodObjednavky,'-');
    mOrdNumber:=NxTrapStr(mKodObjednavky,'/');
    mPeriodCode:=NxTrim(mKodObjednavky,';');
    mIssuedOrder_ID:=GetIssuedOrder_ID(OS,mDocCode,mOrdNumber,mPeriodCode);
    if not(NxIsEmptyOID(mIssuedOrder_ID)) then begin
        Try
        mStore_ID:='';
        mBool:=False;
        mIssuedOrderBO:=os.CreateObject(Class_IssuedOrder);
        mIssuedOrderBO.Load(mIssuedOrder_ID,nil);
        mIssuedOrderBO.SetFieldValueAsString('X_Cislo_Prijemky',mXMLHead.getElementAsString('CISLO_PRIJEMKY'));
        mCislo:=mXMLHead.getElementAsString('CISLO_PRIJEMKY');
        mRows:=mIssuedOrderBO.GetLoadedCollectionMonikerForFieldCode(mIssuedOrderBO.GetFieldCode('Rows'));
        for i:=0 to mXMLHead.getElementsCountInArray('POLOZKY.POLOZKA')-1 do begin
          mConfirmedQuantity:=NxIBStrToFloat(mXMLHead.getElementAsString('POLOZKY.POLOZKA['+IntToStr(i)+'].MNOZSTVI'));
          for j:=0 to mRows.Count-1 do begin
            mIORowBO:=mRows.BusinessObject[j];
            if mIORowBO.GetFieldValueAsInteger('RowType')=3 then begin
              if NxIsEmptyOID(mStore_ID) then mStore_ID:=mIORowBO.GetFieldValueAsString('Store_ID');
              if mIORowBO.GetFieldValueAsString('StoreCard_ID.Code')=mXMLHead.getElementAsString('POLOZKY.POLOZKA['+IntToStr(i)+'].ID_POLOZKY') then begin
                  mIORowBO.SetFieldValueAsFloat('X_ConfirmedQuantity',mConfirmedQuantity);
                  mTempList:=tstringlist.Create;
                  os.SQLSelect(format('select Source_ID from ReceivedOrdersToIssuedOrders where target_id=''%s'' and targetheader_id=''%s'' ',[mIORowBO.oid, mIssuedOrderBO.OID]),mTempList);
                  if mTempList.count>0 then begin
                    mTempBO:=os.CreateObject(Class_ReceivedOrderRow);
                    mtempbo.Load(mTempList.Strings[0],nil);
                    if mTempBO.GetFieldValueAsFloat('X_ConfirmedQuantity')=0 then begin
                     mTempBO.SetFieldValueAsFloat('X_ConfirmedQuantity',mConfirmedQuantity);
                     mTempBO.save;
                    end;
                    mTempBO.free;
                  end;
                  mtemplist.Free;
              end;
                  if  ElementExists(mXMLHead, 'POLOZKY.POLOZKA['+IntToStr(i)+'].VLASTNOSTI.SARZE.SARZE_KOD') then begin
                   mSarzeString:='';
                   for k:=0 to mXMLHead.getElementsCountInArray('POLOZKY.POLOZKA['+IntToStr(i)+'].VLASTNOSTI.SARZE')-1 do begin
                     mDate:=AnsiRightStr(mXMLHead.getElementAsString('POLOZKY.POLOZKA['+IntToStr(i)+'].VLASTNOSTI.EXPIRACE['+IntToStr(0)+'].EXPIRACE_KOD'),2)+'.'+
                            AnsiLeftStr(AnsiRightStr(mXMLHead.getElementAsString('POLOZKY.POLOZKA['+IntToStr(i)+'].VLASTNOSTI.EXPIRACE['+IntToStr(0)+'].EXPIRACE_KOD'),4),2)+'.'+
                            AnsiLeftStr(mXMLHead.getElementAsString('POLOZKY.POLOZKA['+IntToStr(i)+'].VLASTNOSTI.EXPIRACE['+IntToStr(0)+'].EXPIRACE_KOD'),4);
                     if k=0 then mSarzeString:=mXMLHead.getElementAsString('POLOZKY.POLOZKA['+IntToStr(i)+'].VLASTNOSTI.SARZE['+IntToStr(k)+'].SARZE_KOD')+';'+mDate else
                       mSarzeString:=mSarzeString+#13#10+mXMLHead.getElementAsString('POLOZKY.POLOZKA['+IntToStr(i)+'].VLASTNOSTI.SARZE['+IntToStr(k)+'].SARZE_KOD')+';'+mDate;

                   end;
                  mIORowBO.SetFieldValueAsString('X_Note',mSarzeString);
                end;

            end;
          end;
        end;
          for j:=0 to mRows.Count-1 do begin
          mIORowBO:=mRows.BusinessObject[j];
            if not(mBool) then begin
              if not(mIORowBO.GetFieldValueAsFloat('UnitQuantity')=mIORowBO.GetFieldValueAsFloat('X_ConfirmedQuantity')) then mBool:=True;
            end;
          end;
        if mBool then mIssuedOrderBO.SetFieldValueAsInteger('X_TrisState',3) else mIssuedOrderBO.SetFieldValueAsInteger('X_TrisState',2);
        mIssuedOrderBO.save;
        //NxShowSimpleMessage(mStore_ID,nil);
        RCDocQueue_ID:=GetDocQueue_ID(OS,'20',mStore_ID);

        //mIssuedOrderBO.Free;
        try
            mFirm_ID:=mIssuedOrderBO.GetFieldValueAsString('Firm_ID');
            mFirmOffice_ID:=mIssuedOrderBO.GetFieldValueAsString('FirmOffice_ID');
            mInputParams := TNxParameters.Create;
            mParam :=  mInputParams.GetOrCreateParam(dtString, 'DocQueue_ID');
            mParam.AsString := RCDocQueue_ID;
            mParam :=  mInputParams.GetOrCreateParam(dtString, 'Firm_ID');
            mParam.AsString := mIssuedOrderBO.GetFieldValueAsString('Firm_ID');
            mParam :=  mInputParams.GetOrCreateParam(dtString, 'Currency_ID');
            mParam.AsString := mIssuedOrderBO.GetFieldValueAsString('Currency_ID');
            mImportMan := NxCreateDocumentImportManager(OS, Class_IssuedOrder, Class_ReceiptCard);
            mImportMan.AddInputDocument(mIssuedOrderBO.OID);
            mImportMan.LoadParams(mInputParams);
            mImportMan.Execute;
            mImportMan.OutputDocument.SetFieldValueAsString('Firm_ID',mIssuedOrderBO.GetFieldValueAsString('Firm_ID'));
            mRows:=mImportMan.OutputDocument.GetLoadedCollectionMonikerForFieldCode(mImportMan.OutputDocument.GetFieldCode('Rows'));
            for j:=0 to mXMLHead.getElementsCountInArray('POLOZKY.POLOZKA')-1 do begin
              mStoreCardNotFound:=True;
              mStoreCardCode:=mXMLHead.getElementAsString('POLOZKY.POLOZKA['+IntToStr(j)+'].ID_POLOZKY');
              for i:=0 to mRows.count-1 do begin
                mRowBO:=mrows.BusinessObject[i];
                if mRowBO.GetFieldValueAsFloat('X_ConfirmedQuantity')>0 then mRowBO.SetFieldValueAsFloat('UnitQuantity',mRowBO.GetFieldValueAsFloat('X_ConfirmedQuantity')) else mRowBO.MarkForDelete;
                if (mStoreCardNotFound) then begin
                  if mRowBO.GetFieldValueAsString('StoreCard_ID.Code')=mStoreCardCode then mStoreCardNotFound:=False
                end;
              end;
              if mStoreCardNotFound then begin
                mStoreCard_ID:=GetStoreCard_ID(OS,mStoreCardCode);
                if not(NxIsEmptyOID(mStoreCard_ID)) then begin
                  mRowBO:=mRows.AddNewObject;
                  mRowBO.Prefill;
                  mRowBO.SetFieldValueAsString('Store_ID', mStore_ID);
                  mRowBO.SetFieldValueAsString('StoreCard_ID', mStoreCard_ID);
                  mRowBO.SetFieldValueAsFloat('Quantity',NxIBStrToFloat(mXMLHead.getElementAsString('POLOZKY.POLOZKA['+IntToStr(j)+'].MNOZSTVI')));
                  mRowBO.SetFieldValueAsString('Division_ID', '1000000101');
                end;
              end
            end;
            if mRows.CountOfNotDeleted>0 then begin
            mImportMan.OutputDocument.SetFieldValueAsString('Description',mIssuedOrderBO.DisplayName);
            mImportMan.OutputDocument.save;
            mDoc_ID:=mImportMan.OutputDocument.OID;
            if FileExists(Directory+'\PDF_DL\'+mCislo+'.pdf') then begin
              CreateDocument(os,mFirm_ID,mFirmOffice_ID,mDoc_ID,Directory+'\PDF_DL\'+mCislo+'.pdf',619);
            end;
            end;
            mImportMan.free;
         Except
          NxShowSimpleMessage(ExceptionMessage,nil);
         end;
        Except

        end;
     end;
  end;
  // transfer

  if not(NxIsBlank(mXMLHead.getElementAsString('SKLAD_CIL'))) and (AnsiLeftStr(mTempcode,2)='OV') then begin
         mDocCode:=NxTrapStr(mTempCode,'-');
         mDocCode:='OP';
         mStore_ID:='';
         mOrdNumber:=NxTrapStr(mTempCode,'/');
         mPeriodCode:=NxTrim(mTempCode,';');
         mReceivedOrder_ID:=GetReceivedOrder_ID(OS,mDocCode,mOrdNumber,mPeriodCode);
         mReceivedOrderBO:=Os.CreateObject(Class_ReceivedOrder);
         mReceivedOrderBO.Load(mReceivedOrder_ID,nil);
         mRows:=mReceivedOrderBO.GetLoadedCollectionMonikerForFieldCode(mReceivedOrderBO.GetFieldCode('Rows'));
         mStore_ID:=mRows.BusinessObject[0].GetFieldValueAsString('Store_ID');
         mOutgoingTransfer_ID:=GetDocQueue_ID(OS,'22',mStore_ID);
         mIncomingStore_ID:=GetStore_ID(OS,mXMLHead.getElementAsString('SKLAD_CIL'));
         mIncomingTransfer_ID:=GetDocQueue_ID(OS,'24',mIncomingStore_ID);
         try
          mFirm_ID:=mReceivedOrderBO.GetFieldValueAsString('Firm_ID');
          mFirmOffice_ID:=mReceivedOrderBO.GetFieldValueAsString('FirmOffice_ID');
          mInputParams := TNxParameters.Create;
          mParam :=  mInputParams.GetOrCreateParam(dtString, 'DocQueue_ID');
          mParam.AsString := mOutgoingTransfer_ID;
          mParam :=  mInputParams.GetOrCreateParam(dtString, 'Firm_ID');
          mParam.AsString := mReceivedOrderBO.GetFieldValueAsString('Firm_ID');
          mImportMan := NxCreateDocumentImportManager(OS, Class_ReceivedOrder, Class_OutgoingTransfer);
          //doplnit kontrolu na řádky bez OV viz OV-736/2026

          mImportMan.AddInputDocument(mReceivedOrderBO.OID);
          mImportMan.LoadParams(mInputParams);
          mImportMan.Execute;
          mImportMan.OutputDocument.SetFieldValueAsString('Firm_ID', mReceivedOrderBO.GetFieldValueAsString('Firm_ID'));
          mImportMan.OutputDocument.SetFieldValueAsString('FirmOffice_ID', mReceivedOrderBO.GetFieldValueAsString('FirmOffice_ID'));
          mRows:=mImportMan.OutputDocument.GetLoadedCollectionMonikerForFieldCode(mImportMan.OutputDocument.GetFieldCode('Rows'));
          for j:=0 to mXMLHead.getElementsCountInArray('POLOZKY.POLOZKA')-1 do begin
              mStoreCardNotFound:=True;
              mStoreCardCode:=mXMLHead.getElementAsString('POLOZKY.POLOZKA['+IntToStr(j)+'].ID_POLOZKY');
              for i:=0 to mRows.count-1 do begin
                mRowBO:=mrows.BusinessObject[i];
                if mRowBO.GetFieldValueAsFloat('X_ConfirmedQuantity')>0 then mRowBO.SetFieldValueAsFloat('UnitQuantity',mRowBO.GetFieldValueAsFloat('X_ConfirmedQuantity')) else mRowBO.MarkForDelete;
                if (mStoreCardNotFound) then begin
                  if mRowBO.GetFieldValueAsString('StoreCard_ID.Code')=mStoreCardCode then mStoreCardNotFound:=False
                end;
              end;
              if mStoreCardNotFound then begin
                mStoreCard_ID:=GetStoreCard_ID(OS,mStoreCardCode);
                if not(NxIsEmptyOID(mStoreCard_ID)) then begin
                  mRowBO:=mRows.AddNewObject;
                  mRowBO.Prefill;
                  mRowBO.SetFieldValueAsString('Store_ID', mStore_ID);
                  mRowBO.SetFieldValueAsString('StoreCard_ID', mStoreCard_ID);
                  mRowBO.SetFieldValueAsFloat('Quantity',NxIBStrToFloat(mXMLHead.getElementAsString('POLOZKY.POLOZKA['+IntToStr(j)+'].MNOZSTVI')));
                  mRowBO.SetFieldValueAsString('Division_ID', '1000000101');
                end;
              end
          end;
          if mRows.CountOfNotDeleted>0 then begin
          mImportMan.OutputDocument.save;
          mDoc_ID:=mImportMan.OutputDocument.OID;
          if FileExists(Directory+'\PDF_DL\'+mCislo+'.pdf') then begin
            CreateDocument(os,mFirm_ID, mFirmOffice_ID,mDoc_ID,Directory+'\PDF_DL\'+mCislo+'.pdf',621);
          end;
          end;
          mImportMan.free;

          mInputParams := TNxParameters.Create;
          mParam :=  mInputParams.GetOrCreateParam(dtString, 'DocQueue_ID');
          mParam.AsString := mIncomingTransfer_ID;
          mParam :=  mInputParams.GetOrCreateParam(dtString, 'Store_ID');
          mParam.AsString := mIncomingStore_ID;
          mParam :=  mInputParams.GetOrCreateParam(dtString, 'Firm_ID');
          mParam.AsString := mFirm_ID;
          mImportMan := NxCreateDocumentImportManager(OS, Class_OutgoingTransfer, Class_IncomingTransfer);
          mImportMan.AddInputDocument(mDoc_ID);
          mImportMan.LoadParams(mInputParams);
          mImportMan.Execute;
          mImportMan.OutputDocument.SetFieldValueAsString('Firm_ID',mFirm_ID);
          mImportMan.OutputDocument.save;
          mImportMan.free;
       Except
        NxShowSimpleMessage(ExceptionMessage,nil);
       end;

      end;


  // end transfer
  ProcessContinue := True;
end;



procedure QueueOUT(OS: TNxCustomObjectSpace; var ProcessContinue: Boolean; Directory: string; FileName: string);
var
 mXMLHead:TNxScriptingXMLWrapper;
 i,j, k, s, t, mT:integer;
 mDocCode, mOrdNumber, mPeriodCode, mKodObjednavky, mReceivedOrder_ID, mDLDocQueue_ID, mStore_ID, mPVDocQueue_ID, mBOD_ID:string;
 mReceivedOrderBO, mRORowBO,mRowBO, mBODBO, mOTFBO, mOTFRowBO, mITFRowBO, mUserXLinkBO:TNxCustomBusinessObject;
 mRows, mSBRows, mITrows, mOTRows:TNxCustomBusinessMonikerCollection;
 mConfirmedQuantity:Extended;
 mImportMan: TNxDocumentImportManager;
 mInputParams: TNxParameters;
 mParam: TNxParameter;
 mCislo, mSadaCode, mSadaQuantity, mTempStr:string;
 mOutgoingTransfer_ID, mIncomingTransfer_ID, mIncomingStore_ID, mITBO_ID, mITBODocQueue_ID:string;
 mOTBO:TNxCustomBusinessObject;
 mBool, mSUKL, mSada:Boolean;
 mStoreDoc_ID, mSarzeString, mDate:string;
 mStoreDocBO, mStoreDocRowBO, mSBRowBO:TNxCustomBusinessObject;
 mFirm_ID, mFirmOffice_ID, mDoc_ID, mSadaStoreCard_ID, mSearchString, mOTF_ID:string;
 mTransformationList:TStringList;
 mITFBO:TNxHeaderBusinessObject;
begin
  mXMLHead := TNxScriptingXMLWrapper.Create;
  mXMLHead.loadFromFile(Directory+'\'+filename);
  mKodObjednavky:=mXMLHead.getElementAsString('KOD_OBJEDNAVKY');
  if AnsiLeftStr(mKodObjednavky,3)='INM' then begin
    mDocCode:=NxTrapStr(mKodObjednavky,'-');
    mOrdNumber:=NxTrapStr(mKodObjednavky,'/');
    mPeriodCode:=NxTrim(mKodObjednavky,';');
    mStoreDoc_ID:=GetStoreDoc_ID(OS,mDocCode,mOrdNumber,mPeriodCode,'26');
    if not(NxIsEmptyOID(mStoreDoc_ID)) then begin
       try
        mBool:=False;
        mStoreDocBO:=OS.CreateObject(Class_InventoryShortFall);
        mStoreDocBO.Load(mStoreDoc_ID,nil);
        mRows:=mStoreDocBO.GetLoadedCollectionMonikerForFieldCode(mStoreDocBO.GetFieldCode('Rows'));
        for i:=0 to mXMLHead.getElementsCountInArray('POLOZKY.POLOZKA')-1 do begin
          mConfirmedQuantity:=NxIBStrToFloat(mXMLHead.getElementAsString('POLOZKY.POLOZKA['+IntToStr(i)+'].MNOZSTVI'));
          for j:=0 to mRows.Count-1 do begin
            mStoreDocRowBO:=mRows.BusinessObject[j];
            //if mIORowBO.GetFieldValueAsInteger('RowType')=3 then begin
              if mStoreDocRowBO.GetFieldValueAsString('StoreCard_ID.Code')=mXMLHead.getElementAsString('POLOZKY.POLOZKA['+IntToStr(i)+'].ID_POLOZKY') then
                  mStoreDocRowBO.SetFieldValueAsFloat('X_ConfirmedQuantity',mConfirmedQuantity);

            end;
          //end;
        end;
          for j:=0 to mRows.Count-1 do begin
          mStoreDocRowBO:=mRows.BusinessObject[j];
            if not(mBool) then begin
              if not(mStoreDocRowBO.GetFieldValueAsFloat('UnitQuantity')=mStoreDocRowBO.GetFieldValueAsFloat('X_ConfirmedQuantity')) then mBool:=True;
            end;
          end;
        if mBool then mStoreDocBO.SetFieldValueAsInteger('X_TrisState',3) else mStoreDocBO.SetFieldValueAsInteger('X_TrisState',2);
        mStoreDocBO.save;

       Except
       end;
    end;
  end;
  if AnsiLeftStr(mKodObjednavky,3)='VPR' then begin
    mDocCode:=NxTrapStr(mKodObjednavky,'-');
    mOrdNumber:=NxTrapStr(mKodObjednavky,'/');
    mPeriodCode:=NxTrim(mKodObjednavky,';');
    mStoreDoc_ID:=GetStoreDoc_ID(OS,mDocCode,mOrdNumber,mPeriodCode,'30');
    if not(NxIsEmptyOID(mStoreDoc_ID)) then begin
       try
        mBool:=False;
        mStoreDocBO:=OS.CreateObject(Class_RefundedReceiptCard);
        mStoreDocBO.Load(mStoreDoc_ID,nil);
        mRows:=mStoreDocBO.GetLoadedCollectionMonikerForFieldCode(mStoreDocBO.GetFieldCode('Rows'));
        for i:=0 to mXMLHead.getElementsCountInArray('POLOZKY.POLOZKA')-1 do begin
          mConfirmedQuantity:=NxIBStrToFloat(mXMLHead.getElementAsString('POLOZKY.POLOZKA['+IntToStr(i)+'].MNOZSTVI'));
          for j:=0 to mRows.Count-1 do begin
            mStoreDocRowBO:=mRows.BusinessObject[j];
            //if mIORowBO.GetFieldValueAsInteger('RowType')=3 then begin
              if mStoreDocRowBO.GetFieldValueAsString('StoreCard_ID.Code')=mXMLHead.getElementAsString('POLOZKY.POLOZKA['+IntToStr(i)+'].ID_POLOZKY') then
                  mStoreDocRowBO.SetFieldValueAsFloat('X_ConfirmedQuantity',mConfirmedQuantity);

            end;
          //end;
        end;
          for j:=0 to mRows.Count-1 do begin
          mStoreDocRowBO:=mRows.BusinessObject[j];
            if not(mBool) then begin
              if not(mStoreDocRowBO.GetFieldValueAsFloat('UnitQuantity')=mStoreDocRowBO.GetFieldValueAsFloat('X_ConfirmedQuantity')) then mBool:=True;
            end;
          end;
        if mBool then mStoreDocBO.SetFieldValueAsInteger('X_TrisState',3) else mStoreDocBO.SetFieldValueAsInteger('X_TrisState',2);
        mStoreDocBO.save;

       Except
       end;
    end;
  end;
  if AnsiLeftStr(mKodObjednavky,2)='OP' then begin
  mDocCode:=NxTrapStr(mKodObjednavky,'-');
  mOrdNumber:=NxTrapStr(mKodObjednavky,'/');
  mPeriodCode:=NxTrim(mKodObjednavky,';');
  mReceivedOrder_ID:=GetReceivedOrder_ID(OS,mDocCode,mOrdNumber,mPeriodCode);
  if not(NxIsEmptyOID(mReceivedOrder_ID)) then begin
      Try
      mStore_ID:='';
      mBool:=False;
      mTransformationList:=TStringList.Create;
      mTransformationList.Clear;
      mReceivedOrderBO:=os.CreateObject(Class_ReceivedOrder);
      mReceivedOrderBO.Load(mReceivedOrder_ID,nil);
      mSUKL:=mReceivedOrderBO.GetFieldValueAsBoolean('Firm_ID.U_SUKL');
      mReceivedOrderBO.SetFieldValueAsString('X_Cislo_vydejky',mXMLHead.getElementAsString('CISLO_VYDEJKY'));
      mCislo:=mXMLHead.getElementAsString('CISLO_VYDEJKY');
      if NxIsBlank(mXMLHead.getElementAsString('CISLO_VYDEJKY')) then mCislo:=mXMLHead.getElementAsString('CISLO_PRIJEMKY');
      mRows:=mReceivedOrderBO.GetLoadedCollectionMonikerForFieldCode(mReceivedOrderBO.GetFieldCode('Rows'));
      for i:=0 to mXMLHead.getElementsCountInArray('POLOZKY.POLOZKA')-1 do begin
        mConfirmedQuantity:=NxIBStrToFloat(mXMLHead.getElementAsString('POLOZKY.POLOZKA['+IntToStr(i)+'].MNOZSTVI'));
        for j:=0 to mRows.Count-1 do begin
          mRORowBO:=mRows.BusinessObject[j];
          if mRORowBO.GetFieldValueAsInteger('RowType')=3 then begin
            if NxIsEmptyOID(mStore_ID) then mStore_ID:=mRORowBO.GetFieldValueAsString('Store_ID');
            try
             mSada:=ElementExists(mXMLHead,'POLOZKY.POLOZKA['+IntToStr(i)+'].SADA');
            except
             mSada:=False;
            end;
            if mSada then begin
              if mRORowBO.GetFieldValueAsString('StoreCard_ID.Code')=mXMLHead.getElementAsString('POLOZKY.POLOZKA['+IntToStr(i)+'].SADA') then begin
                mRORowBO.SetFieldValueAsFloat('X_ConfirmedQuantity',mConfirmedQuantity);
                AddToList(mTransformationList,mXMLHead.getElementAsString('POLOZKY.POLOZKA['+IntToStr(i)+'].SADA')+';'+NxFloatToIBStr(mConfirmedQuantity));
              end;
            end else begin
             if mRORowBO.GetFieldValueAsString('StoreCard_ID.Code')=mXMLHead.getElementAsString('POLOZKY.POLOZKA['+IntToStr(i)+'].ID_POLOZKY') then begin
                mRORowBO.SetFieldValueAsFloat('X_ConfirmedQuantity',mConfirmedQuantity);
                if  ElementExists(mXMLHead, 'POLOZKY.POLOZKA['+IntToStr(i)+'].VLASTNOSTI.SARZE.SARZE_KOD') then begin
                   mSarzeString:='';
                   for k:=0 to mXMLHead.getElementsCountInArray('POLOZKY.POLOZKA['+IntToStr(i)+'].VLASTNOSTI.SARZE')-1 do begin
                     mDate:=AnsiRightStr(mXMLHead.getElementAsString('POLOZKY.POLOZKA['+IntToStr(i)+'].VLASTNOSTI.EXPIRACE['+IntToStr(0)+'].EXPIRACE_KOD'),2)+'.'+
                            AnsiLeftStr(AnsiRightStr(mXMLHead.getElementAsString('POLOZKY.POLOZKA['+IntToStr(i)+'].VLASTNOSTI.EXPIRACE['+IntToStr(0)+'].EXPIRACE_KOD'),4),2)+'.'+
                            AnsiLeftStr(mXMLHead.getElementAsString('POLOZKY.POLOZKA['+IntToStr(i)+'].VLASTNOSTI.EXPIRACE['+IntToStr(0)+'].EXPIRACE_KOD'),4);
                     if k=0 then mSarzeString:=mXMLHead.getElementAsString('POLOZKY.POLOZKA['+IntToStr(i)+'].VLASTNOSTI.SARZE['+IntToStr(k)+'].SARZE_KOD')+';'+mDate else
                       mSarzeString:=mSarzeString+#13#10+mXMLHead.getElementAsString('POLOZKY.POLOZKA['+IntToStr(i)+'].VLASTNOSTI.SARZE['+IntToStr(k)+'].SARZE_KOD')+';'+mDate;

                   end;
                  mRORowBO.SetFieldValueAsString('X_Note',mSarzeString);
                end;
             end;
            end;
          end;
        end;
      end;
      for j:=0 to mRows.Count-1 do begin
        mRORowBO:=mRows.BusinessObject[j];
        if not(mBool) then begin
          if not(mRORowBO.GetFieldValueAsFloat('UnitQuantity')=mRORowBO.GetFieldValueAsFloat('X_ConfirmedQuantity')) then mBool:=True;
        end;
      end;
      if mBool then mReceivedOrderBO.SetFieldValueAsInteger('X_TrisState',3) else mReceivedOrderBO.SetFieldValueAsInteger('X_TrisState',2);
      mReceivedOrderBO.save;
      if mTransformationList.count>0 then begin
       for mT:=0 to mTransformationList.Count-1 do begin
         mTempStr:=mTransformationList.Strings[mT];
         mSadaCode:=NxTrapStrTrim(mTempStr,';');
         mSadaQuantity:=NxTrapStrTrim(mTempStr,';');
         mSadaStoreCard_ID:=GetStoreCard_ID(OS, mSadaCode);
         mSearchString:=mSadaStoreCard_ID+mReceivedOrderBO.OID;
         mOTF_ID:=OS.SQLSelectFirstAsString('Select id from storedocuments where X_StoreCardIDReceivedOrderID='+QuotedStr(mSearchString)+
                                            ' and documenttype='+QuotedStr('38'),'');
         if not(NxIsEmptyOID(mSadaStoreCard_ID)) and NxIsEmptyOID(mOTF_ID) then begin
          try
           mOTFBO:=OS.CreateObject(Class_OutgoingTransformation);
           mOTFBO.new;
           mOTFBO.Prefill;
           mOTFBO.SetFieldValueAsString('DocQueue_ID',GetDocQueue_ID(OS,'38',mStore_ID));
           mITBODocQueue_ID:=GetDocQueue_ID(OS,'39',mStore_ID);
           mOTFBO.SetFieldValueAsString('Firm_ID', mReceivedOrderBO.GetFieldValueAsString('Firm_ID'));
           mOTFBO.SetFieldValueAsString('Description', mReceivedOrderBO.DisplayName);
           mOTFBO.SetFieldValueAsString('X_StoreCardIDReceivedOrderID', mSearchString);
           mOTRows:=mOTFBO.GetLoadedCollectionMonikerForFieldCode(mOTFBO.GetFieldCode('Rows'));
           for s:=0 to mXMLHead.getElementsCountInArray('POLOZKY.POLOZKA')-1 do begin
             if mXMLHead.getElementAsString('POLOZKY.POLOZKA['+IntToStr(s)+'].SADA')=mSadaCode then begin
              if not(NxIsEmptyOID(GetStoreCard_ID(OS,mXMLHead.getElementAsString('POLOZKY.POLOZKA['+IntToStr(s)+'].ID_POLOZKY')))) then begin
               mOTFRowBO:=mOTRows.AddNewObject;
               mOTFRowBO.Prefill;
               mOTFRowBO.SetFieldValueAsString('Store_ID',mStore_ID);
               mOTFRowBO.SetFieldValueAsString('StoreCard_ID', GetStoreCard_ID(OS,mXMLHead.getElementAsString('POLOZKY.POLOZKA['+IntToStr(s)+'].ID_POLOZKY')));
               mOTFRowBO.SetFieldValueAsFloat('Quantity', NxIBStrToFloat(mXMLHead.getElementAsString('POLOZKY.POLOZKA['+IntToStr(s)+'].MNOZSTVI')));
               mOTFRowBO.SetFieldValueAsString('Division_ID', '1000000101');
              end;
             end;
           end;
           mOTFBO.Save;
               mInputParams := TNxParameters.Create;
               mParam :=  mInputParams.GetOrCreateParam(dtString, 'DocQueue_ID');
               mParam.AsString := mITBODocQueue_ID;
               mImportMan := NxCreateDocumentImportManager(OS, Class_OutgoingTransformation, Class_IncomingTransformation);
               try
                  mImportMan.AddInputDocument(mOTFBO.OID);
                  mImportMan.LoadParams(mInputParams);
                  mImportMan.Execute;
                  mImportMan.CheckOutputDocument;
                  if Assigned(mImportMan.OutputDocument) then begin
                    mITFBO:=TNxHeaderBusinessObject(mImportMan.OutputDocument);
                    mITFBO.SetFieldValueAsString('DocQueue_ID', mITBODocQueue_ID); // musi byt...
                    mITFBO.SetFieldValueAsInteger('AutoFillRowsPriceTransCoef',3);
                    mITrows:=mITFBO.rows;
                    mITRows.DeleteAll;
                    mITFRowBO:=mITrows.AddNewObject;
                    mITFRowBO.Prefill;
                    mITFRowBO.SetFieldValueAsString('Store_ID',mStore_ID);
                    mITFRowBO.SetFieldValueAsString('StoreCard_ID', GetStoreCard_ID(OS,mSadaCode));
                    mITFRowBO.SetFieldValueAsFloat('Quantity', NxIBStrToFloat(mSadaQuantity));
                    mITFRowBO.SetFieldValueAsString('Division_ID', '1000000101');
                  end;
                  mImportMan.OutputDocument.save;
                  mITBO_ID:=mImportMan.OutputDocument.OID;
                  mImportMan.Free;
                  mUserXLinkBO := OS.CreateObject(Class_UserXLink);
                  try
                    mUserXLinkBO.New;
                    mUserXLinkBO.Prefill;
                    mUserXLinkBO.SetFieldValueAsString('SourceCLSID', Class_ReceivedOrder);
                    mUserXLinkBO.SetFieldValueAsString('Source_ID', mReceivedOrderBO.OID);
                    mUserXLinkBO.SetFieldValueAsString('DestinationCLSID', Class_IncomingTransformation);
                    mUserXLinkBO.SetFieldValueAsString('Destination_ID', mITBO_ID);
                    mUserXLinkBO.SetFieldValueAsBoolean('DisplayAsSystem', True);
                    mUserXLinkBO.SetFieldValueAsString('Description',mReceivedOrderBO.displayname);
                    mUserXLinkBO.Save;
                  finally
                    mUserXLinkBO.Free;
                  end;
               except

               end;


            mUserXLinkBO := OS.CreateObject(Class_UserXLink);
            try
              mUserXLinkBO.New;
              mUserXLinkBO.Prefill;
              mUserXLinkBO.SetFieldValueAsString('SourceCLSID', Class_ReceivedOrder);
              mUserXLinkBO.SetFieldValueAsString('Source_ID', mReceivedOrderBO.OID);
              mUserXLinkBO.SetFieldValueAsString('DestinationCLSID', Class_OutgoingTransformation);
              mUserXLinkBO.SetFieldValueAsString('Destination_ID', mOTFBO.OID);
              mUserXLinkBO.SetFieldValueAsBoolean('DisplayAsSystem', True);
              mUserXLinkBO.SetFieldValueAsString('Description',mReceivedOrderBO.displayname);
              mUserXLinkBO.Save;
            finally
              mUserXLinkBO.Free;
            end;
         except

         end;
        end;
       end;
      end;
      if NxIsBlank(mXMLHead.getElementAsString('SKLAD_CIL')) and not(NxIsEmptyOID(mReceivedOrder_ID)) then begin
       if not(mSUKL) then begin
         // nesukl firmy
         mDLDocQueue_ID:=GetDocQueue_ID(OS,'21',mStore_ID);
         try
          mFirm_ID:=mReceivedOrderBO.GetFieldValueAsString('Firm_ID');
          mFirmOffice_ID:=mReceivedOrderBO.GetFieldValueAsString('FirmOffice_ID');
          mInputParams := TNxParameters.Create;
          mParam :=  mInputParams.GetOrCreateParam(dtString, 'DocQueue_ID');
          mParam.AsString := mdlDocQueue_ID;
          mParam :=  mInputParams.GetOrCreateParam(dtString, 'Firm_ID');
          mParam.AsString := mReceivedOrderBO.GetFieldValueAsString('Firm_ID');
          mImportMan := NxCreateDocumentImportManager(OS, Class_ReceivedOrder, Class_BillOfDelivery);
          mImportMan.AddInputDocument(mReceivedOrderBO.OID);
          mImportMan.LoadParams(mInputParams);
          mImportMan.Execute;
          mImportMan.OutputDocument.SetFieldValueAsString('Firm_ID',mReceivedOrderBO.GetFieldValueAsString('Firm_ID'));
          mImportMan.OutputDocument.SetFieldValueAsString('FirmOffice_ID', mReceivedOrderBO.GetFieldValueAsString('FirmOffice_ID'));
          mImportMan.OutputDocument.SetFieldValueAsString('X_InsuranceCo', mReceivedOrderBO.GetFieldValueAsString('X_InsuranceCo'));
          mRows:=mImportMan.OutputDocument.GetLoadedCollectionMonikerForFieldCode(mImportMan.OutputDocument.GetFieldCode('Rows'));
          for i:=0 to mRows.count-1 do begin
            mRowBO:=mrows.BusinessObject[i];
            mSBRows:=mRowBO.GetLoadedCollectionMonikerForFieldCode(mRowBO.GetFieldCode('SBtoBODs'));
            if mRowBO.GetFieldValueAsFloat('X_ConfirmedQuantity')>0 then begin
             mRowBO.SetFieldValueAsFloat('UnitQuantity',mRowBO.GetFieldValueAsFloat('X_ConfirmedQuantity'));
               for s:=0 to mXMLHead.getElementsCountInArray('POLOZKY.POLOZKA')-1 do begin
                  if mRowBO.GetFieldValueAsString('StoreCard_ID.Code')=mXMLHead.getElementAsString('POLOZKY.POLOZKA['+IntToStr(s)+'].ID_POLOZKY') then begin
                    try
                      for t:=0 to mXMLHead.getElementsCountInArray('POLOZKY.POLOZKA['+IntToStr(s)+'].VLASTNOSTI.EXPIRACE')-1 do begin
                        mSBRowBO:=mSBRows.AddNewObject;
                        mSBRowBO.Prefill;
                        mSBRowBO.SetFieldValueAsString('X_Name', mXMLHead.getElementAsString('POLOZKY.POLOZKA['+IntToStr(s)+'].VLASTNOSTI.EXPIRACE['+IntToStr(t)+'].EXPIRACE_KOD'));
                        mSBRowBO.SetFieldValueAsFloat('X_Quantity', NxIBStrToFloat(mXMLHead.getElementAsString('POLOZKY.POLOZKA['+IntToStr(s)+'].VLASTNOSTI.EXPIRACE['+IntToStr(t)+'].EXPIRACE_KS')));
                        try
                         mDate:=AnsiLeftStr(mXMLHead.getElementAsString('POLOZKY.POLOZKA['+IntToStr(s)+'].VLASTNOSTI.EXPIRACE['+IntToStr(t)+'].EXPIRACE_KOD'),8);
                         mSBRowBO.SetFieldValueAsDateTime('X_ExprationDate$Date', ParseISODate(mDate));
                        except

                        end;
                      end;
                    except
                    end;
                  end;
                end;
             end else mRowBO.MarkForDelete;
          end;
          if mRows.CountOfNotDeleted>0 then begin
          mImportMan.OutputDocument.SetFieldValueAsString('Description',mReceivedOrderBO.DisplayName);
          mImportMan.OutputDocument.save;
          mOTBO:=mImportMan.OutputDocument;
          mDoc_ID:=mImportMan.OutputDocument.OID;
          if FileExists(Directory+'\PDF_DL\'+mCislo+'.pdf') then begin
            CreateDocument(os,mFirm_ID,mFirmOffice_ID,mDoc_ID,Directory+'\PDF_DL\'+mCislo+'.pdf',620);
          end;
          end;
          mImportMan.free;
         Except
         if CFxNxRuntime.NxGetEnvironmentType=reRuntimeExe then
          NxShowSimpleMessage(ExceptionMessage,nil);
         end;
       // konec nesukl firem
       end;
       if mSUKL then begin
         // SUKL firmy
         mDLDocQueue_ID:=GetDocQueue_ID(OS,'21',mStore_ID);
         try
          mFirm_ID:=mReceivedOrderBO.GetFieldValueAsString('Firm_ID');
          mFirmOffice_ID:=mReceivedOrderBO.GetFieldValueAsString('FirmOffice_ID');
          mInputParams := TNxParameters.Create;
          mParam :=  mInputParams.GetOrCreateParam(dtString, 'DocQueue_ID');
          mParam.AsString := mdlDocQueue_ID;
          mParam :=  mInputParams.GetOrCreateParam(dtString, 'Firm_ID');
          mParam.AsString := mReceivedOrderBO.GetFieldValueAsString('Firm_ID');
          mImportMan := NxCreateDocumentImportManager(OS, Class_ReceivedOrder, Class_BillOfDelivery);
          mImportMan.AddInputDocument(mReceivedOrderBO.OID);
          mImportMan.LoadParams(mInputParams);
          mImportMan.Execute;
          mImportMan.OutputDocument.SetFieldValueAsString('Firm_ID',mReceivedOrderBO.GetFieldValueAsString('Firm_ID'));
          mImportMan.OutputDocument.SetFieldValueAsString('FirmOffice_ID', mReceivedOrderBO.GetFieldValueAsString('FirmOffice_ID'));
          mImportMan.OutputDocument.SetFieldValueAsString('X_InsuranceCo', mReceivedOrderBO.GetFieldValueAsString('X_InsuranceCo'));
          mRows:=mImportMan.OutputDocument.GetLoadedCollectionMonikerForFieldCode(mImportMan.OutputDocument.GetFieldCode('Rows'));
          for i:=0 to mRows.count-1 do begin
            mRowBO:=mrows.BusinessObject[i];
            mSBRows:=mRowBO.GetLoadedCollectionMonikerForFieldCode(mRowBO.GetFieldCode('SBtoBODs'));
            if (mRowBO.GetFieldValueAsFloat('X_ConfirmedQuantity')>0) and not(NxIsBlank(mRowBO.GetFieldValueAsString('StoreCard_ID.U_Specification3'))) then begin
              mRowBO.SetFieldValueAsFloat('UnitQuantity',mRowBO.GetFieldValueAsFloat('X_ConfirmedQuantity'));
               for s:=0 to mXMLHead.getElementsCountInArray('POLOZKY.POLOZKA')-1 do begin
                  if mRowBO.GetFieldValueAsString('StoreCard_ID.Code')=mXMLHead.getElementAsString('POLOZKY.POLOZKA['+IntToStr(s)+'].ID_POLOZKY') then begin
                    try
                      for t:=0 to mXMLHead.getElementsCountInArray('POLOZKY.POLOZKA['+IntToStr(s)+'].VLASTNOSTI.EXPIRACE')-1 do begin
                        mSBRowBO:=mSBRows.AddNewObject;
                        mSBRowBO.Prefill;
                        mSBRowBO.SetFieldValueAsString('X_Name', mXMLHead.getElementAsString('POLOZKY.POLOZKA['+IntToStr(s)+'].VLASTNOSTI.EXPIRACE['+IntToStr(t)+'].EXPIRACE_KOD'));
                        mSBRowBO.SetFieldValueAsFloat('X_Quantity', NxIBStrToFloat(mXMLHead.getElementAsString('POLOZKY.POLOZKA['+IntToStr(s)+'].VLASTNOSTI.EXPIRACE['+IntToStr(t)+'].EXPIRACE_KS')));
                        try
                         mDate:=AnsiLeftStr(mXMLHead.getElementAsString('POLOZKY.POLOZKA['+IntToStr(s)+'].VLASTNOSTI.EXPIRACE['+IntToStr(t)+'].EXPIRACE_KOD'),8);
                         mSBRowBO.SetFieldValueAsDateTime('X_ExprationDate$Date', ParseISODate(mDate));
                        except

                        end;
                      end;
                    except
                    end;
                  end;
                end;
              end
              else mRowBO.MarkForDelete;
          end;
          if mRows.CountOfNotDeleted>0 then begin
          mImportMan.OutputDocument.SetFieldValueAsString('Description',mReceivedOrderBO.DisplayName);
          mImportMan.OutputDocument.save;
          mOTBO:=mImportMan.OutputDocument;
          mDoc_ID:=mImportMan.OutputDocument.OID;
          if FileExists(Directory+'\PDF_DL\'+mCislo+'.pdf') then begin
            CreateDocument(os,mFirm_ID,mFirmOffice_ID,mDoc_ID,Directory+'\PDF_DL\'+mCislo+'.pdf',620);
          end;
          end;
          mImportMan.free;
         Except
          if CFxNxRuntime.NxGetEnvironmentType=reRuntimeExe then
            NxShowSimpleMessage(ExceptionMessage,nil);
         end;

         try
          mFirm_ID:=mReceivedOrderBO.GetFieldValueAsString('Firm_ID');
          mFirmOffice_ID:=mReceivedOrderBO.GetFieldValueAsString('FirmOffice_ID');
          mInputParams := TNxParameters.Create;
          mParam :=  mInputParams.GetOrCreateParam(dtString, 'DocQueue_ID');
          mParam.AsString := mdlDocQueue_ID;
          mParam :=  mInputParams.GetOrCreateParam(dtString, 'Firm_ID');
          mParam.AsString := mReceivedOrderBO.GetFieldValueAsString('Firm_ID');
          mImportMan := NxCreateDocumentImportManager(OS, Class_ReceivedOrder, Class_BillOfDelivery);
          mImportMan.AddInputDocument(mReceivedOrderBO.OID);
          mImportMan.LoadParams(mInputParams);
          mImportMan.Execute;
          mImportMan.OutputDocument.SetFieldValueAsString('Firm_ID',mReceivedOrderBO.GetFieldValueAsString('Firm_ID'));
          mImportMan.OutputDocument.SetFieldValueAsString('FirmOffice_ID', mReceivedOrderBO.GetFieldValueAsString('FirmOffice_ID'));
          mImportMan.OutputDocument.SetFieldValueAsString('X_InsuranceCo', mReceivedOrderBO.GetFieldValueAsString('X_InsuranceCo'));
          mRows:=mImportMan.OutputDocument.GetLoadedCollectionMonikerForFieldCode(mImportMan.OutputDocument.GetFieldCode('Rows'));
          for i:=0 to mRows.count-1 do begin
            mRowBO:=mrows.BusinessObject[i];
            mSBRows:=mRowBO.GetLoadedCollectionMonikerForFieldCode(mRowBO.GetFieldCode('SBtoBODs'));
            if (mRowBO.GetFieldValueAsFloat('X_ConfirmedQuantity')>0) and (NxIsBlank(mRowBO.GetFieldValueAsString('StoreCard_ID.U_Specification3'))) then begin
             mRowBO.SetFieldValueAsFloat('UnitQuantity',mRowBO.GetFieldValueAsFloat('X_ConfirmedQuantity'));
                for s:=0 to mXMLHead.getElementsCountInArray('POLOZKY.POLOZKA')-1 do begin
                  if mRowBO.GetFieldValueAsString('StoreCard_ID.Code')=mXMLHead.getElementAsString('POLOZKY.POLOZKA['+IntToStr(s)+'].ID_POLOZKY') then begin
                    try
                      for t:=0 to mXMLHead.getElementsCountInArray('POLOZKY.POLOZKA['+IntToStr(s)+'].VLASTNOSTI.EXPIRACE')-1 do begin
                        mSBRowBO:=mSBRows.AddNewObject;
                        mSBRowBO.Prefill;
                        mSBRowBO.SetFieldValueAsString('X_Name', mXMLHead.getElementAsString('POLOZKY.POLOZKA['+IntToStr(s)+'].VLASTNOSTI.EXPIRACE['+IntToStr(t)+'].EXPIRACE_KOD'));
                        mSBRowBO.SetFieldValueAsFloat('X_Quantity', NxIBStrToFloat(mXMLHead.getElementAsString('POLOZKY.POLOZKA['+IntToStr(s)+'].VLASTNOSTI.EXPIRACE['+IntToStr(t)+'].EXPIRACE_KS')));
                        try
                         mDate:=AnsiLeftStr(mXMLHead.getElementAsString('POLOZKY.POLOZKA['+IntToStr(s)+'].VLASTNOSTI.EXPIRACE['+IntToStr(t)+'].EXPIRACE_KOD'),8);
                         mSBRowBO.SetFieldValueAsDateTime('X_ExprationDate$Date', ParseISODate(mDate));
                        except

                        end;
                      end;
                    except
                    end;
                  end;
                end;

             end else mRowBO.MarkForDelete;

          end;
          if mRows.CountOfNotDeleted>0 then begin
          mImportMan.OutputDocument.SetFieldValueAsString('Description',mReceivedOrderBO.DisplayName);
          mImportMan.OutputDocument.save;
          mOTBO:=mImportMan.OutputDocument;
          mDoc_ID:=mImportMan.OutputDocument.OID;
          if FileExists(Directory+'\PDF_DL\'+mCislo+'.pdf') then begin
            CreateDocument(os,mFirm_ID,mFirmOffice_ID,mDoc_ID,Directory+'\PDF_DL\'+mCislo+'.pdf',620);
          end;
          end;
          mImportMan.free;
         Except
          if CFxNxRuntime.NxGetEnvironmentType=reRuntimeExe then
            NxShowSimpleMessage(ExceptionMessage,nil);
         end;
       // SUKL firmy
       end;


      end;
      if not(NxIsBlank(mXMLHead.getElementAsString('SKLAD_CIL'))) and not(NxIsEmptyOID(mReceivedOrder_ID)) then begin
         mOutgoingTransfer_ID:=GetDocQueue_ID(OS,'22',mStore_ID);
         mIncomingStore_ID:=GetStore_ID(OS,mXMLHead.getElementAsString('SKLAD_CIL'));
         mIncomingTransfer_ID:=GetDocQueue_ID(OS,'24',mIncomingStore_ID);
         try
          mFirm_ID:=mReceivedOrderBO.GetFieldValueAsString('Firm_ID');
          mFirmOffice_ID:=mReceivedOrderBO.GetFieldValueAsString('FirmOffice_ID');
          mInputParams := TNxParameters.Create;
          mParam :=  mInputParams.GetOrCreateParam(dtString, 'DocQueue_ID');
          mParam.AsString := mOutgoingTransfer_ID;
          mParam :=  mInputParams.GetOrCreateParam(dtString, 'Firm_ID');
          mParam.AsString := mReceivedOrderBO.GetFieldValueAsString('Firm_ID');
          mImportMan := NxCreateDocumentImportManager(OS, Class_ReceivedOrder, Class_OutgoingTransfer);
          mImportMan.AddInputDocument(mReceivedOrderBO.OID);
          mImportMan.LoadParams(mInputParams);
          mImportMan.Execute;
          mImportMan.OutputDocument.SetFieldValueAsString('Firm_ID',mReceivedOrderBO.GetFieldValueAsString('Firm_ID'));
          mRows:=mImportMan.OutputDocument.GetLoadedCollectionMonikerForFieldCode(mImportMan.OutputDocument.GetFieldCode('Rows'));
          for i:=0 to mRows.count-1 do begin
            mRowBO:=mrows.BusinessObject[i];
            if mRowBO.GetFieldValueAsFloat('X_ConfirmedQuantity')>0 then mRowBO.SetFieldValueAsFloat('UnitQuantity',mRowBO.GetFieldValueAsFloat('X_ConfirmedQuantity')) else mRowBO.MarkForDelete;
          end;
          if mRows.CountOfNotDeleted>0 then begin
          mImportMan.OutputDocument.save;
          mDoc_ID:=mImportMan.OutputDocument.OID;
          if FileExists(Directory+'\PDF_DL\'+mCislo+'.pdf') then begin
            CreateDocument(os,mFirm_ID, mFirmOffice_ID,mDoc_ID,Directory+'\PDF_DL\'+mCislo+'.pdf',621);
          end;
          end;
          mImportMan.free;

          mInputParams := TNxParameters.Create;
          mParam :=  mInputParams.GetOrCreateParam(dtString, 'DocQueue_ID');
          mParam.AsString := mIncomingTransfer_ID;
          mParam :=  mInputParams.GetOrCreateParam(dtString, 'Store_ID');
          mParam.AsString := mIncomingStore_ID;
          mParam :=  mInputParams.GetOrCreateParam(dtString, 'Firm_ID');
          mParam.AsString := mFirm_ID;
          mImportMan := NxCreateDocumentImportManager(OS, Class_OutgoingTransfer, Class_IncomingTransfer);
          mImportMan.AddInputDocument(mDoc_ID);
          mImportMan.LoadParams(mInputParams);
          mImportMan.Execute;
          mImportMan.OutputDocument.SetFieldValueAsString('Firm_ID',mFirm_ID);
          mImportMan.OutputDocument.save;
          mImportMan.free;
       Except
        NxShowSimpleMessage(ExceptionMessage,nil);
       end;

      end;


      Except

      end;
   end;
  end;
  ProcessContinue := True;
end;




function GetDocQueue_ID(var AOS : TNxCustomObjectSpace;var  aDocumentType, aStore_ID : string) : string;
const
  cSQL = 'select dq.id from storesdocqueues sdq left join docqueues dq on dq.id=sdq.docqueue_id where dq.documenttype=''%s'' and sdq.store_id=''%s'' and dq.hidden=''N'' ';
var
  mList : TStringList;
begin
  mList := TStringList.create;
  try
    AOS.SQLSelect(Format(cSQL, [ aDocumentType, aStore_ID]), mList);
    Result:='';
    if mList.Count > 0 then
      Result := mList.Strings[0]
  finally
    mList.Free;
  end;
end;

function GetIssuedOrder_ID(var AOS : TNxCustomObjectSpace;var  aDocCode, aOrdNumber, aPeriodcode : string) : string;
const
  cSQL = 'SELECT IO.ID FROM IssuedOrders IO left join docqueues DQ on DQ.id=io.DocQueue_id left join periods p on p.id=io.period_id WHERE dq.code=''%s'' and io.ordnumber=%s and p.Code=''%s'' ';
var
  mList : TStringList;
begin
  mList := TStringList.create;
  try
    AOS.SQLSelect(Format(cSQL, [aDocCode, aOrdNumber, aPeriodcode]), mList);
    Result:='';
    if mList.Count > 0 then
      Result := mList.Strings[0]
  finally
    mList.Free;
  end;
end;

function GetReceivedOrder_ID(var AOS : TNxCustomObjectSpace;var  aDocCode, aOrdNumber, aPeriodcode : string) : string;
const
  cSQL = 'SELECT IO.ID FROM ReceivedOrders IO left join docqueues DQ on DQ.id=io.DocQueue_id left join periods p on p.id=io.period_id WHERE dq.code=''%s'' and io.ordnumber=%s and p.Code=''%s'' ';
var
  mList : TStringList;
begin
  mList := TStringList.create;
  try
    AOS.SQLSelect(Format(cSQL, [aDocCode, aOrdNumber, aPeriodcode]), mList);
    Result:='';
    if mList.Count > 0 then
      Result := mList.Strings[0]
  finally
    mList.Free;
  end;
end;

function GetStoreDoc_ID(var AOS : TNxCustomObjectSpace;var  aDocCode, aOrdNumber, aPeriodcode, aDocumentType: string) : string;
const
  cSQL = 'SELECT SD.ID FROM StoreDocuments SD left join docqueues DQ on DQ.id=SD.DocQueue_id left join periods p on p.id=SD.period_id WHERE dq.code=''%s'' and SD.ordnumber=%s and p.Code=''%s'' and sd.documenttype=''%s'' ';
var
  mList : TStringList;
begin
  mList := TStringList.create;
  try
    AOS.SQLSelect(Format(cSQL, [aDocCode, aOrdNumber, aPeriodcode, aDocumentType]), mList);
    Result:='';
    if mList.Count > 0 then
      Result := mList.Strings[0]
  finally
    mList.Free;
  end;
end;

function ElementExists(mHlavicka : TNxScriptingXMLWrapper; AName: string): Boolean;

begin
  try
    if not(mHlavicka.getElementAsString(AName)='') then Result:= True;
  except
    Result:= False;
  end;
end;


function GetStore_ID(var AOS : TNxCustomObjectSpace;var  aCode: string) : string;
const
  cSQL = 'SELECT id from stores WHERE code=''%s'' and hidden=''N'' ';
var
  mList : TStringList;
begin
  mList := TStringList.create;
  try
    AOS.SQLSelect(Format(cSQL, [aCode]), mList);
    Result:='';
    if mList.Count > 0 then
      Result := mList.Strings[0]
  finally
    mList.Free;
  end;
end;

function GetStoreCard_ID(var AOS : TNxCustomObjectSpace;var  aCode: string) : string;
const
  cSQL = 'SELECT id from storecards WHERE code=''%s'' and hidden=''N'' ';
var
  mList : TStringList;
begin
  mList := TStringList.create;
  try
    AOS.SQLSelect(Format(cSQL, [aCode]), mList);
    Result:='';
    if mList.Count > 0 then
      Result := mList.Strings[0]
  finally
    mList.Free;
  end;
end;

function GetSadaCode(const Text: string): string;
var
  P: Integer;
begin
  P := Pos(';', Text);
  if P = 0 then
    Result := Text
  else
    Result := Copy(Text, 1, P - 1);
end;

procedure AddToList(var mList: TStringList;var mInputPair: string);
var
  i: Integer;
  mKlic: string;
begin
  mKlic := GetSadaCode(mInputPair);

  for i := 0 to mList.Count - 1 do
    if GetSadaCode(mList.Strings[i]) = mklic then
      Exit;

  mList.Add(mInputPair);
end;

function ParseISODate(var mStringdate: string): TDateTime;
var
  Year, Month, Day: Integer;
begin
  if Length(mStringdate) < 8 then
    exit;

  if not TryStrToInt(Copy(mStringdate, 1, 4), Year) or
     not TryStrToInt(Copy(mStringdate, 5, 2), Month) or
     not TryStrToInt(Copy(mStringdate, 7, 2), Day) then
    exit;

  try
    Result := EncodeDate(Year, Month, Day);
  except
    Result:=0;
  end;
end;

begin
end.