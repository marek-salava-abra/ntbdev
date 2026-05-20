uses
  'REST_SkladTerm.U_Func',
  'REST_SkladTerm.U_Get',
  'REST_SkladTerm.U_Post',
  'REST_SkladTerm.U_Put',
  'StandardUnits.U_Func';

// API
{procedure GET_API(AContext: TNxContext; ARequest: TAPIRequest; AResponse: TAPIResponse);
begin
  API(AContext, ARequest, AResponse, 'GET');
end;

procedure PUT_API(AContext: TNxContext; ARequest: TAPIRequest; AResponse: TAPIResponse);
begin
  API(AContext, ARequest, AResponse, 'PUT');
end;

procedure POST_API(AContext: TNxContext; ARequest: TAPIRequest; AResponse: TAPIResponse);
begin
  API(AContext, ARequest, AResponse, 'POST');
end;

procedure API(AContext: TNxContext; ARequest: TAPIRequest; AResponse: TAPIResponse; AMethod: String);
var
  slPath, slArguments, slResponse, mHeadersNames, mHeaders: TStringList;
  i: Integer;
  mBody: TBytes;
begin
  gLogSectionIndex := 0;
  slPath := TStringList.Create;
  slArguments := TStringList.Create;
  slResponse := TStringList.Create;
  mHeadersNames := TStringList.Create;
  mHeaders := TStringList.Create;
  gLog := TNxCustomLog.Create(REST_LogName);
  try
    try
      gTimeStart := now;
      glog.EnterSection('SkladTerm ' + AMethod, logDebug);
      glog.WriteEventFmt(logDebug, 'Path:%s'     , [ARequest.Path]);
      //glog.WriteEventFmt(logDebug, 'Content:%s'  , [REST_ByteUTF82String(ARequest.Content.Content)]);

      //rozparsuju si cestu a vytahnu prvni cast (/xxx/)
      ParsePath(ARequest.Path, slPath, True);

      //pokud nemam nic v ceste, vracim chybna cesta
      if slPath.Count = 0 then
      begin
        SetPlainResponse(slResponse, Format(getString('error_path_not_found'), ['']), HTTP_SC_BadRequest);
        exit;
      end;

      ARequest.GetHeaders(mHeadersNames);
      for i := 0 to mHeadersNames.Count - 1 do
      begin
        mHeaders.Add(mHeadersNames.Strings(i) + '=' + ARequest.GetHeaderValue(mHeadersNames.Strings(i)));
      end;

      gLog.WriteEventFmt(logDebug, 'Headers:%s', [mHeaders.DelimitedText]);

      slArguments.Delimiter:= '&';
      slArguments.DelimitedText := ARequest.Query;
      slArguments.Text:= CFxInternet.URLDecode(slArguments.Text);

      AResponse.SetHeader('Requested-Client-Version', CLIENT_CURRENT_VERSION);

      // TODO nastavit globalniho uzivatele dle uzivatele z API?
      gSkladTermUser_ID := ARequest.GetHeaderValue('UserID');
      gSkladTermModule := ARequest.GetHeaderValue('ModuleCode');
      gSkladTermDocType := ARequest.GetHeaderValue('DocumentType');

      mBody := TEncoding.UTF8.GetBytes(ARequest.Body);

      if AMethod = 'GET' then
        get(AContext, mHeaders, slPath, slArguments, ARequest.Body, slResponse)
      else if AMethod = 'PUT' then
        put(AContext, mHeaders, slPath, slArguments, mBody, slResponse)
      else if AMethod = 'POST' then
        post(AContext, mHeaders, slPath, slArguments, ARequest.Body, slResponse);

      HTTPAPIResponse(AResponse, slResponse);
    except
      SetPlainResponse(slResponse, getExceptionMessage, HTTP_SC_InternalServerError);
      HTTPAPIResponse(AResponse, slResponse);
    end;
  finally
    //LogWriteDuration('SkladTerm PUT', ARequest, AResponse);
    gLog.LeaveSection('SkladTerm PUT', logDebug);
    slPath.Free;
    slArguments.Free;
    slResponse.Free;
    mHeaders.Free;
    mHeadersNames.Free;
    gLog.Free;
  end;
end;}

// WS
procedure GET_WS(Self: TNxWebServicesHelper; ARequest: TNxHTTPRequest; AResponse: TNxHTTPResponse);
begin
  WS(Self, ARequest, AResponse, 'GET');
end;

procedure PUT_WS(Self: TNxWebServicesHelper; ARequest: TNxHTTPRequest; AResponse: TNxHTTPResponse);
begin
  WS(Self, ARequest, AResponse, 'PUT');
end;

procedure POST_WS(Self: TNxWebServicesHelper; ARequest: TNxHTTPRequest; AResponse: TNxHTTPResponse);
begin
  WS(Self, ARequest, AResponse, 'POST');
end;

procedure WS(Self: TNxWebServicesHelper; ARequest: TNxHTTPRequest; AResponse: TNxHTTPResponse; AMethod: String);
var
  slPath, slArguments, slHeaders, slResponse: TStringList;
  mUser_ID: String;
begin
  gLogSectionIndex:= 0;
  slPath := TStringList.Create;
  slArguments := TStringList.Create;
  slResponse := TStringList.Create;
  slHeaders := TStringList.Create;
  gLog:= TNxCustomLog.Create(REST_LogName);
  try
    try
      gTimeStart:= now;
      gLog.EnterSection('SkladTerm GET', logDebug);
      gLog.WriteEventFmt(logDebug, 'path=%s', [ARequest.Path]);

      slHeaders.Text := ARequest.Header.AllHeaders;

      if(not HTTP_Authorization(Self.ObjectSpace, slHeaders.Values('DeviceID'), slHeaders.Values('Authorization'), slResponse)) then
      begin
        HTTPWSResponse(AResponse, slResponse);
        exit;
      end;

      //nastavim si globalni promenou WS_User_ID (predstavuje uzivatele, ktery je prihlaseni do aplikace)&#xD;
      mUser_ID := slHeaders.Values('UserID');
      if not NxIsEmptyOID(mUser_ID) then
        GlobParams.GetOrCreateParam(dtString, 'WS_User_ID').AsString := mUser_ID
      else
        GlobParams.DeleteByName('WS_User_ID');

      ParsePath(ARequest.Path, slPath);

      //pokud nemam nic v ceste, vracim chybna cesta
      if (slPath.Count = 0) then
      begin
        SetPlainResponse(slResponse, Format(getString('error_path_not_found'), ['']), HTTP_SC_BadRequest);
        exit;
      end;

      slArguments.Delimiter:= '&';
      slArguments.DelimitedText:= ARequest.Arguments;
      slArguments.Text:= CFxInternet.URLDecode(slArguments.Text);

      AResponse.Header.OtherHeaders := 'Requested-Client-Version=' + CLIENT_CURRENT_VERSION;

      gSkladTermUser_ID := getHeaderValue(ARequest, 'UserID');
      gSkladTermModule := getHeaderValue(ARequest, 'ModuleCode');
      gSkladTermDocType := getHeaderValue(ARequest, 'DocumentType');

      if AMethod = 'GET' then
        get(Self.Context, slHeaders, slPath, slArguments,
          REST_ByteUTF82String(ARequest.Content.Content), slResponse)
      else if AMethod = 'PUT' then
        put(Self.Context, slHeaders, slPath, slArguments,
          ARequest.Content.Content, slResponse)
      else if AMethod = 'POST' then
        post(Self.Context, slHeaders, slPath, slArguments,
          REST_ByteUTF82String(ARequest.Content.Content), slResponse);

      HTTPWSResponse(AResponse, slResponse);
    except
      SetPlainResponse(slResponse, getExceptionMessage, HTTP_SC_InternalServerError);
      HTTPWSResponse(AResponse, slResponse);
    end;
  finally
    LogWriteDuration('SkladTerm GET', ARequest, AResponse);
    gLog.LeaveSection('SkladTerm GET', logDebug);
    slPath.free;
    slArguments.Free;
    slHeaders.Free;
    slResponse.Free;
    gLog.free;
    if not NxIsEmptyOID(mUser_ID) then
      GlobParams.DeleteByName('WS_User_ID');
  end;
end;

begin
end.