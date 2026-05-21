const
 cStore_ID = '~00000011Y';

procedure GenerateOV(OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
var
 mStoreCardList, mLogs:TStringList;
 i:integer;
 mIOBO, mIORowBO:TNxCustomBusinessObject;
 mRows:TNxCustomBusinessMonikerCollection;
 mActualQuantity, mLowLimit, mHighLimit,mQuantityFromRO, mQuantityFromIO, mQuantity:Extended;
 mCode, mName:string;
begin
  mStoreCardList:=TStringList.Create;
  mLogs:=TStringList.Create;
  mLogs.Add('__________________________________________________________');
  mLogs.Add(DateTimeToStr(Now)+' - start of generating issued order');
  //OS.SQLSelect('Select storecard_id from storesubcards where store_id='+QuotedStr(cStore_ID)+' and lowlimitquantity>0',mStoreCardList);
  OS.SQLSelect('Select storecard_id from storesubcards where store_id='+QuotedStr(cStore_ID),mStoreCardList);
  //mStoreCardList.add('~0000002HA');
  if mStoreCardList.count>0 then begin
      mLogs.Add(DateTimeToStr(Now)+' - Count of items '+IntToStr(mStoreCardList.count));
      mIOBO:=OS.CreateObject(Class_IssuedOrder);
      mIOBO.New;
      mIOBO.prefill;
      mIOBO.SetFieldValueAsString('DocQueue_ID','~000000304');
      mIOBO.SetFieldValueAsString('Firm_ID','~0000005LQ');
      mIOBO.SetFieldValueAsBoolean('WithPrices', True);
      mIOBO.SetFieldValueAsInteger('TradeType',2);
      mIOBO.SetFieldValueAsString('Country_ID','00000CZ000');
      mRows:=mIOBO.GetLoadedCollectionMonikerForFieldCode(mIOBO.GetFieldCode('Rows'));
      for i:=0 to mStoreCardList.Count-1 do begin
        mCode:=OS.SQLSelectFirstAsString('Select code from storecards where id='+QuotedStr(mStoreCardList.strings[i]),'');
        mName:=OS.SQLSelectFirstAsString('Select Name from storecards where id='+QuotedStr(mStoreCardList.strings[i]),'');
        mActualQuantity:=OS.SQLSelectFirstAsExtended('Select quantity from storesubcards where store_id='+QuotedStr(cStore_ID)+'and storecard_id='+QuotedStr(mStoreCardList.Strings[i]),0);
        mLowLimit:=OS.SQLSelectFirstAsExtended('Select lowlimitquantity from storesubcards where store_id='+QuotedStr(cStore_ID)+'and storecard_id='+QuotedStr(mStoreCardList.Strings[i]),0);
        mHighLimit:=OS.SQLSelectFirstAsExtended('Select highlimitquantity from storesubcards where store_id='+QuotedStr(cStore_ID)+'and storecard_id='+QuotedStr(mStoreCardList.Strings[i]),0);
        mQuantityFromIO:=OS.SQLSelectFirstAsExtended('Select sum(io2.quantity-io2.deliveredquantity) from issuedorders io '+
                                                     'left join issuedorders2 io2 on io.id=io2.parent_id where io.closed=''N'' and io.confirmed=''A''  and io2.store_id='+
                                                     QuotedStr(cStore_ID)+' and io2.storecard_id='+QuotedStr(mStoreCardList.Strings[i]),0);
        mQuantityFromRO:=OS.SQLSelectFirstAsExtended('Select sum(ro2.quantity-ro2.deliveredquantity) from receivedorders ro '+
                                                     'left join receivedorders2 ro2 on ro.id=ro2.parent_id where ro.closed=''N'' and ro.confirmed=''A'' ' +
                                                     'and ro.docqueue_id in (''~000000002'',''~000000003'') and ro2.store_id='+QuotedStr(cStore_ID)+
                                                     ' and ro2.storecard_id='+QuotedStr(mStoreCardList.Strings[i]),0);
        mQuantity:=0;
        if not((mActualQuantity+mQuantityFromIO-mQuantityFromRO)>mLowLimit) then
         mQuantity:=mHighLimit-(mActualQuantity+mQuantityFromIO-mQuantityFromRO);
        if mQuantity>0 then begin
          mIORowBO:=mRows.AddNewObject;
          mIORowBO.Prefill;
          mIORowBO.SetFieldValueAsInteger('RowType',3);
          mIORowBO.SetFieldValueAsString('Store_ID',cStore_ID);
          mIORowBO.SetFieldValueAsString('StoreCard_ID',mStoreCardList.Strings[i]);
          mIORowBO.SetFieldValueAsFloat('Quantity',mQuantity);
          mIORowBO.SetFieldValueAsString('Division_ID','1000000101');
          mLogs.add(mcode+';'+mName+';'+FloatToStr(mActualQuantity)+';'+FloatToStr(mLowLimit)+';'+FloatToStr(mHighLimit)+';'+FloatToStr(mQuantityFromIO)+';'+FloatToStr(mQuantityFromRO));
        end;

      end;
      if mRows.Count>0 then begin
       mIOBO.save;
       mLogs.Add(DateTimeToStr(Now)+' - Created order '+mIOBO.DisplayName);
      end;
      mIOBO.free;

  end;
  mLogs.Add(DateTimeToStr(Now)+' - end of generating issued order');
  mLogs.Add('__________________________________________________________');
  Success := True;
  LogInfoStr := ''+#13#10+mLogs.text;
end;

begin
end.