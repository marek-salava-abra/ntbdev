uses
  'eu.abra.PostProviders.uActionEvents',
  'eu.abra.PostProviders.uLicence',
  'eu.abra.PostProviders.uLanguage';


procedure InitSite_Hook(Self: TSiteForm);
var
  mMultiAction: TMultiAction;
  s: String;
begin
  if not TestLicence(cIsVisual, s) then exit;
  mMultiAction := Self.GetNewMultiAction;
  if Assigned(mMultiAction) then begin
    mMultiAction.Name := 'actPrintPackages';
    mMultiAction.ShowControl := True;
    mMultiAction.ShowMenuItem := True;
    mMultiAction.Category := 'tabList';
    mMultiAction.Caption := lng_Btn_PrintPackage;
    mMultiAction.Items.Add(lng_Btn_PrintPackage);
    //mMultiAction.Items.Add('Předávací protokol');
    mMultiAction.OnExecuteItem := @actPrintPackagesOnExecuteItem;
    mMultiAction.OnUpdate := @actPackagesOnUpdate;
  end;
  mMultiAction := Self.GetNewMultiAction;
  if Assigned(mMultiAction) then begin
    mMultiAction.Name := 'actExportPackages';
    mMultiAction.ShowControl := True;
    mMultiAction.ShowMenuItem := True;
    mMultiAction.Category := 'tabList';
    mMultiAction.Caption := lng_Btn_ExportPackage;
    mMultiAction.Items.Add(lng_Btn_ExportPackage);
    //mMultiAction.Items.Add('Stažení informace');
    mMultiAction.OnExecuteItem := @actExportPackagesOnExecuteItem;
    mMultiAction.OnUpdate := @actPackagesOnUpdate;
  end;
  mMultiAction := Self.GetNewMultiAction;
  if Assigned(mMultiAction) then begin
    mMultiAction.Name := 'actDropPackages';
    mMultiAction.ShowControl := True;
    mMultiAction.ShowMenuItem := True;
    mMultiAction.Category := 'tabList';
    mMultiAction.Caption := lng_Btn_DeletePackage;
    mMultiAction.Items.Add(lng_Btn_DeletePackage);
    //mMultiAction.Items.Add('Stažení informace');
    mMultiAction.OnExecuteItem := @actDropPackagesOnExecuteItem;
    mMultiAction.OnUpdate := @actPackagesOnUpdate;
  end;
  mMultiAction := Self.GetNewMultiAction;
  if Assigned(mMultiAction) then begin
    mMultiAction.Name := 'actOrderPostProvider';
    mMultiAction.ShowControl := True;
    mMultiAction.ShowMenuItem := True;
    mMultiAction.Category := 'tabList';
    mMultiAction.Caption := lng_Btn_CloseOrder;
    mMultiAction.Items.Add(lng_Btn_CloseOrder);
    mMultiAction.OnExecuteItem := @actOrderPostProviderOnExecuteItem;
    //mMultiAction.OnUpdate := @actPackagesOnUpdate;
  end;
  mMultiAction := Self.GetNewMultiAction;
  if Assigned(mMultiAction) then begin
    mMultiAction.Name := 'actActualizeTrackingStatus';
    mMultiAction.ShowControl := True;
    mMultiAction.ShowMenuItem := True;
    mMultiAction.Category := 'tabList';
    mMultiAction.Caption := lng_Btn_TrackATrace;
    mMultiAction.Hint := lng_BtnHint_TrackATrace;
    mMultiAction.Items.Add(lng_Btn_TrackATrace);
    mMultiAction.OnExecuteItem := @actActualizeTrackingStatusesOnExecuteItem;
  end;
end;

begin
end.