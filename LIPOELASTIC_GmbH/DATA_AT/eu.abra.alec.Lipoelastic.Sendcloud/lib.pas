uses '.API', '.JSON';

function CreatePDMIssuedDoc(ABO: TNxCustomBusinessObject; var ALog: string;):string;
var
  mOS: TNxCustomObjectSpace;
  mPDMBO, mAddressBO: TNxCustomBusinessObject;
  mVarSymbol, mBankAccount_ID, mConstSymbol_ID, mTransportationType_ID, mPaymentType_ID: string;
  mPostProvider_ID, mIssuedContent_ID, mPriceList_ID, mExternalNumber, mPDMIssuedDoc_ID: string;
  mDeliveryAddress_ID, mRelDef_ID, mUserXLink: string;
  mPaymentKind, mRelDef: integer;
  mTotalCost: Extended;
begin
  Result:= '';

  mOS:= ABO.ObjectSpace;

  mVarSymbol:= '';
  mBankAccount_ID:= '';
  mConstSymbol_ID:= '';
  mDeliveryAddress_ID:= '';
  mTransportationType_ID:= '';
  mPaymentType_ID:= '';
  mPaymentKind:= 0;
  mTotalCost:= 0;
  mPostProvider_ID:= '';
  mIssuedContent_ID:= '';
  mPriceList_ID:= '';
  mExternalNumber:= '';
  mRelDef_ID:= '';

  case ABO.CLSID of
    Class_BillOfDelivery: mRelDef:= 1438;
    Class_IncomingTransfer: mRelDef:= 1439;
  end;

  if not FetchDataForPDMIssuedDoc(ABO, mVarSymbol, mBankAccount_ID, mConstSymbol_ID, mDeliveryAddress_ID,
                                  mTransportationType_ID, mPaymentType_ID, mPaymentKind,
                                  mTotalCost, mExternalNumber, ALog)
  then
  begin
    LogMessage('ERROR', 'CreatePDMIssuedDoc', 'Error occured while creating Sent mail document. Unable to retrieve data from order in', ALog);
    Result:= '';
    exit;
  end;

  mPDMBO:= mOS.CreateObject(Class_PDMIssuedDoc);
  try
    try
      mPDMBO.New;
      mPDMBO.Prefill;
      mPDMBO.SetFieldValueAsString('DocQueue_ID', cPDM_DOCQUEUE_ID);
      mPDMBO.SetFieldValueAsString('Sender_ID', cPDM_SENDER_ID);

      mPDMBO.SetFieldValueAsString('Firm_ID', ABO.GetFieldValueAsString('Firm_ID'));
      mPDMBO.SetFieldValueAsString('FirmOffice_ID', ABO.GetFieldValueAsString('FirmOffice_ID'));
      mPDMBO.SetFieldValueAsString('Person_ID', ABO.GetFieldValueAsString('Person_ID'));

      if NxIsEmptyOID(mDeliveryAddress_ID) then
        mPDMBO.SetFieldValueAsInteger('TargetAddressType', cPDM_TARGET_ADDRESS_FIRMOFFICE)
      else
      begin
        mPDMBO.SetFieldValueAsInteger('TargetAddressType', cPDM_TARGET_ADDRESS_OTHER);
        mAddressBO:= mOS.CreateObject(Class_Address);
        try
          mAddressBO.Load(mDeliveryAddress_ID, nil);
          mPDMBO.SetFieldValueAsString('TargetAddress_ID.Street', mAddressBO.GetFieldValueAsString('Street'));
          mPDMBO.SetFieldValueAsString('TargetAddress_ID.City', mAddressBO.GetFieldValueAsString('City'));
          mPDMBO.SetFieldValueAsString('TargetAddress_ID.PostCode', mAddressBO.GetFieldValueAsString('PostCode'));
          mPDMBO.SetFieldValueAsString('TargetAddress_ID.PhoneNumber1', mAddressBO.GetFieldValueAsString('PhoneNumber1'));
          mPDMBO.SetFieldValueAsString('TargetAddress_ID.Recipient', mAddressBO.GetFieldValueAsString('Recipient'));
          mPDMBO.SetFieldValueAsString('TargetAddress_ID.Email', mAddressBO.GetFieldValueAsString('Email'));
          mPDMBO.SetFieldValueAsString('TargetAddress_ID.CountryCode', mAddressBO.GetFieldValueAsString('CountryCode'));
        finally
          mAddressBO.Free;
        end;
      end;

      //test
      mPostProvider_ID:= ABO.GetFieldValueAsString('TransportationType_ID.X_PDMPostProvider_ID');
      if NxIsEmptyOID(mPostProvider_ID) then mPostProvider_ID:= '1000000000';

      mIssuedContent_ID:= ABO.GetFieldValueAsString('TransportationType_ID.X_PDMIssuedContentType_ID');
      if NxIsEmptyOID(mIssuedContent_ID) then mIssuedContent_ID:= '2700000000';

      mPDMBO.SetFieldValueAsString('PostProvider_ID', mPostProvider_ID);
      mPDMBO.SetFieldValueAsString('IssuedContent_ID', mIssuedContent_ID);
      mPDMBO.SetFieldValueAsString('PriceList_ID', cPDM_PRICELIST_ID);
      //**********************

      if mTotalCost < 1 then
        mTotalCost:= 1;
      mPDMBO.SetFieldValueAsFloat('Amount', mTotalCost);

      mPDMBO.SetFieldValueAsString('VarSymbol', mVarSymbol);
      mPDMBO.SetFieldValueAsString('BankAccount_ID', mBankAccount_ID);
      mPDMBO.SetFieldValueAsString('ConstSymbol_ID', mConstSymbol_ID);

      mPDMBO.SetFieldValueAsString('X_ExternalNumber', mExternalNumber);
      if ABO.GetFieldValueAsInteger('X_NumberOfParcels') = 0 then
        mPDMBO.SetFieldValueAsInteger('X_NumberOfParcels', 1)
      else
        mPDMBO.SetFieldValueAsInteger('X_NumberOfParcels', ABO.GetFieldValueAsInteger('X_NumberOfParcels'));

      //NxShowSimpleMessage(mPDMBO.GetFieldValueAsString('TargetAddress_ID.Street'), nil);

      mPDMBO.Save;

      //TODO reldef udělat variabilní a ověřit vytvoření
      mRelDef_ID:= CreateNewRelation(mOS, mRelDef, mPDMBO.OID, ABO.OID);
      if NxIsEmptyOID(mRelDef_ID) then
        LogMessage('ERROR', 'CreatePDMIssuedDoc', 'Error occured during the creation of a document relation', ALog);

      mUserXLink:= CreateUserXLink(mOS, Class_PDMIssuedDoc, Class_BillOfDelivery, mPDMBO.OID, ABO.OID, '');
      if NxIsEmptyOID(mUserXLink) then
        LogMessage('ERROR', 'CreatePDMIssuedDoc', 'Error occured during the creation of a user x link relation', ALog);

      if not NxIsBlank(ALog) then
        CFxLog.SaveLog(NxCreateContext_1(ABO), 'PDMID', 'PDMID_ERROR', ALog, ltScripting, Now);
    except
      LogMessage('ERROR', 'CreatePDMIssuedDoc', ExceptionMessage, ALog);
    end;
  finally
    mPDMBO.Free;
  end;

end;


function CreateNewRelation(AOS: TNxCustomObjectSpace; ARelDef: Integer; ALeftSide_ID, ARightSide_ID: string): string;
var
  mBO: TNxCustomBusinessObject;
begin
  Result:= '';
  mBO := AOS.CreateObject(Class_Relation);
  try
    mBO.New;
    mBO.Prefill;
    mBO.SetFieldValueAsInteger('Rel_Def', ARelDef);
    mBO.SetFieldValueAsString('LeftSide_ID', ALeftSide_ID);
    mBO.SetFieldValueAsString('RightSide_ID', ARightSide_ID);
    mBO.Save;
    Result:= mBO.OID;
  finally
    mBO.Free;
  end;
end;


function FetchDataForPDMIssuedDoc(const ABO: TNxCustomBusinessObject; var AVarSymbol: string;
                                    var ABankAccount_ID: string; var AConstSymbol_ID: string;
                                    var ADeliveryAdress_ID: string;
                                    var ATransportationType_ID: string; var APaymentType_ID: string;
                                    var APaymentKind: integer; var ATotalCost: Extended;
                                    var AExternalNumber: string; var ALog: string):boolean;
var
  mROBO: TNxCustomBusinessObject;
  mReceivedOrderID: string;
begin
  Result:= true;
  mReceivedOrderID:= '';

  if ABO.CLSID = Class_BillOfDelivery then
  begin
    mReceivedOrderID:= ABO.ObjectSpace.SQLSelectFirstAsString(Format(
      ' SELECT TOP 1 Provide_ID FROM StoreDocuments2 WHERE Parent_ID = ''%s'' ORDER BY PosIndex ',
      [ABO.OID]));
  end;

  if ABO.CLSID = Class_IncomingTransfer then
  begin
    mReceivedOrderID:= ABO.ObjectSpace.SQLSelectFirstAsString(Format(
      ' SELECT TOP 1 OT2.Provide_ID FROM StoreDocuments2 OT2 '+
      ' JOIN StoreDocuments2 IT2 ON IT2.ProvideRow_ID = OT2.ID '+
      ' WHERE IT2.Parent_ID = ''%s''',
      [ABO.OID]));
  end;

    if NxIsEmptyOID(mReceivedOrderID) then
    begin
      LogMessage('ERROR', 'FetchDataForPDMIssuedDoc', ABO.DisplayName + ' - Unable to retrieve data from order in.', ALog);
      Result:= false;
      exit;
    end;

    mROBO:= ABO.ObjectSpace.CreateObject(Class_ReceivedOrder);
    try
      mROBO.Load(mReceivedOrderID, nil);
      ABankAccount_ID:= mROBO.GetFieldValueAsString('BankAccount_ID');
      AConstSymbol_ID:= mROBO.GetFieldValueAsString('ConstSymbol_ID');
      ADeliveryAdress_ID:= mROBO.GetFieldValueAsString('DeliveryAddress_ID');
      ATransportationType_ID:= mROBO.GetFieldValueAsString('TransportationType_ID');
      APaymentType_ID:= mROBO.GetFieldValueAsString('PaymentType_ID');
      APaymentKind:= mROBO.GetFieldValueAsInteger('PaymentType_ID.PaymentKind');
      AExternalNumber:= mROBO.GetFieldValueAsString('ExternalNumber');
      if NxIsBlank(AExternalNumber) then
        AExternalNumber:= mROBO.DisplayName;

      ATotalCost:= mROBO.GetFieldValueAsFloat('Amount');
    finally
      mROBO.Free;
    end;


end;



procedure SendPreparedPDMDocsToSendcloud(OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
var
  mSQL, mLog, mStatusCode, mPDMIssuedDoc_ID, mExternalNumber, mSendcloudStatus_ID, mTrackingNumber, mTrackingURL: string;
  mErrors, mSendcloudID, mReference, mResultString: String;
  mList: TStringList;
  i: integer;
  mJSON, mResultJSON: TJSONSuperObject;
  mPDMBO: TNxCustomBusinessObject;
begin
  Success := True;
  LogInfoStr := '';
  mLog:= '';
  mStatusCode:= '';
  mExternalNumber:= '';
  mSendcloudID:= '';
  mResultString:= '';


  mList:= TStringList.Create;
  try
    try
      mSQL:= 'SELECT ID FROM PDMIssuedDocs WHERE X_SC_State_ID IS NULL AND X_ErrorMessage = '''' ';
      OS.SQLSelect(mSQL, mList);

      if mList.Count = 0 then exit;

      mJSON:= CreateParcelsBatch_JSON(OS, mList, Class_PDMIssuedDoc, mLog);
      if mJSON.DataType = jtNull then
      begin
        RaiseException('Cannot create batch JSON - '+ mLog);
        exit;
      end;

      if not NxIsBlank(mLog) then
        mLog:= mLog + 'JSONBatch was created with errors above' + nxCrLf;

      mResultJSON:= CallAPI(OS, 'POST', 'parcels', mStatusCode, mLog, mJSON);

      if mStatusCode = '400' then
      begin
        if Assigned(mResultJSON) then
          mResultString:= mResultJSON.AsString;
        Success:= false;
        mLog:= mLog + 'Status code: ' + mStatusCode + nxCrLf + 'JSON: ' + mJSON.AsString + nxCrLf + 'Response: '+mResultString;

        mPDMBO:= OS.CreateObject(Class_PDMIssuedDoc);
        try
          for i:= 0 to mList.Count -1 do
          begin
            mPDMBO.Load(mList[i], nil);
            mPDMBO.SetFieldValueAsString('X_ErrorMessage', 'Request: '+ nxCrLf + mJSON.AsString + nxCrLf + 'Response: '+ nxCrLf + mResultString);
            mPDMBO.Save;
          end;
        finally
          mPDMBO.Free;
        end;
      end else
      begin
        mPDMBO:= OS.CreateObject(Class_PDMIssuedDoc);
        try
          mLog:= mLog + 'Posted parcels ('+IntToStr(mResultJSON.A['parcels'].Length)+'):'+nxCrLf;

          //At first we go through successfull posts
          for i:= 0 to mResultJSON.A['parcels'].Length -1 do
          begin
            mErrors:= '';
            mReference:= '';

            mExternalNumber:= mResultJSON.A['parcels'].O[i].S['order_number'];
            mSendcloudID:= mResultJSON.A['parcels'].O[i].S['id'];
            mReference:= mResultJSON.A['parcels'].O[i].S['reference'];

            //mPDMIssuedDoc_ID:= GetDocumentIDFromDisplayName(OS, mExternalNumber, Class_PDMIssuedDoc);
            {
            if not NxIsBlank(mReference) then
              mPDMIssuedDoc_ID:= OS.SQLSelectFirstAsString(Format('SELECT ID FROM PDMIssuedDocs WHERE ID = ''%s'' ', [mReference]));
            if NxIsEmptyOID(mPDMIssuedDoc_ID) then
              mPDMIssuedDoc_ID:= OS.SQLSelectFirstAsString(Format('SELECT ID FROM PDMIssuedDocs WHERE X_ExternalNumber = ''%s'' ', [mExternalNumber]));
            }

            mSendcloudStatus_ID:= GetSendcloudStatusID(OS, mResultJSON.A['parcels'].O[i].O['status'].I['id']);
            mTrackingNumber:= mResultJSON.A['parcels'].O[i].S['tracking_number'];
            mTrackingURL:= mResultJSON.A['parcels'].O[i].S['tracking_url'];
            if mResultJSON.A['parcels'].O[i].N['errors'].DataType <> jtNull then
              mErrors:= mResultJSON.A['parcels'].O[i].O['errors'].AsString;

            mPDMIssuedDoc_ID:= GetPDMDocument_ID(NxCreateContext(OS), '', mExternalNumber, '', mReference);
            if NxIsEmptyOID(mPDMIssuedDoc_ID) then
            begin
              LogMessage('ERROR', 'SendPreparedPDMDocsToSendcloud', Format('Received order with external number %s not found'+nxCrLf+
                                  'Sendcloud ID: %s', [mExternalNumber, mSendcloudID]), mLog);
              continue;
            end;

            if not UpdatePDMIssuedDocState(NxCreateContext(OS), mPDMIssuedDoc_ID, mSendcloudStatus_ID, mTrackingNumber, mTrackingURL, mErrors, mSendcloudID, mLog) then
            begin
              LogMessage('ERROR', 'SendPreparedPDMDocsToSendcloud', Format('Failed to update PDMIssuedDoc ID: %s'+nxCrLf+
                                  'Sendcloud ID: %s', [mReference, mSendcloudID]), mLog);
            end else
            begin
              mLog:= mLog + mExternalNumber + ' - SC ID: ' + mSendcloudID + ' - OK' + nxCrLf;
            end;
          end;

          //Now we go through failed parcels
          if mResultJSON.N['failed_parcels'].DataType <> jtNull then
          begin
            Success:= false;
            mLog:= mLog + 'Failed parcels:'+nxCrLf;

            for i:= 0 to mResultJSON.A['failed_parcels'].Length -1 do
            begin
              mErrors:= '';
              mReference:= '';
              mExternalNumber:= mResultJSON.A['failed_parcels'].O[i].S['order_number'];
              mSendcloudID:= mResultJSON.A['failed_parcels'].O[i].S['id'];
              mReference:= mResultJSON.A['parcels'].O[i].S['reference'];
              mSendcloudStatus_ID:= GetSendcloudStatusID(OS, mResultJSON.A['failed_parcels'].O[i].O['status'].I['id']);

              if mResultJSON.A['failed_parcels'].O[i].N['errors'].DataType <> jtNull then
              begin
                mErrors:= mResultJSON.A['failed_parcels'].O[i].O['errors'].AsString;
                mLog:= mLog + mExternalNumber + ' - SC ID: ' + mSendcloudID + ' - ' + mErrors + nxCrLf;
              end;

              mPDMIssuedDoc_ID:= GetPDMDocument_ID(NxCreateContext(OS), '', mExternalNumber, '', mReference);
              if NxIsEmptyOID(mPDMIssuedDoc_ID) then
              begin
                LogMessage('ERROR', 'SendPreparedPDMDocsToSendcloud', Format('Received order with external number %s not found' + nxCrLf +
                                          'Sendcloud ID: %s', [mExternalNumber, mSendcloudID]), mLog);
                continue;
              end;

              if not UpdatePDMIssuedDocState(NxCreateContext(OS), mPDMIssuedDoc_ID, mSendcloudStatus_ID, '', '', mErrors, mSendcloudID, mLog) then
              begin
                LogMessage('ERROR', 'SendPreparedPDMDocsToSendcloud', Format('Failed to update PDMIssuedDoc ID: %s'+nxCrLf+
                                    'Sendcloud ID: %s', [mReference, mSendcloudID]), mLog);
              end else
              begin
                mLog:= mLog + mExternalNumber + ' - SC ID: ' + mSendcloudID + ' - OK' + nxCrLf;
              end;

            end;
          end;

        finally
          mPDMBO.Free;
        end;

      end;
      LogInfoStr:= LogInfoStr + mLog;

      if CFxNxRuntime.NxGetEnvironmentType = reRuntimeExe then
        NxShowSimpleMessage(LogInfoStr, nil);
    except
      LogInfoStr:= LogInfoStr + ExceptionMessage + nxCrLf;
    end;
  finally
    mList.Free;
    mJSON.Free;
    mResultJSON.Free;
  end;
end;


function GetDocumentIDFromDisplayName(AOS: TNxCustomObjectSpace; AOrderNumber, ACLSID: string;): string;
var
  mParams: TNxParameters;
  mFakeBO: TNxCustomBusinessObject;
  mDashPos, mSlashPos: Integer;
  mSQL, mTableName: String;
  mList: TStringList;
begin
  Result:= '';
  if Pos('/', AOrderNumber) = 0 then exit;

  mDashPos:= Pos('-', AOrderNumber);
  mSlashPos:= Pos('/', AOrderNumber);

  mList:= TStringList.Create;
  mParams:= TNxParameters.Create;
  mFakeBO:= AOS.CreateObject(ACLSID);
  try
    mParams.GetOrCreateParam(dtString, 'TableName').AsString:= NxGetTableNameForPersistCLSID(mFakeBO.PersistCLSID);
    mParams.GetOrCreateParam(dtString, 'DocQueueCode').AsString:= Copy(AOrderNumber, 1, mDashPos -1);
    mParams.GetOrCreateParam(dtInteger, 'OrdNumber').AsInteger:= StrToInt(Copy(AOrderNumber, mDashPos + 1, mSlashPos - mDashPos - 1));
    mParams.GetOrCreateParam(dtString, 'PeriodCode').AsString:= Copy(AOrderNumber, mSlashPos + 1, Length(AOrderNumber));

    mSQL:=  ' SELECT A.ID FROM :TableName A '+
            ' JOIN DocQueues DQ ON DQ.ID = A.DocQueue_ID '+
            ' JOIN Periods PE ON PE.ID = A.Period_ID '+
            ' WHERE DQ.Code = :DocQueueCode '+
            ' AND A.OrdNumber = :OrdNumber '+
            ' AND PE.Code = :PeriodCode ';

    AOS.SQLSelect(mSQL, mList, mParams);

    Result:= mList[0];
  finally
    mParams.Free;
    mList.Free;
    mFakeBO.Free;
  end;
end;



function GetPDMDocument_ID(AContext: TNxContext; ATrackingNumber, AOrderNumber, AExternalNumber, AReference: string): string;
begin
  Result:= '';
  if not NxIsBlank(AReference) then
    Result:= AContext.SQLSelectFirstAsString(Format('SELECT ID FROM PDMIssuedDocs WHERE ID = ''%s''', [AReference]));

  if NxIsBlank(Result) and (not(NxIsBlank(AOrderNumber))) then
    Result:= AContext.SQLSelectFirstAsString(Format('SELECT ID FROM PDMIssuedDocs WHERE X_ExternalNumber = ''%s''', [AOrderNumber]));

  if NxIsBlank(Result) and (not(NxIsBlank(AExternalNumber))) then
    Result:= AContext.SQLSelectFirstAsString(Format('SELECT ID FROM PDMIssuedDocs WHERE X_ExternalNumber = ''%s''', [AExternalNumber]));

  if NxIsBlank(Result) and (not(NxIsBlank(ATrackingNumber))) then
    Result:= AContext.SQLSelectFirstAsString(Format('SELECT ID FROM PDMIssuedDocs WHERE X_TrackingNumber = ''%s''', [ATrackingNumber]));
end;


function UpdatePDMIssuedDocState(AContext: TNxContext; APDMIssuedDoc_ID, AStatus_ID, ATrackingNumber, ATrackingURL, AError, ASendcloudID: string; var ALog: string):boolean;
var
  mPDMIssuedDocBO: TNxCustomBusinessObject;
begin
  Result:= false;
  mPDMIssuedDocBO:= AContext.GetObjectSpace.CreateObject(Class_PDMIssuedDoc);
  try
    try
      mPDMIssuedDocBO.Load(APDMIssuedDoc_ID, nil);

      mPDMIssuedDocBO.SetFieldValueAsString('X_SC_State_ID', AStatus_ID);

      if NxIsBlank(mPDMIssuedDocBO.GetFieldValueAsString('X_TrackingNumber')) then
        mPDMIssuedDocBO.SetFieldValueAsString('X_TrackingNumber', ATrackingNumber);

      if NxIsBlank(mPDMIssuedDocBO.GetFieldValueAsString('X_TrackingURL')) then
        mPDMIssuedDocBO.SetFieldValueAsString('X_TrackingURL', ATrackingURL);

      if NxIsBlank(mPDMIssuedDocBO.GetFieldValueAsString('X_ErrorMessage')) and (Length(AError) > 2) then
        mPDMIssuedDocBO.SetFieldValueAsString('X_ErrorMessage', AError);

      if NxIsBlank(mPDMIssuedDocBO.GetFieldValueAsString('X_ExternalID')) then
        mPDMIssuedDocBO.SetFieldValueAsString('X_ExternalID', ASendcloudID);

      mPDMIssuedDocBO.Save;
      Result:= True;
    except
      ALog:= ALog + ExceptionMessage + nxCrLf;
    end;
  finally
    mPDMIssuedDocBO.Free;
  end;
end;



function GetSendcloudStatusID(AOS: TNxCustomObjectSpace; AStatusInt: Integer): string;
const
  mSQL = 'SELECT ID FROM DefRollData WHERE Hidden = ''N'' AND CLSID = ''%s'' AND Code = ''%s''';
begin
  Result:= AOS.SQLSelectFirstAsString(Format(mSQL, [Class_BO_Sendcloud_ParcelStates, IntToStr(AStatusInt)]));
end;


function CreateUserXLink(AOS: TNxCustomObjectSpace; ASourceClass, ADestinationClass: TNxPackedGuid; ASourceID, ADestinationID, ADescription: string;):string;
var
  mUserXLink: TNxCustomBusinessObject;
begin
  Result:= '';
  mUserXLink := AOS.CreateObject(Class_UserXLink);
  try
    mUserXLink.New;
    mUserXLink.Prefill;
    mUserXLink.SetFieldValueAsString('SourceCLSID', ASourceClass);
    mUserXLink.SetFieldValueAsString('Source_ID', ASourceID);
    mUserXLink.SetFieldValueAsString('DestinationCLSID', ADestinationClass);
    mUserXLink.SetFieldValueAsString('Destination_ID', ADestinationID);
    mUserXLink.SetFieldValueAsBoolean('DisplayAsSystem', True);
    mUserXLink.SetFieldValueAsString('Description', ADescription);
    mUserXLink.SetFieldValueAsBoolean('OneSided', True);
    mUserXLink.Save;
    Result:= mUserXLink.OID;
  finally
    mUserXLink.Free;
  end;
end;







begin
end.