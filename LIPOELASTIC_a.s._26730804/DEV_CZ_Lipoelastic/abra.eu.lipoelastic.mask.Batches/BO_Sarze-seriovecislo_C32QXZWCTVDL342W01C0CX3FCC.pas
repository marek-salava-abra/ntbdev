{
Vyvolává se při předvyplňování hodnot daného objektu.
}
{
Vyvolává se poté, co se provede na objektu metoda New.
}
procedure New_Hook(Self: TNxCustomBusinessObject);
begin
  self.SetFieldValueAsDateTime('ExpirationDate$Date',0);
end;


procedure Prefill_Hook(Self: TNxCustomBusinessObject);
begin
  self.SetFieldValueAsDateTime('ExpirationDate$Date',0);
end;

begin
end.