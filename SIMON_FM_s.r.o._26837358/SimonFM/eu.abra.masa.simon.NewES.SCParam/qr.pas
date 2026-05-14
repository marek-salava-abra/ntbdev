
{Names}

function Names(AReportHelper:TNxQRScriptHelper;mID:String):String;
var
 mList:tstringlist;
 i:integer;
 mResult:string;
 mBO:TNxCustomBusinessObject;
begin
  Result:='';
  mResult:='';
  mList:=TStringList.Create;
  AReportHelper.ObjectSpace.SQLSelect('Select id from defrolldata where clsid='+Quotedstr('2TIIQXNXIXK4B5CZUIZ20K2W10')+' and X_rel_def='+quotedstr('01')+' and X_Value_ID='+QuotedStr(mID)+' order by X_posindex',mList);
  if mList.count>0 then begin
    for i:=0 to mList.count-1 do begin
       mBO:=AReportHelper.ObjectSpace.CreateObject('2TIIQXNXIXK4B5CZUIZ20K2W10');
       mBO.Load(mlist.strings[i],nil);
       if i=0 then mResult:=mbo.GetFieldValueAsString('X_Parameter_ID.Name') else mResult:=mResult+'|'+mbo.GetFieldValueAsString('X_Parameter_ID.Name');
       mbo.free;
    end;
  end;
  Result:=mResult;
end;

begin
end.