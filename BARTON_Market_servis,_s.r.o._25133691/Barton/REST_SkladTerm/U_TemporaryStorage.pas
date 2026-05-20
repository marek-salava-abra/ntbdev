uses
  'REST_SkladTerm.U_Const',
  'REST_SkladTerm.U_Func',
  'REST_SkladTerm.U_FuncJSON',
  'REST_SkladTerm_Special.U_Const',
  'StandardUnits.U_GetId';

const
  TempStorageStatus_OPEN   = 0; //otevreny (rozpracovany) doklad
  TempStorageStatus_SAVED  = 1; //ulozeno
  TempStorageStatus_STORNO = 2; //smazano uzivatelem ve ctecce
  TempStorageStatus_DELETE = 3; //smazano sysemem ve vyjmecnych pripadech (viz kod)
  TempStorageStatus_PAUSED = 4; //rozpracovano, ale uzivatel na dokladu aktualne nepracuje

// tato procedura umi ulozit velka Data
// pokud jsou Data vetsi nez limit, rozdeli si je na dilky a ty postupne pridava
procedure UpdateInPieces(AOS: TNxCustomObjectSpace; AData: String; ADocID: Integer);
var
  sql, mDataPiece: String;
  mInTransaction: Boolean;
begin
  // uzavreme do transakce, aby bylo atomicke
  mInTransaction := AOS.InTransaction;
  if not mInTransaction then
    AOS.StartTransaction(taReadCommited);
  try
    // nejdriv vycistime
    sql:=
      'UPDATE ' + REST_TABLE_TemporaryStorage + ' SET' + nxCrLf +
      'Data = ' + QuotedStr('') + ',' + nxCrLf +
      'Date$Date = ' + NxFloatToIBStr(Now) + nxCrLf +
      'WHERE ID = ' + IntToStr(ADocID);
    AOS.SQLExecute(sql);

    repeat
      mDataPiece := copy(AData, 1, MaxTemporaryStorageDataLength);
      AData := copy(AData, MaxTemporaryStorageDataLength + 1, length(ADAta));
      sql:=
        'UPDATE ' + REST_TABLE_TemporaryStorage + ' SET ' + nxCrLf +
        'Data = Data ' + CONCAT_STR + QuotedStr(mDataPiece) + ',' + nxCrLf +
        'Date$Date = ' + NxFloatToIBStr(now) + nxCrLf +
        'WHERE ID = ' + IntToStr(ADocID);
      AOS.SQLExecute(sql);
    until NxIsBlank(AData);

    if not mInTransaction then
      AOS.Commit;
  except
    if not mInTransaction then
      AOS.RollBack;
    RaiseException(ExceptionMessage);
  end;
end;

procedure Get_TemporaryStorage(AOS: TNxCustomObjectSpace; APath, AResponse: TStringList);
var
  mSql: String;
  mData: TMemTable;
  mTempId: Integer;
begin
  mTempId := -1;
  if (APath.Count = 1) or (APath.Count = 2) then
  begin
    if APath.Count = 2 then
      mTempId := StrToInt(APath.Strings[1]);
  end
  else
  begin
    SetPlainResponse(AResponse, getString('wrong_parameters_count'), HTTP_SC_BadRequest);
    exit;
  end;

  mData := TMemTable.Create(nil);
  try
    // nejdrive kontrola, zda uzivatel nema rozpracovane doklady v jinych scenarich
    if OnlyOneScenarioWork then
    begin
      mSql :=
        'select' + FIRST_TOP(1) + nxCrLf +
        '  ID "ID",' + nxCrLf +
        '  DataType "DataType"' + nxCrLf +
        'from ' + REST_TABLE_TemporaryStorage + nxCrLf +
        'where' + nxCrLf +
        '  (Status = ' + IntToStr(TempStorageStatus_OPEN) + nxCrLf +
        '    or Status = ' + IntToStr(TempStorageStatus_PAUSED) + ')' + nxCrLf +
        '  and User_ID = ' + QuotedStr(gSkladTermUser_ID) + nxCrLf +
        '  and DataType <> ' + QuotedStr(gSkladTermModule) + nxCrLf;
      FIRST_TOP_ORACLE(1);
      AOS.SQLSelect2(mSql, mData);

      if mData.Active and (mData.RecordCount > 0) then
      begin
        SetPlainResponse(AResponse, Format(getString('finish_another_scenario'),
          [mData.FieldByName('DataType').AsString]), HTTP_SC_ExpectationFailed);
        exit;
      end;
    end;
  finally
    mData.free;
  end;

  mData := TMemTable.Create(nil);
  try
    mSql :=
      'select ' + FIRST_TOP(1) + ' ID as "id", DataType as "DataType", Status as "Status", Data as "data"' + nxCrLf +
      'from ' + REST_TABLE_TemporaryStorage + nxCrLf +
      'where' + nxCrLf;

    if mTempId >= 0 then
        mSql := mSql + nxCrLf +
          '  ID = ' + IntToStr(mTempId) + nxCrLf
    else
      mSql := mSql + nxCrLf +
        '  DataType = ' + QuotedStr(gSkladTermModule) + nxCrLf +
        '  and Status in (' + IntToStr(TempStorageStatus_OPEN) + ', ' + IntToStr(TempStorageStatus_PAUSED) + ')' + nxCrLf +
        '  and User_ID = ' + QuotedStr(gSkladTermUser_ID);

    mSql := mSql +
      'order by id desc' +
      FIRST_TOP_ORACLE(1);

    AOS.SQLSelect2(mSql, mData);

    if mData.Active then
    begin
      // musim nastavit, ze se na dokladu zase zacalo pracovat
      if (mData.FieldByName('id').AsInteger > -1) and (mData.FieldByName('Status').AsInteger = TempStorageStatus_PAUSED) then
      begin
        mSql :=
          'UPDATE ' + REST_TABLE_TemporaryStorage + ' SET ' + nxCrLf +
          '  Status = ' + IntToStr(TempStorageStatus_OPEN) + ',' + nxCrLf +
          '  Date$Date = ' + NxFloatToIBStr(now) + ',' + nxCrLf +
          '  User_ID = ' + QuotedStr(gSkladTermUser_ID) + nxCrLf +
          'where id = ' + IntToStr(mData.FieldByName('id').AsInteger);
        AOS.SQLExecute(mSql);
      end;
      SetResponse(AResponse, mData.FieldByName('Data').AsString);
    end
    else
      SetResponse(AResponse, '{}');
  finally
    mData.free;
  end;
end;

//slouzi k vyhledani otevreneho (rozpracovaneho) dokladu pozadovaneho typu
//pro konkretniho uzivatele. pokud jich existuje vice (nemelo by se stavat),
//vezme se ten nejnovejsi (s nejvetcim cislem)
(*procedure get_TemporaryStorage(AOS: TNxCustomObjectSpace; APath, AResponse: TStringList);
var
  sdData: TMemTable;
  dataType, mSql, Document_ID, mTempId: String;
  mId: Integer;
  user_ID: String;
  mJSON_Root: TJSONSuperObject;

begin
  if (APath.Count >= 3) or (APath.Count <= 5) then
  begin
    dataType := APath.Strings[1];
    user_ID := APath.Strings[2];
    if APath.Count >= 4 then
      Document_ID := APath.Strings[3];
    if APath.Count = 5 then
      mTempId := APath.Strings[4];
  end
  else
  begin
    SetPlainResponse(AResponse, getString('wrong_parameters_count'), HTTP_SC_BadRequest);
    exit;
  end;

  sdData:= TMemTable.Create(nil);
  try
    // nejdrive kontrola, zda uzivatel nema rozpracovane doklady v jinych scenarich
    if OnlyOneScenarioWork then
    begin
      mSql :=
        'SELECT' + FIRST_TOP(1) + nxCrLf +
        '  Id "ID",' + nxCrLf +
        '  DataType "DataType"' + nxCrLf +
        'from ' + REST_TABLE_TemporaryStorage + nxCrLf +
        'where' + nxCrLf +
        '  (Status = ' + IntToStr(TempStorageStatus_OPEN) + nxCrLf +
        '    or Status = ' + IntToStr(TempStorageStatus_PAUSED) + ')' + nxCrLf +
        '  and User_ID = ' + QuotedStr(user_ID) + nxCrLf +
        '  and DataType <> ' + QuotedStr(dataType) + nxCrLf;
      FIRST_TOP_ORACLE(1);
      AOS.SQLSelect2(mSql, sdData);

      if sdData.Active and (sdData.RecordCount > 0) then
      begin
        SetPlainResponse(AResponse, Format(getString('finish_another_scenario'),
          [sdData.FieldByName('DataType').AsString]), HTTP_SC_ExpectationFailed);
        exit;
      end;
    end;
  finally
    sdData.free;
  end;

  sdData:= TMemTable.Create(nil);
  try
    mSql :=
      'SELECT ' + FIRST_TOP(1) + ' Id, DataType, Data, Status' + nxCrLf +
      'from ' + REST_TABLE_TemporaryStorage + nxCrLf +
      'where' + nxCrLf +
      '  DataType = ' + QuotedStr(dataType) + nxCrLf +
      '  and ((Status = ' + IntToStr(TempStorageStatus_OPEN) + nxCrLf +
      '      and User_ID = ' + QuotedStr(user_ID) + ')';

    if not NoncancelableWork then
      mSql := mSql +
        ')' + nxCrLf
    else
    begin
      mSql := mSql + nxCrLf +
        '  or (Status = ' + IntToStr(TempStorageStatus_PAUSED);

      if NoncancelableWorkOnlyOneUser then
        mSql := mSql + nxCrLf +
          '  and User_ID = ' + QuotedStr(user_ID);

      mSql := mSql +
        '))' + nxCrLf;

      if not CFxOID.IsEmpty(Document_ID) then
        mSql := mSql + nxCrLf +
          ' and Document_ID = ' + QuotedStr(Document_ID) + nxCrLf
      else if not CFxOID.IsEmpty(mTempId) then
        mSql := mSql + nxCrLf +
          ' and ID = ' + mTempId + nxCrLf;
    end;

    mSql := mSql +
      'order by id desc' +
      FIRST_TOP_ORACLE(1);

    AOS.SQLSelect2(mSql, sdData);

    //###################
    //DOCASNE OSETRENI !!!
    //pokud je to zaznam s praznejma datama, tak jej smazu
    if sdData.Active and (sdData.RecordCount = 1) then
    begin
      sdData.First;

      mSql :=
        'UPDATE ' + REST_TABLE_TemporaryStorage + ' SET ' + nxCrLf +
        '  Status = ' + IntToStr(TempStorageStatus_DELETE) + ',' + nxCrLf +
        '  Date$Date = ' + NxFloatToIBStr(now) + nxCrLf +
        'where id = ' + IntToStr(sdData.FieldByName('id').AsInteger);

      if sdData.FieldByName('Data').AsString <> '' then
      begin
        mJSON_Root := TJSONSuperObject.ParseString(sdData.FieldByName('Data').AsString, True);
        try
          //gLog.WriteEventFmt(logDebug, '1a:%s', [sdData.FieldByName('Data').AsString]);
          //gLog.WriteEventFmt(logDebug, '1b:%s', [TlkJSON.GenerateText(mJSON_Root)]);
          //gLog.WriteEventFmt(logDebug, '2:%s', [getJSONStr(mJSON_Root, 'data')]);
          //gLog.WriteEventFmt(logDebug, '3:%s', [mJSON_Root.Field['data'].Value]);
          if(mJSON_Root.S['data'] = '-') then
          begin
            AOS.SQLExecute(mSql);
            sdData.EmptyTable;
          end
          else
          begin
            if sdData.FieldByName('Status').AsInteger = TempStorageStatus_PAUSED then
            begin
              mSql :=
                'UPDATE ' + REST_TABLE_TemporaryStorage + ' SET ' + nxCrLf +
                '  Status = ' + IntToStr(TempStorageStatus_OPEN) + ',' + nxCrLf +
                '  Date$Date = ' + NxFloatToIBStr(now) + ',' + nxCrLf +
                '  User_ID = ' + QuotedStr(user_ID) + nxCrLf +
                'where id = ' + IntToStr(sdData.FieldByName('id').AsInteger);
              AOS.SQLExecute(mSql);
            end;
          end;
        finally
          mJSON_Root.free;
        end;
      end
      else
      begin
        AOS.SQLExecute(mSql);
        sdData.EmptyTable;
      end;
    end;
    //###################
    //--------------------------------------------------------------------------

    // vzdy vracime objekt TemporaryStorage, pokud jsme nasli radek v DB, naplnime skutecna data do pole "data"
    if sdData.Active and (sdData.RecordCount = 1) then
      SetResponse(AResponse, sdData.FieldByName('Data').AsString)
    else
      SetResponse(AResponse, '{}');
  finally
    sdData.free;
  end;
end;*)

function TemporaryStorage_Create(AOS: TNxCustomObjectSpace; ADataType: String; AUser_ID, ADoc_ID: String): Integer;
var
  mSql, dataUTF: String;
  json: TJSONSuperObject;
  mDocId: Integer;
begin
  mSql :=
    'INSERT INTO ' + REST_TABLE_TemporaryStorage + nxCrLf +
    '  (User_ID, Document_ID, DataType, Status, Data, Date$Date)' + nxCrLf +
    'VALUES ('+
    '  ' + QuotedStr(AUser_ID) + ',' + nxCrLf +
    '  ' + QuotedStr(ADoc_ID) + ',' + nxCrLf +
    '  ' + QuotedStr(ADataType) + ',' + nxCrLf +
    '  ' + IntToStr(TempStorageStatus_OPEN) + ',' + nxCrLf +
    '  ' + QuotedStr('') + ',' + nxCrLf +
    '  ' + NxFloatToIBStr(Now)+ nxCrLf +
    ')';
  AOS.SQLExecute(mSql);

  //vytahnu si pridelene id (unikat zaznamu)
  mSql :=
    'select' + nxCrLf +
    '  id' + nxCrLf +
    'from ' + REST_TABLE_TemporaryStorage + nxCrLf +
    'where' + nxCrLf +
    '  Status = ' + IntToStr(TempStorageStatus_OPEN) + nxCrLf +
    '  and User_ID = ' + QuotedStr(AUser_ID) + nxCrLf +
    '  and DataType = ' + QuotedStr(ADataType) + nxCrLf;

  // oracle povazuje '' za null
  if DB_TYPE in [2, 3, 4] then
  begin
    mSql := mSql + ' and data is null' + nxCrLf;
    if CFxOID.IsEmpty(ADoc_ID) then
      mSql := mSql + '  and Document_ID is null'
    else
      mSql := mSql + '  and Document_ID = ' + QuotedStr(ADoc_ID);
  end
  else
  begin
    mSql := mSql +
      ' and data = ''''' + nxCrLf +
      '  and Document_ID = ' + QuotedStr(ADoc_ID);
  end;

  mDocId := SQLSelectInt(AOS, mSql);
  //nedostal jsem zadny zaznam - toto by se nemelo stat
  if (mDocId = 0) then
    RaiseException(getString('error_saving_document'));

  Result := mDocId;
end;

procedure TemporaryStorage_Update(AOS: TNxCustomObjectSpace; ATempId: Integer; AData: String);
var
  mSql, dataUTF: String;
  json: TJSONSuperObject;
begin
  if (ATempId < 1)then
    RaiseException(getString('error_invalid_temporary_storage_id'));

  // tato funkce se vola primo ze skriptu, kde neni v JSONu obalujici objekt, tak tuto obalku nejdriv pridame
  // AData musime zaescapovat pro JSON
  json := TJSONSuperObject.CreateByDataType(jtObject);
  try
    json.I['id'] := 0;
    json.S['data'] := AData;
    AData := json.AsJson(false, true);
  finally
    json.free;
  end;

  json := TJSONSuperObject.ParseString(AData, True);
  try
    //nastavim id
    json.I['id'] := ATempId;
    dataUTF := json.AsJson;

    //aktualizuju novy zaznam
    UpdateInPieces(AOS, dataUTF, ATempId);
  finally
    json.free;
  end;
end;

procedure TemporaryStorage_ChangeStatus(AOS: TNxCustomObjectSpace; AID, AStatus: Integer);
begin
  AOS.SQLExecute(
    'UPDATE ' + REST_TABLE_TemporaryStorage + ' SET ' + nxCrLf +
    '  Status = ' + IntToStr(AStatus) + ',' + nxCrLf +
    '  Date$Date = ' + NxFloatToIBStr(Now) + nxCrLf +
    'where' + nxCrLf +
    '  ID = ' + IntToStr(AID)
  );
end;

procedure TemporaryStorage_Finish(AOS: TNxCustomObjectSpace; AID: Integer);
begin
  TemporaryStorage_ChangeStatus(AOS, AID, TempStorageStatus_SAVED);
end;

procedure TemporaryStorage_Delete(AOS: TNxCustomObjectSpace; AID: Integer);
begin
  TemporaryStorage_ChangeStatus(AOS, AID, TempStorageStatus_STORNO);
end;

procedure TemporaryStorage_Pause(AOS: TNxCustomObjectSpace; AID: Integer);
begin
  TemporaryStorage_ChangeStatus(AOS, AID, TempStorageStatus_PAUSED);
end;

//update zaznamu podle ID
procedure put_TemporaryStorage(AOS: TNxCustomObjectSpace; APath: TStringList; ABody: String; AResponse: TStringList);
var
  mChangeType: String;
  slSql: TStringList;
  docId: Integer;
begin
  if(APath.Count = 3) then
  begin
    docId := StrToIntDef(APath.Strings[1], -1);
    mChangeType := APath.Strings[2];
  end
  else
  begin
    SetPlainResponse(AResponse, getString('wrong_parameters_count'), HTTP_SC_BadRequest);
    exit;
  end;

  //neposlal jsem si cislo dokladu
  if(docId = -1)then
  begin
    SetPlainResponse(AResponse, getString('error_invalid_temporary_storage_id'), HTTP_SC_BadRequest);
    exit;
  end;

  // muzu mazat, pozastavit nebo aktualizovat
  if(mChangeType = 'A') then
  begin
    TemporaryStorage_Delete(AOS, docId);
    SetResponse(AResponse, '{}', ContentType_JSON, HTTP_SC_Accepted);
    exit;
  end
  else if (mChangeType = 'P') then
  begin
    TemporaryStorage_Pause(AOS, docId);
    SetResponse(AResponse, '{}', ContentType_JSON, HTTP_SC_Accepted);
    exit;
  end;

  //aktualizace zaznamu
  //dotaz a odpoved
  slSql := TStringList.Create;
  try
    try
      //zjistim stav zaznamu
      AOS.SQLSelect(
        'SELECT status from ' + REST_TABLE_TemporaryStorage + nxCrLf +
        'where ID = ' + IntToStr(docId)
        , slSql
      );

      //mam zaznam?
      if(slSql.Count = 0)then begin
        //nemam - chyba - toto by se stat nemelo - zaznamy nemazu
        RaiseException(Format(getString('document_not_found'), [IntToStr(docId)]));

      end else if(StrToInt(slSql.strings[0]) = TempStorageStatus_SAVED)then begin
        //pokud jiz bylo ulozeno, tak chyba. Jinak dovolim ulozit
        RaiseException(Format(getString('document_already_saved'), [IntToStr(docId)]));
      end;

//###########
//DOCASNE OSETRENI !!!! neukladam text delsi nez 30k. Bori to pamet
//gLog.WriteEventFmt(logDebug, 'TemporaryStorage-PUT:LenData=%d', [Length(contentS)]);
//if(Length(contentS)> MAX_DATA_LEN)then begin
//  gLog.WriteEventFmt(logDebug, 'TemporaryStorage-PUT:MaxLenData:%s', [contentS]);
//  HTTPResponse(AResponse, HTTP_SC_Created, ContentType_JSON, '{}' {contentS}, false);
//  exit;
//end;
//###########

      //aktualizuju data
      UpdateInPieces(AOS, ABody, DocId);
      {sql:=
        'UPDATE '+TABLE_RestTemporaryStorage+' SET '+
        'Data = '+QuotedStr(contentS)+', '+
        'Date$Date = '+NxFloatToIBStr(now)+' '+
        'WHERE ID = '+IntToStr(docId);
      gLog.WriteEventFmt(logDebug, 'TemporaryStorage-sql update:%s', [sql]);
      Self.ObjectSpace.SQLExecute(sql);  }
      //--------------------------------------------------------------------------

      SetResponse(AResponse, '', ContentType_PlainText, HTTP_SC_Created);
    except
      SetPlainResponse(AResponse, ExceptionMessage, HTTP_SC_ExpectationFailed);
    end;
  finally
    slSql.free;
  end;
  //--------------------------------------------------------------------------
end;

begin
end.