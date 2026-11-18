procedure ImportTXT_OnUpdate(Sender : TComponent);
var
  mSite : TSiteForm;
begin
  if Sender is TComponent then begin
    mSite := NxFindSiteForm(TComponent(Sender));
    if Assigned(mSite) then begin
      if mSite is TDynSiteForm then begin
        TBasicAction(Sender).Enabled := TDynSiteForm(mSite).edit;
      end;
    end;
  end
end;

function UpdateQuantity(AOS : TNxCustomObjectSpace; AQuantity : double; AStoreCard_Code : string; AStore_ID : TNxOID) : boolean;
var
  mStoreCard_ID, mStoreSubCard_ID : TNxOID;
  mStoreSubCard, mStoreCard : TNxCustomBusinessObject;
begin
  Result := false;
  try
    if not(AStore_ID='1C00000101') then mStoreCard_ID := scrGetStoreCard_ID(AOS, 'Code', AStoreCard_Code);
    if (AStore_ID='1C00000101') then mStoreCard_ID := scrGetStoreCard_ID(AOS, 'X_Code_SK', AStoreCard_Code);
    //ShowMessage(mStoreCard_ID);
    if NxIsEmptyOID(mStoreCard_ID) then
      exit;
    mStoreCard:=AOS.CreateObject('C3V5QDVZ5BDL342M01C0CX3FCC');
    mStoreCard.Load(mStoreCard_ID,nil);
    mStoreSubCard_ID := iGetOrCreateStoreSubCard_ID(mStoreCard,AStore_ID);

    mStoreSubCard := AOS.CreateObject('GAWVAN4GFNDL342T01C0CX3FCC');
    try
      if not NxIsEmptyOID(mStoreSubCard_ID) then
        mStoreSubCard.Load(mStoreSubCard_ID, nil)
      else begin
        mStoreSubCard.New;
        mStoreSubCard.SetFieldValueAsString('StoreCard_ID', mStoreCard_ID);
        mStoreSubCard.SetFieldValueAsString('Store_ID', AStore_ID);

      end;
      mStoreSubCard.SetFieldValueAsFloat('Quantity', AQuantity);
      mStoreSubCard.SetFieldValueAsDateTime('PurchaseDate$DATE',Date);
      mStoreSubCard.Save;
    finally
      mStoreSubCard.Free;
    end;
    Result := True;
  except
    Result := False;
  end;
end;


{
  Funkce pro dohledání skladové karty
}
function scrGetStoreCard_ID(AOS : TNxCustomObjectSpace; AFieldName : string; AValue : string) : string;
const
  cSQL = 'SELECT ID FROM StoreCards WHERE %s like ''%s'' and Hidden=''N''';
var
  mList : TStringList;
begin
  Result := '';
  mList := TStringList.create;
  try
    AOS.SQLSelect(Format(cSQL, [AFieldName, AValue]), mList);
    if mList.Count > 0 then
      Result := mList.Strings[0]
  finally
    mList.Free;
  end;
end;


{
  Funkce pro dohledání skladu
}
function scrGetStore_ID(AOS : TNxCustomObjectSpace; AFieldName : string; AValue : string) : string;
const
  cSQL = 'SELECT ID FROM Stores WHERE %s like ''%s'' and Hidden=''N''';
var
  mList : TStringList;
begin
  Result := '';
  mList := TStringList.create;
  try
    AOS.SQLSelect(Format(cSQL, [AFieldName, AValue]), mList);
    if mList.Count > 0 then
      Result := mList.Strings[0]
  finally
    mList.Free;
  end;
end;


{
  Funkce pro dohledání dílčí skladové karty
}
function scrGetStoreSubCard_ID(AOS : TNxCustomObjectSpace; AStoreCard_ID : TNxOID; AStore_ID : TNxOID) : string;
const
  cSQL = 'SELECT ID FROM StoreSubCards WHERE StoreCard_ID=''%s'' AND Store_ID=''%s'' ';
var
  mList : TStringList;
begin
  Result := '';
  mList := TStringList.create;
  try
    AOS.SQLSelect(Format(cSQL, [AStoreCard_ID, AStore_ID]), mList);
    if mList.Count > 0 then
      Result := mList.Strings[0]
  finally
    mList.Free;
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