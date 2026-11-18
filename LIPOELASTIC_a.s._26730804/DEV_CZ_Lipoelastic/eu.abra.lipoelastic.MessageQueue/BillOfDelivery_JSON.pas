function Create_BillOfDelivery_Header_JSON(ABillOfDelivery: TNxCustomBusinessObject): TJSONSuperObject;
var
  mJSON: TJSONSuperObject;
  mContext: TNxContext;
begin
  Result := nil;
  mJSON := TJSONSuperObject.Create;
  try
    mContext := NxCreateContext_1(ABillOfDelivery);
    mJSON.S['ID'] := ABillOfDelivery.OID;
    mJSON.S['BillOfDelivery_ID'] := ABillOfDelivery.OID;
    mJSON.S['IssuerOrgIdentNumber'] := mContext.GetCompanyCache.OrgIdentNumber;
    mJSON.S['DisplayName'] := ABillOfDelivery.DisplayName;
    mJSON.S['ExternalNumber'] := ABillOfDelivery.DisplayName;
    mJSON.DT8601['DocDate'] := ABillOfDelivery.GetFieldValueAsDateTime('DocDate$DATE');
    mJSON.S['Description'] := ABillOfDelivery.GetFieldValueAsString('Description');
    mJSON.S['CurrencyCode'] := ABillOfDelivery.GetFieldValueAsString('Currency_ID.Code');
    Result := mJSON;
    mJSON := nil;
  finally
    mJSON.Free;
  end;
end;


function Create_BillOfDelivery_Batch_JSON(ABatch: TNxCustomBusinessObject): TJSONSuperObject;
var
  mJSON: TJSONSuperObject;
begin
  Result := nil;
  mJSON := TJSONSuperObject.Create;
  try
    mJSON.S['ID'] := ABatch.OID;
    mJSON.S['StoreBatch_ID'] := ABatch.GetFieldValueAsString('StoreBatch_ID');
    mJSON.S['StoreBatchName'] := ABatch.GetFieldValueAsString('StoreBatch_ID.Name');
    mJSON.D['Quantity'] := ABatch.GetFieldValueAsFloat('Quantity');
    mJSON.DT8601['Expiry'] := ABatch.GetFieldValueAsDateTime('StoreBatch_ID.ExpirationDate$DATE');
    mJSON.DT8601['Produce'] := ABatch.GetFieldValueAsDateTime('StoreBatch_ID.ProductionDate$DATE');
    mJSON.S['StoreBatchSpecification'] := ABatch.GetFieldValueAsString('StoreBatch_ID.Specification');
    Result := mJSON;
    mJSON := nil;
  finally
    mJSON.Free;
  end;
end;


function Create_BillOfDelivery_Row_JSON(ARow: TNxCustomBusinessObject; ASources: TJSONSuperObject): TJSONSuperObject;
var
  mJSON, mBatchJSON, mSourceJSON: TJSONSuperObject;
  mBatches: TNxCustomBusinessMonikerCollection;
  mProvideRow_ID, mSourceRow_ID: String;
  mIndex: Integer;
begin
  Result := nil;
  mJSON := TJSONSuperObject.Create;
  try
    mJSON.S['ID'] := ARow.OID;
    mJSON.S['BODRowID'] := ARow.OID;
    mJSON.I['PosIndex'] := ARow.GetFieldValueAsInteger('PosIndex');
    mJSON.I['RowType'] := ARow.GetFieldValueAsInteger('RowType');
    mJSON.S['Text'] := ARow.GetFieldValueAsString('Text');
    mJSON.D['Quantity'] := ARow.GetFieldValueAsFloat('Quantity');
    mJSON.S['QUnit'] := ARow.GetFieldValueAsString('QUnit');
    mJSON.D['UnitRate'] := ARow.GetFieldValueAsFloat('UnitRate');
    if not NxIsEmptyOID(ARow.GetFieldValueAsString('StoreCard_ID')) then begin
      mJSON.S['StoreCardCode'] := ARow.GetFieldValueAsString('StoreCard_ID.Code');
      mJSON.S['StoreCardEAN'] := ARow.GetFieldValueAsString('StoreCard_ID.EAN');
      mJSON.S['StoreCardName'] := ARow.GetFieldValueAsString('StoreCard_ID.Name');
    end;

    mJSON.S['ProvideRow_ID'] := ARow.GetFieldValueAsString('ProvideRow_ID');
    mJSON.S['XProvideRowID'] := ARow.GetFieldValueAsString('X_ProvideRow_ID');
    // CZ ReceivedOrders.X_MQ_External_ID identifies the original issued order.
    //mJSON.S['IssuedOrder_ID'] := mSourceJSON.S['X_MQ_External_ID'];

    mJSON.O['DocRowBatches'] := mJSON.CreateJSONArray;
    if ARow.GetFieldValueAsInteger('RowType') = 3 then begin
      mBatches := ARow.GetLoadedCollectionMonikerForFieldCode(ARow.GetFieldCode('DocRowBatches'));
      for mIndex := 0 to mBatches.Count - 1 do begin
        mBatchJSON := Create_BillOfDelivery_Batch_JSON(mBatches.BusinessObject[mIndex]);
        try
          mJSON.A['DocRowBatches'].Add(mBatchJSON);
          mBatchJSON := nil;
        finally
          mBatchJSON.Free;
        end;
      end;
    end;
    Result := mJSON;
    mJSON := nil;
  finally
    mJSON.Free;
  end;
end;


function Create_BillOfDelivery_JSON(ABillOfDelivery: TNxCustomBusinessObject; ASources: TJSONSuperObject): TJSONSuperObject;
var
  mJSON, mRowJSON: TJSONSuperObject;
  mRows: TNxCustomBusinessMonikerCollection;
  mIndex: Integer;
begin
  Result := nil;
  if not Assigned(ABillOfDelivery) then
    RaiseException('document.missing bill_of_delivery');
  if not Assigned(ASources) then
    RaiseException('source.missing received_orders');
  mJSON := Create_BillOfDelivery_Header_JSON(ABillOfDelivery);
  try
    mJSON.O['Rows'] := mJSON.CreateJSONArray;
    mRows := ABillOfDelivery.GetLoadedCollectionMonikerForFieldCode(ABillOfDelivery.GetFieldCode('Rows'));
    if mRows.Count = 0 then
      RaiseException('document.empty Rows id=' + ABillOfDelivery.OID);
    for mIndex := 0 to mRows.Count - 1 do begin
      mRowJSON := Create_BillOfDelivery_Row_JSON(mRows.BusinessObject[mIndex], ASources);
      try
        mJSON.A['Rows'].Add(mRowJSON);
        mRowJSON := nil;
      finally
        mRowJSON.Free;
      end;
    end;
    Result := mJSON;
    mJSON := nil;
  finally
    mJSON.Free;
  end;
end;


begin
end.
