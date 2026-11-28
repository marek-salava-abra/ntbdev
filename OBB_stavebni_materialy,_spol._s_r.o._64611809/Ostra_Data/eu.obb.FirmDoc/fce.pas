procedure AfterSetFieldValue_Hook(Self: TNxCustomBusinessObject; AFieldCode: Integer; AValue: TNxParameter; AOriginalValue: TNxParameter);
var
 mUser:TNxCustomBusinessObject;
 i:Integer;
begin
  if (AFieldCode=self.GetFieldCode('Firm_ID')) and (not(avalue.AsString=AOriginalValue.AsString)) then begin
  //NxScriptingLog.WriteEvent(logInfo, 'FirmDoc');
  mUser:=self.ObjectSpace.CreateObject(Class_SecurityUser);
  mUser.Load(NxGetActualUserID(self.ObjectSpace),nil);

  if not(NxIsEmptyOID(mUser.GetFieldValueAsString('X_Store_ID')))  then begin
     if not(NxIsEmptyOID(self.GetFieldValueAsString('Firm_ID.Store_ID'))) then begin
       if not(self.GetFieldValueAsString('Firm_ID.Store_ID')= mUser.GetFieldValueAsString('X_Store_ID')) then begin
         NxShowSimpleMessage('Nemáte právo použít tuto adresu v dokladu.',nil);
         self.SetFieldValueAsString('Firm_ID','0000000000');
         //self.AddValidateError(self.GetFieldCode('Firm_id'),'Nemáte právo použít tuto adresu v dokladu.');
      end;
     end;
    end;
   end;
end;


procedure Validate_Hook(Self: TNxCustomBusinessObject; var AResult: Boolean);
var
 mUser:TNxCustomBusinessObject;
 i:Integer;
begin
  mUser:=self.ObjectSpace.CreateObject(Class_SecurityUser);
  mUser.Load(NxGetActualUserID(self.ObjectSpace),nil);
   if not(NxIsEmptyOID(mUser.GetFieldValueAsString('X_Store_ID')))  then begin
     if not(NxIsEmptyOID(self.GetFieldValueAsString('Firm_ID.Store_ID'))) then begin
       if not(self.GetFieldValueAsString('Firm_ID.Store_ID')= mUser.GetFieldValueAsString('X_Store_ID')) then begin
        self.AddValidateError(self.GetFieldCode('Firm_id'),'Nemáte právo použít tuto adresu v dokladu.');
        AResult:=False;
      end;
     end;
    end;

end;

begin
end.