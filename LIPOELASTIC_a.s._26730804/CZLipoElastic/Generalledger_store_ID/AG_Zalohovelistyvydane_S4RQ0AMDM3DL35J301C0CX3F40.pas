uses '_Knihovny_ALL.Progress','_Knihovny_ALL.Parse';



procedure OnExec(Sender: TComponent;index:integer);       // přidělení objectspace a zadání zdrojového souboru
var
    mBO: TNxCustomBusinessObject;
    i : integer;
  mSite: TSiteForm;
  mbookmark:TBookmarkList;
  mdbgrid:TDBGrid;
  mstring:string;
  mTabList: TTabSheet;
begin

   if Sender is TComponent then begin
          mSite := NxFindSiteForm(Sender);

          if Assigned(mSite) and (mSite is TDynSiteForm) then begin
               mTabList := TTabSheet(NxFindChildControl(mSite.MainPanel, 'tabList'));
                  if mTabList = nil then
                      RaiseException('tabList nenalezen');
                  mDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdList'));
                  if mDBGrid = nil then
                      RaiseException('DBGrid nenalezen');

     if index=1 then mstring:= AppendStore_ID(msite.BaseObjectSpace,mBO,index,msite) ;
     if index=0 then begin
                  mBookmark := mDBGrid.SelectedRows; // *** v mBookmark jsou id označených záznamu


                    try

                            if mBookmark.count=0 then begin
                                        mBO := TDynSiteForm(mSite).CurrentObject;
                                        AppendStore_ID(msite.BaseObjectSpace,mbo,index,msite) ;
                            end else begin
                               ProgressInit(msite, 'Zpracování označených  ' +  IntToStr(mBookmark.Count-1), 100);
                               for i := 0 to mBookmark.Count-1 do begin // projdu vsechny oznacene zaznamy
                                        mDBGrid.DataSource.DataSet.GotoBookmark(mBookMark.items(i));
                                              ProgressSetPos(1+NxFloor(i/mBookmark.Count*99), inttostr(i) +' z '+inttostr(mBookmark.Count));
                                              mBO := TDynSiteForm(mSite).CurrentObject;
                                               AppendStore_ID(msite.BaseObjectSpace,mBO,index,msite) ;

                                end;
                                ProgressDispose()   ;
                            end;
                   finally
                   end;
               //  TDynSiteForm(mSite).RefreshData;



            end;
      end;
    end;
    NxShowSimpleMessage('Úloha doběhla', nil);
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
    //    if mUserFilter then begin
          mMAction := Self.GetNewMultiAction;
          mMAction.ShowControl := True;
          mMAction.ShowMenuItem := True;
          mMAction.Hint := 'Dopln sklad ';
          mMAction.Caption := 'Dopln sklad ';
          mMAction.Items.Add('dopln sklad vybrane');
          mMAction.Items.Add('dopln sklad vše ');


          mMAction.Category := 'tabList';
          mMAction.OnExecuteItem := @OnExec;




    //  end;
end;

















Function AppendStore_ID(os:TNxCustomObjectSpace;self:TNxCustomBusinessObject;index:integer;mSite:TSiteForm):string;
var
  mr:tstringlist;
  mi,i:integer;
begin
   if index=0 then begin
           mr:=TStringList.create;
            try
                  os.SQLSelect('select a.id||sd2.store_id from GeneralLedger A LEFT JOIN AccDocQueues ADQ ON ADQ.ID=A.AccDocQueue_ID LEFT JOIN Relations R ON R.RightSide_ID = A.ID '
                              + ' join relations Re on A.id=re.rightside_id join storedocuments2 sd2 on sd2.Parent_id=re.leftside_id '


                      + ' WHERE (A.AccDocQueue_ID IN (SELECT ID FROM  AccDocQueues WHERE DocumentType IN ('
                      +quotedstr('20') + ',' + quotedstr('21') + ',' + quotedstr('22') + ',' + quotedstr('23') + ',' + quotedstr('24') + ','
                      +quotedstr('25') + ',' + quotedstr('26') + ',' + quotedstr('27') + ',' + quotedstr('28') + ',' + quotedstr('29') + ','
                      +quotedstr('30') + ',' + quotedstr('36') + ',' + quotedstr('37') + ',' + quotedstr('38') + ',' + quotedstr('39') +'))) and a.X_store_ID is null'
                       + ' and a.id=' + quotedstr(self.oid)
                       ,mr);
                      if mr.count>0 then begin
                              for i:=0 to mr.count-1 do begin
                                  mi:=os.SQLExecute('update GeneralLedger set X_store_ID=' + QuotedStr(copy(mr.Strings[i],11,10)) + ' where id=' + quotedstr(copy(mr.Strings[i],1,10)))
                              end;

                      end;

            finally
                mr.free;
            end;
   end;


   if index=1 then begin

            mr:=TStringList.create;
            try
                  os.SQLSelect('select a.id||sd2.store_id from GeneralLedger A LEFT JOIN AccDocQueues ADQ ON ADQ.ID=A.AccDocQueue_ID LEFT JOIN Relations R ON R.RightSide_ID = A.ID '
                              + ' join relations Re on A.id=re.rightside_id join storedocuments2 sd2 on sd2.Parent_id=re.leftside_id '


                      + ' WHERE (A.AccDocQueue_ID IN (SELECT ID FROM  AccDocQueues WHERE DocumentType IN ('
                      +quotedstr('20') + ',' + quotedstr('21') + ',' + quotedstr('22') + ',' + quotedstr('23') + ',' + quotedstr('24') + ','
                      +quotedstr('25') + ',' + quotedstr('26') + ',' + quotedstr('27') + ',' + quotedstr('28') + ',' + quotedstr('29') + ','
                      +quotedstr('30') + ',' + quotedstr('36') + ',' + quotedstr('37') + ',' + quotedstr('38') + ',' + quotedstr('39') +'))) and a.X_store_ID is null'
                      +' and sd2.rowtype=3'
                      //+' and (A.AccDate$DATE >= 44560 and A.AccDate$DATE < 44891)'
                      ,mr);
                      if mr.count>0 then begin
                              //NxShowSimpleMessage(copy(mr.Strings[0],1,10) + '   -   ' + copy(mr.Strings[0],11,10) ,nil);
                              ProgressInit(msite, 'Zpracování NEVYPLNĚNÝCH  ' +  IntToStr(mr.Count-1), 100);
                              for i:=0 to mr.count-1 do begin
                                  ProgressSetPos(1+NxFloor(i/mr.Count*99), inttostr(i) +' z '+inttostr(mr.Count));
                                  mi:=os.SQLExecute('update GeneralLedger set X_store_ID=' + QuotedStr(copy(mr.Strings[i],11,10)) + ' where id=' + quotedstr(copy(mr.Strings[i],1,10))) ;
                              end;
                              ProgressDispose()   ;
                      end;
            finally
                mr.free;
            end;
   end;
end;


begin
end.