uses  '_Knihovny_ALL.Progress',
      '_Knihovny_ALL.Parse';
var
     mBookmark : TBookmarkList;

procedure NewSQLExecute(Sender: TAction; Index: integer);
var
 mbo,mboSource,mobj,mBOTMP:TNxCustomBusinessObject;
 mSite: TSiteForm;
 mDBGrid : TDBGrid;
 mTabList: TTabSheet;
 i,j,ax,x:integer;
   mForm: TDynSiteForm;
   mtext:string;
   mB_Result:boolean;
   mi:integer;
   mMon,mMonSource:TNxCustomBusinessMonikerCollection;
   mstring:string;
   mr,mlist,mDoclist,mRowList:tstringlist;
   mfind:BOOLEAN;
begin
 // mtext:='Description=' + quotedstr('');
  mSite := NxFindSiteForm(Sender);
    mTabList := TTabSheet(NxFindChildControl(mSite.MainPanel, 'tabList'));
    if mTabList = nil then
        RaiseException('tabList nenalezen');
    mDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdList'));
    if mDBGrid = nil then
        RaiseException('DBGrid nenalezen');
    mBookmark := mDBGrid.SelectedRows; // *** v mBookmark jsou id označených záznamu

  mDoclist:=tstringlist.create;
  mRowList:=tstringlist.create;

  try
  mobj:= TDynSiteForm(mSite).CurrentObject;
  // mdoclist:=TStringList.create;





                   if mBookmark.count=0 then begin
                   mDoclist.add(TDynSiteForm(mSite).CurrentObject.oid);
                 mobj:= TDynSiteForm(mSite).CurrentObject;

                                              mMon := mobj.GetLoadedCollectionMonikerForFieldCode(mobj.GetFieldCode('ROWS'));
                                                ProgressInit(msite, 'Doplnění šarží ' , 100);
                                                  for j:= 0 to mMon.count -1 do begin
                                                       ProgressSetPos(1+NxFloor(j/mMon.count), inttostr(j) +' z '+inttostr(mMon.count));
                                                             mRowList.add(mMon.BusinessObject[j].OID + ';' + NxFloatToIBStr(mMon.BusinessObject[j].GetFieldValueAsFloat('Totalprice')));



                                                  end;
                                                  ProgressDispose();

                                          TDynSiteForm(mSite).ActiveDataSet.RefreshCurrentItem ;



                end else begin
                     for i := 0 to mBookmark.Count- 1 do begin
                                      mDBGrid.DataSource.DataSet.GotoBookmark(mBookMark.items(i));
                                      mobj:= TDynSiteForm(mSite).CurrentObject;

                                      mMon := mobj.GetLoadedCollectionMonikerForFieldCode(mobj.GetFieldCode('ROWS'));
                                                ProgressInit(msite, 'Doplnění šarží ' , 100);
                                                  for j:= 0 to mMon.count -1 do begin
                                                       ProgressSetPos(1+NxFloor(j/mMon.count), inttostr(j) +' z '+inttostr(mMon.count));
























                                                  end;
                                                  ProgressDispose();
                                     TDynSiteForm(mSite).ActiveDataSet.RefreshCurrentItem ;
                     end;

                end;
  finally
     mDoclist.free;
     mRowList.free;
  end;
end;


procedure InitSite_Hook(Self: TDynSiteForm);
var
mAction: TAction;
  mMAction: TMultiAction;
begin

  mmAction := Self.GetNewMultiAction;
  mmAction.ShowControl := True;
  mmAction.ShowMenuItem := True;
 mMAction.Caption := 'Dobropis';
  mMAction.Items.Add('Dobropis');
  mMAction.Hint := 'Vytvoření dobropisu';
  mMAction.Category := 'tabList';
  mmAction.OnExecuteItem:= @NewSQLExecute;



end;


begin
end.