procedure _AfterNewRec_Hook(Self: TDynSiteForm);
var
 mBO, mUser:TNxCustomBusinessObject;
begin
      mBO:=TDynSiteForm(self).CurrentObject;
      mUser:=mbo.ObjectSpace.CreateObject(Class_SecurityUser);
      mUser.Load(NxGetActualUserID_1(mBO),nil);
      mbo.SetFieldValueAsString('DocQueue_ID',muser.GetFieldValueAsString('X_RO_ID'));
      TDynSiteForm(self).ActiveDataSet.RefreshCurrentItem;
end;

begin
end.