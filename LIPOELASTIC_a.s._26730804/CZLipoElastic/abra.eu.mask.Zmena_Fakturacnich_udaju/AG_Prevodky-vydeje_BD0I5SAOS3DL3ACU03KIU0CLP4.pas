uses  '_Knihovny_ALL.Progress',
      '_Knihovny_ALL.Parse';





      const
 ladit=false;


procedure NEWSLExecuteItem(Sender: TAction; Index: integer);
var
 mresult:Boolean;
 mBookmark:TBookmarkList;
 mtext:string;
 mbo:TNxCustomBusinessObject;
 mbo_SL:TNxCustomBusinessObject;
 xSite: TDynSiteForm;
 mDBGrid : TDBGrid;
 mTabList: TTabSheet;
 self:TNxCustomBusinessObject;
 i,ii,k,j:integer;
 mr,mr1,mr2,mIDs_MLRow:TStringList;
 mForm: TBusRollSiteForm;
   mMon,mRows_ML: TNxCustomBusinessMonikerCollection;
   mRow, mNewRow,mbo1,mbo_ml_target_row: TNxCustomBusinessObject;
   mdate:Double;
   mr_ML,mrax:tstringlist;
   mOLE, mRoll, mOResult: Variant;
   mids,mids1:TStringList;
   mBO_ml,mbo_target:TNxCustomBusinessObject;
   mstavpomoc:boolean;
   mobjednavka:string;
   mpotvrzeni:string;
   mOLEStore, mRollStore, mOResultStore,mOResult1: Variant;
   mOLEStorecard, mRollStorecard, mOResultStorecard: Variant;
   midsStore,midsStorecard:TStringList;
   mStore_id,mStorecard_ID:string;
   mi:integer;
begin
    xSite := TComponent(Sender).DynSite;
    mTabList := TTabSheet(NxFindChildControl(xSite.MainPanel, 'tabList'));
    if mTabList = nil then RaiseException('tabList nenalezen');
    mDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdList'));
    if mDBGrid = nil then RaiseException('DBGrid nenalezen');
    mBookmark := mDBGrid.SelectedRows; // *** v mBookmark jsou id označených záznamu

    mBO := TDynSiteForm(xSite).CurrentObject;

                                try
                                mobjednavka:='';


                                  ProgressInit(xsite, 'Zpracování dat ' , 100);
                                      if mBookmark.count=0 then begin
                                                 if index=0 then begin
                                                      if NxIsEmptyOID(TDynSiteForm(xSite).CurrentObject.getFieldValueAsString('TransportationType_ID')) then begin
                                                              mobjednavka:=xsite.BaseObjectSpace.SQLSelectFirstAsString('Select max(ro.TransportationType_ID) from Storedocuments2 SD2 join Receivedorders RO on sd2.Provide_ID=ro.id where SD2.Parent_ID=' + quotedstr(mbo.oid)) ;
                                                              if not nxisblank(mobjednavka) then begin
                                                                   TDynSiteForm(xSite).CurrentObject.SetFieldValueAsString('TransportationType_ID',mobjednavka);
                                                              end;
                                                     end;
                                                 end;

                                                                TDynSiteForm(xSite).CurrentObject.save;
                                                              mobjednavka:='';

                                      end else begin
                                           for i := 0 to mBookmark.Count- 1 do begin
                                           ProgressSetPos(1+NxFloor((i/mBookmark.Count)*99), inttostr(i) +' z '+inttostr(mBookmark.Count));
                                                            mDBGrid.DataSource.DataSet.GotoBookmark(mBookMark.items(i));
                                                            if index=0 then begin
                                                            mobjednavka:='';
                                                                       if NxIsEmptyOID(TDynSiteForm(xSite).CurrentObject.getFieldValueAsString('TransportationType_ID')) then begin
                                                                        mobjednavka:=xsite.BaseObjectSpace.SQLSelectFirstAsString('Select max(ro.TransportationType_ID) from Storedocuments2 SD2 join Receivedorders RO on sd2.Provide_ID=ro.id where SD2.Parent_ID=' + quotedstr(mbo.oid)) ;
                                                                        if not nxisblank(mobjednavka) then begin
                                                                             TDynSiteForm(xSite).CurrentObject.SetFieldValueAsString('TransportationType_ID',mobjednavka);
                                                                        end;
                                                                      end;
                                                                      mobjednavka:='';
                                                            end;


                                                            TDynSiteForm(xSite).CurrentObject.save;

                                           end;
                                      end;
                                  ProgressDispose()

                                 finally
                                   // mids.free;
                                 end;


    TDynSiteForm(xSite).ActiveDataSet.RefreshCurrentItem;
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
            if mUser.GetFieldValueAsString('Name')='Buriánková Alena' then mUserFilter:= true;
  finally
    mUser.Free;
  end;

 // if mUserFilter then begin
        mMAction := Self.GetNewMultiAction;
        mMAction.ShowControl := True;
        mMAction.ShowMenuItem := True;
        mMAction.Caption := 'Změna fakturačních údajů';
        mMAction.Hint := 'Změna fakturačních údajů';
        mMAction.Category := 'tabList';
        mMAction.OnExecuteItem := @NEWSLExecuteItem;
        mMAction.Items.Add('Doplnění dopravy');
 //  end;
end;





begin
end.






