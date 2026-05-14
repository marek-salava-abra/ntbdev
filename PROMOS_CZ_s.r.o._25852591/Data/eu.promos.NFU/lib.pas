procedure Validate_Hook(Self: TNxCustomBusinessObject; var AResult: Boolean);
begin
  if (osNew in self.state) and (self.GetFieldValueAsInteger('rowType')=3) then begin
    if self.GetFieldValueAsBoolean('StoreCard_ID.X_not_for_use') then begin
      self.AddValidateError(self.GetFieldCode('StoreCard_ID'),'Kartu '+self.GetFieldValueAsString('StoreCard_ID.name')+' nelze použít.');
      AResult:=False;
    end;
  end;
end;

begin
end.