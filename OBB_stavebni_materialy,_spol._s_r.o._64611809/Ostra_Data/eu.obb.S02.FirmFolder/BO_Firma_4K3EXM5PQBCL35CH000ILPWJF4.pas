Const
 cFolder='\\192.168.200.65\ABRA_DATA\firmy\';


procedure Validate_Hook(Self: TNxCustomBusinessObject; var AResult: Boolean);
begin
  if not(DirectoryExists(cFolder+self.GetFieldValueAsString('Name'))) then begin
  NxCreateDir(cFolder+self.GetFieldValueAsString('Name'));
  end;
end;

begin
end.

begin
end.