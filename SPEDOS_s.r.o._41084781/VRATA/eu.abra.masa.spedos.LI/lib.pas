procedure LastIncome (OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
var
 mList:TStringList;
 i:integer;
 mStoreSubCardBO:TNxCustomBusinessObject;
 mMessage:string;
begin
  mList:=TStringList.create;
  OS.SQLSelect('Select id from storesubcards',mList);
  for i:=0 to mList.count-1 do begin
   try
    mStoreSubCardBO:=os.CreateObject(Class_StoreSubCard);
    mStoreSubCardBO.load(mList.Strings[i],nil);
    mStoreSubCardBO.SetFieldValueAsDateTime('X_LastIncome', os.SQLSelectFirstAsExtended('Select max(sd.docdate$date) from storedocuments2 sd2 join storedocuments sd on sd.id=sd2.parent_id '+
                                            'where sd2.storecard_id='+Quotedstr(mStoreSubCardBO.GetFieldValueAsString('StoreCard_id'))+' and sd2.store_id='+QuotedStr(mStoreSubCardBO.GetFieldValueAsString('Store_ID'))+
                                            ' and sd2.flowsign=1',0));
    mStoreSubCardBO.save;
    mStoreSubCardBO.free;
   except
    mMessage:=mMessage+#13#10+ExceptionMessage;
   end;
  end;
  mList.Clear;
  OS.SQLSelect('Select id from storecards',mList);
  for i:=0 to mList.count-1 do begin
   try
    mStoreSubCardBO:=os.CreateObject(Class_StoreCard);
    mStoreSubCardBO.load(mList.Strings[i],nil);
    mStoreSubCardBO.SetFieldValueAsDateTime('U_LastIncome', os.SQLSelectFirstAsExtended('Select max(X_LastIncome) from storesubcards where storecard_id='+Quotedstr(mStoreSubCardBO.OID),0));
    mStoreSubCardBO.save;
    mStoreSubCardBO.free;
   except
    mMessage:=mMessage+#13#10+ExceptionMessage;
   end;
  end;
  Success := True;
  LogInfoStr := '';
end;

begin
end.