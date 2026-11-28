
{
Vyvolává se po uložení vlastních dat objektu do databáze.
}
procedure AfterSave_Hook(Self: TNxCustomBusinessObject);
begin
  if (CFxNxRuntime.NxGetEnvironmentType=reRuntimeExe) and not(self.GetFieldValueAsBoolean('U_MassCloned')) then begin
    if osNew in self.State then NxShowSimpleMessage('Byla založena karta '+Self.DisplayName+', je nutné občerstvit seznam.',nil);
  end;
end;

begin
end.