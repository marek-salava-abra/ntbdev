var
    mBO_BusProject:TNxCustomBusinessObject;
    mF_doba:double;
    mRows : TNxCustomBusinessMonikerCollection;
    result:boolean;
    mresult:boolean;
      mBookmark : TBookmarkList;
      morigstate,mstate:string;
      mpotvrzeni:string;




      //vrací cenu z hl. ceníku&#xD;
function GetPriceFromMainPriceList(AOS: TNxCustomObjectSpace; AStorecard_ID, AQUnit, APriceDef_ID: String):Double;
var mSQL:String;
begin
  mSQL := 'Select FIRST 1 Amount as Hodnota FROM storeprices2 SP2x JOIN storeprices SPx on SPx.ID = SP2x.parent_id' +
          ' LEFT JOIN PriceListValidities PLV3 on PLV3.ID = SPx.PRICELISTVALIDITY_ID WHERE' +
          Format(' SP2x.price_id = %s and', [QuotedStr(APriceDef_ID)]) +
          Format(' SP2x.qunit = %s and  SPx.pricelist_id = (SELECT PriceList_ID FROM globdata) and ', [QuotedStr(AQUnit)]) +
          Format(' SPx.StoreCard_ID = %s and  Coalesce(PLV3.ValidFromDate$Date, 0.0) &lt;= %s', [QuotedStr(AStorecard_ID), FloatToStr(Date)]) +
          ' ORDER BY PLV3.ValidFromDate$DATE DESC NULLS LAST';
  result := GetFirstRowFromSQL(AOS, mSQL, 0);
end;

function GetFirstRowFromSQL(AOS: TNxCustomObjectSpace; ASQL: string; ADefault: Variant): Variant;
var
  mr:tstringlist;
begin
  result := ADefault;
  mr:=tstringlist.create;
  try
    AOS.SQLSelect(ASQL, mr);
    if not mr.count=0 then begin

      Result := mr.Strings[0];
    end else begin
      Result := 0;
    end;
  finally
    mr.free;
  end;
end;





procedure FVExecuteItem(Sender: TAction; Index: integer);
var
 mresult:Boolean;
 mtext:string;
 mbo:TNxCustomBusinessObject;
 mbo_SL:TNxCustomBusinessObject;
 mSite: TBusRollSiteForm;
  mDBGrid : TDBGrid;
    mTabList: TTabSheet;
  self:TNxCustomBusinessObject;
  i,ii:integer;
  mr,mr1,mr2,mIDs_MLRow:TStringList;
   mForm: TBusRollSiteForm;
   mMon: TNxCustomBusinessMonikerCollection;
   mRow, mNewRow,mbo1: TNxCustomBusinessObject;
   mdate:Double;
   mr_technik,mr_material:tstringlist;
   mr_ML:tstringlist;
   mOLE, mRoll, mOResult: Variant;
   mids:TStringList;
   mBO_nabidka:TNxCustomBusinessObject;
   mNabidka_ID:string;
   mstavpomoc:boolean;
   mobjednavka:string;
   mr_sum,mWorker:TStringList;
   mstav_rozprac:string;
   mi:integer;
begin
    mstavpomoc:=false;
    mSite := TComponent(Sender).BusRollSite;
    mTabList := TTabSheet(NxFindChildControl(mSite.MainPanel, 'tabList'));
    if mTabList = nil then RaiseException('tabList nenalezen');
    mDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdList'));
    if mDBGrid = nil then RaiseException('DBGrid nenalezen');
    mBookmark := mDBGrid.SelectedRows; // *** v mBookmark jsou id označených záznamu

                try
                        mBO := TBusRollSiteForm(mSite).CurrentObject;
                        if mBookmark.count=0 then begin
                            TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsfloat('X_BasePrice',
                                      GetPriceFromMainPriceList(TBusRollSiteForm(mSite).BaseObjectSpace, TBusRollSiteForm(mSite).CurrentObject.oid, TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('MainUnitCode'),
                                       '1000000101'));



                                TBusRollSiteForm(mSite).CurrentObject.save;
                                //NxShowSimpleMessage(mWorker.Strings[ii],nil);


                        //
                              //mi:=msite.BaseObjectSpace.SQLExecute('update ServiceDocuments set ServiceDocState_ID=' + quotedstr(mstate) + ' where id=' +quotedstr(mbo.oid));
                        end else begin
                           for i := 0 to mBookmark.Count-1 do begin // projdu vsechny oznacene zaznamy
                                    mDBGrid.DataSource.DataSet.GotoBookmark(mBookMark.items(i));
                                    TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsfloat('X_BasePrice',
                                      GetPriceFromMainPriceList(TBusRollSiteForm(mSite).BaseObjectSpace,
                                      TBusRollSiteForm(mSite).CurrentObject.oid, TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('MainUnitCode'), '1000000101'));



                                TBusRollSiteForm(mSite).CurrentObject.save;
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
            if mUser.GetFieldValueAsString('Name')='Supervisor' then begin

                              mMAction := Self.GetNewMultiAction;
                    mMAction.ShowControl := True;
                    mMAction.ShowMenuItem := True;
                    mMAction.Caption := 'Aktualizace base price';
                    mMAction.Hint := 'Aktualizace base price';
                    mMAction.Category := 'tabList';
                    mMAction.OnExecuteItem := @FVExecuteItem;
                    mMAction.Items.Add('Aktualizace base price');
                    mUserFilter:= true;
  end;

  finally
    mUser.Free;
  end;




end;


begin
end.




