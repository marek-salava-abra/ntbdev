uses '.const';

function API_POST(aURL:string; aJSON:TJSONSuperObject; AOS:TNxCustomObjectSpace):TJSONSuperObject;
var
 mWinHTTP:Variant;
begin
  try
   mWinHTTP:= CreateOleObject('WinHttp.WinHttpRequest.5.1');
   mWinHTTP.Open('POST', aURL);
   mWinHTTP.SetRequestHeader('Content-Type', 'application/json');
   mWinHTTP.SetRequestHeader('key',cKey);
   mWinHTTP.Send(aJSON.AsJson);
   if mWinHTTP.Status = 200 then begin
     Result:=TJSONSuperObject.ParseString(mWinHTTP.ResponseText, True);
   end else begin
     CFxLog.SaveLog(NxCreateContext(aOS),'ERR','Chyba POST ne 200',mWinHTTP.ResponseText,2,Now);
   end;
  except
   CFxLog.SaveLog(NxCreateContext(aOS),'ERR','Chyba POST',ExceptionMessage,2,Now);
  end;
end;

begin
end.