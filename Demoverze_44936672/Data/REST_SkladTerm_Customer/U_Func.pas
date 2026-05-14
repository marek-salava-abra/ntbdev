uses
  'REST_SkladTerm.U_Firm',
  'REST_SkladTerm.U_Func',
  'REST_SkladTerm.U_FuncJSON',
  'REST_SkladTerm.U_LogStoreDocument',
  'REST_SkladTerm.U_Requests',
  'REST_SkladTerm.U_SQLQueries',
  'REST_SkladTerm.U_TemporaryStorage',
  'REST_SkladTerm_Special.U_Const',
  'REST_SkladTerm_Special.U_StandardHooks',
  'StandardUnits.U_DataSet';

// ABRA_ReceiptCardFromIOQueue
const
  Store_ID_Damaged          = '3200000101';
  Store_ID_NotConfirmed     = '1300000101';

// vrati ID radku dokladu obsahujici sarze idenfikovatelne zadanym EANem
procedure getStoreBatchesByEAN(Self: TNxWebServicesHelper; ARequest: TNxHTTPRequest;
  AResponse: TNxHTTPResponse; slPath: TStringList);
var
  mSql, mEAN: String;
  mRows :TMemTable;
  json: TJSONSuperObject;
begin
  mEAN := slPath.Strings[1];

  mRows := TMemTable.Create(nil);
  try
    // sloupec se musi jmenovat "message", protoze ctecka pouziva genericky objekt s timto nazvem
    mSql :=
      'select ' + nxCrLf +
      '  SB.ID as "message" ' + nxCrLf +
      'from StoreBatches SB ' + nxCrLf +
      'where ' + nxCrLf +
      '  SB.ID = ''7000000101''';
      Self.ObjectSpace.SQLSelect2(mSql, mRows);

    if mRows.Active then
    begin
      json := REST_jsonCreate_FromDataSet(mRows, nil, nil);
    end
    else begin
      json := TJSONSuperObject.CreateByDataType(jtArray);
    end;

    HTTPResponse(AResponse, HTTP_SC_OK, ContentType_JSON, json.AsJson(false, true));
  finally
    mRows.Free;
  end;
end;
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
procedure putOrdersRequestsWithoutDocStopPicking(Self: TNxWebServicesHelper; ARequest: TNxHTTPRequest;
  AResponse: TNxHTTPResponse; slPath: TStringList);
var
  mJSON_Root: TJSONSuperObject;
  mBO: TNxCustomBusinessObject;
  i: Integer;
  mTemporaryStorageID: Integer;
  mOS: TNxCustomObjectSpace;
  dtJSONRows: TMemTable;
  mDIM: TNxDocumentImportManager;
  mParams: TNxParameters;
  mUser_ID, mDocType,
    mLogStoreDocument_DocQueue_ID, mStoreField, mRequestID, mDocQueue_ID, mModule: String;

begin
  if (slPath.Count <> 1) then
  begin
    ErrREST(ARequest, AResponse, HTTP_SC_BadRequest, getString('wrong_parameters_count'));
    exit;
  end;

  mOS := Self.ObjectSpace;
  LogWriteSectionStart('putOrdersRequestsWithoutDocStopPicking');

  mJSON_Root := TJSONSuperObject.ParseString(GetStringFromBytes(ARequest.Content.Content, TEncoding.UTF8), True);
  mUser_ID := getHeaderValue(ARequest, 'UserID');
  mModule := getHeaderValue(ARequest,'ModuleCode');
  mBO := mOS.CreateObject(Class_OrdersGeneration);
  dtJSONRows := TMemTable.Create(nil);
  try
    mRequestID := REST_getJSONStr(mJSON_Root, 'saveRequestID');
    // pred transakci overime, jestli uz tento request nebezi nebo neni dokonce dokonceny. Pokud ne, tak ho zalozime.
    case Request_Start(mOS, mRequestID, 'putOrdersRequestsWithoutDocStopPicking') of
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
      mBO.ExplicitTransaction := True;

      // dataset, do ktereho si preplnime polozky z JSONu
      DataSet_CreataHeader(dtJSONRows, 'jsonIndex=I,StoreDocument2_ID=S10,StoreDocument2Provide_ID=S10,StoreDocument2ProvideRow_ID=S10,' +
        'DocRowBatch_ID=S10,LogStoreDocument2_ID=S10,StoreFrom_ID=S10,StoreTo_ID=S10,StoreCard_ID=S10,StorePositionFrom_ID=S10,' +
        'StoreBatch_ID=S10,StorePositionTo_ID=S10,Processed=B,UnitQuantity=F,UnitRate=F,UnitCode=S10,Division_ID=S10');
      dtJSONRows.AddIndex('ByJsonIndex', 'jsonIndex', [ixUnique]);
      dtJSONRows.IndexName := 'ByJsonIndex';
      dtJSONRows.Open;
      REST_JsonToDataSet(mJSON_Root.A['rows'], dtJSONRows);

      dtJSONRows.First;
      while not dtJSONRows.EOF do
      begin
        mBO.New;
        mBO.Prefill;
        mBO.SetFieldValueAsString('Firm_ID', REST_getJSONStr(mJSON_Root, 'Firm_ID'));
        mBO.SetFieldValueAsString('Store_ID', dtJSONRows.FieldByName('StoreFrom_ID').AsString);
        mBO.SetFieldValueAsString('StoreCard_ID', dtJSONRows.FieldByName('StoreCard_ID').AsString);
        mBO.SetFieldValueAsString('QUnit', dtJSONRows.FieldByName('UnitCode').AsString);
        mBO.SetFieldValueAsFloat('UnitQuantity', dtJSONRows.FieldByName('UnitQuantity').AsFloat);

        mBO.Save;
        dtJSONRows.Next;
      end;

      // vymaz z TemporaryStorage jeste v transakci
      TemporaryStorage_Delete(mOS, mTemporaryStorageID);

      Request_Finish(mOS, mRequestID);

      mOS.Commit;

      HTTPResponse(AResponse, HTTP_SC_OK, ContentType_JSON, PlainResponse(''));
    except
      mOS.RollBack;
      ErrREST(ARequest, AResponse, HTTP_SC_InternalServerError, getString('error_saving') + ExceptionMessage);
      Request_Cancel(mOS, mRequestID);
      LogWriteSectionEnd;
      exit;
    end;
  finally
    mJSON_Root.Free;
    mBO.Free;
    dtJSONRows.Free;
  end;
  LogWriteSectionEnd;
end;//putOrdersRequestsWithoutDocStopPicking
////////////////////////////////////////////////////////////////////////////////

procedure getKlausTimberBarcodeResult(Self: TNxWebServicesHelper; ARequest: TNxHTTPRequest;
  AResponse: TNxHTTPResponse; slPath: TStringList);
var
  mBarcode, mCode, mType, mError, mIsRow, mModule, mDocType, mUser_Id: String;
  dtHeader: TMemTable;
  mSql: String;
  json: TJSONSuperObject;
begin
  json := nil;
  mIsRow := '';
  if (slPath.Count = 2) or (slPath.Count = 3)then
  begin
    mBarcode := slPath.Strings[1]; // ocekavam nacteny kod
    if slPath.Count = 3 then
      mIsRow := slPath.Strings[2];
  end else
  begin
    ErrREST(ARequest, AResponse, HTTP_SC_BadRequest, getString('error_wrong_parameters_count'));
    exit;
  end;

  mUser_Id := getHeaderValue(ARequest, 'UserID');
  mModule := getHeaderValue(ARequest, 'ModuleCode');
  mDocType := getHeaderValue(ARequest, 'DocumentType');

  dtHeader := TMemTable.Create(nil);
  try
    // vlastni logika toho, co jsem vlastne nacetl
    // muze byt: Firma, Osoba nebo pracoviste.
    // FirmName vyziju jako urceni toho, co tedy nakonec vracim. 1 = Firma, 2 = Osoba, 3 = Pracoviste
    // firma se kontroluje pouze, pokud jsem volal z obrazovky dokladu
    if (mIsRow = '') and (StartsText('FI', mBarcode)) and (Length(mBarcode) = 12) then
    begin
      // firma
      mType := '0';
      mError := Format(getString('firm_not_found'), [mBarcode]);
      mCode := copy(mBarcode, 3, Length(mBarcode) - 2);
      FirmInfo(Self.ObjectSpace, dtHeader, mModule, mDocType, mUser_Id, mCode);
    end
    else if(StartsText('O', mBarcode)) then
    begin
      // osoba
      mType := '1';
      mError := Format(getString('person_not_found'), [mBarcode]);
      mCode := copy(mBarcode, 2, Length(mBarcode) - 1);
      mSql := 'select ' +
        '  P.ID as "ID", ' +  // kvuli navazani polozkoveho datasetu
        '  P.ID as "Firm_ID", ' +
        '  ''1'' as "FirmCode", ' +
        '  P.LastName as "FirmName" ' +
        'from Persons P ' +
        'where P.Title = ' + QuotedStr(mCode);
      Self.ObjectSpace.SQLSelect2(mSql, dtHeader);
    end
    else if(StartsText('P', mBarcode)) then
    begin
      // pracoviste
      mType := '2';
      mError := Format(getString('workplace_not_found'), [mBarcode]);
      mCode := copy(mBarcode, 2, Length(mBarcode) - 1);
      mSql := 'select ' +
        '  A.ID as "ID", ' +  // kvuli navazani polozkoveho datasetu
        '  A.ID as "Firm_ID", ' +
        '  ''2'' as "FirmCode", ' +
        '  A.Name as "FirmName" ' +
        'from CRMActivityProcesses A ' +
        'where A.Code = ' + QuotedStr(mCode);
      Self.ObjectSpace.SQLSelect2(mSql, dtHeader);
    end;

    if dtHeader.Active then
    begin
      dtHeader.First;

      // nastavim typ objektu, protoze firma ho nastavenej nema
      dtHeader.Edit;
      dtHeader.FieldByName('Code').AsString := mType;
      dtHeader.Post;

      LogWriteSectionStart('JSON');
      json := REST_jsonCreate_FromDataSetRow(dtHeader, nil, nil);
      LogWriteSectionEnd;

      HTTPResponse(AResponse, HTTP_SC_OK, ContentType_JSON, json.AsJson(false, true));
    end
    else begin
      ErrREST(ARequest, AResponse, HTTP_SC_NotFound, mError);
    end;
  finally
    dtHeader.Free;
    if Assigned(json) then
      json.Free;
  end;
end;

procedure Raycom_ReceiptCardSave(Self: TNxWebServicesHelper; ARequest: TNxHTTPRequest;
  AResponse: TNxHTTPResponse; slPath: TStringList);
var
  json: TJSONSuperObject;
  mUser_Id, mModule, mDocType: String;
  dtJSONRows: TMemTable;
  dtPrintIDs: TStringList;
  mTemporaryStorageID: Integer;
begin
  json := nil;
  if (slPath.Count = 2) then
  begin
    mDocType := slPath.Strings[1]; //ocekavam ID dokladu
  end else
  begin
    ErrREST(ARequest, AResponse, HTTP_SC_BadRequest, getString('wrong_parameters_count'));
    exit;
  end;

  mUser_Id := getHeaderValue(ARequest, 'UserID');
  mModule := getHeaderValue(ARequest, 'ModuleCode');

  json := TJSONSuperObject.ParseString(REST_ByteUTF82String(ARequest.Content.Content), True);
  dtJSONRows := TMemTable.Create(nil);
  dtPrintIDs := TStringList.Create();
  try
    // ulozim si ID z tabulky o rozpracovanosti
    mTemporaryStorageID := REST_getJSONInt(json, 'tempID');

    // v json je nyni dostupny JSON ze ctecky. Pres Debugger si lze vytahnout pole, ktera obsahuje. Pripadne vetsinova kostra je videt
    // v REST_SkladTerm.U_Queue, funkce getHeaderSql a getRowsSql, kde jsou SQL, ktera obsahuji vetsinu poli prenesnych do ctecky a zpet.

    // Dale si lze z radku udelat dataset.. Zde je ukazka poli, ktera se pouzivaji pri standardni ukladacce
    DataSet_CreataHeader(dtJSONRows, 'jsonIndex=I,StoreDocument_ID=S10,StoreDocument2_ID=S10,StoreDocument2Provide_ID=S10,StoreDocument2ProvideRow_ID=S10,' +
        'DocRowBatch_ID=S10,LogStoreDocument2_ID=S10,StoreFrom_ID=S10,StoreTo_ID=S10,StoreCard_ID=S10,StorePositionFrom_ID=S10,' +
        'StoreBatch_ID=S10,StorePositionTo_ID=S10,Processed=B,UnitQuantity=F,UnitRate=F,UnitCode=S10,Division_ID=S10,WasSelectedByBarcode=B,' +
        'IsNew=B,AccJobOrder_ID=S10,PRFContainerMater_ID=S10,BusProject_ID=S10,BusOrder_ID=S10,BusTransaction_ID=S10');
    dtJSONRows.AddIndex('ByJsonIndex', 'jsonIndex', [ixUnique]);
    dtJSONRows.Open;
    REST_JsonToDataSet(json.A['rows'], dtJSONRows);

    // zde uz pak mam dataset radku, ktery muzu libovolne prochazet
    dtPrintIDs.Add('1C51000101');
    CFxReportManager.PrintByIDs(Self.Context, dtPrintIDs, PrintReport_GetDynSQL(Self.ObjectSpace, 'L400000001'),
      'L400000001', rtoFile, pekPDF, 'C:\FLORESSYSTEM\', 'test.pdf');

    // na konci smazu zaznam z rozpracovanych a potvrdim, ze je to OK nebo ze nastala chyba
    TemporaryStorage_Delete(Self.ObjectSpace, mTemporaryStorageID);
    HTTPResponse(AResponse, HTTP_SC_OK, ContentType_JSON, PlainResponse('')); // OK
    //HTTPResponse(AResponse, HTTP_SC_OK, ContentType_JSON, PlainResponse('TEXT CHYBY')); // CHYBA
  finally
    if Assigned(json) then
      json.Free;
    dtJSONRows.Free;
    dtPrintIDs.Free;
  end;
end;

procedure Put_FreePrintDocStopPicking_Abra_Plab(Self: TNxWebServicesHelper; ARequest: TNxHTTPRequest;
  AResponse: TNxHTTPResponse; slPath: TStringList);
var
  json: TJSONSuperObject;
  mUser_Id, mModule: String;
  dtJSONRows: TMemTable;
  dtPrintIDs: TStringList;
  mTemporaryStorageID, mPrintType: Integer;
begin
  json := nil;
  if (slPath.Count = 2) then
  begin
    mPrintType := StrToInt(slPath.Strings[1]);
  end else
  begin
    ErrREST(ARequest, AResponse, HTTP_SC_BadRequest, getString('wrong_parameters_count'));
    exit;
  end;

  mUser_Id := getHeaderValue(ARequest, 'UserID');
  mModule := getHeaderValue(ARequest, 'ModuleCode');

  json := TJSONSuperObject.ParseString(REST_ByteUTF82String(ARequest.Content.Content), True);
  dtJSONRows := TMemTable.Create(nil);
  try
    Self.ObjectSpace.StartTransaction(taReadCommited);
    try
      // ulozim si ID z tabulky o rozpracovanosti
      mTemporaryStorageID := REST_getJSONInt(json, 'tempID');

      // v json je nyni dostupny JSON ze ctecky. Pres Debugger si lze vytahnout pole, ktera obsahuje. Pripadne vetsinova kostra je videt
      // v REST_SkladTerm.U_SQLQueries, funkce getHeaderSql a getRowsSql, kde jsou SQL, ktera obsahuji vetsinu poli prenesnych do ctecky a zpet.
      // mPrintType obsahuje typ tisku (skupinovy vs individualni)

      // Dale si lze z radku udelat dataset.. Zde je ukazka poli, ktera se pouzivaji pri standardni ukladacce
      DataSet_CreataHeader(dtJSONRows, 'jsonIndex=I,StoreDocument_ID=S10,StoreDocument2_ID=S10,StoreDocument2Provide_ID=S10,StoreDocument2ProvideRow_ID=S10,' +
          'DocRowBatch_ID=S10,LogStoreDocument2_ID=S10,StoreFrom_ID=S10,StoreTo_ID=S10,StoreCard_ID=S10,StorePositionFrom_ID=S10,' +
          'StoreBatch_ID=S10,StorePositionTo_ID=S10,Processed=B,UnitQuantity=F,UnitRate=F,UnitCode=S10,Division_ID=S10,WasSelectedByBarcode=B,' +
          'IsNew=B,AccJobOrder_ID=S10,PRFContainerMater_ID=S10,BusProject_ID=S10,BusOrder_ID=S10,BusTransaction_ID=S10');
      dtJSONRows.AddIndex('ByJsonIndex', 'jsonIndex', [ixUnique]);
      dtJSONRows.Open;
      REST_JsonToDataSet(json.A['rows'], dtJSONRows);

      // zde uz pak mam dataset radku, ktery muzu libovolne prochazet
      //CFxReportManager.PrintByIDs(Self.Context, dtPrintIDs, PrintReport_GetDynSQL(Self.ObjectSpace, 'L400000001'),
      //  'L400000001', rtoFile, pekPDF, 'C:\FLORESSYSTEM\', 'test.pdf');

      //PrintReportToPrinterByIDToQueue(Self.Context, json.S['StoreDocument_ID'], '', '1900000101', '', TISKARNA_SKLAD, mUser_Id, mPrintType);

      // tisk dokladu na tiskarnu
      PrintReportToPrinterByIDToQueue(Self.Context, '19D0000101', '', 'L400000001', '', 'Microsoft Print to PDF', mUser_Id, 1);
      // tisk dokladu do souboru
      PrintReportToPrinterByIDToQueue(Self.Context, '19D0000101', '', 'L400000001', 'G:\Work\temp\tisk2.pdf', '', mUser_Id, 1);
      // tisk souboru na tiskarnu
      PrintReportToPrinterByIDToQueue(Self.Context, '', '', '', 'G:\Work\temp\tisk2.pdf', 'Microsoft Print to PDF', mUser_Id, 1);
      // tisk vice dokladu
      dtPrintIDs := TStringList.Create;
      try
        dtPrintIDs.Add('19D0000101');
        dtPrintIDs.Add('Q910000101');
        PrintReportToPrinterByIDsToQueue(Self.Context, dtPrintIDs, '', 'L400000001', '', 'Microsoft Print to PDF', mUser_Id, 1);
      finally
        dtPrintIDs.Free;
      end;

      // na konci smazu zaznam z rozpracovanych a potvrdim, ze je to OK nebo ze nastala chyba
      TemporaryStorage_Delete(Self.ObjectSpace, mTemporaryStorageID);
      HTTPResponse(AResponse, HTTP_SC_OK, ContentType_JSON, PlainResponse('')); // OK
      Self.ObjectSpace.Commit;
    except
      HTTPResponse(AResponse, HTTP_SC_OK, ContentType_JSON, PlainResponse(Format(getString('%s'), [ExceptionMessage])));
      Self.ObjectSpace.Rollback;
    end;
  finally
    if Assigned(json) then
      json.Free;
    dtJSONRows.Free;
  end;
end;

procedure putKonseptiQueueDocDetailStopPicking(Self: TNxWebServicesHelper; ARequest: TNxHTTPRequest;
  AResponse: TNxHTTPResponse; slPath: TStringList);
var
  mDoc_ID, mDocType, mUser_Id, mModule, mRequestID: String;
  mBO: TNxCustomBusinessObject;
  mTemporaryStorageID : Integer;
begin
  if (slPath.Count = 2) then
  begin
    mDoc_ID := slPath.Strings[1]; //ocekavam ID dokladu
  end else
  begin
    ErrREST(ARequest, AResponse, HTTP_SC_BadRequest, getString('wrong_parameters_count'));
    exit;
  end;

  LogWriteSectionStart('putKonseptiQueueDocDetailStopPicking');

  mUser_Id := getHeaderValue(ARequest, 'UserID');
  mModule := getHeaderValue(ARequest, 'ModuleCode');

  mBO := Self.ObjectSpace.CreateObject(Class_BillOfDelivery);
  try
    Self.ObjectSpace.StartTransaction(taReadCommited);
    try
      mBO.ExplicitTransaction := True;
      mBO.Load(mDoc_ID, nil);
      mBO.PMChangeStateByTransition(PRECHOD_UKONCENI(GetStoreDocType(mDoc_ID, Self.ObjectSpace), mModule));
      //mBO.ChangeStatusBySwitchRule(PRECHOD_UKONCENI(GetStoreDocType(mDoc_ID, Self.ObjectSpace), mModule));
      Self.ObjectSpace.Commit;

      HTTPResponse(AResponse, HTTP_SC_OK, ContentType_JSON, PlainResponse(''));
    except
      Self.ObjectSpace.RollBack;
      HTTPResponse(AResponse, HTTP_SC_OK, ContentType_JSON, PlainResponse(Format(getString('error_stopping_docqueue'), [ExceptionMessage])));
      exit;
    end;

    LogWriteSectionEnd;
  finally
    mBO.Free;
  end;
end;

procedure getVaskyQRCodeResult(Self: TNxWebServicesHelper; ARequest: TNxHTTPRequest;
  AResponse: TNxHTTPResponse; slPath: TStringList);
var
  json: TJSONSuperObject;
  mBarcode: String;
begin
  json := nil;
  if (slPath.Count = 2) then
  begin
    mBarcode := slPath.Strings[1]; //ocekavam artikl
  end else
  begin
    ErrREST(ARequest, AResponse, HTTP_SC_BadRequest, getString('wrong_parameters_count'));
    exit;
  end;

  json := REST_JsonObject_Create(jtObject, nil);
  try
    // ID dokladu, ID radku, mnoztstvi a zda doklad rovnou ulozit
    REST_json_addValue(json, 'storeDocument_ID', '5C41000101');
    REST_json_addValue(json, 'storeDocument2_ID', '4K21000101');
    REST_json_addValue(json, 'unitQuantity', 1);
    REST_json_addValue(json, 'saveDocument', False);

    HTTPResponse(AResponse, HTTP_SC_OK, ContentType_JSON, json.AsJson(false, true));
  finally
    if Assigned(json) then
      json.Free;
  end;
end;

function GetMySQLRows(AOS: TNxCustomObjectSpace; AModule, AUser_Id, ADocType: String; AWhere: String;): String;
begin
  Result :=
    'select ' +
    '  SD2.Parent_ID as "XX_Parent_ID",' + nxCrLf +
    '  SD2.PosIndex as "PosIndex",' + nxCrLf +
    '  SD2.ID as "ID",' + nxCrLf +
    '  ' + putQueueDocDetailStartPicking_RowsOrderBy(AOS, AModule, ADocType, AUser_ID) + ' as "OrderForIndex",' + nxCrLf +
    '  SD.ID as "StoreDocument_ID",' + nxCrLf +
    '  ' + QuotedStr(DOC_IssuedOrder) + ' as "StoreDocumentType",' + nxCrLf +
    '  SD2.ID as "StoreDocument2_ID",' + nxCrLf +
    '  S.ID as "StoreFrom_ID",' + nxCrLf +
    '  S.Code as "StoreFromCode",' + nxCrLf +
    '  S.IsLogistic as "StoreFromIsLogistic$BOOL",' + nxCrLf +
    '  SC.ID as "StoreCard_ID",' + nxCrLf +
    '  SC.' + cStoreCardInfoCodeField + ' as "StoreCardCode",' + nxCrLf +
    '  SC.' + cStoreCardInfoNameField + ' as "StoreCardName",' + nxCrLf +
    '  '';''' + CONCAT_STR + getUnitsSql + CONCAT_STR + ''';'' as "StoreCardUnits",' + nxCrLf +
    '  '';''' + CONCAT_STR + putQueueDocDetailStartPicking_StoreCardBarcodeField(AOS, AModule) + CONCAT_STR + ''';'' as "StoreCardBarcode",' + nxCrLf +
    '  ' + putQueueDocDetailStartPicking_StoreCardAuxInfoForSerNumField(AOS) + ' as "StoreCardAuxInfoForSerNum$BOOL",' + nxCrLf +
    '  case' + nxCrLf +
    '    when (SC.SerialNumberStructure  <> '''') or (CS.CodeStructure is not null and CS.CodeStructure <> '''')' + nxCrLf +
    '    then ''A''' + nxCrLf +
    '    else ''N''' + nxCrLf +
    '  end as "HasStoreBatchStructure$BOOL",' + nxCrLf +
    '  ' + putQueueDocDetailStartPicking_StoreCardCategory(AOS, AModule, ADocType, AUser_ID) + ' as "StoreCardCategory",' + nxCrLf +
    '  ' + DefaultUnitQuantity(AOS, AModule) + ' as  "DefaultUnitQuantity",' + nxCrLf;
  if useMainUnits(AOS, AModule, ADocType, AUser_Id) then
    Result := Result +
      '  SD2.Quantity - SD2.DeliveredQuantity as "UnitQuantity",' + nxCrLf +
      '  SD2.Quantity - SD2.DeliveredQuantity as "UnitQuantityOrig",' + nxCrLf +
      '  SD2.UnitRate as "UnitRate",' + nxCrLf +
      '  SD2.QUnit as "UnitCode",' + nxCrLf
  else
    Result := Result +
      '  (SD2.Quantity - SD2.DeliveredQuantity) / SD2.UnitRate as "UnitQuantity",' + nxCrLf +
      '  (SD2.Quantity - SD2.DeliveredQuantity) / SD2.UnitRate as "UnitQuantityOrig",' + nxCrLf +
      '  SD2.UnitRate as "UnitRate",' + nxCrLf +
      '  SD2.QUnit as "UnitCode",' + nxCrLf;
  Result := Result +
    '  SD2.Division_ID as "Division_ID",' + nxCrLf +
    '  SD2.BusProject_ID as "BusProject_ID",' + nxCrLf +
    '  SD2.BusOrder_ID as "BusOrder_ID",' + nxCrLf +
    '  SD2.BusTransaction_ID as "BusTransaction_ID",' + nxCrLf +
    //'  ''0000000000'' as "StorePositionFrom_ID",' + nxCrLf +
    //'  ''-'' as "StorePositionFromCode",' + nxCrLf +
    '  ' + canAddNewBatch(AOS, AModule) + ' as "CanAddNewBatch",' + nxCrLf +
    '  ' + enabledCustomFields(AOS, AUser_Id, AModule) + ' as "EnabledFields",' + nxCrLf +
//      '  ' + customFields(AOS, AUser_Id, AModule) + ' "customFields", ' + nxCrLf +
    '  ' + DisableQuantityEdit(AOS, AModule) + ' as "DisableQuantityEdit",' + nxCrLf +
    '  ' + rowAuxText(AOS, AModule, ADocType, AUser_ID) + ' as "AuxText",' + nxCrLf +
    '  ' + rowAuxText2(AOS, AModule, ADocType, AUser_ID) + ' as "AuxText2",' + nxCrLf +
    '  ' + putQueueDocDetailStartPicking_customRowColor(AOS, AModule, AUser_Id) + ' as "CustomColor",' + nxCrLf +
    '  ' + IntToStr(showPrintRowButton(AOS, AModule, ADocType, AUser_ID)) + ' as "ShowPrintRowButton",' + nxCrLf +
    '  ' + putQueueDocDetailStartPicking_rowsAuxFields(AOS, AModule, ADocType, AUser_ID) + nxCrLf +
    '  ' + EnterStoreBatchExpirationDate(AOS, AModule, ADocType, AUser_ID, 0) + ' as "EnterStoreBatchExpirationDate"' + nxCrLf +
    'from IssuedOrders2 SD2' + nxCrLf +
    'join IssuedOrders SD on SD.id = SD2.Parent_ID' + nxCrLf +
    'join Stores S on S.ID = SD2.Store_ID' + nxCrLf +
    'left join Stores RS on RS.ID = S.RefundStore_ID' + nxCrLf +
    'join StoreCards SC on SC.ID = SD2.StoreCard_ID' + nxCrLf +
    'left join CodeStructures CS on CS.ID = SC.StoreBatchStructure_ID' + nxCrLf +
    // fake joiny, abych mel aliasy DRB a LSD2, ktere se pouzivaji u razeni
    'left join (select '''' as ID, -1 as PosIndex' + FROM_1_RECORD + ') DRB on DRB.ID = SD2.BusOrder_ID' + nxCrLf +
    'left join (select '''' as ID, -1 as PosIndex' + FROM_1_RECORD + ') LSD2 on LSD2.ID = SD2.BusOrder_ID' + nxCrLf +
    ' ' + putQueueDocDetailStartPicking_Join(AOS, AModule, AUser_Id) + ' ' + nxCrLf +
    'where ' + NxCrLf +
    {'  SD2.Parent_ID = ' + QuotedStr(mDoc_ID) + NxCrLf +
    '  and SD2.RowType = 3 and SC.IsStockType = ''A''' + nxCrLf +}
    AWhere + NxCrLf +
    'order by SD2.PosIndex';
end;

procedure Get_ABRAIssuedOrderRow_Abra(Self: TNxWebServicesHelper; ARequest: TNxHTTPRequest;
  AResponse: TNxHTTPResponse; slPath: TStringList);
var
  mSql, mUser_Id, mDocType, mRow_ID, mModule, mWhere, jsonString: string;
  json: TJSONSuperObject;
  dtRows: TMemTable;
begin
  json := nil;
  if (slPath.Count = 2) then
  begin
    mRow_ID := slPath.Strings[1]; //ocekavam ID skladoveho dokladu
  end else
  begin
    ErrREST(ARequest, AResponse, HTTP_SC_BadRequest, getString('wrong_parameters_count'));
    exit;
  end;

  LogWriteSectionStart('Get_ABRAIssuedOrderRow_Abra');

  mUser_Id := getHeaderValue(ARequest, 'UserID');
  mModule := getHeaderValue(ARequest,'ModuleCode');
  mDocType := getHeaderValue(ARequest, 'DocumentType');

  try
    dtRows := TMemTable.Create(nil);
    try
      mWhere :=
        '  SD2.ID = ' + QuotedStr(mRow_ID) + NxCrLf +
        '  and SD2.RowType = 3 and SC.NonStockType = ''N''' + nxCrLf;

      mSql := GetMySQLRows(Self.ObjectSpace, mModule, mUser_Id, mDocType, mWhere);
      Self.ObjectSpace.SQLSelect2(mSql, dtRows);
      if dtRows.Active then
      begin
        json := REST_jsonCreate_FromDataSet(dtRows, nil, nil);

        jsonString := json.AsJson(false, true);
        jsonString := putQueueDocDetailStartPicking_beforeJSONSend(mModule, jsonString);

        HTTPResponse(AResponse, HTTP_SC_OK, ContentType_JSON, jsonString);
      end
      else
        ErrREST(ARequest, AResponse, HTTP_SC_NotFound, Format(getString('row_not_found'), [mRow_ID]));

    finally
      dtRows.Free;
      if Assigned(json) then
        json.Free;
    end;
  except
    ErrREST(ARequest, AResponse, HTTP_SC_ExpectationFailed, ExceptionMessage);
  end;

  LogWriteSectionEnd;
end;


procedure Get_ReceiptCardFromIOListDocQueue_Abra(Self: TNxWebServicesHelper; ARequest: TNxHTTPRequest;
  AResponse: TNxHTTPResponse; slPath: TStringList);
var
  mDocTypeParameter, mDocType, mModule, mUser_ID: String;
  dtRows: TMemTable;
  mSql, mSearchStr: String;
  json: TJSONSuperObject;
  i: Integer;
  mOS: TNxCustomObjectSpace;
begin
  json := nil;
  mSearchStr := '';
  if ((slPath.Count >= 2) and (slPath.Count <=3)) then
  begin
    mDocTypeParameter := slPath.Strings[1]; //ocekavam typ dokladu
    if slPath.Count = 3 then
      mSearchStr := slPath.Strings[2]; //ocekavam retezec hledani
  end else
  begin
    ErrREST(ARequest, AResponse, HTTP_SC_BadRequest, getString('wrong_parameters_count'));
    exit;
  end;

  mModule := getHeaderValue(ARequest, 'ModuleCode');
  mUser_ID := getHeaderValue(ARequest, 'UserID');
  mDocType := getHeaderValue(ARequest, 'DocumentType');

  mOS := Self.ObjectSpace;

  if mDocTypeParameter <> mDocType then
    RaiseException(getString('error_different_document_type'));

  dtRows := TMemTable.Create(nil);
  try
    LogWriteSectionStart('ListDocQueue ' + mDocType);

    mSql :=
      'select' + nxCrLf +
      '  SD.ID as "ID",' + nxCrLf;

    //if not AOnlySimple then
    //begin
      mSql := mSql +
        '  DQ.Code' + CONCAT_STR + QuotedStr('-') + CONCAT_STR + 'cast(SD.OrdNumber as varchar(6))' +
          CONCAT_STR + QuotedStr('/') + CONCAT_STR + 'P.Code as "DisplayName",' + nxCrLf +
        '  SD.DocDate$DATE as "DocDate$DATE",' +  nxCrLf +
        '  (select count(SD2.ID) from IssuedOrders2 SD2 where SD2.Parent_ID = SD.ID and SD2.RowType = 3) as "ItemCount",' + nxCrLf +
        '   ' + listDocQueue_Field_Description(mOS, mModule, mDocType, mUser_Id) + ' as "Description",' + nxCrLf +
        '   ' + listDocQueue_Field_FirmName(mOS) + ' as "FirmName",' + NxCrLf +
        '   ' + listDocQueue_customRowColor(mOS, mModule, mUser_Id) + ' as "CustomColor",' + nxCrLf +
        '   case' + NxCrLf +
        '     when RTS.ID is not null' + nxCrLf +
        '     then ''A''' + nxCrLf +
        '     else ''N''' + nxCrLf +
        '   end as "InProgress$BOOL",' + nxCrLf;
    //end;

    mSql := mSql +
      '   ' + listDocQueue_AuxNonVisibleFields(mOS, mModule) + nxCrLf + NxCrLf +
      ' from IssuedOrders SD' + NxCrLf +
      ' join Firms F on F.ID = SD.Firm_ID' + NxCrLf +
      ' join DocQueues DQ on DQ.ID = SD.DocQueue_ID' + NxCrLf +
      ' join Periods P on P.ID = SD.Period_ID' + NxCrLf +
      ' left join ' + REST_TABLE_TemporaryStorage + ' RTS on RTS.Document_ID = SD.ID and RTS.DataType = ' +
        QuotedStr(mModule) + ' and RTS.Status = ' + IntToStr(TempStorageStatus_OPEN) + nxCrLf;

    mSql := mSql +
      ' ' + listDocQueue_Join(mOS, mModule, mDocType, mUser_ID) +
      ' where' + nxCrLf +
      '   (SD.IsAvailableForDelivery = ''A'') AND (SD.Closed = ''N'')';

    // hledani
    mSql := mSql + listDocQueue_Search(mOS, mDocType, mSearchStr, mModule, mUser_Id);

    mOS.SQLSelect2(mSql, dtRows);
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

procedure Put_ReceiptCardFromIOStartPicking_Abra(Self: TNxWebServicesHelper; ARequest: TNxHTTPRequest;
  AResponse: TNxHTTPResponse; slPath: TStringList);
var
  mSql, mUser_Id, mDocType, mDocTypeB, mDoc_ID, mModuleName, mModule, mAuxField,
    mChangeableFields, mWhere, mTable, mStatusField, jsonString, mReport_ID: string;
  mBO, mBO2_BoD, mBO2_OutT, mRow: TNxCustomBusinessObject;
  json, dialogJSON: TJSONSuperObject;
  mRows: TNxCustomBusinessMonikerCollection;
  i, tempId: Integer;
  dtHeader, dtStoreDocuments: TMemTable;
  dtRows, mDialog, mDialogValues: TMemTable;
  mSL: TStringList;
  mAuxReadOnly: boolean;
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

  LogWriteSectionStart('PutReceiptCardFromIOStartPicking');

  mUser_Id := getHeaderValue(ARequest, 'UserID');
  mModule := getHeaderValue(ARequest,'ModuleCode');
  mDocType := getHeaderValue(ARequest, 'DocumentType');

  mReport_ID := '';

  mDocTypeB := mDocType;
  if (mDocType = DOC_RefundedBillOfDelivery) and useBillOfDeliveryForRefunding then
    mDocType := DOC_BillOfDelivery;

  Self.ObjectSpace.StartTransaction(taReadCommited);
  try
    // TODO tohle neni uplne nej zpusob
    mBO := GetStoreDocBO(Self.ObjectSpace, mDocType);
    dtHeader := TMemTable.Create(nil);
    dtStoreDocuments := TMemTable.Create(nil);
    dtRows := TMemTable.Create(nil);
    mDialog := TMemTable.Create(nil);
    mDialogValues := TMemTable.Create(nil);
    mSL := TStringList.Create;
    try
      if not Assigned(mBO) then
        RaiseException(getString('not_valid_id'));

      mBO.ExplicitTransaction := True;
      mBO.Load(mDoc_ID, nil);

      mTable := GetTable(mDocType);
      mStatusField := GetStatusField;

      // vratim typ zpet, pokud jsem ho zmenil
      mDocType := mDocTypeB;

      // nechceme pouzivat stavy nad OBP
      // zmena stavu BO
      {if pos(mBO.GetFieldValueAsString(mStatusField), STAV_K_VYSKLADNENI(mDocType, mModule)) <= 0 then
        RaiseException(getString('issuance_another_user'));

      ChangeStatusByRule(mBO, PRECHOD_ZAHAJENI(mDocType, mModule), '0000000000', mUser_Id);}

      mAuxField := StoreDocumentAuxTextField(mModule, mAuxReadOnly);
      mChangeableFields := putQueueDocDetailStartPicking_ChangeableFields(mModule);

      mSql := getHeaderSql(Self.ObjectSpace, mModule, mUser_Id, mDoc_ID, mDocType, mAuxField, mAuxReadOnly, mChangeableFields);

      Self.ObjectSpace.SQLSelect2(mSql, dtHeader);

      // TODO - predavat si ze ctecky info, jestli se maji vrace polozky. Napr. prijem dle dokladu v Dobrovskem polozky nechce.
      if dtHeader.Active then
      begin
        dtHeader.First;

        mWhere :=
          '  SD2.Parent_ID = ' + QuotedStr(mDoc_ID) + NxCrLf +
          '  and SD2.RowType = 3 and SC.NonStockType = ''N''' + nxCrLf +
          '  and (SD2.Quantity - SD2.DeliveredQuantity) > 0' + nxCrLf;


        mSql := GetMySQLRows(Self.ObjectSpace, mModule, mUser_Id, mDocType, mWhere);
        Self.ObjectSpace.SQLSelect2(mSql, dtRows);
        if dtRows.Active then
        begin
          dtRows.AddIndex('id', REST_XX_Parent_ID+';OrderForIndex', [ixPrimary]);
          dtRows.IndexName:= 'id';
          mSL.AddObject('rows=', dtRows);

          putQueueDocDetailStartPicking_beforeJSONCreate(Self.ObjectSpace, mModule, mDocType, mUser_ID, dtRows);
        end;
      end;

      json := REST_jsonCreate_FromDataSetRow(dtHeader, nil, mSL);

      // dialog
      DataSet_CreataHeader(mDialogValues, REST_DialogValuesDatasetHeader);
      mDialogValues.Open;
      dialogJSON := json.CreateJSON;
      dialogJSON.S['text'] := DialogOnDocSave(Self.ObjectSpace, mDocType, mModule, mUser_ID, mDoc_ID, mDialogValues);
      dialogJSON.O['values'] := REST_jsonCreate_FromDataSet(mDialogValues, json);
      json.O['Dialog'] := dialogJSON;

      // rovnou ulozime do TemporaryStorage
      tempId := TemporaryStorage_Create(Self.ObjectSpace, json.AsJson(false, true), mModule, mUser_Id, mDoc_ID);
      json.I['tempID'] := tempId;

      jsonString := json.AsJson(false, true);
      jsonString := putQueueDocDetailStartPicking_beforeJSONSend(mModule, jsonString);

      // tisk
      mReport_ID := REPORT_VYSKLADNENI(mDocType, mModule);
      if mReport_ID <> '' then
        PrintReportToPrinterByIDToQueue(Self.Context, mDoc_ID, '', mReport_ID, '', TISKARNA_SKLAD, mUser_Id, 1);

      HTTPResponse(AResponse, HTTP_SC_OK, ContentType_JSON, jsonString);

      Self.ObjectSpace.Commit;
    finally
      mBO.Free;
      mDialog.Free;
      mDialogValues.Free;
      dtHeader.Free;
      dtStoreDocuments.Free;
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

procedure Put_ReceiptCardFromIOStopPicking_Abra(Self: TNxWebServicesHelper; ARequest: TNxHTTPRequest;
  AResponse: TNxHTTPResponse; slPath: TStringList);
var
  json: TJSONSuperObject;
  mSD, mIO, mSDRow, mDocRowBatch, mStoreBatch: TNxCustomBusinessObject;
  mSDRows, mDocRowBatches: TNxCustomBusinessMonikerCollection;
  i, j: Integer;
  mTemporaryStorageID: Integer;
  mOS: TNxCustomObjectSpace;
  jsonSerNums, jsonCustomFields: TJSONSuperObjectArray;
  dtJSONRows, dtDocumentQuantity: TMemTable;
  mSelectedByBarcode: Boolean;
  mQuantity: Double;
  mDIM: TNxDocumentImportManager;
  mParams: TNxParameters;
  mLSD_ID, mUser_ID, mDocType,
    mLogStoreDocumentClass, mLogStoreDocument_DocQueue_ID, mLogStoreDocument_StoreGateway_ID,
    mStoreField, mStorePositionField, mStoreDocumentClass, mRequestID, mDocQueue_ID, mAuxField,
    mModule, mStoreBatch_ID, mPersonField, mSerNum_ID, mLogStoreDocumentDocType: String;
  mAuxReadOnly: Boolean;
  mProcessedBatches: TStringList;

  function getSumUnitQuantityForSD2_ID(ADataSet: TDataSet; SD2_ID: String; AProcessed, ADamaged, ANotConfirmed: Boolean; var AAllSelectedByBarcode: Boolean; AField: String = ''): Double;
  var
    mBM: TBookmark;
    mField: String;
  begin
    Result := 0;
    AAllSelectedByBarcode := True;

    if AField <> '' then
      mField := AField
    else
      mField := 'StoreDocument2_ID';

    mBM := ADataSet.GetBookmark;
    ADataSet.First;
    while not ADataSet.EOF do
    begin
      if (ADataSet.FieldByName('Processed').AsBoolean = AProcessed) and (ADataSet.FieldByName('IsDamaged').AsBoolean = ADamaged)
        and (ADataSet.FieldByName('IsNotConfirmed').AsBoolean = ANotConfirmed)
        and (ADataSet.FieldByName(mField).AsString = SD2_ID) then
      begin
        Result := Result + ADataSet.FieldByName('UnitQuantity').AsFloat;
        if not ADataSet.FieldByName('WasSelectedByBarcode').AsBoolean then
          AAllSelectedByBarcode := False;
      end;
      ADataSet.Next;
    end;
    ADataSet.GotoBookmark(mBM);
  end;

  procedure fillClassAndIdVariables;
  begin
    mStoreDocumentClass := Class_ReceiptCard;
    mLogStoreDocumentClass := Class_LogStoreInput;
    mLogStoreDocumentDocType := DOC_LogStoreInput;
    mLogStoreDocument_DocQueue_ID := LogStoreInput_DocQueue_ID;
    mLogStoreDocument_StoreGateway_ID := LogStoreInput_StoreGateway_ID;
    mDocQueue_ID := RADA_PRIJEMKA;
    mStoreField := 'StoreFrom_ID';
    mStorePositionField := 'StorePositionFrom_ID';
  end;

  procedure fillCustomFields;
  var
    j: Integer;
  begin
    // kontrola, zda jsou nejaka pole definovana
    if((json.A['rows'].O[dtJSONRows.FieldByName('jsonIndex').AsInteger].N['customFields'].DataType = jtNull)
        or (json.A['rows'].O[dtJSONRows.FieldByName('jsonIndex').AsInteger].N['customFields'].DataType = -1)) then
      exit;

    jsonCustomFields := json.A['rows'].O[dtJSONRows.FieldByName('jsonIndex').AsInteger].A['customFields'];

    for j := 0 to jsonCustomFields.Length - 1 do
    begin
      if(jsonCustomFields.O[j].S['type'] = 'text') then
      begin
        mSDRow.SetFieldValueAsString(jsonCustomFields.O[j].S['field'], jsonCustomFields.O[j].S['textValue']);
      end
      else if(jsonCustomFields.O[j].S['type'] = 'number') then
      begin
        mSDRow.SetFieldValueAsInteger(jsonCustomFields.O[j].S['field'], jsonCustomFields.O[j].I['numberValue']);
      end;
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
      REST_JsonToDataSet(json.O['Dialog'].A['values'], mDialogValues);

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
    ADocument: TNxCustomBusinessObject = nil; AStore_ID: String = ''): String;
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

  procedure fillStoreBatches;
  var
    mStoreBatch: TNxCustomBusinessObject;
    mStoreBatch_ID: String;
    mQuantity: Double;
  begin
    mDocRowBatches := mSDRow.GetLoadedCollectionMonikerForFieldCode(mSDRow.GetFieldCode('DocRowBatches'));
    // pokud mame ID, tak pridame k radku
    if not CFxOID.IsEmpty(dtJSONRows.FieldByName('StoreBatch_ID').AsString) then
    begin
      if Pos(dtJSONRows.FieldByName('StoreBatch_ID').AsString, mProcessedBatches.Text) > 0 then
        exit;

      // pridame sarze podle napipane skutecnosti
      mDocRowBatch := mDocRowBatches.AddNewObject;
      // tento Prefill se nam nehodi, Kuba napr. v Dworkinu v hacku v Prefillu vzdy nastavuje NewBatch := True
      //mDocRowBatch.Prefill;

      // vezmu si mnozstvi pro tuto sarzi ze vsech radku s ni
      // ulozim si id sarze, abych vedel, ze uz jsem ji zpracoval a dalsi radek s ni preskocil
      mQuantity := getSumUnitQuantityForSD2_IDAndBatch_ID(dtJSONRows, mSDRow.OID, dtJSONRows.FieldByName('StoreBatch_ID').AsString, True, False,
        mDocRowBatch.GetFieldValueAsFloat('UnitRate'));
      mProcessedBatches.Append(dtJSONRows.FieldByName('StoreBatch_ID').AsString);
      mDocRowBatch.SetFieldValueAsString('StoreBatch_ID', dtJSONRows.FieldByName('StoreBatch_ID').AsString);
      mDocRowBatch.SetFieldValueAsString('QUnit', mSDRow.GetFieldValueAsString('QUnit'));

      if dtJSONRows.FieldByName('EnterStoreBatchExpirationDate').AsBoolean then
      begin
        mStoreBatch := Self.ObjectSpace.CreateObject(Class_StoreBatch);
        try
          mStoreBatch.Load(mDocRowBatch.GetFieldValueAsString('StoreBatch_ID'), nil);
          mStoreBatch.ExplicitTransaction := True;
          mStoreBatch.SetFieldValueAsDateTime('ExpirationDate$DATE',
            CFxDateTime.ISO8601ToDateTime(dtJSONRows.FieldByName('StoreBatchExpirationDate').AsString));
          mStoreBatch.Save;
        finally
          mStoreBatch.Free;
        end;
      end;

      if useMainUnits(Self.ObjectSpace, mModule, mDocType, mUser_ID) then
        mDocRowBatch.SetFieldValueAsFloat('UnitQuantity', CFxFloat.DivideDef6(mQuantity, mSDRow.GetFieldValueAsFloat('UnitRate'), 0))
      else
        mDocRowBatch.SetFieldValueAsFloat('UnitQuantity', mQuantity);

      afterDocRowBatchFill(Self.ObjectSpace, mModule, mDocRowBatch, mSDRow, mSD, dtJSONRows);
    end
    else // pokud ID NEmame, tak sarzi vytvorim dle generatoru. Pokud generator neni, tak se sarze proste nevytvori
    begin
      // ABRA ma i pri nenastavene strukture vyplnenou hodnout. Vyplneni se pozna podle posledniho znaku A/N
      // FLORES pri nenastavene stukture hodnotu proste uplne smaze, takze lze kontrolovat pouze na prazdny udaj
      if ((ABRA
            and (copy(mSDRow.GetFieldValueAsString('StoreCard_ID.SerialNumberStructure'), Length(mSDRow.GetFieldValueAsString('StoreCard_ID.SerialNumberStructure')),
              1) <> 'N'))
        or (not ABRA and (mSDRow.GetFieldValueAsString('StoreCard_ID.SerialNumberStructure') <> '')))
        or not NxIsEmptyOID(mSDRow.GetFieldValueAsString('StoreCard_ID.StoreBatchStructure_ID')) then
      begin
        // vytvorim sarzi
        mStoreBatch := Self.ObjectSpace.CreateObject(Class_StoreBatch);
        try
          mStoreBatch.New;
          mStoreBatch.Prefill;
          mStoreBatch.SetFieldValueAsString('StoreCard_ID', dtJSONRows.FieldByName('StoreCard_ID').AsString);
          mStoreBatch.Save;
          mStoreBatch_ID := mStoreBatch.OID;
        finally
          mStoreBatch.Free;
        end;

        mDocRowBatch := mDocRowBatches.AddNewObject;
        mDocRowBatch.Prefill;
        mDocRowBatch.SetFieldValueAsBoolean('NewBatch', False);
        mDocRowBatch.SetFieldValueAsString('StoreBatch_ID', mStoreBatch_ID);
        mDocRowBatch.SetFieldValueAsString('QUnit', mSDRow.GetFieldValueAsString('QUnit'));
        if useMainUnits(Self.ObjectSpace, mModule, mDocType, mUser_ID) then
          mDocRowBatch.SetFieldValueAsFloat('UnitQuantity', CFxFloat.DivideDef6(dtJSONRows.FieldByName('UnitQuantity').AsFloat, mSDRow.GetFieldValueAsFloat('UnitRate'), 0))
        else
          mDocRowBatch.SetFieldValueAsFloat('UnitQuantity', dtJSONRows.FieldByName('UnitQuantity').AsFloat);
      end;
    end;
  end;

  procedure fillSerialNumbers;
  var
    mSerNum_ID: String;
    mFound: Boolean;
    mStoreBatch: TNxCustomBusinessObject;
  begin
    // musime do jsonu pro kolekci sernums
    jsonSerNums := json.A['rows'].O[dtJSONRows.FieldByName('jsonIndex').AsInteger].A['sernums'];
    mDocRowBatches := mSDRow.GetLoadedCollectionMonikerForFieldCode(mSDRow.GetFieldCode('DocRowBatches'));

    // pokud neni aktivni vlastni ukladani ser. cisel, tak udelam standardne
    if not putQueueDocDetailStopPicking_FillSerialNumbers(Self.ObjectSpace, mModule, jsonSerNums, mSDRow, mDocRowBatches) then
    begin
      if (mSDRow.GetFieldValueAsInteger('StoreCard_ID.Category') = 1) then
      begin
        for j := 0 to jsonSerNums.Length - 1 do
        begin
          mDocRowBatch := mDocRowBatches.AddNewObject;
          //mDocRowBatch.Prefill;
          if CFxOID.IsEmpty(jsonSerNums.O[j].S['SerNum_ID']) then
          begin
            mSerNum_ID := '';
            if isUsingExistingSerNumberAllowed then
            begin
              // zkusim sarzi ser. cislo
              mSerNum_ID := SQLSelectStr(Self.ObjectSpace, 'select ID from StoreBatches where Name = ' + QuotedStr(jsonSerNums.O[j].S['SerNumName'])
                + ' and StoreCard_ID = ' + QuotedStr(mSDRow.GetFieldValueAsString('StoreCard_ID')) + 'and Hidden = ''N''');
            end;

            // pokud jsem ser. cislo nasel, tak ho vyplnim
            if mSerNum_ID <> '' then
            begin
              mDocRowBatch.SetFieldValueAsString('StoreBatch_ID', mSerNum_ID);
              // ulozim si ser. cislo do JSONu, protoze ho budu potrebovat pri polohovani
              jsonSerNums.O[j].S['SerNum_ID'] := mSerNum_ID;

              // doplnim aux text do specifikace
              mStoreBatch := Self.ObjectSpace.CreateObject(Class_StoreBatch);
              try
                mStoreBatch.ExplicitTransaction := True;
                mStoreBatch.Load(mSerNum_ID, nil);
                mStoreBatch.SetFieldValueAsString('Specification', jsonSerNums.O[j].S['AuxText']);
                mStoreBatch.Save;
              finally
                mStoreBatch.Free;
              end;
            end
            else
            begin
              mStoreBatch := Self.ObjectSpace.CreateObject(Class_StoreBatch);
              try
                mStoreBatch.ExplicitTransaction := True;
                mStoreBatch.New;
                mStoreBatch.Prefill;
                mStoreBatch.SetFieldValueAsString('StoreCard_ID', mSDRow.GetFieldValueAsString('StoreCard_ID'));
                mStoreBatch.SetFieldValueAsBoolean('SerialNumber', True);
                mStoreBatch.SetFieldValueAsString('Name', jsonSerNums.O[j].S['SerNumName']);
                mStoreBatch.SetFieldValueAsString('Specification', jsonSerNums.O[j].S['AuxText']);
                mStoreBatch.Save;
                mStoreBatch_ID := mStoreBatch.OID;
              finally
                mStoreBatch.Free;
              end;

              // nenasel jsem, takze vytvarim nove
              mDocRowBatch.SetFieldValueAsBoolean('NewBatch', False);
              mDocRowBatch.SetFieldValueAsString('StoreBatch_ID', mStoreBatch_ID);
              // ulozim si ser. cislo do JSONu, protoze ho budu potrebovat pri polohovani
              jsonSerNums.O[j].S['SerNum_ID'] := mStoreBatch_ID;
            end;
          end
          else
          begin
            mDocRowBatch.SetFieldValueAsString('StoreBatch_ID', jsonSerNums.O[j].S['SerNum_ID']);
          end;
          mDocRowBatch.SetFieldValueAsString('QUnit', mSDRow.GetFieldValueAsString('QUnit'));
          mDocRowBatch.SetFieldValueAsFloat('UnitQuantity', 1);
        end;
      end;
    end;
  end;

  // pomoci importniho manazera vytvori novou prijemku
  procedure CreateNewDocument(AUseImportManager, ACreateLSD, AProcessed, ADamaged, ANotCofirmed: Boolean; AStore_ID: String = '');
  var
    mSDFree: Boolean;
    mSql: String;
    mUnitPrice: Double;
  begin
    mSDFree := False;
    mDIM := NxCreateDocumentImportManager(Self.ObjectSpace, Class_IssuedOrder, Class_ReceiptCard);
    try
      if AUseImportManager then
      begin
        mIO := mOS.CreateObject(Class_IssuedOrder);
        try
          mParams := TNxParameters.Create;
          try
            mDIM.SaveParams(mParams);

            mIO.Load(REST_getJSONStr(json, 'ID'), nil);
            mDIM.AddInputDocument(REST_getJSONStr(json, 'ID'));
            mDIM.SelectedHeader := mIO;

            mParams.GetOrCreateParam(dtString, 'DocQueue_ID').AsString :=
              GetDocQueueForDocument(mOS, mModule, mDocType, mUser_ID, RADA_PRIJEMKA, DOC_IssuedOrder, mIO);
            mDIM.LoadParams(mParams);
            mDIM.Execute;
            mSD := mDIM.OutputDocument;
            mSD.ExplicitTransaction := True;
          finally
            mParams.Free;
          end;
        finally
          mIO.Free;
        end;
      end
      else
      begin
        // doklad vytvarim bez vazeb
        mSD := mOS.CreateObject(Class_ReceiptCard);
        mSDFree := True;
        mSD.New;
        mSD.Prefill;
        mSD.SetFieldValueAsString('Firm_ID', REST_getJSONStr(json, 'Firm_ID'));
        mSD.SetFieldValueAsString('DocQueue_ID', GetDocQueueForDocument(mOS, mModule, mDocType, mUser_ID, RADA_PRIJEMKA));
      end;

      // projdu radky prijemky a upravim podle skutecnosti
      // pokud jsem sel pres import. manazera, tak budu prochazet radky prijemky a nastavovat je dle datasetu
      // pokud jsem vytvarel cistou prijemku, tak budu radky proste pridavat
      mSDRows := mSD.GetLoadedCollectionMonikerForFieldCode(mSD.GetFieldCode('Rows'));
      if not mSDFree then
      begin
        for i := 0 to mSDRows.Count - 1 do
        begin
          mSDRow := mSDRows.BusinessObject[i];

          mProcessedBatches.Clear;

          mQuantity := getSumUnitQuantityForSD2_ID(dtJSONRows, mSDRow.GetFieldValueAsString('ProvideRow_ID'), AProcessed, ADamaged, ANotCofirmed, mSelectedByBarcode);
          if CFxFloat.IsZero6(mQuantity) then
            mSDRow.MarkForDelete
          else
          begin
            if useMainUnits(Self.ObjectSpace, mModule, mDocType, mUser_ID) then
              mSDRow.SetFieldValueAsFloat('UnitQuantity', CFxFloat.DivideDef6(mQuantity, mSDRow.GetFieldValueAsFloat('UnitRate'), 0))
            else
              mSDRow.SetFieldValueAsFloat('UnitQuantity', mQuantity);

            dtJSONRows.IndexName := 'ByStoreDocument2_ID';
            dtJSONRows.First;
            while not dtJSONRows.Eof do
            begin
              if (dtJSONRows.FieldByName('StoreDocument2_ID').AsString <> mSDRow.GetFieldValueAsString('ProvideRow_ID')) then
              begin
                dtJSONRows.Next;
                continue;
              end;

              // preskakuju radky, ktere me zrovna nezajimaji
              // preskakuju radky, ktere me zrovna nezajimaji
              if not (dtJSONRows.FieldByName('Processed').AsBoolean = AProcessed)
                or not ((dtJSONRows.FieldByName('Processed').AsBoolean = AProcessed) and (dtJSONRows.FieldByName('IsDamaged').AsBoolean = ADamaged))
                or not((dtJSONRows.FieldByName('Processed').AsBoolean = AProcessed) and (dtJSONRows.FieldByName('IsNotConfirmed').AsBoolean = ANotCofirmed)) then
              begin
                dtJSONRows.Next;
                continue;
              end;

              // pokud je artikl s evidenci sarzi
              if (mSDRow.GetFieldValueAsInteger('StoreCard_ID.Category') = 2) then
              begin
                fillStoreBatches;
              end;
              // vyplnim ser. cisla
              fillSerialNumbers;

              // vyplnim custom fieldy
              fillCustomFields;

              dtJSONRows.Next;
            end;
          end;
        end;

        // naplnime pomocny dataset pro vytvoreni polohovaku
        dtDocumentQuantity.EmptyTable;
        if ACreateLSD then
        begin
          dtJSONRows.First;
          while not dtJSONRows.EOF do
          begin
            if dtJSONRows.FieldByName('Processed').AsBoolean
              and not dtJSONRows.FieldByName('IsDamaged').AsBoolean
              and not dtJSONRows.FieldByName('IsNotConfirmed').AsBoolean
              and not CFxOID.IsEmpty(dtJSONRows.FieldByName(mStorePositionField).AsString) then
            begin
              jsonSerNums := json.A['rows'].O[dtJSONRows.FieldByName('jsonIndex').AsInteger].A['sernums'];

              // Pokud ma radek seriova cisla, tak ho musim rozpadnout po nich
              if jsonSerNums.Length > 0 then
              begin
                for i := 0 to jsonSerNums.Length - 1 do
                  AddTodtDocumentQuantity(dtDocumentQuantity,
                    dtJSONRows.FieldByName(mStoreField).AsString,
                    dtJSONRows.FieldByName('StoreCard_ID').AsString,
                    jsonSerNums.O[i].S['SerNum_ID'],
                    dtJSONRows.FieldByName(mStorePositionField).AsString,
                    1,
                    dtJSONRows.FieldByName('UnitRate').AsFloat
                    );
              end
              else
                AddTodtDocumentQuantity(dtDocumentQuantity,
                  dtJSONRows.FieldByName(mStoreField).AsString,
                  dtJSONRows.FieldByName('StoreCard_ID').AsString,
                  NxIIfStr(CFxOID.IsEmpty(dtJSONRows.FieldByName('StoreBatch_ID').AsString), 'ZZZZZZZZZZ', dtJSONRows.FieldByName('StoreBatch_ID').AsString),
                  dtJSONRows.FieldByName(mStorePositionField).AsString,
                  dtJSONRows.FieldByName('UnitQuantity').AsFloat,
                  dtJSONRows.FieldByName('UnitRate').AsFloat
                );
            end;
            dtJSONRows.Next;
          end;
        end;
      end
      else
      begin
        dtDocumentQuantity.EmptyTable;
        dtJSONRows.First;
        while not dtJSONRows.EOF do
        begin
          // preskakuju radky, ktere me zrovna nezajimaji
          if not (dtJSONRows.FieldByName('Processed').AsBoolean = AProcessed)
            or not ((dtJSONRows.FieldByName('Processed').AsBoolean = AProcessed) and (dtJSONRows.FieldByName('IsDamaged').AsBoolean = ADamaged))
            or not((dtJSONRows.FieldByName('Processed').AsBoolean = AProcessed) and (dtJSONRows.FieldByName('IsNotConfirmed').AsBoolean = ANotCofirmed)) then
          begin
            dtJSONRows.Next;
            continue;
          end;

          mSDRow := mSDRows.AddNewObject;
          mSDRow.Prefill;
          mSDRow.SetFieldValueAsInteger('RowType', 3);
          mSDRow.SetFieldValueAsString('Store_ID', AStore_ID);
          mSDRow.SetFieldValueAsString('StoreCard_ID', dtJSONRows.FieldByName('StoreCard_ID').AsString);
          mSDRow.SetFieldValueAsString('QUnit', dtJSONRows.FieldByName('UnitCode').AsString);
          mSDRow.SetFieldValueAsString('Division_ID', STREDISKO_HLAVNI);
          mSDRow.SetFieldValueAsFloat('UnitQuantity', dtJSONRows.FieldByName('UnitQuantity').AsFloat);
          mSDRow.SetFieldValueAsString('ProvideRowType', 'IO');
          mSDRow.SetFieldValueAsString('Provide_ID', dtJSONRows.FieldByName('StoreDocument_ID').AsString);
          mSDRow.SetFieldValueAsString('ProvideRow_ID', dtJSONRows.FieldByName('StoreDocument2_ID').AsString);

          // doplneni ceny
          mSql := 'select top 1 IO2.UnitPrice from IssuedOrders2 IO2 where IO2.ID = ' + QuotedStr(dtJSONRows.FieldByName('StoreDocument2_ID').AsString);
          mUnitPrice := SQLSelectFloat(Self.ObjectSpace, mSql);
          mSDRow.SetFieldValueAsFloat('UnitPrice', mUnitPrice);

          fillCustomFields;

          // sarze
          if (mSDRow.GetFieldValueAsInteger('StoreCard_ID.Category') = 2) then
          begin
            mDocRowBatches := mSDRow.GetLoadedCollectionMonikerForFieldCode(mSDRow.GetFieldCode('DocRowBatches'));

            // pokud mame ID, tak pridame k radku
            if not CFxOID.IsEmpty(dtJSONRows.FieldByName('StoreBatch_ID').AsString) then
            begin
              mDocRowBatch := mDocRowBatches.AddNewObject;
              mDocRowBatch.SetFieldValueAsString('StoreBatch_ID', dtJSONRows.FieldByName('StoreBatch_ID').AsString);
              mDocRowBatch.SetFieldValueAsString('QUnit', dtJSONRows.FieldByName('UnitCode').AsString);
              mDocRowBatch.SetFieldValueAsFloat('UnitQuantity', dtJSONRows.FieldByName('UnitQuantity').AsFloat);
            end
            else // pokud ID NEmame, tak sarzi vytvorim (v tomhle pripade by mela karta mit nastavenou strukturu novych sarzi)
            begin
              // vytvorim sarzi
              mStoreBatch := Self.ObjectSpace.CreateObject(Class_StoreBatch);
              try
                mStoreBatch.New;
                mStoreBatch.Prefill;
                mStoreBatch.SetFieldValueAsString('StoreCard_ID', dtJSONRows.FieldByName('StoreCard_ID').AsString);
                mStoreBatch.Save;
                mStoreBatch_ID := mStoreBatch.OID;
              finally
                mStoreBatch.Free;
              end;
              mDocRowBatch := mDocRowBatches.AddNewObject;
              mDocRowBatch.SetFieldValueAsString('StoreBatch_ID', mStoreBatch_ID);
              mDocRowBatch.SetFieldValueAsString('QUnit', dtJSONRows.FieldByName('UnitCode').AsString);
              mDocRowBatch.SetFieldValueAsFloat('UnitQuantity', dtJSONRows.FieldByName('UnitQuantity').AsFloat);

              // do datasetu ulozim ID nove sarze, abych mohl polohovat
              dtJSONRows.Edit;
              dtJSONRows.FieldByName('StoreBatch_ID').AsString := mStoreBatch_ID;
              dtJSONRows.Post;
            end;
          end;

          // ser. cisla
          if (mSDRow.GetFieldValueAsInteger('StoreCard_ID.Category') = 1) then
          begin
            mDocRowBatches := mSDRow.GetLoadedCollectionMonikerForFieldCode(mSDRow.GetFieldCode('DocRowBatches'));
            // musime do jsonu pro kolekci sernums
            jsonSerNums := json.A['rows'].O[dtJSONRows.FieldByName('jsonIndex').AsInteger].A['sernums'];
            for i := 0 to jsonSerNums.Length - 1 do
            begin
              mDocRowBatch := mDocRowBatches.AddNewObject;

              // pokud neni vyplnene ID, tak ho muzim zjistit nebo cislo vytvorit
              if CFxOID.IsEmpty(jsonSerNums.O[i].S['SerNum_ID']) then
              begin
                // dohledam existujici ser. cislo
                mSerNum_ID := '';
                if IsUsingExistingSerNumberAllowed then
                begin
                  // zkusim sarzi ser. cislo
                  mSerNum_ID := SQLSelectStr(Self.ObjectSpace, 'select ID from StoreBatches where Name = ' + QuotedStr(jsonSerNums.O[i].S['SerNumName'])
                    + ' and StoreCard_ID = ' + QuotedStr(mSDRow.GetFieldValueAsString('StoreCard_ID')) + 'and Hidden = ''N''');
                end;

                if mSerNum_ID <> '' then
                begin
                  mDocRowBatch.SetFieldValueAsString('StoreBatch_ID', mSerNum_ID);
                  // ulozim si ser. cislo do JSONu, protoze ho budu potrebovat pri polohovani
                  jsonSerNums.O[i].S['SerNum_ID'] := mSerNum_ID;
                end
                else
                begin
                  mStoreBatch := Self.ObjectSpace.CreateObject(Class_StoreBatch);
                  try
                    mStoreBatch.New;
                    mStoreBatch.Prefill;
                    mStoreBatch.SetFieldValueAsString('StoreCard_ID', mSDRow.GetFieldValueAsString('StoreCard_ID'));
                    mStoreBatch.SetFieldValueAsBoolean('SerialNumber', True);
                    mStoreBatch.SetFieldValueAsString('Name', jsonSerNums.O[i].S['SerNumName']);
                    mStoreBatch.SetFieldValueAsString('Specification', jsonSerNums.O[i].S['AuxText']);
                    mStoreBatch.Save;
                    mStoreBatch_ID := mStoreBatch.OID;
                  finally
                    mStoreBatch.Free;
                  end;

                  // nenasel jsem, takze vytvarim nove
                  mDocRowBatch.SetFieldValueAsBoolean('NewBatch', False);
                  mDocRowBatch.SetFieldValueAsString('StoreBatch_ID', mStoreBatch_ID);
                  // ulozim si ser. cislo do JSONu, protoze ho budu potrebovat pri polohovani
                  jsonSerNums.O[i].S['SerNum_ID'] := mStoreBatch_ID;
                end;
              end
              else
              begin
                mDocRowBatch.SetFieldValueAsString('StoreBatch_ID', jsonSerNums.O[i].S['SerNum_ID']);
              end;
              mDocRowBatch.SetFieldValueAsString('QUnit', mSDRow.GetFieldValueAsString('QUnit'));
              mDocRowBatch.SetFieldValueAsFloat('UnitQuantity', 1);
            end;
          end;

          dtJSONRows.Next;
        end;
      end;

      // ulozim hodnotu z dialogu
      SaveDialogValues(mSD);


      // budeme ukladat jenom pokud jsou nejake radky
      if mSD.NeedSave and (mSDRows.Count > 0) then
      begin
        //if ABRA then
          mSD.Save;
        afterSaveHook(Self.ObjectSpace, mModule, mUser_Id, mSD, 1, json, dtJSONRows);

        //ChangeStatus(mSD, STAV_VYRIZENO(DOC_PRI, mModule), ROLE_VYSKLADNENO(DOC_PRI, mModule));

        // vytvorime polohovak
        if ACreateLSD and (dtDocumentQuantity.RecordCount > 0) then
          if CreateLogStoreDocument(Self.ObjectSpace, mModule, mDocType, mUser_Id, '', mSD, json, dtJSONRows, dtDocumentQuantity) then
            mLSD_ID := REST_Create_LogStoreDocument(mOS, mSD, '',
              mLogStoreDocumentClass,
              GetDocQueueForDocument(Self.ObjectSpace, mModule, mLogStoreDocumentDocType, mUser_ID, mLogStoreDocument_DocQueue_ID, mDocType, mSD),
              mLogStoreDocument_StoreGateway_ID, dtDocumentQuantity, mUser_Id,
              False, gLog);
      end;
    finally
      mDIM.Free;
      if mSDFree then
        mSD.Free;
    end;
  end;

begin
  if (slPath.Count = 2) then
  begin
    mDocType := slPath.Strings[1];
  end else
  begin
    ErrREST(ARequest, AResponse, HTTP_SC_BadRequest, getString('wrong_parameters_count'));
    exit;
  end;

  mOS := Self.ObjectSpace;

  mUser_ID := getHeaderValue(ARequest, 'UserID');
  mModule := getHeaderValue(ARequest, 'ModuleCode');

  LogWriteSectionStart(mModule);

  fillClassAndIdVariables;

  json := TJSONSuperObject.ParseString(GetStringFromBytes(ARequest.Content.Content, TEncoding.UTF8), True);
  dtJSONRows := TMemTable.Create(nil);
  dtDocumentQuantity := TMemTable.Create(nil);
  mProcessedBatches := TStringList.Create;
  try
    mRequestID := REST_getJSONStr(json, 'saveRequestID');
    // pred transakci overime, jestli uz tento request nebezi nebo neni dokonce dokonceny. Pokud ne, tak ho zalozime.
    case Request_Start(mOS, mRequestID, mModule) of
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
      mTemporaryStorageID := REST_getJSONInt(json, 'tempID');

      // dataset, do ktereho si preplnime polozky z JSONu
      DataSet_CreataHeader(dtJSONRows, 'jsonIndex=I,StoreDocument_ID=S10,StoreDocument2_ID=S10,StoreDocument2Provide_ID=S10,StoreDocument2ProvideRow_ID=S10,' +
        'DocRowBatch_ID=S10,LogStoreDocument2_ID=S10,StoreFrom_ID=S10,StoreTo_ID=S10,StoreCard_ID=S10,StorePositionFrom_ID=S10,IsDamaged=B,' +
        'StoreBatch_ID=S10,StorePositionTo_ID=S10,Processed=B,UnitQuantity=F,UnitRate=F,UnitCode=S10,Division_ID=S10,WasSelectedByBarcode=B,' +
        'IsNew=B,AccJobOrder_ID=S10,PRFContainerMater_ID=S10,BusProject_ID=S10,BusOrder_ID=S10,BusTransaction_ID=S10,EnterStoreBatchExpirationDate=B,' +
        'StoreBatchExpirationDate=S16,IsNotConfirmed=B');
      dtJSONRows.AddIndex('ByJsonIndex', 'jsonIndex', [ixUnique]);
      dtJSONRows.AddIndex('ByStoreDocument2_ID', 'StoreDocument_ID;StoreDocument2_ID;jsonIndex', [ixUnique]);
      dtJSONRows.AddIndex('BySD2_IDBatch_ID', 'StoreDocument_ID;StoreDocument2_ID;StoreBatch_ID;jsonIndex', [ixUnique]);
      dtJSONRows.IndexName := 'ByJsonIndex';
      dtJSONRows.Open;
      REST_JsonToDataSet(json.A['rows'], dtJSONRows);

      // dataset pro funkci Create_LogStoreDocument
      DataSet_CreataHeader(dtDocumentQuantity, 'Store_ID=S10,StoreCard_ID=S10,StoreBatch_ID=S10,StorePosition_ID=S10,Quantity=F');
      dtDocumentQuantity.AddIndex('I0', 'Store_ID;StoreCard_ID;StoreBatch_ID;StorePosition_ID', [ixUnique]);
      dtDocumentQuantity.IndexName:= 'I0';
      dtDocumentQuantity.Open;

      //*******************************************************************************************************************
      //********************************************* potvrzene ***********************************************************
      //*******************************************************************************************************************
      // prijemky budou vznikat z OBV - zaciname potvrzenymi radky
      CreateNewDocument(True, True, True, False, False);

      //*******************************************************************************************************************
      //********************************************* poskozene ***********************************************************
      //*******************************************************************************************************************
      CreateNewDocument(False, False, True, True, False, Store_ID_Damaged);

      //*******************************************************************************************************************
      //********************************************* nepotvrzene *********************************************************
      //*******************************************************************************************************************
      CreateNewDocument(False, False, True, False, True, Store_ID_NotConfirmed);

      //*******************************************************************************************************************
      //********************************************* zbytek **************************************************************
      //*******************************************************************************************************************
      // na nedodane zbozi se prijemka nevytvari
      //CreateNewDocument(True, False, False, False, False);


      // prepnu objednavku
      // nechceme pracovat se stavy
      {mIO := mOS.CreateObject(Class_IssuedOrder);
      try
        mIO.Load(REST_getJSONStr(json, 'ID'), nil);
        ChangeStatusByRule(mIO, PRECHOD_UKONCENI(DOC_IssuedOrder, mModule), ROLE_VYSKLADNENO(DOC_IssuedOrder, mModule));
      finally
        mIO.Free;
      end;}

      // vymaz z TemporaryStorage jeste v transakci
      TemporaryStorage_Delete(mOS, mTemporaryStorageID);

      Request_Finish(mOS, mRequestID);

      mOS.Commit;

      HTTPResponse(AResponse, HTTP_SC_OK, ContentType_JSON, PlainResponse(''));
    except
      mOS.RollBack;
      ErrREST(ARequest, AResponse, HTTP_SC_InternalServerError, getString('error_saving') + ExceptionMessage);
      Request_Cancel(mOS, mRequestID);
      LogWriteSectionEnd;
      exit;
    end;
  finally
    json.Free;
    mProcessedBatches.Free;
    dtJSONRows.Free;
    dtDocumentQuantity.Free;
  end;
  LogWriteSectionEnd;

  // polohovaky potvrdime az mimo hlavni transakci
  ConfirmLSD(mOS, mLogStoreDocumentClass, mLSD_ID, mModule, glog);
end;

begin
end.