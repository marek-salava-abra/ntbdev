{
Umožňuje ovlivnit validaci.
}
procedure Validate_Hook(Self: TNxCustomBusinessObject; var AResult: Boolean);
begin
  if self.GetFieldValueAsBoolean('StoreCard_ID.U_spatna') then self.AddValidateError(self.GetFieldCode('StoreCard_ID'),'Je použita špatná karta nebo s příznakem Nepřijímat');
  if self.GetFieldValueAsBoolean('StoreCard_ID.U_neprijimat') then self.AddValidateError(self.GetFieldCode('StoreCard_ID'),'Je použita špatná karta nebo s příznakem Nepřijímat');
end;

begin
end.