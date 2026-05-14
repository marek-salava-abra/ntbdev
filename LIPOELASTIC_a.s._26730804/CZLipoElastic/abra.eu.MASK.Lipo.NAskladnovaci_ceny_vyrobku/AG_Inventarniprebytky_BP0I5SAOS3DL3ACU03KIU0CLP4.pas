uses 'abra.eu.mask.2017.predvyplneni.funkce';

procedure OnExec(Sender: TComponent;index:integer);       // přidělení objectspace a zadání zdrojového souboru
var
    mBO: TNxCustomBusinessObject;
    i : integer;
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
begin
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
                                                   if (mMon_Source.BusinessObject[i].GetFieldValueAsString('StoreCard_ID.StoreCardCategory_ID')='1700000101') or (mMon_Source.BusinessObject[i].GetFieldValueAsString('StoreCard_ID.StoreCardCategory_ID')='2H00000101') or (mMon_Source.BusinessObject[i].GetFieldValueAsString('StoreCard_ID.StoreCardCategory_ID')='1300000101') or (mMon_Source.BusinessObject[i].GetFieldValueAsString('StoreCard_ID.StoreCardCategory_ID')='A000000101') or (mMon_Source.BusinessObject[i].GetFieldValueAsString('StoreCard_ID.StoreCardCategory_ID')='1900000101') then begin
                                                            if mMon_Source.BusinessObject[i].GetFieldValueAsString('Store_ID.X_Cena')='R' then begin
                                                                price:=mMon_Source.BusinessObject[i].getFieldValueAsFloat('StoreCard_ID.X_Cena_rozprac');
                                                                mMon_Source.BusinessObject[i].SetFieldValueAsFloat('UnitPrice',price);
                                                        //                ShowMessage('03');
                                                            end;
                                                            if mMon_Source.BusinessObject[i].GetFieldValueAsString('Store_ID.X_Cena')='S' then begin
                                                                price:=mMon_Source.BusinessObject[i].getFieldValueAsFloat('StoreCard_ID.X_Cena_skladova');
                                                                mMon_Source.BusinessObject[i].SetFieldValueAsFloat('UnitPrice',price);
                                                        //                ShowMessage('04');
                                                            end;
                                                   end;






                                            end;
                                            mBO.Save;
                            end else begin
                               for i := 0 to mBookmark.Count-1 do begin // projdu vsechny oznacene zaznamy
                                        mDBGrid.DataSource.DataSet.GotoBookmark(mBookMark.items(i));


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