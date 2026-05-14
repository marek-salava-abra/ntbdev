
procedure _PrefillObject_Hook(Self: TBusRollSiteForm; AObject: TNxCustomBusinessObject);
var
  mParamValue, mValue: string;
  mMon: TNxBusinessMoniker;
begin
  //ShowMessage('_PrefillObject_Hook');
  if Assigned(self.SiteParams) and Assigned(self.SiteParams.ParamByName('_CurrentFirm')) then begin
    //ShowMessage('_PrefillObject_Hook - uvnitr');
    mParamValue := self.SiteParams.ParamByName('_CurrentFirm').AsString;
    //ShowMessage('_PrefillObject_Hook - po zjisteni hodnoty parametru');
    AObject.SetFieldValueAsString('X_FIRM_ID', mParamValue);
    mMon := AObject.GetMonikerForFieldCode(AObject.GetFieldCode('X_FIRM_ID'));
    if not mMon.IsNull then begin
      mValue := mMon.BusinessObject.GetFieldValueAsString('Code');
      AObject.SetFieldValueAsString('Code', mValue);
    end;
  end;
end;

procedure _SetReadOnlyForDetail_Hook(Self: TRollSiteForm; AReadOnly: Boolean);
var
  mControl, mControl2: TControl;
begin
  if AReadOnly then
    Exit;
  //ShowMessage('_SetReadOnlyForDetail_Hook');
  if Assigned(self.SiteParams) and Assigned(self.SiteParams.ParamByName('_CurrentFirm')) then begin
    //ShowMessage('_SetReadOnlyForDetail_Hook - uvnitr');
    mControl := NxFindChildControl(Self.GetSiteAppForm, 'edX_FIRM_ID');
    if Assigned(mControl) then begin
      //ShowMessage('FirmControl nalezen');
      NxSetReadOnly([mControl], True);
    end
    else
      ;//ShowMessage('FirmControl nenalezen');
    mControl := nil;
    mControl := NxFindChildControl(Self.GetSiteAppForm, 'edCode');
    mControl2 := NxFindChildControl(Self.GetSiteAppForm, 'edname');
    if Assigned(mControl) and Assigned(mControl2) then begin
      NxSetReadOnly([mControl, mControl2], True);
    end;
  end;
end;

begin
end.
