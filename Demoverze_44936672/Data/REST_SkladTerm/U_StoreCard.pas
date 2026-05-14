uses
  'REST_SkladTerm.U_Func',
  'REST_SkladTerm.U_FuncJSON',
  'REST_SkladTerm.U_SQLQueries',
  'REST_SkladTerm_Special.U_Const',
  'REST_SkladTerm_Special.U_StandardHooks',
  'StandardUnits.U_DataSet',
  'StandardUnits.U_GetId';

///////////////////////////////////////////////////////////////////////////////
procedure get_StoreCardInfo(Self: TNxWebServicesHelper; ARequest: TNxHTTPRequest;
  AResponse: TNxHTTPResponse; slPath: TStringList);
var
  mStoreCard_ID, mStoreCard_ID_Orig, mUserId, mFirm_ID, mStore_ID, mModuleId, mDocType, mStoreUnit_ID: String;
  mExtendedInfo, mWithUnits, mIsId, mWithStoreUnit: Boolean;
  dtHeader: TMemTable;
  dtRows, dtUnits, dtEANs: TMemTable;
  mSL: TStringList;
  mSql: String;
  json, eanJson, eanJsonArray: TJSONSuperObject;
  i: Integer;
begin
  mUserId := getHeaderValue(ARequest, 'UserID');
  mDocType := getHeaderValue(ARequest, 'DocumentType');
  mModuleId := getHeaderValue(ARequest, 'ModuleCode');

  json := nil;
  if (slPath.Count = 7) then
  begin
    // dekoduju text (predtim musim jeste nahradit + mezerou, protoze delphi koduje jinak nez java)
    mStoreCard_ID :=  CFxInternet.URLDecode(ReplaceStr(slPath.Strings[1], '+', ' ')); //ocekavam artikl
    mIsId := slPath.Strings[2] = 'true';
    mFirm_ID := slPath.Strings[3];
    mStore_ID := slPath.Strings[4];
    mWithUnits := slPath.Strings[5] = 'true';
    mExtendedInfo := slPath.Strings[6] = 'true';
  end else
  begin
    ErrREST(ARequest, AResponse, HTTP_SC_BadRequest, getString('wrong_parameters_count'));
    exit;
  end;

  // v pripade artiklu nemusi prijit primo jeho ID, ale treba nejaky jiny identifikator (EAN apod.)
  // zde tedy zjistime nejprve jeho ID
  mWithStoreUnit := False;
  mStoreUnit_ID := '';
  mStoreCard_ID_Orig := mStoreCard_ID;
  mStoreCard_ID := GetStoreCard_ID(Self.ObjectSpace, mStoreCard_ID, mIsId, mWithStoreUnit);

  if mWithStoreUnit then
  begin
    mStoreUnit_ID := Copy(mStoreCard_ID, 12, 10);
    mStoreCard_ID := Copy(mStoreCard_ID, 1, 10);
  end;

  if mStoreCard_ID = '' then
  begin
    ErrREST(ARequest, AResponse, HTTP_SC_NotFound, Format(getString('article_not_found'), [mStoreCard_ID_Orig]));
    exit;
  end;

  dtHeader := TMemTable.Create(nil);
  dtRows := TMemTable.Create(nil);
  dtUnits := TMemTable.Create(nil);
  dtEANs := TMemTable.Create(nil);
  mSL := TStringList.Create;
  try
    // hlavicka artiklu
    LogWriteSectionStart('StoreCardInfo');
    mSql := getStoreCardInfoSql(Self.ObjectSpace, mModuleId, mDocType, mUserId, mStoreCard_ID, mFirm_ID, mStore_ID, mStoreUnit_ID);
    //pridam omezeni, pokud je nastaveno
    mSql := mSql + StoreCard_Where(Self.ObjectSpace, mModuleId);
    Self.ObjectSpace.SQLSelect2(mSql, dtHeader);

    if dtHeader.Active and mExtendedInfo then
    begin
      // dispozice po skladech
      mSql :=
        'select ' + nxCrLf +
        '  SSC.StoreCard_ID as "XX_Parent_ID",' + nxCrLf +
        '  S.ID as "Store_ID",' + nxCrLf +
        '  S.Code as "StoreCode",' + nxCrLf +
        '  (SSC.Quantity - SSC.BookedQuantity) / SU.UnitRate as "Available",' + nxCrLf +
        '  (' + get_StoreCardInfo_ByStoreValue + ') as "CustomValue"' + nxCrLf +
        'from StoreSubCards SSC' + nxCrLf +
        'join StoreCards SC on SC.ID = SSC.StoreCard_ID' + nxCrLf +
        'join StoreUnits SU on SU.Parent_ID = SC.ID and SU.Code = SC.MainUnitCode' + nxCrLf +
        'join Stores S on S.ID = SSC.Store_ID' + nxCrLf +
        'where SSC.StoreCard_ID = ' + QuotedStr(mStoreCard_ID) + nxCrLf +
        '  and SSC.Quantity <> 0' + nxCrLf +
        'order by' + nxCrLf +
        '  S.Code';
      Self.ObjectSpace.SQLSelect2(mSql, dtRows);
      if dtRows.Active then
      begin
        dtRows.AddIndex('id', REST_XX_Parent_ID+';StoreCode', [ixUnique]);
        dtRows.IndexName:= 'id';
        mSL.AddObject('rows=', dtRows);
      end;
    end;

    // pridam jednotky - bohuzel takhle osklive, protoze neumim vnorenou kolekci
    if mWithUnits then
    begin
      mSql :=
        'select' + nxCrLf +
        '  SU.Parent_ID as "XX_Parent_ID",' + nxCrLf +
        '  SU.PosIndex as "PosIndex",' + nxCrLf +
        '  SU.ID as "StoreUnit_ID",' + nxCrLf +
        '  SU.Code as "StoreUnitCode",' + nxCrLf +
        '  SU.Width as "Width",' + nxCrLf +
        '  SU.Height as "Height",' + nxCrLf +
        '  SU.Depth as "Depth",' + nxCrLf +
        '  SU.Weight as "Weight",' + nxCrLf +
        '  case when SC.MainUnitCode = SU.Code then ''A'' else ''N'' end "IsMainUnit$BOOL"' + nxCrLf +
        'from StoreUnits SU' + nxCrLf +
        'join StoreCards SC on SC.ID = SU.Parent_ID' + nxCrLf +
        'where' + nxCrLf +
        '  SU.Parent_ID = ' + QuotedStr(mStoreCard_ID);
      Self.ObjectSpace.SQLSelect2(mSql, dtUnits);
      if dtUnits.Active then
      begin
        dtUnits.AddIndex('id', REST_XX_Parent_ID+';PosIndex', [ixUnique]);
        dtUnits.IndexName:= 'id';
        mSL.AddObject('units=', dtUnits);
      end;
    end;
    LogWriteSectionEnd;

    if dtHeader.Active then
    begin
      dtHeader.First;
      LogWriteSectionStart('JSON');
      json := REST_jsonCreate_FromDataSetRow(dtHeader, nil, mSL);

      if mWithUnits then
      begin
        // pridam EANy k jednotkam
        mSql :=
          'select' + nxCrLf +
          '  SE.ID as "ID",' + nxCrLf +
          '  SE.Parent_ID as "Parent_ID",' + nxCrLf +
          '  SE.EAN as "EAN"' + nxCrLf +
          'from StoreEANs SE' + nxCrLf +
          'join StoreUnits SU on SU.ID = SE.Parent_ID' + nxCrLf +
          'where SU.Parent_ID = ' + QuotedStr(mStoreCard_ID);
        Self.ObjectSpace.SQLSelect2(mSql, dtEANs);
        if dtEANs.Active then
        begin
          // protoze nevim jak na vnoverene kolekce, tak si EANy vlozim k jednotkam rucne
          for i := 0 to json.A['units'].Length - 1 do
          begin
            dtEANs.Filtered := False;
            dtEANs.Filter := 'Parent_ID=' + QuotedStr(json.A['units'].O[i].S['StoreUnit_ID']);
            dtEANs.Filtered := True;

            if dtEANs.Active then
            begin
              dtEANS.First;

              eanJsonArray := json.CreateJSONArray;
              json.A['units'].O[i].O['eans'] := eanJsonArray;

              while not dtEANS.Eof do
              begin
                if IsUnicodeVersion then
                  eanJson := TJSONSuperObject.Create
                else
                  eanJson := eanJsonArray.CreateJSON;

                eanJson.S['StoreEAN_ID'] := dtEANs.FieldByName('ID').AsString;
                eanJson.S['StoreEAN'] := dtEANs.FieldByName('EAN').AsString;
                eanJsonArray.AsArray.Add(eanJson);

                dtEANS.Next;
              end;
            end;
          end;
        end
      end;

      LogWriteSectionEnd;

      HTTPResponse(AResponse, HTTP_SC_OK, ContentType_JSON, json.AsJson(false, true));
    end
    else begin
      ErrREST(ARequest, AResponse, HTTP_SC_NotFound, Format(getString('article_not_found'), [mStoreCard_ID_Orig]));
    end;
  finally
    dtHeader.Free;
    dtRows.Free;
    dtUnits.Free;
    dtEANs.Free;
    mSL.Free;
    if Assigned(json) then
      json.Free;
  end;
end;
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
procedure get_StoreCardInfoPositions(Self: TNxWebServicesHelper; ARequest: TNxHTTPRequest;
  AResponse: TNxHTTPResponse; slPath: TStringList);
var
  mStoreCard_ID, mStoreBatch_ID, mStore_ID, mStoreCard_ID_Orig: String;
  dtHeader: TMemTable;
  dtRows: TMemTable;
  mSL: TStringList;
  mSql: String;
  json: TJSONSuperObject;
  mIsId, mOnlyAvailable: Boolean;
begin
  json := nil;
  if (slPath.Count = 6) then
  begin
    mStoreCard_ID := slPath.Strings[1]; //ocekavam artikl
    mStoreBatch_ID  := slPath.Strings[2];
    mIsId := slPath.Strings[3] = 'true';
    mStore_ID := slPath.Strings[4]; //ocekavam sklad
    mOnlyAvailable := slPath.Strings[5] = 'true';
  end else
  begin
    ErrREST(ARequest, AResponse, HTTP_SC_BadRequest, getString('wrong_parameters_count'));
    exit;
  end;

  // v pripade artiklu nemusi prijit primo jeho ID, ale treba nejaky jiny identifikator (EAN apod.)
  // zde tedy zjistime nejprve jeho ID
  mStoreCard_ID_Orig := mStoreCard_ID;
  mStoreCard_ID := GetStoreCard_ID(Self.ObjectSpace, mStoreCard_ID, mIsId);

  dtHeader := TMemTable.Create(nil);
  dtRows := TMemTable.Create(nil);
  mSL := TStringList.Create;
  try
    // hlavicka artiklu
    LogWriteSectionStart('StoreCardInfoPositions');
    mSql :=
      'select' + nxCrLf +
      '  SC.ID as "ID",' +  // kvuli navazani polozkoveho datasetu
      '  SC.ID as "StoreCard_ID",' + nxCrLf +
      '  SC.' + cStoreCardInfoCodeField + ' as "StoreCardCode",' + nxCrLf +
      '  SC.' + cStoreCardInfoNameField + ' as "StoreCardName",' + nxCrLf +
      '  SC.Category as "StoreCardCategory",' + nxCrLf;
    if ABRA then
      mSql := mSql +
        '  case' + nxCrLf +
        '    when SC.NonStockType = ''A''' + nxCrLf +
        '    then ''N''' + nxCrLf +
        '    else ''A''' + nxCrLf +
        '  end as "StoreCardIsStockType$BOOL",' + nxCrLf
    else
      mSql := mSql +
        '  SC.IsStockType as "StoreCardIsStockType$BOOL",' + nxCrLf;

    mSql := mSql +
      '  SC.MainUnitCode as "MainUnitCode",' + nxCrLf +
      '  SU.UnitRate as "MainUnitRate"' + nxCrLf +
      'from StoreCards SC' + nxCrLf +
      'join StoreUnits SU on SU.Parent_ID = SC.ID and SU.Code = SC.MainUnitCode' + nxCrLf +
      'where SC.ID = ' + QuotedStr(mStoreCard_ID);
    Self.ObjectSpace.SQLSelect2(mSql, dtHeader);

    if dtHeader.Active then
    begin
      dtHeader.First;

      // seznam dispozic na pozicich vybraneho skladu pro vybrany artikl
      mSql :=
        'select' + nxCrLf +
        '  max(LSC.StoreCard_ID) as "XX_Parent_ID",' + nxCrLf +
        '  max(LSP.ID) as "StorePosition_ID",' + nxCrLf +
        '  max(LSP.Code) as "StorePositionCode",' + nxCrLf +
        '  sum((LSC.Quantity - LSC.QuantityReserved) / SU.UnitRate) as "Available",' + nxCrLf +
        '  sum(LSC.QuantityReserved / SU.UnitRate) as "Booked"' + nxCrLf +
        'from LogStorePositions LSP' + nxCrLf +
        'join LogStoreContents LSC on LSC.Parent_ID = LSP.ID' + nxCrLf +
        'join StoreCards SC on SC.ID = LSC.StoreCard_ID' + nxCrLf +
        'join StoreUnits SU on SU.Parent_ID = SC.ID and SU.Code = SC.MainUnitCode' + nxCrLf +
        'where' + nxCrLf +
        '  LSP.Store_ID = ' + QuotedStr(mStore_ID) + nxCrLf +
        '  and SC.ID = ' + QuotedStr(mStoreCard_ID) + nxCrLf;
      // pokud je sarze tak ji omezim
      if not NxIsEmptyOID(mStoreBatch_ID) then
        mSql := mSql + '  and LSC.StoreBatch_ID = ' + QuotedStr(mStoreBatch_ID) + nxCrLf;

      mSql := mSql +
        'group by' + nxCrLf +
        '  LSP.ID' + nxCrLf;

      if mOnlyAvailable then
        mSql := mSql +
          'having' + nxCrLf +
          '  sum(LSC.Quantity - LSC.QuantityReserved) <> 0' + nxCrLf
      else
        mSql := mSql +
          'having' + nxCrLf +
          '  sum(LSC.Quantity) <> 0' + nxCrLf;

      mSql := mSql +
        'order by' + nxCrLf +
        '  max(LSP.Code)';
      Self.ObjectSpace.SQLSelect2(mSql, dtRows);
      if dtRows.Active then
      begin
        dtRows.AddIndex('id', REST_XX_Parent_ID+';StorePositionCode', [ixUnique]);
        dtRows.IndexName:= 'id';
        mSL.AddObject('rows=', dtRows);
      end;
    end;
    LogWriteSectionEnd;

    if dtHeader.Active then
    begin
      LogWriteSectionStart('JSON');
      json := REST_jsonCreate_FromDataSetRow(dtHeader, nil, mSL);
      LogWriteSectionEnd;

      HTTPResponse(AResponse, HTTP_SC_OK, ContentType_JSON, json.AsJson(false, true));
    end
    else begin
      ErrREST(ARequest, AResponse, HTTP_SC_NotFound, Format(getString('article_not_found'), [mStoreCard_ID_Orig]));
    end;
  finally
    dtHeader.Free;
    dtRows.Free;
    mSL.Free;
    if Assigned(json) then
      json.Free;
  end;
end;
///////////////////////////////////////////////////////////////////////////////

procedure get_StoreCardInfoBatchesOnPosition(Self: TNxWebServicesHelper; ARequest: TNxHTTPRequest;
  AResponse: TNxHTTPResponse; slPath: TStringList);
var
  mStoreCard_ID, mStorePosition_ID, mStore_ID: String;
  dtHeader: TMemTable;
  dtRows: TMemTable;
  mSL: TStringList;
  mSql: String;
  json: TJSONSuperObject;
  mIsId: Boolean;
begin
  json := nil;
  if (slPath.Count = 4) then
  begin
    mStoreCard_ID := slPath.Strings[1]; //ocekavam artikl
    mStorePosition_ID  := slPath.Strings[2];
    mStore_ID := slPath.Strings[3]; //ocekavam sklad
  end else
  begin
    ErrREST(ARequest, AResponse, HTTP_SC_BadRequest, getString('wrong_parameters_count'));
    exit;
  end;

  dtHeader := TMemTable.Create(nil);
  dtRows := TMemTable.Create(nil);
  mSL := TStringList.Create;
  try
    // hlavicka artiklu
    LogWriteSectionStart('StoreCardInfoPositions');
    mSql :=
      'select' + nxCrLf +
      '  SC.ID as "ID",' + nxCrLf +  // kvuli navazani polozkoveho datasetu
      '  SC.ID as "StoreCard_ID",' + nxCrLf +
      '  SC.' + cStoreCardInfoCodeField + ' as "StoreCardCode",' + nxCrLf +
      '  SC.' + cStoreCardInfoNameField + ' as "StoreCardName",' + nxCrLf +
      '  SC.Category as "StoreCardCategory",' + nxCrLf;
    if ABRA then
      mSql := mSql +
        '  case' + nxCrLf +
        '    when SC.NonStockType = ''A''' + nxCrLf +
        '    then ''N''' + nxCrLf +
        '    else ''A''' + nxCrLf +
        '  end as "StoreCardIsStockType$BOOL",' + nxCrLf
    else
      mSql := mSql +
        '  SC.IsStockType as "StoreCardIsStockType$BOOL",' + nxCrLf;

    mSql := mSql +
      '  SC.MainUnitCode as "MainUnitCode",' + nxCrLf +
      '  SU.UnitRate as "MainUnitRate"' + nxCrLf +
      'from StoreCards SC' + nxCrLf +
      'join StoreUnits SU on SU.Parent_ID = SC.ID and SU.Code = SC.MainUnitCode' + nxCrLf +
      'where' + nxCrLf +
      '  SC.ID = ' + QuotedStr(mStoreCard_ID);
    Self.ObjectSpace.SQLSelect2(mSql, dtHeader);

    if dtHeader.Active then
    begin
      dtHeader.First;

      // seznam sarzi na pozicich vybraneho skladu pro vybrany artikl
      mSql :=
        'select' + nxCrLf +
        '  max(LSC.StoreCard_ID) as "XX_Parent_ID",' + nxCrLf +
        '  SB.ID as "StorePosition_ID",' + nxCrLf +
        '  max(SB.Name) as "StorePositionCode",' + nxCrLf +
        '  sum((LSC.Quantity - LSC.QuantityReserved) / SU.UnitRate) as "Available",' + nxCrLf +
        '  sum(LSC.QuantityReserved / SU.UnitRate) as "Booked"' + nxCrLf +
        'from LogStoreContents LSC' + nxCrLf +
        'join StoreBatches SB on SB.ID = LSC.StoreBatch_ID' + nxCrLf +
        'join StoreCards SC on SC.ID = LSC.StoreCard_ID' + nxCrLf +
        'join StoreUnits SU on SU.Parent_ID = SC.ID and SU.Code = SC.MainUnitCode' + nxCrLf +
        'where' + nxCrLf +
        '  SC.ID = ' + QuotedStr(mStoreCard_ID) + nxCrLf +
        '  and LSC.Parent_ID = ' + QuotedStr(mStorePosition_ID) + nxCrLf;

      mSql := mSql +
        'group by' + nxCrLf +
        '  SB.ID' + nxCrLf +
        'having' + nxCrLf +
        '  sum(LSC.Quantity) <> 0' + nxCrLf +
        'order by' + nxCrLf +
        '  max(SB.Name)';
      Self.ObjectSpace.SQLSelect2(mSql, dtRows);
      if dtRows.Active then
      begin
        dtRows.AddIndex('id', REST_XX_Parent_ID+';StorePositionCode', [ixUnique]);
        dtRows.IndexName:= 'id';
        mSL.AddObject('rows=', dtRows);
      end;
    end;
    LogWriteSectionEnd;

    if dtHeader.Active then
    begin
      LogWriteSectionStart('JSON');
      json := REST_jsonCreate_FromDataSetRow(dtHeader, nil, mSL);
      LogWriteSectionEnd;

      HTTPResponse(AResponse, HTTP_SC_OK, ContentType_JSON, json.AsJson(false, true));
    end
    else begin
      ErrREST(ARequest, AResponse, HTTP_SC_NotFound, Format(getString('position_not_found'), [mStorePosition_ID]));
    end;
  finally
    dtHeader.Free;
    dtRows.Free;
    mSL.Free;
    if Assigned(json) then
      json.Free;
  end;
end;

///////////////////////////////////////////////////////////////////////////////
procedure get_AvailableQuantity(Self: TNxWebServicesHelper; ARequest: TNxHTTPRequest;
  AResponse: TNxHTTPResponse; slPath: TStringList);
var
  mStore_ID, mStoreCard_ID, mStoreDocument2_ID, mStoreBatch_ID, mStorePosition_ID, mStorePositionTo_ID: String;
  mQuantityDifference: Integer;
  mEnteredQuantity: Double;
  dtHeader: TMemTable;
  mSL: TStringList;
  mSql: String;
  json: TJSONSuperObject;
  mModule, mUser_ID, mDocType: String; //modul, ze ktereho se vola funkce
begin
  json := nil;
  if (slPath.Count = 9) then
  begin
    mStore_ID := slPath.Strings[1]; //ocekavam sklad
    mStoreCard_ID := slPath.Strings[2]; //ocekavam artikl
    mStoreDocument2_ID := slPath.Strings[3]; //ocekavam ID radku
    mQuantityDifference := StrToInt(slPath.Strings[4]); // ocekavam rozdil mezi mnozstvim na radku a zadany mnozstvim
    mEnteredQuantity := StrToFloat(ReplaceStr(slPath.Strings[5], '.', ',')); // ocekavam zadane mnozstvi
    mStoreBatch_ID := slPath.Strings[6]; //ocekavam sarzi nebo NullID
    mStorePosition_ID := slPath.Strings[7]; //ocekavam pozici z nebo NullOID
    mStorePositionTo_ID := slPath.Strings[8]; //ocekavam pozici na nebo NullOID
  end else
  begin
    ErrREST(ARequest, AResponse, HTTP_SC_BadRequest, getString('wrong_parameters_count'));
    exit;
  end;

  mUser_ID := getHeaderValue(ARequest, 'UserID');
  mModule := getHeaderValue(ARequest, 'ModuleCode');
  mDocType := getHeaderValue(ARequest, 'DocumentType');

  dtHeader := TMemTable.Create(nil);
  mSL := TStringList.Create;
  try
    LogWriteSectionStart('AvailableQuantity');

    if CFxOID.IsEmpty(mStorePosition_ID) then
    begin
      // pokud neni zadana Pozice
      if CFxOID.IsEmpty(mStoreBatch_ID) then
      begin
        // a neni zadana sarze, zjistuju dostupne mnozstvi z StoreSubCards
        mSql :=
          'select' + nxCrLf +
          '  SSC.Quantity - SSC.BookedQuantity as "Available", cast('''' as varchar(200)) as "DialogText"' + nxCrLf +
          'from StoreSubCards SSC' + nxCrLf +
          'where' + nxCrLf +
          '  SSC.Store_ID = ' + QuotedStr(mStore_ID) + nxCrLf +
          '  and SSC.StoreCard_ID = ' + QuotedStr(mStoreCard_ID);
      end
      else begin
        // a je zadana sarze, zjistuju dostupne mnozstvi z StoreSubBatches
        mSql :=
          'select' + nxCrLf +
          '  SSB.Quantity - SSB.BookedQuantity as "Available",' + nxCrLf +
          '  cast('''' as varchar(200)) as "DialogText"' +
          'from StoreSubBatches SSB' + nxCrLf +
          'where' + nxCrLf +
          '  SSB.Store_ID = ' + QuotedStr(mStore_ID) + nxCrLf +
          '  and SSB.StoreCard_ID = ' + QuotedStr(mStoreCard_ID) + nxCrLf +
          '  and SSB.StoreBatch_ID = ' + QuotedStr(mStoreBatch_ID);
      end;
    end
    else begin
      // pokud je zadana Pozice, zjistuju dostupne mnozstvi z LogStoreContents
      if checkReservedQuantityInPositions then
        mSql :=
          'select' + nxCrLf +
          '  sum(LSC.Quantity - LSC.QuantityReserved) as "Available", cast('''' as varchar(200)) as "DialogText"' + nxCrLf
      else
        mSql :=
          'select' + nxCrLf +
          '  sum(LSC.Quantity) as "Available", cast('''' as varchar(200)) as "DialogText"' + nxCrLf;

      mSql := mSql +
          'from LogStoreContents LSC' + nxCrLf +
          'where' + nxCrLf +
          '  LSC.Parent_ID = ' + QuotedStr(mStorePosition_ID) + nxCrLf +
          '  and LSC.StoreCard_ID = ' + QuotedStr(mStoreCard_ID);
      if not CFxOID.IsEmpty(mStoreBatch_ID) then
        mSql := mSql + nxCrLf +
          '  and LSC.StoreBatch_ID = ' + QuotedStr(mStoreBatch_ID);
    end;

    Self.ObjectSpace.SQLSelect2(mSql, dtHeader);
    LogWriteSectionEnd;

    if not dtHeader.Active then
    begin
      DataSet_CreataHeader(dtHeader, 'Available=F,DialogText=S200');
      dtHeader.Open;
      dtHeader.Append;
      dtHeader.FieldByName('Available').AsFloat := 0;
      dtHeader.Post;
    end;

    // pridam text dialogu
    dtHeader.Edit;
    dtHeader.FieldByName('DialogText').AsString := dialogTextOnRowSave(Self.ObjectSpace, mModule, mUser_ID,
      mStoreDocument2_ID, mStoreCard_ID, mStoreBatch_ID, mStore_ID, mStorePosition_ID, mEnteredQuantity);
    dtHeader.Post;

    dtHeader.First;

    try
      //hacek ve kterem lze ovlivnit mnozstvi povolene pro radek dokladu
      LogWriteSectionStart('get_AvailableQuantityHook');
      get_AvailableQuantityHook(Self.ObjectSpace, mModule, mDocType, mUser_ID, mStore_ID, mStorePosition_ID, mStorePositionTo_ID,
        mStoreCard_ID, mStoreBatch_ID, mStoreDocument2_ID, dtHeader, mQuantityDifference, mEnteredQuantity);
      LogWriteSectionEnd;

      LogWriteSectionStart('JSON');
      json := REST_jsonCreate_FromDataSetRow(dtHeader, nil, mSL);
      LogWriteSectionEnd;

      HTTPResponse(AResponse, HTTP_SC_OK, ContentType_JSON, json.AsJson(false, true));
    except
      ErrREST(ARequest, AResponse, HTTP_SC_ExpectationFailed, ExceptionMessage);
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
procedure listStoreCards(Self: TNxWebServicesHelper; ARequest: TNxHTTPRequest;
  AResponse: TNxHTTPResponse; slPath: TStringList);
var
  mUser_ID, mModule, mDocType, mSearchStr, mStorePosition_ID: String;
  dtRows: TMemTable;
  mSql, mModuleId: String;
  json: TJSONSuperObject;
begin
  json := nil;
  mSearchStr := '';
  if ((slPath.Count = 2) or (slPath.Count = 3)) then
  begin
    mStorePosition_ID := SlPath.Strings[1];
    if slPath.Count = 3 then
      mSearchStr := CFxInternet.URLDecode(ReplaceStr(slPath.Strings[2], '+', ' '));
  end else
  begin
    ErrREST(ARequest, AResponse, HTTP_SC_BadRequest, getString('wrong_parameters_count'));
    exit;
  end;

  mUser_ID := getHeaderValue(ARequest, 'UserID');
  mModule := getHeaderValue(ARequest, 'ModuleCode');
  mDocType := getHeaderValue(ARequest, 'DocumentType');

  dtRows := TMemTable.Create(nil);
  try
    LogWriteSectionStart('ListStoreCards');

    mSql :=
      'select' + FIRST_TOP(100) + nxCrLf +
      '  SC.ID as "ID",' + nxCrLf +
      '  SC.' + cStoreCardInfoCodeField + ' as "Code",' + nxCrLf +
      '  SC.' + cStoreCardInfoNameField + ' as "Name"' + nxCrLf;

    if (mDocType = DOC_LogStoreTransfer) and not CFxOID.IsEmpty(mStorePosition_ID) then
    begin
      mSql := mSql +
        ', LSC.Quantity - LSC.QuantityReserved "Available"' + nxCrLf +
        'from LogStoreContents LSC' + nxCrLf +
        'join StoreCards SC on SC.ID = LSC.StoreCard_ID and SC.Hidden = ''N''' + nxCrLf +
        'where' + nxCrLf +
        '  LSC.Parent_ID = ' + QuotedStr(mStorePosition_ID) +  nxCrLf +
        '  and LSC.Quantity > 0' + nxCrLf;
    end
    else
    begin
      mSql := mSql +
        'from StoreCards SC' + nxCrLf +
        'where' + nxCrLf +
        '  SC.Hidden = ''N''' + nxCrLf;
    end;

    //pridam omezeni, pokud je nastaveno
    mSql := mSql + StoreCard_Where(Self.ObjectSpace, mModuleId);
    if trim(mSearchStr) <> '' then
      mSql := mSql +
        '  and (SC.' + cStoreCardInfoCodeField + COLLATION_AI + 'like ''%' + mSearchStr + '%''' + nxCrLf +
        '    or SC.Code' + COLLATION_AI + 'like ''%' + mSearchStr + '%''' + nxCrLf +
        '    or SC.' + cStoreCardInfoNameField + COLLATION_AI + 'like ''%' + mSearchStr + '%'')' + nxCrLf;
    mSql := mSql +
      'order by' + nxCrLf +
      '  SC.' + cStoreCardInfoCodeField + nxCrLf +
      FIRST_TOP_ORACLE(100);

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
procedure get_StoreCardPicture(Self: TNxWebServicesHelper; ARequest: TNxHTTPRequest;
  AResponse: TNxHTTPResponse; slPath: TStringList);
var
  mStoreCard_ID, mPicture_ID, mFilePath, mModule: String;
  json: TJSONSuperObject;
  mPicture: TNxCustomBusinessObject;
  mMS: TMemoryStream;
  mImage: TImage;
begin
  json := nil;
  if (slPath.Count = 2) then
  begin
    mStoreCard_ID := slPath.Strings[1]; //ocekavam ID artiklu
  end else
  begin
    ErrREST(ARequest, AResponse, HTTP_SC_BadRequest, getString('wrong_parameters_count'));
    exit;
  end;

  mModule := getHeaderValue(ARequest, 'ModuleCode');

  LogWriteSectionStart('StoreCardPicture');

  mPicture := Self.ObjectSpace.CreateObject(Class_Picture);
  json := TJSONSuperObject.CreateByDataType(jtObject);
  mMS := TMemoryStream.Create;
  mImage := TImage.Create(nil);
  try
    mPicture_ID := SQLSelectStr(Self.ObjectSpace,
      'select Picture_ID from StoreCardPictures where Parent_ID = ' + QuotedStr(mStoreCard_ID) + ' order by PosIndex');

    if CFxOID.IsEmpty(mPicture_ID) then
    begin
      ErrREST(ARequest, AResponse, HTTP_SC_NotFound, Format(getString('storecard_image_not_found'), [mStoreCard_ID]));
    end
    else begin
      mPicture.Load(mPicture_ID, nil);
      json.S['Title'] := mPicture.GetFieldValueAsString('PictureTitle');

      // obrazek je bud v DB nebo externi
      if mPicture.GetFieldValueAsBoolean('ExternalFile') then
      begin
        mFilePath := mPicture.GetFieldValueAsString('PathAndFileName');
        mFilePath := get_StoreCardPicture_customPath(Self.ObjectSpace, mModule, mFilePath);
        if FileExists(mFilePath) then
        begin
          mMS.LoadFromFile(mFilePath);
          json.S['Data'] := EncodeBase64(mMS.GetBytes);
        end;
      end
      else begin
        mMS.SetBytes(mPicture.GetFieldValueAsBytes('BlobData'));
        NxMultiFormatImageLoadFromStream(mMS, mImage.Picture);
        mMS.Clear;
        mImage.Picture.Graphic.SaveToStream(mMS);
        json.S['Data'] := EncodeBase64(mMS.GetBytes);
      end;

      HTTPResponse(AResponse, HTTP_SC_OK, ContentType_JSON, json.AsJson(false, true));
    end;
  finally
    mImage.Free;
    mMS.Free;
    mPicture.Free;
    json.Free;
  end;

  LogWriteSectionEnd;
end;
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
procedure put_ProcessBarcode(Self: TNxWebServicesHelper; ARequest: TNxHTTPRequest;
  AResponse: TNxHTTPResponse; slPath: TStringList);
var
  mBarcode, mStoreCardNew_ID, mStoreBatchNew_ID, mSerialNumberNew_ID, mUnitCode, mSql, mUser_ID, mModule, mDocType,
    mStoreBatchAux, mDocument_ID, mRow_ID, mStoreCard_ID, mStoreFrom_ID, mStoreFromPosition_ID, mStoreTo_ID, mStoreToPosition_ID, mStoreBatch_ID,
    mStorePositionFromNew_ID, mStorePositionToNew_ID, mDialogText, mStoreFromNew_ID, mFirm_ID, mUnitCodeNew: String;
  mUnitQuantity, mUnitQuantityNew, mStoreBatchExpirationDateNew, mUnitRateNew: Double;
  mDialogType, i: Integer;
  json, jsonSB, jsonSFrom, jsonSPFrom, jsonSPTo, jsonSerialNumbers, auxJson, eanJsonArray, eanJson: TJSONSuperObject;
  dtHeader, dtRows, dtStoreBatch, dtStorePositionFrom, dtSerialNumbers, dtUnits, dtEANs: TMemTable;
  mRowsList: TStringList;
  mExtendedInfo, mWithUnits: Boolean;
begin
  json := nil;
  jsonSB := nil;
  jsonSFrom := nil;
  jsonSPFrom := nil;
  jsonSPTo := nil;
  jsonSerialNumbers := nil;

  if slPath.Count = 14 then
  begin
    mDocument_ID := slPath.Strings[1];
    mRow_ID := slPath.Strings[2];
    mFirm_ID := slPath.Strings[3];
    mStoreCard_ID := slPath.Strings[4];
    mStoreFrom_ID := slPath.Strings[5];
    mStoreFromPosition_ID := slPath.Strings[6];
    mStoreTo_ID := slPath.Strings[7];
    mStoreToPosition_ID := slPath.Strings[8];
    mStoreBatch_ID := slPath.Strings[9];
    mUnitCode := slPath.Strings[10];
    mUnitQuantity := StrToFloat(ReplaceStr(slPath.Strings[11], '.', ','));
    mExtendedInfo := slPath.Strings[12] = 'true';
    mWithUnits := slPath.Strings[13] = 'true';
  end else
  begin
    ErrREST(ARequest, AResponse, HTTP_SC_BadRequest, getString('wrong_parameters_count'));
    exit;
  end;

  try
    mUser_ID := getHeaderValue(ARequest, 'UserID');
    mModule := getHeaderValue(ARequest,'ModuleCode');
    mDocType := getHeaderValue(ARequest, 'DocumentType');

    mStoreCardNew_ID := '';
    mStoreBatchNew_ID := '';
    mStoreBatchAux := '';
    mSerialNumberNew_ID := '';
    mStorePositionFromNew_ID := '';
    mStorePositionToNew_ID := '';
    mUnitCodeNew:= '';
    mUnitQuantityNew := -1;
    mDialogText := '';
    mDialogType := 0;
    mStoreBatchExpirationDateNew := 0;
    mStoreFromNew_ID := '';
    mUnitRateNew := 0;

    dtStoreBatch := TMemTable.Create(nil);
    dtStorePositionFrom := TMemTable.Create(nil);
    dtSerialNumbers := TMemTable.Create(nil);
    auxJson := TJSONSuperObject.CreateByDataType(jtObject);
    try
      mBarcode := REST_ByteUTF82String(ARequest.Content.Content);
      // vypada to, ze se barcode posle z aplikace v uvozovkach, takze je odstranim
      if pos('"', mBarcode) = 1 then
        mBarcode := copy(mBarcode, 2, Length(mBarcode) - 2);

      DataSet_CreataHeader(dtStoreBatch, 'ID=S10,StoreBatch_ID=S10,StoreBatchName=S40,StoreCard_ID=S10,StoreCardCode=S40,StoreCardName=S100,StoreCardCategory=I');
      DataSet_CreataHeader(dtStorePositionFrom, 'ID=S10,StorePosition_ID=S10,StorePositionCode=S30,StorePositionName=S50,StorePositionType=I,'
        + 'Store_ID=S10,StoreCode=S5,StoreIsLogistic=B,PreferredStoreBatch_ID=S40,PreferredStoreBatchName=S40');
      DataSet_CreataHeader(dtSerialNumbers, 'SerNum_ID=S10,SerNumName=S40,AuxText=S30');

      parseBarcodeForRowSpecial(Self.ObjectSpace, mModule, mDocType, mBarcode,
        mDocument_ID, mRow_ID, mFirm_ID, mStoreCard_ID, mStoreFrom_ID, mStoreFromPosition_ID, mStoreTo_ID, mStoreToPosition_ID, mStoreBatch_ID, mUnitCode, mUnitQuantity,
        mStoreCardNew_ID, mStoreBatchNew_ID, mStoreFromNew_ID, mStorePositionFromNew_ID, mStorePositionToNew_ID, mUnitCodeNew, mStoreBatchAux, mStoreBatchExpirationDateNew, mUnitQuantityNew,
        mDialogText, mDialogType, dtStoreBatch, dtStorePositionFrom, dtSerialNumbers, auxJson);

      dtHeader := TMemTable.Create(nil);
      dtRows := TMemTable.Create(nil);
      dtUnits := TMemTable.Create(nil);
      dtEANs := TMemTable.Create(nil);
      mRowsList := TStringList.Create;;
      try
        // pokud jde o drobny majetek, potrebuju ziskat ID karty z jine tabulky
        if mDocType = DOC_SmallAssetCard then
        begin
          mSql := GetSmallAssetCardInfoSql(Self.ObjectSpace, mStoreCardNew_ID, True);
          mExtendedInfo := False;
        end
        else
        begin
          // TODO casem sjednotit s get_StoreCard_Info
          mSql := getStoreCardInfoSql(Self.ObjectSpace, mModule, mDocType, mUser_ID, mStoreCardNew_ID, mFirm_ID, mStoreFrom_ID, '');
          mSql := mSql + StoreCard_Where(Self.ObjectSpace, mModule);
        end;
        Self.ObjectSpace.SQLSelect2(mSql, dtHeader);

        if dtHeader.Active and mExtendedInfo then
        begin
          // dispozice po skladech
          mSql := 'select ' +
            '  SSC.StoreCard_ID as "XX_Parent_ID", ' +
            '  S.ID as "Store_ID", ' +
            '  S.Code as "StoreCode", ' +
            '  SSC.Quantity - SSC.BookedQuantity as "Available", ' +
            ' (' + get_StoreCardInfo_ByStoreValue + ') as "CustomValue"' +
            'from StoreSubCards SSC ' +
            'join Stores S on S.ID = SSC.Store_ID ' +
            'where SSC.StoreCard_ID = ' + QuotedStr(mStoreCardNew_ID) +
            '  and SSC.Quantity <> 0 ' +
            'order by S.Code ';
          Self.ObjectSpace.SQLSelect2(mSql, dtRows);
          if dtRows.Active then
          begin
            dtRows.AddIndex('id', REST_XX_Parent_ID+';StoreCode', [ixUnique]);
            dtRows.IndexName:= 'id';
            mRowsList.AddObject('rows=', dtRows);
          end;
        end;

        // pridam jednotky - bohuzel takhle osklive, protoze neumim vnorenou kolekci
        // TODO sjednotit s get_StoreCardInfo
        if mWithUnits then
        begin
          mSql :=
            'select' + nxCrLf +
            '  SU.Parent_ID as "XX_Parent_ID",' + nxCrLf +
            '  SU.PosIndex as "PosIndex",' + nxCrLf +
            '  SU.ID as "StoreUnit_ID",' + nxCrLf +
            '  SU.Code as "StoreUnitCode",' + nxCrLf +
            '  SU.Width as "Width",' + nxCrLf +
            '  SU.Height as "Height",' + nxCrLf +
            '  SU.Depth as "Depth",' + nxCrLf +
            '  SU.Weight as "Weight",' + nxCrLf +
            '  case when SC.MainUnitCode = SU.Code then ''A'' else ''N'' end "IsMainUnit$BOOL"' + nxCrLf +
            'from StoreUnits SU' + nxCrLf +
            'join StoreCards SC on SC.ID = SU.Parent_ID' + nxCrLf +
            'where' + nxCrLf +
            '  SU.Parent_ID = ' + QuotedStr(mStoreCardNew_ID);
          Self.ObjectSpace.SQLSelect2(mSql, dtUnits);
          if dtUnits.Active then
          begin
            dtUnits.AddIndex('id', REST_XX_Parent_ID+';PosIndex', [ixUnique]);
            dtUnits.IndexName:= 'id';
            mRowsList.AddObject('units=', dtUnits);
          end;
        end;

        if dtHeader.Active then
        begin
          dtHeader.First;
          json := REST_jsonCreate_FromDataSetRow(dtHeader, nil, mRowsList);

          if mWithUnits then
          begin
            // pridam EANy k jednotkam
            mSql :=
              'select' + nxCrLf +
              '  SE.ID as "ID",' + nxCrLf +
              '  SE.Parent_ID as "Parent_ID",' + nxCrLf +
              '  SE.EAN as "EAN"' + nxCrLf +
              'from StoreEANs SE' + nxCrLf +
              'join StoreUnits SU on SU.ID = SE.Parent_ID' + nxCrLf +
              'where SU.Parent_ID = ' + QuotedStr(mStoreCardNew_ID);
            Self.ObjectSpace.SQLSelect2(mSql, dtEANs);
            if dtEANs.Active then
            begin
              // protoze nevim jak na vnoverene kolekce, tak si EANy vlozim k jednotkam rucne
              for i := 0 to json.A['units'].Length - 1 do
              begin
                dtEANs.Filtered := False;
                dtEANs.Filter := 'Parent_ID=' + QuotedStr(json.A['units'].O[i].S['StoreUnit_ID']);
                dtEANs.Filtered := True;

                if dtEANs.Active then
                begin
                  dtEANS.First;

                  eanJsonArray := json.CreateJSONArray;
                  json.A['units'].O[i].O['eans'] := eanJsonArray;

                  while not dtEANS.Eof do
                  begin
                    eanJson := eanJsonArray.CreateJSON;
                    eanJson.S['StoreEAN_ID'] := dtEANs.FieldByName('ID').AsString;
                    eanJson.S['StoreEAN'] := dtEANs.FieldByName('EAN').AsString;
                    eanJsonArray.AsArray.Add(eanJson);

                    dtEANS.Next;
                  end;
                end;
              end;
            end
          end;
          json.S['json'] := auxJson.AsJson(false, true);
        end
        else
          json := TJSONSuperObject.CreateByDataType(jtObject);
      finally
        dtHeader.Free;
        dtRows.Free;
        mRowsList.Free;
      end;

      // pokud mam sarzi, pridam ji
      if mStoreBatchNew_ID <> '' then
      begin
        dtHeader := TMemTable.Create(nil);
        dtRows := TMemTable.Create(nil);
        mRowsList := TStringList.Create;;
        try
          mSql := getStoreBatchInfoSql(Self.ObjectSpace, mModule, mDocType, mUser_ID, mStoreBatchNew_ID, '');
          Self.ObjectSpace.SQLSelect2(mSql, dtHeader);

          if dtHeader.Active and mExtendedInfo then
          begin
            // dispozice po skladech
            mSql :=
              'select' + nxCrLf +
              '  SSB.StoreBatch_ID as "XX_Parent_ID",' + nxCrLf +
              '	 S.ID as "Store_ID",' + nxCrLf +
              '	 S.Code as "StoreCode",' + nxCrLf +
              '  SSB.Quantity - SSB.BookedQuantity as "Available",' + nxCrLf +
              '  SSB.BookedQuantity as "CustomValue"' + nxCrLf +
              ' from StoreSubBatches SSB' + nxCrLf +
              'join Stores S on S.ID = SSB.Store_ID' + nxCrLf +
              'where' + nxCrLf +
              '  SSB.StoreBatch_ID = ' + QuotedStr(mStoreBatchNew_ID) + nxCrLf +
              '  and SSB.Quantity <> 0' + nxCrLf +
              'order by' + nxCrLf +
              '  S.Code' + nxCrLf;
            Self.ObjectSpace.SQLSelect2(mSql, dtRows);
            if dtRows.Active then
            begin
              dtRows.AddIndex('id', REST_XX_Parent_ID+';StoreCode', [ixUnique]);
              dtRows.IndexName:= 'id';
              mRowsList.AddObject('storeRows=', dtRows);
            end;
          end;

          jsonSB := REST_jsonCreate_FromDataSetRow(dtHeader, nil, mRowsList);
        finally
          dtHeader.Free;
          dtRows.Free;
          mRowsList.Free;
        end;

        json.O['StoreBatch'] := jsonSB;
        json.O['StoreBatch'].S['StoreBatchSpecification'] := mStoreBatchAux;
        if mStoreBatchExpirationDateNew > 0 then
          json.O['StoreBatch'].S['StoreBatchExpirationDate'] := REST_json_DateTime(mStoreBatchExpirationDateNew);
      end
      else if dtStoreBatch.RecordCount > 0 then
      begin
        dtStoreBatch.First;
        jsonSB := REST_jsonCreate_FromDataSetRow(dtStoreBatch, nil);
        json.O['StoreBatch'] := jsonSB;
        json.O['StoreBatch'].S['StoreBatchSpecification'] := mStoreBatchAux;
      end;

      // pridam pripadne sklad z
      if mStoreFromNew_ID <> '' then
      begin
        dtHeader := TMemTable.Create(nil);
        try
          mSql := getStoreInfoSql(Self.ObjectSpace, mModule, mDocType, mUser_ID, mStoreFromNew_ID);
          Self.ObjectSpace.SQLSelect2(mSql, dtHeader);

          jsonSFrom := REST_jsonCreate_FromDataSetRow(dtHeader, nil);
        finally
          dtHeader.Free;
        end;
        json.O['StoreFrom'] := jsonSFrom;
      end;

      // pridam pripadne pozici z
      if mStorePositionFromNew_ID <> '' then
      begin
        dtHeader := TMemTable.Create(nil);
        dtRows := TMemTable.Create(nil);
        mRowsList := TStringList.Create;;
        try
          mSql := getStorePositionInfoSql(Self.ObjectSpace, mStorePositionFromNew_ID);
          Self.ObjectSpace.SQLSelect2(mSql, dtHeader);

          // TODO sjednotit s getStorePositionInfo
          if dtHeader.Active and mExtendedInfo then
          begin
            // dispozice artiklu na pozici
            mSql :=
              'select' + nxCrLf +
              '  max(LSC.ID) as "ID",' + nxCrLf +
              '  max(LSC.Parent_ID) as "XX_Parent_ID",' + nxCrLf +
              '  max(SC.ID) as "StoreCard_ID", ' + nxCrLf +
              '  max(SC.' + cStoreCardInfoCodeField + ') as "StoreCardCode",' + nxCrLf +
              '  max(SC.' + cStoreCardInfoNameField + ') as "StoreCardName",' + nxCrLf;

            if AvailableInStockActivity_Position_ShowBatches(Self.ObjectSpace, mModule, mDocType, mUser_ID) then
              mSql := mSql +
                '  max(SB.ID) as "StoreBatch_ID",' + nxCrLf +
                '  max(SB.Name) as "StoreBatchName",' + nxCrLf
            else
              mSql := mSql +
                '  '''' as "StoreBatch_ID",' + nxCrLf +
                '  '''' as "StoreBatchName",' + nxCrLf;

            mSql := mSql +
              '  max(SC.MainUnitCode) as "MainUnitCode",' + nxCrLf +
              '  sum(LSC.Quantity - LSC.QuantityReserved) as "Available",' + nxCrLf +
              '  sum(LSC.QuantityReserved) as "Booked"' + nxCrLf +
              'from LogStoreContents LSC' + nxCrLf +
              'join StoreCards SC on SC.ID = LSC.StoreCard_ID' + nxCrLf +
              'left join StoreBatches SB on SB.ID = LSC.StoreBatch_ID' + nxCrLf +
              'where LSC.Parent_ID = ' + QuotedStr(mStorePositionFromNew_ID) + nxCrLf;

            if AvailableInStockActivity_Position_ShowBatches(Self.ObjectSpace, mModule, mDocType, mUser_ID) then
              mSql := mSql +
                'group by LSC.StoreCard_ID, LSC.StoreBatch_ID' + nxCrLf
            else
              mSql := mSql +
                'group by LSC.StoreCard_ID' + nxCrLf;

            mSql := mSql +
              'having sum(LSC.Quantity) <> 0 ' + nxCrLf;

            if AvailableInStockActivity_Position_ShowBatches(Self.ObjectSpace, mModule, mDocType, mUser_ID) then
              mSql := mSql +
                'order by max(SC.' + cStoreCardInfoCodeField + '), max(SB.Name)'
            else
              mSql := mSql +
                'order by max(SC.' + cStoreCardInfoCodeField + ')';

            Self.ObjectSpace.SQLSelect2(mSql, dtRows);
            if dtRows.Active then
            begin
              dtRows.AddIndex('id', REST_XX_Parent_ID+';StoreCardCode;StoreCard_ID;StoreBatchName;StoreBatch_ID', [ixUnique]);
              dtRows.IndexName:= 'id';
              mRowsList.AddObject('rows=', dtRows);
            end;
          end;

          jsonSPFrom := REST_jsonCreate_FromDataSetRow(dtHeader, nil, mRowsList);
        finally
          dtHeader.Free;
          dtRows.Free;
          mRowsList.Free;
        end;
        json.O['StorePositionFrom'] := jsonSPFrom;
      end
      else if dtStorePositionFrom.RecordCount > 0 then
      begin
        dtStorePositionFrom.First;
        jsonSPFrom := REST_jsonCreate_FromDataSetRow(dtStorePositionFrom, nil);
        json.O['StorePositionFrom'] := jsonSPFrom;
      end;

      if mStorePositionToNew_ID <> '' then
      begin
        dtHeader := TMemTable.Create(nil);
        try
          mSql := getStorePositionInfoSql(Self.ObjectSpace, mStorePositionToNew_ID);
          Self.ObjectSpace.SQLSelect2(mSql, dtHeader);

          jsonSPTo := REST_jsonCreate_FromDataSetRow(dtHeader, nil);
        finally
          dtHeader.Free;
        end;
        json.O['StorePositionTo'] := jsonSPTo;
      end;

      // seriova cisla
      if dtSerialNumbers.RecordCount > 0 then
      begin
        dtSerialNumbers.First;
        jsonSerialNumbers := REST_jsonCreate_FromDataSet(dtSerialNumbers, nil);
        json.O['SerialNumbers'] := jsonSerialNumbers;
      end;

      if mUnitCodeNew <> '' then
      begin
        mSql :=
          'select' + nxCrLf +
          '  SU.UnitRate' + nxCrLf +
          'from StoreUnits SU' + nxCrLf +
          'where' + nxCrLf +
          '  SU.Parent_ID = ' + QuotedStr(mStoreCardNew_ID);
        mUnitRateNew := SQLSelectFloat(Self.ObjectSpace, mSql);

        if CFxFloat.GreaterThan6(mUnitRateNew, 0) then
        begin
          json.S['MainUnitCode'] := mUnitCodeNew;
          json.D['MainUnitRate'] := mUnitRateNew;
          json.S['SelectedUnitCode'] := mUnitCodeNew;
          json.D['SelectedUnitRate'] := mUnitRateNew;
        end;
      end;

      json.D['UnitQuantity'] := mUnitQuantityNew;

      if mDialogText <> '' then
      begin
        json.S['DialogText'] := mDialogText;
        json.I['DialogType'] := mDialogType;
      end;

      HTTPResponse(AResponse, HTTP_SC_OK, ContentType_JSON, json.AsJson(false, true));
    finally
      dtStoreBatch.Free;
      dtStorePositionFrom.Free;
      dtSerialNumbers.Free;
      dtUnits.Free;
      dtEANs.Free;
      if Assigned(json) then
        json.Free;
      if Assigned(jsonSB) then
        jsonSB.Free;
      if Assigned(jsonSFrom) then
        jsonSFrom.Free;
      if Assigned(jsonSPFrom) then
        jsonSPFrom.Free;
      if Assigned(jsonSPTo) then
        jsonSPTo.Free;
      if Assigned(jsonSerialNumbers) then
        jsonSerialNumbers.Free;
      auxJson.Free;
    end;
  except
    ErrREST(ARequest, AResponse, HTTP_SC_ExpectationFailed, ExceptionMessage);
  end;
end;
///////////////////////////////////////////////////////////////////////////////

procedure listStoreUnits(Self: TNxWebServicesHelper; ARequest: TNxHTTPRequest;
  AResponse: TNxHTTPResponse; slPath: TStringList);
var
  mSearchStr: String;
  dtRows: TMemTable;
  mSql, mStoreCard_ID: String;
  json: TJSONSuperObject;
begin
  json := nil;
  mSearchStr := '';
  if ((slPath.Count = 2) or (slPath.Count = 3)) then
  begin
    mStoreCard_ID := slPath[1];
    if slPath.Count = 3 then
      mSearchStr := CFxInternet.URLDecode(ReplaceStr(slPath.Strings[2], '+', ' '));
  end else
  begin
    ErrREST(ARequest, AResponse, HTTP_SC_BadRequest, getString('wrong_parameters_count'));
    exit;
  end;

  dtRows := TMemTable.Create(nil);
  try
    LogWriteSectionStart('listStoreCardUnits');
    mSql := 'select ' + FIRST_TOP(100) + NxCrLf +
      '  SU.ID as "ID",' + NxCrLf +
      '  SU.Code as "Code",' + NxCrLf +
      '  SU.Description as "Name"' + NxCrLf +
      'from StoreUnits SU' + NxCrLf +
      'where' + NxCrLf +
      '  SU.Parent_ID = ' + QuotedStr(mStoreCard_ID) + NxCrLf;
    if trim(mSearchStr) <> '' then
      mSql := mSql + 'and (SU.Code' + COLLATION_AI + 'like ''%' + mSearchStr + '%'' ' +
        '  or SU.Description' + COLLATION_AI + 'like ''%' + mSearchStr + '%'') ';
    mSql := mSql +
      ' order by SU.Code' +
      FIRST_TOP_ORACLE(100);

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

procedure get_StoreUnitInfo(Self: TNxWebServicesHelper; ARequest: TNxHTTPRequest;
  AResponse: TNxHTTPResponse; slPath: TStringList);
var
  mStoreUnit_ID, mModule, mUser_ID: String;
  dtHeader: TMemTable;
  dtRows: TMemTable;
  mSL: TStringList;
  mSql: String;
  json: TJSONSuperObject;
begin
  json := nil;
  if (slPath.Count = 2) then
  begin
    mStoreUnit_ID := slPath.Strings[1];
  end else
  begin
    ErrREST(ARequest, AResponse, HTTP_SC_BadRequest, getString('wrong_parameters_count'));
    exit;
  end;

  mModule := getHeaderValue(ARequest, 'ModuleCode');
  mUser_ID := getHeaderValue(ARequest, 'UserID');

  dtHeader := TMemTable.Create(nil);
  try
    // hlavicka skladu
    LogWriteSectionStart('get_StoreUnitInfo');
    mSql :=
      'select' + nxCrLf +
      '  SU.ID as "StoreUnit_ID",' + nxCrLf +
      '  SU.Code as "StoreUnitCode",' + nxCrLf +
      '  SU.Description as "StoreUnitDescription",' + nxCrLf +
      '  SU.UnitRate as "StoreUnitRate",' + nxCrLf +
      '  case' + nxCrLf +
      '    when SC.MainUnitCode = SU.Code' + nxCrLf +
      '    then ''A''' + nxCrLf +
      '    else ''N''' + nxCrLf +
      '  end "IsMainUnit$BOOL"' + nxCrLf +
      'from StoreUnits SU' + nxCrLf +
      'join StoreCards SC on SC.ID = SU.Parent_ID' + nxCrLf +
      'where' + nxCrLf +
      '  SU.ID = ' + QuotedStr(mStoreUnit_ID);
    Self.ObjectSpace.SQLSelect2(mSql, dtHeader);

    LogWriteSectionEnd;

    if dtHeader.Active then
    begin
      dtHeader.First;
      LogWriteSectionStart('JSON');
      json := REST_jsonCreate_FromDataSetRow(dtHeader, nil, nil);
      LogWriteSectionEnd;

      HTTPResponse(AResponse, HTTP_SC_OK, ContentType_JSON, json.AsJson(false, true));
    end
    else begin
      ErrREST(ARequest, AResponse, HTTP_SC_NotFound, Format(getString('storeunit_not_found'), [mStoreUnit_ID]));
    end;
  finally
    dtHeader.Free;
    if Assigned(json) then
      json.Free;
  end;
end;

procedure Put_SaveStoreCardUnit(Self: TNxWebServicesHelper; ARequest: TNxHTTPRequest;
  AResponse: TNxHTTPResponse; slPath: TStringList);
var
  mStoreCard_ID, mModule, mDocType, mUser_ID, mStoreUnit_ID: String;
  mSql: String;
  dtEANs: TMemTable;
  json: TJSONSuperObject;
  i: integer;
  mStoreUnit, mStoreCard, mEAN: TNxCustomBusinessObject;
  mStoreUnits, mEans: TNxCustomBusinessMonikerCollection;
  mOS: TNxCustomObjectSpace;
begin
  if (slPath.Count = 2) then
  begin
    mStoreCard_ID := slPath.Strings[1]; //ocekavam ID dokladu
  end else
  begin
    ErrREST(ARequest, AResponse, HTTP_SC_BadRequest, 'Nesprávný počet parametrů.');
    exit;
  end;

  LogWriteSectionStart('put_SaveStoreCardUnit');

  mOS := Self.ObjectSpace;

  mUser_ID := getHeaderValue(ARequest, 'UserID');
  mDocType := getHeaderValue(ARequest, 'DocumentType');
  mModule := getHeaderValue(ARequest, 'ModuleCode');

  json := TJSONSuperObject.ParseString(REST_ByteUTF82String(ARequest.Content.Content), True);
  dtEANs := TMemTable.Create(nil);
  mStoreCard := mOS.CreateObject(Class_StoreCard);
  try
    // dataset, do ktereho si preplnime EANy
    DataSet_CreataHeader(dtEANs, 'StoreEAN_ID=S10,StoreEAN=S60');
    dtEANs.Open;

    mOS.StartTransaction(taReadCommited);
    try
      mStoreCard.ExplicitTransaction := True;
      mStoreCard.Load(mStoreCard_ID, nil);

      mStoreUnits := mStoreCard.GetLoadedCollectionMonikerForFieldCode(mStoreCard.GetFieldCode('StoreUnits'));

      for i := 0 to mStoreUnits.Count - 1 do
      begin
        mStoreUnit := mStoreUnits.BusinessObject(i);
        mStoreUnit_ID := mStoreUnit.OID;

        if mStoreUnit_ID = json.O['StoreUnit_ID'].AsString then
        begin
          // upravim EANy
          mEans := mStoreUnit.GetLoadedCollectionMonikerForFieldCode(mStoreUnit.GetFieldCode('StoreEANs'));
          REST_JsonToDataSet(json.A['eans'], dtEANs);
          if(dtEANs.Active)then
          begin
            dtEANs.First;
            while(not dtEANs.Eof)do
            begin
              if dtEANs.FieldByName('StoreEAN_ID').AsString = '' then
              begin
                mEAN := mEans.AddNewObject;
                mEAN.Prefill;
                mEAN.SetFieldValueAsString('EAN', dtEANs.FieldByName('StoreEAN').AsString);
              end;
              dtEANs.Next;
            end;
          end;

          break;
        end;
      end;

      if mStoreCard.NeedSave then
        mStoreCard.Save;

      mOS.Commit;

      HTTPResponse(AResponse, HTTP_SC_OK, ContentType_JSON, PlainResponse(''));
    except
      mOS.RollBack;
      ErrREST(ARequest, AResponse, HTTP_SC_ExpectationFailed, ExceptionMessage);
      glog.WriteEvent(logError, 'put_SaveStoreCardUnit - error - ' + ExceptionMessage);
    end;
  finally
    mStoreCard.Free;
    json.Free;
    dtEANs.Free;
    LogWriteSectionEnd;
  end;
end;

procedure Get_CheckEanExistence(Self: TNxWebServicesHelper; ARequest: TNxHTTPRequest;
  AResponse: TNxHTTPResponse; slPath: TStringList);
var
  mSql, mUser_ID, mEan, mEanFounded_ID, mDocType, mModule: String;
  mOS: TNxCustomObjectSpace;
begin
  if (slPath.Count = 2) then
  begin
    mEan := slPath.Strings[1];
  end else
  begin
    ErrREST(ARequest, AResponse, HTTP_SC_BadRequest, 'Nesprávný počet parametrů.');
    exit;
  end;

  LogWriteSectionStart('get_CheckEanExistence');

  mOS := Self.ObjectSpace;

  mUser_ID := getHeaderValue(ARequest, 'UserID');
  mDocType := getHeaderValue(ARequest, 'DocumentType');
  mModule := getHeaderValue(ARequest, 'ModuleCode');

  try
    mSql :=
      'select ID from StoreEANS where EAN = ' + QuotedStr(mEan);

    mEanFounded_ID := SQLSelectStr(mOS, mSql);

    if mEanFounded_ID = '' then
      HTTPResponse(AResponse, HTTP_SC_OK, ContentType_JSON, PlainResponse(''))
    else
      ErrREST(ARequest, AResponse, HTTP_SC_ExpectationFailed, 'EAN "' + mEan + '" již v databázi existuje.');
  except
    ErrREST(ARequest, AResponse, HTTP_SC_ExpectationFailed, ExceptionMessage);
    LogWriteSectionEnd;
  end;

  LogWriteSectionEnd;
end;

begin
end.