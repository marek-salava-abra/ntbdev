{uses
  'REST_SkladTerm.U_Func',
  'REST_SkladTerm.U_FuncJSON',
  'StandardUnits.U_GetId';

const
  cPositionStore_ID = '2100000101';

procedure expressChangePosition(Self: TNxWebServicesHelper; ARequest: TNxHTTPRequest;
  AResponse: TNxHTTPResponse; slPath: TStringList);
var
  mStoreCard_ID, mStoreSubCard_ID, mNewStorePosition_ID: String;
  mSql: String;

  procedure saveNewPosition(AOS: TNxCustomObjectSpace; AStoreSubCard_ID, ANewPosition: String);
  var
    mBO: TNxCustomBusinessObject;
  begin
    mBO := AOS.CreateObject(Class_StoreSubCard);
    try
      mBO.ExplicitTransaction := True;
      mBO.Load(AStoreSubCard_ID, nil);

      mBO.SetFieldValueAsString('X_Pozice', ANewPosition);
      mBO.Save;
    finally
      mBO.Free;
    end;
  end;

begin
  if (slPath.Count = 4) then
  begin
    mStoreCard_ID := slPath.Strings[1];
    mStoreSubCard_ID := slPath.Strings[2];
    mNewStorePosition_ID := slPath.Strings[3];
  end else if (slPath.Count = 3) then
  begin
    mStoreCard_ID := slPath.Strings[1];
    mStoreSubCard_ID := '';
    mNewStorePosition_ID := slPath.Strings[2];
  end
  else
  begin
    ErrREST(ARequest, AResponse, HTTP_SC_BadRequest, getString('wrong_parameters_count'));
    exit;
  end;

  // hlavicka artiklu
  LogWriteSectionStart('expressChangePosition');

  Self.ObjectSpace.StartTransaction(taReadCommited);
  try
    // pokud nemame ID dilci karty, tak hledam dilci kartu na hlavni sklad nebo alespon prvni dilci kartu
    if mStoreSubCard_ID = '' then
    begin
      mSql :=
        'select first 1 SSC.ID from StoreSubCards SSC where SSC.StoreCard_ID = ' + QuotedStr(mStoreCard_ID) +
        ' and SSC.Store_ID = ' + QuotedStr(cPositionStore_ID);
      mStoreSubCard_ID := SQLSelectStr(Self.ObjectSpace, mSql);

      // pokud neni dilci karta na hl. sklade, tak zkusim ziskat prvni dostupnou
      if mStoreSubCard_ID = '' then
      begin
        mSql :=
          'select first 1 SSC.ID from StoreSubCards SSC where SSC.StoreCard_ID = ' + QuotedStr(mStoreCard_ID);
        mStoreSubCard_ID := SQLSelectStr(Self.ObjectSpace, mSql);
      end;
    end;
    LogWriteSectionEnd;

    // pokud nejakou mam tak ulozim novou pozici, jinak chyba
    if mStoreSubCard_ID <> '' then
      saveNewPosition(Self.ObjectSpace, mStoreSubCard_ID, mNewStorePosition_ID)
    else
      RaiseException('Vybraný artikl nemá žádnou dílčí kartu.');


    HTTPResponse(AResponse, HTTP_SC_OK, ContentType_JSON, PlainResponse(''));

    Self.ObjectSpace.Commit;
  except
    Self.ObjectSpace.RollBack;
    ErrREST(ARequest, AResponse, HTTP_SC_InternalServerError, ExceptionMessage);
  end;
end;}

begin
end.