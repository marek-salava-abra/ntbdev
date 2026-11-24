uses '.const', 'eu.abra.PostProviders.uImportManager';


function API_GetInstanceKey_By_VATIdentNumber(AVATIdentNumber: String): String;
begin
  Result := AnsiLeftStr(AVATIdentNumber, 2);
end;


// Compatibility helper; callers will migrate to full VAT identification.
function API_GetInstanceKey_By_OrgIdentNumber(AOrgIdentNumber: String): String;
begin
  Result := '';
  // The instance key selects the existing URL and authentication in secure store.
  case Trim(AOrgIdentNumber) of
    '53578341': Result := 'SK';
  else
    RaiseException('api.instance_not_mapped OrgIdentNumber=' + AOrgIdentNumber);
  end;
end;


procedure API_LoadConnection(AOS: TNxCustomObjectSpace; AInstanceKey: String; var AURL: String; var AAuthorization: String);
var
  mURLKey, mAuthorizationKey: String;
begin
  AURL := '';
  AAuthorization := '';
  if not Assigned(AOS) then
    RaiseException('ObjectSpace pro nacteni konfigurace API neni prirazen.');
  mURLKey := cAPI_SECURESTORE_KEY_PREFIX + AInstanceKey + cAPI_URL_SECURESTORE_KEY_SUFFIX;
  mAuthorizationKey := cAPI_SECURESTORE_KEY_PREFIX + AInstanceKey + cAPI_AUTHENTICATION_SECURESTORE_KEY_SUFFIX;

  if not AOS.ReadFromSecureStore(mURLKey, AURL) then
    RaiseException('V bezpecnem ulozisti nebyl nalezen klic ' + mURLKey + '.');
  if NxIsBlank(AURL) then
    RaiseException('api.connection_url_empty key=' + mURLKey);
  if not AOS.ReadFromSecureStore(mAuthorizationKey, AAuthorization) then
    RaiseException('V bezpecnem ulozisti nebyl nalezen klic ' + mAuthorizationKey + '.');
  if NxIsBlank(AAuthorization) then
    RaiseException('api.connection_authentication_empty key=' + mAuthorizationKey);
end;


procedure API_LoadConnection_By_VATIdentNumber(AOS: TNxCustomObjectSpace; AVATIdentNumber: String;
  var AInstanceKey: String; var AURL: String; var AAuthorization: String);
begin
  AInstanceKey := '';
  AURL := '';
  AAuthorization := '';
  AInstanceKey := API_GetInstanceKey_By_VATIdentNumber(AVATIdentNumber);
  API_LoadConnection(AOS, AInstanceKey, AURL, AAuthorization);
end;



function API_BuildURL(ABaseURL, APath: String): String;
var
  mBaseURL, mPath: String;
begin
  mBaseURL := Trim(ABaseURL);
  mPath := Trim(APath);

  if mPath = '' then begin
    Result := mBaseURL;
    Exit;
  end;

  if Copy(mBaseURL, Length(mBaseURL), 1) = '/' then begin
    if Copy(mPath, 1, 1) = '/' then begin
      Result := mBaseURL + Copy(mPath, 2, Length(mPath) - 1);
    end else begin
      Result := mBaseURL + mPath;
    end;
  end else begin
    if Copy(mPath, 1, 1) = '/' then begin
      Result := mBaseURL + mPath;
    end else begin
      Result := mBaseURL + '/' + mPath;
    end;
  end;
end;


function API_Result(AJSON: TJSONSuperObject): TJSONSuperObject;
var
  mWinHTTP: Variant;
begin
  try
    mWinHTTP := CreateOleObject('WinHttp.WinHttpRequest.5.1');
    mWinHTTP.Open('POST', 'https://log-api.eu.newrelic.com/log/v1');
    mWinHTTP.SetRequestHeader('Content-Type', 'application/json');
    mWinHTTP.SetRequestHeader('Api-Key', 'eu01xx9184505e1c59528b186a0dd8edFFFFNRAL');
    mWinHTTP.Send(AJSON.AsJson);
    Result := TJSONSuperObject.ParseString(mWinHTTP.ResponseText, True);
  except
    Result := TJSONSuperObject.Create;
    Result.S['error'] := 'error';
  end;
end;

function API_FoxEntry_POST(var AOS:TNxCustomObjectSpace;var aURL:string; var aInputJSON: TJSONSuperObject): TJSONSuperObject;
var
  mWinHTTP: Variant;
  mFoxToken: string;
begin
  try
    mWinHTTP := CreateOleObject('WinHttp.WinHttpRequest.5.1');
    mWinHTTP.Open('POST', 'https://api.foxentry.com/'+aURL);
    mWinHTTP.SetRequestHeader('Content-Type', 'application/json');
    mWinHTTP.SetRequestHeader('Api-Key', 'Bearer '+mFoxToken);
    mWinHTTP.Send(AJSON.AsJson);
    Result := TJSONSuperObject.ParseString(mWinHTTP.ResponseText, True);
  except
    Result := TJSONSuperObject.Create;
    Result.S['error'] := 'error';
  end;
end;


function API_Request(AHTTPMethod, AURL, AAuthorization, APayload, ACategory, AInstanceKey: String; ALogResult: Boolean): TJSONSuperObject;
var
  mWinHTTP: Variant;
  mResultJSON: TJSONSuperObject;
  mHTTPStatus: Integer;
  mResponseText: String;
begin
  mHTTPStatus := 0;
  mResponseText := '';
  try
    mWinHTTP := CreateOleObject('WinHttp.WinHttpRequest.5.1');
    mWinHTTP.Open(AHTTPMethod, AURL);
    mWinHTTP.SetRequestHeader('Content-Type', 'application/json');
    mWinHTTP.SetRequestHeader('Authorization', 'Basic ' + AAuthorization);
    if APayload = '' then begin
      mWinHTTP.Send();
    end else begin
      mWinHTTP.Send(APayload);
    end;

    mHTTPStatus := StrToInt(mWinHTTP.Status);
    mResponseText := mWinHTTP.ResponseText;

    if ALogResult then begin
      mResultJSON := TJSONSuperObject.Create;
      mResultJSON.S['Category'] := ACategory;
      mResultJSON.S['InstanceKey'] := AInstanceKey;
      mResultJSON.S['ServiceName'] := cServiceName;
      mResultJSON.I['HTTPStatus'] := mHTTPStatus;
      mResultJSON.S['InputJSON'] := '#' + APayload + '#';
    end;

    if (mHTTPStatus >= 200) and (mHTTPStatus < 300) then begin
      if Trim(mResponseText) = '' then begin
        Result := TJSONSuperObject.Create;
        Result.I['HTTPStatus'] := mHTTPStatus;
      end else begin
        Result := TJSONSuperObject.ParseString(mResponseText, True);
      end;
      if ALogResult then begin
        mResultJSON.S['Status'] := 'OK';
      end;
    end else begin
      Result := TJSONSuperObject.Create;
      Result.S['ID'] := '';
      Result.S['status'] := 'error';
      Result.S['statusMessage'] := IntToStr(mHTTPStatus);
      Result.S['responseText'] := mResponseText;
      if ALogResult then begin
        mResultJSON.S['Status'] := 'Error1';
      end;
    end;

    if ALogResult then begin
      API_Result(mResultJSON);
    end;
  except
    Result := TJSONSuperObject.Create;
    Result.S['error'] := 'error';
    Result.S['except'] := ExceptionMessage;
    Result.I['HTTPStatus'] := mHTTPStatus;
    Result.S['responseText'] := mResponseText;

    if ALogResult then begin
      mResultJSON := TJSONSuperObject.Create;
      mResultJSON.S['Category'] := ACategory;
      mResultJSON.S['InstanceKey'] := AInstanceKey;
      mResultJSON.S['ServiceName'] := cServiceName;
      mResultJSON.I['HTTPStatus'] := mHTTPStatus;
      mResultJSON.S['InputJSON'] := '#' + APayload + '#';
      mResultJSON.S['Status'] := 'Error1';
      API_Result(mResultJSON);
    end;
  end;
end;

function API_GET_PDF(var AOS:tnxcustomobjectspace;var aInstanceKey, aPath, aFileName:string):String;
var
 mAuthorization, mURL:String;
 mWinHTTP:Variant;
 mStream: TMemoryStream;
begin
 Result:='';
 API_LoadConnection(AOS, AInstanceKey, mURL, mAuthorization);
 mWinHTTP:= CreateOleObject('WinHttp.WinHttpRequest.5.1');
 mWinHTTP.Open('GET',mURL+aPath);
 mWinHTTP.SetRequestHeader('Authorization', 'Basic '+mAuthorization);
 mWinHTTP.SetRequestHeader('Accept', 'application/pdf');
 mWinHTTP.Send();

        mStream := TMemoryStream.Create;
        try
          mStream.SetBytes(mWinHTTP.ResponseBody);
          mStream.SaveToFile('c:\ABRA_CZ\print\'+afilename);
          Result:='c:\ABRA_CZ\print\'+afilename;
        finally
          mStream.Free;
        end;
end;


{POST_CreateBB}

procedure POST_CreateBB(AContext:TNxContext; ARequest: TAPIRequest; AResponse: TAPIResponse);
var
  mInputJSON, mOutputJSON:TJSONSuperObject;
  mOS:TNxCustomObjectSpace;
  mPrinterName:string;
  mBO:TNxCustomBusinessObject;
  mList, mLog:TStringList;
begin
  mOS:=AContext.GetObjectSpace;
  mInputJSON:=TJSONSuperObject.Create;
  mOutputJSON:=TJSONSuperObject.Create;
  mInputJSON:=TJSONSuperObject.ParseString(ARequest.Body,True);
  if not(NxIsEmptyOID(mInputJSON.S['billOfDelivery'])) then begin
    mBO:=mOS.CreateObject(Class_BillOfDelivery);
    if mBO.Test(mInputJSON.S['billOfDelivery']) then begin
      mList:=TStringList.Create;
      mLog:=TStringList.Create;
      mList.add(mInputJSON.S['billOfDelivery']);
      mBO.Load(mInputJSON.S['billOfDelivery'],nil);
      if NxIsBlank(mInputJSON.S['printerName']) then mPrinterName:=cPrinterNameLabel else mPrinterName:=mInputJSON.S['printerName'];
      StartAutoCreatePackageNonVisual(mOS, mlist, mBO, mBO.CLSID,'','',mLog,nil,mPrinterName);
      if NxIsBlank(mLog.Text) then
       mOutputJSON.S['status']:='ok'
      else
       mOutputJSON.S['status']:='error';
      mOutputJSON.S['log']:=mLog.text;
    end else begin
      mOutputJSON.S['status']:='not found';
    end;
  end else begin
    mOutputJSON.S['status']:='error';
  end;
  try
        AResponse.Body:=mOutputJSON.AsString;
        AResponse.SetHeader('Content-Type','application/json');
        AResponse.Status := 200;

  finally

  end;
end;

function HUB_API_POST(var aOS:TNxCustomObjectSpace;var aInputJSON:TJSONSuperObject): TJSONSuperObject;
var
  mWinHTTP: Variant;
  mURL, mToken:string;
begin
  try
    if not AOS.ReadFromSecureStore('HUB_URL', mURL) then
     RaiseException('V bezpečném úložišti nebyl nalezen klíč HUB_URL.');
    if not AOS.ReadFromSecureStore('HUB_Token', mToken) then
     RaiseException('V bezpečném úložišti nebyl nalezen klíč HUB_Token.');
    mWinHTTP:= CreateOleObject('WinHttp.WinHttpRequest.5.1');
    mWinHTTP.Open('POST', mURL);
    mWinHTTP.SetRequestHeader('Accept', 'application/json');
    mWinHTTP.SetRequestHeader('Authorization', 'Bearer '+mToken);
    mWinHTTP.Send(aInputJSON.AsJson);
    Result := TJSONSuperObject.ParseString(mWinHTTP.ResponseText, True);
  except
    if CFxNxRuntime.NxGetEnvironmentType = reRuntimeExe then ShowMessage('Při POST dostazu nastala neočekávaná chyba: '+ExceptionMessage);
  end;
end;


function API_GET(AOS: TNxCustomObjectSpace; AInstanceKey, APath: String): TJSONSuperObject;
var
  mAuthorization, mURL: String;
begin
  API_LoadConnection(AOS, AInstanceKey, mURL, mAuthorization);
  Result := API_Request('GET', API_BuildURL(mURL, APath), mAuthorization, '', APath, AInstanceKey, False);
end;


function API_POST(AOS: TNxCustomObjectSpace; AInstanceKey: String; AJSON: TJSONSuperObject; AName: String; AIsScript: Boolean = True): TJSONSuperObject;
var
  mAuthorization, mURL, mPath: String;
begin
  if not Assigned(AJSON) then begin
    RaiseException('Vstupní JSON pro POST není přiřazen.');
  end;
  if Trim(AName) = '' then begin
    RaiseException('Název cílového API endpointu pro POST není vyplněn.');
  end;

  API_LoadConnection(AOS, AInstanceKey, mURL, mAuthorization);
  mPath := AName;
  if AIsScript then begin
    mPath := cAPI_SCRIPT_PATH + AName;
  end else begin
    if Pos('?', mPath) = 0 then
      mPath := mPath + '?select=id'
    else
      mPath := mPath + '&select=id';
  end;

  Result := API_Request('POST', API_BuildURL(mURL, mPath), mAuthorization, AJSON.AsJson, AName, AInstanceKey, True);
end;


function API_PUT(AOS: TNxCustomObjectSpace; AInstanceKey: String; AJSON: TJSONSuperObject; AObjectName, AID: String): TJSONSuperObject;
var
  mAuthorization, mURL, mPath: String;
begin
  if not Assigned(AJSON) then begin
    RaiseException('Vstupní JSON pro PUT není přiřazen.');
  end;
  if Trim(AObjectName) = '' then begin
    RaiseException('Název cílového API objektu pro PUT není vyplněn.');
  end;
  if Trim(AID) = '' then begin
    RaiseException('ID cílového API objektu pro PUT není vyplněno.');
  end;

  API_LoadConnection(AOS, AInstanceKey, mURL, mAuthorization);
  mPath := AObjectName + '/' + AID + '?select=id';
  Result := API_Request('PUT', API_BuildURL(mURL, mPath), mAuthorization, AJSON.AsJson, AObjectName, AInstanceKey, True);
end;


function API_ChangePMState(AOS: TNxCustomObjectSpace; AInstanceKey, AObjectName, AID, APMState_ID: String): TJSONSuperObject;
var
  mAuthorization, mURL, mPath: String;
  mJSON: TJSONSuperObject;
begin
  if Trim(AObjectName) = '' then begin
    RaiseException('Název cílového API objektu pro změnu procesního stavu není vyplněn.');
  end;
  if Trim(AID) = '' then begin
    RaiseException('ID cílového API objektu pro změnu procesního stavu není vyplněno.');
  end;
  if NxIsEmptyOID(APMState_ID) then begin
    RaiseException('ID cílového procesního stavu není vyplněno.');
  end;

  API_LoadConnection(AOS, AInstanceKey, mURL, mAuthorization);
  mPath := AObjectName + '/' + AID + '/pmchangestate?select=id';

  mJSON := TJSONSuperObject.Create;
  try
    mJSON.S['pmstate_id'] := APMState_ID;
    Result := API_Request('PUT', API_BuildURL(mURL, mPath), mAuthorization, mJSON.AsJson, AObjectName + '.pmchangestate', AInstanceKey, True);
  finally
    mJSON.Free;
  end;
end;


begin
end.
