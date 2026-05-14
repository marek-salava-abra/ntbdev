{
Umožňuje ovlivnit validaci.
}
procedure Validate_Hook(Self: TNxCustomBusinessObject; var AResult: Boolean);
begin
  if (self.GetFieldValueAsString('X_ref_ID')<> self.OID) then begin
           self.SetFieldValueAsString('X_ref_ID',self.oid);
  end;
end;

begin
end.