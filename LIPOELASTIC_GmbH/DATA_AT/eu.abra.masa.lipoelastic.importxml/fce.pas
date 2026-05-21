function ElementExists(mXMLHead : TNxScriptingXMLWrapper; AName: string): Boolean;

begin
  try
    if mXMLHead.getElementAsString(AName)<>'' then Result:= True;
  except
    Result:= False;
  end;
end;

function mCompileDate(var mString:String):TDate;
var
 mYear, mMonth, mDay:string;
begin
 mYear:=NxTrapStrTrim(mString,'-');
 mMonth:=NxTrapStrTrim(mString,'-');
 mDay:=NxTrapStrTrim(mString,'-');
 Result:=StrToDate(mDay+'.'+mMonth+'.'+mYear);
end;

Function GetPeriodID(var aOS:TNxCustomObjectSpace;var aDate:Extended):string;
var
 mSQL:string;
begin
  Result:=aOS.SQLSelectFirstAsString('select id from periods where datefrom$date<='+IntToStr(trunc(adate))+' and dateto$date>'+IntToStr(trunc(adate)),'');
end;

begin
end.