uses
  'REST_SkladTerm.U_Func',
  'REST_SkladTerm.U_FuncJSON',
  'REST_SkladTerm.U_SQLQueries',
  'REST_SkladTerm_Special.U_StandardHooks',
  'StandardUnits.U_GetId';

procedure get_BusOrderInfo(Self: TNxWebServicesHelper; ARequest: TNxHTTPRequest;
  AResponse: TNxHTTPResponse; slPath: TStringList);
var
  mBusOrder_ID, mModule, mUser_ID, mDocumentType: String;
  dtHeader: TMemTable;
  dtRows: TMemTable;
  mSL: TStringList;
  mSql: String;
  json: TJSONSuperObject;
begin
  json := nil;
  if (slPath.Count = 2) then
  begin
    mBusOrder_ID := slPath.Strings[1];
  end else
  begin
    ErrREST(ARequest, AResponse, HTTP_SC_BadRequest, getString('wrong_parameters_count'));
    exit;
  end;

  mModule := getHeaderValue(ARequest, 'ModuleCode');
  mUser_ID := getHeaderValue(ARequest, 'UserID');
  mDocumentType := getHeaderValue(ARequest, 'DocumentType');

  dtHeader := TMemTable.Create(nil);
  LogWriteSectionStart('get_BusOrderInfo');
  try
    mSql :=
      'select' + nxCrLf +
      '  BO.ID as "ID",' + nxCrLf +
      '  BO.Code as "Code",' + nxCrLf +
      '  BO.Name as "Name"' + nxCrLf +
      'from BusOrders BO' + nxCrLf +
      'where' + nxCrLf +
      '  BO.ID = ' + QuotedStr(mBusOrder_ID) + nxCrLf +
      '  and BO.Hidden = ''N''';
    Self.ObjectSpace.SQLSelect2(mSql, dtHeader);

    if dtHeader.Active then
    begin
      dtHeader.First;
      LogWriteSectionStart('JSON');
      json := REST_jsonCreate_FromDataSetRow(dtHeader, nil, nil);
      LogWriteSectionEnd;

      HTTPResponse(AResponse, HTTP_SC_OK, ContentType_JSON, json.AsJson(false, true));
    end
    else begin
      ErrREST(ARequest, AResponse, HTTP_SC_NotFound, Format(getString('busorder_not_found'), [mBusOrder_ID]));
    end;
  finally
    dtHeader.Free;
    if Assigned(json) then
      json.Free;
    LogWriteSectionEnd;
  end;
end;

procedure get_DivisionInfo(Self: TNxWebServicesHelper; ARequest: TNxHTTPRequest;
  AResponse: TNxHTTPResponse; slPath: TStringList);
var
  mDivision_ID, mModule, mUser_ID, mDocumentType: String;
  dtHeader: TMemTable;
  dtRows: TMemTable;
  mSL: TStringList;
  mSql: String;
  json: TJSONSuperObject;
begin
  json := nil;
  if (slPath.Count = 2) then
  begin
    mDivision_ID := slPath.Strings[1];
  end else
  begin
    ErrREST(ARequest, AResponse, HTTP_SC_BadRequest, getString('wrong_parameters_count'));
    exit;
  end;

  mModule := getHeaderValue(ARequest, 'ModuleCode');
  mUser_ID := getHeaderValue(ARequest, 'UserID');
  mDocumentType := getHeaderValue(ARequest, 'DocumentType');

  dtHeader := TMemTable.Create(nil);
  LogWriteSectionStart('get_DivisionInfo');
  try
    mSql :=
      'select' + nxCrLf +
      '  D.ID as "ID",' + nxCrLf +
      '  D.Code as "Code",' + nxCrLf +
      '  D.Name as "Name"' + nxCrLf +
      'from Divisions D' + nxCrLf +
      'where' + nxCrLf +
      '  D.ID = ' + QuotedStr(mDivision_ID) + nxCrLf +
      '  and D.Hidden = ''N''';
    Self.ObjectSpace.SQLSelect2(mSql, dtHeader);

    if dtHeader.Active then
    begin
      dtHeader.First;
      LogWriteSectionStart('JSON');
      json := REST_jsonCreate_FromDataSetRow(dtHeader, nil, nil);
      LogWriteSectionEnd;

      HTTPResponse(AResponse, HTTP_SC_OK, ContentType_JSON, json.AsJson(false, true));
    end
    else begin
      ErrREST(ARequest, AResponse, HTTP_SC_NotFound, Format(getString('division_not_found'), [mDivision_ID]));
    end;
  finally
    dtHeader.Free;
    if Assigned(json) then
      json.Free;
    LogWriteSectionEnd;
  end;
end;

procedure get_DocQueueInfo(Self: TNxWebServicesHelper; ARequest: TNxHTTPRequest;
  AResponse: TNxHTTPResponse; slPath: TStringList);
var
  mDocQueue_ID, mModule, mUser_ID, mDocumentType: String;
  dtHeader: TMemTable;
  dtRows: TMemTable;
  mSL: TStringList;
  mSql: String;
  json: TJSONSuperObject;
begin
  json := nil;
  if (slPath.Count = 2) then
  begin
    mDocQueue_ID := slPath.Strings[1];
  end else
  begin
    ErrREST(ARequest, AResponse, HTTP_SC_BadRequest, getString('wrong_parameters_count'));
    exit;
  end;

  mModule := getHeaderValue(ARequest, 'ModuleCode');
  mUser_ID := getHeaderValue(ARequest, 'UserID');
  mDocumentType := getHeaderValue(ARequest, 'DocumentType');

  dtHeader := TMemTable.Create(nil);
  LogWriteSectionStart('get_DocQueueInfo');
  try
    mSql :=
      'select' + nxCrLf +
      '  DQ.ID as "ID",' + nxCrLf +
      '  DQ.Code as "Code",' + nxCrLf +
      '  DQ.Name as "Name"' + nxCrLf +
      'from DocQueues DQ' + nxCrLf +
      'where' + nxCrLf +
      '  DQ.ID = ' + QuotedStr(mDocQueue_ID) + nxCrLf +
      '  and DQ.DocumentType = ' + QuotedStr(mDocumentType) +
      '  and DQ.Hidden = ''N''';
    Self.ObjectSpace.SQLSelect2(mSql, dtHeader);


    if dtHeader.Active then
    begin
      dtHeader.First;
      LogWriteSectionStart('JSON');
      json := REST_jsonCreate_FromDataSetRow(dtHeader, nil, nil);
      LogWriteSectionEnd;

      HTTPResponse(AResponse, HTTP_SC_OK, ContentType_JSON, json.AsJson(false, true));
    end
    else begin
      ErrREST(ARequest, AResponse, HTTP_SC_NotFound, Format(getString('docqueue_not_found'), [mDocQueue_ID]));
    end;
  finally
    dtHeader.Free;
    if Assigned(json) then
      json.Free;
    LogWriteSectionEnd;
  end;
end;

procedure get_FirmOfficeInfo(Self: TNxWebServicesHelper; ARequest: TNxHTTPRequest;
  AResponse: TNxHTTPResponse; slPath: TStringList);
var
  mFirmOffice_ID, mFirm_ID, mModule, mUser_ID, mDocumentType: String;
  dtHeader: TMemTable;
  dtRows: TMemTable;
  mSL: TStringList;
  mSql: String;
  json: TJSONSuperObject;
begin
  json := nil;
  if (slPath.Count = 3) then
  begin
    mFirmOffice_ID := slPath.Strings[1];
    mFirm_ID := slPath.Strings[2];
  end else
  begin
    ErrREST(ARequest, AResponse, HTTP_SC_BadRequest, getString('wrong_parameters_count'));
    exit;
  end;

  mModule := getHeaderValue(ARequest, 'ModuleCode');
  mUser_ID := getHeaderValue(ARequest, 'UserID');
  mDocumentType := getHeaderValue(ARequest, 'DocumentType');

  dtHeader := TMemTable.Create(nil);
  LogWriteSectionStart('get_FirmOfficeInfo');
  try
    mSql :=
      'select' + nxCrLf +
      '  FO.ID as "ID",' + nxCrLf +
      '  '''' as "Code",' + nxCrLf +
      '  FO.Name as "Name",' + nxCrLf +
      '  FO.Parent_ID as "Parent_ID"' + nxCrLf +
      'from FirmOffices FO' + nxCrLf +
      'where' + nxCrLf +
      '  FO.ID = ' + QuotedStr(mFirmOffice_ID) + nxCrLf;

    if not ABRA then
      mSql := mSql +
        '  and FO.Hidden = ''N''';
    Self.ObjectSpace.SQLSelect2(mSql, dtHeader);

    if dtHeader.Active then
    begin
      dtHeader.First;

      if dtHeader.FieldByName('Parent_ID').AsString <> mFirm_ID then
      begin
        RaiseException(getString('firmoffice_not_belong_to_firm'));
      end;

      LogWriteSectionStart('JSON');
      json := REST_jsonCreate_FromDataSetRow(dtHeader, nil, nil);
      LogWriteSectionEnd;

      HTTPResponse(AResponse, HTTP_SC_OK, ContentType_JSON, json.AsJson(false, true));
    end
    else begin
      ErrREST(ARequest, AResponse, HTTP_SC_NotFound, Format(getString('firmoffice_not_found'), [mFirmOffice_ID]));
    end;
  finally
    dtHeader.Free;
    if Assigned(json) then
      json.Free;
    LogWriteSectionEnd;
  end;
end;

procedure get_PersonInfo(Self: TNxWebServicesHelper; ARequest: TNxHTTPRequest;
  AResponse: TNxHTTPResponse; slPath: TStringList);
var
  mPerson_ID, mFirm_ID, mModule, mUser_ID: String;
  dtHeader: TMemTable;
  dtRows: TMemTable;
  mSL: TStringList;
  mSql: String;
  json: TJSONSuperObject;
begin
  json := nil;
  mFirm_ID := '';

  if (slPath.Count = 2) or (slPath.Count = 3) then
  begin
    mPerson_ID := slPath.Strings[1];
    if slPath.Count = 3 then
      mFirm_ID := slPath.Strings[2];
  end else
  begin
    ErrREST(ARequest, AResponse, HTTP_SC_BadRequest, getString('wrong_parameters_count'));
    exit;
  end;

  mModule := getHeaderValue(ARequest, 'ModuleCode');
  mUser_ID := getHeaderValue(ARequest, 'UserID');

  dtHeader := TMemTable.Create(nil);
  LogWriteSectionStart('get_PersonInfo');
  try
    mSql :=
      'select' + nxCrLf +
      '  P.ID as "ID",' + nxCrLf +
      '  P.FirstName ' + CONCAT_STR + ' '' '' ' + CONCAT_STR + ' P.LastName as "Code",' + nxCrLf +
      '  P.FirstName ' + CONCAT_STR + ' '' '' ' + CONCAT_STR + ' P.LastName as "Name"' + nxCrLf +
      'from Persons P' + nxCrLf;

    // pokud je firma, tak osoby omezime pouze na ni
    if not CFxOID.IsEmpty(mFirm_ID) then
      mSql := mSql +
        'join FirmPersons FP on FP.Person_ID = P.ID and FP.Parent_ID = ' + QuotedStr(mFirm_ID) + nxCrLf;

    mSql := mSql +
      'where' + nxCrLf +
      '  P.ID = ' + QuotedStr(mPerson_ID) +
      '  and P.Hidden = ''N''';
    Self.ObjectSpace.SQLSelect2(mSql, dtHeader);

    if dtHeader.Active then
    begin
      dtHeader.First;
      LogWriteSectionStart('JSON');
      json := REST_jsonCreate_FromDataSetRow(dtHeader, nil, nil);
      LogWriteSectionEnd;

      HTTPResponse(AResponse, HTTP_SC_OK, ContentType_JSON, json.AsJson(false, true));
    end
    else begin
      ErrREST(ARequest, AResponse, HTTP_SC_NotFound, Format(getString('person_not_found'), [mPerson_ID]));
    end;
  finally
    dtHeader.Free;
    if Assigned(json) then
      json.Free;
    LogWriteSectionEnd;
  end;
end;

procedure get_TransportationTypeInfo(Self: TNxWebServicesHelper; ARequest: TNxHTTPRequest;
  AResponse: TNxHTTPResponse; slPath: TStringList);
var
  mTransportationType_ID, mModuleName, mUser_ID: String;
  dtHeader: TMemTable;
  dtRows: TMemTable;
  mSL: TStringList;
  mSql: String;
  json: TJSONSuperObject;
begin
  json := nil;
  if (slPath.Count = 2) then
  begin
    mTransportationType_ID := slPath.Strings[1]; //ocekavam sklad
  end else
  begin
    ErrREST(ARequest, AResponse, HTTP_SC_BadRequest, getString('wrong_parameters_count'));
    exit;
  end;

  mModuleName := getHeaderValue(ARequest, 'ModuleCode');
  mUser_ID := getHeaderValue(ARequest, 'UserID');

  dtHeader := TMemTable.Create(nil);
  LogWriteSectionStart('get_TransportationTypeInfo');
  try
    mSql :=
      'select' + nxCrLf +
      '  TT.ID as "ID",' + nxCrLf +
      '  TT.Code as "Code",' + nxCrLf +
      '  TT.Name as "Name"' + nxCrLf +
      'from TransportationTypes TT' + nxCrLf +
      'where' + nxCrLf +
      '  TT.ID = ' + QuotedStr(mTransportationType_ID) + nxCrLf +
      '  and TT.Hidden = ''N''';
    Self.ObjectSpace.SQLSelect2(mSql, dtHeader);


    if dtHeader.Active then
    begin
      dtHeader.First;
      LogWriteSectionStart('JSON');
      json := REST_jsonCreate_FromDataSetRow(dtHeader, nil, nil);
      LogWriteSectionEnd;

      HTTPResponse(AResponse, HTTP_SC_OK, ContentType_JSON, json.AsJson(false, true));
    end
    else begin
      ErrREST(ARequest, AResponse, HTTP_SC_NotFound, Format(getString('transportationtype_not_found'), [mTransportationType_ID]));
    end;
  finally
    dtHeader.Free;
    if Assigned(json) then
      json.Free;
    LogWriteSectionEnd;
  end;
end;

procedure get_WorkplaceInfo(Self: TNxWebServicesHelper; ARequest: TNxHTTPRequest;
  AResponse: TNxHTTPResponse; slPath: TStringList);
var
  mWorkplace_ID, mModule, mUser_ID: String;
  dtHeader: TMemTable;
  dtRows: TMemTable;
  mSL: TStringList;
  mSql: String;
  json: TJSONSuperObject;
begin
  json := nil;
  if (slPath.Count = 2) then
  begin
    mWorkplace_ID := slPath.Strings[1];
  end else
  begin
    ErrREST(ARequest, AResponse, HTTP_SC_BadRequest, getString('wrong_parameters_count'));
    exit;
  end;

  mModule := getHeaderValue(ARequest, 'ModuleCode');
  mUser_ID := getHeaderValue(ARequest, 'UserID');

  dtHeader := TMemTable.Create(nil);
  LogWriteSectionStart('get_WorkplaceInfo');
  try
    mSql :=
      'select' + nxCrLf +
      '  WP.ID as "ID",' + nxCrLf +
      '  WP.Code as "Code",' + nxCrLf +
      '  WP.Title as "Name"' + nxCrLf +
      'from PRFWorkPlaces WP' + nxCrLf +
      'where' + nxCrLf +
      '  WP.ID = ' + QuotedStr(mWorkplace_ID) +
      '  and WP.Hidden = ''N''';
    Self.ObjectSpace.SQLSelect2(mSql, dtHeader);


    if dtHeader.Active then
    begin
      dtHeader.First;
      LogWriteSectionStart('JSON');
      json := REST_jsonCreate_FromDataSetRow(dtHeader, nil, nil);
      LogWriteSectionEnd;

      HTTPResponse(AResponse, HTTP_SC_OK, ContentType_JSON, json.AsJson(false, true));
    end
    else begin
      ErrREST(ARequest, AResponse, HTTP_SC_NotFound, Format(getString('workplace_not_found'), [mWorkplace_ID]));
    end;
  finally
    dtHeader.Free;
    if Assigned(json) then
      json.Free;
    LogWriteSectionEnd;
  end;
end;

procedure get_AssetLocationInfo(Self: TNxWebServicesHelper; ARequest: TNxHTTPRequest;
  AResponse: TNxHTTPResponse; slPath: TStringList);
var
  mAssetLocation_ID, mModule, mUser_ID: String;
  dtHeader: TMemTable;
  dtRows: TMemTable;
  mSL: TStringList;
  mSql: String;
  json: TJSONSuperObject;
begin
  json := nil;
  if (slPath.Count = 2) then
  begin
    mAssetLocation_ID := slPath.Strings[1];
  end else
  begin
    ErrREST(ARequest, AResponse, HTTP_SC_BadRequest, getString('wrong_parameters_count'));
    exit;
  end;

  mModule := getHeaderValue(ARequest, 'ModuleCode');
  mUser_ID := getHeaderValue(ARequest, 'UserID');

  dtHeader := TMemTable.Create(nil);
  LogWriteSectionStart('get_AssetLocationInfo');
  try
    mSql :=
      'select' + nxCrLf +
      '  AL.ID as "ID",' + nxCrLf +
      '  AL.Code as "Code",' + nxCrLf +
      '  AL.Name as "Name"' + nxCrLf +
      'from AssetLocations AL' + nxCrLf +
      'where' + nxCrLf +
      '  AL.ID = ' + QuotedStr(mAssetLocation_ID) +
      '  and AL.Hidden = ''N''';
    Self.ObjectSpace.SQLSelect2(mSql, dtHeader);

    LogWriteSectionEnd;

    if dtHeader.Active then
    begin
      dtHeader.First;
      LogWriteSectionStart('JSON');
      json := REST_jsonCreate_FromDataSetRow(dtHeader, nil, nil);

      HTTPResponse(AResponse, HTTP_SC_OK, ContentType_JSON, json.AsJson(false, true));
    end
    else begin
      ErrREST(ARequest, AResponse, HTTP_SC_NotFound, Format(getString('assetlocation_not_found'), [mAssetLocation_ID]));
    end;
  finally
    dtHeader.Free;
    if Assigned(json) then
      json.Free;
    LogWriteSectionEnd;
  end;
end;

procedure get_AssetResponsibleInfo(Self: TNxWebServicesHelper; ARequest: TNxHTTPRequest;
  AResponse: TNxHTTPResponse; slPath: TStringList);
var
  mAssetResponsible_ID, mModule, mUser_ID: String;
  dtHeader: TMemTable;
  dtRows: TMemTable;
  mSL: TStringList;
  mSql: String;
  json: TJSONSuperObject;
begin
  json := nil;
  if (slPath.Count = 2) then
  begin
    mAssetResponsible_ID := slPath.Strings[1];
  end else
  begin
    ErrREST(ARequest, AResponse, HTTP_SC_BadRequest, getString('wrong_parameters_count'));
    exit;
  end;

  mModule := getHeaderValue(ARequest, 'ModuleCode');
  mUser_ID := getHeaderValue(ARequest, 'UserID');

  dtHeader := TMemTable.Create(nil);
  LogWriteSectionStart('get_AssetResponsibleInfo');
  try
    mSql :=
      'select' + nxCrLf +
      '  AR.ID as "ID",' + nxCrLf +
      '  P.PersonalNumber as "Code",' + nxCrLf +
      '  P.FirstName ' + CONCAT_STR + ' '' '' ' + CONCAT_STR + ' P.LastName as "Name"' + nxCrLf +
      'from AssetResponsibles AR' + nxCrLf +
      'join Persons P on P.ID = AR.Person_ID' + nxCrLf +
      'where' + nxCrLf +
      '  AR.ID = ' + QuotedStr(mAssetResponsible_ID) +
      '  and P.Hidden = ''N''';
    Self.ObjectSpace.SQLSelect2(mSql, dtHeader);


    if dtHeader.Active then
    begin
      dtHeader.First;
      LogWriteSectionStart('JSON');
      json := REST_jsonCreate_FromDataSetRow(dtHeader, nil, nil);
      LogWriteSectionEnd;

      HTTPResponse(AResponse, HTTP_SC_OK, ContentType_JSON, json.AsJson(false, true));
    end
    else begin
      ErrREST(ARequest, AResponse, HTTP_SC_NotFound, Format(getString('assetresponsible_not_found'), [mAssetResponsible_ID]));
    end;
  finally
    dtHeader.Free;
    if Assigned(json) then
      json.Free;
    LogWriteSectionEnd;
  end;
end;

procedure get_SmallAssetCardInfo(Self: TNxWebServicesHelper; ARequest: TNxHTTPRequest;
  AResponse: TNxHTTPResponse; slPath: TStringList);
var
  mSmallAssetCard_ID, mModule, mUser_ID: String;
  mIsId: Boolean;
  dtHeader, dtRows: TMemTable;
  mSL: TStringList;
  mSql: String;
  json: TJSONSuperObject;
  mCount: Integer;
begin
  json := nil;
  if (slPath.Count = 3) then
  begin
    mSmallAssetCard_ID := slPath.Strings[1];
    mIsId := slPath.Strings[2] = 'true';
  end else
  begin
    ErrREST(ARequest, AResponse, HTTP_SC_BadRequest, getString('wrong_parameters_count'));
    exit;
  end;

  mModule := getHeaderValue(ARequest, 'ModuleCode');
  mUser_ID := getHeaderValue(ARequest, 'UserID');

  dtHeader := TMemTable.Create(nil);
  LogWriteSectionStart('get_SmallAssetCardInfo');
  try
    // POZOR, zde se vraci namisto fieldu ciselniku (ID, Code, Name) fieldy pro StoreCard (StoreCard_ID, StoreCardCode, ...),
    // protoze je potreba to volat i behem specialniho parsovani
    mSql := GetSmallAssetCardInfoSql(Self.ObjectSpace, mSmallAssetCard_ID, mIsId);

    Self.ObjectSpace.SQLSelect2(mSql, dtHeader);

    if dtHeader.Active then
    begin
      dtHeader.First;

      // zkontroluju, ze drobny majetek ma POUZE 1 radek v rozpisu - vic jich nyni nepodporujeme
      mSql :=
        'select' + nxCrLf +
        '  count(SAC2.ID)' + nxCrLf +
        'from SmallAssetCards2 SAC2' + nxCrLf +
        'join SmallAssetCards SAC on SAC.ID = SAC2.Parent_ID' + nxCrLf +
        'where' + nxCrLf +
        '  SAC.ID = ' + QuotedStr(dtHeader.FieldByName('ID').AsString) + nxCrLf;
      mCount := SQLSelectInt(Self.ObjectSpace, mSql);

      if mCount > 1 then
      begin
        RaiseException(Format(getString('error_saving_breakdown_has_too_many_rows'), [dtHeader.FieldByName('StoreCardName').AsString]));
      end;

      LogWriteSectionStart('JSON');
      json := REST_jsonCreate_FromDataSetRow(dtHeader, nil, nil);
      LogWriteSectionEnd;

      HTTPResponse(AResponse, HTTP_SC_OK, ContentType_JSON, json.AsJson(false, true));
    end
    else begin
      ErrREST(ARequest, AResponse, HTTP_SC_NotFound, Format(getString('smallassetcard_not_found'), [mSmallAssetCard_ID]));
    end;
  finally
    dtHeader.Free;
    if Assigned(json) then
      json.Free;
    LogWriteSectionEnd;
  end;
end;

procedure get_ListBusOrders(Self: TNxWebServicesHelper; ARequest: TNxHTTPRequest;
  AResponse: TNxHTTPResponse; slPath: TStringList);
var
  mModule, mUser_ID, mSearchStr, mDocumentType: String;
  dtRows: TMemTable;
  mSql: String;
  json: TJSONSuperObject;
begin
  json := nil;
  mSearchStr := '';
  if (slPath.Count = 1) or (slPath.Count = 2) then
  begin
    if slPath.Count = 2 then
      mSearchStr := CFxInternet.URLDecode(ReplaceStr(slPath.Strings[1], '+', ' '));
  end else
  begin
    ErrREST(ARequest, AResponse, HTTP_SC_BadRequest, getString('wrong_parameters_count'));
    exit;
  end;

  mModule := getHeaderValue(ARequest, 'ModuleCode');
  mUser_ID := getHeaderValue(ARequest, 'UserID');
  mDocumentType := getHeaderValue(ARequest, 'DocumentType');

  dtRows := TMemTable.Create(nil);
  LogWriteSectionStart('get_ListBusOrders');
  try
    mSql :=
      'select' + FIRST_TOP(100) + nxCrLf +
      '  BO.ID as "ID",' + nxCrLf +
      '  BO.Code as "Code",' + nxCrLf +
      '  BO.Name as "Name"' + nxCrLf +
      'from BusOrders BO' + nxCrLf +
      'where' + nxCrLf +
      '  BO.Hidden = ''N''' + nxCrLf;

    // pripadne hledani
    if trim(mSearchStr) <> '' then
    begin
      // muze se stat, ze nekdo do hledaciho okynka naskenuje carovy kod pozice ve tvaru SPXXXXXXXXXX
      if (length(mSearchStr) = 12) and (copy(mSearchStr, 1, 2) = 'BO') then
        mSearchStr := copy(mSearchStr, 3, 10);
      mSql := mSql +
        '  and (BO.Code' + COLLATION_AI + 'like ''%' + mSearchStr + '%''' + nxCrLf +
        '    or BO.Name' + COLLATION_AI + 'like ''%' + mSearchStr + '%''' + nxCrLf +
        '    or BO.ID = ' + QuotedStr(mSearchStr) + ')' + nxCrLf;
    end;
    mSql := mSql +
      'order by' + nxCrLf +
      '  BO.Code' + nxCrLf;
    mSql := mSql + FIRST_TOP_ORACLE(100);
    Self.ObjectSpace.SQLSelect2(mSql, dtRows);

    LogWriteSectionStart('JSON');
    if dtRows.Active then
    begin
      json := REST_jsonCreate_FromDataSet(dtRows, nil, nil);
    end
    else begin
      json := TJSONSuperObject.CreateByDataType(jtArray);
    end;
    LogWriteSectionEnd;

    HTTPResponse(AResponse, HTTP_SC_OK, ContentType_JSON, json.AsJson(false, true));
  finally
    dtRows.Free;
    if Assigned(json) then
      json.Free;
    LogWriteSectionEnd;
  end;
end;

procedure get_ListDivisions(Self: TNxWebServicesHelper; ARequest: TNxHTTPRequest;
  AResponse: TNxHTTPResponse; slPath: TStringList);
var
  mModule, mUser_ID, mSearchStr, mDocumentType: String;
  dtRows: TMemTable;
  mSql: String;
  json: TJSONSuperObject;
begin
  json := nil;
  mSearchStr := '';
  if (slPath.Count = 1) or (slPath.Count = 2) then
  begin
    if slPath.Count = 2 then
      mSearchStr := CFxInternet.URLDecode(ReplaceStr(slPath.Strings[1], '+', ' '));
  end else
  begin
    ErrREST(ARequest, AResponse, HTTP_SC_BadRequest, getString('wrong_parameters_count'));
    exit;
  end;

  mModule := getHeaderValue(ARequest, 'ModuleCode');
  mUser_ID := getHeaderValue(ARequest, 'UserID');
  mDocumentType := getHeaderValue(ARequest, 'DocumentType');

  dtRows := TMemTable.Create(nil);
  LogWriteSectionStart('get_ListDivisions');
  try
    mSql :=
      'select' + FIRST_TOP(100) + nxCrLf +
      '  D.ID as "ID",' + nxCrLf +
      '  D.Code as "Code",' + nxCrLf +
      '  D.Name as "Name"' + nxCrLf +
      'from Divisions D' + nxCrLf +
      'where' + nxCrLf +
      '  D.Hidden = ''N''' + nxCrLf;

    // pripadne hledani
    if trim(mSearchStr) <> '' then
    begin
      // muze se stat, ze nekdo do hledaciho okynka naskenuje carovy kod pozice ve tvaru SPXXXXXXXXXX
      if (length(mSearchStr) = 12) and (copy(mSearchStr, 1, 2) = 'BO') then
        mSearchStr := copy(mSearchStr, 3, 10);
      mSql := mSql +
        '  and (D.Code' + COLLATION_AI + 'like ''%' + mSearchStr + '%''' + nxCrLf +
        '    or D.Name' + COLLATION_AI + 'like ''%' + mSearchStr + '%''' + nxCrLf +
        '    or D.ID = ' + QuotedStr(mSearchStr) + ')' + nxCrLf;
    end;
    mSql := mSql +
      'order by' + nxCrLf +
      '  D.Code' + nxCrLf;
    mSql := mSql + FIRST_TOP_ORACLE(100);
    Self.ObjectSpace.SQLSelect2(mSql, dtRows);

    LogWriteSectionStart('JSON');
    if dtRows.Active then
    begin
      json := REST_jsonCreate_FromDataSet(dtRows, nil, nil);
    end
    else begin
      json := TJSONSuperObject.CreateByDataType(jtArray);
    end;
    LogWriteSectionEnd;

    HTTPResponse(AResponse, HTTP_SC_OK, ContentType_JSON, json.AsJson(false, true));
  finally
    dtRows.Free;
    if Assigned(json) then
      json.Free;
    LogWriteSectionEnd;
  end;
end;

procedure get_ListDocQueues(Self: TNxWebServicesHelper; ARequest: TNxHTTPRequest;
  AResponse: TNxHTTPResponse; slPath: TStringList);
var
  mModule, mUser_ID, mSearchStr, mDocumentType: String;
  dtRows: TMemTable;
  mSql: String;
  json: TJSONSuperObject;
begin
  json := nil;
  mSearchStr := '';
  if (slPath.Count = 1) or (slPath.Count = 2) then
  begin
    if slPath.Count = 2 then
      mSearchStr := CFxInternet.URLDecode(ReplaceStr(slPath.Strings[1], '+', ' '));
  end else
  begin
    ErrREST(ARequest, AResponse, HTTP_SC_BadRequest, getString('wrong_parameters_count'));
    exit;
  end;

  mModule := getHeaderValue(ARequest, 'ModuleCode');
  mUser_ID := getHeaderValue(ARequest, 'UserID');
  mDocumentType := getHeaderValue(ARequest, 'DocumentType');

  dtRows := TMemTable.Create(nil);
  LogWriteSectionStart('get_ListDocQueues');
  try
    mSql :=
      'select' + FIRST_TOP(100) + nxCrLf +
      '  DQ.ID as "ID",' + nxCrLf +
      '  DQ.Code as "Code",' + nxCrLf +
      '  DQ.Name as "Name"' + nxCrLf +
      'from DocQueues DQ' + nxCrLf +
      'where' + nxCrLf +
      '  DQ.Hidden = ''N''' + nxCrLf +
      '  and DQ.DocumentType = ' + QuotedStr(mDocumentType) + nxCrLf;

    // pripadne hledani
    if trim(mSearchStr) <> '' then
    begin
      // muze se stat, ze nekdo do hledaciho okynka naskenuje carovy kod pozice ve tvaru SPXXXXXXXXXX
      if (length(mSearchStr) = 12) and (copy(mSearchStr, 1, 2) = 'DQ') then
        mSearchStr := copy(mSearchStr, 3, 10);
      mSql := mSql +
        '  and (DQ.Code' + COLLATION_AI + 'like ''%' + mSearchStr + '%''' + nxCrLf +
        '    or DQ.Name' + COLLATION_AI + 'like ''%' + mSearchStr + '%''' + nxCrLf +
        '    or DQ.ID = ' + QuotedStr(mSearchStr) + ')' + nxCrLf;
    end;
    mSql := mSql +
      'order by' + nxCrLf +
      '  DQ.Code' + nxCrLf;
    mSql := mSql + FIRST_TOP_ORACLE(100);
    Self.ObjectSpace.SQLSelect2(mSql, dtRows);

    LogWriteSectionStart('JSON');
    if dtRows.Active then
    begin
      json := REST_jsonCreate_FromDataSet(dtRows, nil, nil);
    end
    else begin
      json := TJSONSuperObject.CreateByDataType(jtArray);
    end;
    LogWriteSectionEnd;

    HTTPResponse(AResponse, HTTP_SC_OK, ContentType_JSON, json.AsJson(false, true));
  finally
    dtRows.Free;
    if Assigned(json) then
      json.Free;
    LogWriteSectionEnd;
  end;
end;

procedure get_ListFirmOffices(Self: TNxWebServicesHelper; ARequest: TNxHTTPRequest;
  AResponse: TNxHTTPResponse; slPath: TStringList);
var
  mFirm_ID, mModule, mUser_ID, mSearchStr, mDocumentType: String;
  dtRows: TMemTable;
  mSql: String;
  json: TJSONSuperObject;
begin
  json := nil;
  mSearchStr := '';
  if (slPath.Count = 2) or (slPath.Count = 3) then
  begin
    mFirm_ID := slPath.Strings[1];
    if slPath.Count = 3 then
      mSearchStr := CFxInternet.URLDecode(ReplaceStr(slPath.Strings[2], '+', ' '));
  end else
  begin
    ErrREST(ARequest, AResponse, HTTP_SC_BadRequest, getString('wrong_parameters_count'));
    exit;
  end;

  mModule := getHeaderValue(ARequest, 'ModuleCode');
  mUser_ID := getHeaderValue(ARequest, 'UserID');
  mDocumentType := getHeaderValue(ARequest, 'DocumentType');

  dtRows := TMemTable.Create(nil);
  LogWriteSectionStart('get_ListFirmOffices');
  try
    mSql :=
      'select' + FIRST_TOP(100) + nxCrLf +
      '  FO.ID as "ID",' + nxCrLf +
      '  FO.Name as "Code",' + nxCrLf +
      '  A.Street' + CONCAT_STR + ''', ''' + CONCAT_STR + 'A.City' + CONCAT_STR + ''', ''' + CONCAT_STR + 'A.Country as "Name"' + nxCrLf +
      'from FirmOffices FO' + nxCrLf +
      'join Addresses A on A.ID = FO.Address_ID' + nxCrLf +
      'where' + nxCrLf +
      '  FO.Parent_ID = ' + QuotedStr(mFirm_ID) + nxCrLf;

    if not ABRA then
      mSql := mSql +
        '  and FO.Hidden = ''N''' + nxCrLf;

    // pripadne hledani
    if trim(mSearchStr) <> '' then
    begin
      // muze se stat, ze nekdo do hledaciho okynka naskenuje carovy kod pozice ve tvaru SPXXXXXXXXXX
      if (length(mSearchStr) = 12) and (copy(mSearchStr, 1, 2) = 'FO') then
        mSearchStr := copy(mSearchStr, 3, 10);
      mSql := mSql +
        '  and (FO.Name' + COLLATION_AI + 'like ''%' + mSearchStr + '%''' + nxCrLf +
        '    or FO.ID = ' + QuotedStr(mSearchStr) + ')' + nxCrLf;
    end;
    mSql := mSql +
      'order by' + nxCrLf +
      '  FO.Name' + nxCrLf;
    mSql := mSql + FIRST_TOP_ORACLE(100);
    Self.ObjectSpace.SQLSelect2(mSql, dtRows);

    LogWriteSectionStart('JSON');
    if dtRows.Active then
    begin
      json := REST_jsonCreate_FromDataSet(dtRows, nil, nil);
    end
    else begin
      json := TJSONSuperObject.CreateByDataType(jtArray);
    end;
    LogWriteSectionEnd;

    HTTPResponse(AResponse, HTTP_SC_OK, ContentType_JSON, json.AsJson(false, true));
  finally
    dtRows.Free;
    if Assigned(json) then
      json.Free;
    LogWriteSectionEnd;
  end;
end;

procedure get_ListPersons(Self: TNxWebServicesHelper; ARequest: TNxHTTPRequest;
  AResponse: TNxHTTPResponse; slPath: TStringList);
var
  mFirm_ID, mSearchStr, mModule, mUser_ID, mDocType, mSelect, mFrom, mWhere, mJoin, mOrderBy: String;
  dtRows: TMemTable;
  mSql: String;
  json: TJSONSuperObject;
  mParameters: TStringList;
begin
  LogWriteSectionStart('get_ListPersons');
  try
    json := nil;
    mSearchStr := '';
    mSelect := '';
    mFrom := '';
    mWhere := '';
    mJoin := '';
    mOrderBy := '';

    if (slPath.Count = 2) or (slPath.Count = 3) then
    begin
      mFirm_ID := slPath.Strings[1];
      if slPath.Count = 3 then
        mSearchStr := CFxInternet.URLDecode(ReplaceStr(slPath.Strings[2], '+', ' '));
    end else
    begin
      ErrREST(ARequest, AResponse, HTTP_SC_BadRequest, getString('wrong_parameters_count'));
      exit;
    end;

    mModule := getHeaderValue(ARequest, 'ModuleCode');
    mUser_ID := getHeaderValue(ARequest, 'UserID');
    mDocType := getHeaderValue(ARequest, 'DocumentType');

    dtRows := TMemTable.Create(nil);
    mParameters := TStringList.Create;
    try
      mSelect :=
        '  P.ID as "ID",' + nxCrLf +
        '  P.FirstName ' + CONCAT_STR + ' '' '' ' + CONCAT_STR + ' P.LastName as "Code",' + nxCrLf +
        '  P.FirstName ' + CONCAT_STR + ' '' '' ' + CONCAT_STR + ' P.LastName as "Name"';

      mFrom :=
        'Persons P';

      // pokud je firma, tak osoby omezime pouze na ni
      if not CFxOID.IsEmpty(mFirm_ID) then
        mJoin := mJoin +
          'join FirmPersons FP on FP.Person_ID = P.ID and FP.Parent_ID = ' + QuotedStr(mFirm_ID);

      mWhere :=
        '  P.Hidden = ''N''';

      // pripadne hledani
      if trim(mSearchStr) <> '' then
      begin
        // muze se stat, ze nekdo do hledaciho okynka naskenuje carovy kod ve tvaru PEXXXXXXXXXX
        if (length(mSearchStr) = 12) and (copy(mSearchStr, 1, 2) = 'PE') then
          mSearchStr := copy(mSearchStr, 3, 10);
        mWhere := mWhere + nxCrLf +
          '  and (P.LastName' + COLLATION_AI + 'like ''%' + mSearchStr + '%'' ' + nxCrLf +
          '    or P.FirstName' + COLLATION_AI + 'like ''%' + mSearchStr + '%'' ' + nxCrLf +
          '    or P.ID = ' + QuotedStr(mSearchStr) + ')';
      end;

      mOrderBy :=
        '  P.LastName, P.FirstName' + nxCrLf;

      mParameters.Values('firm_id') := mFirm_ID;
      mParameters.Values('select') := mSelect;
      mParameters.Values('from') := mFrom;
      mParameters.Values('join') := mJoin;
      mParameters.Values('where') := mWhere;
      mParameters.Values('orderby') := mOrderBy;

      FilterList(Self.ObjectSpace, mModule, mDocType, mUser_ID, 'get_ListPersons', mParameters);

      mSql :=
        'select' + FIRST_TOP(100) + nxCrLf +
        mParameters.Values('select') + nxCrLf +
        'from ' +
        mParameters.Values('from') + nxCrLf +
        mParameters.Values('join');

        if mParameters.Values('where') <> '' then
          mSql := mSql + nxCrLf +
          'where' + nxCrLf +
          mParameters.Values('where');

        if mParameters.Values('orderby') <> '' then
          mSql := mSql + nxCrLf +
          'order by' + nxCrLf +
          mParameters.Values('orderby');

      mSql := mSql + nxCrLf +
        FIRST_TOP_ORACLE(100);
      Self.ObjectSpace.SQLSelect2(mSql, dtRows);

      LogWriteSectionStart('JSON');
      if dtRows.Active then
      begin
        json := REST_jsonCreate_FromDataSet(dtRows, nil, nil);
      end
      else begin
        json := TJSONSuperObject.CreateByDataType(jtArray);
      end;
      LogWriteSectionEnd;

      HTTPResponse(AResponse, HTTP_SC_OK, ContentType_JSON, json.AsJson(false, true));
    finally
      dtRows.Free;
      mParameters.Free;
      if Assigned(json) then
        json.Free;
    end;
  finally
    LogWriteSectionEnd;
  end;
end;

procedure get_ListTransportationTypes(Self: TNxWebServicesHelper; ARequest: TNxHTTPRequest;
  AResponse: TNxHTTPResponse; slPath: TStringList);
var
  mSearchStr: String;
  dtRows: TMemTable;
  mSql: String;
  json: TJSONSuperObject;
begin
  json := nil;
  mSearchStr := '';
  if (slPath.Count = 1) or (slPath.Count = 2) then
  begin
    if slPath.Count = 2 then
      mSearchStr := CFxInternet.URLDecode(ReplaceStr(slPath.Strings[1], '+', ' '));
  end else
  begin
    ErrREST(ARequest, AResponse, HTTP_SC_BadRequest, getString('wrong_parameters_count'));
    exit;
  end;

  dtRows := TMemTable.Create(nil);
  LogWriteSectionStart('get_ListTransportationTypes');
  try
    mSql :=
      'select' + FIRST_TOP(100) + nxCrLf +
      '  TT.ID as "ID",' + nxCrLf +
      '  TT.Code as "Code",' + nxCrLf +
      '  TT.Name as "Name"' + nxCrLf +
      'from TransportationTypes TT' + nxCrLf +
      'where' + nxCrLf +
      '  TT.Hidden = ''N''' + nxCrLf;

    // pripadne hledani
    if trim(mSearchStr) <> '' then
    begin
      // muze se stat, ze nekdo do hledaciho okynka naskenuje carovy kod pozice ve tvaru SPXXXXXXXXXX
      if (length(mSearchStr) = 12) and (copy(mSearchStr, 1, 2) = 'TT') then
        mSearchStr := copy(mSearchStr, 3, 10);
      mSql := mSql + ' and (TT.Code' + COLLATION_AI + 'like ''%' + mSearchStr + '%'' ' + nxCrLf +
        '  or TT.Name' + COLLATION_AI + 'like ''%' + mSearchStr + '%'' ' + nxCrLf +
        '  or TT.ID = ' + QuotedStr(mSearchStr) + ')' + nxCrLf;
    end;
    mSql := mSql +
      'order by' + nxCrLf +
      '  TT.Code' + nxCrLf;
    mSql := mSql + FIRST_TOP_ORACLE(100);
    Self.ObjectSpace.SQLSelect2(mSql, dtRows);
    LogWriteSectionEnd;

    LogWriteSectionStart('JSON');
    if dtRows.Active then
    begin
      json := REST_jsonCreate_FromDataSet(dtRows, nil, nil);
    end
    else begin
      json := TJSONSuperObject.CreateByDataType(jtArray);
    end;

    HTTPResponse(AResponse, HTTP_SC_OK, ContentType_JSON, json.AsJson(false, true));
  finally
    dtRows.Free;
    if Assigned(json) then
      json.Free;
    LogWriteSectionEnd;
  end;
end;

procedure get_ListWorkplaces(Self: TNxWebServicesHelper; ARequest: TNxHTTPRequest;
  AResponse: TNxHTTPResponse; slPath: TStringList);
var
  mSearchStr: String;
  dtRows: TMemTable;
  mSql: String;
  json: TJSONSuperObject;
begin
  json := nil;
  mSearchStr := '';
  if (slPath.Count = 1) or (slPath.Count = 2) then
  begin
    if slPath.Count = 2 then
      mSearchStr := CFxInternet.URLDecode(ReplaceStr(slPath.Strings[1], '+', ' '));
  end else
  begin
    ErrREST(ARequest, AResponse, HTTP_SC_BadRequest, getString('wrong_parameters_count'));
    exit;
  end;

  dtRows := TMemTable.Create(nil);
  LogWriteSectionStart('get_ListWorkplaces');
  try
    mSql :=
      'select' + FIRST_TOP(100) + nxCrLf +
      '  WP.ID as "ID",' + nxCrLf +
      '  WP.Code as "Code",' + nxCrLf +
      '  WP.Title as "Name"' + nxCrLf +
      'from PRFWorkPlaces WP' + nxCrLf +
      'where' + nxCrLf +
      '  WP.Hidden = ''N''' + nxCrLf;

    // pripadne hledani
    if trim(mSearchStr) <> '' then
    begin
      // muze se stat, ze nekdo do hledaciho okynka naskenuje carovy kod pozice ve tvaru SPXXXXXXXXXX
      if (length(mSearchStr) = 12) and (copy(mSearchStr, 1, 2) = 'WP') then
        mSearchStr := copy(mSearchStr, 3, 10);
      mSql := mSql +
        '  and (WP.Code' + COLLATION_AI + 'like ''%' + mSearchStr + '%'' ' + nxCrLf +
        '    or WP.Title' + COLLATION_AI + 'like ''%' + mSearchStr + '%'' ' + nxCrLf +
        '    or WP.ID = ' + QuotedStr(mSearchStr) + ')' + nxCrLf;
    end;
    mSql := mSql +
      'order by' + nxCrLf +
      '  WP.Code' + nxCrLf;
    mSql := mSql + FIRST_TOP_ORACLE(100);
    Self.ObjectSpace.SQLSelect2(mSql, dtRows);

    LogWriteSectionStart('JSON');
    if dtRows.Active then
    begin
      json := REST_jsonCreate_FromDataSet(dtRows, nil, nil);
    end
    else begin
      json := TJSONSuperObject.CreateByDataType(jtArray);
    end;
    LogWriteSectionEnd;

    HTTPResponse(AResponse, HTTP_SC_OK, ContentType_JSON, json.AsJson(false, true));
  finally
    dtRows.Free;
    if Assigned(json) then
      json.Free;
    LogWriteSectionEnd;
  end;
end;

procedure get_ListAssetLocations(Self: TNxWebServicesHelper; ARequest: TNxHTTPRequest;
  AResponse: TNxHTTPResponse; slPath: TStringList);
var
  mSearchStr: String;
  dtRows: TMemTable;
  mSql: String;
  json: TJSONSuperObject;
begin
  json := nil;
  mSearchStr := '';
  if (slPath.Count = 1) or (slPath.Count = 2) then
  begin
    if slPath.Count = 2 then
      mSearchStr := CFxInternet.URLDecode(ReplaceStr(slPath.Strings[1], '+', ' '));
  end else
  begin
    ErrREST(ARequest, AResponse, HTTP_SC_BadRequest, getString('wrong_parameters_count'));
    exit;
  end;

  dtRows := TMemTable.Create(nil);
  LogWriteSectionStart('get_ListAssetLocations');
  try
    mSql :=
      'select' + FIRST_TOP(100) + nxCrLf +
      '  AL.ID as "ID",' + nxCrLf +
      '  AL.Code as "Code",' + nxCrLf +
      '  AL.Name as "Name"' + nxCrLf +
      'from AssetLocations AL' + nxCrLf +
      'where' + nxCrLf +
      '  AL.Hidden = ''N''' + nxCrLf;

    // pripadne hledani
    if trim(mSearchStr) <> '' then
    begin
      // muze se stat, ze nekdo do hledaciho okynka naskenuje carovy kod ve tvaru SPXXXXXXXXXX
      if (length(mSearchStr) = 12) and (copy(mSearchStr, 1, 2) = 'AL') then
        mSearchStr := copy(mSearchStr, 3, 10);
      mSql := mSql +
        '  and (AL.Code' + COLLATION_AI + 'like ''%' + mSearchStr + '%'' ' + nxCrLf +
        '    or AL.Name' + COLLATION_AI + 'like ''%' + mSearchStr + '%'' ' + nxCrLf +
        '    or AL.ID = ' + QuotedStr(mSearchStr) + ')' + nxCrLf;
    end;
    mSql := mSql +
      'order by' + nxCrLf +
      '  AL.Code' + nxCrLf;
    mSql := mSql + FIRST_TOP_ORACLE(100);
    Self.ObjectSpace.SQLSelect2(mSql, dtRows);
    LogWriteSectionEnd;

    LogWriteSectionStart('JSON');
    if dtRows.Active then
    begin
      json := REST_jsonCreate_FromDataSet(dtRows, nil, nil);
    end
    else begin
      json := TJSONSuperObject.CreateByDataType(jtArray);
    end;

    HTTPResponse(AResponse, HTTP_SC_OK, ContentType_JSON, json.AsJson(false, true));
  finally
    dtRows.Free;
    if Assigned(json) then
      json.Free;
    LogWriteSectionEnd;
  end;
end;

procedure get_ListAssetResponsibles(Self: TNxWebServicesHelper; ARequest: TNxHTTPRequest;
  AResponse: TNxHTTPResponse; slPath: TStringList);
var
  mSearchStr: String;
  dtRows: TMemTable;
  mSql: String;
  json: TJSONSuperObject;
begin
  json := nil;
  mSearchStr := '';
  if (slPath.Count = 1) or (slPath.Count = 2) then
  begin
    if slPath.Count = 2 then
      mSearchStr := CFxInternet.URLDecode(ReplaceStr(slPath.Strings[1], '+', ' '));
  end else
  begin
    ErrREST(ARequest, AResponse, HTTP_SC_BadRequest, getString('wrong_parameters_count'));
    exit;
  end;

  dtRows := TMemTable.Create(nil);
  LogWriteSectionStart('get_ListAssetResponsibles');
  try
    mSql :=
      'select' + FIRST_TOP(100) + nxCrLf +
      '  AR.ID as "ID",' + nxCrLf +
      '  P.PersonalNumber as "Code",' + nxCrLf +
      '  P.FirstName ' + CONCAT_STR + ' '' '' ' + CONCAT_STR + ' P.LastName as "Name"' + nxCrLf +
      'from AssetResponsibles AR' + nxCrLf +
      'join Persons P on P.ID = AR.Person_ID' + nxCrLf +
      'where' + nxCrLf +
      '  P.Hidden = ''N''' + nxCrLf;

    // pripadne hledani
    if trim(mSearchStr) <> '' then
    begin
      // muze se stat, ze nekdo do hledaciho okynka naskenuje carovy kod pozice ve tvaru SPXXXXXXXXXX
      if (length(mSearchStr) = 12) and (copy(mSearchStr, 1, 2) = 'AR') then
        mSearchStr := copy(mSearchStr, 3, 10);
      mSql := mSql +
        '  and (P.PersonalNumber' + COLLATION_AI + 'like ''%' + mSearchStr + '%'' ' + nxCrLf +
        '    or P.LastName' + COLLATION_AI + 'like ''%' + mSearchStr + '%'' ' + nxCrLf +
        '    or P.FirstName' + COLLATION_AI + 'like ''%' + mSearchStr + '%'' ' + nxCrLf +
        '    or AR.ID = ' + QuotedStr(mSearchStr) + ')' + nxCrLf;
    end;
    mSql := mSql +
      'order by' + nxCrLf +
      '  P.PersonalNumber' + nxCrLf;
    mSql := mSql + FIRST_TOP_ORACLE(100);
    Self.ObjectSpace.SQLSelect2(mSql, dtRows);
    LogWriteSectionEnd;

    LogWriteSectionStart('JSON');
    if dtRows.Active then
    begin
      json := REST_jsonCreate_FromDataSet(dtRows, nil, nil);
    end
    else begin
      json := TJSONSuperObject.CreateByDataType(jtArray);
    end;

    HTTPResponse(AResponse, HTTP_SC_OK, ContentType_JSON, json.AsJson(false, true));
  finally
    dtRows.Free;
    if Assigned(json) then
      json.Free;
    LogWriteSectionEnd;
  end;
end;

procedure get_ListSmallAssetCards(Self: TNxWebServicesHelper; ARequest: TNxHTTPRequest;
  AResponse: TNxHTTPResponse; slPath: TStringList);
var
  mSearchStr: String;
  dtRows: TMemTable;
  mSql: String;
  json: TJSONSuperObject;
begin
  json := nil;
  mSearchStr := '';
  if (slPath.Count = 1) or (slPath.Count = 2) then
  begin
    if slPath.Count = 2 then
      mSearchStr := CFxInternet.URLDecode(ReplaceStr(slPath.Strings[1], '+', ' '));
  end else
  begin
    ErrREST(ARequest, AResponse, HTTP_SC_BadRequest, getString('wrong_parameters_count'));
    exit;
  end;

  dtRows := TMemTable.Create(nil);
  LogWriteSectionStart('get_ListSmallAssetCards');
  try
    mSql :=
      'select' + FIRST_TOP(100) + nxCrLf +
      '  SAC.ID as "ID",' + nxCrLf +
      '  SAC.InventoryNr as "Code",' + nxCrLf +
      '  SAC.Name as "Name"' + nxCrLf +
      'from SmallAssetCards SAC' + nxCrLf +
      'where' + nxCrLf +
      '  SAC.Status = 0' + nxCrLf;

    // pripadne hledani
    if trim(mSearchStr) <> '' then
    begin
      // muze se stat, ze nekdo do hledaciho okynka naskenuje carovy kod pozice ve tvaru SAXXXXXXXXXX
      if (length(mSearchStr) = 12) and (copy(mSearchStr, 1, 2) = 'SA') then
        mSearchStr := copy(mSearchStr, 3, 10);
      mSql := mSql +
        '  and (SAC.InventoryNr' + COLLATION_AI + 'like ''%' + mSearchStr + '%'' ' + nxCrLf +
        '    or SAC.Name' + COLLATION_AI + 'like ''%' + mSearchStr + '%'' ' + nxCrLf +
        '    or SAC.ID = ' + QuotedStr(mSearchStr) + ')' + nxCrLf;
    end;
    mSql := mSql +
      'order by' + nxCrLf +
      '  SAC.InventoryNr' + nxCrLf;
    mSql := mSql + FIRST_TOP_ORACLE(100);
    Self.ObjectSpace.SQLSelect2(mSql, dtRows);

    LogWriteSectionStart('JSON');
    if dtRows.Active then
    begin
      json := REST_jsonCreate_FromDataSet(dtRows, nil, nil);
    end
    else begin
      json := TJSONSuperObject.CreateByDataType(jtArray);
    end;
    LogWriteSectionEnd;

    HTTPResponse(AResponse, HTTP_SC_OK, ContentType_JSON, json.AsJson(false, true));
  finally
    dtRows.Free;
    if Assigned(json) then
      json.Free;
    LogWriteSectionEnd;
  end;
end;

procedure get_ListDocuments(Self: TNxWebServicesHelper; ARequest: TNxHTTPRequest;
  AResponse: TNxHTTPResponse; slPath: TStringList; slArguments: TStringList = nil);
var
  mSearchStr, mText: String;
  dtRows: TMemTable;
  mSql: String;
  json: TJSONSuperObject;
begin
  json := nil;
  mSearchStr := '';
  if (slPath.Count = 1) or (slPath.Count = 2) then
  begin
    if slPath.Count = 2 then
      mSearchStr := CFxInternet.URLDecode(ReplaceStr(slPath.Strings[1], '+', ' '));
  end else
  begin
    ErrREST(ARequest, AResponse, HTTP_SC_BadRequest, getString('wrong_parameters_count'));
    exit;
  end;

  dtRows := TMemTable.Create(nil);
  LogWriteSectionStart('get_ListDocuments');
  try
    mSql :=
      'select' + FIRST_TOP(100) + nxCrLf +
      '  D.ID as "ID",' + nxCrLf +
      '  DQ.Code' + CONCAT_STR + QuotedStr('-') + CONCAT_STR + 'cast(D.OrdNumber as varchar(6))' +
        CONCAT_STR + QuotedStr('/') + CONCAT_STR + 'P.Code as "Code",' + nxCrLf +
      '  D.Description as "Name"' + nxCrLf +
      'from Documents D' + nxCrLf +
      'join DocQueues DQ on DQ.ID = D.DocQueue_ID' + nxCrLf +
      'join Periods P on P.ID = D.Period_ID' + nxCrLf;

    // pokud mame query parametry, tak v nich budou povolena ID a zobrazime jen ty
    if Assigned(slArguments) and (slArguments.Count > 0) then
    begin
      // upravim si list tak, abych ho mohl pouzit v dotazu
      mText := slArguments.DelimitedText;
      mText := ReplaceText(mText, 'IDs=', '');
      mText := ReplaceText(mText, '[', '');
      mText := ReplaceText(mText, ']', '');
      //slArguments.DelimitedText := copy(slArguments.DelimitedText, 1, Length(slArguments.DelimitedText) - 2);

      mSql := mSql +
        'where' + nxCrLf +
        '  D.ID in (''' + ReplaceText(mText, ',', ''',''') + ''')' + nxCrLf;
    end;

    // pripadne hledani
    if trim(mSearchStr) <> '' then
    begin
      if not Assigned(slArguments) or (not slArguments.Count > 0) then
        mSql := mSql +
          'where' + nxCrLf;

      mSql := mSql +
        '  (DQ.Code' + CONCAT_STR + QuotedStr('-') + CONCAT_STR + 'cast(D.OrdNumber as varchar(6))' +
          CONCAT_STR + QuotedStr('/') + CONCAT_STR + 'P.Code like ''%' + mSearchStr + '%'' ' + nxCrLf +
        '    or D.Description' + COLLATION_AI + 'like ''%' + mSearchStr + '%'')' + nxCrLf;
    end;
    mSql := mSql +
      'order by' + nxCrLf +
      '  DQ.Code' + CONCAT_STR + QuotedStr('-') + CONCAT_STR + 'cast(D.OrdNumber as varchar(6))' +
          CONCAT_STR + QuotedStr('/') + CONCAT_STR + 'P.Code' + nxCrLf;
    mSql := mSql + FIRST_TOP_ORACLE(100);
    Self.ObjectSpace.SQLSelect2(mSql, dtRows);

    LogWriteSectionStart('JSON');
    if dtRows.Active then
    begin
      json := REST_jsonCreate_FromDataSet(dtRows, nil, nil);
    end
    else begin
      json := TJSONSuperObject.CreateByDataType(jtArray);
    end;
    LogWriteSectionEnd;

    HTTPResponse(AResponse, HTTP_SC_OK, ContentType_JSON, json.AsJson(false, true));
  finally
    dtRows.Free;
    if Assigned(json) then
      json.Free;
    LogWriteSectionEnd;
  end;
end;

begin
end.