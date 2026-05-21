uses '.lib';

{
Vyvolává se po uložení vlastních dat objektu do databáze.
}
procedure AfterSave_Hook(Self: TNxCustomBusinessObject);
var
  mLog: string;
begin
  mLog:= '';
  if (osNew in Self.State)
    and (not(Self.GetFieldValueAsString('TransportationType_ID') = cTRANSPORTATIONTYPE_ID_ABHOLUNG))
    and (Self.GetFieldValueAsBoolean('X_SendcloudAutomatic')) then
  begin
    CreatePDMIssuedDoc(Self, mLog);
    if (not(NxIsBlank(mLog))) and (CFxNxRuntime.NxGetEnvironmentType = reRuntimeExe) then
      NxShowSimpleMessage(mLog, nil);
  end;
end;

begin
end.