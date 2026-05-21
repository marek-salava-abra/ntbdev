uses '.API';

function CreateParcelsBatch_JSON(AOS: TNxCustomObjectSpace; const AList: TStringList; ACLSID: string; var ALog: string;):TJSONSuperObject;
var
  mJSON, mSingleJSON: TJSONSuperObject;
  mBO: TNxCustomBusinessObject;
  i: integer;
begin
  //Result:= nil;
  mJSON:= TJSONSuperObject.Create;
  try
    mBO:= AOS.CreateObject(ACLSID);
    try
      mJSON.O['parcels']:= mJSON.CreateJSONArray;
      for i:= 0 to AList.Count -1 do
      begin
        mBO.Load(AList[i], nil);
        //NxShowSimpleMessage(CreateSingleParcel_JSON(mBO), nil);
        mSingleJSON:= CreateSingleParcel_JSON(mBO, ALog);
        if Assigned(mSingleJSON) then
          mJSON.A['parcels'].Add(mSingleJSON);
      end;
      Result:= mJSON;
    finally
      mBO.Free;
    end;
  except
    LogMessage('ERROR', 'CreateParcelsBatch_JSON', ExceptionMessage, ALog);
  end;
end;

function CreateSingleParcel_JSON(const ABO: TNxCustomBusinessObject; var ALog: string): TJSONSuperObject;
var
  mJSON, mItemsListJSON: TJSONSuperObject;
  mName, mStreet, mCity, mPostCode, mCountryCode, mRecipient, mUsedName: string;
  mAddressTypeVar: string;
begin
  Result:= nil;
  mJSON:= nil;

  case ABO.GetFieldValueAsInteger('TargetAddressType') of
  0:
    begin
      mAddressTypeVar:= 'Firm_ID.ResidenceAddress_ID';
      mName:= ABO.GetFieldValueAsString('Firm_ID.Name');
    end;
  1:
    begin
      mAddressTypeVar:= 'FirmOffice_ID.Address_ID';
      mName:= ABO.GetFieldValueAsString(mAddressTypeVar + '.Recipient');
      if NxIsBlank(mName) then
        mName:= ABO.GetFieldValueAsString('FirmOffice_ID.Parent_ID.Name'); //?? Recipient?
    end;
  2:
    begin
      mAddressTypeVar:= 'Person_ID.Address_ID';
      mName:= ABO.GetFieldValueAsString('Person_ID.FullName');
    end;
  3:
    begin
      mAddressTypeVar:= 'TargetAddress_ID';
      mName:= ABO.GetFieldValueAsString('TargetAddress_ID.Recipient');
      if NxIsBlank(Trim(mName)) then
        mName:= ABO.GetFieldValueAsString('TargetAddress_ID.Location');
    end;
  end;

  mJSON:= TJSONSuperObject.Create;
  try
    //mRecipient:= ABO.GetFieldValueAsString(mAddressTypeVar + '.Recipient');
    //if (not(NxIsBlank(mRecipient))) and (not(ABO.GetFieldValueAsBoolean('Firm_ID.X_B2B'))) then
    //  mName:= mRecipient;

    //required fields
    mJSON.S['name']:= mName;
    mJSON.S['address']:= ABO.GetFieldValueAsString(mAddressTypeVar + '.Street');
    if not NxIsBlank(ABO.GetFieldValueAsString(mAddressTypeVar + '.x_addressline_2')) then
      mJSON.S['address_2']:= ABO.GetFieldValueAsString(mAddressTypeVar + '.x_addressline_2');
    mJSON.S['city']:= ABO.GetFieldValueAsString(mAddressTypeVar + '.City');
    mJSON.S['postal_code']:= ABO.GetFieldValueAsString(mAddressTypeVar + '.PostCode');
    mJSON.S['country']:= ABO.GetFieldValueAsString(mAddressTypeVar + '.CountryCode');
    mJSON.S['telephone']:= ABO.GetFieldValueAsString(mAddressTypeVar + '.PhoneNumber1');
    mJSON.S['email']:= ABO.GetFieldValueAsString(mAddressTypeVar + '.EMail');
    //mJSON.I['quantity']:= 1;
    mJSON.O['shipment']:= mJSON.CreateJSON;
    mJSON.O['shipment'].I['id']:= StrToInt(ABO.GetFieldValueAsString('IssuedContent_ID.Code'));
    //mJSON.O['shipment'].S['name']:= '';         //optional

    //true if the label should be created directly when creating parcel
    //false if the label should be created later
    mJSON.B['request_label']:= false;

    //optional fields
    mJSON.S['order_number']:= ABO.GetFieldValueAsString('X_ExternalNumber');
    mJSON.S['reference']:= ABO.OID;

    if ABO.GetFieldValueAsInteger('X_NumberOfParcels') = 0 then
      mJSON.I['quantity']:= 1
    else
      mJSON.I['quantity']:= ABO.GetFieldValueAsInteger('X_NumberOfParcels');        //Min 1, Max 250;


    mItemsListJSON:= CreateListOfItems_JSON(ABO, ALog);
    if Assigned(mItemsListJSON) then
      mJSON.O['parcel_items']:= mItemsListJSON.O['parcel_items'];


    //mJSON.S['company_name']:= '';
    //mJSON.S['contract']:= '';
    //mJSON.S['address_2']:= '';
    //mJSON.S['house_number']:= '';
    //mJSON.I['insured_value']:= '';   //must be value >2, Max 5000.
    //mJSON.S['total_order_value_currency']:= '';
    //mJSON.S['total_order_value']:= '';

    //mJSON.S['shipping_method_checkout_name']:= '';
    //mJSON.S['to_post_number']:= '';
    //mJSON.S['country_state']:= '';
    //mJSON.I['sender_address']:= 0;
    //mJSON.S['external_reference']:= '';
    //mJSON.S['reference']:= '';
    //mJSON.I['to_service_point']:= 0;
    //mJSON.B['is_return']:= false;
    //mJSON.S['length']:= '';
    //mJSON.S['width']:= '';
    //mJSON.S['height']:= '';
    //mJSON.S['weight']:= '';

  Result:= mJSON;

  except
    LogMessage('ERROR', 'CreateSingleParcel_JSON', ExceptionMessage, ALog);
    mJSON.Free;
  end;
end;


function CreateListOfItems_JSON(const ABO: TNxCustomBusinessObject; var ALog: string): TJSONSuperObject;
var
  mBODBO: TNxCustomBusinessObject;
  mRows: TNxCustomBusinessMonikerCollection;
  mJSON: TJSONSuperObject;
  mSingleJSON: TJSONSuperObject;
  mBillOfDelivery_ID: string;
  mCountOfRowType3, i: integer
begin
  Result:= nil;
  mJSON:= nil;

  mCountOfRowType3:= 0;

  mBillOfDelivery_ID:= ABO.ObjectSpace.SQLSelectFirstAsString(Format('SELECT RIGHTSIDE_ID FROM RELATIONS WHERE REL_DEF = 1438 AND LEFTSIDE_ID = ''%s''',[ABO.OID]));
  if NxIsEmptyOID(mBillOfDelivery_ID) then
  begin
    LogMessage('ERROR', 'CreateListOfItems_JSON', 'Bill of delivery not found, ID: '+ABO.OID, ALog);
    exit;
  end;

  mBODBO:= ABO.ObjectSpace.CreateObject(Class_BillOfDelivery);
  try
    mBODBO.Load(mBillOfDelivery_ID, nil);
    mRows:= mBODBO.GetLoadedCollectionMonikerForFieldCode(mBODBO.GetFieldCode('Rows'));

    mJSON:= TJSONSuperObject.Create;
    try
      mJSON.O['parcel_items']:= mJSON.CreateJSONArray;
      for i:= 0 to mRows.Count -1 do
      begin
        if not (mRows.BusinessObject[i].GetFieldValueAsInteger('RowType') = 3) then
          continue;

        if mRows.BusinessObject[i].GetFieldValueAsString('StoreCard_ID.StoreCardCategory_ID') = cSTORECARDCATEGORY_ID_TRANSPORT then
          continue;

        mSingleJSON:= CreateSignleItem_JSON(mRows.BusinessObject[i], ALog);
        if Assigned(mSingleJSON) then
          mJSON.A['parcel_items'].Add(mSingleJSON)
        else
          LogMessage('ERROR', 'CreateListOfItems_JSON', 'Cannot create item: '+mRows.BusinessObject[i].GetFieldValueAsString('StoreCard_ID.Code') + ' DOC: '+mBODBO.OID, ALog);
      end;
      if mJSON.A['parcel_items'].Length > 0 then
        Result:= mJSON
      else
        mJSON.Free;
    except
      mJSON.Free;
      LogMessage('ERROR', 'CreateListOfItems_JSON', 'Error occured while creating parcel_items DOC: '+mBODBO.OID, ALog);
      Result:= nil;
    end;
  finally
    mBODBO.Free;
  end;
end;


function CreateSignleItem_JSON(const ABO: TNxCustomBusinessObject; var ALog: string): TJSONSuperObject;
var
  mRows: TNxCustomBusinessMonikerCollection;
  mRow: TNxCustomBusinessObject;
  mJSON: TJSONSuperObject;
  mName, mStreet, mCity, mPostCode, mCountryCode: string;
  mAddressTypeVar: string;
  mBillOfDelivery_ID: string;
  i: integer;
  mWeight: extended;
begin
  Result:= nil;
  mJSON:= nil;

  if ABO.GetFieldValueAsString('StoreCard_ID.StoreAssortmentGroup_ID') = cSTOREASSORTMENTGROUP_ID_MARKETING then
    exit;

  mJSON:= TJSONSuperObject.Create;
  try
    case ABO.GetFieldValueAsInteger('StoreCard_ID.IntrastatWeightUnit') of
      0: mWeight:= ABO.GetFieldValueAsFloat('StoreCard_ID.IntrastatWeight') / 1000;
      1: mWeight:= ABO.GetFieldValueAsFloat('StoreCard_ID.IntrastatWeight');
      2: mWeight:= ABO.GetFieldValueAsFloat('StoreCard_ID.IntrastatWeight') * 1000;
    end;

    mJSON.S['hs_code']:= ABO.GetFieldValueAsString('StoreCard_ID.IntrastatCommodity_ID.Code');
    mJSON.S['weight']:= NxIBFormatFloatWithNamedMask('0.000', mWeight, '.', ABO.ObjectSpace);
    mJSON.I['quantity']:= Trunc(ABO.GetFieldValueAsFloat('Quantity'));
    mJSON.S['description']:= ABO.GetFieldValueAsString('StoreCard_ID.Name');
    mJSON.D['value']:= ABO.GetFieldValueAsFloat('ProvideRow_ID.TAmount');

    Result:= mJSON;

  except
    LogMessage('ERROR', 'CreateSignleItem_JSON', ExceptionMessage, ALog);
    mJSON.Free;
    Result:= nil;
  end;
end;

begin
end.