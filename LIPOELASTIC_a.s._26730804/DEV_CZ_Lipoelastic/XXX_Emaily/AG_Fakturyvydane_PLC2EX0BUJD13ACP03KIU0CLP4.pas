uses 'XXX_Emaily.auto_email', 'EU.Aabra.Mask.Validace.lib';

const
  dates_packedGUID = 'AVV1JYV5AVNOZHQCK0D4CJFUCS'; //Aktivita BO
  dates_siteGUID = 'OYC0P3TDDY1ORIJO2SKTP2KZKG';  //Faktury Vydane SITE
var
mSite: TSiteForm;
mHead : TNxHeaderBusinessObject;
mBO_source:TNxCustomBusinessObject     ;





{
Vyvoláva sa po vykonaní inicializácie agendy/formulára. V tomto okamihu je už na formulári dostupný SiteContext.
}
procedure InitSite_Hook(Self: TSiteForm);
var
 muser:TNxCustomBusinessObject;
  mMAction: TMultiAction;
  mCAction: TBasicAction;
  mAList: TActionList;
  i : integer;
  mUserFilter:Boolean;
  mUserFilterTL:string;
begin

          mMAction := Self.GetNewMultiAction;
          mMAction.ShowControl := True;
          mMAction.ShowMenuItem := True;
          mMAction.Hint := 'xxx Odeslání FV i ISDOC';
          mMAction.Caption := 'xxx Odeslání FV i ISDOC';
          mMAction.Items.Add('xxx Odeslání FV i ISDOC');
          mMAction.Category := 'tabList';
          mMAction.OnExecuteItem := @OnExec;


end;




procedure OnExec(Sender: TComponent;index:integer);       // přidělení objectspace a zadání zdrojového souboru
var
  mBO: TNxCustomBusinessObject;
  i : integer;
  mSite: TDynSiteForm;
  mControl : TControl;
  mDBGrid : TDBGrid;
  mBookmark : TBookmarkList;
  mTabList: TTabSheet;
  mid:string;
  mMon:TNxCustomBusinessMonikerCollection;
  mMon_Source: TNxCustomBusinessMonikerCollection;
  mIIs:TStringList;
begin
    mSite := TDynSiteForm(NxFindSiteForm(Sender));
    mTabList := TTabSheet(NxFindChildControl(mSite.MainPanel, 'tabList'));
    mBO := TDynSiteForm(mSite).CurrentObject;
    if mTabList = nil then
        RaiseException('tabList nenalezen');
    mDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdList'));
    if mDBGrid = nil then
        RaiseException('DBGrid nenalezen');
                     try
                    mBookmark := mDBGrid.SelectedRows; // *** v mBookmark jsou id označených záznamu
                            if mBookmark.count=0 then begin
                                        mBO := TDynSiteForm(mSite).CurrentObject;
                                        mIIs:=TStringList.create;
                                              try
                                                 mIIs.Add(TDynSiteForm(msite).CurrentObject.OID);

                                                 Zpracovani_dokladu(msite.BaseObjectSpace,True,'',mIIs,true);
                                              finally
                                                 mIIs.free;
                                              end;

                            end else begin
                               for i := 0 to mBookmark.Count-1 do begin // projdu vsechny oznacene zaznamy
                                        mDBGrid.DataSource.DataSet.GotoBookmark(mBookMark.items(i));
                                        mBO := TDynSiteForm(mSite).CurrentObject;
                                        mIIs:=TStringList.create;
                                              try
                                                 mIIs.Add(TDynSiteForm(msite).CurrentObject.OID);

                                                 Zpracovani_dokladu(msite.BaseObjectSpace,True,'',mIIs,true);
                                              finally
                                                 mIIs.free;
                                              end;

                                end;
                            end;
                   finally
                   end;




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