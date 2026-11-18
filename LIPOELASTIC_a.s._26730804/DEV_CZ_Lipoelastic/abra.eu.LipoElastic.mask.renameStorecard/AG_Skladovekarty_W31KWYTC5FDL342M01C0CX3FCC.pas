

procedure OnExec(Sender: TComponent;index:integer);       // přidělení objectspace a zadání zdrojového souboru
var
    mBO: TNxCustomBusinessObject;
    i : integer;
    mSite: TSiteForm;
  mControl : TControl;
  mDBGrid : TDBGrid;
  mBookmark : TBookmarkList;
  CZ_pomoc_name,EN_pomoc_name:string ;
  mTabList: TTabSheet;
begin
      mSite := NxFindSiteForm(Sender);
    mTabList := TTabSheet(NxFindChildControl(mSite.MainPanel, 'tabList'));
    if mTabList = nil then
        RaiseException('tabList nenalezen');
    mDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdList'));
    if mDBGrid = nil then
        RaiseException('DBGrid nenalezen');
                    try
                    mBookmark := mDBGrid.SelectedRows; // *** v mBookmark jsou id označených záznamu
                            if mBookmark.count=0 then begin
                                        mBO := TBusRollSiteForm(mSite).CurrentObject;
                                        CZ_pomoc_name:='';
                                        if copy(mbo.GetFieldValueAsString('U_material'),1,1)='C' then CZ_pomoc_name:=CZ_pomoc_name+'C' else CZ_pomoc_name:=CZ_pomoc_name+'_' ;
                                        CZ_pomoc_name:=CZ_pomoc_name+ '/';
                                        CZ_pomoc_name:=CZ_pomoc_name+ mbo.GetFieldValueAsString('X_typ_velky');
                                        CZ_pomoc_name:=CZ_pomoc_name+ ' ';
                                        CZ_pomoc_name:=CZ_pomoc_name+mbo.GetFieldValueAsString('U_druh_id.name') ;
                                        CZ_pomoc_name:=CZ_pomoc_name+', ' ;
                                        CZ_pomoc_name:=CZ_pomoc_name+mbo.GetFieldValueAsString('U_provedeni_id.Name');
                                        CZ_pomoc_name:=CZ_pomoc_name+', vel. ';
                                        CZ_pomoc_name:=CZ_pomoc_name+mbo.GetFieldValueAsString('U_velikost_id.Name');
                                        CZ_pomoc_name:=CZ_pomoc_name+', ';
                                        CZ_pomoc_name:=CZ_pomoc_name+mbo.GetFieldValueAsString('U_barva_id.Name') ;

                                        EN_pomoc_name:='';
                                        if copy(mbo.GetFieldValueAsString('U_material'),1,1)='C' then EN_pomoc_name:=EN_pomoc_name+'C' else EN_pomoc_name:=EN_pomoc_name+'_' ;
                                        EN_pomoc_name:=EN_pomoc_name+ '/';
                                        EN_pomoc_name:=EN_pomoc_name+ mbo.GetFieldValueAsString('X_typ_velky');
                                        EN_pomoc_name:=EN_pomoc_name+ ' ';
                                        EN_pomoc_name:=EN_pomoc_name+mbo.GetFieldValueAsString('U_druh_id.U_EN_name') ;
                                        EN_pomoc_name:=EN_pomoc_name+', ' ;
                                        EN_pomoc_name:=EN_pomoc_name+mbo.GetFieldValueAsString('U_provedeni_id.U_EN_name');
                                        EN_pomoc_name:=EN_pomoc_name+', size ';
                                        EN_pomoc_name:=EN_pomoc_name+mbo.GetFieldValueAsString('U_velikost_id.Name');
                                        EN_pomoc_name:=EN_pomoc_name+', ';
                                        EN_pomoc_name:=EN_pomoc_name+mbo.GetFieldValueAsString('U_barva_id.U_EN_name') ;


                                        mbo.SetFieldValueAsSTRING('X_CZ_pomoc_name',CZ_pomoc_name);
                                        mbo.SetFieldValueAsSTRING('X_EN_pomoc_name',En_pomoc_name);
                                        mbo.Save;
                            end else begin
                               for i := 0 to mBookmark.Count-1 do begin // projdu vsechny oznacene zaznamy
                                        mDBGrid.DataSource.DataSet.GotoBookmark(mBookMark.items(i));
                                              mBO := TBusRollSiteForm(mSite).CurrentObject;
                                            try
                                            //NxShowSimpleMessage(mbo.oid,nil);
                                            CZ_pomoc_name:='';
                                            if copy(mbo.GetFieldValueAsString('U_material'),1,1)='C' then CZ_pomoc_name:=CZ_pomoc_name+'C' else CZ_pomoc_name:=CZ_pomoc_name+'_' ;
                                            CZ_pomoc_name:=CZ_pomoc_name+ '/';
                                            CZ_pomoc_name:=CZ_pomoc_name+ mbo.GetFieldValueAsString('X_typ_velky');
                                            CZ_pomoc_name:=CZ_pomoc_name+ ' ';
                                            CZ_pomoc_name:=CZ_pomoc_name+mbo.GetFieldValueAsString('U_druh_id.name') ;
                                            CZ_pomoc_name:=CZ_pomoc_name+', ' ;
                                            CZ_pomoc_name:=CZ_pomoc_name+mbo.GetFieldValueAsString('U_provedeni_id.Name');
                                            CZ_pomoc_name:=CZ_pomoc_name+', vel. ';
                                            CZ_pomoc_name:=CZ_pomoc_name+mbo.GetFieldValueAsString('U_velikost_id.Name');
                                            CZ_pomoc_name:=CZ_pomoc_name+', ';
                                            CZ_pomoc_name:=CZ_pomoc_name+mbo.GetFieldValueAsString('U_barva_id.Name') ;

                                            EN_pomoc_name:='';
                                        if copy(mbo.GetFieldValueAsString('U_material'),1,1)='C' then EN_pomoc_name:=EN_pomoc_name+'C' else EN_pomoc_name:=EN_pomoc_name+'_' ;
                                        EN_pomoc_name:=EN_pomoc_name+ '/';
                                        EN_pomoc_name:=EN_pomoc_name+ mbo.GetFieldValueAsString('X_typ_velky');
                                        EN_pomoc_name:=EN_pomoc_name+ ' ';
                                        EN_pomoc_name:=EN_pomoc_name+mbo.GetFieldValueAsString('U_druh_id.U_EN_name') ;
                                        EN_pomoc_name:=EN_pomoc_name+', ' ;
                                        EN_pomoc_name:=EN_pomoc_name+mbo.GetFieldValueAsString('U_provedeni_id.U_EN_name');
                                        EN_pomoc_name:=EN_pomoc_name+', size ';
                                        EN_pomoc_name:=EN_pomoc_name+mbo.GetFieldValueAsString('U_velikost_id.Name');
                                        EN_pomoc_name:=EN_pomoc_name+', ';
                                        EN_pomoc_name:=EN_pomoc_name+mbo.GetFieldValueAsString('U_barva_id.U_EN_name') ;


                                        mbo.SetFieldValueAsSTRING('X_CZ_pomoc_name',CZ_pomoc_name);
                                        mbo.SetFieldValueAsSTRING('X_EN_pomoc_name',En_pomoc_name);
                                        mbo.Save;
                                       finally

                                       end;

                                end;
                            end;
                   finally
                   end;
                 TBusRollSiteForm(mSite).RefreshData;



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
     //   if mUserFilter then begin
          mMAction := Self.GetNewMultiAction;
          mMAction.ShowControl := True;
          mMAction.ShowMenuItem := True;
          mMAction.Hint := 'Změna názvu skladové karty';
          mMAction.Caption := 'Hromadná změna názvu skladové karty';
          mMAction.Items.Add('Rename Storecard');
          //mMAction.Items.Add('Makrokarta');
          mMAction.Category := 'tabList';
          mMAction.OnExecuteItem := @OnExec;






  //    end;
end;


begin
end.