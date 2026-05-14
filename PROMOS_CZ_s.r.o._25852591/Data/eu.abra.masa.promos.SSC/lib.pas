procedure CreateStoreSubCard(OS: TNxCustomObjectSpace;  var Success: Boolean; var LogInfoStr: String);
var
 mList:TStringList;
 mBO:TNxCustomBusinessObject;
 i:integer;
begin
  mList:=TStringList.Create;
  OS.SqlSelect('Select id from storecards where hidden=''N'' and not(id in (select storecard_id from storesubcards where store_id=''1000000101''))',mList);
  if mlist.count>0 then begin
    for i:=0 to mlist.count-1 do begin
      try
       mBO:=OS.CreateObject(Class_StoreSubCard);
       mBO.new;
       mbo.prefill;
       mbo.SetFieldValueAsString('Store_ID','1000000101');
       mbo.SetFieldValueAsString('StoreCard_ID',mlist.strings[i]);
       mbo.save;
       mbo.free;
      except

      end;
    end;
  end;
  Success := True;
  LogInfoStr := 'Založeno '+IntToStr(mlist.Count);
end;

begin
end.