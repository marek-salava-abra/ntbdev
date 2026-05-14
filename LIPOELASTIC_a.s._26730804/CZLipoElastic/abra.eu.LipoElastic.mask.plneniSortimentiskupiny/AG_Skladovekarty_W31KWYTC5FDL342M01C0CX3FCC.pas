
procedure OnExec(Sender: TComponent;index:integer);       // přidělení objectspace a zadání zdrojového souboru
var
    mBO: TNxCustomBusinessObject;
    i : integer;
  mSite: TSiteForm;
  mbookmark:TBookmarkList;
  mdbgrid:TDBGrid;
  mr,mx:tstringlist;
  mBO_Batch,mBO_SubBatch,mBO_storesubcards:TNxCustomBusinessObject;
  mID_batch:string;

 mTabList: TTabSheet;
 mStoreAssortmentGroup_ID:string;
begin
    if Sender is TComponent then begin
          mSite := NxFindSiteForm(Sender);

          if Assigned(mSite) and (mSite is TBusRollSiteForm) then begin
               mTabList := TTabSheet(NxFindChildControl(mSite.MainPanel, 'tabList'));
                  if mTabList = nil then
                      RaiseException('tabList nenalezen');
                  mDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdList'));
                  if mDBGrid = nil then
                      RaiseException('DBGrid nenalezen');
                  mBookmark := mDBGrid.SelectedRows; // *** v mBookmark jsou id označených záznamu


               mbo:= TBusRollSiteForm(mSite).CurrentObject;
                    try
                            if mBookmark.count=0 then begin
                                        mBO := TBusRollSiteForm(mSite).CurrentObject;
                                        mStoreAssortmentGroup_ID:='';
                                        if (mStoreAssortmentGroup_ID='') and ( not nxisemptyoid(mbo.GetFieldValueAsString('StoreAssortmentGroup_ID.PArent_id.PArent_id.PArent_id.PArent_id.PArent_id.PArent_id.PArent_id'))) then mStoreAssortmentGroup_ID:= mbo.GetFieldValueAsString('StoreAssortmentGroup_ID.PArent_id.PArent_id.PArent_id.PArent_id.PArent_id.PArent_id.PArent_id')   ;
                                        if (mStoreAssortmentGroup_ID='') and ( not nxisemptyoid(mbo.GetFieldValueAsString('StoreAssortmentGroup_ID.PArent_id.PArent_id.PArent_id.PArent_id.PArent_id.PArent_id'))) then mStoreAssortmentGroup_ID:= mbo.GetFieldValueAsString('StoreAssortmentGroup_ID.PArent_id.PArent_id.PArent_id.PArent_id.PArent_id.PArent_id')   ;
                                        if (mStoreAssortmentGroup_ID='') and ( not nxisemptyoid(mbo.GetFieldValueAsString('StoreAssortmentGroup_ID.PArent_id.PArent_id.PArent_id.PArent_id.PArent_id'))) then mStoreAssortmentGroup_ID:= mbo.GetFieldValueAsString('StoreAssortmentGroup_ID.PArent_id.PArent_id.PArent_id.PArent_id.PArent_id')   ;
                                        if (mStoreAssortmentGroup_ID='') and ( not nxisemptyoid(mbo.GetFieldValueAsString('StoreAssortmentGroup_ID.PArent_id.PArent_id.PArent_id.PArent_id'))) then mStoreAssortmentGroup_ID:= mbo.GetFieldValueAsString('StoreAssortmentGroup_ID.PArent_id.PArent_id.PArent_id.PArent_id')   ;
                                        if (mStoreAssortmentGroup_ID='') and ( not nxisemptyoid(mbo.GetFieldValueAsString('StoreAssortmentGroup_ID.PArent_id.PArent_id.PArent_id'))) then mStoreAssortmentGroup_ID:= mbo.GetFieldValueAsString('StoreAssortmentGroup_ID.PArent_id.PArent_id.PArent_id')   ;
                                        if (mStoreAssortmentGroup_ID='') and ( not nxisemptyoid(mbo.GetFieldValueAsString('StoreAssortmentGroup_ID.PArent_id.PArent_id'))) then mStoreAssortmentGroup_ID:= mbo.GetFieldValueAsString('StoreAssortmentGroup_ID.PArent_id.PArent_id')   ;
                                        if (mStoreAssortmentGroup_ID='') and ( not nxisemptyoid(mbo.GetFieldValueAsString('StoreAssortmentGroup_ID.PArent_id'))) then mStoreAssortmentGroup_ID:= mbo.GetFieldValueAsString('StoreAssortmentGroup_ID.PArent_id')   ;
                                        if (mStoreAssortmentGroup_ID='') and ( not nxisemptyoid(mbo.GetFieldValueAsString('StoreAssortmentGroup_ID'))) then mStoreAssortmentGroup_ID:= mbo.GetFieldValueAsString('StoreAssortmentGroup_ID')   ;
                                        if mStoreAssortmentGroup_ID<>'' then begin
                                             mbo.SetFieldValueAsString('X_StoreAssortmentGroup_ID',mStoreAssortmentGroup_ID);
                                             mbo.save;
                                        end;
                            end else begin
                               for i := 0 to mBookmark.Count-1 do begin // projdu vsechny oznacene zaznamy
                                        mDBGrid.DataSource.DataSet.GotoBookmark(mBookMark.items(i));
                                        mBO := TBusRollSiteForm(mSite).CurrentObject;




                                        mStoreAssortmentGroup_ID:='';
                                        if (mStoreAssortmentGroup_ID='') and ( not nxisemptyoid(mbo.GetFieldValueAsString('StoreAssortmentGroup_ID.PArent_id.PArent_id.PArent_id.PArent_id.PArent_id.PArent_id.PArent_id'))) then mStoreAssortmentGroup_ID:= mbo.GetFieldValueAsString('StoreAssortmentGroup_ID.PArent_id.PArent_id.PArent_id.PArent_id.PArent_id.PArent_id.PArent_id')   ;
                                        if (mStoreAssortmentGroup_ID='') and ( not nxisemptyoid(mbo.GetFieldValueAsString('StoreAssortmentGroup_ID.PArent_id.PArent_id.PArent_id.PArent_id.PArent_id.PArent_id'))) then mStoreAssortmentGroup_ID:= mbo.GetFieldValueAsString('StoreAssortmentGroup_ID.PArent_id.PArent_id.PArent_id.PArent_id.PArent_id.PArent_id')   ;
                                        if (mStoreAssortmentGroup_ID='') and ( not nxisemptyoid(mbo.GetFieldValueAsString('StoreAssortmentGroup_ID.PArent_id.PArent_id.PArent_id.PArent_id.PArent_id'))) then mStoreAssortmentGroup_ID:= mbo.GetFieldValueAsString('StoreAssortmentGroup_ID.PArent_id.PArent_id.PArent_id.PArent_id.PArent_id')   ;
                                        if (mStoreAssortmentGroup_ID='') and ( not nxisemptyoid(mbo.GetFieldValueAsString('StoreAssortmentGroup_ID.PArent_id.PArent_id.PArent_id.PArent_id'))) then mStoreAssortmentGroup_ID:= mbo.GetFieldValueAsString('StoreAssortmentGroup_ID.PArent_id.PArent_id.PArent_id.PArent_id')   ;
                                        if (mStoreAssortmentGroup_ID='') and ( not nxisemptyoid(mbo.GetFieldValueAsString('StoreAssortmentGroup_ID.PArent_id.PArent_id.PArent_id'))) then mStoreAssortmentGroup_ID:= mbo.GetFieldValueAsString('StoreAssortmentGroup_ID.PArent_id.PArent_id.PArent_id')   ;
                                        if (mStoreAssortmentGroup_ID='') and ( not nxisemptyoid(mbo.GetFieldValueAsString('StoreAssortmentGroup_ID.PArent_id.PArent_id'))) then mStoreAssortmentGroup_ID:= mbo.GetFieldValueAsString('StoreAssortmentGroup_ID.PArent_id.PArent_id')   ;
                                        if (mStoreAssortmentGroup_ID='') and ( not nxisemptyoid(mbo.GetFieldValueAsString('StoreAssortmentGroup_ID.PArent_id'))) then mStoreAssortmentGroup_ID:= mbo.GetFieldValueAsString('StoreAssortmentGroup_ID.PArent_id')   ;
                                        if (mStoreAssortmentGroup_ID='') and ( not nxisemptyoid(mbo.GetFieldValueAsString('StoreAssortmentGroup_ID'))) then mStoreAssortmentGroup_ID:= mbo.GetFieldValueAsString('StoreAssortmentGroup_ID')   ;
                                        if mStoreAssortmentGroup_ID<>'' then begin
                                          //   NxShowSimpleMessage(mStoreAssortmentGroup_ID,nil);

                                             mbo.SetFieldValueAsString('X_StoreAssortmentGroup_ID',mStoreAssortmentGroup_ID);
                                             mbo.save;
                                        end;

                                end;
                            end;
                   finally
                   end;
                 TBusRollSiteForm(mSite).RefreshData;



            end;
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
    mUserFilter:=true;
    mUser := Self.BaseObjectSpace.CreateObject('22AHIVDVAVE13C5S00CA141B44');
    try
      mUser.Load(Self.CompanyCache.GetUserID, nil);
            mUserFilter:= mUser.GetFieldValueAsBoolean('X_ChangeStoreCtaegory');

    finally
      mUser.Free;
    end;
  {    //  if mUserFilter then begin
          mMAction := Self.GetNewMultiAction;
          mMAction.ShowControl := True;
          mMAction.ShowMenuItem := True;
          mMAction.Hint := 'Sortimentni skupina';
          mMAction.Caption := 'Sortimentni skupina';
          mMAction.Items.Add('Sortimentni skupina');
          mMAction.Category := 'tabList';
          mMAction.OnExecuteItem := @OnExec;



    //  end;    }
end;


begin
end.