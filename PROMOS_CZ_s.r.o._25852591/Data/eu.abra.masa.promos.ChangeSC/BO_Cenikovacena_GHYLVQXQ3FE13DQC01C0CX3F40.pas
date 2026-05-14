{
Umožňuje ovlivnit validaci.
}
procedure Validate_Hook(Self: TNxCustomBusinessObject; var AResult: Boolean);
var
 mBO:TNxCustomBusinessObject;
begin
  if CFxNxRuntime.NxGetEnvironmentType=reRuntimeExe then begin
     mBO:=self.ObjectSpace.CreateObject(Class_StoreCard);
     mbo.load(self.GetFieldValueAsString('Parent_ID.StoreCard_ID'),nil);
     mbo.Invalidate;
     mbo.save;
     mbo.free;
  end;
end;

begin
end.