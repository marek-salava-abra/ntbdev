uses 'ExportstavuSkladusSarzi.Reporting';

var
mSite: TSiteForm;
mHead : TNxHeaderBusinessObject;
mBO_source:TNxCustomBusinessObject     ;




{
Vyvolává se po vytvoření instance formuláře.
}
procedure FormCreate_Hook(Self: TSiteForm);
var
  mAction: TBasicAction;
begin
 mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Category := 'tabList';
  mAction.Caption := 'Ruční spuštení úlohy';
  mAction.OnExecute := @NewReporting;


end;


procedure NewReporting(Sender: TComponent);
var
  mSite: TSiteForm;
  mDBGrid : TDBGrid;
  mTabList: TTabSheet;
begin
  mSite := TComponent(sender).DynSite;
  {mTabList := TTabSheet(NxFindChildControl(mSite.MainPanel, 'tabList'));
  if mTabList = nil then
    RaiseException('tabList nenalezen');
  mDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdList'));
  if mDBGrid = nil then
    RaiseException('DBGrid nenalezen');     }
   //NxShowSimpleMessage('jdu odesílat',mSite);
  Create_report(msite.BaseObjectSpace,true,'OK');
end;






begin
end.