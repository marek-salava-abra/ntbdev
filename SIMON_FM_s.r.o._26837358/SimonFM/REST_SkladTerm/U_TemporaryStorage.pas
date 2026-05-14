uses
  'REST_SkladTerm.U_Const',
  'REST_SkladTerm.U_Func',
  'REST_SkladTerm.U_FuncJSON',
  'REST_SkladTerm_Special.U_Const',
  'REST_SkladTerm_Special.U_StandardHooks',
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
      '  Data = ' + QuotedStr('') + ',' + nxCrLf +
      '  Date$Date = ' + NxFloatToIBStr(Now) + ',' + nxCrLf +
      '  UpdateCount = UpdateCount + 1' + nxCrLf +
      'WHERE ID = ' + IntToStr(ADocID);
    AOS.SQLExecute(sql);

    repeat
      mDataPiece := copy(AData, 1, MaxTemporaryStorageDataLength);
      AData := copy(AData, MaxTemporaryStorageDataLength + 1, length(ADAta));
      sql:=
        'UPDATE ' + REST_TABLE_TemporaryStorage + ' SET ' + nxCrLf +
        '  Data = Data ' + CONCAT_STR + QuotedStr(mDataPiece) + ',' + nxCrLf +
        '  Date$Date = ' + NxFloatToIBStr(now) + ',' + nxCrLf +
        '  UpdateCount = UpdateCount + 1' + nxCrLf +
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
  mJson: TJSONSuperObject;
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
      'select ' + FIRST_TOP(1) + ' ID as "id", DataType as "DataType", Status as "Status", Filepath as "Filepath", Data as "data"' + nxCrLf +
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
          '  User_ID = ' + QuotedStr(gSkladTermUser_ID) + ',' + nxCrLf +
          '  UpdateCount = UpdateCount + 1' + nxCrLf +
          'where id = ' + IntToStr(mData.FieldByName('id').AsInteger);
        AOS.SQLExecute(mSql);
      end;

      if SaveTemporaryStorageOnDisk then
      begin
        mJson := TJSONSuperObject.ParseFile(mData.FieldByName('Filepath').AsString, True);
        try
          SetResponse(AResponse, mJson.AsJson);
        finally
          mJson.Free;
        end;
      end
      else
        SetResponse(AResponse, mData.FieldByName('Data').AsString);
    end
    else
      SetResponse(AResponse, '{}');
  finally
    mData.free;
  end;
end;

function TemporaryStorage_Create(AOS: TNxCustomObjectSpace; ADataType: String; AUser_ID, ADoc_ID: String): Integer;
var
  mSql, mPath: String;
  json: TJSONSuperObject;
  mDocId: Integer;
  mHandle: Int64;
  mInTransaction: Boolean;
begin
  mInTransaction := AOS.InTransaction;
  if not mInTransaction then
    AOS.StartTransaction(taReadCommited);
  try
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
      mSql := mSql +
        '  and data is null' + nxCrLf +
        '  and trim(Filepath) is null' + nxCrLf;

      if CFxOID.IsEmpty(ADoc_ID) then
        mSql := mSql + '  and Document_ID is null'
      else
        mSql := mSql + '  and Document_ID = ' + QuotedStr(ADoc_ID);
    end
    else
    begin
      mSql := mSql +
        '  and data = ''''' + nxCrLf +
        '  and Filepath = ''''' + nxCrLf +
        '  and Document_ID = ' + QuotedStr(ADoc_ID);
    end;

    mDocId := SQLSelectInt(AOS, mSql);

    if (mDocId = 0) then
      RaiseException(getString('error_saving_document'))
    else
    begin
      if SaveTemporaryStorageOnDisk then
      begin
        mPath := GetFileName(AOS, mDocId);
        mSql := 'update ' + REST_TABLE_TemporaryStorage + ' set Filepath = ' + QuotedStr(mPath) + ' where id = ' + QuotedStr(IntToStr(mDocId));
        AOS.SQLExecute(mSql);

        mHandle := FileCreate(mPath);
        FileClose(mHandle);
      end;
    end;
    if not mInTransaction then
      AOS.Commit;
  except
    if not mInTransaction then
      AOS.Rollback;
    RaiseException(ExceptionMessage);
  end;

  Result := mDocId;
end;

procedure TemporaryStorage_Update(AOS: TNxCustomObjectSpace; ATempId: Integer; AData: String);
var
  mSql, mData, mFilePath: String;
  json: TJSONSuperObject;
begin
  if (ATempId < 1)then
    RaiseException(getString('error_invalid_temporary_storage_id'));

  // tato funkce se vola primo ze skriptu, kde neni v JSONu obalujici objekt, tak tuto obalku nejdriv pridame
  // AData musime zaescapovat pro JSON
  json := TJSONSuperObject.CreateByDataType(jtObject);
  try
    json.I['id'] := ATempId;
    json.S['data'] := AData;
    mData := json.AsJson;

    if SaveTemporaryStorageOnDisk then
    begin
      mSql := 'select FilePath from ' + REST_TABLE_TemporaryStorage + ' where id = ' + IntToStr(ATempId);
      mFilePath := SQLSelectStr(AOS, mSql);

      mSql  :=
        'UPDATE ' + REST_TABLE_TemporaryStorage + ' SET' + nxCrLf +
        '  Date$Date = ' + NxFloatToIBStr(Now) + ',' + nxCrLf +
        '  UpdateCount = UpdateCount + 1' + nxCrLf +
        'WHERE ID = ' + IntToStr(ATempId);
      AOS.SQLExecute(mSql);
      json.SaveToFile(mFilePath);
    end
    else
      UpdateInPieces(AOS, mData, ATempId);
  finally
    json.free;
  end;
end;

procedure TemporaryStorage_ChangeStatus(AOS: TNxCustomObjectSpace; AID, AStatus: Integer);
begin
  AOS.SQLExecute(
    'UPDATE ' + REST_TABLE_TemporaryStorage + ' SET ' + nxCrLf +
    '  Status = ' + IntToStr(AStatus) + ',' + nxCrLf +
    '  Date$Date = ' + NxFloatToIBStr(Now) + ',' + nxCrLf +
    '  UpdateCount = UpdateCount + 1' + nxCrLf +
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
  mChangeType, mSql: String;
  mRecord: TMemTable;
  docId: Integer;
  mJson: TJSONSuperObject;
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
  mRecord := TMemTable.Create(nil);
  try
    try
      //zjistim stav zaznamu
      AOS.SQLSelect2(
        'SELECT Status as "Status", Filepath as "Filepath" from ' + REST_TABLE_TemporaryStorage + nxCrLf +
        'where ID = ' + IntToStr(docId)
        , mRecord
      );

      //mam zaznam?
      if not mRecord.Active then
        //nemam - chyba - toto by se stat nemelo - zaznamy nemazu
        RaiseException(Format(getString('document_not_found'), [IntToStr(docId)]));

      mRecord.First;
      if mRecord.FieldByName('Status').AsInteger = TempStorageStatus_SAVED then
        //pokud jiz bylo ulozeno, tak chyba. Jinak dovolim ulozit
        RaiseException(Format(getString('document_already_saved'), [IntToStr(docId)]));

      //aktualizuju data
      if SaveTemporaryStorageOnDisk then
      begin
        mSql  :=
          'UPDATE ' + REST_TABLE_TemporaryStorage + ' SET' + nxCrLf +
          '  Date$Date = ' + NxFloatToIBStr(Now) + ',' + nxCrLf +
          '  UpdateCount = UpdateCount + 1' + nxCrLf +
          'WHERE ID = ' + IntToStr(DocId);
        AOS.SQLExecute(mSql);

        mJson := TJSONSuperObject.ParseString(ABody, True);
        try
          mJson.SaveToFile(mRecord.FieldByName('Filepath').AsString)
        finally
          mJson.Free;
        end;
      end
      else
        UpdateInPieces(AOS, ABody, DocId);

      SetResponse(AResponse, '', ContentType_PlainText, HTTP_SC_Created);
    except
      SetPlainResponse(AResponse, ExceptionMessage, HTTP_SC_ExpectationFailed);
    end;
  finally
    mRecord.free;
  end;
  //--------------------------------------------------------------------------
end;

function GetFileName(AOS: TNxCustomObjectSpace; AID: Integer): String;
var
  mPath: String;
begin
   mPath := TemporaryStoragePath(AOS, gSkladTermModule, gSkladTermDocType, gSkladTermUser_ID);
   mPath := mPath + AOS.GetConnectionName + '_' + IntToStr(AID) + '.txt';
   Result := mPath;
end;

begin
end.