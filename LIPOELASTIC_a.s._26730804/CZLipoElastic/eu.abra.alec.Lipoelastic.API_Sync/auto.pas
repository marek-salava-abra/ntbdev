uses '.const', '.API';
{
  cStateToBeSynced = '~000000303';
  cStateSyncOK = '~000000305';
  cStateSyncError = '~000000306';

  cReceiptCardCodeFieldName = 'U_SK_ReceiptCardCode';
  cStoreCodeFieldName = 'U_SK_StoreCode';
}

procedure AutoSync_BillsOfDelivery (OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
var
  mBO, mRowBO, mDocRowBatchBO: TNxCustomBusinessObject;
  mRows, mDRBRows: TNxCustomBusinessMonikerCollection;
  mHeaderJSON, mRowJSON, mStoreBatchJSON, mResultJSON: TJSONSuperObject;
  mBODList: TStringList;
  mProvideRow_ID: string;
  i, j, k: integer;
begin
  Success := True;
  LogInfoStr := '';

  mBODList:= TStringList.Create;
  try
    OS.SQLSelect(Format(
      ' SELECT ID FROM StoreDocuments '+
      ' WHERE DocumentType = ''21'' AND PMState_ID in (''%s'', ''%s'', ''%s'') ',
      [cStateToBeSynced, cStateToBeSynced_Sales, cStateToBeSynced_Transfers]), mBODList);

    LogInfoStr:= LogInfoStr + 'Počet dodacích listů ke zpracování '+IntToStr(mBODList.Count)+nxCrLf;

    for k:= 0 to mBODList.Count -1 do begin
      mBO:= OS.CreateObject(Class_BillOfDelivery);
      try
        mBO.load(mBODList.strings[k],nil);
        //if Assigned(mBO) then begin

        //Kontrola jestli je provedeno nastavení k synchronizaci
        if NxIsBlank(mbo.GetFieldValueAsString('DocQueue_ID.'+cReceiptCardCodeFieldName)) then begin
          LogInfoStr:= LogInfoStr + nxCrLf+ 'Řada dokladů '+#13#10+ mBO.GetFieldValueAsString('DocQueue_ID.Code')+' - '+mBO.GetFieldValueAsString('DocQueue_ID.Name')+#13#10+
            'nemá nastaveny parametry pro odeslání do ČR. Doklad přeskočen.';
            Success:= false;
          continue;
        end;
        //if NxIsBlank(mBO.GetFieldValueAsString('X_ExternalDocument')) then begin
          mRows:=mBO.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('Rows'));
          mHeaderJSON:=TJSONSuperObject.Create;
          case mBO.GetFieldValueAsString('PMState_ID') of
            cStateToBeSynced:           mHeaderJSON.S['BODType']:= 'VYROBA';
            cStateToBeSynced_Sales:     mHeaderJSON.S['BODType']:= 'OBCHOD';
            cStateToBeSynced_Transfers: mHeaderJSON.S['BODType']:= 'PREVOD'
          end;
          mHeaderJSON.S['ExternalNumber']:=mBO.DisplayName;
          mHeaderJSON.S['Description']:=mBO.GetFieldValueAsString('Description');
          mHeaderJSON.S['BillOfDelivery_ID']:=mBO.OID;
          mHeaderJSON.S['ReceiptCardCode']:=mbo.GetFieldValueAsString('DocQueue_ID.'+cReceiptCardCodeFieldName);
          mHeaderJSON.S['StoreCode']:= mBO.GetFieldValueAsString('DocQueue_ID.'+cStoreCodeFieldName);
          mHeaderJSON.O['Rows'] := mHeaderJSON.CreateJSONArray;
          for i:=0 to mRows.count-1 do begin
            mRowBO:=mRows.BusinessObject[i];
            mRowJSON:=TJSONSuperObject.Create;
            mrowJSON.I['RowType']:=mRowBO.GetFieldValueAsInteger('RowType');
            if not(NxIsEmptyOID(mRowBO.GetFieldValueAsString('StoreCard_ID'))) then
              mRowJSON.S['StoreCardCode']:=mRowBO.GetFieldValueAsString('StoreCard_ID.Code')
            else
              mRowJSON.S['StoreCardCode']:='';
            mRowJSON.D['Quantity']:=mRowBO.GetFieldValueAsFloat('Quantity');
            mRowJSON.S['Text']:=mRowBO.GetFieldValueAsString('Text');
            mRowJSON.S['QUnit']:=mRowBO.GetFieldValueAsString('Qunit');
            mProvideRow_ID:= OS.SQLSelectFirstAsString('Select X_ProvideRow_ID from receivedorders2 where id='+QuotedStr(mRowBO.GetFieldValueAsString('ProvideRow_ID')),'');
            mRowJSON.S['XProvideRowID']:=mProvideRow_ID;
            mRowJSON.S['BODRowID']:=mRowBO.OID;
            mRowJSON.O['DocRowBatches']:=mRowJSON.CreateJSONArray;
            mDRBRows:=mRowBO.GetLoadedCollectionMonikerForFieldCode(mRowBO.GetFieldCode('DocRowBatches'));
            if mDRBRows.count>0 then begin
              for j:=0 to mDRBRows.count-1 do begin
                mStoreBatchJSON:=TJSONSuperObject.Create;
                mDocRowBatchBO:=mDRBRows.BusinessObject[j];
                mStoreBatchJSON.S['StoreBatchName']:=mDocRowBatchBO.GetFieldValueAsString('StoreBatch_ID.Name');
                mStoreBatchJSON.D['Quantity']:=mDocRowBatchBO.GetFieldValueAsFloat('Quantity');
                mStoreBatchJSON.DT8601['Expiry']:=mDocRowBatchBO.GetFieldValueAsDateTime('StoreBatch_ID.ExpirationDate$DATE');
                mStoreBatchJSON.DT8601['Produce']:=mDocRowBatchBO.GetFieldValueAsDateTime('StoreBatch_ID.ProductionDate$DATE');
                mStoreBatchJSON.S['StoreBatchSpecification']:=mDocRowBatchBO.GetFieldValueAsString('StoreBatch_ID.Specification');
                mStoreBatchJSON.S['X_Verze']:= mDocRowBatchBO.GetFieldValueAsString('StoreBatch_ID.X_Verze');
                //varianta šarže
                mRowJSON.A['DocRowBatches'].Add(mStoreBatchJSON);
              end;
            end;
            mHeaderJSON.A['Rows'].Add(mRowJSON);
          end;
          mResultJSON:= TJSONSuperObject.Create;

          mResultJSON:= API_POST(mHeaderJSON, 'BillsOfDelivery');
          //NxSleep(30000);

          //Když zůstane ResultJSON prázdný
          if not(Length(mResultJSON.AsString) > 2) then begin
            LogInfoStr:= LogInfoStr + nxCrLf + mBO.DisplayName + ' ' + 'Timeout';
            Success:= false;
            continue;
          end;

          if not(NxIsBlank(mResultJSON.S['DisplayName'])) then begin
            if (mBO.GetFieldValueAsString('X_ExternalDocument')='0') or (NxIsBlank(mBO.GetFieldValueAsString('X_ExternalDocument'))) or (mBO.GetFieldValueAsString('X_ExternalDocument') = mResultJSON.S['DisplayName']) then begin
              mBO.SetFieldValueAsString('X_ExternalDocument',mResultJSON.S['DisplayName']);
              mBO.SetFieldValueAsString('PMState_ID', cStateSyncOK);
              mBO.Save;

              //mBO.PMChangeState(cStateSyncOK);
              LogInfoStr:= LogInfoStr + nxCrLf + mBO.DisplayName + ' ' + 'OK';

            end else begin
              mBO.PMChangeState(cStateSyncError);
              LogInfoStr:= LogInfoStr + nxCrLf + mBO.DisplayName + ' ' + 'Již má vyplněno pole s externím dokumentem: '+mBO.GetFieldValueAsString('X_ExternalDocument')+' API vrátilo: '+mResultJSON.S['DisplayName'];
              Success:= false;
              continue;
            end;
          end;

          {
          if not(NxIsBlank(mBO.GetFieldValueAsString('X_ExternalDocument'))) then begin
            mBO.PMChangeState(cStateSyncOK);
            LogInfoStr:= LogInfoStr + nxCrLf + mBO.DisplayName + ' ' + 'OK';
          end;
          }

          if mResultJSON.S['status']='error' then begin
            LogInfoStr:= LogInfoStr + nxCrLf + mBO.DisplayName + ' ' + mResultJSON.S['statusMessage'];
            mBO.PMChangeState(cStateSyncError);
            Success:= false;
            continue;
          end;
        //end else begin
          //LogInfoStr:= LogInfoStr + nxCrLf + mBO.DisplayName + ' ' + 'Již má vyplněno pole s externím dokumentem: '+mBO.GetFieldValueAsString('X_ExternalDocument')+'. Doklad přeskočen.';
          //Success:= false;
          //continue;
        //end;
      except
        LogInfoStr:= LogInfoStr + nxCrLf + mBO.DisplayName + ' ' + 'Vyskytla se chyba: '+ExceptionMessage;
        if Assigned(mBO) then begin
          if NxIsBlank(mBO.GetFieldValueAsString('X_ExternalDocument')) and (not(NxIsBlank(mResultJSON.S['DisplayName']))) then begin
            OS.SQLExecute('UPDATE StoreDocuments SET X_ExternalDocument = '+mResultJSON.S['DisplayName']+' WHERE ID ='+QuotedStr(mBO.OID));
          end;
        end;
        Success:= false;
        mBO.Free;
      end;
    end;
  finally
    mBODList.Free;
  end;
end;



{
procedure AutoSync_BillsOfDelivery (OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
var
  mBO, mRowBO, mDocRowBatchBO: TNxCustomBusinessObject;
  mRows, mDRBRows: TNxCustomBusinessMonikerCollection;
  mHeaderJSON, mRowJSON, mStoreBatchJSON, mResultJSON: TJSONSuperObject;
  mBODList: TStringList;
  mProvideRow_ID: string;
  i, j, k: integer;
begin
  Success := True;
  LogInfoStr := '';

  mBODList:= TStringList.Create;
  try
    OS.SQLSelect('SELECT ID FROM StoreDocuments WHERE DocumentType = ''21'' AND PMState_ID = '+QuotedStr(cStateToBeSynced), mBODList);
    LogInfoStr:= LogInfoStr + 'Počet dodacích listů ke zpracování '+IntToStr(mBODList.Count)+nxCrLf;

    for k:= 0 to mBODList.Count -1 do begin
      mBO:= OS.CreateObject(Class_BillOfDelivery);
      try
        mBO.load(mBODList.strings[k],nil);
        //if Assigned(mBO) then begin

        //Kontrola jestli je provedeno nastavení k synchronizaci
        if NxIsBlank(mbo.GetFieldValueAsString('DocQueue_ID.'+cReceiptCardCodeFieldName)) then begin
          LogInfoStr:= LogInfoStr + nxCrLf+ 'Řada dokladů '+#13#10+ mBO.GetFieldValueAsString('DocQueue_ID.Code')+' - '+mBO.GetFieldValueAsString('DocQueue_ID.Name')+#13#10+
            'nemá nastaveny parametry pro odeslání do ČR. Doklad přeskočen.';
            Success:= false;
          continue;
        end;
        if NxIsBlank(mBO.GetFieldValueAsString('X_ExternalDocument')) then begin
          mRows:=mBO.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('Rows'));
          mHeaderJSON:=TJSONSuperObject.Create;
          mHeaderJSON.S['ExternalNumber']:=mBO.DisplayName;
          mHeaderJSON.S['Description']:=mBO.GetFieldValueAsString('Description');
          mHeaderJSON.S['BillOfDelivery_ID']:=mBO.OID;
          mHeaderJSON.S['ReceiptCardCode']:=mbo.GetFieldValueAsString('DocQueue_ID.'+cReceiptCardCodeFieldName);
          mHeaderJSON.S['StoreCode']:= mBO.GetFieldValueAsString('DocQueue_ID.'+cStoreCodeFieldName);
          mHeaderJSON.O['Rows'] := mHeaderJSON.CreateJSONArray;
          for i:=0 to mRows.count-1 do begin
            mRowBO:=mRows.BusinessObject[i];
            mRowJSON:=TJSONSuperObject.Create;
            mrowJSON.I['RowType']:=mRowBO.GetFieldValueAsInteger('RowType');
            if not(NxIsEmptyOID(mRowBO.GetFieldValueAsString('StoreCard_ID'))) then
              mRowJSON.S['StoreCardCode']:=mRowBO.GetFieldValueAsString('StoreCard_ID.Code')
            else
              mRowJSON.S['StoreCardCode']:='';
            mRowJSON.D['Quantity']:=mRowBO.GetFieldValueAsFloat('Quantity');
            mRowJSON.S['Text']:=mRowBO.GetFieldValueAsString('Text');
            mRowJSON.S['QUnit']:=mRowBO.GetFieldValueAsString('Qunit');
            mProvideRow_ID:= OS.SQLSelectFirstAsString('Select X_ProvideRow_ID from receivedorders2 where id='+QuotedStr(mRowBO.GetFieldValueAsString('ProvideRow_ID')),'');
            mRowJSON.S['XProvideRowID']:=mProvideRow_ID;
            mRowJSON.S['BODRowID']:=mRowBO.OID;
            mRowJSON.O['DocRowBatches']:=mRowJSON.CreateJSONArray;
            mDRBRows:=mRowBO.GetLoadedCollectionMonikerForFieldCode(mRowBO.GetFieldCode('DocRowBatches'));
            if mDRBRows.count>0 then begin
              for j:=0 to mDRBRows.count-1 do begin
                mStoreBatchJSON:=TJSONSuperObject.Create;
                mDocRowBatchBO:=mDRBRows.BusinessObject[j];
                mStoreBatchJSON.S['StoreBatchName']:=mDocRowBatchBO.GetFieldValueAsString('StoreBatch_ID.Name');
                mStoreBatchJSON.D['Quantity']:=mDocRowBatchBO.GetFieldValueAsFloat('Quantity');
                mStoreBatchJSON.DT8601['Expiry']:=mDocRowBatchBO.GetFieldValueAsDateTime('StoreBatch_ID.ExpirationDate$DATE');
                mStoreBatchJSON.DT8601['Produce']:=mDocRowBatchBO.GetFieldValueAsDateTime('StoreBatch_ID.ProductionDate$DATE');
                mStoreBatchJSON.S['StoreBatchSpecification']:=mDocRowBatchBO.GetFieldValueAsString('StoreBatch_ID.Specification');
                mRowJSON.A['DocRowBatches'].Add(mStoreBatchJSON);
              end;
            end;
            mHeaderJSON.A['Rows'].Add(mRowJSON);
          end;
          mResultJSON:= TJSONSuperObject.Create;

          mResultJSON:= API_POST(mHeaderJSON, 'BillsOfDelivery');
          NxSleep(30000);

          //Když zůstane ResultJSON prázdný
          if not(Length(mResultJSON.AsString) > 2) then begin
            LogInfoStr:= LogInfoStr + nxCrLf + mBO.DisplayName + ' ' + 'Timeout';
            Success:= false;
            continue;
          end;

          if not(NxIsBlank(mResultJSON.S['DisplayName'])) then begin
            mBO.SetFieldValueAsString('X_ExternalDocument',mResultJSON.S['DisplayName']);
            mBO.Save;
          end;

          if not(NxIsBlank(mBO.GetFieldValueAsString('X_ExternalDocument'))) then begin
            mBO.PMChangeState(cStateSyncOK);
            LogInfoStr:= LogInfoStr + nxCrLf + mBO.DisplayName + ' ' + 'OK';
          end;

          if mResultJSON.S['status']='error' then begin
            LogInfoStr:= LogInfoStr + nxCrLf + mBO.DisplayName + ' ' + mResultJSON.S['statusMessage'];
            mBO.PMChangeState(cStateSyncError);
            Success:= false;
            continue;
          end;
        end else begin
          LogInfoStr:= LogInfoStr + nxCrLf + mBO.DisplayName + ' ' + 'Již má vyplněno pole s externím dokumentem: '+mBO.GetFieldValueAsString('X_ExternalDocument')+'. Doklad přeskočen.';
          Success:= false;
          continue;
        end;
      except
        LogInfoStr:= LogInfoStr + nxCrLf + mBO.DisplayName + ' ' + 'Vyskytla se chyba: '+ExceptionMessage;
        if Assigned(mBO) then begin
          if NxIsBlank(mBO.GetFieldValueAsString('X_ExternalDocument')) and (not(NxIsBlank(mResultJSON.S['DisplayName']))) then begin
            OS.SQLExecute('UPDATE StoreDocuments SET X_ExternalDocument = '+mResultJSON.S['DisplayName']+' WHERE ID ='+QuotedStr(mBO.OID));
          end;
        end;
        Success:= false;
      end;
    end;
  finally
    mBODList.Free;
  end;
end;
}


begin
end.