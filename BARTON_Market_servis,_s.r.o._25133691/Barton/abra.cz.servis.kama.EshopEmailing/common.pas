uses 'abra.cz.servis.kama.EshopEmailing.constants';

const
  cDefRollCLSID = '1EM15VZKGXLONIBKTGPMJTAIFS'; //čáselník s nastavením
  cDocumentsDefRollCLSID = 'PNHFASIC3S2OPJJW5TQR0PKTDW'; //dokumenty ke stažení

  {
   0 - Registrace uživatele
   1 - Prijetí objednávky
   2 - Potvrzení objednávky
   3 - Částečné vyrízení objendávky
   4 - Kompletní vyrízení objednávky
   5 - Vytvoření zálohy
   6 - Akce na UDP v OP
   7 - EET OSP
   8 - Faktura vydaná - tlačítko
   9 - Pokladní příjem - tlačítko
  10 - Vytvoření dodacího litu
  11 - Vytvoření nabídky
  12 - Změna stavu nabídky
  13 - nastavení procesu v aktivitě
  14 - Odeslání OP pomocí tlačítka
  15 - Odeslání OV pomocí tlačítka
  16 - Odeslání DZLV pomocí tlačítka
  17 - Odeslání DV pomocí tlačítka
  18 - Vytvoření odeslané pošty
  19 - Vytvoření odeslané pošty pomocí tlačítka
  20 - Zaplacení zálohového listu - úplné
  21 - Odeslání výzvy k os. odběru pomocí tlačítka
  22 - Změna stavu odeslané pošty z Balíkobotu na exportováno
  23 - Vytvoření FV
  24 - Zaplacení zálohového listu (online platba)
  25 - Změna procesního stavu dodacího listu
  26 - Změna stavu odeslané pošty z Balíkobotu na uzavřeno
  27 - Zaplacení zálohového listu - částečné
  28 - Změna procesního stavu OP
 }

function EshopAction(ABO: TNxCustomBusinessObject; AAction: Integer; ASpecParamID: string = ''; ASite: TDynSiteForm = nil): Boolean;
begin
  result := true;
  if AAction = 0 then RegisterUser(ABO, AAction, ASpecParamID);
  if AAction = 1 then ProcessCommonDoc(ABO, AAction);
  if AAction = 2 then ProcessCommonDoc(ABO, AAction);
  if AAction = 3 then ProcessCommonDoc(ABO, AAction);
  if AAction = 4 then ProcessCommonDoc(ABO, AAction);
  if AAction = 5 then ProcessCommonDoc(ABO, AAction);
  if AAction = 6 then ProcessUDFOrder(ABO, AAction, ASpecParamID);
  if AAction = 7 then ProcessCommonDoc(ABO, AAction);
  if AAction = 8 then result := ProcessCommonDocWithDynSite(ABO, AAction, Assigned(ASite), ASite);
  if AAction = 9 then result := ProcessCommonDocWithDynSite(ABO, AAction, Assigned(ASite), ASite);
  if AAction = 10 then ProcessCommonDoc(ABO, AAction);
  if AAction = 11 then ProcessOffer(ABO, AAction, '');
  if AAction = 12 then ProcessOffer(ABO, AAction, ASpecParamID);
  if AAction = 13 then ProcessCRMActivity(ABO, AAction, ASpecParamID);
  if AAction = 14 then result := ProcessCommonDocWithDynSite(ABO, AAction, Assigned(ASite), ASite);
  if AAction = 15 then result := ProcessCommonDocWithDynSite(ABO, AAction, Assigned(ASite), ASite);
  if AAction = 16 then result := ProcessCommonDocWithDynSite(ABO, AAction, Assigned(ASite), ASite);
  if AAction = 17 then result := ProcessCommonDocWithDynSite(ABO, AAction, Assigned(ASite), ASite);
  if AAction = 18 then ProcessCommonDoc(ABO, AAction);
  if AAction = 19 then result := ProcessCommonDocWithDynSite(ABO, AAction, Assigned(ASite), ASite);
  if AAction = 20 then ProcessCommonDoc(ABO, AAction);
  if AAction = 21 then result := ProcessCommonDocWithDynSite(ABO, AAction, Assigned(ASite), ASite);
  if AAction = 22 then ProcessCommonDoc(ABO, AAction);
  if AAction = 23 then ProcessCommonDoc(ABO, AAction);
  if AAction = 24 then ProcessCommonDoc(ABO, AAction);
  if AAction = 25 then ProcessChangePMState(ABO, AAction, ASpecParamID);
  if AAction = 26 then ProcessCommonDoc(ABO, AAction);
  if AAction = 27 then ProcessCommonDoc(ABO, AAction);
  if AAction = 28 then ProcessChangePMState(ABO, AAction, ASpecParamID);
end;

procedure ProcessCommonDoc(ABO: TNxCustomBusinessObject; AAction: Integer);
var
  mSQL, mEmailAddress, mCountryID: string;
  mStr: TStrings;
  i: integer;
  mFound: Boolean;
begin
  mEmailAddress := GetEmailAddress(ABO);
  if not NxIsBlank(mEmailAddress) and (NxAt('@', mEmailAddress) > 0) then begin
    mStr := TStringList.Create;
    try
      mCountryID := GetCountryID(ABO.ObjectSpace, ABO.GetFieldValueAsString('Firm_ID.ResidenceAddress_ID.CountryCode'));
      if not NxIsEmptyOID(mCountryID) then begin //zkusíme definici se zemí
        mSQL := Format('Select ID as dbvalue from DefRollData where Hidden=''N'' and CLSID=%s and X_SystemAction=%s and X_UsedDocQueue_ID LIKE (' + QuotedStr('%%') + GetConcatChar + '%s' + GetConcatChar + QuotedStr('%%') + ') and X_UsedCountry_ID=%s',
          [QuotedStr(cDefRollCLSID), IntToStr(AAction), QuotedStr(ABO.GetFieldValueAsString('DocQueue_ID')), QuotedStr(mCountryID)]);
        mFound := GetSQLValuesAsStrings(ABO.ObjectSpace, mSQL, mStr);
        for i := 0 to mStr.Count - 1 do begin
          TrySendEmailCommon(ABO, mStr.Strings[i], mEmailAddress);
        end;
      end;
      if not mFound then begin //nyní definici bez země
        mSQL := Format('Select ID as dbvalue from DefRollData where Hidden=''N'' and CLSID=%s and X_SystemAction=%s and X_UsedDocQueue_ID LIKE (' + QuotedStr('%%') + GetConcatChar + '%s' + GetConcatChar + QuotedStr('%%') + ') and X_UsedCountry_ID is null',
          [QuotedStr(cDefRollCLSID), IntToStr(AAction), QuotedStr(ABO.GetFieldValueAsString('DocQueue_ID'))]);
        mFound := GetSQLValuesAsStrings(ABO.ObjectSpace, mSQL, mStr);
        for i := 0 to mStr.Count - 1 do begin
          TrySendEmailCommon(ABO, mStr.Strings[i], mEmailAddress);
        end;
      end;
    finally
      mStr.Free;
    end;
  end;
end;

procedure ProcessUDFOrder(ABO: TNxCustomBusinessObject; AAction: Integer; ADefinitionID: string);
var
  mSQL, mEmailAddress, mCountryID: string;
begin
  mEmailAddress := GetEmailAddress(ABO);
  if not NxIsBlank(mEmailAddress) and (NxAt('@', mEmailAddress) > 0) then begin
    TrySendEmailCommon(ABO, ADefinitionID, mEmailAddress);
  end;
end;


function ProcessCommonDocWithDynSite(ABO: TNxCustomBusinessObject; AAction: Integer; AEditEmail: Boolean; ASite: TDynSiteForm): Boolean;
var
  mSQL, mEmailAddress, mCountryID: string;
  mStr: TStrings;
  mFound, mResult: Boolean;
  i: integer;
begin
  result := false;
  mEmailAddress := GetEmailAddress(ABO);
  if not NxIsBlank(mEmailAddress) and (NxAt('@', mEmailAddress) > 0) then begin
    mStr := TStringList.Create;
    try
      mCountryID := GetCountryID(ABO.ObjectSpace, ABO.GetFieldValueAsString('Firm_ID.ResidenceAddress_ID.CountryCode'));
      if not NxIsEmptyOID(mCountryID) then begin //zkusíme definici se zemí
        mSQL := Format('Select ID as dbvalue from DefRollData where Hidden=''N'' and CLSID=%s and X_SystemAction=%s and X_UsedDocQueue_ID LIKE (' + QuotedStr('%%') + GetConcatChar + '%s' + GetConcatChar + QuotedStr('%%') + ') and X_UsedCountry_ID=%s',
          [QuotedStr(cDefRollCLSID), IntToStr(AAction), QuotedStr(ABO.GetFieldValueAsString('DocQueue_ID')), QuotedStr(mCountryID)]);
        mFound := GetSQLValuesAsStrings(ABO.ObjectSpace, mSQL, mStr);
        for i := 0 to mStr.Count - 1 do begin
          mResult := TrySendEmailCommon(ABO, mStr.Strings[i], mEmailAddress, AEditEmail, ASite);
          if mResult then result := true;
        end;
      end;
      if not mFound then begin //nyní definici bez země
        mSQL := Format('Select ID as dbvalue from DefRollData where Hidden=''N'' and CLSID=%s and X_SystemAction=%s and X_UsedDocQueue_ID LIKE (' + QuotedStr('%%') + GetConcatChar + '%s' + GetConcatChar + QuotedStr('%%') + ') and X_UsedCountry_ID is null',
          [QuotedStr(cDefRollCLSID), IntToStr(AAction), QuotedStr(ABO.GetFieldValueAsString('DocQueue_ID'))]);
        mFound := GetSQLValuesAsStrings(ABO.ObjectSpace, mSQL, mStr);
        for i := 0 to mStr.Count - 1 do begin
          mResult := TrySendEmailCommon(ABO, mStr.Strings[i], mEmailAddress, AEditEmail, ASite);
          if mResult then result := true;
        end;
      end;
    finally
      mStr.Free;
    end;
  end;
end;

procedure ProcessOffer(ABO: TNxCustomBusinessObject; AAction: Integer; AOfferStateID: string);
var
  mSQL, mEmailAddress, mCountryID: string;
  mStr: TStrings;
  mFound, mResult: Boolean;
  i: integer;
begin
  mEmailAddress := GetEmailAddress(ABO);
  if not NxIsBlank(mEmailAddress) and (NxAt('@', mEmailAddress) > 0) then begin
    mStr := TStringList.Create;
    try
      mCountryID := GetCountryID(ABO.ObjectSpace, ABO.GetFieldValueAsString('Firm_ID.ResidenceAddress_ID.CountryCode'));

      if not NxIsEmptyOID(mCountryID) then begin //zkusíme definici se zemí
        if NxIsBlank(AOfferStateID) then
          mSQL := Format('Select ID as dbvalue from DefRollData where Hidden=''N'' and CLSID=%s and X_SystemAction=%s and X_UsedDocQueue_ID LIKE (' + QuotedStr('%%') + GetConcatChar + '%s' + GetConcatChar + QuotedStr('%%') + ') and X_UsedCountry_ID=%s',
            [QuotedStr(cDefRollCLSID), IntToStr(AAction), QuotedStr(ABO.GetFieldValueAsString('DocQueue_ID')), QuotedStr(mCountryID)])
        else
          mSQL := Format('Select ID as dbvalue from DefRollData where Hidden=''N'' and CLSID=%s and X_SystemAction=%s and X_UsedDocQueue_ID LIKE (' + QuotedStr('%%') + GetConcatChar + '%s' + GetConcatChar + QuotedStr('%%') + ') and X_OfferState_ID=%s and X_UsedCountry_ID=%s',
            [QuotedStr(cDefRollCLSID), IntToStr(AAction), QuotedStr(ABO.GetFieldValueAsString('DocQueue_ID')), QuotedStr(AOfferStateID), QuotedStr(mCountryID)]);

        mFound := GetSQLValuesAsStrings(ABO.ObjectSpace, mSQL, mStr);
        for i := 0 to mStr.Count - 1 do begin
          TrySendEmailCommon(ABO, mStr.Strings[i], mEmailAddress);
        end;
      end;
      if not mFound then begin //nyní definici bez země
        if NxIsBlank(AOfferStateID) then
          mSQL := Format('Select ID as dbvalue from DefRollData where Hidden=''N'' and CLSID=%s and X_SystemAction=%s and X_UsedDocQueue_ID LIKE (' + QuotedStr('%%') + GetConcatChar + '%s' + GetConcatChar + QuotedStr('%%') + ') and X_UsedCountry_ID is null',
            [QuotedStr(cDefRollCLSID), IntToStr(AAction), QuotedStr(ABO.GetFieldValueAsString('DocQueue_ID'))])
        else
          mSQL := Format('Select ID as dbvalue from DefRollData where Hidden=''N'' and CLSID=%s and X_SystemAction=%s and X_UsedDocQueue_ID LIKE (' + QuotedStr('%%') + GetConcatChar + '%s' + GetConcatChar + QuotedStr('%%') + ') and X_OfferState_ID=%s and X_UsedCountry_ID is null',
            [QuotedStr(cDefRollCLSID), IntToStr(AAction), QuotedStr(ABO.GetFieldValueAsString('DocQueue_ID')), QuotedStr(AOfferStateID)]);
        mFound := GetSQLValuesAsStrings(ABO.ObjectSpace, mSQL, mStr);
        for i := 0 to mStr.Count - 1 do begin
          TrySendEmailCommon(ABO, mStr.Strings[i], mEmailAddress);
        end;
      end;
    finally
      mStr.Free;
    end;
  end;
end;

procedure ProcessCRMActivity(ABO: TNxCustomBusinessObject; AAction: Integer; AProcessID: string);
var
  mSQL, mEmailAddress, mCountryID: string;
  mStr: TStrings;
  mFound, mResult: Boolean;
  i: integer;
begin
  mEmailAddress := GetEmailAddress(ABO);
  if not NxIsBlank(mEmailAddress) and (NxAt('@', mEmailAddress) > 0) then begin
    mStr := TStringList.Create;
    try
      mCountryID := GetCountryID(ABO.ObjectSpace, ABO.GetFieldValueAsString('Firm_ID.ResidenceAddress_ID.CountryCode'));
      if not NxIsEmptyOID(mCountryID) then begin //zkusíme definici se zemí
        if NxIsBlank(AProcessID) then
          mSQL := Format('Select ID as dbvalue from DefRollData where Hidden=''N'' and CLSID=%s and X_SystemAction=%s and X_UsedActQueue_ID=%s and X_UsedCountry_ID=%s',
            [QuotedStr(cDefRollCLSID), IntToStr(AAction), QuotedStr(ABO.GetFieldValueAsString('ActQueue_ID')), QuotedStr(mCountryID)])
        else
          mSQL := Format('Select ID as dbvalue from DefRollData where Hidden=''N'' and CLSID=%s and X_SystemAction=%s and X_UsedActQueue_ID=%s and X_ActivityProcess_ID=%s and X_UsedCountry_ID=%s',
            [QuotedStr(cDefRollCLSID), IntToStr(AAction), QuotedStr(ABO.GetFieldValueAsString('ActQueue_ID')), QuotedStr(AProcessID), QuotedStr(mCountryID)]);

        mFound := GetSQLValuesAsStrings(ABO.ObjectSpace, mSQL, mStr);
        for i := 0 to mStr.Count - 1 do begin
          TrySendEmailCommon(ABO, mStr.Strings[i], mEmailAddress);
        end;
      end;
      if not mFound then begin //nyní definici bez země
        if NxIsBlank(AProcessID) then
          mSQL := Format('Select ID as dbvalue from DefRollData where Hidden=''N'' and CLSID=%s and X_SystemAction=%s and X_UsedActQueue_ID=%s and X_UsedCountry_ID is null',
            [QuotedStr(cDefRollCLSID), IntToStr(AAction)])
        else
          mSQL := Format('Select ID as dbvalue from DefRollData where Hidden=''N'' and CLSID=%s and X_SystemAction=%s and X_UsedActQueue_ID=%s and X_ActivityProcess_ID=%s and X_UsedCountry_ID is null',
            [QuotedStr(cDefRollCLSID), IntToStr(AAction), QuotedStr(ABO.GetFieldValueAsString('ActQueue_ID')), QuotedStr(AProcessID)]);
        mFound := GetSQLValuesAsStrings(ABO.ObjectSpace, mSQL, mStr);
        for i := 0 to mStr.Count - 1 do begin
          TrySendEmailCommon(ABO, mStr.Strings[i], mEmailAddress);
        end;
      end;
    finally
      mStr.Free;
    end;
  end;
end;


procedure ProcessChangePMState(ABO: TNxCustomBusinessObject; AAction: Integer; APMStateID: string);
var
  mSQL, mEmailAddress, mCountryID: string;
  mStr: TStrings;
  mFound, mResult: Boolean;
  i: integer;
begin
  mEmailAddress := GetEmailAddress(ABO);
  if not NxIsBlank(mEmailAddress) and (NxAt('@', mEmailAddress) > 0) then begin
    mStr := TStringList.Create;
    try
      mCountryID := GetCountryID(ABO.ObjectSpace, ABO.GetFieldValueAsString('Firm_ID.ResidenceAddress_ID.CountryCode'));

      if not NxIsEmptyOID(mCountryID) then begin //zkusíme definici se zemí
        mSQL := Format('Select ID as dbvalue from DefRollData where Hidden=''N'' and CLSID=%s and X_SystemAction=%s and X_UsedDocQueue_ID LIKE (' + QuotedStr('%%') + GetConcatChar + '%s' + GetConcatChar + QuotedStr('%%') + ') and X_PMState_ID=%s and X_UsedCountry_ID=%s',
          [QuotedStr(cDefRollCLSID), IntToStr(AAction), QuotedStr(ABO.GetFieldValueAsString('DocQueue_ID')), QuotedStr(APMStateID), QuotedStr(mCountryID)]);

        mFound := GetSQLValuesAsStrings(ABO.ObjectSpace, mSQL, mStr);
        for i := 0 to mStr.Count - 1 do begin
          TrySendEmailCommon(ABO, mStr.Strings[i], mEmailAddress);
        end;
      end;
      if not mFound then begin //nyní definici bez země
        mSQL := Format('Select ID as dbvalue from DefRollData where Hidden=''N'' and CLSID=%s and X_SystemAction=%s and X_UsedDocQueue_ID LIKE (' + QuotedStr('%%') + GetConcatChar + '%s' + GetConcatChar + QuotedStr('%%') + ') and X_PMState_ID=%s and X_UsedCountry_ID is null',
          [QuotedStr(cDefRollCLSID), IntToStr(AAction), QuotedStr(ABO.GetFieldValueAsString('DocQueue_ID')), QuotedStr(APMStateID)]);

        mFound := GetSQLValuesAsStrings(ABO.ObjectSpace, mSQL, mStr);
        for i := 0 to mStr.Count - 1 do begin
          TrySendEmailCommon(ABO, mStr.Strings[i], mEmailAddress);
        end;
      end;
    finally
      mStr.Free;
    end;
  end;
end;


procedure RegisterUser(ABO: TNxCustomBusinessObject; AAction: Integer; AEshopID: string);
var
  mSQL, mEmailAddress, mCountryID: string;
  mStr: TStrings;
  mFound, mResult: Boolean;
  i: integer;
begin
  mEmailAddress := GetEmailAddress(ABO);
  if not NxIsBlank(mEmailAddress) and (NxAt('@', mEmailAddress) > 0) then begin
    mStr := TStringList.Create;
    try
      mCountryID := GetCountryID(ABO.ObjectSpace, ABO.GetFieldValueAsString('Parent_ID.ResidenceAddress_ID.CountryCode'));
      if not NxIsEmptyOID(mCountryID) then begin //zkusíme definici se zemí
        if AEshopID = '' then
          mSQL := Format('Select ID as dbvalue from DefRollData where Hidden=''N'' and CLSID=%s and X_SystemAction=%s and X_UsedCountry_ID=%s',
            [QuotedStr(cDefRollCLSID), IntToStr(AAction), QuotedStr(mCountryID)])
        else
          mSQL := Format('Select ID as dbvalue from DefRollData where Hidden=''N'' and CLSID=%s and X_SystemAction=%s and X_UsedCountry_ID=%s and (X_EshopID=%s or X_EshopID is null or X_EshopID = ' + QuotedStr('') + ')',
            [QuotedStr(cDefRollCLSID), IntToStr(AAction), QuotedStr(mCountryID), QuotedStr(AEshopID)]);
        mFound := GetSQLValuesAsStrings(ABO.ObjectSpace, mSQL, mStr);
        for i := 0 to mStr.Count - 1 do begin
          TrySendEmailPerson(ABO, mStr.Strings[i], mEmailAddress);
        end;
      end;
      if not mFound then begin //nyní definici bez země
        if AEshopID = '' then
          mSQL := Format('Select ID as dbvalue from DefRollData where Hidden=''N'' and CLSID=%s and X_SystemAction=%s and X_UsedCountry_ID is null',
            [QuotedStr(cDefRollCLSID), IntToStr(AAction)])
        else
          mSQL := Format('Select ID as dbvalue from DefRollData where Hidden=''N'' and CLSID=%s and X_SystemAction=%s and X_UsedCountry_ID is null  and (X_EshopID=%s or X_EshopID is null or X_EshopID = ' + QuotedStr('') + ')',
            [QuotedStr(cDefRollCLSID), IntToStr(AAction), QuotedStr(AEshopID)]);

        mFound := GetSQLValuesAsStrings(ABO.ObjectSpace, mSQL, mStr);
        for i := 0 to mStr.Count - 1 do begin
          TrySendEmailPerson(ABO, mStr.Strings[i], mEmailAddress);
        end;
      end;
    finally
      mStr.Free;
    end;
  end;
end;

function TrySendEmailCommon(ABO: TNxCustomBusinessObject; ADefinitionID, AEmailAddress: string; AEdit: Boolean = false; ASite: TDynSiteForm = nil): boolean;
var
  mFileName, mOutputFileName, mEmlID: string;
  mSettingObj: TNxCustomBusinessObject;
begin
  result := false;
  if not NxIsEmptyOID(ADefinitionID) then begin
    mSettingObj := ABO.ObjectSpace.CreateObject(cDefRollCLSID);
    try
      mSettingObj.Load(ADefinitionID, nil);
      if EvalCondition(ABO, mSettingObj.GetFieldValueAsString('X_EmailCondition')) then begin
        if not NxIsEmptyOID(mSettingObj.GetFieldvalueAsString('X_AttachReport_ID')) then begin
          if mSettingObj.GetFieldValueAsInteger('X_AttachementFormat') = 0 then begin
            mFileName := NxSearchReplace(ABO.DisplayName, '/', '-', [srAll]) + '_' + ABO.OID + '.pdf';
            mOutputFileName := PrintDocToFile(ABO.ObjectSpace, ABO.OID, mSettingObj.GetFieldvalueAsString('X_AttachReport_ID'), mFileName, mSettingObj.GetFieldvalueAsString('X_AttachReport_ID.DataSource'), pekPDF);
          end else if mSettingObj.GetFieldValueAsInteger('X_AttachementFormat') = 1 then begin
            mFileName := NxSearchReplace(ABO.DisplayName, '/', '-', [srAll]) + '_' + ABO.OID + '.html';
            mOutputFileName := PrintDocToFile(ABO.ObjectSpace, ABO.OID, mSettingObj.GetFieldvalueAsString('X_AttachReport_ID'), mFileName, mSettingObj.GetFieldvalueAsString('X_AttachReport_ID.DataSource'), pekHTML);
          end;
        end else begin
          mFileName := '';
          mOutputFileName := '';
        end;
        mEmlID := CreateEmail(mSettingObj, ABO, AEmailAddress, mOutputFileName, AEdit, ASite);
        if not NxIsEmptyOID(mEmlID) then result := true;
        if mSettingObj.GetFieldValueAsBoolean('X_SendSMS') then SendSMS(ABO, mSettingObj.GetFieldValueAsString('X_SMSMessage'), mSettingObj.GetFieldValueAsInteger('X_SMSGate'), mSettingObj.GetFieldValueAsString('X_SMSUserName'), mSettingObj.GetFieldValueAsString('X_SMSPassword'), mSettingObj.GetFieldValueAsString('X_OwnVariableField'), mSettingObj.GetFieldValueAsString('X_ExternalScript'));
      end else AddDebugLog('Nevyhověla podmínka pro odeslání: ' + mSettingObj.GetFieldValueAsString('X_EmailCondition') + ' pro objekt: ' + ABO.DisplayName);
    finally
      mSettingObj.free;
    end;
  end;
end;


function TrySendEmailPerson(ABO: TNxCustomBusinessObject; ADefinitionID, AEmailAddress: string; AEdit: Boolean = false; ASite: TDynSiteForm = nil): boolean;
var
  mFileName, mOutputFileName, mEmlID: string;
  mSettingObj: TNxCustomBusinessObject;
begin
  result := false;
  if not NxIsEmptyOID(ADefinitionID) then begin
    mSettingObj := ABO.ObjectSpace.CreateObject(cDefRollCLSID);
    try
      mSettingObj.Load(ADefinitionID, nil);
      if EvalCondition(ABO, mSettingObj.GetFieldValueAsString('X_EmailCondition')) then begin
        if not NxIsEmptyOID(mSettingObj.GetFieldvalueAsString('X_AttachReport_ID')) then begin
          if mSettingObj.GetFieldValueAsInteger('X_AttachementFormat') = 0 then begin
            mFileName := NxSearchReplace(ABO.DisplayName, '/', '-', [srAll]) + '_' + ABO.OID + '.pdf';
            mOutputFileName := PrintDocToFile(ABO.ObjectSpace, ABO.GetFieldValueAsString('Person_ID'), mSettingObj.GetFieldvalueAsString('X_AttachReport_ID'), mFileName, mSettingObj.GetFieldvalueAsString('X_AttachReport_ID.DataSource'), pekPDF);
          end else if mSettingObj.GetFieldValueAsInteger('X_AttachementFormat') = 1 then begin
            mFileName := NxSearchReplace(ABO.DisplayName, '/', '-', [srAll]) + '_' + ABO.OID + '.html';
            mOutputFileName := PrintDocToFile(ABO.ObjectSpace, ABO.GetFieldValueAsString('Person_ID'), mSettingObj.GetFieldvalueAsString('X_AttachReport_ID'), mFileName, mSettingObj.GetFieldvalueAsString('X_AttachReport_ID.DataSource'), pekHTML);
          end;
        end else begin
          mFileName := '';
          mOutputFileName := '';
        end;
        CreateEmail(mSettingObj, ABO, AEmailAddress, mOutputFileName);
        if mSettingObj.GetFieldValueAsBoolean('X_SendSMS') then SendSMS(ABO, mSettingObj.GetFieldValueAsString('X_SMSMessage'), mSettingObj.GetFieldValueAsInteger('X_SMSGate'), mSettingObj.GetFieldValueAsString('X_SMSUserName'), mSettingObj.GetFieldValueAsString('X_SMSPassword'), mSettingObj.GetFieldValueAsString('X_OwnVariableField'), mSettingObj.GetFieldValueAsString('X_ExternalScript'));
      end else AddDebugLog('Nevyhověla podmínka pro odeslání: ' + mSettingObj.GetFieldValueAsString('X_EmailCondition'));
    finally
      mSettingObj.free;
    end;
  end;
end;


function EvalCondition(ABO: TNxCustomBusinessObject; ACondition: string): Boolean;
begin
  result := false;
  try
    if trim(ACondition) <> '' then
      result := NxEvalObjectExprAsBoolean(ABO, ACondition)
    else
      result := true;
  except
    AddDebugLog(ExceptionMessage);
  end;
end;


function GetEmailAddress(ABO: TNxCustomBusinessObject): string;
begin
  result := '';
  if ABO.CLSID in [Class_ReceivedOrder, Class_IssuedDepositInvoice, Class_OtherIncome, Class_IssuedInvoice, Class_CashReceived, Class_BillOfDelivery, Class_IssuedOffer, Class_IssuedOrder, Class_VATIssuedDepositInvoice, Class_CRMActivity, Class_IssuedCreditNote] then begin
    if ABO.GetFieldCode('X_ALTEMAIL') > 0 then
      result := ABO.GetFieldValueAsString('X_ALTEMAIL');
    if NxIsBlank(result) then
      result := ABO.GetFieldValueAsString('Person_ID.Address_ID.Email');
    if NxIsBlank(result) then
      result := ABO.GetFieldValueAsString('FirmOffice_ID.Address_ID.Email');
    if NxIsBlank(result) then
      result := ABO.GetFieldValueAsString('Firm_ID.ResidenceAddress_ID.Email');
  end;
  if (ABO.CLSID = Class_FirmPerson) then
    result := ABO.GetFieldValueAsString('Person_ID.Address_ID.EMail');
  if (ABO.CLSID = Class_PDMIssuedDoc) then begin
    if ABO.GetFieldCode('X_ALTEMAIL') > 0 then
      result := ABO.GetFieldValueAsString('X_ALTEMAIL');
    if NxIsBlank(result) then
      result := ABO.GetFieldValueAsString('TargetAddress_ID.EMail');
  end;
  if NxIsBlank(result) then
    AddDebugLog(Format('Pro objekt %s nenalezen e-mail', [ABO.DisplayName]));
end;

function GetPhoneNumber(ABO: TNxCustomBusinessObject): string;
begin
  result := '';
  if ABO.CLSID in [Class_ReceivedOrder, Class_IssuedDepositInvoice, Class_OtherIncome, Class_IssuedInvoice, Class_CashReceived, Class_BillOfDelivery, Class_IssuedOffer, Class_IssuedOrder, Class_VATIssuedDepositInvoice, Class_CRMActivity] then begin
    try
      result := ABO.GetFieldValueAsString('X_ALTPHONENUMBER1');
    except
      AddDebugLog(ExceptionMessage);
    end;
    if NxIsBlank(result) then
      result := ABO.GetFieldValueAsString('Person_ID.Address_ID.PhoneNumber1');
    if NxIsBlank(result) then
      result := ABO.GetFieldValueAsString('FirmOffice_ID.Address_ID.PhoneNumber1');
    if NxIsBlank(result) then
      result := ABO.GetFieldValueAsString('Firm_ID.ResidenceAddress_ID.PhoneNumber1');
  end;
  if (ABO.CLSID = Class_FirmPerson) then
    result := ABO.GetFieldValueAsString('Person_ID.Address_ID.PhoneNumber1');
  if (ABO.CLSID = Class_PDMIssuedDoc) then
    result := ABO.GetFieldValueAsString('TargetAddress_ID.PhoneNumber1');
end;

function CreateEmail(ASettingsObj, ASendObj: TNxCustomBusinessObject; AEmailAddress, AAttachementFile: string; AEditEmail: boolean = false; ASite: TDynSiteForm = nil): string;
var
  mObj, mRec: TNxCustomBusinessObject;
  mAttachements: TStrings;
  i, j: Integer;
  mEmailCopy, mSubject, mOwnVariableField, mEmailReply: string;
  mEmailCopyExpr, mHiddenEmailCopyExpr: string;
  mBody: TStrings;
begin
  result := '';
  mObj := ASettingsObj.ObjectSpace.CreateObject(Class_EmailSent);
  mBody := TStringList.Create;
  try
    mObj.New;
    mObj.Prefill;
    mObj.SetFieldValueAsString('EmailAccount_ID', ASettingsObj.GetFieldValueAsString('X_OwnEmailAccount_ID'));
    mSubject := ASettingsObj.GetFieldValueAsString('X_EmailSubject');
    mOwnVariableField := ASettingsObj.GetFieldValueAsString('X_OwnVariableField');
    ProcessText(mSubject, '', ASendObj, AEmailAddress, mOwnVariableField, ASettingsObj.GetFieldValueAsString('X_ExternalScript'));
    mObj.SetFieldValueAsString('Subject', mSubject);
    mBody.Add(ASettingsObj.GetFieldValueAsString('X_EmailBody'));
    ProcessText(mBody.Text, ASettingsObj.GetFieldValueAsString('X_EmailRows'), ASendObj, AEmailAddress, mOwnVariableField, ASettingsObj.GetFieldValueAsString('X_ExternalScript'));
    mObj.SetFieldValueAsInteger('BodySavedAs', ASettingsObj.GetFieldValueAsInteger('X_EmailFormat'));
    if (ASettingsObj.GetFieldValueAsInteger('X_EmailFormat') = 0) then
      mObj.SetFieldValueAsString('Body', mBody.Text);
    mObj.SetFieldValueAsInteger('SentState', 1);
    mObj.SetFieldValueAsBoolean('AddSentIdent', False);

    if ASendObj.CLSID = Class_FirmPerson then
      mObj.SetFieldValueAsString('Firm_ID', ASendObj.GetFieldValueAsString('Parent_ID'))
    else begin
      mObj.SetFieldValueAsString('Firm_ID', ASendObj.GetFieldValueAsString('Firm_ID'));
      mObj.SetFieldValueAsString('FirmOffice_ID', ASendObj.GetFieldValueAsString('FirmOffice_ID'));
      mObj.SetFieldValueAsString('Person_ID', ASendObj.GetFieldValueAsString('Person_ID'));
    end;

    mRec := mObj.GetCollectionMonikerForFieldCode(mObj.GetFieldCode('Recipients')).AddNewObject;
    mRec.SetFieldValueAsInteger('EmailType', 0);
    mRec.SetFieldValueAsString('Email', AEmailAddress);

    if not NxIsBlank(ASettingsObj.GetFieldValueAsString('X_EmailAddressCopy')) then begin
      if ASettingsObj.GetFieldValueAsBoolean('X_EmailAddressCopyByExpr') then
        mEmailCopyExpr := NxEvalObjectExprAsString(ASendObj, ASettingsObj.GetFieldValueAsString('X_EmailAddressCopy'))
      else
        mEmailCopyExpr := ASettingsObj.GetFieldValueAsString('X_EmailAddressCopy');

      if NxIsBlank(mEmailCopyExpr) = false then begin
        mRec := mObj.GetCollectionMonikerForFieldCode(mObj.GetFieldCode('Recipients')).AddNewObject;
        mRec.SetFieldValueAsInteger('EmailType', 1);
        mRec.SetFieldValueAsString('Email', mEmailCopyExpr);
      end;
    end;

    if not NxIsBlank(ASettingsObj.GetFieldValueAsString('X_HiddenEmailAddressCopy')) then begin
      if ASettingsObj.GetFieldValueAsBoolean('X_HiddenEmailAddressCopyByExpr') then
        mHiddenEmailCopyExpr := NxEvalObjectExprAsString(ASendObj, ASettingsObj.GetFieldValueAsString('X_HiddenEmailAddressCopy'))
      else
        mHiddenEmailCopyExpr := ASettingsObj.GetFieldValueAsString('X_HiddenEmailAddressCopy');

      if NxIsBlank(mHiddenEmailCopyExpr) = false then begin
        mRec := mObj.GetCollectionMonikerForFieldCode(mObj.GetFieldCode('Recipients')).AddNewObject;
        mRec.SetFieldValueAsInteger('EmailType', 2);
        mRec.SetFieldValueAsString('Email', mHiddenEmailCopyExpr);
      end;
    end;

    //kopie na zakázku
    if ASettingsObj.GetFieldValueAsBoolean('X_SendCopyBusOrderEmail') = true then begin
      mEmailCopy := GetFirstRowEmail(ASendObj, Class_BusOrder);
      if mEmailCopy <> '' then begin
        mRec := mObj.GetCollectionMonikerForFieldCode(mObj.GetFieldCode('Recipients')).AddNewObject;
        mRec.SetFieldValueAsInteger('EmailType', 1);
        mRec.SetFieldValueAsString('Email', mEmailCopy);
      end;
    end;

    //kopie na obch. případ
    if ASettingsObj.GetFieldValueAsBoolean('X_SendCopyBusTransactionEmail') = true then begin
      mEmailCopy := GetFirstRowEmail(ASendObj, Class_BusTransaction);
      if mEmailCopy <> '' then begin
        mRec := mObj.GetCollectionMonikerForFieldCode(mObj.GetFieldCode('Recipients')).AddNewObject;
        mRec.SetFieldValueAsInteger('EmailType', 1);
        mRec.SetFieldValueAsString('Email', mEmailCopy);
      end;
    end;

    //kopie na projekt
    if ASettingsObj.GetFieldValueAsBoolean('X_SendCopyBusProjectEmail') = true then begin
      mEmailCopy := GetFirstRowEmail(ASendObj, Class_BusProject);
      if mEmailCopy <> '' then begin
        mRec := mObj.GetCollectionMonikerForFieldCode(mObj.GetFieldCode('Recipients')).AddNewObject;
        mRec.SetFieldValueAsInteger('EmailType', 1);
        mRec.SetFieldValueAsString('Email', mEmailCopy);
      end;
    end;

    //kopie na sklad
    if ASettingsObj.GetFieldValueAsBoolean('X_SendCopyStoreEmail') = true then begin
      if ASendObj.CLSID <> Class_VATIssuedDepositInvoice then begin
        mEmailCopy := GetFirstRowEmail(ASendObj, Class_Store);
        if mEmailCopy <> '' then begin
          mRec := mObj.GetCollectionMonikerForFieldCode(mObj.GetFieldCode('Recipients')).AddNewObject;
          mRec.SetFieldValueAsInteger('EmailType', 1);
          mRec.SetFieldValueAsString('Email', mEmailCopy);
        end;
      end;
    end;

    //odpovědi na email skladu
    if ASettingsObj.GetFieldValueAsBoolean('X_ReplyToStoreEmail') = true then begin
      if ASendObj.CLSID <> Class_VATIssuedDepositInvoice then begin
        mEmailReply := GetFirstRowEmail(ASendObj, Class_Store);
        if mEmailReply <> '' then begin
          mObj.SetFieldValueAsString('ReplyTo', mEmailReply);
        end;
      end;
    end;

    if not NxIsBlank(AAttachementFile) then begin
      if FileExists(AAttachementFile) then
        TnxEmailSent(mObj).AttachFile(AAttachementFile);
    end;

    mAttachements := TStringList.Create;
    try
      //pole napevno
      mAttachements.Text := ASettingsObj.GetFieldValueAsString('X_AttachFiles');
      for i := 0 to mAttachements.Count - 1 do begin
        if FileExists(mAttachements.Strings[i]) then
          TNxEmailSent(mObj).AttachFile(mAttachements.Strings[i]);
      end;

      //dle X_ položky
      if NxIsBlank(ASettingsObj.GetFieldValueAsString('X_AttachFilesFieldName')) = false then begin
        mAttachements.Text := ASendObj.GetFieldValueAsString(ASettingsObj.GetFieldValueAsString('X_AttachFilesFieldName'));
        for i := 0 to mAttachements.Count - 1 do begin
          if FileExists(mAttachements.Strings[i]) then
            TNxEmailSent(mObj).AttachFile(mAttachements.Strings[i]);
        end;
      end;

    finally
      mAttachements.Free;
    end;

    if ASettingsObj.GetFieldValueAsBoolean('X_AttachDocuments') then
      AttachDocuments(ASendObj, mObj);


    if not AEditEmail then begin
      mObj.save;
      if ASettingsObj.GetFieldValueAsInteger('X_EmailFormat') = 1 then begin
        if Length(mBody.Text) < GetMaxStringLength then
          ASendObj.ObjectSpace.SQLExecute('Update EmailsSent set Body=' + QuotedStr(mBody.Text) + ' where ID=' + QuotedStr(mObj.OID))
        else begin
          for j := 0 to mBody.Count - 1 do begin
            ASendObj.ObjectSpace.SQLExecute('Update EmailsSent set Body=Body ' + GetConcatChar + QuotedStr(mBody.Strings[j]) + ' where ID=' + QuotedStr(mObj.OID));
          end;
        end;
      end;

      if ASettingsObj.GetFieldValueAsInteger('X_EmailSendTime') = 0 then
        TNxEmailSent(mObj).SendMail;
      result := mObj.OID;
    end else begin
      mObj.SetFieldValueAsInteger('BodySavedAs', ASettingsObj.GetFieldValueAsInteger('X_EmailFormat'));
      mObj.SetFieldValueAsString('Body', mBody.Text);

      ASite.ShowDynFormWithNewDocument('KJAGOM3EAOI45GTB45MXJQTD0S', NxCreateContext_1(mObj), mObj);
      if not (osNew in mObj.State) then //podle stavu obbjektu poznáme, jestli jej uživatel uložil
        result := mObj.OID
      else
        result := '';
    end;
  finally
    mObj.free;
    mBody.Free;
    if not NxIsBlank(AAttachementFile) then
      DeleteFile(AAttachementFile);
  end;
end;

//vrátí e-mail z prvního řádku

function GetFirstRowEmail(ASendObj: TNxCustomBusinessObject; AClass: string): string;
var
  mMonikerColl: TNxCustomBusinessMonikerCollection;
  mObjList: TObjectList;

begin
  result := '';
  if ASendObj.GetFieldCode('Rows') > 0 then begin //jedná se o objekt s řádky
    mMonikerColl := ASendObj.GetLoadedCollectionMonikerForFieldCode(ASendObj.GetFieldCode('Rows'));
    if mMonikerColl.Count > 0 then begin
      mObjList := TObjectList.Create;
      try
        mObjList.OwnsObjects := False;
        mMonikerColl.FillBusinesObjectListByPosition(mObjList);
        if AClass = Class_BusOrder then
          result := TNxCustomBusinessObject(mObjList.Items[0]).GetFieldValueAsString('BusOrder_ID.X_Email');
        if AClass = Class_BusTransaction then
          result := TNxCustomBusinessObject(mObjList.Items[0]).GetFieldValueAsString('BusTransaction_ID.X_Email');
        if AClass = Class_BusProject then
          result := TNxCustomBusinessObject(mObjList.Items[0]).GetFieldValueAsString('BusProject_ID.X_Email');
        if AClass = Class_Store then
          result := TNxCustomBusinessObject(mObjList.Items[0]).GetFieldValueAsString('Store_ID.Address_ID.Email');
      finally
        mObjList.free;
      end;
    end;
  end;
end;


//vrátí e-mail z prvního řádku

function GetDocFirstRowValue(ASendObj: TNxCustomBusinessObject; AValue: string): string;
var
  mMonikerColl: TNxCustomBusinessMonikerCollection;
  mObjList: TObjectList;

begin
  result := '';
  if ASendObj.GetFieldCode('Rows') > 0 then begin //jedná se o objekt s řádky
    mMonikerColl := ASendObj.GetLoadedCollectionMonikerForFieldCode(ASendObj.GetFieldCode('Rows'));
    if mMonikerColl.Count > 0 then begin
      mObjList := TObjectList.Create;
      try
        mObjList.OwnsObjects := False;
        mMonikerColl.FillBusinesObjectListByPosition(mObjList);
        result := TNxCustomBusinessObject(mObjList.Items[0]).GetFieldValueAsString(AValue);
      finally
        mObjList.free;
      end;
    end;
  end;
end;

//zjistí, jestli je kompletně vyplněná volná adresa
//AType-1 = fakturační, AType-2 = dodací

function GetIsFreeAddressComplete(ABO: TNxCustomBusinessObject; AType: integer): boolean;
begin
  result := true;
  if AType = 1 then begin
    if NxIsBlank(ABO.GetFieldValueAsString('X_ALTCITY'))
      or NxIsBlank(ABO.GetFieldValueAsString('X_ALTSTREET'))
      or NxIsBlank(ABO.GetFieldValueAsString('X_ALTPOSTCODE'))
      or NxIsBlank(ABO.GetFieldValueAsString('X_ALTCOUNTRY'))
      then result := false;
  end else if AType = 2 then begin
    if NxIsBlank(ABO.GetFieldValueAsString('X_ALTCITY2'))
      or NxIsBlank(ABO.GetFieldValueAsString('X_ALTSTREET2'))
      or NxIsBlank(ABO.GetFieldValueAsString('X_ALTPOSTCODE2'))
      //ALTCOUNTRY2 netestujeme, je prázdná, musí být stejná jako ALTCOUNTRY
    or NxIsBlank(ABO.GetFieldValueAsString('X_ALTCOUNTRY'))
      then result := false;
  end;
end;

procedure ProcessText(var AText: string; ARowsText: string; ABO: TNxCustomBusinessObject; AEmail, AOwnVariableField, AExternalScript: string);
var mTOStateText: string;
  mTOState: integer;
  mWithXFields: Boolean;
  mCountryName: string;
  mRowsText: string;
  mBillRowsAmountWIV: double;
  mReceivedOrderID: string;
begin
  mBillRowsAmountWIV := 0;
  mReceivedOrderID := '';

  if ABO.CLSID in [Class_IssuedOrder, Class_VATIssuedDepositInvoice, Class_CRMActivity, Class_PDMIssuedDoc] then
    mWithXFields := false
  else
    mWithXFields := true;

  //pouze OP
  if ABO.CLSID in [Class_ReceivedOrder] then begin
    AText := NxSearchReplace(AText, '<!--RO_HASH_SHA1//-->', HashString(ABO.GetFieldValueAsString('Firm_ID'), ABO.OID, halg_SHA1), [srAll]);
    AText := NxSearchReplace(AText, '<!--RO_HASH_SHA256//-->', HashString(ABO.GetFieldValueAsString('Firm_ID'), ABO.OID, halg_SHA256), [srAll]);
    AText := NxSearchReplace(AText, '<!--RO_HASH_SHA384//-->', HashString(ABO.GetFieldValueAsString('Firm_ID'), ABO.OID, halg_SHA384), [srAll]);
    AText := NxSearchReplace(AText, '<!--RO_HASH_SHA512//-->', HashString(ABO.GetFieldValueAsString('Firm_ID'), ABO.OID, halg_SHA512), [srAll]);
    AText := NxSearchReplace(AText, '<!--RO_HASH_MD5//-->', HashString(ABO.GetFieldValueAsString('Firm_ID'), ABO.OID, halg_MD5), [srAll]);
    AText := NxSearchReplace(AText, '<!--RO_ID//-->', ABO.OID, [srAll]);
  end;

  //pouze FV
  if ABO.CLSID = Class_IssuedInvoice then begin
    if (ABO.GetFieldCode('X_TRACKING_NUMBER') > 0) and (NxIsBlank(ABO.GetFieldValueAsString('TransportationType_ID.X_Tracking_URL')) = false) then
      AText := NxSearchReplace(AText, '<!--TRACKING_URL//-->', CFxInternet.URLEncode(Format(ABO.GetFieldValueAsString('TransportationType_ID.X_Tracking_URL'), [ABO.GetFieldValueAsString('X_TRACKING_NUMBER')])), [srAll]);
  end;

  //pouze ZL a FV
  if ABO.CLSID in [Class_IssuedDepositInvoice, Class_IssuedInvoice] then begin
    AText := NxSearchReplace(AText, '<!--VARSYMBOL//-->', ABO.GetFieldValueAsString('VARSYMBOL'), [srAll])
  end;

  //ZL + FV + OP
  if ABO.CLSID in [Class_IssuedDepositInvoice, Class_IssuedInvoice, Class_ReceivedOrder] then begin
    AText := NxSearchReplace(AText, '<!--BANKACCOUNT//-->', ABO.GetFieldValueAsString('BankAccount_ID.BankAccount'), [srAll]);
  end;

  //ZL + OP + FV + PP + DL + NV + DV
  if ABO.CLSID in [Class_ReceivedOrder, Class_IssuedDepositInvoice, Class_IssuedInvoice, Class_CashReceived, Class_BillOfDelivery, Class_IssuedOffer, Class_IssuedOrder, Class_VATIssuedDepositInvoice, Class_CRMActivity, Class_IssuedCreditNote, Class_PDMIssuedDoc] then begin
    AText := NxSearchReplace(AText, '<!--EMAIL//-->', AEmail, [srAll]);

    if mWithXFields and not NxIsBlank(ABO.GetFieldValueAsString('X_ALTFIRM')) then
      AText := NxSearchReplace(AText, '<!--FIRM_NAME//-->', ABO.GetFieldValueAsString('X_ALTFIRM'), [srAll])
    else
      AText := NxSearchReplace(AText, '<!--FIRM_NAME//-->', ABO.GetFieldValueAsString('Firm_ID.Name'), [srAll]);

    if mWithXFields and GetIsFreeAddressComplete(ABO, 1) then
      AText := NxSearchReplace(AText, '<!--FIRM_ADDRESS_CITY//-->', ABO.GetFieldValueAsString('X_ALTCITY'), [srAll])
    else
      AText := NxSearchReplace(AText, '<!--FIRM_ADDRESS_CITY//-->', ABO.GetFieldValueAsString('Firm_ID.ResidenceAddress_ID.City'), [srAll]);

    if mWithXFields and GetIsFreeAddressComplete(ABO, 1) then
      AText := NxSearchReplace(AText, '<!--FIRM_ADDRESS_STREET//-->', ABO.GetFieldValueAsString('X_ALTSTREET'), [srAll])
    else
      AText := NxSearchReplace(AText, '<!--FIRM_ADDRESS_STREET//-->', ABO.GetFieldValueAsString('Firm_ID.ResidenceAddress_ID.Street'), [srAll]);

    if mWithXFields and GetIsFreeAddressComplete(ABO, 1) then
      AText := NxSearchReplace(AText, '<!--FIRM_ADDRESS_POSTCODE//-->', ABO.GetFieldValueAsString('X_ALTPOSTCODE'), [srAll])
    else
      AText := NxSearchReplace(AText, '<!--FIRM_ADDRESS_POSTCODE//-->', ABO.GetFieldValueAsString('Firm_ID.ResidenceAddress_ID.PostCode'), [srAll]);

    mCountryName := '';
    if mWithXFields and GetIsFreeAddressComplete(ABO, 1) then begin
      mCountryName := ABO.GetFieldValueAsString('X_ALTCOUNTRY');
      AText := NxSearchReplace(AText, '<!--FIRM_ADDRESS_COUNTRY//-->', mCountryName, [srAll]);
      AText := NxSearchReplace(AText, '<!--FIRM_ADDRESS_COUNTRY_CS//-->', mCountryName, [srAll]);
      AText := NxSearchReplace(AText, '<!--FIRM_ADDRESS_COUNTRY_SK//-->', mCountryName, [srAll]);
      AText := NxSearchReplace(AText, '<!--FIRM_ADDRESS_COUNTRY_ENUS//-->', mCountryName, [srAll]);
      AText := NxSearchReplace(AText, '<!--FIRM_ADDRESS_COUNTRY_DE//-->', mCountryName, [srAll]);
      AText := NxSearchReplace(AText, '<!--FIRM_ADDRESS_COUNTRY_HU//-->', mCountryName, [srAll]);
    end else begin
      mCountryName := ABO.GetFieldValueAsString('Firm_ID.ResidenceAddress_ID.Country');
      AText := NxSearchReplace(AText, '<!--FIRM_ADDRESS_COUNTRY//-->', mCountryName, [srAll]);
    end;
    ReplaceCountryMutations(ABO.ObjectSpace, AText, 'FIRM_ADDRESS_COUNTRY', mCountryName);

    if mWithXFields and not NxIsBlank(ABO.GetFieldValueAsString('X_ALTORGIDENTNUMBER')) then
      AText := NxSearchReplace(AText, '<!--FIRM_ORGIDENTNUMBER//-->', ABO.GetFieldValueAsString('X_ALTORGIDENTNUMBER'), [srAll])
    else
      AText := NxSearchReplace(AText, '<!--FIRM_ORGIDENTNUMBER//-->', ABO.GetFieldValueAsString('Firm_ID.OrgIdentNumber'), [srAll]);

    if mWithXFields and not NxIsBlank(ABO.GetFieldValueAsString('X_ALTVATIDENTNUMBER')) then
      AText := NxSearchReplace(AText, '<!--FIRM_VATIDENTNUMBER//-->', ABO.GetFieldValueAsString('X_ALTVATIDENTNUMBER'), [srAll])
    else
      AText := NxSearchReplace(AText, '<!--FIRM_VATIDENTNUMBER//-->', ABO.GetFieldValueAsString('Firm_ID.VatIdentNumber'), [srAll]);


    if mWithXFields and GetIsFreeAddressComplete(ABO, 2) then
      AText := NxSearchReplace(AText, '<!--FIRMOFFICE_ADDRESS_CITY//-->', ABO.GetFieldValueAsString('X_ALTCITY2'), [srAll])
    else
      AText := NxSearchReplace(AText, '<!--FIRMOFFICE_ADDRESS_CITY//-->', ABO.GetFieldValueAsString('FirmOffice_ID.Address_ID.City'), [srAll]);

    if mWithXFields and GetIsFreeAddressComplete(ABO, 2) then
      AText := NxSearchReplace(AText, '<!--FIRMOFFICE_ADDRESS_STREET//-->', ABO.GetFieldValueAsString('X_ALTSTREET2'), [srAll])
    else
      AText := NxSearchReplace(AText, '<!--FIRMOFFICE_ADDRESS_STREET//-->', ABO.GetFieldValueAsString('FirmOffice_ID.Address_ID.Street'), [srAll]);

    if mWithXFields and GetIsFreeAddressComplete(ABO, 2) then
      AText := NxSearchReplace(AText, '<!--FIRMOFFICE_ADDRESS_POSTCODE//-->', ABO.GetFieldValueAsString('X_ALTPOSTCODE2'), [srAll])
    else
      AText := NxSearchReplace(AText, '<!--FIRMOFFICE_ADDRESS_POSTCODE//-->', ABO.GetFieldValueAsString('FirmOffice_ID.Address_ID.PostCode'), [srAll]);

    mCountryName := '';
    if mWithXFields and GetIsFreeAddressComplete(ABO, 2) then begin
      mCountryName := ABO.GetFieldValueAsString('X_ALTCOUNTRY'); {Zde nelze pouzit X_ALTCOUNTRY2, protoze se nevyplnuje - fakturacni a dodaci zeme musi byt vzdy stejna}
      AText := NxSearchReplace(AText, '<!--FIRMOFFICE_ADDRESS_COUNTRY//-->', mCountryName, [srAll]);
      AText := NxSearchReplace(AText, '<!--FIRMOFFICE_ADDRESS_COUNTRY_CS//-->', mCountryName, [srAll]);
      AText := NxSearchReplace(AText, '<!--FIRMOFFICE_ADDRESS_COUNTRY_SK//-->', mCountryName, [srAll]);
      AText := NxSearchReplace(AText, '<!--FIRMOFFICE_ADDRESS_COUNTRY_ENUS//-->', mCountryName, [srAll]);
      AText := NxSearchReplace(AText, '<!--FIRMOFFICE_ADDRESS_COUNTRY_DE//-->', mCountryName, [srAll]);
      AText := NxSearchReplace(AText, '<!--FIRMOFFICE_ADDRESS_COUNTRY_HU//-->', mCountryName, [srAll]);
    end else begin
      mCountryName := ABO.GetFieldValueAsString('FirmOffice_ID.Address_ID.Country');
      AText := NxSearchReplace(AText, '<!--FIRMOFFICE_ADDRESS_COUNTRY//-->', mCountryName, [srAll]);
    end;
    ReplaceCountryMutations(ABO.ObjectSpace, AText, 'FIRMOFFICE_ADDRESS_COUNTRY', mCountryName);



    if mWithXFields and not NxIsBlank(ABO.GetFieldValueAsString('X_ALTPHONENUMBER1')) then
      AText := NxSearchReplace(AText, '<!--PERSON_ADDRESS_PHONENUMBER1//-->', ABO.GetFieldValueAsString('X_ALTPHONENUMBER1'), [srAll])
    else
      AText := NxSearchReplace(AText, '<!--PERSON_ADDRESS_PHONENUMBER1//-->', ABO.GetFieldValueAsString('Person_ID.Address_ID.PhoneNumber1'), [srAll]);

    if mWithXFields and not NxIsBlank(ABO.GetFieldValueAsString('X_ALTPHONENUMBER2')) then
      AText := NxSearchReplace(AText, '<!--PERSON_ADDRESS_PHONENUMBER2//-->', ABO.GetFieldValueAsString('X_ALTPHONENUMBER2'), [srAll])
    else
      AText := NxSearchReplace(AText, '<!--PERSON_ADDRESS_PHONENUMBER2//-->', ABO.GetFieldValueAsString('Person_ID.Address_ID.PhoneNumber2'), [srAll]);

    if mWithXFields and not NxIsBlank(ABO.GetFieldValueAsString('X_ALTEMAIL')) then
      AText := NxSearchReplace(AText, '<!--PERSON_ADDRESS_EMAIL//-->', ABO.GetFieldValueAsString('X_ALTEMAIL'), [srAll])
    else
      AText := NxSearchReplace(AText, '<!--PERSON_ADDRESS_EMAIL//-->', ABO.GetFieldValueAsString('Person_ID.Address_ID.Email'), [srAll]);


    if mWithXFields and not NxIsBlank(ABO.GetFieldValueAsString('X_ALTFIRSTNAME') + ABO.GetFieldValueAsString('X_ALTLASTNAME')) then
      AText := NxSearchReplace(AText, '<!--PERSON_FIRST_NAME//-->', ABO.GetFieldValueAsString('X_ALTFIRSTNAME'), [srAll])
    else
      AText := NxSearchReplace(AText, '<!--PERSON_FIRST_NAME//-->', ABO.GetFieldValueAsString('Person_ID.FirstName'), [srAll]);

    if mWithXFields and not NxIsBlank(ABO.GetFieldValueAsString('X_ALTFIRSTNAME') + ABO.GetFieldValueAsString('X_ALTLASTNAME')) then
      AText := NxSearchReplace(AText, '<!--PERSON_LAST_NAME//-->', ABO.GetFieldValueAsString('X_ALTLASTNAME'), [srAll])
    else
      AText := NxSearchReplace(AText, '<!--PERSON_LAST_NAME//-->', ABO.GetFieldValueAsString('Person_ID.LastName'), [srAll]);

    if mWithXFields and NxIsBlank(ABO.GetFieldValueAsString('X_ALTFIRSTNAME') + ABO.GetFieldValueAsString('X_ALTLASTNAME')) then
      AText := NxSearchReplace(AText, '<!--PERSON_TITLE//-->', ABO.GetFieldValueAsString('Person_ID.Title'), [srAll])
    else
      AText := NxSearchReplace(AText, '<!--PERSON_TITLE//-->', '', [srAll]);

    if ABO.CLSID in [Class_CashReceived, Class_CRMActivity, Class_IssuedOrder, Class_VATIssuedDepositInvoice, Class_PDMIssuedDoc] = false then begin
      try
        if not NxIsBlank(ABO.GetFieldValueAsString('TransportationType_ID.X_Name_CS')) then
          AText := NxSearchReplace(AText, '<!--TRANSPORTATIONTYPE_NAME_CS//-->', ABO.GetFieldValueAsString('TransportationType_ID.X_Name_CS'), [srAll])
        else
          AText := NxSearchReplace(AText, '<!--TRANSPORTATIONTYPE_NAME_CS//-->', ABO.GetFieldValueAsString('TransportationType_ID.Name'), [srAll]);

        if not NxIsBlank(ABO.GetFieldValueAsString('TransportationType_ID.X_Name_SK')) then
          AText := NxSearchReplace(AText, '<!--TRANSPORTATIONTYPE_NAME_SK//-->', ABO.GetFieldValueAsString('TransportationType_ID.X_Name_SK'), [srAll])
        else
          AText := NxSearchReplace(AText, '<!--TRANSPORTATIONTYPE_NAME_SK//-->', ABO.GetFieldValueAsString('TransportationType_ID.Name'), [srAll]);

        if not NxIsBlank(ABO.GetFieldValueAsString('TransportationType_ID.X_Name_DE')) then
          AText := NxSearchReplace(AText, '<!--TRANSPORTATIONTYPE_NAME_DE//-->', ABO.GetFieldValueAsString('TransportationType_ID.X_Name_DE'), [srAll])
        else
          AText := NxSearchReplace(AText, '<!--TRANSPORTATIONTYPE_NAME_DE//-->', ABO.GetFieldValueAsString('TransportationType_ID.Name'), [srAll]);

        if not NxIsBlank(ABO.GetFieldValueAsString('TransportationType_ID.X_Name_ENUS')) then
          AText := NxSearchReplace(AText, '<!--TRANSPORTATIONTYPE_NAME_ENUS//-->', ABO.GetFieldValueAsString('TransportationType_ID.X_Name_ENUS'), [srAll])
        else
          AText := NxSearchReplace(AText, '<!--TRANSPORTATIONTYPE_NAME_ENUS//-->', ABO.GetFieldValueAsString('TransportationType_ID.Name'), [srAll]);

        if not NxIsBlank(ABO.GetFieldValueAsString('TransportationType_ID.X_Note_CS')) then
          AText := NxSearchReplace(AText, '<!--TRANSPORTATIONTYPE_NOTE_CS//-->', ABO.GetFieldValueAsString('TransportationType_ID.X_Note_CS'), [srAll]);

        if not NxIsBlank(ABO.GetFieldValueAsString('TransportationType_ID.X_Note_SK')) then
          AText := NxSearchReplace(AText, '<!--TRANSPORTATIONTYPE_NOTE_SK//-->', ABO.GetFieldValueAsString('TransportationType_ID.X_Note_SK'), [srAll]);

        if not NxIsBlank(ABO.GetFieldValueAsString('TransportationType_ID.X_Note_DE')) then
          AText := NxSearchReplace(AText, '<!--TRANSPORTATIONTYPE_NOTE_DE//-->', ABO.GetFieldValueAsString('TransportationType_ID.X_Note_DE'), [srAll]);

        if not NxIsBlank(ABO.GetFieldValueAsString('TransportationType_ID.X_Note_ENUS')) then
          AText := NxSearchReplace(AText, '<!--TRANSPORTATIONTYPE_NOTE_ENUS//-->', ABO.GetFieldValueAsString('TransportationType_ID.X_Note_ENUS'), [srAll])
      except
        AddDebugLog(ExceptionMessage);
      end;
    end;

    if ABO.CLSID in [Class_BillOfDelivery, Class_CashReceived, Class_CRMActivity, Class_IssuedOrder, Class_VATIssuedDepositInvoice, Class_PDMIssuedDoc] = false then begin
      try
        if not NxIsBlank(ABO.GetFieldValueAsString('PaymentType_ID.X_Name_CS')) then
          AText := NxSearchReplace(AText, '<!--PAYMENTTYPE_NAME_CS//-->', ABO.GetFieldValueAsString('PaymentType_ID.X_Name_CS'), [srAll])
        else
          AText := NxSearchReplace(AText, '<!--PAYMENTTYPE_NAME_CS//-->', ABO.GetFieldValueAsString('PaymentType_ID.Name'), [srAll]);

        if not NxIsBlank(ABO.GetFieldValueAsString('PaymentType_ID.X_Name_SK')) then
          AText := NxSearchReplace(AText, '<!--PAYMENTTYPE_NAME_SK//-->', ABO.GetFieldValueAsString('PaymentType_ID.X_Name_SK'), [srAll])
        else
          AText := NxSearchReplace(AText, '<!--PAYMENTTYPE_NAME_SK//-->', ABO.GetFieldValueAsString('PaymentType_ID.Name'), [srAll]);

        if not NxIsBlank(ABO.GetFieldValueAsString('PaymentType_ID.X_Name_DE')) then
          AText := NxSearchReplace(AText, '<!--PAYMENTTYPE_NAME_DE//-->', ABO.GetFieldValueAsString('PaymentType_ID.X_Name_DE'), [srAll])
        else
          AText := NxSearchReplace(AText, '<!--PAYMENTTYPE_NAME_DE//-->', ABO.GetFieldValueAsString('PaymentType_ID.Name'), [srAll]);

        if not NxIsBlank(ABO.GetFieldValueAsString('PaymentType_ID.X_Name_ENUS')) then
          AText := NxSearchReplace(AText, '<!--PAYMENTTYPE_NAME_ENUS//-->', ABO.GetFieldValueAsString('PaymentType_ID.X_Name_ENUS'), [srAll])
        else
          AText := NxSearchReplace(AText, '<!--PAYMENTTYPE_NAME_ENUS//-->', ABO.GetFieldValueAsString('PaymentType_ID.Name'), [srAll]);

        if not NxIsBlank(ABO.GetFieldValueAsString('PaymentType_ID.X_Note_CS')) then
          AText := NxSearchReplace(AText, '<!--PAYMENTTYPE_NOTE_CS//-->', ABO.GetFieldValueAsString('PaymentType_ID.X_Note_CS'), [srAll])
        else
          AText := NxSearchReplace(AText, '<!--PAYMENTTYPE_NAME_CS//-->', ABO.GetFieldValueAsString('PaymentType_ID.Name'), [srAll]);

        if not NxIsBlank(ABO.GetFieldValueAsString('PaymentType_ID.X_Note_CS')) then
          AText := NxSearchReplace(AText, '<!--PAYMENTTYPE_NOTE_CS//-->', ABO.GetFieldValueAsString('PaymentType_ID.X_Note_CS'), [srAll]);

        if not NxIsBlank(ABO.GetFieldValueAsString('PaymentType_ID.X_Note_SK')) then
          AText := NxSearchReplace(AText, '<!--PAYMENTTYPE_NOTE_SK//-->', ABO.GetFieldValueAsString('PaymentType_ID.X_Note_SK'), [srAll]);

        if not NxIsBlank(ABO.GetFieldValueAsString('PaymentType_ID.X_Note_DE')) then
          AText := NxSearchReplace(AText, '<!--PAYMENTTYPE_NOTE_DE//-->', ABO.GetFieldValueAsString('PaymentType_ID.X_Note_DE'), [srAll]);

        if not NxIsBlank(ABO.GetFieldValueAsString('PaymentType_ID.X_Note_ENUS')) then
          AText := NxSearchReplace(AText, '<!--PAYMENTTYPE_NOTE_ENUS//-->', ABO.GetFieldValueAsString('PaymentType_ID.X_Note_ENUS'), [srAll]);
      except
        AddDebugLog(ExceptionMessage);
      end;
    end;
  end;

  if ABO.CLSID in [Class_ReceivedOrder, Class_IssuedOffer] then begin
    AText := NxSearchReplace(AText, '<!--NOTE//-->', ABO.GetFieldValueAsString('DESCRIPTION'), [srAll]);
    AText := NxSearchReplace(AText, '<!--EXTERNAL_NUMBER//-->', ABO.GetFieldValueAsString('ExternalNumber'), [srAll]);
  end;

  if ABO.CLSID in [Class_ReceivedOrder] then begin
    if ABO.GetFieldCode('X_POZNAMKA') > 0 then
      AText := NxSearchReplace(AText, '<!--POZNAMKA//-->', ABO.GetFieldValueAsString('X_POZNAMKA'), [srAll]);
  end;

  if ABO.CLSID in [Class_ReceivedOrder, Class_IssuedOffer] then begin
    if ABO.GetFieldCode('X_NOTE') > 0 then
      AText := NxSearchReplace(AText, '<!--X_NOTE//-->', ABO.GetFieldValueAsString('X_NOTE'), [srAll]);
  end;

  if (ABO.CLSID = Class_ReceivedOrder) then begin
    if (ABO.GetFieldValueAsBoolean('ONLYWHOLEORDER')) then begin
      AText := NxSearchReplace(AText, '<!--ONLYWHOLEORDER//-->', 'Dodat kompletně', [srAll]);
      AText := NxSearchReplace(AText, '<!--ONLYWHOLEORDER_SK//-->', 'Dodať kompletne', [srAll]);
      AText := NxSearchReplace(AText, '<!--ONLYWHOLEORDER_ENUS//-->', 'Deliver completely', [srAll]);
      AText := NxSearchReplace(AText, '<!--ONLYWHOLEORDER_HU//-->', 'Kompletten szállítani', [srAll]);
      AText := NxSearchReplace(AText, '<!--ONLYWHOLEORDER_DE//-->', 'Vollständig hinzufügen', [srAll]);
    end else begin
      AText := NxSearchReplace(AText, '<!--ONLYWHOLEORDER//-->', 'Dodat průběžně', [srAll]);
      AText := NxSearchReplace(AText, '<!--ONLYWHOLEORDER_SK//-->', 'Dodať priebežne', [srAll]);
      AText := NxSearchReplace(AText, '<!--ONLYWHOLEORDER_ENUS//-->', 'Deliver consecutively', [srAll]);
      AText := NxSearchReplace(AText, '<!--ONLYWHOLEORDER_HU//-->', 'Folyamatosan szállítani', [srAll]);
      AText := NxSearchReplace(AText, '<!--ONLYWHOLEORDER_DE//-->', 'Fügen Sie fortlaufend hinzu', [srAll]);
    end;
  end;

  if ABO.CLSID in [Class_ReceivedOrder, Class_IssuedDepositInvoice, Class_OtherIncome, Class_IssuedInvoice, Class_CashReceived, Class_BillOfDelivery, Class_IssuedOffer, Class_VATIssuedDepositInvoice, Class_CRMActivity, Class_IssuedOrder, Class_IssuedCreditNote, Class_PDMIssuedDoc] then begin
    AText := NxSearchReplace(AText, '<!--DOC_NUMBER//-->', ABO.DisplayName, [srAll]);

    if ABO.CLSID in [Class_CRMActivity, Class_PDMIssuedDoc, Class_BillOfDelivery] = false then begin
      AText := NxSearchReplace(AText, '<!--DOC_DATE//-->', DateToStr(ABO.GetFieldValueAsDateTime('DocDate$DATE')), [srAll]);
      AText := NxSearchReplace(AText, '<!--DOC_AMOUNT//-->', FormatFloat('0.00,', ABO.GetFieldValueAsFloat('Amount')), [srAll]);
      AText := NxSearchReplace(AText, '<!--CURRENCY//-->', ABO.GetFieldValueAsString('Currency_ID.Code'), [srAll]);
      AText := NxSearchReplace(AText, '<!--CURRENCY_SYMBOL//-->', ABO.GetFieldValueAsString('Currency_ID.Symbol'), [srAll]);
      AText := NxSearchReplace(AText, '<!--DESCRIPTION//-->', ABO.GetFieldValueAsString('Description'), [srAll]);
      if ABO.CLSID in [Class_IssuedDepositInvoice] = false then begin
        AText := NxSearchReplace(AText, '<!--DOC_AMOUNTWITHOUTVAT//-->', FormatFloat('0.00,', ABO.GetFieldValueAsFloat('AmountWithoutVAT')), [srAll]);
        AText := NxSearchReplace(AText, '<!--DOC_ROUNDINGAMOUNT//-->', FormatFloat('0.00,', ABO.GetFieldValueAsFloat('RoundingAmount')), [srAll]);
        if ABO.CLSID in [Class_VATIssuedDepositInvoice] = false then
          AText := NxSearchReplace(AText, '<!--DOC_VATAMOUNT//-->', FormatFloat('0.00,', ABO.GetFieldValueAsFloat('VATAmount')), [srAll]);
      end;
    end;
  end;

  if (ABO.CLSID = Class_FirmPerson) then begin
    AText := NxSearchReplace(AText, '<!--EMAIL//-->', AEmail, [srAll]);
    AText := NxSearchReplace(AText, '<!--FIRM_NAME//-->', ABO.GetFieldValueAsString('Parent_ID.Name'), [srAll]);
    AText := NxSearchReplace(AText, '<!--FIRM_ADDRESS_CITY//-->', ABO.GetFieldValueAsString('Parent_ID.ResidenceAddress_ID.City'), [srAll]);
    AText := NxSearchReplace(AText, '<!--FIRM_ADDRESS_STREET//-->', ABO.GetFieldValueAsString('Parent_ID.ResidenceAddress_ID.Street'), [srAll]);
    AText := NxSearchReplace(AText, '<!--FIRM_ADDRESS_POSTCODE//-->', ABO.GetFieldValueAsString('Parent_ID.ResidenceAddress_ID.PostCode'), [srAll]);
    AText := NxSearchReplace(AText, '<!--FIRM_ADDRESS_COUNTRY//-->', ABO.GetFieldValueAsString('Parent_ID.ResidenceAddress_ID.Country'), [srAll]);
    ReplaceCountryMutations(ABO.ObjectSpace, AText, 'FIRM_ADDRESS_COUNTRY', ABO.GetFieldValueAsString('Parent_ID.ResidenceAddress_ID.Country'));
    AText := NxSearchReplace(AText, '<!--FIRM_ORGIDENTNUMBER//-->', ABO.GetFieldValueAsString('Parent_ID.OrgIdentNumber'), [srAll]);
    AText := NxSearchReplace(AText, '<!--FIRM_VATIDENTNUMBER//-->', ABO.GetFieldValueAsString('Parent_ID.VatIdentNumber'), [srAll]);
    AText := NxSearchReplace(AText, '<!--PERSON_FIRST_NAME//-->', ABO.GetFieldValueAsString('Person_ID.FirstName'), [srAll]);
    AText := NxSearchReplace(AText, '<!--PERSON_LAST_NAME//-->', ABO.GetFieldValueAsString('Person_ID.LastName'), [srAll]);
    AText := NxSearchReplace(AText, '<!--PERSON_TITLE//-->', ABO.GetFieldValueAsString('Person_ID.Title'), [srAll]);
    AText := NxSearchReplace(AText, '<!--PERSON_ADDRESS//-->', ABO.GetFieldValueAsString('Person_ID.Address_ID.ShortAddress'), [srAll]);
    AText := NxSearchReplace(AText, '<!--PERSON_ADDRESS_PHONENUMBER1//-->', ABO.GetFieldValueAsString('Person_ID.Address_ID.PhoneNumber1'), [srAll]);
    AText := NxSearchReplace(AText, '<!--PERSON_ADDRESS_PHONENUMBER2//-->', ABO.GetFieldValueAsString('Person_ID.Address_ID.PhoneNumber2'), [srAll]);
    AText := NxSearchReplace(AText, '<!--USER//-->', ABO.GetFieldValueAsString('Person_ID.X_USER'), [srAll]);
    AText := NxSearchReplace(AText, '<!--DOC_NUMBER//-->', '', [srAll]);
    AText := NxSearchReplace(AText, '<!--DOC_DATE//-->', '', [srAll]);
  end;

  if (ABO.CLSID = Class_OtherIncome) then begin
    if ABO.GetFieldValueAsBoolean('EET') = true then begin
      AText := NxSearchReplace(AText, '<!--EET_BKP//-->', ABO.GetFieldValueAsString('EETTurnover_ID.BKP'), [srAll]);
      AText := NxSearchReplace(AText, '<!--EET_FIK//-->', ABO.GetFieldValueAsString('EETTurnover_ID.FIK'), [srAll]);
      AText := NxSearchReplace(AText, '<!--EET_ESTABLISHMENT//-->', ABO.GetFieldValueAsString('EETTurnover_ID.Establishment_ID.Name'), [srAll]);
      AText := NxSearchReplace(AText, '<!--EET_CASHDEVICE//-->', ABO.GetFieldValueAsString('EETTurnover_ID.CashDeviceCode'), [srAll]);
      AText := NxSearchReplace(AText, '<!--EET_TURNOVERSTATE//-->', ABO.GetFieldValueAsString('EETTurnover_ID.TurnoverState'), [srAll]);
      mTOState := ABO.GetFieldValueAsInteger('EETTurnover_ID.TurnoverState');
      case mTOState of
        0: mTOStateText := 'Koncept';
        1: mTOStateText := 'K odeslání';
        2: mTOStateText := 'Odeslaná';
        3: mTOStateText := 'Chyba odeslání';
        4: mTOStateText := 'Chyba generování';
        5: mTOStateText := 'Odmítnuto';
      end;
      AText := NxSearchReplace(AText, '<!--EET_TURNOVERSTATETEXT//-->', mTOStateText, [srAll]);
    end;
  end;

  if ABO.CLSID = Class_IssuedOffer then begin
    AText := NxSearchReplace(AText, '<!--OFFER_STATE//-->', ABO.GetFieldValueAsString('OfferState_ID.Name'), [srAll]);
    ReplaceOfferStateMutations(ABO.ObjectSpace, AText, 'OFFER_STATE', ABO.GetFieldValueAsString('OfferState_ID'));
    AText := NxSearchReplace(AText, '<!--OFFER_VALID_DATE//-->', DateToStr(ABO.GetFieldValueAsDateTime('ValidTill$DATE')), [srAll]);
  end;

  if ABO.CLSID = Class_CRMActivity then begin
    AText := NxSearchReplace(AText, '<!--ACTIVITY_PROCESS//-->', ABO.GetFieldValueAsString('ActivityProcess_ID.Name'), [srAll]);
    AText := NxSearchReplace(AText, '<!--ACTIVITY_SOLVER_ROLE//-->', ABO.GetFieldValueAsString('SolverRole_ID.Name'), [srAll]);
    AText := NxSearchReplace(AText, '<!--ACTIVITY_SOLVER_USER//-->', ABO.GetFieldValueAsString('SolverUser_ID.Name'), [srAll]);
    AText := NxSearchReplace(AText, '<!--ACTIVITY_SCHEDULED_START//-->', DateToStr(ABO.GetFieldValueAsDateTime('SheduledStart$Date')), [srAll]);
    AText := NxSearchReplace(AText, '<!--ACTIVITY_SCHEDULED_END//-->', DateToStr(ABO.GetFieldValueAsDateTime('SheduledEnd$Date')), [srAll]);
    AText := NxSearchReplace(AText, '<!--ACTIVITY_REAL_START//-->', DateToStr(ABO.GetFieldValueAsDateTime('RealStart$Date')), [srAll]);
    AText := NxSearchReplace(AText, '<!--ACTIVITY_REAL_END//-->', DateToStr(ABO.GetFieldValueAsDateTime('RealEnd$Date')), [srAll]);
    AText := NxSearchReplace(AText, '<!--ACTIVITY_DESCRIPTION//-->', ABO.GetFieldValueAsString('Description'), [srAll]);
    AText := NxSearchReplace(AText, '<!--ACTIVITY_ANSWER//-->', ABO.GetFieldValueAsString('Answer'), [srAll]);
  end;

  if ABO.CLSID = Class_PDMIssuedDoc then begin
    AText := NxSearchReplace(AText, '<!--NOTE//-->', ABO.GetFieldValueAsString('Note'), [srAll]);
    AText := NxSearchReplace(AText, '<!--DESCRIPTION//-->', ABO.GetFieldValueAsString('Description'), [srAll]);
    AText := NxSearchReplace(AText, '<!--VARSYMBOL//-->', ABO.GetFieldValueAsString('Varsymbol'), [srAll]);
    AText := NxSearchReplace(AText, '<!--ISSUEDDOC_POSTNUMBER//-->', ABO.GetFieldValueAsString('PostNumber'), [srAll]);
    AText := NxSearchReplace(AText, '<!--ISSUEDDOC_CASHONDELIVERY//-->', FormatFloat('0.00,', ABO.GetFieldValueAsFloat('CashOnDelivery')), [srAll]);
    AText := NxSearchReplace(AText, '<!--ISSUEDDOC_AMOUNT//-->', FormatFloat('0.00,', ABO.GetFieldValueAsFloat('Amount')), [srAll]);
    AText := NxSearchReplace(AText, '<!--ISSUEDDOC_INSUREDVALUE//-->', FormatFloat('0.00,', ABO.GetFieldValueAsFloat('InsuredValue')), [srAll]);
    AText := NxSearchReplace(AText, '<!--ISSUEDDOC_POSTPROVIDER//-->', ABO.GetFieldValueAsString('PostProvider_ID.Name'), [srAll]);
    if ABO.GetFieldCode('X_PD_Track_Url') > 0 then
      AText := NxSearchReplace(AText, '<!--ISSUEDDOC_TRACK_URL//-->', ABO.GetFieldValueAsString('X_PD_Track_Url'), [srAll]);
  end;

  if ABO.CLSID = Class_IssuedDepositInvoice then begin
    AText := NxSearchReplace(AText, '<!--RECEIVED_ORDER_DISPLAYNAME//-->', ABO.GetFieldValueAsString('ReceivedOrder_ID.DisplayName'), [srAll]);
    AText := NxSearchReplace(AText, '<!--RECEIVED_ORDER_EXTERNAL_NUMBER//-->', ABO.GetFieldValueAsString('ReceivedOrder_ID.ExternalNumber'), [srAll]);
    AText := NxSearchReplace(AText, '<!--ISSUEDDEPOSIT_PAID//-->', FormatFloat('0.00,', ABO.GetFieldValueAsFloat('PaidAmount')), [srAll]);
    AText := NxSearchReplace(AText, '<!--ISSUEDDEPOSIT_NOTPAID//-->', FormatFloat('0.00,', ABO.GetFieldValueAsFloat('NotPaidAmount')), [srAll]);

  end;

  if ABO.CLSID = Class_BillOfDelivery then begin
    mReceivedOrderID := GetFirstOrderIDToBillOfDelivery(ABO);
    if not NxIsEmptyOID(mReceivedOrderID) then begin
      AText := NxSearchReplace(AText, '<!--RECEIVED_ORDER_DISPLAYNAME//-->', GetValueFromReceivedOrder(ABO.ObjectSpace, mReceivedOrderID, 'DisplayName'), [srAll]);
      AText := NxSearchReplace(AText, '<!--RECEIVED_ORDER_EXTERNAL_NUMBER//-->', GetValueFromReceivedOrder(ABO.ObjectSpace, mReceivedOrderID, 'ExternalNumber'), [srAll]);
      AText := NxSearchReplace(AText, '<!--RECEIVED_ORDER_PAYMENTTYPE_NAME_CS//-->', GetValueFromReceivedOrder(ABO.ObjectSpace, mReceivedOrderID, 'PaymentType_ID.X_Name_CS'), [srAll]);
      AText := NxSearchReplace(AText, '<!--RECEIVED_ORDER_CURRENCY//-->', GetValueFromReceivedOrder(ABO.ObjectSpace, mReceivedOrderID, 'Currency_ID.Code'), [srAll]);
      AText := NxSearchReplace(AText, '<!--RECEIVED_ORDER_CURRENCY_SYMBOL//-->', GetValueFromReceivedOrder(ABO.ObjectSpace, mReceivedOrderID, 'Currency_ID.Symbol'), [srAll]);
    end else
      AddDebugLog(Format('Pro objekt %s nenalezena objednávka', [ABO.DisplayName]));
  end;

  if ABO.CLSID = Class_IssuedInvoice then begin
    mReceivedOrderID := GetFirstOrderIDToIssuedInvoice(ABO);
    if not NxIsEmptyOID(mReceivedOrderID) then begin
      AText := NxSearchReplace(AText, '<!--RECEIVED_ORDER_DISPLAYNAME//-->', GetValueFromReceivedOrder(ABO.ObjectSpace, mReceivedOrderID, 'DisplayName'), [srAll]);
      AText := NxSearchReplace(AText, '<!--RECEIVED_ORDER_EXTERNAL_NUMBER//-->', GetValueFromReceivedOrder(ABO.ObjectSpace, mReceivedOrderID, 'ExternalNumber'), [srAll]);
    end else
      AddDebugLog(Format('Pro objekt %s nenalezena objednávka', [ABO.DisplayName]));
  end;


  AText := NxSearchReplace(AText, '<!--ACTUAL_DATE//-->', DateToStr(Date), [srAll]);
  AText := NxSearchReplace(AText, '<!--ACTUAL_DATETIME//-->', DateTimeToStr(Now), [srAll]);

  AText := NxSearchReplace(AText, '<!--BUSORDER_CODE//-->', GetDocFirstRowValue(ABO, 'BusOrder_ID.Code'), [srAll]);
  AText := NxSearchReplace(AText, '<!--BUSORDER_NAME//-->', GetDocFirstRowValue(ABO, 'BusOrder_ID.Name'), [srAll]);
  AText := NxSearchReplace(AText, '<!--BUSORDER_EMAIL//-->', GetDocFirstRowValue(ABO, 'BusOrder_ID.X_Email'), [srAll]);
  AText := NxSearchReplace(AText, '<!--BUSORDER_PHONENUMBER//-->', GetDocFirstRowValue(ABO, 'BusOrder_ID.X_PhoneNumber'), [srAll]);

  AText := NxSearchReplace(AText, '<!--BUSTRANSACTION_CODE//-->', GetDocFirstRowValue(ABO, 'BusTransaction_ID.Code'), [srAll]);
  AText := NxSearchReplace(AText, '<!--BUSTRANSACTION_NAME//-->', GetDocFirstRowValue(ABO, 'BusTransaction_ID.Name'), [srAll]);
  AText := NxSearchReplace(AText, '<!--BUSTRANSACTION_EMAIL//-->', GetDocFirstRowValue(ABO, 'BusTransaction_ID.X_Email'), [srAll]);
  AText := NxSearchReplace(AText, '<!--BUSTRANSACTION_PHONENUMBER//-->', GetDocFirstRowValue(ABO, 'BusTransaction_ID.X_PhoneNumber'), [srAll]);

  AText := NxSearchReplace(AText, '<!--BUSPROJECT_CODE//-->', GetDocFirstRowValue(ABO, 'BusProject_ID.Code'), [srAll]);
  AText := NxSearchReplace(AText, '<!--BUSPROJECT_NAME//-->', GetDocFirstRowValue(ABO, 'BusProject_ID.Name'), [srAll]);
  AText := NxSearchReplace(AText, '<!--BUSPROJECT_EMAIL//-->', GetDocFirstRowValue(ABO, 'BusProject_ID.X_Email'), [srAll]);
  AText := NxSearchReplace(AText, '<!--BUSPROJECT_PHONENUMBER//-->', GetDocFirstRowValue(ABO, 'BusProject_ID.X_PhoneNumber'), [srAll]);

  AText := NxSearchReplace(AText, '<!--STORE_CODE//-->', GetDocFirstRowValue(ABO, 'Store_ID.Code'), [srAll]);
  AText := NxSearchReplace(AText, '<!--STORE_NAME//-->', GetDocFirstRowValue(ABO, 'Store_ID.Name'), [srAll]);
  AText := NxSearchReplace(AText, '<!--STORE_EMAIL//-->', GetDocFirstRowValue(ABO, 'Store_ID.Address_ID.Email'), [srAll]);
  AText := NxSearchReplace(AText, '<!--STORE_PHONENUMBER1//-->', GetDocFirstRowValue(ABO, 'Store_ID.Address_ID.PhoneNumber1'), [srAll]);
  AText := NxSearchReplace(AText, '<!--STORE_PHONENUMBER2//-->', GetDocFirstRowValue(ABO, 'Store_ID.Address_ID.PhoneNumber2'), [srAll]);

  AText := NxSearchReplace(AText, '<!--DIVISION_CODE//-->', GetDocFirstRowValue(ABO, 'Division_ID.Code'), [srAll]);
  AText := NxSearchReplace(AText, '<!--DIVISION_NAME//-->', GetDocFirstRowValue(ABO, 'Division_ID.Name'), [srAll]);
  AText := NxSearchReplace(AText, '<!--DIVISION_EMAIL//-->', GetDocFirstRowValue(ABO, 'Division_ID.Address_ID.Email'), [srAll]);
  AText := NxSearchReplace(AText, '<!--DIVISION_PHONENUMBER1//-->', GetDocFirstRowValue(ABO, 'Division_ID.Address_ID.PhoneNumber1'), [srAll]);
  AText := NxSearchReplace(AText, '<!--DIVISION_PHONENUMBER2//-->', GetDocFirstRowValue(ABO, 'Division_ID.Address_ID.PhoneNumber2'), [srAll]);

  if NxIsBlank(AOwnVariableField) = false then begin
    AText := NxSearchReplace(AText, '<!--' + AOwnVariableField + '//-->', ABO.GetFieldValueAsString(AOwnVariableField), [srAll]);
  end;

  if NxAt('<!--ROWS//-->', AText) > 0 then begin
    mRowsText := ProcessTextRows(ARowsText, ABO, mBillRowsAmountWIV, AExternalScript);
    AText := NxSearchReplace(AText, '<!--ROWS//-->', mRowsText, [srAll]);
  end;

  AText := NxSearchReplace(AText, '<!--BILL_AMOUNTWITHVAT//-->', FormatFloat('0.00,', mBillRowsAmountWIV), [srAll]);

  //dokumenty ke stažení
  if NxAt('<!--DOCUMENTS_DOWNLOAD', AText) > 0 then begin
    try
      FillDocsURL(ABO, AText);
    except
      OutputDebugString('Chyba při plnění dokumentů ke stažení: ' + ExceptionMessage);
    end;
  end;
  RunScript(ABO.ObjectSpace, ABO, AText, AExternalScript);
end;

procedure FillDocsURL(ABO: TNxCustomBusinessObject; var AText: string);
var mRowsDts: TMemoryDataset;
  mSql, mRowsPersistCLSID: string;
  mCol: TNxCustomBusinessMonikerCollection;
begin
  //jen pro řádkové objekty
  if ABO.GetFieldCode('Rows') > 0 then begin
    mCol := ABO.GetLoadedCollectionMonikerForFieldCode(ABO.GetFieldCode('Rows'));
    if mCol.Count > 0 then begin
      mRowsPersistCLSID := mCol.BusinessObject[0].PersistCLSID;
      mSQL := 'Select distinct A.X_VALUE, A.X_VALUE_CS, A.X_VALUE_DE, A.X_VALUE_ENUS, A.X_VALUE_SK from DefRollData A' + NxCrLf +
        Format('where A.CLSID=%s and A.Hidden=%s and X_AttachToEmail=%s and exists(Select B.ID from %s B where B.Parent_ID=%s and B.RowType=3 and B.Storecard_ID=A.X_Storecard_ID) order by A.X_POSINDEX',
        [QuotedStr(cDocumentsDefRollCLSID), QuotedStr('N'), QuotedStr('A'), NxGetTableNameForPersistCLSID(mRowsPersistCLSID), QuotedStr(ABO.OID)]);
      mRowsDts := TMemoryDataset.Create(nil);
      try
        ABO.ObjectSpace.SQLSelect2(mSQL, mRowsDts);
        if mRowsDts.Active then begin
          mRowsDts.First;
          while not mRowsDts.Eof do begin
            AText := NxSearchReplace(AText, '<!--DOCUMENTS_DOWNLOAD_CS//-->', '<a href="' + mRowsDts.FieldByName('X_VALUE').AsString + '">' + mRowsDts.FieldByName('X_VALUE_CS').AsString + '</a><br><!--DOCUMENTS_DOWNLOAD_CS//-->', [srAll]);
            AText := NxSearchReplace(AText, '<!--DOCUMENTS_DOWNLOAD_DE//-->', '<a href="' + mRowsDts.FieldByName('X_VALUE').AsString + '">' + mRowsDts.FieldByName('X_VALUE_DE').AsString + '</a><br><!--DOCUMENTS_DOWNLOAD_DE//-->', [srAll]);
            AText := NxSearchReplace(AText, '<!--DOCUMENTS_DOWNLOAD_ENUS//-->', '<a href="' + mRowsDts.FieldByName('X_VALUE').AsString + '">' + mRowsDts.FieldByName('X_VALUE_ENUS').AsString + '</a><br><!--DOCUMENTS_DOWNLOAD_ENUS//-->', [srAll]);
            AText := NxSearchReplace(AText, '<!--DOCUMENTS_DOWNLOAD_SK//-->', '<a href="' + mRowsDts.FieldByName('X_VALUE').AsString + '">' + mRowsDts.FieldByName('X_VALUE_SK').AsString + '</a><br><!--DOCUMENTS_DOWNLOAD_SK//-->', [srAll]);
            mRowsDts.Next;
          end;
          AText := NxSearchReplace(AText, '<!--DOCUMENTS_DOWNLOAD_CS//-->', '', [srAll]);
          AText := NxSearchReplace(AText, '<!--DOCUMENTS_DOWNLOAD_DE//-->', '', [srAll]);
          AText := NxSearchReplace(AText, '<!--DOCUMENTS_DOWNLOAD_ENUS//-->', '', [srAll]);
          AText := NxSearchReplace(AText, '<!--DOCUMENTS_DOWNLOAD_SK//-->', '', [srAll]);
        end;
      finally
        mRowsDts.Free;
      end;
    end;
  end;
end;

procedure ReplaceOfferStateMutations(AOS: TNxCustomObjectSpace; var AText: string; ATagName, AStateID: string);
var mBO: TNxCustomBusinessObject;
begin
  if not NxIsEmptyOID(AStateID) then begin
    mBO := AOS.CreateObject(Class_IssuedOfferState);
    try
      mBO.Load(AStateID, nil);
      if mBO.GetFieldCode('X_NAME_CS') > 0 then
        AText := NxSearchReplace(AText, '<!--' + ATagName + '_CS' + '//-->', mBO.GetFieldValueAsString('X_NAME_CS'), [srAll]);
      if mBO.GetFieldCode('X_NAME_SK') > 0 then
        AText := NxSearchReplace(AText, '<!--' + ATagName + '_SK' + '//-->', mBO.GetFieldValueAsString('X_NAME_SK'), [srAll]);
      if mBO.GetFieldCode('X_NAME_ENUS') > 0 then
        AText := NxSearchReplace(AText, '<!--' + ATagName + '_ENUS' + '//-->', mBO.GetFieldValueAsString('X_NAME_ENUS'), [srAll]);
      if mBO.GetFieldCode('X_NAME_DE') > 0 then
        AText := NxSearchReplace(AText, '<!--' + ATagName + '_DE' + '//-->', mBO.GetFieldValueAsString('X_NAME_DE'), [srAll]);
      if mBO.GetFieldCode('X_NAME_HU') > 0 then
        AText := NxSearchReplace(AText, '<!--' + ATagName + '_HU' + '//-->', mBO.GetFieldValueAsString('X_NAME_HU'), [srAll]);
    finally
      mBO.Free;
    end;
  end;
end;

procedure ReplaceCountryMutations(AOS: TNxCustomObjectSpace; var AText: string; ATagName, ACountryName: string);
var mCountryID: string;
  mBO: TNxCustomBusinessObject;
begin
  if ACountryName <> '' then begin
    mCountryID := GetCountryIDByName(AOS, ACountryName);
    if not NxIsEmptyOID(mCountryID) then begin
      mBO := AOS.CreateObject(Class_Country);
      try
        mBO.Load(mCountryID, nil);
        if mBO.GetFieldCode('X_NAME_CS') > 0 then
          AText := NxSearchReplace(AText, '<!--' + ATagName + '_CS' + '//-->', mBO.GetFieldValueAsString('X_NAME_CS'), [srAll]);
        if mBO.GetFieldCode('X_NAME_SK') > 0 then
          AText := NxSearchReplace(AText, '<!--' + ATagName + '_SK' + '//-->', mBO.GetFieldValueAsString('X_NAME_SK'), [srAll]);
        if mBO.GetFieldCode('X_NAME_ENUS') > 0 then
          AText := NxSearchReplace(AText, '<!--' + ATagName + '_ENUS' + '//-->', mBO.GetFieldValueAsString('X_NAME_ENUS'), [srAll]);
        if mBO.GetFieldCode('X_NAME_DE') > 0 then
          AText := NxSearchReplace(AText, '<!--' + ATagName + '_DE' + '//-->', mBO.GetFieldValueAsString('X_NAME_DE'), [srAll]);
        if mBO.GetFieldCode('X_NAME_HU') > 0 then
          AText := NxSearchReplace(AText, '<!--' + ATagName + '_HU' + '//-->', mBO.GetFieldValueAsString('X_NAME_HU'), [srAll]);
      finally
        mBO.Free;
      end;
    end;
  end;
  AText := NxSearchReplace(AText, '<!--' + ATagName + '_CS' + '//-->', '', [srAll]);
  AText := NxSearchReplace(AText, '<!--' + ATagName + '_DE' + '//-->', '', [srAll]);
  AText := NxSearchReplace(AText, '<!--' + ATagName + '_ENUS' + '//-->', '', [srAll]);
  AText := NxSearchReplace(AText, '<!--' + ATagName + '_HU' + '//-->', '', [srAll]);
end;

function ProcessTextRows(AText: string; ABO: TNxCustomBusinessObject; var ABillRowsAmountWIV: Double = 0; AExternalScript: string): string;
var
  i: Integer;
  mRowsCol: TNxCustomBusinessMonikerCollection;
  mObjList: TObjectList;
  mObjRow, mSCBO: TNxCustomBusinessObject;
  mText: string;
  mAmount: Double;
begin
  result := '';
  ABillRowsAmountWIV := 0;
  if ABO.GetFieldCode('ROWS') > 0 then begin
    mRowsCol := ABO.GetLoadedCollectionMonikerForFieldCode(ABO.GetFieldCode('Rows'));
    mObjList := TObjectList.Create;
    try
      mObjList.OwnsObjects := False;
      mRowsCol.FillBusinesObjectListByPosition(mObjList);
      for i := 0 to mObjList.Count - 1 do begin
        mText := AText;
        mObjRow := TNxCustomBusinessObject(mObjList.Items[i]);
        if not NxCheckBit(mObjRow.State, osMarkForDelete) then begin
          if (mObjRow.GetFieldCode('Storecard_ID') > 0) and (mObjRow.GetFieldCode('RowType') > 0) and (mObjRow.GetFieldValueAsInteger('RowType') < 4) then begin
            mSCBO := ABO.ObjectSpace.CreateObject(Class_StoreCard);
            try
              mText := NxSearchReplace(mText, '<!--ROW_STORECARD_CODE//-->', mObjRow.GetFieldValueAsString('Storecard_ID.Code'), [srAll]);
              mText := NxSearchReplace(mText, '<!--ROW_STORECARD_NAME//-->', mObjRow.GetFieldValueAsString('Storecard_ID.Name'), [srAll]);
              mText := NxSearchReplace(mText, '<!--ROW_STORECARD_SPECIFICATION//-->', mObjRow.GetFieldValueAsString('Storecard_ID.Specification'), [srAll]);
              mText := NxSearchReplace(mText, '<!--ROW_STORECARD_SPECIFICATION2//-->', mObjRow.GetFieldValueAsString('Storecard_ID.Specification2'), [srAll]);
              mText := NxSearchReplace(mText, '<!--ROW_STORECARD_FOREIGNNAME//-->', mObjRow.GetFieldValueAsString('Storecard_ID.ForeignName'), [srAll]);
              mText := NxSearchReplace(mText, '<!--ROW_STORECARD_ID//-->', mObjRow.GetFieldValueAsString('Storecard_ID'), [srAll]);
              if (mObjRow.GetFieldValueAsInteger('RowType') = 3) and mObjRow.GetFieldValueAsBoolean('Storecard_ID.X_ESHOP') then
                mText := NxSearchReplace(mText, '<!--ROW_PRODUCT_NAME_URL//-->', GetProductURL(mObjRow.GetFieldValueAsString('Storecard_ID.Name')), [srAll])
              else
                mText := NxSearchReplace(mText, '<!--ROW_PRODUCT_NAME_URL//-->', '', [srAll]);
              mText := NxSearchReplace(mText, '<!--ROW_PRODUCT_ESHOP_NAME_CS_URL//-->', GetProductURL(mObjRow.GetFieldValueAsString('Storecard_ID.X_Eshop_Name_CS')), [srAll]);
              mText := NxSearchReplace(mText, '<!--ROW_PRODUCT_ESHOP_NAME_SK_URL//-->', GetProductURL(mObjRow.GetFieldValueAsString('Storecard_ID.X_Eshop_Name_SK')), [srAll]);
              mText := NxSearchReplace(mText, '<!--ROW_PRODUCT_ESHOP_NAME_DE_URL//-->', GetProductURL(mObjRow.GetFieldValueAsString('Storecard_ID.X_Eshop_Name_DE')), [srAll]);
              mText := NxSearchReplace(mText, '<!--ROW_PRODUCT_ESHOP_NAME_ENUS_URL//-->', GetProductURL(mObjRow.GetFieldValueAsString('Storecard_ID.X_Eshop_Name_ENUS')), [srAll]);
              mText := NxSearchReplace(mText, '<!--CURRENCY//-->', ABO.GetFieldValueAsString('Currency_ID.Code'), [srAll]);
              mText := NxSearchReplace(mText, '<!--CURRENCY_SYMBOL//-->', ABO.GetFieldValueAsString('Currency_ID.Symbol'), [srAll]);

              if mObjRow.GetFieldCode('Text') > 0 then begin
                if mObjRow.GetFieldValueAsString('Text') <> '' then
                  mText := NxSearchReplace(mText, '<!--ROW_UNIVERSAL_TEXT//-->', mObjRow.GetFieldValueAsString('Text'), [srAll])
                else
                  mText := NxSearchReplace(mText, '<!--ROW_UNIVERSAL_TEXT//-->', mObjRow.GetFieldValueAsString('Storecard_ID.Code') + ' ' + mObjRow.GetFieldValueAsString('Storecard_ID.Name'), [srAll]);
              end;

              if mSCBO.GetFieldCode('X_Eshop_Name_CS') > 0 then begin
                mText := NxSearchReplace(mText, '<!--ROW_STORECARD_ESHOP_NAME_CS//-->', mObjRow.GetFieldValueAsString('Storecard_ID.X_Eshop_Name_CS'), [srAll]);
                if mObjRow.GetFieldCode('Text') > 0 then begin
                  if mObjRow.GetFieldValueAsString('Text') <> '' then
                    mText := NxSearchReplace(mText, '<!--ROW_UNIVERSAL_TEXT_CS//-->', mObjRow.GetFieldValueAsString('Text'), [srAll])
                  else
                    mText := NxSearchReplace(mText, '<!--ROW_UNIVERSAL_TEXT_CS//-->', mObjRow.GetFieldValueAsString('Storecard_ID.Code') + ' ' + mObjRow.GetFieldValueAsString('Storecard_ID.X_Eshop_Name_CS'), [srAll]);
                end;
              end;

              if mSCBO.GetFieldCode('X_Eshop_Name_ENUS') > 0 then begin
                mText := NxSearchReplace(mText, '<!--ROW_STORECARD_ESHOP_NAME_ENUS//-->', mObjRow.GetFieldValueAsString('Storecard_ID.X_Eshop_Name_ENUS'), [srAll]);
                if mObjRow.GetFieldCode('Text') > 0 then begin
                  if mObjRow.GetFieldValueAsString('Text') <> '' then
                    mText := NxSearchReplace(mText, '<!--ROW_UNIVERSAL_TEXT_ENUS//-->', mObjRow.GetFieldValueAsString('Text'), [srAll])
                  else
                    mText := NxSearchReplace(mText, '<!--ROW_UNIVERSAL_TEXT_ENUS//-->', mObjRow.GetFieldValueAsString('Storecard_ID.Code') + ' ' + mObjRow.GetFieldValueAsString('Storecard_ID.X_Eshop_Name_ENUS'), [srAll]);
                end;
              end;

              if mSCBO.GetFieldCode('X_Eshop_Name_DE') > 0 then begin
                mText := NxSearchReplace(mText, '<!--ROW_STORECARD_ESHOP_NAME_DE//-->', mObjRow.GetFieldValueAsString('Storecard_ID.X_Eshop_Name_DE'), [srAll]);
                if mObjRow.GetFieldCode('Text') > 0 then begin
                  if mObjRow.GetFieldValueAsString('Text') <> '' then
                    mText := NxSearchReplace(mText, '<!--ROW_UNIVERSAL_TEXT_DE//-->', mObjRow.GetFieldValueAsString('Text'), [srAll])
                  else
                    mText := NxSearchReplace(mText, '<!--ROW_UNIVERSAL_TEXT_DE//-->', mObjRow.GetFieldValueAsString('Storecard_ID.Code') + ' ' + mObjRow.GetFieldValueAsString('Storecard_ID.X_Eshop_Name_DE'), [srAll]);
                end;
              end;

              if mSCBO.GetFieldCode('X_Eshop_Name_SK') > 0 then begin
                mText := NxSearchReplace(mText, '<!--ROW_STORECARD_ESHOP_NAME_SK//-->', mObjRow.GetFieldValueAsString('Storecard_ID.X_Eshop_Name_SK'), [srAll]);
                if mObjRow.GetFieldCode('Text') > 0 then begin
                  if mObjRow.GetFieldValueAsString('Text') <> '' then
                    mText := NxSearchReplace(mText, '<!--ROW_UNIVERSAL_TEXT_SK//-->', mObjRow.GetFieldValueAsString('Text'), [srAll])
                  else
                    mText := NxSearchReplace(mText, '<!--ROW_UNIVERSAL_TEXT_SK//-->', mObjRow.GetFieldValueAsString('Storecard_ID.Code') + ' ' + mObjRow.GetFieldValueAsString('Storecard_ID.X_Eshop_Name_SK'), [srAll]);
                end;
              end;

              if mSCBO.GetFieldCode('X_Eshop_Name_HU') > 0 then begin
                mText := NxSearchReplace(mText, '<!--ROW_STORECARD_ESHOP_NAME_HU//-->', mObjRow.GetFieldValueAsString('Storecard_ID.X_Eshop_Name_HU'), [srAll]);
                if mObjRow.GetFieldCode('Text') > 0 then begin
                  if mObjRow.GetFieldValueAsString('Text') <> '' then
                    mText := NxSearchReplace(mText, '<!--ROW_UNIVERSAL_TEXT_HU//-->', mObjRow.GetFieldValueAsString('Text'), [srAll])
                  else
                    mText := NxSearchReplace(mText, '<!--ROW_UNIVERSAL_TEXT_HU//-->', mObjRow.GetFieldValueAsString('Storecard_ID.Code') + ' ' + mObjRow.GetFieldValueAsString('Storecard_ID.X_Eshop_Name_HU'), [srAll]);
                end;
              end;

              if mSCBO.GetFieldCode(cFieldImage) > 0 then
                mText := NxSearchReplace(mText, '<!--ROW_PICTURE_FILENAME//-->', GetPictureName(mObjRow.ObjectSpace, mObjRow.GetFieldValueAsString('Storecard_ID.' + cFieldImage)), [srAll]);

              mText := NxSearchReplace(mText, '<!--ROW_FIRST_PICTURE_ID//-->', GetFirstPictureID(mObjRow.ObjectSpace, mObjRow.GetFieldValueAsString('Storecard_ID')), [srAll]);

            finally
              mSCBO.Free;
            end;
          end;

          if (mObjRow.GetFieldCode('RowType') > 0) and (mObjRow.GetFieldValueAsInteger('RowType') < 4) then begin
            if mObjRow.GetFieldCode('Text') > 0 then
              mText := NxSearchReplace(mText, '<!--ROW_TEXT//-->', mObjRow.GetFieldValueAsString('Text'), [srAll]);
            if mObjRow.GetFieldCode('QUnit') > 0 then
              mText := NxSearchReplace(mText, '<!--ROW_QUNIT//-->', mObjRow.GetFieldValueAsString('QUnit'), [srAll]);
            if mObjRow.GetFieldCode('UnitQuantity') > 0 then
              mText := NxSearchReplace(mText, '<!--ROW_UNITQUANTITY//-->', FormatFloat('0.###,', mObjRow.GetFieldValueAsFloat('UnitQuantity')), [srAll]);
            if mObjRow.GetFieldCode('UnitPrice') > 0 then
              mText := NxSearchReplace(mText, '<!--ROW_UNITPRICE//-->', FormatFloat('0.00,', mObjRow.GetFieldValueAsFloat('UnitPrice')), [srAll]);
            if mObjRow.GetFieldCode('TotalPrice') > 0 then
              mText := NxSearchReplace(mText, '<!--ROW_TOTALPRICE//-->', FormatFloat('0.00,', mObjRow.GetFieldValueAsFloat('TotalPrice')), [srAll]);
            if mObjRow.GetFieldCode('TAmount') > 0 then
              mText := NxSearchReplace(mText, '<!--ROW_TAMOUNT//-->', FormatFloat('0.00,', mObjRow.GetFieldValueAsFloat('TAmount')), [srAll]);
            if mObjRow.GetFieldCode('TAmountWithoutVAT') > 0 then
              mText := NxSearchReplace(mText, '<!--ROW_TAMOUNTWITHOUTVAT//-->', FormatFloat('0.00,', mObjRow.GetFieldValueAsFloat('TAmountWithoutVAT')), [srAll]);
            if mObjRow.GetFieldCode('LocalTAmount') > 0 then
              mText := NxSearchReplace(mText, '<!--ROW_LOCALTAMOUNT//-->', FormatFloat('0.00,', mObjRow.GetFieldValueAsFloat('LocalTAmount')), [srAll]);
            if mObjRow.GetFieldCode('LocalTAmountWithoutVAT') > 0 then
              mText := NxSearchReplace(mText, '<!--ROW_LOCALTAMOUNTWITHOUTVAT//-->', FormatFloat('0.00,', mObjRow.GetFieldValueAsFloat('LocalTAmountWithoutVAT')), [srAll]);
            if mObjRow.GetFieldCode('VATRate') > 0 then
              mText := NxSearchReplace(mText, '<!--ROW_VATRATE//-->', FormatFloat('0,', mObjRow.GetFieldValueAsFloat('VATRate')), [srAll]);
            if mObjRow.GetFieldCode('TotalPercentualDiscount') > 0 then
              mText := NxSearchReplace(mText, '<!--ROW_TOTALPERCENTUALDISCOUNT//-->', FormatFloat('0.0,', mObjRow.GetFieldValueAsFloat('TotalPercentualDiscount')), [srAll]);
            if (mObjRow.GetFieldCode('TAmountWithoutVAT') > 0) and (mObjRow.GetFieldCode('UnitQuantity') > 0) and (mObjRow.GetFieldValueAsFloat('UnitQuantity') > 0) then
              mText := NxSearchReplace(mText, '<!--ROW_DISC_UNITPRICE_WOV//-->', FormatFloat('0.00,', mObjRow.GetFieldValueAsFloat('TAmountWithoutVAT') / mObjRow.GetFieldValueAsFloat('UnitQuantity')), [srAll]);
            if (mObjRow.GetFieldCode('TAmount') > 0) and (mObjRow.GetFieldCode('UnitQuantity') > 0) and (mObjRow.GetFieldValueAsFloat('UnitQuantity') > 0) then
              mText := NxSearchReplace(mText, '<!--ROW_DISC_UNITPRICE_WIV//-->', FormatFloat('0.00,', mObjRow.GetFieldValueAsFloat('TAmount') / mObjRow.GetFieldValueAsFloat('UnitQuantity')), [srAll]);
            if mObjRow.GetFieldCode('Store_ID') > 0 then begin
              mText := NxSearchReplace(mText, '<!--ROW_STORE_CODE//-->', mObjRow.GetFieldValueAsString('Store_ID.Code'), [srAll]);
              mText := NxSearchReplace(mText, '<!--ROW_STORE_NAME//-->', mObjRow.GetFieldValueAsString('Store_ID.Name'), [srAll]);
            end;
          end;
          //k řádku DL vrací hodnotu z OP
          if mObjRow.CLSID = Class_BillOfDeliveryRow then begin
            mText := NxSearchReplace(mText, '<!--ROW_BILL_DISC_UNITPRICE_WIV//-->', FormatFloat('0.00,', GetBillRowValueFromOrder(mObjRow, 'ROW_BILL_DISC_UNITPRICE_WIV')), [srAll]);
            mAmount := GetBillRowValueFromOrder(mObjRow, 'ROW_BILL_LOCALTAMOUNT');
            mText := NxSearchReplace(mText, '<!--ROW_BILL_LOCALTAMOUNT//-->', FormatFloat('0.00,', mAmount), [srAll]);
            ABillRowsAmountWIV := ABillRowsAmountWIV + mAmount;
          end;
          RunScript(ABO.ObjectSpace, mObjRow, mText, AExternalScript);
        end;
        if (mObjRow.GetFieldCode('RowType') > 0) and (mObjRow.GetFieldValueAsInteger('RowType') = 4) then
          mText := '';
        result := result + mText;
      end
    finally
      mObjList.Free;
    end;
  end;
end;

//k řádku DL vrací hodnoty z řádku OP

function GetBillRowValueFromOrder(ARowBO: TNxCustomBusinessObject; AValue: string): Variant;
var mOrderRowID: string;
  mOrderRowBO: TNxCustomBusinessObject;
begin
  result := 0;
  mOrderRowID := ARowBO.GetFieldValueAsString('ProvideRow_ID');
  if not NxIsEmptyOID(mOrderRowID) then begin
    mOrderRowBO := ARowBO.ObjectSpace.CreateObject(Class_ReceivedOrderRow);
    try
      mOrderRowBO.Load(mOrderRowID, nil);
      if (AValue = 'ROW_BILL_DISC_UNITPRICE_WIV') and (ARowBO.GetFieldValueAsInteger('RowType') = 3) then begin
        result := mOrderRowBO.GetFieldValueAsFloat('TAmount') / mOrderRowBO.GetFieldValueAsFloat('Quantity');
      end;
      if (AValue = 'ROW_BILL_LOCALTAMOUNT') and (ARowBO.GetFieldValueAsInteger('RowType') = 3) then begin
        result := ARowBO.GetFieldValueAsFloat('UnitQuantity') * (mOrderRowBO.GetFieldValueAsFloat('TAmount') / mOrderRowBO.GetFieldValueAsFloat('Quantity'));
      end;
    finally
      mOrderRowBO.Free;
    end;
  end;
end;

function GetFirmNameFromPerson(AOS: TNxCustomObjectSpace; APersonID: string): string;
var mSQL: string;
begin
  mSQL := Format('Select F.Name as dbvalue from FirmsPersons A JOIN Firms F ON F.ID=A.Firm_ID where A.Person_ID=%s', [QuotedStr(APersonID)]);
  result := GetSQLValue(AOS, mSQL, '');
end;

function PrintDocToFile(AOS: TNxCustomObjectSpace; AObjID, AReportID, AFileName, ADynSQLCLSID: string; AFileType: Integer): string;
var mPath: string;
  mContext: TNxContext;
  mIDs: TStrings;
begin
  result := '';
  mContext := NxCreateContext(AOS);
  mIDs := TStringList.Create;
  try
    mIDs.Add(AObjID);
    mPath := NxGetTempDir;
    CFxReportManager.PrintByIDs(mContext, mIDs, ADynSQLCLSID, AReportID, rtoFile, AFileType, mPath, AFileName);
    result := NxAddSlash(mPath) + AFileName;
  finally
    mContext.free;
    mIDs.Free;
  end;
end;

procedure SendSMS(ABO: TNxCustomBusinessObject; AMessage: string; AGate: Integer; AUserName, APassword, AOwnVariableField, AExternalScript: string);
var mText: string;
  mPhoneNumber: string;
  mURL, mTime, mSalt, mAuth, mErrText: string;
  mResponse: TStrings;
  mErr: Integer;
  mXMLResult: TNxScriptingXMLWrapper;
  mBytes: TBytes;
begin
  mText := AMessage;
  mPhoneNumber := GetPhoneNumber(ABO);
  if NxIsBlank(mPhoneNumber) = false then begin
    mResponse := TStringList.Create;
    mXMLResult := TNxScriptingXMLWrapper.Create;
    try
      ProcessText(mText, '', ABO, '', AOwnVariableField, AExternalScript);
      if AGate = 0 then begin //www.smsbrana.cz
        //zabezpečené přihlášení
        mTime := FormatDateTime('YYYYMMDD', now) + 'T' + FormatDateTime('HHMMSS', now);
        mSalt := ABO.CLSID + ABO.OID + FormatDateTime('HHMMSS', now);
        mAuth := CFxHash.NxGetHashOfString(APassword + mTime + mSalt, halg_MD5, true);
        mURL := 'https://api.smsbrana.cz/smsconnect/http.php';
        mURL := mURL + '?login=' + AUserName;
        mURL := mURL + '&time=' + mTime;
        mURL := mURL + '&salt=' + mSalt;
        mURL := mURL + '&auth=' + mAuth;
        mURL := mURL + '&action=send_sms';
        mURL := mURL + '&number=' + mPhoneNumber;
        mURL := mURL + '&message=' + mText;

        { //jednoduché přihlášení s otevřeným heslem
          mURL := 'https://api.smsbrana.cz/smsconnect/http.php';
          mURL := mURL + '?login=' + AUserName;
          mURL := mURL + '&password=' + APassword;
          mURL := mURL + '&action=send_sms';
          mURL := mURL + '&number=' + mPhoneNumber;
          mURL := mURL + '&message=' + mText;
        }
        CFxInternet.HTTPGetText(CFxInternet.URLEncode(mURL), '', mResponse);
        mBytes := TEncoding.UTF8.GetBytes(mResponse.Text);
        mXMLResult.loadFromBytes(mBytes);
        mErr := mXMLResult.getElementAsInteger('err');
        if mErr <> 0 then begin
          mErrText := 'Chyba odeslání SMS: ';
          case mErr of
            -1: mErrText := mErrText + 'duplicitní ”user_id” - stejně označená SMS byla odeslaná již v minulosti';
            1: mErrText := mErrText + 'neznámá chyba';
            2: mErrText := mErrText + 'neplatný login';
            3: mErrText := mErrText + 'neplatný ”hash” nebo ”password”';
            4: mErrText := mErrText + 'neplatný ”time”, větší odchylka času mezi servery než maximální akceptovaná v nastavení služby SMS Connect';
            5: mErrText := mErrText + 'nepovolená IP, viz nastavení služby SMS Connect';
            6: mErrText := mErrText + 'neplatný název akce';
            7: mErrText := mErrText + 'tato ”salt” byla již jednou za daný den použita';
            8: mErrText := mErrText + 'nebylo navázáno spojení s databází';
            9: mErrText := mErrText + 'nedostatečný kredit';
            10: mErrText := mErrText + 'neplatné číslo příjemce SMS';
            11: mErrText := mErrText + 'prázdný text zprávy';
            12: mErrText := mErrText + 'SMS je delší než povolených 459 znaků';
          end;
          OutputDebugString(mErrText);
        end;
      end;
    finally
      mResponse.Free;
      mXMLResult.free;
    end;
  end;
end;

function GetSQLValue(AOS: TNxCustomObjectSpace; ASQL: string; ADefault: Variant): Variant;
var mDts: TDataset;
begin
  result := ADefault;
  mDts := TMemoryDataset.Create(nil);
  try
    AOS.SQLSelect2(ASQL, mDts);
    if mDts.Active then begin
      mDts.First;
      while not mDts.Eof do begin
        result := mDts.FieldValues('dbvalue');
        mDts.Next;
      end;
    end;
  finally
    mDts.Free;
  end;
end;

function CheckDefinitionExists(AOS: TNxCustomObjectSpace; AAction: Integer): Boolean;
var mSQL, mID: string;
begin
  result := false;
  mSQL := Format('Select ID as dbvalue from DefRollData where Hidden=''N'' and CLSID=%s and X_SystemAction=%s', [QuotedStr(cDefRollCLSID), IntToStr(AAction)]);
  mID := GetSQLValue(AOS, mSQL, '');
  if not NxIsEmptyOID(mID) then
    result := true;
end;

//vrátí ID prvního obrázku z databáze

function GetFirstPictureID(AOS: TNxCustomObjectSpace; AStorecardID: string): string;
var mStr: TStrings;
  mSQL: string;
begin
  result := '';
  mStr := TStringList.Create;
  try
    mSQL := Format('Select Picture_ID from StoreCardPictures where Parent_ID=%s order by PosIndex', [QuotedStr(AStorecardID)]);
    AOS.SQLSelect(mSQL, mStr);
    if mStr.Count > 0 then
      result := mStr.Strings[0];
  finally
    mStr.Free;
  end;
end;

function GetCountryID(AOS: TNxCustomObjectSpace; ACountryCode: string): string;
var mSQL, mID: string;
  mCont: TNxContext;
begin
  result := '';
  mSQL := Format('Select ID as dbvalue from Countries where Code=%s and Hidden=%s', [QuotedStr(ACountryCode), QuotedStr('N')]);
  mID := GetSQLValue(AOS, mSQL, '');
  if mID <> '' then
    result := mID
  else begin
    mCont := NxCreateContext(AOS);
    try
      result := mCont.GetCompanyCache.CountryID;
    finally
      mCont.Free;
    end;
  end;
end;

//vrátí název prvního obrázku z folderu

function GetPictureName(AOS: TNxCustomObjectSpace; ASubPath: string): string;
var mPicList: TStringList;
begin
  mPicList := TStringList.Create;
  mPicList.Sorted := True;
  try
    NxGetFileList(NxAddSlash(cImagesLocalPath) + ASubPath + '\', mPicList, '*.*', false);
    if mPicList.Count > 2 then begin
      result := mPicList[2];
      result := CFxInternet.PathEncode({NxAddSlash(cImagesLocalPath)+}ASubPath + '\' + result);
      mPicList.Sort;
    end else
      result := '';
  finally
    mPicList.Free;
  end;
end;

function GetCountryIDByName(AOS: TNxCustomObjectSpace; ACountryName: string): string;
var mSQL, mID: string;
  mCont: TNxContext;
begin
  result := '';
  mSQL := Format('Select ID as dbvalue from Countries where Name=%s and Hidden=%s', [QuotedStr(ACountryName), QuotedStr('N')]);
  result := GetSQLValue(AOS, mSQL, '');
end;

function GetConcatChar: string;
begin
  if (CFxNxRuntime.NxGetDatabaseCode = 'IB') or (CFxNxRuntime.NxGetDatabaseCode = 'ORA') then
    result := ' || '
  else
    result := ' + ';
end;

function GetCompanyParam(AOS: TNxCustomObjectSpace; AGUID: string): integer;
var mSQL: string;
  mStr: TStrings;
begin
  result := 0;
  mSQL := Format('Select NumValue from COMPANYPARAMETERS where GUID=%s', [QuotedStr(AGUID)]);
  mStr := TStringList.Create;
  try
    AOS.SQLSelect(mSQL, mStr);
    if mStr.Count > 0 then
      result := StrToInt(mStr.Strings[0]);
  finally
    mStr.Free;
  end;
end;


function GetValueFromReceivedOrder(AOS: TNxCustomObjectSpace; AOrderID, AValue: string): string;
var mBO: TNxCustomBusinessObject;
begin
  result := '';
  mBO := AOS.CreateObject(Class_ReceivedOrder);
  try
    mBO.Load(AOrderID, nil);
    result := mBO.GetFieldValueAsString(AValue);
  finally
    mBO.free;
  end;
end;

//vrátí první OP k DL

function GetFirstOrderIDToBillOfDelivery(ABO: TNxCustomBusinessObject): string;
var mSQL, mID: string;
  mStr: TStrings;
begin
  result := '';
  if Assigned(ABO) then begin
    mSQL := 'Select RO.ID' +
      ' from StoreDocuments2 A ' +
      ' JOIN ReceivedOrders RO ON RO.ID=A.Provide_ID' +
      Format(' where RO.ID is not null and A.Parent_ID=%s', [QuotedStr(ABO.OID)]) +
    ' order by RO.OrdNumber';
    mStr := TStringList.Create;
    try
      ABO.ObjectSpace.SQLSelect(mSQL, mStr);
      if mStr.Count > 0 then begin
        result := mStr.Strings[0];
      end;
    finally
      mStr.Free;
    end;
  end;
end;

//vrátí první OP k FV

function GetFirstOrderIDToIssuedInvoice(ABO: TNxCustomBusinessObject): string;
var mSQL, mID: string;
  mStr: TStrings;
begin
  result := '';
  if Assigned(ABO) then begin
    mSQL := 'Select RO.ID' +
      ' from IssuedInvoices2 A' +
      ' JOIN StoreDocuments2 SD2 ON SD2.ID=A.ProvideRow_ID' +
      ' JOIN ReceivedOrders RO ON RO.ID=SD2.Provide_ID' +
      Format(' where RO.ID is not null and SD2.ID is not null and A.Parent_ID=%s', [QuotedStr(ABO.OID)]) +
    ' order by RO.OrdNumber';
    mStr := TStringList.Create;
    try
      ABO.ObjectSpace.SQLSelect(mSQL, mStr);
      if mStr.Count > 0 then begin
        result := mStr.Strings[0];
      end;
    finally
      mStr.Free;
    end;
  end;
end;

procedure AttachDocuments(AObj: TNxCustomBusinessObject; var AEmailSent: TNxCustomBusinessObject);
var mSQL: string;
  mStr: TStrings;
  mRelDef: Integer;
  i: integer;
  mAttachment: TNxCustomBusinessObject;
  mAttachments: TNxCustomBusinessMonikerCollection;
begin
  mRelDef := GetDocRelDef(AObj.CLSID);
  mSQL := Format('Select R.RightSide_ID from Relations R where R.LeftSide_ID=%s and R.Rel_def=%s',
    [QuotedStr(AObj.OID), IntTOStr(mRelDef)]);
  mStr := TStringList.Create;
  try
    AObj.ObjectSpace.SQLSelect(mSQL, mStr);
    for i := 0 to mStr.Count - 1 do begin
      mAttachments := AEmailSent.GetCollectionMonikerForFieldCode(AEmailSent.GetFieldCode('Attachments'));
      mAttachment := mAttachments.AddNewObject;
      mAttachment.Prefill;
      mAttachment.SetFieldValueAsInteger('ContentType', 1);
      mAttachment.SetFieldValueAsString('Document_ID', mStr.Strings[i]);
    end;
  finally
    mStr.free;
  end;
end;

function GetDocRelDef(ACLSID: string): Integer;
begin
  result := -1;
  case ACLSID of
    Class_IssuedInvoice: result := 600;
    Class_IssuedCreditNote: result := 605;
    Class_CashReceived: result := 607;
    Class_IssuedDepositInvoice: result := 615;
    Class_IssuedOrder: result := 632;
    Class_ReceivedOrder: result := 633;
    Class_VATIssuedDepositInvoice: result := 663;
    Class_VATIssuedDepositCreditNote: result := 664;
    Class_IssuedOffer: result := 675;
  end;
end;

function GetSQLValuesAsStrings(AOS: TNxCustomObjectSpace; ASQL: string; var AStr: TStrings): Boolean;
begin
  result := false;
  AStr.Clear;
  AOS.SQLSelect(ASQL, AStr);
  if AStr.count > 0 then
    result := true;
end;

function HashString(AFirmID, ADocID: string; AMethod: TNxHashAlgorithm): string;
begin
  result := CFxHash.NxGetHashOfString(AFirmID + ADocID, AMethod, true);
end;

//vrací url adresu produktu na eshopu (bez hlavní domény)

function GetProductURL(Name: string): string;
var mNameTMP: string;
begin
  result := '';
  mNameTMP := AnsiLowerCase(Name);
  mNameTMP := NxRemoveDiacritics(mNameTMP);
  mNameTMP := NxCorrectText(mNameTMP, '0123456789abcdefghijklmnopqrstuvwxyzáěéčďíóřšťúůýž', '-');
  mNameTMP := NxSearchReplace(mNameTMP, '------', '-', [srAll]);
  mNameTMP := NxSearchReplace(mNameTMP, '-----', '-', [srAll]);
  mNameTMP := NxSearchReplace(mNameTMP, '----', '-', [srAll]);
  mNameTMP := NxSearchReplace(mNameTMP, '---', '-', [srAll]);
  mNameTMP := NxSearchReplace(mNameTMP, '--', '-', [srAll]);
  mNameTMP := NxTrim(mNameTMP, '-');

  result := mNameTMP + '/';
end;

function GetMaxStringLength: integer;
begin
  result := 65530;
  if CFxNxRuntime.NxGetDatabaseCode = 'ORA' then
    result := 3999
  else if CFxNxRuntime.NxGetDatabaseCode = 'IB' then
    result := 16300
  else if CFxNxRuntime.NxGetDatabaseCode = 'MSSQL' then
    result := 65530;
end;


procedure RunScript(AOS: TNxCustomObjectSpace; ABO: TNxCustomBusinessObject; var AText, AScriptName: string);
var mText: string;
begin
  if AScriptName <> '' then begin
    try
      mText := CFxScriptingEngine.CallScript(AScriptName, [ObjToInt(AOS), ObjToInt(ABO), AText]);
      AText := mText;
    except
      OutputDebugString('Chyba při zpracování externího skriptu ' + ExceptionMessage);
    end;
  end;
end;


procedure AddDebugLog(AMessage: string);
begin
  NxScriptingLog.WriteEvent(logDebug, AMessage);
  OutputDebugString(AMessage);
end;

begin
end.
