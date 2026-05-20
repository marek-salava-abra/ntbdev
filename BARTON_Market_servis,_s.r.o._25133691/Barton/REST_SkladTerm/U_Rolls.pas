uses
  'REST_SkladTerm.U_Firm',
  'REST_SkladTerm.U_Func',
  'REST_SkladTerm.U_FuncJSON',
  'REST_SkladTerm.U_PackageShipping',
  'REST_SkladTerm.U_SQLQueries',
  'REST_SkladTerm.U_Store',
  'REST_SkladTerm.U_StoreBatch',
  'REST_SkladTerm.U_StoreCard',
  'REST_SkladTerm.U_StorePosition',
  'REST_SkladTerm_Special.U_StandardHooks',
  'StandardUnits.U_GetId';

procedure get_BusOrderInfo(AOS: TNxCustomObjectSpace; APath, AResponse: TStringList);
var
  mBusOrder_ID: String;
  dtHeader: TMemTable;
  dtRows: TMemTable;
  mSL: TStringList;
  mSql: String;
  json: TJSONSuperObject;
begin
  json := nil;
  if (APath.Count = 2) then
  begin
    mBusOrder_ID := APath.Strings[1];
  end else
  begin
    SetPlainResponse(AResponse, getString('wrong_parameters_count'), HTTP_SC_BadRequest);
    exit;
  end;

  dtHeader := TMemTable.Create(nil);
  LogWriteSectionStart('get_BusOrderInfo');
  try
    mSql :=
      'select' + nxCrLf +
      '  BO.ID as "id",' + nxCrLf +
      '  BO.Code as "code",' + nxCrLf +
      '  BO.Name as "name"' + nxCrLf +
      'from BusOrders BO' + nxCrLf +
      'where' + nxCrLf +
      '  BO.ID = ' + QuotedStr(mBusOrder_ID) + nxCrLf +
      '  and BO.Hidden = ''N''';
    AOS.SQLSelect2(mSql, dtHeader);

    if dtHeader.Active then
    begin
      dtHeader.First;
      LogWriteSectionStart('JSON');
      json := REST_jsonCreate_FromDataSetRow(dtHeader, nil, nil);
      LogWriteSectionEnd;

      SetResponse(AResponse, json.AsJson(false, true));
    end
    else
      SetPlainResponse(AResponse, Format(getString('busorder_not_found'), [mBusOrder_ID]), HTTP_SC_NotFound);
  finally
    dtHeader.Free;
    if Assigned(json) then
      json.Free;
    LogWriteSectionEnd;
  end;
end;

procedure get_BusProjectInfo(AOS: TNxCustomObjectSpace; APath, AResponse: TStringList);
var
  mBusProject_ID: String;
  dtHeader: TMemTable;
  dtRows: TMemTable;
  mSL: TStringList;
  mSql: String;
  json: TJSONSuperObject;
begin
  json := nil;
  if (APath.Count = 2) then
  begin
    mBusProject_ID := APath.Strings[1];
  end else
  begin
    SetPlainResponse(AResponse, getString('wrong_parameters_count'), HTTP_SC_BadRequest);
    exit;
  end;

  dtHeader := TMemTable.Create(nil);
  LogWriteSectionStart('mBusProject_ID');
  try
    mSql :=
      'select' + nxCrLf +
      '  BP.ID as "id",' + nxCrLf +
      '  BP.Code as "code",' + nxCrLf +
      '  BP.Name as "name"' + nxCrLf +
      'from BusProjects BP' + nxCrLf +
      'where' + nxCrLf +
      '  BP.ID = ' + QuotedStr(mBusProject_ID) + nxCrLf +
      '  and BP.Hidden = ''N''';
    AOS.SQLSelect2(mSql, dtHeader);

    if dtHeader.Active then
    begin
      dtHeader.First;
      LogWriteSectionStart('JSON');
      json := REST_jsonCreate_FromDataSetRow(dtHeader, nil, nil);
      LogWriteSectionEnd;

      SetResponse(AResponse, json.AsJson(false, true));
    end
    else
      SetPlainResponse(AResponse, Format(getString('busproject_not_found'), [mBusProject_ID]), HTTP_SC_NotFound);
  finally
    dtHeader.Free;
    if Assigned(json) then
      json.Free;
    LogWriteSectionEnd;
  end;
end;

procedure get_BusTransactionInfo(AOS: TNxCustomObjectSpace; APath, AResponse: TStringList);
var
  mBusTransaction_ID: String;
  dtHeader: TMemTable;
  dtRows: TMemTable;
  mSL: TStringList;
  mSql: String;
  json: TJSONSuperObject;
begin
  json := nil;
  if (APath.Count = 2) then
  begin
    mBusTransaction_ID := APath.Strings[1];
  end else
  begin
    SetPlainResponse(AResponse, getString('wrong_parameters_count'), HTTP_SC_BadRequest);
    exit;
  end;

  dtHeader := TMemTable.Create(nil);
  LogWriteSectionStart('get_BusTransactionInfo');
  try
    mSql :=
      'select' + nxCrLf +
      '  BT.ID as "id",' + nxCrLf +
      '  BT.Code as "code",' + nxCrLf +
      '  BT.Name as "name"' + nxCrLf +
      'from BusTransactions BT' + nxCrLf +
      'where' + nxCrLf +
      '  BT.ID = ' + QuotedStr(mBusTransaction_ID) + nxCrLf +
      '  and BT.Hidden = ''N''';
    AOS.SQLSelect2(mSql, dtHeader);

    if dtHeader.Active then
    begin
      dtHeader.First;
      LogWriteSectionStart('JSON');
      json := REST_jsonCreate_FromDataSetRow(dtHeader, nil, nil);
      LogWriteSectionEnd;

      SetResponse(AResponse, json.AsJson(false, true));
    end
    else
      SetPlainResponse(AResponse, Format(getString('bustransaction_not_found'), [mBusTransaction_ID]), HTTP_SC_NotFound);
  finally
    dtHeader.Free;
    if Assigned(json) then
      json.Free;
    LogWriteSectionEnd;
  end;
end;

procedure get_DivisionInfo(AOS: TNxCustomObjectSpace; APath, AResponse: TStringList);
var
  mDivision_ID: String;
  dtHeader: TMemTable;
  dtRows: TMemTable;
  mSL: TStringList;
  mSql: String;
  json: TJSONSuperObject;
begin
  json := nil;
  if (APath.Count = 2) then
  begin
    mDivision_ID := APath.Strings[1];
  end else
  begin
    SetPlainResponse(AResponse, getString('wrong_parameters_count'), HTTP_SC_BadRequest);
    exit;
  end;

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
    AOS.SQLSelect2(mSql, dtHeader);

    if dtHeader.Active then
    begin
      dtHeader.First;
      LogWriteSectionStart('JSON');
      json := REST_jsonCreate_FromDataSetRow(dtHeader, nil, nil);
      LogWriteSectionEnd;

      SetResponse(AResponse, json.AsJson(false, true));
    end
    else
      SetPlainResponse(AResponse, Format(getString('division_not_found'), [mDivision_ID]), HTTP_SC_NotFound);
  finally
    dtHeader.Free;
    if Assigned(json) then
      json.Free;
    LogWriteSectionEnd;
  end;
end;

procedure get_DocQueueInfo(AOS: TNxCustomObjectSpace; APath, AResponse: TStringList);
var
  mDocQueue_ID: String;
  dtHeader: TMemTable;
  dtRows: TMemTable;
  mSL: TStringList;
  mSql: String;
  json: TJSONSuperObject;
begin
  json := nil;
  if (APath.Count = 2) then
  begin
    mDocQueue_ID := APath.Strings[1];
  end else
  begin
    SetPlainResponse(AResponse, getString('wrong_parameters_count'), HTTP_SC_BadRequest);
    exit;
  end;

  dtHeader := TMemTable.Create(nil);
  LogWriteSectionStart('get_DocQueueInfo');
  try
    mSql :=
      'select' + nxCrLf +
      '  DQ.ID as "id",' + nxCrLf +
      '  DQ.Code as "code",' + nxCrLf +
      '  DQ.Name as "name"' + nxCrLf +
      'from DocQueues DQ' + nxCrLf +
      'where' + nxCrLf +
      '  DQ.ID = ' + QuotedStr(mDocQueue_ID) + nxCrLf +
      '  and DQ.DocumentType = ' + QuotedStr(gSkladTermDocType) +
      '  and DQ.Hidden = ''N''';
    AOS.SQLSelect2(mSql, dtHeader);

    if dtHeader.Active then
    begin
      dtHeader.First;
      LogWriteSectionStart('JSON');
      json := REST_jsonCreate_FromDataSetRow(dtHeader, nil, nil);
      LogWriteSectionEnd;

      SetResponse(AResponse, json.AsJson(false, true));
    end
    else
      SetPlainResponse(AResponse, Format(getString('docqueue_not_found'), [mDocQueue_ID]), HTTP_SC_NotFound);
  finally
    dtHeader.Free;
    if Assigned(json) then
      json.Free;
    LogWriteSectionEnd;
  end;
end;

procedure get_FirmOfficeInfo(AOS: TNxCustomObjectSpace; APath, AResponse: TStringList);
var
  mFirmOffice_ID, mFirm_ID: String;
  dtHeader: TMemTable;
  dtRows: TMemTable;
  mSL: TStringList;
  mSql: String;
  json: TJSONSuperObject;
begin
  json := nil;
  if (APath.Count = 3) then
  begin
    mFirmOffice_ID := APath.Strings[1];
    mFirm_ID := APath.Strings[2];
  end else
  begin
    SetPlainResponse(AResponse, getString('wrong_parameters_count'), HTTP_SC_BadRequest);
    exit;
  end;

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
    AOS.SQLSelect2(mSql, dtHeader);

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

      SetResponse(AResponse, json.AsJson(false, true));
    end
    else
      SetPlainResponse(AResponse, Format(getString('firmoffice_not_found'), [mFirmOffice_ID]), HTTP_SC_NotFound);
  finally
    dtHeader.Free;
    if Assigned(json) then
      json.Free;
    LogWriteSectionEnd;
  end;
end;

procedure get_PersonInfo(AOS: TNxCustomObjectSpace; APath, AResponse: TStringList);
var
  mPerson_ID, mFirm_ID: String;
  dtHeader: TMemTable;
  dtRows: TMemTable;
  mSL: TStringList;
  mSql: String;
  json: TJSONSuperObject;
begin
  json := nil;
  mFirm_ID := '';

  if (APath.Count = 2) or (APath.Count = 3) then
  begin
    mPerson_ID := APath.Strings[1];
    if APath.Count = 3 then
      mFirm_ID := APath.Strings[2];
  end else
  begin
    SetPlainResponse(AResponse, getString('wrong_parameters_count'), HTTP_SC_BadRequest);
    exit;
  end;

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
    AOS.SQLSelect2(mSql, dtHeader);

    if dtHeader.Active then
    begin
      dtHeader.First;
      LogWriteSectionStart('JSON');
      json := REST_jsonCreate_FromDataSetRow(dtHeader, nil, nil);
      LogWriteSectionEnd;

      SetResponse(AResponse, json.AsJson(false, true));
    end
    else
      SetPlainResponse(AResponse, Format(getString('person_not_found'), [mPerson_ID]), HTTP_SC_NotFound);
  finally
    dtHeader.Free;
    if Assigned(json) then
      json.Free;
    LogWriteSectionEnd;
  end;
end;

procedure get_TransportationTypeInfo(AOS: TNxCustomObjectSpace; APath, AResponse: TStringList);
var
  mTransportationType_ID: String;
  dtHeader: TMemTable;
  dtRows: TMemTable;
  mSL: TStringList;
  mSql: String;
  json: TJSONSuperObject;
begin
  json := nil;
  if (APath.Count = 2) then
  begin
    mTransportationType_ID := APath.Strings[1]; //ocekavam sklad
  end else
  begin
    SetPlainResponse(AResponse, getString('wrong_parameters_count'), HTTP_SC_BadRequest);
    exit;
  end;

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
    AOS.SQLSelect2(mSql, dtHeader);


    if dtHeader.Active then
    begin
      dtHeader.First;
      LogWriteSectionStart('JSON');
      json := REST_jsonCreate_FromDataSetRow(dtHeader, nil, nil);
      LogWriteSectionEnd;

      SetResponse(AResponse, json.AsJson(false, true));
    end
    else
      SetPlainResponse(AResponse, Format(getString('transportationtype_not_found'), [mTransportationType_ID]), HTTP_SC_NotFound);
  finally
    dtHeader.Free;
    if Assigned(json) then
      json.Free;
    LogWriteSectionEnd;
  end;
end;

procedure get_WorkplaceInfo(AOS: TNxCustomObjectSpace; APath, AResponse: TStringList);
var
  mWorkplace_ID: String;
  dtHeader: TMemTable;
  dtRows: TMemTable;
  mSL: TStringList;
  mSql: String;
  json: TJSONSuperObject;
begin
  json := nil;
  if (APath.Count = 2) then
  begin
    mWorkplace_ID := APath.Strings[1];
  end else
  begin
    SetPlainResponse(AResponse, getString('wrong_parameters_count'), HTTP_SC_BadRequest);
    exit;
  end;

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
    AOS.SQLSelect2(mSql, dtHeader);


    if dtHeader.Active then
    begin
      dtHeader.First;
      LogWriteSectionStart('JSON');
      json := REST_jsonCreate_FromDataSetRow(dtHeader, nil, nil);
      LogWriteSectionEnd;

      SetResponse(AResponse, json.AsJson(false, true));
    end
    else
      SetPlainResponse(AResponse, Format(getString('workplace_not_found'), [mWorkplace_ID]), HTTP_SC_NotFound);
  finally
    dtHeader.Free;
    if Assigned(json) then
      json.Free;
    LogWriteSectionEnd;
  end;
end;

procedure get_AssetLocationInfo(AOS: TNxCustomObjectSpace; APath, AResponse: TStringList);
var
  mAssetLocation_ID: String;
  dtHeader: TMemTable;
  dtRows: TMemTable;
  mSL: TStringList;
  mSql: String;
  json: TJSONSuperObject;
begin
  json := nil;
  if (APath.Count = 2) then
  begin
    mAssetLocation_ID := APath.Strings[1];
  end else
  begin
    SetPlainResponse(AResponse, getString('wrong_parameters_count'), HTTP_SC_BadRequest);
    exit;
  end;

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
    AOS.SQLSelect2(mSql, dtHeader);

    LogWriteSectionEnd;

    if dtHeader.Active then
    begin
      dtHeader.First;
      LogWriteSectionStart('JSON');
      json := REST_jsonCreate_FromDataSetRow(dtHeader, nil, nil);

      SetResponse(AResponse, json.AsJson(false, true));
    end
    else
      SetPlainResponse(AResponse, Format(getString('assetlocation_not_found'), [mAssetLocation_ID]), HTTP_SC_NotFound);
  finally
    dtHeader.Free;
    if Assigned(json) then
      json.Free;
    LogWriteSectionEnd;
  end;
end;

procedure get_AssetResponsibleInfo(AOS: TNxCustomObjectSpace; APath, AResponse: TStringList);
var
  mAssetResponsible_ID: String;
  dtHeader: TMemTable;
  dtRows: TMemTable;
  mSL: TStringList;
  mSql: String;
  json: TJSONSuperObject;
begin
  json := nil;
  if (APath.Count = 2) then
  begin
    mAssetResponsible_ID := APath.Strings[1];
  end else
  begin
    SetPlainResponse(AResponse, getString('wrong_parameters_count'), HTTP_SC_BadRequest);
    exit;
  end;

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
    AOS.SQLSelect2(mSql, dtHeader);

    if dtHeader.Active then
    begin
      dtHeader.First;
      LogWriteSectionStart('JSON');
      json := REST_jsonCreate_FromDataSetRow(dtHeader, nil, nil);
      LogWriteSectionEnd;

      SetResponse(AResponse, json.AsJson(false, true));
    end
    else
      SetPlainResponse(AResponse, Format(getString('assetresponsible_not_found'), [mAssetResponsible_ID]), HTTP_SC_NotFound);
  finally
    dtHeader.Free;
    if Assigned(json) then
      json.Free;
    LogWriteSectionEnd;
  end;
end;

procedure get_SmallAssetCardInfo(AOS: TNxCustomObjectSpace; APath, AResponse: TStringList);
var
  mSmallAssetCard_ID: String;
  mIsId: Boolean;
  dtHeader, dtRows: TMemTable;
  mSL: TStringList;
  mSql: String;
  json: TJSONSuperObject;
  mCount: Integer;
begin
  json := nil;
  if (APath.Count = 3) then
  begin
    mSmallAssetCard_ID := APath.Strings[1];
    mIsId := APath.Strings[2] = 'true';
  end else
  begin
    SetPlainResponse(AResponse, getString('wrong_parameters_count'), HTTP_SC_BadRequest);
    exit;
  end;

  dtHeader := TMemTable.Create(nil);
  LogWriteSectionStart('get_SmallAssetCardInfo');
  try
    // POZOR, zde se vraci namisto fieldu ciselniku (ID, Code, Name) fieldy pro StoreCard (StoreCard_ID, StoreCardCode, ...),
    // protoze je potreba to volat i behem specialniho parsovani
    mSql := GetSmallAssetCardInfoSql(AOS, mSmallAssetCard_ID, mIsId);

    AOS.SQLSelect2(mSql, dtHeader);

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
      mCount := SQLSelectInt(AOS, mSql);

      if mCount > 1 then
      begin
        RaiseException(Format(getString('error_saving_breakdown_has_too_many_rows'), [dtHeader.FieldByName('StoreCardName').AsString]));
      end;

      LogWriteSectionStart('JSON');
      json := REST_jsonCreate_FromDataSetRow(dtHeader, nil, nil);
      LogWriteSectionEnd;

      SetResponse(AResponse, json.AsJson(false, true));
    end
    else
      SetPlainResponse(AResponse, Format(getString('smallassetcard_not_found'), [mSmallAssetCard_ID]), HTTP_SC_NotFound);
  finally
    dtHeader.Free;
    if Assigned(json) then
      json.Free;
    LogWriteSectionEnd;
  end;
end;

procedure get_StoreMenuInfo(AOS: TNxCustomObjectSpace; APath, AResponse: TStringList);
var
  mStoreMenu_ID: String;
  dtHeader: TMemTable;
  dtRows: TMemTable;
  mSL: TStringList;
  mSql: String;
  json: TJSONSuperObject;
begin
  json := nil;
  if (APath.Count = 2) then
  begin
    mStoreMenu_ID := APath.Strings[1];
  end else
  begin
    SetPlainResponse(AResponse, getString('wrong_parameters_count'), HTTP_SC_BadRequest);
    exit;
  end;

  dtHeader := TMemTable.Create(nil);
  LogWriteSectionStart('get_StoreMenuInfo');
  try
    mSql :=
      'select' + nxCrLf +
      '  SM.ID as "ID",' + nxCrLf +
      '  SM.Text as "Code",' + nxCrLf +
      '  SM.Text as "Name",' + nxCrLf +
      '  SM2.Parent_ID "Parent_ID",' + nxCrLf +
      '  SM2.Text "ParentText"' + nxCrLf +
      'from StoreMenu SM' + nxCrLf +
      'left join StoreMenu SM2 on SM2.ID = SM.Parent_ID' + nxCrLf +
      'where' + nxCrLf +
      '  SM.ID = ' + QuotedStr(mStoreMenu_ID) + nxCrLf +
      '  and SM.Hidden = ''N''';
    AOS.SQLSelect2(mSql, dtHeader);

    if dtHeader.Active then
    begin
      dtHeader.First;
      LogWriteSectionStart('JSON');
      json := REST_jsonCreate_FromDataSetRow(dtHeader, nil, nil);
      LogWriteSectionEnd;

      SetResponse(AResponse, json.AsJson(false, true));
    end
    else
      SetPlainResponse(AResponse, Format(getString('storemenu_not_found'), [mStoreMenu_ID]), HTTP_SC_NotFound);
  finally
    dtHeader.Free;
    if Assigned(json) then
      json.Free;
    LogWriteSectionEnd;
  end;
end;

function get_ListBusOrders(ASearch: String): String;
var
  AOS: TNxCustomObjectSpace; APath, AResponse: TStringList;
  mSearchStr: String;
  dtRows: TMemTable;
  mSql: String;
  json: TJSONSuperObject;
begin
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
    if trim(ASearch) <> '' then
    begin
      // muze se stat, ze nekdo do hledaciho okynka naskenuje carovy kod pozice ve tvaru SPXXXXXXXXXX
      if (length(ASearch) = 12) and (copy(ASearch, 1, 2) = 'BO') then
        mSearchStr := copy(ASearch, 3, 10);
      mSql := mSql +
        '  and (BO.Code' + COLLATION_AI + 'like ''%' + ASearch + '%''' + nxCrLf +
        '    or BO.Name' + COLLATION_AI + 'like ''%' + ASearch + '%''' + nxCrLf +
        '    or BO.ID = ' + QuotedStr(ASearch) + ')' + nxCrLf;
    end;
    mSql := mSql +
      'order by' + nxCrLf +
      '  BO.Code' + nxCrLf;
    mSql := mSql + FIRST_TOP_ORACLE(100);

    Result := mSql;
  finally
    LogWriteSectionEnd;
  end;
end;

function get_ListBusProjects(ASearch: String): String;
var
  AOS: TNxCustomObjectSpace; APath, AResponse: TStringList;
  mSearchStr: String;
  dtRows: TMemTable;
  mSql: String;
  json: TJSONSuperObject;
begin
  LogWriteSectionStart('get_ListBusProjects');
  try
    mSql :=
      'select' + FIRST_TOP(100) + nxCrLf +
      '  BP.ID as "ID",' + nxCrLf +
      '  BP.Code as "Code",' + nxCrLf +
      '  BP.Name as "Name"' + nxCrLf +
      'from BusProjects BP' + nxCrLf +
      'where' + nxCrLf +
      '  BP.Hidden = ''N''' + nxCrLf;

    if trim(ASearch) <> '' then
    begin
      if (length(ASearch) = 12) and (copy(ASearch, 1, 2) = 'BO') then
        mSearchStr := copy(ASearch, 3, 10);
      mSql := mSql +
        '  and (BP.Code' + COLLATION_AI + 'like ''%' + ASearch + '%''' + nxCrLf +
        '    or BP.Name' + COLLATION_AI + 'like ''%' + ASearch + '%''' + nxCrLf +
        '    or BP.ID = ' + QuotedStr(ASearch) + ')' + nxCrLf;
    end;
    mSql := mSql +
      'order by' + nxCrLf +
      '  BP.Code' + nxCrLf;
    mSql := mSql + FIRST_TOP_ORACLE(100);

    Result := mSql;
  finally
    LogWriteSectionEnd;
  end;
end;

function get_ListBusTransactions(ASearch: String): String;
var
  AOS: TNxCustomObjectSpace; APath, AResponse: TStringList;
  mSearchStr: String;
  dtRows: TMemTable;
  mSql: String;
  json: TJSONSuperObject;
begin
  LogWriteSectionStart('get_ListBusTransactions');
  try
    mSql :=
      'select' + FIRST_TOP(100) + nxCrLf +
      '  BT.ID as "ID",' + nxCrLf +
      '  BT.Code as "Code",' + nxCrLf +
      '  BT.Name as "Name"' + nxCrLf +
      'from BusTransactions BT' + nxCrLf +
      'where' + nxCrLf +
      '  BT.Hidden = ''N''' + nxCrLf;

    // pripadne hledani
    if trim(ASearch) <> '' then
    begin
      // muze se stat, ze nekdo do hledaciho okynka naskenuje carovy kod pozice ve tvaru SPXXXXXXXXXX
      if (length(ASearch) = 12) and (copy(ASearch, 1, 2) = 'BO') then
        mSearchStr := copy(ASearch, 3, 10);
      mSql := mSql +
        '  and (BT.Code' + COLLATION_AI + 'like ''%' + ASearch + '%''' + nxCrLf +
        '    or BT.Name' + COLLATION_AI + 'like ''%' + ASearch + '%''' + nxCrLf +
        '    or BT.ID = ' + QuotedStr(ASearch) + ')' + nxCrLf;
    end;
    mSql := mSql +
      'order by' + nxCrLf +
      '  BT.Code' + nxCrLf;
    mSql := mSql + FIRST_TOP_ORACLE(100);

    Result := mSql;
  finally
    LogWriteSectionEnd;
  end;
end;

function get_ListDivisions(ASearch: String): String;
var
  mSql: String;
begin
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
    if trim(ASearch) <> '' then
    begin
      // muze se stat, ze nekdo do hledaciho okynka naskenuje carovy kod pozice ve tvaru SPXXXXXXXXXX
      if (length(ASearch) = 12) and (copy(ASearch, 1, 2) = 'BO') then
        ASearch := copy(ASearch, 3, 10);
      mSql := mSql +
        '  and (D.Code' + COLLATION_AI + 'like ''%' + ASearch + '%''' + nxCrLf +
        '    or D.Name' + COLLATION_AI + 'like ''%' + ASearch + '%''' + nxCrLf +
        '    or D.ID = ' + QuotedStr(ASearch) + ')' + nxCrLf;
    end;
    mSql := mSql +
      'order by' + nxCrLf +
      '  D.Code' + nxCrLf;
    mSql := mSql + FIRST_TOP_ORACLE(100);

    Result := mSql;
  finally
    LogWriteSectionEnd;
  end;
end;

function get_ListDocQueues(ASearch: String): String;
var
  mSql: String;
begin
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
      '  and DQ.DocumentType = ' + QuotedStr(gSkladTermDocType) + nxCrLf;

    // pripadne hledani
    if trim(ASearch) <> '' then
    begin
      // muze se stat, ze nekdo do hledaciho okynka naskenuje carovy kod pozice ve tvaru SPXXXXXXXXXX
      if (length(ASearch) = 12) and (copy(ASearch, 1, 2) = 'DQ') then
        ASearch := copy(ASearch, 3, 10);
      mSql := mSql +
        '  and (DQ.Code' + COLLATION_AI + 'like ''%' + ASearch + '%''' + nxCrLf +
        '    or DQ.Name' + COLLATION_AI + 'like ''%' + ASearch + '%''' + nxCrLf +
        '    or DQ.ID = ' + QuotedStr(ASearch) + ')' + nxCrLf;
    end;
    mSql := mSql +
      'order by' + nxCrLf +
      '  DQ.Code' + nxCrLf;
    mSql := mSql + FIRST_TOP_ORACLE(100);

    Result := mSql;
  finally
    LogWriteSectionEnd;
  end;
end;

function get_ListFirmOffices(ASearch, AFirm_ID: String): String;
var
  mSql: String;
begin
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
      '  FO.Parent_ID = ' + QuotedStr(AFirm_ID) + nxCrLf;

    if not ABRA then
      mSql := mSql +
        '  and FO.Hidden = ''N''' + nxCrLf;

    // pripadne hledani
    if trim(ASearch) <> '' then
    begin
      // muze se stat, ze nekdo do hledaciho okynka naskenuje carovy kod pozice ve tvaru SPXXXXXXXXXX
      if (length(ASearch) = 12) and (copy(ASearch, 1, 2) = 'FO') then
        ASearch := copy(ASearch, 3, 10);
      mSql := mSql +
        '  and (FO.Name' + COLLATION_AI + 'like ''%' + ASearch + '%''' + nxCrLf +
        '    or FO.ID = ' + QuotedStr(ASearch) + ')' + nxCrLf;
    end;
    mSql := mSql +
      'order by' + nxCrLf +
      '  FO.Name' + nxCrLf;
    mSql := mSql + FIRST_TOP_ORACLE(100);

    Result := mSql;
  finally
    LogWriteSectionEnd;
  end;
end;

function get_ListPersons(AOS: TNxCustomObjectSpace; ASearch, AFirm_ID: String): String;
var
  mSelect, mFrom, mWhere, mJoin, mOrderBy: String;
  mSql: String;
  mParameters: TStringList;
begin
  LogWriteSectionStart('get_ListPersons');
  try
    mSelect := '';
    mFrom := '';
    mWhere := '';
    mJoin := '';
    mOrderBy := '';

    mParameters := TStringList.Create;
    try
      mSelect :=
        '  P.ID as "ID",' + nxCrLf +
        '  P.FirstName ' + CONCAT_STR + ' '' '' ' + CONCAT_STR + ' P.LastName as "Code",' + nxCrLf +
        '  P.FirstName ' + CONCAT_STR + ' '' '' ' + CONCAT_STR + ' P.LastName as "Name"';

      mFrom :=
        'Persons P';

      // pokud je firma, tak osoby omezime pouze na ni
      if not CFxOID.IsEmpty(AFirm_ID) then
        mJoin := mJoin +
          'join FirmPersons FP on FP.Person_ID = P.ID and FP.Parent_ID = ' + QuotedStr(AFirm_ID);

      mWhere :=
        '  P.Hidden = ''N''';

      // pripadne hledani
      if trim(ASearch) <> '' then
      begin
        // muze se stat, ze nekdo do hledaciho okynka naskenuje carovy kod ve tvaru PEXXXXXXXXXX
        if (length(ASearch) = 12) and (copy(ASearch, 1, 2) = 'PE') then
          ASearch := copy(ASearch, 3, 10);
        mWhere := mWhere + nxCrLf +
          '  and (P.LastName' + COLLATION_AI + 'like ''%' + ASearch + '%'' ' + nxCrLf +
          '    or P.FirstName' + COLLATION_AI + 'like ''%' + ASearch + '%'' ' + nxCrLf +
          '    or P.ID = ' + QuotedStr(ASearch) + ')';
      end;

      mOrderBy :=
        '  P.LastName, P.FirstName' + nxCrLf;

      mParameters.Values('firm_id') := AFirm_ID;
      mParameters.Values('select') := mSelect;
      mParameters.Values('from') := mFrom;
      mParameters.Values('join') := mJoin;
      mParameters.Values('where') := mWhere;
      mParameters.Values('orderby') := mOrderBy;

      FilterList(AOS, gSkladTermModule, gSkladTermDocType, gSkladTermUser_ID, 'get_ListPersons', mParameters);

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

      Result := mSql;
    finally
      mParameters.Free;
    end;
  finally
    LogWriteSectionEnd;
  end;
end;

function get_ListTransportationTypes(ASearch: String): String;
var
  mSql: String;
begin
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
    if trim(ASearch) <> '' then
    begin
      // muze se stat, ze nekdo do hledaciho okynka naskenuje carovy kod pozice ve tvaru SPXXXXXXXXXX
      if (length(ASearch) = 12) and (copy(ASearch, 1, 2) = 'TT') then
        ASearch := copy(ASearch, 3, 10);
      mSql := mSql + ' and (TT.Code' + COLLATION_AI + 'like ''%' + ASearch + '%'' ' + nxCrLf +
        '  or TT.Name' + COLLATION_AI + 'like ''%' + ASearch + '%'' ' + nxCrLf +
        '  or TT.ID = ' + QuotedStr(ASearch) + ')' + nxCrLf;
    end;
    mSql := mSql +
      'order by' + nxCrLf +
      '  TT.Code' + nxCrLf;
    mSql := mSql + FIRST_TOP_ORACLE(100);

    Result := mSql;
  finally
    LogWriteSectionEnd;
  end;
end;

function get_ListWorkplaces(ASearch: String): String;
var
  mSql: String;
begin
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
    if trim(ASearch) <> '' then
    begin
      // muze se stat, ze nekdo do hledaciho okynka naskenuje carovy kod pozice ve tvaru SPXXXXXXXXXX
      if (length(ASearch) = 12) and (copy(ASearch, 1, 2) = 'WP') then
        ASearch := copy(ASearch, 3, 10);
      mSql := mSql +
        '  and (WP.Code' + COLLATION_AI + 'like ''%' + ASearch + '%'' ' + nxCrLf +
        '    or WP.Title' + COLLATION_AI + 'like ''%' + ASearch + '%'' ' + nxCrLf +
        '    or WP.ID = ' + QuotedStr(ASearch) + ')' + nxCrLf;
    end;
    mSql := mSql +
      'order by' + nxCrLf +
      '  WP.Code' + nxCrLf;
    mSql := mSql + FIRST_TOP_ORACLE(100);

    Result := mSql;
  finally
    LogWriteSectionEnd;
  end;
end;

function get_ListAssetLocations(ASearch: String): String;
var
  mSql: String;
begin
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
    if trim(ASearch) <> '' then
    begin
      // muze se stat, ze nekdo do hledaciho okynka naskenuje carovy kod ve tvaru SPXXXXXXXXXX
      if (length(ASearch) = 12) and (copy(ASearch, 1, 2) = 'AL') then
        ASearch := copy(ASearch, 3, 10);
      mSql := mSql +
        '  and (AL.Code' + COLLATION_AI + 'like ''%' + ASearch + '%'' ' + nxCrLf +
        '    or AL.Name' + COLLATION_AI + 'like ''%' + ASearch + '%'' ' + nxCrLf +
        '    or AL.ID = ' + QuotedStr(ASearch) + ')' + nxCrLf;
    end;
    mSql := mSql +
      'order by' + nxCrLf +
      '  AL.Code' + nxCrLf;
    mSql := mSql + FIRST_TOP_ORACLE(100);

    Result := mSql;
  finally
    LogWriteSectionEnd;
  end;
end;

function get_ListAssetResponsibles(ASearch: String): String;
var
  mSql: String;
begin
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
    if trim(ASearch) <> '' then
    begin
      // muze se stat, ze nekdo do hledaciho okynka naskenuje carovy kod pozice ve tvaru SPXXXXXXXXXX
      if (length(ASearch) = 12) and (copy(ASearch, 1, 2) = 'AR') then
        ASearch := copy(ASearch, 3, 10);
      mSql := mSql +
        '  and (P.PersonalNumber' + COLLATION_AI + 'like ''%' + ASearch + '%'' ' + nxCrLf +
        '    or P.LastName' + COLLATION_AI + 'like ''%' + ASearch + '%'' ' + nxCrLf +
        '    or P.FirstName' + COLLATION_AI + 'like ''%' + ASearch + '%'' ' + nxCrLf +
        '    or AR.ID = ' + QuotedStr(ASearch) + ')' + nxCrLf;
    end;
    mSql := mSql +
      'order by' + nxCrLf +
      '  P.PersonalNumber' + nxCrLf;
    mSql := mSql + FIRST_TOP_ORACLE(100);

    Result := mSql;
  finally
    LogWriteSectionEnd;
  end;
end;

function get_ListSmallAssetCards(ASearch: String): String;
var
  mSql: String;
begin
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
    if trim(ASearch) <> '' then
    begin
      // muze se stat, ze nekdo do hledaciho okynka naskenuje carovy kod pozice ve tvaru SAXXXXXXXXXX
      if (length(ASearch) = 12) and (copy(ASearch, 1, 2) = 'SA') then
        ASearch := copy(ASearch, 3, 10);
      mSql := mSql +
        '  and (SAC.InventoryNr' + COLLATION_AI + 'like ''%' + ASearch + '%'' ' + nxCrLf +
        '    or SAC.Name' + COLLATION_AI + 'like ''%' + ASearch + '%'' ' + nxCrLf +
        '    or SAC.ID = ' + QuotedStr(ASearch) + ')' + nxCrLf;
    end;
    mSql := mSql +
      'order by' + nxCrLf +
      '  SAC.InventoryNr' + nxCrLf;
    mSql := mSql + FIRST_TOP_ORACLE(100);

    Result := mSql;
  finally
    LogWriteSectionEnd;
  end;
end;

function get_ListDocuments(ASearch, mAllowedIds: String): String;
var
  mSql: String;
begin
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
    if mAllowedIds = '' then
      mAllowedIds := '0000000000';

    mSql := mSql +
      'where' + nxCrLf +
      '  D.ID in (''' + ReplaceText(mAllowedIds, ',', ''',''') + ''')' + nxCrLf;

    // pripadne hledani
    if trim(ASearch) <> '' then
    begin
      mSql := mSql +
        '  and (DQ.Code' + CONCAT_STR + QuotedStr('-') + CONCAT_STR + 'cast(D.OrdNumber as varchar(6))' +
          CONCAT_STR + QuotedStr('/') + CONCAT_STR + 'P.Code like ''%' + ASearch + '%'' ' + nxCrLf +
        '    or D.Description' + COLLATION_AI + 'like ''%' + ASearch + '%'')' + nxCrLf;
    end;
    mSql := mSql +
      'order by' + nxCrLf +
      '  DQ.Code' + CONCAT_STR + QuotedStr('-') + CONCAT_STR + 'cast(D.OrdNumber as varchar(6))' +
          CONCAT_STR + QuotedStr('/') + CONCAT_STR + 'P.Code' + nxCrLf;
    mSql := mSql + FIRST_TOP_ORACLE(100);

    Result := mSql;
  finally
    LogWriteSectionEnd;
  end;
end;

function get_ListStoreMenus(ASearch: String): String;
var
  mSql: String;
begin
  LogWriteSectionStart('get_ListStoreMenus');
  try
    mSql :=
      'select' + FIRST_TOP(100) + nxCrLf +
      '  SM.ID as "ID",' + nxCrLf +
      '  SM.Text as "Code",' + nxCrLf +
      '  case' + nxCrLf +
      '    when SM2.Text is null' + nxCrLf +
      '    then SM.Text' + nxCrLf +
      '    else SM2.Text' + CONCAT_STR + '''/''' + CONCAT_STR + 'SM.Text' + nxCrLf +
      '  end as "Name"' + nxCrLf +
      'from StoreMenu SM' + nxCrLf +
      'left join StoreMenu SM2 on SM2.ID = SM.Parent_ID' + nxCrLf +
      'where' + nxCrLf +
      '  SM.Hidden = ''N''' + nxCrLf;

    // pripadne hledani
    if trim(ASearch) <> '' then
    begin
      // muze se stat, ze nekdo do hledaciho okynka naskenuje carovy kod pozice ve tvaru SPXXXXXXXXXX
      if (length(ASearch) = 12) and (copy(ASearch, 1, 2) = 'SM') then
        ASearch := copy(ASearch, 3, 10);
      mSql := mSql +
        '  and (SM.Text' + COLLATION_AI + 'like ''%' + ASearch + '%''' + nxCrLf +
        '    or SM2.Text' + COLLATION_AI + 'like ''%' + ASearch + '%''' + nxCrLf +
        '    or SM.ID = ' + QuotedStr(ASearch) + ')' + nxCrLf;
    end;
    mSql := mSql +
      'order by' + nxCrLf +
      '  SM.Text' + nxCrLf;
    mSql := mSql + FIRST_TOP_ORACLE(100);

    Result := mSql;
  finally
    LogWriteSectionEnd;
  end;
end;

procedure rolls(AOS: TNxCustomObjectSpace; APath, AQueryParams, AResponse: TStringList);
var
  mSql, mRollType, mSearchStr, mStoreCardId, mStoreId, mStoreBatchId, mFirmId,
    mStorePositionId, mAllowedIds: String;
  mOnlyAvailable, mInPositionFirst, mOnlyLogistic: Boolean;
  json: TJSONSuperObject;
  mRows: TMemTable;
begin
  json := nil;
  mSearchStr := '';
  if (APath.Count = 2) or (APath.Count = 3) then
  begin
    mRollType := APath.Strings[1];
    if APath.Count = 3 then
      mSearchStr := CFxInternet.URLDecode(ReplaceStr(APath.Strings[2], '+', ' '));
  end else
  begin
    SetPlainResponse(AResponse, getString('wrong_parameters_count'), HTTP_SC_BadRequest);
    exit;
  end;

  LogWriteSectionStart('rolls');
  mRows := TMemTable.Create(nil);
  try
    mStoreCardId := AQueryParams.Values('storeCardId');
    mStoreId := AQueryParams.Values('storeId');
    mStoreBatchId := AQueryParams.Values('storeBatchId');
    mStorePositionId := AQueryParams.Values('storePositionId');
    mFirmId := AQueryParams.Values('firmId');
    mAllowedIds := AQueryParams.Values('allowedIds');
    mOnlyAvailable := AQueryParams.Values('onlyAvailable') = 'true';
    mOnlyLogistic := AQueryParams.Values('onlyLogistic') = 'true';
    mInPositionFirst := AQueryParams.Values('inStockFirst') = 'true';

    mSql := '';
    case mRollType of
      'ASSET_LOCATION': mSql := get_ListAssetLocations(mSearchStr);
      'ASSET_RESPONSIBLE': mSql := get_ListAssetResponsibles(mSearchStr);
      'BUS_ORDER': mSql := get_ListBusOrders(mSearchStr);
      'BUS_PROJECT': mSql := get_ListBusProjects(mSearchStr);
      'BUS_TRANSACTION': mSql := get_ListBusTransactions(mSearchStr);
//      'CUSTOMER': get_
//      'DIALOG'
      'DIVISION': mSql := get_ListDivisions(mSearchStr);
      'DOC_QUEUE': mSql := get_ListDocQueues(mSearchStr);
      'DOCUMENT': mSql := get_ListDocuments(mSearchStr, mAllowedIds);
      'FIRM': mSql := listFirms(AOS, mSearchStr);
      'FIRM_OFFICE': mSql := get_ListFirmOffices(mSearchStr, mFirmId);
      'PERSON': mSql := get_ListPersons(AOS, mSearchStr, mFirmId);
      'POST_PROVIDER': mSql := listPostProviders(mSearchStr);
      'SMALLL_ASSET_CARD': mSql := get_ListSmallAssetCards(mSearchStr);
      'STORE_BATCH': mSql := get_ListStoreBatches(AOS, mSearchStr, mStoreCardId, mStoreId, mStorePositionId, mOnlyAvailable);
      'STORE_CARD': mSql := listStoreCards(AOS, mSearchStr, mStorePositionId, mAllowedIds);
      'STORE_MENU': mSql := get_ListStoreMenus(mSearchStr);
      'STORE_POSITION': mSql := listStorePositions(AOS, mSearchStr, mStoreId, mStoreCardId, mStoreBatchId, mOnlyAvailable, mInPositionFirst);
      'STORE': mSql := listStores(AOS, mSearchStr, mOnlyLogistic);
      'STORE_UNIT': mSql := listStoreUnits(mSearchStr, mStoreCardId);
      'TRANSPORTATION_TYPE': mSql := get_ListTransportationTypes(mSearchStr);
      'WORKPLACE': mSql := get_ListWorkplaces(mSearchStr);
      else RaiseException(Format(getString('rolltype_not_found'), [mRollType]))
    end;
    AOS.SQLSelect2(mSql, mRows);

    if mRows.Active then
    begin
      json := REST_jsonCreate_FromDataSet(mRows, nil, nil);
    end
    else begin
      json := TJSONSuperObject.CreateByDataType(jtArray);
    end;
    SetResponse(AResponse, json.AsJson(false, true));
  finally
    mRows.Free;
    if Assigned(json) then
      json.Free;
    LogWriteSectionEnd;
  end;
end;

begin
end.