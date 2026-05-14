{
Vyvolává se po změně každé položky. A to pouze, pokud k této změně nedochází díky načítání objektu z databáze nebo díky vytváření kopie.
}
procedure AfterSetFieldValue_Hook(Self: TNxCustomBusinessObject; AFieldCode: Integer; AValue: TNxParameter; AOriginalValue: TNxParameter);
var
 mUser:TNxCustomBusinessObject;

begin
  if (AFieldCode=self.GetFieldCode('U_SendToES')) and not(avalue.AsBoolean=AOriginalValue.AsBoolean) and self.GetFieldValueAsBoolean('U_sendToES') then begin
    //self.SetFieldValueAsBoolean('U_SendToEs2',True);
      muser:=self.ObjectSpace.CreateObject(Class_SecurityUser);
      muser.load(NxGetActualUserID_1(self),nil);
      if not(mUser.GetFieldValueAsBoolean('U_eshop')) then begin
       NxShowSimpleMessage('Nemáte právo nastavit příznak exportu na e-shop.',nil);
       self.SetFieldValueAsBoolean('U_sendToES',false);
      end;
  end;
end;

begin
end.