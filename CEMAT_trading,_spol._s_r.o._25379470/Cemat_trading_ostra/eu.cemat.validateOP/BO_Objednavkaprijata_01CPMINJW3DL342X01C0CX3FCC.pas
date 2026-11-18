{
Umožňuje ovlivnit validaci.
}
procedure Validate_Hook(Self: TNxCustomBusinessObject; var AResult: Boolean);
var
 muser:TNxCustomBusinessObject;
 mUser_ID:String;
begin
  mUser_ID:=NxGetActualUserID_1(self);
  mUser:=self.ObjectSpace.CreateObject(Class_SecurityUser);
  mUser.Load(mUser_ID,nil);
  if not(NxIsEmptyOID(self.GetFieldValueAsString('Firm_ID.PaymentType_ID'))) then begin
     if not(self.GetFieldValueAsString('Firm_ID.PaymentType_ID')=self.GetFieldValueAsString('PaymentType_ID'))
      then begin
      self.AddValidateError(self.GetFieldCode('PaymentType_ID'),'Způsob platby neodpovídá zadanému typu platby na firmě');
      AResult:=False;
      end;
  end;
  if NxIsBlank(self.GetFieldValueAsString('U_Zkontroloval')) and self.GetFieldValueAsBoolean('U_zkontrolovano_uctarnou')
  then self.SetFieldValueAsString('U_Zkontroloval',mUser.GetFieldValueAsString('Name')+' '+FormatDateTime('d.m.yyyy HH:MM',Now));
 // if self.GetFieldValueAsBoolean('Closed') then self.SetFieldValueAsInteger('U_stav',3);


end;





begin
end.