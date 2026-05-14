procedure CheckMail (OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
var
 mList:TStringList;
 mBO:TNxCustomBusinessObject;
 i:integer;
 mMessage:string;
begin
  mMessage:='';
  mList:=TStringList.Create;
  OS.SQLSelect('SELECT A.ID FROM EmailsSent A WHERE A.DocDate$DATE >= '+NxFloatToIBStr(date-3)+' AND A.SentState=3 ', mList);
  if mList.count>0 then begin
    for i:=0 to mList.count-1 do begin
       mBO:=OS.CreateObject(Class_EmailSent);
       mBO.Load(mList.strings[i],nil);
       mBO.SetFieldValueAsInteger('SentState',1);
       mMessage:=mMessage+#13#10+mbo.DisplayName;
       mbo.save;
       mbo.free;
    end;
  end;
  Success := True;
  LogInfoStr := 'Počet mailů '+IntToStr(mlist.Count)+#13#10+mMessage;
end;

begin
end.