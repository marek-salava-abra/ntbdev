procedure CreateSubcards (OS: TNxCustomObjectSpace;
  var Success: Boolean; var LogInfoStr: String);

var
 mList, mStoreList, mUsedStoreList, mValidSToreList:TStringList;
 mssc:TNxCustomBusinessObject;
 i, j, k:integer;
begin
  mList:=TStringList.Create;
  mStoreList:=TStringList.create;
  os.SQLSelect('Select id from stores where hidden=''N'' ', mStoreList);
  os.SQLSelect('Select id from storecards where hidden=''N'' ', mList);
  for i:=0 to mList.count-1 do begin
      for k:=0 to mStoreList.count-1 do begin
        mUsedStoreList:=TStringList.create;
        os.SQLSelect(format('select id from storesubcards where storecard_id=''%s'' and store_id=''%s'' ',[mlist.Strings[i],mStoreList.Strings[k]]),mUsedStoreList);
        if mUsedStoreList.count=0 then begin
        mssc:=os.CreateObject(Class_StoreSubCard);
        mssc.new;
        mssc.prefill;
        mssc.SetFieldValueAsString('StoreCard_ID',mlist.strings[i]);
        mssc.SetFieldValueAsString('Store_ID',mStoreList.Strings[k]);
        mssc.save;
        mssc.free;


        end;
        mUsedStoreList.free;
      end;
  end;
  Success := True;
  LogInfoStr := '';
end;

begin
end.