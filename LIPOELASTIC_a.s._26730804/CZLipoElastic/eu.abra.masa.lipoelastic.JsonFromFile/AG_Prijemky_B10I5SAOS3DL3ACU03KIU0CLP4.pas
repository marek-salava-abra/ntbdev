const
  cSQL_X_Aktivni = ' AND X_Aktivni = ''A'' ';

procedure InitSite_Hook(Self: TSiteForm);
var
  mAct, mAct2: TBasicAction;
  i:Integer;
begin
  mAct := Self.GetNewAction;
  mAct.Caption := '##JSON##';
  mAct.Category := 'tabList';
  mAct.OnExecute := @ProcessJSON;
end;

Procedure ProcessJSON(Sender:TComponent);
var
 mSite:TSiteForm;
 mHeaderBO, mRowBO, mDRBBO, mBODRow, mLog:TNxCustomBusinessObject;
 i,j,k:integer;
 mRows, mDRBRows:TNxCustomBusinessMonikerCollection;
 mOS:TNxCustomObjectSpace;
 mIORowList, mIOList:tstringlist;
 mOrder_ID, mStoreBatch_ID, mDocQueue_ID, mStore_ID, mStoreCard_ID ,mLogStr:string;
 mImportManager: TNxDocumentImportManager;
 mInputParams: TNxParameters;
 mParam: TNxParameter;
 mMessage, mReceiptCard_ID:string;
 mOpenDlg:TOpenDialog;
 AInput, mResult: TJSONSuperObject;
begin
 mSite := TComponent(Sender).Site;
 mOS:=msite.BaseObjectSpace;
 mOpenDlg:=TOpenDialog.Create(sender);
 if mOpenDlg.Execute then begin
    AInput:=TJSONSuperObject.ParseFile(mOpenDlg.FileName,True);
    mMessage:='';
 mLogStr:= '';
 mResult:=TJSONSuperObject.create;
 if not(NxIsEmptyOID(AInput.S['BillOfDelivery_ID'])) then
   mReceiptCard_ID:=mOS.SQLSelectFirstAsString('SELECT a.id FROM StoreDocuments A WHERE A.DocumentType='+Quotedstr('20')+
                                               ' AND ((exists (SELECT 1 FROM USERDATA WHERE FIELDCODE=2000031 AND CLSID='+
                                               QuotedStr('E03ZNUMDTCC4PDAUIEY1MBTJC0')+' AND ID = A.ID AND (STRINGFIELDVALUE LIKE '+Quotedstr(AInput.S['BillOfDelivery_ID'])+')))) ','');

 if NxIsEmptyOID(mReceiptCard_ID) then begin
  try
    if AInput.A['Rows'].Length>0 then begin
      {try
        AInput.SaveToFile('\\CZVS0006\logy\_JSON\InsertBODJSON_'+FormatDateTime('YYYYMMDDhhmmss',Now)+'.json', true, true);
      except
      end;}
      mDocQueue_ID:=mOS.SQLSelectFirstAsString('Select id from docqueues where documenttype=''20'' and hidden=''N'' and code='+QuotedStr(AInput.S['ReceiptCardCode']),'');
      if NxIsEmptyOID(mDocQueue_ID) then mDocQueue_ID:='5G10000101';
      mHeaderBO:=mOS.CreateObject(Class_ReceiptCard);
      mHeaderBO.New;
      mheaderbo.Prefill;
      mHeaderBO.SetFieldValueAsString('DocQueue_ID',mDocQueue_ID);
      mHeaderBO.SetFieldValueAsString('U_SKBillOfDelivery_ID',AInput.S['BillOfDelivery_ID']);
      mHeaderBO.SetFieldValueAsString('Description',AInput.S['ExternalNumber']);
      mHeaderBO.SetFieldValueAsString('U_DL',AInput.S['ExternalNumber']);
      mHeaderBO.SetFieldValueAsBoolean('X_ZAPI',true);
      for i:=0 to AInput.A['Rows'].Length-1 do begin
        OutputDebugString(AInput.A['Rows'].O[i].S['StoreCardCode']);
      {
        if (NxIsEmptyOID(AInput.A['Rows'].O[i].S['XProvideRowID'])) and (AInput.A['Rows'].O[i].I['RowType']=3) then begin
          mRows:= mHeaderBO.GetLoadedCollectionMonikerForFieldCode(mHeaderBO.GetFieldCode('Rows'));
          mRowBO:= mRows.AddNewObject;
          mBODRow:= mOS.CreateObject(Class_BillOfDeliveryRow);
          try
            mBODRow.Load(AInput.A['Rows'].O[i].S['BODRowID'], nil);

            mRowBO.SetFieldValueAsInteger('RowType', 3);
            mRowBO.SetFieldValueAsString('Store_ID' , mBODRow.GetFieldValueAsString('Store_ID'));
            mRowBO.SetFieldValueAsString('StoreCard_ID' , mBODRow.GetFieldValueAsString('StoreCard_ID'));
            mRowBO.SetFieldValueAsFloat('Quantity',AInput.A['Rows'].O[i].D['Quantity']);
            mRowBO.SetFieldValueAsFloat('UnitPrice',0);
            mRowBO.SetFieldValueAsFloat('TotalPrice',0);
            mRowBO.SetFieldValueAsString('X_StoreDocuments2_ID',AInput.A['Rows'].O[i].S['BODRowID']);

            if AInput.A['Rows'].O[i].A['DocRowBatches'].Length>0 then begin
              mDRBRows:=mRowBO.GetLoadedCollectionMonikerForFieldCode(mRowBO.GetFieldCode('DocRowBatches'));
              for k:=0 to AInput.A['Rows'].O[i].A['DocRowBatches'].Length-1 do begin
                mStoreBatch_ID:=mOS.SQLSelectFirstAsString(
                  ' SELECT ID FROM StoreBatches '+
                  ' WHERE StoreCard_ID='+QuotedStr(mRowBO.GetFieldValueAsString('StoreCard_ID'))+
                  ' AND Name='+QuotedStr(AInput.A['Rows'].O[i].A['DocRowBatches'].O[k].S['StoreBatchName']),'');
                if NxIsEmptyOID(mStoreBatch_ID) then begin
                  mDRBBO:=mDRBRows.AddNewObject;
                  mDRBBO.SetFieldValueAsBoolean('NewBatch',True);
                  mDRBBO.SetFieldValueAsString('NewBatchName',AInput.A['Rows'].O[i].A['DocRowBatches'].O[k].S['StoreBatchName']);
                  mDRBBO.SetFieldValueAsDateTime('NewBatchExpirationDate$Date',AInput.A['Rows'].O[i].A['DocRowBatches'].O[k].DT8601['Expiry']);
                  mDRBBO.SetFieldValueAsString('NewBatchSpecification',AInput.A['Rows'].O[i].A['DocRowBatches'].O[k].S['StoreBatchSpecification']);
                  mDRBBO.SetFieldValueAsFloat('Quantity',AInput.A['Rows'].O[i].A['DocRowBatches'].O[k].D['Quantity']);
                end else begin
                  mDRBBO:=mDRBRows.AddNewObject;
                  mDRBBO.SetFieldValueAsBoolean('NewBatch',False);
                  mDRBBO.SetFieldValueAsString('StoreBatch_ID',mStoreBatch_ID);
                  mDRBBO.SetFieldValueAsFloat('Quantity',AInput.A['Rows'].O[i].A['DocRowBatches'].O[k].D['Quantity']);
                end;
              end;
            end;
          finally
            mBODRow.Free;
          end;
        end;
        }
        if not(NxIsEmptyOID(AInput.A['Rows'].O[i].S['XProvideRowID'])) and (AInput.A['Rows'].O[i].I['RowType']=3) then begin
          mIORowList:=TStringList.create;
          mIOList:=TStringList.create;
          mIORowList.Add(AInput.A['Rows'].O[i].S['XProvideRowID']);
          mOrder_ID:= mOS.SQLSelectFirstAsString(
            ' Select parent_id from issuedorders2 '+
            ' where ((quantity-deliveredquantity)>0) '+
            ' and id='+QuotedStr(AInput.A['Rows'].O[i].S['XProvideRowID']),'');

          if NxIsEmptyOID(mOrder_ID) then begin
            mRows:= mHeaderBO.GetLoadedCollectionMonikerForFieldCode(mHeaderBO.GetFieldCode('Rows'));
            mStore_ID:= mOS.SQLSelectFirstAsString('SELECT ID FROM Stores WHERE Hidden = ''N'' AND Code = '+QuotedStr(AInput.S['StoreCode']));
            mStoreCard_ID:= mOS.SQLSelectFirstAsString('SELECT ID FROM StoreCards WHERE Hidden = ''N'' '+cSQL_X_Aktivni+' AND Code = '+QuotedStr(AInput.A['Rows'].O[i].S['StoreCardCode']));
            if NxIsEmptyOID(mStoreCard_ID) or NxIsEmptyOID(mStore_ID) then RaiseException('Nenalezen sklad nebo karta');
            mRowBO:= mRows.AddNewObject;
            mRowBO.SetFieldValueAsInteger('RowType', 3);
            mRowBO.SetFieldValueAsString('Store_ID', mStore_ID);
            mRowBO.SetFieldValueAsString('StoreCard_ID' , mStoreCard_ID);
            mRowBO.SetFieldValueAsString('QUnit', AInput.A['Rows'].O[i].S['QUnit']);
            mRowBO.SetFieldValueAsFloat('Quantity', AInput.A['Rows'].O[i].D['Quantity']);
            mRowBO.SetFieldValueAsFloat('UnitPrice',0);
            mRowBO.SetFieldValueAsFloat('TotalPrice',0);
            mRowBO.SetFieldValueAsString('X_StoreDocuments2_ID',AInput.A['Rows'].O[i].S['BODRowID']);
            mRowBO.SetFieldValueAsString('Division_ID', '6700000101'); //VV
            mRowBO.SetFieldValueAsString('BusOrder_ID', '');
            mRowBO.SetFieldValueAsString('BusProject_ID', '');
            mRowBO.SetFieldValueAsString('BusTransaction_ID', '');
            OutputDebugString('without order');

            mLogStr:= mLogStr + nxCrLf + AInput.S['ExternalNumber']+'|'+AInput.A['Rows'].O[i].S['StoreCardCode'];

            if AInput.A['Rows'].O[i].A['DocRowBatches'].Length > 0 then begin
              mLogStr:= mLogStr + nxCrLf + 'Šarže: ';
              mDRBRows:= mRowBO.GetLoadedCollectionMonikerForFieldCode(mRowBO.GetFieldCode('DocRowBatches'));
              for k:=0 to AInput.A['Rows'].O[i].A['DocRowBatches'].Length-1 do begin
                mStoreBatch_ID:=mOS.SQLSelectFirstAsString(
                  ' SELECT ID FROM StoreBatches '+
                  ' WHERE StoreCard_ID='+QuotedStr(mRowBO.GetFieldValueAsString('StoreCard_ID'))+
                  ' AND Name='+QuotedStr(AInput.A['Rows'].O[i].A['DocRowBatches'].O[k].S['StoreBatchName']),'');

                mLogStr:= mLogStr + nxCrLf + AInput.A['Rows'].O[i].A['DocRowBatches'].O[k].S['StoreBatchName'];
                if NxIsEmptyOID(mStoreBatch_ID) then begin
                  mDRBBO:=mDRBRows.AddNewObject;
                  mDRBBO.SetFieldValueAsBoolean('NewBatch',True);
                  mDRBBO.SetFieldValueAsString('NewBatchName',AInput.A['Rows'].O[i].A['DocRowBatches'].O[k].S['StoreBatchName']);
                  mDRBBO.SetFieldValueAsDateTime('NewBatchExpirationDate$Date',AInput.A['Rows'].O[i].A['DocRowBatches'].O[k].DT8601['Expiry']);
                  mDRBBO.SetFieldValueAsString('NewBatchSpecification',AInput.A['Rows'].O[i].A['DocRowBatches'].O[k].S['StoreBatchSpecification']);
                  mDRBBO.SetFieldValueAsFloat('Quantity',AInput.A['Rows'].O[i].A['DocRowBatches'].O[k].D['Quantity']);
                end else begin
                  mDRBBO:=mDRBRows.AddNewObject;
                  mDRBBO.SetFieldValueAsBoolean('NewBatch',False);
                  mDRBBO.SetFieldValueAsString('StoreBatch_ID',mStoreBatch_ID);
                  mDRBBO.SetFieldValueAsFloat('Quantity',AInput.A['Rows'].O[i].A['DocRowBatches'].O[k].D['Quantity']);
                end;
              end;
            end;

            mLogStr:= mLogStr + nxCrLf + '--------------------';

          end else begin
            OutputDebugString('with order');
            mIOList.Add(mOrder_ID);
            mInputParams := TNxParameters.Create;
            mParam := mInputParams.GetOrCreateParam(dtString, 'SelectedRows'); // jen povolene radky
            mParam.AsString := mIORowList.Text;
            mParam := mInputParams.GetOrCreateParam(dtString, 'SelectedHeader');
            mParam.AsString := mOrder_ID;
            mImportManager := NxCreateDocumentImportManager(mOS, Class_IssuedOrder, Class_ReceiptCard);
            try
              mImportManager.OutputDocument := mHeaderBO;
              mImportManager.AddInputDocuments(mIOList);
              mImportManager.LoadParams(mInputParams);
              //mImportManager.ExecuteWizard(mSite);
              mImportManager.Execute;
              //mImportManager.CheckOutputDocument;
              //mImportManager.OutputDocument.Save;
            except
             mMessage:=mMessage+#13#10+AInput.A['Rows'].O[i].S['XProvideRowID']+'  objekt '+IntToStr(i)+' Order ID:'+mOrder_ID;
             OutputDebugString(mMessage);
            end;
            mRows:=mHeaderBO.GetLoadedCollectionMonikerForFieldCode(mHeaderBO.GetFieldCode('Rows'));
            for j:=0 to mRows.Count-1 do begin
              mRowBO:=mRows.BusinessObject[j];
              if mRowBO.GetFieldValueAsString('ProvideRow_ID') = AInput.A['Rows'].O[i].S['XProvideRowID'] then begin
                mRowBO.SetFieldValueAsString('X_StoreDocuments2_ID',AInput.A['Rows'].O[i].S['BODRowID']);
                mRowBO.SetFieldValueAsFloat('Quantity',AInput.A['Rows'].O[i].D['Quantity']);
                mRowBO.SetFieldValueAsFloat('UnitPrice',0);
                mRowBO.SetFieldValueAsFloat('TotalPrice',0);
                if AInput.A['Rows'].O[i].A['DocRowBatches'].Length > 0 then begin
                  mDRBRows:=mRowBO.GetLoadedCollectionMonikerForFieldCode(mRowBO.GetFieldCode('DocRowBatches'));
                  for k:=0 to AInput.A['Rows'].O[i].A['DocRowBatches'].Length -1 do begin
                    mStoreBatch_ID:=mOS.SQLSelectFirstAsString('Select id from StoreBatches where storecard_id='+
                                                                QuotedStr(mRowBO.GetFieldValueAsString('StoreCard_ID'))+
                                                                ' and name='+QuotedStr(AInput.A['Rows'].O[i].A['DocRowBatches'].O[k].S['StoreBatchName']),'');
                    if NxIsEmptyOID(mStoreBatch_ID) then begin
                      mDRBBO:=mDRBRows.AddNewObject;
                      mDRBBO.SetFieldValueAsBoolean('NewBatch',True);
                      mDRBBO.SetFieldValueAsString('NewBatchName',AInput.A['Rows'].O[i].A['DocRowBatches'].O[k].S['StoreBatchName']);
                      mDRBBO.SetFieldValueAsDateTime('NewBatchExpirationDate$Date',AInput.A['Rows'].O[i].A['DocRowBatches'].O[k].DT8601['Expiry']);
                      mDRBBO.SetFieldValueAsString('NewBatchSpecification',AInput.A['Rows'].O[i].A['DocRowBatches'].O[k].S['StoreBatchSpecification']);
                      mDRBBO.SetFieldValueAsFloat('Quantity',AInput.A['Rows'].O[i].A['DocRowBatches'].O[k].D['Quantity']);
                    end else begin
                      mDRBBO:=mDRBRows.AddNewObject;
                      mDRBBO.SetFieldValueAsBoolean('NewBatch',False);
                      mDRBBO.SetFieldValueAsString('StoreBatch_ID',mStoreBatch_ID);
                      mDRBBO.SetFieldValueAsFloat('Quantity',AInput.A['Rows'].O[i].A['DocRowBatches'].O[k].D['Quantity']);
                    end;
                    OutputDebugString(AInput.A['Rows'].O[i].A['DocRowBatches'].O[k].S['StoreBatchName']);
                  end;
                end;
              end;
            end;
          end;
        end;
      end;
    end;
    OutputDebugString('BeforeSave');
    mHeaderBO.SetFieldValueAsInteger('TradeType',2);
    mHeaderBO.SetFieldValueAsString('IntrastatDeliveryTerm_ID','3001000000');
    mHeaderBO.SetFieldValueAsString('IntrastatTransactionType_ID','0101000000');
    mHeaderBO.SetFieldValueAsString('IntrastatTransportationType_ID','2000000000');
    mHeaderBO.SetFieldValueAsString('Country_ID','00000SK000');
    mHeaderBO.save;
    OutputDebugString('Saved');
    mResult.S['status']:='ok';
    mResult.S['statusMessage']:=mMessage;
    mResult.S['DisplayName']:=mHeaderBO.DisplayName;
    mHeaderBO.free;

    if not(NxIsBlank(mLogStr)) then begin
      mLog:=mOS.CreateObject(Class_PRFLog);
      try
        mLog.new;
        mlog.prefill;
        mLog.SetFieldValueAsString('DocQueue_ID','~000000B02');
        mLog.SetFieldValueAsString('Code', 'PrenosDL');
        mLog.SetFieldValueAsString('Note', 'K těmto kartám nebyly dohledány objednávky vydané' + nxCrLf + mLogStr);
        mlog.save;
      finally
        mLog.Free;
      end;
    end;

  except
    mResult.S['status']:='error';
    mResult.S['statusMessage']:=ExceptionMessage;
    mResult.S['DisplayName']:='';
  end;
 end else begin
   mHeaderBO:=mOS.CreateObject(Class_ReceiptCard);
   mHeaderbo.Load(mReceiptCard_ID,nil);
   mResult.S['status']:='ok';
   mResult.S['statusMessage']:='Již synchronizováno';
   mResult.S['DisplayName']:=mHeaderBO.DisplayName;
   mHeaderBO.free;
 end;
  CFxLog.SaveLog(NxCreateContext(mOS),'LA','ObsahResult',mResult.AsString,2,Now);

 end;
end;

begin
end.