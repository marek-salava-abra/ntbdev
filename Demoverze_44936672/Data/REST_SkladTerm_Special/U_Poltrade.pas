(*uses
  'REST_SkladTerm.U_Func',
  'REST_SkladTerm.U_FuncJSON',
  'StandardUnits.U_GetId';

procedure putPoltradeNewStoreBatch(Self: TNxWebServicesHelper; ARequest: TNxHTTPRequest;
  AResponse: TNxHTTPResponse; slPath: TStringList);
var
  mSql: string;
  boStoreBatch: TNxCustomBusinessObject;
  checkBatchName: boolean;
  dtRows: TMemTable;
  json, jsonI: TJSONSuperObject;
begin
  jsonI := TJSONSuperObject.ParseString(REST_ByteUTF82String(ARequest.Content.Content), True);
  json := TJSONSuperObject.CreateByDataType(jtObject);
  dtRows := TMemTable.Create(nil);
  try
    // dohledam typ obalu
    mSql :=
      'select first 1 SC.ID from StoreCards SC where SC.Code = ' + QuotedStr(jsonI.S['StoreCardName']);
    Self.ObjectSpace.SQLSelect2(mSql, dtRows);

    if(not dtRows.Active) then
    begin
      HTTPResponse(AResponse, HTTP_SC_ExpectationFailed, ContentType_PlainText, 'Nebyl nalezen typ obalu s kódem "' + QuotedStr(jsonI.S['StoreCardName']) + '"');
      exit;
    end;
    dtRows.First;

    boStoreBatch := Self.ObjectSpace.CreateObject(Class_StoreBatch);
    try
      try
        boStoreBatch.New;
        boStoreBatch.SetFieldValueAsString('StoreCard_ID', jsonI.S['StoreCard_ID']);
        boStoreBatch.SetFieldValueAsString('Specification', jsonI.S['StoreBatchSpecification']);
        boStoreBatch.SetFieldValueAsString('X_TypObalu_ID', dtRows.FieldByName('ID').AsString);
        //boStoreBatch.SetFieldValueAsString('Note', IntToStr(jsonI.I['StoreCardCategory']));
        boStoreBatch.Save;
      except
        HTTPResponse(AResponse, HTTP_SC_ExpectationFailed, ContentType_PlainText, ExceptionMessage);
        exit;
      end;

      json.S['StoreBatch_ID'] := boStoreBatch.OID;
      json.S['StoreBatchName'] := boStoreBatch.GetFieldValueAsString('Name');
      json.S['StoreBatchSpecification'] := jsonI.S['StoreBatchSpecification'];
      json.I['StoreCardCategory'] := jsonI.I['StoreCardCategory'];
      HTTPResponse(AResponse, HTTP_SC_OK, ContentType_JSON, json.AsJson(false, true));
    finally
      boStoreBatch.Free;
    end;
  finally
    dtRows.Free;
    json.Free;
    jsonI.Free;
  end;
end;

procedure listTypObalu(Self: TNxWebServicesHelper; ARequest: TNxHTTPRequest;
  AResponse: TNxHTTPResponse; slPath: TStringList);
var
  dtRows: TMemTable;
  mSql: String;
  json: TJSONSuperObject;
begin
  json := nil;

  dtRows := TMemTable.Create(nil);
  try
    LogWriteSectionStart('listTypObalu');
    mSql :=
      'SELECT ' + nxCrLf +
      '  SC.ID "ID", ' + nxCrLf +
      '  SC.Code "Code", ' + nxCrLf +
      '  SC.Name "Name" ' + nxCrLf +
      'FROM StoreMenu SM ' + nxCrLf +
      'JOIN StoreCardMenuItemLinks SCL ON SCL.StoreMenuItem_ID = SM.ID ' + nxCrLf +
      'JOIN StoreCards SC ON SC.ID = SCL.StoreCard_ID ' + nxCrLf +
      'WHERE ' + nxCrLf +
   	  '  SM.ID = ''1200000101'' ' + nxCrLf +
     	'  AND SC.Hidden = ''N''';
    mSql := mSql + ' order by SC.Code ';
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

procedure PutValuesFromSpecialBarcode(Self: TNxWebServicesHelper; ARequest: TNxHTTPRequest;
  AResponse: TNxHTTPResponse; slPath: TStringList);
var
  mSql, mBarcode, mModule, mUser_ID, mStoreCard_ID: string;
  boStoreBatch: TNxCustomBusinessObject;
  mFound: boolean;
  dtStorePosition, dtStoreBatch: TMemTable;
  jsonO, jsonI: TJSONSuperObject;
begin
  mModule := getHeaderValue(ARequest, 'ModuleCode');
  mUser_ID := getHeaderValue(ARequest, 'UserID');

  jsonI := TJSONSuperObject.ParseString(REST_ByteUTF82String(ARequest.Content.Content), True);
  jsonO := TJSONSuperObject.CreateByDataType(jtObject);
  dtStorePosition := TMemTable.Create(nil);
  dtStoreBatch := TMemTable.Create(nil);
  try
    try
      mFound := False;
      mBarcode := jsonI.S['barcode'];

      // u presunu zkousim i artikl
      if mModule = 'POLT_TransferBetweenPositions' then
      begin
        mSql := 'select first 1 SC.ID from StoreCards SC where SC.Code = ' + QuotedStr(mBarcode) + ' or SC.EAN = ' + QuotedStr(mBarcode);
        mStoreCard_ID := SQLSelectStr(Self.ObjectSpace, mSql);

        if mStoreCard_ID <> '' then
        begin
          jsonO.S['StoreCard_ID'] := mStoreCard_ID;
          mFound := True;
        end
      end;

      // jde o pozici?
      if (not mFound) and (Length(mBarcode) = 12) and (pos('SP', mBarcode) = 1) then
      begin
        mSql := 'select first 1 SP.ID, SP.Code from LogStorePositions SP where SP.ID = ' + QuotedStr(copy(mBarcode, 3, 10));
        Self.ObjectSpace.SQLSelect2(mSql, dtStorePosition);

        if dtStorePosition.Active then
        begin
          dtStorePosition.First;
          jsonO.S['StorePosition_ID'] := dtStorePosition.FieldByName('ID').AsString;
          jsonO.S['StorePositionCode'] := dtStorePosition.FieldByName('CODE').AsString;
          mFound := True;
        end
        else
          RaiseException(Format(getString('position_not_found'), [copy(mBarcode, 3, 10)]));
      end;

      // pokud neslo o pozici, tak zkusim sarzi
      if not mFound then
      begin
        // zkusim dohledat sarzi
        mSql := 'select first 1 SB.ID, SB.NAME, SB.StoreCard_ID "StoreCard_ID" from StoreBatches SB where SB.Specification = ' + QuotedStr(mBarcode);
        Self.ObjectSpace.SQLSelect2(mSql, dtStoreBatch);

        if dtStoreBatch.Active then
        begin
          dtStoreBatch.First;
          jsonO.S['StoreBatch_ID'] := dtStoreBatch.FieldByName('ID').AsString;
          jsonO.S['StoreBatchName'] := dtStoreBatch.FieldByName('NAME').AsString;
          jsonO.S['StoreCard_ID'] := dtStoreBatch.FieldByName('StoreCard_ID').AsString;
        end
        else
          RaiseException(Format(getString('storebatch_not_found'), [mBarcode]));
      end;
      HTTPResponse(AResponse, HTTP_SC_OK, ContentType_JSON, jsonO.AsJson(false, true));
    except
      ErrREST(ARequest, AResponse, HTTP_SC_NotFound, ExceptionMessage);
    end;
  finally
    dtStorePosition.Free;
    dtStoreBatch.Free;
    jsonO.Free;
    jsonI.Free;
  end;
end;*)

begin
end.