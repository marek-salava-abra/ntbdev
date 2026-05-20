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

    if ADocType in [DOC_ReceiptCard, DOC_BillOfDelivery, DOC_OutgoingTransfer, DOC_RefundedBillOfDelivery, DOC_IncomingTransfer, DOC_ReceivedOrder,
        DOC_RefundedReceiptCard] then
      Result := Result +
        '  TT.ID as "TransportationType_ID",' +  NxCrLf +
        '  TT.Code as "TransportationTypeCode",' +  NxCrLf;
    if AAuxField <> '' then
    begin
      Result := Result +
        '  SD.' + AAuxField + ' as "AuxText",' + NxCrLf +
        '  ' + QuotedStr(NxBoolToStr(AAuxReadOnly)) + ' as "AuxReadOnly$BOOL",' + NxCrLf +;
    end;
    if AChangeableFields <> '' then
    begin
      Result := Result +
        AChangeableFields + ' as "ChangeableFields",' + NxCrLf +;
    end;
    Result := Result +
      GetSQLDocHeaderParameters(AOS, ADocType, AModule, AUser_ID, ADoc_ID) + NxCrLf +
      'from ' + mTable + ' SD' + nxCrLf +
      'left join Firms F on F.ID = SD.Firm_ID' + nxCrLf +
      'join DocQueues DQ on DQ.ID = SD.DocQueue_ID' + nxCrLf +
      'join Periods P on P.ID = SD.Period_ID' + nxCrLf +
      putQueueDocDetailStartPicking_HeaderJoin(AOS, AModule, ADocType, AUser_ID) + NxCrLf;
      if ADocType in [DOC_ReceiptCard, DOC_BillOfDelivery, DOC_OutgoingTransfer, DOC_RefundedBillOfDelivery, DOC_IncomingTransfer, DOC_RECEIVEDORDER,
          DOC_RefundedReceiptCard] then
        Result := Result +
          'left join TransportationTypes TT on TT.ID = SD.TransportationType_ID' + nxCrLf;
      Result := Result +
        'where SD.ID = ' + QuotedStr(ADoc_ID);

    mGroupBy := putQueueDocDetailStartPicking_HeaderGroupBy(AOS, Amodule, AUser_ID);
    if mGroupBy <> '' then
      Result := Result + nxCrLf + 'group by' + nxCrLf + mGroupBy;
  end;
end;

function getRowsSql(AOS: TNxCustomObjectSpace; AModule, AUser_ID, ADocType: String; var AWhere: String): String;
var
  mTable, mSql, mCustomerSql: String;
  mStoreCardBehavior, mStoreBatchBehavior, mStorePositionBehavior, mStorePositionToBehavior, mStoreBatchNoteVisibility, mStoreBatchNoteField,
    mStoreBatchExpirationField: String;
  mExpirationEnterType: Integer;
  mStoreBatchNoteReadOnly, mAuxTextRowList, mAuxTextRowDetail, mAuxTextStoreCardInfo: Boolean;
begin
  mTable := GetTable(ADocType);
  if ADocType in [DOC_ShippingList, DOC_RemovalList] then
    mSql :=
      'select' + nxCrLf +
      '  A2.Parent_ID as "XX_Parent_ID",' + nxCrLf +
      '  A2.PosIndex as "PosIndex",' + nxCrLf +
      '  A2.ID as "ID",' + nxCrLf
  else
    mSql :=
      'select' + nxCrLf +
      '  SD2.Parent_ID as "XX_Parent_ID",' + nxCrLf +
      '  SD2.PosIndex as "PosIndex",' + nxCrLf +
      '  SD2.ID as "ID",' + nxCrLf;

  mSql := mSql +
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
    '  LSP.Code as "StorePositionFromCode",' + nxCrLf +
    '  coalesce(SB.ID, '''') as "StoreBatch_ID",' + nxCrLf +
    '  ' + putQueueDocDetailStartPicking_StoreBatchField(AOS, AModule, ADocType) + ' as "StoreBatchName",' + nxCrLf +
    '  ' + canAddNewBatch(AOS, AModule) + ' as "CanAddNewBatch",' + nxCrLf +
    '  ' + enabledCustomFields(AOS, AUser_Id, AModule) + ' as "EnabledFields",' + nxCrLf +
//      '  ' + customFields(AOS, AUser_Id, AModule) + ' "customFields", ' + nxCrLf +
    '  ' + DisableQuantityEdit(AOS, AModule) + ' as "DisableQuantityEdit",' + nxCrLf +
    '  ' + rowAuxText2(AOS, AModule, ADocType, AUser_ID) + ' as "AuxText2",' + nxCrLf +
    '  ' + putQueueDocDetailStartPicking_customRowColor(AOS, AModule, AUser_Id) + ' as "CustomColor",' + nxCrLf +
    '  ' + putQueueDocDetailStartPicking_CanEnterBiggerQuantity(AOS, AModule, ADocType, AUser_ID) + ' as "CanEnterBiggerQuantity$BOOL",' + nxCrLf +
    '  ' + ShowOtherUnitsUnitRate(AOS, AModule, ADocType, AUser_ID) + ' as "ShowOtherUnitsUnitRate$BOOL",' + nxCrLf +
    '  ' + EnableZeroQuantity(AOS, AModule, ADocType, AUser_ID) + ' as "EnableZeroQuantity$BOOL",' + nxCrLf +
    '  ' + putQueueDocDetailStartPicking_rowsAuxFields(AOS, AModule, ADocType, AUser_ID) + nxCrLf;

  if ADocType = DOC_IssuedOrder then
    mSql := mSql +
      '  ' + QuotedStr(DOC_IssuedOrder) + ' as "StoreDocumentType",' + nxCrLf
  else
    mSql := mSql +
      '  SD.DocumentType as "StoreDocumentType",' + nxCrLf;

  mAuxTextRowList := False;
  mAuxTextRowDetail := False;
  mAuxTextStoreCardInfo := False;
  mSql := mSql +
    '  ' + StoreCardAuxText(AOS, AModule, ADocType, AUser_ID, 'getRowsSql',
      mAuxTextRowList, mAuxTextRowDetail, mAuxTextStoreCardInfo) + ' as "StoreCardAuxText",' + nxCrLf +
    '  ' + QuotedStr(NxBoolToStr(mAuxTextRowList)) + ' as "AuxTextInRowList$BOOL",' + nxCrLf +
    '  ' + QuotedStr(NxBoolToStr(mAuxTextRowDetail)) + ' as "AuxTextInRowDetail$BOOL",' + nxCrLf +
    '  ' + QuotedStr(NxBoolToStr(mAuxTextStoreCardInfo)) + ' as "AuxTextInSCInfo$BOOL",' + nxCrLf;

  // zadavani data expirace
  mExpirationEnterType := 0;
  mStoreBatchExpirationField := 'ExpirationDate$DATE';
  mSql := mSql +
    '  ' + EnterStoreBatchExpirationDate(AOS, AModule, ADocType, AUser_ID, mExpirationEnterType, mStoreBatchExpirationField) + ' as "EnterBatchExpirationDate",' + nxCrLf +
    '  ' + QuotedStr(IntToStr(mExpirationEnterType)) + ' as "StoreBatchExpDateEnterType",' + nxCrLf +
    '  coalesce(SB.' + mStoreBatchExpirationField + ', 0) as "StoreBatchExpirationDate$DATE",' + nxCrLf;

  // musí být jako string, protože GSON v Android parsuje Enum ze stringu
  mStoreBatchNoteVisibility := '0';
  mStoreBatchNoteField := '';
  StoreBatchNoteVisibility(AOS, AModule, ADocType, AUser_ID, mStoreBatchNoteVisibility, mStoreBatchNoteField);
  mSql := mSql +
    '  cast(' + mStoreBatchNoteVisibility + ' as varchar(1)) as "StoreBatchNoteVisibility",' + nxCrLf;
  if mStoreBatchNoteField = '' then
    mSql := mSql +
      '  '''''
  else
    mSql := mSql +
      '  SB.' + mStoreBatchNoteField;
  mSql := mSql +
     ' as "StoreBatchNote",' + nxCrLf;

  // chovani poli (zmena, validace)
  mStoreCardBehavior := '0';
  mStoreBatchBehavior := '0';
  mStorePositionBehavior := '0';
  mStorePositionToBehavior := '0';
  EnteredFieldsBehavior(AOS, AModule, ADocType, AUser_ID, mStoreCardBehavior, mStoreBatchBehavior, mStorePositionBehavior, mStorePositionToBehavior);
  mSql := mSql +
    '  cast(' + mStoreCardBehavior + ' as int) as "StoreCardBehavior",' + nxCrLf +
    '  cast(' + mStoreBatchBehavior + ' as int) as "StoreBatchBehavior",' + nxCrLf +
    '  cast(' + mStorePositionBehavior + ' as int) as "StorePositionBehavior",' + nxCrLf +
    '  cast(' + mStorePositionToBehavior + ' as int) as "StorePositionToBehavior",' + nxCrLf;

  // u vratek chci jina pole
  if ADocType = DOC_RefundedBillOfDelivery then
    mSql := mSql +
      '  coalesce(SD.RDocument_ID, '''') as "StoreDocument2Provide_ID",' + nxCrLf +
      '  coalesce(SD2.RDocumentRow_ID, '''') as "StoreDocument2ProvideRow_ID",' + nxCrLf
  else if ADocType = DOC_RefundedReceiptCard then
    mSql := mSql +
      '  (select max(Parent_ID) from StoreDocuments2 where ID = SD2.RDocumentRow_ID) as "StoreDocument2Provide_ID",' + nxCrLf +
      '  coalesce(SD2.RDocumentRow_ID, '''') as "StoreDocument2ProvideRow_ID",' + nxCrLf
  else if ADocType = DOC_LogStoreTransfer then
    mSql := mSql +
      '  coalesce(SD.StoreDocument_ID, '''') as "StoreDocument2Provide_ID",' + nxCrLf +
      '  coalesce(SD2.StoreDocRow_ID, '''') as "StoreDocument2ProvideRow_ID",' + nxCrLf
  else if ADocType = DOC_IssuedOrder then
    mSql := mSql +
      '  SD.ID as "StoreDocument2Provide_ID",' + nxCrLf +
      '  SD2.ID as "StoreDocument2ProvideRow_ID",' + nxCrLf
  else
    mSql := mSql +
      '  coalesce(SD2.Provide_ID, '''') as "StoreDocument2Provide_ID",' + nxCrLf +
      '  coalesce(SD2.ProvideRow_ID, '''') as "StoreDocument2ProvideRow_ID",' + nxCrLf;

  if (AModule = 'STD_RefundedBillOfDeliveryQueue') and useBillOfDeliveryForRefunding then
    mSql := mSql +
      '  coalesce(RS.ID, S.ID) as "StoreFrom_ID",' + nxCrLf +
      '  coalesce(RS.Code, S.Code) as "StoreFromCode",' + nxCrLf +
      '  coalesce(RS.IsLogistic, S.IsLogistic) as "StoreFromIsLogistic$BOOL",' + nxCrLf
  else
    mSql := mSql +
      '  S.ID as "StoreFrom_ID",' + nxCrLf +
      '  S.Code as "StoreFromCode",' + nxCrLf +
      '  S.IsLogistic as "StoreFromIsLogistic$BOOL",' + nxCrLf;

  // pro presuny mezi pozicemi nejsou zadna strediska apod, ani vyroba
  if ADocType = DOC_LogStoreTransfer then
  begin
    mSql := mSql +
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
      '  SD2.QUnit as "UnitCode",' + nxCrLf +
      '  coalesce(SD2.ContentUnit, SD2.QUnit) as "ContentUnit",' + nxCrLf;

    if useMainUnits(AOS, AModule, ADocType, AUser_Id) then
      mSql := mSql +
        '  SD2.Quantity as "UnitQuantity",' + nxCrLf +
        '  SD2.Quantity as "UnitQuantityOrig"' + nxCrLf
    else
      mSql := mSql +
        '  SD2.Quantity / SD2.UnitRate as "UnitQuantity",' + nxCrLf +
        '  SD2.Quantity / SD2.UnitRate as "UnitQuantityOrig"' + nxCrLf;
  end
  else
  begin
    mSql := mSql +
      '  SD2.Division_ID as "Division_ID",' + nxCrLf +
      '  SD2.BusProject_ID as "BusProject_ID",' + nxCrLf +
      '  SD2.BusOrder_ID as "BusOrder_ID",' + nxCrLf +
      '  SD2.BusTransaction_ID as "BusTransaction_ID",' + nxCrLf +
      '  '''' as "StorePositionTo_ID",' + nxCrLf +
      '  '''' as "StorePositionToCode",' + nxCrLf +
      '  coalesce(DRB.ID, '''') as "DocRowBatch_ID",' + nxCrLf +
      '  coalesce(LSD2.ID, '''') as "LogStoreDocument2_ID",' + nxCrLf +
      '  coalesce(LSD2.ContentUnit, SD2.QUnit) as "ContentUnit",' + nxCrLf;

    if useMainUnits(AOS, AModule, ADocType, AUser_Id) then
    begin
      if ADocType = DOC_IssuedOrder then
        mSql := mSql +
          '  SD2.Quantity - SD2.DeliveredQuantity as "UnitQuantity",' + nxCrLf +
          '  SD2.Quantity - SD2.DeliveredQuantity as "UnitQuantityOrig",' + nxCrLf
      else
        mSql := mSql +
          '  coalesce(LSD2.Quantity, DRB.Quantity, SD2.Quantity) as "UnitQuantity",' + nxCrLf +
          '  coalesce(LSD2.Quantity, DRB.Quantity, SD2.Quantity) as "UnitQuantityOrig",' + nxCrLf;
      mSql := mSql +
        '  coalesce(LSD2.UnitRate, SD2.UnitRate) as "UnitRate",' + nxCrLf +
        '  coalesce(LSD2.QUnit, SD2.QUnit) as "UnitCode",' + nxCrLf;
    end
    else
    begin
      if ADocType = DOC_IssuedOrder then
        mSql := mSql +
          '  (SD2.Quantity - SD2.DeliveredQuantity) / SD2.UnitRate as "UnitQuantity",' + nxCrLf +
          '  (SD2.Quantity - SD2.DeliveredQuantity) / SD2.UnitRate as "UnitQuantityOrig",' + nxCrLf
      else
        mSql := mSql +
          '  coalesce(LSD2.Quantity, DRB.Quantity, SD2.Quantity) / SD2.UnitRate as "UnitQuantity",' + nxCrLf +
          '  coalesce(LSD2.Quantity, DRB.Quantity, SD2.Quantity) / SD2.UnitRate as "UnitQuantityOrig",' + nxCrLf;
      mSql := mSql +
        '  SD2.UnitRate as "UnitRate",' + nxCrLf +
        '  SD2.QUnit as "UnitCode",' + nxCrLf;
    end;

    if ADocType = DOC_IssuedOrder then
      mSql := mSql +
        '  '''' as "AccJobOrder_ID",' + nxCrLf +
        '  '''' as "PRFContainerMater_ID",' + nxCrLf +
        '  '''' as "StoreTo_ID",' + nxCrLf +
        '  '''' as "StoreToCode",' + nxCrLf +
        '  ''N'' as "StoreToIsLogistic$BOOL"' + nxCrLf
    else if ABRA then
      mSql := mSql +
        // jina vyroba
        '  coalesce(JO.ID, '''') as "AccJobOrder_ID",' + nxCrLf +
        '  coalesce(MAT.Parent_ID, '''') as "PRFContainerMater_ID",' + nxCrLf +
        '  coalesce(S2.ID, '''') as "StoreTo_ID",' + nxCrLf +
        '  S2.Code as "StoreToCode",' + nxCrLf +
        '  coalesce(S2.IsLogistic, ''N'') as "StoreToIsLogistic$BOOL"' + nxCrLf
    else
      mSql := mSql +
        '  coalesce(SD2.AccJobOrder_ID, '''') as "AccJobOrder_ID",' + nxCrLf +
        '  coalesce(SD2.PRFContainerMater_ID, '''') as "PRFContainerMater_ID",' + nxCrLf +
        '  coalesce(S2.ID, S3.ID, '''') as "StoreTo_ID",' + nxCrLf +
        '  coalesce(S2.Code, S3.Code, null) as "StoreToCode",' + nxCrLf +
        '  coalesce(S2.IsLogistic, S3.IsLogistic, ''N'') as "StoreToIsLogistic$BOOL"' + nxCrLf;
  end;

  if ADocType in [DOC_ShippingList, DOC_RemovalList] then
    mSql := mSql +
      'from ' + mTable + '2 A2' + nxCrLf +
      'join StoreDocuments2 SD2 on SD2.ID = A2.ProvideRow_ID' + nxCrLf +
      'join StoreDocuments SD on SD.id = SD2.Parent_ID' + nxCrLf
  else
    mSql := mSql +
      'from ' + mTable + '2 SD2' + nxCrLf +
      'join ' + mTable + ' SD on SD.id = SD2.Parent_ID' + nxCrLf;

  mSql := mSql +
    'join Stores S on S.ID = SD2.Store_ID' + nxCrLf +
    'left join Stores RS on RS.ID = S.RefundStore_ID' + nxCrLf;

  if ADocType = DOC_LogStoreTransfer then
  begin
    mSql := mSql +
      'join LogStoreDocuments2 LSD3 on LSD3.ID = SD2.MasterRow_ID' + nxCrLf +
      'join LogStorePositions LSP2 on LSP2.ID = LSD3.StorePosition_ID'  + nxCrLf +
      'left join StoreBatches SB on SB.ID = SD2.StoreBatch_ID' + nxCrLf;
  end
  else
  begin
    if ADocType <> DOC_IssuedOrder then
    begin
      if ABRA then
        mSql := mSql +
          // vyroba z ABRA (prvni je na ziskani radku kusovniku, druhy ID vyr. prikazu
          'left join PLMMIPLMaterialDistrib MAT on MAT.StoreDocument2_ID = SD2.ID' + NxCrLf +
          'left join PLMJobOrders JO on JO.ProductionTask_ID = SD2.ProductionTask_ID' + NxCrLf
        else
          mSql := mSql +
            'left join Stores S3 on S3.ID = SD.PlannedReverseDocumentStore_ID' + nxCrLf;

      mSql := mSql +
        'left join DocRowBatches DRB on DRB.Parent_ID = SD2.ID' + nxCrLf +
        'left join StoreBatches SB on SB.ID = DRB.StoreBatch_ID' + nxCrLf +
        // join na radky abych mohl vzit sklad z PRP
        'left join StoreDocuments2 SD2_PRP on SD2_PRP.ProvideRow_ID = SD2.ID and SD2_PRP.FlowType = ' + QuotedStr(DOC_IncomingTransfer) + nxCrLf +
        'left join Stores S2 on S2.ID = SD2_PRP.Store_ID' + nxCrLf;
    end
    else
      mSql := mSql +
        'left join DocRowBatches DRB on DRB.Parent_ID = ''0000000000''' + nxCrLf +
        'left join StoreBatches SB on SB.ID = DRB.StoreBatch_ID' + nxCrLf;
  end;

  mSql := mSql +
    'join StoreCards SC on SC.ID = SD2.StoreCard_ID' + nxCrLf;

  if (ADocType = DOC_RefundedBillOfDelivery) and useBillOfDeliveryForRefunding then
    mSql := mSql +
      'left join LogStoreDocuments2 LSD2 on ''0000000000'' = SD2.ID' + nxCrLf +
      'left join LogStorePositions LSP on ''0000000000'' =  LSD2.ID' + nxCrLf
  else if ADocType = DOC_LogStoreTransfer then
    mSql := mSql +
      'left join LogStorePositions LSP on LSP.ID = SD2.StorePosition_ID' + nxCrLf
  else if ADocType = DOC_IssuedOrder then
    mSql := mSql +
      'left join LogStoreDocuments2 LSD2 on LSD2.StoreDocRow_ID = ''0000000000''' + nxCrLf +
      'left join LogStorePositions LSP on LSP.ID =  ''0000000000''' + nxCrLf
  else
    mSql := mSql +
      'left join LogStoreDocuments2 LSD2 on LSD2.StoreDocRow_ID = SD2.ID and coalesce(LSD2.StoreBatch_ID, '''') = coalesce(DRB.StoreBatch_ID, '''')' + nxCrLf +
      'left join LogStorePositions LSP on LSP.ID = ' + putQueueDocDetailStartPicking_StorePositionFromJoinField(AOS, ADocType) + ' ' + nxCrLf;

  mSql := mSql +
    'left join CodeStructures CS on CS.ID = SC.StoreBatchStructure_ID' + nxCrLf +
    ' ' + putQueueDocDetailStartPicking_Join(AOS, AModule, AUser_Id) + ' ' + nxCrLf +
    'where ' + nxCrLf
    + AWhere + nxCrLf +
    'order by SD2.PosIndex';

  mCustomerSql := customGetRowsSql(AOS, AModule, AUser_Id, ADocType, mSql, AWhere);

  if mCustomerSql = '' then
    Result := mSql
  else
    Result := mCustomerSql;
end;

function getStoreCardInfoSql(AOS: TNxCustomObjectSpace; AModule, ADocType, AUser_ID: String; AStoreCardIds: TStringList; AFirm_ID, AStore_ID: String;
  AToBatch_ID: String): String;
var
  mTitle, mStoreUnitId, mStoreCardId, mSql: String;
  mStoreCardBehavior, mStoreBatchNoteVisibility: String;
  mExpirationEnterType: Integer;
  mAuxTextRowList, mAuxTextRowDetail, mAuxTextStoreCardInfo: Boolean;
  i: Integer;
begin
  mSql := '';
  for i := 0 to AStoreCardIds.Count - 1 do
  begin
    if Length(AStoreCardIds.Strings(i)) > 10 then
    begin
      // odstranim pripadne uvozovky, ktere mi tam string list nacpal
      AStoreCardIds.Strings(i) := ReplaceStr(AStoreCardIds.Strings(i), '"', '');
      mStoreUnitId := Copy(AStoreCardIds.Strings(i), 12, 10);
      mStoreCardId := Copy(AStoreCardIds.Strings(i), 1, 10);
    end
    else
      mStoreCardId := AStoreCardIds.Strings(i);

    mSql := mSql +
      'select' + nxCrLf +
      '  SC.ID as "ID",' + nxCrLf + // kvuli navazani polozkoveho datasetu
      '  SC.ID as "StoreCard_ID",' + nxCrLf +
      '  SC.' + cStoreCardInfoCodeField + ' as "StoreCardCode",' + nxCrLf +
      '  SC.' + cStoreCardInfoNameField + ' as "StoreCardName",' + nxCrLf +
      '  SC.ShortName as "StoreCardShortName",' + nxCrLf;

    if AToBatch_ID <> '' then
      mSql := mSql +
        QuotedStr(AToBatch_ID) + ' as "XX_Parent_ID",' + nxCrLf;

    if not CFxOID.IsEmpty(mStoreUnitId) then
      // TODO doplneni poli
      mSql := mSql +
        '  SU2.Code as "SelectedUnitCode",' + nxCrLf +
        '  coalesce(SU2.UnitRate, 0) as "SelectedUnitRate",' + nxCrLf
    else
      mSql := mSql +
        '  SC.MainUnitCode as "SelectedUnitCode",' + nxCrLf +
        '  coalesce(SU.UnitRate, 0) as "SelectedUnitRate",' + nxCrLf;

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
      '  ' + enabledCustomFields(AOS, AUser_ID, AModule) + ' as "enabledFields",' + nxCrLf +
      '  coalesce((select ' + FIRST_TOP(1) + ' ''A'' from StoreCardPictures SCP left join Pictures P on P.ID = SCP.Picture_ID where SCP.Parent_ID = SC.ID' + FIRST_TOP_ORACLE(1) + '), ''N'') as "HasPicture$BOOL",' + nxCrLf +
      '  (select sum(SSC.Quantity - SSC.BookedQuantity) / SU.UnitRate from StoreSubCards SSC where SSC.StoreCard_ID = SC.ID) as "SUM_Available",' + nxCrLf +
      '  cast(' + get_StoreCardInfo_SummaryValue(AOS, mTitle) + ' as varchar(30)) as "SUM_CustomValue", ' + nxCrLf +
      '  ' + mTitle + 'as "SUM_CustomTitle",' + NxCrLf +
      '  '';''' + CONCAT_STR + putQueueDocDetailStartPicking_StoreCardBarcodeField(AOS, AModule) + CONCAT_STR + ''';'' as "StoreCardBarcode",' + nxCrLf +
      '  ' + DefaultUnitQuantity(AOS, AModule) + ' as  "DefaultUnitQuantity",' + nxCrLf +
      '  ' + rowAuxText2(AOS, AModule, ADocType, AUser_ID) + ' as "AuxText2",' + NxCrLf;

      mAuxTextRowList := False;
      mAuxTextRowDetail := False;
      mAuxTextStoreCardInfo := False;
      mSql := mSql +
        '  ' + StoreCardAuxText(AOS, AModule, ADocType, AUser_ID, 'getStoreCardInfoSql',
          mAuxTextRowList, mAuxTextRowDetail, mAuxTextStoreCardInfo) + ' as "AuxText",' + nxCrLf +
        '  ' + QuotedStr(NxBoolToStr(mAuxTextRowList)) + ' as "AuxTextInRowList$BOOL",' + nxCrLf +
        '  ' + QuotedStr(NxBoolToStr(mAuxTextRowDetail)) + ' as "AuxTextInRowDetail$BOOL",' + nxCrLf +
        '  ' + QuotedStr(NxBoolToStr(mAuxTextStoreCardInfo)) + ' as "AuxTextInSCInfo$BOOL",' + nxCrLf;

      // zadavani data expirace
      mExpirationEnterType := 0;
      mSql := mSql +
        '  ' + EnterStoreBatchExpirationDate(AOS, AModule, ADocType, AUser_ID, mExpirationEnterType, '') + ' as "EnterBatchExpirationDate",' + nxCrLf +
        '  ' + QuotedStr(IntToStr(mExpirationEnterType)) + ' as "StoreBatchExpDateEnterType",' + nxCrLf;

      // musí být jako string, protože GSON v Android parsuje Enum ze stringu
      mStoreBatchNoteVisibility := '0';
      StoreBatchNoteVisibility(AOS, AModule, ADocType, AUser_ID, mStoreBatchNoteVisibility, '');
      mSql := mSql +
        '  cast(' + mStoreBatchNoteVisibility + ' as varchar(1)) as "StoreBatchNoteVisibility",' + nxCrLf;

    // chovani poli (zmena, validace)
    mStoreCardBehavior := '0';
    EnteredFieldsBehavior(AOS, AModule, ADocType, AUser_ID, mStoreCardBehavior, '0', '0', '0');
    mSql := mSql +
      'cast (' + mStoreCardBehavior + ' as int) as "StoreCardBehavior"' + nxCrLf;

    mSql := mSql +
      'from StoreCards SC' + nxCrLf +
      'join StoreUnits SU on SU.Parent_ID = SC.ID and SU.Code = SC.MainUnitCode' + nxCrLf +
      'left join CodeStructures CS on CS.ID = SC.StoreBatchStructure_ID' + nxCrLf +
      'left join StoreUnits SU2 on SU2.Parent_ID = SC.ID and SU2.ID = ' + QuotedStr(mStoreUnitId) + nxCrLf +
      get_StoreCardInfo_Join(AOS, AModule, AUser_ID) + nxCrLf +
      'where SC.ID = ' + QuotedStr(mStoreCardId);

    mSql := mSql +
      StoreCard_Where(AOS,  AModule, ADocType, AUser_ID);

    if i < AStoreCardIds.Count - 1 then
      mSql := mSql + nxCrLf + nxCrLf +
        ' union all' + nxCrLf + nxCrLf;
  end;
  Result := mSql;
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
  mSqlCondition, mSql, mStoreBatchNoteField, mStoreBatchExpirationField: String;
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
  Result :=
    'select' +
    '  SB.ID as "ID",' +  // kvuli navazani polozkoveho datasetu
    '  SB.ID as "StoreBatch_ID",' + NxCrLf +
    '  SB.Name as "StoreBatchName",' + NxCrLf +
    '  SC.ID as "StoreCard_ID",' + NxCrLf +
    '  SC.' + cStoreCardInfoCodeField + ' as "StoreCardCode",' + NxCrLf +
    '  SC.' + cStoreCardInfoNameField + ' as "StoreCardName",' + NxCrLf +
    '  SC.Category as "StoreCardCategory",' + NxCrLf +
    '  ' + mStoreBatchNoteField + ' as "StoreBatchNote",' + NxCrLf +
    '  (select sum(SSB.Quantity - SSB.BookedQuantity) / SU.UnitRate from StoreSubBatches SSB where SSB.StoreBatch_ID = ' + QuotedStr(AStoreBatch_ID) + ') as "SUM_Available",' +
    '  cast((select sum(SSB.BookedQuantity) / SU.UnitRate from StoreSubBatches SSB where SSB.StoreBatch_ID = ' + QuotedStr(AStoreBatch_ID) + ') as varchar(30)) as "SUM_CustomValue", ';

  mStoreBatchExpirationField := 'ExpirationDate$DATE';
  EnterStoreBatchExpirationDate(AOS, AModule, ADocType, AUser_ID, 0, mStoreBatchExpirationField);
  Result := Result +
    '  SB.' + mStoreBatchExpirationField + ' as "StoreBatchExpirationDate$DATE",' + NxCrLf;

  Result := Result +
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
    '  LSP.ID as "id",' + nxCrLf +
    '  LSP.Code as "code",' + nxCrLf +
    '  LSP.Name as "name",' + nxCrLf +
    '  LSP.PositionType as "type",' + nxCrLf +
    '  S.ID as "storeId",' + nxCrLf +
    '  S.Code as "storeCode",' + nxCrLf +
    '  S.IsLogistic as "storeIsLogistic$BOOL",' + nxCrLf +
    '  -1 as "availableQuantity",' + nxCrLf +
    '  cast('''' as varchar(40)) as "preferredStoreBatchId",' + nxCrLf +
    '  cast('''' as varchar(40)) as "preferredStoreBatchName"' + nxCrLf +
    'from LogStorePositions LSP' + nxCrLf +
    'join Stores S on S.ID = LSP.Store_ID' + nxCrLf +
    'where LSP.ID = ' + QuotedStr(AStorePosition_ID);
end;

function getStoreInfoSql(AOS: TNxCustomObjectSpace; AModule, ADocType, AUser_ID, AStore_ID: String): String;
begin
  Result :=
    'select' + nxCrLf +
    '  S.ID as "id",' + nxCrLf +
    '  S.Code as "code",' + nxCrLf +
    '  S.Name as "name",' + nxCrLf +
    '  ' + get_StoreInfo_IsLogistic(AOS, AModule, AUser_ID) + ' as "isLogistic$BOOL",' + NxCrLf + nxCrLf +
    '  coalesce((select ' + FIRST_TOP(1) + ' LSP.ID from LogStorePositions LSP' + nxCrLf +
    '    where LSP.Store_ID = ' + QuotedStr(AStore_ID) + ' and LSP.X_IsAux = ''A'' order by LSP.Code' + FIRST_TOP_ORACLE(1) + '), '''') as "auxPositionId"' + nxCrLf +
    'from Stores S' + nxCrLf +
    get_StoreInfo_Join(AOS, AModule, AUser_ID) + ' ' + NxCrLf + nxCrLf +
    'where S.ID = ' + QuotedStr(AStore_ID);
end;

procedure GetStoreCard_ID(AOS: TNxCustomObjectSpace; ABarcode: String; AIsId: Boolean; var OWithStoreUnit: Boolean; var OResultList: TStringList);
var
  mResultList: TStringList;
  i: Integer;
begin
  mResultList := TStringList.Create;
  try
    // pokud mame predane primo ID artiklu, jen overime, ze existuje
    if AIsId then
    begin
      AOS.SQLSelect(
        'select ' + FIRST_TOP(1) + ' SC.ID ' +
        'from StoreCards SC ' +
        'where SC.ID = ' + QuotedStr(ABarcode) +
        ' ' + FIRST_TOP_ORACLE(1), OResultList);
    end
    // jinak hledame v dalsich udajich podle konfigurace
    else begin
      for i := 1 to Length(cStoreCardInfoSearchIn) do
      begin
        OWithStoreUnit := False;
        mResultList.Clear;

        // hledame v EAN
        if Copy(cStoreCardInfoSearchIn, i, 1) = 'E' then
        begin
          // vracim navic ID jednotky
          AOS.SQLSelect(
            'select' + nxCrLf +
            '  SC.ID' + CONCAT_STR + ''';''' + CONCAT_STR + 'SU.ID' + nxCrLf +
            'from StoreUnits SU' + nxCrLf +
            'join StoreEANs SE on SE.Parent_ID = SU.ID' + nxCrLf +
            'join StoreCards SC on SC.ID = SU.Parent_ID' + nxCrLf +
            'where' + nxCrLf +
            '  SC.Hidden = ''N'' and SE.EAN = ' + QuotedStr(ABarcode),
            mResultList);

          OWithStoreUnit := True;
        end;

        // hledame ve vyrobnich prikazech, bereme artikl prvniho produktu
        if Copy(cStoreCardInfoSearchIn, i, 1) = 'V' then
          AOS.SQLSelect(
            'select' + nxCrLf +
            '  JOP.StoreCard_ID' + nxCrLf +
            'from PRFJobOrders JO' +
            'join PRFContainerProducts JOP on JOP.Parent_ID = JO.ID' + nxCrLf +
            'where' + nxCrLf +
            '  JO.CodeID = ' + QuotedStr(ABarcode) + ' and JOP.DocumentType = ''JP''' + nxCrLf +
            'order by JOP.PosIndex',
            mResultList);

        // hledame v kodu artiklu
        if Copy(cStoreCardInfoSearchIn, i, 1) = 'C' then
          AOS.SQLSelect(
            'select' + nxCrLf +
            '  SC.ID ' + nxCrLf +
            'from StoreCards SC' + nxCrLf +
            'where' + nxCrLf +
            '  SC.Hidden = ''N'' and SC.Code = ' + QuotedStr(ABarcode),
            mResultList);

        // hledame ve vlastnim hledani
        if Copy(cStoreCardInfoSearchIn, i, 1) = 'X' then
          AOS.SQLSelect(
            StoreCard_CustomSearch(ABarcode, OWithStoreUnit),
            mResultList);

        OResultList.AddStrings(mResultList);

        // nyni pokud jsem nasel dle jednoho udaje, tak dalsi uz nezkousim
        if (OResultList.Count > 0) then
          break;
      end;
    end;
  finally
    mResultList.Free;
  end;
end;

function GetSQLDocHeaderParameters(AOS: TNxCustomObjectSpace; ADocType, AModule, AUser_ID, ADoc_ID: String): String;
var
  mBusTransactionMandatory, mBusProjectMandatory: Boolean;
begin
  mBusTransactionMandatory := False;
  mBusProjectMandatory := False;

  Result :=
    putQueueDocDetailStartPicking_CanAddItems(AOS, AModule, ADocType) + ' as "CanAddItems",' + nxCrLf +
    QuotedStr(NxBoolToStr(askForNewDocumentCreation(AModule))) + ' as "AskForNewDocumentCreation$BOOL",' + nxCrLf +
    QuotedStr(NxBoolToStr(putQueueDocDetailStartPicking_isEditingProcessedItemAllowed(AOS, AModule, ADocType, AUser_ID))) + ' as "CanEditProcessedItem$BOOL",' + nxCrLf +
    putQueueDocDetailStartPicking_createTransferIn(AOS, AModule, ADocType, AUser_ID) + ' as "CreateTransferIn$BOOL",' + nxCrLf +
    QuotedStr(putQueueDocDetailStartPicking_defaultPosition()) + ' as "DefaultPosition",' + nxCrLf +
    QuotedStr(NxBoolToStr(putQueueDocDetailStartPicking_showBarecodeField(AModule))) + ' as "ShowBarecodeField$BOOL",' + nxCrLf +
    QuotedStr(NxBoolToStr(showSerNumberSelection(AOS, AModule, ADocType, AUser_ID))) +  ' as "ShowSerNumberSelection$BOOL",' + nxCrLf +
    QuotedStr(NxBoolToStr(putQueueDocDetailStartPicking_openSerNumberScreenAutomatically(AOS, AModule, AUser_ID))) +  ' as "AutoopenSerNumberScreen$BOOL",' + nxCrLf +
    HeaderAuxFields(AOS, AModule, ADocType, AUser_ID) + nxCrLf +
    QuotedStr(NxBoolToStr(EnterPerson(AOS, AModule, ADocType, AUser_ID, ''))) +  ' as "EnterPerson$BOOL",' + nxCrLf +
    QuotedStr(NxBoolToStr(EnterDocQueue(AOS, AModule, ADocType, AUser_ID))) +  ' as "enterDocQueue$BOOL",' + nxCrLf +
    QuotedStr(NxBoolToStr(EnterFirmOffice(AOS, AModule, ADocType, AUser_ID))) +  ' as "EnterFirmOffice$BOOL",' + nxCrLf +
    QuotedStr(NxBoolToStr(EnterBusOrder(AOS, AModule, ADocType, AUser_ID))) +  ' as "enterBusOrder$BOOL",' + nxCrLf +
    QuotedStr(NxBoolToStr(EnterBusTransaction(AOS, AModule, ADocType, AUser_ID, mBusTransactionMandatory))) +  ' as "enterBusTransaction$BOOL",' + nxCrLf +
    QuotedStr(NxBoolToStr(mBusTransactionMandatory)) + ' as "enterBusTranMandatory$BOOL",' + nxCrLf +
    QuotedStr(NxBoolToStr(EnterBusProject(AOS, AModule, ADocType, AUser_ID, mBusProjectMandatory))) +  ' as "enterBusProject$BOOL",' + nxCrLf +
    QuotedStr(NxBoolToStr(mBusProjectMandatory)) + ' as "enterBusProjectMandatory$BOOL",' + nxCrLf +
    QuotedStr(NxBoolToStr(EnterDivision(AOS, AModule, ADocType, AUser_ID))) +  ' as "EnterDivision$BOOL",' + nxCrLf +
    QuotedStr(NxBoolToStr(EnterTransportationType(AOS, AModule, ADocType, AUser_ID))) +  ' as "EnterTransportationType$BOOL",' + nxCrLf +
    IntToStr(newRowDefaultValue(AOS, AModule, AUser_ID)) + ' as "NewRowDefaultValue",' + nxCrLf +
    QuotedStr(NxBoolToStr(CanEditRowUnit(AOS, AModule, ADocType, AUser_ID))) + ' as "CanEditRowUnit$BOOL",' + nxCrLf +
    QuotedStr(NxBoolToStr(CanCreateNewSerialNumbers(AOS, AModule, ADocType, AUser_ID, ADoc_ID))) + ' as "CanCreateNewSerialNumbers$BOOL",' + nxCrLf +
    IntToStr(IsStoreBatchEnteringRequired(AOS, AModule, ADocType, AUser_ID)) + ' as "IsStoreBatchEnteringRequired",' + nxCrLf +
    QuotedStr(NxBoolToStr(IsAvailableQuantityCheckActive(AOS, AModule, ADocType, AUser_ID))) + ' as "IsQuantityCheckActive$BOOL",' + nxCrLf +
    IntToStr(KeepSelectedPosition(AOS, AModule, ADocType, AUser_ID)) + ' as "KeepSelectedPosition",' + nxCrLf +
    IntToStr(showPrintRowButton(AOS, AModule, ADocType, AUser_ID)) + ' as "ShowPrintRowButton",' + nxCrLf +
    AddSplittedRowAtTheEnd(AOS, AModule, ADocType, AUser_ID) + ' as "AddSplittedRowAtTheEnd$BOOL",' + nxCrLf +
    ShowStoreAvailability(AOS, AModule, ADocType, AUser_ID) + ' as "ShowStoreAvailability$BOOL",' + nxCrLf +
    QuotedStr(NxBoolToStr(NewRowToTheEnd(AOS, AModule, ADocType, AUser_ID))) + ' as "pars.newRowToEnd$BOOL",' + nxCrLf +
    CanTakePhotos(AOS, AModule, ADocType, AUser_ID) + ' as "CanTakePhotos$BOOL"' + nxCrLf;
end;

// pokud je AOnlySimple = True, vrati pouze ID dokladu s uzivatelskymi joiny a omezenimi, jinak vraci kompletni informace ke fronte
function GetListDocQueueSql(AOS: TNxCustomObjectSpace; AModule, AUser_Id, ASearchStr: String; ADocumentTypes: TStringList; AOnlySimple: Boolean = False): String;
var
  mTable, mColumns, mJoins, mDocType: String;
  i: Integer;
begin
  Result := '';
  for i := 0 to ADocumentTypes.Count - 1 do
  begin
    mDocType := ADocumentTypes.Strings(i);
    mTable := GetTable(mDocType);

    // sloupce, ktere se budou nacitat do seznamu - v jedne promenne, abych je mohl pridat do vsech pripadnych casti dotazu
    mColumns :=
      '   DQ.Code' + CONCAT_STR + QuotedStr('-') + CONCAT_STR + 'cast(SD.OrdNumber as varchar(6))' +
        CONCAT_STR + QuotedStr('/') + CONCAT_STR + 'P.Code as "DisplayName",' + nxCrLf +
      '   SD.DocDate$DATE as "DocDate$DATE",' +  nxCrLf;

    if mDocType in [DOC_ShippingList, DOC_RemovalList] then
      mColumns := mColumns + '   (select count(SD2.ID) from ' + mTable + '2 SD2 where SD2.Parent_ID = SD.ID) as "ItemCount",' + nxCrLf
    else if mDocType = DOC_JOBORDER then
      mColumns := mColumns + '   0 as "ItemCount",' + nxCrLf
    else if mDocType = DOC_IssuedOrder then
      mColumns := mColumns + '   (select count(SD2.ID) from IssuedOrders2 SD2 where SD2.Parent_ID = SD.ID and SD2.RowType = 3) as "ItemCount",' + nxCrLf
    else if  mDocType = DOC_LogStoreTransfer then
      mColumns := mColumns + '   (select count(SD2.ID) from LogStoreDocuments2 SD2 where SD2.Parent_ID = SD.ID and SD2.MasterRow_ID is not null) as "ItemCount",' + nxCrLf
    else
      mColumns := mColumns + '   (select count(SD2.ID) from StoreDocuments2 SD2 where SD2.Parent_ID = SD.ID and SD2.RowType = 3) as "ItemCount",' + nxCrLf;

    mColumns := mColumns +
      '   ' + listDocQueue_Field_Description(AOS, AModule, mDocType, AUser_Id) + ' as "Description",' + nxCrLf +
      '   ' + listDocQueue_Field_FirmName(AOS, AModule, mDocType, AUser_Id) + ' as "FirmName",' + NxCrLf +
      '   ' + listDocQueue_customRowColor(AOS, AModule, mDocType, AUser_Id) + ' as "CustomColor",' + nxCrLf +
      '   ' + listDocQueue_AuxNonVisibleFields(AOS, AModule, mDocType, AUser_Id) + nxCrLf;

    // joiny, ktere budu pridavat k dotazum
    mJoins :=
      ' join Firms F on F.ID = SD.Firm_ID' + NxCrLf +
      ' join DocQueues DQ on DQ.ID = SD.DocQueue_ID' + NxCrLf +
      ' join Periods P on P.ID = SD.Period_ID' + NxCrLf +
      ' ' + listDocQueue_Join(AOS, AModule, mDocType, AUser_ID) + nxCrLf;

    // prvni cast, nacteni dokladu primo z tabulky podle stavu K vyskladneni
    Result := Result +
      ' select' + nxCrLf +
      '   SD.ID as "ID"' + nxCrLf;

    if not AOnlySimple then
    begin
      Result := Result +
        ',   ''N'' as "InProgress$BOOL",' + nxCrLf  +
        '  -1 "tempID",' + nxCrLf +
        mColumns +
    end;

    Result := Result +
      ' from ' + mTable + ' SD' + NxCrLf +
      mJoins;

    // presuny mezi pozicemi nemaji stav Vyskladnovano, takze musim kouknout do tabulky rozpracovanosti a rozpracovane doklady vynechat
    // (nactou se v druhe casti)
    if mDocType in [DOC_LogStoreTransfer] then
      Result := Result +
        ' left join ' + REST_TABLE_TemporaryStorage + ' RTS on RTS.Document_ID = SD.ID and RTS.DataType = ' +
          QuotedStr(AModule) + ' and RTS.Status in (' + IntToStr(TempStorageStatus_OPEN) + ', ' + IntToStr(TempStorageStatus_PAUSED) + ')' + nxCrLf;

    Result := Result +
      ' where' + nxCrLf;

    // presuny mezi pozicemi nemaji stav, ale provedeno/neprovedeno
    if mDocType in [DOC_LogStoreTransfer] then
      Result := Result +
       '   SD.Executed = ''N''' + NxCrLf +
       '   and RTS.ID is null' + NxCrLf
    else
      Result := Result +
       '   SD.' + GetStatusField + ' in (''' +  replacestr(STAV_K_VYSKLADNENI(mDocType, AModule), ',', ''',''') + ''')';

    // typ dokladu kontroluji pouze pro sklad. doklady
    if not (mDocType in [DOC_ShippingList, DOC_RemovalList, DOC_IssuedOrder]) then
    begin
      // pokud se maji pouzivat vydejky pri vraceni, tak volam jiny typ dokladu
      if (mDocType = DOC_RefundedBillOfDelivery) and useBillOfDeliveryForRefunding then
        Result := Result + '   and SD.DocumentType = ' + QuotedStr(DOC_BillOfDelivery) + nxCrLf
      else
        Result := Result + '   and SD.DocumentType = ' + QuotedStr(mDocType) + nxCrLf;
    end;

    // hledani
    Result := Result + listDocQueue_Search(AOS, mDocType, ASearchStr, AModule, AUser_Id);

    if i < ADocumentTypes.Count - 1 then
      Result := Result +
        nxCrLf + '  union all '  + nxCrLf + nxCrLf;
  end;

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
      '  RTS.ID "tempID",' + nxCrLf +
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
    Result := Result + listDocQueue_Search(AOS, mDocType, ASearchStr, AModule, AUser_Id) + nxCrLf;
  end;

  Result := 'select * from (' + nxCrLf + Result + nxCrLf + ') q ';

  if not AOnlySimple then
    Result := Result + listDocQueue_OrderBy(AOS, AModule, mDocType, AUser_Id);
end;

// pokud je AOnlySimple = True, vrati pouze ID dokladu s uzivatelskymi joiny a omezenimi, jinak vraci kompletni informace ke fronte
function GetListWithoutDocQueueSql(AOS: TNxCustomObjectSpace; AModule, ADocType, AUser_Id, ASearchStr: String; AOnlySimple: Boolean = False): String;
begin
  Result := Result +
    'select' + nxCrLf +
    '  0000000000 as "ID",' + nxCrLf;

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
      '  SD.ID as "tempID",' + nxCrLf +
      // zkusim si nacist i data, abych z nich mohl pripadne zobrazit nejake informace
      '  Data as "Data"' + nxCrLf;
  end;

  Result := Result +
    'from ' + REST_TABLE_TemporaryStorage + ' SD' + NxCrLf;

  Result := Result +
    ' where' + nxCrLf +
    '   SD.DataType = ' + QuotedStr(AModule) + nxCrLf +
    '   and ((SD.Status = ' + IntToStr(TempStorageStatus_OPEN) + nxCrLf +
    '       and SD.User_ID = ' + QuotedStr(AUser_ID) + ')' + nxCrLf +
    '     or (SD.Status = ' + IntToStr(TempStorageStatus_PAUSED);

    if NoncancelableWorkOnlyOneUser then
      Result := Result + nxCrLf +
        '     and SD.User_ID = ' + QuotedStr(AUser_ID) + '))' + nxCrLf
    else
      Result := Result +
        '))' + nxCrLf;

  Result := 'select * from ( ' + Result + ') q ';

  if not AOnlySimple then
    Result := Result + ' order by "DocDate$DATE"';
end;

function GetListPartialInvProtocolsSql(AOS: TNxCustomObjectSpace; AModule, ADocType, AUser_Id, ASearchStr: String; AOnlySimple: Boolean = False): String;
var
  mColumns, mJoins: String;
begin
  mColumns :=
    '  DQ.Code' + CONCAT_STR + QuotedStr('-') + CONCAT_STR + 'cast(SD.OrdNumber as varchar(6))' + nxCrLf +
      CONCAT_STR + QuotedStr('/') + CONCAT_STR + 'P.Code as "DisplayName", ' + nxCrLf +
    '  SD.DocDate$DATE "DocDate$DATE",' + nxCrLf +
    '  (select count(PIR.ID) from PartialInvProtocolRows PIR' + nxCrLf +
    '    left join PartialInvProtocolBatches PIB on PIR.id = PIB.Parent_ID' + nxCrLf +
    '    where PIR.Parent_ID = SD.id) "ItemCount",' + nxCrLf +
    '  SD.Description as "Description",' + nxCrLf +
    '  S.Code "FirmName"' + nxCrLf;

  mJoins :=
    'join MainInvProtocols MIP on SD.MainProtocol_ID = MIP.id' + nxCrLf +
    'join Stores S on S.ID = MIP.Store_ID' + nxCrLf +
    'join DocQueues DQ on DQ.ID = SD.DocQueue_ID' + nxCrLf +
    'join Periods P on P.ID = SD.Period_ID' + nxCrLf;

  Result :=
    'select' + nxCrLf +
    '  SD.ID as "ID"' + nxCrLf;

  if not AOnlySimple then
  begin
    Result := Result +
      ',   ''N'' as "InProgress$BOOL",' + nxCrLf +
      '  -1 "tempID",' + nxCrLf +
      mColumns;
  end;

  Result := Result +
    'from PartialInvProtocols SD' + nxCrLf +
    mJoins +
    'where ' + nxCrLf +
    '  (SD.User_ID is null ' + nxCrLf +
    '    or (SD.User_ID = ' + QuotedStr(AUser_Id) + ' and ReaderID = ''''))' + nxCrLf +
    '  and SD.Closed = ''N''' + nxCrLf +
    '  and MIP.StartedAt$DATE > 0' + nxCrLf +
    '  and MIP.Closed = ''N''' + nxCrLf;

  Result := Result + listDocQueue_Search(AOS, ADocType, ASearchStr, AModule, AUser_Id);

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
        '  RTS.ID "tempID",' + nxCrLf +
        mColumns;
    end;

    Result := Result +
      ' from ' + REST_TABLE_TemporaryStorage + ' RTS' + NxCrLf +
      ' join PartialInvProtocols SD on SD.ID = RTS.Document_ID' + NxCrLf +
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
    Result := Result + ' order by "DocDate$DATE"';
end;

function GetListMainInvProtocolsSql(AOS: TNxCustomObjectSpace; AModule, ADocType, AUser_Id, ASearchStr: String; AOnlySimple: Boolean = False): String;
var
  mColumns, mJoins: String;
begin
  mColumns :=
    '  DQ.Code' + CONCAT_STR + QuotedStr('-') + CONCAT_STR + 'cast(SD.OrdNumber as varchar(6))' + nxCrLf +
      CONCAT_STR + QuotedStr('/') + CONCAT_STR + 'P.Code as "DisplayName", ' + nxCrLf +
    '  SD.DocDate$DATE "DocDate$DATE",' + nxCrLf +
    '  SD.Description as "Description",' + nxCrLf +
    '  S.Code "FirmName",' + nxCrLf +
    '  S.id "StoreId"' + nxCrLf;

  mJoins :=
    'join Stores S on S.ID = SD.Store_ID' + nxCrLf +
    'join DocQueues DQ on DQ.ID = SD.DocQueue_ID' + nxCrLf +
    'join Periods P on P.ID = SD.Period_ID' + nxCrLf;

  Result :=
    'select' + nxCrLf +
    '  SD.ID as "ID"' + nxCrLf;

  if not AOnlySimple then
  begin
    Result := Result +
      ',   ''N'' as "InProgress$BOOL",' + nxCrLf +
      '  -1 "tempID",' + nxCrLf +
      mColumns;
  end;

  Result := Result +
    'from MainInvProtocols SD' + nxCrLf +
    mJoins +
    'where' + nxCrLf +
    '  SD.Closed = ''N''' + nxCrLf +
    '  and SD.StartedAt$DATE > 0';

  Result := Result + listDocQueue_Search(AOS, ADocType, ASearchStr, AModule, AUser_Id);

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
        '  RTS.ID "tempID",' + nxCrLf +
        mColumns;
    end;

    Result := Result +
      ' from ' + REST_TABLE_TemporaryStorage + ' RTS' + NxCrLf +
      ' join MainInvProtocols SD on SD.ID = RTS.Document_ID' + NxCrLf +
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
    Result := Result + ' order by "DocDate$DATE"';
end;

function GetPartialInvProtocolsRowsSql(AOS: TNxCustomObjectSpace; AModule, ADocType, AUser_ID, ADoc_ID: String;): String;
var
  mAuxTextRowList, mAuxTextRowDetail, mAuxTextStoreCardInfo: Boolean;
begin
  Result :=
    'select ' + nxCrLf+
    '  PIR.Parent_ID as "XX_Parent_ID", ' + nxCrLf +
    '  PIR.ID as "StoreDocument2_ID", ' + nxCrLf +
    '  S.ID as "StoreFrom_ID", ' + nxCrLf +
    '  ' + putQueueDocDetailStartPicking_RowsOrderBy(AOS, AModule, ADocType, AUser_ID) + ' as "OrderForIndex",' + nxCrLf +
    '  S.Code as "StoreFromCode", ' + nxCrLf +
    '  S.IsLogistic as "StoreFromIsLogistic$BOOL", ' + nxCrLf +
    '  SC.ID as "StoreCard_ID", ' + nxCrLf +
    '  SC.' + cStoreCardInfoCodeField + ' as "StoreCardCode", ' + nxCrLf +
    '  SC.' + cStoreCardInfoNameField + ' as "StoreCardName", ' + nxCrLf +
    '  '';''' + CONCAT_STR + getUnitsSql + CONCAT_STR + ''';'' as "StoreCardUnits", ' + nxCrLf +
    '  '';''' + CONCAT_STR + putQueueDocDetailStartPicking_StoreCardBarcodeField(AOS, AModule) + CONCAT_STR + ''';'' as "StoreCardBarcode", ' + nxCrLf +
    '  SC.Category as "StoreCardCategory", ' + nxCrLf +
    //'  coalesce(MIB.DocumentedQuantity / MIB.UnitRate, MIR.DocumentedQuantity / MIR.UnitRate) "UnitQuantity", ' + nxCrLf +
    '  0 "UnitQuantity", ' + nxCrLf +
    '  MIR.UnitRate as "UnitRate", ' + nxCrLf +
    '  MIR.QUnit as "UnitCode", ' + nxCrLf +
    '  coalesce(LSP.ID, '''') as "StorePositionFrom_ID", ' + nxCrLf +
    '  coalesce(LSP.Code, '''') as "StorePositionFromCode", ' + nxCrLf +
    '  coalesce(SB.ID, '''') as "StoreBatch_ID", ' + nxCrLf +
    '  coalesce(SB.Name, '''') as "StoreBatchName", ' + nxCrLf +
    '  ' + putQueueDocDetailStartPicking_rowsAuxFields(AOS, AModule, ADocType, AUser_ID) + nxCrLf;

  mAuxTextRowList := False;
  mAuxTextRowDetail := False;
  mAuxTextStoreCardInfo := False;
  Result := Result +
    '  ' + StoreCardAuxText(AOS, AModule, ADocType, AUser_ID, 'getRowsSql',
      mAuxTextRowList, mAuxTextRowDetail, mAuxTextStoreCardInfo) + ' as "StoreCardAuxText",' + nxCrLf +
    '  ' + QuotedStr(NxBoolToStr(mAuxTextRowList)) + ' as "AuxTextInRowList$BOOL",' + nxCrLf +
    '  ' + QuotedStr(NxBoolToStr(mAuxTextRowDetail)) + ' as "AuxTextInRowDetail$BOOL",' + nxCrLf +
    '  ' + QuotedStr(NxBoolToStr(mAuxTextStoreCardInfo)) + ' as "AuxTextInSCInfo$BOOL",' + nxCrLf;

  Result := Result +
    '  ' + rowAuxText2(AOS, AModule, ADocType, AUser_ID) + ' as "AuxText2" ' + nxCrLf +
    ' from PartialInvProtocolRows PIR ' + nxCrLf +
    ' join PartialInvProtocols PIP on PIR.Parent_ID = PIP.id ' + nxCrLf +
    ' join MainInvProtocols MIP on PIP.MainProtocol_ID = MIP.id ' + nxCrLf +
    ' join MainInvProtocolRows MIR on PIR.MIPRow_ID = MIR.id ' + nxCrLf +
    ' join Stores S on S.ID = MIP.Store_ID ' + nxCrLf +
    ' join StoreCards SC on SC.ID = MIR.StoreCard_ID ' + nxCrLf +
    ' left join PartialInvProtocolBatches PIB on PIR.ID = PIB.Parent_ID ' + nxCrLf +
    ' left join MainInvProtocolBatches MIB on PIB.MIPBatch_ID = MIB.id ' + nxCrLf +
    ' left join StoreBatches SB on SB.ID = MIB.StoreBatch_ID ' + nxCrLf +
    ' left join PartialInvProtocolPositions PIPP on PIR.PIPPosition_ID = PIPP.id ' + nxCrLf +
    ' left join MainInvProtocolPositions MIPP on PIPP.MIPPosition_ID = MIPP.id ' + nxCrLf +
    ' left join LogStorePositions LSP on LSP.ID = MIPP.StorePosition_ID ' + nxCrLf +
    ' where ' + nxCrLf +
    ' 	PIR.Parent_ID = ' + QuotedStr(ADoc_ID) + nxCrLf;

  if ABRA then
    Result := Result +
      '   and SC.NonStockType = ''N''' + nxCrLf
  else
    Result := Result +
      '   and SC.IsStockType = ''A''' + nxCrLf;

  Result := Result +
    ' order by ' + nxCrLf +
    ' 	SC.Code, SB.Name, LSP.Code';
end;

begin
end.