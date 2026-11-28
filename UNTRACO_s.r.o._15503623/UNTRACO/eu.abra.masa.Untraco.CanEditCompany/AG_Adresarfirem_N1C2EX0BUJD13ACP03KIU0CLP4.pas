procedure _CanEdit_Hook(Self: TRollSiteForm; var ACanEdit: Boolean);
var
 mUser, mFirmBO:TNxCustomBusinessObject;
 mOS:TNxCustomObjectSpace;
 mKey:string;
begin
  mOS:=TBusRollSiteForm(Self).BaseObjectSpace;
  mUser:=mOS.CreateObject(Class_SecurityUser);
  mUser.Load(NxGetActualUserID(mOS),nil);
  if not(mUser.GetFieldValueAsBoolean('U_CanEdit')) then begin
    mFirmBO:=TBusRollSiteForm(Self).CurrentObject;
    mKey:=mFirmBO.GetFieldValueAsString('K1');
    if (Copy(mKey, 3, 1) = '1') or (Copy(mKey, 4, 1) = '1') then begin
      NxShowSimpleMessage('Nemáte oprávnění editovat VO/Nemocnici.',self);
      ACanEdit := false;
    end;
  end;
end;

begin
end.