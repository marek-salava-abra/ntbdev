uses 'eu.cemat.mail.mail';

procedure SendEmail (OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
var
 mList:TstringList;
 mBO:TNxCustomBusinessObject;
 i:Integer;
 mResult:string;

begin
  mResult:='';
  mList:=TStringList.create;
  os.SQLSelect('select id from receivedorders where X_date_of_service='+IntToStr(Trunc(Date)),mList);
  for i:=0 to mlist.Count-1 do begin
    mbo:= os.CreateObject(Class_ReceivedOrder);
    mbo.load(mList.strings[i],nil);
    mResult:=mResult+#13#10+mBO.DisplayName+'  email 1: '+mbo.GetFieldValueAsString('CreatedBy_ID.Address_ID.Email')+'  email 2: '+mbo.GetFieldValueAsString('U_servis_email');
    SendInternalMail(OS,mbo.GetFieldValueAsString('CreatedBy_ID.Address_ID.Email'),'','',
        'Nový servis ',mbo.DisplayName+' '+mbo.GetFieldValueAsString('U_ServiceDescription'),'', mbo.GetFieldValueAsString('Firm_ID'),
                   '1000000101','');
     SendInternalMail(OS,mbo.GetFieldValueAsString('U_servis_email'),'','',
        'Nový servis ',mbo.DisplayName+' '+mbo.GetFieldValueAsString('U_ServiceDescription'),'', mbo.GetFieldValueAsString('Firm_ID'),
                   '1000000101','');
    mbo.free;


  end;
  Success := True;
  LogInfoStr := 'Seznam obsahoval '+IntToStr(mlist.Count)+' objednávek, podrobnosti níže. '+mResult;
end;

begin
end.