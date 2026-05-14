

procedure _AfterEditRec_Hook(Self: TRollSiteForm);
var
 mUserBO:TNxCustomBusinessObject;
begin
  muserBO:=self.BaseObjectSpace.CreateObject(Class_SecurityUser);
  mUserBO.Load(NxGetActualUserID_1(TBusRollSiteForm(Self).CurrentObject),nil);
  if not(mUserbo.GetFieldValueAsBoolean('U_EditNotForUse')) then begin
    //DisableControlWithNameOnSite(Self.GetSiteAppForm, 'mpnDueTerm');
    //DisableControlWithNameOnSite(Self.GetSiteAppForm, 'mpnAfterDueTerm');
    DisableControlWithNameOnSite(Self.GetSiteAppForm, 'mpn_X_Not_For_Use');
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