

{
Umožňuje ovlivnit validaci.
}
procedure Validate_Hook(Self: TNxCustomBusinessObject; var AResult: Boolean);
begin
  try
   if not(NxIsBlank(self.GetFieldValueAsString('U_u_crm_id_office'))) then self.SetFieldValueAsBoolean('U_CRM',true);
  except

  end;
end;

begin
end.