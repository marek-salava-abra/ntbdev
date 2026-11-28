procedure NahraditStrednik (OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
var
 mList:TStringList;
 mBO:TNxCustomBusinessObject;
 i:integer;
begin
  mList:=TStringList.Create;
  OS.SQLSelect('Select id from storecards where name like '+QuotedStr('%;%')+' and hidden=''N'' ',mList);
  if mList.Count>0 then begin
    for i:=0 to mlist.count-1 do begin
      mBO:=OS.CreateObject(Class_StoreCard);
      mBO.load(mlist.strings[i],nil);
      mBO.SetFieldValueAsString('Name',NxSearchReplace(mbo.GetFieldValueAsString('Name'),';',' ',[srAll]));
      mbo.Save;
      mbo.free;
    end;
  end;
  Success := True;
  LogInfoStr := '';
end;

begin
end.