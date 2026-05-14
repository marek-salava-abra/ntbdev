{
Umožňuje ovlivnit validaci.
}
procedure Validate_Hook(Self: TNxCustomBusinessObject; var AResult: Boolean);
begin
  if (CFxNxRuntime.NxGetEnvironmentType=reRuntimeExe) and (self.GetFieldValueAsString('Parent_ID.DocQueue_ID')='7RQ0000101') then begin
     if self.GetFieldValueAsInteger('RowType')=3 then begin
       if not(self.GetFieldValueAsString('Store_ID')='4P00000101') then begin
         AResult:=false;
         self.AddValidateError(self.GetFieldCode('Store_ID'),'Sklad není VO.');
       end;
     end;
  end;
end;

begin
end.