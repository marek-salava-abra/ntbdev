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
                                        mBO_Source:=TDynSiteForm(mSite).CurrentObject;
                                        for i := 0 to mMon_Source.Count - 1 do begin
                                            if mMon_Source.BusinessObject[i].GetFieldValueAsFloat('Storecard_ID.X_cena_precen')= 0 then mMon_Source.BusinessObject[i].MarkForDelete;
                                        end;
                                        mBO_Source.Save;
                                        mBO_Source.Refresh;
                                        mBO_Target:= TNxCustomBusinessObject(msite.BaseObjectSpace.CreateObject('2D0I5SAOS3DL3ACU03KIU0CLP4'));
                                       try

                                            mBO_Target.New;
                                            mBO_Target.Prefill;
                                            mBO_Target.SetFieldValueAsString('DocQueue_ID','C700000101');
                                            mBO_Target.SetFieldValueAsDateTime('docDate$date',mBO_Source.GetFieldValueAsDateTime('docDate$date')+1);
                                            mBO_Target.SetFieldValueAsString('Firm_ID',mBO_Source.GetFieldValueAsString('Firm_id'));
                                            mBO_Target.SetFieldValueAsString('Description',mBO_Source.GetFieldValueAsString('Docqueue_ID.Code') + '-' +inttostr(mBO_Source.GetFieldValueAsInteger('ordnumber'))+'/' +mBO_Source.GetFieldValueAsString('Period_ID.Code'));
                                            mMon_Source:= mBO_Source.GetLoadedCollectionMonikerForFieldCode(mBO_Source.GetFieldCode('ROWS'));
                                            for i := 0 to mMon_Source.Count - 1 do begin

                                                    mMon_Target:= mBO_Target.GetCollectionMonikerForFieldCode(mBO_Target.GetFieldCode('Rows')).AddNewObject;
                                                    mMon_Target.Prefill;
                                                    mMon_Target.SetFieldValueAsString('Store_ID',mMon_Source.BusinessObject[i].getFieldValueAsString('Store_ID')); //text bude  ...
                                                    mMon_Target.SetFieldValueAsString('Storecard_ID',mMon_Source.BusinessObject[i].getFieldValueAsString('Storecard_ID'));
                                                    mMon_Target.SetFieldValueAsString('BusOrder_ID',mMon_Source.BusinessObject[i].getFieldValueAsString('BusOrder_ID')); //text bude  ...
                                                    mMon_Target.SetFieldValueAsFloat('Quantity',mMon_Source.BusinessObject[i].getFieldValueAsFloat('Quantity'));
                                                    mMon_Target.SetFieldValueAsFloat('Unitprice',mMon_Source.BusinessObject[i].getFieldValueAsFloat('Storecard_ID.X_cena_precen'));
                                                    mMon_Target.SetFieldValueAsString('Division_ID',mMon_Target.GetFieldValueAsString('Store_ID.X_BusDivision_ID'));
                                                    mMon_Target.SetFieldValueAsString('BusTransaction_ID',mMon_Source.BusinessObject[i].getFieldValueAsString('BusTransaction_ID')); //text bude  ...

                                                    mBO_Source.SetFieldValueAsBoolean('Finished',True)
                                            end;
                                            mBO_Target.Save;

                                        finally
                                            mBO_Target.Free;
                                        end;
                                        //TBusRollSiteForm(mSite).CurrentObject.Refresh;
                            end else begin
                               for i := 0 to mBookmark.Count-1 do begin // projdu vsechny oznacene zaznamy
                                        mDBGrid.DataSource.DataSet.GotoBookmark(mBookMark.items(i));
                                              mBO := TDynSiteForm(mSite).CurrentObject;
                                        mBO_Source:=TDynSiteForm(mSite).CurrentObject;
                                        for i := 0 to mMon_Source.Count - 1 do begin
                                            if mMon_Source.BusinessObject[i].GetFieldValueAsFloat('Storecard_ID.X_cena_precen')= 0 then mMon_Source.BusinessObject[i].MarkForDelete;
                                        end;
                                        mBO_Source.Save;
                                        mBO_Source.Refresh;
                                        mBO_Target:= TNxCustomBusinessObject(msite.BaseObjectSpace.CreateObject('2D0I5SAOS3DL3ACU03KIU0CLP4'));
                                       try

                                            mBO_Target.New;
                                            mBO_Target.Prefill;
                                            mBO_Target.SetFieldValueAsString('DocQueue_ID','C700000101');
                                            mBO_Target.SetFieldValueAsString('Firm_ID',mBO_Source.GetFieldValueAsString('Firm_id'));
                                            mBO_Target.SetFieldValueAsString('Description',mBO_Source.GetFieldValueAsString('Docqueue_ID.Code') + '-' +inttostr(mBO_Source.GetFieldValueAsInteger('ordnumber'))+'/' +mBO_Source.GetFieldValueAsString('Period_ID.Code'));
                                            mMon_Source:= mBO_Source.GetLoadedCollectionMonikerForFieldCode(mBO_Source.GetFieldCode('ROWS'));
                                            for i := 0 to mMon_Source.Count - 1 do begin

                                                    mMon_Target:= mBO_Target.GetCollectionMonikerForFieldCode(mBO_Target.GetFieldCode('Rows')).AddNewObject;
                                                    mMon_Target.Prefill;
                                                    mMon_Target.SetFieldValueAsString('Store_ID',mMon_Source.BusinessObject[i].getFieldValueAsString('Store_ID')); //text bude  ...
                                                    mMon_Target.SetFieldValueAsString('Storecard_ID',mMon_Source.BusinessObject[i].getFieldValueAsString('Storecard_ID'));
                                                    mMon_Target.SetFieldValueAsString('BusOrder_ID',mMon_Source.BusinessObject[i].getFieldValueAsString('BusOrder_ID')); //text bude  ...
                                                    mMon_Target.SetFieldValueAsFloat('Quantity',mMon_Source.BusinessObject[i].getFieldValueAsFloat('Quantity'));
                                                    mMon_Target.SetFieldValueAsFloat('Unitprice',mMon_Source.BusinessObject[i].getFieldValueAsFloat('Storecard_ID.X_cena_precen'));
                                                    mMon_Target.SetFieldValueAsString('Division_ID',mMon_Target.GetFieldValueAsString('Store_ID.X_BusDivision_ID'));
                                                    mMon_Target.SetFieldValueAsString('BusTransaction_ID',mMon_Source.BusinessObject[i].getFieldValueAsString('BusTransaction_ID')); //text bude  ...

                                                    mBO_Source.SetFieldValueAsBoolean('Finished',True)
                                            end;
                                            mBO_Target.Save;
;
                                        finally
                                            mBO_Target.Free;
                                        end;

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
          mMAction.Hint := 'Přecenění ';
          mMAction.Caption := 'Přecenění';
          mMAction.Items.Add('Přecenění');
          mMAction.Category := 'tabList';
          mMAction.OnExecuteItem := @OnExec;


end;





begin
end.