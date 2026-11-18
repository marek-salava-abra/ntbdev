
{TypZak}

function TypZak(AReportHelper:TNxQRScriptHelper;Firm_ID:String):String;
var
 mBO:TNxCustomBusinessObject;
begin
  mBO:=AReportHelper.ObjectSpace.CreateObject(Class_Firm);
  mBO.Load(Firm_ID,nil);
  if mBO.GetFieldValueAsInteger('U_Typ_Zak')=0 then Result:='';
  if mBO.GetFieldValueAsInteger('U_Typ_Zak')=1 then Result:='Dealer';
  if mBO.GetFieldValueAsInteger('U_Typ_Zak')=2 then Result:='Importér';
  if mBO.GetFieldValueAsInteger('U_Typ_Zak')=3 then Result:='Koncový zákazník';
  if mBO.GetFieldValueAsInteger('U_Typ_Zak')=4 then Result:='OE';
  if mBO.GetFieldValueAsInteger('U_Typ_Zak')=5 then Result:='Pneuservis';
  mbo.free;
end;

function GetMachineTypes(AReportHelper:TNxQRScriptHelper;InputString:String):String;
var
 mList:TStringList;
 i:integer;
 mBO:TNxCustomBusinessObject;
 mString:string;
begin
 Result:='';
 mString:='';
 mList:=TStringList.create;
 mList.Delimiter:=Chr(59);
 mlist.DelimitedText:=InputString;
 for i:=0 to mlist.count-1 do begin
   mBO:=AReportHelper.ObjectSpace.CreateObject(Class_UserRollBusinessObject_X31UYKJK05G4T0RBSM0IAFOB5O);
   mBO.Load(mList.strings[i],nil);
   mString:=mString+'<MachineType><code>'+mbo.GetFieldValueAsString('Code')+'</code>'+#13#10+'<name>'+mbo.GetFieldValueAsString('Name')+'</name>'+#13#10+'</MachineType>';
   mbo.free;
 end;
 Result:=mString;
end;

begin
end.