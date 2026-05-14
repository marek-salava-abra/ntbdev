var
    mFSazba_hod_den,mFDoprava_km,mF_doprava_pausal,mFSazba_hod:double;
    mBO_BusProject:TNxCustomBusinessObject;
    mF_pausal_prace,mF_pausal_Vyjezd,mF_prace,mF_km:double;
    // doby + termíny
    mF_doba:double;
    mRows : TNxCustomBusinessMonikerCollection;
    mTabList: TTabSheet;
    mBookmark : TBookmarkList;

procedure FVExecuteItem(Sender: TMultiAction; Index: integer);
var
 mtext:string;
 mImportMan:TNxDocumentImportManager;
 mbo,mrow:TNxCustomBusinessObject;
 mSite: TDynSiteForm;
 mDBGrid : TDBGrid;
 i:integer;
 mForm: TDynSiteForm;
 mMon: TNxCustomBusinessMonikerCollection;
 mF_cena_km:double;
 mF_celkem_cena:double;
 mS_celkem_cena:string;
 mF_cena:double;
 mResult:boolean;
 mr:TStringList;
begin

mSite := TComponent(Sender).DynSite;
    mTabList := TTabSheet(NxFindChildControl(mSite.MainPanel, 'tabList'));
    if mTabList = nil then RaiseException('tabList nenalezen');
    mDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdList'));
    if mDBGrid = nil then RaiseException('DBGrid nenalezen');
    mBookmark := mDBGrid.SelectedRows; // *** v mBookmark jsou id označených záznamu
    mForm := TComponent(Sender).DynSite;
    mbo:=TDynSiteForm(mSite).CurrentObject;
    if mbo.GetFieldValueAsString('docqueue_ID')='7J00000101' then begin
              mF_cena_km:=0;
              mF_celkem_cena:=0;
              mresult:=InputQuery('Zadání částek','částky za objednanou dopravu bez DPH', ms_celkem_cena);
              mF_celkem_cena:=NxIBStrToFloat(mS_celkem_cena);
              mr:=TStringList.create;
              try
                  if mbo.GetFieldValueAsInteger('U_nakladka')=1 then mbo.ObjectSpace.SQLSelect('select sum(ii2.Quantity * ii2.unitrate * ii2.X_Vytizenost * po.X_vzdalenost_spedos) from issuedorders2 ii2 left join PostOffices po on po.id=ii2.X_Vzdalenost_psc where ii2.parent_ID=' + quotedstr(mbo.oid),mr);
                  if mbo.GetFieldValueAsInteger('U_nakladka')=2 then mbo.ObjectSpace.SQLSelect('select sum(ii2.Quantity * ii2.unitrate * ii2.X_Vytizenost * po.X_vzdalenost_jezerany) from issuedorders2 ii2 left join PostOffices po on po.id=ii2.X_Vzdalenost_psc where ii2.parent_ID=' + quotedstr(mbo.oid),mr);
                  if mbo.GetFieldValueAsInteger('U_nakladka')=3 then mbo.ObjectSpace.SQLSelect('select sum(ii2.Quantity * ii2.unitrate * ii2.X_Vytizenost * po.X_vzdalenost_hlucinka) from issuedorders2 ii2 left join PostOffices po on po.id=ii2.X_Vzdalenost_psc where ii2.parent_ID=' + quotedstr(mbo.oid),mr);

                  if mr.count>0 then begin
                        mF_cena_km:=mF_celkem_cena/NxIBStrToFloat(mr.Strings[0]);
                        mMon := mbo.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('ROWS'));
                        for i := 0 to mMon.Count-1 do begin
                               mRow := mMon.BusinessObject[i];
                               if mbo.GetFieldValueAsInteger('U_nakladka')=1 then mf_cena:=mRow.getFieldValueAsfloat('X_Vzdalenost_psc.X_vzdalenost_spedos')* mRow.getFieldValueAsfloat('Quantity') *mRow.getFieldValueAsfloat('unitrate')* mRow.getFieldValueAsfloat('X_Vytizenost')*mF_cena_km ;
                               if mbo.GetFieldValueAsInteger('U_nakladka')=2 then mf_cena:=mRow.getFieldValueAsfloat('X_Vzdalenost_psc.X_vzdalenost_jezerany')* mRow.getFieldValueAsfloat('Quantity') *mRow.getFieldValueAsfloat('unitrate')* mRow.getFieldValueAsfloat('X_Vytizenost')*mF_cena_km ;
                               if mbo.GetFieldValueAsInteger('U_nakladka')=3 then mf_cena:=mRow.getFieldValueAsfloat('X_Vzdalenost_psc.X_vzdalenost_hlucinka')* mRow.getFieldValueAsfloat('Quantity') *mRow.getFieldValueAsfloat('unitrate')* mRow.getFieldValueAsfloat('X_Vytizenost')*mF_cena_km ;
                               mRow.setFieldValueAsfloat('UnitPrice',0);
                               mRow.setFieldValueAsfloat('TotalPrice',mf_cena);
                               mRow.setFieldValueAsfloat('TAmountWithoutVAT',mf_cena);
                               //if mRow.GetFieldValueAsfloat('Quantity') - mRow.GetFieldValueAsfloat('DeliveredQuantity')>0 then begin
                        end;

                  mbo.Save;
                  end;
              finally
                mr.free;
              end;



             TDynSiteForm(mSite).RefreshData;
       end;
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
            if mUser.GetFieldValueAsString('Name')='Supervisor' then mUserFilter:= true;
  finally
    mUser.Free;
  end;
  mMAction := Self.GetNewMultiAction;
  mMAction.ShowControl := True;
  mMAction.ShowMenuItem := True;
  mMAction.Caption := 'Rozpočet dopravy';
  mMAction.Hint := 'Rozpočet dopravy';
  mMAction.Category := 'tabList';
  mMAction.OnExecuteItem := @FVExecuteItem;
  mMAction.Items.Add('Rozpočet dopravy');
end;


begin
end.