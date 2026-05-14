(*uses
  'ZalohaVydana.U_Func',
  'Balikobot.U_Balikobot',
  'Const.U_Rolls',
  'Const.U_Const',
  'ExpL_Fakturace.U_Func',
  'REST_SkladTerm.U_Func',
  'REST_SkladTerm.U_FuncJSON',
  //'REST_SkladTerm.U_LogStoreDocument',
  'REST_SkladTerm.U_Requests',
  'REST_SkladTerm.U_StoreCard',
  'REST_SkladTerm.U_TemporaryStorage',
  'REST_SkladTerm_Special.U_Const',
  'REST_SkladTerm_Special.U_StandardHooks',
  'StandardUnits.U_DataSet',
  'StandardUnits.U_GetId',
  'StandardUnits.U_Relation';

const
  // Zpusoby dopravy
  cBaliky      = '00000P1000,1010000101,2010000101,1020000101,1030000101';
  cPalety      = '1000000101';
  cOsobniOdber = '00000O1000, 00000V1000, 1050000101';
  cZavozy      = '';

  // typy zasilek
  cTypBalik      = '30Z1000101';
  cTypPaleta     = '20Z1000101';
  cTypEURPaleta  = '10Z1000101';

  // zpusoby platby
  cDobirka = '4000000101';

  // odesilatel posty
  cOdesilatel_ID = '1000000101';

  // artikly palet
  cEURPaleta_ID   = 'HMT0000101';
  cPaleta_ID      = '1171000101';
  cPaletySklad_ID = '2100000101';
  cPaletyPozice_ID = '1020000101';

  // stavy a prechody
  cStavVYDKBaleni     = 'XWQER00101';
  cStavVYDBaleno      = 'WWVER00101';
  cStavVYDZabaleno    = 'VWWER00101';
  cStavPRVKBaleni     = 'WWYER00101';
  cStavPRVBaleno      = 'VW7FR00101';
  cStavPRVZabaleno    = 'ZWYER00101';

  cPrechodVYDBaleno   = 'CT40000101'; // K Baleni -> Baleno
  cPrechodVYDZruseno  = 'ET40000101'; // Baleno -> K Baleni
  cPrechodVYDZabaleno = 'CT50000101'; // Baleno -> Zabaleno
  cPrechodVYDVyrizeno = 'DT50000101'; // Zabaleno -> Vyrizeno
  cPrechodVYDVyrizeno2 = 'DT40000101';// Baleno -> Vyrizeno

  cPrechodPRVBaleno   = 'DTP0000101'; // K Baleni -> Baleno
  cPrechodPRVZruseno  = 'ETP0000101'; // Baleno -> K Baleni
  cPrechodPRVZabaleno = 'FTP0000101'; // Baleno -> Zabaleno
  cPrechodPRVVyrizeno = 'GTP0000101'; // Zabaleno -> Vyrizeno
  cPrechodPRVVyrizeno2 = 'HTP0000101';// Baleno -> Vyrizeno

  // exp. listy
  cStavBaleno         = 'XWSER00101';
  cStavZabaleno       = '2XRER00101';
  cStavVyrizeno       = 'WW0FR00101';

procedure getPersonalDelivery(Self: TNxWebServicesHelper; ARequest: TNxHTTPRequest;
  AResponse: TNxHTTPResponse; slPath: TStringList);
var
  mSql, mBarcode: String;
  dtHeader: TMemTable;
  json: TJSONSuperObject;
begin
  json := nil;

  if (slPath.Count = 2) then
  begin
    mBarcode := slPath.Strings[1];
  end else
  begin
    ErrREST(ARequest, AResponse, HTTP_SC_BadRequest, getString('wrong_parameters_count'));
    exit;
  end;

  try
    mSql := 'select ' +
      '  SD.ID as "ID", ' +
      '  DQ.Code' + CONCAT_STR + QuotedStr('-') + CONCAT_STR + 'cast(SD.OrdNumber as varchar(6))' +
         CONCAT_STR + QuotedStr('/') + CONCAT_STR + 'P.Code as "DisplayName", ' +
      '  SD.Description as "Description", ' +
      '  F.Name as "FirmName" ' +
      'from ShippingLists SD ' +
      'join Firms F on F.ID = SD.Firm_ID ' +
      'join DocQueues DQ on DQ.ID = SD.DocQueue_ID ' +
      'join Periods P on P.ID = SD.Period_ID ' +
      'where ' + nxCrLf +
      '  SD.Status_ID = ' + QuotedStr(cStavZabaleno) + nxCrLf +
      '  and SD.ID = ' + QuotedStr(mBarcode);

    dtHeader := TMemTable.Create(nil);
    try
      Self.ObjectSpace.SQLSelect2(mSql, dtHeader);

      json := REST_jsonCreate_FromDataSetRow(dtHeader, nil, nil);

      HTTPResponse(AResponse, HTTP_SC_OK, ContentType_JSON, json.AsJson(false, true));
    finally
      dtHeader.Free;
      if Assigned(json) then
        json.Free;
    end;
  except
    //HTTPResponse(AResponse, HTTP_SC_ExpectationFailed, ContentType_JSON, PlainResponse(ExceptionMessage));
    ErrREST(ARequest, AResponse, HTTP_SC_ExpectationFailed, ExceptionMessage);
  end;
end;

procedure putPersonalDelivery(Self: TNxWebServicesHelper; ARequest: TNxHTTPRequest;
  AResponse: TNxHTTPResponse; slPath: TStringList);
var
  mUser_Id, mSql, mBarcode, mModule: String;
  mSD: TNxCustomBusinessObject;
begin
  if (slPath.Count = 2) then
  begin
    mBarcode := slPath.Strings[1];
  end else
  begin
    ErrREST(ARequest, AResponse, HTTP_SC_BadRequest, getString('wrong_parameters_count'));
    exit;
  end;

  mUser_Id := getHeaderValue(ARequest, 'UserID');
  mModule := getHeaderValue(ARequest,'ModuleCode');

  Self.ObjectSpace.StartTransaction(taReadCommited);
  try
    mSD := Self.ObjectSpace.CreateObject(Class_ShippingList);
    try
      mSD.Load(mBarcode, nil);

      // prepnu EXL
      if mSD.GetFieldValueAsString('Status_ID') <> cStavZabaleno then
        RaiseException('Exp. list ' + mSD.GetFieldValueAsString('DisplayName') + ' není ve stavu Zabaleno');

      mSD.ChangeStatus(cStavVyrizeno, ROLE_VYSKLADNENO(DOC_EXPLIST, mModule));

      // prepnu vydejky
      changeStoreDocumentsStatus(Self.ObjectSpace, mBarcode, cStavVYDZabaleno, cStavPRVZabaleno, cPrechodVYDVyrizeno, cPrechodPRVVyrizeno, mUser_Id, '');
    finally
      mSD.Free;
    end;

    Self.ObjectSpace.Commit;

    HTTPResponse(AResponse, HTTP_SC_OK, ContentType_JSON, PlainResponse(''));
  except
    Self.ObjectSpace.RollBack;
    HTTPResponse(AResponse, HTTP_SC_OK, ContentType_JSON, PlainResponse(ExceptionMessage));
  end;

end;

procedure listShippingListsDocQueue(Self: TNxWebServicesHelper; ARequest: TNxHTTPRequest;
  AResponse: TNxHTTPResponse; slPath: TStringList);
var
  mDocType, mModuleName: String;
  dtRows: TMemTable;
  mSql, mSearchStr: String;
  json: TJSONSuperObject;
  i: Integer;
begin
  json := nil;
  mSearchStr := '';
  if ((slPath.Count >= 2) and (slPath.Count <=3)) then
  begin
    mDocType := slPath.Strings[1]; //ocekavam typ dokladu
    if slPath.Count = 3 then
      mSearchStr := slPath.Strings[2]; //ocekavam retezec hledani
  end else
  begin
    ErrREST(ARequest, AResponse, HTTP_SC_BadRequest, getString('wrong_parameters_count'));
    exit;
  end;

  mModuleName := getHeaderValue(ARequest, 'ModuleCode');

  try
    dtRows := TMemTable.Create(nil);
    try
      LogWriteSectionStart('ShippingListDocQueue ' + mDocType);

      mSql := '';

      mSql := mSql + 'select ' +
      '   SD.ID as "ID", ' +
      '   DQ.Code' + CONCAT_STR + QuotedStr('-') + CONCAT_STR + 'cast(SD.OrdNumber as varchar(6))' +
        CONCAT_STR + QuotedStr('/') + CONCAT_STR + 'P.Code as "DisplayName", ' +
      //' ' + FUNCTION_PREFIX + 'ib_DateToString(SD.DocDate$DATE, ''dd.mm.yyyy'') as "DocDate", ' +
      '   SD.DocDate$DATE as "DocDate$DATE", ' +
      '   (select count(SD2.ID) from ShippingLists2 SD2 where SD2.Parent_ID = SD.ID ) as "ItemCount", ' +
      '   ' + listDocQueue_Field_Description(Self.ObjectSpace, mModuleName) + ' as "Description", ' +
      '   ' + listDocQueue_Field_FirmName(Self.ObjectSpace) + ' as "FirmName", ' +
      '   ' + listDocQueue_AuxNonVisibleFields(Self.ObjectSpace, mModuleName) + nxCrLf +
      ' from ShippingLists SD ' +
      ' join Firms F on F.ID = SD.Firm_ID ' +
      ' join DocQueues DQ on DQ.ID = SD.DocQueue_ID ' +
      ' join Periods P on P.ID = SD.Period_ID ' +
      ' ' + listDocQueue_Join(Self.ObjectSpace, mModuleName, mDocType) +
      ' where ' +
      '   SD.Status_ID in (''' + replacestr(STAV_K_VYSKLADNENI(mDocType, mModuleName), ',', ''',''') + ''')';
      // pripadne hledani
      if trim(mSearchStr) <> '' then
        mSql := mSql + listDocQueue_Search(Self.ObjectSpace, mDocType, mSearchStr, mModuleName);

      mSql := 'select * from ( ' + mSql + ') q ';
      mSql := mSql + listDocQueue_OrderBy(Self.ObjectSpace, mModuleName);

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

      HTTPResponse(AResponse, HTTP_SC_OK, ContentType_JSON, json.AsJson(False, True));
    finally
      dtRows.Free;
      if Assigned(json) then
        json.Free;
    end;
  except
    HTTPResponse(AResponse, HTTP_SC_OK, ContentType_JSON, PlainResponse(ExceptionMessage));
  end;
end;

procedure putShippingListsQueueDocDetailCancelPicking(Self: TNxWebServicesHelper; ARequest: TNxHTTPRequest;
  AResponse: TNxHTTPResponse; slPath: TStringList);
var
  mSql, mUser_Id, mDocType, mDoc_ID, mModule: string;
  mBO: TNxCustomBusinessObject;
  mInv: integer; // 0 - neni inventarizace, 1 - dle DIP, 2 - volna
  mTemporaryStorageID: Integer;
begin
  if (slPath.Count = 3) then
  begin
    mDoc_ID := slPath.Strings[1]; //ocekavam ID skladoveho dokladu
    mTemporaryStorageID := StrToIntDef(slPath.Strings[2], 0); //ocekavam ID v TemporaryStorage
  end else
  begin
    ErrREST(ARequest, AResponse, HTTP_SC_BadRequest, getString('wrong_parameters_count'));
    exit;
  end;

  mDocType := DOC_EXPLIST;

  LogWriteSectionStart('putShippingListsQueueDocDetailCancelPicking');

  mUser_Id := getHeaderValue(ARequest, 'UserID');
  mModule := getHeaderValue(ARequest,'ModuleCode');

  Self.ObjectSpace.StartTransaction(taReadCommited);
  try
    mBO := Self.ObjectSpace.CreateObject(Class_ShippingList);
    try
      mBO.ExplicitTransaction := True;
      mBO.Load(mDoc_ID, nil);

      if mBO.GetFieldValueAsString('Status_ID') <> STAV_VYSKLADNOVANO(mDocType, mModule) then
        RaiseException(getString('document_not_in_to_dispatch_status'));

      mBO.ChangeStatusBySwitchRule(PRECHOD_PRERUSENI(mDocType, mModule));

      changeStoreDocumentsStatus(Self.ObjectSpace, mDoc_ID, cStavVYDBaleno, cStavPRVBaleno, cPrechodVYDZruseno, cPrechodPRVZruseno, mUser_Id);

      TemporaryStorage_Delete(Self.ObjectSpace, mTemporaryStorageID);

      //HTTPResponse(AResponse, HTTP_SC_OK, ContentType_JSON, PlainResponse(''));

      //os.Commit;
    finally
      mBO.Free;
    end;

    HTTPResponse(AResponse, HTTP_SC_OK, ContentType_JSON, PlainResponse(''));
    Self.ObjectSpace.Commit;
  except
    Self.ObjectSpace.RollBack;
    HTTPResponse(AResponse, HTTP_SC_ExpectationFailed, ContentType_JSON, Format(getString('error_canceling_issuance'), [ExceptionMessage]));
  end;

  LogWriteSectionEnd;
end;

procedure putShippingListsQueueDocDetailStartPicking(Self: TNxWebServicesHelper; ARequest: TNxHTTPRequest;
  AResponse: TNxHTTPResponse; slPath: TStringList);
var
  mSql, mUser_Id, mDocType, mDoc_ID, mModuleName, mModule, mAuxField,
    mChangeableFields, mWhere, mBoD: string;
  mBO, mSD, mRow: TNxCustomBusinessObject;
  json: TJSONSuperObject;
  //mRows: TNxCustomBusinessMonikerCollection;
  mTransportationType, tempId: Integer;
  dtHeader: TMemTable;
  dtRows: TMemTable;
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

  mUser_Id := getHeaderValue(ARequest, 'UserID');
  mModule := getHeaderValue(ARequest,'ModuleCode');

  LogWriteSectionStart(mModule);

  Self.ObjectSpace.StartTransaction(taReadCommited);
  try
    dtHeader := TMemTable.Create(nil);
    dtRows := TMemTable.Create(nil);
    mSL := TStringList.Create;
    mBO := Self.ObjectSpace.CreateObject(Class_ShippingList);
    mSD := Self.ObjectSpace.CreateObject(Class_BillOfDelivery);
    try
      mDocType := DOC_EXPLIST;

      mBO.ExplicitTransaction := True;
      mBO.Load(mDoc_ID, nil);

      if pos(mBO.GetFieldValueAsString('Status_ID'), STAV_K_VYSKLADNENI(mDocType, mModule)) <= 0 then
        RaiseException(getString('issuance_another_user'));

      mBO.ChangeStatus(STAV_VYSKLADNOVANO(mDocType, mModule), ROLE_VYSKLADNENO(mDocType, mModule), mUser_Id);

      mBoD := '';
      changeStoreDocumentsStatus(Self.ObjectSpace, mDoc_ID, cStavVYDKBaleni, cStavPRVKBaleni, cPrechodVYDBaleno, cPrechodPRVBaleno, mUser_Id, mBoD);

      // zpusob dopravy
      //mTransportationType =
      if pos(copy(mBoD, 12, 10), cBaliky) > 0 then
        mTransportationType := 0
      else if pos(copy(mBoD, 12, 10), cPalety) > 0 then
        mTransportationType := 1
      else if pos(copy(mBoD, 12, 10), cOsobniOdber) > 0 then
        mTransportationType := 2
      else if pos(copy(mBoD, 12, 10), cZavozy) > 0 then
        mTransportationType := 3
      else
        mTransportationType := -1;

      mAuxField := StoreDocumentAuxTextField(mModule, mAuxReadOnly);
      mChangeableFields := putQueueDocDetailStartPicking_ChangeableFields(mModule);

      mSql :=
        'select ' +
        '  SD.ID as "ID", ' +
        '  DQ.Code' + CONCAT_STR + QuotedStr('-') + CONCAT_STR + 'cast(SD.OrdNumber as varchar(6))' +
           CONCAT_STR + QuotedStr('/') + CONCAT_STR + 'P.Code as "DisplayName", ' +
        '  SD.Description as "Description", ' +
        '  F.Name as "FirmName", ';
      if mAuxField <> '' then
      begin
        mSql := mSql +
          '  ' + mAuxField + ' as "AuxText", ' +
          '  ' + QuotedStr(NxBoolToString(mAuxReadOnly)) + ' as "AuxReadOnly", ';
      end;
      if mChangeableFields <> '' then
      begin
        mSql := mSql +
          mChangeableFields + ' as "ChangeableFields", ';
      end;
      mSql := mSql +
        putQueueDocDetailStartPicking_CanAddItems(Self.ObjectSpace, mModule, mDocType) + ' as "CanAddItems", ' + nxCrLf +
        putQueueDocDetailStartPicking_CanEnterBiggerQuantity(Self.ObjectSpace, mModule) + ' as "CanEnterBiggerQuantity", ' + nxCrLf +
        QuotedStr(NxBoolToString(askForNewDocumentCreation(mModule))) + ' as "AskForNewDocumentCreation", ' + nxCrLf +
        QuotedStr(NxBoolToString(putQueueDocDetailStartPicking_isEditingProcessedItemAllowed(Self.ObjectSpace, mModule))) + ' as "IsEditingProcessedItemAllowed", ' + nxCrLf +
        QuotedStr(NxBoolToString(putQueueDocDetailStartPicking_createTransferIn(mModule))) + ' as "CreateTransferIn", ' + nxCrLf +
        QuotedStr(putQueueDocDetailStartPicking_defaultPosition()) + ' as "DefaultPosition", ' + nxCrLf +
        QuotedStr(NxBoolToString(putQueueDocDetailStartPicking_showBarecodeField(mModule))) + ' as "ShowBarecodeField", ' + nxCrLf +
        QuotedStr(NxBoolToString(specialBarecodeHandling(mModule))) + ' as "SpecialBarecodeHandling", ' + nxCrLf;

      // zda se ma pro osobni odber zobrazit dialog s upozornenim o osobnim odberu
      if mTransportationType = 2 then
        mSql := mSql + '''true'' as "AuxBoolean", ' + nxCrLf;

      mSql := mSql + IntToStr(mTransportationType) + ' as "AuxText2" ' + nxCrLf +
        'from ShippingLists SD ' + nxCrLf +
        'join Firms F on F.ID = SD.Firm_ID ' + nxCrLf +
        'join DocQueues DQ on DQ.ID = SD.DocQueue_ID ' + nxCrLf +
        'join Periods P on P.ID = SD.Period_ID ' + nxCrLf +
        'where SD.ID = ' + QuotedStr(mDoc_ID);

      Self.ObjectSpace.SQLSelect2(mSql, dtHeader);

      // TODO - predavat si ze ctecky info, jestli se maji vrace polozky. Napr. prijem dle dokladu v Dobrovskem polozky nechce.
      if dtHeader.Active then
      begin
        dtHeader.First;

        mWhere := 'SL2.Parent_ID = ' + QuotedStr(mDoc_ID) +
          '  and SD2.RowType = 3 and SC.IsStockType = ''A'' ';
        mSql := getShippingListsRowsSql(Self.ObjectSpace, mModule, mUser_Id, mDocType, mWhere);
        Self.ObjectSpace.SQLSelect2(mSql, dtRows);
        if dtRows.Active then
        begin
          dtRows.AddIndex('id', XX_Parent_ID+';OrderForIndex', [ixPrimary]);
          dtRows.IndexName:= 'id';
          mSL.AddObject('rows=', dtRows);
        end;
      end;

      json := REST_jsonCreate_FromDataSetRow(dtHeader, nil, mSL);

      // rovnou ulozime do TemporaryStorage
      tempId := TemporaryStorage_Create(Self.ObjectSpace, json.AsJson(false, true), mModule, mUser_Id, mDoc_ID);
      json.I['tempID'] := tempId;

      HTTPResponse(AResponse, HTTP_SC_OK, ContentType_JSON, json.AsJson(false, true));

      Self.ObjectSpace.Commit;
    finally
      mBO.Free;
      mSD.Free;
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

function getShippingListsRowsSql(AOS: TNxCustomObjectSpace; AModule, AUser_Id, ADocType, AWhere: String): String;
begin
  Result := 'select ' +
    '  SL2.Parent_ID as "XX_Parent_ID", ' + nxCrLf +
    '  SL2.PosIndex as "PosIndex", ' + nxCrLf +
    '  ' + putQueueDocDetailStartPicking_RowsOrderBy(AOS, AModule) + ' as "OrderForIndex", ' + nxCrLf +
    '  SD2.ID as "StoreDocument2_ID", ' + nxCrLf +
    '  coalesce(SD2.Provide_ID, '''') as "StoreDocument2Provide_ID", ' + nxCrLf +
    '  coalesce(SD2.ProvideRow_ID, '''') as "StoreDocument2ProvideRow_ID", ' + nxCrLf +
    '  coalesce(DRB.ID, '''') as "DocRowBatch_ID", ' + nxCrLf +
    '  coalesce(LSD2.ID, '''') as "LogStoreDocument2_ID", ' + nxCrLf +
    '  S.ID as "StoreFrom_ID", ' + nxCrLf +
    '  S.Code as "StoreFromCode", ' + nxCrLf +
    '  S.IsLogistic as "StoreFromIsLogistic$BOOL", ' + nxCrLf +
    '  SC.ID as "StoreCard_ID", ' + nxCrLf +
    '  SC.' + cStoreCardInfoCodeField + ' as "StoreCardCode", ' + nxCrLf +
    '  SC.' + cStoreCardInfoNameField + ' as "StoreCardName", ' + nxCrLf +
    '  '';''' + CONCAT_STR + getUnitsSql + CONCAT_STR + ''';'' as "StoreCardUnits", ' + nxCrLf +
    '  '';''' + CONCAT_STR + putQueueDocDetailStartPicking_StoreCardBarcodeField(AOS, AModule) + CONCAT_STR + ''';'' as "StoreCardBarcode", ' + nxCrLf +
    '  ' + putQueueDocDetailStartPicking_StoreCardAuxInfoForSerNumField(AOS) + ' as "StoreCardAuxInfoForSerNum$BOOL", ' + nxCrLf +
    '  case ' + nxCrLf +
    '    when (SC.SerialNumberStructure  <> '''') or (CS.CodeStructure is not null and CS.CodeStructure <> '''') ' + nxCrLf +
    '    then ''A'' ' + nxCrLf +
    '    else ''N'' ' + nxCrLf +
    '  end as "HasStoreBatchStructure$BOOL", ' + nxCrLf +
    '  ' + putQueueDocDetailStartPicking_StoreCardCategory(AOS) + ' as "StoreCardCategory", ' + nxCrLf +
    '  coalesce(LSD2.Quantity, DRB.Quantity, SD2.Quantity) / SD2.UnitRate as "UnitQuantity", ' + nxCrLf +
    '  SD2.UnitRate as "UnitRate", ' + nxCrLf +
    '  SD2.QUnit as "UnitCode", ' + nxCrLf +
    '  SD2.Division_ID as "Division_ID", ' + nxCrLf +
    '  SD2.BusProject_ID as "BusProject_ID", ' + nxCrLf +
    '  SD2.BusOrder_ID as "BusOrder_ID", ' + nxCrLf +
    '  SD2.BusTransaction_ID as "BusTransaction_ID", ' + nxCrLf +
    '  '''' as "StorePositionTo_ID", ' + nxCrLf +
    '  '''' as "StorePositionToCode", ' + nxCrLf +
    '  coalesce(LSP.ID, '''') as "StorePositionFrom_ID", ' + nxCrLf +
    '  coalesce(LSP.Code, '''') as "StorePositionFromCode", ' + nxCrLf +
    '  coalesce(SB.ID, '''') as "StoreBatch_ID", ' + nxCrLf +
    '  ' + putQueueDocDetailStartPicking_StoreBatchField(AOS, AModule, ADocType) + ' as "StoreBatchName", ' + nxCrLf +
    '  coalesce(LSD2.ID, '''') as "LogStoreDocument2_ID", ' + nxCrLf +
    '  ' + putQueueDocDetailStartPicking_rowAuxText(AModule) + ' as "AuxText",' + nxCrLf +
    '  ' + putQueueDocDetailStartPicking_rowAuxText2(AModule) + ' as "AuxText2",' + nxCrLf +
    '  coalesce(SD2.AccJobOrder_ID, '''') as "AccJobOrder_ID", ' + nxCrLf +
    '  coalesce(SD2.PRFContainerMater_ID, '''') as "PRFContainerMater_ID", ' + nxCrLf +
    '  coalesce(S2.ID, '''') as "StoreTo_ID", ' + nxCrLf +
    '  coalesce(S2.Code, '''') as "StoreToCode", ' + nxCrLf +
    '  coalesce(S2.IsLogistic, ''N'') as "StoreToIsLogistic$BOOL" ' + nxCrLf +
    'from ShippingLists2 SL2 ' + nxCrLf +
    'join StoreDocuments2 SD2 on SD2.ID = SL2.ProvideRow_ID ' + nxCrLf +
    'join StoreDocuments SD on SD.id = SD2.Parent_ID ' + nxCrLf +
    'join Stores S on S.ID = SD2.Store_ID ' + nxCrLf +
    'left join Stores S2 on S2.ID = SD.PlannedReverseDocumentStore_ID ' + nxCrLf +
    'join StoreCards SC on SC.ID = SD2.StoreCard_ID ' + nxCrLf +
    'left join DocRowBatches DRB on DRB.Parent_ID = SD2.ID ' + nxCrLf +
    'left join StoreBatches SB on SB.ID = DRB.StoreBatch_ID ' + nxCrLf +
    'left join LogStoreDocuments2 LSD2 on LSD2.StoreDocRow_ID = SD2.ID and coalesce(LSD2.StoreBatch_ID, '''') = coalesce(DRB.StoreBatch_ID, '''') ' + nxCrLf +
    'left join LogStorePositions LSP on LSP.ID = ' + putQueueDocDetailStartPicking_StorePositionFromJoinField(AOS, ADocType) + ' ' + nxCrLf +
    'left join CodeStructures CS on CS.ID = SC.StoreBatchStructure_ID ' + nxCrLf +
    ' ' + putQueueDocDetailStartPicking_Join(AOS, AModule, AUser_Id) + ' ' + nxCrLf +
    'where ' + AWhere + ' ' + nxCrLf +
    'order by SD2.PosIndex ';
end;

procedure putObalyShippingListsQueueDocDetailStopPicking(Self: TNxWebServicesHelper; ARequest: TNxHTTPRequest;
  AResponse: TNxHTTPResponse; slPath: TStringList);
var
  mSql, mUser_Id, mDocType, mDoc_ID, mBoD_ID, mDocumentType: string;
  mSL, mBoD, mTT, mBoDRow, mDocRowBatch, mStoreBatch: TNxCustomBusinessObject;
  mPDMIssuedDoc: TNxHeaderBusinessObject;
  json, auxJson: TJSONSuperObject;
  mBoDRows: TNxCustomBusinessMonikerCollection;
  i: Integer;
  slMsgId, mPackagesIDs: TStringList;
  dtJSONRows, dtDocumentQuantity: TMemTable;
  mDIM: TNxDocumentImportManager;
  mParams: TNxParameters;
  mTemporaryStorageID: Integer;
  mRequestID, mModule, mWasSelectedByBarcodeFieldName, mAuxField, mAuxFieldTextOld, mStoreField, mStorePositionField: String;
  mAllSelectedByBarcode, mAuxReadOnly: Boolean;

  procedure AddToPrintQueue;
  var
    mContext: TNxContext;
  begin
    mContext := NxCreateContext(Self.ObjectSpace);
    try
      PrintReportToPrinterByIDToQueue(mContext, mPDMIssuedDoc.OID, '', '', mPDMIssuedDoc.GetFieldValueAsString('X_LABEL_URL'), TISKARNA_STITKY_BALIK, User_ID_Automat, 1);
    finally
      mContext.Free;
    end;
  end;

  function createPDMIssuedDoc(APackagesCount: Integer; ADimensions: TJSONSuperObject; AOnlyWeight: Boolean; AVarSymbol: String;
    AInsuredValue, ACashOnDelivery:Double = -1; ACurrencyCode: String = ''; AInvoicesIDs: TStringList = nil): String;
  var
    mDoc: TNxCustomBusinessObject;
  begin
    mDoc := Self.ObjectSpace.CreateObject(Class_PDMIssuedDoc);
    mTT := Self.ObjectSpace.CreateObject(Class_TransportationType);
    try
      mTT.Load(copy(mBoD_ID, 12, 10), nil);

      mDoc.ExplicitTransaction := True;
      mDoc.New;
      mDoc.Prefill;

      mDoc.SetFieldValueAsString('Docqueue_ID', PDMIssuedDoc_DocQueue_ID);
      mDoc.SetFieldValueAsString('Firm_ID', mSL.GetFieldValueAsString('Firm_ID'));
      mDoc.SetFieldValueAsString('FirmOffice_ID', mSL.GetFieldValueAsString('FirmOffice_ID'));
      mDoc.SetFieldValueAsString('Person_ID', mSL.GetFieldValueAsString('Person_ID'));

      // adresa podle volby na EXL
      if  mSL.GetFieldValueAsInteger('DeliveryType') = 3 then
      begin
        mDoc.SetFieldValueAsString('TargetAddress_ID.Location', mSL.GetFieldValueAsString('DeliveryAddress_ID.Location'));
        mDoc.SetFieldValueAsString('TargetAddress_ID.Recipient', mSL.GetFieldValueAsString('DeliveryAddress_ID.Recipient'));
        mDoc.SetFieldValueAsString('TargetAddress_ID.City', mSL.GetFieldValueAsString('DeliveryAddress_ID.City'));
        mDoc.SetFieldValueAsString('TargetAddress_ID.Street', mSL.GetFieldValueAsString('DeliveryAddress_ID.Street'));
        mDoc.SetFieldValueAsString('TargetAddress_ID.ZIP', mSL.GetFieldValueAsString('DeliveryAddress_ID.ZIP'));
        mDoc.SetFieldValueAsString('TargetAddress_ID.PostCode', mSL.GetFieldValueAsString('DeliveryAddress_ID.PostCode'));
        mDoc.SetFieldValueAsString('TargetAddress_ID.Country', mSL.GetFieldValueAsString('DeliveryAddress_ID.Country'));
        mDoc.SetFieldValueAsString('TargetAddress_ID.PhoneNumber1', mSL.GetFieldValueAsString('DeliveryAddress_ID.PhoneNumber1'));
        mDoc.SetFieldValueAsString('TargetAddress_ID.PhoneNumber2', mSL.GetFieldValueAsString('DeliveryAddress_ID.PhoneNumber2'));
        mDoc.SetFieldValueAsString('TargetAddress_ID.FaxNumber', mSL.GetFieldValueAsString('DeliveryAddress_ID.FaxNumber'));
        mDoc.SetFieldValueAsString('TargetAddress_ID.EMail', mSL.GetFieldValueAsString('DeliveryAddress_ID.EMail'));
        mDoc.SetFieldValueAsString('TargetAddress_ID.Location', mSL.GetFieldValueAsString('DeliveryAddress_ID.Location'));
        mDoc.SetFieldValueAsString('TargetAddress_ID.CountryCode', mSL.GetFieldValueAsString('DeliveryAddress_ID.CountryCode'));
        mDoc.SetFieldValueAsString('TargetAddress_ID.X_FirmName', mSL.GetFieldValueAsString('DeliveryAddress_ID.X_FirmName'));
        mDoc.SetFieldValueAsString('TargetAddress_ID.X_LastName', mSL.GetFieldValueAsString('DeliveryAddress_ID.X_LastName'));
        mDoc.SetFieldValueAsString('TargetAddress_ID.X_FirstName', mSL.GetFieldValueAsString('DeliveryAddress_ID.X_FirstName'));
        //mDoc.SetFieldValueAsInteger('TargetAddressType', mSL.GetFieldValueAsInteger('DeliveryType'));
      end
      else if  mSL.GetFieldValueAsInteger('DeliveryType') in [1, 2] then
      begin
        mDoc.SetFieldValueAsString('TargetAddress_ID.Location', mSL.GetFieldValueAsString('DeliveryFirmOffice_ID.Address_ID.Location'));
        mDoc.SetFieldValueAsString('TargetAddress_ID.Recipient', mSL.GetFieldValueAsString('DeliveryFirmOffice_ID.Address_ID.Recipient'));
        mDoc.SetFieldValueAsString('TargetAddress_ID.City', mSL.GetFieldValueAsString('DeliveryFirmOffice_ID.Address_ID.City'));
        mDoc.SetFieldValueAsString('TargetAddress_ID.Street', mSL.GetFieldValueAsString('DeliveryFirmOffice_ID.Address_ID.Street'));
        mDoc.SetFieldValueAsString('TargetAddress_ID.ZIP', mSL.GetFieldValueAsString('DeliveryFirmOffice_ID.Address_ID.ZIP'));
        mDoc.SetFieldValueAsString('TargetAddress_ID.PostCode', mSL.GetFieldValueAsString('DeliveryFirmOffice_ID.Address_ID.PostCode'));
        mDoc.SetFieldValueAsString('TargetAddress_ID.Country', mSL.GetFieldValueAsString('DeliveryFirmOffice_ID.Address_ID.Country'));
        mDoc.SetFieldValueAsString('TargetAddress_ID.PhoneNumber1', mSL.GetFieldValueAsString('DeliveryFirmOffice_ID.Address_ID.PhoneNumber1'));
        mDoc.SetFieldValueAsString('TargetAddress_ID.PhoneNumber2', mSL.GetFieldValueAsString('DeliveryFirmOffice_ID.Address_ID.PhoneNumber2'));
        mDoc.SetFieldValueAsString('TargetAddress_ID.FaxNumber', mSL.GetFieldValueAsString('DeliveryFirmOffice_ID.Address_ID.FaxNumber'));
        mDoc.SetFieldValueAsString('TargetAddress_ID.EMail', mSL.GetFieldValueAsString('DeliveryFirmOffice_ID.Address_ID.EMail'));
        mDoc.SetFieldValueAsString('TargetAddress_ID.Location', mSL.GetFieldValueAsString('DeliveryFirmOffice_ID.Address_ID.Location'));
        mDoc.SetFieldValueAsString('TargetAddress_ID.CountryCode', mSL.GetFieldValueAsString('DeliveryFirmOffice_ID.Address_ID.CountryCode'));
        //mDoc.SetFieldValueAsInteger('TargetAddressType', mSL.GetFieldValueAsInteger('DeliveryType'));
      end else begin
        mDoc.SetFieldValueAsInteger('TargetAddressType', 1);
      end;

      // zadam osobu
      if not NxIsEmptyOID(mSL.GetFieldValueAsString('Person_ID')) then
      begin
        if (mSL.GetFieldValueAsString('Person_ID.LastName') <> '') and (mDoc.GetFieldValueAsString('TargetAddress_ID.Recipient') = '') then
          mDoc.SetFieldValueAsString('TargetAddress_ID.Recipient', copy(NxTrim(mSL.GetFieldValueAsString('Person_ID.Title') + ' ' +
            mSL.GetFieldValueAsString('Person_ID.FirstName') + ' ' + mSL.GetFieldValueAsString('Person_ID.LastName'), ' '), 1, 30));
      end;

      // vyplnim hodnoty ohledne baliku
      mDoc.SetFieldValueAsString('X_RealOrderID', mSL.DisplayName);
      mDoc.SetFieldValueAsString('Note',mSL.GetFieldValueAsString('X_NoteForPostProv'));
      mDoc.SetFieldValueAsInteger('X_OrderNumber', (i + 1));
      mDoc.SetFieldValueAsInteger('X_PiecesCountOne', APackagesCount);
      mDoc.SetFieldValueAsString('Sender_ID', cOdesilatel_ID);
      //mDoc.SetFieldValueAsString('VarSymbol', AVarSymbol);
      mDoc.SetFieldValueAsString('PostProvider_ID', mTT.GetFieldValueAsString('X_PostProvider_ID'));
      mDoc.SetFieldValueAsString('IssuedContent_ID', mTT.GetFieldValueAsString('X_IssuedContent_ID'));
      mDoc.SetFieldValueAsInteger('WeightUnit', 1);
      mDoc.SetFieldValueAsFloat('Postage', 1);

      if (Assigned(ADimensions)) and (ADimensions.DataType <> jtNull) and (ADimensions.DataType <> - 1) then
      begin
        mDoc.SetFieldValueAsFloat('Weight', ADimensions.D['Weight']);
        if not AOnlyWeight then
        begin
          mDoc.SetFieldValueAsInteger('X_Width', Ceil(ADimensions.D['Width']));
          mDoc.SetFieldValueAsInteger('X_Height', Ceil(ADimensions.D['Height']));
          mDoc.SetFieldValueAsInteger('X_Length', Ceil(ADimensions.D['Depth']))
        end;
      end;

      // cena zasilky
      if AInsuredValue > 0 then
      begin
        mDoc.SetFieldValueAsFloat('InsuredValue', AInsuredValue);
        mDoc.SetFieldValueAsString('X_MENA', ACurrencyCode);
      end;

      // Dobirka
      if ACashOnDelivery > 0 then
      begin
        mDoc.SetFieldValueAsFloat('CashOnDelivery', ACashOnDelivery);
        mDoc.SetFieldValueAsString('VarSymbol', AVarSymbol);
      end;

      mDoc.Save;

      // na konec ulozim vazby
      // vazba na expedicni list
      Relation_CreateAndSave(Self.ObjectSpace, Relation_getRelationNumber(rtDataDocument_ShippingList_StartNumber, Class_PDMIssuedDoc), mSL.OID, mDoc.OID);
      Relation_CreateAndSave(Self.ObjectSpace, rtShippingList_PDMIssuedDoc, mDoc.OID, mSL.OID);

      // vazba na faktury
      if Assigned(AInvoicesIDs) then
      begin
        for i := 0 to AInvoicesIDs.Count - 1 do
        begin
          //Relation_CreateAndSave(Self.ObjectSpace, rtIssuedInvoice_PDMIssuedDoc, IssuedInvoice_ID, PDMIssuedDoc.OID);
          Relation_CreateAndSave(Self.ObjectSpace, Relation_getRelationNumber(rtDataDocument_IssuedInvoice_StartNumber, Class_PDMIssuedDoc), AInvoicesIDs.Strings(i), mDoc.OID);
          Relation_CreateAndSave(Self.ObjectSpace, rtIssuedInvoice_PDMIssuedDoc, mDoc.OID, AInvoicesIDs.Strings(i));
        end;
      end;

      Result := mDoc.OID;
    finally
      mDoc.Free;
      mTT.Free;
    end;
  end;

  procedure createLogStorePositionOnEURPallet;
  var
    mLogStoreOutputRow: TNxCustomBusinessObject;
    mParams: TNxParameters;
    mDIM: TNxDocumentImportManager;
    mLogStoreOutput_ID, mClass: String;
    mLogStoreOutput: TNxLogStoreDocument;
    mLogStoreOutputRows: TNxCustomBusinessMonikerCollection;
  begin
    if mDocumentType = '21' then
      mClass := Class_BillOfDelivery
    else
      mClass := Class_OutgoingTransfer;

    mParams := TNxParameters.Create;
    mDIM := NXCreateDocumentImportManager(Self.ObjectSpace, mClass, Class_LogStoreOutput);
    try
      mDIM.SaveParams(mParams);
      mParams.GetOrCreateParam(dtString, 'DocQueue_ID').AsString := LogStoreOutput_DocQueue_ID;
      mParams.GetOrCreateParam(dtString, 'StoreGateway_ID').asString := LogStoreOutput_StoreGateway_ID;
      // automaticke polohovani mi pada
      //mParams.GetOrCreateParam(dtBoolean, 'AutoPrefillPosition').AsBoolean := True;
      mDIM.LoadParams(mParams);
      mDIM.AddInputDocument(mBoD.OID);
      //mDIM.SelectedHeader := mBoD;
      mDIM.Execute;
      mLogStoreOutput := TNxLogStoreDocument(mDIM.OutputDocument);
      mLogStoreOutput.ExplicitTransaction := True;
      mLogStoreOutput_ID := mLogStoreOutput.OID;

      // zapolohuju jenom radky s paletou
      mLogStoreOutputRows := mLogStoreOutput.GetLoadedCollectionMonikerForFieldCode(mLogStoreOutput.GetFieldCode('Rows'));
      for i := 0 to mLogStoreOutputRows.Count - 1 do
      begin
        mLogStoreOutputRow := mLogStoreOutputRows.BusinessObject[i];
        if mLogStoreOutputRow.GetFieldValueAsString('StoreCard_ID') = cEURPaleta_ID then
        begin
          mLogStoreOutputRow.SetFieldValueAsString('StorePosition_ID', cPaletyPozice_ID);
          mLogStoreOutputRow.SetFieldValueAsFloat('Quantity', mLogStoreOutputRow.GetFieldValueAsFloat('RestQuantity'));
        end
        else
          mLogStoreOutputRow.MarkForDelete;
      end;
      mLogStoreOutput.Save;
    finally
      mParams.free;
      mDIM.Free;
    end;

    // provedeni musim udelas zvlast
    mLogStoreOutput := TNxLogStoreDocument(Self.ObjectSpace.CreateObject(Class_LogStoreOutput));
    try
      mLogStoreOutput.Load(mLogStoreOutput_ID, nil);
      mLogStoreOutput.MakeExecuted;
    finally
      mLogStoreOutput.Free;
    end;
  end;

  procedure processPackages;
  var
    mSLList, mInvoicesIDs: TStringList;
    mII: TNxHeaderBusinessObject;
    mInsuredValue, mCashInDelivery: Double;
    mVarSymbol, mPackageID, mCurrencyCode: string;
    mTransportationType_ID, mPaymentType_ID: string;
    sql: string;
  begin
    mSLList := TStringList.Create();
    mInvoicesIDs := TStringList.Create();
    auxJson := TJSONSuperObject.ParseString(json.S['json'], True);
    mII := TNxHeaderBusinessObject(Self.ObjectSpace.CreateObject(Class_IssuedInvoice));
    try
      //zjistim si zpusob platby
      sql:=
        'select first 1 ro.PaymentType_ID, ro.TRANSPORTATIONTYPE_ID '+
        'from X_ISSUEDROWS(''E'', '''+mDoc_ID+''', null) a '+
        'join receivedorders ro on ro.ID=a.receivedorder_ID '+
        'group by ro.PaymentType_ID, ro.TRANSPORTATIONTYPE_ID';
      mPaymentType_ID:= SQLSelectStr(Self.ObjectSpace, sql);
      mTransportationType_ID:= NxTokenR(mPaymentType_ID, ',');

      mInsuredValue := 0;
      mCashInDelivery := 0;
      mCurrencyCode := '';
      mVarSymbol := '';

      if(mTransportationType_ID = TransportationType_ID_V1) and (mPaymentType_ID = PaymentType_ID_H1)then begin
        //nevytvarim FV, na Zavod a Hotove

      end else begin
        // vytvorim rucne faktury a udelam z nich soucet castek
        mSLList.Append(mDoc_ID);
        ExpL2Fav(nil, Self.ObjectSpace, mSLList, mInvoicesIDs, True, SlucovatFAV_Neslucovat, true);

        for i := 0 to mInvoicesIDs.Count - 1 do
        begin
          mII.Load(mInvoicesIDs.Strings(i), nil);
          ImportZaloh(mII);
          //mInsuredValue := mInsuredValue + mII.GetFieldValueAsFloat('Amount');
          mInsuredValue := mInsuredValue + mII.GetFieldValueAsFloat('AmountWithVATDeposit');
          mCurrencyCode := mII.GetFieldValueAsString('Currency_ID.Code');

          // pokud je zpusob platby dobirkou, tak chci pridat i tu
          if mII.GetFieldValueAsString('PaymentType_ID') = cDobirka then
          begin
            mCashInDelivery := mCashInDelivery + mII.GetFieldValueAsFloat('Amount');
            mVarSymbol := mII.GetFieldValueAsString('VarSymbol');
          end;
        end;
      end;

      // jeden balik = jeden doklad
      for i := 0 to auxJson.A['packages'].Length - 1 do
      begin
        mPackageID := createPDMIssuedDoc(auxJson.A['packages'].Length, auxJson.A['packages'].O[i], True, mVarSymbol, mInsuredValue, mCashInDelivery, mCurrencyCode, mInvoicesIDs);
        mPackagesIDs.Add(mPackageID);
      end;
    finally
      mSLList.Free;
      mII.Free;
      mInvoicesIDs.Free;
      auxJson.Free;
    end;

    // TODO tisk?
  end;

  procedure processPallets;
  var
    mSLList, mInvoicesIDs: TStringList;
    mII: TNxHeaderBusinessObject;
    mPackage: TNxCustomBusinessObject;
    mInsuredValue, mCashInDelivery: Double;
    mVarSymbol, mPackageID, mCurrencyCode: String;
    mPackageDataset: TMemTable;
    mTotalWeight: Double;
    mClass, mStoreDocument_ID: String;
    mTransportationType_ID, mPaymentType_ID: string;
    sql: string;
  begin

    if mDocumentType = '21' then
      mClass := Class_BillOfDelivery
    else
      mClass := Class_OutgoingTransfer;

    auxJson := TJSONSuperObject.ParseString(json.S['json'], True);
    mSLList := TStringList.Create;
    mInvoicesIDs := TStringList.Create;
    mBoD := Self.ObjectSpace.CreateObject(mClass);
    mII := TNxHeaderBusinessObject(Self.ObjectSpace.CreateObject(Class_IssuedInvoice));
    try
      mBoD.ExplicitTransaction := True;
      loadFirstStoreDocumentID(mDoc_ID, mBoD);

      mBoDRows := mBoD.GetLoadedCollectionMonikerForFieldCode(mBoD.GetFieldCode('Rows'));

      // pridam EUR palety
      if auxJson.A['eurPallets'].Length > 0 then
      begin
        mBoDRow := mBoDRows.AddNewObject;
        mBoDRow.Prefill;
        mBoDRow.SetFieldValueAsInteger('RowType', 3);
        mBoDRow.SetFieldValueAsString('Store_ID', cPaletySklad_ID);
        mBoDRow.SetFieldValueAsString('StoreCard_ID', cEURPaleta_ID);
        mBoDRow.SetFieldValueAsFloat('Quantity', auxJson.A['eurPallets'].Length);
        mBoDRow.SetFieldValueAsString('Division_ID', STREDISKO_HLAVNI);
      end;

      // pridam palety
      if auxJson.A['pallets'].Length > 0 then
      begin
        mBoDRow := mBoDRows.AddNewObject;
        mBoDRow.Prefill;
        mBoDRow.SetFieldValueAsInteger('RowType', 3);
        mBoDRow.SetFieldValueAsString('Store_ID', cPaletySklad_ID);
        mBoDRow.SetFieldValueAsString('StoreCard_ID', cPaleta_ID);
        mBoDRow.SetFieldValueAsFloat('Quantity', auxJson.A['pallets'].Length);
        mBoDRow.SetFieldValueAsString('Division_ID', STREDISKO_HLAVNI);
      end;

      mBoD.Save;

      // nove radky s EUR paletami zapolohuju
      if auxJson.A['eurPallets'].Length > 0 then
        createLogStorePositionOnEURPallet;

      //zjistim si zpusob platby
      sql:=
        'select first 1 ro.PaymentType_ID, ro.TRANSPORTATIONTYPE_ID '+
        'from X_ISSUEDROWS(''E'', '''+mDoc_ID+''', null) a '+
        'join receivedorders ro on ro.ID=a.receivedorder_ID '+
        'group by ro.PaymentType_ID, ro.TRANSPORTATIONTYPE_ID';
      mPaymentType_ID:= SQLSelectStr(Self.ObjectSpace, sql);
      mTransportationType_ID:= NxTokenR(mPaymentType_ID, ',');

      mInsuredValue := 0;
      mCashInDelivery := 0;
      mCurrencyCode := '';
      mVarSymbol := '';

      if(mTransportationType_ID = TransportationType_ID_V1) and (mPaymentType_ID = PaymentType_ID_H1)then begin
        //nevytvarim FV, na Zavod a Hotove

      end else begin
        // vytvorim rucne faktury a udelam z nich soucet castek
        mSLList.Append(mDoc_ID);
        ExpL2Fav(nil, Self.ObjectSpace, mSLList, mInvoicesIDs, True, SlucovatFAV_Neslucovat, true);

        for i := 0 to mInvoicesIDs.Count - 1 do
        begin
          mII.Load(mInvoicesIDs.Strings(i), nil);
          ImportZaloh(mII);
          //mInsuredValue := mInsuredValue + mII.GetFieldValueAsFloat('Amount');
          mInsuredValue := mInsuredValue + mII.GetFieldValueAsFloat('AmountWithVATDeposit');
          mCurrencyCode := mII.GetFieldValueAsString('Currency_ID.Code');

          // pokud je zpusob platby dobirkou, tak chci pridat i tu
          if mII.GetFieldValueAsString('PaymentType_ID') = cDobirka then
          begin
            mCashInDelivery := mCashInDelivery + mII.GetFieldValueAsFloat('Amount');
            mVarSymbol := mII.GetFieldValueAsString('VarSymbol');
          end;
        end;
      end;

      // vytvorim odeslanou postu
      // jedna posta pro cely exp. list
      mPackage := Self.ObjectSpace.CreateObject(Class_PDMIssuedDoc);
      mPackageDataset := TMemTable.Create(nil);
      try
        mPackageID := createPDMIssuedDoc(auxJson.A['packages'].Length, nil, True, mVarSymbol, mInsuredValue, mCashInDelivery, mCurrencyCode, mInvoicesIDs);
        DataSet_CreataHeader(mPackageDataset, 'Type=S10,Weight=F,Count=I');

        mPackageDataset.Open;
        mPackageDataset.Edit;

        // udelam soucty vahy a poctu baliku
        for i := 0 to auxJson.A['packages'].Length - 1 do
        begin
          if i = 0 then
          begin
            mPackageDataset.Insert;
            mPackageDataset.FieldByName('Type').AsString := cTypBalik;
            mPackageDataset.FieldByName('Weight').AsFloat := 0;
            mPackageDataset.FieldByName('Count').AsInteger := 0;
          end;

          mPackageDataset.FieldByName('Weight').AsFloat := mPackageDataset.FieldByName('Weight').AsFloat + auxJson.A['packages'].O[i].D['Weight'];
          mPackageDataset.FieldByName('Count').AsInteger := mPackageDataset.FieldByName('Count').AsInteger + 1;
        end;

        for i := 0 to auxJson.A['eurPallets'].Length - 1 do
        begin
          if i = 0 then
          begin
            mPackageDataset.Insert;
            mPackageDataset.FieldByName('Type').AsString := cTypEURPaleta;
            mPackageDataset.FieldByName('Weight').AsFloat := 0;
            mPackageDataset.FieldByName('Count').AsInteger := 0;
          end;

          mPackageDataset.FieldByName('Weight').AsFloat := mPackageDataset.FieldByName('Weight').AsFloat + auxJson.A['eurPallets'].O[i].D['Weight'];
          mPackageDataset.FieldByName('Count').AsInteger := mPackageDataset.FieldByName('Count').AsInteger + 1;
        end;

        for i := 0 to auxJson.A['pallets'].Length - 1 do
        begin
          if i = 0 then
          begin
            mPackageDataset.Insert;
            mPackageDataset.FieldByName('Type').AsString := cTypPaleta;
            mPackageDataset.FieldByName('Weight').AsFloat := 0;
            mPackageDataset.FieldByName('Count').AsInteger := 0;
          end;

          mPackageDataset.FieldByName('Weight').AsFloat := mPackageDataset.FieldByName('Weight').AsFloat + auxJson.A['pallets'].O[i].D['Weight'];
          mPackageDataset.FieldByName('Count').AsInteger := mPackageDataset.FieldByName('Count').AsInteger + 1;
        end;
        mPackageDataset.Post;

        // projdu dataset a vyplnim podle nej odesl. postu
        mPackage.Load(mPackageID, nil);
        mPackage.ExplicitTransaction := True;

        mPackageDataset.First;
        i := 0;
        mTotalWeight := 0;
        while not mPackageDataset.Eof do
        begin
          if i = 0 then
          begin
            mPackage.SetFieldValueAsString('X_MUTypeOne_ID', mPackageDataset.FieldByName('Type').AsString);
            mPackage.SetFieldValueAsString('X_ContentOne', FloatToStr(mPackageDataset.FieldByName('Weight').AsFloat));
            mPackage.SetFieldValueAsInteger('X_PiecesCountOne', mPackageDataset.FieldByName('Count').AsInteger);
            mTotalWeight := mTotalWeight + mPackageDataset.FieldByName('Weight').AsFloat;
          end
          else if i = 1 then
          begin
            mPackage.SetFieldValueAsString('X_MUTypeTwo_ID', mPackageDataset.FieldByName('Type').AsString);
            mPackage.SetFieldValueAsString('X_ContentTwo', FloatToStr(mPackageDataset.FieldByName('Weight').AsFloat));
            mPackage.SetFieldValueAsInteger('X_PiecesCountTwo', mPackageDataset.FieldByName('Count').AsInteger);
            mTotalWeight := mTotalWeight + mPackageDataset.FieldByName('Weight').AsFloat;
          end
          else if i = 2 then
          begin
            mPackage.SetFieldValueAsString('X_MUTypeThree_ID', mPackageDataset.FieldByName('Type').AsString);
            mPackage.SetFieldValueAsString('X_ContentThree', FloatToStr(mPackageDataset.FieldByName('Weight').AsFloat));
            mPackage.SetFieldValueAsInteger('X_PiecesCountThree', mPackageDataset.FieldByName('Count').AsInteger);
            mTotalWeight := mTotalWeight + mPackageDataset.FieldByName('Weight').AsFloat;
          end;

          i := i + 1;
          mPackageDataset.Next;
        end;

        mPackage.SetFieldValueAsFloat('Weight', mTotalWeight);

        mPackage.Save;
      finally
        mPackage.Free;
        mPackageDataset.Free;
      end;

      // pridam balik k odeslani do balikobotu
      mPackagesIDs.Add(mPackageID);

    finally
      auxJson.Free;
      mSLList.Free;
      mII.Free;
      mInvoicesIDs.Free;
      mBoD.Free;
    end;
  end;

  procedure processPersonal;
  begin
    // TODO Tisk DL (DL nebo EXP?)
    // TODO Odelsani emailu zakaznikovi
  end;

  // zavoz
  procedure processCollection;
  var
    mClass: String;
  begin
    if mDocumentType = '21' then
      mClass := Class_BillOfDelivery
    else
      mClass := Class_OutgoingTransfer;

    // doplnim do prvni vydejky pocet palet dle predanych cisel
    auxJson := TJSONSuperObject.ParseString(json.S['json'], True);
    mBoD := Self.ObjectSpace.CreateObject(mClass);
    try
      mBoD.ExplicitTransaction := True;
      loadFirstStoreDocumentID(mDoc_ID, mBoD);

      mBoDRows := mBoD.GetLoadedCollectionMonikerForFieldCode(mBoD.GetFieldCode('Rows'));

      // pridam EUR palety
      if auxJson.I['eurPallets'] > 0 then
      begin
        mBoDRow := mBoDRows.AddNewObject;
        mBoDRow.Prefill;
        mBoDRow.SetFieldValueAsInteger('RowType', 3);
        mBoDRow.SetFieldValueAsString('Store_ID', cPaletySklad_ID);
        mBoDRow.SetFieldValueAsString('StoreCard_ID', cEURPaleta_ID);
        mBoDRow.SetFieldValueAsFloat('Quantity', auxJson.I['eurPallets']);
        mBoDRow.SetFieldValueAsString('Division_ID', STREDISKO_HLAVNI);
      end;

      // pridam palety
      if auxJson.I['pallets'] > 0 then
      begin
        mBoDRow := mBoDRows.AddNewObject;
        mBoDRow.Prefill;
        mBoDRow.SetFieldValueAsInteger('RowType', 3);
        mBoDRow.SetFieldValueAsString('Store_ID', cPaletySklad_ID);
        mBoDRow.SetFieldValueAsString('StoreCard_ID', cPaleta_ID);
        mBoDRow.SetFieldValueAsFloat('Quantity', auxJson.I['pallets']);
        mBoDRow.SetFieldValueAsString('Division_ID', STREDISKO_HLAVNI);
      end;

      mBoD.Save;

      // nove radky s EUR paletami zapolohuju
      if auxJson.A['eurPallets'].Length > 0 then
        createLogStorePositionOnEURPallet;

    finally
      auxJson.Free;
      mBoD.Free;
    end;
  end;

begin
  json := nil;
  if (slPath.Count = 2) then
  begin
    mDoc_ID := slPath.Strings[1]; //ocekavam ID dokladu
  end else
  begin
    ErrREST(ARequest, AResponse, HTTP_SC_BadRequest, getString('wrong_parameters_count'));
    exit;
  end;

  mUser_Id := getHeaderValue(ARequest, 'UserID');
  mModule := getHeaderValue(ARequest, 'ModuleCode');
  mBoD_ID := '';

  LogWriteSectionStart('putObalyShippingListsQueueDocDetailStopPicking');

  mDocumentType := getFirstDocumentType(Self.ObjectSpace, mDoc_ID);

  json := TJSONSuperObject.ParseString(REST_ByteUTF82String(ARequest.Content.Content), True);
  mTemporaryStorageID := REST_getJSONInt(json, 'tempID');
  mPackagesIDs := TStringList.Create;
  //mSD := GetStoreDocBOID(mDoc_ID, Self.ObjectSpace, mDocType);
  mSL := Self.ObjectSpace.CreateObject(Class_ShippingList);
  dtJSONRows := TMemTable.Create(nil);
  try
    mRequestID := REST_getJSONStr(json, 'saveRequestID');
    // pred transakci overime, jestli uz tento request nebezi nebo neni dokonce dokonceny. Pokud ne, tak ho zalozime.
    case Request_Start(Self.ObjectSpace, mRequestID, 'putObalyShippingListsQueueDocDetailStopPicking') of
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
      mSL.ExplicitTransaction := True;
      mSL.Load(mDoc_ID, nil);

      // zmenim stavy dokladum
      LogWriteSectionStart('CHANGESTATUS');
      if mSL.GetFieldValueAsString('Status_ID') <> cStavBaleno then
        RaiseException('Exp. list není ve stavu Baleno');
      LogWriteSectionEnd;

      // provedu akce dle zpusobu dopravy
      if json.S['AuxText2'] = '0' then
      begin
        // baliky
        // zmenim stavy
        // vypnu hacek AfterSave, protoze se v nem vytvari faktury. Ja je ale potrebuju vytvorit rucne, abych z nich ziskal castky
        Self.ObjectSpace.EnableHooks(False, skBusinessObject, Class_ShippingList, 'AfterSave_Hook');
        try
          mSL.ChangeStatus(cStavVyrizeno, ROLE_VYSKLADNENO(DOC_EXPLIST, mModule));
        finally
          Self.ObjectSpace.EnableHooks(True, skBusinessObject, Class_ShippingList);
        end;

        changeStoreDocumentsStatus(Self.ObjectSpace, mDoc_ID, cStavVYDBaleno, cStavPRVBaleno, cPrechodVYDVyrizeno2, cPrechodPRVVyrizeno2, mUser_Id, mBoD_ID);

        processPackages;
      end
      else if json.S['AuxText2'] = '1' then
      begin
        // palety
        // zmenim stavy
        // vypnu hacek AfterSave, protoze se v nem vytvari faktury. Ja je ale potrebuju vytvorit rucne, abych z nich ziskal castky
        Self.ObjectSpace.EnableHooks(False, skBusinessObject, Class_ShippingList, 'AfterSave_Hook');
        try
        mSL.ChangeStatus(cStavVyrizeno, ROLE_VYSKLADNENO(DOC_EXPLIST, mModule));
        finally
          Self.ObjectSpace.EnableHooks(True, skBusinessObject, Class_ShippingList);
        end;
        changeStoreDocumentsStatus(Self.ObjectSpace, mDoc_ID, cStavVYDBaleno, cStavPRVBaleno, cPrechodVYDVyrizeno2, cPrechodPRVVyrizeno2, mUser_Id, mBoD_ID);

        processPallets;
      end
      else if json.S['AuxText2'] = '2' then
      begin
        // osobni odber
        // zmenim stavy
        mSL.ChangeStatus(cStavZabaleno, ROLE_VYSKLADNENO(DOC_EXPLIST, mModule));
        changeStoreDocumentsStatus(Self.ObjectSpace, mDoc_ID, cStavVYDBaleno, cStavPRVBaleno, cPrechodVYDZabaleno, cPrechodPRVZabaleno, mUser_Id, mBoD_ID);

        processPersonal;
      end
      else if json.S['AuxText2'] = '3' then
      begin
        // zavoz
        // zmenim stavy
        mSL.ChangeStatus(cStavVyrizeno, ROLE_VYSKLADNENO(DOC_EXPLIST, mModule));
        changeStoreDocumentsStatus(Self.ObjectSpace, mDoc_ID, cStavVYDBaleno, cStavPRVBaleno, cPrechodVYDVyrizeno2, cPrechodPRVVyrizeno2, mUser_Id, mBoD_ID);

        processCollection;
      end;

      // vymaz z TemporaryStorage jeste v transakci
      TemporaryStorage_Delete(Self.ObjectSpace, mTemporaryStorageID);

      Request_Finish(Self.ObjectSpace, mRequestID);

      Self.ObjectSpace.Commit;

      HTTPResponse(AResponse, HTTP_SC_OK, ContentType_JSON, PlainResponse(''));
    except
      self.ObjectSpace.RollBack;
      HTTPResponse(AResponse, HTTP_SC_OK, ContentType_JSON, PlainResponse(Format(getString('error_stopping_docqueue'), [ExceptionMessage])));
      Request_Cancel(Self.ObjectSpace, mRequestID);
      exit;
    end;

    // po odeslani odeslu do balikobotu
    mPDMIssuedDoc := TNxHeaderBusinessObject(Self.ObjectSpace.CreateObject(Class_PDMIssuedDoc));
    try
      Self.ObjectSpace.StartTransaction(taReadCommited);
      try
        for i := 0 to mPackagesIDs.Count - 1 do
        begin
          mPDMIssuedDoc.Load(mPackagesIDs.Strings(i), nil);
          main_Add(Self.ObjectSpace, mPDMIssuedDoc, nil);
        end;

        for i := 0 to mPackagesIDs.Count - 1 do
        begin
          mPDMIssuedDoc.Load(mPackagesIDs.Strings(i), nil);
          //if mPDMIssuedDoc.GetFieldValueAsString('PostProvider_ID') <> PostProvider_ID_BBDSV then AddToPrintQueue;
          AddToPrintQueue;
        end;
        Self.ObjectSpace.Commit;
      except
        Self.ObjectSpace.RollBack;
      end;
    finally
      mPDMIssuedDoc.Free;
    end;
  finally
    mSL.Free;
    mPackagesIDs.Free;
    json.Free;
    dtJSONRows.Free;
  end;

  LogWriteSectionEnd;
end;

{
  Vrati ID prvni vydejky, prevodky k expedicnimu listu
}
function getFirstDocumentType(AOS: TNxCustomObjectSpace; AShippingList_ID: String): String;
var
  mID, mSql: String;
begin
  mSql := 'select first 1' + nxCrLf +
    '   SD.DocumentType "DocumenType" ' + nxCrLf +
    ' from ShippingLists2 SL2 ' + nxCrLf +
    ' join StoreDocuments SD on SD.ID = SL2.Provide_ID ' + nxCrLf +
    ' where ' + nxCrLf +
    '   SL2.Parent_ID = ' + QuotedStr(AShippingList_ID);
  mID := SQLSelectStr(AOS, mSql);
  Result := mID;
end;

{
  Vrati prvni vydejku k expedicnimu listu
}
procedure loadFirstStoreDocumentID(AShippingList_ID: String; var ABO: TNxCustomBusinessObject);
var
  mID, mSql: String;
begin
  mSql := 'select first 1' + nxCrLf +
    '   SL2.Provide_ID "ID" ' + nxCrLf +
    ' from ShippingLists2 SL2 ' + nxCrLf +
    ' where ' + nxCrLf +
    '   SL2.Parent_ID = ' + QuotedStr(AShippingList_ID);
  mID := SQLSelectStr(ABO.ObjectSpace, mSql);

  ABO.Load(mID, nil);
end;

{
  Prepne stavy vydejkam nebo prevodkam k zadanemu Expedicnimu listu
  Pokud je zadan posledni parametr, vrati se v nem udaje z prvniho zaznamu (prevodky). ID:TransportationType_ID
}
procedure changeStoreDocumentsStatus(AOS: TNxCustomObjectSpace; AShippingList_ID, ABoFStatusFrom, AOTRStatusFrom, ABoFSwitchRule, AOTRSwitchRule, AUser_ID: String; var OFirstDocument: String = '');
var
  mSD: TNxCustomBusinessObject;
  dtStoreDocuments: TMemTable;
  mSql, mStatus_ID, mSwitchRule_ID, mClass: String;
begin
  dtStoreDocuments := TMemTable.Create(nil);
  try
    // prepnu vydejky
    mSql := 'select distinct' + nxCrLf +
    '   SD.ID "ID", ' + nxCrLf +
    '   SD.TransportationType_ID "TransportationType_ID", ' + nxCrLf +
    '   SD.DocumentType "DocumentType" ' + nxCrLf +
    ' from ShippingLists2 SL2 ' + nxCrLf +
    ' join StoreDocuments SD on SD.id = SL2.Provide_ID and (SD.DocumentType = ''21'' or SD.DocumentType = ''22'')' + nxCrLf +
    ' where ' + nxCrLf +
    '   SL2.Parent_ID = ' + QuotedStr(AShippingList_ID);
    AOS.SQLSelect2(mSql, dtStoreDocuments);

    if dtStoreDocuments.Active then
    begin
      dtStoreDocuments.First;

      if dtStoreDocuments.FieldByName('DocumentType').AsInteger = 21 then
      begin
        mClass := Class_BillOfDelivery;
        mStatus_ID := ABoFStatusFrom;
        mSwitchRule_ID := ABoFSwitchRule;
      end
      else
      begin
        mClass := Class_OutgoingTransfer;
        mStatus_ID := AOTRStatusFrom;
        mSwitchRule_ID := AOTRSwitchRule;
      end;

      mSD := AOS.CreateObject(mClass);
      try
        mSD.ExplicitTransaction := True;
        while not dtStoreDocuments.Eof do
        begin
          mSD.Load(dtStoreDocuments.FieldByName('ID').AsString, nil);

          if mSD.GetFieldValueAsString('Status_ID') <> mStatus_ID then
            RaiseException('Výdejka/převodka ' + mSD.GetFieldValueAsString('DisplayName') + ' není ve správném stavu');

          mSD.ChangeStatusBySwitchRule(mSwitchRule_ID, '0000000000', AUser_ID);
          //mSD.ChangeStatus();

          if OFirstDocument = '' then
            OFirstDocument := dtStoreDocuments.FieldByName('ID').AsString + ':' + dtStoreDocuments.FieldByName('TransportationType_ID').AsString;

          dtStoreDocuments.Next;
        end;
        dtStoreDocuments.First;
      finally
        mSD.Free;
      end;
    end;
  finally
    dtStoreDocuments.Free;
  end;
end;

procedure PA_PrintReports (OS: TNxCustomObjectSpace;
  var Success: Boolean; var LogInfoStr: String);
var
  ds: TMemTable;
  mInTransaction: boolean;
  mTempFile: String;
  mResponse: TMemoryStream;
begin
  Success := True;
  LogInfoStr := '';

  gLog:= TNxCustomLog.Create('REST');
  ds:= TMemTable.Create(nil);
  try
    //nekonecny cyklus. koncim v 22:00
    repeat
      Sleep(10000);
      gLog.InitInternalLog;

      if(ds.Active)then begin
        ds.Close;
        ds.Fields.Clear;
      end;

      OS.SQLSelect2(
        'SELECT id, Document_ID, DynSource_ID, Report_ID, Filepath, PrinterName, Copies  '+
        'FROM '+TABLE_Print+' WHERE Status=0 ORDER BY id',
        ds);
      if(not ds.Active)OR(ds.RecordCount = 0)then begin
        continue;
      end;

      ds.first;
      while(not ds.eof)do begin
        //test, zda objekt stale existuje

        //tisknu v transakci. potrebuju zamknout prave tisknutej tisk, aby se nevytiskl v jine
        //pl. uloze novu
        mInTransaction := true; //nebudu zapinat transakci. dela to nejakej problem //OS.InTransaction;
        if not mInTransaction then
          OS.StartTransaction(taReadCommited);
        try
          //zapisu ze jsem vytiskl (aby to uz nikdo nebral). pokud chyba, tak odroluju zpet
          OS.SQLExecute('UPDATE '+TABLE_Print+
            ' SET Status=1, DatePrint$DATE = '+NxFloatToIBStr(now)+
            ' WHERE id='+QuotedStr(ds.FieldByName('id').AsString));

          // tisknu buď report nebo soubor
          if trim(ds.FieldByName('Report_ID').AsString) <> '' then
          begin
            PrintReportToPrinterByID(
              NxCreateContext(OS),
              ds.FieldByName('Document_ID').AsString,
              ds.FieldByName('DynSource_ID').AsString,
              ds.FieldByName('Report_ID').AsString,
              ds.FieldByName('PrinterName').AsString,
              ds.FieldByName('Copies').AsInteger
            );
          end
          else if trim(ds.FieldByName('Filepath').AsString) <> '' then
          begin
            mTempFile := '';
            // pokud jde o web. odkaz, tak ho musim stahnout
            if StartsStr('http', ds.FieldByName('Filepath').AsString) then
            begin
              mResponse := TMemoryStream.Create;
              try
                mTempFile := NxGetTempDir + ds.FieldByName('Document_ID').AsString + '.pdf';
                CFxInternet.HTTPGetBinary(ds.FieldByName('Filepath').AsString, '', mResponse);
                mResponse.SaveToFile(mTempFile);
              finally
                mResponse.Free;
              end;
            end
            else
            begin
              mTempFile := ds.FieldByName('Filepath').AsString;
            end;

            if (mTempFile <> '') then
            begin
              //ShellAPI.PrintFile(mTempFile, ds.FieldByName('PrinterName').AsString);
              // pokud jde o DSV tak tisknu zmenseny stitek
              if pos('\\Dbserver\flores\Stitek', mTempFile) > 0 then
                NxExecFile('cmd /C C:\FLORESSYSTEM\Tisk\DSV\PDFtoPrinter.exe "' + mTempFile + '" "' + ds.FieldByName('PrinterName').AsString + '"', True, True)
              else
                NxExecFile('cmd /C C:\FLORESSYSTEM\Tisk\Ostatni\PDFtoPrinter.exe "' + mTempFile + '" "' + ds.FieldByName('PrinterName').AsString + '"', True, True);
            end
            else
            begin
              RaiseException('Nepodařilo se získat cestu k souboru');
            end;
          end
          else
          begin
            RaiseException('Není vyplněno ID reportu ani cesta k souboru');
          end;

          //commit
          if not mInTransaction then
            OS.Commit;

          //zaloguju projistotu v chranene sekci
          try
            gLog.WriteEventFmt(logNotice, 'PRINT OK: ID=%d,Document_ID=%s,DynSource_ID=%s,Report_ID=%s,Filepath=%s,PrinterName=%s', [
              ds.FieldByName('ID').AsInteger,
              ds.FieldByName('Document_ID').AsString,
              ds.FieldByName('DynSource_ID').AsString,
              ds.FieldByName('Report_ID').AsString,
              ds.FieldByName('Filepath').AsString,
              ds.FieldByName('PrinterName').AsString]);
          except
          end;

        except
          //chyba
          OS.SQLExecute('UPDATE '+TABLE_Print+
            ' SET '+
            ' Status=2, '+
            ' DatePrint$DATE = '+NxFloatToIBStr(now)+', '+
            ' Error = '+QuotedStr(ExceptionMessage)+' '+
            ' WHERE id='+QuotedStr(ds.FieldByName('id').AsString));


          if not mInTransaction then
            OS.Commit;

          gLog.WriteEventFmt(logError, 'PRINT ERR: ID=%d,Document_ID=%s,DynSource_ID=%s,Report_ID=%s,Filepath=%s,PrinterName=%s,Error:%s', [
            ds.FieldByName('ID').AsInteger,
            ds.FieldByName('Document_ID').AsString,
            ds.FieldByName('DynSource_ID').AsString,
            ds.FieldByName('Report_ID').AsString,
            ds.FieldByName('Filepath').AsString,
            ds.FieldByName('PrinterName').AsString,
            ExceptionMessage
            ]);
        end;
        ds.next;
      end;
    until(HourOf(now) < 5)OR(HourOf(now) >= 22);
  finally
    ds.free;
    glog.free;
  end;
end;*)

begin
end.