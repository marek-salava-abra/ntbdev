
function GetAvailableQuantity(var AOS : TNxCustomObjectSpace;var aStoreCard_ID, aStore_ID:string): extended;
const
  cSQL = 'SELECT Quantity FROM StoreSubCards WHERE StoreCard_ID=''%s'' and Store_id=''%s'' ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    AOS.SQLSelect(Format(cSQL, [aStoreCard_ID, aStore_ID]), mList);
    if mList.Count > 0 then
      Result := StrToFloat(mList.Strings[0])
      else Result:=0;
  finally
    mList.Free;
  end;
end;

function GetPOZPQuantity(var AOS : TNxCustomObjectSpace;var aStoreCard_ID:string): extended;
const
  cSQL = 'SELECT sum(Quantity) FROM PLMProduceRequests WHERE StoreCard_ID=''%s'' and joborder_id is Null ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    AOS.SQLSelect(Format(cSQL, [aStoreCard_ID]), mList);
    if mList.Count > 0 then
      Result := StrToFloat(mList.Strings[0])
      else Result:=0;
  finally
    mList.Free;
  end;
end;

function GetVYPPQuantity(var AOS : TNxCustomObjectSpace;var aStoreCard_ID:string): extended;
const
  cSQL = 'SELECT ID FROM PLMJObOrders WHERE StoreCard_ID=''%s'' and FinishedBy_ID is Null ';
  cSQL2 =  'Select sum(fp2.quantity) from PLMFinishedProducts fp left join PLMFinishedProducts2 fp2 on fp.id=fp2.parent_id where fp.JobOrder_ID=''%s'' ';
var
  mList, mList2 : TStringList;
  mBO:TNxCustomBusinessObject;
  i:Integer;
  mResult:Extended;
begin
  mList := TStringList.Create;
  mResult:=0;
  Result:=0;
  try
    AOS.SQLSelect(Format(cSQL, [aStoreCard_ID]), mList);
    if mList.Count > 0 then begin
      for i:=0 to mList.count-1 do begin;
      mList2 := TstringList.Create;
      mbo:=aos.CreateObject(Class_PLMJobOrder);
      mbo.Load(mlist.strings[i], nil);
      AOS.SQLSelect(Format(cSQL2, [mbo.OID]), mList2);
      if mbo.GetFieldValueAsFloat('Quantity')-StrToFloat(mList2.Strings[0])>0 then  mResult := mResult+mbo.GetFieldValueAsFloat('Quantity')-StrToFloat(mList2.Strings[0]);
      mlist2.Free;
      mbo.free;
    end;
    end;
  finally
    Result:=mresult;
    mList.Free;
  end;
end;

begin
end.