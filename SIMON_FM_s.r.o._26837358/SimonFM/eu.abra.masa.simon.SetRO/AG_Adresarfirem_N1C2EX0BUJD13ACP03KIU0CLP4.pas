

procedure _AfterEditRec_Hook(Self: TRollSiteForm);
var
 mUserBO:TNxCustomBusinessObject;
begin
  muserBO:=self.BaseObjectSpace.CreateObject(Class_SecurityUser);
  mUserBO.Load(NxGetActualUserID_1(TBusRollSiteForm(Self).CurrentObject),nil);
  if not(mUserbo.GetFieldValueAsBoolean('U_EditCheckBox')) then begin
    //DisableControlWithNameOnSite(Self.GetSiteAppForm, 'mpnDueTerm');
    //DisableControlWithNameOnSite(Self.GetSiteAppForm, 'mpnAfterDueTerm');
    DisableControlWithNameOnSite(Self.GetSiteAppForm, 'mpn_X_ExcludeReminder');
    DisableControlWithNameOnSite(Self.GetSiteAppForm, 'mpn_X_TypeOfAutoInvoice');
  end;
  if not(mUserBO.OID in ['2V10000101','D000000101','SUPER00000']) then begin
    DisableControlWithNameOnSite(Self.GetSiteAppForm, 'mpn_X_NoTransport');
  end;
end;

procedure DisableControlWithNameOnSite(AParent: TWinControl; AName: String);
var
  mControl: TControl;
begin
  mControl := NxFindChildControl(AParent, AName);
  if Assigned(mControl) then begin
    DisableAllControlsOnControl(mControl);
  end else;
end;

procedure DisableAllControlsOnControl(AComponent: TComponent);
var
  i: Integer;
begin
  for i := AComponent.ComponentCount-1 downto 0 do begin
    DisableAllControlsOnControl(AComponent.Components(i));
  end;
  if AComponent is TControl then begin
    TControl(AComponent).Enabled := false;
  end;
end;

begin
end.