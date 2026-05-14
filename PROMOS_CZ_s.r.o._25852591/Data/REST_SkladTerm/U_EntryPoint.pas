uses
  'REST_SkladTerm.U_Const',
  'REST_SkladTerm.U_Func',
  'REST_SkladTerm.U_Get',
  'REST_SkladTerm.U_Post',
  'REST_SkladTerm.U_Put',
  'REST_SkladTerm_Special.U_Const',
  'StandardUnits.U_Func';

// API
procedure GET_API(AContext: TNxContext; ARequest: TAPIRequest; AResponse: TAPIResponse);
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
  slPath, slArguments, slResponse, mHeadersNames, mHeaders, mQueryParamNames: TStringList;
  i: Integer;
  mBody: TBytes;
  mProfilerStart: Boolean;
begin
  gLogSectionIndex := 0;
  slPath := TStringList.Create;
  slArguments := TStringList.Create;
  mQueryParamNames := TStringList.Create;
  slResponse := TStringList.Create;
  mHeadersNames := TStringList.Create;
  mHeaders := TStringList.Create;
  gLog := TNxCustomLog.Create(REST_LogName);
  try
    try
      gTimeStart := Now;
      gLog.EnterSection('SkladTerm ' + AMethod, logDebug);
      LogWriteEvent(Format('Path: %s', [ARequest.Path]));

      mHeaders.CaseSensitive := False;
      ARequest.GetHeaders(mHeadersNames);
      for i := 0 to mHeadersNames.Count - 1 do
      begin
        mHeaders.Add(mHeadersNames.Strings(i) + '=' + ARequest.GetHeaderValue(mHeadersNames.Strings(i)));
      end;
      LogWriteEvent(Format('Headers: %s', [mHeaders.DelimitedText]));

      if (pos(ContentType_JSON, mHeaders.Values('Content-Type')) > 0)
          or (pos(ContentType_PlainText, mHeaders.Values('Content-Type')) > 0) then
        LogWriteEvent(Format('Content: %s', [ARequest.Body]))
      else
        LogWriteEvent('Content: ---Body is empty, or it is not JSON or plain text---');

      VerifyLicence(AContext.GetObjectSpace, mHeaders.Values('DeviceID'));

      //rozparsuju si cestu a vytahnu prvni cast (/xxx/)
      // musim smazat prvni cast, kde je i nazev spojeni a cesta ve skriptu
      ARequest.GetPathSegments(slPath);
      slPath.DelimitedText :=
        copy(slPath.DelimitedText, pos('U_EntryPoint,API,', slPath.DelimitedText) + Length('U_EntryPoint,API,'), Length(slPath.DelimitedText));
      // zpetna kompatibilita
      //ParsePath(ARequest.Path, slPath, True);

      //pokud nemam nic v ceste, vracim chybna cesta
      if slPath.Count = 0 then
      begin
        SetPlainResponse(slResponse, Format(getString('error_path_not_found'), ['']), HTTP_SC_BadRequest);
        exit;
      end;

      ARequest.GetQueryParams(mQueryParamNames);
      for i := 0 to mQueryParamNames.Count - 1 do
      begin
        if ARequest.ContainsQueryParam(mQueryParamNames[i]) then
          slArguments.Values[mQueryParamNames[i]] := ARequest.GetQueryParamValue(mQueryParamNames[i]);
      end;
      // zpetna kompatibilita
      //slArguments.Delimiter:= '&';
      //slArguments.DelimitedText := ARequest.Query;
      //slArguments.Text:= CFxInternet.URLDecode(slArguments.Text);

      AResponse.SetHeader('Requested-Client-Version', CLIENT_CURRENT_VERSION);

      // TODO nastavit globalniho uzivatele dle uzivatele z API?
      gSkladTermUser_ID := mHeaders.Values('UserID');
      gSkladTermModule := mHeaders.Values('ModuleCode');
      gSkladTermDocType := mHeaders.Values('DocumentType');

      mBody := TEncoding.UTF8.GetBytes(ARequest.Body);

      mProfilerStart := False;
      try
        mProfilerStart := CheckProfilerStart(PROFILER_CONFIG_FILE_PATH);
      except
      end;

      if mProfilerStart then
      begin
        LogWriteEvent('Profiler started');
        CFxProfiler.Start;
      end;

      if AMethod = 'GET' then
        get(AContext, mHeaders, slPath, slArguments, ARequest.Body, slResponse)
      else if AMethod = 'PUT' then
        put(AContext, mHeaders, slPath, slArguments, mBody, True, slResponse)
      else if AMethod = 'POST' then
        post(AContext, mHeaders, slPath, slArguments, ARequest.Body, slResponse);

      HTTPAPIResponse(AResponse, slResponse);
    except
      SetPlainResponse(slResponse, getExceptionMessage, HTTP_SC_InternalServerError);
      HTTPAPIResponse(AResponse, slResponse);
    end;
  finally
    slPath.Free;
    slArguments.Free;
    mQueryParamNames.Free;
    slResponse.Free;
    mHeaders.Free;
    mHeadersNames.Free;
    if mProfilerStart then
    begin
      LogWriteEvent('Profiler stopped');
      CFxProfiler.Stop;
      try
        CFxProfiler.Save(PROFILER_RESULTS_PATH + ReplaceStr(CFxDateTime.DateTimeToISO8601(Now), ':', '_') + '.ap');
      except
        LogWriteEvent(ExceptionMessage);
      end;
    end;
    gLog.LeaveSection('SkladTerm ' + AMethod, logDebug);
    gLog.Free;
  end;
end;

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
  mUser_ID, mBody: String;
  mProfilerStart: Boolean;
begin
  gLogSectionIndex := 0;
  slPath := TStringList.Create;
  slArguments := TStringList.Create;
  slResponse := TStringList.Create;
  slHeaders := TStringList.Create;
  gLog := TNxCustomLog.Create(REST_LogName);
  try
    try
      gTimeStart := Now;
      gLog.EnterSection('SkladTerm ' + AMethod, logDebug);
      LogWriteEvent(Format('Path: %s', [ARequest.Path]));

      slHeaders.CaseSensitive := False;
      slHeaders.Text := ARequest.Header.AllHeaders;
      LogWriteEvent(Format('Headers: %s', [slHeaders.DelimitedText]));

      mBody := '';
      if (pos(ContentType_JSON, slHeaders.Values('Content-Type')) > 0)
          or (pos(ContentType_PlainText, slHeaders.Values('Content-Type')) > 0) then
      begin
        mBody := REST_ByteUTF82String(ARequest.Content.Content);
        LogWriteEvent(Format('Content: %s', [mBody]));
      end
      else
        LogWriteEvent('Content: ---Body is empty, or it is not JSON or plain text---');

      if(not HTTP_Authorization(Self.ObjectSpace, slHeaders.Values('Authorization'), slResponse)) then
      begin
        HTTPWSResponse(AResponse, slResponse);
        exit;
      end;

      VerifyLicence(Self.ObjectSpace, slHeaders.Values('DeviceID'));

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

      gSkladTermUser_ID := slHeaders.Values('UserID');
      gSkladTermModule := slHeaders.Values('ModuleCode');
      gSkladTermDocType := slHeaders.Values('DocumentType');

      mProfilerStart := False;
      try
        mProfilerStart := CheckProfilerStart(PROFILER_CONFIG_FILE_PATH);
      except
      end;

      if mProfilerStart then
      begin
        LogWriteEvent('Profiler started');
        CFxProfiler.Start;
      end;

      if AMethod = 'GET' then
        get(Self.Context, slHeaders, slPath, slArguments, mBody, slResponse)
      else if AMethod = 'PUT' then
        put(Self.Context, slHeaders, slPath, slArguments, ARequest.Content.Content, False, slResponse)
      else if AMethod = 'POST' then
        post(Self.Context, slHeaders, slPath, slArguments, mBody, slResponse);

      HTTPWSResponse(AResponse, slResponse);
    except
      SetPlainResponse(slResponse, getExceptionMessage, HTTP_SC_InternalServerError);
      HTTPWSResponse(AResponse, slResponse);
    end;
  finally
    slPath.free;
    slArguments.Free;
    slHeaders.Free;
    slResponse.Free;
    if not NxIsEmptyOID(mUser_ID) then
      GlobParams.DeleteByName('WS_User_ID');
    if mProfilerStart then
    begin
      LogWriteEvent('Profiler stopped');
      CFxProfiler.Stop;
      try
        CFxProfiler.Save(PROFILER_RESULTS_PATH + ReplaceStr(CFxDateTime.DateTimeToISO8601(Now), ':', '_') + '.ap');
      except
        LogWriteEvent(ExceptionMessage);
      end;
    end;
    gLog.LeaveSection('SkladTerm ' + AMethod, logDebug);
    gLog.free;
  end;
end;

begin
end.