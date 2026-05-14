
const
  Allowed = ['A' .. 'Z', 'a' .. 'z', '0' .. '9', '_', ' ', 'ě', 'š', 'č', 'ř', 'ž', 'ý', 'á', 'í',
  'é', 'ó', 'ň', ',' , '.', 'é', '-', 'ť', '/', '+', 'ú', 'ů', 'Č', '&', '°',';','"', '(',')', 'Ř', 'Á','Š',
  'Ž', 'Ú', '=', 'Ý','*', '\', 'Í', ':', 'ď','„','%','ľ','ü','“', 'Ü', 'Ě', 'Á','–','!','?','É','Ň','®','´'];

function StringSearch(AReportHelper:TNxQRScriptHelper;Name:String):Boolean;


var
    i: Integer;
  begin
  //NxShowSimpleMessage('Jsem tu',nil);
    Result := Length(Name) > 0;
    i := 1;
    while Result and (i <= Length(Name)) do
    begin
      Result := Result AND (Name[i] in Allowed);
      //if not(name[i] in Allowed) then NxShowSimpleMessage(IntToStr(i)+' '+Name[i],nil);
      inc(i);
    end;
    if  Length(name) = 0 then Result := true;
  end;

function StringSearch2(AReportHelper:TNxQRScriptHelper;Name:String):String;


var
    i: Integer;
    r:Boolean;
  begin
  //NxShowSimpleMessage('Jsem tu',nil);
    Result:='';
    r := Length(Name) > 0;
    i := 1;
    while R and (i <= Length(Name)) do
    begin
      r:= r AND (Name[i] in Allowed);
      if not(name[i] in Allowed) then result:=(IntToStr(i)+' '+Name[i]+' '+IntToStr(Ord(Name[i])));
      inc(i);
    end;
    if  Length(name) = 0 then Result := '';
  end;


{FE}

function FE(AReportHelper:TNxQRScriptHelper;FileName:String):String;
begin
  Result:='';
  if FileExists(FileName) then Result:=FileName;
end;

begin
end.