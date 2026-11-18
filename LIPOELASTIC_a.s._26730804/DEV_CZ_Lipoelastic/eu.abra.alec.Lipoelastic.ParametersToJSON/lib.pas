uses '.const', '.ReportStatus';

function API_POST(aJSON:TJSONSuperObject;aName:string):TJSONSuperObject;
var
 mWinHTTP:Variant;
 mResultJSON:TJSONSuperObject;
begin
  try
   mWinHTTP:= CreateOleObject('WinHttp.WinHttpRequest.5.1');
   mWinHTTP.Open('POST', cURL+aName);
   mWinHTTP.SetRequestHeader('Content-Type', 'application/json');
   mWinHTTP.SetRequestHeader('Authorization','Basic VGVzdDoxMjM=');       //U3VwZXJ2aXNvcjpyb3BhbWFzYQ==
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

begin
end.