function scrGetStoreCard_ID(AOS : TNxCustomObjectSpace; AValue : string) : string;
const
  cSQL = 'SELECT Sc.ID FROM StoreCards sc left join storeunits su on su.parent_id=sc.id '+
         ' left join StoreEANs SE on se.parent_id=su.id WHERE SE.Ean like ''%s'' and sc.Hidden=''N''';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    Result:='';
    AOS.SQLSelect(Format(cSQL, [AValue]), mList);
    if mList.Count > 0 then
      Result := mList.Strings[0]
  finally
    mList.Free;
  end;
end;

function scrOutgoingTransfer_ID(AOS : TNxCustomObjectSpace; AValue : string) : string;
const
  cSQL = 'SELECT A.ID FROM Storedocuments a where a.DocumentType=''22'' and ((select count(*)  from StoreDocuments SDx  where SDx.RDocument_ID = A.ID and    SDx.RDocumentType = ''22'' ) = 0 ) '+
         'and A.X_month like ''%s'' and a.period_id=''31I0000101'' ';
var
  mList : TStringList;
begin
  mList := TStringList.create;
  try
    Result:='';
    AOS.SQLSelect(Format(cSQL, [AValue]), mList);
    if mList.Count > 0 then
      Result := mList.Strings[0]
  finally
    mList.Free;
  end;
end;

function scrGetSupplier_ID(AOS : TNxCustomObjectSpace; AFirm_ID : string; AStorecard_ID : string) : string;
const
  cSQL = 'SELECT ID FROM Suppliers WHERE Firm_ID=''%s'' and StoreCard_ID=''%s''';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  Result:='';
  try
    NxScriptingLog.WriteEventFmt(logDebug, cSQL, [AFirm_ID, AStorecard_ID]);
    AOS.SQLSelect(Format(cSQL,  [AFirm_ID, AStorecard_ID]), mList);
    if mList.Count > 0 then
      Result := mList.Strings[0]
  finally
    mList.Free;
  end;
end;

begin
end.