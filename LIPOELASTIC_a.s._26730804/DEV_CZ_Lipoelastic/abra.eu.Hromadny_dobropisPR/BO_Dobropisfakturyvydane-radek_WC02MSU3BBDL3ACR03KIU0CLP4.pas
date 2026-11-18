{
Vyvolává se při předvyplňování hodnot daného objektu.
}
procedure Prefill_Hook(Self: TNxCustomBusinessObject);
begin
  if self.GetFieldValueAsString('Parent_ID.Firm_ID')='JJHF800101' then begin
      self.SetFieldValueAsString('X_duvod_vraceni','RZDO300101');
  end;
end;

{
Umožňuje ovlivnit validaci.
}
procedure Validate_Hook(Self: TNxCustomBusinessObject; var AResult: Boolean);
begin


end;

begin
end.