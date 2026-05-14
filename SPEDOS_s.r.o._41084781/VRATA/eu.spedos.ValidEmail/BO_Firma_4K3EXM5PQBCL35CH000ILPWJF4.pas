{
Umožňuje ovlivnit validaci.
}
procedure Validate_Hook(Self: TNxCustomBusinessObject; var AResult: Boolean);
var
 mUserBO:TNxCustomBusinessObject;
begin
  mUserBO:=Self.ObjectSpace.CreateObject(Class_SecurityUser);
  mUserBO.Load(NxGetActualUserID_1(self),nil);
  if not(mUserBO.GetFieldValueAsBoolean('U_CheckEmail')) then begin
  if NxIsEmptyOID(Self.GetFieldValueAsString('Firm_ID')) then begin
    if not(NxIsValidEMail(self.GetFieldValueAsString('ResidenceAddress_ID.Email'),false)) then begin
      self.AddValidateError(self.GetFieldCode('ResidenceAddress_ID.Email'), 'Není vyplněn platný email');
      AResult:=False;
    end;
  end;
  end;
  mUserBO.Free;
end;

begin
end.