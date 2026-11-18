const
 cURL = 'https://pneub2b.eu/SupplierCommunication.ashx?cmd=';
 cLogin = '8200';
 cPass = 'KingTonyDodavatel.';
 cRO_DocQueue_ID = '1BE0000101';

function API_POST(aURL, aLogin, aPass: String; aResponseXML:TNxScriptingXMLWrapper; aOS:TNxCustomObjectSpace): TNxScriptingXMLWrapper;
var
  mWinHTTP: Variant;
  mResponse, mPost: TMemoryStream;
  mBytes: TBytes;
begin
  Result := nil;
  try
    mPost:=TMemoryStream.create;
    aResponseXML.saveToBytes(mBytes,'UTF-8');
    mWinHTTP := CreateOleObject('WinHttp.WinHttpRequest.5.1');
    mWinHTTP.Open('POST', aURL, False);
    mWinHTTP.SetRequestHeader('Content-Type', 'application/xml');
    mWinHTTP.SetRequestHeader('Authorization', 'Basic ' + EncodeBase64(TEncoding.UTF8.GetBytes(aLogin + ':' + aPass)));
    mWinHTTP.Send(mBytes);

    if mWinHTTP.Status = 200 then
    begin
      mResponse := TMemoryStream.Create;
      try
        mResponse.SetBytes(mWinHTTP.ResponseBody);
        mResponse.Position := 0;

        Result := TNxScriptingXMLWrapper.Create;
        Result.LoadFromStream(mResponse);
      finally
        mResponse.Free;
      end;
    end;
  except
    if Assigned(Result) then
    begin
      Result.Free;
      Result := nil;
    end;
    CFxLog.SaveLog(NxCreateContext(aOS),'LS','chyba',ExceptionMessage,2,now);
  end;
end;

function GetDynSource (AOS : TNxCustomObjectSpace; AValue : string) : String;

const
  cSQL = 'SELECT DataSource FROM Reports WHERE ID=''%s'' ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    Result:='';
    AOS.SQLSelect(Format(cSQL, [ AValue]), mList);
    if mList.Count > 0 then
      Result := (mList.Strings[0]);
  finally
    mList.Free;
  end;
end;

begin
end.