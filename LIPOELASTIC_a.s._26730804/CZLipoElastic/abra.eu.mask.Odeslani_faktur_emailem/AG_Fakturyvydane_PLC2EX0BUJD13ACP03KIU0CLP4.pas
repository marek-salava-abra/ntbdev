uses 'abra.eu.mask.Odeslani_faktur_emailem.auto_email', 'EU.Aabra.Mask.Validace.lib';

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
  mAction.Caption := 'Oprava odesílání odeslání faktur';
  mAction.OnExecute := @NewValidateClick;
end;



procedure NewValidateClick(Sender: TComponent);
var
  mSite: TSiteForm;
  mDBGrid : TDBGrid;
  mTabList: TTabSheet;
  mIIs:TStringList;
begin
  mSite := TComponent(sender).DynSite;
  {mTabList := TTabSheet(NxFindChildControl(mSite.MainPanel, 'tabList'));
  if mTabList = nil then
    RaiseException('tabList nenalezen');
  mDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdList'));
  if mDBGrid = nil then
    RaiseException('DBGrid nenalezen');     }
   //NxShowSimpleMessage('jdu odesílat',mSite);
mIIs:=TStringList.create;
try
   mIIs.Add(TDynSiteForm(msite).CurrentObject.OID);

   Zpracovani_dokladu(msite.BaseObjectSpace,True,'',mIIs,true);
finally
   mIIs.free;
end;

end;






begin
end.