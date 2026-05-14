uses
  'REST_SkladTerm.U_Func',
  'REST_SkladTerm.U_Queue',
  'REST_SkladTerm_Special.U_StandardHooks';

////////////////////////////////////////////////////////////////////////////////
procedure put_LoginToSystem(Self: TNxWebServicesHelper; ARequest: TNxHTTPRequest;
  AResponse: TNxHTTPResponse; slPath: TStringList);
var
  mUsername, mPassword, mSecurityUser_ID: String;
  version, loginCode: String;
  mSecurityUser, mStore, mDivision, mFirm: TNxCustomBusinessObject;
  jsonIn: TJSONSuperObject;
  json: TJSONSuperObject;
  dtLoggedUser: TMemTable;
  mSL: TStringList;
  mDeviceID, mDefaultStoreID, mDefaultFirmID: String;
  mVersionOK, mloginWithCode: Boolean;
begin
  jsonIn := TJSONSuperObject.ParseString(REST_ByteUTF82String(ARequest.Content.Content), false);
  try
    try
      mUsername := jsonIn.S['username'];
      mPassword := jsonIn.S['password'];
      version := jsonIn.S['version'];
      mloginWithCode := jsonIn.B['loginWithCode'];
      loginCode := jsonIn.S['code'];
    except
      ErrREST(ARequest, AResponse, HTTP_SC_BadRequest, ExceptionMessage);
      exit;
    end;
  finally
    jsonIn.Free;
  end;

  //zkontroluji login
  mSecurityUser := nil;
  if mLoginWithCode then
    mSecurityUser_ID := CustomCodeLogin(Self.ObjectSpace, loginCode)
  else if DomainLoginUsed then
    // pokud je zapnute domenove prihlasovani, NxVerifyUser nefunguje
    // v takovem pripade overujeme podle jmena a hesla, heslo ocekavame v poli X_Password na uzivateli
    mSecurityUser_ID := SQLSelectStr(Self.ObjectSpace, 'select ID from SecurityUsers where LoginName = ' +
      QuotedStr(mUsername) + ' and X_Password = ' + QuotedStr(mPassword))
  else
    mSecurityUser_ID := NxVerifyUser(Self.ObjectSpace, mUsername, mPassword);

  if(not NxIsEmptyOID(mSecurityUser_ID))then
  begin
    mSecurityUser := Self.ObjectSpace.CreateObject(Class_SecurityUser);
    mSecurityUser.Load(mSecurityUser_ID, nil);
  end
  else
  begin
    mSecurityUser := nil;
  end;

  //odpoved
  LogWriteSectionStart('JSON');
  json := TJSONSuperObject.CreateByDataType(jtObject);
  mStore := Self.ObjectSpace.CreateObject(Class_Store);
  mDivision := Self.ObjectSpace.CreateObject(Class_Division);
  mFirm := Self.ObjectSpace.CreateObject(Class_Firm);
  dtLoggedUser := TMemTable.Create(nil);
  try
    //--------------------------------------------------------------------------
    if(not Assigned(mSecurityUser))then begin
      gLog.WriteEventFmt(logWarning, 'login incorrect:%s/%s', [mUsername, mPassword]);
    end else
    begin
      gLog.WriteEventFmt(logNotice, 'login ok:%s', [mUsername]);

      try
        mStore.Load(getStoreForUser(Self.ObjectSpace, mSecurityUser_ID), nil);
      except
        RaiseException(getString('user_no_store'));
      end;

      //json_addValue(sl, 'firmName'   , Self.ObjectSpace.GetConnectionName);
      json.S['id'] := mSecurityUser.GetFieldValueAsString('ID');
      json.S['name'] := mSecurityUser.GetFieldValueAsString('Name');
      mVersionOK := True;
      if version <> CLIENT_CURRENT_VERSION then
      begin
        json.S['new_version'] := CLIENT_CURRENT_VERSION;
        json.S['update_url'] := CLIENT_CURRENT_VERSION_URL;
        mVersionOK := False;
      end;
      json.S['visible_modules'] := ModifyVisibleModulesString(Self.ObjectSpace, mStore.OID, mSecurityUser.GetFieldValueAsString('ID'));
      json.I['connection_timeout'] := CLIENT_CONNECTION_TIMEOUT;
      json.I['connection_timeout_long'] := CLIENT_CONNECTION_TIMEOUT_LONG;

      json.S['user_store_id'] := mStore.OID;
      json.S['user_store_code'] := mStore.GetFieldValueAsString('Code');
      json.B['user_store_is_logistic'] := mStore.GetFieldValueAsBoolean('IsLogistic');

      try
        mStore.Load(SKLAD_HLAVNI, nil);
      except
        RaiseException(getString('no_main_store'));
      end;
      json.S['main_store_id'] := mStore.OID;
      json.S['main_store_code'] := mStore.GetFieldValueAsString('Code');

      try
        mDivision.Load(getDivisionForUser(Self.ObjectSpace, mSecurityUser_ID), nil);
      except
        RaiseException(getString('user_no_division'));
      end;
      json.S['user_division_id'] := mDivision.OID;
      json.S['user_division_code'] := mDivision.GetFieldValueAsString('Code');

      json.S['connection_name'] := Self.Context.GetConnectionName;
      json.S['company_name'] := Self.Context.GetCompanyCache.CompanyName;
      json.S['erp_system'] := NxIIfStr(ABRA, 'ABRA', 'FLORES');

      json.B['enable_logging'] := enableLogging(Self.ObjectSpace, mSecurityUser_ID);

      try
        mDefaultStoreID := getDefaultStoreForUser(Self.ObjectSpace, mSecurityUser_ID);
        if mDefaultStoreID <> '' then
        begin
          mStore.Load(mDefaultStoreID, nil);
          json.S['default_store_id'] := mStore.OID;
          json.S['default_store_code'] := mStore.GetFieldValueAsString('Code');
          json.B['default_store_is_logistic'] := mStore.GetFieldValueAsBoolean('IsLogistic');
        end
        else
        begin
          json.S['default_store_id'] := '';
          json.S['default_store_code'] := '';
          json.B['default_store_is_logistic'] := false;
        end;
      except
        json.S['default_store_id'] := '';
        json.S['default_store_code'] := '';
      end;

      json.B['noncancelable_work'] := NoncancelableWork;
      json.S['custom_fields'] := customFields(Self.ObjectSpace, json.S['id']);
      json.S['soft_input_disabled'] := disableSoftInputKeyboard(Self.ObjectSpace, json.S['id']);
      json.S['aux_field'] := LoginObjectAuxField(json.S['id']);
      json.I['decimal_places'] := DecimalPlaces;
      json.S['barcode_button_scenarios'] := ShowBarcodeButton(json.S['id']);
      json.B['show_document_queue_count'] := ShowDocumentQueueCount;
      json.I['mainmenu_buttons_refresh_time'] := MAINMENU_BUTTONS_REFRESH_TIME;
      json.B['show_quick_support_action'] := ShowQuickSupportAction;
      json.S['special_barcode_handling_modules'] := specialBarcodeHandling(json.S['id']);
      json.B['notConfirmedSerNumsToNewRow'] := NotConfirmedSerNumsToNewRow;
      json.B['serialNumbersConfirming'] := SerialNumbersConfirming;
      json.B['showDialogOnSave'] := ShowDialogOnSave;
      json.B['useUnitsEANs'] := UseUnitsEANs;
      json.S['barcodeFocusOnly'] := BarcodeFocusOnly(Self.ObjectSpace, json.S['id']);

      // ABRA na uzivateli nema odkaz do osob
      if not ABRA then
       json.S['person_id'] := mSecurityUser.GetFieldValueAsString('Person_ID');

      try
        mDefaultFirmID := getDefaultFirmForUser(Self.ObjectSpace, mSecurityUser_ID);
        if mDefaultFirmID <> '' then
        begin
          mFirm.Load(mDefaultFirmID, nil);
          json.S['default_firm_id'] := mFirm.OID;
          json.S['default_firm_name'] := mFirm.GetFieldValueAsString('Name');
        end
        else
        begin
          json.S['default_firm_id'] := '';
          json.S['default_firm_name'] := '';
        end;
      except
        json.S['default_firm_id'] := '';
        json.S['default_firm_name'] := '';
      end;

      // kontrola, jestli uz tento uzivatel neni prihlaseny v jine ctecce
      if DuplicateLoginCheck and mVersionOK then
      begin
        mSL := TStringList.Create;
        try
          mSL.Text := ARequest.Header.AllHeaders;
          mDeviceID := mSL.Values['DeviceID'];
        finally
          mSL.Free;
        end;
        Self.ObjectSpace.SQLSelect2(
          'select SU.LoginName, LU.DeviceID, ' +
          '  (select DRD.Code from UserData UD ' +
          '   join DefRollData DRD on DRD.ID = UD.ID ' +
          '   where UD.CLSID = ''RV5F5HCAZ41OD0QWKMGRZI0VD0'' ' +
          '     and UD.FieldCode = 2000001 and UD.StringFieldValue = LU.DeviceID ' +
          '  ) as DeviceCode ' +
          'from REST_LoggedUsers LU ' +
          'join SecurityUsers SU on SU.ID = LU.User_ID ' +
          'where LU.User_ID = ' + QuotedStr(mSecurityUser_ID)
          , dtLoggedUser);
        if dtLoggedUser.Active then
        begin
          dtLoggedUser.First;
          gLog.WriteEventFmt(logNotice, 'current device ID:"%s", logged device ID: "%s", logged device code: "%s"',
            [mDeviceID, trim(dtLoggedUser.FieldByName('DeviceID').AsString), dtLoggedUser.FieldByName('DeviceCode').AsString]);
          if trim(dtLoggedUser.FieldByName('DeviceID').AsString) <> mDeviceID then
            RaiseException(Format(getString('user_already_logged'),
              [dtLoggedUser.FieldByName('LoginName').AsString, dtLoggedUser.FieldByName('DeviceCode').AsString]));
        end
        else begin
          Self.ObjectSpace.SQLExecute('insert into REST_LoggedUsers (DeviceID, User_ID, LoggedSince$DATE) values (' +
            QuotedStr(mDeviceID) + ', ' + QuotedStr(mSecurityUser_ID) + ', ' + NxFloatToIBStr(Now) + ') ');
        end;
      end;
    end;

    LogWriteSectionEnd;
    //--------------------------------------------------------------------------

    if Assigned(mSecurityUser) then
      HTTPResponse(AResponse, HTTP_SC_OK, ContentType_JSON, json.AsJson(false, true))
    else
      ErrREST(ARequest, AResponse, HTTP_SC_Unauthorized, 'BAD_CREDENTIALS');
  finally
    dtLoggedUser.Free;
    mDivision.Free;
    mStore.Free;
    mFirm.Free;
    if(Assigned(mSecurityUser)) then mSecurityUser.free;
    json.Free;
  end;
end;//get_LoginToSystem
////////////////////////////////////////////////////////////////////////////////

procedure put_Logout(Self: TNxWebServicesHelper; ARequest: TNxHTTPRequest;
  AResponse: TNxHTTPResponse; slPath: TStringList);
var
  mUser_ID: String;
begin
  mUser_ID := getHeaderValue(ARequest, 'UserID');

  LogWriteSectionStart('Logout: ' + mUser_Id);
  Self.ObjectSpace.SQLExecute('delete from REST_LoggedUsers ' +
    'where User_ID = ' + QuotedStr(mUser_ID));
  LogWriteSectionEnd;

  HTTPResponse(AResponse, HTTP_SC_OK, ContentType_JSON, PlainResponse(''));
end;

begin
end.