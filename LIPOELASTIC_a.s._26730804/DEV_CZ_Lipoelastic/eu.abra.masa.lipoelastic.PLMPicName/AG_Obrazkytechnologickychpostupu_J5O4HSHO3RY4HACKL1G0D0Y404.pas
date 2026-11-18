procedure _AfterEditRec_Hook(Self: TRollSiteForm);
var
 mUser_ID:string;
begin
  //if not (osNew in TBusRollSiteForm(Self).CurrentObject.State) then
    DisableControlWithNameOnSite(Self.GetSiteAppForm, 'edName');
  //else
    //AllowControlWithNameOnSite(Self.GetSiteAppForm, 'edName');
    //DisableControlWithNameOnSite(Self.GetSiteAppForm, 'mpnAfterDueTerm');
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
    TControl(AComponent).Refresh;
  end;
end;

procedure AllowAllControlsOnControl(AComponent: TComponent);
var
  i: Integer;
begin
  for i := AComponent.ComponentCount-1 downto 0 do begin
    AllowAllControlsOnControl(AComponent.Components(i));
  end;
  if AComponent is TControl then begin
    TControl(AComponent).Enabled := true;
    TControl(AComponent).Refresh;
  end;
end;

procedure AllowControlWithNameOnSite(AParent: TWinControl; AName: String);
var
  mControl: TControl;
begin
  mControl := NxFindChildControl(AParent, AName);
  if Assigned(mControl) then begin
    AllowAllControlsOnControl(mControl);
  end else;
end;


procedure My_OnChange_pgcDataViews(Sender: TPageControl);
begin
   DisableControlWithNameOnSite(Sender.Site.GetSiteAppForm, 'edName');
end;

begin
end.