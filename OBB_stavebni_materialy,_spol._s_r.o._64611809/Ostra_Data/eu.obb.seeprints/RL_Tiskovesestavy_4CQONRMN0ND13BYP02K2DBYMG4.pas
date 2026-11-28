
procedure OnSelectSQL_Hook(Self: TNxBusinessRoll; AParams: TNxParameters; ADSQL: TRollDynamicSQL; AKind: TRollOnSelectSQLKind);
var
 mUser:TNxCustomBusinessObject;
begin
  mUser:=self.ObjectSpace.CreateObject(Class_SecurityUser);
  mUser.Load(NxGetActualUserID(self.ObjectSpace),nil);
  if muser.GetFieldValueAsBoolean('U_SeePrints') then ADSQL.Where.Add(' title like ''x%''  ');
end;

begin
end.