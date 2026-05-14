Function ImportImage(var AOS:TNxCustomObjectSpace; var aID:String):string;
var
 mBO:TNxCustomBusinessObject;
 mJSON:TJSONSuperObject;
 mURL:string;
begin
  mJSON:=TJSONSuperObject.Create;
  mJSON:=API_GET_Picture('http://api.abra-cz.prod.ad.lipoelastic.com:82/Lipoelastic/script/webapi/lib/picture/'+aID);
  //NxShowSimpleMessage(mJSON.AsString,nil);
  try
   mBO:=aos.CreateObject(Class_PLMPicture);
   mBO.New;
   mbo.Prefill;
   mbo.SetFieldValueAsString('Name',mJSON.S['name']);
   mbo.SetFieldValueAsBytes('Picture_ID.BlobData', savePictureData(encodePictureToFile(mJSON.S['base64Data'], mJSON.S['type'])));
   mbo.save;
   Result:=mbo.OID;
   mbo.free;
  except
   NxShowSimpleMessage(ExceptionMessage,nil);
  end;
end;

function API_GET_Picture(AURL:string): TJSONSuperObject;
var
  mWinHTTP: Variant;
  mRequest, mLogin: string;
begin
  try
    mWinHTTP:= CreateOleObject('WinHttp.WinHttpRequest.5.1');
    mWinHTTP.Open('GET', AURL);
    mWinHTTP.SetRequestHeader('Content-Type', 'application/json');
    mWinHTTP.SetRequestHeader('Authorization','Basic VGVzdDoxMjM=');
    mWinHTTP.Send('');
    Result := TJSONSuperObject.ParseString(mWinHTTP.ResponseText, True);
  except
    Result:= TJSONSuperObject.Create;
    Result.S['Except']:= 'Funkce API_GET - nastala neočekávaná chyba: '+ExceptionMessage;
  end;
end;

function encodePictureToFile(aData: String; aType: String): String;
var
  mStream: TMemoryStream;
begin
  mStream := TMemoryStream.Create;
  try
    mStream.SetBytes(DecodeBase64(aData));
    NxCreateTempFile(Result);
    DeleteFile(Result);
    Result := Result + '.' + aType;
    OutputDebugString(Result);
    mStream.SaveToFile(Result);
  finally
    mStream.Free;
  end;
end;

function savePictureData(aFileName: String): TBytes;
var
  mPicture: TPicture;
  mStream: TMemoryStream;
begin
  mStream := TMemoryStream.Create;
  mPicture := TPicture.Create;
  try
    mPicture.LoadFromFile(aFileName);
    mPicture.SaveMultiFormatToStream(mStream);
    Result := mStream.GetBytes;
    DeleteFile(aFileName);
  finally
    mPicture.Free;
    mStream.Free;
  end;
end;


begin
end.