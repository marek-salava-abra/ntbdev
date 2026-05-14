procedure CheckInvoices (OS: TNxCustomObjectSpace;  var Success: Boolean; var LogInfoStr: String);
var
 mList:tstringlist;
 i:integer;
 mBO:TNxCustomBusinessObject;
begin
  mList:=TStringList.Create;
  os.SQLSelect(format('Select ii.id from issuedinvoices ii where ii.tradetype=2 and (ii.localamountwithoutvat-(select sum(b.LocalIntrastatAmount) from issuedinvoices2 b where b.parent_id=ii.id))>20 and ii.createdat$date>=%s ',[IntToStr(trunc(date))]),mList);
  if mlist.count>0 then begin
    for i:=0 to mlist.count-1 do begin
      mbo:=os.CreateObject(Class_IssuedInvoice);
      mbo.load(mlist.strings[i],nil);
      mbo.Invalidate;
      mbo.save;
      mbo.free;

    end;
  end;
  Success := True;
  LogInfoStr := '';
end;

begin
end.