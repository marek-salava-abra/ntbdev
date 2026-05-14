uses
  'REST_SkladTerm.U_Func',
  'REST_SkladTerm.U_FuncJSON',
  'REST_SkladTerm.U_LogStoreDocument',
  'REST_SkladTerm.U_Requests',
  'REST_SkladTerm.U_SQLQueries',
  'REST_SkladTerm.U_TemporaryStorage',
  'REST_SkladTerm_Special.U_Const',
  'REST_SkladTerm_Special.U_StandardHooks',
  'StandardUnits.U_DataSet',
  'StandardUnits.U_GetId';

procedure cancelInventorizationByDIP(mUser_Id, mDoc_ID: string; mTemporaryStorageID: integer; os: TNxCustomObjectSpace);
var
  mBO: TNxCustomBusinessObject;
begin
  mBO := os.CreateObject(Class_PartialInvProtocol);
  try
    mBO.ExplicitTransaction := True;
    mBO.Load(mDoc_ID, nil);

    if mBO.GetFieldValueAsString('User_ID') <> mUser_Id then
      RaiseException(getString('document_another_user'));

    mBO.SetFieldValueAsString('User_ID', '');

    TemporaryStorage_Delete(os, mTemporaryStorageID);

    mBO.save;
  finally
    mBO.Free;
  end;
end;

procedure cancelInventorizationFree(mTemporaryStorageID: integer; os: TNxCustomObjectSpace);
var
  mBO: TNxCustomBusinessObject;
  mUserId: string;
begin
    TemporaryStorage_Delete(os, mTemporaryStorageID);
end;

procedure isStoreLogistic(Self: TNxWebServicesHelper; ARequest: TNxHTTPRequest;
  AResponse: TNxHTTPResponse; slPath: TStringList);
var
  storeId: string;
  dtRows: TMemTable;
  mSql, mResult: String;
  //json: TJSONSuperObject;
begin
  //json := nil;
  if ((slPath.Count = 2)) then
  begin
    storeId := slPath.Strings[1];
  end else
  begin
    ErrREST(ARequest, AResponse, HTTP_SC_BadRequest, getString('wrong_parameters_count'));
    exit;
  end;

  dtRows := TMemTable.Create(nil);
  try
    LogWriteSectionStart('isStoreLogistic');
    mSql := 'select ' +
      '   case ' +
      '     when S.isLogistic = ''A'' ' +
      '     then ''true'' ' +
      '     else ''false'' ' +
      '   end "isLogistic" ' +
      ' from Stores S ' +
      'where S.id = ' + QuotedStr(storeId);
    Self.ObjectSpace.SQLSelect2(mSql, dtRows);
    LogWriteSectionEnd;

    LogWriteSectionStart('JSON');
    if dtRows.Active then
    begin
      mResult := dtRows.FieldByName('isLogistic').AsString;
    end
    else begin
    end;
    LogWriteSectionEnd;

    HTTPResponse(AResponse, HTTP_SC_OK, ContentType_JSON, PlainResponse(mResult));
  finally
    dtRows.Free;
  end;
end;

procedure listStorePositionsForInv(Self: TNxWebServicesHelper; ARequest: TNxHTTPRequest;
  AResponse: TNxHTTPResponse; slPath: TStringList);
var
  mSearchStr, doc_ID, storeCard_ID: String;
  dtRows: TMemTable;
  mSql: String;
  json: TJSONSuperObject;
begin
  json := nil;
  mSearchStr := '';
  if ((slPath.Count >= 2) and (slPath.Count <=4)) then
  begin
    doc_ID := slPath.Strings[1];
    storeCard_ID := slPath.Strings[2];
    if slPath.Count = 4 then
      mSearchStr := slPath.Strings[3]; //ocekavam retezec hledani
  end else
  begin
    ErrREST(ARequest, AResponse, HTTP_SC_BadRequest, getString('wrong_parameters_count'));
    exit;
  end;

  dtRows := TMemTable.Create(nil);
  try
    LogWriteSectionStart('ListStorePositions');
    mSql :=
      'select ' + FIRST_TOP(100) + nxCrLf +
      '   SP.ID as "ID", ' + nxCrLf +
      '   SP.Code as "Code", ' + nxCrLf +
      '   SP.Name as "Name" ' + nxCrLf +
      ' from PartialInvProtocolPositions PIP ' + nxCrLf +
      ' join MainInvProtocolPositions MIPP on PIP.MIPPosition_ID = MIPP.id ' + nxCrLf +
      ' join LogStorePositions SP on MIPP.StorePosition_ID = SP.id ' + nxCrLf +
      'where PIP.Parent_ID = ' + QuotedStr(doc_ID);
    {mSql := 'select ' + FIRST_TOP + ' 100 ' +
      '   SP.ID as "ID", ' +
      '   SP.Code as "Code", ' +
      '   SP.Name as "Name" ' +
      ' from PartialInvProtocolRows PIR ' +
      ' join MainInvProtocolRows MIR on PIR.MIPRow_ID = MIR.id ' +
//      ' join PartialInvProtocolPositions PIP on PIR.PIPPosition_ID = PIP.id' +
      ' join MainInvProtocolPositions MIPP on MIR.MIPPosition_ID = MIPP.id ' +
      ' join LogStorePositions SP on MIPP.StorePosition_ID = SP.id ' +
      ' where ' +
      '   PIR.Parent_ID = ' + QuotedStr(doc_ID) +
      '   and MIR.StoreCard_ID = ' + QuotedStr(storeCard_ID);}
    // pripadne hledani
    if trim(mSearchStr) <> '' then
      mSql := mSql + ' and (SP.Code' + COLLATION_AI + 'like ''%' + mSearchStr + '%'' ' +
        '  or SP.Name' + COLLATION_AI + 'like ''%' + mSearchStr + '%'') ';
    mSql := mSql + ' order by SP.Code ';
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
    LogWriteSectionEnd;

    HTTPResponse(AResponse, HTTP_SC_OK, ContentType_JSON, json.AsJson(false, true));
  finally
    dtRows.Free;
    if Assigned(json) then
      json.Free;
  end;
end;

procedure putNewStoreBatches(Self: TNxWebServicesHelper; ARequest: TNxHTTPRequest;
  AResponse: TNxHTTPResponse; slPath: TStringList);
var
  mSql, mStoreBatchName, sStoreCard_ID, sSql: string;
  boStoreBatch: TNxCustomBusinessObject;
  dtJSONBatches, dtBatches: TMemTable;
  jsonI: TJSONSuperObject;
  i: integer;

begin
  jsonI := TJSONSuperObject.ParseString(REST_ByteUTF82String(ARequest.Content.Content), True);

  dtJSONBatches := TMemTable.Create(nil);
  try
    //dataset se sarzemi
    DataSet_CreataHeader(dtJSONBatches, 'jsonIndex=I,StoreCard_ID=S10,StoreBatchName=S50,StoreCardCategory=I,StoreBatchSpecification=S30');
    dtJSONBatches.AddIndex('ByJsonIndex', 'jsonIndex', [ixUnique]);
    dtJSONBatches.Open;
    REST_JsonToDataSet(jsonI.A['serialNumbers'], dtJSONBatches);
    dtJSONBatches.First;
    i := 0;

    boStoreBatch := Self.ObjectSpace.CreateObject(Class_StoreBatch);
    try
      //vytvorim sarze a seriova cisla
      while not dtJSONBatches.Eof do
      begin
        //zjistim jestli uz sarze existuje
        sSql := 'select ID from StoreBatches where StoreCard_ID = ' + QuotedStr(dtJSONBatches.FieldByName('StoreCard_ID').AsString)
          + ' and Name = ' + QuotedStr(dtJSONBatches.FieldByName('StoreBatchName').AsString)
          + ' and Hidden = ''N''';
        dtBatches := TMemTable.Create(nil);
        try
          Self.ObjectSpace.SQLSelect2(sSql, dtBatches);
          //pokd neexistuje tak vytvorim novou
          if dtBatches.IsEmpty then
          begin
            try
              boStoreBatch.New;
              boStoreBatch.SetFieldValueAsString('StoreCard_ID', dtJSONBatches.FieldByName('StoreCard_ID').AsString);
              boStoreBatch.SetFieldValueAsString('Name', dtJSONBatches.FieldByName('StoreBatchName').AsString);

              //pokud je to seriove cislo, tak oznacim a pridam AUX
              if dtJSONBatches.FieldByName('StoreCardCategory').AsInteger = 1 then
              begin
                boStoreBatch.SetFieldValueAsBoolean('SerialNumber', true);
                boStoreBatch.SetFieldValueAsString('Specification', dtJSONBatches.FieldByName('StoreBatchSpecification').AsString);
              end;
              boStoreBatch.Save;
              //jen abych mel co vratit, v aplikaci se ale nepouzije
              jsonI.A['serialNumbers'].O[i].S('StoreBatch_ID') := boStoreBatch.OID;
            except
              HTTPResponse(AResponse, HTTP_SC_ExpectationFailed, ContentType_PlainText, ExceptionMessage);
              exit;
            end;
          end;
          dtJSONBatches.Next;
          i := i + 1;
        finally
          dtBatches.free;
        end;
      end;
    finally
      boStoreBatch.Free;
    end;
  finally
    dtJSONBatches.Free;
  end;

  HTTPResponse(AResponse, HTTP_SC_OK, ContentType_JSON, jsonI.AsJson(false, true));
end;

procedure putNewStoreBatch(Self: TNxWebServicesHelper; ARequest: TNxHTTPRequest;
  AResponse: TNxHTTPResponse; slPath: TStringList);
var
  mSql, mStoreBatchName, sStoreCard_ID, mModuleName, mUser_ID, mDocType: string;
  boStoreBatch: TNxCustomBusinessObject;
  checkBatchName: boolean;
  dtRows: TMemTable;
  json, jsonI: TJSONSuperObject;
begin
  mModuleName := getHeaderValue(ARequest, 'ModuleCode');
  mUser_ID := getHeaderValue(ARequest, 'UserID');
  mDocType := getHeaderValue(ARequest, 'DocumentType');

  jsonI := TJSONSuperObject.ParseString(REST_ByteUTF82String(ARequest.Content.Content), True);
  json := TJSONSuperObject.CreateByDataType(jtObject);
  dtRows := TMemTable.Create(nil);
  try
    mStoreBatchName := jsonI.S['StoreBatchName'];
    sStoreCard_ID := jsonI.S['StoreCard_ID'];

    // pokud je v ceste nastaveno, ze se kontrolovat nazev nema (treba protoze se vyplnuje automaticky), tak nekontroluju
    // pokud neni v ceste nastaveno, tak se kontroluje
    checkBatchName := True;
    if slPath.Count = 2 then
      checkBatchName := StrToBool(slPath[1]);

    if checkBatchName and (mStoreBatchName = '') then
    begin
      ErrREST(ARequest, AResponse, HTTP_SC_BadRequest, getString('storebatch_name_not_entered'));
      exit;
    end;

    mSql :=
      'select ID "StoreBatch_ID", Name "StoreBatchName"' + NxCrLf +
      'from StoreBatches' + NxCrLf +
      'where Name = ' + QuotedStr(mStoreBatchName) + NxCrLf +
      'and StoreCard_ID = ' + QuotedStr(sStoreCard_ID);
    Self.ObjectSpace.SQLSelect2(mSql, dtRows);

    LogWriteSectionStart('JSON');
    if not dtRows.IsEmpty then
    begin
      dtRows.First;
      json.S['StoreBatch_ID'] := dtRows.FieldByName('StoreBatch_ID').AsString;
      json.S['StoreBatchName'] := dtRows.FieldByName('StoreBatchName').AsString;
      HTTPResponse(AResponse, HTTP_SC_OK, ContentType_JSON, json.AsJson(false, true));
    end
    else
    begin
      boStoreBatch := Self.ObjectSpace.CreateObject(Class_StoreBatch);
      try
        try
          boStoreBatch.New;
          boStoreBatch.SetFieldValueAsString('StoreCard_ID', sStoreCard_ID);
          boStoreBatch.SetFieldValueAsString('Name', mStoreBatchName);
          putNewStoreBatch_beforeSaveHook(Self.ObjectSpace, mModuleName, mDocType, mUser_ID, boStoreBatch);
          boStoreBatch.Save;
        except
          HTTPResponse(AResponse, HTTP_SC_ExpectationFailed, ContentType_PlainText, ExceptionMessage);
          exit;
        end;

        json.S['StoreBatch_ID'] := boStoreBatch.OID;
        json.S['StoreBatchName'] := mStoreBatchName;
        HTTPResponse(AResponse, HTTP_SC_OK, ContentType_JSON, json.AsJson(false, true));
      finally
        boStoreBatch.Free;
      end;
    end;
    LogWriteSectionEnd;
  finally
    dtRows.Free;
    jsonI.Free;
    json.Free;
  end;
end;

////////////////////////////////////////////////////////////////////////////////
procedure listPartialInvProtocols(Self: TNxWebServicesHelper; ARequest: TNxHTTPRequest;
  AResponse: TNxHTTPResponse; slPath: TStringList);
var
  mUser_ID, mDocType, mModule: String;
  dtRows: TMemTable;
  mSql, mSearchStr: String;
  json: TJSONSuperObject;
begin
  json := nil;
  mSearchStr := '';
  if ((slPath.Count >= 1) and (slPath.Count <= 2)) then
  begin
    if slPath.Count = 2 then
      mSearchStr := slPath.Strings[1]; //ocekavam retezec hledani
  end else
  begin
    ErrREST(ARequest, AResponse, HTTP_SC_BadRequest, getString('wrong_parameters_count'));
    exit;
  end;

  mUser_ID := getHeaderValue(ARequest, 'UserID');
  mDocType := getHeaderValue(ARequest, 'DocumentType');
  mModule := getHeaderValue(ARequest, 'ModuleCode');

  dtRows := TMemTable.Create(nil);
  try
    LogWriteSectionStart('Inventorization');

    mSql := GetListPartialInvProtocolsSql(Self.ObjectSpace, mModule, mDocType, mUser_ID, mSearchStr);

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
    LogWriteSectionEnd;

    HTTPResponse(AResponse, HTTP_SC_OK, ContentType_JSON, json.AsJson(false, true));
  finally
    dtRows.Free;
    if Assigned(json) then
      json.Free;
  end;
end;
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
procedure listMainInvProtocols(Self: TNxWebServicesHelper; ARequest: TNxHTTPRequest;
  AResponse: TNxHTTPResponse; slPath: TStringList);
var
  mUser_Id, mDocType, mModule: String;
  dtRows: TMemTable;
  mSql, mSearchStr: String;
  json: TJSONSuperObject;
begin
  json := nil;
  mSearchStr := '';
  //if ((slPath.Count >= 2) and (slPath.Count <=3)) then
  if ((slPath.Count >= 1) and (slPath.Count <= 2)) then
  begin
  //  mDocType := slPath.Strings[1]; //ocekavam typ dokladu
    if slPath.Count = 2 then
      mSearchStr := slPath.Strings[1]; //ocekavam retezec hledani
  end else
  begin
    ErrREST(ARequest, AResponse, HTTP_SC_BadRequest, getString('wrong_parameters_count'));
    exit;
  end;

  mUser_ID := getHeaderValue(ARequest, 'UserID');
  mDocType := getHeaderValue(ARequest, 'DocumentType');
  mModule := getHeaderValue(ARequest, 'ModuleCode');

  dtRows := TMemTable.Create(nil);
  try
    LogWriteSectionStart('Inventorization');

    mSql := GetListMainInvProtocolsSql(Self.ObjectSpace, mModule, mDocType, mUser_ID, mSearchStr);

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
    LogWriteSectionEnd;

    HTTPResponse(AResponse, HTTP_SC_OK, ContentType_JSON, json.AsJson(false, true));
  finally
    dtRows.Free;
    if Assigned(json) then
      json.Free;
  end;
end;
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
procedure putPartialInvProtocolDocDetailStartPicking(Self: TNxWebServicesHelper; ARequest: TNxHTTPRequest;
  AResponse: TNxHTTPResponse; slPath: TStringList);
var
  mSql, mUser_Id, mModule, mDocType, mDoc_ID: string;
  mBO, mRow: TNxCustomBusinessObject;
  json: TJSONSuperObject;
  mRows: TNxCustomBusinessMonikerCollection;
  i, tempID: Integer;
  dtHeader: TMemTable;
  dtRows: TMemTable;
  mSL: TStringList;
begin
  json := nil;
  if (slPath.Count = 2) then
  begin
    mDoc_ID := slPath.Strings[1]; //ocekavam ID skladoveho dokladu
  end else
  begin
    ErrREST(ARequest, AResponse, HTTP_SC_BadRequest, getString('wrong_parameters_count'));
    exit;
  end;

  LogWriteSectionStart('putPartialInvProtocolDocDetailStartPicking');

  mUser_Id := getHeaderValue(ARequest, 'UserID');
  mModule := getHeaderValue(ARequest, 'ModuleCode');
  mDocType := getHeaderValue(ARequest, 'DocumentType');

  Self.ObjectSpace.StartTransaction(taReadCommited);
  try
    dtHeader := TMemTable.Create(nil);
    dtRows := TMemTable.Create(nil);
    mSL := TStringList.Create;
    mBO :=  Self.ObjectSpace.CreateObject(Class_PartialInvProtocol);
    try
      mBO.ExplicitTransaction := True;
      mBO.Load(mDoc_ID, nil);

      if ((not NxIsEmptyOID(mBO.GetFieldValueAsString('User_ID')))
          and (mBO.GetFieldValueAsString('User_ID') <> mUser_Id)) then
          RaiseException(getString('inventarization_another_user'));

      mBO.SetFieldValueAsString('User_ID', mUser_Id);

      mSql := 'select ' + nxCrLf +
        '   PIP.ID as "ID", ' + nxCrLf +
        '   DQ.Code' + CONCAT_STR + QuotedStr('-') + CONCAT_STR + 'cast(PIP.OrdNumber as varchar(6))' + nxCrLf +
              CONCAT_STR + QuotedStr('/') + CONCAT_STR + 'P.Code as "DisplayName", ' + nxCrLf +
        '   PIP.Description as "Description", ' + nxCrLf +
        '   S.ID "Store_ID", ' + nxCrLf +
        '   S.Code "StoreCode", ' + nxCrLf +
        '   S.IsLogistic as "StoreIsLogistic$BOOL", ' + nxCrLf +
        GetSQLDocHeaderParameters(Self.ObjectSpace, mDocType, mModule, mUser_Id, mDoc_ID) + nxCrLf +
        ' from PartialInvProtocols PIP ' + nxCrLf +
        ' join DocQueues DQ on DQ.ID = PIP.DocQueue_ID ' + nxCrLf +
        ' join Periods P on P.ID = PIP.Period_ID ' + nxCrLf +
        ' join MainInvProtocols MIP on MIP.id = PIP.MainProtocol_ID ' + nxCrLf +
        ' join Stores S on MIP.Store_ID = S.id ' + nxCrLf +
        ' where PIP.ID = ' + QuotedStr(mDoc_ID);
      Self.ObjectSpace.SQLSelect2(mSql, dtHeader);

      if dtHeader.Active then
      begin
        dtHeader.First;

        mSql :=
          'select ' + nxCrLf+
          '  PIR.Parent_ID as "XX_Parent_ID", ' + nxCrLf +
          '  PIR.ID as "StoreDocument2_ID", ' + nxCrLf +
          '  S.ID as "StoreFrom_ID", ' + nxCrLf +
          '  ' + putQueueDocDetailStartPicking_RowsOrderBy(Self.ObjectSpace, mModule, mDocType, mUser_ID) + ' as "OrderForIndex",' + nxCrLf +
          '  S.Code as "StoreFromCode", ' + nxCrLf +
          '  S.IsLogistic as "StoreFromIsLogistic$BOOL", ' + nxCrLf +
          '  SC.ID as "StoreCard_ID", ' + nxCrLf +
          '  SC.' + cStoreCardInfoCodeField + ' as "StoreCardCode", ' + nxCrLf +
          '  SC.' + cStoreCardInfoNameField + ' as "StoreCardName", ' + nxCrLf +
          '  '';''' + CONCAT_STR + getUnitsSql + CONCAT_STR + ''';'' as "StoreCardUnits", ' + nxCrLf +
          '  '';''' + CONCAT_STR + putQueueDocDetailStartPicking_StoreCardBarcodeField(Self.ObjectSpace, mModule) + CONCAT_STR + ''';'' as "StoreCardBarcode", ' + nxCrLf +
          '  SC.Category as "StoreCardCategory", ' + nxCrLf +
          //'  coalesce(MIB.DocumentedQuantity / MIB.UnitRate, MIR.DocumentedQuantity / MIR.UnitRate) "UnitQuantity", ' + nxCrLf +
          '  0 "UnitQuantity", ' + nxCrLf +
          '  MIR.UnitRate as "UnitRate", ' + nxCrLf +
          '  MIR.QUnit as "UnitCode", ' + nxCrLf +
          '  coalesce(LSP.ID, '''') as "StorePositionFrom_ID", ' + nxCrLf +
          '  coalesce(LSP.Code, '''') as "StorePositionFromCode", ' + nxCrLf +
          '  coalesce(SB.ID, '''') as "StoreBatch_ID", ' + nxCrLf +
          '  coalesce(SB.Name, '''') as "StoreBatchName", ' + nxCrLf +
          '  ' + putQueueDocDetailStartPicking_rowsAuxFields(Self.ObjectSpace, mModule, mDocType, mUser_ID) + nxCrLf +
          '  ' + rowAuxText(Self.ObjectSpace, mModule, mDocType, mUser_Id) + ' as "AuxText",' + nxCrLf +
          '  ' + rowAuxText2(Self.ObjectSpace, mModule, mDocType, mUser_Id) + ' as "AuxText2" ' + nxCrLf +
          ' from PartialInvProtocolRows PIR ' + nxCrLf +
          ' join PartialInvProtocols PIP on PIR.Parent_ID = PIP.id ' + nxCrLf +
          ' join MainInvProtocols MIP on PIP.MainProtocol_ID = MIP.id ' + nxCrLf +
          ' join MainInvProtocolRows MIR on PIR.MIPRow_ID = MIR.id ' + nxCrLf +
          ' join Stores S on S.ID = MIP.Store_ID ' + nxCrLf +
          ' join StoreCards SC on SC.ID = MIR.StoreCard_ID ' + nxCrLf +
          ' left join PartialInvProtocolBatches PIB on PIR.ID = PIB.Parent_ID ' + nxCrLf +
          ' left join MainInvProtocolBatches MIB on PIB.MIPBatch_ID = MIB.id ' + nxCrLf +
          ' left join StoreBatches SB on SB.ID = MIB.StoreBatch_ID ' + nxCrLf +
          ' left join PartialInvProtocolPositions PIPP on PIR.PIPPosition_ID = PIPP.id ' + nxCrLf +
          ' left join MainInvProtocolPositions MIPP on PIPP.MIPPosition_ID = MIPP.id ' + nxCrLf +
          ' left join LogStorePositions LSP on LSP.ID = MIPP.StorePosition_ID ' + nxCrLf +
          ' where ' + nxCrLf +
          ' 	PIR.Parent_ID = ' + QuotedStr(mDoc_ID) + nxCrLf;

        if ABRA then
          mSql := mSql +
            '   and SC.NonStockType = ''N''' + nxCrLf
        else
          mSql := mSql +
            '   and SC.IsStockType = ''A''' + nxCrLf;

        mSql := mSql +
          ' order by ' + nxCrLf +
          ' 	SC.Code, SB.Name, LSP.Code';
        Self.ObjectSpace.SQLSelect2(mSql, dtRows);
        if dtRows.Active then
        begin
          dtRows.AddIndex('id', REST_XX_Parent_ID+';OrderForIndex', [ixPrimary]);
          dtRows.IndexName:= 'id';
          mSL.AddObject('rows=', dtRows);
        end;
      end;

      json := REST_jsonCreate_FromDataSetRow(dtHeader, nil, mSL);

      tempId := TemporaryStorage_Create(Self.ObjectSpace, json.AsJson(false, true), mModule, mUser_Id, mDoc_ID);
      json.I['tempID'] := tempId;

      HTTPResponse(AResponse, HTTP_SC_OK, ContentType_JSON, json.AsJson(false, true));

      mBO.Save;
      Self.ObjectSpace.Commit;
    finally
      mBO.Free;
      dtHeader.Free;
      dtRows.Free;
      mSL.Free;
      if Assigned(json) then
        json.Free;
    end;
  except
    Self.ObjectSpace.RollBack;
    ErrREST(ARequest, AResponse, HTTP_SC_ExpectationFailed, ExceptionMessage);
  end;

  LogWriteSectionEnd;
end;
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
procedure putMainInvProtocolDocDetailStartPicking(Self: TNxWebServicesHelper; ARequest: TNxHTTPRequest;
  AResponse: TNxHTTPResponse; slPath: TStringList);
var
  mSql, mUser_Id, mDocType, mDoc_ID, mModule: string;
  json: TJSONSuperObject;
  mRows: TNxCustomBusinessMonikerCollection;
  i, tempId: Integer;
  dtHeader: TMemTable;
  dtRows: TMemTable;
  mSL: TStringList;
begin
  json := nil;
  if (slPath.Count = 2) then
  begin
    mDoc_ID := slPath.Strings[1]; //ocekavam ID skladoveho dokladu
  end else
  begin
    ErrREST(ARequest, AResponse, HTTP_SC_BadRequest, getString('wrong_parameters_count'));
    exit;
  end;

  LogWriteSectionStart('put-inventorization-start');

  mUser_Id := getHeaderValue(ARequest, 'UserID');
  mModule := getHeaderValue(ARequest, 'ModuleCode');
  mDocType := getHeaderValue(ARequest, 'DocumentType');

  dtHeader := TMemTable.Create(nil);
  dtRows := TMemTable.Create(nil);
  mSL := TStringList.Create;
  try
    mSql := 'select ' + nxCrLf +
      '   MIP.ID as "ID", ' + nxCrLf +
      '   DQ.Code' + CONCAT_STR + QuotedStr('-') + CONCAT_STR + 'cast(MIP.OrdNumber as varchar(6))' + nxCrLf +
            CONCAT_STR + QuotedStr('/') + CONCAT_STR + 'P.Code as "DisplayName", ' + nxCrLf +
      '   MIP.Description as "Description", ' + nxCrLf +
      '   S.ID "Store_ID", ' + nxCrLf +
      '   S.Code "StoreCode", ' + nxCrLf +
      '   ' + get_StoreInfo_IsLogistic(Self.ObjectSpace, mModule, mUser_ID) + ' as "StoreIsLogistic$BOOL", ' + nxCrLf +
      '   ' + QuotedStr(NxBoolToString(putQueueDocDetailStartPicking_openSerNumberScreenAutomatically(Self.ObjectSpace, mModule, mUser_Id))) +  ' as "AutoopenSerNumberScreen", ' + nxCrLf +
      '   ' + IntToStr(newRowDefaultValue(Self.ObjectSpace, mModule, mUser_ID)) + ' as "NewRowDefaultValue", ' + nxCrLf +
      GetSQLDocHeaderParameters(Self.ObjectSpace, mDocType, mModule, mUser_Id, mDoc_ID) + nxCrLf +
      ' from MainInvProtocols MIP ' + nxCrLf +
      ' join DocQueues DQ on DQ.ID = MIP.DocQueue_ID ' + nxCrLf +
      ' join Periods P on P.ID = MIP.Period_ID ' + nxCrLf +
      ' join Stores S on MIP.Store_ID = S.id ' + nxCrLf +
      'where MIP.ID = ' + QuotedStr(mDoc_ID);
    Self.ObjectSpace.SQLSelect2(mSql, dtHeader);

    json := REST_jsonCreate_FromDataSetRow(dtHeader, nil, mSL);

    tempId := TemporaryStorage_Create(Self.ObjectSpace, json.AsJson(false, true), mModule, mUser_Id, mDoc_ID);
    json.I['tempID'] := tempId;

    HTTPResponse(AResponse, HTTP_SC_OK, ContentType_JSON, json.AsJson(false, true));
  finally
    dtHeader.Free;
    dtRows.Free;
    mSL.Free;
    if Assigned(json) then
      json.Free;
  end;

  LogWriteSectionEnd;
end;
////////////////////////////////////////////////////////////////////////////////

/////////////////////////////////////////////////////////////////////////////////////////////////////////
////// Ulozeni dle DIP
////// TODO Praktickz stejne jako SaveInventorizationFREE - chtelo by to spojit
////// Rozdil je v nezalozeni pozic pred ukladanim a v ukonceni PIP na konci (plus se samozrejme pracuje
////// nactenym DIP.
/////////////////////////////////////////////////////////////////////////////////////////////////////////
procedure putPartialInvProtocolDocDetailStopPicking(Self: TNxWebServicesHelper; ARequest: TNxHTTPRequest;
  AResponse: TNxHTTPResponse; slPath: TStringList);
var
  mJSON_Root : TJSONSuperObject;
  jsonSerNums: TJSONSuperObjectArray;
  mTemporaryStorageID, iIndex, j: Integer;
  mDoc_ID, mUser_Id, mDeviceID, sSql, mLastStoreCard_ID, mModule, mDocType: string;
  boPIP: TNxPartialInvProtocol;
  boPIPPosition: TNxPartialInvProtocolPosition;
  boPIPRow: TNxPartialInvProtocolRow;
  dtJSONRows: TMemTable;
  mSL: TStringList;
  fdStorePosition, fdStoreCard, fdStoreBatch: TField;
  mMIPBatches, mPIPBatches: TNxCustomBusinessMonikerCollection;
  mRequestID, sStoreBatchID, mPIPRow_ID, mStorePosition_ID, mStoreCard_ID: String;
  mStoreCardsList, mStoreBatchesList: TStringList;
  mIsLogistic, mFound: Boolean;
  mUnitQuantity: Double;

  //////////////////////////////////////////////////////////////////////////////
  ////// Smaze radky, ktere skladnik nenalezl (pridane pri pridani pozice)
  //////////////////////////////////////////////////////////////////////////////
  procedure deleteZeroRows(docId: string);
  var
    dtRows: TMemTable;
    sSql: string;
    i: integer;
    mPIP, boRow: TNxCustomBusinessObject;
  begin
    dtRows := TMemTable.Create(nil);
    boRow := Self.ObjectSpace.CreateObject(Class_PartialInvProtocolRow);
    try
      boRow.ExplicitTransaction := true;
      sSql :=
        'select ' +
          '	  PIR.id "ID", ' +
          '   PIR.RealQuantity "RealQuantity"' +
          ' from PartialInvProtocolRows PIR ' +
          ' where ' +
          '	  PIR.Parent_ID = ' + QuotedStr(docId) +
          '   and PIR.RealQuantity = 0';
      Self.ObjectSpace.SQLSelect2(sSql, dtRows);

      if not dtRows.IsEmpty then
      begin
        dtRows.First;

        while not dtRows.Eof do
        begin
          if dtRows.FieldByName('RealQuantity').AsFloat = 0 then
          begin
            boRow.Load(dtRows.FieldByName('ID').AsString, nil);
            boRow.Delete;
          end;
          dtRows.Next;
        end;
      end;
    finally
      dtRows.Free;
      boRow.Free;
    end;
  end;

  //////////////////////////////////////////////////////////////////////////////
  ////// FALSE pokud je dataset prazdny nebo v nem po filtrovani neni zadny prvek
  ////// TRUE  pokud nejaky prvek v datasetu je
  //////////////////////////////////////////////////////////////////////////////
  function filterDataset(var dt: TMemTable; StorePosition_ID, StoreCard_ID, StoreBatch_ID: string): boolean;
  var
    conditionList: TStringList;
    condition: string;
    i: integer;
  begin
      dt.Filtered := false;
      //pokud je prazdny, vratim false
      if dt.isEmpty then
      begin
        Result := false;
      end
      else //neni prazdny tak filtruju
      begin
        condition := '';
        conditionList := TStringList.Create;
        try
          //nastavim podminky
          if (StorePosition_ID <> '') then
          begin
            conditionList.Append('StorePosition_ID = ' + QuotedStr(trim(StorePosition_ID)));
          end;

          if (StoreCard_ID <> '') then
          begin
            conditionList.Append('StoreCard_ID = ' + QuotedStr(trim(StoreCard_ID)));
          end;

          if (StoreBatch_ID <> '') then
          begin
            conditionList.Append('StoreBatch_ID = ' + QuotedStr(trim(StoreBatch_ID)));
          end;

          for i := 0 to conditionList.Count - 1 do
          begin
            condition := condition + conditionList.Strings[i];

            //pridam and pokud nejde jeste o posledni string
            if i < conditionList.Count - 1 then
            begin
              condition := condition + ' and ';
            end;
          end;

          dt.Filter := condition;
          dt.Filtered := true;

          if dt.RecordCount = 0 then
          begin
            Result := false;
          end
          else
          begin
            Result := true;
          end;
        finally
          conditionList.Free;
        end;
      end;
  end;

  //////////////////////////////////////////////////////////////////////////////
  ////// PRIPRAVI POZICE NA MIP A DIP
  //////////////////////////////////////////////////////////////////////////////
  procedure setUpPositions(dtJSONRows: TMemTable; sMIP_ID, sPIP_ID: string;);
  var
    sSql: string;
    dtMIPPositions, dtPIPPositions: TMemTable;
    boMIPPosition, boPIPPosition: TNxCustomBusinessObject;
  begin
    dtMIPPositions := TMemTable.Create(nil);
    dtPIPPositions := TMemTable.Create(nil);
    boMIPPosition := Self.ObjectSpace.CreateObject(Class_MainInvProtocolPosition);
    boPIPPosition := Self.ObjectSpace.CreateObject(Class_PartialInvProtocolPosition);
    try
      boMIPPosition.ExplicitTransaction := true;
      boPIPPosition.ExplicitTransaction := true;

      //ziskam pozice z MIP
      sSql :=
      'select ' +
        '   MIP.id "ID", ' +
        '   MIP.StorePosition_ID "StorePosition_ID" ' +
        ' from MainInvProtocolPositions MIP ' +
        ' where ' +
        '	  MIP.Parent_ID = ' + QuotedStr(sMIP_ID);
      Self.ObjectSpace.SQLSelect2(sSql, dtMIPPositions);
      if dtMIPPositions.isEmpty then
      begin
        DataSet_CreataHeader(dtMIPPositions, 'ID=S10,StorePosition_ID=S10');
      end;
      dtMIPPositions.AddIndex('Index', 'StorePosition_ID;ID', [ixPrimary]);
      dtMIPPositions.IndexName := 'Index';
      dtMIPPositions.Open;

      sSql :=
      'select ' +
        '   PIP.id "ID", ' +
        '   MIP.id "MIPPosition_ID", ' +
        '   MIP.StorePosition_ID "StorePosition_ID" ' +
        ' from PartialInvProtocolPositions PIP ' +
        ' join MainInvProtocolPositions MIP on PIP.MIPPosition_ID = MIP.id ' +
        ' where ' +
        '	  PIP.Parent_ID = ' + QuotedStr(sPIP_ID);
      Self.ObjectSpace.SQLSelect2(sSql, dtPIPPositions);
      if dtPIPPositions.isEmpty then
      begin
        DataSet_CreataHeader(dtPIPPositions, 'ID=S10,MIPPosition_ID=S10,StorePosition_ID=S10');
      end;
      dtPIPPositions.AddIndex('Index', 'StorePosition_ID;ID', [ixPrimary]);
      dtPIPPositions.IndexName := 'Index';
      dtPIPPositions.Open;

      //pripravim si HIP a DIP pridanim potrebnych pozic
      while not dtJSONRows.Eof do
      begin
        //pokud neni pozice na HIP, pridam ji
        if not filterDataset(dtMIPPositions,
          dtJSONRows.FieldByName('StorePositionFrom_ID').AsString,
          '',
          '') then
        begin
          boMIPPosition.New;
          boMIPPosition.Prefill;
          boMIPPosition.SetFieldValueAsString('Parent_ID', sMIP_ID);
          boMIPPosition.SetFieldValueAsString('StorePosition_ID', dtJSONRows.FieldByName('StorePositionFrom_ID').AsString);
          boMIPPosition.Save;

          dtMIPPositions.Insert;
          dtMIPPositions.FieldByName('ID').AsString := boMIPPosition.OID;
          dtMIPPositions.FieldByName('StorePosition_ID').AsString := boMIPPosition.GetFieldValueAsString('StorePosition_ID');
          dtMIPPositions.Commit;
        end;

        //pokud neni pozice na DIP, pridam ji
        if not filterDataset(dtPIPPositions,
          dtJSONRows.FieldByName('StorePositionFrom_ID').AsString,
          '',
          '') then
        begin
          boPIPPosition.New;
          boPIPPosition.Prefill;
          boPIPPosition.SetFieldValueAsString('MIPPosition_ID', dtMIPPositions.FieldByName('ID').AsString);
          boPIPPosition.SetFieldValueAsString('Parent_ID', sPIP_ID);
          boPIPPosition.Save;

          dtPIPPositions.Insert;
          dtPIPPositions.FieldByName('ID').AsString := boPIPPosition.OID;
          dtPIPPositions.FieldByName('MIPPosition_ID').AsString := dtMIPPositions.FieldByName('ID').AsString;
          dtPIPPositions.FieldByName('StorePosition_ID').AsString := dtMIPPositions.FieldByName('StorePosition_ID').AsString;
          dtPIPPositions.Commit;
        end;

        dtJSONRows.Next;
      end;
    finally
      dtJSONRows.First;
      dtMIPPositions.Free;
      boMIPPosition.Free;
      boPIPPosition.Free;
    end;
  end;

  procedure SaveDialogValues(ABO: TNxCustomBusinessObject);
  var
    mDialogValues: TMemTable;
    mDialogType: Integer;
    mDialogField: String;
  begin
    mDialogValues := TMemTable.Create(nil);
    try
      DataSet_CreataHeader(mDialogValues, REST_DialogValuesDatasetHeader);
      mDialogValues.Open;
      REST_JsonToDataSet(mJSON_Root.O['Dialog'].A['values'], mDialogValues);

      mDialogValues.First;
      while not mDialogValues.Eof do
      begin
        if(mDialogValues.FieldByName('type').AsString = 'number') then
          ABO.SetFieldValueAsInteger(mDialogValues.FieldByName('field').AsString, mDialogValues.FieldByName('intValue').AsInteger)
        else if(mDialogValues.FieldByName('type').AsString = 'text') then
          ABO.SetFieldValueAsString(mDialogValues.FieldByName('field').AsString, mDialogValues.FieldByName('stringValue').AsString)
        else if(mDialogValues.FieldByName('type').AsString = 'roll') then
          ABO.SetFieldValueAsString(mDialogValues.FieldByName('field').AsString, mDialogValues.FieldByName('rollValueId').AsString);
        mDialogValues.Next;
      end;
    finally
      mDialogValues.Free;
    end;
  end;

begin
  if (slPath.Count = 2) then
  begin
    mDoc_ID := slPath.Strings[1]
  end else
  begin
    ErrREST(ARequest, AResponse, HTTP_SC_BadRequest, getString('wrong_parameters_count'));
    exit;
  end;

  LogWriteSectionStart('putPartialInvProtocolDocDetailStopPicking');
  dtJSONRows := TMemTable.Create(nil);
  mStoreCardsList := TStringList.Create;
  mStoreBatchesList := TStringList.Create;
  boPIP := TNxPartialInvProtocol(Self.ObjectSpace.CreateObject(Class_PartialInvProtocol));
  mJSON_Root := TJSONSuperObject.ParseString(GetStringFromBytes(ARequest.Content.Content, TEncoding.UTF8), True);
  try
    //kontrola, zda uz neprobiha
    mRequestID := REST_getJSONStr(mJSON_Root, 'saveRequestID');
    // pred transakci overime, jestli uz tento request nebezi nebo neni dokonce dokonceny. Pokud ne, tak ho zalozime.
    case Request_Start(Self.ObjectSpace, mRequestID, 'putPartialInvProtocolDocDetailStopPicking') of
      1: begin
        ErrREST(ARequest, AResponse, HTTP_SC_ExpectationFailed, getString('request_in_process'));
        exit;
      end;
      2: begin
        HTTPResponse(AResponse, HTTP_SC_OK, ContentType_JSON, PlainResponse(''));
        exit;
      end;
    end;

    self.ObjectSpace.StartTransaction(taReadCommited);
    try
      boPIP.ExplicitTransaction := True;

      mTemporaryStorageID := REST_getJSONInt(mJSON_Root, 'tempID');
      mDoc_ID := REST_getJSONStr(mJSON_Root, 'ID');

      mUser_Id := getHeaderValue(ARequest, 'UserID');
      mModule := getHeaderValue(ARequest, 'ModuleCode');
      mDocType := getHeaderValue(ARequest, 'DocumentType');

      //ziskani deviceID
      mSL := TStringList.Create;
      try
        mSL.Text := ARequest.Header.AllHeaders;
        mDeviceID := mSL.Values['DeviceID'];
      finally
        mSL.Free;
      end;

      //pripravim si hlavicku pro JSON
      DataSet_CreataHeader(dtJSONRows, 'jsonIndex=I,' +
      'UnitQuantity=F,StoreBatch_ID=S10,StoreCardCategory=I,StoreCard_ID=S10,StoreFromIsLogistic=B' +
      ',StorePositionFrom_ID=S10,StorePositionFromCode=S30,StorePositionTo_ID=S10,StorePositionToCode=S30,Store_ID=S10,UnitCode=S10,UnitRate=F,Processed=B,StoreCardName=S100');
      dtJSONRows.AddIndex('ByJsonIndex', 'jsonIndex', [ixPrimary]);
      dtJSONRows.AddIndex('ByStoreCard', 'StoreCard_ID', [ixPrimary]);
      dtJSONRows.AddIndex('Razeni', 'StorePositionFrom_ID;StoreCard_ID;StoreBatch_ID;jsonIndex', [ixPrimary]);
      dtJSONRows.IndexName := 'Razeni';
      dtJSONRows.Open;
      REST_JsonToDataSet(mJSON_Root.A['rows'], dtJSONRows);

      //kontrola jestli neni prazdne
      dtJSONRows.Filter := 'Processed=true';
      dtJSONRows.Filtered := true;
      if dtJSONRows.IsEmpty then
      begin
        RaiseException(getString('no_rows_processed'));
      end;
      dtJSONRows.Filtered := false;
      dtJSONRows.First;

      //ulozim si pole
      fdStorePosition := dtJSONRows.FieldByName('StorePositionFrom_ID');
      fdStoreCard := dtJSONRows.FieldByName('StoreCard_ID');
      fdStoreBatch := dtJSONRows.FieldByName('StoreBatch_ID');

      boPIP.Load(mDoc_ID, nil);
      boPIP.SetFieldValueAsString('User_ID', mUser_Id);
      boPIP.SetFieldValueAsString('ReaderID', mDeviceID);

      SaveDialogValues(boPIP);

      boPIP.Save;

      mIsLogistic := False;
      //pokud jde o pozicovanej sklad, tak si nejdriv pripravim pozice
      if dtJSONRows.FieldByName('StoreFromIsLogistic').AsBoolean then
      begin
        mIsLogistic := True;
      end;

        //TODO mDoc_ID
      mDoc_ID := boPIP.OID;

      while not dtJSONRows.Eof do
      begin
        //preskocim pokud neni zpracovanej
        if not dtJSONRows.FieldByName('Processed').AsBoolean then
        begin
          dtJSONRows.Next;
          continue;
        end;

        //chyba, pokud neni zadana pozice u pozicovanyho skladu
        if ((dtJSONRows.FieldByName('StoreFromIsLogistic').AsBoolean)
          and (fdStorePosition.AsString = '')) then
        begin
          RaiseException(Format(getString('no_position_entered'),  [dtJSONRows.FieldByName('StoreCardName').AsString]));
        end;

        boPIPRow := TNxPartialInvProtocolRow(self.ObjectSpace.CreateObject(Class_PartialInvProtocolRow));
        try
          boPIPRow.ExplicitTransaction := true;
          // pokud ma radek sarze nebo ser. cisla, tak mu nejde nastavit primo mnozstvi, tudiz budu vyplnovat nulu a mnoztsvi se pak
          // propise ze sarze a ser. cisla
          if ((dtJSONRows.FieldByName('StoreCardCategory').AsInteger = 1)
              or (dtJSONRows.FieldByName('StoreCardCategory').AsInteger = 2)) then
            mUnitQuantity := 0
          else
            mUnitQuantity := dtJSONRows.FieldByName('UnitQuantity').AsFloat;

          // pokud pracuju s polohovanym skladem tak budu nejdrive potrebovat pozici
          if mIsLogistic then
          begin
            // dohledam pozici na dilcim protokolu a pokud neni tak ji zalozim
            if not boPIP.Positions_Find(fdStorePosition.AsString, mStorePosition_ID) then
              mStorePosition_ID := boPIP.Positions_Add(fdStorePosition.AsString);

            // nactu pozici a pridam na ni radek s artiklem
            boPIPPosition := TNxPartialInvProtocolPosition(self.ObjectSpace.CreateObject(Class_PartialInvProtocolPosition));
            try
              boPIPPosition.ExplicitTransaction := True;
              boPIPPosition.Load(mStorePosition_ID, nil);

              // zkusim najit radek a pokud nenajdu tak ho vytvorim
              mFound := True;
              if boPIPPosition.StoreCards_Find(fdStoreCard.AsString, dtJSONRows.FieldByName('UnitCode').AsString, mStoreCardsList) then
                mPIPRow_ID := mStoreCardsList.Strings(0)
              else
              begin
                mPIPRow_ID := boPIPPosition.StoreCards_Add(fdStoreCard.AsString, dtJSONRows.FieldByName('UnitCode').AsString, mUnitQuantity);
                mFound := False;
              end;
              boPIPPosition.Save;
            finally
              boPIPPosition.Free;
            end;
          end
          else // neni polohovany, takze hledam rovnou radek
          begin
            mFound := True;
            if boPIP.StoreCards_Find(fdStoreCard.AsString, dtJSONRows.FieldByName('UnitCode').AsString, mStoreCardsList) then
              mPIPRow_ID := mStoreCardsList.Strings(0)
            else
            begin
              mPIPRow_ID := boPIP.StoreCards_Add(fdStoreCard.AsString, dtJSONRows.FieldByName('UnitCode').AsString, mUnitQuantity);
              mFound := False;
            end;
          end;

          // nactu vytvoreny radek
          boPIPRow.Load(mPIPRow_ID, nil);

          // pokud jsem radek nasel, tak k nemu musim pridat mnozstvi
          if mFound then
            boPIPRow.SetFieldValueAsFloat('UnitRealQuantity', boPIPRow.GetFieldValueAsFloat('UnitRealQuantity') + mUnitQuantity);

          if dtJSONRows.FieldByName('StoreCardCategory').AsInteger = 1 then
          begin
            jsonSerNums := mJSON_Root.A['rows'].O[dtJSONRows.FieldByName('jsonIndex').AsInteger].A['sernums'];
            for j := 0 to jsonSerNums.Length - 1 do
            begin
              //uz existujici ser. cislo?
              if jsonSerNums.O[j].S['SerNum_ID'] = '' then
              begin
                //neexistuje, najdu ji
                sSql := 'select ID from StoreBatches where StoreCard_ID = ' + QuotedStr(fdStoreCard.AsString) +
                  ' and Name = ' + QuotedStr(jsonSerNums.O[j].S['SerNumName']) + ' and Hidden = ''N''';
                sStoreBatchID := SQLSelectStr(Self.ObjectSpace, sSql);
              end
              else begin
                sStoreBatchID := jsonSerNums.O[j].S['SerNum_ID'];
              end;
              // pridam seriove cislo do radku
              boPIPRow.StoreBatches_Add(sStoreBatchID, dtJSONRows.FieldByName('UnitCode').AsString, 1);
            end;
          end;

          // pokud ma radek sarze, tak pridam sarze
          if dtJSONRows.FieldByName('StoreCardCategory').AsInteger = 2 then
          begin
            // sarzi pridavam mnozstvi primo z datasetu, v mUnitQuantity mam totiz umyslne nulu
            boPIPRow.StoreBatches_Add(fdStoreBatch.AsString, dtJSONRows.FieldByName('UnitCode').AsString, dtJSONRows.FieldByName('UnitQuantity').AsFloat);
          end;

          boPIPRow.Save;

          // vycistim list s radky
          mStoreCardsList.Clear;
          dtJSONRows.Next;
        finally
          boPIPRow.Free;
        end;
      end;

      glog.WriteEvent(logDebug, 'Before beforeSaveHook');
      beforeSaveHook(Self.ObjectSpace, mModule, boPIP, 0, mJSON_Root, dtJSONRows);
      glog.WriteEvent(logDebug, 'After beforeSaveHook');

      if boPIP.NeedSave then
        boPIP.Save;

      //deleteZeroRows(boPIP.OID);
      afterSaveHook(Self.ObjectSpace, mModule, mUser_Id, boPIP, 0, mJSON_Root, dtJSONRows);

      if InvetarizationByDIP_CloseDIP then
      begin
        boPIP.DoCloseProtocol('');
      end;

      // vymaz z TemporaryStorage jeste v transakci
      TemporaryStorage_Delete(Self.ObjectSpace, mTemporaryStorageID);

      //dokonceni pozadavku
      Request_Finish(Self.ObjectSpace, mRequestID);

      self.ObjectSpace.Commit;

      HTTPResponse(AResponse, HTTP_SC_OK, ContentType_JSON, PlainResponse(''));
    except
      self.ObjectSpace.RollBack;
      ErrREST(ARequest, AResponse, HTTP_SC_InternalServerError, Format(getString('error_MIP_saving'), [ExceptionMessage]));
      Request_Cancel(Self.ObjectSpace, mRequestID);
      exit;
    end;
  finally
    boPIP.Free;
    dtJSONRows.Free;
    mStoreBatchesList.Free;
    mStoreCardsList.Free;
    mJSON_Root.Free;
  end;
  LogWriteSectionEnd;
end;

////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
procedure listStoreCardsForInv(Self: TNxWebServicesHelper; ARequest: TNxHTTPRequest;
  AResponse: TNxHTTPResponse; slPath: TStringList);
var
  mSearchStr: String;
  dtRows: TMemTable;
  mSql, sDocId: String;
  iInvType: integer;
  json: TJSONSuperObject;
  boDoc: TNxCustomBusinessObject;
  bStoreLogistic, bCanAddNew: bool;
begin
  json := nil;
  mSearchStr := '';
  bStoreLogistic := false;
  if ((slPath.Count = 2) or (slPath.Count = 3)) then
  begin
    sDocId := slPath[1];
    //iInvType := StrToInt(slPath[2]);
    if slPath.Count = 3 then
      mSearchStr := CFxInternet.URLDecode(ReplaceStr(slPath.Strings[2], '+', ' '));
  end else
  begin
    ErrREST(ARequest, AResponse, HTTP_SC_BadRequest, getString('wrong_parameters_count'));
    exit;
  end;

  boDoc := Self.ObjectSpace.CreateObject(Class_PartialInvProtocol);
  try
    boDoc.Load(sDocId, nil);
    bStoreLogistic := boDoc.GetFieldValueAsBoolean('MainProtocol_ID.Store_ID.IsLogistic');
    bCanAddNew := boDoc.GetFieldValueAsBoolean('MainProtocol_ID.AddRowsFromPIP');
  finally
    boDoc.Free;
  end;

  dtRows := TMemTable.Create(nil);
  try
    LogWriteSectionStart('ListStoreCardsForInv');

    //pokud sklad neni polohovanej, tak chci jen artikly z dokladu
    mSql :=
      'select ' + FIRST_TOP(100) +
      '   SC.ID as "ID", ' +
      '   SC.' + cStoreCardInfoCodeField + ' as "Code", ' +
      '   SC.' + cStoreCardInfoNameField + ' as "Name" ';
    if not bStoreLogistic then
    begin
      mSql := mSql +
        ' from PartialInvProtocolRows PIR ' +
        ' join MainInvProtocolRows MIR on PIR.MIPRow_ID = MIR.id ' +
        ' join StoreCards SC on MIR.StoreCard_ID = SC.id ' +
        ' where PIR.Parent_ID = ' + QuotedStr(sDocId);
    end
    else
    begin
      mSql := mSql +
        ' from StoreCards SC ' +
        ' where 1 = 1 ';
    end;
    if trim(mSearchStr) <> '' then
      mSql := mSql + 'and (SC.Code' + COLLATION_AI + 'like ''%' + mSearchStr + '%'' ' +
        '  or SC.Name' + COLLATION_AI + 'like ''%' + mSearchStr + '%'') ';
    mSql := mSql +
    ' order by SC.Code ' +
    FIRST_TOP_ORACLE(100);

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
    LogWriteSectionEnd;

    HTTPResponse(AResponse, HTTP_SC_OK, ContentType_JSON, json.AsJson(false, true));
  finally
    dtRows.Free;
    if Assigned(json) then
      json.Free;
  end;
end;
////////////////////////////////////////////////////////////////////////////////
procedure saveInventorizationFree(Self: TNxWebServicesHelper; ARequest: TNxHTTPRequest;
  AResponse: TNxHTTPResponse; slPath: TStringList);
var
  mJSON_Root : TJSONSuperObject;
  jsonSerNums: TJSONSuperObjectArray;
  mTemporaryStorageID, iIndex, j: Integer;
  mDoc_ID, mUser_Id, mDeviceID, sSql, mLastStoreCard_ID, mModule, mDocType: string;
  boPIP: TNxPartialInvProtocol;
  boPIPPosition: TNxPartialInvProtocolPosition;
  boPIPRow: TNxPartialInvProtocolRow;
  dtJSONRows: TMemTable;
  boMIP: TNxCustomBusinessObject;
  mSL: TStringList;
  fdStorePosition, fdStoreCard, fdStoreBatch: TField;
  mMIPBatches, mPIPBatches: TNxCustomBusinessMonikerCollection;
  mRequestID, sStoreBatchID, mPIPRow_ID, mStorePosition_ID, mStoreCard_ID: String;
  mStoreCardsList, mStoreBatchesList: TStringList;
  mIsLogistic, mFound: Boolean;
  mUnitQuantity: Double;

  //////
  ////// Smaze radky, ktere skladnik nenalezl (pridane pri pridani pozice)
  //////
  procedure deleteZeroRows(docId: string);
  var
    dtRows: TMemTable;
    sSql: string;
    i: integer;
    mPIP, boRow: TNxCustomBusinessObject;
  begin
    dtRows := TMemTable.Create(nil);
    boRow := Self.ObjectSpace.CreateObject(Class_PartialInvProtocolRow);
    try
      boRow.ExplicitTransaction := true;
      sSql :=
        'select ' +
          '	  PIR.id "ID", ' +
          '   PIR.RealQuantity "RealQuantity"' +
          ' from PartialInvProtocolRows PIR ' +
          ' where ' +
          '	  PIR.Parent_ID = ' + QuotedStr(docId) +
          '   and PIR.RealQuantity = 0';
      Self.ObjectSpace.SQLSelect2(sSql, dtRows);

      if not dtRows.IsEmpty then
      begin
        dtRows.First;
        while not dtRows.Eof do
        begin
          if dtRows.FieldByName('RealQuantity').AsFloat = 0 then
          begin
            boRow.Load(dtRows.FieldByName('ID').AsString, nil);
            boRow.Delete;
          end;
          dtRows.Next;
        end;
      end;
    finally
      dtRows.Free;
      boRow.Free;
    end;
  end;

  procedure SaveDialogValues(ABO: TNxCustomBusinessObject);
  var
    mDialogValues: TMemTable;
    mDialogType: Integer;
    mDialogField: String;
  begin
    mDialogValues := TMemTable.Create(nil);
    try
      DataSet_CreataHeader(mDialogValues, REST_DialogValuesDatasetHeader);
      mDialogValues.Open;
      REST_JsonToDataSet(mJSON_Root.O['Dialog'].A['values'], mDialogValues);

      mDialogValues.First;
      while not mDialogValues.Eof do
      begin
        if(mDialogValues.FieldByName('type').AsString = 'number') then
          ABO.SetFieldValueAsInteger(mDialogValues.FieldByName('field').AsString, mDialogValues.FieldByName('intValue').AsInteger)
        else if(mDialogValues.FieldByName('type').AsString = 'text') then
          ABO.SetFieldValueAsString(mDialogValues.FieldByName('field').AsString, mDialogValues.FieldByName('stringValue').AsString)
        else if(mDialogValues.FieldByName('type').AsString = 'roll') then
          ABO.SetFieldValueAsString(mDialogValues.FieldByName('field').AsString, mDialogValues.FieldByName('rollValueId').AsString);
        mDialogValues.Next;
      end;
    finally
      mDialogValues.Free;
    end;
  end;

  // vrati radu dokladu
  function GetDocQueueForDocument(AOS: TNxCustomObjectSpace; AModule, ADocType, AUser_ID, ADefaultDocQueue_ID: String; ASourceDocType: String = '';
    ADocument: TNxCustomBusinessObject = nil): String;
  var
    mDocQueue_ID: String;
  begin
    Result := '';

    mDocQueue_ID := GetDocQueue_ID(AOS, AModule, ADocType, AUser_ID, ASourceDocType, ADocument);
    if not CFxOID.IsEmpty(mDocQueue_ID) then
      Result := mDocQueue_ID
    else
      Result := ADefaultDocQueue_ID;
  end;

begin
  if (slPath.Count = 1) then
  begin
    //mDocType := slPath.Strings[1];
  end else
  begin
    ErrREST(ARequest, AResponse, HTTP_SC_BadRequest, getString('wrong_parameters_count'));
    exit;
  end;

  LogWriteSectionStart('saveInventorizationFree');
  dtJSONRows := TMemTable.Create(nil);
  mStoreCardsList := TStringList.Create;
  mStoreBatchesList := TStringList.Create;
  boPIP := TNxPartialInvProtocol(Self.ObjectSpace.CreateObject(Class_PartialInvProtocol));
  mJSON_Root := TJSONSuperObject.ParseString(GetStringFromBytes(ARequest.Content.Content, TEncoding.UTF8), True);
  try
    //kontrola, zda uz neprobiha
    mRequestID := REST_getJSONStr(mJSON_Root, 'saveRequestID');
    // pred transakci overime, jestli uz tento request nebezi nebo neni dokonce dokonceny. Pokud ne, tak ho zalozime.
    case Request_Start(Self.ObjectSpace, mRequestID, 'saveInventorizationFree') of
      1: begin
        ErrREST(ARequest, AResponse, HTTP_SC_ExpectationFailed, getString('request_in_process'));
        exit;
      end;
      2: begin
        HTTPResponse(AResponse, HTTP_SC_OK, ContentType_JSON, PlainResponse(''));
        exit;
      end;
    end;

    Self.ObjectSpace.StartTransaction(taReadCommited);
    try
      boPIP.ExplicitTransaction := True;

      mTemporaryStorageID := REST_getJSONInt(mJSON_Root, 'tempID');

      mDoc_ID := REST_getJSONStr(mJSON_Root, 'ID');

      mUser_Id := getHeaderValue(ARequest, 'UserID');
      mModule := getHeaderValue(ARequest, 'ModuleCode');
      mDocType := getHeaderValue(ARequest, 'DocumentType');

      //ziskani deviceID
      mSL := TStringList.Create;
      try
        mSL.Text := ARequest.Header.AllHeaders;
        mDeviceID := mSL.Values['DeviceID'];
      finally
        mSL.Free;
      end;

      //pripravim si hlavicku pro JSON
      DataSet_CreataHeader(dtJSONRows, 'jsonIndex=I,' +
      'UnitQuantity=F,StoreBatch_ID=S10,StoreCardCategory=I,StoreCard_ID=S10,StoreFromIsLogistic=B' +
      ',StorePositionFrom_ID=S10,StorePositionTo_ID=S10,StorePositionToCode=S30,Store_ID=S10,UnitCode=S10,UnitRate=F,Processed=B,StoreCardName=S100');
      dtJSONRows.AddIndex('ByJsonIndex', 'jsonIndex', [ixPrimary]);
      dtJSONRows.AddIndex('Razeni', 'StorePositionFrom_ID;StoreCard_ID;StoreBatch_ID;jsonIndex', [ixPrimary]);
      dtJSONRows.IndexName := 'Razeni';
      dtJSONRows.Open;
      REST_JsonToDataSet(mJSON_Root.A['rows'], dtJSONRows);

      //kontrola jestli neni prazdne
      dtJSONRows.Filter := 'Processed=true';
      dtJSONRows.Filtered := true;
      if dtJSONRows.IsEmpty then
      begin
        RaiseException(getString('no_rows_processed'));
      end;
      dtJSONRows.Filtered := false;
      dtJSONRows.First;

      //ulozim si pole
      fdStorePosition := dtJSONRows.FieldByName('StorePositionFrom_ID');
      fdStoreCard := dtJSONRows.FieldByName('StoreCard_ID');
      fdStoreBatch := dtJSONRows.FieldByName('StoreBatch_ID');

      //vytvorim PIP
      boPIP.New;
      boPIP.Prefill;
      boPIP.SetFieldValueAsString('MainProtocol_ID', mDoc_ID);
      boPIP.SetFieldValueAsBoolean('AddPositions', True);
      boPIP.SetFieldValueAsBoolean('AddRows', True);
      boPIP.SetFieldValueAsBoolean('PrefillPositionsRows', False);
      boPIP.SetFieldValueAsString('User_ID', mUser_Id);
      boPIP.SetFieldValueAsString('ReaderID', mDeviceID);

      // kvuli predani vychoziho objektu (MIP) ho musim docasne nacist
      boMIP := Self.ObjectSpace.CreateObject(Class_MainInvProtocol);
      try
        boMIP.Load(mDoc_ID, nil);
        boPIP.SetFieldValueAsString('DocQueue_ID',
          GetDocQueueForDocument(Self.ObjectSpace, mModule, DOC_PartialInvProtocol, mUser_ID, RADA_DILCI_INV_PROTOKOL, DOC_MainInvProtocol, boMIP));
      finally
        boMIP.Free;
      end;

      SaveDialogValues(boPIP);

      boPIP.Save;

      mIsLogistic := False;
      //pokud jde o pozicovanej sklad, tak si nejdriv pripravim pozice
      if dtJSONRows.FieldByName('StoreFromIsLogistic').AsBoolean then
      begin
        //setUpPositions(dtJSONRows, mDoc_ID, boPIP.OID);
        mIsLogistic := True;
      end;

        //TODO mDoc_ID
      mDoc_ID := boPIP.OID;

      while not dtJSONRows.Eof do
      begin
        //preskocim pokud neni zpracovanej
        if not dtJSONRows.FieldByName('Processed').AsBoolean then
        begin
          dtJSONRows.Next;
          continue;
        end;

        //chyba, pokud neni zadana pozice u pozicovanyho skladu
        if ((dtJSONRows.FieldByName('StoreFromIsLogistic').AsBoolean)
          and (fdStorePosition.AsString = '')) then
        begin
          RaiseException(Format(getString('no_position_entered'),  [dtJSONRows.FieldByName('StoreCardName').AsString]));
        end;

        boPIPRow := TNxPartialInvProtocolRow(self.ObjectSpace.CreateObject(Class_PartialInvProtocolRow));
        try
          boPIPRow.ExplicitTransaction := True;
          // pokud ma radek sarze nebo ser. cisla, tak mu nejde nastavit primo mnozstvi, tudiz budu vyplnovat nulu a mnoztsvi se pak
          // propise ze sarze a ser. cisla
          if ((dtJSONRows.FieldByName('StoreCardCategory').AsInteger = 1)
              or (dtJSONRows.FieldByName('StoreCardCategory').AsInteger = 2)) then
            mUnitQuantity := 0
          else
            mUnitQuantity := dtJSONRows.FieldByName('UnitQuantity').AsFloat;

          // pokud pracuju s polohovanym skladem tak budu nejdrive potrebovat pozici
          if mIsLogistic then
          begin
            // dohledam pozici na dilcim protokolu a pokud neni tak ji zalozim
            if not boPIP.Positions_Find(fdStorePosition.AsString, mStorePosition_ID) then
              mStorePosition_ID := boPIP.Positions_Add(fdStorePosition.AsString);

            // nactu pozici a pridam na ni radek s artiklem
            boPIPPosition := TNxPartialInvProtocolPosition(self.ObjectSpace.CreateObject(Class_PartialInvProtocolPosition));
            try
              boPIPPosition.ExplicitTransaction := True;
              boPIPPosition.Load(mStorePosition_ID, nil);

              // zkusim najit radek a pokud nenajdu tak ho vytvorim
              mFound := True;
              if boPIPPosition.StoreCards_Find(fdStoreCard.AsString, dtJSONRows.FieldByName('UnitCode').AsString, mStoreCardsList) then
                mPIPRow_ID := mStoreCardsList.Strings(0)
              else
              begin
                mPIPRow_ID := boPIPPosition.StoreCards_Add(fdStoreCard.AsString, dtJSONRows.FieldByName('UnitCode').AsString, mUnitQuantity);
                mFound := False;
              end;
              boPIPPosition.Save;
            finally
              boPIPPosition.Free;
            end;
          end
          else // neni polohovany, takze hledam rovnou radek
          begin
            mFound := True;
            if boPIP.StoreCards_Find(fdStoreCard.AsString, dtJSONRows.FieldByName('UnitCode').AsString, mStoreCardsList) then
              mPIPRow_ID := mStoreCardsList.Strings(0)
            else
            begin
              mPIPRow_ID := boPIP.StoreCards_Add(fdStoreCard.AsString, dtJSONRows.FieldByName('UnitCode').AsString, mUnitQuantity);
              mFound := False;
            end;
          end;

          // nactu vytvoreny radek
          boPIPRow.Load(mPIPRow_ID, nil);

          // pokud jsem radek nasel, tak k nemu musim pridat mnozstvi
          if mFound then
            boPIPRow.SetFieldValueAsFloat('UnitRealQuantity', boPIPRow.GetFieldValueAsFloat('UnitRealQuantity') + mUnitQuantity);

          if dtJSONRows.FieldByName('StoreCardCategory').AsInteger = 1 then
          begin
            jsonSerNums := mJSON_Root.A['rows'].O[dtJSONRows.FieldByName('jsonIndex').AsInteger].A['sernums'];
            for j := 0 to jsonSerNums.Length - 1 do
            begin
              //uz existujici ser. cislo?
              if jsonSerNums.O[j].S['SerNum_ID'] = '' then
              begin
                //neexistuje, najdu ji
                sSql := 'select ID from StoreBatches where StoreCard_ID = ' + QuotedStr(fdStoreCard.AsString) +
                  ' and Name = ' + QuotedStr(jsonSerNums.O[j].S['SerNumName']) + ' and Hidden = ''N''';
                sStoreBatchID := SQLSelectStr(Self.ObjectSpace, sSql);
              end
              else begin
                sStoreBatchID := jsonSerNums.O[j].S['SerNum_ID'];
              end;
              // pridam seriove cislo do radku
              boPIPRow.StoreBatches_Add(sStoreBatchID, dtJSONRows.FieldByName('UnitCode').AsString, 1);
            end;
          end;

          // pokud ma radek sarze, tak pridam sarze
          if dtJSONRows.FieldByName('StoreCardCategory').AsInteger = 2 then
          begin
            // sarzi pridavam mnozstvi primo z datasetu, v mUnitQuantity mam totiz umyslne nulu
            boPIPRow.StoreBatches_Add(fdStoreBatch.AsString, dtJSONRows.FieldByName('UnitCode').AsString,  dtJSONRows.FieldByName('UnitQuantity').AsFloat);
          end;

          boPIPRow.Save;

          // vycistim list s radky
          mStoreCardsList.Clear;
          dtJSONRows.Next;
        finally
          boPIPRow.Free;
        end;
      end;

      //deleteZeroRows(boPIP.OID);

      glog.WriteEvent(logDebug, 'Before beforeSaveHook');
      beforeSaveHook(Self.ObjectSpace, mModule, boPIP, 0, mJSON_Root, dtJSONRows);
      glog.WriteEvent(logDebug, 'After beforeSaveHook');

      if boPIP.NeedSave then
        boPIP.Save;

      afterSaveHook(Self.ObjectSpace, mModule, mUser_Id, boPIP, 0, mJSON_Root, dtJSONRows);

      if InvetarizationFree_CloseDIP then
      begin
        boPIP.DoCloseProtocol('');
      end;

      // vymaz z TemporaryStorage jeste v transakci
      TemporaryStorage_Delete(Self.ObjectSpace, mTemporaryStorageID);

      //dokonceni pozadavku
      Request_Finish(Self.ObjectSpace, mRequestID);

      self.ObjectSpace.Commit;

      HTTPResponse(AResponse, HTTP_SC_OK, ContentType_JSON, PlainResponse(''));
    except
      self.ObjectSpace.RollBack;
      ErrREST(ARequest, AResponse, HTTP_SC_InternalServerError, Format(getString('error_MIP_saving'), [ExceptionMessage]));
      Request_Cancel(Self.ObjectSpace, mRequestID);
      exit;
    end;
  finally
    boPIP.Free;
    dtJSONRows.Free;
    mStoreBatchesList.Free;
    mStoreCardsList.Free;
    mJSON_Root.Free;
  end;
  LogWriteSectionEnd;
end;
////////////////////////////////////////////////////////////////////////////////

begin
end.