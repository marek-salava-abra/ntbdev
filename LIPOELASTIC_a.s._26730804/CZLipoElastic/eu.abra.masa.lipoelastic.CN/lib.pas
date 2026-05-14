uses '.dataMatrix';

const
 cICNDocQueue_ID='1B10000101';
 cRBODDocQueue_ID='PA10000101';
 cDestinationStore_ID='1030000101';
 cSQL_X_Aktivni = ' AND X_Aktivni = ''A'' ';


Function POST_CreateCN(AContext: TNxContext; ABody: TJSONSuperObject; APath: String): TJSONSuperObject;
var
 mBO, mRowBO, mFirmBO, mFirmBankAccountBO, mVRRowBO, mVRBO, mIIROWBO, mDRBBO, mPaymentOrderBO, mIIBO:TNxCustomBusinessObject;
 mInvoice_ID, mVR_ID, mFirmBankAccount_ID, mInvoiceRow_ID, mMessage:String;
 mImportMan: TNxDocumentImportManager;
 mRows, mBankRows, mDocRowBatches:TNxCustomBusinessMonikerCollection;
 i,j,k:integer;
 mOS:TNxCustomObjectSpace;
 mInvoiceRowList, mBODRowList, mOtherRowList:TStringList;
 mInputParams:TNxParameters;
 mParam:TNxParameter;
 mICN: TNxIssuedCreditNote;
 mICNDocQueue_ID, mRBODDocQueue_ID, mDestinationStore_ID, mStoreBatch_ID, mDocBatch_ID :string;
 mDivision_ID, mStoreCard_ID, mBusOrder_ID, mBusTransaction_ID, mBusProject_ID, mBillOfDelivery_ID, mBoDRow_ID:string;
 mReclamation:Boolean;
 mReceivedOrderBO, mReceivedOrderRowBO, mBODRowBO:TNxCustomBusinessObject;
 mOrderRows, mPORows:TNxCustomBusinessMonikerCollection;
 mPaymentOrderDocumentBO:TNxCustomBusinessObject;
 mDS: TMemoryDataset;
 mFieldDef: TFieldDef;
 mCompleteOrder: boolean;
 mTempStr, mEOID, mSC_ID, mBatch_ID: string;
 mQuantity: Extended;
begin
 Result := TJSONSuperObject.Create;
 mOS:=AContext.GetObjectSpace;
 mReclamation:=False;
 mDivision_ID:='';
 mBusOrder_ID:='';
 mBusTransaction_ID:='';
 mBusProject_ID:='';
 mInvoice_ID:=mOS.SQLSelectFirstAsString(
  ' SELECT DISTINCT(II.ID) FROM IssuedInvoices II '+
  ' LEFT JOIN Firms F ON F.ID = II.Firm_ID '+
  ' LEFT JOIN Addresses A ON A.ID = F.ElectronicAddress_ID '+
  ' LEFT JOIN IssuedInvoices2 II2 ON II.ID = II2.Parent_ID  '+
  ' LEFT JOIN StoreDocuments2 SD2 ON SD2.ID = II2.ProvideRow_ID '+
  ' LEFT JOIN ReceivedOrders2 RO2 ON RO2.ID = SD2.ProvideRow_ID '+
  ' LEFT JOIN ReceivedOrders RO ON RO2.Parent_ID = RO.ID '+
  ' WHERE RO.ExternalNumber = '+QuotedStr(ABody.S['externalOrderNumber'])+
  ' AND A.Email = '+QuotedStr(ABody.S['email']),'');

  mInvoiceRowList:= TStringList.Create;
  mInvoiceRowList.Sorted:= true;
  mInvoiceRowList.Duplicates:= dupIgnore;

  if not(NxIsEmptyOID(mInvoice_ID)) then begin

    mDS:= TMemoryDataset.Create(nil);
    try
      mOS.SQLSelect2(
        ' SELECT II2.ID AS ID, '+
        ' SC.Code AS StoreCardCode, '+
        ' SC.StoreCardCategory_ID AS SCCategory, '+
        ' II2.Store_ID AS Store_ID, '+
        ' IIF(SB.Name IS NULL, II2.Quantity, DRB.Quantity) AS Quantity, '+
        ' II2.BusOrder_ID as BusOrder_ID, '+
        ' II2.BusTransaction_ID AS BusTransaction_ID, '+
        ' II2.BusProject_ID AS BusProject_ID, '+
        ' SB.ID AS StoreBatch_ID, '+
        ' SB.Name AS StoreBatch, '+
        ' '''' AS DataMatrix, '+
        ' DRB.Quantity AS BatchQuantity, '+
        ' ''N'' AS Complete, '+
        ' 0 AS ToReturn, '+
        ' '''' AS Reason '+
        ' FROM IssuedInvoices2 II2 '+
        ' JOIN StoreCards SC ON SC.ID = II2.StoreCard_ID '+
        ' LEFT JOIN DocRowBatches DRB ON DRB.Parent_ID = II2.ProvideRow_ID '+
        ' LEFT JOIN StoreBatches SB ON SB.ID = DRB.StoreBatch_ID '+
        //' WHERE SC.StoreCardCategory_ID not in (''~00000000G'',''~000000002'') '+
        ' WHERE II2.Parent_ID='+QuotedStr(mInvoice_ID), mDS);

      if mDS.Active then begin
        mDS.First;
        mCompleteOrder:= True;

        //Projdu dataset a porovnám ho s JSON na vracené položky a vracené množství. Pokud se vrací vše označím jako Complete

        while not mDS.Eof do begin
          mDS.Edit;
          for i:= 0 to ABody.A['lines'].Length -1 do begin
            //Pokud existují šarže zkontroluji jestli sedí
            if ABody.A['lines'].O[i].A['batches'].Length > 0 then begin
              for j:= 0 to ABody.A['lines'].O[i].A['batches'].Length -1 do begin
                //Použijeme funkci na dekodování šarže z datamatrix kodu
                mTempStr:= DatamatrixDecodeBatches(mOS, ABody.A['lines'].O[i].A['batches'].O[j].AsString);
                mEOID:= NxTrapStr(mTempStr, ';');
                mStoreCard_ID:= NxTrapStr(mTempStr, ';');
                mBatch_ID:= NxTrapStr(mTempStr, ';');
                mQuantity:= 1;
                mTempStr:= '';
                //OutputDebugString('Batch: '+mBatch_ID);
                //OutputDebugString('ParsedSC: '+mStoreCard_ID);
                //OutputDebugString('SCCode: '+mDS.FieldByName('StoreCardCode').AsString);
                //OutputDebugString('ProductCode: '+AInput.A['lines'].O[i].S['productCode']);
                //OutputDebugString('Batch_ID: '+mds.FieldByName('StoreBatch_ID').AsString);
                //Naleznu šarži a přičtu 1ks do vrácení. šarže se opakuje tolikrát kolikrát se vrací
                {if (mDS.FieldByName('StoreCardCode').AsString = AInput.A['lines'].O[i].S['productCode'])
                  and (mDS.FieldByName('StoreBatch').AsString = AInput.A['lines'].O[i].A['batches'].O[j].AsString) then
                begin }
                if (mDS.FieldByName('StoreCardCode').AsString = ABody.A['lines'].O[i].S['productCode'])
                  and (mDS.FieldByName('StoreBatch_ID').AsString = mBatch_ID) then
                begin
                  OutputDebugString('StoreCard = ProductCode AND Batch_ID = ParsedBatch_ID');
                  mDS.FieldByName('ToReturn').AsFloat:= mDS.FieldByName('ToReturn').AsFloat + 1;
                  mDS.FieldByName('Reason').AsString:= ABody.A['lines'].O[i].S['reason'];
                  mDS.FieldByName('DataMatrix').AsString:= ABody.A['lines'].O[i].A['batches'].O[j].AsString;
                end;
              end;
            end else begin
              if (mDS.FieldByName('StoreCardCode').AsString = ABody.A['lines'].O[i].S['productCode']) then begin
                mDS.FieldByName('ToReturn').AsFloat:= ABody.A['lines'].O[i].D['productQuantity'];
                mDS.FieldByName('Reason').AsString:= ABody.A['lines'].O[i].S['reason'];
              end;
            end;
            if mDS.FieldByName('Quantity').AsFloat = mDS.FieldByName('ToReturn').AsFloat then
              mDS.FieldByName('Complete').AsString:= 'A';


          end;
          if mDS.FieldByName('Reason').AsString = 'R' then
            mReclamation:= true;
          mDS.Post;
          //OutputDebugString('mDS loop');
          mDS.Next;
        end;

        //Projdu znovu dataset abych zkontroloval jestli jsou všechny zbožové řádky kompletní
        mDS.First;
        while not mDS.Eof do begin
          if (mDS.FieldByName('Complete').AsString = 'N') and (not(mDS.FieldByName('SCCategory').AsString in ['~00000000G','~000000002'])) then begin
            mCompleteOrder:= false;
            OutputDebugString('NOT COMPLETE '+mDS.FieldByName('StoreCardCode').AsString);
          end;

          mDS.Next;
        end;
        //Pokud jsou všechny zbožové řádky kompletní, označuji ke vrácení i služby
        if mCompleteOrder then begin
          mDS.First;
          while not mDS.Eof do begin
            mDS.Edit;
            mDS.FieldByName('Complete').AsString:= 'A';
            mDS.FieldByName('ToReturn').AsFloat:= mDS.FieldByName('Quantity').AsFloat;
            mDS.Post;
            mDS.Next;
          end;
        end;
        //Projdu a udělám si seznam vracených řádků
        mDS.First;
        while not mDS.Eof do begin
          if mDS.FieldByName('ToReturn').AsFloat > 0 then begin
            mInvoiceRowList.Add(mDS.FieldByName('ID').AsString);
          end;
          OutputDebugString(
            'ID: '+mDS.FieldByName('ID').AsString + nxCrLf +
            'StoreCardCode: '+mDS.FieldByName('StoreCardCode').AsString + nxCrLf +
            'SCCategory: '+mDS.FieldByName('SCCategory').AsString + nxCrLf +
            'Store_ID: '+mDS.FieldByName('Store_ID').AsString + nxCrLf +
            'Quantity: '+mDS.FieldByName('Quantity').AsString + nxCrLf +
            'BusOrder_ID: '+mDS.FieldByName('BusOrder_ID').AsString + nxCrLf +
            'BusTransaction_ID: '+mDS.FieldByName('BusTransaction_ID').AsString + nxCrLf +
            'BusProject_ID: '+mDS.FieldByName('BusProject_ID').AsString + nxCrLf +
            'StoreBatch_ID: '+mDS.FieldByName('StoreBatch_ID').AsString + nxCrLf +
            'StoreBatch: '+mDS.FieldByName('StoreBatch').AsString + nxCrLf +
            'BatchQuantity: '+mDS.FieldByName('BatchQuantity').AsString + nxCrLf +
            'Complete: '+mDS.FieldByName('Complete').AsString + nxCrLf +
            'ToReturn: '+mDS.FieldByName('ToReturn').AsString
            );
          mDS.Next;
        end;

        //OutputDebugString('Complete: '+NxBoolToLanguage(mCompleteOrder));
        //exit;
      end;
      mBusOrder_ID:= mDS.FieldByName('BusOrder_ID').AsString;
      Result.S['BusOrder_ID']:= mBusOrder_ID;

      if mInvoiceRowList.Count = 0 then begin
        Result.S['Result']:='Vyjímka: Nenalezeny žádné řádky k vrácení';
        exit;
      end;

      mTempStr:= '';

      mImportMan := NxCreateDocumentImportManager(mOS, Class_IssuedInvoice, Class_IssuedCreditNote);
      mDestinationStore_ID:= cDestinationStore_ID;
      mRBODDocQueue_ID:= cRBODDocQueue_ID;
      mICNDocQueue_ID:= cICNDocQueue_ID;
      //mIIROWBO:= mOS.CreateObject(Class_IssuedInvoiceRow);
      //mIIROWBO.Load(mInvoiceRow_ID);

      GetDocQueueIDs(mBusOrder_ID, mDestinationStore_ID, mRBODDocQueue_ID, mICNDocQueue_ID, mReclamation);
      //mIIROWBO.free;
      Try
        mInputParams := TNxParameters.Create;
        mParam := mInputParams.GetOrCreateParam(dtString, 'SelectedRows');
        mParam.AsString := mInvoiceRowList.Text;
        mParam := mInputParams.GetOrCreateParam(dtBoolean, 'DoNotImportChargesSerialNumbers');
        mParam.AsBoolean := True;
        mParam := mInputParams.GetOrCreateParam(dtString, 'DocQueue_ID');
        mParam.AsString := mICNDocQueue_ID;
        mParam := mInputParams.GetOrCreateParam(dtString, 'SelectedHeader');
        mParam.AsString := mInvoice_ID;
        mParam := mInputParams.GetOrCreateParam(dtString, 'StoreDocQueue_ID');
        mParam.AsString := mRBODDocQueue_ID;

        mImportMan.AddInputDocument(mInvoice_ID);
        mImportMan.LoadParams(mInputParams);
        mImportMan.Execute;

        mImportMan.AfterExecuteFromOLE;
        mImportMan.OutputDocument.SetFieldValueAsString('DocQueue_ID',mICNDocQueue_ID);
        mImportMan.OutputDocument.SetFieldValueAsString('StoreDocQueue_ID',mRBODDocQueue_ID);
        mImportMan.OutputDocument.SetFieldValueAsString('Description',ABody.S['externalOrderNumber']);
        mImportMan.OutputDocument.SetFieldValueAsString('ReasonDescription',ABody.S['message']);
        mImportMan.OutputDocument.SetFieldValueAsDateTime('DocDate$DATE', Date);
        mImportMan.OutputDocument.SetFieldValueAsDateTime('DueDate$DATE', Date +1);
        mImportMan.OutputDocument.SetFieldValueAsString('PaymentType_ID', '1900000101'); //Ub
        mImportMan.OutputDocument.SetFieldValueAsString('X_TicketID', ABody.S['ticketId']);
        mImportMan.OutputDocument.SetFieldValueAsString('U_TicketNumber', ABody.S['ticketNumber']);

        //dohledávání a zakládání účtu
        if not(NxIsBlank(ABody.S['bankAccount'])) then begin
          mFirmBankAccount_ID:=mOS.SQLSelectFirstAsString('Select id from FirmBankAccounts where Parent_id='+
                                                         QuotedStr(mImportMan.OutputDocument.GetFieldValueAsString('Firm_ID'))+
                                                         ' and BankAccount='+QuotedStr(ABody.S['bankAccount']),'');
          if NxIsEmptyOID(mFirmBankAccount_ID) then begin
            mFirmBO:=mOS.CreateObject(Class_Firm);
            mFirmBO.Load(mImportMan.OutputDocument.GetFieldValueAsString('Firm_ID'),nil);
            mBankRows:=mFirmBO.GetLoadedCollectionMonikerForFieldCode(mFirmBO.GetFieldCode('Rows'));
            mFirmBankAccountBO:=mBankRows.AddNewObject;
            mFirmBankAccountBO.prefill;
            mFirmBankAccountBO.SetFieldValueAsString('BankAccount',ABody.S['bankAccount']);
            mFirmBankAccount_ID:=mFirmBankAccountBO.OID;
            mFirmBO.save;
            mFirmBO.free;
          end;
          mImportMan.OutputDocument.SetFieldValueAsString('FirmBankAccount_ID',mFirmBankAccount_ID);
        end;
        //konec dohledávání účtu
        //mTempStr:= mTempStr+nxCrLf+ mImportMan.OutputDocument.GetFieldValueAsString('DocQueue_ID.Code');
        //mTempStr:= mTempStr+nxCrLf+ mImportMan.OutputDocument.GetFieldValueAsString('StoreDocQueue_ID.Code');

        mRows:=mImportMan.OutputDocument.GetLoadedCollectionMonikerForFieldCode(mImportMan.OutputDocument.GetFieldCode('Rows'));
        for i:= 0 to mRows.Count -1 do begin
          mRowBO:=mRows.BusinessObject[i];
          for k:= 0 to ABody.A['lines'].Length -1 do begin
            if mRowBO.GetFieldValueAsString('StoreCard_ID.Code')=ABody.A['lines'].O[k].S['productCode'] then begin
              mRowBO.SetFieldValueAsString('Store_ID',mDestinationStore_ID);
              mRowBO.SetFieldValueAsString('X_Duvod_Vraceni', mOS.SQLSelectFirstAsString('Select id from defrolldata where clsid='+QuotedStr('TQZJRHNCDTVOL3T5BO2OHBQZPK')+' and code='+QuotedStr(ABody.A['lines'].O[k].S['reason'])+' and hidden='+QuotedStr('N'),''));
              if ABody.A['lines'].O[k].D['productQuantity']>0 then begin
                mRowBO.SetFieldValueAsFloat('Quantity', ABody.A['lines'].O[k].D['productQuantity']);
              end else begin
                mRowBO.SetFieldValueAsFloat('Quantity',0); //doplnit množství
              end;
              if ABody.A['lines'].O[k].D['price']>0 then
                mRowBO.SetFieldValueAsFloat('UnitPrice',ABody.A['lines'].O[k].D['price']);
              if NxIsEmptyOID(mDivision_ID) then mDivision_ID:=mRowBO.GetFieldValueAsString('Division_ID');
              if NxIsEmptyOID(mBusOrder_ID) then mBusOrder_ID:=mRowBO.GetFieldValueAsString('BusOrder_ID');
              if NxIsEmptyOID(mBusTransaction_ID) then mBusTransaction_ID:=mRowBO.GetFieldValueAsString('BusTransaction_ID');
              if NxIsEmptyOID(mBusProject_ID) then mBusProject_ID:=mRowBO.GetFieldValueAsString('BusProject_ID');
              mRowBO.validate;
            end else begin
              mRowBO.SetFieldValueAsString('Store_ID', mDestinationStore_ID);
            end;
          end;
          mRowBO.SetFieldValueAsString('Store_ID', mDestinationStore_ID);
          //mTempStr:= mTempStr + nxCrLf + mRowBO.GetFieldValueAsString('Store_ID.Code');

        end;
        try
          mImportMan.OutputDocument.save;
          Result.S['IssuedCreditNote']:=mImportMan.OutputDocument.DisplayName;
          Result.I['StatusCode']:=200;
        except
          CFxLog.SaveLog(NxCreateContext(mOS),'LA','Chyba CN',ExceptionMessage,2,Now);
          Result.I['StatusCode']:=404;
          Result.S['IssuedCreditNote']:='';
        end;

        mVR_ID:=mos.SQLSelectFirstAsString('Select provide_id from issuedcreditnotes2 where parent_id='+QuotedStr(mImportMan.OutputDocument.OID),'');
        if not(NxIsEmptyOID(mVR_ID)) then begin
          mVRBO:=mOS.CreateObject(Class_RefundedBillOfDelivery);
          mVRBO.Load(mVR_ID,nil);
          Result.S['StoreDocument']:=mVRBO.DisplayName;
          mRows:=mvrbo.GetLoadedCollectionMonikerForFieldCode(mVRBO.GetFieldCode('Rows'));
          for i:=0 to mRows.count-1 do begin
            mRowBO:=mRows.BusinessObject[i];
            for k:= 0 to ABody.A['lines'].Length -1 do begin
              if mrowbo.GetFieldValueAsString('StoreCard_ID.Code')=ABody.A['lines'].O[k].S['productCode'] then begin
                if ABody.A['lines'].O[k].A['batches'].Length>0 then begin
                  mDocRowBatches:=mRowBO.GetLoadedCollectionMonikerForFieldCode(mRowBO.GetFieldCode('DocRowBatches'));
                  for j:=0 to ABody.A['lines'].O[k].A['batches'].Length-1 do begin
                    mTempStr:= DatamatrixDecodeBatches(mOS, ABody.A['lines'].O[k].A['batches'].O[j].AsString);
                    mEOID:= NxTrapStr(mTempStr, ';');
                    mStoreCard_ID:= NxTrapStr(mTempStr, ';');
                    mBatch_ID:= NxTrapStr(mTempStr, ';');
                    mTempStr:= '';

                    mDS.First;
                    while not(mDS.Eof) do begin
                      if mDS.FieldByName('StoreBatch_ID').AsString = mBatch_ID then begin
                        mDRBBO:= mDocRowBatches.AddNewObject;
                        mDRBBO.SetFieldValueAsString('StoreBatch_ID', mDS.FieldByName('StoreBatch_ID').AsString);
                        mDRBBO.SetFieldValueAsFloat('Quantity', mDS.FieldByName('ToReturn').AsFloat);
                      end;
                      mDS.Next;
                    end;
                  end;
                end;
              end;
            end;
          end;
        end;
        {
        if not(AInput.B['changeGoods']) then begin
          mPaymentOrderBO:=mOS.CreateObject(Class_PaymentOrderRow);
          try
            mPaymentOrderBO.new;
            mPaymentOrderBO.prefill;
            mPaymentOrderBO.SetFieldValueAsFloat('Amount',mImportMan.OutputDocument.GetFieldValueAsFloat('Amount'));
            mPaymentOrderBO.SetFieldValueAsString('Firm_ID',mImportMan.OutputDocument.GetFieldValueAsString('Firm_ID'));
            mpaymentorderbo.SetFieldValueAsString('VarSymbol',mImportMan.OutputDocument.GetFieldValueAsString('VarSymbol'));
            mPaymentOrderBO.SetFieldValueAsString('TargetBankAccount',mImportMan.OutputDocument.GetFieldValueAsString('FirmBankAccount_ID.BankAccount'));
            mpaymentorderBO.SetFieldValueAsDateTime('DueDate$Date',Date+1);
            mPaymentOrderBO.SetFieldValueAsString('BankAccount_ID','3JN0000101');
            mPaymentOrderBO.SetFieldValueAsString('Currency_ID',mImportMan.OutputDocument.GetFieldValueAsString('Currency_ID'));
            mPORows:=mPaymentOrderBO.GetLoadedCollectionMonikerForFieldCode(mPaymentOrderBO.GetFieldCode('PaymentOrderDocuments'));
            mPaymentOrderDocumentBO:=mPORows.AddNewObject;
            mPaymentOrderDocumentBO.SetFieldValueAsString('PDocument_ID',mImportMan.OutputDocument.OID);
            mPaymentOrderDocumentBO.SetFieldValueAsString('PDocumentType','60');
            mPaymentOrderDocumentBO.SetFieldValueAsFloat('Amount',mImportMan.OutputDocument.GetFieldValueAsFloat('Amount'));
            mPaymentOrderBO.save;
          finally
            mPaymentOrderBO.free;
          end;
        end;
        }
        if mReclamation and ABody.B['changeGoods'] then begin
          mReceivedOrderBO:=mOS.CreateObject(Class_ReceivedOrder);
          try
            mReceivedOrderBO.new;
            mReceivedOrderBO.prefill;
            mReceivedOrderBO.SetFieldValueAsString('DocQueue_ID','4762000101');
            mReceivedOrderBO.SetFieldValueAsString('Firm_ID',mImportMan.OutputDocument.GetFieldValueAsString('Firm_ID'));
            mReceivedOrderBO.SetFieldValueAsString('ExternalNumber',ABody.S['externalOrderNumber']);
            mReceivedOrderBO.SetFieldValueAsString('Currency_ID',mImportMan.OutputDocument.GetFieldValueAsString('Currency_ID'));
            mReceivedOrderBO.SetFieldValueAsInteger('TradeType',mImportMan.OutputDocument.GetFieldValueAsInteger('TradeType'));
            mReceivedOrderBO.SetFieldValueAsString('Country_ID',mImportMan.OutputDocument.GetFieldValueAsString('Country_ID'));
            mOrderRows:=mReceivedOrderBO.GetLoadedCollectionMonikerForFieldCode(mReceivedOrderBO.GetFieldCode('Rows'));
            for k:= 0 to ABody.A['lines'].Length -1 do begin
              mStoreCard_ID:=mOS.SQLSelectFirstAsString('Select id from storecards where hidden=''N'' '+cSQL_X_Aktivni+' and code='+QuotedStr(ABody.A['lines'].O[k].S['productCode']),'');
              if not(NxIsEmptyOID(mStoreCard_ID)) then begin
                mReceivedOrderRowBO:=mOrderRows.AddNewObject;
                mReceivedOrderRowBO.SetFieldValueAsInteger('RowType',3);
                mReceivedOrderRowBO.SetFieldValueAsString('Store_ID','1120000101');
                mReceivedOrderRowBO.SetFieldValueAsString('StoreCard_ID',mStoreCard_ID);
                mReceivedOrderRowBO.SetFieldValueAsFloat('Quantity',ABody.A['lines'].O[k].D['productQuantity']);
                mReceivedOrderRowBO.SetFieldValueAsString('Division_ID',mDivision_ID);
                mReceivedOrderRowBO.SetFieldValueAsString('BusOrder_ID',mBusOrder_ID);
                mReceivedOrderRowBO.SetFieldValueAsString('BusTransaction_ID',mBusTransaction_ID);
                mReceivedOrderRowBO.SetFieldValueAsString('BusProject_ID',mBusProject_ID);
              end;
            end;
            mReceivedOrderBO.save;
            mImportMan.OutputDocument.delete;
            Result.S['IssuedCreditNote']:='';
          finally
            mReceivedOrderBO.free;
          end;
        end;
        try
          if mVRBO.NeedSave then mVRBO.save;
        except
          OutputDebugString(ExceptionMessage);
          Result.S['Result']:='Vyjímka:' +ExceptionMessage;
        end;
      finally
        mImportMan.Free;
      end;
    finally
      mDS.Free;
    end;

    Result.S['Result']:='OK';
  end else begin
    Result.I['StatusCode']:=404;
    Result.S['Result']:='Nebyla dohledána faktura';
  end;
  mInvoiceRowList.Free;
end;


procedure GetDocQueueIDs(ABusOrder_ID: String; var ADestinationStore_ID: string; var ARBODDocQueue_ID: String; var AICNDocQueue_ID: String; AReclamation: boolean);
begin
  if not(AReclamation) then begin
    if ABusOrder_ID = '1700000101' then  begin                        // cz eshop
      ADestinationStore_ID:= '1030000101';     //sklad 45
      ARBODDocQueue_ID:= '~000000302';         //řada VXDT
      AICNDocQueue_ID:='1B10000101'            // řada DVT
    end;
    if ABusOrder_ID = '2700000101' then  begin                        // eshop EU
      ADestinationStore_ID:= '1030000101';
      ARBODDocQueue_ID:= '~000000303';
      AICNDocQueue_ID:='2B10000101'
    end;
    if ABusOrder_ID = '3G90000101' then  begin                       // eshop FR
      ADestinationStore_ID:= '1030000101';
      ARBODDocQueue_ID:= '~000000303';
      AICNDocQueue_ID:='2B10000101'
    end;
    if ABusOrder_ID = '2G00000101' then begin                        // eshop ITL
      ADestinationStore_ID:= '1030000101';
      ARBODDocQueue_ID:= '~000000303';
      AICNDocQueue_ID:='2B10000101'
    end;
    if ABusOrder_ID = '1000000S01' then begin                        // eshop SK
      ADestinationStore_ID:= '1030000101';
      ARBODDocQueue_ID:= '~000000303';
      AICNDocQueue_ID:='2B10000101'
    end;
  end else begin
    if ABusOrder_ID = '1700000101' then  begin                        // cz eshop
      ADestinationStore_ID:= '3D30000101';     //sklad rekla
      ARBODDocQueue_ID:= '~000000302';         //řada VXDT
      AICNDocQueue_ID:='1B10000101'            // řada DVT
    end;
    if ABusOrder_ID = '2700000101' then  begin                        // eshop EU
      ADestinationStore_ID:= '3D30000101';
      ARBODDocQueue_ID:= '~000000303';
      AICNDocQueue_ID:='2B10000101'
    end;
    if ABusOrder_ID = '3G90000101' then  begin                        // eshop FR
      ADestinationStore_ID:= '3D30000101';
      ARBODDocQueue_ID:= '~000000303';
      AICNDocQueue_ID:='2B10000101'
    end;
    if ABusOrder_ID = '2G00000101' then begin                       // eshop ITL
      ADestinationStore_ID:= '3D30000101';
      ARBODDocQueue_ID:= '~000000303';
      AICNDocQueue_ID:='2B10000101'
    end;
     if ABusOrder_ID = '1000000S01' then begin                         // eshop SK
      ADestinationStore_ID:= '3D30000101';
      ARBODDocQueue_ID:= '~000000303';
      AICNDocQueue_ID:='2B10000101'
    end;
  end;
   // 1700000101 cz eshop
   // Vratky:  Sklad 45 ČR vratka DL – VXDT Dobropis -DVT
   // Mimo ČR Vratka DL – VXDZ Dobropis – DVE
   // Reklamace: Sklad Rekla ČR Vratka DL – VXDT Dobropis -DVT
   // Mimo ČR Vratka DL – VXDZ =Dobropis – DVE
end;


//ARCHIV 17.7.2024
{
Function POST_CreateCN(var AContext: TNXContext;var  AInput: TJSONSuperObject;var APath: String) : TJSONSuperObject;
var
 mBO, mRowBO, mFirmBO, mFirmBankAccountBO, mVRRowBO, mVRBO, mIIROWBO, mDRBBO, mPaymentOrderBO:TNxCustomBusinessObject;
 mInvoice_ID, mVR_ID, mFirmBankAccount_ID, mInvoiceRow_ID, mMessage:String;
 mImportMan: TNxDocumentImportManager;
 mRows, mBankRows, mDocRowBatches:TNxCustomBusinessMonikerCollection;
 i,j,k:integer;
 mOS:TNxCustomObjectSpace;
 mInvoiceRowList, mBODRowList:TStringList;
 mInputParams:TNxParameters;
 mParam:TNxParameter;
 mICN: TNxIssuedCreditNote;
 mICNDocQueue_ID, mRBODDocQueue_ID, mDestinationStore_ID, mStoreBatch_ID:string;
 mDivision_ID, mStoreCard_ID, mBusOrder_ID, mBusTransaction_ID, mBusProject_ID, mBillOfDelivery_ID, mBoDRow_ID:string;
 mReclamation:Boolean;
 mReceivedOrderBO, mReceivedOrderRowBO, mBODRowBO:TNxCustomBusinessObject;
 mOrderRows, mPORows:TNxCustomBusinessMonikerCollection;
 mPaymentOrderDocumentBO:TNxCustomBusinessObject;
begin
 Result := TJSONSuperObject.Create;
 mOS:=AContext.GetObjectSpace;
 mReclamation:=False;
 mDivision_ID:='';
 mBusOrder_ID:='';
 mBusTransaction_ID:='';
 mBusProject_ID:='';
 mInvoice_ID:=mOS.SQLSelectFirstAsString('select distinct(ii.id) from issuedinvoices ii '+
                                                                'left join firms f on f.id=ii.firm_id '+
                                                                'left join addresses a on a.id=f.electronicAddress_id '+
                                                                'left join issuedinvoices2 ii2 on ii.id=ii2.parent_id  '+
                                                                'left join storedocuments2 sd2 on sd2.id=ii2.providerow_id '+
                                                                'left join receivedorders2 ro2 on ro2.id=sd2.providerow_id '+
                                                                'left join receivedorders ro on ro2.parent_id=ro.id '+
                                                                'where ro.externalnumber='+QuotedStr(AInput.S['externalOrderNumber'])+
                                                                ' and a.email='+QuotedStr(AInput.S['email']),'');
   if not(NxIsEmptyOID(mInvoice_ID)) then begin
                          mInvoiceRowList:=TStringList.Create;
                          for i:= 0 to AInput.A['lines'].Length -1 do begin
                           if (AInput.A['lines'].O[i].S['reason']='R') and not(mReclamation) then mReclamation:=True;
                           if AInput.A['lines'].O[i].A['batches'].Length>0 then begin
                            for j:=0 to AInput.A['lines'].O[i].A['batches'].Length-1 do begin
                            }
                               {mInvoiceRow_ID:=mOS.SQLSelectFirstAsString('SELECT ii2.id FROM issuedinvoices2 ii2 '+
                                                                          'left join StoreCards SC on ii2.storecard_id=sc.id  '+
                                                                          'left join docrowbatches drb on drb.Parent_ID=ii2.providerow_id '+
                                                                          'left join storebatches sb on sb.id=drb.storebatch_id '+
                                                                          'WHERE (((SC.EAN LIKE N'+QuotedStr(AInput.A['lines'].O[i].S['productCode'])+' ESCAPE ''~'') '+
                                                                          'OR    (SC.ID IN (SELECT SU.Parent_ID  FROM StoreEANs SE '+
                                                                          '   JOIN StoreUnits SU ON SE.Parent_Id = SU.Id '+
                                                                          '   WHERE SU.Parent_ID = SC.ID '+
                                                                          '   AND SE.Ean LIKE N'+QuotedStr(AInput.A['lines'].O[i].S['productCode'])+' ESCAPE ''~'')))) AND (SC.Hidden = ''N'') and '+
                                                                          '   ii2.parent_id='+QuotedStr(mInvoice_ID)+
                                                                          ' and sb.name='+Quotedstr(AInput.A['lines'].O[i].A['batches'].O[j].AsString),''); }{
                                mInvoiceRow_ID:=mOS.SQLSelectFirstAsString('SELECT ii2.id FROM issuedinvoices2 ii2 '+
                                                                          'left join StoreCards SC on ii2.storecard_id=sc.id  '+
                                                                          'left join docrowbatches drb on drb.Parent_ID=ii2.providerow_id '+
                                                                          'left join storebatches sb on sb.id=drb.storebatch_id '+
                                                                          'WHERE (SC.Code='+QuotedStr(AInput.A['lines'].O[i].S['productCode'])+' and SC.Hidden = ''N'') and '+
                                                                          '   ii2.parent_id='+QuotedStr(mInvoice_ID)+
                                                                          ' and sb.name='+Quotedstr(AInput.A['lines'].O[i].A['batches'].O[j].AsString),'');
                              if not(NxIsEmptyOID(mInvoiceRow_ID)) then mInvoiceRowList.Add(mInvoiceRow_ID);
                            end;
                           end else begin
                            mInvoiceRow_ID:=mOS.SQLSelectFirstAsString('SELECT ii2.id FROM issuedinvoices2 ii2 '+
                                                                        'left join StoreCards SC on ii2.storecard_id=sc.id  '+
                                                                        'WHERE SC.code='+QuotedStr(AInput.A['lines'].O[i].S['productCode'])+' and '+
                                                                        '   ii2.parent_id='+QuotedStr(mInvoice_ID),'');
                            if not(NxIsEmptyOID(mInvoiceRow_ID)) then mInvoiceRowList.Add(mInvoiceRow_ID);
                           end;
                          end;
                          mImportMan := NxCreateDocumentImportManager(mOS, Class_IssuedInvoice, Class_IssuedCreditNote);
                          mDestinationStore_ID:=cDestinationStore_ID;
                          mRBODDocQueue_ID:=cRBODDocQueue_ID;
                          mICNDocQueue_ID:=cICNDocQueue_ID;
                          mIIROWBO:=mos.CreateObject(Class_IssuedInvoiceRow);
                          mIIROWBO.Load(mInvoiceRow_ID);
                          Result.S['BusOrder_ID']:=mIIROWBO.GetFieldValueAsString('BusOrder_ID');
                           if not(mReclamation) then begin
                            if mIIROWBO.GetFieldValueAsString('BusOrder_ID')='1700000101' then  begin                        // cz eshop
                                mDestinationStore_ID:= '1030000101';     //sklad 45
                                mRBODDocQueue_ID:= '~000000302';         //řada VXDT
                                mICNDocQueue_ID:='1B10000101'            // řada DVT
                             end;
                             if mIIROWBO.GetFieldValueAsString('BusOrder_ID')='2700000101' then  begin                        // eshop EU
                                mDestinationStore_ID:= '1030000101';
                                mRBODDocQueue_ID:= '~000000303';
                                mICNDocQueue_ID:='2B10000101'
                              end;
                             if mIIROWBO.GetFieldValueAsString('BusOrder_ID')='3G90000101' then  begin                       // eshop FR
                                mDestinationStore_ID:= '1030000101';
                                mRBODDocQueue_ID:= '~000000303';
                                mICNDocQueue_ID:='2B10000101'
                              end;
                              if mIIROWBO.GetFieldValueAsString('BusOrder_ID')='2G00000101' then begin                        // eshop ITL
                                mDestinationStore_ID:= '1030000101';
                                mRBODDocQueue_ID:= '~000000303';
                                mICNDocQueue_ID:='2B10000101'
                              end;
                              if mIIROWBO.GetFieldValueAsString('BusOrder_ID')='1000000S01' then begin                        // eshop SK
                                mDestinationStore_ID:= '1030000101';
                                mRBODDocQueue_ID:= '~000000303';
                                mICNDocQueue_ID:='2B10000101'
                              end;
                             end else begin
                              if mIIROWBO.GetFieldValueAsString('BusOrder_ID')='1700000101' then  begin                        // cz eshop
                                mDestinationStore_ID:= '3D30000101';     //sklad rekla
                                mRBODDocQueue_ID:= '~000000302';         //řada VXDT
                                mICNDocQueue_ID:='1B10000101'            // řada DVT
                              end;
                              if mIIROWBO.GetFieldValueAsString('BusOrder_ID')='2700000101' then  begin                        // eshop EU
                                mDestinationStore_ID:= '3D30000101';
                                mRBODDocQueue_ID:= '~000000303';
                                mICNDocQueue_ID:='2B10000101'
                              end;
                              if mIIROWBO.GetFieldValueAsString('BusOrder_ID')='3G90000101' then  begin                        // eshop FR
                                mDestinationStore_ID:= '3D30000101';
                                mRBODDocQueue_ID:= '~000000303';
                                mICNDocQueue_ID:='2B10000101'
                              end;
                              if mIIROWBO.GetFieldValueAsString('BusOrder_ID')='2G00000101' then begin                       // eshop ITL
                                mDestinationStore_ID:= '3D30000101';
                                mRBODDocQueue_ID:= '~000000303';
                                mICNDocQueue_ID:='2B10000101'
                              end;
                               if mIIROWBO.GetFieldValueAsString('BusOrder_ID')='1000000S01' then begin                         // eshop SK
                                mDestinationStore_ID:= '3D30000101';
                                mRBODDocQueue_ID:= '~000000303';
                                mICNDocQueue_ID:='2B10000101'
                              end;
                             end;
                           // 1700000101 cz eshop
                           // Vratky:  Sklad 45 ČR vratka DL – VXDT Dobropis -DVT
                           // Mimo ČR Vratka DL – VXDZ Dobropis – DVE
                           // Reklamace: Sklad Rekla ČR Vratka DL – VXDT Dobropis -DVT
                           // Mimo ČR Vratka DL – VXDZ =Dobropis – DVE


                          mIIROWBO.free;
                          Try
                           mInputParams := TNxParameters.Create;
                           mParam := mInputParams.GetOrCreateParam(dtString, 'SelectedRows');
                           mParam.AsString := mInvoiceRowList.Text;
                           mParam := mInputParams.GetOrCreateParam(dtString, 'DocQueue_ID');
                           mParam.AsString := mICNDocQueue_ID;
                           mParam := mInputParams.GetOrCreateParam(dtString, 'SelectedHeader');
                           mParam.AsString := mInvoice_ID;
                           mParam := mInputParams.GetOrCreateParam(dtBoolean, 'DoNotImportChargesSerialNumbers');
                           mParam.AsBoolean := True;
                           mParam := mInputParams.GetOrCreateParam(dtString, 'StoreDocQueue_ID');
                           mParam.AsString := mRBODDocQueue_ID;
                           mImportMan.AddInputDocument(mInvoice_ID);
                           mImportMan.LoadParams(mInputParams);
                           mImportMan.Execute;
                           mImportMan.AfterExecuteFromOLE;
                           mImportMan.OutputDocument.SetFieldValueAsString('DocQueue_ID',mICNDocQueue_ID);
                           mImportMan.OutputDocument.SetFieldValueAsString('StoreDocQueue_ID',mRBODDocQueue_ID);
                           mImportMan.OutputDocument.SetFieldValueAsString('Description',AInput.S['externalOrderNumber']);
                           mImportMan.OutputDocument.SetFieldValueAsString('ReasonDescription',AInput.S['message']);
                           mImportMan.OutputDocument.SetFieldValueAsDateTime('DocDate$DATE', Date + 1);
                           mImportMan.OutputDocument.SetFieldValueAsString('PaymentType_ID', '1900000101'); //Ub
                           mImportMan.OutputDocument.SetFieldValueAsString('X_TicketID', AInput.S['X_TicketID']);

                           //dohledávání a zakládání účtu
                           if not(NxIsBlank(AInput.S['bankAccount'])) then begin
                             mFirmBankAccount_ID:=mOS.SQLSelectFirstAsString('Select id from FirmBankAccounts where Parent_id='+
                                                                             QuotedStr(mImportMan.OutputDocument.GetFieldValueAsString('Firm_ID'))+
                                                                             ' and BankAccount='+QuotedStr(AInput.S['bankAccount']),'');
                             if NxIsEmptyOID(mFirmBankAccount_ID) then begin
                               mFirmBO:=mOS.CreateObject(Class_Firm);
                               mFirmBO.Load(mImportMan.OutputDocument.GetFieldValueAsString('Firm_ID'),nil);
                               mBankRows:=mFirmBO.GetLoadedCollectionMonikerForFieldCode(mFirmBO.GetFieldCode('Rows'));
                               mFirmBankAccountBO:=mBankRows.AddNewObject;
                               mFirmBankAccountBO.prefill;
                               mFirmBankAccountBO.SetFieldValueAsString('BankAccount',AInput.S['bankAccount']);
                               mFirmBankAccount_ID:=mFirmBankAccountBO.OID;
                               mFirmBO.save;
                               mFirmBO.free;
                             end;
                             mImportMan.OutputDocument.SetFieldValueAsString('FirmBankAccount_ID',mFirmBankAccount_ID);
                           end;
                           //konec dohledávání účtu
                           mRows:=mImportMan.OutputDocument.GetLoadedCollectionMonikerForFieldCode(mImportMan.OutputDocument.GetFieldCode('Rows'));
                           for i:=0 to mRows.count-1 do begin
                             mRowBO:=mRows.BusinessObject[i];
                             for k:= 0 to AInput.A['lines'].Length -1 do begin
                              if mrowbo.GetFieldValueAsString('StoreCard_ID.Code')=AInput.A['lines'].O[k].S['productCode'] then begin
                                 if NxIsEmptyOID(mDivision_ID) then mDivision_ID:=mRowBO.GetFieldValueAsString('Division_ID');
                                 if NxIsEmptyOID(mBusOrder_ID) then mBusOrder_ID:=mRowBO.GetFieldValueAsString('BusOrder_ID');
                                 if NxIsEmptyOID(mBusTransaction_ID) then mBusTransaction_ID:=mRowBO.GetFieldValueAsString('BusTransaction_ID');
                                 if NxIsEmptyOID(mBusProject_ID) then mBusProject_ID:=mRowBO.GetFieldValueAsString('BusProject_ID');
                                 mRowBO.SetFieldValueAsString('X_Duvod_Vraceni', mOS.SQLSelectFirstAsString('Select id from defrolldata where clsid='+QuotedStr('TQZJRHNCDTVOL3T5BO2OHBQZPK')+' and code='+QuotedStr(AInput.A['lines'].O[k].S['reason'])+' and hidden='+QuotedStr('N'),''));
                                 mRowBO.SetFieldValueAsString('Store_ID',mDestinationStore_ID);
                                 if AInput.A['lines'].O[k].D['productQuantity']>0 then
                                  mRowBO.SetFieldValueAsFloat('Quantity',AInput.A['lines'].O[i].D['productQuantity']) else
                                  mRowBO.SetFieldValueAsFloat('Quantity',0); //doplnit množství
                                 if AInput.A['lines'].O[k].D['price']>0 then
                                  mRowBO.SetFieldValueAsFloat('UnitPrice',AInput.A['lines'].O[k].D['price']);
                                 mRowBO.validate;
                              end;
                             end;
                           end;
                           mImportMan.OutputDocument.save;
                           Result.S['IssuedCreditNote']:=mImportMan.OutputDocument.DisplayName;
                           mVR_ID:=mos.SQLSelectFirstAsString('Select provide_id from issuedcreditnotes2 where parent_id='+QuotedStr(mImportMan.OutputDocument.OID),'');
                           mVRBO:=mOS.CreateObject(Class_RefundedBillOfDelivery);
                           mVRBO.Load(mVR_ID,nil);
                           Result.S['StoreDocument']:=mVRBO.DisplayName;
                           mRows:=mvrbo.GetLoadedCollectionMonikerForFieldCode(mVRBO.GetFieldCode('Rows'));
                           for i:=0 to mRows.count-1 do begin
                             mRowBO:=mRows.BusinessObject[i];
                             for k:= 0 to AInput.A['lines'].Length -1 do begin
                              if mrowbo.GetFieldValueAsString('StoreCard_ID.Code')=AInput.A['lines'].O[k].S['productCode'] then begin
                                if AInput.A['lines'].O[k].A['batches'].Length>0 then begin
                                   mDocRowBatches:=mRowBO.GetLoadedCollectionMonikerForFieldCode(mRowBO.GetFieldCode('DocRowBatches'));
                                   for j:=0 to AInput.A['lines'].O[k].A['batches'].Length-1 do begin
                                      mStoreBatch_ID:=mOS.SQLSelectFirstAsString('Select id from storebatches where storecard_id='
                                                           +Quotedstr(mRowBO.GetFieldValueAsString('StoreCard_ID'))+' and name='+QuotedStr(AInput.A['lines'].O[k].A['batches'].O[j].AsString),'');
                                      if not(NxIsEmptyOID(mStoreBatch_ID)) then begin
                                         mDRBBO:=mDocRowBatches.AddNewObject;
                                         mDRBBO.SetFieldValueAsString('StoreBatch_ID',mStoreBatch_ID);
                                      end;
                                   end;
                                end;
                              end;
                             end;
                           end;
                          if not(AInput.B['changeGoods']) then begin
                              mPaymentOrderBO:=mOS.CreateObject(Class_PaymentOrderRow);
                              mPaymentOrderBO.new;
                              mPaymentOrderBO.prefill;
                              mPaymentOrderBO.SetFieldValueAsFloat('Amount',mImportMan.OutputDocument.GetFieldValueAsFloat('Amount'));
                              mPaymentOrderBO.SetFieldValueAsString('Firm_ID',mImportMan.OutputDocument.GetFieldValueAsString('Firm_ID'));
                              mpaymentorderbo.SetFieldValueAsString('VarSymbol',mImportMan.OutputDocument.GetFieldValueAsString('VarSymbol'));
                              mPaymentOrderBO.SetFieldValueAsString('TargetBankAccount',mImportMan.OutputDocument.GetFieldValueAsString('FirmBankAccount_ID.BankAccount'));
                              mpaymentorderBO.SetFieldValueAsDateTime('DueDate$Date',Date+1);
                              mPaymentOrderBO.SetFieldValueAsString('BankAccount_ID','3JN0000101');  //ALEC - 16.7.2024 - změna účtu na 3JN0000101
                              mPaymentOrderBO.SetFieldValueAsString('Currency_ID',mImportMan.OutputDocument.GetFieldValueAsString('Currency_ID'));
                              mPORows:=mPaymentOrderBO.GetLoadedCollectionMonikerForFieldCode(mPaymentOrderBO.GetFieldCode('PaymentOrderDocuments'));
                              mPaymentOrderDocumentBO:=mPORows.AddNewObject;
                              mPaymentOrderDocumentBO.SetFieldValueAsString('PDocument_ID',mImportMan.OutputDocument.OID);
                              mPaymentOrderDocumentBO.SetFieldValueAsString('PDocumentType','60');
                              mPaymentOrderDocumentBO.SetFieldValueAsFloat('Amount',mImportMan.OutputDocument.GetFieldValueAsFloat('Amount'));
                              mPaymentOrderBO.save;
                              mPaymentOrderBO.free;
                          end;
                          if mReclamation and AInput.B['changeGoods'] then begin
                             mReceivedOrderBO:=mOS.CreateObject(Class_ReceivedOrder);
                             mReceivedOrderBO.new;
                             mReceivedOrderBO.prefill;
                             mReceivedOrderBO.SetFieldValueAsString('DocQueue_ID','4762000101');
                             mReceivedOrderBO.SetFieldValueAsString('Firm_ID',mImportMan.OutputDocument.GetFieldValueAsString('Firm_ID'));
                             mReceivedOrderBO.SetFieldValueAsString('ExternalNumber',AInput.S['externalOrderNumber']);
                             mReceivedOrderBO.SetFieldValueAsString('Currency_ID',mImportMan.OutputDocument.GetFieldValueAsString('Currency_ID'));
                             mReceivedOrderBO.SetFieldValueAsInteger('TradeType',mImportMan.OutputDocument.GetFieldValueAsInteger('TradeType'));
                             mReceivedOrderBO.SetFieldValueAsString('Country_ID',mImportMan.OutputDocument.GetFieldValueAsString('Country_ID'));
                             mOrderRows:=mReceivedOrderBO.GetLoadedCollectionMonikerForFieldCode(mReceivedOrderBO.GetFieldCode('Rows'));
                              for k:= 0 to AInput.A['lines'].Length -1 do begin
                                mStoreCard_ID:=mOS.SQLSelectFirstAsString('Select id from storecards where hidden=''N'' and code='+QuotedStr(AInput.A['lines'].O[k].S['productCode']),'');
                                if not(NxIsEmptyOID(mStoreCard_ID)) then begin
                                  mReceivedOrderRowBO:=mOrderRows.AddNewObject;
                                  mReceivedOrderRowBO.SetFieldValueAsInteger('RowType',3);
                                  mReceivedOrderRowBO.SetFieldValueAsString('Store_ID','1120000101');
                                  mReceivedOrderRowBO.SetFieldValueAsString('StoreCard_ID',mStoreCard_ID);
                                  mReceivedOrderRowBO.SetFieldValueAsFloat('Quantity',AInput.A['lines'].O[k].D['productQuantity']);
                                  mReceivedOrderRowBO.SetFieldValueAsString('Division_ID',mDivision_ID);
                                  mReceivedOrderRowBO.SetFieldValueAsString('BusOrder_ID',mBusOrder_ID);
                                  mReceivedOrderRowBO.SetFieldValueAsString('BusTransaction_ID',mBusTransaction_ID);
                                  mReceivedOrderRowBO.SetFieldValueAsString('BusProject_ID',mBusProject_ID);
                                end;
                              end;
                             mReceivedOrderBO.save;
                             mReceivedOrderBO.free;
                             mImportMan.OutputDocument.delete;
                             Result.S['IssuedCreditNote']:='';
                          end;
                          try
                           if mVRBO.NeedSave then mVRBO.save;
                          except
                           Result.S['Result']:='Vyjímka:' +ExceptionMessage;
                          end;
                          finally

                          end;
     Result.I['StatusCode']:=200;
     Result.S['Result']:='OK';
   end else begin
     Result.I['StatusCode']:=404;
     Result.S['Result']:='Nebyla dohledána faktura';
   end;
end;
}

begin
end.