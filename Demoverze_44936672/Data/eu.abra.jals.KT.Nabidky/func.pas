uses
  'eu.abra.jals.KT.Nabidky.Const';

//******************************************************************************
function GetCurrentExchangeRate(AOS: TNxCustomObjectSpace; ACurrencyID: string; ADate: TDateTime): Extended;
var
  mSQL: string;
  mResult: TStringList;
begin
  Result := 0;
  if Assigned(AOS) and not NxIsEmptyOID(ACurrencyID) then
  begin
    mSQL := Format('Select first 1 er2.currrate/er2.refcurrrate from ExchangeRates2 er2 where er2.parent_id in (select er.id from exchangerates er where er.Currency_ID = ''%s'') and er2.date$date <= %d order by er2.date$date desc', [ACurrencyID, trunc(ADate)]);
    Log('GetCurrentExchangeRate', 'mSQL=' + mSQL);
    mResult := TStringList.Create;
    try
      AOS.SQLSelect(mSQL, mResult);
      if mResult.Count > 0 then
      begin
        Log('GetCurrentExchangeRate', StringReplace(mResult[0], '"','', [rfReplaceAll, rfIgnoreCase]));
        Result := NxStrToFloat(StringReplace(mResult[0], '"','', [rfReplaceAll, rfIgnoreCase]), ',');
      end;
    finally
      mResult.Free;
    end;
  end;
end;

//******************************************************************************
//Zjistí roli, která má stejnou zkratku jako je zkratka uživatele.
function GetUserRole(AOS:TNxCustomObjectSpace ): string;
var
  mRollID:string;
  mActualUser_ID: string;
  mSQL: string;
begin
{dopřidat správně begin}
  Result := '';
  mActualUser_ID:= NxGetActualUserID(AOS);
  mSQL:= 'select sr.Id from SecurityUsers su join SecurityRoles sr on sr.ShortName=su.ShortName where su.Id='''+mActualUser_ID+'''';
  mRollID:=SQLSingleSelect(AOS,mSQL,nil);
  if not NxIsEmptyOID(mRollID) then
  begin
    Result:= mRollID;
  end
  else
  begin
    Log('GetUserRole','Chybí role, která by měla stejnou zkratku jako zkratka uživatele.');//hlška,že roli nenašel
  end;
end;


//******************************************************************************
function CheckUserRightForSetupOfferState(AOS: TNxCustomObjectSpace; AOfferStateID: string): Boolean;
var
  mUserRoleID: string;
  mOfferStates: TStringList;
  mSQL: string;
  mActualUser_ID: string;
  mDemandOfferState: string;
  mOffersStatesID: string;
begin
  Result:= False;
  mUserRoleID:= GetUserRole(AOS);
  mActualUser_ID:= NxGetActualUserID (AOS);
  mDemandOfferState:= AOfferStateID;
  //Dotaz pro stavy, které má na sobě role, přiřazena aktuálnímu uživateli.
  mSQL:='select sr.X_StavyNabidek from SecurityRoles sr where sr.Id='''+mUserRoleID+'''';
  try
    mOfferStates:= TStringList.Create;
    mOffersStatesID:= SQLSingleSelect(AOS, mSQL, nil); // Zjišťuji stavy NV, které může role přiřazovat.
    mOfferStates.delimiter:=';';
    mOfferStates.delimitedtext:=mOffersStatesID;
    Log('CheckUserRightForSetupOfferState', '-Zahájeno.'+NxIntegerToLanguage(mOfferStates.IndexOf(mDemandOfferState),3));
    if (mOfferStates.IndexOf(mDemandOfferState)>-1) then begin //použít f-ci Index of, zjistím, zda mOfferStates, obsahuje hledaný stav=ten, který chci  jako uživatel nastavit.
      Result := TRUE;
    end
    else
    begin
      Log('CheckUserRightForSetupOfferState:' ,'Uživatel není oprávněn provést změnu na tento stav nabídky.');
    end;
  finally
    mOfferStates.Free;
  end;
end;


//******************************************************************************
procedure CopyFromBusinessObject(AFrom, ATo: TNxCustomBusinessObject; AFieldsNotToCopy: string);
var
  mNonCopyableFields, mFields: TStringList;
  i: integer;
begin
  if Assigned(AFrom) and Assigned(ATo) then
  begin
    mNonCopyableFields := TStringList.Create;
    try
      mFields := TStringList.Create;
      try
        AFrom.GetFieldNames(mFields);
        mNonCopyableFields.CommaText := AFieldsNotToCopy;
        for i := 0 to mFields.Count - 1 do
        try
          Log('CopyFromBusinessObject', IntToStr(mNonCopyableFields.IndexOf(mFields.Strings[i])));
          if ((mNonCopyableFields.Count > 0) and (mNonCopyableFields.IndexOf(mFields.Strings[i]) >= 0)) or (mNonCopyableFields.Count = 0) then
          begin
            ATo.CopyFieldValueFrom(AFrom, mFields.Strings[i]);
            Log('CopyFromBusinessObject', ' kopírujeme ' + mFields.Strings[i]) ;
          end;
        except
          Log('CopyFromBusinessObject', ExceptionMessage);
        end;
      finally
        mFields.Free;
      end;
      Log('CopyFromBusinessObject', 'Kopírujeme X položky');
      ATo.CopyUserFieldValuesFrom(AFrom, true, true);
    finally
      mNonCopyableFields.Free;
    end;
  end;
end;


//******************************************************************************
procedure Log(AFuncName, AText: string);
begin
  if cDebug then
  begin
    OutputDebugString(Format('%s: %s', [AFuncName, AText]));
  end;
end;

//******************************************************************************
function GetChildComponent(AControl: TWinControl; AControlName: string): TComponent;
const
  cFuncName = 'GetComponent';
begin
  Result := nil;
  if Assigned(AControl) then
  begin
    Result := AControl.FindChildControl(AControlName);
  end
  else
  begin
    Log(cFuncName, 'Nebyl předán platný parametr AComponent');
  end;
end;

//******************************************************************************
function SQLSingleSelect(AOS: TNxCustomObjectSpace; ASQL: string; ALog: TStringList): string;
var
  mIDs: TStringList;
begin
  Result := '';

  if Assigned(AOS) and not NxIsBlank(ASQL) then
  begin
    mIDs := TStringList.Create;
    try
      SQLMultiSelect(AOS, ASQL, mIDs, ALog);
      if mIDs.Count > 0 then
        Result := NxSearchReplace(mIDs.Strings[0], '"', '', [srAll]);
    finally
      mIDs.Free;
    end;
  end;
end;

//******************************************************************************
procedure SQLMultiSelect(AOS: TNxCustomObjectSpace; ASQL: string; AIDs, ALog: TStringList);
const
  cFuncName = 'SQLMultiSelect';
begin
  try
    if Assigned(AIDs) and Assigned(AOS) and  not NxIsBlank(ASQL) then
    begin
      Log(cFuncName, 'query: ' + ASQL);
      AOS.SQLSelect(ASQL, AIDs);
      Log(cFuncName, 'result: ' + AIDs.CommaText);
    end;
  except
    Log(cFuncName, 'Nepodařilo se načíst data z databáze.' + #13#10 + #13#10 + ExceptionMessage);
  end;
end;

//******************************************************************************
procedure AddField(ADataset: TDataSet; AName: string; AFieldType: TFieldType; ASize, AFieldCode: integer; AReadOnly: boolean);
var
  mFieldDef: TFieldDef;
  mField: TField;
begin
  if Assigned(ADataset) then
  begin
    mFieldDef := TFieldDef.Create(ADataSet.FieldDefs, AName, AFieldType, ASize, False, AFieldCode);
    mField := mFieldDef.CreateField(ADataSet, nil, AName, False);
    mField.ReadOnly := AReadOnly;
    mField.FieldName := AName;
    mField.FieldKind := fkData;
  end;
end;

//******************************************************************************
procedure FillStringListFromEnumField(AOS: TNxCustomObjectSpace; AList: TStrings; AFieldName, AParentID: string);
var
  mEnum: string;
  mComboValues: array of string;
  mEnumList: TStringList;
begin
  mEnum := SQLSingleSelect(AOS, Format('select enumeration from userfielddefs2 where fieldname like ''%s'' and parent_id = ''%s''', [AFieldName, AParentID]), nil);
  if not NxIsBlank(mEnum) then
  begin
    AList.Text := mEnum;
  end;
end;

//******************************************************************************
procedure SetupCombobox(ACombobox: TComboBox; AFieldName, AParentID: string);
var
  mComboValues: array of string;
  mEnumList: TStringList;
  i: integer;
begin
  mEnumList := TStringList.Create;
  try
    FillStringListFromEnumField(ACombobox.DynSite.BaseObjectSpace, mEnumList, AFieldName, AParentID);
    SetLength(mComboValues, mEnumList.Count);
    for i := 0 to mEnumList.Count - 1 do
    begin
      mComboValues[i] := mEnumList[i];
    end;
    NxFillComboBox(ACombobox, mComboValues);
    Log('SetupCombobox', AFieldName + ' ' + ACombobox.Values.CommaText);
  finally
    mEnumList.Free;
  end;
end;

//******************************************************************************
procedure CreateRelation(AOS: TNxCustomObjectSpace; ARelDef: integer; ALefSideID, ARightSideID: string);
var
  mRelation: TNxCustomBusinessObject;
begin
  if Assigned(AOS) and not NxIsEmptyOID(ALefSideID) and not NxIsEmptyOID(ARightSideID) then
  begin
    mRelation := AOS.CreateObject(Class_Relation);
    try
      mRelation.New;
      mRelation.Prefill;
      mRelation.SetFieldValueAsInteger('REL_DEF', ARelDef);
      mRelation.SetFieldValueAsString('LEFTSIDE_ID', ALefSideID);
      mRelation.SetFieldValueAsString('RIGHTSIDE_ID', ARightSideID);
      mRelation.Save;
    finally
      mRelation.Free;
    end;
  end;
end;

//******************************************************************************
procedure SendOffer(AOffer: TNxCustomBusinessObject);
var
  mRecipient, mSubject, mFileName, mBodyFileName, mPath, mPrintID, mDynSQL, mTranslation: string;
  mContext: TNxContext;
  mIDs, mBody: TStringList;
begin
  if Assigned(AOffer) then
  begin
    //vybrat tiskovou sestavu
    GetRollReportID('1TBWV0KN4OVOB4RBWMJBHTVPJC', mPrintID);
    mDynSQL := SQLSingleSelect(aOffer.ObjectSpace, 'select r.datasource from reports r where R.ID ='''+mPrintID+'''', nil);
    mTranslation := SQLSingleSelect(aOffer.ObjectSpace, 'select X_Popis from defrolldata where clsid = ''JO5JUH3Y3YZ4Z5V1J214HDX3HS'' and  X_TiskovaSestava_ID ='''+mPrintID+''' and hidden = ''N'' and X_PreferovanyJazykProTisk = ' + AOffer.GetFieldValueAsString('Firm_ID.X_PreferovanyJazykProTisk'), nil);
    //vytisknout
    mPath := NxGetTempDir;
    mFileName := mTranslation + ' ' + CorrectFileName(AOffer)+ '.PDF';

    mContext := NxCreateContext(AOffer.ObjectSpace);
    mIDs := TStringList.Create;
    try
      mIDs.Add(AOffer.OID);
      CFxReportManager.PrintByIDs(mContext, mIDs, mDynSQL, mPrintID, rtoFile, pekPDF, mPath, mFileName);
    finally
      mIDs.Free;
    end;

    //odeslat do emailoveho klienta
    mRecipient := AOffer.GetFieldValueAsString('FirmOffice_ID.Address_ID.Email');
    if NxIsBlank(mRecipient) then mRecipient := AOffer.GetFieldValueAsString('Firm_ID.ResidenceAddress_ID.Email');
    if not nxIsBlank(mRecipient) then mRecipient := mRecipient + ',';
    mRecipient := mRecipient + NxEvalObjectExprAsString(AOffer, 'NxGetUserAddress(''EMail'')');

    if NxIsBlank(mRecipient) then
    begin
      NxShowSimpleMessage('Není vyplněna e-mailová adresa ani na provozovně ani na sídle firmy vybrané na nabídce ani pro aktuálně přihlášeného uživatele. Není možné nabídku odeslat. Před odesláním je potřeba doplnit e-mailovou adresu na do adresy provozovny nebo sídla firmy. Je také možné nechat zaslat email na vlastní email přihlášeného uživatele.', nil);
    end
    else
    begin
      mSubject := AOffer.DisplayName;
      mBody := TStringList.Create;
      try
        mBody.Text := Format(cMailBody, [AOffer.DisplayName]);
        mBody.Add(NxEvalObjectExprAsString(AOffer, 'NxGetUserName'));
        mBody.Add(NxEvalObjectExprAsString(AOffer, 'NxGetUserAddress(''PhoneNumber1'')'));
        Randomize;
        mBodyFileName := mPath + Format('Body%d.txt', [RandomRange(1,100)]);
        mBody.SaveToFile(mBodyFileName);
      finally
        mBody.Free;
      end;

      mFileName := mPath + mFileName;

      SendEmailViaEmailClient(mRecipient, cMailCopy, mSubject, mBodyFileName, mFileName, mPath);
    end;
  end;
end;

//******************************************************************************
function CorrectFileName(AOffer: TNxCustomBusinessObject): string;
var
  mDocQueue, mOrdNumber, mPeriod: string;
begin
  if Assigned(AOffer) then
  begin
    mDocQueue := AOffer.GetFieldValueAsString('DocQueue_ID.Code');
    mOrdNumber := AOffer.GetFieldValueAsString('OrdNumber');
    mPeriod := AOffer.GetFieldValueAsString('Period_ID.Code');

    Result := mDocQueue  + '_' + mPeriod + '_' + NxPadL(mOrdNumber, 4, '0');
  end;
end;

//******************************************************************************
procedure SendEmailViaEmailClient(ARecipient, ACopy, ASubject, ABodyFileName, AFileName, APath: string);
const
  cFuncName= 'SendEmailViaEmailClient';
var
  s: string;
begin
  if NxIsBlank(AFileName) or NxIsBlank(APath) then
  begin
    s := '-t "'+ ARecipient+'" -c "'+ ACopy+'" -s "'+ASubject+'" -b @"'+ABodyFileName+'" -d';
  end
  else
  begin
    s := '-t "'+ ARecipient+'" -c "'+ ACopy+'" -s "'+ASubject+'" -b @"'+ABodyFileName+'" -d -a "'+AFileName+'"';
  end;
  ShellAPI.Execute('open', 'mapimail.exe', s, APath);
  Log('SendEmailViaEmailClient', s);
end;

//******************************************************************************
function GetRollReportID(const aProgPoint:string;var aID: string;const aCanChangeDetailed:Boolean= true;const aMask:integer=0):boolean;
var
  mOLE: Variant;
  mRoll: Variant;
begin
  Result := false;
  mOLE := GetAbraOLEApplication;
  mRoll := mOLE.GetRoll(Roll_Reports, aMask);// číselník reportů
   mRoll.Params.Add('_PROGPOINT=' + aProgPoint); // pro agendu reportu musi byt
  aID := mRoll.SelectDialog2(aCanChangeDetailed,aID);
  Result := aID<>'';
end;

//******************************************************************************
function SafeGetFieldValueAsString(AObject: TNxCustomBusinessObject; AFieldName: string; ADefault: string = '') : string;
begin
  if Assigned(AObject) then
  begin
    Result := AObject.GetFieldValueAsString(AFieldName);
  end
  else
  begin
    Result := ADefault;
  end;
end;

//******************************************************************************
function SafeGetFieldValueAsInteger(AObject: TNxCustomBusinessObject; AFieldName: string; ADefault: Integer = 0): integer;
begin
  if Assigned(AObject) then
  begin
    Result := AObject.GetFieldValueAsInteger(AFieldName);
  end
  else
  begin
    Result := ADefault;
  end;
end;

//******************************************************************************
function SafeGetFieldValueAsBoolean(AObject: TNxCustomBusinessObject; AFieldName: string; ADefault: Boolean = False): boolean;
begin
  if Assigned(AObject) then
  begin
    Result := AObject.GetFieldValueAsBoolean(AFieldName);
  end
  else
  begin
    Result := ADefault;
  end;
end;

//******************************************************************************
function SafeGetFieldValueAsFloat(AObject: TNxCustomBusinessObject; AFieldName: string; ADefault:Extended = 0): Extended;
begin
  if Assigned(AObject) then
  begin
    Result := AObject.GetFieldValueAsFloat(AFieldName);
  end
  else
  begin
    Result := ADefault;
  end;
end;

//******************************************************************************
procedure CopyFields(ASource, ADestination: TNxCustomBusinessObject);
const
  cFuncName = 'CopyFields';
begin
  if Assigned(ADestination) then
  begin
    ADestination.SetFieldValueAsString('X_IPPC', SafeGetFieldValueAsString(ASource, 'X_IPPC'));
    ADestination.SetFieldValueAsInteger('X_PocetStosu', SafeGetFieldValueAsInteger(ASource, 'X_PocetStosu'));
    ADestination.SetFieldValueAsInteger('X_KusuVeStosu', SafeGetFieldValueAsInteger(ASource, 'X_KusuVeStosu'));
    ADestination.SetFieldValueAsInteger('X_PocetStosuSlozene', SafeGetFieldValueAsInteger(ASource, 'X_PocetStosuSlozene'));
    ADestination.SetFieldValueAsInteger('X_KusuVeStosuSlozene', SafeGetFieldValueAsInteger(ASource, 'X_KusuVeStosuSlozene'));
    ADestination.SetFieldValueAsString('X_PreferovanyKamion', SafeGetFieldValueAsString(ASource, 'X_PreferovanyKamion'));
    ADestination.SetFieldValueAsBoolean('X_LisovanaKostka', SafeGetFieldValueAsBoolean(ASource, 'X_LisovanaKostka'));
    ADestination.SetFieldValueAsBoolean('X_DrevenaKostka', SafeGetFieldValueAsBoolean(ASource, 'X_DrevenaKostka'));
    ADestination.SetFieldValueAsBoolean('X_Susene', SafeGetFieldValueAsBoolean(ASource, 'X_Susene'));
    ADestination.SetFieldValueAsBoolean('X_OrezaneRohy', SafeGetFieldValueAsBoolean(ASource, 'X_OrezaneRohy'));
    ADestination.SetFieldValueAsBoolean('X_Slozene', SafeGetFieldValueAsBoolean(ASource, 'X_Slozene'));
    ADestination.SetFieldValueAsBoolean('X_VzduchosuchaPaleta', SafeGetFieldValueAsBoolean(ASource, 'X_VzduchosuchaPaleta'));
//    ADestination.SetFieldValueAsBoolean('X_KrizovaPaleta', SafeGetFieldValueAsBoolean(ASource, 'X_KrizovaPaleta'));
//    ADestination.SetFieldValueAsBoolean('X_HranolkovaPaleta', SafeGetFieldValueAsBoolean(ASource, 'X_HranolkovaPaleta'));
    if ASource.HasField('X_Kvalita') then ADestination.SetFieldValueAsString('X_Kvalita_ID', SafeGetFieldValueAsString(ASource, 'X_Kvalita'));
    if ASource.HasField('X_Kvalita_ID') then ADestination.SetFieldValueAsString('X_Kvalita', SafeGetFieldValueAsString(ASource, 'X_Kvalita_ID'));

    ADestination.SetFieldValueAsFloat('X_Pozice_01', SafeGetFieldValueAsFloat(ASource, 'X_Pozice_01'));
    ADestination.SetFieldValueAsFloat('X_Tloustka_01', SafeGetFieldValueAsFloat(ASource, 'X_Tloustka_01'));
    ADestination.SetFieldValueAsFloat('X_Sirka_01', SafeGetFieldValueAsFloat(ASource, 'X_Sirka_01'));
    ADestination.SetFieldValueAsFloat('X_Delka_01', SafeGetFieldValueAsFloat(ASource, 'X_Delka_01'));
    ADestination.SetFieldValueAsFloat('X_Pocet_01', SafeGetFieldValueAsFloat(ASource, 'X_Pocet_01'));

    ADestination.SetFieldValueAsFloat('X_Pozice_02', SafeGetFieldValueAsFloat(ASource, 'X_Pozice_02'));
    ADestination.SetFieldValueAsFloat('X_Tloustka_02', SafeGetFieldValueAsFloat(ASource, 'X_Tloustka_02'));
    ADestination.SetFieldValueAsFloat('X_Sirka_02', SafeGetFieldValueAsFloat(ASource, 'X_Sirka_02'));
    ADestination.SetFieldValueAsFloat('X_Delka_02', SafeGetFieldValueAsFloat(ASource, 'X_Delka_02'));
    ADestination.SetFieldValueAsFloat('X_Pocet_02', SafeGetFieldValueAsFloat(ASource, 'X_Pocet_02'));

    ADestination.SetFieldValueAsFloat('X_Pozice_03', SafeGetFieldValueAsFloat(ASource, 'X_Pozice_03'));
    ADestination.SetFieldValueAsFloat('X_Tloustka_03', SafeGetFieldValueAsFloat(ASource, 'X_Tloustka_03'));
    ADestination.SetFieldValueAsFloat('X_Sirka_03', SafeGetFieldValueAsFloat(ASource, 'X_Sirka_03'));
    ADestination.SetFieldValueAsFloat('X_Delka_03', SafeGetFieldValueAsFloat(ASource, 'X_Delka_03'));
    ADestination.SetFieldValueAsFloat('X_Pocet_03', SafeGetFieldValueAsFloat(ASource, 'X_Pocet_03'));

    ADestination.SetFieldValueAsFloat('X_Pozice_04', SafeGetFieldValueAsFloat(ASource, 'X_Pozice_04'));
    ADestination.SetFieldValueAsFloat('X_Tloustka_04', SafeGetFieldValueAsFloat(ASource, 'X_Tloustka_04'));
    ADestination.SetFieldValueAsFloat('X_Sirka_04', SafeGetFieldValueAsFloat(ASource, 'X_Sirka_04'));
    ADestination.SetFieldValueAsFloat('X_Delka_04', SafeGetFieldValueAsFloat(ASource, 'X_Delka_04'));
    ADestination.SetFieldValueAsFloat('X_Pocet_04', SafeGetFieldValueAsFloat(ASource, 'X_Pocet_04'));

    ADestination.SetFieldValueAsFloat('X_Pozice_05', SafeGetFieldValueAsFloat(ASource, 'X_Pozice_05'));
    ADestination.SetFieldValueAsFloat('X_Tloustka_05', SafeGetFieldValueAsFloat(ASource, 'X_Tloustka_05'));
    ADestination.SetFieldValueAsFloat('X_Sirka_05', SafeGetFieldValueAsFloat(ASource, 'X_Sirka_05'));
    ADestination.SetFieldValueAsFloat('X_Delka_05', SafeGetFieldValueAsFloat(ASource, 'X_Delka_05'));
    ADestination.SetFieldValueAsFloat('X_Pocet_05', SafeGetFieldValueAsFloat(ASource, 'X_Pocet_05'));

    ADestination.SetFieldValueAsFloat('X_Pozice_06', SafeGetFieldValueAsFloat(ASource, 'X_Pozice_06'));
    ADestination.SetFieldValueAsFloat('X_Tloustka_06', SafeGetFieldValueAsFloat(ASource, 'X_Tloustka_06'));
    ADestination.SetFieldValueAsFloat('X_Sirka_06', SafeGetFieldValueAsFloat(ASource, 'X_Sirka_06'));
    ADestination.SetFieldValueAsFloat('X_Delka_06', SafeGetFieldValueAsFloat(ASource, 'X_Delka_06'));
    ADestination.SetFieldValueAsFloat('X_Pocet_06', SafeGetFieldValueAsFloat(ASource, 'X_Pocet_06'));

    ADestination.SetFieldValueAsFloat('X_Pozice_07', SafeGetFieldValueAsFloat(ASource, 'X_Pozice_07'));
    ADestination.SetFieldValueAsFloat('X_Tloustka_07', SafeGetFieldValueAsFloat(ASource, 'X_Tloustka_07'));
    ADestination.SetFieldValueAsFloat('X_Sirka_07', SafeGetFieldValueAsFloat(ASource, 'X_Sirka_07'));
    ADestination.SetFieldValueAsFloat('X_Delka_07', SafeGetFieldValueAsFloat(ASource, 'X_Delka_07'));
    ADestination.SetFieldValueAsFloat('X_Pocet_07', SafeGetFieldValueAsFloat(ASource, 'X_Pocet_07'));

    ADestination.SetFieldValueAsFloat('X_Pozice_08', SafeGetFieldValueAsFloat(ASource, 'X_Pozice_08'));
    ADestination.SetFieldValueAsFloat('X_Tloustka_08', SafeGetFieldValueAsFloat(ASource, 'X_Tloustka_08'));
    ADestination.SetFieldValueAsFloat('X_Sirka_08', SafeGetFieldValueAsFloat(ASource, 'X_Sirka_08'));
    ADestination.SetFieldValueAsFloat('X_Delka_08', SafeGetFieldValueAsFloat(ASource, 'X_Delka_08'));
    ADestination.SetFieldValueAsFloat('X_Pocet_08', SafeGetFieldValueAsFloat(ASource, 'X_Pocet_08'));

    ADestination.SetFieldValueAsFloat('X_Pozice_09', SafeGetFieldValueAsFloat(ASource, 'X_Pozice_09'));
    ADestination.SetFieldValueAsFloat('X_Tloustka_09', SafeGetFieldValueAsFloat(ASource, 'X_Tloustka_09'));
    ADestination.SetFieldValueAsFloat('X_Sirka_09', SafeGetFieldValueAsFloat(ASource, 'X_Sirka_09'));
    ADestination.SetFieldValueAsFloat('X_Delka_09', SafeGetFieldValueAsFloat(ASource, 'X_Delka_09'));
    ADestination.SetFieldValueAsFloat('X_Pocet_09', SafeGetFieldValueAsFloat(ASource, 'X_Pocet_09'));

    ADestination.SetFieldValueAsFloat('X_Pozice_10', SafeGetFieldValueAsFloat(ASource, 'X_Pozice_10'));
    ADestination.SetFieldValueAsFloat('X_Tloustka_10', SafeGetFieldValueAsFloat(ASource, 'X_Tloustka_10'));
    ADestination.SetFieldValueAsFloat('X_Sirka_10', SafeGetFieldValueAsFloat(ASource, 'X_Sirka_10'));
    ADestination.SetFieldValueAsFloat('X_Delka_10', SafeGetFieldValueAsFloat(ASource, 'X_Delka_10'));
    ADestination.SetFieldValueAsFloat('X_Pocet_10', SafeGetFieldValueAsFloat(ASource, 'X_Pocet_10'));
  end
  else
  begin
    Log(cFuncName, Format('ADestination (%d) nesmí být nil', [ObjToInt(ADestination)]));
  end;
end;

begin
end.