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

        mOLE:= GetAbraOLEApplication;
        mOResult:= mOLE.CreateStrings;
        mRoll:= mOLE.GetRoll('O3OWQQYWYJCL3J0B01K0LEIOE0', 0);
                          if not mRoll.MultiSelectDialog(False, mOResult) then Exit;
                                mids:= TStringList.Create;
                                try
                                  mids.Text:= mOResult.Text;


                                  ProgressInit(xsite, 'Zpracování dat ' , 100);
                                      if mBookmark.count=0 then begin
                                                 //if index=0 then begin
                                                                TDynSiteForm(xSite).CurrentObject.SetFieldValueAsString('Firm_ID',mids.Strings[0]);
                                                                TDynSiteForm(xSite).CurrentObject.save;


                                      end else begin
                                           for i := 0 to mBookmark.Count- 1 do begin
                                           ProgressSetPos(1+NxFloor((i/mBookmark.Count)*99), inttostr(i) +' z '+inttostr(mBookmark.Count));
                                                            mDBGrid.DataSource.DataSet.GotoBookmark(mBookMark.items(i));
                                                            TDynSiteForm(xSite).CurrentObject.SetFieldValueAsString('Firm_ID',mids.Strings[0]);
                                                            TDynSiteForm(xSite).CurrentObject.save;

                                           end;
                                      end;
                                  ProgressDispose()

                                 finally
                                    mids.free;
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

  if mUserFilter then begin
        mMAction := Self.GetNewMultiAction;
        mMAction.ShowControl := True;
        mMAction.ShowMenuItem := True;
        mMAction.Caption := 'Změna fakturačních údajů';
        mMAction.Hint := 'Změna fakturačních údajů';
        mMAction.Category := 'tabList';
        mMAction.OnExecuteItem := @NEWSLExecuteItem;
        mMAction.Items.Add('Změna fakturačních údajů');
   end;
end;





begin
end.






