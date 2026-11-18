uses  '_Knihovny_ALL.Progress',
      '_Knihovny_ALL.Parse';

var
    result:boolean;
    mresult:boolean;
    mBookmark : TBookmarkList;
    mBustrasaction_ID:string;



procedure mLogstik(Sender: TAction; Index: integer);
var
 mresult:Boolean;
 mbo:TNxCustomBusinessObject;
 mSite: TSiteForm;
 mDBGrid : TDBGrid;
 mTabList: TTabSheet;
  mr:TStringList;
  i:integer;
  mUser:string;
  mi:integer;
begin
  mSite := NxFindSiteForm(Sender);
    mTabList := TTabSheet(NxFindChildControl(mSite.MainPanel, 'tabList'));
    if mTabList = nil then
        RaiseException('tabList nenalezen');
    mDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdList'));
    if mDBGrid = nil then
        RaiseException('DBGrid nenalezen');
    mBookmark := mDBGrid.SelectedRows; // *** v mBookmark jsou id označených záznamu
   if index=0 then msite.SiteContext.GetCompanyCache.GetUserID    ;

              if mBookmark.count=0 then begin
                mi:=msite.BaseObjectSpace.SQLExecute('update receivedorders set X_Logistik_ID=' + QuotedStr(muser) + ' WHERE id=' + QuotedStr(TDynSiteForm(msite).CurrentObject.oid));

                NxShowSimpleMessage(msite.SiteContext.GetCompanyCache.GetUserID,nil);
                TDynSiteForm(msite).ActiveDataSet.RefreshCurrentItem;
              end else begin
                   ProgressInit(msite, 'Zpracování souboru ' + '', 100);
                   for i := 0 to mBookmark.Count- 1 do begin
                                    ProgressSetPos(1+NxFloor(i/mBookmark.Count*99), inttostr(i) +' z '+inttostr(mBookmark.Count));
                                    mDBGrid.DataSource.DataSet.GotoBookmark(mBookMark.items(i));
                                    NxShowSimpleMessage(msite.SiteContext.GetCompanyCache.GetUserID,nil);
                                    mi:=msite.BaseObjectSpace.SQLExecute('update receivedorders set X_Logistik_ID=' + QuotedStr(muser) + ' WHERE id=' + QuotedStr(TDynSiteForm(msite).CurrentObject.oid));

                                   TDynSiteForm(msite).ActiveDataSet.RefreshCurrentItem;

                   end;
                   ProgressDispose()   ;
              end;

              TDynSiteForm(msite).RefreshData;
              TDynSiteForm(msite).Refresh;
end;




procedure InitSite_Hook(Self: TSiteForm);
var
mAction: TAction;
  mMAction: TMultiAction;
  mUserFilter: Boolean;
  mUser: TNxCustomBusinessObject;
begin
  mUserFilter:=false;
  mUser := Self.BaseObjectSpace.CreateObject('22AHIVDVAVE13C5S00CA141B44');            // přihlášený uživatel
  try
      mUser.Load(Self.CompanyCache.GetUserID, nil);
            if mUser.GetFieldValueAsString('Name')='Supervisor' then begin
             {   mmAction := Self.GetNewMultiAction;
                mmAction.ShowControl := True;
                mmAction.ShowMenuItem := True;
                mmAction.Caption := 'Logistik';
                mmAction.Hint := 'Logistik';
                mmAction.Category := 'tabList';
                mMAction.Items.Add('Aktuální uživatel');
                mMAction.Items.Add('Výber uživatele ');
                mmAction.OnExecuteItem:= @mLogstik;
               }

            end;
            mUserFilter:= true;
  finally
    mUser.Free;
  end;




end;

begin
end.