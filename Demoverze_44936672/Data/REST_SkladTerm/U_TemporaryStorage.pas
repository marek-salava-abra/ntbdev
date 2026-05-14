uses
  'REST_SkladTerm.U_Const',
  'REST_SkladTerm.U_Func',
  'REST_SkladTerm_Special.U_Const',
  'StandardUnits.U_GetId';

const
  TempStorageStatus_OPEN   = 0; //otevreny (rozpracovany) doklad
  TempStorageStatus_SAVE   = 1; //ulozeno
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

////////////////////////////////////////////////////////////////////////////////
//slouzi k vyhledani otevreneho (rozpracovaneho) dokladu pozadovaneho typu
//pro konkretniho uzivatele. pokud jich existuje vice (nemelo by se stavat),
//vezme se ten nejnovejsi (s nejvetcim cislem)
procedure get_TemporaryStorage(Self: TNxWebServicesHelper; ARequest: TNxHTTPRequest;
  AResponse: TNxHTTPResponse; slPath: TStringList);

var
  sdData: TMemTable;
  dataType, mSql, Document_ID, mTempId: String;
  mId: Integer;
  user_ID: String;
  mJSON_Root: TJSONSuperObject;

begin
  if (slPath.Count >= 3) or (slPath.Count <= 5) then
  begin
    dataType := slPath.Strings[1]; //ocekavam typ dat
    user_ID := slPath.Strings[2];   //ocekavam login
    if slPath.Count >= 4 then
      Document_ID := slPath.Strings[3];
    if slPath.Count = 5 then
      mTempId := slPath.Strings[4];
  end
  else
  begin
    ErrREST(ARequest, AResponse, HTTP_SC_BadRequest);
    exit;
  end;

  sdData:= TMemTable.Create(nil);
  try
    // nejdrive kontrola, zda uzivatel nema rozpracovane doklady v jinych scenarich
    if OnlyOneScenarioWork then
    begin
      mSql :=
        'SELECT' + FIRST_TOP(1) + nxCrLf +
        'Id' + nxCrLf +
        'from ' + REST_TABLE_TemporaryStorage + nxCrLf +
        'where' + nxCrLf +
        '  (Status = ' + IntToStr(TempStorageStatus_OPEN) + nxCrLf +
        '    or Status = ' + IntToStr(TempStorageStatus_PAUSED) + ')' + nxCrLf +
        '  and User_ID = ' + QuotedStr(user_ID) + nxCrLf +
        '  and DataType <> ' + QuotedStr(dataType) + nxCrLf;
      FIRST_TOP_ORACLE(1);
      mId := SQLSelectInt(Self.ObjectSpace, mSql);

      if mId > 0 then
      begin
        ErrREST(ARequest, AResponse, HTTP_SC_ExpectationFailed, Format(getString('finish_another_scenario'),
          [sdData.FieldByName('DataType').AsString]));
        exit;
      end;
    end;

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

    Self.ObjectSpace.SQLSelect2(mSql, sdData);

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
            Self.ObjectSpace.SQLExecute(mSql);
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
              Self.ObjectSpace.SQLExecute(mSql);
            end;
          end;
        finally
          mJSON_Root.free;
        end;
      end
      else
      begin
        Self.ObjectSpace.SQLExecute(mSql);
        sdData.EmptyTable;
      end;
    end;
    //###################
    //--------------------------------------------------------------------------

    // vzdy vracime objekt TemporaryStorage, pokud jsme nasli radek v DB, naplnime skutecna data do pole "data"
    if sdData.Active and (sdData.RecordCount = 1) then
      HTTPResponse(AResponse, HTTP_SC_OK, ContentType_JSON, sdData.FieldByName('Data').AsString)
    else
      HTTPResponse(AResponse, HTTP_SC_OK, ContentType_JSON, '{}');
  finally
    sdData.free;
  end;
end;//get_TemporaryStorage
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
function TemporaryStorage_Create(AOS: TNxCustomObjectSpace; AData: String; ADataType: String; AUser_ID, ADoc_ID: String): Integer;
var
  sql     : string;
  dataUTF : String;
  dataType: string;
  user_ID : string;
  mJSON_Root, json : TJSONSuperObject;
  DocId   : integer;
begin
  // tato funkce se vola primo ze skriptu, kde neni v JSONu obalujici objekt, tak tuto obalku nejdriv pridame
  // AData musime zaescapovat pro JSON

  // toto escapovani bylo nedokonale - vadila napr. uvozovka v nazvu artiklu
  //AData := '{"id":0,"data":"' + jsonEscapeString(AData) + '"}';
  json := TJSONSuperObject.CreateByDataType(jtObject);
  try
    json.I['id'] := 0;
    json.S['data'] := AData;
    AData := json.AsJson(false, true);
  finally
    json.free;
  end;

  mJSON_Root := TJSONSuperObject.ParseString(AData, True);
  try
    //###################
    //DOCASNE OSETRENI !!!! neukladam text delsi nez 30k. Bori to pamet.
    //Musim si ale doklad ulozit, kvuli prideleni cisla. Data ulozim prazdna a v pripade GET
    //se budu tvarit, ze tam zadny rozpracovany doklad neni (smazu jej)
//    if(Length(AData)> MAX_DATA_LEN)then begin
//      //gLog.WriteEventFmt(logDebug, 'TemporaryStorage-POST:MaxLenData:%s', [TEncoding.UTF8.GetString(ARequest.Content.Content)]);
//      mJSON_Root.S['data']:= '-';
//    end;
    //###################

    //--------------------------------------------------------------------------
    //vlozim novy (prazdny), abch zjiskal ID
    sql:=
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
    //gLog.WriteEventFmt(logDebug, 'TemporaryStorage-sql insert:%s', [sql]);
    AOS.SQLExecute(sql);

    //vytahnu si pridelene id (unikat zaznamu)
    sql :=
      'select' + nxCrLf +
      '  id' + nxCrLf +
      'from ' + REST_TABLE_TemporaryStorage + nxCrLf +
      'where' + nxCrLf +
      '  Status = ' + IntToStr(TempStorageStatus_OPEN) + nxCrLf +
      '  and user_ID = ' + QuotedStr(AUser_ID) + nxCrLf +
      '  and DataType = ' + QuotedStr(ADataType) + nxCrLf;

    // oracle povazuje '' za null
    if DB_TYPE in [2, 3, 4] then
    begin
      sql := sql + ' and data is null' + nxCrLf;
      if CFxOID.IsEmpty(ADoc_ID) then
        sql := sql + '  and Document_ID is null'
      else
        sql := sql + '  and Document_ID = ' + QuotedStr(ADoc_ID);
    end
    else
    begin
      sql := sql +
        ' and data = ''''' + nxCrLf +
        '  and Document_ID = ' + QuotedStr(ADoc_ID);
    end;


    DocId:= sqlSelectInt(AOS, sql);
    //nedostal jsem zadny zaznam - toto by se nemelo stat
    if(DocId = 0)then
      RaiseException(getString('error_saving_document'));

    //nastavim id
    mJSON_Root.I['id']:= DocId;
    dataUTF:= mJSON_Root.AsJson;

    //aktualizuju novy zaznam
    UpdateInPieces(AOS, dataUTF, DocId);
    {sql:=
      'UPDATE '+TABLE_RestTemporaryStorage+' SET '+
      'Data = '+QuotedStr(dataUTF)+', '+
      'Date$Date = '+NxFloatToIBStr(now)+' '+
      'WHERE ID = '+IntToStr(DocId);
    //gLog.WriteEventFmt(logDebug, 'TemporaryStorage-sql update:%s', [sql]);
    AOS.SQLExecute(sql); }
    //--------------------------------------------------------------------------

    Result := DocId;
  finally
    mJSON_Root.free;
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

procedure TemporaryStorage_Delete(AOS: TNxCustomObjectSpace; AID: Integer);
begin
  TemporaryStorage_ChangeStatus(AOS, AID, TempStorageStatus_STORNO);
end;

procedure TemporaryStorage_Pause(AOS: TNxCustomObjectSpace; AID: Integer);
begin
  TemporaryStorage_ChangeStatus(AOS, AID, TempStorageStatus_PAUSED);
end;

//update zaznamu podle ID
procedure put_TemporaryStorage(Self: TNxWebServicesHelper; ARequest: TNxHTTPRequest;
  AResponse: TNxHTTPResponse; slPath: TStringList);
var
  contentS, mChangeType: String;
  slSql: TStringList;
  docId: Integer;
begin
  if(slPath.Count = 3) then
  begin
    docId := StrToIntDef(slPath.Strings[1], -1);
    mChangeType := slPath.Strings[2];
  end
  else
  begin
    ErrREST(ARequest, AResponse, HTTP_SC_BadRequest);
    exit;
  end;

  //neposlal jsem si cislo dokladu
  if(docId = -1)then begin
    ErrREST(ARequest, AResponse, HTTP_SC_BadRequest);
    exit;
  end;

  // muzu mazat, pozastavit nebo aktualizovat
  if(mChangeType = 'A') then
  begin
    TemporaryStorage_Delete(Self.ObjectSpace, docId);
    HTTPResponse(AResponse, HTTP_SC_Accepted, ContentType_JSON, '{}');
    exit;
  end
  else if (mChangeType = 'P') then
  begin
    TemporaryStorage_Pause(Self.ObjectSpace, docId);
    HTTPResponse(AResponse, HTTP_SC_Accepted, ContentType_JSON, '{}');
    exit;
  end;

  //--------------------------------------------------------------------------
  //aktualizace zaznamu
  //dotaz a odpoved
  contentS:= TEncoding.UTF8.GetString(ARequest.Content.Content);
  slSql:=TStringList.Create;
  try
    try
      //--------------------------------------------------------------------------
      //zjistim stav zaznamu
      Self.ObjectSpace.SQLSelect(
        'SELECT status from ' + REST_TABLE_TemporaryStorage + nxCrLf +
        'where ID = ' + IntToStr(docId)
        , slSql
      );

      //mam zaznam?
      if(slSql.Count = 0)then begin
        //nemam - chyba - toto by se stat nemelo - zaznamy nemazu
        RaiseException(Format(getString('document_not_found'), [IntToStr(docId)]));

      end else if(StrToInt(slSql.strings[0]) = TempStorageStatus_SAVE)then begin
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
      UpdateInPieces(Self.ObjectSpace, contentS, DocId);
      {sql:=
        'UPDATE '+TABLE_RestTemporaryStorage+' SET '+
        'Data = '+QuotedStr(contentS)+', '+
        'Date$Date = '+NxFloatToIBStr(now)+' '+
        'WHERE ID = '+IntToStr(docId);
      gLog.WriteEventFmt(logDebug, 'TemporaryStorage-sql update:%s', [sql]);
      Self.ObjectSpace.SQLExecute(sql);  }
      //--------------------------------------------------------------------------

      HTTPResponse(AResponse, HTTP_SC_Created, ContentType_JSON, '{}' {contentS}, false);
    except
      ErrREST(ARequest, AResponse, HTTP_SC_ExpectationFailed, ExceptionMessage);
    end;
  finally
    slSql.free;
  end;
  //--------------------------------------------------------------------------
end;//post_TemporaryStorage
////////////////////////////////////////////////////////////////////////////////

begin
end.