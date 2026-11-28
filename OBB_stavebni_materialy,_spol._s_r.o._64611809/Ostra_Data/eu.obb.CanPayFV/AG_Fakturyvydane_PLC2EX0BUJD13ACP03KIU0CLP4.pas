procedure _CanSaveNow_Hook(Self: TDynSiteForm; var ACanSaveNow: Boolean);
var
  mUser,mBO: TNxCustomBusinessObject;
  mCtrl: TWinControl;
  mChkBox: TCheckBox;
  i: Integer;
begin
  mBO := Self.ActiveDataSet.CurrentObject;
  if mbo.GetFieldValueAsFloat('Amount')<0 then begin
  mUser:=mBO.ObjectSpace.CreateObject(Class_SecurityUser);
  mUser.Load(NxGetActualUserID_1(mBO),nil);

  if not mUser.GetFieldValueAsBoolean('U_Saldo') then begin
    mCtrl := TWinControl(NxFindChildControl(Self.GetSiteAppForm, 'pnDesk'));
    if mCtrl = nil then
      mCtrl := Self.GetSiteAppForm;
    mCtrl := TWinControl(NxFindChildControl(mCtrl, 'pnSitePanel'));
    if mCtrl = nil then
      mCtrl := Self.GetSiteAppForm;
    mCtrl := TWinControl(NxFindChildControl(mCtrl, 'pnSite'));
    mCtrl := TWinControl(NxFindChildControl(mCtrl, 'pnFunc'));
    for i := 0 to mCtrl.ControlCount - 1 do begin
      if mCtrl.Controls(i) is TWinControl then begin
        mChkBox := TCheckBox(NxFindChildControl(TWinControl(mCtrl.Controls(i)), 'CactGeneratePaymentOrdersAfterSave'));
        if mChkBox <> nil then
          break;
      end;
    end;
    if Assigned(mChkBox) then
      mChkBox.Checked := False;
  end;
  end;
end;

begin
end.