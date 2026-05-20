uses 'abra.cz.servis.kama.EshopEmailing.common';

procedure Validate_Hook(Self: TNxCustomBusinessObject; var AResult: Boolean);
var mUsedDocQueueID, mUsedCountryID, mUsedActQueueID, mActProcessID, mOfferSateID, mCondition, mPMStateID: string;
begin
  mUsedDocQueueID := Self.GetFieldValueAsString('X_UsedDocQueue_ID');
  mUsedCountryID := Self.GetFieldValueAsString('X_UsedCountry_ID');
  mCondition := AnsiUpperCase(Self.GetFieldValueAsString('X_EmailCondition'));

  if (mUsedCountryID = '') or (mUsedCountryID = '0000000000') then
    mUsedCountryID := ' is null'
  else mUsedCountryID := '=' + QuotedStr(mUsedCountryID);

  mUsedActQueueID := Self.GetFieldValueAsString('X_UsedActQueue_ID');
  mOfferSateID := Self.GetFieldValueAsString('X_OfferState_ID');
  mActProcessID := Self.GetFieldValueAsString('X_ActivityProcess_ID');
  mPMStateID := Self.GetFieldValueAsString('X_PMState_ID');

  if NxIsEmptyOID(Self.GetFieldValueAsString('X_OwnEmailAccount_ID')) then begin
    AResult := false;
    Self.AddValidateError(Self.GetFieldCode('X_OwnEmailAccount_ID'), 'Vlastní e-mailový účet musí být vyplněn.');
  end;

  if (Self.GetFieldValueAsInteger('X_SystemAction') = 0) and (not NxIsEmptyOID(Self.GetFieldValueAsString('X_UsedDocQueue_ID'))) then begin
    AResult := false;
    Self.AddValidateError(Self.GetFieldCode('X_UsedDocQueue_ID'), 'Při akci registrace se řada neuvádí');
  end;

  //akce při UDP - název položky
  if (Self.GetFieldValueAsInteger('X_SystemAction') = 6) and NxIsBlank(Self.GetFieldValueAsString('X_UserFieldName')) then begin
    AResult := false;
    Self.AddValidateError(Self.GetFieldCode('X_UserFieldName'), 'Název definovatelné položky musí být vyplněn.');
  end;

  //akce při UDP - typ položky
  if (Self.GetFieldValueAsInteger('X_SystemAction') = 6) and (VerifyUserField(Self.ObjectSpace, Self.GetFieldValueAsString('X_UserFieldName')) = false) then begin
    AResult := false;
    Self.AddValidateError(Self.GetFieldCode('X_UserFieldName'), 'Definovatelná položka musí být typu Ano/Ne.');
  end;

  //akce při změně stavu nabídky
  if (Self.GetFieldValueAsInteger('X_SystemAction') = 12) and (NxIsEmptyOID(mOfferSateID)) then begin
    AResult := false;
    Self.AddValidateError(Self.GetFieldCode('X_OfferState_ID'), 'Stav nabídky musí být vyplněn');
  end;

  //akce při procesu aktivity nabídky
  if (Self.GetFieldValueAsInteger('X_SystemAction') = 13) and (NxIsEmptyOID(mActProcessID)) then begin
    AResult := false;
    Self.AddValidateError(Self.GetFieldCode('X_ActivityProcess_ID'), 'Proces aktivity musí být vyplněn');
  end;

  //kombinace řady, zěmě a akce
  if GetSQLValue(Self.ObjectSpace, Format('Select count(ID) as dbvalue from DefRollData where CLSID=%s and ID<>%s and X_SystemAction=%s and X_UsedDocQueue_ID = %s and X_UsedCountry_ID %s' + NxCrLf +
    'and Upper(cast(X_EmailCondition as varchar(1000)))=%s' + NxCrLf +
    'and (X_SystemAction<>0 and X_SystemAction<>6 and X_SystemAction<>12 and X_SystemAction<>13 and X_SystemAction<>25)',
    [QuotedStr('1EM15VZKGXLONIBKTGPMJTAIFS'), QuotedStr(Self.OID), IntToStr(Self.GetFieldValueAsInteger('X_SystemAction')), QuotedStr(NxSearchReplace(mUsedDocQueueID, ';', QuotedStr(','), [srAll])), mUsedCountryID, QuotedStr(mCondition)]), 0) > 0 then begin
    AResult := false;
    Self.AddValidateError(Self.GetFieldCode('X_SystemAction'), 'Již existuje kombinace systémové události, řady, země, měny a podnímky.');
  end;

  //stav nabídky
  if Self.GetFieldValueAsInteger('X_SystemAction') = 12 then begin
    if GetSQLValue(Self.ObjectSpace, Format('Select count(ID) as dbvalue from DefRollData where CLSID=%s and ID<>%s and X_SystemAction=%s and X_UsedDocQueue_ID = %s and (X_OfferState_ID<>'''' and X_OfferState_ID<>'' '' ) and X_OfferState_ID=%s and X_UsedCountry_ID %s and Hidden=%s',
      [QuotedStr('1EM15VZKGXLONIBKTGPMJTAIFS'), QuotedStr(Self.OID), IntToStr(Self.GetFieldValueAsInteger('X_SystemAction')), QuotedStr(NxSearchReplace(mUsedDocQueueID, ';', QuotedStr(','), [srAll])), QuotedStr(mOfferSateID), mUsedCountryID, QuotedStr('N')]), 0) > 0 then begin
      AResult := false;
      Self.AddValidateError(Self.GetFieldCode('X_SystemAction'), 'Kombinace systémové události, řady dokladů, země a stavu nabídky je již použita.');
    end;
  end;

  //proces aktivity
  if Self.GetFieldValueAsInteger('X_SystemAction') = 13 then begin
    if GetSQLValue(Self.ObjectSpace, Format('Select count(ID) as dbvalue from DefRollData where CLSID=%s and ID<>%s and X_SystemAction=%s and X_UsedActQueue_ID=%s and (X_ActivityProcess_ID<>'''' and X_ActivityProcess_ID<>'' '' ) and X_ActivityProcess_ID=%s and X_UsedCountry_ID %s and Hidden=%s',
      [QuotedStr('1EM15VZKGXLONIBKTGPMJTAIFS'), QuotedStr(Self.OID), IntToStr(Self.GetFieldValueAsInteger('X_SystemAction')), QuotedStr(mUsedActQueueID), QuotedStr(mActProcessID), mUsedCountryID, QuotedStr('N')]), 0) > 0 then begin
      AResult := false;
      Self.AddValidateError(Self.GetFieldCode('X_SystemAction'), 'Kombinace systémové události, řady aktivit, země a procesu aktivity je již použita.');
    end;
  end;

  //změna proces. stavu
  if Self.GetFieldValueAsInteger('X_SystemAction') in [25,28] then begin
    if GetSQLValue(Self.ObjectSpace, Format('Select count(ID) as dbvalue from DefRollData where CLSID=%s and ID<>%s and X_SystemAction=%s and X_UsedActQueue_ID=%s and (X_ActivityProcess_ID<>'''' and X_ActivityProcess_ID<>'' '' ) and X_PMState_ID=%s and X_UsedCountry_ID %s and Hidden=%s',
      [QuotedStr('1EM15VZKGXLONIBKTGPMJTAIFS'), QuotedStr(Self.OID), IntToStr(Self.GetFieldValueAsInteger('X_SystemAction')), QuotedStr(mUsedActQueueID), QuotedStr(mActProcessID), mUsedCountryID, QuotedStr('N')]), 0) > 0 then begin
      AResult := false;
      Self.AddValidateError(Self.GetFieldCode('X_SystemAction'), 'Kombinace systémové události, řady dokladů, země a procesního stavu je již použita.');
    end;

    if NxIsEmptyOID(mPMStateID) then begin
      AResult := false;
      Self.AddValidateError(Self.GetFieldCode('X_PMState_ID'), 'Procesní stav musí být vyplněn.');
    end;
  end;

  if Self.GetFieldValueAsBoolean('X_SendSMS') then begin
    if NxIsBlank(Self.GetFieldValueAsString('X_SMSUserName')) then begin
      AResult := false;
      Self.AddValidateError(Self.GetFieldCode('X_SMSUserName'), 'Uživatelské jméno musí být vyplněné');
    end;
    if NxIsBlank(Self.GetFieldValueAsString('X_SMSPassword')) then begin
      AResult := false;
      Self.AddValidateError(Self.GetFieldCode('X_SMSPassword'), 'Heslo musí být vyplněné');
    end;
    if NxIsBlank(Self.GetFieldValueAsString('X_SMSMessage')) then begin
      AResult := false;
      Self.AddValidateError(Self.GetFieldCode('X_SMSMessage'), 'Zpráva musí být vyplněná');
    end;
  end;
end;

function VerifyUserField(AOS: TNxCustomObjectSpace; AFieldName: string): Boolean;
var mSQL: string;
  mStr: TStrings;
begin
  result := true;
  AFieldName := NxSearchReplace(AFieldName, 'X_', '', [srAll]);
  AFieldName := NxSearchReplace(AFieldName, 'U_', '', [srAll]);

  mSQL := Format('Select A.FieldDataType from UserFieldDefs2 A JOIN UserFieldDefs B ON B.ID=A.Parent_ID and B.CLSID=%s and A.FieldName=%s', [QuotedStr('01CPMINJW3DL342X01C0CX3FCC'), QuotedStr(AFieldName)]);
  mStr := TStringList.Create;
  try
    AOS.SQLSelect(mSQL, mStr);
    if mStr.Count > 0 then begin
      result := StrToInt(mStr.Strings[0]) = 5;
    end;
  finally
    mStr.Free;
  end;
end;



begin
end.
