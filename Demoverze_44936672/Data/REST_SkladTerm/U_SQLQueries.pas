uses
  'REST_SkladTerm.U_Func',
  'REST_SkladTerm.U_TemporaryStorage',
  'REST_SkladTerm_Special.U_Const',
  'REST_SkladTerm_Special.U_StandardHooks',
  'StandardUnits.U_DataSet',
  'StandardUnits.U_GetId';

function getHeaderSql(AOS: TNxCustomObjectSpace; AModule, AUser_ID, ADoc_ID, ADocType, AAuxField: String; AAuxReadOnly: Boolean; AChangeableFields: String): String;
var
  mTable, mGroupBy: String;
  mFirmNameLabel, mFirmCodeLabel, mFirmOfficeLabel, mDisplayName, mFirmName, mFirmCode, mFirmOffice: String;
begin
  Result := customGetHeaderSql(AOS, AModule, ADoc_ID, ADocType, AAuxField, AAuxReadOnly, AChangeableFields);

  mTable := GetTable(ADocType);

  mFirmNameLabel := QuotedStr('Firma:');
  mFirmCodeLabel := QuotedStr('');
  mFirmOfficeLabel := QuotedStr('');

  mDisplayName := 'DQ.Code' + CONCAT_STR + QuotedStr('-') + CONCAT_STR + 'cast(SD.OrdNumber as varchar(6))' +
    CONCAT_STR + QuotedStr('/') + CONCAT_STR + 'P.Code';
  mFirmName := 'F.Name';
  mFirmCode := QuotedStr('');
  mFirmOffice := QuotedStr('');

  getHeaderSql_Fields(AOS, Amodule, ADocType, AUser_ID, mFirmNameLabel, mFirmCodeLabel, mFirmOfficeLabel, mDisplayName, mFirmName, mFirmCode, mFirmOffice);

  if Result = '' then
  begin
    Result := 'select' + NxCrLf +
      '  SD.ID as "ID",' + NxCrLf +
      '  ' + mDisplayName + ' as "DisplayName",' + NxCrLf +
      '  SD.DocDate$DATE as "DocDate$DATE",' + nxCrLf +
      '  ' + mFirmNameLabel + ' as "FirmNameLabel",' +  NxCrLf +
      '  ' + mFirmCodeLabel + ' as "FirmCodeLabel",' +  NxCrLf +
      '  ' + mFirmOfficeLabel + ' as "FirmOfficeLabel",' +  NxCrLf +
      '  SD.Firm_ID as "Firm_ID",' +  NxCrLf +
      '  ' + mFirmName + ' as "FirmName",' +  NxCrLf +
      '  ' + mFirmCode + ' as "FirmCode",' +  NxCrLf +
      '  ' + mFirmOffice + ' as "FirmOffice",' +  NxCrLf;

    if ADocType = DOC_JOBORDER then
      Result := Result +
        '  SD.CodeID as "Description",' + NxCrLf
    else
      Result := Result +
        '  SD.Description as "Description",' + NxCrLf;

    if ADocType in [DOC_ReceiptCard, DOC_BillOfDelivery, DOC_OutgoingTransfer, DOC_RefundedBillOfDelivery, DOC_IncomingTransfer, DOC_ReceivedOrder] then
      Result := Result +
        '  TT.ID as "TransportationType_ID",' +  NxCrLf +
        '  TT.Code as "TransportationTypeCode",' +  NxCrLf;
    if AAuxField <> '' then
    begin
      Result := Result +
        '  SD.' + AAuxField + ' as "AuxText",' + NxCrLf +
        '  ' + QuotedStr(NxBoolToString(AAuxReadOnly)) + ' as "AuxReadOnly",' + NxCrLf +;
    end;
    if AChangeableFields <> '' then
    begin
      Result := Result +
        AChangeableFields + ' as "ChangeableFields",' + NxCrLf +;
    end;
    Result := Result +
      GetSQLDocHeaderParameters(AOS, ADocType, AModule, AUser_ID, ADoc_ID) + NxCrLf +
      'from ' + mTable + ' SD' + nxCrLf +
      'join Firms F on F.ID = SD.Firm_ID' + nxCrLf +
      'join DocQueues DQ on DQ.ID = SD.DocQueue_ID' + nxCrLf +
      'join Periods P on P.ID = SD.Period_ID' + nxCrLf +
      putQueueDocDetailStartPicking_HeaderJoin(AOS, AModule, ADocType, AUser_ID) + NxCrLf;
      if ADocType in [DOC_ReceiptCard, DOC_BillOfDelivery, DOC_OutgoingTransfer, DOC_RefundedBillOfDelivery, DOC_IncomingTransfer, DOC_RECEIVEDORDER] then
        Result := Result +
          'left join TransportationTypes TT on TT.ID = SD.TransportationType_ID' + nxCrLf;
      Result := Result +
        'where SD.ID = ' + QuotedStr(ADoc_ID);

    mGroupBy := putQueueDocDetailStartPicking_HeaderGroupBy(AOS, Amodule, AUser_ID);
    if mGroupBy <> '' then
      Result := Result + nxCrLf + 'group by' + nxCrLf + mGroupBy;
  end;
end;

function getRowsSql(AOS: TNxCustomObjectSpace; AModule, AUser_Id, ADocType: String; var AWhere: String): String;
var
  mTable: String;
  mStoreCardBehavior, mStoreBatchBehavior, mStorePositionBehavior, mStoreBatchNoteVisibility, mStoreBatchNoteField: String;
  mExpirationEnterType: Integer;
  mStoreBatchNoteReadOnly: Boolean;
begin
  Result := customGetRowsSql(AOS, AModule, AUser_Id, ADocType, AWhere);

  mTable := GetTable(ADocType);

  if Result = '' then
  begin
    if ADocType in [DOC_ShippingList, DOC_RemovalList] then
      Result :=
        'select' + nxCrLf +
        '  A2.Parent_ID as "XX_Parent_ID",' + nxCrLf +
        '  A2.PosIndex as "PosIndex",' + nxCrLf +
        '  A2.ID as "ID",' + nxCrLf
    else
      Result :=
        'select' + nxCrLf +
        '  SD2.Parent_ID as "XX_Parent_ID",' + nxCrLf +
        '  SD2.PosIndex as "PosIndex",' + nxCrLf +
        '  SD2.ID as "ID",' + nxCrLf;

    Result := Result +
      '  ' + putQueueDocDetailStartPicking_RowsOrderBy(AOS, AModule, ADocType, AUser_ID) + ' as "OrderForIndex",' + nxCrLf +
      '  SD.ID as "StoreDocument_ID",' + nxCrLf +
      '  SD2.ID as "StoreDocument2_ID",' + nxCrLf +
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
      '  ' + DefaultUnitQuantity(AOS, AModule) + ' as  "DefaultUnitQuantity",' + nxCrLf +
      '  coalesce(LSP.ID, '''') as "StorePositionFrom_ID",' + nxCrLf +
      '  coalesce(LSP.Code, '''') as "StorePositionFromCode",' + nxCrLf +
      '  coalesce(SB.ID, '''') as "StoreBatch_ID",' + nxCrLf +
      '  ' + putQueueDocDetailStartPicking_StoreBatchField(AOS, AModule, ADocType) + ' as "StoreBatchName",' + nxCrLf +
      '  coalesce(SB.ExpirationDate$DATE, 1.0) as "StoreBatchExpirationDate$DATE",' + nxCrLf +
      '  ' + canAddNewBatch(AOS, AModule) + ' as "CanAddNewBatch",' + nxCrLf +
      '  ' + enabledCustomFields(AOS, AUser_Id, AModule) + ' as "EnabledFields",' + nxCrLf +
//      '  ' + customFields(AOS, AUser_Id, AModule) + ' "customFields", ' + nxCrLf +
      '  ' + DisableQuantityEdit(AOS, AModule) + ' as "DisableQuantityEdit",' + nxCrLf +
      '  ' + rowAuxText(AOS, AModule, ADocType, AUser_ID) + ' as "AuxText",' + nxCrLf +
      '  ' + rowAuxText2(AOS, AModule, ADocType, AUser_ID) + ' as "AuxText2",' + nxCrLf +
      '  ' + putQueueDocDetailStartPicking_customRowColor(AOS, AModule, AUser_Id) + ' as "CustomColor",' + nxCrLf +
      '  ' + putQueueDocDetailStartPicking_CanEnterBiggerQuantity(AOS, AModule, ADocType, AUser_ID) + ' as "CanEnterBiggerQuantity$BOOL",' + nxCrLf +
      '  ' + ShowOtherUnitsUnitRate(AOS, AModule, ADocType, AUser_ID) + ' as "ShowOtherUnitsUnitRate$BOOL",' + nxCrLf +
      '  ' + putQueueDocDetailStartPicking_rowsAuxFields(AOS, AModule, ADocType, AUser_ID) + nxCrLf;

    if ADocType = DOC_IssuedOrder then
      Result := Result +
        '  ' + QuotedStr(DOC_IssuedOrder) + ' as "StoreDocumentType",' + nxCrLf
    else
      Result := Result +
        '  SD.DocumentType as "StoreDocumentType",' + nxCrLf;

    // zadavani data expirace
    mExpirationEnterType := 0;
    Result := Result +
      '  ' + EnterStoreBatchExpirationDate(AOS, AModule, ADocType, AUser_ID, mExpirationEnterType) + ' as "EnterStoreBatchExpirationDate",' + nxCrLf +
      '  ' + IntToStr(mExpirationEnterType) + ' as "StoreBatchExpDateEnterType",' + nxCrLf;

    // musí být jako string, protože GSON v Android parsuje Enum ze stringu
    mStoreBatchNoteVisibility := '0';
    mStoreBatchNoteField := '';
    StoreBatchNoteVisibility(AOS, AModule, ADocType, AUser_ID, mStoreBatchNoteVisibility, mStoreBatchNoteField);
    Result := Result +
      '  cast(' + mStoreBatchNoteVisibility + ' as varchar(1)) as "StoreBatchNoteVisibility",' + nxCrLf;
    if mStoreBatchNoteField = '' then
      Result := Result +
        '  '''''
    else
      Result := Result +
        '  SB.' + mStoreBatchNoteField;
    Result := Result +
       ' as "StoreBatchNote",' + nxCrLf;

    // chovani poli (zmena, validace)
    mStoreCardBehavior := '0';
    mStoreBatchBehavior := '0';
    mStorePositionBehavior := '0';
    EnteredFieldsBehavior(AOS, AModule, ADocType, AUser_ID, mStoreCardBehavior, mStoreBatchBehavior, mStorePositionBehavior);
    Result := Result +
      '  cast(' + mStoreCardBehavior + ' as int) as "StoreCardBehavior",' + nxCrLf +
      '  cast(' + mStoreBatchBehavior + ' as int) as "StoreBatchBehavior",' + nxCrLf +
      '  cast(' + mStorePositionBehavior + ' as int) as "StorePositionBehavior",' + nxCrLf;

    // u vratek chci jina pole
    if ADocType = DOC_RefundedBillOfDelivery then
      Result := Result +
        '  coalesce(SD.RDocument_ID, '''') as "StoreDocument2Provide_ID",' + nxCrLf +
        '  coalesce(SD2.RDocumentRow_ID, '''') as "StoreDocument2ProvideRow_ID",' + nxCrLf
    else if ADocType = DOC_LogStoreTransfer then
      Result := Result +
        '  coalesce(SD.StoreDocument_ID, '''') as "StoreDocument2Provide_ID",' + nxCrLf +
        '  coalesce(SD2.StoreDocRow_ID, '''') as "StoreDocument2ProvideRow_ID",' + nxCrLf
    else if ADocType = DOC_IssuedOrder then
      Result := Result +
        '  SD.ID as "StoreDocument2Provide_ID",' + nxCrLf +
        '  SD2.ID as "StoreDocument2ProvideRow_ID",' + nxCrLf
    else
      Result := Result +
        '  coalesce(SD2.Provide_ID, '''') as "StoreDocument2Provide_ID",' + nxCrLf +
        '  coalesce(SD2.ProvideRow_ID, '''') as "StoreDocument2ProvideRow_ID",' + nxCrLf;

    if (AModule = 'STD_RefundedBillOfDeliveryQueue') and useBillOfDeliveryForRefunding then
      Result := Result +
        '  coalesce(RS.ID, S.ID) as "StoreFrom_ID",' + nxCrLf +
        '  coalesce(RS.Code, S.Code) as "StoreFromCode",' + nxCrLf +
        '  coalesce(RS.IsLogistic, S.IsLogistic) as "StoreFromIsLogistic$BOOL",' + nxCrLf
    else
      Result := Result +
        '  S.ID as "StoreFrom_ID",' + nxCrLf +
        '  S.Code as "StoreFromCode",' + nxCrLf +
        '  S.IsLogistic as "StoreFromIsLogistic$BOOL",' + nxCrLf;

    // pro presuny mezi pozicemi nejsou zadna strediska apod, ani vyroba
    if ADocType = DOC_LogStoreTransfer then
    begin
      Result := Result +
        '  '''' as "Division_ID",' + nxCrLf +
        '  '''' as "BusProject_ID",' + nxCrLf +
        '  '''' as "BusOrder_ID",' + nxCrLf +
        '  '''' as "BusTransaction_ID",' + nxCrLf +
        '  S.IsLogistic as "StoreToIsLogistic$BOOL",' + nxCrLf +
        '  LSP2.ID as "StorePositionTo_ID",' + nxCrLf +
        '  LSP2.Code as "StorePositionToCode",' + nxCrLf +
        '  '''' as "AccJobOrder_ID",' + nxCrLf +
        '  '''' as "PRFContainerMater_ID",' + nxCrLf +
        '  S.ID as "StoreTo_ID",' + nxCrLf +
        '  S.Code as "StoreToCode",' + nxCrLf +
        '  '''' as "DocRowBatch_ID",' + nxCrLf +
        '  '''' as "LogStoreDocument2_ID",' + nxCrLf +
        '  SD2.UnitRate as "UnitRate",' + nxCrLf +
        '  SD2.QUnit as "UnitCode",' + nxCrLf;

      if useMainUnits(AOS, AModule, ADocType, AUser_Id) then
        Result := Result +
          '  SD2.Quantity as "UnitQuantity",' + nxCrLf +
          '  SD2.Quantity as "UnitQuantityOrig"' + nxCrLf
      else
        Result := Result +
          '  SD2.Quantity / SD2.UnitRate as "UnitQuantity",' + nxCrLf +
          '  SD2.Quantity / SD2.UnitRate as "UnitQuantityOrig"' + nxCrLf;
    end
    else
    begin
      Result := Result +
        '  SD2.Division_ID as "Division_ID",' + nxCrLf +
        '  SD2.BusProject_ID as "BusProject_ID",' + nxCrLf +
        '  SD2.BusOrder_ID as "BusOrder_ID",' + nxCrLf +
        '  SD2.BusTransaction_ID as "BusTransaction_ID",' + nxCrLf +
        '  '''' as "StorePositionTo_ID",' + nxCrLf +
        '  '''' as "StorePositionToCode",' + nxCrLf +
        '  coalesce(DRB.ID, '''') as "DocRowBatch_ID",' + nxCrLf +
        '  coalesce(LSD2.ID, '''') as "LogStoreDocument2_ID",' + nxCrLf;

      if useMainUnits(AOS, AModule, ADocType, AUser_Id) then
      begin
        if ADocType = DOC_IssuedOrder then
          Result := Result +
            '  SD2.Quantity - SD2.DeliveredQuantity as "UnitQuantity",' + nxCrLf +
            '  SD2.Quantity - SD2.DeliveredQuantity as "UnitQuantityOrig",' + nxCrLf
        else
          Result := Result +
            '  coalesce(LSD2.Quantity, DRB.Quantity, SD2.Quantity) as "UnitQuantity",' + nxCrLf +
            '  coalesce(LSD2.Quantity, DRB.Quantity, SD2.Quantity) as "UnitQuantityOrig",' + nxCrLf;
        Result := Result +
          '  coalesce(LSD2.UnitRate, SD2.UnitRate) as "UnitRate",' + nxCrLf +
          '  coalesce(LSD2.QUnit, SD2.QUnit) as "UnitCode",' + nxCrLf;
      end
      else
      begin
        if ADocType = DOC_IssuedOrder then
          Result := Result +
            '  (SD2.Quantity - SD2.DeliveredQuantity) / SD2.UnitRate as "UnitQuantity",' + nxCrLf +
            '  (SD2.Quantity - SD2.DeliveredQuantity) / SD2.UnitRate as "UnitQuantityOrig",' + nxCrLf
        else
          Result := Result +
            '  coalesce(LSD2.Quantity, DRB.Quantity, SD2.Quantity) / SD2.UnitRate as "UnitQuantity",' + nxCrLf +
            '  coalesce(LSD2.Quantity, DRB.Quantity, SD2.Quantity) / SD2.UnitRate as "UnitQuantityOrig",' + nxCrLf;
        Result := Result +
          '  SD2.UnitRate as "UnitRate",' + nxCrLf +
          '  SD2.QUnit as "UnitCode",' + nxCrLf;
      end;

      if ADocType = DOC_IssuedOrder then
        Result := Result +
          '  '''' as "AccJobOrder_ID",' + nxCrLf +
          '  '''' as "PRFContainerMater_ID",' + nxCrLf +
          '  '''' as "StoreTo_ID",' + nxCrLf +
          '  '''' as "StoreToCode",' + nxCrLf +
          '  ''N'' as "StoreToIsLogistic$BOOL"' + nxCrLf
      else if ABRA then
        Result := Result +
          // jina vyroba
          '  coalesce(JO.ID, '''') as "AccJobOrder_ID",' + nxCrLf +
          '  coalesce(MAT.Parent_ID, '''') as "PRFContainerMater_ID",' + nxCrLf +
          '  coalesce(S2.ID, '''') as "StoreTo_ID",' + nxCrLf +
          '  coalesce(S2.Code, '''') as "StoreToCode",' + nxCrLf +
          '  coalesce(S2.IsLogistic, ''N'') as "StoreToIsLogistic$BOOL"' + nxCrLf
      else
        Result := Result +
          '  coalesce(SD2.AccJobOrder_ID, '''') as "AccJobOrder_ID",' + nxCrLf +
          '  coalesce(SD2.PRFContainerMater_ID, '''') as "PRFContainerMater_ID",' + nxCrLf +
          '  coalesce(S2.ID, S3.ID, '''') as "StoreTo_ID",' + nxCrLf +
          '  coalesce(S2.Code, S3.Code, '''') as "StoreToCode",' + nxCrLf +
          '  coalesce(S2.IsLogistic, S3.IsLogistic, ''N'') as "StoreToIsLogistic$BOOL"' + nxCrLf;
    end;

    if ADocType in [DOC_ShippingList, DOC_RemovalList] then
      Result := Result +
        'from ' + mTable + '2 A2' + nxCrLf +
        'join StoreDocuments2 SD2 on SD2.ID = A2.ProvideRow_ID' + nxCrLf
    else
      Result := Result +
        'from ' + mTable + '2 SD2' + nxCrLf +
        'join ' + mTable + ' SD on SD.id = SD2.Parent_ID' + nxCrLf;

    Result := Result +
      'join Stores S on S.ID = SD2.Store_ID' + nxCrLf +
      'left join Stores RS on RS.ID = S.RefundStore_ID' + nxCrLf;

    if ADocType = DOC_LogStoreTransfer then
    begin
      Result := Result +
        'join LogStoreDocuments2 LSD3 on LSD3.ID = SD2.MasterRow_ID' + nxCrLf +
        'join LogStorePositions LSP2 on LSP2.ID = LSD3.StorePosition_ID'  + nxCrLf +
        'left join StoreBatches SB on SB.ID = SD2.StoreBatch_ID' + nxCrLf;
    end
    else
    begin
      if ADocType <> DOC_IssuedOrder then
      begin
        if ABRA then
          Result := Result +
            // vyroba z ABRA (prvni je na ziskani radku kusovniku, druhy ID vyr. prikazu
            'left join PLMMIPLMaterialDistrib MAT on MAT.StoreDocument2_ID = SD2.ID' + NxCrLf +
            'left join PLMJobOrders JO on JO.ProductionTask_ID = SD2.ProductionTask_ID' + NxCrLf
          else
            Result := Result +
              'left join Stores S3 on S3.ID = SD.PlannedReverseDocumentStore_ID' + nxCrLf;

        Result := Result +
          'left join DocRowBatches DRB on DRB.Parent_ID = SD2.ID' + nxCrLf +
          'left join StoreBatches SB on SB.ID = DRB.StoreBatch_ID' + nxCrLf +
          // join na radky abych mohl vzit sklad z PRP
          'left join StoreDocuments2 SD2_PRP on SD2_PRP.ProvideRow_ID = SD2.ID and SD2_PRP.FlowType = ' + QuotedStr(DOC_IncomingTransfer) + nxCrLf +
          'left join Stores S2 on S2.ID = SD2_PRP.Store_ID' + nxCrLf;
      end
      else
        Result := Result +
          'left join DocRowBatches DRB on DRB.Parent_ID = ''0000000000''' + nxCrLf +
          'left join StoreBatches SB on SB.ID = DRB.StoreBatch_ID' + nxCrLf;
    end;

    Result := Result +
      'join StoreCards SC on SC.ID = SD2.StoreCard_ID' + nxCrLf;

    if (AModule = 'STD_RefundedBillOfDeliveryQueue') and useBillOfDeliveryForRefunding then
      Result := Result +
        'left join LogStoreDocuments2 LSD2 on ''0000000000'' = SD2.ID' + nxCrLf +
        'left join LogStorePositions LSP on ''0000000000'' =  LSD2.ID' + nxCrLf
    else if ADocType = DOC_LogStoreTransfer then
      Result := Result +
        'left join LogStorePositions LSP on LSP.ID = SD2.StorePosition_ID' + nxCrLf
    else if ADocType = DOC_IssuedOrder then
      Result := Result +
        'left join LogStoreDocuments2 LSD2 on LSD2.StoreDocRow_ID = ''0000000000''' + nxCrLf +
        'left join LogStorePositions LSP on LSP.ID =  ''0000000000''' + nxCrLf
    else
      Result := Result +
        'left join LogStoreDocuments2 LSD2 on LSD2.StoreDocRow_ID = SD2.ID and coalesce(LSD2.StoreBatch_ID, '''') = coalesce(DRB.StoreBatch_ID, '''')' + nxCrLf +
        'left join LogStorePositions LSP on LSP.ID = ' + putQueueDocDetailStartPicking_StorePositionFromJoinField(AOS, ADocType) + ' ' + nxCrLf;

    Result := Result +
      'left join CodeStructures CS on CS.ID = SC.StoreBatchStructure_ID' + nxCrLf +
      ' ' + putQueueDocDetailStartPicking_Join(AOS, AModule, AUser_Id) + ' ' + nxCrLf +
      'where ' + nxCrLf
      + AWhere + nxCrLf +
      'order by SD2.PosIndex';
    end;
end;

{function getRowsForIssuedOrder(AOS: TNxCustomObjectSpace; AModule, AUser_Id, ADocType: String; var AWhere: String): String;
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
      '  coalesce(LSD2.Quantity, DRB.Quantity, SD2.Quantity) as "UnitQuantity",' + nxCrLf +
      '  coalesce(LSD2.Quantity, DRB.Quantity, SD2.Quantity) as "UnitQuantityOrig",' + nxCrLf +
      '  coalesce(LSD2.UnitRate, SD2.UnitRate) as "UnitRate",' + nxCrLf +
      '  coalesce(LSD2.QUnit, SD2.QUnit) as "UnitCode",' + nxCrLf
  else
    Result := Result +
      '  coalesce(LSD2.Quantity, DRB.Quantity, SD2.Quantity) / SD2.UnitRate as "UnitQuantity",' + nxCrLf +
      '  coalesce(LSD2.Quantity, DRB.Quantity, SD2.Quantity) / SD2.UnitRate as "UnitQuantityOrig",' + nxCrLf +
      '  SD2.UnitRate as "UnitRate",' + nxCrLf +
      '  SD2.QUnit as "UnitCode",' + nxCrLf;
  Result := Result +
    '  SD2.Division_ID as "Division_ID",' + nxCrLf +
    '  SD2.BusProject_ID as "BusProject_ID",' + nxCrLf +
    '  SD2.BusOrder_ID as "BusOrder_ID",' + nxCrLf +
    '  SD2.BusTransaction_ID as "BusTransaction_ID",' + nxCrLf +
    '  ' + canAddNewBatch(AOS, AModule) + ' as "CanAddNewBatch",' + nxCrLf +
    '  ' + enabledCustomFields(AOS, AUser_Id, AModule) + ' as "EnabledFields",' + nxCrLf +
//      '  ' + customFields(AOS, AUser_Id, AModule) + ' "customFields", ' + nxCrLf +
    '  ' + DisableQuantityEdit(AOS, AModule) + ' as "DisableQuantityEdit",' + nxCrLf +
    '  ' + rowAuxText(AOS, AModule, ADocType, AUser_ID) + ' as "AuxText",' + nxCrLf +
    '  ' + rowAuxText2(AOS, AModule, ADocType, AUser_ID) + ' as "AuxText2",' + nxCrLf +
    '  ' + putQueueDocDetailStartPicking_customRowColor(AOS, AModule, AUser_Id) + ' as "CustomColor",' + nxCrLf +
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
    'where ' + AWhere + ' ' + nxCrLf +
    'order by SD2.PosIndex';
end;}

// Pokud AIsUnit = True, tak v AStoreCard_ID mam ID jednotky (StoreUnit) a chci vratit detaily k tyhle jednotce
function getStoreCardInfoSql(AOS: TNxCustomObjectSpace; AModule, ADocType, AUser_ID, AStoreCard_ID, AFirm_ID, AStore_ID: String; AStoreUnit_ID: String; AToBatch_ID: String = ''): String;
var
  mTitle: String;
  mStoreCardBehavior, mStoreBatchNoteVisibility: String;
begin
  Result :=
    'select' + nxCrLf +
    '  SC.ID as "ID",' + nxCrLf + // kvuli navazani polozkoveho datasetu
    '  SC.ID as "StoreCard_ID",' + nxCrLf +
    '  SC.' + cStoreCardInfoCodeField + ' as "StoreCardCode",' + nxCrLf +
    '  SC.' + cStoreCardInfoNameField + ' as "StoreCardName",' + nxCrLf +
    '  SC.ShortName as "StoreCardShortName",' + nxCrLf;

  if AToBatch_ID <> '' then
    Result := Result +
      QuotedStr(AToBatch_ID) + ' as "XX_Parent_ID",' + nxCrLf;

  if not CFxOID.IsEmpty(AStoreUnit_ID) then
    // TODO doplneni poli
    Result := Result +
      '  coalesce(SU2.Code, '''') as "SelectedUnitCode",' + nxCrLf +
      '  coalesce(SU2.UnitRate, 0) as "SelectedUnitRate",' + nxCrLf
  else
    Result := Result +
      '  coalesce(SC.MainUnitCode, '''') as "SelectedUnitCode",' + nxCrLf +
      '  coalesce(SU.UnitRate, 0) as "SelectedUnitRate",' + nxCrLf;

  if ABRA then
    Result := Result +
      '  case' + nxCrLf +
      '    when SC.NonStockType = ''A''' + nxCrLf +
      '    then ''N''' + nxCrLf +
      '    else ''A''' + nxCrLf +
      '  end as "StoreCardIsStockType$BOOL",' + nxCrLf
  else
    Result := Result +
      '  SC.IsStockType as "StoreCardIsStockType$BOOL",' + nxCrLf;

  Result := Result +
    '  ' + putQueueDocDetailStartPicking_StoreCardAuxInfoForSerNumField(AOS) + ' as "StoreCardAuxInfoForSerNum$BOOL",' + nxCrLf +
    '  ' + putQueueDocDetailStartPicking_StoreCardCategory(AOS, AModule, ADocType, AUser_ID) + ' as "StoreCardCategory",' + nxCrLf +
    '  '';''' + CONCAT_STR + getUnitsSql + CONCAT_STR + ''';'' as "StoreCardUnits",' + nxCrLf +
    '  SC.MainUnitCode as "MainUnitCode",' + nxCrLf +
    '  SU.UnitRate as "MainUnitRate",' + nxCrLf +
    '  case ' + nxCrLf +
    '    when (SC.SerialNumberStructure  <> '''') or (CS.CodeStructure is not null and CS.CodeStructure <> '''')' + nxCrLf +
    '    then ''A''' + nxCrLf +
    '    else ''N''' + nxCrLf +
    '  end as "HasStoreBatchStructure$BOOL",' + nxCrLf +
    '  ' + canAddNewBatch(AOS, AModule) + ' as "CanAddNewBatch",' + nxCrLf +
    '  ' + enabledCustomFields(AOS, AUser_ID, AModule, AStoreCard_ID) + ' as "enabledFields",' + nxCrLf +
    '  coalesce((select ' + FIRST_TOP(1) + ' ''A'' from StoreCardPictures SCP left join Pictures P on P.ID = SCP.Picture_ID where SCP.Parent_ID = ' + QuotedStr(AStoreCard_ID) + FIRST_TOP_ORACLE(1) + '), ''N'') as "HasPicture$BOOL",' + nxCrLf +
    '  (select sum(SSC.Quantity - SSC.BookedQuantity) / SU.UnitRate from StoreSubCards SSC where SSC.StoreCard_ID = '+QuotedStr(AStoreCard_ID)+') as "SUM_Available",' + nxCrLf +
    '  (' + get_StoreCardInfo_SummaryValue(AOS, AStoreCard_ID, mTitle) + ') as "SUM_CustomValue", ' + nxCrLf +
    '  ' + mTitle + 'as "SUM_CustomTitle",' + NxCrLf +
    '  '';''' + CONCAT_STR + putQueueDocDetailStartPicking_StoreCardBarcodeField(AOS, AModule) + CONCAT_STR + ''';'' as "StoreCardBarcode",' + nxCrLf +
    '  ' + get_StoreCardInfo_AuxField(AOS, AModule, AUser_ID, AStoreCard_ID, AFirm_ID, AStore_ID) + ' as "AuxField",' + NxCrLf +
    '  ' + DefaultUnitQuantity(AOS, AModule) + ' as  "DefaultUnitQuantity",' + nxCrLf +
    '  ' + rowAuxText(AOS, AModule, ADocType, AUser_ID) + ' as "AuxText",' + NxCrLf +
    '  ' + rowAuxText2(AOS, AModule, ADocType, AUser_ID) + ' as "AuxText2",' + NxCrLf;

    // musí být jako string, protože GSON v Android parsuje Enum ze stringu
    mStoreBatchNoteVisibility := '0';
    StoreBatchNoteVisibility(AOS, AModule, ADocType, AUser_ID, mStoreBatchNoteVisibility, '');
    Result := Result +
      '  cast(' + mStoreBatchNoteVisibility + ' as varchar(1)) as "StoreBatchNoteVisibility",' + nxCrLf;

  // chovani poli (zmena, validace)
  mStoreCardBehavior := '0';
  EnteredFieldsBehavior(AOS, AModule, ADocType, AUser_ID, mStoreCardBehavior, '0', '0');
  Result := Result +
    'cast (' + mStoreCardBehavior + ' as int) as "StoreCardBehavior"' + nxCrLf;

  Result := Result +
    'from StoreCards SC' + nxCrLf +
    'join StoreUnits SU on SU.Parent_ID = SC.ID and SU.Code = SC.MainUnitCode' + nxCrLf +
    'left join CodeStructures CS on CS.ID = SC.StoreBatchStructure_ID' + nxCrLf +
    'left join StoreUnits SU2 on SU2.Parent_ID = SC.ID and SU2.ID = ' + QuotedStr(AStoreUnit_ID) + nxCrLf +
    get_StoreCardInfo_Join(AOS, AModule, AUser_ID) + nxCrLf +
    'where SC.ID = ' + QuotedStr(AStoreCard_ID);
end;
///////////////////////////////////////////////////////////////////////////////

function GetSmallAssetCardInfoSql(AOS: TNxCustomObjectSpace; ABarcode: String; AIsId: Boolean): String;
var
  mSql, mResult: String;
begin
  mSql :=
    'select' + nxCrLf +
    '  SAC.ID as "ID",' + nxCrLf +
    '  SAC.ID as "StoreCard_ID",' + nxCrLf +
    '  SAC.InventoryNr as "StoreCardCode",' + nxCrLf +
    '  SAC.Name as "StoreCardName"' + nxCrLf +
    'from SmallAssetCards SAC' + nxCrLf +
    'where' + nxCrLf +
    '  SAC.Status = 0' + nxCrLf;

  if AIsId then
    mSql := mSql +
      '  and SAC.ID = ' + QuotedStr(ABarcode)
  else
    mSql := mSql +
      '  and (SAC.EAN = ' + QuotedStr(ABarcode)  + nxCrLf +
      '    or SAC.InventoryNr = ' + QuotedStr(ABarcode) + ')' + nxCrLf;

  Result := mSql;
end;

///////////////////////////////////////////////////////////////////////////////
function getStoreBatchInfoSql(AOS: TNxCustomObjectSpace; AModule, ADocType, AUser_ID, AStoreBatch_ID, AStoreCard_ID: String): String;
var
  mSqlCondition, mSql, mStoreBatchNoteField: String;
begin
  if CFxOID.IsEmpty(AStoreCard_ID) then
    mSqlCondition := 'SB.ID = ' + QuotedStr(AStoreBatch_ID)
  else
    mSqlCondition := 'SB.StoreCard_ID = ' + QuotedStr(AStoreCard_ID) + ' and SB.Name = ' + QuotedStr(AStoreBatch_ID);

  mStoreBatchNoteField := '';
  StoreBatchNoteVisibility(AOS, AModule, ADocType, AUser_ID, '', mStoreBatchNoteField);

  if mStoreBatchNoteField = '' then
    mStoreBatchNoteField :=  ''''''
  else
    mStoreBatchNoteField := 'SB.' + mStoreBatchNoteField;
  Result := Result +
     mStoreBatchNoteField + ' as "StoreBatchNote",' + nxCrLf;

  // v pripade upravy sloupcu, upravit i sloupce datasetu v U_StoreCard.get_ParseCode
  Result := 'select' +
    '  SB.ID as "ID",' +  // kvuli navazani polozkoveho datasetu
    '  SB.ID as "StoreBatch_ID",' + NxCrLf +
    '  SB.Name as "StoreBatchName",' + NxCrLf +
    '  SB.ExpirationDate$DATE as "StoreBatchExpirationDate$DATE",' + NxCrLf +
    '  SC.ID as "StoreCard_ID",' + NxCrLf +
    '  SC.' + cStoreCardInfoCodeField + ' as "StoreCardCode",' + NxCrLf +
    '  SC.' + cStoreCardInfoNameField + ' as "StoreCardName",' + NxCrLf +
    '  SC.Category as "StoreCardCategory",' + NxCrLf +
    '  ' + mStoreBatchNoteField + ' as "StoreBatchNote",' + NxCrLf +
    '  (select sum(SSB.Quantity - SSB.BookedQuantity) / SU.UnitRate from StoreSubBatches SSB where SSB.StoreBatch_ID = ' + QuotedStr(AStoreBatch_ID) + ') as "SUM_Available",' +
    '  (select sum(SSB.BookedQuantity) / SU.UnitRate from StoreSubBatches SSB where SSB.StoreBatch_ID = ' + QuotedStr(AStoreBatch_ID) + ') as "SUM_CustomValue", ' +
    '  ''Ve výdeji'' as "SUM_CustomTitle"' + NxCrLf +
    'from StoreBatches SB ' +
    'join StoreCards SC on SC.ID = SB.StoreCard_ID ' +
    'join StoreUnits SU on SU.Parent_ID = SC.ID and SU.Code = SC.MainUnitCode' + nxCrLf +
    'where ' + mSqlCondition;
end;

function getStorePositionInfoSql(AOS: TNxCustomObjectSpace; AStorePosition_ID: String): String;
begin
  Result :=
    'select' + nxCrLf +
    '  LSP.ID as "ID",' + nxCrLf +  // kvuli navazani polozkoveho datasetu
    '  LSP.ID as "StorePosition_ID",' + nxCrLf +
    '  LSP.Code as "StorePositionCode",' + nxCrLf +
    '  LSP.Name as "StorePositionName",' + nxCrLf +
    '  LSP.PositionType as "StorePositionType",' + nxCrLf +
    '  S.ID as "Store_ID",' + nxCrLf +
    '  S.Code as "StoreCode",' + nxCrLf +
    '  S.IsLogistic as "StoreIsLogistic$BOOL",' + nxCrLf +
    '  -1 as "AvailableQuantity",' + nxCrLf +
    '  cast('''' as varchar(40)) as "PreferredStoreBatch_ID",' + nxCrLf +
    '  cast('''' as varchar(40)) as "PreferredStoreBatchName"' + nxCrLf +
    'from LogStorePositions LSP' + nxCrLf +
    'join Stores S on S.ID = LSP.Store_ID' + nxCrLf +
    'where LSP.ID = ' + QuotedStr(AStorePosition_ID);
end;

function getStoreInfoSql(AOS: TNxCustomObjectSpace; AModule, ADocType, AUser_ID, AStore_ID: String): String;
begin
  Result :=
    'select' + nxCrLf +
    '  S.ID as "ID",' + nxCrLf +
    '  S.ID as "Store_ID",' + nxCrLf +
    '  S.Code as "StoreCode",' + nxCrLf +
    '  S.Name as "StoreName",' + nxCrLf +
    '  ' + get_StoreInfo_IsLogistic(AOS, AModule, AUser_ID) + ' as "IsLogistic$BOOL",' + NxCrLf + nxCrLf +
    '  coalesce((select ' + FIRST_TOP(1) + ' LSP.ID from LogStorePositions LSP' + nxCrLf +
    '    where LSP.Store_ID = ' + QuotedStr(AStore_ID) + ' and LSP.X_IsAux = ''A'' order by LSP.Code' + FIRST_TOP_ORACLE(1) + '), '''') as "AuxPosition_ID"' + nxCrLf +
    'from Stores S' + nxCrLf +
    get_StoreInfo_Join(AOS, AModule, AUser_ID) + ' ' + NxCrLf + nxCrLf +
    'where S.ID = ' + QuotedStr(AStore_ID);
end;

function GetStoreCard_ID(AOS: TNxCustomObjectSpace; ABarcode: String; AIsId: Boolean; var OWithStoreUnit: Boolean = False): String;
var
  mResult: String;
  i: Integer;
begin
  mResult := '';
  // pokud mame predane primo ID artiklu, jen overime, ze existuje
  if AIsId then
  begin
    mResult := SQLSelectStr(AOS,
      'select ' + FIRST_TOP(1) + ' SC.ID ' +
      'from StoreCards SC ' +
      'where SC.ID = ' + QuotedStr(ABarcode) +
      ' ' + FIRST_TOP_ORACLE(1));
  end
  // jinak hledame v dalsich udajich podle konfigurace
  else begin
    for i := 1 to Length(cStoreCardInfoSearchIn) do
    begin
      OWithStoreUnit := False;

      // hledame v EAN
      if Copy(cStoreCardInfoSearchIn, i, 1) = 'E' then
      begin
        // vracim ID jednotky namisto artiklu
        mResult := SQLSelectStr(AOS,
          'select' + FIRST_TOP(1) + nxCrLf +
          '  SC.ID' + CONCAT_STR + ''';''' + CONCAT_STR + 'SU.ID' + nxCrLf +
          'from StoreUnits SU' + nxCrLf +
          'join StoreEANs SE on SE.Parent_ID = SU.ID' + nxCrLf +
          'join StoreCards SC on SC.ID = SU.Parent_ID' + nxCrLf +
          'where' + nxCrLf +
          '  SC.Hidden = ''N'' and SE.EAN = ' + QuotedStr(ABarcode) + nxCrLf +
          FIRST_TOP_ORACLE(1));

          OWithStoreUnit := True;
        end;

      // hledame ve vyrobnich prikazech, bereme artikl prvniho produktu
      if Copy(cStoreCardInfoSearchIn, i, 1) = 'V' then
        mResult := SQLSelectStr(AOS,
          'select ' + FIRST_TOP(1) + ' JOP.StoreCard_ID ' +
          'from PRFJobOrders JO ' +
          'join PRFContainerProducts JOP on JOP.Parent_ID = JO.ID ' +
          'where JO.CodeID = ' + QuotedStr(ABarcode) + ' and JOP.DocumentType = ''JP'' ' +
          'order by JOP.PosIndex ' +
          ' ' + FIRST_TOP_ORACLE(1));

      // hledame v kodu artiklu
      if Copy(cStoreCardInfoSearchIn, i, 1) = 'C' then
        mResult := SQLSelectStr(AOS,
          'select ' + FIRST_TOP(1) + ' SC.ID ' +
          'from StoreCards SC ' +
          'where SC.Hidden = ''N'' and SC.Code = ' + QuotedStr(ABarcode) +
          ' ' + FIRST_TOP_ORACLE(1));

      // hledame ve vlastnim hledani
      if Copy(cStoreCardInfoSearchIn, i, 1) = 'X' then
        mResult := SQLSelectStr(AOS,
          StoreCard_CustomSearch(ABarcode, OWithStoreUnit));

      if not CFxOID.IsEmpty(Result) or ((Length(mResult) = 21) and OWithStoreUnit) then
        break;
    end;
  end;

  Result := mResult;
end;

function GetSQLDocHeaderParameters(AOS: TNxCustomObjectSpace; ADocType, AModule, AUser_ID, ADoc_ID: String): String;
begin
  Result :=
    putQueueDocDetailStartPicking_CanAddItems(AOS, AModule, ADocType) + ' as "CanAddItems",' + nxCrLf +
    QuotedStr(NxBoolToString(askForNewDocumentCreation(AModule))) + ' as "AskForNewDocumentCreation",' + nxCrLf +
    QuotedStr(NxBoolToString(putQueueDocDetailStartPicking_isEditingProcessedItemAllowed(AOS, AModule))) + ' as "IsEditingProcessedItemAllowed",' + nxCrLf +
    putQueueDocDetailStartPicking_createTransferIn(AOS, AModule, ADocType, AUser_ID) + ' as "CreateTransferIn$BOOL",' + nxCrLf +
    QuotedStr(putQueueDocDetailStartPicking_defaultPosition()) + ' as "DefaultPosition",' + nxCrLf +
    QuotedStr(NxBoolToString(putQueueDocDetailStartPicking_showBarecodeField(AModule))) + ' as "ShowBarecodeField",' + nxCrLf +
    QuotedStr(NxBoolToString(showSerNumberSelection(AOS, AModule))) +  ' as "ShowSerNumberSelection",' + nxCrLf +
    QuotedStr(NxBoolToString(putQueueDocDetailStartPicking_openSerNumberScreenAutomatically(AOS, AModule, AUser_ID))) +  ' as "AutoopenSerNumberScreen",' + nxCrLf +
    putQueueDocDetailStartPicking_headerAuxFields(AOS, AModule, ADocType, AUser_ID) + nxCrLf +
    QuotedStr(NxBoolToString(EnterPerson(AOS, AModule, ADocType, AUser_ID, ''))) +  ' as "EnterPerson",' + nxCrLf +
    QuotedStr(NxBoolToString(EnterDocQueue(AOS, AModule, ADocType, AUser_ID))) +  ' as "EnterDocQueue",' + nxCrLf +
    QuotedStr(NxBoolToString(EnterFirmOffice(AOS, AModule, ADocType, AUser_ID))) +  ' as "EnterFirmOffice",' + nxCrLf +
    QuotedStr(NxBoolToString(EnterBusOrder(AOS, AModule, ADocType, AUser_ID))) +  ' as "EnterBusOrder",' + nxCrLf +
    QuotedStr(NxBoolToString(EnterDivision(AOS, AModule, ADocType, AUser_ID))) +  ' as "EnterDivision",' + nxCrLf +
    QuotedStr(NxBoolToString(EnterTransportationType(AOS, AModule, ADocType, AUser_ID))) +  ' as "EnterTransportationType",' + nxCrLf +
    IntToStr(newRowDefaultValue(AOS, AModule, AUser_ID)) + ' as "NewRowDefaultValue",' + nxCrLf +
    QuotedStr(NxBoolToString(CanEditRowUnit(AOS, AModule, ADocType, AUser_ID))) + ' as "CanEditRowUnit",' + nxCrLf +
    QuotedStr(NxBoolToString(CanCreateNewSerialNumbers(AOS, AModule, ADocType, AUser_ID, ADoc_ID))) + ' as "CanCreateNewSerialNumbers",' + nxCrLf +
    IntToStr(IsStoreBatchEnteringRequired(AOS, AModule, ADocType, AUser_ID)) + ' as "IsStoreBatchEnteringRequired",' + nxCrLf +
    QuotedStr(NxBoolToString(IsAvailableQuantityCheckActive(AOS, AModule, ADocType, AUser_ID))) + ' as "IsAvailableQuantityCheckActive",' + nxCrLf +
    IntToStr(KeepSelectedPosition(AOS, AModule, ADocType, AUser_ID)) + ' as "KeepSelectedPosition",' + nxCrLf +
    IntToStr(showPrintRowButton(AOS, AModule, ADocType, AUser_ID)) + ' as "ShowPrintRowButton",' + nxCrLf +
    CanTakePhotos(AOS, AModule, ADocType, AUser_ID) + ' as "CanTakePhotos$BOOL"' + nxCrLf;
end;

// pokud je AOnlySimple = True, vrati pouze ID dokladu s uzivatelskymi joiny a omezenimi, jinak vraci kompletni informace ke fronte
function GetListDocQueueSql(AOS: TNxCustomObjectSpace; AModule, ADocType, AUser_Id, ASearchStr: String; AOnlySimple: Boolean = False): String;
var
  mTable, mColumns, mJoins: String;
begin
  mTable := GetTable(ADocType);

  // sloupce, ktere se budou nacitat do seznamu - v jedne promenne, abych je mohl pridat do vsech pripadnych casti dotazu
  mColumns :=
    '   DQ.Code' + CONCAT_STR + QuotedStr('-') + CONCAT_STR + 'cast(SD.OrdNumber as varchar(6))' +
      CONCAT_STR + QuotedStr('/') + CONCAT_STR + 'P.Code as "DisplayName",' + nxCrLf +
    '   SD.DocDate$DATE as "DocDate$DATE",' +  nxCrLf;

  if ADocType in [DOC_ShippingList, DOC_RemovalList] then
    mColumns := mColumns + '   (select count(SD2.ID) from ' + mTable + '2 SD2 where SD2.Parent_ID = SD.ID) as "ItemCount",' + nxCrLf
  else if ADocType = DOC_JOBORDER then
    mColumns := mColumns + '   0 as "ItemCount",' + nxCrLf
  else if ADocType = DOC_IssuedOrder then
    mColumns := mColumns + '   (select count(SD2.ID) from IssuedOrders2 SD2 where SD2.Parent_ID = SD.ID and SD2.RowType = 3) as "ItemCount",' + nxCrLf
  else if  ADocType = DOC_LogStoreTransfer then
    mColumns := mColumns + '   (select count(SD2.ID) from LogStoreDocuments2 SD2 where SD2.Parent_ID = SD.ID and SD2.MasterRow_ID is not null) as "ItemCount",' + nxCrLf
  else
    mColumns := mColumns + '   (select count(SD2.ID) from StoreDocuments2 SD2 where SD2.Parent_ID = SD.ID and SD2.RowType = 3) as "ItemCount",' + nxCrLf;

  mColumns := mColumns +
    '   ' + listDocQueue_Field_Description(AOS, AModule, ADocType, AUser_Id) + ' as "Description",' + nxCrLf +
    '   ' + listDocQueue_Field_FirmName(AOS) + ' as "FirmName",' + NxCrLf +
    '   ' + listDocQueue_customRowColor(AOS, AModule, AUser_Id) + ' as "CustomColor",' + nxCrLf +
    '   ' + listDocQueue_AuxNonVisibleFields(AOS, AModule) + nxCrLf;

  // joiny, ktere budu pridavat k dotazum
  mJoins :=
    ' join Firms F on F.ID = SD.Firm_ID' + NxCrLf +
    ' join DocQueues DQ on DQ.ID = SD.DocQueue_ID' + NxCrLf +
    ' join Periods P on P.ID = SD.Period_ID' + NxCrLf +
    ' ' + listDocQueue_Join(AOS, AModule, ADocType, AUser_ID) + nxCrLf;

  // prvni cast, nacteni dokladu primo z tabulky podle stavu K vyskladneni
  Result := Result +
    ' select' + nxCrLf +
    '   SD.ID as "ID"' + nxCrLf;

  if not AOnlySimple then
  begin
    Result := Result +
      ',   ''N'' as "InProgress$BOOL",' + nxCrLf  +
      mColumns +
  end;

  Result := Result +
    ' from ' + mTable + ' SD' + NxCrLf +
    mJoins;

  // presuny mezi pozicemi nemaji stav Vyskladnovano, takze musim kouknout do tabulky rozpracovanosti a rozpracovane doklady vynechat
  // (nactou se v druhe casti)
  if ADocType in [DOC_LogStoreTransfer] then
    Result := Result +
      ' left join ' + REST_TABLE_TemporaryStorage + ' RTS on RTS.Document_ID = SD.ID and RTS.DataType = ' +
        QuotedStr(AModule) + ' and RTS.Status = ' + IntToStr(TempStorageStatus_OPEN) + nxCrLf;

  Result := Result +
    ' where' + nxCrLf;

  // presuny mezi pozicemi nemaji stav, ale provedeno/neprovedeno
  if ADocType in [DOC_LogStoreTransfer] then
    Result := Result +
     '   SD.Executed = ''N''' + NxCrLf +
     '   and RTS.ID is null' + NxCrLf
  else
    Result := Result +
     '   SD.' + GetStatusField + ' in (''' +  replacestr(STAV_K_VYSKLADNENI(ADocType, AModule), ',', ''',''') + ''')';

  // typ dokladu kontroluji pouze pro sklad. doklady
  if not (ADocType in [DOC_ShippingList, DOC_RemovalList, DOC_IssuedOrder]) then
  begin
    // pokud se maji pouzivat vydejky pri vraceni, tak volam jiny typ dokladu
    if (ADocType = DOC_RefundedBillOfDelivery) and useBillOfDeliveryForRefunding then
      Result := Result + '   and SD.DocumentType = ' + QuotedStr(DOC_BillOfDelivery) + nxCrLf
    else
      Result := Result + '   and SD.DocumentType = ' + QuotedStr(ADocType) + nxCrLf;
  end;

  // hledani
  Result := Result + listDocQueue_Search(AOS, ADocType, ASearchStr, AModule, AUser_Id);

  // druha cast, pokud je dovoleno doklady ponechavat rozpracovane, tak udelam UNION vychazejici z tabulky rozpracovanosti
  if NoncancelableWork then
  begin
    Result := Result + nxCrLf + nxCrLf +
      ' union all' + nxCrLf + nxCrLf +
      ' select' + nxCrLf +
      '   SD.ID as "ID"' + nxCrLf;

    if not AOnlySimple then
    begin
      Result := Result +
        ',   ''A'' as "InProgress$BOOL",' + nxCrLf +
        mColumns;
    end;

    Result := Result +
      ' from ' + REST_TABLE_TemporaryStorage + ' RTS' + NxCrLf +
      ' join ' + mTable + ' SD on SD.ID = RTS.Document_ID' + NxCrLf +
      mJoins +
      ' where' + nxCrLf +
      '   RTS.DataType = ' + QuotedStr(AModule) + nxCrLf +
      '   and ((RTS.Status = ' + IntToStr(TempStorageStatus_OPEN) + nxCrLf +
      '       and RTS.User_ID = ' + QuotedStr(AUser_ID) + ')' + nxCrLf +
      '     or (RTS.Status = ' + IntToStr(TempStorageStatus_PAUSED);

    if NoncancelableWorkOnlyOneUser then
      Result := Result + nxCrLf +
        '     and RTS.User_ID = ' + QuotedStr(AUser_ID) + '))' + nxCrLf
    else
      Result := Result +
        '))' + nxCrLf;

    // hledani
    Result := Result + listDocQueue_Search(AOS, ADocType, ASearchStr, AModule, AUser_Id);
  end;

  Result := 'select * from (' + nxCrLf + Result + nxCrLf + ') q ';

  if not AOnlySimple then
    Result := Result + listDocQueue_OrderBy(AOS, AModule);
end;

// pokud je AOnlySimple = True, vrati pouze ID dokladu s uzivatelskymi joiny a omezenimi, jinak vraci kompletni informace ke fronte
function GetListWithoutDocQueueSql(AOS: TNxCustomObjectSpace; AModule, ADocType, AUser_Id, ASearchStr: String; AOnlySimple: Boolean = False): String;
begin
  Result := Result +
    'select' + nxCrLf +
    '  cast(SD.ID as varchar(10)) as "ID",' + nxCrLf;

  if not AOnlySimple then
  begin
    Result := Result +
      '  ''-'' as "DisplayName",' + nxCrLf +
      '  SD.Date$DATE as "DocDate$DATE",' +  nxCrLf +
      '  0 as "ItemCount",' + nxCrLf +
      '  '''' as "Description",' + nxCrLf +
      '  cast(''-'' as char(200)) as "FirmName",' + NxCrLf +
      '  cast(''-'' as char(200)) as "AuxText",' + NxCrLf +
      '  ''''  as "CustomColor",' + nxCrLf +
      '  ''A'' as "InProgress$BOOL",' + nxCrLf +
      // zkusim si nacist i data, abych z nich mohl pripadne zobrazit nejake informace
      '  Data as "Data"' + nxCrLf;
  end;

  Result := Result +
    'from ' + REST_TABLE_TemporaryStorage + ' SD' + NxCrLf;
    //' join Firms F on F.ID = SD.Firm_ID' + NxCrLf +
    //' join DocQueues DQ on DQ.ID = SD.DocQueue_ID' + NxCrLf +
    //' join Periods P on P.ID = SD.Period_ID' + NxCrLf;

  Result := Result +
    'where' + nxCrLf +
    '  SD.Status = 0' + nxCrLf +
    '  and SD.User_ID = ' + QuotedStr(AUser_Id) + nxCrLf +
    '  and SD.DataType = ' + QuotedStr(AModule);

  // hledani
  //Result := Result + listDocQueue_Search(AOS, ADocType, ASearchStr, AModule, AUser_Id);

  Result := 'select * from ( ' + Result + ') q ';

  if not AOnlySimple then
    Result := Result + ' order by "DocDate$DATE"';
end;

function GetListPartialInvProtocolsSql(AOS: TNxCustomObjectSpace; AModule, ADocType, AUser_Id, ASearchStr: String; AOnlySimple: Boolean = False): String;
begin
  Result :=
    'select' + nxCrLf +
    '  PIP.ID as "ID"' + nxCrLf;
  if not AOnlySimple then
  begin
    Result := Result +
    '  ,DQ.Code' + CONCAT_STR + QuotedStr('-') + CONCAT_STR + 'cast(PIP.OrdNumber as varchar(6))' + nxCrLf +
      CONCAT_STR + QuotedStr('/') + CONCAT_STR + 'P.Code as "DisplayName",' + nxCrLf +
    '  PIP.DocDate$DATE "DocDate$DATE",' + nxCrLf +
    '  (select count(PIR.ID) from PartialInvProtocolRows PIR' + nxCrLf +
    '    left join PartialInvProtocolBatches PIB on PIR.id = PIB.Parent_ID' + nxCrLf +
    '    where PIR.Parent_ID = PIP.id) "ItemCount",' + nxCrLf +
    '  PIP.Description as "Description",' + nxCrLf +
    '  S.Code "FirmName",' + nxCrLf;

    if NoncancelableWork then
      Result := Result +
        '  case' + NxCrLf +
        '    when PIP.User_ID = ' + QuotedStr(AUser_Id) + ' and ReaderID = '''' and RTS.ID is not null' + nxCrLf +
        '    then ''A''' + nxCrLf +
        '    else ''N''' + nxCrLf +
        '  end as "InProgress$BOOL"' + nxCrLf
    else
      Result := Result + '''N'' "InProgress$BOOL"' + nxCrLf;
  end;

  Result := Result +
    'from PartialInvProtocols PIP' + nxCrLf +
    'join MainInvProtocols MIP on PIP.MainProtocol_ID = MIP.id' + nxCrLf +
    'join Stores S on S.ID = MIP.Store_ID' + nxCrLf +
    'join DocQueues DQ on DQ.ID = PIP.DocQueue_ID' + nxCrLf +
    'join Periods P on P.ID = PIP.Period_ID' + nxCrLf;
    // abych mel uzivatele (kvuli ABRA) a abych zkontroloval, ze opravdu existuje zaznam o rozpracovanosti
  if NoncancelableWork then
    Result := Result + 'left join REST_TemporaryStorage RTS on RTS.Document_ID = PIP.ID and RTS.Status = ' + IntToStr(TempStorageStatus_OPEN) + nxCrLf;

  Result := Result +
    'where ' +
    '  (PIP.User_ID is null ' + nxCrLf +
    '    or (PIP.User_ID = ' + QuotedStr(AUser_Id) + ' and ReaderID = ''''))' + nxCrLf +
    '  and PIP.Closed = ''N''' + nxCrLf +
    '  and MIP.StartedAt$DATE > 0' + nxCrLf +
    '  and MIP.Closed = ''N''';
  // pripadne hledani
  if trim(ASearchStr) <> '' then
  begin
    Result := Result +
      ' and ((PIP.Description' + COLLATION_AI + 'like ''%' + ASearchStr + '%'' ) ' +
      ' or ((DQ.Code' + CONCAT_STR + QuotedStr('-') + CONCAT_STR + 'cast(PIP.OrdNumber as varchar(6))' +
      CONCAT_STR + QuotedStr('/') + CONCAT_STR + 'P.Code)' + COLLATION_AI + 'like ''%' + ASearchStr + '%'' )) ';
  end;

  if not AOnlySimple then
    Result := Result + ' order by PIP.DocDate$DATE ';
end;

function GetListMainInvProtocolsSql(AOS: TNxCustomObjectSpace; AModule, ADocType, AUser_Id, ASearchStr: String; AOnlySimple: Boolean = False): String;
begin
  Result :=
    'select' + nxCrLf +
    '  MIP.ID as "ID"' + nxCrLf;

  if not AOnlySimple then
  begin
    Result := Result +
      '  ,DQ.Code' + CONCAT_STR + QuotedStr('-') + CONCAT_STR + 'cast(MIP.OrdNumber as varchar(6))' + nxCrLf +
        CONCAT_STR + QuotedStr('/') + CONCAT_STR + 'P.Code as "DisplayName", ' + nxCrLf +
      '  MIP.DocDate$DATE "DocDate$DATE",' + nxCrLf +
      '  MIP.Description as "Description",' + nxCrLf +
      '  S.Code "FirmName",' + nxCrLf +
      '  S.id "StoreId"' + nxCrLf;
  end;

  Result := Result +
    'from MainInvProtocols MIP' + nxCrLf +
    'join Stores S on S.ID = MIP.Store_ID' + nxCrLf +
    'join DocQueues DQ on DQ.ID = MIP.DocQueue_ID' + nxCrLf +
    'join Periods P on P.ID = MIP.Period_ID' + nxCrLf +
    'where' + nxCrLf +
    '  MIP.Closed = ''N''' + nxCrLf +
    '  and MIP.StartedAt$DATE > 0';

  // pripadne hledani
  if trim(ASearchStr) <> '' then
  begin
    Result := Result + ' and ((MIP.Description' + COLLATION_AI + 'like ''%' + ASearchStr + '%'' ) ' +
      ' or ((DQ.Code' + CONCAT_STR + QuotedStr('-') + CONCAT_STR + 'cast(MIP.OrdNumber as varchar(6))' +
      CONCAT_STR + QuotedStr('/') + CONCAT_STR + 'P.Code)' + COLLATION_AI + 'like ''%' + ASearchStr + '%'' )) ';
  end;

  if not AOnlySimple then
    Result := Result + ' order by MIP.StartedAt$DATE ';
end;

begin
end.