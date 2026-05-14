procedure Validate_Hook(Self: TNxCustomBusinessObject; var AResult: Boolean);
begin
    if self.GetFieldValueAsDateTime('RealStoreCard_ID.AuthorizedAt$Date')=0 then begin
     self.AddValidateError(self.GetFieldCode('RealStoreCard_ID'),'Karta '+self.GetFieldValueAsString('RealStoreCard_ID.Name')+' není schválená.');
     AResult:=False;
    end;
end;

begin
end.