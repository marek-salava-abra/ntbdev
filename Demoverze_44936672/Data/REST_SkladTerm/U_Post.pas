uses
  'REST_SkladTerm.U_Func',
  'REST_SkladTerm.U_TemporaryStorage',
  'REST_SkladTerm_Customer.U_Requests'
  ;

////////////////////////////////////////////////////////////////////////////////
procedure post(Self: TNxWebServicesHelper; ARequest: TNxHTTPRequest; AResponse: TNxHTTPResponse);
var
  slPath: TStringList;
  adr   : string;
begin
  gLogSectionIndex:= 0;
  slPath:= TStringList.Create;
  gLog:= TNxCustomLog.Create(REST_LogName);
  try
    try
      gTimeStart:= now;
      glog.EnterSection('SkladTerm POST', logDebug);
      glog.WriteEventFmt(logDebug, 'path=%s', [ARequest.Path]);

      if(not HTTP_Authorization(Self.ObjectSpace, ARequest, AResponse))then begin
        exit;
      end;

      ParsePath(ARequest.Path, slPath);

      //pokud nemam nic v ceste, vracim chybna cesta
      if(slPath.Count = 0)then begin
        ErrREST(ARequest, AResponse, HTTP_SC_BadRequest);
        exit;
      end;

      AResponse.Header.OtherHeaders := 'Requested-Client-Version=' + CLIENT_CURRENT_VERSION;

      // specialni zpracovani
      if not processSpecialPostRequests(Self, ARequest, AResponse, slPath) then
      begin
        // standardni zpracovani
        //podle toho zavolam funkci, ktera pozadavek zpracuje
        {case slPath.Strings[0] of
          'temporaryStorage': post_TemporaryStorage(Self, ARequest, AResponse, slPath);
          else} ErrREST(ARequest, AResponse, HTTP_SC_BadRequest);
        //end;
      end;
    except
      ErrREST(ARequest, AResponse, HTTP_SC_ExpectationFailed, ExceptionMessage);
    end;

  finally
    LogWriteDuration('SkladTerm POST', ARequest, AResponse);
    glog.LeaveSection('SkladTerm POST', logDebug);
    slPath.free;
    glog.free;
  end;
end;
////////////////////////////////////////////////////////////////////////////////

begin
end.