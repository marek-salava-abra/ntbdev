//uses 'abra.eu.mask.Spedos.Servis.2015.Stav_zasob.const',
//       'abra.eu.mask.Spedos.Servis.2015.Stav_zasob.funkce';
var
    mFSazba_hod_den,mFDoprava_km,mF_doprava_pausal,mFSazba_hod:double;
    mBO_BusProject:TNxCustomBusinessObject;
    mF_pausal_prace,mF_pausal_Vyjezd,mF_prace,mF_km:double;
    // doby + termíny
    mF_doba:double;
    mRows : TNxCustomBusinessMonikerCollection;
    result:boolean;
    mresult:boolean;
      mBookmark : TBookmarkList;
          mOLE, mRoll, mOResult: Variant;
    mids:tstringlist;

procedure FVExecuteItem(Sender: TAction; Index: integer);
var
 mresult:Boolean;
 mtext:string;
 mbo_source:TNxCustomBusinessObject;
 mbo_target:TNxCustomBusinessObject;
 mSite: TSiteForm;
  mDBGrid : TDBGrid;
    mTabList: TTabSheet;
  self:TNxCustomBusinessObject;
  i,ii:integer;
  mr,mIDs_MLRow:TStringList;
  mi:integer;
begin
    mSite := NxFindSiteForm(TComponent(Sender));
    mTabList := TTabSheet(NxFindChildControl(mSite.MainPanel, 'tabList'));
    if mTabList = nil then RaiseException('tabList nenalezen');
    mDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdList'));
    if mDBGrid = nil then RaiseException('DBGrid nenalezen');
    mBookmark := mDBGrid.SelectedRows; // *** v mBookmark jsou id označených záznamu

                try

                        mbo_source := TBusRollSiteForm(mSite).CurrentObject;

                        if mBookmark.count=0 then begin
                            NxShowSimpleMessage('Není označen žádný zdrojový SP pro načtění parametrů',msite);
                        end else begin
                            if mBookmark.count>0 then begin
                                 for i:=0 to mBookmark.count-1 do begin

                                       mDBGrid.DataSource.DataSet.GotoBookmark(mBookMark.items(i));
                                        mbo_target := TBusRollSiteForm(mSite).CurrentObject;
                                        if not NxIsBlank(mbo_source.GetFieldValueAsString('X_par1')) then mbo_target.setFieldValueAsString('X_par1',mbo_source.GetFieldValueAsString('X_par1'));
                                        if not NxIsBlank(mbo_source.GetFieldValueAsString('X_par2')) then mbo_target.setFieldValueAsString('X_par2',mbo_source.GetFieldValueAsString('X_par2'));
                                        if not NxIsBlank(mbo_source.GetFieldValueAsString('X_par3')) then mbo_target.setFieldValueAsString('X_par3',mbo_source.GetFieldValueAsString('X_par3'));
                                        if not NxIsBlank(mbo_source.GetFieldValueAsString('X_par4')) then mbo_target.setFieldValueAsString('X_par4',mbo_source.GetFieldValueAsString('X_par4'));
                                        if not NxIsBlank(mbo_source.GetFieldValueAsString('X_par5')) then mbo_target.setFieldValueAsString('X_par5',mbo_source.GetFieldValueAsString('X_par5'));
                                        if not NxIsBlank(mbo_source.GetFieldValueAsString('X_par6')) then mbo_target.setFieldValueAsString('X_par6',mbo_source.GetFieldValueAsString('X_par6'));
                                        if not NxIsBlank(mbo_source.GetFieldValueAsString('X_par7')) then mbo_target.setFieldValueAsString('X_par7',mbo_source.GetFieldValueAsString('X_par7'));
                                        if not NxIsBlank(mbo_source.GetFieldValueAsString('X_par8')) then mbo_target.setFieldValueAsString('X_par8',mbo_source.GetFieldValueAsString('X_par8'));
                                        if not NxIsBlank(mbo_source.GetFieldValueAsString('X_par9')) then mbo_target.setFieldValueAsString('X_par9',mbo_source.GetFieldValueAsString('X_par9'));
                                        if not NxIsBlank(mbo_source.GetFieldValueAsString('X_par10')) then mbo_target.setFieldValueAsString('X_par10',mbo_source.GetFieldValueAsString('X_par10'));
                                        if not NxIsBlank(mbo_source.GetFieldValueAsString('X_par11')) then mbo_target.setFieldValueAsString('X_par11',mbo_source.GetFieldValueAsString('X_par11'));
                                        if not NxIsBlank(mbo_source.GetFieldValueAsString('X_par12')) then mbo_target.setFieldValueAsString('X_par12',mbo_source.GetFieldValueAsString('X_par12'));
                                        if not NxIsBlank(mbo_source.GetFieldValueAsString('X_par13')) then mbo_target.setFieldValueAsString('X_par13',mbo_source.GetFieldValueAsString('X_par13'));
                                        if not NxIsBlank(mbo_source.GetFieldValueAsString('X_par14')) then mbo_target.setFieldValueAsString('X_par14',mbo_source.GetFieldValueAsString('X_par14'));
                                        if not NxIsBlank(mbo_source.GetFieldValueAsString('X_par15')) then mbo_target.setFieldValueAsString('X_par15',mbo_source.GetFieldValueAsString('X_par15'));
                                        if not NxIsBlank(mbo_source.GetFieldValueAsString('X_par16')) then mbo_target.setFieldValueAsString('X_par16',mbo_source.GetFieldValueAsString('X_par16'));
                                        if not NxIsBlank(mbo_source.GetFieldValueAsString('X_par17')) then mbo_target.setFieldValueAsString('X_par17',mbo_source.GetFieldValueAsString('X_par17'));
                                        if not NxIsBlank(mbo_source.GetFieldValueAsString('X_par18')) then mbo_target.setFieldValueAsString('X_par18',mbo_source.GetFieldValueAsString('X_par18'));
                                        if not NxIsBlank(mbo_source.GetFieldValueAsString('X_par19')) then mbo_target.setFieldValueAsString('X_par19',mbo_source.GetFieldValueAsString('X_par19'));
                                        if not NxIsBlank(mbo_source.GetFieldValueAsString('X_par20')) then mbo_target.setFieldValueAsString('X_par20',mbo_source.GetFieldValueAsString('X_par20'));
                                        if not NxIsBlank(mbo_source.GetFieldValueAsString('X_par21')) then mbo_target.setFieldValueAsString('X_par21',mbo_source.GetFieldValueAsString('X_par21'));
                                        if not NxIsBlank(mbo_source.GetFieldValueAsString('X_par22')) then mbo_target.setFieldValueAsString('X_par22',mbo_source.GetFieldValueAsString('X_par22'));
                                        if not NxIsBlank(mbo_source.GetFieldValueAsString('X_par23')) then mbo_target.setFieldValueAsString('X_par23',mbo_source.GetFieldValueAsString('X_par23'));
                                        if not NxIsBlank(mbo_source.GetFieldValueAsString('X_par24')) then mbo_target.setFieldValueAsString('X_par24',mbo_source.GetFieldValueAsString('X_par24'));
                                        if not NxIsBlank(mbo_source.GetFieldValueAsString('X_par25')) then mbo_target.setFieldValueAsString('X_par25',mbo_source.GetFieldValueAsString('X_par25'));
                                        if not NxIsBlank(mbo_source.GetFieldValueAsString('X_par26')) then mbo_target.setFieldValueAsString('X_par26',mbo_source.GetFieldValueAsString('X_par26'));
                                        if not NxIsBlank(mbo_source.GetFieldValueAsString('X_par27')) then mbo_target.setFieldValueAsString('X_par27',mbo_source.GetFieldValueAsString('X_par27'));
                                        if not NxIsBlank(mbo_source.GetFieldValueAsString('X_par28')) then mbo_target.setFieldValueAsString('X_par28',mbo_source.GetFieldValueAsString('X_par28'));
                                        if not NxIsBlank(mbo_source.GetFieldValueAsString('X_par29')) then mbo_target.setFieldValueAsString('X_par29',mbo_source.GetFieldValueAsString('X_par29'));
                                        if not NxIsBlank(mbo_source.GetFieldValueAsString('X_par30')) then mbo_target.setFieldValueAsString('X_par30',mbo_source.GetFieldValueAsString('X_par30'));
                                        if not NxIsBlank(mbo_source.GetFieldValueAsString('X_par31')) then mbo_target.setFieldValueAsString('X_par31',mbo_source.GetFieldValueAsString('X_par31'));
                                        if not NxIsBlank(mbo_source.GetFieldValueAsString('X_par32')) then mbo_target.setFieldValueAsString('X_par32',mbo_source.GetFieldValueAsString('X_par32'));
                                        if not NxIsBlank(mbo_source.GetFieldValueAsString('X_par33')) then mbo_target.setFieldValueAsString('X_par33',mbo_source.GetFieldValueAsString('X_par33'));
                                        if not NxIsBlank(mbo_source.GetFieldValueAsString('X_par34')) then mbo_target.setFieldValueAsString('X_par34',mbo_source.GetFieldValueAsString('X_par34'));
                                        if not NxIsBlank(mbo_source.GetFieldValueAsString('X_par35')) then mbo_target.setFieldValueAsString('X_par35',mbo_source.GetFieldValueAsString('X_par35'));
                                        if not NxIsBlank(mbo_source.GetFieldValueAsString('X_par36')) then mbo_target.setFieldValueAsString('X_par36',mbo_source.GetFieldValueAsString('X_par36'));
                                        mbo_target.save;

                                        mi:=msite.BaseObjectSpace.SQLExecute('update DefRollData set X_ServicedObject_ID=' + quotedstr(mbo_target.oid) +
                                            ' WHERE CLSID = ' +quotedstr('L5NKMYE3ZLSOLEBABM5CCHGOIC') + ' AND (X_ServicedObject_ID = ' + quotedstr(mbo_source.oid));
                                  end;
                            end else begin
                                NxShowSimpleMessage('Je označeno více zdrojových SP - není možné pokračovat',msite);
                            end;
                        end;
               finally

               end;
 TBusRollSiteForm(mSite).RefreshData;
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
            if (mUser.GetFieldValueAsString('Name')='Supervisor') or (mUser.GetFieldValueAsString('Name')='Miroslav Cibulec') then mUserFilter:= true;
  finally
    mUser.Free;
  end;

  if mUserFilter then begin
  mMAction := Self.GetNewMultiAction;
  mMAction.ShowControl := True;
  mMAction.ShowMenuItem := True;
  mMAction.Caption := 'Slucování SP - parametry';
  mMAction.Hint := 'Z označeného SP - překopíruje parametry do aktivního SP';
  mMAction.Category := 'tabList';
  mMAction.OnExecuteItem := @FVExecuteItem;
  mMAction.Items.Add('Slucování SP - parametry');
  end;

end;



begin
end.