{
Vyvolává se po provedení inicializace agendy/formuláře. V tento okamžik je již na formuláři dostupný SiteContext.
}
procedure InitSite_Hook(Self: TSiteForm);
var
 mAction: TAction;
  mMAction: TMultiAction;
begin
  mMAction := Self.GetNewMultiAction;
  mMAction.ShowControl := True;
  mMAction.ShowMenuItem := True;
  mMAction.Caption := 'Zápis SQL execute';
  mMAction.Items.Add('Hlavička');
 // mMAction.Items.Add('Řádek');
 // mMAction.Items.Add('Šarže');
  mMAction.Hint := 'SQL EXECUTE pro vybrané doklady';
  mMAction.Category := 'tabList';
  mMAction.OnExecute := @NewSQLExecute;
 // mMAction.OnUpdate := @NewDLUpdate;
end;



procedure NewSQLExecute(Sender: TComponent;index:integer);
var
  mSite: TBusRollSiteForm;
  mObj: TNxCustomBusinessObject;
  mID: string;
  mMon,mDocBatchRows: TNxCustomBusinessMonikerCollection;
  mi,i,ii:integer;
  mstring:string;
   mDBGrid : TDBGrid;
  mBookmark : TBookmarkList;
  mTabList: TTabSheet;
begin
  if Sender is TComponent then begin
    //OutputDebugString('Sender je TComponent.');
    mSite := TComponent(Sender).BusRollSite;
    //OutputDebugString('Nalezen nadřízený SiteForm.');

    // Ziskame aktualni objekt (TNxCustomBusinessObject)



  //  mstring:='(select max(SD2.STORECARD_id)
//from StoreBatches SB
//   joIn docrowbatches DRB on drb.Storebatch_id=sb.ID
//   JOIN STOREDOCUMENTS2 SD2 ON SD2.ID=DRB.pARENT_id
//   WHERE SD2.STORECARD_id<>SB.STORECARD_id and a.id=sb.id
//    )


    mstring:=InputBox('Zadej klauzuli pro SQL Execute', 'SET ' , mstring);

    mTabList := TTabSheet(NxFindChildControl(mSite.MainPanel, 'tabList'));
    if mTabList = nil then
        RaiseException('tabList nenalezen');
    mDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdList'));
    if mDBGrid = nil then
        RaiseException('DBGrid nenalezen');
                    mBookmark := mDBGrid.SelectedRows; // *** v mBookmark jsou id označených záznamu
                            if mBookmark.count=0 then begin
                                      mObj := mSite.CurrentObject;
                                      try
                                        if Assigned(mObj) then begin
                                               mi:=TBusRollSiteForm(msite).BaseObjectSpace.SQLExecute('Update Storecards set ' + mstring + ' where id=' + QuotedStr(mobj.oid))
                                        end;
                                      finally
                                        mObj.Free;
                                      end;
                             end else begin
                               for i := 0 to mBookmark.Count-1 do begin // projdu vsechny oznacene zaznamy
                                        mDBGrid.DataSource.DataSet.GotoBookmark(mBookMark.items(i));
                                              mObj := TBusRollSiteForm(mSite).CurrentObject;
                                              try
                                        if Assigned(mObj) then begin
                                               mi:=TBusRollSiteForm(msite).BaseObjectSpace.SQLExecute('Update Storecards set ' + mstring + ' where id=' + QuotedStr(mobj.oid))
                                        end;
                                      finally
                                        mObj.Free;
                                      end;
                               end;
                            end;
  end;
end;






begin
end.