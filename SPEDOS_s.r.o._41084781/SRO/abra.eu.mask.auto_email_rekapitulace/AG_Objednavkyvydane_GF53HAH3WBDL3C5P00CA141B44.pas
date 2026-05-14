uses 'abra.eu.mask.auto_email_rekapitulace.rekapitulace';

var
mSite: TSiteForm;
mHead : TNxHeaderBusinessObject;
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
  mAction.Caption := 'Okamžité odeslání';
  mAction.OnExecute := @NewValidateClick;

    mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Category := 'tabList';
  mAction.Caption := 'Již odesláno ručně';
  mAction.OnExecute := @SendHAndClick;
end;



procedure sendHandClick(Sender: TComponent);
var
  mSite: TSiteForm;
  mDBGrid : TDBGrid;
  mTabList: TTabSheet;
  mi:integer;
begin
  mSite := TComponent(sender).DynSite;
  {mTabList := TTabSheet(NxFindChildControl(mSite.MainPanel, 'tabList'));
  if mTabList = nil then
    RaiseException('tabList nenalezen');
  mDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdList'));
  if mDBGrid = nil then
    RaiseException('DBGrid nenalezen');     }
   //NxShowSimpleMessage('jdu odesílat',mSite);
 mi:=msite.BaseObjectSpace.SQLExecute('update IssuedOrders set x_odeslano=' + IntToStr(Round(now())) + ' where id=' + quotedstr(TDynSiteForm(msite).CurrentObject.oid)) ;
 TDynSiteForm(msite).CurrentObject.Refresh  ;
end;




procedure NewValidateClick(Sender: TComponent);
var
  mSite: TSiteForm;
  mDBGrid : TDBGrid;
  mTabList: TTabSheet;
  mi:Integer;
begin
  mSite := TComponent(sender).DynSite;
  {mTabList := TTabSheet(NxFindChildControl(mSite.MainPanel, 'tabList'));
  if mTabList = nil then
    RaiseException('tabList nenalezen');
  mDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdList'));
  if mDBGrid = nil then
    RaiseException('DBGrid nenalezen');     }
   //NxShowSimpleMessage('jdu odesílat',mSite);
 Odeslani_dokladu_auto(msite.BaseObjectSpace,true,'OK');
end;






begin
end.