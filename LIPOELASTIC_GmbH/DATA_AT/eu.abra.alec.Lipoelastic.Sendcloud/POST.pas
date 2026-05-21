uses '.lib';


{POST_ParcelStatusChanged}

procedure POST_ParcelStatusChanged(AContext:TNxContext; ARequest: TAPIRequest; AResponse: TAPIResponse);
var
  mHeaders: TStringList;
  i, mStatusCode, mParcelStatus: Integer;
  mParcelJSON, mResponseJSON: TJSONSuperObject;
  mOrderNumber, mExternalNumber, mTrackingNumber, mPDMDoc_ID, mStatus_ID, mLog, mTrackingURL, mReference, mSendcloudID: string;
begin
  mLog:= '';
  mOrderNumber:= '';
  mExternalNumber:= '';
  mTrackingNumber:= '';
  mTrackingURL:= '';
  mReference:= '';
  mSendcloudID:= '';

  AResponse.SetHeader('Content-Type','application/json');

  mParcelJSON:= TJSONSuperObject.Create;
  mResponseJSON:= TJSONSuperObject.Create;
  try
    mParcelJSON:= TJSONSuperObject.ParseString(ARequest.Body, true);

    if mParcelJSON.O['parcel'].DataType <> jtNull then
    begin
      if mParcelJSON.N['parcel.tracking_number'].DataType <> jtNull then
        mTrackingNumber:= mParcelJSON.S['parcel.tracking_number'];

      if mParcelJSON.N['parcel.tracking_url'].DataType <> jtNull then
        mTrackingURL:= mParcelJSON.S['parcel.tracking_url'];

      if mParcelJSON.N['parcel.order_number'].DataType <> jtNull then
        mOrderNumber:= mParcelJSON.S['parcel.order_number'];

      if mParcelJSON.N['parcel.external_order_id'].DataType <> jtNull then
        mExternalNumber:= mParcelJSON.S['parcel.external_order_id'];

      if mParcelJSON.N['parcel.reference'].DataType <> jtNull then
        mReference:= mParcelJSON.S['parcel.reference'];
      if mParcelJSON.N['parcel.id'].DataType <> jtNull then
        mSendcloudID:= mParcelJSON.S['parcel.id'];
    end;

    mPDMDoc_ID:= GetPDMDocument_ID(AContext, mTrackingNumber, mOrderNumber, mExternalNumber, mReference);
    if NxIsEmptyOID(mPDMDoc_ID) then
    begin
      AResponse.Status:= 200;    //původně 404 - změněno na 200 - protože občas je založená samotná odeslaná pošta, která není v AbraGen
      mResponseJSON.S['error']:= 'PDMIssuedDoc not found';
      exit;
    end;

    mStatusCode:= mParcelJSON.I['parcel.status.id'];

    mStatus_ID:= GetSendcloudStatusID(AContext.GetObjectSpace, mStatusCode);
    if NxIsEmptyOID(mStatus_ID) then
    begin
      AResponse.Status:= 404;
      mResponseJSON.S['error']:= 'Unable to find Sendcloud status ID';
      exit;
    end;

    if not (UpdatePDMIssuedDocState(AContext, mPDMDoc_ID, mStatus_ID, mTrackingNumber, mTrackingURL, '', mSendcloudID, mLog)) then
    begin
      if (Pos('byl změněn jiným uživatelem', mLog) > 0) and (not(UpdatePDMIssuedDocState(AContext, mPDMDoc_ID, mStatus_ID, mTrackingNumber, mTrackingURL, '', mSendcloudID, mLog))) then
      begin
        AResponse.Status:= 403;
        mResponseJSON.S['error']:= Format('Updating PDMIssuedDocState failed with exception: %s', [mLog]);
        exit;
      end;
    end;

    if not (UpdateBillOfDelivery(AContext, mPDMDoc_ID, mTrackingNumber, mLog)) then
    begin
      //není až tak důležité, takže jen na to upozorníme
      mResponseJSON.S['error']:= Format('Updating BillOfDelivery with tracking number failed with exception: %s', [mLog]);
    end;

    mResponseJSON.S['id']:= mPDMDoc_ID;
    mResponseJSON.S['status']:= 'PDMIssuedDoc updated';

    AResponse.Status:= 200;

    //CFxLog.SaveLog(AContext, 'LOG-SC', 'SendCloud-webhook', 'Request:' + nxCrLf + ARequest.Body + 'Response:' + nxCrLf + mResponseJSON.AsString, ltScripting, Now);
  finally
    AResponse.Body:= mResponseJSON.AsString;
    if mResponseJSON.N['error'].DataType <> jtNull then
      CFxLog.SaveLog(AContext, 'LOG-SC', 'SendCloud-webhook', 'Request:' + nxCrLf + ARequest.Body + nxCrLf + nxCrLf + 'Response:' + nxCrLf + AResponse.Body, ltScripting, Now);

    mResponseJSON.Free;
    mParcelJSON.Free;
  end;
end;



function UpdateBillOfDelivery(AContext: TNxContext; APDMIssuedDoc_ID, ATrackingNumber: string; var ALog: string): Boolean;
var
  mBillOfDelivery_ID: string;
  mBODBO: TNxCustomBusinessObject;
begin
  Result:= False;
  mBillOfDelivery_ID:= AContext.GetObjectSpace.SQLSelectFirstAsString(Format('SELECT R.RightSide_ID FROM Relations R WHERE R.REL_DEF = 1438 AND R.LeftSide_ID = ''%s''',[APDMIssuedDoc_ID]));
  if NxIsEmptyOID(mBillOfDelivery_ID) then
    exit;

  mBODBO:= AContext.GetObjectSpace.CreateObject(Class_BillOfDelivery);
  try
    try
      mBODBO.Load(mBillOfDelivery_ID, nil);

      if NxIsBlank(mBODBO.GetFieldValueAsString('X_TrackingNumber')) then
      begin
        mBODBO.SetFieldValueAsString('X_TrackingNumber', ATrackingNumber);
        mBODBO.Save;
      end;
      Result:= True;
    except
      ALog:= ALog + ExceptionMessage + nxCrLf;
    end;
  finally
    mBODBO.Free;
  end;
end;


begin
end.