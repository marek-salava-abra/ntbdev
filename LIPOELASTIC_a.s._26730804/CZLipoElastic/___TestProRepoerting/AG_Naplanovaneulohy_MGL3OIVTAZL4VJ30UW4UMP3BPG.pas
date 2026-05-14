uses 'Naplanovana_uloha_reporting.Reporting';

const
  dates_packedGUID = 'AVV1JYV5AVNOZHQCK0D4CJFUCS'; //Aktivita BO
  dates_siteGUID = 'OYC0P3TDDY1ORIJO2SKTP2KZKG';  //Faktury Vydane SITE
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
  mAction.Caption := 'Koncept report';
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