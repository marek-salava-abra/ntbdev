
{GetType}

function GetType(AReportHelper:TNxQRScriptHelper;U_RF_Found_ID:String):Integer;
var
 mBO:TNxCustomBusinessObject;
begin
  Result:=0;
  if not(NxIsEmptyOID(U_RF_Found_ID)) then begin
    mBO:=AReportHelper.ObjectSpace.CreateObject('2AWXCEP3JINOPHKXQYEIB53HYS');
    mBO.Load(U_RF_Found_ID,nil);
    Result:=mbo.GetFieldValueAsInteger('U_RetFundType');
    mbo.free;
  end;
end;

begin
end.