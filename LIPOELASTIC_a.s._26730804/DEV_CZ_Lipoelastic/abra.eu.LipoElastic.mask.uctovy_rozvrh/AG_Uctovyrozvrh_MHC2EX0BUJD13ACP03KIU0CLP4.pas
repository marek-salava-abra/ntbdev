

procedure OnExec(Sender: TComponent;index:integer);       // přidělení objectspace a zadání zdrojového souboru
var
    mBO: TNxCustomBusinessObject;
    i : integer;
    mSite: TSiteForm;
  mControl : TControl;
  mDBGrid : TDBGrid;
  mBookmark : TBookmarkList;
  CZ_pomoc_name,EN_pomoc_name:string ;
  mTabList: TTabSheet;
begin
      mSite := NxFindSiteForm(Sender);
    mTabList := TTabSheet(NxFindChildControl(mSite.MainPanel, 'tabList'));
    if mTabList = nil then
        RaiseException('tabList nenalezen');
    mDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdList'));
    if mDBGrid = nil then
        RaiseException('DBGrid nenalezen');
                    try
                    mBookmark := mDBGrid.SelectedRows; // *** v mBookmark jsou id označených záznamu
                            if mBookmark.count=0 then begin
                                        mBO := TBusRollSiteForm(mSite).CurrentObject;
                                        if index=0 then mbo.SetFieldValueAsBoolean('IsIncomplete',False);
                                        if index=1 then mbo.SetFieldValueAsBoolean('IsIncomplete',True);
                                        mbo.Save;
                            end else begin
                               for i := 0 to mBookmark.Count-1 do begin // projdu vsechny oznacene zaznamy
                                        mDBGrid.DataSource.DataSet.GotoBookmark(mBookMark.items(i));
                                              mBO := TBusRollSiteForm(mSite).CurrentObject;
                                            try
                                            //NxShowSimpleMessage(mbo.oid,nil);

                                        if index=0 then mbo.SetFieldValueAsBoolean('IsIncomplete',False);
                                        if index=1 then mbo.SetFieldValueAsBoolean('IsIncomplete',True);
                                        mbo.Save;
                                       finally

                                       end;

                                end;
                            end;
                   finally
                   end;
                 TBusRollSiteForm(mSite).RefreshData;



end;



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
          mMAction.Hint := 'Kompletní účty';
          mMAction.Caption := 'Kompletní účty';
          mMAction.Items.Add('Kompletní účty');
          mMAction.Items.Add('Nekompletní účty');
          //mMAction.Items.Add('Makrokarta');
          mMAction.Category := 'tabList';
          mMAction.OnExecuteItem := @OnExec;


end;


begin
end.