const
  cSTORE_ID = '~00000011Y';
  cDIVISION_ID = '1000000101';

{
Vyvolává se před fyzickým uložením vlastních dat objektu do databáze.
}
procedure BeforeSave_Hook(Self: TNxCustomBusinessObject);
var
  mPackagingList, mContainersList: TStringList;
  mRows: TNxCustomBusinessMonikerCollection;
  mRow: TNxCustomBusinessObject;
  i, j: integer;
begin
  if not (Self.GetFieldValueAsString('PMState_ID.Code') in ['1001', '1020', '1030']) then
    exit;
  if not (Self.GetFieldValueAsString('X_PackagingMethod_ID.Code') in ['APM02', 'APM03']) then
    exit;
  if not (CFxNxRuntime.NxGetEnvironmentType = reRuntimeExe) then
    exit;

  mPackagingList:= TStringList.create;
  try
    mPackagingList.NameValueSeparator:= '=';
    //mPackagingList.Sorted:= True;
    //mPackagingList.Duplicates:= dupIgnore;

    mRows:= Self.GetLoadedCollectionMonikerForFieldCode(Self.GetFieldCode('Rows'));
    for i:= 0 to mRows.Count -1 do
    begin
      mRow:= mRows.BusinessObject[i];
      //netrojkové řádky přeskočím
      if not (mRow.GetFieldValueAsInteger('RowType') = 3) then continue;
      //pokud jsou zde obaly, smažu je
      if mRow.GetFieldValueAsInteger('StoreCard_ID.Category') = 4 then
      begin
        mRow.MarkForDelete;
        continue;
      end;

      mContainersList:= GetPackagingCardIDs(Self.ObjectSpace, mRow.GetFieldValueAsString('StoreCard_ID'), mRow.GetFieldValueAsString('Qunit'));
      try
        for j:= 0 to mContainersList.Count -1 do
        begin
          AddPackagingCard(mPackagingList, mContainersList.Names[j], NxIBStrToFloat(mContainersList.ValueFromIndex[j]), mRow.GetFieldValueAsFloat('Quantity'));
        end;
      finally
        mContainersList.Free;
      end;
    end;

    for i:= 0 to mPackagingList.Count - 1 do
    begin
      mRow:= mRows.AddNewObject;
      mRow.SetFieldValueAsInteger('RowType', 3);
      mRow.SetFieldValueAsString('Store_ID', cSTORE_ID);
      mRow.SetFieldValueAsString('Division_ID', cDIVISION_ID);
      mRow.SetFieldValueAsString('StoreCard_ID', mPackagingList.Names[i]);
      mRow.SetFieldValueAsFloat('UnitQuantity', NxIBStrToFloat(mPackagingList.ValueFromIndex[i]));
    end;
  finally
    mPackagingList.Free;
  end;
end;


procedure AddPackagingCard(APackagingList: TStringList; AStoreCard_ID: string; AQuantity, ARowQuantity: Extended);
var
  idx: Integer;
  addQty, curQty: Extended;
begin
  if (APackagingList = nil) or NxIsEmptyOID(AStoreCard_ID) then
    Exit;

  addQty := AQuantity * ARowQuantity;

  idx := APackagingList.IndexOfName(AStoreCard_ID);

  if idx >= 0 then
  begin
    // načtu a přičtu
    curQty := NxIBStrToFloat(APackagingList.ValueFromIndex[idx]) + addQty;

    // přepíšu celý řádek
    APackagingList[idx] := AStoreCard_ID + APackagingList.NameValueSeparator + NxFloatToIBStr(curQty);
  end
  else
  begin
    // přidám nový řádek
    APackagingList.Add(AStoreCard_ID + APackagingList.NameValueSeparator + NxFloatToIBStr(addQty));
  end;
end;


function GetPackagingCardIDs(AOS: TNxCustomObjectSpace; AStoreCard_ID, QUnit: string): TStringList;
const
  cSTORECARD_CATEGORY_PACKAGING_ID = '~000000203';
begin
  Result:= TStringList.Create;
  try
    Result.NameValueSeparator:= '=';
    Result.Sorted:= True;
    Result.Duplicates:= dupIgnore;

  AOS.SQLSelect(Format(
    ' SELECT C.StoreCard_ID || ''='' || CAST(C.UnitQuantity AS VARCHAR) FROM StoreUnits SU '+
    ' JOIN StoreContainers C ON C.Parent_ID = SU.ID '+
    ' JOIN StoreCards SC ON SC.ID = C.StoreCard_ID '+
    ' WHERE SU.Parent_ID = ''%s'' '+
    ' AND SU.Code = ''%s'' ' +
    ' AND SC.StoreCardCategory_ID = ''%s'' ',
    [AStoreCard_ID, QUnit, cSTORECARD_CATEGORY_PACKAGING_ID]), Result);
  except
    NxShowSimpleMessage(ExceptionMessage, nil);
  end;
end;

begin
end.