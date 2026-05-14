uses 'EU.Aabra.Mask.Validace.lib';

{
Vyvolává se před fyzickým uložením vlastních dat objektu do databáze.
}
procedure BeforeSave_Hook(Self: TNxCustomBusinessObject);
begin
//  self.setFieldValueAsString('PaymentType_ID', '9000000101');
end;

{
Umožňuje ovlivnit validaci.
}
procedure Validate_Hook(Self: TNxCustomBusinessObject; var AResult: Boolean);
begin
    if not self.GetFieldValueAsBoolean('VATDocument') then begin
       self.SetFieldValueAsBoolean('VATDocument',True) ;



  end;

end;

begin
end.