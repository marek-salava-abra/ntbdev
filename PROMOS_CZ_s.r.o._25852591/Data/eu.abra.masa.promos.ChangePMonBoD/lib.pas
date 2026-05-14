procedure ChangeState(OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
var
 mList:TStringList;
 mBO:TNxCustomBusinessObject;
 i:integer;
begin
  mList:=TStringList.Create;
  OS.SQLSelect('Select id from storedocuments where docdate$Date>='+NxFloatToIBStr(date-90)+' and documenttype='+QuotedStr('21')+' and pmstate_id='+QuotedStr('SDDEF00000'),mList);
  if mlist.count>0 then begin
    for i:=0 to mlist.count-1 do begin
      mBO:=OS.CreateObject(Class_BillOfDelivery);
      mBO.Load(mList.Strings[i],nil);
      if mBO.GetFieldValueAsString('DocQueue_ID.Code')='DL' then begin
        if mbo.GetFieldValueAsString('TransportationType_ID')='00000O1000' then  mbo.PMChangeState('3040000101');//osobní
        if mbo.GetFieldValueAsString('TransportationType_ID')='00000P1000' then  mbo.PMChangeState('5040000101');//speciálně
        if mbo.GetFieldValueAsString('TransportationType_ID')='2000000101' then  mbo.PMChangeState('4040000101');//přepravcem
        if mbo.GetFieldValueAsString('TransportationType_ID')='00000V1000' then  mbo.PMChangeState('2040000101');//dodavatelem
      end;
      mbo.free;
    end;
  end;
  Success := True;
  LogInfoStr := 'Počet DL '+IntToStr(mlist.Count);
end;

begin
end.