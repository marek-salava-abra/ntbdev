uses '.const';


function API_POST(aJSON:TJSONSuperObject;AName:string; AIsScript: Boolean = True; aIndex: integer = 0):TJSONSuperObject;
var
 mWinHTTP:Variant;
 mResultJSON:TJSONSuperObject;
 mSuffix, mURL: string;
begin
  mSuffix:= '';
  if (AIsScript = True) and (aIndex = 0) then mSuffix:= 'script/eu.abra.alec.Lipoelastic.SK_API/lib/';
  if (AIsScript = True) and (aIndex = 1) then mSuffix:= 'script/eu.abra.masa.lipoelastic.DE_API/lib/';
  if (AIsScript = True) and (aIndex = 2) then mSuffix:= 'script/eu.abra.masa.lipoelastic.AT_API/lib/';
  try
   mWinHTTP:= CreateOleObject('WinHttp.WinHttpRequest.5.1');
   mURl:=cURL+mSuffix+aName;
   if aIndex=1 then mURL:= cURLDE+mSuffix+aName;
   if aIndex=2 then mURL:= cURLAT+mSuffix+aName;
   mWinHTTP.Open('POST', mURL);
   mWinHTTP.SetRequestHeader('Content-Type', 'application/json');
   if aIndex=0 then mWinHTTP.SetRequestHeader('Authorization','Basic '+cAuthorization);
   if aIndex=1 then mWinHTTP.SetRequestHeader('Authorization','Basic '+cAuthorizationDE);
   if aIndex=2 then mWinHTTP.SetRequestHeader('Authorization','Basic '+cAuthorizationAT);
   mWinHTTP.Send(aJSON.AsJson);
   mResultJSON:=TJSONSuperObject.Create;
   mResultJSON.S['Category']:=aName;
   mResultJSON.S['ServiceName']:=cServiceName+' '+cURL;
   mResultJSON.I['HTTPStatus']:=StrToInt(mWinHTTP.status);
   mResultJSON.S['Method']:='POST';
   mResultJSON.S['InputJSON']:='#'+aJSON.AsString+'#';
   if mWinHTTP.status='200' then begin
     Result:=TJSONSuperObject.ParseString(mWinHTTP.ResponseText, True);
     mResultJSON.S['Status']:='OK';
     mResultJSON.S['ResponseText']:=mWinHTTP.ResponseText;
     mResultJSON.S['ExceptionMessage']:='';
   end else begin
     Result:=TJSONSuperObject.create;
     Result.S['ID']:='';
     mResultJSON.S['Status']:='Error1';
     mResultJSON.S['ResponseText']:=mWinHTTP.ResponseText;
     mResultJSON.S['ExceptionMessage']:='';
   end;
   API_Result(mResultJSON);
  except
   Result:=TJSONSuperObject.create;
   Result.S['error']:='error';
   mResultJSON:=TJSONSuperObject.Create;
   mResultJSON.S['Category']:=aName;
   mResultJSON.S['ServiceName']:=cServiceName+' '+cURL;
   mResultJSON.I['HTTPStatus']:=404;
   mResultJSON.S['InputJSON']:=aJSON.AsString;
   mResultJSON.S['Status']:='Error1';
   mResultJSON.S['ResponseText']:='';
   mResultJSON.S['ExceptionMessage']:=ExceptionMessage;
   mResultJSON.S['Method']:='POST';
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

function API_PUT(aJSON:TJSONSuperObject; AObjectName, AID:string; aIndex: integer = 0):TJSONSuperObject;
var
 mWinHTTP:Variant;
 mResultJSON:TJSONSuperObject;
 mURL, mAuth:string;
begin
  try
    if aIndex=0 then mURL:=cURL + AObjectName + '/' + AID + '?select=id';
    if aIndex=2 then mURL:=cURLAT + AObjectName + '/' + AID + '?select=id';
    mWinHTTP.SetRequestHeader('Content-Type', 'application/json');
    if aIndex=0 then mAuth:=cAuthorization;
    if aIndex=2 then mAuth:=cAuthorizationAT;
    mWinHTTP:= CreateOleObject('WinHttp.WinHttpRequest.5.1');
    mWinHTTP.Open('PUT', mURL);
    mWinHTTP.SetRequestHeader('Content-Type', 'application/json');
    mWinHTTP.SetRequestHeader('Authorization','Basic '+mAuth);
    mWinHTTP.Send(aJSON.AsJson);
    mResultJSON:=TJSONSuperObject.Create;
    mResultJSON.S['Category']:=AObjectName;
    mResultJSON.S['ServiceName']:=cServiceName;
    mResultJSON.I['HTTPStatus']:=StrToInt(mWinHTTP.status);
    mResultJSON.S['Method']:='PUT';
    mResultJSON.S['InputJSON']:='#'+aJSON.AsString+'#';
    //NxShowSimpleMessage(mWinHTTP.Status, nil);
    if mWinHTTP.status='200' then begin
      Result:=TJSONSuperObject.ParseString(mWinHTTP.ResponseText, True);
      mResultJSON.S['Status']:='OK';
      mResultJSON.S['ResponseText']:=mWinHTTP.ResponseText;
      mResultJSON.S['ExceptionMessage']:='';
    end else begin
      Result:=TJSONSuperObject.create;
      Result.S['ID']:='';
      mResultJSON.S['Status']:='Error1';
      mResultJSON.S['ResponseText']:=mWinHTTP.ResponseText;
      mResultJSON.S['ExceptionMessage']:='';
    end;
    API_Result(mResultJSON);
  except
    //NxShowSimpleMessage(ExceptionMessage, nil);
    Result:=TJSONSuperObject.create;
    Result.S['error']:='error';
    mResultJSON:=TJSONSuperObject.Create;
    mResultJSON.S['Category']:=AObjectName;
    mResultJSON.S['Method']:='PUT';
    mResultJSON.S['ServiceName']:=cServiceName;
    mResultJSON.I['HTTPStatus']:=404;
    mResultJSON.S['InputJSON']:=aJSON.AsString;
    mResultJSON.S['Status']:='Error1';
    mResultJSON.S['ExceptionMessage']:=ExceptionMessage;
    mResultJSON.S['ResponseText']:='';
    API_Result(mResultJSON);
  end;
end;


function API_GET(aURL:String; aIndex: integer = 0): TJSONSuperObject;
var
  mWinHTTP: Variant;
  mRequest, mLogin, mAuth: string;
  mJSON:TJSONSuperObject;
  mList:TStringList;
begin
  try
    mWinHTTP:= CreateOleObject('WinHttp.WinHttpRequest.5.1');
    mWinHTTP.Open('GET', aURL);
    mWinHTTP.SetRequestHeader('Content-Type', 'application/json');
    if aIndex=0 then mAuth:=cAuthorization;
    if aIndex=1 then mAuth:=cAuthorizationDE;
    if aIndex=2 then mAuth:=cAuthorizationAT;
    mWinHTTP.SetRequestHeader('Authorization','Basic '+mAuth);
    mWinHTTP.Send();
    Result:=TJSONSuperObject.ParseString(ConvertToText(mWinHTTP.Responsebody), True);
  except

  end;
end;



function ConvertToText(aUnicodeBytes: TBytes): String;
var
  mUnicodeBites: TBytes;
begin
  mUnicodeBites := TEncoding.Convert(aUnicodeBytes,Encoding_cpUTF_8,Encoding_cpUTF_16);
  Result := TEncoding.Unicode.GetString(mUnicodeBites);
end;


function ConvertUTF8toString(aString: String): String;
var
  mUnicodeBites: TBytes;
begin
  mUnicodeBites := TEncoding.UTF8.GetBytes(aString);
  mUnicodeBites := TEncoding.Convert(mUnicodeBites,Encoding_cpUTF_8,Encoding_cpUTF_16);
  Result := TEncoding.Unicode.GetString(mUnicodeBites);
end;

begin
end.