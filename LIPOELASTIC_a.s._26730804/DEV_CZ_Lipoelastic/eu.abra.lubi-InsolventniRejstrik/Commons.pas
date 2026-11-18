uses
  'eu.abra.lubi-InsolventniRejstrik.uLicence',
  'eu.abra.lubi-InsolventniRejstrik.uProgressForm',
  'eu.abra.lubi-InsolventniRejstrik.uTransactions';

const
  cCLSIDInsolventIndexBussinesObject = '30GI1J230G5O1IGJ4V20RGZLEO';
  cCLSIDInsolventIndexSettingsBussinesObject = 'WDRPQOEXWZWO540K4B4MBNGWUS';
  cEMail = 'EMail';
  cOkRecord = 'Bylo spracováno %d záznamů.';
  cDLLDir = '_exe\';
  cDllName = 'InsolventIndex.dll';
  cJusticeDir = 'JusticeCzeIsir\';
  

  cNullOID = '0000000000';
  cInDebug = False;
  cUseDebugger = True;
  cAppName = 'eu.abra.lubi-InsolventniRejstrik';
  cCrLf = #13#10;
  cStav0 = 'Běžící ins.řízení';
  cStav1 = 'Prohlášení úpadku';
  cStav2 = 'Ukončené ins.řízení';
  cAutoErrorRepeatValue = 10;

////////////////////////////////////////////////////////////////////////////////
// LUBI pomocne funkce
////////////////////////////////////////////////////////////////////////////////

procedure ShowDebugMessage(AMessage: Variant);
begin
  if cInDebug then begin
    if cUseDebugger then
      OutputDebugString(Format('%s : %s',[cAppName, VarToStr(AMessage)]))
    else
      ShowMessage(Format('%s : %s',[cAppName, VarToStr(AMessage)]));
  end;
end;

function GetFirstRecordFromSQL(AOS: TNxCustomObjectSpace; ASQL: String): String;
var
  mSQLRes: TStrings;
begin
  Result := '';
  mSQLRes := TStringList.Create;
  try
    AOS.SQLSelect(ASQL, mSQLRes);
    if mSQLRes.Count > 0 then
      Result := mSQLRes.Strings[0]
  finally
    mSQLRes.Free;
  end;
end;

{** To samé jako Token, ale respektuje i prázdné položky }
function CdTokenEx(var AStr: string; const ASeparators: string): string;
var
  i: Integer;
begin
  i := NxCharPos(ASeparators, AStr);
  if i > 0 then begin
    Result := Copy(AStr, 1, i-1);
    Delete(AStr, 1, i-1);
    Delete(AStr, 1, Length(ASeparators));
//    AStr := TrimL(AStr, ASeparators);
  end
  else begin
    Result := AStr;
    AStr := '';
  end;
end;

{** To samé jako Token, ale respektuje i prázdné položky }
function CdTokenExR(var Str: string; const Separators: string): string;
var I: Integer;
begin
  //Str := TrimR(Str, Separators);
  I := NxCharPosR(Separators, Str);
  if I > 0 then begin
    Result := Copy(Str, I + 1, Length(Str));
    Delete(Str, I + 1, Length(Str));
    //Str := TrimR(Str, Separators);
    end
  else begin
    Result := Str;
    Str := '';
  end;
end;

// dotazovaci messagebox
function CdConfirmMessageBox_YesRes(ACaption, AText: string; AParent: TSiteForm): Boolean;
var
  mRes: integer;
begin
  Result := False;
  mRes := NxMessageBox(ACaption, AText, mdConfirm, mdbYesNo, 1, nil, False, AParent);
  if mRes = mrYes{6} then
    Result := True
end;

//------------------------------------------------------------------------------

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
  ShowDebugMessage('GetValueFromStorageOS - ' + AName);
  ShowDebugMessage('REsult - ' + Result);
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

procedure CreateInitSetings(aObjSpace: TNxCustomObjectSpace; aName, aValue: string);
var mSQL: string;
    mBO: TNxCustomBusinessObject;
begin
  mSQL:= 'Select Count(ID) from DefRollData where CLSID = ''%s'' and Hidden=''N'' and Code=''%s'' ';
  mSQL:= Format(mSQL, [cCLSIDInsolventIndexSettingsBussinesObject, aName]);
  if GetFirstRecordFromSQL(aObjSpace, mSQL) = '0' then
  begin
    mBO:= aObjSpace.CreateObject(cCLSIDInsolventIndexSettingsBussinesObject);
    try
      mBO.New;
      mBO.Prefill;
      mBO.SetFieldValueAsString('Code', aName);
      mBO.SetFieldValueAsString('U_Data', aValue);
      mBO.Save;
    finally
      mBO.Free;
    end;
  end;
end;

procedure CreateInitRecord(aObjSpace: TNxCustomObjectSpace);
begin
  // LUBI puvodni hodnoty RONE - nutne zachovat z duvodu zpetne kompatibility
  if GetValueFromStorageOS('InsolventIndex.InitSerrings', aObjSpace, '') <> 'OK' then begin
    try
      CreateInitSetings(aObjSpace, 'Body', 'Nové firmy v insolvenčním rejstříku, vůči kterým jsou evidovány pohledávky: {CRLF} %s');
      CreateInitSetings(aObjSpace, 'Subject', 'Insolvenční rejstřík');
      CreateInitSetings(aObjSpace, 'Warning', 'Firma je evidována v Insolvenčním rejstříku !!!');
      CreateInitSetings(aObjSpace, 'NewFVBody', 'Byla zadána nová faktura %s na firmu %s která je evidována v insolvenčním rejstoíku.');
      CreateInitSetings(aObjSpace, 'SMTPPort', '25');
      CreateInitSetings(aObjSpace, 'SMTPServer', '');
      CreateInitSetings(aObjSpace, 'SMTPLogin', '');
      CreateInitSetings(aObjSpace, 'SMTPPass', '');
      CreateInitSetings(aObjSpace, 'SMTPSender', '');
    finally
      SetValueToStorageOS('InsolventIndex.InitSerrings', 'OK', aObjSpace, '');
    end;
  end;
  // nové položky nastavení vyhodnocení
  if GetValueFromStorageOS('InsolventIndex.NewSettings', aObjSpace, '') <> 'OK' then begin
    try
      CreateInitSetings(aObjSpace, 'NEVYRIZENA', cStav0);
      CreateInitSetings(aObjSpace, 'OBZIVLA', cStav0);
      CreateInitSetings(aObjSpace, 'VYRIZENA', cStav0);
      CreateInitSetings(aObjSpace, 'MORATORIUM', cStav0);
      CreateInitSetings(aObjSpace, 'NEVYR-POST', cStav0);
      CreateInitSetings(aObjSpace, 'KONKURS', cStav1);
      CreateInitSetings(aObjSpace, 'K-PO ZRUŠ.', cStav1);
      CreateInitSetings(aObjSpace, 'ÚPADEK', cStav1);
      CreateInitSetings(aObjSpace, 'REORGANIZ', cStav1);
      CreateInitSetings(aObjSpace, 'ODDLUŽENÍ', cStav1);
      CreateInitSetings(aObjSpace, 'PRAVOMOCNA', cStav2);
      CreateInitSetings(aObjSpace, 'ODSKRTNUTA', cStav2);
    finally
      SetValueToStorageOS('InsolventIndex.NewSettings', 'OK', aObjSpace, '');
    end;
  end;
end;

procedure GetEmails(aObjSpace: TNxCustomObjectSpace; aIDs: TStringList);
var mSQL: string;
    i: Integer;
begin
  if not Assigned(aIDs) then Exit;
  mSQL:= 'select UD.StringFieldValue From DefRollData A' +
         ' left join UserData UD on UD.ID = A.ID and UD.FieldCode = 2000001 and UD.CLSID = ''%s'' '+
         ' where A.CLSID = ''%s'' and A.Code = ''%s'' and A.Hidden = ''%s'' ';
  aObjSpace.SQLSelect(Format(mSQL, [cCLSIDInsolventIndexSettingsBussinesObject, cCLSIDInsolventIndexSettingsBussinesObject, cEMail, 'N']), aIDs);
  for i:= 0 to aIDs.Count - 1 do begin
    if Copy(aIDs[i], 1, 1) = '"' then
      aIDs[i]:= copy(aIDs[i], 2, Length(aIDs[i]) - 2)
  end;
  ShowDebugMessage('GetEmails SQLres: ' + aIDs.Text);
end;

function GetPropertis(aObjSpace: TNxCustomObjectSpace; aName: string): string;
var mSQL: string;
    mResult: TStringList;
begin
  CreateInitRecord(aObjSpace);
  mSQL:= 'select UD.StringFieldValue From DefRollData A' +
         ' left join UserData UD on UD.ID = A.ID and UD.FieldCode = 2000001 and UD.CLSID = ''%s'' '+
         ' where A.CLSID = ''%s'' and A.Code = ''%s'' and A.Hidden = ''%s'' ';
  mResult:= TStringList.Create;
  try
    aObjSpace.SQLSelect(Format(mSQL, [cCLSIDInsolventIndexSettingsBussinesObject, cCLSIDInsolventIndexSettingsBussinesObject, aName, 'N']), mResult);
    if mResult.Count > 0 then
    begin
      Result:= mResult[0];
      Result:= StringReplace(Result, '{CRLF}', #13#10, [rfReplaceAll]);
      if (Result <> '') and (Result[1] = '"') and (Result[Length(Result)] = '"') then
        Result:= Copy(Result, 2, Length(Result) - 2);
    end;
  finally
    mResult.Free;
  end;
  ShowDebugMessage('GetPropertis - AName: ' + aName);
  ShowDebugMessage('GetPropertis - Result: ' + Result);
end;

function CheckFirms(aObjSpace: TNxCustomObjectSpace; aOrgIdentNumber: string): string;
var
  mSQL, mS: string;
  mIDs: TStringList;
  i: Integer;
begin
  Result:= '';
  mSQL:= 'select A.ID, ''Firma: '' || Max(A.Name) || '', IČ: '' || cast(Max(A.OrgIdentNumber) as varchar(15)) || '', Suma: '' || cast(Sum(II.localamount - II.localpaidamount - II.creditamount + II.localpaidcreditamount) as varchar(25)) || '' CZK'' as Info from Firms A ' +
         '   left join issuedinvoices II on II.Firm_ID = A.ID ' +
         '  where (A.OrgIdentNumber = ''%s'') and ' +
         '        ((II.localamount - II.localpaidamount - II.creditamount + II.localpaidcreditamount) > 0) ' +
         ' group by A.ID ';
  mSQL:= Format(mSQL, [aOrgIdentNumber]);
  mIDs:= TStringList.Create;
  try
    aObjSpace.SQLSelect(mSQL, mIDs);
    for i:= 0 to mIDs.Count - 1 do
    begin
      mS:= mIDs[i];
      mS:= Copy(mS, 13, Length(mS) - 14);  // lubi ?? co to je za prasarnu ??
      mIDs[i]:= mS;
    end;
    if mIDs.Count > 0 then
      Result:= mIDs.Text;
  finally
    mIDs.Free;
  end;
  ShowDebugMessage('CheckFirms - Result: ' + Result);
end;

//ADate je formatu 21.01.2008 10:19:40,000
function DLLDateToDateTime(const ADate:string): TDateTime;
  function iStrToInt(const AValue: string): integer;
  begin
    Result:= StrToIntDef(AValue, 0);
  end;
var
  mLineFrom, mYear, mMonth, mDay, mHour, mMinutes, mSeconds, mMSeconds: string;
begin
  try
    mLineFrom := ADate;
    mDay := Trim(NxToken(mLineFrom, '.'));
    mMonth := Trim(NxToken(mLineFrom, '.'));
    mYear:= Trim(NxToken(mLineFrom, ' '));
    mHour:= Trim(NxToken(mLineFrom, ':'));
    mMinutes:= Trim(NxToken(mLineFrom, ':'));
    mSeconds:= Trim(NxToken(mLineFrom, ','));
    mMSeconds:= Trim(mLineFrom);
    Result := EncodeDateTime(StrToInt(mYear),StrToInt(mMonth), StrToInt(mDay), StrToInt(mHour), StrToInt(mMinutes), StrToInt(mSeconds), iStrToInt(mMSeconds));
  except
    OutputDebugString('DLLDateToDateTime: ' + ExceptionMessage);
  end;
end;

procedure CopyJusticeCZIsir(const AOutputFile: String);
var
  mTempPath, mDLLPath: string;
  mFileList : TStringList;
  i: integer;
begin
  mFileList := TStringList.Create;
  try
    //seznam souborů pro kopírování do Tempu
    mDLLPath := ExtractFilePath(Application.ExeName)+cDLLDir+cJusticeDir;
    NxGetFileList(mDLLPath, mFileList, '*.*');

    mTempPath := ExtractFilePath(AOutputFile)+cJusticeDir;
    if not DirectoryExists(mTempPath) then
      if not NxCreateDir(mTempPath) then
        RaiseException('Nepodařilo se vytvořit adresář '+mTempPath);


    for i:= 0 to mFileList.Count -1 do begin
      if (mFileList[i] = '.') or (mFileList[i] = '..') then continue;
      if (Pos('data', mFileList[i]) > 0) or (Pos('logs', mFileList[i]) > 0) then continue;

      if not NxCopyFile(mDLLPath+mFileList[i],mTempPath+mFileList[i]) then
        ShowDebugMessage('Nepodařilo se zkopírovat '+mDLLPath+mFileList[i]+' do '+mTempPath+mFileList[i]);
    end;
  finally
    mFileList.Free;
  end;
end;

function ImportInsolventIndex(aObjSpace: TNxCustomObjectSpace; ASite: TSiteForm): string;
var
  mS, mLastID, mFile, mIC, mStatus: string;
  mBO: TNxCustomBusinessObject;
  mFirms, mIDs, mICs, mInfoList, mList, mHTMNoImportedList: TStringList;
  i, mRecordCount, x: Integer;
  mOK: Boolean;
  cNoveFirmy, cEmailSubject, cSMTPLogin,
  cSMTPPassword, cSMTPServer, cSendEmail: string;
  cSMTPPort, mStav: Integer;
  mLine, mID, mDatum, mTypText, mSpis, mInfoID, mInfoLine, mMessage, mTmp: string;
  mFounded, mHTMLOK: Boolean;
  mStavKonkursu, mLineTyp, mSQL, mSQLRes: string;
  mHandle: integer;
  mDLLPath: string;
  mShow: Boolean;
begin
  mShow := (ASite <> nil);
  try
    if mShow then
      ProgressInit(ASite, 'Aktualizace historie...', 100);
    try
    if mShow then
      ProgressSetPos(0, 'Vytvářím soubory.');
    cNoveFirmy:= GetPropertis(aObjSpace, 'Body');// 'Nové firmy v insolvenčním rejstříku, vůči kterým jsou evidovány pohledávky: ' + #13#10;
    cEmailSubject:= GetPropertis(aObjSpace, 'Subject');// 'Insolvenční rejstřík';
    cSMTPLogin:= GetPropertis(aObjSpace, 'SMTPLogin');// 'trialabra@abra.eu';
    cSMTPPassword:= GetPropertis(aObjSpace, 'SMTPPass');// 'trial';
    cSMTPServer:= GetPropertis(aObjSpace, 'SMTPServer');// 'mail.abra.eu';
    try
      cSMTPPort:= StrToInt(GetPropertis(aObjSpace, 'SMTPPort'));// 25;
    except
      cSMTPPort:= 25;
    end;
    cSendEmail:= GetPropertis(aObjSpace, 'SMTPSender');// 'noreply@abra.eu';
    
    Result:= '';
    mLastID := GetValueFromStorageOS('InsolventIndex.LastRecord', aObjSpace, '');
    // delete from centralstorage where path = 'InsolventIndex.LastRecord'
    //mLastID := '9164134'; // LUBI VYHODIT jen pro testy !!!!!!!!!!!!!!!!!!

    // prazdne LastID neni povoleno - musi se zacinat od nuly
    if mLastID = '' then
      mLastID := '0';
    NxCreateTempFile(mFile);
    //mFile := 'C:\DOCUME~1\LUKAS~1.BIL\LOCALS~1\Temp\d\~NXE.tmp'; // lubi vyhodit !!!!
    ShowDebugMessage('mFile: ' + mFile);
    ShowDebugMessage('DllPath: ' +ExtractFilePath(Application.ExeName)+cDLLDir+ cDllName);
    ShowDebugMessage('mLastID: ' + mLastID);
    CopyJusticeCZIsir(mFile);
    mDLLPath := ExtractFilePath(Application.ExeName)+cDLLDir+ cDllName;
    mMessage := '';
    if mShow then
      ProgressSetPos(10, 'Stahuji data.');
    mOK := (NxDllCallA(mDLLPath, 'GetNewRecords', 'F(S,S):I', [mLastID, mFile]) =1);  // LUBI vratit
    if mShow then
      ProgressSetPos(25, 'Zpracovávám data.');
    //mOK := True; // LUBI vyhodit
    if not mOK then begin
      ShowDebugMessage('Error');
      mIDs := TStringList.Create;
      try
        mIDs.LoadFromFile(mFile);
        Result := mIDs.Text;
      finally
        mIDs.Free;
      end;
      Exit;
    end;
    mFirms:= TStringList.Create;
    mHTMNoImportedList := TStringList.Create;
    try
      mIDs:= TStringList.Create;
      try
        ShowDebugMessage('OK');
        mIDs.LoadFromFile(mFile);
        mRecordCount:= mIDs.Count - 1;
        ShowDebugMessage('mRecordCount: ' + IntToStr(mRecordCount));
        ShowDebugMessage('mIDs.Text: ' + mIDs.Text);
        // LUBI
        if mIDs.Count > 0 then begin
          mMessage := mIDs[0];
          ShowDebugMessage('mMessage: ' + mMessage);
        end;
        for i := 1 to mIDs.Count - 1 do begin
          if mShow then
            ProgressSetPos(25+NxFloor((i/mRecordCount)*75), IntToStr(i) + ' z ' + inttostr(mRecordCount));
          mLine := mIDs[i];
          ShowDebugMessage('mLine: ' + mLine);
          mTmp := CdTokenEx(mLine, ';'); // prvni je jen pro razeni - odstranuji ihned
          mLineTyp := CdTokenEx(mLine, ';');
          mID := CdTokenEx(mLine, ';');
          if mLineTyp = '1' then
            mIC := CdTokenEx(mLine, ';')
          else
            mIC := '';
          mStavKonkursu := CdTokenEx(mLine, ';');
          mDatum := CdTokenEx(mLine, ';');
          mTypText := CdTokenEx(mLine, ';');
          mSpis := mLine;

          ShowDebugMessage('mLineTyp: ' + mLineTyp);
          ShowDebugMessage('mID: ' + mID);
          ShowDebugMessage('mIC: ' + mIC);
          ShowDebugMessage('mStavKonkursu: ' + mStavKonkursu);
          ShowDebugMessage('mDatum: ' + mDatum);
          ShowDebugMessage('mTypText: ' + mTypText);
          ShowDebugMessage('mSpis: ' + mSpis);
          if (mID <> '') and (mLineTyp <> '') and (mStavKonkursu <> '') then begin
            //mIC:= mIDs[i];
            //mStatus:= Copy(mIC, Pos(';', mIC) + 1, 1);
            //mIC:= Copy(mIC, 1, Pos(';', mIC) - 1);
            mICs := TStringList.Create;
            mInfoList := TStringList.Create;
            try
              mBO:= aObjSpace.CreateObject(cCLSIDInsolventIndexBussinesObject);
              try
                if (mLineTyp = '1') and (mIC <> '') then begin
                  if mSpis <> '' then begin
                    // nejdulezitejsi je parovat podle spisu, az pak podle ICO
                    mSQL := 'select I.Insolvence_ID I from InsolvenceLinks I join DefRollData D on D.ID = I.Insolvence_ID where I.DocumentNumber = ''%s'' and D.Hidden = ''N''';
                    mSQL := Format(mSQL, [mSpis]);
                    //mSQL := 'select ID from DefRollData where X_ISIRDATA like ''%s'' and Hidden = ''N''';
                    //mSQL := Format(mSQL, ['%' + mSpis + '%']);
                    mSQL := Format(mSQL, ['mSpis']);
                    ShowDebugMessage('mSQL: ' + mSQL);
                    aObjSpace.SQLSelect(mSQL, mICs);
                    ShowDebugMessage('mSQLres: ' + mICs.Text);
                  end;
                  if mICs.Count > 0 then begin
                    mLineTyp := '2'; // dohledano pres spis, provadim pouze update
                  end
                  else begin
                    mSQL := 'select ID from DefRollData where X_OrgIdentNumber = ''' + mIC + ''' and Hidden = ''N''';
                    ShowDebugMessage('mSQL: ' + mSQL);
                    aObjSpace.SQLSelect(mSQL, mICs);
                    ShowDebugMessage('mSQLres: ' + mICs.Text);
                  end;
                end;
                if (mLineTyp = '2') and (mSpis <> '') then begin
                  mSQL := 'select I.Insolvence_ID I from InsolvenceLinks I join DefRollData D on D.ID = I.Insolvence_ID where I.DocumentNumber = ''%s'' and D.Hidden = ''N''';
                  mSQL := Format(mSQL, [mSpis]);
                  //mSQL := 'select ID from DefRollData where X_ISIRDATA like ''%s'' and Hidden = ''N''';
                  //mSQL := Format(mSQL, ['%' + mSpis + '%']);
                  mSQL := Format(mSQL, ['mSpis']);
                  ShowDebugMessage('mSQL: ' + mSQL);
                  aObjSpace.SQLSelect(mSQL, mICs);
                  ShowDebugMessage('mSQLres: ' + mICs.Text);
                end;
                if not((mICs.Count = 0) and (mLineTyp = '2')) then begin
                  mHTMLOK := True;
                  if mICs.Count = 0 then begin
                    ShowDebugMessage('Provadim HTML test: ' + mIC + ' - ' + mSpis);
                    mHTMLOK := HTMLTest(mIC, mSpis);
                  end;
                  //if (mIC <> '') and (mSpis <> '') then
                  //  HTMLTest(mIC, mSpis); // lubi dva radky vyhodit jen pro testy !!!!
                  if mHTMLOK then begin
                    aObjSpace.StartTransaction(taReadCommited);
                    try
                      if mICs.Count = 0 then begin
                        mBO.New;
                        mBO.Prefill;
                        mBO.SetFieldValueAsString('X_OrgIdentNumber', mIC);
                        mBO.SetFieldValueAsString('X_ISIRDATA', mID + '; ICO: ' + mIC + '; Stav konkursu: ' + mStavKonkursu + '; Datum: ' + mDatum + '; Spis: ' + mSpis + '; TypText: ' + mTypText);
                      end
                      else begin
                        mBO.Load(mICs[0], nil);
                        if mLineTyp = '2' then
                          mIC := mBO.GetFieldValueAsString('X_OrgIdentNumber');
                        // pridani nebo aktualizace pole v memo
                        mInfoList.Text := mBO.GetFieldValueAsString('X_ISIRDATA');
                        mFounded := False;
                        for x := 0 to mInfoList.Count - 1 do begin
                          mInfoLine := mInfoList[x];
                          //ShowDebugMessage('mInfoLine: ' + mInfoLine);
                          mInfoID := CdTokenEx(mInfoLine, ';');
                          if mInfoID = mID then begin
                            ShowDebugMessage('UPDATE: aktualizuji stavajici s ID: ' + mID);
                            mInfoList.Strings[x] := mID + '; ICO: ' + mIC + '; Stav konkursu: ' + mStavKonkursu + '; Datum: ' + mDatum + '; Spis: ' + mSpis + '; TypText: ' + mTypText;
                            mFounded := True;
                            Break;
                          end;
                        end;
                        if not mFounded then begin
                          ShowDebugMessage('UPDATE: pridavam s ID: ' + mID);
                          mInfoList.Add(mID + '; ICO: ' + mIC + '; Stav konkursu: ' + mStavKonkursu + '; Datum: ' + mDatum + '; Spis: ' + mSpis + '; TypText: ' + mTypText);
                        end;
                        ShowDebugMessage('UPDATE: set X_ISIRDATA: ' + mInfoList.Text);
                        mBO.SetFieldValueAsString('X_ISIRDATA', mInfoList.Text);
                      end;
                      mStav := GetStavKonkursu(aObjSpace, mStavKonkursu);
                      {mStav := 2;
                      if (mStavKonkursu = 'NEVYRIZENA') or (mStavKonkursu = 'OBZIVLA') or (mStavKonkursu = 'ODSKRTNUTA') or
                        (mStavKonkursu = 'VYRIZENA') or (mStavKonkursu = 'MORATORIUM') or (mStavKonkursu = 'NEVYR-POST') then
                        mStav := 0;
                      if (mStavKonkursu = 'KONKURS') or (mStavKonkursu = 'K-PO ZRUŠ.') or (mStavKonkursu = 'ÚPADEK') or
                        (mStavKonkursu = 'REORGANIZ') or (mStavKonkursu = 'ODDLUŽENÍ') then
                        mStav := 1;
                      if (mStavKonkursu = 'PRAVOMOCNA') then
                        mStav := 2;
                      }
                      if mStav = 2 then
                        mStatus := 'N'
                      else
                        mStatus := 'A';
                      mBO.SetFieldValueAsString('CODE', mStatus);
                      mBO.SetFieldValueAsInteger('X_StavKonkursu', mStav);
                      mBO.SetFieldValueAsDateTime('X_ABRADate', Now);
                      mBO.SetFieldValueAsDateTime('X_ISISRLASTDATE', DLLDateToDateTime(mDatum)); // zapis casu posledni zmeny dle webu ISIR
                      if mBO.DifferentFromOriginal_1('CODE') then begin
                        ShowDebugMessage('Save start');
                        mBO.Save;
                        ShowDebugMessage('Save ok');
                        if mBO.GetFieldValueAsString('CODE') = 'A' then begin
                          mS:= CheckFirms(aObjSpace, mBO.GetFieldValueAsString('X_OrgIdentNumber'));
                          if mS <> '' then
                            mFirms.Add(mS); // kvuli odeslani mailu - odesilam jen pri zmene na ano
                        end;
                      end
                      else begin
                        ShowDebugMessage('Save start');
                        mBO.Save; // ukladam vzdy - meni se datum posledni zmeny X_ABRADate
                        ShowDebugMessage('Save ok');
                        {if mBO.GetFieldValueAsString('CODE') = 'A' then begin
                          mS:= CheckFirms(aObjSpace, mBO.GetFieldValueAsString('X_OrgIdentNumber'));
                          if mS <> '' then
                            mFirms.Add(mS);
                        end;
                        }
                      end;
                      mLastID := mID;  // zde si pamatuji mID poseldniho uspesne zpracovaneho zaznamu
                      mList := TStringList.Create;
                      try
                        mSQL := 'select Insolvence_ID from InsolvenceLinks where Insolvence_ID = ''%s'' and DocumentNumber = ''%s''';
                        mSQL := Format(mSQL, [mBO.OID, mSpis]);
                        mSQLRes := GetFirstRecordFromSQL(aObjSpace, mSQL);
                        if NxIsEmptyOID(mSQLRes) then begin
                          mSQL := 'insert into InsolvenceLinks (Insolvence_ID, DocumentNumber) VALUES (''%s'', ''%s'')';
                          mSQL := Format(mSQL, [mBO.OID, mSpis]);
                          aObjSpace.SQLExecute(mSQL);
                        end;
                      finally
                        mList.Free;
                      end;
                      aObjSpace.Commit;
                    except
                      aObjSpace.RollBack;
                      RaiseException(ExceptionMessage); // chybu nepozereme
                    end;
                  end
                  else begin
                    mHTMNoImportedList.Add(mIC + ' - ' + mSpis);
                  end;
                end
                else
                  ShowDebugMessage('Typ radku 2 a nenalezen zaznam - aktualizaci nelze provest.');
              finally
                mBO.Free;
              end;
            finally
              mICs.Free;
              mInfoList.Free;
            end;
          end;
        end;
        //mIC:= mIDs[0]; // LUBI tohle je asi blbe - to bude prvni a ne posledni !!!
        //mLastID:= Copy(mIC, 2, Length(mIC) - 2);
        {
          mLine := mIDs[i];
          ShowDebugMessage('mLine: ' + mLine);
          mID := NxToken(mLine, ';');
        }
        ShowDebugMessage('mLastID: ' + mLastID);
        if mFirms.Count > 0 then begin
          mIDs.Clear;
          mFirms.Insert(0, cNoveFirmy);
          // jine mIDs - asi ok
          GetEmails(aObjSpace, mIDs);
          if (mIDs.Count > 0) and (cSMTPServer <> '') then begin
            for i:= 0 to mIDs.Count - 1 do begin
              try
                CFxInternet.SMTPSendMailWithMoreFiles(csNone, cSMTPLogin, cSMTPPassword, cSMTPServer, cSMTPPort, cSendEmail, mIDs[i], '', '', cEmailSubject, mFirms.Text, commAsText, '');
               except
                 ShowDebugMessage('Chyba - SMTPSendMailWithMoreFiles');
               end;
            end;
          end;
        end;
      finally
        mIDs.Free;
      end;
      if mHTMNoImportedList.Count > 0 then begin
        //NxShowSimpleMessage('HTML vyhozene: ' + #13#10 + mHTMNoImportedList.Text, nil);
        ShowDebugMessage('HTML vyhozene: ' + #13#10 + mHTMNoImportedList.Text);
      end;
      if mMessage <> '' then begin
        if Pos('chybe', mMessage) > 0 then
          Result := Format(cOkRecord, [mRecordCount]) + #13#10 + mFirms.Text + #13#10 + mMessage
        else
          Result := '+OK, ' + Format(cOkRecord, [mRecordCount]) + #13#10 + mFirms.Text;
      end
      else
        Result := '+OK, ' + Format(cOkRecord, [mRecordCount]) + #13#10 + mFirms.Text;
    finally
      mFirms.Free;
      mHTMNoImportedList.Free;
    end;
    SetValueToStorageOS('InsolventIndex.LastRecord', mLastID, aObjSpace, '');
    ShowDebugMessage('Ukonceno OK: ' + Result);
    finally
      if mShow then
        ProgressDispose();
    end;
  except
    Result:= ExceptionMessage;
    ShowDebugMessage('Error: ' + ExceptionMessage);
    ShowDebugMessage('Zapisuji lastID  pri chybe: ' + mLastID);
    SetValueToStorageOS('InsolventIndex.LastRecord', mLastID, aObjSpace, '');
  end;
  if mShow then
    NxShowSimpleMessage(Result, ASite);
end;

procedure AutoImportInsolventIndex(OS: TNxCustomObjectSpace;
  var Success: Boolean; var LogInfoStr: String);
var
  mS: string;
  mCounter: Integer;
  mResult: Boolean;
begin
  LogInfoStr := '';
  Success := TestLicence(cIsNotVisual, LogInfoStr);
  if not Success then exit;
  // podporujeme opakovane spousteni
  mResult := ProceedImport(mCounter, mS, OS);
  while (not mResult) and (mCounter <= cAutoErrorRepeatValue) do begin
    ShowDebugMessage('Rekurze AUTO spusteni insolvence');
    mResult := ProceedImport(mCounter, mS, OS);
  end;
  Success := mResult;
  LogInfoStr := mS;
end;

function ProceedImport(var ACounter: integer; var AStrResult: string; AOS: TNxCustomObjectSpace): Boolean;
var
  mS: string;
begin
  Result := False;
  Inc(ACounter);
  try
    try
      mS := ImportInsolventIndex(AOS, nil);
    except
      ShowDebugMessage('Except ProceedImport');
      Result := False;
      AStrResult := mS; // oboje nemusi byt jen pro jistotu, dulezite je pozrani chyby
    end;
  finally
    ShowDebugMessage('finally ProceedImport');
    Result := Copy(mS, 1, 3) = '+OK';
    AStrResult := mS;
  end;
  ShowDebugMessage('ProceedImport - AStrResult: ' + AStrResult);
  ShowDebugMessage('ProceedImport - Result: ' + BoolToStr(Result, True));
end;

procedure ExBeforeSoftValidate_Hook(Self: TNxCustomBusinessObject);
var
  mS, mSQL, mIC: string;
begin
  try
    mSQL:= 'Select ID from DefRollData where CLSID = ''%s'' and X_OrgIdentNumber = ''%s'' and Hidden=''N'' and Code=''A'' ';
    mSQL:= Format(mSQL, [cCLSIDInsolventIndexBussinesObject, Self.GetMonikerForFieldCode(Self.GetFieldCode('Firm_ID')).BusinessObject.GetFieldValueAsString('OrgIdentNumber')]);
    mS:= GetFirstRecordFromSQL(Self.ObjectSpace, mSQL);
    if mS <> '' then
      Self.AddValidateError(Self.GetFieldCode('Firm_ID'), GetPropertis(Self.ObjectSpace, 'Warning'));
  except end;
end;

procedure XExport(ASite: TSiteForm; aFileName: string);
var
  mSQL, mLine, mSpis: string;
  mInsRe, mList: TStringList;
  mDataSet: TMemoryDataset;
  i: integer;
  mStream: TFileStream;
  mOS: TNxCustomObjectSpace;
begin
  mOS := ASite.BaseObjectSpace;
  mList := TStringList.Create;
  try
    // pro vetsi data je problem s pametovou narocnosti a TStringList predelano na praci s FileStreamem
    try
      if FileExists(aFileName) then
        mStream :=TFileStream.Create(aFileName, fmOpenWrite)
      else
        mStream := TFileStream.Create(aFileName, fmCreate);
    except
      RaiseException('Nelze otevřít soubor: '+ aFileName);
    end;
    try
      mLine := 'Data=' + cCLSIDInsolventIndexBussinesObject+cCrLf;
      NxWriteString(mStream, mLine);
      mLine := 'LastRecord=' + GetValueFromStorageOS('InsolventIndex.LastRecord', mOS, '')+cCrLf;
      NxWriteString(mStream, mLine);

      // odstraneny data X_ISIRDATA, zjistovany v cyklu
      mSQL:= 'select D.Code, D.X_OrgIdentNumber, D.X_ABRADate, D.X_StavKonkursu, D.X_ISISRLASTDATE, D.ID from DefRollData D where D.CLSID = ''%s'' and Hidden = ''N'' ';
      mSQL:= Format(mSQL, [cCLSIDInsolventIndexBussinesObject]);
      mDataSet := TMemoryDataset.Create(nil);
      try
        ShowDebugMessage('SQL: ' + mSQL);
        ProgressInit(ASite, 'Export historie...', 100);
        try
          ProgressSetPos(0, 'Zjišťuji data.');
          mOS.SQLSelect2(mSQL, mDataSet);
          if mDataSet.Active then begin
            mDataSet.First;
            while not mDataSet.Eof do begin
              ProgressSetPos(1+NxFloor((mDataSet.RecNo/mDataSet.RecordCount)*99), inttostr(mDataSet.RecNo) +' z '+inttostr(mDataSet.RecordCount));
              mLine := '';
              mSQL := 'select DocumentNumber from InsolvenceLinks where Insolvence_ID = ''%s''';
              mSQL := Format(mSQL, [mDataSet.FieldByName('ID').AsString]);
              mList.Clear;
              mOS.SQLSelect(mSQL, mList);
              for i := 0 to mList.Count - 1 do begin
                mSpis := mList[i];
                mSpis := NxTrim(mSpis, '"');
                //mSpis := NxSearchReplace(mSpis, '''', '',  [srAll]);
                if mLine <> '' then
                  mLine := mLine + '*?*' + mSpis
                else
                  mLine := mSpis;
              end;
              if mLine <> '' then
                mLine := mLine + '*?*';
              mLine := mLine + mDataSet.FieldByName('Code').AsString + '*!*' + mDataSet.FieldByName('X_OrgIdentNumber').AsString + '*!*' +
                mDataSet.FieldByName('X_ABRADate').AsString + '*!*' + IntToStr(mDataSet.FieldByName('X_StavKonkursu').AsInteger) + '*!*' +
                mDataSet.FieldByName('X_ISISRLASTDATE').AsString + '*!*';
              mList.Clear;
              mSQL := 'select D.X_ISIRDATA from DefRollData D where D.CLSID = ''%s'' and D.ID = ''%s'' and Hidden = ''N'' ';
              mSQL := Format(mSQL, [cCLSIDInsolventIndexBussinesObject, mDataSet.FieldByName('ID').AsString]);
              mList.Clear;
              mOS.SQLSelect(mSQL, mList);
              if (mList.count > 0) then
                mLine := mLine + NxTrim(mList[0], '"');
              mLine:= mLine +cCrLf+cCrLf;
              NxWriteString(mStream, mLine);
              mDataSet.Next;
            end;
          end;
        finally
          ProgressDispose();
        end;
      finally
        mDataset.Free;
      end;
    finally
      mStream.Free;
    end;
  finally
    mList.Free;
  end;
end;

procedure XImport(ASite: TSiteForm; aFileName: string);
const
  cSQL = 'insert into DefRollData (ID, CLSID, CODE, X_OrgIdentNumber, X_ABRADate, X_StavKonkursu, X_ISISRLASTDATE) '+
         'values (%s, %s, %s, %s, %s, %s, %s)';
  cSQL2 = 'update DefRollData set '+
          'CODE = %s, X_OrgIdentNumber = %s, X_ABRADate = %s, '+
          'X_StavKonkursu = %s, X_ISISRLASTDATE = %s '+
          'where ID = %s and CLSID = %s';
  cSQL30 = 'update DefRollData set '+
          'X_ISIRDATA = %s '+
          'where ID = %s and CLSID = %s';
  cSQL31 = 'update DefRollData set '+
          'X_ISIRDATA = X_ISIRDATA || %s '+
          'where ID = %s and CLSID = %s';
  //delka sql dotazu resp. stringu
  cCount = 40000;
  cCountORA = 3950;
var
  mS, mLastRecord, mLine, mID, mSQL, mSpis: string;
  mInsRej, mSpisList, mList: TStringList;
  i, x: Integer;
  mCode, mOrgIdentNumber, mABRADate, mStavKonkursu, mISISRLASTDATE, mISIRDATA: string;
  mOS: TNxCustomObjectSpace;
  mFileStream: TFileStream;
  mInsert, mInTransaction: boolean;
  mInfo: string;
  mCount: Integer;
begin
  mOS := ASite.BaseObjectSpace;
  try
    mFileStream := TFileStream.Create(aFileName, fmOpenRead);
  except
    RaiseException('Nelze otevřít soubor:' + aFileName);
  end;
  try
    mSpisList := TStringList.Create;
    try
      ReadLine(mFileStream, mS);
      if mS <> 'Data=' + cCLSIDInsolventIndexBussinesObject then Exit;
      ReadLine(mFileStream, mS);
      mLastRecord := Copy(mS, Pos('=', mS) + 1, 100);
      mS := '';
      ProgressInit(ASite, 'Import historie...', mFileStream.Size);
      try
        while (mFileStream.Position < mFileStream.Size) do begin
          ProgressSetPos(mFileStream.Position);
          if (mS = '') then
            ReadLine(mFileStream, mS);
          if (mS <> '') then begin
            // rozhazet polozky
            mLine := mS;
            if Pos('*!*', mLine) > 0 then begin
              ShowDebugMessage('mLine: ' + mLine);
              // nejdrive spisy oddelene *?*
              mSpisList.Clear;
              while Pos('*?*', mLine) > 0 do begin
                mSpis := CdTokenEx(mLine, '*?*');
                if (mSpis <> '') and (mSpisList.IndexOf(mSpis) = -1) then begin
                  mSpisList.Add(mSpis);
                end;
              end;
              mCode := CdTokenEx(mLine, '*!*');
              mOrgIdentNumber := CdTokenEx(mLine, '*!*');
              mABRADate := CdTokenEx(mLine, '*!*');
              mStavKonkursu := CdTokenEx(mLine, '*!*');
              mISISRLASTDATE := CdTokenEx(mLine, '*!*');
              mISIRDATA := mLine;
              // lubi do exportu pridat i spisy a atady je take zakladat !!!
              if (mFileStream.Position < mFileStream.Size) then begin
                ReadLine(mFileStream, mS);
                while (Pos('*!*', mS) = 0) and (mFileStream.Position < mFileStream.Size) do begin
                  if (mS <> '') then
                    mISIRDATA := mISIRDATA + cCrLf + mS;
                  ReadLine(mFileStream, mS);
                end;
              end;
              ShowDebugMessage('mCode: ' + mCode);
              ShowDebugMessage('mOrgIdentNumber: ' + mOrgIdentNumber);
              ShowDebugMessage('mABRADate: ' + mABRADate);
              ShowDebugMessage('mStavKonkursu: ' + mStavKonkursu);
              ShowDebugMessage('mISISRLASTDATE: ' + mISISRLASTDATE);
              ShowDebugMessage('mSpisList: ' + mSpisList.Text);
              ShowDebugMessage('mISIRDATA: ' + mISIRDATA);
              mSQL := 'select ID from DefRollData where CLSID = '''+ cCLSIDInsolventIndexBussinesObject +''' and X_OrgIdentNumber = ''' + mOrgIdentNumber + ''' and Hidden = ''N''';
              mID := GetFirstRecordFromSQL(mOS, mSQL);
              mInsert := NxIsEmptyOID(mID);
              if mInsert then
                mID := mOS.CreateOID(Class_DefRollBusinessObject);
              OSStartTransaction(mInTransaction, mOS);
              try
                mABRADate := CFxFloat.FloatToStr(StrToFloat(mABRADate), '.');
                mISISRLASTDATE := CFxFloat.FloatToStr(StrToFloat(mISISRLASTDATE), '.');
                if mInsert then begin
                  mSQL := Format(cSQL, [QuotedStr(mID), QuotedStr(cCLSIDInsolventIndexBussinesObject), QuotedStr(mCode), QuotedStr(mOrgIdentNumber), mABRADate, mStavKonkursu, mISISRLASTDATE])
                end else begin
                  mSQL := Format(cSQL2, [QuotedStr(mCode), QuotedStr(mOrgIdentNumber), mABRADate, mStavKonkursu, mISISRLASTDATE, QuotedStr(mID), QuotedStr(cCLSIDInsolventIndexBussinesObject)])
                end;
                mOS.SQLExecute(mSQL);
                //vlozime isirdata
                mInfo := CFxNxRuntime.NxGetDatabaseCode;
                if (mInfo = 'FB') or (mInfo = 'IB') or (mInfo = 'MSSQL') then
                 mCount := cCount
                else
                 mCount := cCountORA;
                for x := 0 to (Length(mISIRDATA) div mCount) do begin
                  mSQL := copy(mISIRDATA, x*mCount+1, mCount);
                  if (x = 0) then
                    mSQL := Format(cSQL30, [QuotedStr(mSQL), QuotedStr(mID), QuotedStr(cCLSIDInsolventIndexBussinesObject)])
                  else
                    mSQL := Format(cSQL31, [QuotedStr(mSQL), QuotedStr(mID), QuotedStr(cCLSIDInsolventIndexBussinesObject)]);
                  mOS.SQLExecute(mSQL);
                end;
                for x := 0 to mSpisList.Count - 1 do begin
                  mSQL := 'insert into InsolvenceLinks (Insolvence_ID, DocumentNumber) VALUES (''%s'', ''%s'')';
                  mSQL := Format(mSQL, [mID, mSpisList[x]]);
                  mOS.SQLExecute(mSQL);
                end;
                OSCommit(mInTransaction, mOS);
              except
                OSRollBack(mInTransaction, mOS);;
                RaiseException(ExceptionMessage);
              end;
            end;
          end;
        end;
      finally
        ProgressDispose();
      end;
      SetValueToStorageOS('InsolventIndex.LastRecord', mLastRecord, mOS, '');
      ShowDebugMessage('Import LastRecord: ' + mLastRecord);
      NxShowSimpleMessage('Import insolvenčního rejstříku byl úspěšně dokončen.', ASite);
    finally
      mSpisList.Free;
    end;
  finally
    mFileStream.Free;
  end;
end;

procedure PrepareDatabase(AObjectSpace: TNxCustomObjectSpace);
var
  mSucc, mCreate: Boolean;
  mVal, mInfo, mCheckSQL: string;
  mBO : TNxCustomBusinessObject;
  mList: TStringList;
  mSQL : string;
  mInTransaction: boolean;
begin
  //jen at to zjistim rychleji
  mVal := GetFirstRecordFromSQL(AObjectSpace,
          'SELECT tablename FROM nx$tables WHERE tablename = ''INSOLVENCELINKS''');

  if (mVal = '') then begin
    mInfo := CFxNxRuntime.NxGetDatabaseCode;
    OSStartTransaction(mInTransaction, AObjectSpace);
    try
      mSQL := '';

      //tabulka
      // Firebird
      if (mInfo = 'FB') or (mInfo = 'IB') then
      begin
        mSQL := 'CREATE TABLE InsolvenceLinks ' +
                '( ' +
                '    Insolvence_ID CHAR(10), ' +
                '    DocumentNumber VARCHAR(30) ' +
                ')';
      end
      // MSSQL
      else if mInfo = 'MSSQL' then begin
        mSQL := 'CREATE TABLE InsolvenceLinks ' +
                '( ' +
                '    Insolvence_ID CHAR(10) COLLATE Czech_CS_AS NOT NULL, ' +
                '    DocumentNumber VARCHAR(30) COLLATE Czech_CS_AS NOT NULL ' +
                ')';
      end
      // Oracle
      else begin
        mSQL := 'CREATE TABLE InsolvenceLinks ' +
                '( ' +
                '    Insolvence_ID CHAR(10), ' +
                '    DocumentNumber VARCHAR(30) ' +
                ')';
      end;
      if (mSQL <> '') then begin
        AObjectSpace.SQLExecute(mSQL);
      end;
      OSCommit(mInTransaction, AObjectSpace);
    except
      ShowDebugMessage('Preparedatabase - tabulka neni vytvorena');
      OSRollBack(mInTransaction, AObjectSpace);;
    end;

    OSStartTransaction(mInTransaction, AObjectSpace);
    try
      //trigger
      // Firebird
      if (mInfo = 'FB') or (mInfo = 'IB') then
      begin
        mSQL := 'CREATE trigger defrolldata_insolvence for defrolldata ' +
                'active after delete position 0 ' +
                'AS ' +
                'begin ' +
                '  delete from InsolvenceLinks where Insolvence_ID = Old.ID ; ' +
                'end';
      end
      // MSSQL
      else if mInfo = 'MSSQL' then begin
        mSQL := 'CREATE TRIGGER defrolldata_insolvence ON defrolldata' + #13#10 +
                '  AFTER DELETE ' + #13#10 +
                'AS' + #13#10 +
                'BEGIN' + #13#10 +
                '  DECLARE @i INT, @d INT, @mCount INT;' + #13#10 +
                '  DECLARE @mID CHAR(10);' + #13#10 +
                '  SELECT @i = COUNT(*) FROM inserted;' + #13#10 +
                '  SELECT @d = COUNT(*) FROM deleted;' + #13#10 +
                '  SET @mID = '''';' + #13#10 +
                '  /*delete*/' + #13#10 +
                '  IF ((@d > 0) and (@i = 0))' + #13#10 +
                '    SELECT @mID = ID FROM  deleted;' + #13#10 +
                '  /*smazeme*/' + #13#10 +
                '  IF (@mID <> '''')' + #13#10 +
                '  BEGIN' + #13#10 +
                '    DELETE FROM InsolvenceLinks' + #13#10 +
                '    WHERE Insolvence_ID = @mID;' + #13#10 +
                '  END;' + #13#10 +
                'END';
      end
      // Oracle
      else begin
        mSQL := 'create TRIGGER defrolldata_insolvence ' +
                'AFTER DELETE ON defrolldata ' +
                'FOR EACH ROW ' +
                'begin ' +
                '  Delete from InsolvenceLinks where  Insolvence_ID = :old.ID; ' +
                'END;';
      end;
      if (mSQL <> '') then begin
        AObjectSpace.SQLExecute(mSQL);
      end;
      OSCommit(mInTransaction, AObjectSpace);
    except
      ShowDebugMessage('Preparedatabase - trigger neni vytvoren');
      OSRollBack(mInTransaction, AObjectSpace);;
    end;

    OSStartTransaction(mInTransaction, AObjectSpace);
    try
      //index
      // Firebird
      if (mInfo = 'FB') or (mInfo = 'IB') then
      begin
        mSQL := 'CREATE INDEX InsolvenceLinks_DocNumber ON InsolvenceLinks(DocumentNumber)';
      end
      // MSSQL
      else if mInfo = 'MSSQL' then begin
        mSQL := 'CREATE INDEX InsolvenceLinks_DocNumber ON InsolvenceLinks(DocumentNumber)';
      end
      // Oracle
      else begin
        mSQL := 'CREATE INDEX InsolvenceLinks_DocNumber ON InsolvenceLinks(DocumentNumber)';
      end;
      if (mSQL <> '') then begin
        AObjectSpace.SQLExecute(mSQL);
      end;
      OSCommit(mInTransaction, AObjectSpace);
    except
      ShowDebugMessage('Preparedatabase - index neni vytvoren');
      OSRollBack(mInTransaction, AObjectSpace);;
    end;
  end else
    ShowDebugMessage('Preparedatabase - tabulka je vytvorena');
end;

function GetStavKonkursu(AOS: TNxCustomObjectSpace; ATextKonkursu: string): integer;
var
  mSQL, mSQLRes: string;
begin
  ShowDebugMessage('GetStavKonkursu - ATextKonkursu: ' + ATextKonkursu);
  Result := 2;
  mSQL := 'select U.StringFieldValue from DefRollData D ' +
          'left join UserData U on U.CLSID = ''%s'' and U.ID = D.ID and U.FieldCode = 2000001 ' +
          'where D.Code = ''%s'' and D.CLSID = ''%s''';
  mSQL := Format(mSQL, [cCLSIDInsolventIndexSettingsBussinesObject, ATextKonkursu, cCLSIDInsolventIndexSettingsBussinesObject]);
  mSQLRes := GetFirstRecordFromSQL(AOS, mSQL);
  // odstranit uvozovky
  mSQLRes := NxTrim(mSQLRes, '"');
  ShowDebugMessage('mSQLRes: ' + mSQLRes);
  if mSQLRes = cStav0 then begin
    Result := 0;
  end;
  if mSQLRes = cStav1 then begin
    Result := 1;
  end;
  if mSQLRes = cStav2 then begin
    Result := 2;
  end;
  ShowDebugMessage('GetStavKonkursu - Result: ' + IntToStr(Result));
end;

function HTMLTest(AICO, ASpis: string): Boolean;
var
  mDLLPath : string;
begin
  ShowDebugMessage('HTMLTest start');
  mDLLPath := ExtractFilePath(Application.ExeName)+cDLLDir+ cDllName;
  Result := (NxDllCallA(mDLLPath, 'DLLHTMLTest', 'F(S,S):I', [AICO, ASpis])=1);
  ShowDebugMessage('HTMLTest result skript: ' + BoolToStr(Result, True));
end;

{typy navratove hodnoty fce
  cStav0 = 'Běžící ins.řízení';
  cStav1 = 'Prohlášení úpadku';
  cStav2 = 'Ukončené ins.řízení';
}
function GetLastStavFromHTML(AICO: string; var AInfo: string): Integer;
var
  mURL: string;
  AStream: TMemoryStream;
  mRichEdit: TRichEdit;
  i, x: integer;
  mLine, mPrefix, mBody, mSuffix: string;
  mTestStr, mSpis, mStav: string;
  mIndex1, mIndex2, mIndex3, mIndex4: integer;
  mForm: TForm;
  mResList: TStringList;
  mFounded: Boolean;
begin
  ShowDebugMessage('GetLastStavFromHTML - start');
  {
  format:
  INS
  cislo
  znak /
  rok
  INS 887 / 2008
  }
  AInfo := '';
  Result := 0;
  if AICO = '' then begin
    ShowDebugMessage('GetLastStavFromHTML - prazdne ICO exit');
    Exit;
  end;
  {HTTPSend fce HTTPGetText}
  mForm := TForm.Create(nil);
  try
    mRichEdit := TRichEdit.Create(nil);
    AStream := TMemoryStream.Create;
    try
      mRichEdit.Parent := mForm;
      mRichEdit.WordWrap := False;
      mResList := TStringList.Create;
      try
        mURL := 'https://isir.justice.cz/isir/ueu/vysledek_lustrace.do;jsessionid=0c3c3fa1292eb875143e8e8e6408?nazev_osoby=&vyhledat_pouze_podle_zacatku=on&podpora_vyhledat_pouze_podle_zacatku=true&jmeno_osoby=&ic=' + AICO;
        mURL := mURL + '&datum_narozeni=&rc=&mesto=&cislo_senatu=&bc_vec=&rocnik=&id_osoby_puvodce=&druh_stav_konkursu=&datum_stav_od=&datum_stav_do=&aktualnost=AKTUALNI_I_UKONCENA&druh_kod_udalost=&datum_akce_od=&datum_akce_do=';
        mURL := mURL + '&nazev_osoby_f=&rowsAtOnce=50&spis_znacky_datum=&spis_znacky_obdobi=14DNI';
        if CFxInternet.HttpGetBinary(mURL, '', AStream) then begin
          ShowDebugMessage('Load web ok');
          AStream.Position := 0;
          mRichEdit.Lines.LoadFromStream(AStream);
          //ShowDebugMessage(mRichEdit.Lines.Text);
          for i := 0 to mRichEdit.Lines.Count - 1 do begin
            mSpis := '';
            mPrefix := '';
            mBody := '';
            mSuffix := '';
            mLine := mRichEdit.Lines.Strings[i];
            mIndex1 := Pos('INS', mLine); // musi byt case sensitive
            if mIndex1 > 0 then begin
              if (i + 3) <= (mRichEdit.Lines.Count - 1) then begin
                //ShowDebugMessage('Founded INS: ' + mLine);
                mPrefix := 'INS';
                mLine := mRichEdit.Lines.Strings[i+1];
                mLine := Trim(mLine);
                //ShowDebugMessage('mLine po trim: ' + mLine);
                if NxIsNumeric(mLine) then
                  mBody := mLine;
                mLine := mRichEdit.Lines.Strings[i+2];
                mIndex3 := Pos('/', mLine);
                if mIndex3 > 0 then begin
                  mLine := mRichEdit.Lines.Strings[i+3];
                  mLine := Trim(mLine);
                  if NxIsNumeric(mLine) then begin
                    if Length(mLine) = 4 then begin
                      mSuffix := mLine;
                    end;
                  end;
                end;
                ShowDebugMessage('mPrefix: ' + mPrefix);
                ShowDebugMessage('mBody: ' + mBody);
                ShowDebugMessage('mSuffix: ' + mSuffix);
                if (mPrefix <> '') and (mBody <> '') and (mSuffix <> '')then begin
                  mSpis := mPrefix + ' ' + mBody + '/' + mSuffix;
                  // dohledani prvniho vyskytu "Stav řízení:"
                  x := i+4;
                  while x <= mRichEdit.Lines.Count - 1 do begin
                    mLine := mRichEdit.Lines.Strings[x];
                    mIndex2 := Pos(AnsiUpperCase('Stav řízení:'), AnsiUpperCase(mLine));
                    //ShowDebugMessage('Stav řízení: mLine: ' + mLine);
                    if mIndex2 > 0 then begin
                      if (x+4) <= (mRichEdit.Lines.Count - 1) then begin
                        mLine :=  mRichEdit.Lines.Strings[x+4];
                        mStav := Trim(mLine);
                        mResList.Add(mSpis + ';' + mStav);
                        Break;
                      end
                      else
                        Break;
                    end;
                    Inc(x);
                  end;
                end;
              end;
            end;
          end;
        end
        else begin
          RaiseException('Nepodařil se dotaz na web ISIR - restartujte IS ABRA a akci prosím zopakujte.');
        end;
        ShowDebugMessage(mResList.Text);
        // parsovani vysledku
        // byl nalezen nejaky spis
        if mResList.Count > 0 then begin
          // alespon jednou se vyskytuje jiny stav nez ukoncujici stav? Tj. jiny nez PRAVOMOCNA nebo ODSKRTNUTA pak res bud 0 nebo 1 jinak 2
          mFounded := False;
          for i := mResList.Count - 1 downto 0 do begin // obracene na konci jsou zrejme nejnovejsi udaje
            mLine := mResList.Strings[i];
            mStav := NxTokenR(mLine, ';');
            if (Pos(AnsiUpperCase('Pravomocná'), AnsiUpperCase(mStav)) = 0) then begin
              if (Pos(AnsiUpperCase('Odškrtnutá'), AnsiUpperCase(mStav)) = 0) then begin
                mFounded := True;
                // typicky result
                Result := 1;
                AInfo := 'KONKURS';
                if Pos(AnsiUpperCase('Před rozhodnutím o úpadku'), AnsiUpperCase(mStav)) > 0 then begin
                  Result := 0;
                  AInfo := 'NEVYRIZENA';
                end;
                if Pos(AnsiUpperCase('Obživlá'), AnsiUpperCase(mStav)) > 0 then begin
                  Result := 0;
                  AInfo := 'OBZIVLA';
                end;
                if Pos(AnsiUpperCase('Vyřízená'), AnsiUpperCase(mStav)) > 0 then begin
                  Result := 0;
                  AInfo := 'VYRIZENA';
                end;
                if Pos(AnsiUpperCase('konkurs'), AnsiUpperCase(mStav)) > 0 then begin
                  Result := 1;
                  AInfo := 'KONKURS';
                end;
                if Pos(AnsiUpperCase('úpadku'), AnsiUpperCase(mStav)) > 0 then begin
                  Result := 1;
                  AInfo := 'ÚPADEK';
                end;
                if Pos(AnsiUpperCase('reorganizace'), AnsiUpperCase(mStav)) > 0 then begin
                  Result := 1;
                  AInfo := 'REORGANIZ';
                end;
                if Pos(AnsiUpperCase('oddlužení'), AnsiUpperCase(mStav)) > 0 then begin
                  Result := 1;
                  AInfo := 'ODDLUŽENÍ';
                end;
                if Pos(AnsiUpperCase('moratorium'), AnsiUpperCase(mStav)) > 0 then begin
                  Result := 0;
                  AInfo := 'MORATORIUM';
                end;
                if Pos(AnsiUpperCase('Postoupená'), AnsiUpperCase(mStav)) > 0 then begin
                  Result := 0;
                  AInfo := 'NEVYR-POST';
                end;
                // firma je v insolvenci
                Break;
              end;
            end;
          end;
          if not mFounded then begin
            // firma neni v insolvenci
            Result := 2;
            for i := mResList.Count - 1 downto 0 do begin // obracene na konci jsou zrejme nejnovejsi udaje
              mLine := mResList.Strings[i];
              mStav := NxTokenR(mLine, ';');
              if (Pos(AnsiUpperCase('Pravomocná'), AnsiUpperCase(mStav)) > 0) or (Pos(AnsiUpperCase('Odškrtnutá'), AnsiUpperCase(mStav)) > 0) then begin
                if Pos(AnsiUpperCase('Pravomocná'), AnsiUpperCase(mStav)) > 0 then
                  AInfo := 'PRAVOMOCNA';
                if Pos(AnsiUpperCase('Odškrtnutá'), AnsiUpperCase(mStav)) > 0 then
                  AInfo := 'ODSKRTNUTA';
                Break;
              end;
            end;
          end;
        end;

  {
  cStav0 = 'Běžící ins.řízení';
  cStav1 = 'Prohlášení úpadku';
  cStav2 = 'Ukončené ins.řízení';

  if (mCode = 'NEVYRIZENA') or
  (mCode = 'OBZIVLA') or
  (mCode = 'VYRIZENA') or
  (mCode = 'MORATORIUM') or
  (mCode = 'NEVYR-POST') or
  (mCode = 'KONKURS') or
  (mCode = 'K-PO ZRUŠ.') or
  (mCode = 'ÚPADEK') or
  (mCode = 'REORGANIZ') or
  (mCode = 'ODDLUŽENÍ') or
  (mCode = 'PRAVOMOCNA') or
  (mCode = 'ODSKRTNUTA') then begin

Stav řízení:
Pravomocná věc
Odškrtnutá - skončená věc
Prohlášený konkurs
V úpadku

Před rozhodnutím o úpadku
Obživlá věc
Vyřízená věc
//Zrušeno vrchním soudem  oboje ignore
//Mylný zápis do rejstříku
Prohlášený konkurs po zrušení VS
Povolena reorganizace
Povoleno oddlužení
Povoleno moratorium
Postoupená věc
  }

      finally
        mResList.Free;
      end;
    finally
      AStream.Free;
      mRichEdit.Free;
    end;
  finally
    mForm.Free;
  end;
  ShowDebugMessage('WEB result: ' + IntToStr(Result));
  ShowDebugMessage('AInfo: ' + AInfo);
end;

procedure ActualizeItemFromWeb(AOS: TNxCustomObjectSpace; AItemOID: string);
var
  mFile, mSQL, mInfoLine, mStavFinal, mStav: string;
  mSite: TSiteForm;
  mOS: TNxCustomObjectSpace;
  mList, mInfoList: TStringList;
  i, mIntStav: integer;
  mBO: TNxCustomBusinessObject;
  mNewLine, mICO, mValue1, mValue2, mValue3, mValue4, mValue5, mValue6: string;
begin
  ShowDebugMessage('ActualizeItemFromWeb - start');
  mInfoList := TStringList.Create;
  try
    mBO := AOS.CreateObject(cCLSIDInsolventIndexBussinesObject);
    try
      ShowDebugMessage('Load OID: ' + AItemOID);
      mBO.Load(AItemOID, nil);
      mICO := mBO.GetFieldValueAsString('X_OrgIdentNumber');
      ShowDebugMessage('mICO: ' + mICO);
      mIntStav := GetLastStavFromHTML(mICO, mStav);
      if mIntStav <> mBO.GetFieldValueAsInteger('X_StavKonkursu') then begin
        ShowDebugMessage('Ruzne stavy');
        mInfoList.Text := mBO.GetFieldValueAsString('X_ISIRDATA');
        // stav nastavuji podle posledniho radku
        mInfoLine := mInfoList[mInfoList.Count - 1];
        ShowDebugMessage('mInfoLine: ' + mInfoLine);
        // zjisteni stavu konkursu
        mValue1 := NxTokenR(mInfoLine, ';');
        mValue2 := NxTokenR(mInfoLine, ';');
        mValue3 := NxTokenR(mInfoLine, ';');
        mValue4 := NxTokenR(mInfoLine, ';'); // stav
        mValue5 := NxToken(mValue4, ':'); // stav
        mValue6 := NxToken(mValue1, ':');
        mNewLine := mInfoLine + ';' + mValue5 + ': ' + mStav + ';' {+ mValue4 + ';'} + mValue3 + ';' + mValue2 + ';' + mValue6 + ': ' + 'Servisní aktualizace stavu dle webu ISIR';
        ShowDebugMessage('mNewLine: ' + mNewLine);
        mInfoList.Add(mNewLine);
        mBO.SetFieldValueAsString('X_ISIRDATA', mInfoList.Text);
        //mIntStav := GetStavKonkursu(mOS, mStav); // lubi asi todo i nahoru na stav po webu
        mBO.SetFieldValueAsInteger('X_StavKonkursu', mIntStav);
        if mIntStav = 2 then
          mBO.SetFieldValueAsString('Code', 'N')
        else
          mBO.SetFieldValueAsString('Code', 'A');
        mBO.Save;
        ShowDebugMessage('Save ok');
      end;
    finally
      mBO.Free;
    end;
  finally
    mInfoList.Free;
  end;
  ShowDebugMessage('ActualizeItemFromWeb - end');
end;

//vrati jednu radku ze streamu
function ReadLine( var Stream: TStream; var Line: string): boolean;
var
  ch: Char;
  mPtr: Pointer;
  mBytes: TBytes;
  i: integer;
begin
  result := False;
  SetLength(mBytes, 0);
  Line := '';
  ch := #0;
  mPtr := @ch;
  i:= Length(mBytes);
  SetLength(mBytes, i+1);
  mBytes[i] := Ord(' ');
  while (Stream.Read( mPtr, 1) = 1) do
  begin
    if (ch = #13) then break;
    result := True;
    i:= Length(mBytes);
    SetLength(mBytes, i+1);
    mBytes[i] := Ord(ch);
  end;
  Line := TEncoding.Unicode.GetString(TEncoding.Convert(mBytes, Encoding_cp1250, Encoding_cpUTF_16));
  Line := TrimLeft(Line);
  if ch = #13 then
  begin
    result := True;
    if (Stream.Read( mPtr, 1) = 1) and (ch <> #10) then
      Stream.Seek(-1, soCurrent);
  end
end;

begin
end.