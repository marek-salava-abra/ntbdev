{
Umožňuje ovlivnit validaci.
}
procedure Validate_Hook(Self: TNxCustomBusinessObject; var AResult: Boolean);
begin
  if (self.GetFieldValueAsBoolean('Parent_ID.VatDocument')) then begin
     if NxIsEmptyOID(self.GetFieldValueAsString('BusTransaction_ID')) then begin
       self.AddValidateError(self.GetFieldCode('BusTransaction_ID'),'Není vyplněn obchodní případ');
       AResult:=False;
     end;


  end;
end;

begin
end.