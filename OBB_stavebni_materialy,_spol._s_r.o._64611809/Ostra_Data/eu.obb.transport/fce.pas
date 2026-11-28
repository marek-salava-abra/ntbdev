function GetProject_ID(AOS : TNxCustomObjectSpace; aCode : string) : String;
const
  cSQL = 'SELECT ID FROM BusProjects WHERE code=''%s'' and hidden=''N'' ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    AOS.SQLSelect(Format(cSQL, [aCode]), mList);
    if mList.Count > 0 then
      Result := (mList.Strings[0])
      else Result:=''
  finally
    mList.Free;
  end;
end;


begin
end.