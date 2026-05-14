{
Vyvolává se při předvyplňování hodnot daného objektu.
}
procedure Prefill_Hook(Self: TNxCustomBusinessObject);
begin
  self.setFieldValueAsDateTime('U_Datum',Now);
  self.setFieldValueAsDateTime('U_Odeslano',Now);
  self.setFieldValueAsDateTime('U_Prevzato',Now+1);

end;

begin
end.