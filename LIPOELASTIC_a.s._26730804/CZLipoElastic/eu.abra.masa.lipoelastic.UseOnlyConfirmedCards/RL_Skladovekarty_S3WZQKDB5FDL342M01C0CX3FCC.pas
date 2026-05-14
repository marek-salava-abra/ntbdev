procedure OnSelectSQL_Hook(Self: TNxBusinessRoll; AParams: TNxParameters; ADSQL: TRollDynamicSQL; AKind: TRollOnSelectSQLKind);
var
 mUser:TNxCustomBusinessObject;
begin
 mUser:=self.ObjectSpace.CreateObject(Class_SecurityUser);
 mUser.load(NxGetActualUserID(self.ObjectSpace),nil);
 if mUser.GetFieldValueAsBoolean('X_ND_UseOnlyConfirmedCards') then begin
   if AParams.ParamExist('MyActiveCard') and
    AParams.GetOrCreateParam(dtBoolean, 'MyActiveCard').AsBoolean then begin
      ADSQL.Where.Add('A.X_Aktivni = ''A''');
   end;
 end;
 mUser.free;
end;

begin
end.