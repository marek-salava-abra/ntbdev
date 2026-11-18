uses 'abra.eu.mask.2017.refresh_OP.libs';
{
Vyvolává se před fyzickým uložením vlastních dat objektu do databáze.
}
procedure BeforeSave_Hook(Self: TNxCustomBusinessObject);
begin
   self.SetFieldValueAsFloat('X_Quantity',getquantity(self));
   self.SetFieldValueAsFloat('X_in_store',getinstore(self));
   self.SetFieldValueAsFloat('X_Reservation',getreservation(self));
   self.SetFieldValueAsFloat('X_Vychystano',getlogistic(self));
   self.SetFieldValueAsFloat('X_delivered',getdelivered(self));
    if ((Trim(self.getFieldValueAsString('X_identifikace'))='') or (Trim(self.getFieldValueAsString('X_identifikace'))='0'))then self.SetFieldValueAsString('X_identifikace',self.GetFieldValueAsString('Firm_ID.Name'));


end;

begin
end.