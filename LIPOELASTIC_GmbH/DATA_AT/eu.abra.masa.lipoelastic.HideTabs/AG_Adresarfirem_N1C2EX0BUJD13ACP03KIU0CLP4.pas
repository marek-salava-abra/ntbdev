{
Vyvolává se po vytvoření instance formuláře.
}
procedure InitSite_Hook(Self: TSiteForm);
var
  mTab, mTabDetail: TTabSheet;
  mPanelDetail: TPanel;
  pgcDetails: TPageControl;
  mControl: TControl;
  i: integer;
  mUser:TNxCustomBusinessObject;
begin
  if not(NxIsEmptyOID(NxGetActualUserID(self.BaseObjectSpace))) then begin
  mUser:=self.BaseObjectSpace.CreateObject(Class_SecurityUser);
  mUser.Load(NxGetActualUserID(self.BaseObjectSpace),nil);
    if mUser.GetFieldValueAsBoolean('X_HideTabsFirm') then begin
        mControl := TWinControl(Self.FindChildControl('tabDetail')).FindChildControl('pnDetail.pgcDetails');
        if Assigned(mControl) and (mControl is TPageControl) then
        begin
          pgcDetails := TPageControl(mControl);
          for i:= 0 to pgcDetails.PageCount -1 do begin
            if pgcDetails.Pages[i].Name in ['tabFirmPersons', 'tabKeys', 'tabCategorisation', 'tabTexts', 'tabPhoto'] then
              pgcDetails.Pages[i].TabVisible:= false;
            if pgcDetails.Pages[i].Name = 'tabSiteUserFormX' then
              pgcDetails.Pages[i].Caption:= 'Overview';
          end;
        end;
    end;
  end;
end;



begin
end.