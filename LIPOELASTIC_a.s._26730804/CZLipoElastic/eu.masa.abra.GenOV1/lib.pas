procedure GenerateOrders (OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
var
 mList, mSaveList:TStringList;
 i, mErrorCount:integer;
 mBO, mRowBO, mStoreCardBO:TNxCustomBusinessObject;
 mRows:TNxCustomBusinessMonikerCollection;
 mSupplierBO:TNxCustomBusinessObject;
 mQuantityOV, mQuantityOP, mStoreQuantity, mDavka, mLowLimitQuantity, mFinalQuantity, mOrdQuantity:Extended;
 mHeader_ID, mMessage, mTempDate, mOrder_ID:string;
 ss, ss2: TStringList;
begin
  // řada dokladu OV1, sklad 999, rozpad dle dodavatelů, středisko VV, datum dodání +14 od created$date
  // firma z hlavního dodavatele, projekt z hlavního dodavatele, confirmed=true
  mList:=TStringList.Create;
  mSaveList:=TStringList.Create;
  mTempDate:=FormatDateTime('YYYYMMDDhhmmss',Now);
  mMessage:='Kód;Název;OV;OP;Skladem;Spodní limit;Dávka;Finální množství;Objednáno';
  OS.SQLSelect('Select distinct ssc.StoreCard_id from storesubcards ssc left join StoreCardMenuItemLinks sm on sm.StoreCard_id=ssc.storecard_id where ssc.Store_ID='+quotedstr('1120000101')+' and ssc.lowlimitquantity>0 and sm.storemenuitem_id='+Quotedstr('1A30000101'), mList);
  mErrorCount:=0;
  for i:=0 to mlist.count-1 do begin
      mStoreCardBO:=OS.CreateObject(Class_StoreCard);
      mStoreCardBO.load(mlist.Strings[i],nil);
      mDavka:=mStoreCardBO.GetFieldValueAsFloat('X_davka_sici');
      mLowLimitQuantity:=OS.SQLSelectFirstAsExtended('Select LowLimitQuantity from storesubcards where StoreCard_ID = '+QuotedStr(mStoreCardBO.oid)+' and Store_ID = '+QuotedStr('1120000101'),0);
      mStoreQuantity:=OS.SQLSelectFirstAsExtended('Select sum(quantity) from storesubcards where StoreCard_ID = '+QuotedStr(mStoreCardBO.oid)+' and Store_ID IN ('+QuotedStr('2J10000101')+','+QuotedStr('1120000101')+')',0);
      mQuantityOP:=OS.SQLSelectFirstAsExtended('SELECT sum(a.quantity-a.deliveredquantity) FROM ReceivedOrders2 A '+
                                               'JOIN ReceivedOrders RO ON RO.ID = A.Parent_ID WHERE A.RowType=3 '+
                                               'AND ((RO.DocQueue_ID IN ('+Quotedstr('2S00000101')+','+Quotedstr('1S00000101')+','+Quotedstr('2O20000101')+','+Quotedstr('5B10000101')+') ) '+
                                               ' AND (A.StoreCard_ID = '+QuotedStr(mStoreCardBO.oid)+' ) AND '+
                                               '(/* musime bohuzel doplnit podminku za neskladove radky, aby se  do vystupu dostaly ciste textove doklady */ '+
                                               '((A.RowType=3 and A.Store_ID = '+QuotedStr('1120000101')+') or (A.RowType<>3)) ) '+
                                               'AND (RO.confirmed = '+Quotedstr('A')+' ) AND (RO.closed = '+Quotedstr('N')+' )  AND (('+Quotedstr('N')+' = '+Quotedstr('A')+') OR (('+Quotedstr('N')+' = '+Quotedstr('N')+') AND (A.Revided_ID IS NULL)) ))',0);
      mQuantityOV:=OS.SQLSelectFirstAsExtended('SELECT sum(a.quantity-a.deliveredquantity) FROM IssuedOrders2 A '+
                                                 'JOIN issuedorders IO ON IO.id = A.parent_id WHERE  A.RowType=3 '+
                                                 'AND ((IO.DocQueue_ID IN ('+Quotedstr('1540000101')+','+quotedstr('7B10000101')+','+Quotedstr('8B10000101')+')) '+
                                                 'AND (A.StoreCard_ID = '+QuotedStr(mStoreCardBO.oid)+' ) AND '+
                                                 '(/* musime bohuzel doplnit podminku za neskladove radky, aby se  do vystupu dostaly ciste textove doklady */ '+
                                                 '((A.RowType=3 and A.Store_ID = '+QuotedStr('2J10000101')+') or (A.RowType<>3)) ) AND (IO.confirmed = '+Quotedstr('A')+' ) AND '+
                                                 '(IO.closed = '+Quotedstr('N')+' ) AND (('+Quotedstr('N')+' = '+Quotedstr('A')+') OR (('+Quotedstr('N')+' = '+Quotedstr('N')+') AND (A.Revided_ID IS NULL)) ))',0);

      mFinalQuantity:=(mStoreQuantity-mQuantityOP+mQuantityOV)-mLowLimitQuantity;
      if mFinalQuantity<0 then begin
        mOrdQuantity:=mdavka*(Trunc(-mFinalQuantity/mDavka)+1);
        if mOrdQuantity=0 then mOrdQuantity:=-mFinalQuantity;
        mMessage:=mMessage+#13#10+
                mStoreCardBO.GetFieldValueAsString('Code')+';'+mStoreCardBO.GetFieldValueAsString('Name')+
                ';'+ FloatToStr(mQuantityOV)+';'+FloatToStr(mQuantityOP)+';'+FloatToStr(mStoreQuantity)+';'+FloatToStr(mLowLimitQuantity)+';'+FloatToStr(mDavka)+';'+FloatToStr(mFinalQuantity)+';'+FloatToStr(mOrdQuantity);
        mHeader_ID:=OS.SQLSelectFirstAsString('Select id from issuedorders where docqueue_id='+QuotedStr('1540000101')+' and firm_id='+QuotedStr(mStoreCardBO.GetFieldValueAsString('MainSupplier_ID.Firm_ID'))+' and docdate$date='+inttostr(trunc(date)),'');
        mBO:=OS.CreateObject(Class_IssuedOrder);
        if NxIsEmptyOID(mHeader_ID) then begin
          mBO.New;
          mBO.Prefill;
          mbo.SetFieldValueAsString('DocQueue_ID','1540000101');
          mBO.SetFieldValueAsString('Firm_ID',mStoreCardBO.GetFieldValueAsString('MainSupplier_ID.Firm_ID'));
          mBO.SetFieldValueAsBoolean('Confirmed',true);
        end else begin
          mBO.Load(mHeader_ID,nil);
        end;
        mRows:=mBO.GetLoadedCollectionMonikerForFieldCode(mbo.getfieldcode('Rows'));
         mRowBO:=mRows.AddNewObject;
         mRowBO.Prefill;
         mRowBO.SetFieldValueAsInteger('RowType',3);
         mRowBO.SetFieldValueAsString('Store_ID','2J10000101');
         mRowBO.SetFieldValueAsString('StoreCard_ID',mStoreCardBO.OID);
         mRowBO.SetFieldValueAsFloat('Quantity',mOrdQuantity);
         mRowBO.SetFieldValueAsString('Division_ID','6700000101');
         mRowBO.SetFieldValueAsString('BusTransaction_ID','1T00000101');
         mRowBO.SetFieldValueAsString('BusProject_ID', mBO.GetFieldValueAsString('Firm_ID.X_BusProject_ID'));
         if not(NxIsEmptyOID(mBO.GetFieldValueAsString('Firm_ID.X_BusProject_ID.Division_ID'))) then
          mRowBO.SetFieldValueAsString('Division_ID',mBO.GetFieldValueAsString('Firm_ID.X_BusProject_ID.Division_ID'));
         //mRowBO.SetFieldValueAsDateTime('DeliveryDate$Date',date+14);
        try
         mbo.save;
        except
         mMessage:=mMessage+';'+ExceptionMessage;
         mErrorCount:=mErrorCount+1;
        end;
        mOrder_ID:=mBO.OID;
        SortOrder(OS,mOrder_ID);
        mbo.free;
      end;
      mStoreCardBO.free;
  end;

  Success := True;
  mSaveList.Text:=mMessage;
  //mSaveList.SaveToFile('C:\AbraG3\GenOV\GenOV_'+FormatDateTime('YYY-MM-DD',now)+'.csv');
  LogInfoStr := 'Počet záznamů:'+IntToStr(mlist.count)+' počet chyb: '+IntToStr(mErrorCount)+#13#10+mMessage+#13#10+#13#10+'časová značka '+mTempDate;
end;

Procedure SortOrder(var AOS:TNxCustomObjectSpace; var aOrder_ID:string);
var
  mO: TNxHeaderBusinessObject;
  mORow: TNxRowBusinessObject;
  mOSC, mBO: TNxCustomBusinessObject;
  i, j, mPOSIndex: integer;
  ss, ss2, mBOList: TStringList;
  s, mSCName: String;
begin
  try
    ss := TStringList.Create;
    ss2 := TStringList.Create;
     mBO:=AOS.CreateObject(Class_IssuedOrder);
     mBO.Load(aOrder_ID,nil);
       mO := TNxHeaderBusinessObject(mBO);
        for i:=0 to mbo.GetLoadedCollectionMonikerForFieldCode(mbo.GetFieldCode('Rows')).Count-1 do begin
          mORow := TNxRowBusinessObject(mbo.GetLoadedCollectionMonikerForFieldCode(mbo.GetFieldCode('Rows')).BusinessObject[i]);
          mPOSIndex := mORow.GetFieldValueAsInteger('POSIndex');
          if NxIsEmptyOID(mORow.GetFieldValueAsString('StoreCard_ID')) then
            mSCName := '_' + IntToStr(mPOSIndex)
          else begin
            mOSC := mORow.GetMonikerForFieldCode(mORow.GetFieldCode('StoreCard_ID')).BusinessObject;
            mSCName := mOSC.GetFieldValueAsString('Name');
          end;
          ss.Values[mSCName + mORow.OID] := mORow.OID + IntToStr(mPOSIndex);
        end;
        ss.Sort;
        for i:=0 to ss.Count-1 do begin
          s := Copy(ss.ValueFromIndex(i), 1, 10);
          ss2.Values[s] := IntToStr(i+1);
        end;
        for i:=0 to mO.Rows.Count-1 do begin
          mORow := TNxRowBusinessObject(mbo.GetLoadedCollectionMonikerForFieldCode(mbo.GetFieldCode('Rows')).BusinessObject[i]);
          mORow.Position := StrToInt(ss2.Values[mORow.OID]);
        end;
        mBO.save;
  finally
    ss.Free;
    ss2.Free;
  end;
end;


begin
end.