uses 'abra.cz.servis.kama.EshopEmailing.common';

var mNewDoc: Boolean;
  mOrigValueConfirm: Boolean;
  mUserFields: TDataset;
  mParPMStatesOn, mPMSystemState: integer;
  mOldPMStateID: string;

procedure Validate_Hook(Self: TNxCustomBusinessObject; var AResult: Boolean);
begin
   Self.GetOriginalValue('PMState_ID', mOldPMStateID);
end;

procedure AfterSave_Hook(Self: TNxCustomBusinessObject);
var mSQL: string;
  mPrevValue: string;
  mDocQueueID: string;
  mCountryID: string;
begin
  try
    if not Assigned(mUserFields) then begin
      mUserFields := TMemoryDataset.Create(nil);
    end;
    if Assigned(mUserFields) then begin
      mUserFields.Active := false;
      mUserFields.Fields.Clear;
      mUserFields.FieldDefs.Clear;

      mDocQueueID := Self.GetFieldValueAsString('DocQueue_ID');
      mCountryID := GetCountryID(Self.ObjectSpace, Self.GetFieldValueAsString('Firm_ID.ResidenceAddress_ID.CountryCode'));
      if not NxIsEmptyOID(mCountryID) then begin //zkusíme definici se zemí
        mSQL := Format('Select A.ID as ID, A.X_UserFieldName as UserFieldName, %s as PrevValue from DefRollData A where X_SystemAction=6 and X_UserFieldName <> %s and CLSID=%s and X_UsedDocQueue_ID LIKE (' + QuotedStr('%%') + GetConcatChar + '%s' + GetConcatChar + QuotedStr('%%') + ') and X_UsedCountry_ID=%s and Hidden=%s',
          [QuotedStr('X'), QuotedStr(''), QuotedStr('1EM15VZKGXLONIBKTGPMJTAIFS'), QuotedStr(mDocQueueID), QuotedStr(mCountryID), QuotedStr('N')]);
        Self.ObjectSpace.SQLSelect2(mSQL, mUserFields);
      end;
      if mUserFields.Active = false then begin //nyní definici bez země
        mSQL := Format('Select A.ID as ID, A.X_UserFieldName as UserFieldName, %s as PrevValue from DefRollData A where X_SystemAction=6 and X_UserFieldName <> %s and CLSID=%s and X_UsedDocQueue_ID LIKE (' + QuotedStr('%%') + GetConcatChar + '%s' + GetConcatChar + QuotedStr('%%') + ') and X_UsedCountry_ID is null and Hidden=%s',
          [QuotedStr('X'), QuotedStr(''), QuotedStr('1EM15VZKGXLONIBKTGPMJTAIFS'), QuotedStr(mDocQueueID), QuotedStr('N')]);
        Self.ObjectSpace.SQLSelect2(mSQL, mUserFields);
      end;

      if mUserFields.Active then begin
        mUserFields.First;
        while not mUserFields.Eof do begin
          mUserFields.Edit;
          Self.GetOriginalValue(mUserFields.FieldByName('UserFieldName').AsString, mPrevValue);
          mUserFields.FieldByName('PrevValue').AsString := mPrevValue;
          mUserFields.Post;
          mUserFields.Next;
        end;
      end;
    end;

    mNewDoc := NxCheckBit(Self.State, osNew);
    Self.GetOriginalValue_3('Confirmed', mOrigValueConfirm);
    mParPMStatesOn := GetCompanyParam(Self.ObjectSpace, 'RLZ44YQB322OPAGJSWSW5XJ13G');//procesní stavy OP
    mPMSystemState := Self.GetFieldValueAsInteger('PMState_ID.SystemState');
  except
    NxScriptingLog.WriteEvent(logDebug, ExceptionMessage);
    OutputDebugString(ExceptionMessage);
  end;
end;


procedure _FinalizeSave_PreHook(Self: TNxCustomBusinessObject);
var mActValue: string;
begin
  try
    if NxCheckBit(Self.State, osInvalid) = false then begin
      if (mNewDoc) then
        EshopAction(self, 1)
      else begin
        if (mOrigValueConfirm = false) and (Self.GetFieldValueAsBoolean('Confirmed') = true) then
          EshopAction(self, 2)
      end;

      //změna proces. stavu
      if (mParPMStatesOn = 1) and (mOldPMStateID <> Self.GetFieldValueAsString('PMState_ID')) then begin
        EshopAction(self, 28, Self.GetFieldValueAsString('PMState_ID'));
      end;
    end;

    if Assigned(mUserFields) then begin
      if mUserFields.Active then begin
        mUserFields.First;
        while not mUserFields.Eof do begin
          mActValue := Self.GetFieldValueAsString(mUserFields.FieldByName('UserFieldName').AsString);
          if (mActValue <> mUserFields.FieldByName('PrevValue').asString) and (mActValue = 'A') then
            EshopAction(self, 6, mUserFields.FieldByName('ID').asString);
          mUserFields.Next;
        end;
      end;
      mUserFields.Free;
      mUserFields := nil;
    end;
  except
    NxScriptingLog.WriteEvent(logDebug, ExceptionMessage);
    OutputDebugString(ExceptionMessage);
  end;
end;

begin
end.
