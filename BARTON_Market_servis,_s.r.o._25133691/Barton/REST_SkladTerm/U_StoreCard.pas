uses
  'REST_SkladTerm.U_Func',
  'REST_SkladTerm.U_FuncJSON',
  'REST_SkladTerm.U_SQLQueries',
  'REST_SkladTerm_Special.U_Const',
  'REST_SkladTerm_Special.U_StandardHooks',
  'StandardUnits.U_DataSet',
  'StandardUnits.U_Func',
  'StandardUnits.U_GetId';

procedure get_StoreCardInfo(AOS: TNxCustomObjectSpace; APath, AQueryParams, AResponse: TStringList);
var
  mBarcode, mBarcode_Orig, mFirm_ID, mStore_ID, mStoreUnit_ID, mExtendedInfoStore_ID: String;
  mExtendedInfo, mWithUnits, mIsId, mWithStoreUnit, mAsArray: Boolean;
  dtHeader: TMemTable;
  dtRows, dtUnits, dtEANs: TMemTable;
  mSL, mStoreCardIds: TStringList;
  mSql: String;
  json, eanJson, eanJsonArray: TJSONSuperObject;
  i, j: Integer;
begin
  json := nil;
  if (APath.Count = 8) then
  begin
    // dekoduju text (predtim musim jeste nahradit + mezerou, protoze delphi koduje jinak nez java)
    mBarcode :=  CFxInternet.URLDecode(ReplaceStr(APath.Strings[1], '+', ' '));
    mIsId := APath.Strings[2] = 'true';
    mFirm_ID := APath.Strings[3];
    mStore_ID := APath.Strings[4];
    mWithUnits := APath.Strings[5] = 'true';
    mExtendedInfo := APath.Strings[6] = 'true';
    mExtendedInfoStore_ID := APath.Strings[7];
  end else
  begin
    SetPlainResponse(AResponse, getString('wrong_parameters_count'), HTTP_SC_BadRequest);
    exit;
  end;

  mAsArray := AQueryParams.Values('asArray') = 'true';

  mStoreCardIds := TStringList.Create;
  try
    // v pripade artiklu nemusi prijit primo jeho ID, ale treba nejaky jiny identifikator (EAN apod.)
    // zde tedy zjistime nejprve jeho ID
    mWithStoreUnit := False;
    mStoreUnit_ID := '';
    mBarcode_Orig := mBarcode;
    GetStoreCard_ID(AOS, mBarcode, mIsId, mWithStoreUnit, mStoreCardIds);

    if mStoreCardIds.Count = 0 then
    begin
      SetPlainResponse(AResponse, Format(getString('article_not_found'), [mBarcode_Orig]), HTTP_SC_NotFound);
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

      mSql := getStoreCardInfoSql(AOS, gSkladTermModule, gSkladTermDocType, gSkladTermUser_ID, mStoreCardIds, mFirm_ID, mStore_ID, '');
      AOS.SQLSelect2(mSql, dtHeader);

      if dtHeader.Active then
      begin
        // projdu si dataset a odstranim z nej informace o pripadne jednotce, protoze uz je nepotrebuju
        for i := 0 to mStoreCardIds.Count - 1 do
          mStoreCardIds.Strings(i) := Copy(mStoreCardIds.Strings(i), 1, 10);

        if mExtendedInfo then
        begin
          // dispozice po skladech
          mSql :=
            'select ' + nxCrLf +
            '  SSC.StoreCard_ID as "XX_Parent_ID",' + nxCrLf +
            '  S.ID as "Store_ID",' + nxCrLf +
            '  S.Code as "StoreCode",' + nxCrLf +
            '  (SSC.Quantity - SSC.BookedQuantity) / SU.UnitRate as "Available",' + nxCrLf +
            '  cast(' + get_StoreCardInfo_ByStoreValue + ' as varchar(30)) as "CustomValue"' + nxCrLf +
            'from StoreSubCards SSC' + nxCrLf +
            'join StoreCards SC on SC.ID = SSC.StoreCard_ID' + nxCrLf +
            'join StoreUnits SU on SU.Parent_ID = SC.ID and SU.Code = SC.MainUnitCode' + nxCrLf +
            'join Stores S on S.ID = SSC.Store_ID' + nxCrLf +
            'where' + nxCrLf +
            '  SSC.StoreCard_ID in (''' + ReplaceStr(mStoreCardIds.DelimitedText, ',', ''',''') + ''')' + nxCrLf +
            '  and SSC.Quantity <> 0' + nxCrLf;

          if not CFxOID.IsEmpty(mExtendedInfoStore_ID) then
            mSql := mSql +
              '  and S.ID = ' + QuotedStr(mExtendedInfoStore_ID) + nxCrLf;

          mSql := mSql +
            'order by' + nxCrLf +
            '  S.Code';
          AOS.SQLSelect2(mSql, dtRows);
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
            '  SU.Parent_ID in (''' + ReplaceStr(mStoreCardIds.DelimitedText, ',', ''',''') + ''')';
          AOS.SQLSelect2(mSql, dtUnits);
          if dtUnits.Active then
          begin
            dtUnits.AddIndex('id', REST_XX_Parent_ID+';PosIndex', [ixUnique]);
            dtUnits.IndexName:= 'id';
            mSL.AddObject('units=', dtUnits);
          end;
        end;

        dtHeader.First;
        // TODO muzu odstranit az se bude vzdy volat jako pole
        if mAsArray then
        begin
          BeforeJSONCreate(AOS, gSkladTermModule, gSkladTermDocType, gSkladTermUser_ID, dtHeader);
          json := REST_jsonCreate_FromDataSet(dtHeader, nil, mSL);

          if mWithUnits then
          begin
            for j := 0 to json.AsArray.Length - 1 do
            begin
              // pridam EANy k jednotkam
              mSql :=
                'select' + nxCrLf +
                '  SE.ID as "ID",' + nxCrLf +
                '  SE.Parent_ID as "Parent_ID",' + nxCrLf +
                '  SE.EAN as "EAN"' + nxCrLf +
                'from StoreEANs SE' + nxCrLf +
                'join StoreUnits SU on SU.ID = SE.Parent_ID' + nxCrLf +
                'where SU.Parent_ID = ' + QuotedStr(json.AsArray.O[j].S['StoreCard_ID']);
              AOS.SQLSelect2(mSql, dtEANs);
              if dtEANs.Active then
              begin
                // protoze nevim jak na vnoverene kolekce, tak si EANy vlozim k jednotkam rucne
                for i := 0 to json.AsArray.O[j].A['units'].Length - 1 do
                begin
                  dtEANs.Filtered := False;
                  dtEANs.Filter := 'Parent_ID=' + QuotedStr(json.AsArray.O[j].A['units'].O[i].S['StoreUnit_ID']);
                  dtEANs.Filtered := True;

                  if dtEANs.Active then
                  begin
                    dtEANS.First;

                    eanJsonArray := json.CreateJSONArray;
                    json.AsArray.O[j].A['units'].O[i].O['eans'] := eanJsonArray;

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
              end;
            end;
          end;
        end
        else
        begin
          BeforeJSONCreate(AOS, gSkladTermModule, gSkladTermDocType, gSkladTermUser_ID, dtHeader);
          json := REST_jsonCreate_FromDataSetRow(dtHeader, nil, mSL);
        end;

        LogWriteSectionEnd;

        BeforeJSONSend(AOS, gSkladTermModule, gSkladTermDocType, gSkladTermUser_ID, json);
        SetResponse(AResponse, json.AsJson(false, true));
      end
      else begin
        SetPlainResponse(AResponse, Format(getString('article_not_found'), [mBarcode_Orig]), HTTP_SC_NotFound);
      end;
    finally
      mStoreCardIds.Free;
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

procedure get_StoreCardInfoPositions(AOS: TNxCustomObjectSpace; APath, AResponse: TStringList);
var
  mStoreCard_ID, mStoreBatch_ID, mStore_ID, mStoreCard_ID_Orig: String;
  dtHeader: TMemTable;
  dtRows: TMemTable;
  mSL, mStoreCardIds: TStringList;
  mSql: String;
  json: TJSONSuperObject;
  mIsId, mOnlyAvailable: Boolean;
begin
  json := nil;
  if (APath.Count = 6) then
  begin
    mStoreCard_ID := APath.Strings[1];
    mStoreBatch_ID  := APath.Strings[2];
    mIsId := APath.Strings[3] = 'true';
    mStore_ID := APath.Strings[4];
    mOnlyAvailable := APath.Strings[5] = 'true';
  end else
  begin
    SetPlainResponse(AResponse, getString('wrong_parameters_count'), HTTP_SC_BadRequest);
    exit;
  end;

  mStoreCardIds := TStringList.Create;
  try
    // v pripade artiklu nemusi prijit primo jeho ID, ale treba nejaky jiny identifikator (EAN apod.)
    // zde tedy zjistime nejprve jeho ID
    mStoreCard_ID_Orig := mStoreCard_ID;
    GetStoreCard_ID(AOS, mStoreCard_ID, mIsId, False, mStoreCardIds);

    if mStoreCardIds.Count = 0 then
    begin
      SetPlainResponse(AResponse, Format(getString('article_not_found'), [mStoreCard_ID_Orig]), HTTP_SC_NotFound);
      exit;
    end;

    mStoreCard_ID := mStoreCardIds.Strings(0);
  finally
    mStoreCardIds.Free;
  end;

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
    AOS.SQLSelect2(mSql, dtHeader);

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
      AOS.SQLSelect2(mSql, dtRows);
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

      SetResponse(AResponse, json.AsJson(false, true));
    end
    else
      SetPlainResponse(AResponse, Format(getString('article_not_found'), [mStoreCard_ID_Orig]), HTTP_SC_NotFound);
  finally
    dtHeader.Free;
    dtRows.Free;
    mSL.Free;
    if Assigned(json) then
      json.Free;
  end;
end;

procedure get_StoreCardInfoBatchesOnPosition(AOS: TNxCustomObjectSpace; APath, AResponse: TStringList);
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
  if (APath.Count = 4) then
  begin
    mStoreCard_ID := APath.Strings[1]; //ocekavam artikl
    mStorePosition_ID  := APath.Strings[2];
    mStore_ID := APath.Strings[3]; //ocekavam sklad
  end else
  begin
    SetPlainResponse(AResponse, getString('wrong_parameters_count'), HTTP_SC_BadRequest);
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
    AOS.SQLSelect2(mSql, dtHeader);

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
      AOS.SQLSelect2(mSql, dtRows);
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

      SetResponse(AResponse, json.AsJson(false, true));
    end
    else
      SetPlainResponse(AResponse, Format(getString('position_not_found'), [mStorePosition_ID]), HTTP_SC_NotFound);
  finally
    dtHeader.Free;
    dtRows.Free;
    mSL.Free;
    if Assigned(json) then
      json.Free;
  end;
end;

procedure get_AvailableQuantity(AOS: TNxCustomObjectSpace; APath, AResponse: TStringList);
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
  if (APath.Count = 9) then
  begin
    mStore_ID := APath.Strings[1];
    mStoreCard_ID := APath.Strings[2];
    mStoreDocument2_ID := APath.Strings[3];
    mQuantityDifference := StrToInt(APath.Strings[4]);
    mEnteredQuantity := StrToFloat(ReplaceStr(APath.Strings[5], '.', ','));
    mStoreBatch_ID := APath.Strings[6];
    mStorePosition_ID := APath.Strings[7];
    mStorePositionTo_ID := APath.Strings[8];
  end else
  begin
    SetPlainResponse(AResponse, getString('wrong_parameters_count'), HTTP_SC_BadRequest);
    exit;
  end;

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

    AOS.SQLSelect2(mSql, dtHeader);
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
    dtHeader.FieldByName('DialogText').AsString := dialogTextOnRowSave(AOS, mModule, mUser_ID,
      mStoreDocument2_ID, mStoreCard_ID, mStoreBatch_ID, mStore_ID, mStorePosition_ID, mEnteredQuantity);
    dtHeader.Post;

    dtHeader.First;

    try
      //hacek ve kterem lze ovlivnit mnozstvi povolene pro radek dokladu
      LogWriteSectionStart('get_AvailableQuantityHook');
      get_AvailableQuantityHook(AOS, mModule, mDocType, mUser_ID, mStore_ID, mStorePosition_ID, mStorePositionTo_ID,
        mStoreCard_ID, mStoreBatch_ID, mStoreDocument2_ID, dtHeader, mQuantityDifference, mEnteredQuantity);
      LogWriteSectionEnd;

      LogWriteSectionStart('JSON');
      json := REST_jsonCreate_FromDataSetRow(dtHeader, nil, mSL);
      LogWriteSectionEnd;

      SetResponse(AResponse, json.AsJson(false, true));
    except
      SetPlainResponse(AResponse, ExceptionMessage, HTTP_SC_ExpectationFailed);
    end;
  finally
    dtHeader.Free;
    mSL.Free;
    if Assigned(json) then
      json.Free;
  end;
end;

function listStoreCards(AOS: TNxCustomObjectSpace; ASearch, AStorePosition_ID: String; AAllowedIds: String): String;
var
  mSql: String;
begin
  LogWriteSectionStart('listStoreCards');
  try
    mSql :=
      'select' + FIRST_TOP(100) + nxCrLf +
      '  SC.ID as "ID",' + nxCrLf +
      '  SC.' + cStoreCardInfoCodeField + ' as "Code",' + nxCrLf +
      '  SC.' + cStoreCardInfoNameField + ' as "Name"' + nxCrLf;

    if (gSkladTermDocType = DOC_LogStoreTransfer) and not CFxOID.IsEmpty(AStorePosition_ID) then
    begin
      mSql := mSql +
        ', LSC.Quantity - LSC.QuantityReserved "Available"' + nxCrLf +
        'from LogStoreContents LSC' + nxCrLf +
        'join StoreCards SC on SC.ID = LSC.StoreCard_ID and SC.Hidden = ''N''' + nxCrLf +
        'where' + nxCrLf +
        '  LSC.Parent_ID = ' + QuotedStr(AStorePosition_ID) +  nxCrLf +
        '  and LSC.Quantity > 0' + nxCrLf;
    end
    else
    begin
      mSql := mSql +
        'from StoreCards SC' + nxCrLf +
        'where' + nxCrLf +
        '  SC.Hidden = ''N''' + nxCrLf;
    end;

    if AAllowedIds <> '' then
      mSql := mSql +
        '  and SC.ID in (''' + ReplaceText(AAllowedIds, ',', ''',''') + ''')' + nxCrLf;

    //pridam omezeni, pokud je nastaveno
    mSql := mSql + StoreCard_Where(AOS, gSkladTermModule, gSkladTermDocType, gSkladTermUser_ID);
    if trim(ASearch) <> '' then
      mSql := mSql +
        '  and (SC.' + cStoreCardInfoCodeField + COLLATION_AI + 'like ''%' + ASearch + '%''' + nxCrLf +
        '    or SC.Code' + COLLATION_AI + 'like ''%' + ASearch + '%''' + nxCrLf +
        '    or SC.' + cStoreCardInfoNameField + COLLATION_AI + 'like ''%' + ASearch + '%'')' + nxCrLf;
    mSql := mSql +
      'order by' + nxCrLf +
      '  SC.' + cStoreCardInfoCodeField + nxCrLf +
      FIRST_TOP_ORACLE(100);

    Result := mSql;
  finally
    LogWriteSectionEnd;
  end;
end;

procedure get_StoreCardPicture(AOS: TNxCustomObjectSpace; APath, AResponse: TStringList);
var
  mStoreCard_ID, mFilePath, mSql: String;
  json, jsonPicture: TJSONSuperObject;
  mPicture: TNxCustomBusinessObject;
  mMS: TMemoryStream;
  mPicturesIds: TStringList;
  mImage: TImage;
  i: Integer;
begin
  json := nil;
  if (APath.Count = 2) then
  begin
    mStoreCard_ID := APath.Strings[1];
  end
  else
  begin
    SetPlainResponse(AResponse, getString('wrong_parameters_count'), HTTP_SC_BadRequest);
    exit;
  end;

  LogWriteSectionStart('StoreCardPicture');

  mPicture := AOS.CreateObject(Class_Picture);
  json := TJSONSuperObject.CreateByDataType(jtArray);
  mMS := TMemoryStream.Create;
  mImage := TImage.Create(nil);
  mPicturesIds := TStringList.Create;
  try
    mSql :=
      'select' + nxCrLf +
      '  Picture_ID' + nxCrLf +
      'from StoreCardPictures' + nxCrLf +
      'where' + nxCrLf +
      '  Parent_ID = ' + QuotedStr(mStoreCard_ID) + nxCrLf +
      'order by' + nxCrLf +
      '  PosIndex';
    AOS.SQLSelect(mSql, mPicturesIds);

    if mPicturesIds.Count = 0 then
      SetPlainResponse(AResponse, Format(getString('storecard_image_not_found'), [mStoreCard_ID]), HTTP_SC_NotFound)
    else
    begin
      for i := 0 to mPicturesIds.Count - 1 do
      begin
        mPicture.Load(mPicturesIds.Strings(i), nil);

        jsonPicture := TJSONSuperObject.CreateByDataType(jtObject);
        try
          jsonPicture.S['Picture_ID'] := mPicturesIds.Strings(i);
          jsonPicture.I['PosIndex'] := i;
          jsonPicture.S['Title'] := mPicture.GetFieldValueAsString('PictureTitle');

          // obrazek je bud v DB nebo externi
          if mPicture.GetFieldValueAsBoolean('ExternalFile') then
          begin
            mFilePath := mPicture.GetFieldValueAsString('PathAndFileName');
            mFilePath := get_StoreCardPicture_customPath(AOS, gSkladTermModule, mFilePath);
            if FileExists(mFilePath) then
            begin
              mMS.LoadFromFile(mFilePath);
              jsonPicture.S['Data'] := EncodeBase64(mMS.GetBytes);
            end;
          end
          else
          begin
            mMS.SetBytes(mPicture.GetFieldValueAsBytes('BlobData'));
            NxMultiFormatImageLoadFromStream(mMS, mImage.Picture);
            mMS.Clear;
            mImage.Picture.Graphic.SaveToStream(mMS);
            jsonPicture.S['Data'] := EncodeBase64(mMS.GetBytes);
          end;

          json.AsArray.Add(jsonPicture);
        finally
          jsonPicture.Free;
        end;
      end;
      SetResponse(AResponse, json.AsJson(false, true));
    end;
  finally
    mImage.Free;
    mMS.Free;
    mPicture.Free;
    json.Free;
    mPicturesIds.Free;
  end;

  LogWriteSectionEnd;
end;

procedure put_ProcessBarcode(AOS: TNxCustomObjectSpace; APath: TStringList; ABody: String; AResponse: TStringList);
var
  mBarcode, mStoreCardNew_ID, mStoreBatchNew_ID, mSerialNumberNew_ID, mUnitCode, mSql, mNextStoreCardBarcode,
    mStoreBatchAux, mDocument_ID, mRow_ID, mStoreCard_ID, mStoreFrom_ID, mStoreFromPosition_ID, mStoreTo_ID, mStoreToPosition_ID, mStoreBatch_ID,
    mStorePositionFromNew_ID, mStorePositionToNew_ID, mDialogText, mStoreFromNew_ID, mFirm_ID, mUnitCodeNew: String;
  mOriginalUnitQuantity, mActualUnitQuantity, mUnitQuantityNew, mStoreBatchExpirationDateNew, mUnitRateNew: Double;
  mDialogType, i: Integer;
  json, jsonSB, jsonSFrom, jsonSPFrom, jsonSPTo, jsonSerialNumbers, auxJson, eanJsonArray, eanJson: TJSONSuperObject;
  dtHeader, dtRows, dtStoreBatch, dtStorePositionFrom, dtSerialNumbers, dtUnits, dtEANs: TMemTable;
  mRowsList, mStoreCardIds: TStringList;
  mExtendedInfo, mWithUnits: Boolean;
begin
  json := nil;
  jsonSB := nil;
  jsonSFrom := nil;
  jsonSPFrom := nil;
  jsonSPTo := nil;
  jsonSerialNumbers := nil;

  if APath.Count = 15 then
  begin
    mDocument_ID := APath.Strings[1];
    mRow_ID := APath.Strings[2];
    mFirm_ID := APath.Strings[3];
    mStoreCard_ID := APath.Strings[4];
    mStoreFrom_ID := APath.Strings[5];
    mStoreFromPosition_ID := APath.Strings[6];
    mStoreTo_ID := APath.Strings[7];
    mStoreToPosition_ID := APath.Strings[8];
    mStoreBatch_ID := APath.Strings[9];
    mUnitCode := APath.Strings[10];
    mOriginalUnitQuantity := StrToFloat(ReplaceStr(APath.Strings[11], '.', ','));
    mActualUnitQuantity := StrToFloat(ReplaceStr(APath.Strings[12], '.', ','));
    mExtendedInfo := APath.Strings[13] = 'true';
    mWithUnits := APath.Strings[14] = 'true';
  end else
  begin
    SetPlainResponse(AResponse, getString('wrong_parameters_count'), HTTP_SC_BadRequest);
    exit;
  end;

  try
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
    mNextStoreCardBarcode := '';

    dtStoreBatch := TMemTable.Create(nil);
    dtStorePositionFrom := TMemTable.Create(nil);
    dtSerialNumbers := TMemTable.Create(nil);
    auxJson := TJSONSuperObject.CreateByDataType(jtObject);
    try
      mBarcode := ABody;
      // vypada to, ze se barcode posle z aplikace v uvozovkach, takze je odstranim
      if pos('"', mBarcode) = 1 then
        mBarcode := copy(mBarcode, 2, Length(mBarcode) - 2);

      DataSet_CreataHeader(dtStoreBatch, 'ID=S10,StoreBatch_ID=S10,StoreBatchName=S40,StoreCard_ID=S10,StoreCardCode=S40,StoreCardName=S100,StoreCardCategory=I');
      DataSet_CreataHeader(dtStorePositionFrom, 'id=S10,code=S30,name=S50,type=I,'
        + 'storeId=S10,storeCode=S5,storeIsLogistic=B,preferredStoreBatchId=S40,preferredStoreBatchName=S40');
      DataSet_CreataHeader(dtSerialNumbers, 'SerNum_ID=S10,SerNumName=S40,AuxText=S30');

      parseBarcodeForRowSpecial(AOS, gSkladTermModule, gSkladTermDocType, gSkladTermUser_ID, mBarcode,
        mDocument_ID, mRow_ID, mFirm_ID, mStoreCard_ID, mStoreFrom_ID, mStoreFromPosition_ID, mStoreTo_ID, mStoreToPosition_ID, mStoreBatch_ID,
        mUnitCode, mOriginalUnitQuantity, mActualUnitQuantity, mStoreCardNew_ID, mStoreBatchNew_ID, mStoreFromNew_ID, mStorePositionFromNew_ID,
        mStorePositionToNew_ID, mUnitCodeNew, mStoreBatchAux, mNextStoreCardBarcode, mStoreBatchExpirationDateNew, mUnitQuantityNew,
        mDialogText, mDialogType, dtStoreBatch, dtStorePositionFrom, dtSerialNumbers, auxJson);

      dtHeader := TMemTable.Create(nil);
      dtRows := TMemTable.Create(nil);
      dtUnits := TMemTable.Create(nil);
      dtEANs := TMemTable.Create(nil);
      mRowsList := TStringList.Create;
      mStoreCardIds := TStringList.Create;
      try
        mStoreCardIds.Add(mStoreCardNew_ID);

        // pokud jde o drobny majetek, potrebuju ziskat ID karty z jine tabulky
        if gSkladTermDocType = DOC_SmallAssetCard then
        begin
          mSql := GetSmallAssetCardInfoSql(AOS, mStoreCardNew_ID, True);
          mExtendedInfo := False;
        end
        else
        begin
          // TODO casem sjednotit s get_StoreCard_Info
          mSql := getStoreCardInfoSql(AOS, gSkladTermModule, gSkladTermDocType, gSkladTermUser_ID, mStoreCardIds, mFirm_ID, mStoreFrom_ID, '');

          if mStoreCardIds.Count > 0 then
            mStoreCardNew_ID := mStoreCardIds.Strings(0);
        end;
        AOS.SQLSelect2(mSql, dtHeader);

        if dtHeader.Active and mExtendedInfo then
        begin
          // dispozice po skladech
          mSql := 'select ' +
            '  SSC.StoreCard_ID as "XX_Parent_ID", ' +
            '  S.ID as "Store_ID", ' +
            '  S.Code as "StoreCode", ' +
            '  (SSC.Quantity - SSC.BookedQuantity) / SU.UnitRate as "Available", ' +
            '   cast((' + get_StoreCardInfo_ByStoreValue + ' as varchar(30)) as "CustomValue"' +
            'from StoreSubCards SSC ' +
            'join StoreCards SC on SC.ID = SSC.StoreCard_ID' + nxCrLf +
            'join StoreUnits SU on SU.Parent_ID = SC.ID and SU.Code = SC.MainUnitCode' + nxCrLf +
            'join Stores S on S.ID = SSC.Store_ID ' +
            'where SSC.StoreCard_ID = ' + QuotedStr(mStoreCardNew_ID) +
            '  and SSC.Quantity <> 0 ' +
            'order by S.Code ';
          AOS.SQLSelect2(mSql, dtRows);
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
          AOS.SQLSelect2(mSql, dtUnits);
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
            AOS.SQLSelect2(mSql, dtEANs);
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
        dtEANs.Free;
        mRowsList.Free;
        mStoreCardIds.Free;
      end;

      // pokud mam sarzi, pridam ji
      if not CFxOID.IsEmpty(mStoreBatchNew_ID)then
      begin
        dtHeader := TMemTable.Create(nil);
        dtRows := TMemTable.Create(nil);
        mRowsList := TStringList.Create;;
        try
          mSql := getStoreBatchInfoSql(AOS, gSkladTermModule, gSkladTermDocType, gSkladTermUser_ID, mStoreBatchNew_ID, '');
          AOS.SQLSelect2(mSql, dtHeader);

          if dtHeader.Active and mExtendedInfo then
          begin
            // dispozice po skladech
            mSql :=
              'select' + nxCrLf +
              '  SSB.StoreBatch_ID as "XX_Parent_ID",' + nxCrLf +
              '	 S.ID as "Store_ID",' + nxCrLf +
              '	 S.Code as "StoreCode",' + nxCrLf +
              '  SSB.Quantity - SSB.BookedQuantity as "Available",' + nxCrLf +
              '  cast(SSB.BookedQuantity as varchar(30)) as "CustomValue"' + nxCrLf +
              ' from StoreSubBatches SSB' + nxCrLf +
              'join Stores S on S.ID = SSB.Store_ID' + nxCrLf +
              'where' + nxCrLf +
              '  SSB.StoreBatch_ID = ' + QuotedStr(mStoreBatchNew_ID) + nxCrLf +
              '  and SSB.Quantity <> 0' + nxCrLf +
              'order by' + nxCrLf +
              '  S.Code' + nxCrLf;
            AOS.SQLSelect2(mSql, dtRows);
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
      if not CFxOID.IsEmpty(mStoreFromNew_ID) then
      begin
        dtHeader := TMemTable.Create(nil);
        try
          mSql := getStoreInfoSql(AOS, gSkladTermModule, gSkladTermDocType, gSkladTermUser_ID, mStoreFromNew_ID);
          AOS.SQLSelect2(mSql, dtHeader);

          jsonSFrom := REST_jsonCreate_FromDataSetRow(dtHeader, nil);
        finally
          dtHeader.Free;
        end;
        json.O['StoreFrom'] := jsonSFrom;
      end;

      // pridam pripadne pozici z
      if not CFxOID.IsEmpty(mStorePositionFromNew_ID) then
      begin
        dtHeader := TMemTable.Create(nil);
        dtRows := TMemTable.Create(nil);
        mRowsList := TStringList.Create;;
        try
          mSql := getStorePositionInfoSql(AOS, mStorePositionFromNew_ID);
          AOS.SQLSelect2(mSql, dtHeader);

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

            if AvailableInStockActivity_Position_ShowBatches(AOS, gSkladTermModule, gSkladTermDocType, gSkladTermUser_ID) then
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

            if AvailableInStockActivity_Position_ShowBatches(AOS, gSkladTermModule, gSkladTermDocType, gSkladTermUser_ID) then
              mSql := mSql +
                'group by LSC.StoreCard_ID, LSC.StoreBatch_ID' + nxCrLf
            else
              mSql := mSql +
                'group by LSC.StoreCard_ID' + nxCrLf;

            mSql := mSql +
              'having sum(LSC.Quantity) <> 0 ' + nxCrLf;

            if AvailableInStockActivity_Position_ShowBatches(AOS, gSkladTermModule, gSkladTermDocType, gSkladTermUser_ID) then
              mSql := mSql +
                'order by max(SC.' + cStoreCardInfoCodeField + '), max(SB.Name)'
            else
              mSql := mSql +
                'order by max(SC.' + cStoreCardInfoCodeField + ')';

            AOS.SQLSelect2(mSql, dtRows);
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
          dtUnits.Free;
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

      if not CFxOID.IsEmpty(mStorePositionToNew_ID) then
      begin
        dtHeader := TMemTable.Create(nil);
        try
          mSql := getStorePositionInfoSql(AOS, mStorePositionToNew_ID);
          AOS.SQLSelect2(mSql, dtHeader);

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
          '  SU.Parent_ID = ' + QuotedStr(mStoreCardNew_ID) + nxCrLf +
          '  and SU.Code = ' + QuotedStr(mUnitCodeNew);
        mUnitRateNew := SQLSelectFloat(AOS, mSql);

        if CFxFloat.GreaterThan6(mUnitRateNew, 0) then
        begin
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

      if mNextStoreCardBarcode <> '' then
        json.S['nextStoreCardBarcode'] := mNextStoreCardBarcode;

      SetResponse(AResponse, json.AsJson(false, true));
    finally
      dtStoreBatch.Free;
      dtStorePositionFrom.Free;
      dtSerialNumbers.Free;
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
    SetPlainResponse(AResponse, getExceptionMessage, HTTP_SC_ExpectationFailed);
  end;
end;

function listStoreUnits(ASearch, AStoreCard_ID: String): String;
var
  mSql, mStoreCard_ID: String;
begin
  LogWriteSectionStart('listStoreCardUnits');
  try
    mSql :=
      'select ' + FIRST_TOP(100) + NxCrLf +
      '  SU.ID as "ID",' + NxCrLf +
      '  SU.Code as "Code",' + NxCrLf +
      '  SU.Description as "Name"' + NxCrLf +
      'from StoreUnits SU' + NxCrLf +
      'where' + NxCrLf +
      '  SU.Parent_ID = ' + QuotedStr(AStoreCard_ID) + NxCrLf;
    if trim(ASearch) <> '' then
      mSql := mSql + 'and (SU.Code' + COLLATION_AI + 'like ''%' + ASearch + '%'' ' +
        '  or SU.Description' + COLLATION_AI + 'like ''%' + ASearch + '%'') ';
    mSql := mSql +
      ' order by SU.Code' +
      FIRST_TOP_ORACLE(100);

    Result := mSql;
  finally
    LogWriteSectionEnd;
  end;
end;

procedure get_StoreUnitInfo(AOS: TNxCustomObjectSpace; APath, AResponse: TStringList);
var
  mStoreUnit_ID: String;
  dtHeader: TMemTable;
  dtRows: TMemTable;
  mSL: TStringList;
  mSql: String;
  json: TJSONSuperObject;
begin
  json := nil;
  if (APath.Count = 2) then
  begin
    mStoreUnit_ID := APath.Strings[1];
  end else
  begin
    SetPlainResponse(AResponse, getString('wrong_parameters_count'), HTTP_SC_BadRequest);
    exit;
  end;

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
    AOS.SQLSelect2(mSql, dtHeader);

    LogWriteSectionEnd;

    if dtHeader.Active then
    begin
      dtHeader.First;
      LogWriteSectionStart('JSON');
      json := REST_jsonCreate_FromDataSetRow(dtHeader, nil, nil);
      LogWriteSectionEnd;

      SetResponse(AResponse, json.AsJson(false, true));
    end
    else
      SetPlainResponse(AResponse, Format(getString('storeunit_not_found'), [mStoreUnit_ID]), HTTP_SC_NotFound);
  finally
    dtHeader.Free;
    if Assigned(json) then
      json.Free;
  end;
end;

procedure Put_SaveStoreCardUnit(AOS: TNxCustomObjectSpace; APath: TStringList; ABody: String; AResponse: TStringList);
var
  mStoreCard_ID, mStoreUnit_ID: String;
  mSql: String;
  dtEANs: TMemTable;
  json: TJSONSuperObject;
  i: integer;
  mStoreUnit, mStoreCard, mEAN: TNxCustomBusinessObject;
  mStoreUnits, mEans: TNxCustomBusinessMonikerCollection;
begin
  if (APath.Count = 2) then
  begin
    mStoreCard_ID := APath.Strings[1];
  end else
  begin
    SetPlainResponse(AResponse, getString('wrong_parameters_count'), HTTP_SC_BadRequest);
    exit;
  end;

  LogWriteSectionStart('put_SaveStoreCardUnit');

  json := TJSONSuperObject.ParseString(ABody, True);
  dtEANs := TMemTable.Create(nil);
  mStoreCard := AOS.CreateObject(Class_StoreCard);
  try
    // dataset, do ktereho si preplnime EANy
    DataSet_CreataHeader(dtEANs, 'StoreEAN_ID=S10,StoreEAN=S60');
    dtEANs.Open;

    AOS.StartTransaction(taReadCommited);
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

      AOS.Commit;

      SetResponse(AResponse, PlainResponse(''));
    except
      AOS.RollBack;
      SetPlainResponse(AResponse, ExceptionMessage, HTTP_SC_ExpectationFailed);
      gLog.WriteEvent(logError, 'put_SaveStoreCardUnit - error - ' + ExceptionMessage);
    end;
  finally
    mStoreCard.Free;
    json.Free;
    dtEANs.Free;
    LogWriteSectionEnd;
  end;
end;

procedure Post_CheckEanExistence(AOS: TNxCustomObjectSpace; ABody: String; APath, AResponse: TStringList);
var
  mSql, mEan, mEanFounded_ID: String;
begin
  if APath.Count <> 1 then
  begin
    SetPlainResponse(AResponse, getString('wrong_parameters_count'), HTTP_SC_BadRequest);
    exit;
  end;

  LogWriteSectionStart('Post_CheckEanExistence');
  try
    mEan := ABody;
    // vypada to, ze se barcode posle z aplikace v uvozovkach, takze je odstranim
    if pos('"', mEan) = 1 then
      mEan := copy(mEan, 2, Length(mEan) - 2);

    mSql :=
      'select ID from StoreEANS where EAN = ' + QuotedStr(mEan);

    mEanFounded_ID := SQLSelectStr(AOS, mSql);

    if mEanFounded_ID = '' then
      SetResponse(AResponse, PlainResponse(''))
    else
      SetPlainResponse(AResponse, Format(getString('error_ean_already_exists'), [mEan]), HTTP_SC_ExpectationFailed);
  except
    SetPlainResponse(AResponse, ExceptionMessage, HTTP_SC_ExpectationFailed);
    LogWriteSectionEnd;
  end;

  LogWriteSectionEnd;
end;

begin
end.