Var
    mSite: TSiteForm;
    mDBGrid : TDBGrid;
    mTabList: TTabSheet;
    mCustomBusinessObject: TNxCustomBusinessObject;

    mHeaderBusinessObject : TNxHeaderBusinessObject;
    i : integer;
    mResult:Boolean;
    mBookmarkList:TBookmarkList ;
    aid:string;

procedure OnExec(Sender: TComponent;index:integer;);       // přidělení objectspace a zadání zdrojového souboru
var
mi,i,ii:integer;
mr: tstringlist;
mIDS:string ;
mMon:TNxCustomBusinessMonikerCollection;
begin
        mSite := NxFindSiteForm(Sender);
        mTabList := TTabSheet(NxFindChildControl(mSite.MainPanel, 'tabList'));
        if mTabList = nil then RaiseException('tabList nenalezen');
        mDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdList'));
        if mDBGrid = nil then RaiseException('DBGrid nenalezen');

        mBookmarkList := mDBGrid.SelectedRows; // *** v mBookmark jsou id označených záznamu

          if mBookmarkList.count=0 then begin
                  mCustomBusinessObject:= TDynSiteForm(mSite).CurrentObject;
                  mMon := mCustomBusinessObject.GetLoadedCollectionMonikerForFieldCode(mCustomBusinessObject.GetFieldCode('ROWS'));

                      for ii := 0 to mMon.Count-1 do begin
                        if mMon.BusinessObject[ii].GetFieldValueAsInteger('Rowtype')= 3 then begin
                            if not NxIsEmptyOID(mMon.BusinessObject[ii].GetFieldValueAsString('Storecard_ID.X_store_id')) then begin
                                 mMon.BusinessObject[ii].setFieldValueAsstring('Store_id',mMon.BusinessObject[ii].GetFieldValueAsstring('Storecard_ID.X_store_id')) ;
                            end;
                        end;

                      end;

                mCustomBusinessObject.save;





        end else begin
             for i := 0 to mBookmarkList.Count-1 do begin // projdu vsechny oznacene zaznamy
                  mDBGrid.DataSource.DataSet.GotoBookmark(mBookmarkList.items(i));

                  mCustomBusinessObject:= TDynSiteForm(mSite).CurrentObject;
                  mMon := mCustomBusinessObject.GetLoadedCollectionMonikerForFieldCode(mCustomBusinessObject.GetFieldCode('ROWS'));

                      for ii := 0 to mMon.Count-1 do begin
                        if mMon.BusinessObject[ii].GetFieldValueAsInteger('Rowtype')= 3 then begin
                            if not NxIsEmptyOID(mMon.BusinessObject[ii].GetFieldValueAsstring('Storecard_ID.X_store_id')) then begin
                                 mMon.BusinessObject[ii].setFieldValueAsstring('Store_id',mMon.BusinessObject[ii].GetFieldValueAsstring('Storecard_ID.X_store_id')) ;
                            end;
                        end;

                      end;

                mCustomBusinessObject.save;


             end;
        end;

        msite.Refresh;
        mDBGrid.Refresh;
        mDBGrid.DataSource.DataSet.Refresh;
end;




procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TBasicAction;
  mMAction: TMultiAction;
  mCAction: TBasicAction;
  mAList: TActionList;
  i : integer;
  mUserFilter:Boolean;
  mUserFilterTL:string;
  muser:TNxCustomBusinessObject;
begin
          mMAction := Self.GetNewMultiAction;
          mMAction.ShowControl := True;
          mMAction.ShowMenuItem := True;
          mMAction.Hint := 'Změna skladu 771';
          mMAction.Caption := 'Změna skladu 771';
          mMAction.Items.Add('Změna skladu 771');
          mMAction.Category := 'tabList';
          mMAction.OnExecuteItem := @OnExec;

end;



begin
end.