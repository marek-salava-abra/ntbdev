var
  gUpdated, gCreated: Integer;

// API_POST - Odesílání dat na API v JSON formátu
function API_POST(aJSON:TJSONSuperObject;AName:string; AIsScript: Boolean = True; aIndex: integer = 0):TJSONSuperObject;
var
 mWinHTTP:Variant;
 mResultJSON:TJSONSuperObject;
 mSuffix, mURL: string;
begin
  mSuffix:= '';
  try
   mWinHTTP:= CreateOleObject('WinHttp.WinHttpRequest.5.1');
   mURl:='https://api.barton.cz:8444/barton/'+mSuffix+aName;  // UPRAVIT: URL_ENDPOINT nahradit správným URL
   mWinHTTP.Open('POST', mURL);
   mWinHTTP.SetRequestHeader('Content-Type', 'application/json');
   mWinHTTP.SetRequestHeader('Authorization','Basic '+EncodeBase64(TEncoding.UTF8.GetBytes('API:ApiHeslo')));
   mWinHTTP.Send(aJSON.AsJson);
   if mWinHTTP.status='200' then begin
     Result:=TJSONSuperObject.ParseString(mWinHTTP.ResponseText, True);
   end else begin
     Result:=TJSONSuperObject.create;
     Result.S['ID']:='';
   end;
  except
   Result:=TJSONSuperObject.create;
   Result.S['error']:='error';
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
    mWinHTTP.SetRequestHeader('Authorization','Basic '+EncodeBase64(TEncoding.UTF8.GetBytes('API:ApiHeslo')));
    mWinHTTP.Send();
    Result:=TJSONSuperObject.ParseString(ConvertToText(mWinHTTP.Responsebody), True);
  except
    Result:=TJSONSuperObject.create;
    Result.S['error']:='error';
  end;
end;

function ConvertToText(aUnicodeBytes: TBytes): String;
var
  mUnicodeBites: TBytes;
begin
  mUnicodeBites := TEncoding.Convert(aUnicodeBytes,Encoding_cpUTF_8,Encoding_cpUTF_16);
  Result := TEncoding.Unicode.GetString(mUnicodeBites);
end;

begin
end.