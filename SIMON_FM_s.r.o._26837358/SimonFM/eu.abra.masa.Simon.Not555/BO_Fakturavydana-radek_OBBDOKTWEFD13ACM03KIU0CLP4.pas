{
Umožňuje ovlivnit validaci.
}
procedure Validate_Hook(Self: TNxCustomBusinessObject; var AResult: Boolean);
var
 mBO:TNxCustomBusinessObject;
begin
  mBO:=self.ObjectSpace.CreateObject(Class_SecurityUser);
  mBO.Load(NxGetActualUserID_1(self),nil);
  if mBO.GetFieldValueAsBoolean('U_Not555') then begin
    if self.GetFieldValueAsInteger('RowType')=3 then begin
       if self.GetFieldValueAsString('Store_ID.Code')='555' then begin
         self.AddValidateError(self.GetFieldCode('Store_ID'),'Nemáte oprávnění fakturovat ze skladu 555.');
         AResult:=false;
       end;
    end;
  end;
end;

begin
end.