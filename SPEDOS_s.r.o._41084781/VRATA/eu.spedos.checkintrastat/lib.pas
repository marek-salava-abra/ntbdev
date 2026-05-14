procedure  CheckIntrastatInvoices(OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
var
 mList:TStringList;
 mInvoiceBO:TNxCustomBusinessObject;
 i:integer;
 mMessage:string;
begin
  mList:=TStringList.Create;
  mMessage:='';
  os.SQLSelect(format('Select id from issuedinvoices where docdate$date=%s and tradetype=2 ',[IntToStr(Trunc(Date-7))]),mList);
  if mList.count>0 then begin
    try
     for i:=0 to mList.Count-1 do begin
       mInvoiceBO:=OS.CreateObject(Class_IssuedInvoice);
       mInvoiceBO.Load(mList.Strings[i],nil);
       mInvoiceBO.Invalidate;
       mInvoiceBO.Save;
       mMessage:=mMessage+#13#10+'Přepočítal jsem fakturu '+mInvoiceBO.DisplayName;
       mInvoiceBO.free;
     end;
    Except
      mMessage:=mMessage+#13#10+ExceptionMessage;
    end;
  end;
  Success := True;
  LogInfoStr := 'Přepočet proběhl u '+IntToStr(mList.count)+' faktur.'+mMessage;
end;

begin
end.