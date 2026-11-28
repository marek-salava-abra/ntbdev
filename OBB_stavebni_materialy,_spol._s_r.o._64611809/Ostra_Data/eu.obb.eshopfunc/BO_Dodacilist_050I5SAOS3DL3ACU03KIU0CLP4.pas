{
Umožňuje ovlivnit validaci.
}
{
Vyvolává se po změně každé položky. A to pouze, pokud k této změně nedochází díky načítání objektu z databáze nebo díky vytváření kopie.
}
procedure AfterSetFieldValue_Hook(Self: TNxCustomBusinessObject; AFieldCode: Integer; AValue: TNxParameter; AOriginalValue: TNxParameter);
var
 mUser:TNxCustomBusinessObject;
begin
  mUser:=Self.ObjectSpace.CreateObject(Class_SecurityUser);
  mUser.load(NxGetActualUserID(self.ObjectSpace),nil);
  if not(mUser.GetFieldValueAsBoolean('U_Deus')) then begin
   if not(self.GetFieldValueAsBoolean('U_eshopDL')) then begin
     if (AFieldCode=self.GetFieldCode('Firm_ID')) and not(AValue.AsString=AOriginalValue.AsString) then begin
        if self.GetFieldValueAsString('Firm_ID.OrgIdentNumber')='09698507' then NxShowSimpleMessage('Nemáte právo vystavit DL na Deus, doklad nepůjde uložit.',nil);
     end;
   end;
  end;
end;

procedure Validate_Hook(Self: TNxCustomBusinessObject; var AResult: Boolean);
var
 mUser:TNxCustomBusinessObject;
begin
  mUser:=Self.ObjectSpace.CreateObject(Class_SecurityUser);
  mUser.load(NxGetActualUserID(self.ObjectSpace),nil);
  if not(mUser.GetFieldValueAsBoolean('U_Deus')) then begin
    if not(self.GetFieldValueAsBoolean('U_eshopDL')) then begin
      if self.GetFieldValueAsString('Firm_ID.OrgIdentNumber')='09698507' then begin
         self.AddValidateError(self.GetFieldCode('Firm_ID'),'Nemáte právo vystavit dodací list na DEUS.');
         AResult:=False;
      end;
    end;
  end;
end;



begin
end.