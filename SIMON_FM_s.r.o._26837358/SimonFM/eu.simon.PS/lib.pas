procedure CheckOrders (OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
var
 mList:TStringList;
 mBO:TNxCustomBusinessObject;
 i:Integer;
begin
  mList:=TStringList.Create;
  os.SQLSelect('Select id from receivedorders where closed=''N'' and pmstate_id in (''2010000101'',''2030000101'',''1010000101'') and docqueue_id=''1W10000101'' and not(transportationtype_id=''2250000101'') order by createdat$date',mList);
  if mlist.Count>0 then begin
     for i:=0 to mlist.count-1 do begin
       mBO:=OS.CreateObject(Class_ReceivedOrder);
       mBO.Load(mlist.strings[i],nil);
       mBO.Save;
       mBO.Free;

     end;
  end;
  Success := True;
  LogInfoStr := ''+inttostr(i);
end;

procedure CheckDL30 (OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
var
 mList:TStringList;
 mBO:TNxCustomBusinessObject;
 i:Integer;
begin
  mList:=TStringList.Create;
  os.SQLSelect('Select id from storedocuments where pmstate_id='+Quotedstr('2000000001')+' and (docqueue_id='+Quotedstr('2M00000101')+' or docqueue_id='+QuotedStr('5R00000101')+') and docdate$date>45292',mList);
  if mlist.Count>0 then begin
     for i:=0 to mlist.count-1 do begin
       mBO:=OS.CreateObject(Class_BillOfDelivery);
       mBO.Load(mlist.strings[i],nil);
       mBO.Save;
       mBO.Free;
     end;
  end;
  Success := True;
  LogInfoStr := ''+inttostr(i);
end;


begin
end.