procedure  DeleteRecords(OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
var
 mList:TStringList;
 i:integer;
 mBO:TNxCustomBusinessObject;
begin
  mList:=TStringList.Create;
  OS.SQLSelect('select id from UNRELIABLEFIRMLOGS where logdate$date<'+NxFloatToIBStr(Date-100),mList);
  if mlist.Count>0 then begin
    for i:=0 to mlist.count-1 do begin
      mBO:=OS.CreateObject(Class_UnreliableFirmLog);
      mBO.load(mList.strings[i],nil);
      mbo.Delete;
    end;
  end;
  Success := True;
  LogInfoStr := 'Smazáno '+IntToStr(mlist.Count);
end;

begin
end.