{
Umožňuje ovlivnit validaci.
}
procedure Validate_Hook(Self: TNxCustomBusinessObject; var AResult: Boolean);
begin
  if self.GetFieldValueAsInteger('RowType')=3 then begin
    if self.GetFieldValueAsDateTime('StoreCard_ID.AuthorizedAt$Date')=0 then begin
    self.AddValidateError(self.GetFieldCode('StoreCard_ID'),'Karta '+self.GetFieldValueAsString('StoreCard_ID.Name')+' není schválená.');
    AResult:=False;
   end;
  end;
end;

begin
end.