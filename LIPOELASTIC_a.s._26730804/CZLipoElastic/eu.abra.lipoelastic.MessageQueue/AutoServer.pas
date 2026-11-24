uses '.receivedOrder', '.BillOfDelivery_JSON';

const
  cMQ_State_Done = 1;
  cMQ_State_Error = 2;

procedure ProcessMessageQueue(OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
var
  mMQList, mLogs: TStringList;
  mMessageQueueBO: TNxCustomBusinessObject;
  i: Integer;
  mMQ_Code, mMQ_DocType: string;
begin
  Success := True;
  LogInfoStr := '';
  mLogs := TStringList.Create;
  mMQList := TStringList.Create;
  try
    OS.SQLSelect(
      'SELECT ID FROM DefRollData' +
      ' WHERE CLSID = ' + QuotedStr(Class_MessageQueue) +
      ' AND X_MQ_State = 0' +
      ' AND Hidden = ' + QuotedStr('N'),
      mMQList
    );

    mLogs.Add(DateTimeToStr(Now) + ' queue.started');
    mLogs.Add(DateTimeToStr(Now) + ' queue.loaded count=' + IntToStr(mMQList.Count));

    for i := 0 to mMQList.Count - 1 do begin
      mMessageQueueBO := OS.CreateObject(Class_MessageQueue);
      try
        mMessageQueueBO.Load(mMQList.Strings[i], nil);

        mMQ_Code:= mMessageQueueBO.GetFieldValueAsString('Code');
        mMQ_DocType:= mMessageQueueBO.GetFieldValueAsString('X_MQ_DocumentType');

        case mMQ_DocType of
          'RO': CreateOrder(OS, mMessageQueueBO);
        else
          Set_MessageQueue_Result(mMessageQueueBO, cMQ_State_Error, 'document.unsupported type=' + mMQ_DocType);
        end;

        if mMessageQueueBO.GetFieldValueAsInteger('X_MQ_State') = cMQ_State_Error then begin
          Success := False;
        end;
        mLogs.Add(
          DateTimeToStr(Now) +
          ' message.processed code=' + mMQ_Code +
          ' state=' + IntToStr(mMessageQueueBO.GetFieldValueAsInteger('X_MQ_State')) +
          ' result=' + mMessageQueueBO.GetFieldValueAsString('X_MQ_ResultMessage')
        );
      finally
        mMessageQueueBO.Free;
      end;
    end;

    mLogs.Add(DateTimeToStr(Now) + ' queue.finished');
    LogInfoStr := NxCrLf + mLogs.Text;
  finally
    mMQList.Free;
    mLogs.Free;
  end;
end;


procedure Set_MessageQueue_Result(AMQBO: TNxCustomBusinessObject; AState: Integer; AResult: String);
begin
  AMQBO.SetFieldValueAsInteger('X_MQ_State', AState);
  AMQBO.SetFieldValueAsString('X_MQ_ResultMessage', AResult);
  AMQBO.Save;
end;


procedure Get_BillOfDelivery_IDs_SyncReady(AOS: TNxCustomObjectSpace; AIDs: TStringList);
begin
  AIDs.Clear;
  // ABRA stores bills of delivery as type 21; the outgoing MQ message is type 20.
  AOS.SQLSelect(
    'SELECT ID FROM StoreDocuments WHERE DocumentType = ' + QuotedStr('21') +
    ' AND PMState_ID = ' + QuotedStr(cMQ_BOD_PMState_ID_SYNC_READY), AIDs);
end;


function Get_BillOfDelivery_Sources(ABillOfDelivery: TNxCustomBusinessObject; var ATargetInstanceKey: String): TJSONSuperObject;
var
  mOrderIDs: TStringList;
  mOrderBO: TNxCustomBusinessObject;
  mSources, mSourceJSON: TJSONSuperObject;
  mExternal_ID, mOrgIdentNumber, mInstanceKey: String;
  mOrderIndex: Integer;
begin
  Result := nil;
  ATargetInstanceKey := '';
  mOrderBO := nil;
  mSourceJSON := nil;
  mSources := TJSONSuperObject.Create;
  mOrderIDs := TStringList.Create;
  try
    ABillOfDelivery.ObjectSpace.SQLSelect(
      'SELECT DISTINCT RO.ID FROM StoreDocuments2 SD2' +
      ' JOIN ReceivedOrders2 RO2 ON RO2.ID = SD2.ProvideRow_ID' +
      ' JOIN ReceivedOrders RO ON RO.ID = RO2.Parent_ID' +
      ' WHERE SD2.Parent_ID = ' + QuotedStr(ABillOfDelivery.OID), mOrderIDs);
    if mOrderIDs.Count = 0 then
      RaiseException('source.not_found bill_of_delivery_id=' + ABillOfDelivery.OID);

    mOrderBO := ABillOfDelivery.ObjectSpace.CreateObject(Class_ReceivedOrder);
    for mOrderIndex := 0 to mOrderIDs.Count - 1 do begin
      mOrderBO.Load(mOrderIDs.Strings[mOrderIndex], nil);
      mExternal_ID := mOrderBO.GetFieldValueAsString('X_MQ_External_ID');
      if NxIsEmptyOID(mExternal_ID) then
        RaiseException('source.missing X_MQ_External_ID received_order_id=' + mOrderBO.OID);
        
      mOrgIdentNumber := Trim(mOrderBO.GetFieldValueAsString('Firm_ID.OrgIdentNumber'));
      mInstanceKey := API_GetInstanceKey_By_OrgIdentNumber(mOrgIdentNumber);
      if ATargetInstanceKey = '' then
        ATargetInstanceKey := mInstanceKey;
      if ATargetInstanceKey <> mInstanceKey then
        RaiseException('source.multiple_instances bill_of_delivery_id=' + ABillOfDelivery.OID);

      mSourceJSON := TJSONSuperObject.Create;
      mSourceJSON.S['X_MQ_External_ID'] := mExternal_ID;
      mSourceJSON.S['OrgIdentNumber'] := mOrgIdentNumber;
      mSources.O[mOrderBO.OID] := mSourceJSON;
      mSourceJSON := nil;
    end;
    Result := mSources;
    mSources := nil;
  finally
    mSourceJSON.Free;
    mSources.Free;
    mOrderBO.Free;
    mOrderIDs.Free;
  end;
end;


procedure AutoSync_CreateAndSyncInvoice_DS(OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
var
 mList, mLogs:TStringList;
 i:integer;
 mFirm_ID, mSQL, mOrder_ID:String;
 mImportMan:TNxDocumentImportManager;
 mInputParams:TNxParameters;
 mParam:TNxParameter;
begin
  mList:=TStringList.Create;
  mLogs:=TStringList.Create;
  mFirm_ID:=OS.SQLSelectFirstAsString('Select id from firms where hidden=''N'' and firm_ID is null and OrgIdentNumber='+Quotedstr('53578341'),'');
  mSQL:=  'SELECT a.ID FROM StoreDocuments A JOIN Firms F ON F.ID=A.Firm_ID'#13#10 +
          'WHERE A.DocumentType=''21'''#13#10 +
          'AND ((((A.DOCQUEUE_ID IN ('+QuotedStr(cMQ_BOD_DocQueue_ID_DLDS)+')) )) AND (F.ID='+Quotedstr(mFirm_ID)+' OR ((F.Firm_ID IS NOT NULL) AND (F.Firm_ID='+Quotedstr(mFirm_ID)+'))) '#13#10 +
          'AND (((''A'' = ''A'') AND ((A.Finished = ''N'') AND (A.IsAvailableForDelivery = ''A''))) OR ((''A'' = ''N'') AND ((A.Finished ' +
          '= ''A'') OR (A.IsAvailAbleForDelivery = ''N''))))) order by a.docdate$date desc';
  OS.SQLSelect(mSQL,mList);
  if mList.count>0 then begin
              try
                      mOrder_ID:=OS.SQLSelectFirstAsString('Select distinct(provide_id) from storedocuments2 where parent_id='+QuotedStr(mList.Strings[0]),'');
                      mInputParams := TNxParameters.Create;
                      mParam := mInputParams.GetOrCreateParam(dtString, 'DocQueue_ID');
                      mParam.AsString := cMQ_II_DocQueue_ID_FVE;
                      if not(NxIsEmptyOID(mOrder_ID)) then begin
                       mParam := mInputParams.GetOrCreateParam(dtString, 'SelectedHeader');
                       mParam.AsString := mOrder_ID;
                      end else begin
                       mParam := mInputParams.GetOrCreateParam(dtString, 'SelectedHeader');
                       mParam.AsString := mList.Strings[0];
                      end;
                      mImportMan:=NxCreateDocumentImportManager(OS,Class_BillOfDelivery,Class_IssuedInvoice);
                      mImportMan.AddInputDocuments(mList);
                      mImportMan.LoadParams(mInputParams);
                      mImportMan.Execute;
                      mImportMan.OutputDocument.SetFieldValueAsString('DocQueue_ID', cMQ_II_DocQueue_ID_FVE);
                      mImportMan.OutputDocument.SetFieldValueAsString('Firm_ID',mFirm_ID);
                      mImportMan.OutputDocument.SetFieldValueAsString('Description','');
                      mImportMan.OutputDocument.save;
                      mLogs.add(mImportMan.OutputDocument.DisplayName);
              except
               mLogs.add(ExceptionMessage);
              end;

  end;
  mList.Free;
  Success := True;
  LogInfoStr := ''+NxCrLf+mLogs.Text;
  mLogs.free;
end;

procedure AutoSync_BillsOfDelivery_DS(OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
var
  mIDs: TStringList;
  mBO: TNxCustomBusinessObject;
  mSources, mDocumentJSON, mMessageQueueJSON, mResponseJSON: TJSONSuperObject;
  mTargetInstanceKey: String;
  mIndex: Integer;
begin
  Success := True;
  LogInfoStr := '';
  mIDs := TStringList.Create;
  try
    Get_BillOfDelivery_IDs_SyncReady(OS, mIDs);
    LogInfoStr := 'delivery_sync.loaded count=' + IntToStr(mIDs.Count) + NxCrLf;
    for mIndex := 0 to mIDs.Count - 1 do begin
      mBO := nil;
      mSources := nil;
      mDocumentJSON := nil;
      mMessageQueueJSON := nil;
      mResponseJSON := nil;
      try
        try
          mBO := OS.CreateObject(Class_BillOfDelivery);
          mBO.Load(mIDs.Strings[mIndex], nil);
          if mBO.GetFieldValueAsString('PMState_ID') = cMQ_BOD_PMState_ID_SYNC_READY then begin
            mSources := Get_BillOfDelivery_Sources(mBO, mTargetInstanceKey);
            mDocumentJSON := Create_BillOfDelivery_JSON(mBO, mSources);
            mMessageQueueJSON := TJSONSuperObject.Create;
            mMessageQueueJSON.S['X_MQ_DocumentType'] := '20';
            mMessageQueueJSON.S['X_MQ_SourceABRA'] := cMQ_SourceInstanceKey;
            mMessageQueueJSON.S['X_MQ_JSON'] := mDocumentJSON.AsString;
            // Same as SK -> CZ: POST creates MessageQueue in the destination ABRA.
            // Code, timestamps and default queue state are filled by the target BO.
            mResponseJSON := API_POST(OS, mTargetInstanceKey, mMessageQueueJSON, cMQ_API_MessageQueue_Endpoint, False);
            if not Is_API_PUT_Response_Successful(mResponseJSON) then
              RaiseException('delivery_sync.post_failed target=' + mTargetInstanceKey +
                ' error=' + Get_API_PUT_Response_ErrorMessage(mResponseJSON));
            mBO.PMChangeState(cMQ_BOD_PMState_ID_ZPRACOVAVA_SE);
            LogInfoStr := LogInfoStr + 'delivery_sync.sent id=' + mBO.OID +
              ' target=' + mTargetInstanceKey + ' state=processing response=' + mResponseJSON.AsString + NxCrLf;
          end;
        except
          Success := False;
          LogInfoStr := LogInfoStr + 'delivery_sync.error id=' + mIDs.Strings[mIndex] +
            ' error=' + ExceptionMessage + NxCrLf;
        end;
      finally
        mResponseJSON.Free;
        mMessageQueueJSON.Free;
        mDocumentJSON.Free;
        mSources.Free;
        mBO.Free;
      end;
    end;
  finally
    mIDs.Free;
  end;
end;





begin
end.
