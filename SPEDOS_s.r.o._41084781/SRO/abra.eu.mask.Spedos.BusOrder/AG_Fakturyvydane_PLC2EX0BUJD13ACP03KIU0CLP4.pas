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
mi,i:integer;
mr: tstringlist;
mIDS:string ;
begin
        mSite := NxFindSiteForm(Sender);
        mTabList := TTabSheet(NxFindChildControl(mSite.MainPanel, 'tabList'));
        if mTabList = nil then RaiseException('tabList nenalezen');
        mDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdList'));
        if mDBGrid = nil then RaiseException('DBGrid nenalezen');

        mBookmarkList := mDBGrid.SelectedRows; // *** v mBookmark jsou id označených záznamu

          if mBookmarkList.count=0 then begin
                  mCustomBusinessObject:= TDynSiteForm(mSite).CurrentObject;
                  mr:=TStringList.create;
                  try
                     msite.BaseObjectSpace.SQLSelect('Select distinct BusOrder_id from issuedinvoices2 where parent_id=' + quotedstr(TDynSiteForm(mSite).CurrentObject.oid) , mr);
                        if mr.count>0 then begin
                           mIDS:='(';
                           for i:=0 to mr.count-1 do begin

                                        if index=0 then mi:=msite.BaseObjectSpace.SQLExecute('update busOrders bo set bo.X_Closed =''A'', bo.x_Change_closed=(select max(head.docdate$date) from issuedinvoices head left join issuedinvoices2 rox on rox.parent_id=head.id where rox.BusOrder_id=' +
                                         quotedstr(mr.Strings[i]) + ') where bo.id=' + quotedstr(mr.Strings[i]));
                                        if index=1 then mi:=msite.BaseObjectSpace.SQLExecute('update busOrders bo set bo.X_Closed =''N'', bo.x_Change_closed=' + QuotedStr(NxFloatToIBStr(0)) +
                                        ' where bo.id=' + quotedstr(mr.Strings[i]));

                           end;
                        end;

                  finally
                  mr.free;
                  end;
                  if index=1 then mi:=msite.BaseObjectSpace.SQLExecute('update busOrders set X_Closed =''N'',x_Change_closed=' +QuotedStr(NxFloatToIBStr(0)) + ' where id in ' + mIDS);


        end else begin
             for i := 0 to mBookmarkList.Count-1 do begin // projdu vsechny oznacene zaznamy
                  mDBGrid.DataSource.DataSet.GotoBookmark(mBookmarkList.items(i));

                      mCustomBusinessObject:= TDynSiteForm(mSite).CurrentObject;
                      mr:=TStringList.create;
                  try
                     msite.BaseObjectSpace.SQLSelect('Select distinct BusOrder_id from issuedinvoices2 where parent_id=' + quotedstr(TDynSiteForm(mSite).CurrentObject.oid) , mr);
                        if mr.count>0 then begin
                           for i:=0 to mr.count-1 do begin

                                        if index=0 then mi:=msite.BaseObjectSpace.SQLExecute('update busOrders bo set bo.X_Closed =''A'', bo.x_Change_closed=(select max(head.docdate$date) from issuedinvoices head left join issuedinvoices2 rox on rox.parent_id=head.id where rox.BusOrder_id=' +
                                         quotedstr(mr.Strings[i]) + ') where bo.id=' + quotedstr(mr.Strings[i]));
                                        if index=1 then mi:=msite.BaseObjectSpace.SQLExecute('update busOrders bo set bo.X_Closed =''N'', bo.x_Change_closed=' + QuotedStr(NxFloatToIBStr(0)) +
                                        ' where bo.id=' + quotedstr(mr.Strings[i]));
                           end;
                        end;

                  finally
                  mr.free;
                  end;



             end;
        end;
     try





        finally
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
          mMAction.Hint := 'Obchodní uzavření';
          mMAction.Caption := 'Obchodní uzavření';
          mMAction.Items.Add('Obchodní uzavření');
          mMAction.Items.Add('Obchodní zpetné otevření');
          mMAction.Category := 'tabList';
          mMAction.OnExecuteItem := @OnExec;

end;



begin
end.