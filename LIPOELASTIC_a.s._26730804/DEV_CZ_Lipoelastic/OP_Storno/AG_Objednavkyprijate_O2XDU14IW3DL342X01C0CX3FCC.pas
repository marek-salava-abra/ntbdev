uses 'OP_Storno.lib';
var
     mBookmark : TBookmarkList;

procedure Storno(Sender: TAction; Index: integer);
var
 mbo:TNxCustomBusinessObject;
 mSite: TSiteForm;
 mDBGrid : TDBGrid;
 mTabList: TTabSheet;
 i:integer;
   mForm: TDynSiteForm;
   mtext:string;
   mB_Result:boolean;
   mS_Result:string;
   mi:integer;
begin

  mSite := NxFindSiteForm(Sender);
    mTabList := TTabSheet(NxFindChildControl(mSite.MainPanel, 'tabList'));
    if mTabList = nil then
        RaiseException('tabList nenalezen');
    mDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdList'));
    if mDBGrid = nil then
        RaiseException('DBGrid nenalezen');
    mBookmark := mDBGrid.SelectedRows; // *** v mBookmark jsou id označených záznamu
    mbo:= TDynSiteForm(mSite).CurrentObject;
    if mBookmark.count=0 then begin
              try
              mS_Result:=OP_storno(TDynSiteForm(mSite).CurrentObject);
              //TDynSiteForm(mSite).ActiveDataSet.RefreshAndRestoreLastSelectedItem ;

                             // TDynSiteForm(mSite).CurrentObject.Refresh;
                              //if index=0 then
                              try
                                    mS_Result:=ZL_storno(TDynSiteForm(mSite).CurrentObject);
                                      if index=99 then begin
                                          ZL_delete(mBO);
                                          mbo.Refresh;
                                          mbo.MarkForDelete;
                                      end;
                              finally

                              end;
                              TDynSiteForm(mSite).CurrentObject.Refresh;
                            //  TDynSiteForm(mSite).ActiveDataSet.RefreshAndRestoreLastSelectedItem ;

              finally

              end;
    end else begin
         for i := 0 to mBookmark.Count- 1 do begin
                          mDBGrid.DataSource.DataSet.GotoBookmark(mBookMark.items(i));
                        try
                        mS_Result:=OP_storno(TDynSiteForm(mSite).CurrentObject);
                        //TDynSiteForm(mSite).ActiveDataSet.RefreshAndRestoreLastSelectedItem ;

                        //  TDynSiteForm(mSite).CurrentObject.Refresh;
                         //if index=0 then
                         try
                                 mS_Result:=ZL_storno(TDynSiteForm(mSite).CurrentObject);
                                 if index=99 then begin
                                          ZL_delete(TDynSiteForm(mSite).CurrentObject);
                                          //TDynSiteForm(mSite).ActiveDataSet.RefreshAndRestoreLastSelectedItem ;
                                          TDynSiteForm(mSite).CurrentObject.MarkForDelete
                                      end;
                         finally

                         end;
                        //TDynSiteForm(mSite).CurrentObject.Refresh;

                        finally

                        end;

         end;

    end;

  TDynSiteForm(mSite).ActiveDataSet.RefreshAndRestoreLastSelectedItem ;

  //TDynSiteForm(mSite).Refresh;

end;


procedure InitSite_Hook(Self: TDynSiteForm);
var
mAction: TAction;
  mMAction: TMultiAction;
begin
//if (NxGetActualUserID(self.BaseObjectSpace)='SUPER00000') or (NxGetActualUserID(self.BaseObjectSpace)='1Z10000101') then begin
  mmAction := Self.GetNewMultiAction;
  mmAction.ShowControl := True;
  mmAction.ShowMenuItem := True;
  mmAction.Caption := 'Storno';
  mmAction.Hint := 'Storno ';
  mmAction.Category := 'tabList';
  mMAction.Items.Add('Storno');
  //mMAction.Items.Add('Smazání včetně zálohy');
  mmAction.OnExecute:= @Storno;

//end;

end;


begin
end.