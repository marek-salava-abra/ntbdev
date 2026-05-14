

function iCheckUnit(AStoreCard : TNxCustomBusinessObject; AUnitCode : string; var AUnitRate : double) : boolean;
var
  i : integer;
  mColl : TNxCustomBusinessMonikerCollection;
begin
  Result := false;
  AUnitRate := 0;
  mColl := AStoreCard.GetLoadedCollectionMonikerForFieldCode(AStoreCard.GetFieldCode('StoreUnits'));
  if not Assigned(mColl) then
    exit;
  for i:= 0 to mColl.Count - 1 do
    if mColl.BusinessObject[i].GetFieldValueAsString('Code') = AUnitCode then begin
      AUnitRate := mColl.BusinessObject[i].GetFieldValueAsFloat('UnitRate');
      Result := True;
      exit;
    end;
end;


function iGetOrCreateStoreSubCard_ID(AStoreCard : TNxCustomBusinessObject; AStore_ID : TNxOID) : TNxOID;
var
  mParam : TNxParameters;
  mSubCard : TNxCustomBusinessObject;
begin
  Result := '';
  mParam := TNxParameters.Create;
  try
    mParam.GetOrCreateParam(dtString, 'Store_ID').AsString := AStore_ID;
    AStoreCard.GetStringFromObjectAction(6, mParam, Result);
    if NxIsEmptyOID(Result) then begin
      mSubCard := AStoreCard.ObjectSpace.CreateObject('GAWVAN4GFNDL342T01C0CX3FCC'); // StoreSubCard
      try
        mSubCard.New;
        mSubCard.Prefill;
        mSubCard.GetMonikerForFieldCode(mSubCard.GetFieldCode('StoreCard_ID')).BindToObject(AStoreCard);
        mSubCard.SetFieldValueAsString('Store_ID', AStore_ID);
        mSubCard.Save;
        Result := mSubCard.OID;
      finally
        mSubCard.Free;
      end;
    end;
  finally
    mParam.Free;
  end;
end;


begin
end.