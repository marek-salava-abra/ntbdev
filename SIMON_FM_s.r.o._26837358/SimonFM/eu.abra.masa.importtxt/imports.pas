







procedure Import_AddRows(ARows : TNxCustomBusinessMonikerCollection; AList : TStringList; ADivision_ID : string; AStore_ID : string);
var
  i : Integer;
  mRowBO : TNxCustomBusinessObject;
  mRowTxt, mStoreCard_ID, mStoreCard_Code : string;
  mQuantity, mprice : double;
begin
  for i := 0 to AList.Count - 1 do begin
    mRowTxt := Alist.strings[i];
    mStoreCard_ID:= NxToken(mRowTxt, ';');
    mQuantity := 0;
    mQuantity := StrToFloat(NxToken(mRowTxt, ';'));
    //mStoreCard_ID:=scrStorecard_ID(arows.ObjectSpace, mstorecard_code);
    if (mQuantity > 0) and not(NxIsEmptyOID(mStoreCard_ID))then begin
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






begin
end.