

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
  mOLE, mRoll, mOResult: Variant;
  mid:string;
  mids1:TStringList;
begin
      mSite := NxFindSiteForm(Sender);
    mTabList := TTabSheet(NxFindChildControl(mSite.MainPanel, 'tabList'));
    mBO := TBusRollSiteForm(mSite).CurrentObject;
    if mTabList = nil then
        RaiseException('tabList nenalezen');
    mDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdList'));
    if mDBGrid = nil then
        RaiseException('DBGrid nenalezen');
                    if index=0 then begin
                         mid:= inputbox('Doplnění provozovny', 'Doplnění ID provozovny','');

                    end;

                    try
                    mBookmark := mDBGrid.SelectedRows; // *** v mBookmark jsou id označených záznamu
                            if mBookmark.count=0 then begin
                                        mBO := TBusRollSiteForm(mSite).CurrentObject;
                                        if index=0 then mbo.SetFieldValueAsstring('X_Office_ID',mid);
                                        if index=1 then mbo.SetFieldValueAsstring('X_Office_ID','');
                                        mbo.Save;
                                        //TBusRollSiteForm(mSite).CurrentObject.Refresh;
                            end else begin
                               for i := 0 to mBookmark.Count-1 do begin // projdu vsechny oznacene zaznamy
                                        mDBGrid.DataSource.DataSet.GotoBookmark(mBookMark.items(i));
                                              mBO := TBusRollSiteForm(mSite).CurrentObject;
                                            try
                                            //NxShowSimpleMessage(mbo.oid,nil);

                                            if index=0 then mbo.SetFieldValueAsstring('X_Office_ID',mid);
                                            if index=1 then mbo.SetFieldValueAsstring('X_Office_ID','');
                                            mbo.Save;
                                            //TBusRollSiteForm(mSite).CurrentObject.Refresh;
                                       finally

                                       end;

                                end;
                            end;
                   finally
                   end;




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
          mMAction.Hint := 'Provozovna';
          mMAction.Caption := 'Provozovna';
          mMAction.Items.Add('Doplnění provozovny');
          mMAction.Items.Add('Smazání provozovny');
          mMAction.Category := 'tabList';
          mMAction.OnExecuteItem := @OnExec;


end;


begin
end.