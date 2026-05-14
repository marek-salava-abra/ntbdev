function scrOrderRow_ID(AOS : TNxCustomObjectSpace; AFirm_ID : string; AStoreCard_ID:string; AStore_ID:string) : string;
const
  cSQL = 'SELECT IO2.ID FROM IssuedOrders IO left join IssuedOrders2 IO2 on IO2.parent_ID=IO.ID where IO.Closed=''N'' and IO.Issued=''A'' and io.Firm_ID=''%s'' and io2.storecard_ID=''%s'' and io2.store_ID=''%s'' and not((io2.deliveredquantity-io2.quantity)=0) order by io.docdate$date desc';
var
  mList2 : TStringList;
begin
  mList2 := TStringList.Create;
  try
    mlist2.Clear;
    Result:='';
    AOS.SQLSelect(Format(cSQL, [AFirm_ID,AStoreCard_ID,AStore_ID]), mList2);
    if mList2.Count > 0 then
      Result := mList2.Strings[0];
  finally
    mList2.Free;
  end;
end;

function scrOrder_ID(AOS : TNxCustomObjectSpace; AOrderRow_ID : string) : string;
const
  cSQL = 'SELECT IO2.Parent_ID FROM IssuedOrders2 io2 where io2.ID=''%s'' ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    Result:='';
    AOS.SQLSelect(Format(cSQL, [AOrderRow_ID]), mList);
    if mList.Count > 0 then
      Result := mList.Strings[0];
  finally
    mList.Free;
  end;
end;

begin
end.