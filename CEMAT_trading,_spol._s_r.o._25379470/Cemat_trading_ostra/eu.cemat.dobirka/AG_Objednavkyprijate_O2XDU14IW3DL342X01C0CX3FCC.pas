procedure _FormActivate_PostHook(Self: TSiteForm);
var
  mControl: TControl;
  mObject: TObject;
begin
  mControl := NxFindChildControl(TDynSiteForm(Self).MainPanel, 'navRows');
  if (mControl <> Nil) then
  begin
   mObject := GetObjectProp(mControl, 'Datasource');
   GlobParams.GetOrCreateParam(dtInteger, 'CematDSPointer').AsInteger := ObjToInt(TNxCustomObjectDataSet(GetObjectProp(mObject, 'Dataset')));
  end;
end;

procedure FormHide_Hook(Self: TSiteForm);
begin
  if GlobParams.ParamExist('CematDSPointer') then
    GlobParams.ParamByName('CematDSPointer').AsInteger := 0;
end;

begin
end.