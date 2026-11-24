uses '.API', '.const';


const
  cRO_Store_ID = '1120000101';
  cRO_Division_ID = '~000000202';
  cRO_MQ_State_Done = 1;
  cRO_MQ_State_Error = 2;
  cRO_SourceInstanceKey = 'SK';
  cRO_SourceObjectName = 'ReceivedOrders';
  cRO_SourceSyncState_Done = 1;
  cPAYMENTKIND_DOBIRKA = 3;


procedure Set_ReceivedOrder_MessageQueue_Result(AMQBO: TNxCustomBusinessObject; AState: Integer; AResult: String);
begin
  AMQBO.SetFieldValueAsInteger('X_MQ_State', AState);
  AMQBO.SetFieldValueAsString('X_MQ_ResultMessage', AResult);
  AMQBO.Save;
end;


function Is_API_PUT_Response_Successful(AResponseJSON: TJSONSuperObject): Boolean;
begin
  Result := False;
  if not Assigned(AResponseJSON) then
    Exit;

  Result :=
    (
      not NxIsEmptyOID(AResponseJSON.S['ID']) or
      not NxIsEmptyOID(AResponseJSON.S['id'])
    ) and
    (LowerCase(AResponseJSON.S['status']) <> 'error') and
    (LowerCase(AResponseJSON.S['error']) <> 'error');
end;


function Get_API_PUT_Response_ErrorMessage(AResponseJSON: TJSONSuperObject): String;
var
  mHTTPStatus: String;
begin
  if not Assigned(AResponseJSON) then begin
    Result := 'API did not return a response.';
    Exit;
  end;

  mHTTPStatus := AResponseJSON.S['statusMessage'];
  Result := AResponseJSON.S['responseText'];
  if NxIsBlank(Result) then Result := AResponseJSON.S['except'];
  if NxIsBlank(Result) then Result := AResponseJSON.S['description'];
  if NxIsBlank(Result) then Result := AResponseJSON.S['message'];
  if NxIsBlank(Result) and (LowerCase(AResponseJSON.S['error']) <> 'error') then
    Result := AResponseJSON.S['error'];
  if NxIsBlank(Result) then Result := AResponseJSON.AsString;

  if not NxIsBlank(mHTTPStatus) then
    Result := 'HTTP ' + mHTTPStatus + ': ' + Result;
end;


procedure Sync_ReceivedOrder_ProcessingToSource(AOrder: TNxCustomBusinessObject);
var
  mInstanceKey, mSourceOrder_ID: String;
  mInputJSON, mLookupJSON, mResultJSON: TJSONSuperObject;
begin
  if AOrder.GetFieldValueAsString('DocQueue_ID') <> cRO_DocQueue_ID_OPDS then
    Exit;
  if AOrder.GetFieldValueAsString('PMState_ID') <> cMQ_RO_PMState_ID_ZPRACOVAVA_SE then
    Exit;
  if NxIsEmptyOID(AOrder.GetFieldValueAsString('X_MQ_External_ID')) then
    Exit;

  mInstanceKey := API_GetInstanceKey_By_OrgIdentNumber(AOrder.GetFieldValueAsString('Firm_ID.OrgIdentNumber'));
  // Zatím je nakonfigurováno mapování pouze pro SK.
  if mInstanceKey <> 'SK' then
    RaiseException('state_mapping.not_found instance=' + mInstanceKey);

  mInputJSON := TJSONSuperObject.Create;
  mLookupJSON := nil;
  mResultJSON := nil;
  try
    mInputJSON.S['IssuedOrder_ID'] := AOrder.GetFieldValueAsString('X_MQ_External_ID');
    mLookupJSON := API_POST(AOrder.ObjectSpace, mInstanceKey, mInputJSON,
      'script/eu.abra.Lipoelastic.MessageQueue/API/RecievedOrdersToIssuedOrders', False);
    if not Assigned(mLookupJSON) then
      RaiseException('state_sync.source_lookup_failed received_order_id=' + AOrder.OID);
    mSourceOrder_ID := mLookupJSON.S['ReceivedOrder_ID'];
    if NxIsEmptyOID(mSourceOrder_ID) then
      RaiseException('state_sync.source_not_found received_order_id=' + AOrder.OID);

    mResultJSON := API_ChangePMState(AOrder.ObjectSpace, mInstanceKey, cRO_SourceObjectName,
      mSourceOrder_ID, cMQ_SK_RO_PMState_ID_ZPRACOVAVA_SE);
    if not Is_API_PUT_Response_Successful(mResultJSON) then
      RaiseException('state_sync.failed source_received_order_id=' + mSourceOrder_ID +
        ' error=' + Get_API_PUT_Response_ErrorMessage(mResultJSON));
  finally
    mResultJSON.Free;
    mLookupJSON.Free;
    mInputJSON.Free;
  end;
end;


procedure Set_BillOfDelivery_Orders_Processing(ABillOfDelivery: TNxCustomBusinessObject);
var
  mOrderIDs: TStringList;
  mOrder: TNxCustomBusinessObject;
  mState: String;
  i: Integer;
begin
  mOrderIDs := TStringList.Create;
  mOrder := nil;
  try
    ABillOfDelivery.ObjectSpace.SQLSelect(
      'SELECT DISTINCT RO.ID FROM StoreDocuments2 SD2' +
      ' JOIN ReceivedOrders2 RO2 ON RO2.ID = SD2.ProvideRow_ID' +
      ' JOIN ReceivedOrders RO ON RO.ID = RO2.Parent_ID' +
      ' WHERE SD2.Parent_ID = ' + QuotedStr(ABillOfDelivery.OID) +
      ' AND RO.DocQueue_ID = ' + QuotedStr(cRO_DocQueue_ID_OPDS), mOrderIDs);
    mOrder := ABillOfDelivery.ObjectSpace.CreateObject(Class_ReceivedOrder);
    for i := 0 to mOrderIDs.Count - 1 do begin
      mOrder.Load(mOrderIDs.Strings[i], nil);
      mState := mOrder.GetFieldValueAsString('PMState_ID');
      if (mState <> cMQ_RO_PMState_ID_ZPRACOVAVA_SE) and
         (mState <> cMQ_RO_PMState_ID_VYFAKTUROVANA) and
         (mState <> cMQ_RO_PMState_ID_STORNOVANA) then
        mOrder.PMChangeState(cMQ_RO_PMState_ID_ZPRACOVAVA_SE);
    end;
  finally
    mOrder.Free;
    mOrderIDs.Free;
  end;
end;


procedure Update_Source_ReceivedOrder(AOS: TNxCustomObjectSpace; ASourceReceivedOrder_ID: String; ACZOrderBO: TNxCustomBusinessObject);
var
  mUpdateJSON, mResultJSON: TJSONSuperObject;
begin
  if NxIsEmptyOID(ASourceReceivedOrder_ID) then begin
    RaiseException('input.missing field=ReceivedOrder_ID');
  end;
  if not Assigned(ACZOrderBO) then begin
    RaiseException('callback.missing target_received_order');
  end;
  if NxIsEmptyOID(ACZOrderBO.OID) then begin
    RaiseException('callback.missing target_received_order');
  end;

  mUpdateJSON := TJSONSuperObject.Create;
  mResultJSON := nil;
  try
    mUpdateJSON.S['X_MQ_External_ID'] := ACZOrderBO.OID;
    //mUpdateJSON.S['X_ExternalDocument'] := ACZOrderBO.DisplayName;
    mUpdateJSON.I['X_MQ_SyncState'] := cRO_SourceSyncState_Done;

    mResultJSON := API_PUT(
      AOS,
      cRO_SourceInstanceKey,
      mUpdateJSON,
      cRO_SourceObjectName,
      ASourceReceivedOrder_ID
    );

    if not Is_API_PUT_Response_Successful(mResultJSON) then begin
      RaiseException(
        'callback.failed source_received_order_id=' + ASourceReceivedOrder_ID +
        ' target_received_order_id=' + ACZOrderBO.OID +
        ' phase=update' +
        ' error=' + Get_API_PUT_Response_ErrorMessage(mResultJSON)
      );
    end;

    mResultJSON.Free;
    mResultJSON := nil;

    // Procesni stav se v ABRA Web API meni samostatnou operaci, ne beznym PUT objektu.
    mResultJSON := API_ChangePMState(
      AOS,
      cRO_SourceInstanceKey,
      cRO_SourceObjectName,
      ASourceReceivedOrder_ID,
      cMQ_SK_RO_PMState_ID_OBJEDNANA_V_CZ
    );

    if not Is_API_PUT_Response_Successful(mResultJSON) then begin
      RaiseException(
        'callback.failed source_received_order_id=' + ASourceReceivedOrder_ID +
        ' target_received_order_id=' + ACZOrderBO.OID +
        ' phase=pmchangestate' +
        ' error=' + Get_API_PUT_Response_ErrorMessage(mResultJSON)
      );
    end;
  finally
    if Assigned(mResultJSON) then
      mResultJSON.Free;
    mUpdateJSON.Free;
  end;
end;


function Get_Value_ID_By_Code(AOS: TNxCustomObjectSpace; ATableName: String; ACode: String): String;
begin
  Result := '';
  if NxIsBlank(ACode) then
    Exit;

  Result := AOS.SQLSelectFirstAsString(
    'SELECT ID FROM ' + ATableName +
    ' WHERE Hidden = ' + QuotedStr('N') +
    ' AND Code = ' + QuotedStr(ACode),
    ''
  );
end;


function Get_StoreCard_ID_By_EAN(AOS: TNxCustomObjectSpace; AEAN: String; ASourceRow_ID: String): String;
begin
  if NxIsBlank(AEAN) then begin
    RaiseException('input.missing field=Rows.StoreCardEAN row_id=' + ASourceRow_ID);
  end;

  Result := AOS.SQLSelectFirstAsString(
    ' SELECT ID FROM StoreCards' +
    ' WHERE Hidden = ' + QuotedStr('N') +
    ' AND EAN = ' + QuotedStr(AEAN));

  if NxIsEmptyOID(Result) then begin
    RaiseException('lookup.not_found table=StoreCards EAN=' + AEAN);
  end;
end;


function Get_Firm_ID_By_OrgIdentNumber(AOS: TNxCustomObjectSpace; AOrgIdentNumber: String): String;
begin
  if NxIsBlank(AOrgIdentNumber) then begin
    RaiseException('input.missing field=IssuerOrgIdentNumber');
  end;

  Result := AOS.SQLSelectFirstAsString(
    'SELECT ID FROM Firms' +
    ' WHERE Firm_ID IS NULL' +
    ' AND Hidden = ' + QuotedStr('N') +
    ' AND OrgIdentNumber = ' + QuotedStr(AOrgIdentNumber),
    ''
  );
  if NxIsEmptyOID(Result) then begin
    RaiseException('lookup.not_found table=Firms OrgIdentNumber=' + AOrgIdentNumber);
  end;
end;


function Get_VATRate_ID(AOS: TNxCustomObjectSpace; AVATCountry_ID: String; AVATRate: Extended): String;
begin
  Result := AOS.SQLSelectFirstAsString(
    'SELECT ID FROM VATRates' +
    ' WHERE Hidden = ' + QuotedStr('N') +
    ' AND Country_ID = ' + QuotedStr(AVATCountry_ID) +
    ' AND Tariff = ' + NxFloatToIBStr(AVATRate),
    ''
  );
  if NxIsEmptyOID(Result) then begin
    RaiseException(
      'lookup.not_found table=VATRates' +
      ' Country_ID=' + AVATCountry_ID +
      ' Tariff=' + FloatToStr(AVATRate)
    );
  end;
end;


procedure Fill_ReceivedOrder_DeliveryAddress(AOrderBO: TNxCustomBusinessObject; AAddressJSON: TJSONSuperObject);
begin
  AOrderBO.SetFieldValueAsInteger('DeliveryType', 3);
  AOrderBO.SetFieldValueAsString('DeliveryAddress_ID.Location', AAddressJSON.S['Location']);
  AOrderBO.SetFieldValueAsString('DeliveryAddress_ID.Recipient', AAddressJSON.S['Recipient']);
  AOrderBO.SetFieldValueAsString('DeliveryAddress_ID.Street', AAddressJSON.S['Street']);
  AOrderBO.SetFieldValueAsString('DeliveryAddress_ID.City', AAddressJSON.S['City']);
  AOrderBO.SetFieldValueAsString('DeliveryAddress_ID.PostCode', AAddressJSON.S['PostCode']);
  AOrderBO.SetFieldValueAsString('DeliveryAddress_ID.Country', AAddressJSON.S['Country']);
  AOrderBO.SetFieldValueAsString('DeliveryAddress_ID.CountryCode', AAddressJSON.S['CountryCode']);
  AOrderBO.SetFieldValueAsString('DeliveryAddress_ID.PhoneNumber1', AAddressJSON.S['PhoneNumber1']);
  AOrderBO.SetFieldValueAsString('DeliveryAddress_ID.PhoneNumber2', AAddressJSON.S['PhoneNumber2']);
  AOrderBO.SetFieldValueAsString('DeliveryAddress_ID.FaxNumber', AAddressJSON.S['FaxNumber']);
  AOrderBO.SetFieldValueAsString('DeliveryAddress_ID.EMail', AAddressJSON.S['EMail']);
  AOrderBO.SetFieldValueAsString('DeliveryAddress_ID.X_PickupPoint', AAddressJSON.S['X_PickupPoint']);
end;


procedure Add_ReceivedOrder_Row(AOS: TNxCustomObjectSpace; ARows: TNxCustomBusinessMonikerCollection; ARowJSON: TJSONSuperObject; AVATCountry_ID: String);
var
  mOrderRowBO: TNxCustomBusinessObject;
  mSourceRow_ID, mStoreCard_ID: String;
  mRowType: Integer;
begin
  if not Assigned(ARowJSON) then begin
    RaiseException('input.invalid field=Rows');
  end;

  mSourceRow_ID := ARowJSON.S['ID'];
  if NxIsEmptyOID(mSourceRow_ID) then begin
    RaiseException('input.missing field=Rows.ID');
  end;

  mRowType := ARowJSON.I['RowType'];
  mOrderRowBO := ARows.AddNewObject;
  mOrderRowBO.Prefill;
  mOrderRowBO.SetFieldValueAsInteger('RowType', mRowType);
  mOrderRowBO.SetFieldValueAsInteger('PosIndex', ARowJSON.I['PosIndex']);
  mOrderRowBO.SetFieldValueAsString('Text', ARowJSON.S['Text']);
  mOrderRowBO.SetFieldValueAsString('X_ProvideRow_ID', mSourceRow_ID);
  mOrderRowBO.SetFieldValueAsString('Division_ID', cRO_Division_ID);

  if mRowType = 3 then begin
    mStoreCard_ID := Get_StoreCard_ID_By_EAN(AOS, ARowJSON.S['StoreCardEAN'], mSourceRow_ID);
    mOrderRowBO.SetFieldValueAsString('Store_ID', cRO_Store_ID);
    mOrderRowBO.SetFieldValueAsString('StoreCard_ID', mStoreCard_ID);
  end;

  mOrderRowBO.SetFieldValueAsFloat('Quantity', ARowJSON.D['Quantity']);
  mOrderRowBO.SetFieldValueAsString('QUnit', ARowJSON.S['QUnit']);
  mOrderRowBO.SetFieldValueAsFloat('UnitRate', ARowJSON.D['UnitRate']);
  mOrderRowBO.SetFieldValueAsFloat('UnitPrice', ARowJSON.D['UnitPrice']);
  mOrderRowBO.SetFieldValueAsString('VATRate_ID', '00000X0000');
  mOrderRowBO.SetFieldValueAsDateTime('DeliveryDate$DATE', ARowJSON.DT8601['DeliveryDate']);
end;


procedure CreateOrder(AOS: TNxCustomObjectSpace; var AMQBO: TNxCustomBusinessObject);
var
  mJSON, mAddressJSON: TJSONSuperObject;
  mRowsJSON: TJSONSuperObjectArray;
  mOrderBO: TNxCustomBusinessObject;
  mRows: TNxCustomBusinessMonikerCollection;
  mSourceIssuedOrder_ID, mSourceReceivedOrder_ID, mExistingOrder_ID: String;
  mFirm_ID, mCountry_ID, mVATCountry_ID, mCurrency_ID: String;
  mOrderCreated: Boolean;
  i: Integer;
begin
  mJSON := nil;
  mOrderBO := nil;
  mOrderCreated := False;
  try
    try
      if NxIsBlank(AMQBO.GetFieldValueAsString('X_MQ_JSON')) then begin
        RaiseException('input.missing field=X_MQ_JSON');
      end;

      mJSON := TJSONSuperObject.ParseString(AMQBO.GetFieldValueAsString('X_MQ_JSON'), True);
      if not Assigned(mJSON) then begin
        RaiseException('input.invalid field=X_MQ_JSON');
      end;

      mSourceIssuedOrder_ID := mJSON.S['ID'];
      if NxIsEmptyOID(mSourceIssuedOrder_ID) then begin
        RaiseException('input.missing field=ID');
      end;

      mSourceReceivedOrder_ID := mJSON.S['ReceivedOrder_ID'];
      if NxIsEmptyOID(mSourceReceivedOrder_ID) then begin
        RaiseException('input.missing field=ReceivedOrder_ID');
      end;

      mExistingOrder_ID := AOS.SQLSelectFirstAsString(
        'SELECT ID FROM ReceivedOrders' +
        ' WHERE X_MQ_External_ID = ' + QuotedStr(mSourceIssuedOrder_ID),
        ''
      );
      if not NxIsEmptyOID(mExistingOrder_ID) then begin
        mOrderBO := AOS.CreateObject(Class_ReceivedOrder);
        mOrderBO.Load(mExistingOrder_ID, nil);
      end else begin
        mRowsJSON := mJSON.A['Rows'];
        if not Assigned(mRowsJSON) then begin
          RaiseException('input.missing field=Rows');
        end;

        if mRowsJSON.Length = 0 then begin
          RaiseException('input.empty field=Rows');
        end;

        mAddressJSON := mJSON.O['DeliveryAddress'];
        if not Assigned(mAddressJSON) then begin
          RaiseException('input.missing field=DeliveryAddress');
        end;

        mFirm_ID := Get_Firm_ID_By_OrgIdentNumber(AOS, mJSON.S['IssuerOrgIdentNumber']);
        mCountry_ID := Get_Value_ID_By_Code(AOS, 'Countries', mJSON.S['CountryCode']);
        //mVATCountry_ID := Get_Value_ID_By_Code(AOS, 'Countries', mJSON.S['VATCountryCode']);
        mCurrency_ID := Get_Value_ID_By_Code(AOS, 'Currencies', mJSON.S['CurrencyCode']);

        mOrderBO := AOS.CreateObject(Class_ReceivedOrder);
        mOrderBO.New;
        mOrderBO.Prefill;
        mOrderBO.SetFieldValueAsString('DocQueue_ID', cRO_DocQueue_ID_OPDS);
        mOrderBO.SetFieldValueAsString('Firm_ID', mFirm_ID);
        mOrderBO.SetFieldValueAsDateTime('DocDate$DATE', mJSON.DT8601['DocDate']);
        mOrderBO.SetFieldValueAsString('ExternalNumber', mJSON.S['ExternalNumber']);
        mOrderBO.SetFieldValueAsString('X_MQ_External_ID', mSourceIssuedOrder_ID);
        mOrderBO.SetFieldValueAsString('X_MQ_OrderType', mJSON.S['X_MQ_OrderType']);
        mOrderBO.SetFieldValueAsInteger('TradeType', mJSON.I['TradeType']);
        mOrderBO.SetFieldValueAsString('Description', mJSON.S['Description']);
        mOrderBO.SetFieldValueAsString('X_Poznam_exp', mJSON.S['X_Poznam_exp']);
        mOrderBO.SetFieldValueAsString('Country_ID', mCountry_ID);
        mOrderBO.SetFieldValueAsString('VATCountry_ID', '00000CZ000');
        mOrderBO.SetFieldValueAsString('Currency_ID', mCurrency_ID);
        mOrderBO.SetFieldValueAsBoolean('PricesWithVAT', mJSON.B['PricesWithVAT']);
        mOrderBO.SetFieldValueAsFloat('CurrRate', mJSON.D['CurrRate']);
        


        // Externi ID dopravy a platby jsou uz primo ID ciselniku v cilove ABRA.
        // Jejich povinnost se kontroluje pred odeslanim do MessageQueue.
        mOrderBO.SetFieldValueAsString('PaymentType_ID', mJSON.S['PaymentType_ID']);
        mOrderBO.SetFieldValueAsString('TransportationType_ID', mJSON.S['TransportationType_ID']);

        mOrderBO.SetFieldValueAsFloat('U_Cena', mJSON.D['ReceivedOrderAmount']);

        if mOrderBO.GetFieldValueAsInteger('PaymentType_ID.PaymentKind') = cPAYMENTKIND_DOBIRKA then begin
          mOrderBO.SetFieldValueAsFloat('U_Dobirka', mJSON.D['ReceivedOrderAmount']);
        end;

        mOrderBO.SetFieldValueAsString('IntrastatDeliveryTerm_ID', Get_Value_ID_By_Code(AOS, 'IntrastatDeliveryTerms', mJSON.S['IntrastatDeliveryTermCode']));
        mOrderBO.SetFieldValueAsString('IntrastatTransactionType_ID',Get_Value_ID_By_Code(AOS,'IntrastatTransactionTypes',mJSON.S['IntrastatTransactionTypeCode']));
        mOrderBO.SetFieldValueAsString('IntrastatTransportationType_ID', Get_Value_ID_By_Code(AOS,'IntrastatTransportationTypes',mJSON.S['IntrastatTransportationTypeCode']));

        Fill_ReceivedOrder_DeliveryAddress(mOrderBO, mAddressJSON);
        mOrderBO.SetFieldValueAsString('X_Delivery_Adress_ID', mOrderBO.GetFieldValueAsString('DeliveryAddress_ID'));
        //mOrderBO.SetFieldValueAsString('X_Delivery_Adress_ID', mJSON.S['X_Delivery_Adress_ID']);

        mRows := mOrderBO.GetLoadedCollectionMonikerForFieldCode(mOrderBO.GetFieldCode('Rows'));
        for i := 0 to mRowsJSON.Length - 1 do begin
          Add_ReceivedOrder_Row(AOS, mRows, mRowsJSON.O[i], mVATCountry_ID);
        end;

        mOrderBO.SetFieldValueAsBoolean('Confirmed', True);
        mOrderBO.Save;
        mOrderCreated := True;
      end;

      Update_Source_ReceivedOrder(AOS, mSourceReceivedOrder_ID, mOrderBO);

      if mOrderCreated then begin
        Set_ReceivedOrder_MessageQueue_Result(AMQBO, cRO_MQ_State_Done,
          'received_order.created id=' + mOrderBO.OID +
          ' display_name=' + mOrderBO.DisplayName +
          ' source_updated id=' + mSourceReceivedOrder_ID);
      end else begin
        Set_ReceivedOrder_MessageQueue_Result(AMQBO, cRO_MQ_State_Done,
          'received_order.exists id=' + mOrderBO.OID +
          ' display_name=' + mOrderBO.DisplayName +
          ' source_updated id=' + mSourceReceivedOrder_ID);
      end;
    except
      Set_ReceivedOrder_MessageQueue_Result(AMQBO, cRO_MQ_State_Error, ExceptionMessage);
    end;
  finally
    if Assigned(mOrderBO) then
      mOrderBO.Free;
    if Assigned(mJSON) then
      mJSON.Free;
  end;
end;


begin
end.
