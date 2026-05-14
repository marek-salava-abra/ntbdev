
{ChangeStr}

function ChangeStr(AReportHelper:TNxQRScriptHelper;Name:String):String;
var
 mName:string;
begin
  mName:=NxRemoveDiacritics(Name);
  mName:=NxSearchReplace(mName,' ','-',[srAll]);
  mName:=NxSearchReplace(mName,'/','-',[srAll]);
  mName:=NxSearchReplace(mName,'"','',[srAll]);
  mName:=NxSearchReplace(mName,',','',[srAll]);

  Result:=mName;
end;

begin
end.