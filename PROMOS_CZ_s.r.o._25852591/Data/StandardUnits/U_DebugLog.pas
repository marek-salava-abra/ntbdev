var
  DebugLog   : TStringList;
  DebugLog_ON: boolean;
  
////////////////////////////////////////////////////////////////////////////////
procedure DebugLog_Add(Log: string);
begin
  if(DebugLog_ON)then begin
    if(not assigned(DebugLog))then
      DebugLog := TStringList.Create;
      
    DebugLog.Add(Log);
  end;
end;
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
procedure DebugLog_SaveAndFree(aFile: string);
begin
  if(assigned(DebugLog))then begin
    DebugLog.SaveToFile(aFile);
    DebugLog.Free;
    DebugLog:= nil;
  end;
end;
////////////////////////////////////////////////////////////////////////////////


begin
  DebugLog_ON:= false; //implicitne vypnute logovani
end.