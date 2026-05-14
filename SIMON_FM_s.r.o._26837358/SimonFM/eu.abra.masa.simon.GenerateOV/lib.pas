procedure PozOV (OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
var
 mList:TStringList;
 i:integer;
 mLowLimit, mStoreQuantity, mOBMQuantity, mPozOVQuantity, mQuantity:Extended;
 mBO:TNxCustomBusinessObject;
 mMessage:string;
begin
  mList:=TStringList.Create;
  mMessage:='';
  os.SQLSelect('Select sc.id from storecards sc left join storesubcards ssb on ssb.storecard_id=sc.id where ssb.lowlimitquantity>0 and ssb.store_id='+Quotedstr('2D00000101')+' and sc.hidden='
               +QuotedStr('N')+' and (sc.code like '+QuotedStr('zk%')+' or sc.code like '+QuotedStr('ZK%')+')' ,mList);
  for i:=0 to mList.count-1 do begin
     mLowLimit:=OS.SQLSelectFirstAsExtended('Select lowlimitquantity from storesubcards where storecard_id='+QuotedStr(mList.strings[i])+' and store_id='+Quotedstr('2D00000101'),0);
     mStoreQuantity:=OS.SQLSelectFirstAsExtended('Select quantity from storesubcards where storecard_id='+QuotedStr(mList.strings[i])+' and store_id='+Quotedstr('2D00000101'),0);
     mPozOVQuantity:=OS.SQLSelectFirstAsExtended('Select Sum(Quantity) from ORDERSREQUESTS where storecard_id='+QuotedStr(mList.strings[i])+' and store_id='+Quotedstr('2D00000101'),0);
     mOBMQuantity:=OS.SQLSelectFirstAsExtended('Select Sum(io2.Quantity-io2.deliveredquantity) from issuedorders io left join issuedorders2 io2 on io2.parent_id=io.id where io.closed='+QuotedStr('N')+' and io.docqueue_id='+Quotedstr('1Z00000101')+' and io2.storecard_id='+QuotedStr(mList.strings[i])+' and io2.store_id='+Quotedstr('2D00000101'),0);
     mQuantity:=mLowLimit-mStoreQuantity-mOBMQuantity-mPozOVQuantity;
     if mQuantity>0 then begin
      Try
       mBO:=os.CreateObject(Class_OrdersGeneration);
       mBO.new;
       mbo.Prefill;
       mbo.SetFieldValueAsString('StoreCard_ID',mList.strings[i]);
       mBO.SetFieldValueAsString('Store_ID','2D00000101');
       mBO.SetFieldValueAsFloat('Quantity',mQuantity);
       mbo.SetFieldValueAsString('Firm_ID',mbo.GetFieldValueAsString('StoreCard_ID.MainSupplier_ID.Firm_ID'));
       mbo.Save;
       mbo.free;
      except
       mMessage:=mMessage+#13#10+' id karty '+mList.Strings[i]+#13#10+ExceptionMessage;
      end;
     end;
  end;
  Success := True;
  LogInfoStr := 'Počet záznamů '+IntToStr(mlist.Count)+mMessage;
end;

begin
end.