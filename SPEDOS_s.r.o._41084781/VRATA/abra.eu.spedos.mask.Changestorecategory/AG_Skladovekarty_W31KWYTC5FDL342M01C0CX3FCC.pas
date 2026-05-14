procedure ChangeCategory(Sender: TAction;index:integer);
var
msite:TBusRollSiteForm;
mBo:TNxCustomBusinessObject;
i:integer;
msleva:string;
mresult:boolean;
mrow:TNxCustomBusinessObject;
mMat,mPrac:boolean;
mi,mI_ML:integer;
 mDBGrid : TDBGrid;
mTabList: TTabSheet;
mBookmark : TBookmarkList;
mr:tstringlist;
begin
  mSite := TComponent(Sender).BusRollSite;
    mSite := TComponent(Sender).BusRollSite;
    mTabList := TTabSheet(NxFindChildControl(mSite.MainPanel, 'tabList'));
    if mTabList = nil then RaiseException('tabList nenalezen');
    mDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdList'));
    if mDBGrid = nil then RaiseException('DBGrid nenalezen');
    mBookmark := mDBGrid.SelectedRows; // *** v mBookmark jsou id označených záznamu
    if mBookmark.count=0 then begin
                      if index=0 then begin
                                    mr:=TStringList.create;
                                    try
                                         msite.BaseObjectSpace.SQLSelect('select sum(quantity) from StoreSubCards where storecard_ID=' + quotedstr(TBusRollSiteForm(msite).CurrentObject.oid),mr);
                                         if  NxIBStrToFloat(mr.Strings[0])>0 then begin
                                             NxShowSimpleMessage('Na skladové kartě je množství, kartu nelze změnit.',nil);
                                         end else begin
                                             mi:=msite.BaseObjectSpace.SQLExecute('update Storecards set Category=' + quotedstr(inttostr(index)) + ' where id=' + quotedstr(TBusRollSiteForm(msite).CurrentObject.oid));
                                         end;
                                    finally
                                          mr.free;
                                    end;
                               end;

                               if (index=1) or (index=2) then begin
                                  mr:=TStringList.create;
                                    try
                                         msite.BaseObjectSpace.SQLSelect('select sum(quantity) from StoreSubBatches where storecard_ID=' + quotedstr(TBusRollSiteForm(msite).CurrentObject.oid),mr);
                                         if  NxIBStrToFloat(mr.Strings[0])>0 then begin
                                             NxShowSimpleMessage('Na šaržích/SN je množství, kartu nelze změnit.',nil);
                                         end else begin
                                             mi:=msite.BaseObjectSpace.SQLExecute('update Storecards set Category=' + quotedstr(inttostr(index)) + ' where id=' + quotedstr(TBusRollSiteForm(msite).CurrentObject.oid));
                                         end;
                                    finally
                                          mr.free;
                                    end;
                               end;

           //mi:=msite.BaseObjectSpace.SQLExecute('update Storecards set Category=' + quotedstr(inttostr(index)) + ' where id=' + quotedstr(TBusRollSiteForm(msite).CurrentObject.oid));
    end else begin


             for mI_ML:= 0 to mBookmark.Count-1 do begin // projdu vsechny oznacene zaznamy
                  mDBGrid.DataSource.DataSet.GotoBookmark(mBookMark.items(mI_ML));
                               if index=0 then begin
                                    mr:=TStringList.create;
                                    try
                                         msite.BaseObjectSpace.SQLSelect('selecc sum(quantity) from StoreSubCards where storecard_ID=' + quotedstr(TBusRollSiteForm(msite).CurrentObject.oid),mr);
                                         if  NxIBStrToFloat(mr.Strings[0])>0 then begin
                                             NxShowSimpleMessage('Na skladové kartě je množství, kartu nelze změnit.',nil);
                                         end else begin
                                             mi:=msite.BaseObjectSpace.SQLExecute('update Storecards set Category=' + quotedstr(inttostr(index)) + ' where id=' + quotedstr(TBusRollSiteForm(msite).CurrentObject.oid));
                                         end;
                                    finally
                                          mr.free;
                                    end;
                               end;

                               if (index=1) or (index=2) then begin
                                  mr:=TStringList.create;
                                    try
                                         msite.BaseObjectSpace.SQLSelect('selecc sum(quantity) from StoreSubBatches where storecard_ID=' + quotedstr(TBusRollSiteForm(msite).CurrentObject.oid),mr);
                                         if  NxIBStrToFloat(mr.Strings[0])>0 then begin
                                             NxShowSimpleMessage('Na šaržích/SN je množství, kartu nelze změnit.',nil);
                                         end else begin
                                             mi:=msite.BaseObjectSpace.SQLExecute('update Storecards set Category=' + quotedstr(inttostr(index)) + ' where id=' + quotedstr(TBusRollSiteForm(msite).CurrentObject.oid));
                                         end;
                                    finally
                                          mr.free;
                                    end;
                               end;

       //    mi:=msite.BaseObjectSpace.SQLExecute('update Storecards set Category=' + quotedstr(inttostr(index)) + ' where id=' + quotedstr(TBusRollSiteForm(msite).CurrentObject.oid));


             end;
        msite.RefreshData;

    end;

end ;





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
        mUser.load(Self.CompanyCache.GetUserID,nil);
        if copy(mUser.GetFieldValueAsString('X_parametry'),1,1)='1' then mUserFilter:= true;
    finally
      mUser.Free;
    end;
    if mUserFilter then begin
             mMAction := Self.GetNewMultiAction;
              mMAction.ShowControl := True;
              mMAction.ShowMenuItem := True;
              mMAction.Caption := 'Změna typu skladové karty';
              mMAction.Hint := 'Třída skladové karty';
              mMAction.Category := 'tabList';
              mMAction.OnExecuteItem := @ChangeCategory;
              mMAction.Items.Add('Základní');
              mMAction.Items.Add('Sériové Číslo');
              mMAction.Items.Add('Šarže');
              mMAction.Items.Add('Makrokarta');
              mMAction.Items.Add('Obal');
    end;
end;

begin
end.