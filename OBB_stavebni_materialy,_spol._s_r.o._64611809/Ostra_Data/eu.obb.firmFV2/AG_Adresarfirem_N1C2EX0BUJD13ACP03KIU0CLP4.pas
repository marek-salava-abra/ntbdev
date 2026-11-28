procedure InitSite_Hook(Self: TSiteForm);
var
  mBut, mBut2: TBasicAction;

begin
  if not Assigned(Self.BaseObjectSpace) then
    exit;

mBut:= Self.GetNewAction;
mBut.ShowControl := True;
mBut.ShowMenuItem := True;
mBut.Caption := 'Vytisknout saldo';
mBut.Category := 'tabList';
mBut.OnExecute := @PrintFV;

end;

procedure PrintFV(sender:TComponent);
var
 mSite:TSiteForm;
 mList:TstringList;
 mOS:TNxCustomObjectSpace;
 mBO, mUser:TNxCustomBusinessObject;
 mContext:TNxContext;
begin
  mSite:=TComponent(sender).BusRollSite;
  mBO:=TBusRollSiteForm(mSite).CurrentObject;
   if Assigned(mBO) then begin
   mUser:=mBO.ObjectSpace.CreateObject(Class_SecurityUser);
   mUser.Load(NxGetActualUserID_1(mBO),nil);
   if not(muser.GetFieldValueAsBoolean('U_saldo')) then NxShowSimpleMessage('Nemáte právo tisknout saldo pro firmu ' +mbo.GetFieldValueAsString('Name'),mSite);
   if (mUser.GetFieldValueAsBoolean('U_saldo')) then begin
    mList:=TStringList.Create;
    mOS:=mbo.ObjectSpace;
    mlist.Add(mBO.OID);
    if mlist.Count>0 then begin
        mContext:=NxCreateNotLoggedContext_1(mBO);
        mContext.LogOn('Josef Novák','XDQcJZwc2SKRfZ1epob8');

        CFxReportManager.PrintByIDs(mContext,mList,'5BL03ASFX4OOP4ZHZEHOVBZGBG','1E50000101',rtoPreview,pekPDF,'','');
        mContext.Free;

    end;
    end;
   end;
end;


begin
end.