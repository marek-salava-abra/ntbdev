uses  'eu.abra.roeh.Logio.ConstVar',
       'eu.abra.roeh.Logio.func',
      'eu.abra.roeh.Logio.LibCsv';

function SQLSelect(aObjSpace: TNxCustomObjectSpace; aSQL: string): string;
var mRes: TStringList;
begin
  Result:= '';
  mRes:= TStringList.Create;
  try
    aObjSpace.SQLSelect(aSQL, mRes);
    if mRes.Count > 0 then
      Result:= mRes[0];
  finally
    mRes.Free;
  end;
end;

procedure CreateInitSetings(aObjSpace: TNxCustomObjectSpace; aName, aValue: string);
var mSQL: string;
    mBO: TNxCustomBusinessObject;
begin
  mSQL:= 'Select Count(ID) from DefRollData where CLSID = ''%s'' and Hidden=''N'' and Code=''%s'' ';
  mSQL:= Format(mSQL, [cBusOrderStore, aName]);
  if SQLSelect(aObjSpace, mSQL) = '0' then
  begin
    mBO:= aObjSpace.CreateObject(cBusOrderStore);
    try
      mBO.New;
      mBO.Prefill;
      mBO.SetFieldValueAsString('Code', aName);
      mBO.SetFieldValueAsString('Name', aValue);
      mBO.Save;
    finally
      mBO.Free;
    end;
  end;
end;

function SetValueToStorageOS(AName: string; AValue: string; AObjectSpace: TNxCustomObjectSpace; AAgend: String = ''): Boolean;
var
  mPars: TNxParameters;
  mCon: TNxContext;
begin
  Result := False;
  mCon := NxCreateContext(AObjectSpace);
  try
    mPars := TNxParameters.Create;
    try
      if AAgend <> '' then
        AName := AAgend + '_' + AName;
      mPars.GetOrCreateParam(dtString, AName).AsString := AValue;
      try
        mCon.GetCompanyCache.SavePropertiesForCompany(AName, mPars);
        Result := True;
      except
        Result := False;
      end;
    finally
      mPars.Free;
    end;
  finally
    mCon.Free;
  end;
end;

function GetValueFromStorageOS(AName: string; AObjectSpace: TNxCustomObjectSpace; AAgend: String= ''): string;
var
  mPars: TNxParameters;
  mCon: TNxContext;
begin
  Result := '';
  mCon := NxCreateContext(AObjectSpace);
  try
    mPars := TNxParameters.Create;
    try
      if AAgend <> '' then
        AName := AAgend + '_' + AName;
      mCon.GetCompanyCache.LoadPropertiesForCompany(AName, mPars);
      Result := mPars.GetOrCreateParam(dtString, AName).AsString;
    finally
      mPars.Free;
    end;
  finally
    mCon.Free;
  end;
end;

// Rušení persistentních dat přes TNxCompanyCache - náhrada INI souboru
// Zatím podpora pouze pro string
procedure DeleteValueFromStorageOS(AName: string; AObjectSpace: TNxCustomObjectSpace; AAgend: String= '');
var
  mCon: TNxContext;
begin
  mCon := NxCreateContext(AObjectSpace);
  try
    if AAgend <> '' then
      AName := AAgend + '_' + AName;
    mCon.GetCompanyCache.DeletePropertiesForCompany(AName);
  finally
    mCon.Free;
  end;
end;

// Rušení persistentních dat přes TNxCompanyCache - náhrada INI souboru
// Zatím podpora pouze pro string
// na uživatele
procedure DeleteValueFromStorageForUserOS(AName: string; AObjectSpace: TNxCustomObjectSpace; AAgend: String= '');
var
  mCon: TNxContext;
begin
  mCon := NxCreateContext(AObjectSpace);
  try
    if AAgend <> '' then
      AName := AAgend + '_' + AName;
    mCon.GetCompanyCache.DeleteProperties(AName);
  finally
    mCon.Free;
  end;
end;

function GetValueFromStorageForUserOS(AName: string; AObjectSpace: TNxCustomObjectSpace; AAgend: String= ''): string;
var
  mPars: TNxParameters;
  mCon: TNxContext;
begin
  Result := '';
  mCon := NxCreateContext(AObjectSpace);
  try
    mPars := TNxParameters.Create;
    try
      if AAgend <> '' then
        AName := AAgend + '_' + AName;
      mCon.GetCompanyCache.LoadProperties(AName, mPars);
      Result := mPars.GetOrCreateParam(dtString, AName).AsString;
    finally
      mPars.Free;
    end;
  finally
    mCon.Free;
  end;
end;

function SetValueToStorageForUserOS(AName: string; AValue: string; AObjectSpace: TNxCustomObjectSpace; AAgend: String = ''): Boolean;
var
  mPars: TNxParameters;
  mCon: TNxContext;
begin
  Result := False;
  mCon := NxCreateContext(AObjectSpace);
  try
    mPars := TNxParameters.Create;
    try
      if AAgend <> '' then
        AName := AAgend + '_' + AName;
      mPars.GetOrCreateParam(dtString, AName).AsString := AValue;
      try
        mCon.GetCompanyCache.SaveProperties(AName, mPars);
        Result := True;
      except
        Result := False;
      end;
    finally
      mPars.Free;
    end;
  finally
    mCon.Free;
  end;
end;

procedure CreateInitRecord(aObjSpace: TNxCustomObjectSpace);
begin
  if GetValueFromStorageOS(cInitInventoroParam, aObjSpace, '') <> 'OK' then begin
    try
      CreateInitSetings(aObjSpace, 'EXPORT', '');
      CreateInitSetings(aObjSpace, 'PROMO', '');
      CreateInitSetings(aObjSpace, 'PROMODYN', '');
      CreateInitSetings(aObjSpace, 'FTP_IP', '');
      CreateInitSetings(aObjSpace, 'FTP_PASS', '');
      CreateInitSetings(aObjSpace, 'FTP_PORT', '21');
      CreateInitSetings(aObjSpace, 'FTP_USER', '');
      CreateInitSetings(aObjSpace, 'FTP_DIR', '');
      CreateInitSetings(aObjSpace, 'lt_provide', '14');
      CreateInitSetings(aObjSpace, 'MAXPROVIDE', '30');
      CreateInitSetings(aObjSpace, 'MINDATE', '1095');
      CreateInitSetings(aObjSpace, 'PATH', '');
      CreateInitSetings(aObjSpace, 'URL', '');
      CreateInitSetings(aObjSpace, 'DEFAULTST', '');
      CreateInitSetings(aObjSpace, 'NEWPRODUCT', '90');
      CreateInitSetings(aObjSpace, 'FREQCALC', '7');
    finally
      SetValueToStorageOS(cInitInventoroParam, 'OK', aObjSpace, '');
    end;
  end;
end;

function IsSupervisor(AObjectSpace: TNxCustomObjectSpace): Boolean;
const
  cSQL = 'SELECT surl.user_id FROM SECURITYPRIVILEGERIGHTS spr inner join SECURITYUSERROLELINKS surl on surl.role_id=spr.role_id where spr.classid=''G1TDNZSKTVCL33N2010DELDFKK''';
var
  mSupervisors: TStringList;
  mCurrentUser: String;
begin
  mCurrentUser := NxGetActualUserID(AObjectSpace);
  mSupervisors := TStringList.Create;
  try
    AObjectSpace.SQLSelect(cSQL, mSupervisors);
    Result := mSupervisors.IndexOf(mCurrentUser) >= 0;
  finally
    mSupervisors.Free;
  end;
end;

function IsMassChange(AObjectSpace: TNxCustomObjectSpace): Boolean;
const
  cSQL = 'SELECT surl.user_id FROM SECURITYPRIVILEGERIGHTS spr inner join SECURITYUSERROLELINKS surl on surl.role_id=spr.role_id where (spr.classid=''G1TDNZSKTVCL33N2010DELDFKK'') or (spr.classid=''AMPHLDJQA5QOFGNWN50WZIKSRG'')';
var
  mSupervisors: TStringList;
  mCurrentUser: String;
begin
  mCurrentUser := NxGetActualUserID(AObjectSpace);
  mSupervisors := TStringList.Create;
  try
    AObjectSpace.SQLSelect(cSQL, mSupervisors);
    Result := mSupervisors.IndexOf(mCurrentUser) >= 0;
  finally
    mSupervisors.Free;
  end;
end;

function ExistFirm(mBO:TNxCustomObjectSpace; const iFirmCode,iFirmName,iVATIdentNumber,iAddr1,iAddr2,iAddr3,iPhoneNumber1,iFaxNumber:string):string;// získá nebo založí firmu
var
  Str: TStringList;
  mId:String;
  mBoFirm,mAdr:TNxCustomBusinessObject;
begin
  Result:= '';
  Str := TStringList.Create;
  try
    Str.Clear;
    if Trim(iVATIdentNumber) <> '' then mBo.SQLSelect('select id from firms f where f.Hidden <> ''A'' and f.VATIdentNumber =''' + Trim(iVATIdentNumber) + '''',Str);
    if Str.Count > 0 then Result := Str.Strings[0] //       // firma je nalezena
      else begin
        mBo.SQLSelect('select id from firms f where f.Hidden <> ''A'' and f.Name =''' + iFirmName + '''',Str);
        if Str.Count > 0 then Result := Str.Strings[0]; //       // firma je nalezena
      end;
  finally
    Str.free;
  end;
  if Result = '' then begin
    mBoFirm := mBO.CreateObject('4K3EXM5PQBCL35CH000ILPWJF4'); // založímeme si firmu
    try
      mBoFirm.New;
      mBoFirm.Prefill;
      mBoFirm.SetFieldValueAsString('Code',CopyLT(iFirmCode,20));
      mBoFirm.SetFieldValueAsString('Name',CopyLT(iFirmName,80));
      mBoFirm.SetFieldValueAsString('VATIdentNumber',CopyLT(iVATIdentNumber,20));
      mAdr := mBoFirm.GetMonikerForFieldCode(mBoFirm.GetFieldCode('ResidenceAddress_ID')).BusinessObject;
      mAdr.SetFieldValueAsString('PhoneNumber1',CopyLT(iPhoneNumber1,30));
      mAdr.SetFieldValueAsString('FaxNumber',CopyLT(iFaxNumber,30));
//      mAdr.SetFieldValueAsString('OfficialHouseNumber',CopyLT(iAddr1,50));
      mAdr.SetFieldValueAsString('Street' ,CopyLT(iAddr1,60));
      mAdr.SetFieldValueAsString('City' ,CopyLT(iAddr2,60));
      mAdr.SetFieldValueAsString('Country' ,CopyLT(iAddr3,40));
      mId := mBoFirm.GetFieldValueAsString('ID');
      mBoFirm.Save;
      Result := mID;
    finally
      mBoFirm.Free;
    end;
  end;
end;

function DateConvert(const mDate:string): string; // konvertuje z daného formátu datum do standardu data windows
begin
  Result := Copy(mDate,7,2) + DateSeparator + Copy(mDate,5,2) + DateSeparator + Copy(mDate,1,4)
end;

function GetTradeType(mCSVStr : TStringList;N:Integer;const cPMNo,cVatCode:String):integer;
var
  mColum : Integer;
  mValue,  mPaymentNoOld, mPaymentNo : string;
  mUvoz : Boolean;
begin
  Result := 1;
  mColum:= GetColumIndex(cPMNo,mCSVStr.Strings(0),cEvaluator,mUvoz);
  mPaymentNo := GetColum(mColum,mCSVStr.Strings(N),cEvaluator);
  mPaymentNoOld := mPaymentNo;
  While  (N<= mCSVStr.Count - 1) and (mPaymentNoOld = mPaymentNo) do begin  // cyklus na řádky
     mColum:= GetColumIndex(cVatCode,mCSVStr.Strings(0),cEvaluator,mUvoz);
     mValue:=Trim(GetColum(mColum,mCSVStr.Strings(N),cEvaluator));
     if (mValue = '20') then Break; // tuzemský
     // NA neřeším to je ostatní
     if (mValue = 'EX') then break; // Export, ale neřešíme je jen mimo DPH
     if (mValue = 'RC') then begin // Reverse charge
       Result := 2;
       break;
     end;
    Inc(N);
    if N< mCSVStr.Count then begin // zjistíme VS z dalšího řádku
      mColum:= GetColumIndex(cPMNo,mCSVStr.Strings(0),cEvaluator,mUvoz);
      mPaymentNo := GetColum(mColum,mCSVStr.Strings(N),cEvaluator);
    end else mPaymentNo := '';
  end;
end;




begin
end.