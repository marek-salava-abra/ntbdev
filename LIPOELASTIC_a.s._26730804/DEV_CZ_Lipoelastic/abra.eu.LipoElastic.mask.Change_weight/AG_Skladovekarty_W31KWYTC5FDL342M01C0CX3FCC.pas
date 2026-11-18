
procedure OnExec(Sender: TComponent;index:integer);       // přidělení objectspace a zadání zdrojového souboru
var
    mBO: TNxCustomBusinessObject;
    i,x : integer;
  mSite: TSiteForm;
  mbookmark:TBookmarkList;
  mdbgrid:TDBGrid;
  mstring:string;
  mWeight:double;
  mBoolean:Boolean;
   mTabList: TTabSheet;
   mMon:TNxCustomBusinessMonikerCollection;
   mFnetto,mFObal,mfBrutto:double;
begin
   mstring:='';
   mWeight:=0;


    if Sender is TComponent then begin
          mSite := NxFindSiteForm(Sender);
          if Assigned(mSite) and (mSite is TBusRollSiteForm) then begin



               mTabList := TTabSheet(NxFindChildControl(mSite.MainPanel, 'tabList'));
              if mTabList = nil then RaiseException('tabList nenalezen');
              mDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdList'));
              if mDBGrid = nil then RaiseException('DBGrid nenalezen');


               mBookmark := mDBGrid.SelectedRows; // *** v mBookmark jsou id označených záznamu

               mbo:= TBusRollSiteForm(mSite).CurrentObject;
                    if index=0 then begin
                         mBoolean:=InputQuery('Zadej hmotnost pro hromadnou změnu' , 'Hmotnost',mstring);
                       mWeight:=NxIBStrToFloat(mstring);
                    end;
                            try

                                    if mBookmark.count=0 then begin
                                                mBO := TBusRollSiteForm(mSite).CurrentObject;
                                                if index=0 then mbo.SetFieldValueAsFloat('IntrastatWeight',mWeight);
                                                if index=1 then begin
                                                    mFObal:=0;
                                                    mFObal:= msite.BaseObjectSpace.SQLSelectFirstAsExtended('SELECT max(SUx.Weight* CASE WHEN (SUx.WeightUnit=0) THEN 0.001 WHEN (SUx.WeightUnit=2) THEN 1000 ELSE 1 END ) FROM Storecards SCx left join StoreUnits SUx on SUx.Parent_ID=scx.X_Krabicka_ID where scx.id='
                                                            + quotedstr(mbo.OID)) ;
                                                    mFObal:=mFObal + msite.BaseObjectSpace.SQLSelectFirstAsExtended('SELECT max(SUx.Weight* CASE WHEN (SUx.WeightUnit=0) THEN 0.001 WHEN (SUx.WeightUnit=2) THEN 1000 ELSE 1 END ) FROM Storecards SCx left join StoreUnits SUx on SUx.Parent_ID=scx.X_Sacek_ID where scx.id='
                                                            + quotedstr(mbo.OID)) ;

                                                end;

                                                mMon := mbo.GetLoadedCollectionMonikerForFieldCode(mbo.GetFieldCode('StoreUnits'));
                                                for x:=0 to mMon.count-1 do begin
                                                    if mMon.BusinessObject[x].GetFieldValueAsString('Code')=mbo.GetFieldValueAsString('MainUnitCode') then begin
                                                        // NxShowSimpleMessage('hlavni jednotka',nil);
                                                       if index=0 then mMon.BusinessObject[x].SetFieldValueAsFloat('Weight',mWeight);

                                                       if index=1 then begin
                                                           mfBrutto:=0;
                                                           mFnetto:=0;
                                                           mfBrutto:= mMon.BusinessObject[x].getFieldValueAsFloat('Weight') ;
                                                           mFnetto:=mfBrutto-mFObal;
                                                           mMon.BusinessObject[x].SetFieldValueAsFloat('X_NettoWeight',mFnetto);
                                                       end;
                                                    end;
                                                end;

                                                mbo.Save;
                                    end else begin
                                       for i := 0 to mBookmark.Count-1 do begin // projdu vsechny oznacene zaznamy
                                                mDBGrid.DataSource.DataSet.GotoBookmark(mBookMark.items(i));
                                                      mBO := TBusRollSiteForm(mSite).CurrentObject;

                                                    if index=0 then mbo.SetFieldValueAsFloat('IntrastatWeight',mWeight);
                                                    if index=1 then begin
                                                        mFObal:=0;
                                                        try
                                                        mFObal:= msite.BaseObjectSpace.SQLSelectFirstAsExtended('SELECT max(SUx.Weight* CASE WHEN (SUx.WeightUnit=0) THEN 0.001 WHEN (SUx.WeightUnit=2) THEN 1000 ELSE 1 END ) FROM Storecards SCx left join StoreUnits SUx on SUx.Parent_ID=scx.X_Krabicka_ID where scx.id='
                                                                + quotedstr(mbo.OID)) ;
                                                        finally

                                                        end;
                                                        try
                                                        mFObal:=mFObal + msite.BaseObjectSpace.SQLSelectFirstAsExtended('SELECT max(SUx.Weight* CASE WHEN (SUx.WeightUnit=0) THEN 0.001 WHEN (SUx.WeightUnit=2) THEN 1000 ELSE 1 END ) FROM Storecards SCx left join StoreUnits SUx on SUx.Parent_ID=scx.X_Sacek_ID where scx.id='
                                                            + quotedstr(mbo.OID)) ;
                                                        finally

                                                        end;

                                                    end;

                                                    mMon := mbo.GetLoadedCollectionMonikerForFieldCode(mbo.GetFieldCode('StoreUnits'));
                                                          for x:=0 to mMon.count-1 do begin
                                                              if mMon.BusinessObject[x].GetFieldValueAsString('Code')=mbo.GetFieldValueAsString('MainUnitCode') then begin
                                                                 //  NxShowSimpleMessage('hlavni jednotka',nil);
                                                                 if index=0 then mMon.BusinessObject[x].SetFieldValueAsFloat('Weight',mWeight);
                                                                 if index=1 then begin
                                                                     mfBrutto:=0;
                                                                     mFnetto:=0;
                                                                     mfBrutto:= mMon.BusinessObject[x].getFieldValueAsFloat('Weight') ;
                                                                     mFnetto:=mfBrutto-mFObal;
                                                                     mMon.BusinessObject[x].SetFieldValueAsFloat('X_NettoWeight',mFnetto);
                                                                 end;

                                                              end;
                                                          end;
                                                     mbo.Save;
                                        end;
                                    end;
                           finally

                           end;

                 TBusRollSiteForm(mSite).RefreshData;
              NxShowSimpleMessage('Úloha doběhla',nil);


       end;
    end;
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

          mMAction := Self.GetNewMultiAction;
          mMAction.ShowControl := True;
          mMAction.ShowMenuItem := True;
          mMAction.Hint := 'Změna váhy';
          mMAction.Caption := 'Změna váhy';
          mMAction.Items.Add('Změna váhy pro intrastat');
          mMAction.Items.Add('Netto váha výpočtem');
          mMAction.Category := 'tabList';
          mMAction.OnExecuteItem := @OnExec;


end;


begin
end.