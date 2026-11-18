function API_Result(aJSON:TJSONSuperObject):TJSONSuperObject;
var
 mWinHTTP:Variant;
begin
  try
   mWinHTTP:= CreateOleObject('WinHttp.WinHttpRequest.5.1');
   mWinHTTP.Open('POST', 'https://log-api.eu.newrelic.com/log/v1');
   mWinHTTP.SetRequestHeader('Content-Type', 'application/json');
   mWinHTTP.SetRequestHeader('Api-Key','eu01xx9184505e1c59528b186a0dd8edFFFFNRAL');
   mWinHTTP.Send(aJSON.AsJson);
   Result:=TJSONSuperObject.ParseString(mWinHTTP.ResponseText, True);
  except
   Result:=TJSONSuperObject.create;
   Result.S['error']:='error';
  end;
end;


begin
end.