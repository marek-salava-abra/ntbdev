{
Umožňuje ovlivnit validaci.
}
procedure Validate_Hook(Self: TNxCustomBusinessObject; var AResult: Boolean);
var
 mRows:TNxCustomBusinessMonikerCollection;
 i:integer;
 mFirm_ID:string;
 mResult:Boolean;
 mUser:TNxCustomBusinessObject;
begin
  mUser:=self.ObjectSpace.CreateObject(Class_SecurityUser);
  mUser.Load(NxGetActualUserID_1(self),nil);
  if not(muser.GetFieldValueAsBoolean('U_Saldo')) then begin
    mResult:=True;
    mRows:=self.GetLoadedCollectionMonikerForFieldCode(self.GetFieldCode('Rows'));
    if mRows.CountOfNotDeleted>1 then begin
    for i:=0 to mrows.CountOfNotDeleted-1 do begin
      if i=0 then mFirm_ID:=mrows.BusinessObject[i].GetFieldValueAsString('RSourceParent_ID.Firm_ID');
      if (i>0) and mResult then begin
        if not(mFirm_ID=mrows.BusinessObject[i].GetFieldValueAsString('RSourceParent_ID.Firm_ID')) then mResult:=False;
      end;
    end;
    if not(mresult) then NxShowSimpleMessage('dobropis je na rozdílné firmy',nil);
    AResult:=mResult;
    end;
  end;
end;

begin
end.