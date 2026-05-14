uses
  'REST_SkladTerm.U_Func',
  'REST_SkladTerm.U_FuncJSON',
  'REST_SkladTerm.U_Requests',
  'REST_SkladTerm.U_TemporaryStorage',
  'StandardUnits.U_GetId',
  'StandardUnits.U_Dataset';

procedure get_PostProviderInfo(AOS: TNxCustomObjectSpace; APath, AResponse: TStringList);
var
  mPostProvider_ID: String;
  dtHeader: TMemTable;
  mSL: TStringList;
  mSql: String;
  json: TJSONSuperObject;
begin
  json := nil;
  if (APath.Count = 2) then
  begin
    mPostProvider_ID := APath.Strings[1];
  end else
  begin
    SetPlainResponse(AResponse, getString('wrong_parameters_count'), HTTP_SC_BadRequest);
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
    AOS.SQLSelect2(mSql, dtHeader);

    LogWriteSectionEnd;

    if dtHeader.Active then
    begin
      dtHeader.First;
      LogWriteSectionStart('JSON');
      json := REST_jsonCreate_FromDataSetRow(dtHeader, nil, mSL);
      LogWriteSectionEnd;

     SetResponse(AResponse, json.AsJson(false, true));
    end
    else begin
      SetPlainResponse(AResponse, Format(getString('shipper_not_found'), [mPostProvider_ID]), HTTP_SC_NotFound);
    end;
  finally
    dtHeader.Free;
    mSL.Free;
    if Assigned(json) then
      json.Free;
  end;
end;

function listPostProviders(ASearch: String): String;
var
  mSql: String;
begin
  LogWriteSectionStart('listPostProviders');
  try
    mSql :=
      'select' + nxCrLf +
      '  PP.ID as "ID",' + nxCrLf +
      '  PP.Code as "Code",' + nxCrLf +
      '  PP.Name as "Name"' + nxCrLf +
      'from PDMPostProviders PP ' + nxCrLf +
      'where PP.Hidden = ''N'' ';
    if trim(ASearch) <> '' then
      mSql := mSql + 'and (PP.Code' + COLLATION_AI + 'like ''%' + ASearch + '%'' ' +
        '  or PP.Name' + COLLATION_AI + 'like ''%' + ASearch + '%'') ';
    mSql := mSql + ' order by PP.Code ';

    Result := mSql;
  finally
    LogWriteSectionEnd;
  end;
end;

procedure get_PackageInfo(AOS: TNxCustomObjectSpace; APath, AResponse: TStringList);
var
  mPostNumber, mPostProvider_ID, mRO_ID: String;
  dtHeader: TMemTable;
  mSL: TStringList;
  mSql: String;
  json: TJSONSuperObject;
begin
  json := nil;
  if (APath.Count = 3) then
  begin
    mPostProvider_ID := APath.Strings[1]; //ocekavam PostProvider_ID
    mPostNumber := APath.Strings[2]; //ocekavam podaci cislo baliku
  end else
  begin
    SetPlainResponse(AResponse, getString('wrong_parameters_count'), HTTP_SC_BadRequest);
    exit;
  end;

  dtHeader := TMemTable.Create(nil);
  mSL := TStringList.Create;
  try
    // hlavicka baliku
    LogWriteSectionStart('PackageInfo');
    mSql :=
      'select' + nxCrLf +
      '  PID.ID as "ID",' + nxCrLf +  // kvuli navazani polozkoveho datasetu
      '  PID.ID as "Package_ID",' + nxCrLf +
      '  PID.X_PostNumber_EAN as "PostNumber",' + nxCrLf +
      '  PID.Closing_ID as "Closing_ID",' + nxCrLf + nxCrLf +
      '  PID.PostProvider_ID as "PostProvider_ID"' + nxCrLf +
      'from PDMIssuedDocs PID' + nxCrLf +
      'where' + nxCrLf +
      '  PID.PostProvider_ID = ' + QuotedStr(mPostProvider_ID) + ' and PID.X_PostNumber_EAN' + COLLATION_AI + ' = ' + QuotedStr(mPostNumber);
    AOS.SQLSelect2(mSql, dtHeader);

    LogWriteSectionEnd;

    if dtHeader.Active then
    begin
      dtHeader.First;

      // kontrola, jestli neni stornovana OBP
      mSql :=
        'SELECT RO.ID' + nxCrLf +
        'from Relations R' + nxCrLf +
    	  'join ShippingLists2 SL2 on SL2.Parent_ID = R.RightSide_ID' + nxCrLf +
    	  'join StoreDocuments2 SD2 on SD2.Parent_ID = SL2.Provide_ID and SD2.ID = SL2.ProvideRow_ID' + nxCrLf +
        'join IssuedRows IR on IR.TypeConnection = 100 and IR.StoreDocument_ID = SD2.Parent_ID and IR.StoreDocumentRow_ID = SD2.ID' + nxCrLf +
        'join ReceivedOrders RO on RO.ID = IR.Order_ID' + nxCrLf +
        'join UserStatuses US on US.ID = RO.Status_ID' + nxCrLf +
        'where' + nxCrLf +
        '  R.REL_DEF = 1475 and R.LeftSide_ID = ' + QuotedStr(dtHeader.FieldByName('Package_ID').AsString) + nxCrLf +
        '  and US.InternalStatus = 6';
      mRO_ID := SQLSelectStr(AOS, mSql);
      if NxIsBlank(mRO_ID) then
      begin
        LogWriteSectionStart('JSON');
        json := REST_jsonCreate_FromDataSetRow(dtHeader, nil, mSL);
        LogWriteSectionEnd;

        SetResponse(AResponse, json.AsJson(false, true));
      end
      else begin
        SetPlainResponse(AResponse, Format(getString('package_canceled_order'), [mPostNumber]), HTTP_SC_NotFound);
      end;
    end
    else
      SetPlainResponse(AResponse, Format(getString('package_not_found'), [mPostNumber]), HTTP_SC_NotFound);
  finally
    dtHeader.Free;
    mSL.Free;
    if Assigned(json) then
      json.Free;
  end;
end;

procedure putPackageShipping(AOS: TNxCustomObjectSpace; APath: TStringList; ABody: String; AResponse: TStringList);
var
  mJSON_Root: TJSONSuperObject;
  mPDMIssuedDoc, mPDMClosing, mPDMClosing2: TNxCustomBusinessObject;
  i: Integer;
  mTemporaryStorageID: Integer;
  dtJSONRows: TMemTable;
  mRequestID, mPostProvider_ID: String;
begin
  if (APath.Count = 1) then
  begin
    //mDocType := slPath.Strings[1];
  end else
  begin
    SetPlainResponse(AResponse, getString('wrong_parameters_count'), HTTP_SC_BadRequest);
    exit;
  end;

  LogWriteSectionStart('putPackageShipping');

  mJSON_Root := TJSONSuperObject.ParseString(ABody, True);
  mPDMClosing := AOS.CreateObject(Class_PDMClosing);
  mPDMClosing2 := AOS.CreateObject(Class_PDMClosing);
  dtJSONRows := TMemTable.Create(nil);
  try
    mRequestID := REST_getJSONStr(mJSON_Root, 'saveRequestID');
    // pred transakci overime, jestli uz tento request nebezi nebo neni dokonce dokonceny. Pokud ne, tak ho zalozime.
    case Request_Start(AOS, mRequestID, 'putPackageShipping') of
      1: begin
        SetPlainResponse(AResponse, getString('request_in_process'), HTTP_SC_ExpectationFailed);
        exit;
      end;
      2: begin
        SetResponse(AResponse, PlainResponse(''));
        exit;
      end;
    end;

    AOS.StartTransaction(taReadCommited);
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
        mPDMIssuedDoc := AOS.CreateObject(Class_PDMIssuedDoc);
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
      TemporaryStorage_Finish(AOS, mTemporaryStorageID);

      Request_Finish(AOS, mRequestID);

      AOS.Commit;

      SetResponse(AResponse, PlainResponse(''));
    except
      AOS.RollBack;
      SetPlainResponse(AResponse, Format(getString('error_package_shipping_saving'), [ExceptionMessage]), HTTP_SC_InternalServerError);
      Request_Cancel(AOS, mRequestID);
      LogWriteSectionEnd;
    end;
  finally
    mJSON_Root.Free;
    mPDMClosing.Free;
    mPDMClosing2.Free;
    dtJSONRows.Free;
  end;
  LogWriteSectionEnd;
end;

begin
end.