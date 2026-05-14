uses 'abra.eu.mask.2017.predvyplneni.funkce';

procedure OnExec(Sender: TComponent;index:integer);       // přidělení objectspace a zadání zdrojového souboru
var
    mBO: TNxCustomBusinessObject;
    i ,j : integer;
    mSite: TDynSiteForm;
  mControl : TControl;
  mDBGrid : TDBGrid;
  mBookmark : TBookmarkList;
  mTabList: TTabSheet;
  mid:string;
  mMon:TNxCustomBusinessMonikerCollection;
  mMon_Source: TNxCustomBusinessMonikerCollection;
  price,mWeight:double;
  mr:tstringlist;
  mPrice_id,mPrice1_id,mPricelist_id:string;
begin

//    mPrice_id:='1000000101';
//    mPrice1_id:= '4100000101';
    mPricelist_id:= '3G30000101';


      mSite := TDynSiteForm(NxFindSiteForm(Sender));
    mTabList := TTabSheet(NxFindChildControl(mSite.MainPanel, 'tabList'));
    mBO := TDynSiteForm(mSite).CurrentObject;
    if mTabList = nil then begin
        RaiseException('tabList nenalezen');
    end else begin
        mDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdList'));
        //if mDBGrid = nil then NxShowSimpleMessage('AA',nil);
            //RaiseException('DBGrid nenalezen');


                     try
                    mBookmark := mDBGrid.SelectedRows; // *** v mBookmark jsou id označených záznamu
                            if mBookmark.count=0 then begin
                                        mBO := TDynSiteForm(mSite).CurrentObject;
                                                  mWeight:=0;
                                                  mMon_Source:= mBO.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('ROWS'));
                                                        for i := 0 to mMon_Source.Count - 1 do begin
                                                                     mr:=TStringList.create;
                                                                     try
                                                                           msite.BaseObjectSpace.SQLSelect('SELECT (SU.Weight* CASE WHEN (SU.WeightUnit=0) THEN 0.001 WHEN (SU.WeightUnit=2) THEN 1000 ELSE 1 END )' +
                                                                            ' From storecards SC join StoreUnits SU on SU.Parent_ID=SC.id AND SU.Code='+ quotedstr(mMon_Source.BusinessObject[i].GetFieldValueAsString('Qunit'))+
                                                                            ' where (sc.id IS NOT NULL) AND SU.Parent_ID=sc.id AND SU.Code=' + quotedstr(mMon_Source.BusinessObject[i].GetFieldValueAsString('Qunit'))+
                                                                              ' and SC.id =' + quotedstr(mMon_Source.BusinessObject[i].GetFieldValueAsString('Storecard_ID')),mr);
                                                                          if mr.count>0 then  mWeight:=mWeight + NxIBStrToFloat(mr.Strings[j]);
                                                                     finally
                                                                         mr.free;
                                                                     end;
                                                        end;
                                                        if mBO.getFieldValueAsFloat('U_weight')=0 then mBO.SetFieldValueAsFloat('U_weight',mWeight);
                                                         mBO.SetFieldValueAsstring('U_DodPod_Mesto', mbo.GetFieldValueAsString('FirmOffice_ID.Address_ID.City'));
                                                        mbo.save;




                            end else begin
                               for i := 0 to mBookmark.Count-1 do begin // projdu vsechny oznacene zaznamy
                                        mDBGrid.DataSource.DataSet.GotoBookmark(mBookMark.items(i));
                                         mBO := TDynSiteForm(mSite).CurrentObject;
                                                  mWeight:=0;
                                                  mMon_Source:= mBO.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('ROWS'));
                                                        for i := 0 to mMon_Source.Count - 1 do begin
                                                                     mr:=TStringList.create;
                                                                     try
                                                                           msite.BaseObjectSpace.SQLSelect('SELECT (SU.Weight* CASE WHEN (SU.WeightUnit=0) THEN 0.001 WHEN (SU.WeightUnit=2) THEN 1000 ELSE 1 END )' +
                                                                            ' From storecards SC join StoreUnits SU on SU.Parent_ID=SC.id AND SU.Code='+ quotedstr(mMon_Source.BusinessObject[i].GetFieldValueAsString('Qunit'))+
                                                                            ' where (sc.id IS NOT NULL) AND SU.Parent_ID=sc.id AND SU.Code=' + quotedstr(mMon_Source.BusinessObject[i].GetFieldValueAsString('Qunit'))+
                                                                              ' and SC.id =' + quotedstr(mMon_Source.BusinessObject[i].GetFieldValueAsString('Storecard_ID')),mr);
                                                                          if mr.count>0 then  mWeight:=mWeight + NxIBStrToFloat(mr.Strings[j]);
                                                                     finally
                                                                         mr.free;
                                                                     end;
                                                        end;
                                                        if mBO.getFieldValueAsFloat('U_weight')=0 then mBO.SetFieldValueAsFloat('U_weight',mWeight);
                                                         mBO.SetFieldValueAsstring('U_DodPod_Mesto', mbo.GetFieldValueAsString('FirmOffice_ID.Address_ID.City'));
                                                        mbo.save;

                                end;
                            end;
                   finally
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
          mMAction.Hint := 'Doplnění logistiky';
          mMAction.Caption := 'Doplnění logistiky';
          mMAction.Items.Add('Doplnění logistiky');
          mMAction.Category := 'tabList,tabDetail';
          mMAction.OnExecuteItem := @OnExec;


end;





begin
end.