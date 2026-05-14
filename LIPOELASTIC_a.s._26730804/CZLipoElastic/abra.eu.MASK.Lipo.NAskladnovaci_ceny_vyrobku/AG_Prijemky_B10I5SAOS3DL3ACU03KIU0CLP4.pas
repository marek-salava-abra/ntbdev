uses 'abra.eu.mask.2017.predvyplneni.funkce';

procedure OnExec(Sender: TComponent;index:integer);       // přidělení objectspace a zadání zdrojového souboru
var
    mBO: TNxCustomBusinessObject;
    i,x : integer;
    mSite: TDynSiteForm;
  mControl : TControl;
  mDBGrid : TDBGrid;
  mBookmark : TBookmarkList;
  CZ_pomoc_name,EN_pomoc_name:string ;
  mTabList: TTabSheet;
  mOLE, mRoll, mOResult: Variant;
  mid:string;
  mids1:TStringList;
  mMon:TNxCustomBusinessMonikerCollection;
  mBustransaction_ID,mBusProject_ID,mBusOrder_ID:string;
  BO,mBO_Source: TNxCustomBusinessObject ;
  mBO_Target,mMon_Target: TNxCustomBusinessObject;
  mMon_Source: TNxCustomBusinessMonikerCollection;
  price:double;
  mxg:tstringlist;
  mPrice_id,mPrice1_id,mPricelist_id:string;
begin

//    mPrice_id:='1000000101';
//    mPrice1_id:= '4100000101';
    mPricelist_id:= '3G30000101';


      mSite := TDynSiteForm(NxFindSiteForm(Sender));
    mTabList := TTabSheet(NxFindChildControl(mSite.MainPanel, 'tabList'));
    mBO := TDynSiteForm(mSite).CurrentObject;
    if mTabList = nil then
        RaiseException('tabList nenalezen');
    mDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdList'));
    if mDBGrid = nil then
        RaiseException('DBGrid nenalezen');
                     try
                    mBookmark := mDBGrid.SelectedRows; // *** v mBookmark jsou id označených záznamu
                            if mBookmark.count=0 then begin
                                        mBO := TDynSiteForm(mSite).CurrentObject;

                                            mMon_Source:= mBO.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('ROWS'));
                                            for i := 0 to mMon_Source.Count - 1 do begin
                                                   mPrice_id:='1000000101';
                                                   if (mMon_Source.BusinessObject[i].GetFieldValueAsString('StoreCard_ID.StoreCardCategory_ID')='1700000101')
                                                       or (mMon_Source.BusinessObject[i].GetFieldValueAsString('StoreCard_ID.StoreCardCategory_ID')='2H00000101')
                                                       or (mMon_Source.BusinessObject[i].GetFieldValueAsString('StoreCard_ID.StoreCardCategory_ID')='1300000101')
                                                       or (mMon_Source.BusinessObject[i].GetFieldValueAsString('StoreCard_ID.StoreCardCategory_ID')='A000000101')

                                                       or (mMon_Source.BusinessObject[i].GetFieldValueAsString('StoreCard_ID.StoreCardCategory_ID')='~00000000B')
                                                       or (mMon_Source.BusinessObject[i].GetFieldValueAsString('StoreCard_ID.StoreCardCategory_ID')='~00000000C')
                                                       //// or (Self.GetFieldValueAsString('StoreCard_ID.StoreCardCategory_ID')='')
                                                       or (mMon_Source.BusinessObject[i].GetFieldValueAsString('StoreCard_ID.StoreCardCategory_ID')='1900000101') then begin
                                                            if mMon_Source.BusinessObject[i].GetFieldValueAsString('Store_ID.X_Cena')='R' then begin
                                                               mPrice_id:='4100000101';

                                                            end;
                                                            if mMon_Source.BusinessObject[i].GetFieldValueAsString('Store_ID.X_Cena')='S' then begin
                                                                mPrice_id:= '1000000101';
                                                              mMon_Source.BusinessObject[i].SetFieldValueAsFloat('UnitPrice',price);
                                                        //                ShowMessage('04');
                                                            end;
                                                     end;
                                                    {   price:=0;
                                                        mxg:=tstringlist.create;
                                                                try
                                                                    msite.BaseObjectSpace.SQLSelect(format('SELECT a.amount FROM StorePrices2 A JOIN PriceDefinitions PD ON PD.ID=A.Price_ID JOIN StorePrices SP ON SP.ID=A.Parent_ID JOIN StoreCards SC ON SC.ID=SP.StoreCard_ID JOIN PriceLists PL ON PL.ID=SP.PriceList_ID where (pl.id=%s) and (pd.id=%s) and (SP.StoreCard_ID.id=%s)',[quotedstr(mPricelist_id),quotedstr(mPrice_ID), quotedstr(mMon_Source.BusinessObject[i].GetFieldValueAsString('StoreCard_ID'))]),mxg);
                                                                    if mxg.count>0 then begin
                                                                        //NxShowSimpleMessage(mxg.Strings[0],Null);
                                                                        price:=NxIBStrToFloat(mxg.Strings[0]);
                                                                    end;
                                                                finally
                                                                    mxg.free;
                                                                end; }

                                                                if price<>0 then
                                                                mMon_Source.BusinessObject[i].SetFieldValueAsFloat('UnitPrice',price);

                                           end;
                                            mBO.Save;
                            end else begin
                               for x := 0 to mBookmark.Count-1 do begin // projdu vsechny oznacene zaznamy
                                        mDBGrid.DataSource.DataSet.GotoBookmark(mBookMark.items(x));

                                        {mMon_Source:= mBO.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('ROWS'));
                                            for i := 0 to mMon_Source.Count - 1 do begin
                                                   mPrice_id:='1000000101';
                                                   if (mMon_Source.BusinessObject[i].GetFieldValueAsString('StoreCard_ID.StoreCardCategory_ID')='1700000101')
                                                       or (mMon_Source.BusinessObject[i].GetFieldValueAsString('StoreCard_ID.StoreCardCategory_ID')='2H00000101')
                                                       or (mMon_Source.BusinessObject[i].GetFieldValueAsString('StoreCard_ID.StoreCardCategory_ID')='1300000101')
                                                       or (mMon_Source.BusinessObject[i].GetFieldValueAsString('StoreCard_ID.StoreCardCategory_ID')='A000000101')

                                                       or (mMon_Source.BusinessObject[i].GetFieldValueAsString('StoreCard_ID.StoreCardCategory_ID')='~00000000B')
                                                        or (mMon_Source.BusinessObject[i].GetFieldValueAsString('StoreCard_ID.StoreCardCategory_ID')='~00000000B')
                                                       // or (Self.GetFieldValueAsString('StoreCard_ID.StoreCardCategory_ID')='')
                                                       // or (Self.GetFieldValueAsString('StoreCard_ID.StoreCardCategory_ID')='')
                                                       // or (Self.GetFieldValueAsString('StoreCard_ID.StoreCardCategory_ID')='')
                                                       // or (Self.GetFieldValueAsString('StoreCard_ID.StoreCardCategory_ID')='')
                                                       // or (Self.GetFieldValueAsString('StoreCard_ID.StoreCardCategory_ID')='')
                                                       // or (Self.GetFieldValueAsString('StoreCard_ID.StoreCardCategory_ID')='')
                                                       // or (Self.GetFieldValueAsString('StoreCard_ID.StoreCardCategory_ID')='')
                                                       // or (Self.GetFieldValueAsString('StoreCard_ID.StoreCardCategory_ID')='')
                                                       // or (Self.GetFieldValueAsString('StoreCard_ID.StoreCardCategory_ID')='')
                                                       // or (Self.GetFieldValueAsString('StoreCard_ID.StoreCardCategory_ID')='')
                                                       // or (Self.GetFieldValueAsString('StoreCard_ID.StoreCardCategory_ID')='')
                                                       // or (Self.GetFieldValueAsString('StoreCard_ID.StoreCardCategory_ID')='')
                                                       // or (Self.GetFieldValueAsString('StoreCard_ID.StoreCardCategory_ID')='')
                                                       // or (Self.GetFieldValueAsString('StoreCard_ID.StoreCardCategory_ID')='')

                                                       or (mMon_Source.BusinessObject[i].GetFieldValueAsString('StoreCard_ID.StoreCardCategory_ID')='1900000101') then begin
                                                            if mMon_Source.BusinessObject[i].GetFieldValueAsString('Store_ID.X_Cena')='R' then begin
                                                               mPrice_id:='4100000101';

                                                            end;
                                                            if mMon_Source.BusinessObject[i].GetFieldValueAsString('Store_ID.X_Cena')='S' then begin
                                                                mPrice_id:= '1000000101';
                                                              mMon_Source.BusinessObject[i].SetFieldValueAsFloat('UnitPrice',price);
                                                        //                ShowMessage('04');
                                                            end;
                                                     end;
                                                      { price:=0;
                                                        mxg:=tstringlist.create;
                                                                try
                                                                    msite.BaseObjectSpace.SQLSelect(format('SELECT a.amount FROM StorePrices2 A JOIN PriceDefinitions PD ON PD.ID=A.Price_ID JOIN StorePrices SP ON SP.ID=A.Parent_ID JOIN StoreCards SC ON SC.ID=SP.StoreCard_ID JOIN PriceLists PL ON PL.ID=SP.PriceList_ID where (pl.id=%s) and (pd.id=%s) and (SP.StoreCard_ID.id=%s)',[quotedstr(mPricelist_id),quotedstr(mPrice_ID), quotedstr(mMon_Source.BusinessObject[i].GetFieldValueAsString('StoreCard_ID'))]),mxg);
                                                                    if mxg.count>0 then begin
                                                                        //NxShowSimpleMessage(mxg.Strings[0],Null);
                                                                        price:=NxIBStrToFloat(mxg.Strings[0]);
                                                                    end;
                                                                finally
                                                                    mxg.free;
                                                                end;

                                                                if price<>0 then
                                                                mMon_Source.BusinessObject[i].SetFieldValueAsFloat('UnitPrice',price);

                                           end;     }
                                             mBO.SetFieldValueAsString('U_DL','_');
                                            mBO.Save;



                                end;
                            end;
                   finally
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
          mMAction.Hint := 'Aktualizace skladových cen';
          mMAction.Caption := 'Aktualizace skladových cen';
          mMAction.Items.Add('Aktualizace skladových cen');
          mMAction.Category := 'tabList';
          mMAction.OnExecuteItem := @OnExec;


end;





begin
end.