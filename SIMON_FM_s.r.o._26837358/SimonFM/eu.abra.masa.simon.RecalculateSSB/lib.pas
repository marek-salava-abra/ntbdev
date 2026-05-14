procedure RSSB(OS: TNxCustomObjectSpace;  var Success: Boolean; var LogInfoStr: String);
var
 mList:TStringList;
 i:integer;
 mBO:TNxCustomBusinessObject;
begin
  mList:=TStringList.Create;
  OS.SQLSelect('Select id from storesubcards where store_id=''1B00000101'' and quantity>0 ',mList);
  for i:=0 to mList.count-1 do begin
     //try
       mBO:=OS.CreateObject(Class_StoreSubCard);
       mBO.load(mlist.Strings[i],nil);
       mBO.SetFieldValueAsFloat('X_Sale90',OS.SQLSelectFirstAsExtended('select sum(sd2.quantity) from storedocuments sd left join storedocuments2 sd2 on sd.id=sd2.parent_id where sd.documenttype='
                                                +quotedstr('21')+' and sd2.storecard_id='+quotedstr(mBO.GetFieldValueAsString('StoreCard_ID'))+' and sd.docdate$date>'+IntToStr(Trunc(Date-90)),0));
       mBO.SetFieldValueAsFloat('X_Count',OS.SQLSelectFirstAsExtended('select count(sd2.id) from storedocuments sd left join storedocuments2 sd2 on sd.id=sd2.parent_id where sd.documenttype='
                                                +quotedstr('21')+' and sd2.storecard_id='+quotedstr(mBO.GetFieldValueAsString('StoreCard_ID'))+' and sd.docdate$date>'+IntToStr(Trunc(Date-90)),0));
       mbo.Save;
     //Except

     //end;
  end;
  Success := True;
  LogInfoStr := '';
end;

begin
end.