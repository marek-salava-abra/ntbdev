uses
  'REST_SkladTerm.U_Func',
  'REST_SkladTerm.U_FuncJSON',
  'REST_SkladTerm.U_Requests',
  'REST_SkladTerm.U_TemporaryStorage',
  'StandardUnits.U_GetId',
  'StandardUnits.U_Dataset';

///////////////////////////////////////////////////////////////////////////////
procedure get_PostProviderInfo(Self: TNxWebServicesHelper; ARequest: TNxHTTPRequest;
  AResponse: TNxHTTPResponse; slPath: TStringList);
var
  mPostProvider_ID: String;
  dtHeader: TMemTable;
  mSL: TStringList;
  mSql: String;
  json: TJSONSuperObject;
begin
  json := nil;
  if (slPath.Count = 2) then
  begin
    mPostProvider_ID := slPath.Strings[1]; //ocekavam dopravce (PDMPostProviders)
  end else
  begin
    ErrREST(ARequest, AResponse, HTTP_SC_BadRequest, getString('wrong_parameters_count'));
    exit;
  end;

  dtHeader := TMemTable.Create(nil);
  mSL := TStringList.Create;
  try
    // hlavicka dopravce
    LogWriteSectionStart('PostProviderInfo');
    mSql := 'select ' +
      '  PP.ID as "ID", ' +  // kvuli navazani polozkoveho datasetu
      '  PP.ID as "PostProvider_ID", ' +
      '  PP.Code as "PostProviderCode", ' +
      '  PP.Name as "PostProviderName" ' +
      'from PDMPostProviders PP ' +
      'where PP.ID = ' + QuotedStr(mPostProvider_ID);
    Self.ObjectSpace.SQLSelect2(mSql, dtHeader);

    LogWriteSectionEnd;

    if dtHeader.Active then
    begin
      dtHeader.First;
      LogWriteSectionStart('JSON');
      json := REST_jsonCreate_FromDataSetRow(dtHeader, nil, mSL);
      LogWriteSectionEnd;

      HTTPResponse(AResponse, HTTP_SC_OK, ContentType_JSON, json.AsJson(false, true));
    end
    else begin
      ErrREST(ARequest, AResponse, HTTP_SC_NotFound, Format(getString('shipper_not_found'), [mPostProvider_ID]));
    end;
  finally
    dtHeader.Free;
    mSL.Free;
    if Assigned(json) then
      json.Free;
  end;
end;
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
procedure listPostProviders(Self: TNxWebServicesHelper; ARequest: TNxHTTPRequest;
  AResponse: TNxHTTPResponse; slPath: TStringList);
var
  mSearchStr: String;
  dtRows: TMemTable;
  mSql: String;
  json: TJSONSuperObject;
begin
  mSearchStr := '';
  json := nil;
  if ((slPath.Count = 1) or (slPath.Count = 2)) then
  begin
    if slPath.Count = 2 then
      mSearchStr := CFxInternet.URLDecode(ReplaceStr(slPath.Strings[1], '+', ' '));
  end else
  begin
    ErrREST(ARequest, AResponse, HTTP_SC_BadRequest, getString('wrong_parameters_count'));
    exit;
  end;

  dtRows := TMemTable.Create(nil);
  try
    LogWriteSectionStart('ListPostProviders');
    mSql := 'select ' +
      '  PP.ID as "ID", ' +
      '  PP.Code as "Code", ' +
      '  PP.Name as "Name" ' +
      'from PDMPostProviders PP ' +
      'where PP.Hidden = ''N'' ';
    if trim(mSearchStr) <> '' then
      mSql := mSql + 'and (PP.Code' + COLLATION_AI + 'like ''%' + mSearchStr + '%'' ' +
        '  or PP.Name' + COLLATION_AI + 'like ''%' + mSearchStr + '%'') ';
    mSql := mSql + ' order by PP.Code ';
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
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
procedure get_PackageInfo(Self: TNxWebServicesHelper; ARequest: TNxHTTPRequest;
  AResponse: TNxHTTPResponse; slPath: TStringList);
var
  mPostNumber, mPostProvider_ID, mRO_ID: String;
  dtHeader: TMemTable;
  mSL: TStringList;
  mSql: String;
  json: TJSONSuperObject;
begin
  json := nil;
  if (slPath.Count = 3) then
  begin
    mPostProvider_ID := slPath.Strings[1]; //ocekavam PostProvider_ID
    mPostNumber := slPath.Strings[2]; //ocekavam podaci cislo baliku
  end else
  begin
    ErrREST(ARequest, AResponse, HTTP_SC_BadRequest, getString('wrong_parameters_count'));
    exit;
  end;

  dtHeader := TMemTable.Create(nil);
  mSL := TStringList.Create;
  try
    // hlavicka baliku
    LogWriteSectionStart('PackageInfo');
    mSql := 'select ' +
      '  PID.ID as "ID", ' +  // kvuli navazani polozkoveho datasetu
      '  PID.ID as "Package_ID", ' +
      '  PID.X_PostNumber_EAN as "PostNumber", ' +
      '  PID.Closing_ID as "Closing_ID", ' +
      '  PID.PostProvider_ID as "PostProvider_ID" ' +
      'from PDMIssuedDocs PID ' +
      'where PID.PostProvider_ID = ' + QuotedStr(mPostProvider_ID) + ' and PID.X_PostNumber_EAN' + COLLATION_AI + '= ' + QuotedStr(mPostNumber);
    Self.ObjectSpace.SQLSelect2(mSql, dtHeader);

    LogWriteSectionEnd;

    if dtHeader.Active then
    begin
      dtHeader.First;

      // kontrola, jestli neni stornovana OBP
      mSql := 'SELECT RO.ID ' +
        'from Relations R ' +
    	  'join ShippingLists2 SL2 on SL2.Parent_ID = R.RightSide_ID ' +
    	  'join StoreDocuments2 SD2 on SD2.Parent_ID = SL2.Provide_ID and SD2.ID = SL2.ProvideRow_ID ' +
        'join IssuedRows IR on IR.TypeConnection = 100 and IR.StoreDocument_ID = SD2.Parent_ID and IR.StoreDocumentRow_ID = SD2.ID ' +
        'join ReceivedOrders RO on RO.ID = IR.Order_ID ' +
        'join UserStatuses US on US.ID = RO.Status_ID ' +
        'where R.REL_DEF = 1475 and R.LeftSide_ID = ' + QuotedStr(dtHeader.FieldByName('Package_ID').AsString) +
        '  and US.InternalStatus = 6 ';

      {
      'select RO.ID ' +
        'from dbo.X_IssuedRows(''OP'', '+QuotedStr(dtHeader.FieldByName('Package_ID').AsString)+', null) XIR ' +
        'join ReceivedOrders RO on RO.ID = XIR.ReceivedOrder_ID ' +
        'join UserStatuses US on US.ID = RO.Status_ID ' +
        'where US.InternalStatus = 6 ';  }
      mRO_ID := SQLSelectStr(Self.ObjectSpace, mSql);
      if NxIsBlank(mRO_ID) then
      begin
        LogWriteSectionStart('JSON');
        json := REST_jsonCreate_FromDataSetRow(dtHeader, nil, mSL);
        LogWriteSectionEnd;

        HTTPResponse(AResponse, HTTP_SC_OK, ContentType_JSON, json.AsJson(false, true));
      end
      else begin
        ErrREST(ARequest, AResponse, HTTP_SC_NotFound, Format(getString('package_canceled_order'), [mPostNumber]));
      end;
    end
    else begin
      ErrREST(ARequest, AResponse, HTTP_SC_NotFound, Format(getString('package_not_found'), [mPostNumber]));
    end;
  finally
    dtHeader.Free;
    mSL.Free;
    if Assigned(json) then
      json.Free;
  end;
end;
///////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
procedure putPackageShipping(Self: TNxWebServicesHelper; ARequest: TNxHTTPRequest;
  AResponse: TNxHTTPResponse; slPath: TStringList);
var
  mJSON_Root: TJSONSuperObject;
  mPDMIssuedDoc, mPDMClosing, mPDMClosing2: TNxCustomBusinessObject;
  i: Integer;
  mTemporaryStorageID: Integer;
  mOS: TNxCustomObjectSpace;
  dtJSONRows: TMemTable;
  mRequestID, mPostProvider_ID, mUser_ID: String;
begin
  if (slPath.Count = 1) then
  begin
    //mDocType := slPath.Strings[1];
  end else
  begin
    ErrREST(ARequest, AResponse, HTTP_SC_BadRequest, getString('wrong_parameters_count'));
    exit;
  end;

  mOS := Self.ObjectSpace;
  LogWriteSectionStart('putPackageShipping');

  mJSON_Root := TJSONSuperObject.ParseString(GetStringFromBytes(ARequest.Content.Content, TEncoding.UTF8), True);
  mUser_ID := getHeaderValue(ARequest, 'UserID');
  mPDMClosing := mOS.CreateObject(Class_PDMClosing);
  mPDMClosing2 := mOS.CreateObject(Class_PDMClosing);
  dtJSONRows := TMemTable.Create(nil);
  try
    mRequestID := REST_getJSONStr(mJSON_Root, 'saveRequestID');
    // pred transakci overime, jestli uz tento request nebezi nebo neni dokonce dokonceny. Pokud ne, tak ho zalozime.
    case Request_Start(mOS, mRequestID, 'putPackageShipping') of
      1: begin
        ErrREST(ARequest, AResponse, HTTP_SC_ExpectationFailed, getString('request_in_process'));
        exit;
      end;
      2: begin
        HTTPResponse(AResponse, HTTP_SC_OK, ContentType_JSON, PlainResponse(''));
        exit;
      end;
    end;

    mOS.StartTransaction(taReadCommited);
    try
      mTemporaryStorageID := REST_getJSONInt(mJSON_Root, 'tempID');
      mPostProvider_ID := REST_getJSONStr(mJSON_Root, 'PostProvider_ID');
      mPDMClosing.ExplicitTransaction := True;
      mPDMClosing2.ExplicitTransaction := True;

      // dataset, do ktereho si preplnime polozky z JSONu
      DataSet_CreataHeader(dtJSONRows, 'jsonIndex=I,Package_ID=S10');
      dtJSONRows.AddIndex('ByJsonIndex', 'jsonIndex', [ixUnique]);
      dtJSONRows.IndexName := 'ByJsonIndex';
      dtJSONRows.Open;
      REST_JsonToDataSet(mJSON_Root.A['rows'], dtJSONRows);

      // nejdriv vytvorime uzaverku
      mPDMClosing.New;
      mPDMClosing.Prefill;
      mPDMClosing.SetFieldValueAsString('DocQueue_ID', RADA_UZAVERKA_POSTY);
      mPDMClosing.SetFieldValueAsString('PostProvider_ID', mPostProvider_ID);
      // datum odeslani nastavime az po pripojeni odeslanych post, aby se na to dal chytit hacek s tiskem
      //mPDMClosing.SetFieldValueAsDateTime('PostDate$DATE', Now);
      mPDMClosing.Save;

      // pak k ni priradime jednotlive baliky
      dtJSONRows.First;
      while not dtJSONRows.EOF do
      begin
        mPDMIssuedDoc := mOS.CreateObject(Class_PDMIssuedDoc);
        try
          mPDMIssuedDoc.ExplicitTransaction := True;
          mPDMIssuedDoc.Load(dtJSONRows.FieldByName('Package_ID').AsString, nil);
          mPDMIssuedDoc.SetFieldValueAsString('Closing_ID', mPDMClosing.OID);
          mPDMIssuedDoc.Save;
        finally
          mPDMIssuedDoc.Free;
        end;
        dtJSONRows.Next;
      end;

      // nastaveni data odeslani
      mPDMClosing2.Load(mPDMClosing.OID, nil);
      mPDMClosing2.SetFieldValueAsDateTime('PostDate$DATE', Now);
      mPDMClosing2.Save;

      // pripadny tisk reportu
      //PrintReportToPrinterByIDToQueue(Self.Context, mPDMClosing.OID, '', REPORT, '', TISKARNA, mUser_ID, 1);

      // vymaz z TemporaryStorage jeste v transakci
      TemporaryStorage_Delete(mOS, mTemporaryStorageID);

      Request_Finish(mOS, mRequestID);

      mOS.Commit;

      HTTPResponse(AResponse, HTTP_SC_OK, ContentType_JSON, PlainResponse(''));
    except
      mOS.RollBack;
      ErrREST(ARequest, AResponse, HTTP_SC_InternalServerError, Format(getString('error_package_shipping_saving'), [ExceptionMessage]));
      Request_Cancel(mOS, mRequestID);
      LogWriteSectionEnd;
      exit;
    end;
  finally
    mJSON_Root.Free;
    mPDMClosing.Free;
    mPDMClosing2.Free;
    dtJSONRows.Free;
  end;
  LogWriteSectionEnd;
end;//putPackageShipping
////////////////////////////////////////////////////////////////////////////////

begin
end.