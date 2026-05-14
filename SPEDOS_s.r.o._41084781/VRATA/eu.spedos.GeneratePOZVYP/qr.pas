
{GetSize}

function GetSize(AReportHelper:TNxQRScriptHelper;JobOrder_ID:String):String;
Var
 mBO:TNxCustomBusinessObject;
begin
  Result:='';
  if not(NxIsEmptyOID(JobOrder_ID)) then begin
     mbo:=AReportHelper.ObjectSpace.CreateObject(Class_PLMJobOrder);
     mbo.load(JobOrder_ID,nil);
     result:=NxTokenR(mbo.GetFieldValueAsString('StoreCard_ID.Code'),' ')+' mm';
     mbo.free;

  end;
end;

function GetPozice(AReportHelper:TNxQRScriptHelper;JobOrder_ID:String):String;
Var
 mBO:TNxCustomBusinessObject;
begin
  Result:='';
  if not(NxIsEmptyOID(JobOrder_ID)) then begin
     mbo:=AReportHelper.ObjectSpace.CreateObject(Class_PLMJobOrder);
     mbo.load(JobOrder_ID,nil);
     result:=mbo.GetFieldValueAsString('X_pozice');
     mbo.free;

  end;
end;

begin
end.