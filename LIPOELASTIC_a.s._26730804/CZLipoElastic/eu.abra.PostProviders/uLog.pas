var
  gLog: TNxCustomLog;

const
  Balikobot_LogName = 'BalikobotLog';

procedure WriteEvent(AMessage: String; ALogLevel: TNxLogLevel = logDebug);
begin
  if gLog <> nil then
    gLog.WriteEvent(ALogLevel, AMessage);
end;

procedure EnterSection(ASection: String; ALogLevel: TNxLogLevel = logDebug);
begin
  if gLog <> nil then
    gLog.EnterSection(ASection, ALogLevel);
end;

procedure LeaveSection(ASection: String; ALogLevel: TNxLogLevel = logDebug);
begin
  if gLog <> nil then
    gLog.LeaveSection(ASection, ALogLevel);
end;

procedure FreeLog;
begin
  gLog.Free;
  gLog := nil;
end;

begin
end.