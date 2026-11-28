procedure DisableControlWithNameOnSite(AParent: TWinControl; AName: String);
var
  mControl: TControl;
begin
  mControl := NxFindChildControl(AParent, AName);
  if Assigned(mControl) then
  begin
    DisableAllControlsOnControl(mControl);
  end;
end;

// Rekurze - vyhledá všechny prvky na panelu. -> Díky varantnímu formuláři -> Nejde se dostatna prvky přímo.
procedure DisableAllControlsOnControl(AComponent: TComponent);
var
  i: Integer;
begin
  for i := AComponent.ComponentCount-1 downto 0 do
  begin
    DisableAllControlsOnControl(AComponent.Components(i));
  end;
  if AComponent is TControl then
  begin
    TControl(AComponent).Enabled := False;
    TControl(AComponent).Refresh;
  end;
end;

procedure _StartEdit_PreHook(Self: TDynSiteForm);
var
   mSecurityUser: TNxCustomBusinessObject;
begin
   mSecurityUser:= Self.BaseObjectSpace.CreateObject(Class_SecurityUser);
   try
      mSecurityUser.Load(NxGetActualUserID(Self.BaseObjectSpace),nil);
      //if Not mSecurityUser.GetFieldValueAsBoolean('X_Faktoring') then
      //begin
         DisableControlWithNameOnSite(Self.GetSiteAppForm, 'mpn_X_Faktoring');
         DisableControlWithNameOnSite(Self.GetSiteAppForm, 'mpn_X_Faktoring2');
      //end;
   finally
      mSecurityUser.Free;
   end;
end;

begin
end.