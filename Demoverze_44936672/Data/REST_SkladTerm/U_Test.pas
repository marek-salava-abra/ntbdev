(*uses
  'REST_SkladTerm.U_Func',
  'REST_SkladTerm.U_FuncJSON',
  'REST_SkladTerm.U_Translation',
  'REST_SkladTerm_Special.U_Const',
  'StandardUnits.U_DataSet';

procedure PutCreateOutgoingSubstitution(Self: TNxWebServicesHelper; ARequest: TNxHTTPRequest;
  AResponse: TNxHTTPResponse; slPath: TStringList);
var
  mOS: TNxCustomObjectSpace;
  jsonString, mUser_Id, mModule, mDocType: String;
begin
  mUser_Id := getHeaderValue(ARequest, 'UserID');
  mModule := getHeaderValue(ARequest,'ModuleCode');
  mDocType := getHeaderValue(ARequest, 'DocumentType');

  mOS := Self.ObjectSpace;

  LogWriteSectionStart('PutCreateOutgoingSubstitution');

  //dtLogStoreDocument := TMemTable.Create(nil);
  try
    // dataset pro funkci Create_LogStoreDocument
    {DataSet_CreataHeader(dtLogStoreDocument, 'Store_ID=S10,StoreCard_ID=S10,StoreBatch_ID=S10,StorePosition_ID=S10,Quantity=F');
    dtLogStoreDocument.AddIndex('I0', 'Store_ID;StoreCard_ID;StoreBatch_ID;StorePosition_ID', [ixUnique]);
    dtLogStoreDocument.IndexName:= 'I0';
    dtLogStoreDocument.Open;}

    mOS.StartTransaction(taReadCommited);
    try
      CreateOutgoingSubstitution(mOS, mModule);

      // vymaz z TemporaryStorage jeste v transakci
      {TemporaryStorage_Delete(mOS, mTemporaryStorageID);

      Request_Finish(mOS, mRequestID);}

      mOS.Commit;

      HTTPResponse(AResponse, HTTP_SC_OK, ContentType_JSON, PlainResponse(''));
    except
      mOS.RollBack;
      ErrREST(ARequest, AResponse, HTTP_SC_InternalServerError, getString('error_saving') + ExceptionMessage);
      //Request_Cancel(mOS, mRequestID);
      //LogWriteSectionEnd;
      exit;
    end;

    //HTTPResponse(AResponse, HTTP_SC_OK, ContentType_JSON, PlainResponse('OK'));
  finally
    //dtJSONRows.Free;
    //dtLogStoreDocument.Free;
  end;
  LogWriteSectionEnd;
end;

procedure CreateOutgoingSubstitution(AOS: TNxCustomObjectSpace; AModule: String);
var
  json: TJSONSuperObject;
  jsonBatches: TJSONSuperObjectArray;
  dtJSONRows, dtLogStoreDocument: TMemTable;
  mSD, mSDRow, mDocRowBatch: TNxCustomBusinessObject;
  mSDRows, mDocRowBatches: TNxCustomBusinessMonikerCollection;
  i: integer;
begin
  mSD := AOS.CreateObject(Class_OutgoingSubstitution);
  try
    mSD.ExplicitTransaction := True;

    // vytvorime doklad
    mSD.New;
    mSD.Prefill;
    mSD.SetFieldValueAsString('DocQueue_ID', DOC_OutgoingSubstitution);
    mSD.SetFieldValueAsString('Firm_ID', FIRM_OWN);
    mSD.SetFieldValueAsString('Description', 'TEST');
    mSDRows := mSD.GetCollectionMonikerForFieldCode(mSD.GetFieldCode('Rows'));

    // bez sarze
    mSDRow := mSDRows.AddNewObject;
    mSDRow.Prefill;
    mSDRow.SetFieldValueAsInteger('RowType', 3);
    mSDRow.SetFieldValueAsString('Store_ID', '2100000101');
    mSDRow.SetFieldValueAsString('StoreCard_ID', '3100000101');
    mSDRow.SetFieldValueAsString('Division_ID', STREDISKO_HLAVNI);
    mSDRow.SetFieldValueAsFloat('Quantity', 5);

    // se sarzemi
    mSDRow := mSDRows.AddNewObject;
    mSDRow.Prefill;
    mSDRow.SetFieldValueAsInteger('RowType', 3);
    mSDRow.SetFieldValueAsString('Store_ID', '2100000101');
    mSDRow.SetFieldValueAsString('StoreCard_ID', '5100000101');
    mSDRow.SetFieldValueAsString('Division_ID', STREDISKO_HLAVNI);
    mSDRow.SetFieldValueAsFloat('Quantity', 5);

    // sarze
    {if mSDRow.GetFieldValueAsInteger('StoreCard_ID.Category') = 2 then
    begin
      mDocRowBatches := mSDRow.GetLoadedCollectionMonikerForFieldCode(mSDRow.GetFieldCode('DocRowBatches'));
      // musime do jsonu pro kolekci
      jsonBatches := json.A['rows'].O[dtJSONRows.FieldByName('jsonIndex').AsInteger].A['storeBatches'];
      for i := 0 to jsonBatches.Length - 1 do
      begin
        mDocRowBatch := mDocRowBatches.AddNewObject;
        mDocRowBatch.SetFieldValueAsString('StoreBatch_ID', jsonBatches.O[i].S['id']);
        //mDocRowBatch.SetFieldValueAsString('QUnit', mSDRow.GetFieldValueAsString('QUnit'));
        if(jsonBatches.O[i].D['quantity'] > 0) then
          mDocRowBatch.SetFieldValueAsFloat('UnitQuantity', jsonBatches.O[i].D['quantity'])
        else
          mDocRowBatch.SetFieldValueAsFloat('UnitQuantity', 1);
      end;
    end;}

    // se ser. cisly
    mSDRow := mSDRows.AddNewObject;
    mSDRow.Prefill;
    mSDRow.SetFieldValueAsInteger('RowType', 3);
    mSDRow.SetFieldValueAsString('Store_ID', '2100000101');
    mSDRow.SetFieldValueAsString('StoreCard_ID', '6100000101');
    mSDRow.SetFieldValueAsString('Division_ID', STREDISKO_HLAVNI);
    mSDRow.SetFieldValueAsFloat('Quantity', 5);

    // sarze a ser. cisla
    {if (mSDRow.GetFieldValueAsInteger('StoreCard_ID.Category') = 1)
      or (mSDRow.GetFieldValueAsInteger('StoreCard_ID.Category') = 2) then
    begin
      mDocRowBatches := mSDRow.GetLoadedCollectionMonikerForFieldCode(mSDRow.GetFieldCode('DocRowBatches'));
      // musime do jsonu pro kolekci
      jsonBatches := json.A['rows'].O[dtJSONRows.FieldByName('jsonIndex').AsInteger].A['storeBatches'];
      for i := 0 to jsonBatches.Length - 1 do
      begin
        mDocRowBatch := mDocRowBatches.AddNewObject;
        mDocRowBatch.SetFieldValueAsString('StoreBatch_ID', jsonBatches.O[i].S['id']);
        //mDocRowBatch.SetFieldValueAsString('QUnit', mSDRow.GetFieldValueAsString('QUnit'));
        if(jsonBatches.O[i].D['quantity'] > 0) then
          mDocRowBatch.SetFieldValueAsFloat('UnitQuantity', jsonBatches.O[i].D['quantity'])
        else
          mDocRowBatch.SetFieldValueAsFloat('UnitQuantity', 1);
      end;
    end;}

    //mSD.SetFieldValueAsString('Description', mSD.OID);
    mSD.ChangeStatus(STAV_K_VYSKLADNENI(DOC_OutgoingSubstitution, AModule), ROLE_VYSKLADNENO(DOC_PRI, AModule));
    //mSD.ChangeStatus('S200000001', 'EC00000001');

    // naplnime pomocny dataset pro vytvoreni polohovaku k PreVyd
    {dtDocumentQuantity.EmptyTable;
    dtJSONRows.First;
    while not dtJSONRows.EOF do
    begin
      if not CFxOID.IsEmpty(dtJSONRows.FieldByName(mStorePositionField).AsString) then
      begin
        AddTodtDocumentQuantity(dtDocumentQuantity,
          dtJSONRows.FieldByName(mStoreField).AsString,
          dtJSONRows.FieldByName('StoreCard_ID').AsString,
          NxIIfStr(CFxOID.IsEmpty(dtJSONRows.FieldByName('StoreBatch_ID').AsString), 'ZZZZZZZZZZ', dtJSONRows.FieldByName('StoreBatch_ID').AsString),
          dtJSONRows.FieldByName(mStorePositionField).AsString,
          dtJSONRows.FieldByName('UnitQuantity').AsFloat
        );
      end;
      dtJSONRows.Next;
    end;

    // vytvorime polohovak
    if dtDocumentQuantity.RecordCount > 0 then
      mLSD_ID := Create_LogStoreDocument(mOS, mSD, '',
        mLogStoreDocumentClass,
        mLogStoreDocument_DocQueue_ID,
        mLogStoreDocument_StoreGateway_ID, dtDocumentQuantity, mUser_Id,
        False, gLog);}
  finally
    mSD.Free;
  end;
end;

(*
{
  Odstrani rozpracovane doklady pro konkretniho uzivatele.
}
procedure removeWorkInProgress(Self: TNxWebServicesHelper; ARequest: TNxHTTPRequest;
  AResponse: TNxHTTPResponse; slPath: TStringList);
var
  mOS: TNxCustomObjectSpace;
  mSql, mUser_ID, mScenario: String;
  mList: TStringList;
  mCount: Integer;
begin
  LogWriteSectionStart('removeWorkInProgress');

  if (slPath.Count = 2) or (slPath.Count = 3) then
  begin
    mUser_ID := slPath.Strings[1];
    if slPath.Count = 3 then
      mScenario := slPath.Strings[2];
  end else
  begin
    ErrREST(ARequest, AResponse, HTTP_SC_BadRequest, getString('wrong_parameters_count'));
    exit;
  end;

  mOS := Self.ObjectSpace;
  mOS.StartTransaction(taReadCommited);
  try
    mSql :=
      'select ' +
      '  ID ' +
      'from ' + TABLE_RestTemporaryStorage + ' ' +
      'where ' +
      '  Status = 0 ' +
      '  and User_ID = ' + QuotedStr(mUser_ID);

    if mScenario <> '' then
      mSql := mSql + ' and DataType = ' + mScenario;

    mList := TStringList.Create;
    try
      mOS.SQLSelect(mSql, mList);

      mCount := mList.Count;
      if mList.Count > 0 then
      begin
        mList.Delimiter := ';';

        mSql :=
        'update ' + TABLE_RestTemporaryStorage + ' ' +
        'SET Status = 2 ' +
        'where ID in (''' + ReplaceStr(mList.DelimitedText, ';', ''', ''') + ''')';

        mOS.SQLExecute(mSql);
      end;
    finally
      mList.Free;
    end;

    mOS.Commit;
    HTTPResponse(AResponse, HTTP_SC_OK, ContentType_JSON, PlainResponse(IntToStr(mCount)));
  except
    mOS.RollBack;
  end;

  LogWriteSectionEnd;
end;

{
  Priprava dat pro scenar prijmu dle dokladu
}
procedure prepareReceiptCardDocQueueTest(Self: TNxWebServicesHelper; ARequest: TNxHTTPRequest;
  AResponse: TNxHTTPResponse; slPath: TStringList);
var
  mOS: TNxCustomObjectSpace;
  json: TJSONSuperObject;
  jsonBatches: TJSONSuperObjectArray;
  jsonString: String;
  dtJSONRows, dtLogStoreDocument: TMemTable;
  mSD, mSDRow, mDocRowBatch: TNxCustomBusinessObject;
  mSDRows, mDocRowBatches: TNxCustomBusinessMonikerCollection;
  i: integer;
begin
  mOS := Self.ObjectSpace;

  LogWriteSectionStart('prepareReceiptCardDocQueueTest');

  // protoze si posilam json jako string, tak si ho poladim
  jsonString := ReplaceStr(REST_ByteUTF82String(ARequest.Content.Content), '\"', '"');
  jsonString := copy(jsonString, 2, length(jsonString) - 2);
  json := TJSONSuperObject.ParseString(jsonString, True);

  dtJSONRows := TMemTable.Create(nil);
  dtLogStoreDocument := TMemTable.Create(nil);
  mSD := mOS.CreateObject(Class_ReceiptCard);
  try
    // dataset, do ktereho si preplnime polozky z JSONu
    DataSet_CreataHeader(dtJSONRows, 'jsonIndex=I,storeCard_id=S10,store_id=S100,quantity=F');
    dtJSONRows.AddIndex('ByJsonIndex', 'jsonIndex', [ixUnique]);
    dtJSONRows.Open;
    JsonToDataSet(json.A['rows'], dtJSONRows);

    // dataset pro funkci Create_LogStoreDocument
    DataSet_CreataHeader(dtLogStoreDocument, 'Store_ID=S10,StoreCard_ID=S10,StoreBatch_ID=S10,StorePosition_ID=S10,Quantity=F');
    dtLogStoreDocument.AddIndex('I0', 'Store_ID;StoreCard_ID;StoreBatch_ID;StorePosition_ID', [ixUnique]);
    dtLogStoreDocument.IndexName:= 'I0';
    dtLogStoreDocument.Open;

    mOS.StartTransaction(taReadCommited);
    try
      mSD.ExplicitTransaction := True;

      // vytvorime doklad
      mSD.New;
      mSD.Prefill;
      mSD.SetFieldValueAsString('DocQueue_ID', json.S['docQueue_id']);
      mSD.SetFieldValueAsString('Firm_ID', json.S['firm_id']);
      mSD.SetFieldValueAsString('Description', json.S['description']);
      mSDRows := mSD.GetCollectionMonikerForFieldCode(mSD.GetFieldCode('Rows'));
      dtJSONRows.First;
      while not dtJSONRows.EOF do
      begin
        mSDRow := mSDRows.AddNewObject;
        mSDRow.Prefill;
        mSDRow.SetFieldValueAsInteger('RowType', 3);
        mSDRow.SetFieldValueAsString('Store_ID', dtJSONRows.FieldByName('store_id').AsString);
        mSDRow.SetFieldValueAsString('StoreCard_ID', dtJSONRows.FieldByName('storeCard_ID').AsString);
        //mSDRow.SetFieldValueAsString('QUnit', dtJSONRows.FieldByName('UnitCode').AsString);
        mSDRow.SetFieldValueAsString('Division_ID', STREDISKO_HLAVNI);
        mSDRow.SetFieldValueAsFloat('Quantity', dtJSONRows.FieldByName('quantity').AsFloat);

        // sarze a ser. cisla
        if (mSDRow.GetFieldValueAsInteger('StoreCard_ID.Category') = 1)
          or (mSDRow.GetFieldValueAsInteger('StoreCard_ID.Category') = 2) then
        begin
          mDocRowBatches := mSDRow.GetLoadedCollectionMonikerForFieldCode(mSDRow.GetFieldCode('DocRowBatches'));
          // musime do jsonu pro kolekci
          jsonBatches := json.A['rows'].O[dtJSONRows.FieldByName('jsonIndex').AsInteger].A['storeBatches'];
          for i := 0 to jsonBatches.Length - 1 do
          begin
            mDocRowBatch := mDocRowBatches.AddNewObject;
            mDocRowBatch.SetFieldValueAsString('StoreBatch_ID', jsonBatches.O[i].S['id']);
            //mDocRowBatch.SetFieldValueAsString('QUnit', mSDRow.GetFieldValueAsString('QUnit'));
            if(jsonBatches.O[i].D['quantity'] > 0) then
              mDocRowBatch.SetFieldValueAsFloat('UnitQuantity', jsonBatches.O[i].D['quantity'])
            else
              mDocRowBatch.SetFieldValueAsFloat('UnitQuantity', 1);
          end;
        end;

        dtJSONRows.Next;
      end;
      mSD.SetFieldValueAsString('Description', mSD.OID);
      mSD.ChangeStatus(STAV_K_VYSKLADNENI(DOC_PRI), ROLE_VYSKLADNENO(DOC_PRI));
      //mSD.ChangeStatus('S200000001', 'EC00000001');

      // naplnime pomocny dataset pro vytvoreni polohovaku k PreVyd
      {dtDocumentQuantity.EmptyTable;
      dtJSONRows.First;
      while not dtJSONRows.EOF do
      begin
        if not CFxOID.IsEmpty(dtJSONRows.FieldByName(mStorePositionField).AsString) then
        begin
          AddTodtDocumentQuantity(dtDocumentQuantity,
            dtJSONRows.FieldByName(mStoreField).AsString,
            dtJSONRows.FieldByName('StoreCard_ID').AsString,
            NxIIfStr(CFxOID.IsEmpty(dtJSONRows.FieldByName('StoreBatch_ID').AsString), 'ZZZZZZZZZZ', dtJSONRows.FieldByName('StoreBatch_ID').AsString),
            dtJSONRows.FieldByName(mStorePositionField).AsString,
            dtJSONRows.FieldByName('UnitQuantity').AsFloat
          );
        end;
        dtJSONRows.Next;
      end;

      // vytvorime polohovak
      if dtDocumentQuantity.RecordCount > 0 then
        mLSD_ID := Create_LogStoreDocument(mOS, mSD, '',
          mLogStoreDocumentClass,
          mLogStoreDocument_DocQueue_ID,
          mLogStoreDocument_StoreGateway_ID, dtDocumentQuantity, mUser_Id,
          False, gLog);

      // vymaz z TemporaryStorage jeste v transakci
      TemporaryStorage_Delete(mOS, mTemporaryStorageID);

      Request_Finish(mOS, mRequestID);}

      mOS.Commit;

      HTTPResponse(AResponse, HTTP_SC_OK, ContentType_JSON, PlainResponse(mSD.OID));
    except
      mOS.RollBack;
      ErrREST(ARequest, AResponse, HTTP_SC_InternalServerError, getString('error_saving') + ExceptionMessage);
      //Request_Cancel(mOS, mRequestID);
      //LogWriteSectionEnd;
      exit;
    end;

    //HTTPResponse(AResponse, HTTP_SC_OK, ContentType_JSON, PlainResponse('OK'));
  finally
    dtJSONRows.Free;
    mSD.Free;
    dtLogStoreDocument.Free;
  end;
  LogWriteSectionEnd;
end;

procedure receiptCardWithoutDocTest(Self: TNxWebServicesHelper; ARequest: TNxHTTPRequest;
  AResponse: TNxHTTPResponse; slPath: TStringList);
var
  mUser_Id, mModule, mSql, mDoc_ID: String;
  mOS: TNxCustomObjectSpace;
  mSD: TNxCustomBusinessObject;
  json: TJSONSuperObject;
  dtJSONRows, dtDocumentRows: TMemTable;
begin
  {if (slPath.Count = 2) then
  begin
    mDoc_ID := slPath.Strings[1]; //ocekavam ID skladoveho dokladu
  end else
  begin
    ErrREST(ARequest, AResponse, HTTP_SC_BadRequest, 'Nesprávný počet parametrů.');
    exit;
  end;}{

  mUser_Id := getHeaderValue(ARequest, 'UserID');
  mModule := getHeaderValue(ARequest,'ModuleCode');

  mOS := Self.ObjectSpace;

  LogWriteSectionStart('receiptCardWithoutDocTest');

  json := TJSONSuperObject.ParseString(REST_ByteUTF82String(ARequest.Content.Content), True);

  // dataset, do ktereho si preplnime polozky z JSONu
  DataSet_CreataHeader(dtJSONRows, 'jsonIndex=I,Store_ID=S10,StoreCard_ID=S10,StorePosition_ID=S10,IsOK=B,Quantity=F');
  dtJSONRows.AddIndex('ByJsonIndex', 'jsonIndex', [ixUnique]);
  dtJSONRows.Open;
  JsonToDataSet(json.A['rows'], dtJSONRows);

  mSql :=
    'select ' +
    '  SD2.Parent_ID as "XX_Parent_ID", ' +
    '  SD2.PosIndex as "PosIndex", ' +
    '  SD2.ID as "StoreDocument2_ID", ' +
    '  coalesce(DRB.ID, '''') as "DocRowBatch_ID", ' +
    '  coalesce(LSD2.ID, '''') as "LogStoreDocument2_ID", ' +
    '  S.ID as "Store_ID", ' +
    '  S.IsLogistic as "StoreIsLogistic$BOOL", ' +
    '  SC.ID as "StoreCard_ID", ' +
    '  SC.Category as "StoreCardCategory", ' +
    '  coalesce(LSD2.Quantity, DRB.Quantity, SD2.Quantity) / SD2.UnitRate as "UnitQuantity", ' +
    '  SD2.UnitRate as "UnitRate", ' +
    '  SD2.QUnit as "UnitCode", ' +
    '  coalesce(LSP.ID, '''') as "StorePositionFrom_ID", ' +
    '  coalesce(SB.ID, '''') as "StoreBatch_ID", ' +
    '  coalesce(LSD2.ID, '''') as "LogStoreDocument2_ID" ' +
    'from StoreDocuments2 SD2 ' +
    //'join StoreDocuments SD on SD.ID = SD2.Parent_ID' +
    'join Stores S on S.ID = SD2.Store_ID ' +
    'join StoreCards SC on SC.ID = SD2.StoreCard_ID ' +
    'left join DocRowBatches DRB on DRB.Parent_ID = SD2.ID ' +
    'left join StoreBatches SB on SB.ID = DRB.StoreBatch_ID ' +
    'left join LogStoreDocuments2 LSD2 on LSD2.StoreDocRow_ID = SD2.ID and coalesce(LSD2.StoreBatch_ID, '''') = coalesce(DRB.StoreBatch_ID, '''') ' +
    'left join LogStorePositions LSP on LSP.ID = LSD2.StorePosition_ID ' +
    'where SD2.Parent_ID = (select first 1 SD.ID from StoreDocuments SD order by SD.DocDate$DATE DESC)' +
    '  and SD2.RowType = 3 and SC.IsStockType = ''A'' ' +
    'order by SD2.PosIndex ';
  mOS.SQLSelect2(mSql, dtDocumentRows);



  HTTPResponse(AResponse, HTTP_SC_OK, ContentType_PlainText, 'OK');

  LogWriteSectionEnd;
end;


{
  Kontrola vysledku DOKLAD vs JSON
}
procedure checkResult(Self: TNxWebServicesHelper; ARequest: TNxHTTPRequest;
  AResponse: TNxHTTPResponse; slPath: TStringList);
var
  mOS: TNxCustomObjectSpace;
  json: TJSONSuperObject;
  jsonBatches: TJSONSuperObjectArray;
  jsonString, docId: String;
  dtJSONRows, dtLogStoreDocument: TMemTable;
  mSD, mSDRow, mDocRowBatch: TNxCustomBusinessObject;
  mSDRows, mDocRowBatches: TNxCustomBusinessMonikerCollection;
  i, j: integer;
  found: boolean;
begin
  LogWriteSectionStart('checkResult');
  try

    mOS := Self.ObjectSpace;

    // protoze si posilam json jako string, tak si ho poladim
    jsonString := ReplaceStr(REST_ByteUTF82String(ARequest.Content.Content), '\"', '"');
    jsonString := copy(jsonString, 2, length(jsonString) - 2);
    json := TJSONSuperObject.ParseString(jsonString, True);

    docId := slPath.Strings[1];

    dtJSONRows := TMemTable.Create(nil);
    dtLogStoreDocument := TMemTable.Create(nil);
    mSD := mOS.CreateObject(Class_ReceiptCard);
    try
      try
        // dataset, do ktereho si preplnime polozky z JSONu
        DataSet_CreataHeader(dtJSONRows, 'jsonIndex=I,storeCard_id=S10,store_id=S100,quantity=F');
        dtJSONRows.AddIndex('ByJsonIndex', 'jsonIndex', [ixUnique]);
        dtJSONRows.Open;
        JsonToDataSet(json.A['rows'], dtJSONRows);

        // dataset pro funkci Create_LogStoreDocument
        DataSet_CreataHeader(dtLogStoreDocument, 'Store_ID=S10,StoreCard_ID=S10,StoreBatch_ID=S10,StorePosition_ID=S10,Quantity=F');
        dtLogStoreDocument.AddIndex('I0', 'Store_ID;StoreCard_ID;StoreBatch_ID;StorePosition_ID', [ixUnique]);
        dtLogStoreDocument.IndexName:= 'I0';
        dtLogStoreDocument.Open;

        // nactu doklad
        mSD.Load(docId, nil);
        {mSD.SetFieldValueAsString('DocQueue_ID', json.S['docQueue_id']);
        mSD.SetFieldValueAsString('Firm_ID', json.S['firm_id']);
        mSD.SetFieldValueAsString('Description', json.S['description']);}

        // zacnu prochazet radky
        // jdu podle JSONu a hledam radky na dokladu. Plus na zacatku zkonstroluju pocet
        mSDRows := mSD.GetLoadedCollectionMonikerForFieldCode(mSD.GetFieldCode('Rows'));
        dtJSONRows.First;
        while not dtJSONRows.EOF do
        begin
          // nesedi pocet, to je chyba
          if mSDRows.Count <> dtJSONRows.RecordCount then
            RaiseException('Počet řádků JSON není shodný s počtem řádků na dokladu.');

          // projdu radky a porovnavam podle artiklu, mnozstvi
          found := false;
          for i := 0 to mSDRows.Count - 1 do
          begin
            mSDRow := mSDRows.BusinessObject(i);
            // kontroluju shodu artiklu a mnozstvi
            if (mSDRow.GetFieldValueAsString('StoreCard_ID') = dtJSONRows.FieldByName('storeCard_id').AsString)
              and (CFxFloat.Compare2(mSDRow.GetFieldValueAsFloat('Quantity'), dtJSONRows.FieldByName('quantity').AsFloat) = 0) then
            begin
              // pokud ma sarze nebo ser. cisla tak budu konstrolovat jejich shodu
              if (mSDRow.GetFieldValueAsInteger('StoreCard_ID.Category') = 1)
                or (mSDRow.GetFieldValueAsInteger('StoreCard_ID.Category') = 2) then
              begin
                mDocRowBatches := mSDRow.GetLoadedCollectionMonikerForFieldCode(mSDRow.GetFieldCode('DocRowBatches'));
                jsonBatches := json.A['rows'].O[dtJSONRows.FieldByName('jsonIndex').AsInteger].A['storeBatches'];
                for j := 0 to jsonBatches.Length - 1 do
                begin
                  mDocRowBatch := mDocRowBatches.AddNewObject;
                  mDocRowBatch.SetFieldValueAsString('StoreBatch_ID', jsonBatches.O[j].S['id']);
                  //mDocRowBatch.SetFieldValueAsString('QUnit', mSDRow.GetFieldValueAsString('QUnit'));
                  if(jsonBatches.O[i].D['quantity'] > 0) then
                    mDocRowBatch.SetFieldValueAsFloat('UnitQuantity', jsonBatches.O[j].D['quantity'])
                  else
                    mDocRowBatch.SetFieldValueAsFloat('UnitQuantity', 1);
                end;
              end
              else
                found := true;
            end
            else
              continue;
          end;

          if not found then
            RaiseException('Řádek z JSON nebyl na dokladu nalezen.');

          {// sarze a ser. cisla
          if (mSDRow.GetFieldValueAsInteger('StoreCard_ID.Category') = 1)
            or (mSDRow.GetFieldValueAsInteger('StoreCard_ID.Category') = 2) then
          begin
            mDocRowBatches := mSDRow.GetLoadedCollectionMonikerForFieldCode(mSDRow.GetFieldCode('DocRowBatches'));
            // musime do jsonu pro kolekci
            jsonBatches := json.A['rows'].O[dtJSONRows.FieldByName('jsonIndex').AsInteger].A['storeBatches'];
            for i := 0 to jsonBatches.Length - 1 do
            begin
              mDocRowBatch := mDocRowBatches.AddNewObject;
              mDocRowBatch.SetFieldValueAsString('StoreBatch_ID', jsonBatches.O[i].S['id']);
              //mDocRowBatch.SetFieldValueAsString('QUnit', mSDRow.GetFieldValueAsString('QUnit'));
              if(jsonBatches.O[i].D['quantity'] > 0) then
                mDocRowBatch.SetFieldValueAsFloat('UnitQuantity', jsonBatches.O[i].D['quantity'])
              else
                mDocRowBatch.SetFieldValueAsFloat('UnitQuantity', 1);
            end;
          end;}

          dtJSONRows.Next;
        end;
        {mSD.SetFieldValueAsString('Description', mSD.OID);
        mSD.ChangeStatus(STAV_K_VYSKLADNENI(DOC_PRI), ROLE_VYSKLADNENO(DOC_PRI));}
        //mSD.ChangeStatus('S200000001', 'EC00000001');

        // naplnime pomocny dataset pro vytvoreni polohovaku k PreVyd
        {dtDocumentQuantity.EmptyTable;
        dtJSONRows.First;
        while not dtJSONRows.EOF do
        begin
          if not CFxOID.IsEmpty(dtJSONRows.FieldByName(mStorePositionField).AsString) then
          begin
            AddTodtDocumentQuantity(dtDocumentQuantity,
              dtJSONRows.FieldByName(mStoreField).AsString,
              dtJSONRows.FieldByName('StoreCard_ID').AsString,
              NxIIfStr(CFxOID.IsEmpty(dtJSONRows.FieldByName('StoreBatch_ID').AsString), 'ZZZZZZZZZZ', dtJSONRows.FieldByName('StoreBatch_ID').AsString),
              dtJSONRows.FieldByName(mStorePositionField).AsString,
              dtJSONRows.FieldByName('UnitQuantity').AsFloat
            );
          end;
          dtJSONRows.Next;
        end;

        // vytvorime polohovak
        if dtDocumentQuantity.RecordCount > 0 then
          mLSD_ID := Create_LogStoreDocument(mOS, mSD, '',
            mLogStoreDocumentClass,
            mLogStoreDocument_DocQueue_ID,
            mLogStoreDocument_StoreGateway_ID, dtDocumentQuantity, mUser_Id,
            False, gLog);

        // vymaz z TemporaryStorage jeste v transakci
        TemporaryStorage_Delete(mOS, mTemporaryStorageID);

        Request_Finish(mOS, mRequestID);}

        HTTPResponse(AResponse, HTTP_SC_OK, ContentType_JSON, PlainResponse('OK'));
      except
        ErrREST(ARequest, AResponse, HTTP_SC_InternalServerError, ExceptionMessage);
      end;
    finally
      dtJSONRows.Free;
      mSD.Free;
      dtLogStoreDocument.Free;
    end;
  finally
    LogWriteSectionEnd;
  end;
end;


procedure idlingResourceTest(Self: TNxWebServicesHelper; ARequest: TNxHTTPRequest;
  AResponse: TNxHTTPResponse; slPath: TStringList);
var
  seconds: integer;
begin
  seconds := StrToInt(slPath.Strings[1]);
  Sleep(seconds * 1000);
  HTTPResponse(AResponse, HTTP_SC_OK, ContentType_JSON, PlainResponse('OK'));
end;*)

begin
end.