// Načtení WinHTTP objektu
//---------------------------------------------------------------------------------

function GetWinHTTP(var WinHttpRequest: Variant): Boolean;
begin
  try
     if not VarIsType(WinHttpRequest, varDispatch) then
      WinHttpRequest := CreateOleObject('WinHttp.WinHttpRequest.5.1');
    Result:=True;
  except
    Result := False;
    ShowMessage(ExceptionMessage);
    WinHttpRequest := nil;
  end;
end;




function SendHTTPRequest(AMethod, AURL, ARequest: string; AHeaders: array of string): string;
var
  mWinHTTP: variant;
  i: integer;
  mList: TStringList;
begin
  GetWinHTTP(mWinHTTP);
  mWinHTTP.Open(AMethod, AURL);
  mList := TStringList.Create;
  try
    for i := 0 to Length(AHeaders)-1 do begin
      mList.Delimiter := '|';
      mList.DelimitedText := AHeaders[i];
      mWinHTTP.SetRequestHeader(mList[0], mList[1]);
    end;
    mWinHTTP.SetTimeouts(0, 0, 0, 0);
    mWinHTTP.Send(ARequest);
    if mWinHTTP.Status <> '200' then begin
      RaiseException('Chyba při načtení webové služby: '+mWinHTTP.StatusText);
    end;
  finally
    mList.Free;
  end;
  Result := mWinHTTP.ResponseText;
end;



// Odeslání HTTP požadavku s autentizací
// @param string AMethod metoda (POST|GET)
// @param string AURL url požadavku
// @param string ARequest content požadavku
// @param array of string AHeaders Hlavičky
//                                 "ContentType|text/xml; charset=utf-8"
//                                 "Accept-Encoding|gzip,deflate"
// @param string AUser Uživatel
// @param string APassword Heslo
//---------------------------------------------------------------------------------


function SendHTTPRequestAuth(AMethod, AURL, ARequest: string; AHeaders: array of string; AUser, APassword: string): string;
var
  mWinHTTP: variant;
  i: integer;
  mList: TStringList;
  mHeader, mValue: string;
begin
  GetWinHTTP(mWinHTTP);
  mWinHTTP.Open(AMethod, AURL);
  mWinHTTP.SetCredentials(AUser, APassword, 0);
  for i := 0 to Length(AHeaders)-1 do begin
    mHeader := NxToken(AHeaders[i], '|');
    mValue := NxToken(AHeaders[i], '|');
    mWinHTTP.SetRequestHeader(mHeader, mValue);
  end;
  mWinHTTP.SetTimeouts(0, 0, 0, 0);
  mWinHTTP.Send(ARequest);
  if mWinHTTP.Status <> '200' then begin
      RaiseException('Chyba při načtení webové služby: '+mWinHTTP.StatusText);
  end;
  Result := mWinHTTP.ResponseText;
end;


// Odeslání HTTP požadavku přes proxy
// @param string AMethod metoda (POST|GET)
// @param string AURL url požadavku
// @param string ARequest content požadavku
// @param array of string AHeaders Hlavičky
//                                 "ContentType|text/xml; charset=utf-8"
//                                 "Accept-Encoding|gzip,deflate"
// @param string AHost Proxy host
// @param integer APort Proxy port
// @param string AUser Proxy uživatel
// @param string APassword Proxy heslo
//---------------------------------------------------------------------------------

{
function SendHTTPRequestProxy(AMethod, AURL, ARequest: string; AHeaders: array of string;
  AHost: string; APort: integer; AUser, APassword: string): string;
var
  mWinHTTP: variant;
  i: integer;
  mList: TStringList;
  mHeader, mValue: string;
begin
  GetWinHTTP(mWinHTTP);
  mWinHTTP.Open(AMethod, AURL);
  mWinHTTP.SetProxy(2, AHost + ':' + IntToStr(APort));
  mWinHTTP.SetCredentials(AUser, APassword, 1);
  for i := 0 to Length(AHeaders)-1 do begin
    mHeader := NxToken(AHeaders[i], '|');
    mValue := NxToken(AHeaders[i], '|');
    mWinHTTP.SetRequestHeader(mHeader, mValue);
  end;
  mWinHTTP.SetTimeouts(0, 0, 0, 0);
  mWinHTTP.Send(ARequest);
  if mWinHTTP.Status <> '200' then begin
      RaiseException('Chyba při načtení webové služby: '+mWinHTTP.StatusText);
  end;
  Result := mWinHTTP.ResponseText;
end;
     }

begin
end.