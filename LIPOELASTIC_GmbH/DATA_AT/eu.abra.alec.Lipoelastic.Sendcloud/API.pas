uses '.const';

function CallAPI(AOS: TNxCustomObjectSpace; const AMethod, AEndpoint: string; var AStatusCode :string; var ALog: string;
                  const ARequestBody: TJSONSuperObject = nil; AUseErrorsVerboseCarrier: boolean = True): TJSONSuperObject;
var
  mWinHTTP: Variant;
  mBaseURL, mFullURL, mResponseText, mExceptionLog, mLogin: string;
  mErrorsVerboseCarrier: string;

begin
  Result := nil; // Default result

  if AUseErrorsVerboseCarrier then
    mErrorsVerboseCarrier:= '?errors=verbose-carrier'
  else
    mErrorsVerboseCarrier:= '';

  mFullURL := cBaseURL + cAPIVersion + '/' + AEndpoint + mErrorsVerboseCarrier;
  //NxShowSimpleMessage(EncodeBase64(TEncoding.ANSI.GetBytes(cPublicKey+':'+cPrivateKey)), nil);
  //exit;

  try
    // Initialize HTTP request
    mWinHTTP := CreateOleObject('WinHttp.WinHttpRequest.5.1');
    mWinHTTP.Open(AMethod, mFullURL);
    mWinHTTP.SetRequestHeader('Content-Type', 'application/json');
    mWinHTTP.SetRequestHeader('Authorization', 'Basic ' + EncodeBase64(TEncoding.UTF8.GetBytes(cPublicKey+':'+cPrivateKey)));
    // Send request with optional body
    if Assigned(ARequestBody) and (AMethod <> 'GET') then
      mWinHTTP.Send(ARequestBody.AsString)
    else
      mWinHTTP.Send('');

    // Handle response
    AStatusCode := VarToStr(mWinHTTP.Status);
    mResponseText := TEncoding.UTF8.GetString(mWinHTTP.responseBody);
    //Log := Format('Request: [%s] %s | Response: %s', [Method, FullURL, ResponseText]);

    if AStatusCode in ['200', '201'] then
      Result := TJSONSuperObject.ParseString(mResponseText, True)
    else begin
      Result := TJSONSuperObject.ParseString(mResponseText, True);
      LogMessage('ERROR', 'CallAPI', Format('API Error: [%s] %s | Status: %s | Response: %s', [AMethod, mFullURL, VarToStr(AStatusCode), mResponseText]), ALog);
    end;
  except
    LogMessage('ERROR', 'CallAPI', Format('An unexpected error occurred during API call: %s', [ExceptionMessage]), ALog);
  end;
end;

procedure LogMessage(const AMsgType, AFunctionName, AMessageText: string; var ALog: string);
begin
  if AMsgType = 'ERROR' then
    ALog := ALog + Format('[%s] %s - ERROR: %s', [AFunctionName, DateTimeToStr(Now), AMessageText]) + nxCrLf
  else if AMsgType = 'WARNING' then
    ALog := ALog + Format('[%s] %s - WARNING: %s', [AFunctionName, DateTimeToStr(Now), AMessageText]) + nxCrLf
  else if AMsgType = 'INFO' then
    ALog := ALog + Format('[%s] %s - INFO: %s', [AFunctionName, DateTimeToStr(Now), AMessageText]) + nxCrLf;
end;




begin
end.