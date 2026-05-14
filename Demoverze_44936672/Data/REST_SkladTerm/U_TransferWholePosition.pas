uses
  'REST_SkladTerm.U_Func',
  'REST_SkladTerm.U_FuncJSON',
  'REST_SkladTerm.U_LogStoreDocument',
  'REST_SkladTerm.U_TemporaryStorage',
  'REST_SkladTerm.U_Requests',
  'REST_SkladTerm_Special.U_Const',
  'REST_SkladTerm_Special.U_StandardHooks',
  'StandardUnits.U_DataSet';

function isTransferWholePositionContentsAllowed(AContext: TNxContext; AStorePosition_ID, AUnblockPositions: String; var AMessage: String): Boolean;
var
  dtStoreDocs, dtLogStoreDocs: TMemTable;
  mSql, mMessageSD, mMessageLSD: String;
begin
  Result := True;

  // hledame blokujici doklady
  // ze vsech blokujicich povolime pouze ty pozicni doklady, ktere jsou navazane na skladovy doklad ve spravnem stavu
  // LSD navazane na skl. dokl. ve spatnem stavu a volne LSD blokujeme
  dtStoreDocs := TMemTable.Create(nil);
  dtLogStoreDocs := TMemTable.Create(nil);
  try
    // LSD navazane na SD
    mSql := 'select ' +
      '  max(DQ.Code)' + CONCAT_STR + QuotedStr('-') + CONCAT_STR + 'cast(max(SD.OrdNumber) as varchar(6))' + nxCrLf +
         CONCAT_STR + QuotedStr('/') + CONCAT_STR + 'max(P.Code) as "DisplayName", ' + nxCrLf;
    if ABRA then
      mSql := mSql + '  max(US.Code) as "UserStatusCode"' + nxCrLf
    else
      mSql := mSql + '  max(US.UserStatusCode) as "UserStatusCode"' + nxCrLf;

    mSql := mSql +
      'from LogStoreDocuments2 LSD2 ' + nxCrLf +
      'join LogStoreDocuments LSD on LSD.ID = LSD2.Parent_ID' + nxCrLf +
      'join StoreDocuments SD on SD.ID = LSD.StoreDocument_ID' + nxCrLf;
    if ABRA then
      mSql := mSql + 'join PMStates US on US.ID = SD.PMState_ID' + nxCrLf
    else
      mSql := mSql + 'join UserStatuses US on US.ID = SD.Status_ID' + nxCrLf;

    mSql := mSql +
      'join DocQueues DQ on DQ.ID = SD.DocQueue_ID' + nxCrLf +
      'join Periods P on P.ID = SD.Period_ID' + nxCrLf +
      'where LSD2.StorePosition_ID = ' + QuotedStr(AStorePosition_ID) + ' ' +
      '  and LSD.Executed = ''N'' ';

    if AUnblockPositions <> '' then
      mSql := mSql + '  and not SD.' + GetStatusField + ' in (' + AUnblockPositions + ')';

      mSql := mSql +'group by SD.ID ';
    AContext.GetObjectSpace.SQLSelect2(mSql, dtStoreDocs);

    // volne LSD
    mSql := 'select ' +
      '  max(DQ.Code)' + CONCAT_STR + QuotedStr('-') + CONCAT_STR + 'cast(max(LSD.OrdNumber) as varchar(6))' +
         CONCAT_STR + QuotedStr('/') + CONCAT_STR + 'max(P.Code) as "DisplayName" ' +
      'from LogStoreDocuments2 LSD2 ' +
      'join LogStoreDocuments LSD on LSD.ID = LSD2.Parent_ID ' +
      'join DocQueues DQ on DQ.ID = LSD.DocQueue_ID ' +
      'join Periods P on P.ID = LSD.Period_ID ' +
      'where LSD2.StorePosition_ID = ' + QuotedStr(AStorePosition_ID) + ' ' +
      '  and LSD.Executed = ''N'' ' +
      '  and LSD.StoreDocument_ID is null ' +
      'group by LSD.ID ';
    AContext.GetObjectSpace.SQLSelect2(mSql, dtLogStoreDocs);

    mMessageSD := '';
    if dtStoreDocs.Active then
    begin
      Result := False;
      dtStoreDocs.First;
      while not dtStoreDocs.EOF do
      begin
        mMessageSD := mMessageSD + dtStoreDocs.FieldByName('DisplayName').AsString + ': ' + dtStoreDocs.FieldByName('UserStatusCode').AsString + nxCrLf;
        dtStoreDocs.Next;
      end;
      mMessageSD := getString('blocking_documents') + nxCrLf + mMessageSD + nxCrLf;
    end;

    mMessageLSD := '';
    if dtLogStoreDocs.Active then
    begin
      Result := False;
      dtLogStoreDocs.First;
      while not dtLogStoreDocs.EOF do
      begin
        mMessageLSD := mMessageLSD + dtLogStoreDocs.FieldByName('DisplayName').AsString + nxCrLf;
        dtLogStoreDocs.Next;
      end;
      mMessageLSD := getString('blocking_free_documents') + nxCrLf + mMessageLSD + nxCrLf;
    end;

    AMessage := getString('transfer_whole_position_cannot_be_done') + nxCrLf + nxCrLf + mMessageSD + mMessageLSD;
  finally
    dtStoreDocs.Free;
    dtLogStoreDocs.Free;
  end;
end;

///////////////////////////////////////////////////////////////////////////////
procedure getTransferWholePositionContentsAllowed(Self: TNxWebServicesHelper; ARequest: TNxHTTPRequest;
  AResponse: TNxHTTPResponse; slPath: TStringList);
var
  mStorePosition_ID, mUser_ID, mModule, mDocType, mUnblockPositions: String;
  mMessage: String;
  mBlockedFirst: Boolean;
begin
  if (slPath.Count = 2) then
  begin
    mStorePosition_ID := slPath.Strings[1]; //ocekavam pozici
  end else
  begin
    ErrREST(ARequest, AResponse, HTTP_SC_BadRequest, getString('wrong_parameters_count'));
    exit;
  end;

  LogWriteSectionStart('getTransferWholePositionContentsAllowed');

  mModule := getHeaderValue(ARequest, 'ModuleCode');
  mUser_ID := getHeaderValue(ARequest, 'UserID');
  mDocType := getHeaderValue(ARequest, 'DocumentType');

  mBlockedFirst := False;
  mUnblockPositions := POVOLENE_STAVY_PRESUN_CELE_POZICE(Self.ObjectSpace, mModule, mDocType, mUser_ID, nil, mBlockedFirst);

  if isTransferWholePositionContentsAllowed(Self.Context, mStorePosition_ID, mUnblockPositions, mMessage) then
  begin
    HTTPResponse(AResponse, HTTP_SC_OK, ContentType_JSON, PlainResponse(''));
  end
  else begin
    ErrREST(ARequest, AResponse, HTTP_SC_ExpectationFailed, mMessage);
  end;
  LogWriteSectionEnd;
end;
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
procedure putTransferWholePositionContents(Self: TNxWebServicesHelper; ARequest: TNxHTTPRequest;
  AResponse: TNxHTTPResponse; slPath: TStringList);
var
  mStorePositionFrom_ID, mStorePositionTo_ID: String;
  mMessage, mSql, mLastLSD_ID, mUser_ID, mModule, mDocType, mUnblockPositions: String;
  dtBlockingLSDRows, dtLSPContents: TMemTable;
  mLSD, mLSDRow: TNxCustomBusinessObject;
  mLSDRows: TNxCustomBusinessMonikerCollection;
  i: Integer;
  mTemporaryStorageID: Integer;
  mRequestID: String;
  json: TJSONSuperObject;
  mSL: TStringList;
  mBlockedFirst: Boolean;

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
begin
  if (slPath.Count = 1) then
  begin
    //mStorePositionFrom_ID := slPath.Strings[1]; //ocekavam pozici z
    //mStorePositionTo_ID := slPath.Strings[2]; //ocekavam pozici na
  end else
  begin
    ErrREST(ARequest, AResponse, HTTP_SC_BadRequest, getString('wrong_parameters_count'));
    exit;
  end;

  LogWriteSectionStart('putTransferWholePositionContents');

  mModule := getHeaderValue(ARequest, 'ModuleCode');
  mUser_ID := getHeaderValue(ARequest, 'UserID');
  mDocType := getHeaderValue(ARequest, 'DocumentType');

  mBlockedFirst := False;

  json := TJSONSuperObject.ParseString(REST_ByteUTF82String(ARequest.Content.Content), True);
  dtBlockingLSDRows := TMemTable.Create(nil);
  dtLSPContents := TMemTable.Create(nil);
  mSL := TStringList.Create;
  try
    mTemporaryStorageID := REST_getJSONInt(json, 'tempID');
    mRequestID := REST_getJSONStr(json, 'saveRequestID');
    mStorePositionFrom_ID := REST_getJSONStr(json, 'StorePositionFrom_ID');
    mStorePositionTo_ID := REST_getJSONStr(json, 'StorePositionTo_ID');
    // pred transakci overime, jestli uz tento request nebezi nebo neni dokonce dokonceny. Pokud ne, tak ho zalozime.
    case Request_Start(Self.ObjectSpace, mRequestID, 'putTransferWholePositionContents') of
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
      mUnblockPositions := POVOLENE_STAVY_PRESUN_CELE_POZICE(Self.ObjectSpace, mModule, mDocType, mUser_ID, json, mBlockedFirst);

      // znovu zkontrolujeme, jestli neni pozice blokovana doklady v nepovolenych stavech
      if not isTransferWholePositionContentsAllowed(Self.Context, mStorePositionFrom_ID, mUnblockPositions, mMessage) then
      begin
        ErrREST(ARequest, AResponse, HTTP_SC_ExpectationFailed, mMessage);
        Self.ObjectSpace.RollBack;
        exit;
      end;

      // provedeme presun vseho na zdrojove pozici na cilovou pozici
      // udelame to pomoci dokladu Presun mezi pozicemi
      // pokud je obsah zdrojove pozice blokovany neprovedenymi pozicnimi doklady, nejdriv z nich blokujici polozky smazeme,
      // po presunu je tam vratime s novou pozici


      // ziskame vsechny blokujici radky
      mSql := 'select LSD.ID as "LSD_ID", LSD.DocumentType as "DocumentType", LSD2.ID as "LSD2_ID", ' +
        '  LSD2.Store_ID as "Store_ID", LSD2.StoreCard_ID as "StoreCard_ID", LSD2.StoreBatch_ID as "StoreBatch_ID", ' +
        '  LSD2.QUnit as "QUnit", LSD2.Quantity as "Quantity", LSD2.StoreDocRow_ID as "StoreDocRow_ID" ' +
        'from LogStoreDocuments2 LSD2 ' +
        'join LogStoreDocuments LSD on LSD.ID = LSD2.Parent_ID ' +
        'where LSD2.StorePosition_ID = ' + QuotedStr(mStorePositionFrom_ID) + ' ' +
        '  and LSD.Executed = ''N'' ' +
        'order by LSD.ID ';
      Self.ObjectSpace.SQLSelect2(mSql, dtBlockingLSDRows);

      // vymazeme je z pozicnich dokladu
      if dtBlockingLSDRows.Active then
      begin
        mLastLSD_ID := '';
        dtBlockingLSDRows.First;
        while not dtBlockingLSDRows.EOF do
        begin
          if mLastLSD_ID <> dtBlockingLSDRows.FieldByName('LSD_ID').AsString then
          begin
            // vzdy, kdyz narazime na nove ID hlavicky, nacteme ji a smazeme z ni vsechny polozky pracujici s nasi zdrojovou pozici
            // s presuny mezi pozicemi nepocitame
            mLSD := Self.ObjectSpace.CreateObject(GetStoreDocClass(dtBlockingLSDRows.FieldByName('DocumentType').AsString));
            try
              mLSD.ExplicitTransaction := True;
              mLSD.Load(dtBlockingLSDRows.FieldByName('LSD_ID').AsString, nil);
              mLSDRows := mLSD.GetLoadedCollectionMonikerForFieldCode(mLSD.GetFieldCode('Rows'));
              for i := 0 to mLSDRows.Count - 1 do
              begin
                mLSDRow := mLSDRows.BusinessObject[i];
                if mLSDRow.GetFieldValueAsString('StorePosition_ID') = mStorePositionFrom_ID then
                  mLSDRow.MarkForDelete;
              end;
              mLSD.Save;
            finally
              mLSD.Free;
            end;
            mLastLSD_ID := dtBlockingLSDRows.FieldByName('LSD_ID').AsString;
          end;
          dtBlockingLSDRows.Next;
        end;
      end;

      // vytvorime presun mezi pozicemi na veskery obsah zdrojove pozice
      // ziskame obsah zdrojove pozice
      mSql := 'select LSP.Store_ID as "Store_ID", LSC.StoreCard_ID as "StoreCard_ID", ' +
        '  LSC.StoreBatch_ID as "StoreBatch_ID", LSC.QUnit as "QUnit", ' +
        '  LSC.Quantity as "Quantity" ' +
        'from LogStoreContents LSC ' +
        'join LogStorePositions LSP on LSP.ID = LSC.Parent_ID ' +
        'where LSC.Parent_ID = ' + QuotedStr(mStorePositionFrom_ID);
      Self.ObjectSpace.SQLSelect2(mSql, dtLSPContents);

      mLSD := Self.ObjectSpace.CreateObject(Class_LogStoreTransfer);
      try
        mLSD.ExplicitTransaction := True;
        mLSD.New;
        mLSD.Prefill;
        mLSD.SetFieldValueAsString('DocQueue_ID',
          GetDocQueueForDocument(Self.ObjectSpace, mModule, DOC_LogStoreTransfer, mUser_ID, LogStoreTransfer_DocQueue_ID));
        mLSD.SetFieldValueAsString('Firm_ID', FIRM_OWN);
        if not ABRA then
          mLSD.SetFieldValueAsString('StoreMan_ID', SqlSelectStr(Self.ObjectSpace, 'select Person_ID from SecurityUsers where ID = ' + QuotedStr(mUser_ID)));
        mLSDRows := mLSD.GetLoadedCollectionMonikerForFieldCode(mLSD.GetFieldCode('Rows'));

        dtLSPContents.First;
        while not dtLSPContents.EOF do
        begin
          mLSDRow := mLSDRows.AddNewObject;
          mLSDRow.SetFieldValueAsString('Store_ID', dtLSPContents.FieldByName('Store_ID').AsString);
          mLSDRow.SetFieldValueAsString('StoreCard_ID', dtLSPContents.FieldByName('StoreCard_ID').AsString);
          mLSDRow.SetFieldValueAsString('StoreBatch_ID', dtLSPContents.FieldByName('StoreBatch_ID').AsString);
          mLSDRow.SetFieldValueAsString('StorePosition_ID', mStorePositionFrom_ID);
          mLSDRow.SetFieldValueAsString('QUnit', dtLSPContents.FieldByName('QUnit').AsString);
          mLSDRow.SetFieldValueAsFloat('Quantity', dtLSPContents.FieldByName('Quantity').AsFloat);
          mLSDRow.SetFieldValueAsString('IncomingStorePosition_ID', mStorePositionTo_ID);

          dtLSPContents.Next;
        end;

        glog.WriteEvent(logDebug, 'putTransferWholePositionContents - ulozeni LSDTransfer ' + mLSD.DisplayName);
        mLSD.Save;
        glog.WriteEvent(logDebug, 'putTransferWholePositionContents - potvrzeni LSDTransfer ' + mLSD.DisplayName);
        TNxLogStoreDocument(mLSD).MakeExecuted;
      finally
        mLSD.Free;
      end;

      // na puvodni blokujici doklady naskladame polozky, ktere jsme na zacatku smazali, ale s novou pozici
      if dtBlockingLSDRows.Active then
      begin
        // sesbirame si ID dokladu
        mSL.Clear;
        dtBlockingLSDRows.First;
        while not dtBlockingLSDRows.EOF do
        begin
          if mSL.IndexOf(dtBlockingLSDRows.FieldByName('LSD_ID').AsString) = -1 then
            mSL.Append(dtBlockingLSDRows.FieldByName('LSD_ID').AsString);
          dtBlockingLSDRows.Next;
        end;

        for i := 0 to mSL.Count - 1 do
        begin
          // nacteme doklad a naskladame na neho vsechny puvodni polozky
          // s presuny mezi pozicemi nepocitame
          mLSD := GetLogStoreDocBOID(mSL[i], Self.ObjectSpace, mDocType);
          try
            mLSD.ExplicitTransaction := True;
            mLSD.Load(mSL[i], nil);
            mLSDRows := mLSD.GetLoadedCollectionMonikerForFieldCode(mLSD.GetFieldCode('Rows'));

            dtBlockingLSDRows.First;
            while not dtBlockingLSDRows.EOF do
            begin
              if dtBlockingLSDRows.FieldByName('LSD_ID').AsString = mLSD.OID then
              begin
                mLSDRow := mLSDRows.AddNewObject;
                mLSDRow.SetFieldValueAsString('Store_ID', dtBlockingLSDRows.FieldByName('Store_ID').AsString);
                mLSDRow.SetFieldValueAsString('StoreCard_ID', dtBlockingLSDRows.FieldByName('StoreCard_ID').AsString);
                mLSDRow.SetFieldValueAsString('StoreBatch_ID', dtBlockingLSDRows.FieldByName('StoreBatch_ID').AsString);
                mLSDRow.SetFieldValueAsString('StorePosition_ID', mStorePositionTo_ID);
                mLSDRow.SetFieldValueAsString('StoreDocRow_ID', dtBlockingLSDRows.FieldByName('StoreDocRow_ID').AsString);
                mLSDRow.SetFieldValueAsString('QUnit', dtBlockingLSDRows.FieldByName('QUnit').AsString);
                mLSDRow.SetFieldValueAsFloat('Quantity', dtBlockingLSDRows.FieldByName('Quantity').AsFloat);
              end;

              dtBlockingLSDRows.Next;
            end;

            mLSD.Save;
          finally
            mLSD.Free;
          end;
        end;
      end;

      // vymaz z TemporaryStorage jeste v transakci
      TemporaryStorage_Delete(Self.ObjectSpace, mTemporaryStorageID);

      Request_Finish(Self.ObjectSpace, mRequestID);

      Self.ObjectSpace.Commit;

      HTTPResponse(AResponse, HTTP_SC_OK, ContentType_JSON, PlainResponse(''));
    except
      Self.ObjectSpace.RollBack;
      ErrREST(ARequest, AResponse, HTTP_SC_ExpectationFailed, getString('error_while_trasfer_whole_position') + ExceptionMessage);
      Request_Cancel(Self.ObjectSpace, mRequestID);
      glog.WriteEvent(logError, 'putTransferWholePositionContents - error - ' + ExceptionMessage);
    end;
  finally
    json.Free;
    dtBlockingLSDRows.Free;
    dtLSPContents.Free;
    mSL.Free;
    LogWriteSectionEnd;
  end;
end;
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
procedure PutDispatchWholePosition(Self: TNxWebServicesHelper; ARequest: TNxHTTPRequest;
  AResponse: TNxHTTPResponse; slPath: TStringList);
var
  mUser_ID, mDocType, mModule, mRequestID, mPersonField, mSql, mLSD_ID, mLastStore_ID, mLastStoreCard_ID, mLastStoreBatch_ID,
    mFirm_ID: String;
  mTemporaryStorageID: Integer;
  json: TJSONSuperObject;
  dtJsonRows, dtLSPContents: TMemTable;
  mBoD, mBoDRow, mBoDDocRowBatch: TNxCustomBusinessObject;
  mBoDRows, mBoDDocRowBatches: TNxCustomBusinessMonikerCollection;
  mSL: TStringList;
  i: Integer;

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
begin
  if (slPath.Count <> 1) then
  begin
    ErrREST(ARequest, AResponse, HTTP_SC_BadRequest, getString('wrong_parameters_count'));
    exit;
  end;

  LogWriteSectionStart('PutDispatchWholePosition');

  mUser_ID := getHeaderValue(ARequest, 'UserID');
  mDocType := getHeaderValue(ARequest, 'DocumentType');
  mModule := getHeaderValue(ARequest, 'ModuleCode');

  json := TJSONSuperObject.ParseString(REST_ByteUTF82String(ARequest.Content.Content), True);
  dtLSPContents := TMemTable.Create(nil);
  mSL := TStringList.Create;
  dtJsonRows := TMemTable.Create(nil);
  try
    mTemporaryStorageID := REST_getJSONInt(json, 'tempID');
    mRequestID := REST_getJSONStr(json, 'saveRequestID');

    // pred transakci overime, jestli uz tento request nebezi nebo neni dokonce dokonceny. Pokud ne, tak ho zalozime.
    case Request_Start(Self.ObjectSpace, mRequestID, 'PutDispatchWholePosition') of
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
      DataSet_CreataHeader(dtJsonRows, 'jsonIndex=I,StoreFrom_ID=S10,StorePositionFrom_ID=S10');
      dtJsonRows.AddIndex('ByJsonIndex', 'jsonIndex', [ixUnique]);
      dtJsonRows.AddIndex('ByStoreAndStorePosition_ID', 'StoreFrom_ID;StorePositionFrom_ID;jsonIndex', [ixUnique]);
      dtJsonRows.Open;
      REST_JsonToDataSet(json.A['rows'], dtJsonRows);

      mSL.Delimiter := ',';

      // prectu si pozice, ktere se nacetly, abych z nich mohl vzit vsechny artikly
      dtJsonRows.First;
      while not dtJsonRows.Eof do
      begin
        mSL.Add(dtJsonRows.FieldByName('StorePositionFrom_ID').AsString);
        dtJsonRows.Next;
      end;

      // ziskame vsechny artikly z nactenych pozic
      mSql :=
        'select' + NxCrLf +
        '  LSP.Store_ID as "Store_ID",' + NxCrLf +
        '  LSC.StoreCard_ID as "StoreCard_ID",' + NxCrLf +
        '  LSC.StoreBatch_ID as "StoreBatch_ID",' + NxCrLf +
        '  LSP.ID as "StorePosition_ID",' + NxCrLf +
        '  LSC.QUnit as "QUnit",' + NxCrLf +
        '  sum(LSC.Quantity - LSC.QuantityReserved) as "Quantity"' + NxCrLf +
        'from LogStoreContents LSC' + NxCrLf +
        'join LogStorePositions LSP on LSP.ID = LSC.Parent_ID' + NxCrLf +
        'where' + NxCrLf +
        '  LSP.ID in (''' + ReplaceStr(mSL.DelimitedText, ',', ''',''') + ''')' + NxCrLf +
        '  and (LSC.Quantity - LSC.QuantityReserved) > 0' + NxCrLf +
        'group by' + NxCrLf +
        ' LSP.Store_ID, LSC.StoreCard_ID, LSC.StoreBatch_ID, LSP.ID, LSC.QUnit';
      Self.ObjectSpace.SQLSelect2(mSql, dtLSPContents);

      // kontrola, ze na pozicich neco bylo
      if not dtLSPContents.Active then
      begin
        RaiseException(getString('error_positions_empty'));
        exit;
      end;

      dtLSPContents.AddIndex('ByStore_SC_SB_SP', 'Store_ID;StoreCard_ID;StoreBatch_ID;StorePosition_ID', [ixUnique]);
      dtLSPContents.IndexName := 'ByStore_SC_SB_SP';

      // vytvorim vydejku
      mBoD := Self.ObjectSpace.CreateObject(Class_BillOfDelivery);
      try
        mBoD.ExplicitTransaction := True;
        mBoD.New;
        mBoD.Prefill;

        if EnterPerson(Self.ObjectSpace, mModule, mDocType, mUser_ID, mPersonField) then
          mBoD.SetFieldValueAsString(mPersonField, REST_getJSONStr(json, 'Person_ID'));

        if EnterDocQueue(Self.ObjectSpace, mModule, mDocType, mUser_ID) then
          mBoD.SetFieldValueAsString('DocQueue_ID', REST_getJSONStr(json, 'DocQueue_ID'))
        else
          mBoD.SetFieldValueAsString('DocQueue_ID',
            GetDocQueueForDocument(Self.ObjectSpace, mModule, mDocType, mUser_ID, RADA_VYDEJKA));

        if EnterTransportationType(Self.ObjectSpace, mModule, mDocType, mUser_ID) then
          mBoD.SetFieldValueAsString('TransportationType_ID', REST_getJSONStr(json, 'TransportationType_ID'));

        // firmu bud podle dokladu, nebo vychozi
        mFirm_ID := REST_getJSONStr(json, 'Firm_ID');
        if CFxOID.IsEmpty(mFirm_ID) then
          mBoD.SetFieldValueAsString('Firm_ID',  FIRM_OWN)
        else
          mBoD.SetFieldValueAsString('Firm_ID',  mFirm_ID);

        mBoDRows := mBoD.GetLoadedCollectionMonikerForFieldCode(mBoD.GetFieldCode('Rows'));

        // pridam radky vydejky
        mLastStore_ID := '';
        mLastStoreCard_ID := '';
        mLastStoreBatch_ID := '';
        dtLSPContents.First;
        while not dtLSPContents.EOF do
        begin
          // pokud jde o stejny radek (sklad, artikl) tak jen prictu mnoztvi
          // jinak pridam novy radek
          if (mLastStore_ID = dtLSPContents.FieldByName('Store_ID').AsString)
            and (mLastStoreCard_ID = dtLSPContents.FieldByName('StoreCard_ID').AsString) then
          begin
            mBoDRow.SetFieldValueAsFloat('Quantity', mBoDRow.GetFieldValueAsFloat('Quantity') + dtLSPContents.FieldByName('Quantity').AsFloat);

            // sarze
            if mBoDRow.GetFieldValueAsInteger('StoreCard_ID.Category') in [1, 2] then
            begin
              // bud pridavam k existujici, nebo pridam novou
              if mLastStoreBatch_ID = dtLSPContents.FieldByName('StoreBatch_ID').AsString then
              begin
                mBoDDocRowBatches := mBoDRow.GetLoadedCollectionMonikerForFieldCode(mBoDRow.GetFieldCode('DocRowBatches'));
                for i := 0 to mBoDDocRowBatches.Count - 1 do
                begin
                  mBoDDocRowBatch := mBoDDocRowBatches.BusinessObject(i);

                  if mBoDDocRowBatch.GetFieldValueAsString('StoreBatch_ID') = dtLSPContents.FieldByName('StoreBatch_ID').AsString then
                  begin
                    mBoDDocRowBatch.SetFieldValueAsFloat('Quantity', mBoDDocRowBatch.GetFieldValueAsFloat('Quantity') + dtLSPContents.FieldByName('Quantity').AsFloat);
                    break;
                  end;
                end;
              end
              else
              begin
                mBoDDocRowBatches := mBoDRow.GetLoadedCollectionMonikerForFieldCode(mBoDRow.GetFieldCode('DocRowBatches'));
                mBoDDocRowBatch := mBoDDocRowBatches.AddNewObject;
                mBoDDocRowBatch.SetFieldValueAsString('StoreBatch_ID', dtLSPContents.FieldByName('StoreBatch_ID').AsString);
                mBoDDocRowBatch.SetFieldValueAsString('QUnit', dtLSPContents.FieldByName('QUnit').AsString);
                mBoDDocRowBatch.SetFieldValueAsFloat('Quantity', dtLSPContents.FieldByName('Quantity').AsFloat);
              end;
            end;
          end
          else
          begin
            mBoDRow := mBoDRows.AddNewObject;
            mBoDRow.SetFieldValueAsInteger('RowType', 3);
            mBoDRow.SetFieldValueAsString('Store_ID', dtLSPContents.FieldByName('Store_ID').AsString);
            mBoDRow.SetFieldValueAsString('StoreCard_ID', dtLSPContents.FieldByName('StoreCard_ID').AsString);
            mBoDRow.SetFieldValueAsString('QUnit', dtLSPContents.FieldByName('QUnit').AsString);
            mBoDRow.SetFieldValueAsFloat('Quantity', dtLSPContents.FieldByName('Quantity').AsFloat);
            mBoDRow.SetFieldValueAsString('Division_ID', STREDISKO_HLAVNI);

            // pridam sarzi, nebo seriove cislo
            if mBoDRow.GetFieldValueAsInteger('StoreCard_ID.Category') in [1, 2] then
            begin
              mBoDDocRowBatches := mBoDRow.GetLoadedCollectionMonikerForFieldCode(mBoDRow.GetFieldCode('DocRowBatches'));
              mBoDDocRowBatch := mBoDDocRowBatches.AddNewObject;
              mBoDDocRowBatch.SetFieldValueAsString('StoreBatch_ID', dtLSPContents.FieldByName('StoreBatch_ID').AsString);
              mBoDDocRowBatch.SetFieldValueAsString('QUnit', dtLSPContents.FieldByName('QUnit').AsString);
              mBoDDocRowBatch.SetFieldValueAsFloat('Quantity', dtLSPContents.FieldByName('Quantity').AsFloat);
            end;
          end;

          // ulozim udaje o zpracovanem radku
          mLastStore_ID := dtLSPContents.FieldByName('Store_ID').AsString;
          mLastStoreCard_ID := dtLSPContents.FieldByName('StoreCard_ID').AsString;
          mLastStoreBatch_ID := dtLSPContents.FieldByName('StoreBatch_ID').AsString;

          dtLSPContents.Next;
        end;

        mBoD.Save;

        afterSaveHook(Self.ObjectSpace, mModule, mUser_Id, mBoD, 0, json, dtJsonRows);

        ChangeStatusByRule(mBoD, PRECHOD_VYTVORENI(mDocType, mModule));

        // vytvorime polohovak
        if dtLSPContents.RecordCount > 0 then
          if CreateLogStoreDocument(Self.ObjectSpace, mModule, mDocType, mUser_Id, '', mBoD, json, dtJsonRows, dtLSPContents) then
            mLSD_ID := REST_Create_LogStoreDocument(Self.ObjectSpace, mBoD, '',
              Class_LogStoreOutput,
              GetDocQueueForDocument(Self.ObjectSpace, mModule, DOC_LogStoreOutput, mUser_ID, LogStoreOutput_DocQueue_ID, mDocType, mBoD),
              LogStoreOutput_StoreGateway_ID, dtLSPContents, mUser_Id,
              False, gLog);
      finally
        mBoD.Free;
      end;

      // vymaz z TemporaryStorage jeste v transakci
      TemporaryStorage_Delete(Self.ObjectSpace, mTemporaryStorageID);

      Request_Finish(Self.ObjectSpace, mRequestID);

      Self.ObjectSpace.Commit;

      HTTPResponse(AResponse, HTTP_SC_OK, ContentType_JSON, PlainResponse(''));
    except
      Self.ObjectSpace.RollBack;
      ErrREST(ARequest, AResponse, HTTP_SC_ExpectationFailed, getString('error_while_dispatch_whole_position') + ExceptionMessage);
      Request_Cancel(Self.ObjectSpace, mRequestID);
      glog.WriteEvent(logError, 'PutDispatchWholePosition - error - ' + ExceptionMessage);
    end;

    // polohovaky potvrdime az mimo hlavni transakci
    ConfirmLSD(Self.ObjectSpace, Class_LogStoreOutput, mLSD_ID, 'PutDispatchWholePosition', gLog);
  finally
    json.Free;
    dtJsonRows.Free;
    dtLSPContents.Free;
    mSL.Free;
    LogWriteSectionEnd;
  end;
end;
///////////////////////////////////////////////////////////////////////////////

begin
end.