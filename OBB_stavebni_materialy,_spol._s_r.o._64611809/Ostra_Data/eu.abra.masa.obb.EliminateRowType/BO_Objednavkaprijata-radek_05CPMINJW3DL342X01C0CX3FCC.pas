{
Umožňuje ovlivnit validaci.
}
procedure Validate_Hook(Self: TNxCustomBusinessObject; var AResult: Boolean);
begin
  if CFxNxRuntime.NxGetEnvironmentType=reRuntimeExe then begin
    if not(self.GetFieldValueAsString('Parent_ID.Firm_ID.OrgIdentNumber')='09698507') then begin
      if self.GetFieldValueAsInteger('RowType') in [0,1,2] then begin
       self.AddValidateError(self.GetFieldCode('RowType'),'Použití neskladového řádku není povoleno.Opravte textový řádek za skladový (typ3)');
       AResult:=False;
      end;
    end;
  end;
end;

begin
end.