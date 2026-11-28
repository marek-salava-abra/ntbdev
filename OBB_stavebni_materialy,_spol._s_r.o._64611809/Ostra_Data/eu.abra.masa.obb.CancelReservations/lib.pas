procedure CR(OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
var
 mList:TStringList;
 i:integer;
 mBO:TNxCustomBusinessObject;
begin
  mList:=TStringList.create;
  OS.SQLSelect('select r.id from receivedorders ro left join receivedorders2 ro2 on ro.id=ro2.parent_id left join reservations r on r.owner_id=ro2.id  '+
               'where ro.Closed=''A'' and r.dateto$date>'+NxFloatToIBStr(date)+' and r.reserved>r.supplied and r.reserved>0 ',mList);
  if mList.count>0 then begin
    for i:=0 to mlist.Count-1 do begin
      mBO:=OS.CreateObject(Class_Reservation);
      mbo.load(mList.strings[i],nil);
      mBO.SetFieldValueAsFloat('Reserved',mBO.GetFieldValueAsFloat('Supplied'));
      mBO.save;
      mBO.free;
    end;
  end;
  Success := True;
  LogInfoStr := 'Zneplatněno '+IntToStr(mlist.Count)+' rezervací';
end;

begin
end.