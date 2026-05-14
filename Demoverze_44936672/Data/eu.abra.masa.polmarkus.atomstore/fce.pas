uses '.const';

function API_GET(AURL, aToken:string): TJSONSuperObject;
var
  mWinHTTP: Variant;
  mRequest, mLogin: string;
begin
  try
    mWinHTTP:= CreateOleObject('WinHttp.WinHttpRequest.5.1');
    mWinHTTP.Open('GET', AURL);
    mWinHTTP.SetRequestHeader('Content-Type', 'application/json');
    mWinHTTP.SetRequestHeader('X-API-TOKEN', aToken);
    mWinHTTP.Send('');
    Result := TJSONSuperObject.ParseString(mWinHTTP.ResponseText, True);
  except
    Result:= TJSONSuperObject.Create;
    Result.S['Except']:= 'Funkce API_GET - nastala neočekávaná chyba: '+ExceptionMessage;
  end;
end;

function API_POST(aJSON:TJSONSuperObject;aURL, aToken:string; AOS:TNxCustomObjectSpace):TJSONSuperObject;
var
 mWinHTTP:Variant;
 SentHeaders:string;
begin


  try
   mWinHTTP:= CreateOleObject('WinHttp.WinHttpRequest.5.1');
   mWinHTTP.Open('POST', aURL);
   //mWinHTTP.SetRequestHeader('Content-Type', 'application/json');
   //mWinHTTP.SetRequestHeader('Vary','Accept-Encoding');
   //mWinHTTP.setRequestHeader('Content-Encoding','gzip');
   mWinHTTP.Send(aJSON.AsJson);
   Result:=TJSONSuperObject.ParseString(mWinHTTP.ResponseText, True);
   NxShowSimpleMessage(SentHeaders+#13#10+'_________'+#13#10+mWinHTTP.GetAllResponseHeaders(),nil);
   NxShowSimpleMessage(mWinHTTP.ResponseText,nil);
  except
   CFxLog.SaveLog(NxCreateContext(aOS),'AS','Chyba POST',ExceptionMessage,2,Now);
  end;
end;


Function GetActualToken(var AOS:TNxCustomObjectSpace):string;
var
 mJSON, mResultJson:TJSONSuperObject;
 mURL:string;
 mBool:Boolean;
begin
 mJSON:=TJSONSuperObject.Create;
 mJSON.S['login']:=cLogin;
 mJSON.S['password']:=cPassword;
 mURL:=cURL+'users/authorize/';
 mJSON.SaveToFile(cCURLPath+'data.json');
 mBool:=ShellAPI.Execute('open','curl.bat','',cCurlPath);
 mResultJson:=TJSONSuperObject.ParseFile(cCurlPath+'token.json',false);
 if mResultJson.S['status']='ok' then Result:=mResultJson.S['token']
   else Result:='chyba';


end;


begin
end.