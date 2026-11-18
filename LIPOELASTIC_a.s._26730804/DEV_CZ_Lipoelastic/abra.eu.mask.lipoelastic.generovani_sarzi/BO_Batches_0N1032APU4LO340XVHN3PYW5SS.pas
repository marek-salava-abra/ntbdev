{
Umožňuje ovlivnit validaci.
}
procedure Validate_Hook(Self: TNxCustomBusinessObject; var AResult: Boolean);
begin
                                     Self.SetFieldValueAsDateTime('ProductionDate$DATE',now) ;
                                   if not Self.GetFieldValueAsInteger('StoreCard_ID.ExpirationDue')=0 then
                                   Self.SetFieldValueAsDateTime('ExpirationDate$Date',NxIncDate(Now,Self.GetFieldValueAsInteger('StoreCard_ID.ExpirationDue'),0,0)) ;   //1096
                                   if  NxIsEmptyOID(self.getFieldValueAsString('X_parent_ID')) then begin
                                         self.setFieldValueAsString('X_parent_ID',self.GetFieldValueAsString('Storecard_ID.X_parent_ID'));
                                   end;

end;

begin
end.