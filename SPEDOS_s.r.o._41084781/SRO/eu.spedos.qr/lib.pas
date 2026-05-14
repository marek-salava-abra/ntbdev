
{VarSymbo}

function VarSymbol(AReportHelper:TNxQRScriptHelper;DQCode:String;OrdNumber:Integer;PCode:String;DocumentType:String):String;
var
 mList:TStringList;
 mBO:TNxCustomBusinessObject;
begin
  Result:='';
  mList:=TStringList.create;
  if DocumentType='04' then begin
   AReportHelper.ObjectSpace.SQLSelect(format('Select a.id from receivedinvoices a left join periods p on p.id=a.period_id left join docqueues dq on dq.id=a.docqueue_id where dq.code=''%s'' and a.ordnumber=%s and p.code=''%s'' ',[DQCode,IntToStr(OrdNumber),PCode]),mList);
   if mList.count>0 then begin
     mBO:=AReportHelper.ObjectSpace.CreateObject(Class_ReceivedInvoice);
     mBO.Load(mlist.strings[0],nil);
     Result:=mbo.GetFieldValueAsString('VarSymbol');
     mbo.free;
   end;
  end;
  if DocumentType='03' then begin
   AReportHelper.ObjectSpace.SQLSelect(format('Select a.id from issuedinvoices a left join periods p on p.id=a.period_id left join docqueues dq on dq.id=a.docqueue_id where dq.code=''%s'' and a.ordnumber=%s and p.code=''%s'' ',[DQCode,IntToStr(OrdNumber),PCode]),mList);
   if mList.count>0 then begin
     mBO:=AReportHelper.ObjectSpace.CreateObject(Class_IssuedInvoice);
     mBO.Load(mlist.strings[0],nil);
     Result:=mbo.GetFieldValueAsString('VarSymbol');
     mbo.free;
   end;
  end;
  mList.free;
end;

begin
end.