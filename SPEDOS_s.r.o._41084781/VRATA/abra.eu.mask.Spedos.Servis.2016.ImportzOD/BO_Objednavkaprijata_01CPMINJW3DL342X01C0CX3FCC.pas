{
Vyvolává se poté, co se provede na objektu metoda New.
}
procedure New_Hook(Self: TNxCustomBusinessObject);
begin
  self.SetFieldValueAsBoolean('IsRowDiscount', True);
end;

begin
end.