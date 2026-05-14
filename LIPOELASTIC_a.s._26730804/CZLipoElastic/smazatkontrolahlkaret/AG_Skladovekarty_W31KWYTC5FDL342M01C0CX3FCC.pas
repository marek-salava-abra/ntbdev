
procedure xxx(Sender: TComponent;index:integer);       // přidělení objectspace a zadání zdrojového souboru
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


                                    if not NxIsEmptyOID(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_parent_ID')) then begin
                                           if copy(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_parent_ID.X_synchronizace_ID'),3,1)<>'1' then begin

                                                   mBO.load(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_parent_ID'),nil);

                                                          mBO.setFieldValueAsString('X_synchronizace_ID','001000');
                                                          mBO.SetFieldValueAsBoolean('hidden',false)    ;
                                                          mbo.save;
                                            end;
                                    end;
                                    if not NxIsEmptyOID(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_ridici_karta_seskupeni')) then begin
                                           if copy(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_ridici_karta_seskupeni.X_synchronizace_ID'),3,1)<>'1' then begin

                                                   mBO.load(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_ridici_karta_seskupeni'),nil);

                                                          mBO.setFieldValueAsString('X_synchronizace_ID','001000');
                                                          mBO.SetFieldValueAsBoolean('hidden',false)    ;
                                                          mbo.save;
                                            end;
                                    end;



                            end else begin
                               for i := 0 to mBookmark.Count-1 do begin // projdu vsechny oznacene zaznamy
                                        mDBGrid.DataSource.DataSet.GotoBookmark(mBookMark.items(i));

                                    if not NxIsEmptyOID(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_parent_ID')) then begin
                                           if copy(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_parent_ID.X_synchronizace_ID'),3,1)<>'1' then begin

                                                   mBO.load(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_parent_ID'),nil);

                                                          mBO.setFieldValueAsString('X_synchronizace_ID','001000');
                                                          mBO.SetFieldValueAsBoolean('hidden',false)    ;
                                                          mbo.save;
                                            end;
                                    end;
                                    if not NxIsEmptyOID(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_ridici_karta_seskupeni')) then begin
                                           if copy(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_ridici_karta_seskupeni.X_synchronizace_ID'),3,1)<>'1' then begin

                                                   mBO.load(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_ridici_karta_seskupeni'),nil);

                                                          mBO.setFieldValueAsString('X_synchronizace_ID','001000');
                                                          mBO.SetFieldValueAsBoolean('hidden',false)    ;
                                                          mbo.save;
                                            end;
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
        if mUserFilter then begin


          mMAction := Self.GetNewMultiAction;
          mMAction.ShowControl := True;
          mMAction.ShowMenuItem := True;
          mMAction.Hint := 'Synchronizace matek';
          mMAction.Caption := 'Synchronizace matek';
          mMAction.Items.Add('Synchronizace matek');

          mMAction.Category := 'tabList';
          mMAction.OnExecuteItem := @xxx;



      end;
end;


begin
end.