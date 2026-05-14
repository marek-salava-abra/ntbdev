const
  cUserName = 'promos@kingtony.cz';
  cPassword = 'Michal499';
  cDefaultFirm_ID = 'AAA1000000'; //gastro
  cDocQueue_ID = '4200000101'; //OPA
  cDivision_ID = '1000000101'; // 100

function GetOrder_ID(AOS : TNxCustomObjectSpace; AFieldName : string; AValue : string) : string;
const
  cSQL = 'SELECT ID FROM ReceivedOrders WHERE %s like ''%s''';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    AOS.SQLSelect(Format(cSQL, [AFieldName, AValue]), mList);
    Result:='';
    if mList.Count > 0 then
      Result := mList.Strings[0]
  finally
    mList.Free;
  end;
end;

function GetFirmByFirmOffice(AOS : TNxCustomObjectSpace; AValue : string) : string;
const
  cSQL = 'SELECT FO.Parent_ID FROM FirmOffices FO LEFT JOIN Firms F ON F.ID=FO.Parent_ID WHERE F.Firm_ID is null and F.Hidden=''N'' and FO.OfficeIdentNumber = ''%s'' ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    AOS.SQLSelect(Format(cSQL, [AValue]), mList);
    Result:='';
    if mList.Count > 0 then
      Result := mList.Strings[0]
  finally
    mList.Free;
  end;
end;

function GetFirmOfficeByFirmName(AOS : TNxCustomObjectSpace; AValue : string) : string;
const
  cSQL = 'SELECT FO.ID FROM FirmOffices FO LEFT JOIN Firms F ON F.ID=FO.Parent_ID WHERE F.Firm_ID is null and F.Hidden=''N'' and FO.OfficeIdentNumber = ''%s'' ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    AOS.SQLSelect(Format(cSQL, [AValue]), mList);
    Result:='';
    if mList.Count > 0 then
      Result := mList.Strings[0]
  finally
    mList.Free;
  end;
end;

function GetFirmByIdentNumber(AOS : TNxCustomObjectSpace; AValue : string) : string;
const
  cSQL = 'SELECT ID FROM Firms WHERE Firm_ID is null and Hidden=''N'' and OrgIdentNumber = ''%s'' ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    AOS.SQLSelect(Format(cSQL, [AValue]), mList);
    Result:='';
    if mList.Count > 0 then
      Result := mList.Strings[0]
  finally
    mList.Free;
  end;
end;

function GetCurrencyID(AOS : TNxCustomObjectSpace; AValue : string) : string;
const
  cSQL = 'SELECT ID FROM Currencies WHERE Code = ''%s'' and Hidden=''N''';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    AOS.SQLSelect(Format(cSQL, [AValue]), mList);
    Result:='';
    if mList.Count > 0 then
      Result := mList.Strings[0]
  finally
    mList.Free;
  end;
end;

function GetPeriodID(AOS: TNxCustomObjectSpace; ADate: TDate): string;
var
  laPeriods: TStrings;
begin
  Result:='';
  laPeriods:=TStringList.Create;
  AOS.SQLSelect('Select P.ID from Periods P '+
                        'where '+FloatToStr(DateOf(ADate))+' between P.DateFrom$DATE and P.DateTo$DATE', laPeriods);
  if laPeriods.Count>0 then begin
    Result:=laPeriods.Strings(0);
  end;
end;

function GetToken: string;
var
  mWinHTTP: Variant;
  mJson: TJSONSuperObject;
  mToken,mRequest: string;
begin
  try
    mWinHTTP:= CreateOleObject('WinHttp.WinHttpRequest.5.1');
    mWinHTTP.Open('POST', 'https://api.dotykacka.cz/v2/signin/token');
    mWinHTTP.SetRequestHeader('Content-Type', 'application/json; charset=UTF-8');
    mWinHTTP.SetRequestHeader('Authorization', 'User bbe1baece9a4c7ff964199f2995fdfc7');
    mWinHTTP.SetRequestHeader('X-Password', cPassword);
    mRequest:= '{"_cloudId": "354810661"}';
    mWinHTTP.Send(mRequest);
    if mWinHTTP.Status <> 201 then begin    //kód <> 200 = dotaz vůbec neprošel
      if CFxNxRuntime.NxGetEnvironmentType = reRuntimeExe then ShowMessage('Nebylo možné vygenerovat přístupový token: ' + IntToStr(mWinHTTP.Status) +': '+ mWinHTTP.StatusText + ' '+mWinHTTP.ResponseText);
    end
    else begin
      mJson := TJSONSuperObject.ParseString(mWinHTTP.ResponseText, True);
      mToken := mJSon.S['accessToken'];
      Result:= mToken;
    end;
  except
    if CFxNxRuntime.NxGetEnvironmentType = reRuntimeExe then ShowMessage('Nastala neočekávaná chyba při získávání tokenu: '+ExceptionMessage);
  end;
end;

function API_GET(AURL:string; var AStatusCode:integer; AStatusText: string): TJSONSuperObject;
var
  mWinHTTP: Variant;
  mToken,mRequest: string;
begin
  try
    mToken:= GetToken;
    if NxIsBlank(mToken) then
      exit;
    mWinHTTP:= CreateOleObject('WinHttp.WinHttpRequest.5.1');
    mWinHTTP.Open('GET', AURL);
    mWinHTTP.SetRequestHeader('Content-Type', 'application/json; charset=UTF-8');
    mWinHTTP.SetRequestHeader('Accept', 'application/json; charset=UTF-8');
    mWinHTTP.SetRequestHeader('Authorization', 'Bearer '+mToken);
    mWinHTTP.Send('');
    AStatusCode:= mWinHTTP.Status;
    AStatusText:= mWinHTTP.StatusText + ' '+mWinHTTP.ResponseText;
    Result := TJSONSuperObject.ParseString(mWinHTTP.ResponseText, True);
  except
    if CFxNxRuntime.NxGetEnvironmentType = reRuntimeExe then ShowMessage('Při GET dotazu do Markeeta nastala neočekávaná chyba: '+ExceptionMessage);
  end;
end;

begin
end.