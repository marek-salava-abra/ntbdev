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
   mr,mlist,mlistprice,mdoclist:tstringlist;
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
  mobj:= TDynSiteForm(mSite).CurrentObject;
  // mdoclist:=TStringList.create;

 try
   //while mtext<> '' do begin
    mB_Result:=InputQuery('Zadaj parametry', 'Vratka ', mtext);
    //   if mtext<>'' then mdoclist.Add(mtext);

   //end;


    mlist:=tstringlist.create;
    mlistprice:=tstringlist.create;



     mboSource:=msite.BaseObjectSpace.CreateObject('3OKSI2XXYK2OB2JRPZ3U4UXTGK');

               try


                          //   for ax:=0 to mdoclist.count-1 do begin
                          //         mboSource.load(mdoclist.Strings[ax],nil);
                          mboSource.load(mtext,nil);
                                        mMonSource := mboSource.GetLoadedCollectionMonikerForFieldCode(mboSource.GetFieldCode('ROWS'));
                                        for j:= 0 to mMonSource.count -1 do begin
                                            mlist.add(mMonSource.BusinessObject[j].GetFieldValueAsString('Storecard_id.code'));
                                            mlistprice.add(
                                            //mMonSource.BusinessObject[j].oid                                            //+
                                            //               mMonSource.BusinessObject[j].GetFieldValueAsString('Storecard_id') +
                                                           NxFloatToIBStr(mMonSource.BusinessObject[j].GetFieldValueAsFloat('TAmount'))
                                            )                                            ;
                                        end;

                          //   end;



                 finally
                     mboSource.free;
                 end;

     if mBookmark.count=0 then begin
                 mobj:= TDynSiteForm(mSite).CurrentObject;

                                              mMon := mobj.GetLoadedCollectionMonikerForFieldCode(mobj.GetFieldCode('ROWS'));
                                                ProgressInit(msite, 'Doplnění šarží ' , 100);
                                                  for j:= 0 to mMon.count -1 do begin
                                                       ProgressSetPos(1+NxFloor(j/mMon.count), inttostr(j) +' z '+inttostr(mMon.count));

                                                                mFind:=false;

                                                                     for x:=0 to mlist.count-1 do begin

                                                                         if pos(mlist.Strings[x],mMon.BusinessObject[j].GetFieldValueAsString('Text')) > 0 then begin
                                                                             mfind:=true;
                                                                             //mMonSource.BusinessObject[j].setFieldValueAsstring('X_ProvideRow_ID',copy(mlistprice.Strings[x],1,10));
                                                                             //mMonSource.BusinessObject[j].setFieldValueAsstring('X_Storecard_ID',copy(mlistprice.Strings[x],11,10));
                                                                             mMonSource.BusinessObject[j].setFieldValueAsFloat('TAmount',NxIBStrToFloat(copy(mlistprice.Strings[x],21,10)));
                                                                             //NxShowSimpleMessage('Nalezeno',nil);
                                                                         end;
                                                                     end;
                                                          if not mfind then mMon.BusinessObject[j].MarkForDelete;

                                                  end;
                                                  ProgressDispose();
                                          mobj.save;
                                          TDynSiteForm(mSite).ActiveDataSet.RefreshCurrentItem ;



                end else begin
                     for i := 0 to mBookmark.Count- 1 do begin
                                      mDBGrid.DataSource.DataSet.GotoBookmark(mBookMark.items(i));
                                      mobj:= TDynSiteForm(mSite).CurrentObject;

                                      mMon := mobj.GetLoadedCollectionMonikerForFieldCode(mobj.GetFieldCode('ROWS'));
                                                ProgressInit(msite, 'Doplnění šarží ' , 100);
                                                  for j:= 0 to mMon.count -1 do begin
                                                       ProgressSetPos(1+NxFloor(j/mMon.count), inttostr(j) +' z '+inttostr(mMon.count));

                                                                 mFind:=false;

                                                                     for x:=0 to mlist.count-1 do begin

                                                                         if pos(mlist.Strings[x],mMon.BusinessObject[j].GetFieldValueAsString('Text')) > 0 then begin
                                                                             mfind:=true;
                                                                            // mMonSource.BusinessObject[j].setFieldValueAsstring('X_ProvideRow_ID',copy(mlistprice.Strings[x],1,10));
                                                                            // mMonSource.BusinessObject[j].setFieldValueAsstring('X_Storecard_ID',copy(mlistprice.Strings[x],11,10));
                                                                             mMonSource.BusinessObject[j].setFieldValueAsFloat('TAmount',NxIBStrToFloat(copy(mlistprice.Strings[x],21,10)));
                                                                             //NxShowSimpleMessage('Nalezeno',nil);
                                                                         end;
                                                                     end;
                                                          if not mfind then mMon.BusinessObject[j].MarkForDelete;

                                                  end;
                                                  ProgressDispose();
                                     mobj.save;
                                     TDynSiteForm(mSite).ActiveDataSet.RefreshCurrentItem ;
                     end;

                end;



     finally
          mlist.free;
          mlistprice.free;
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
 mMAction.Caption := 'Dohledání položek';
  mMAction.Items.Add('Hlavička');
  mMAction.Hint := 'dohledání položek';
  mMAction.Category := 'tabList';
  mMAction.Items.Add('Intrastat dodací podmínky');

  mmAction.OnExecuteItem:= @NewSQLExecute;



end;


begin
end.

