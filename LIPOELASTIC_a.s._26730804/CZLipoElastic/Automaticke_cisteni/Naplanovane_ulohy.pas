


procedure Delete_Email (OS: TNxCustomObjectSpace;
  var Success: Boolean; var LogInfoStr: String);
var
mr:tstringlist;
mbo:TNxCustomBusinessObject;
i:integer;
begin
  Success := True;
  LogInfoStr := '';
  mr:=tstringlist.create;
  mbo:=os.CreateObject('5C1HWDQDR3J4NAAYZRO5PWHLWK');
  try

       os.Sqlselect('Select id from EmailsSent where A.SentDate$DATE>200 AND SentDate$DATE <' + NxFloatToIBStr(Date-90) ,mr);
       if mr.count>0 then begin
           for i:=0 to mr.count-1 do begin
               mbo.Load(mr.Strings[i],null);
               mbo.Delete;
           end;
       end;





  finally
      mbo.free;
      mr.free;
  end;


end;

begin
end.