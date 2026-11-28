procedure  DULF(OS: TNxCustomObjectSpace;  var Success: Boolean; var LogInfoStr: String);
var
 mList:TStringList;
 mBO:TNxCustomBusinessObject;
 i:integer;
begin
  mList:=TStringList.Create;
  os.SQLSelect(format('select id from UnreliableFirmLogs where logdate$date<%s ',[IntToStr(Trunc(date-90))]),mList);
  if mlist.Count>0 then begin
    for i:=0 to mList.count-1 do begin
     mBO:=OS.CreateObject(Class_UnreliableFirmLog);
     mBO.Load(mlist.strings[i],nil);
     mbo.Delete;
    end;
  end;
  Success := True;
  LogInfoStr := 'Smazal jsem '+IntToStr(mlist.Count)+' záznamů';
end;

begin
end.