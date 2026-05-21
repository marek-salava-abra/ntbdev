const
 cURL='http://10.5.5.207:82/CZLipoElastic/';    //ostrá data
 cServiceName='AbraGen AT';
 cAuthorization ='QVBJX0FUX0FicmE6cXU0RmlFd1R5bUh3';

function API_POST(aJSON:TJSONSuperObject;AName:string; AIsScript: Boolean = True; aIndex: integer = 0):TJSONSuperObject;
var
 mWinHTTP:Variant;
 mResultJSON:TJSONSuperObject;
 mSuffix, mURL: string;
begin
  mSuffix:= '';
  if (AIsScript = True) and (aIndex = 0) then mSuffix:= 'script/eu.abra.alec.Lipoelastic.API_Sync/lib/';

  try
   mWinHTTP:= CreateOleObject('WinHttp.WinHttpRequest.5.1');
   mURl:=cURL+mSuffix+aName;
   mWinHTTP.Open('POST', mURL);
   mWinHTTP.SetRequestHeader('Content-Type', 'application/json');
   if aIndex=0 then mWinHTTP.SetRequestHeader('Authorization','Basic '+cAuthorization);
   mWinHTTP.Send(aJSON.AsJson);
   mResultJSON:=TJSONSuperObject.Create;
   mResultJSON.S['Category']:=aName;
   mResultJSON.S['ServiceName']:=cServiceName;
   mResultJSON.I['HTTPStatus']:=StrToInt(mWinHTTP.status);
   mResultJSON.S['InputJSON']:='#'+aJSON.AsString+'#';
   if mWinHTTP.status='200' then begin
     Result:=TJSONSuperObject.ParseString(mWinHTTP.ResponseText, True);
     mResultJSON.S['Status']:='OK';
   end else begin
     Result:=TJSONSuperObject.create;
     Result.S['ID']:='';
     Result.S['Status']:=mWinHTTP.status;
     mResultJSON.S['Status']:='Error1';
   end;
   API_Result(mResultJSON);
  except
   Result:=TJSONSuperObject.create;
   Result.S['error']:='error';
   mResultJSON:=TJSONSuperObject.Create;
   mResultJSON.S['Category']:=aName;
   mResultJSON.S['ServiceName']:=cServiceName;
   mResultJSON.I['HTTPStatus']:=404;
   mResultJSON.S['InputJSON']:=aJSON.AsString;
   mResultJSON.S['Status']:='Error1';
   API_Result(mResultJSON);
  end;
end;

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