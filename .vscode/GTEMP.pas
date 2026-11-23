procedure GenerateIIfromOPV(OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
var
 mList, mLogs:TStringList;
 mSQL: String;
 i:integer;

 //kopie do emailu marek.zizka a tvůrce
begin
  mList := TStringList.Create;
  mLogs := TStringList.Create;
  try
    OS.sqlselect(mSQL, mList);
    if mList.Count > 0 then begin

    end;
  finally
   Success := True;
   LogInfoStr := ''+nxcrlf+mlogs.Text;
  end; 
end;

begin
end.