
{GetFirmName}

function GetFirmName(AReportHelper:TNxQRScriptHelper;Row_ID:String):String;
var
 mBO:TNxCustomBusinessObject;
begin
  Result:='';
  if not(NxIsEmptyOID(Row_ID)) then begin
    mBO:=AReportHelper.ObjectSpace.CreateObject(Class_BillOfDeliveryRow);
    mbo.Load(Row_ID,nil);
    Result:=mbo.GetFieldValueAsString('Parent_ID.Firm_ID.Name');
    mbo.free;
  end;
end;

function GetQuantity(AReportHelper:TNxQRScriptHelper;Row_ID:String):Extended;
var
 mBO:TNxCustomBusinessObject;
begin
  Result:=0;
  if not(NxIsEmptyOID(Row_ID)) then begin
    mBO:=AReportHelper.ObjectSpace.CreateObject(Class_BillOfDeliveryRow);
    mbo.Load(Row_ID,nil);
    Result:=mbo.GetFieldValueAsFloat('Quantity');
    mbo.free;
  end;
end;


begin
end.