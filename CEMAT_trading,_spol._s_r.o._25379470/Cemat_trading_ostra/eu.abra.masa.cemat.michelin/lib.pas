
{GetPID}
function GetWeek(AReportHelper:TNxQRScriptHelper;aDocDate:Extended):String;
begin
  Result:=IntToStr(WeekOfTheYear(aDocDate));
end;

function GetPID(AReportHelper:TNxQRScriptHelper;StoreCard_ID:String):String;
var
 mBO:TNxCustomBusinessObject;
begin
  Result:='';
  if not(NxIsEmptyOID(StoreCard_ID)) then begin
    mBO:=AReportHelper.ObjectSpace.CreateObject(Class_StoreCard);
    mBO.Load(StoreCard_ID,nil);
    Result:=mBO.GetFieldValueAsString('U_PID');
    if NxIsBlank(mBO.GetFieldValueAsString('U_PID')) then Result:=mBO.GetFieldValueAsString('U_CAI');
    mbo.free;
  end;
end;

function GetMT(AReportHelper:TNxQRScriptHelper;StoreCard_ID:String):String;
var
 mBO:TNxCustomBusinessObject;
begin
  Result:='';
  if not(NxIsEmptyOID(StoreCard_ID)) then begin
    mBO:=AReportHelper.ObjectSpace.CreateObject(Class_StoreCard);
    mBO.Load(StoreCard_ID,nil);
    Result:=mBO.GetFieldValueAsString('U_michelin_type');
    mbo.free;
  end;
end;

function GetWeight(AReportHelper:TNxQRScriptHelper;StoreCard_ID:String):Extended;
var
 mBO:TNxCustomBusinessObject;
 mUnits:TNxCustomBusinessMonikerCollection;
begin
  Result:=0;
  if not(NxIsEmptyOID(StoreCard_ID)) then begin
    mBO:=AReportHelper.ObjectSpace.CreateObject(Class_StoreCard);
    mBO.Load(StoreCard_ID,nil);
    mUnits:=mBO.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('StoreUnits'));
    Result:=mUnits.BusinessObject[0].GetFieldValueAsFloat('Weight');
    mbo.free;
  end;
end;


function GetMenu(AReportHelper:TNxQRScriptHelper;StoreCard_ID:String):String;
var
 mBO:TNxCustomBusinessObject;
begin
  Result:='';
  if not(NxIsEmptyOID(StoreCard_ID)) then begin
    mBO:=AReportHelper.ObjectSpace.CreateObject(Class_StoreCard);
    mBO.Load(StoreCard_ID,nil);
    Result:=mBO.GetFieldValueAsString('StoreMenuItem_ID.Text');
    mbo.free;
  end;
end;

function GetTypZak(AReportHelper:TNxQRScriptHelper;Firm_ID:String):String;
var
 mBO:TNxCustomBusinessObject;
begin
  Result:='';
  if not(NxIsEmptyOID(Firm_ID)) then begin
    mBO:=AReportHelper.ObjectSpace.CreateObject(Class_Firm);
    mBO.Load(Firm_ID,nil);
    if mBO.GetFieldValueAsInteger('U_Typ_Zak')=1 then Result:='Dealer';
    if mBO.GetFieldValueAsInteger('U_Typ_Zak')=2 then Result:='Importér';
    if mBO.GetFieldValueAsInteger('U_Typ_Zak')=3 then Result:='Koncový zákazník';
    if mBO.GetFieldValueAsInteger('U_Typ_Zak')=4 then Result:='OE';
    if mBO.GetFieldValueAsInteger('U_Typ_Zak')=5 then Result:='Pneuservis';
    mbo.free;
  end;
end;

function GetSCC(AReportHelper:TNxQRScriptHelper;StoreCard_ID:String):String;
var
 mBO:TNxCustomBusinessObject;
begin
  Result:='';
  if not(NxIsEmptyOID(StoreCard_ID)) then begin
    mBO:=AReportHelper.ObjectSpace.CreateObject(Class_StoreCard);
    mBO.Load(StoreCard_ID,nil);
    Result:=mBO.GetFieldValueAsString('StoreCardCategory_ID');
    mbo.free;
  end;
end;

begin
end.