procedure DeleteRecords(OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
var
 mBO:TNxCustomBusinessObject;
 i:integer;
 mList:TStringList;
begin
  mList:=TStringList.Create;
  OS.SQLSelect('Select id from UnreliableFirmLogs where LogDate$DATE<'+NxFloatToIBStr(Date-90), mList);
  if mlist.count>0 then begin
    for i:=0 to mlist.count-1 do begin
      mBO:=OS.CreateObject(Class_UnreliableFirmLog);
      mBO.Load(mlist.Strings[i],nil);
      mBO.Delete;
    end;
  end;
  Success := True;
  LogInfoStr := '';
end;

begin
end.