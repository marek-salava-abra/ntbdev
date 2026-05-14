




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




procedure Import_AddRows2(ARows : TNxCustomBusinessMonikerCollection; AList : TStringList; ADivision_ID : string; AStore_ID : string);
var
  i : Integer;
  mRowBO : TNxCustomBusinessObject;
  mRowTxt, mStoreCard_ID, mstorecard_code, mbalast1,mbalast2,mbalast3 : string;
  mQuantity, mprice : double;
begin
  for i := 0 to AList.Count - 1 do begin
    mRowTxt := Alist.strings[i];
    mStoreCard_ID:= NxToken(mRowTxt, ';');
    //mStoreCard_ID:=scrStorecard_ID(arows.ObjectSpace, mstorecard_code);
    mQuantity := StrToFloat(NxToken(mRowTxt, ';'));

    if mQuantity > 0 then begin
      mRowBO := ARows.AddNewObject;
      mRowBO.Prefill;
      mRowBO.SetFieldValueAsInteger('RowType', 3);
      mRowBO.SetFieldValueAsString('Store_ID', AStore_ID);
      mRowBO.SetFieldValueAsString('StoreCard_ID', mStoreCard_ID);
      mRowBO.SetFieldValueAsString('Division_ID', '1100000101');
      mRowBO.SetFieldValueAsString('BusTransaction_ID', '1000000101');
      mRowBO.SetFieldValueAsFloat('Quantity', mQuantity);
     // mRowBO.SetFieldValueAsFloat('UnitPrice',0);
     // mrowbo.SetFieldValueAsFloat('TotalPRice',mprice);
    end;
  end;
end;

function scrStorecard_ID(AOS : TNxCustomObjectSpace; AOrderRow_ID : string) : string;
const
  cSQL = 'SELECT ID FROM Storecards where code=''%s'' and hidden=''N'' ';
var
  mList : TStringList;
begin
  mList := TStringList.create;
  try
    Result:='';
    AOS.SQLSelect(Format(cSQL, [AOrderRow_ID]), mList);
    if mList.Count > 0 then
      Result := mList.Strings[0]
  finally
    mList.Free;
  end;
end;






begin
end.