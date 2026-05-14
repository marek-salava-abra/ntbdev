uses
  'eu.abra.PostProviders.uSQLFunc',
  'eu.abra.PostProviders.uLanguage',
  'eu.abra.PostProviders.uLog';

//Získá uživatele a heslo z poskytovatele, nebo skladu na balíčku
function WSGetPassForPackage(var ABOPDMIssuedDoc: TNxCustomBusinessObject; var AUser:String; var APass:String):Boolean;
var mRes : String;
begin
  AUser := '';
  APass := '';
  Result := True;
  mRes := '';
  mRes := GetFirstRecordFromSQL(ABOPDMIssuedDoc.ObjectSpace,'select X_PD_UseStores from PDMPostProviders where X_PD_IsLicensed = ''A'' and X_PD_BB_ProviderModul = 1');

  if ABOPDMIssuedDoc.HasField('X_PD_Setting_ID') then
  begin
    if not CFxOID.IsEmptyOrFull( ABOPDMIssuedDoc.GetFieldValueAsString('X_PD_Setting_ID') ) then
      mRes := 'X';
  end;

  if mRes = 'A' then
  begin
    if ABOPDMIssuedDoc.GetFieldValueAsString('X_PD_Store_ID.X_PD_ClientID') <> '' then
    begin
      AUser := ABOPDMIssuedDoc.GetFieldValueAsString('X_PD_Store_ID.X_PD_ClientID');
      APass := ABOPDMIssuedDoc.GetFieldValueAsString('X_PD_Store_ID.X_PD_ClientPass');
    end
    else
      Result := False;
  end
  else if mRes = 'X' then
  begin
    if ABOPDMIssuedDoc.GetFieldValueAsString('X_PD_Setting_ID.X_PD_APIUser') <> '' then
    begin
      AUser := ABOPDMIssuedDoc.GetFieldValueAsString('X_PD_Setting_ID.X_PD_APIUser');
      APass := ABOPDMIssuedDoc.GetFieldValueAsString('X_PD_Setting_ID.X_PD_APIPassword');
    end
    else
      Result := False;
  end
  else
  begin
    AUser := ABOPDMIssuedDoc.GetFieldValueAsString('PostProvider_ID.X_PD_WSUser');
    APass := ABOPDMIssuedDoc.GetFieldValueAsString('PostProvider_ID.X_PD_WSPass');
  end;

end;


function GetHTTP(var WinHttpRequest: Variant): Boolean;
begin
  try
    if not VarIsType(WinHttpRequest, varDispatch) then
      WinHttpRequest := CreateOleObject('WinHttp.WinHttpRequest.5.1');
    Result := True;
  except
    WinHttpRequest := nil;
    Result := False;
    RaiseException(ExceptionMessage);
  end;
end;

function WSPostFile(AContext: TNxContext; const AFileName, AURL: string; var AResponseText: string; AAddProlog: Boolean = false;
  var APostProviderBO : TNxCustomBusinessObject = nil; AUseUTF8Encoding : Boolean = false): string;
var
  mFileName: string;
  mData: TStringList;
  mMessage, mStr, mFunctionName: string;
  mWinHTTP: Variant;
  mResponseText, mStatusText: string;
  mBytes: TBytes;
begin
  Result := '';
  AResponseText := '';
  mData := TStringList.Create;

  try
    if AUseUTF8Encoding then
      mData.LoadFromFile(AFileName, TEncoding.UTF8)
    else
      mData.LoadFromFile(AFileName);

    OutputDebugString(AURL);
    OutputDebugString(mData.text);

    if AAddProlog then
      mData.Insert(0, '<?xml version="1.0" encoding="utf-8"?>');

    if GetHTTP(mWinHTTP) then begin
      mWinHTTP.Open('POST', AURL);
      mWinHTTP.SetRequestHeader('Content-Type', 'text/xml; charset=utf-8;');
      if APostProviderBO <> nil then
        mWinHTTP.SetRequestHeader('Authorization','Basic '+ EncodeBase64(TEncoding.UTF8.GetBytes(APostProviderBO.GetFieldValueAsString('X_PD_WSUser')+ ':'+APostProviderBO.GetFieldValueAsString('X_PD_WSPass'))));
      mWinHTTP.Send(mData.Text);
      Result := mWinHTTP.StatusText;
      AResponseText := mWinHTTP.ResponseText;
      OutputDebugString(mWinHTTP.ResponseText);
    end;
  finally
    mData.Free;
  end;
end;

//Z balíčku zjistím přístupové údaje pro komunikaci. Ze skladu pomocí funkce WSGetPassForPackage
function WSPostFile_2(AContext: TNxContext; const AFileName, AURL: string; var AResponseText: string; var APDMIssuedDocBO : TNxCustomBusinessObject = nil; ): Integer;
var
  mFileName, mUser, mPass: string;
  mData: TStringList;
  mMessage, mStr, mFunctionName: string;
  mWinHTTP: Variant;
  mResponseText, mStatusText: string;
  mBytes: TBytes;
begin
  Result := -1;
  AResponseText := '';
  mData := TStringList.Create;
  try
    mData.LoadFromFile(AFileName);
    OutputDebugString(AURL);
    OutputDebugString(mData.text);

    if GetHTTP(mWinHTTP) then begin
      mWinHTTP.Open('POST', AURL);
      mWinHTTP.SetRequestHeader('Content-Type', 'application/json; charset=utf-8;');
      mWinHTTP.SetRequestHeader('BB-Partner', '.k.iwwKxE50aJP0a');

      if WSGetPassForPackage(APDMIssuedDocBO, mUser, mPass) then
        mWinHTTP.SetRequestHeader('Authorization','Basic '+ EncodeBase64(TEncoding.UTF8.GetBytes( mUser + ':'+mPass)));

      mWinHTTP.Send(mData.Text);
      Result := mWinHTTP.Status;
      AResponseText := mWinHTTP.ResponseText;
      WriteEvent(Format('Response url : %s', [AURL]));
      WriteEvent(Format('Response code: %d', [mWinHTTP.Status]));
      WriteEvent(Format('Response body: %s', [AResponseText]));
      OutputDebugString(mWinHTTP.ResponseText);
    end;
  finally
    mData.Free;
  end;
end;


//Z balíčku zjistím přístupové údaje pro komunikaci. Ze skladu pomocí funkce WSGetPassForPackage
function WSPostFile_3(AContext: TNxContext; var AStream: TMemoryStream; const AURL: string; var AResponseText: string; var APDMIssuedDocBO : TNxCustomBusinessObject = nil; ): Integer;
var
  mFileName, mUser, mPass, mID: string;
  mMessage, mStr, mFunctionName: string;
  mWinHTTP: Variant;
  mResponseText, mStatusText: string;
  mBytes: TBytes;
begin
  Result := -1;
  AResponseText := '';
  OutputDebugString(AURL);
  OutputDebugString(NxReadString(AStream));

    if GetHTTP(mWinHTTP) then begin
      mWinHTTP.Open('POST', AURL);
      mWinHTTP.SetRequestHeader('Content-Type', 'application/json; charset=utf-8;');
      mWinHTTP.SetRequestHeader('BB-Partner', '.k.iwwKxE50aJP0a');

      if WSGetPassForPackage(APDMIssuedDocBO, mUser, mPass) then
        mWinHTTP.SetRequestHeader('Authorization','Basic '+ EncodeBase64(TEncoding.UTF8.GetBytes( mUser + ':'+mPass)));

      mWinHTTP.Send( NxReadString(AStream) );
      Result := mWinHTTP.Status;
      AResponseText := mWinHTTP.ResponseText;

      if APDMIssuedDocBO <> nil then
        mID := APDMIssuedDocBO.OID
      else
        mID := '0000000000';

      WriteEvent(Format('%s: Response url : %s', [mID, AURL]));
      WriteEvent(Format('%s: Response code: %d', [mID, mWinHTTP.Status]));
      WriteEvent(Format('%s: Response body: %s', [mID, AResponseText]));
      OutputDebugString(mWinHTTP.ResponseText);
    end;
end;




function WSGetFile(AContext: TNxContext; const AURL: string; var AResponseText: string; var APostProvider: TNxCustomBusinessObject): Integer;
var
  mWinHTTP: Variant;
begin
  Result := -1;
  try
    if GetHTTP(mWinHTTP) then begin
      OutputDebugString(AURL);
      mWinHTTP.Open('GET', AURL);
      mWinHTTP.SetRequestHeader('Content-Type', 'application/json');
      mWinHTTP.SetRequestHeader('BB-Partner', '.k.iwwKxE50aJP0a');
      mWinHTTP.SetRequestHeader('Authorization','Basic '+ EncodeBase64(TEncoding.UTF8.GetBytes(APostProvider.GetFieldValueAsString('X_PD_WSUser')+ ':'+APostProvider.GetFieldValueAsString('X_PD_WSPass'))));
      mWinHTTP.Send();
      Result := mWinHTTP.Status;
      AResponseText := mWinHTTP.ResponseText;
    end;
  except
    RaiseException(lng_msg_APIError+ AURL+' '+ ExceptionMessage);
  end;
end;


function WSGetBytes(AContext: TNxContext; const AURL: string; var ABytes: TBytes; var APostProvider: TNxCustomBusinessObject): Integer;
var
  mWinHTTP: Variant;
begin
  Result := -1;
  try
    if GetHTTP(mWinHTTP) then begin
      mWinHTTP.Open('GET', AURL);
      mWinHTTP.SetRequestHeader('Content-Type', 'application/json');
      mWinHTTP.SetRequestHeader('BB-Partner', '.k.iwwKxE50aJP0a');
      mWinHTTP.SetRequestHeader('Authorization','Basic '+ EncodeBase64(TEncoding.UTF8.GetBytes(APostProvider.GetFieldValueAsString('X_PD_WSUser')+ ':'+APostProvider.GetFieldValueAsString('X_PD_WSPass'))));
      mWinHTTP.Send();
      Result := mWinHTTP.Status;
      ABytes := mWinHTTP.ResponseBody;
    end;
  except
    RaiseException(lng_msg_APIError+ AURL+' '+ ExceptionMessage);
  end;
end;

begin
end.