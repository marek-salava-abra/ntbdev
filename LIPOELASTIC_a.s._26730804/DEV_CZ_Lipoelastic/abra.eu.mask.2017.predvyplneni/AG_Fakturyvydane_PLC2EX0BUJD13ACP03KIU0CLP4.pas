uses 'abra.eu.mask.2017.predvyplneni.funkce', 'EU.Aabra.Mask.Validace.lib';

procedure OnExec(Sender: TComponent;index:integer);       // přidělení objectspace a zadání zdrojového souboru
var
    mBO: TNxCustomBusinessObject;
    i,ii : integer;
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
  mi:integer;
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
                                        mMon := mBO.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('ROWS'));
                                        for i := 0 to mMon.Count - 1 do begin


                                                      if mMon.BusinessObject[i].GetFieldValueAsInteger('Rowtype')=3 then begin
                                                            //mMon.BusinessObject[i].SetFieldValueAsString('BusOrder_id','');
                                                            //mMon.BusinessObject[i].SetFieldValueAsString('BusProject_id','');

                                                              if not NxIsEmptyOID((mMon.BusinessObject[i].GetFieldValueAsString('StoreCard_id.X_BusTransaction_ID'))) then begin
                                                                         mBustransaction_ID:='';
                                                                         mBustransaction_ID:=(mMon.BusinessObject[i].GetFieldValueAsString('StoreCard_id.X_BusTransaction_ID'));
                                                                         //if mBustransaction_ID<>'' then  mMon.BusinessObject[i].SetFieldValueAsString('BusTransaction_id',mBustransaction_ID );
                                                                            if mBustransaction_ID<>'' then    mi:=mSite.BaseObjectSpace.SQLExecute('update issuedinvoices2 set BusTransaction_id=' + quotedstr(mBustransaction_ID) + ' where id=' + quotedstr(mMon.BusinessObject[i].oid));
                                                              end;

                                                          // if NxIsEmptyOID(mMon.BusinessObject[i].getFieldValueAsString('BusOrder_id')) then begin
                                                                mBusOrder_ID:='';

                                                                mBusOrder_ID:=GetBusOrder_ID(mMon.BusinessObject[i]);
                                                              //  if mBusOrder_ID<>'' then  mMon.BusinessObject[i].SetFieldValueAsString('BusOrder_id',mBusOrder_ID);
                                                            if mBusOrder_ID<>'' then mi:=mSite.BaseObjectSpace.SQLExecute('update issuedinvoices2 set BusOrder_id=' + quotedstr(mBusOrder_ID) + ' where id=' + quotedstr(mMon.BusinessObject[i].oid));

                                                          // end;
                                                          // if NxIsEmptyOID(mMon.BusinessObject[i].getFieldValueAsString('BusProject_id')) then begin
                                                                mBusProject_ID:='';

                                                                mBusProject_ID:=GetProject_ID(mMon.BusinessObject[i]);
                                                               // if mBusProject_ID<>'' then  mMon.BusinessObject[i].SetFieldValueAsString('BusProject_id',mBusProject_ID);
                                                            if mBusProject_ID<>'' then mi:=mSite.BaseObjectSpace.SQLExecute('update issuedinvoices2 set BusProject_id=' + quotedstr(mBusProject_ID) + ' where id=' + quotedstr(mMon.BusinessObject[i].oid));

                                                          // end;
                                                      end;
                                                end;   // konec řádku
                                        //mbo.Save;
                                        //TBusRollSiteForm(mSite).CurrentObject.Refresh;
                            end else begin
                               for ii := 0 to mBookmark.Count-1 do begin // projdu vsechny oznacene zaznamy
                                        mDBGrid.DataSource.DataSet.GotoBookmark(mBookMark.items(ii));
                                              mBO := TDynSiteForm(mSite).CurrentObject;
                                                        mMon := mBO.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('ROWS'));
                                              for i := 0 to mMon.Count - 1 do begin



                                                      //NxShowSimpleMessage(mbo.oid,nil);

                                                          if mMon.BusinessObject[i].GetFieldValueAsInteger('Rowtype')=3 then begin
                                                            //mMon.BusinessObject[i].SetFieldValueAsString('BusOrder_id','');
                                                            //mMon.BusinessObject[i].SetFieldValueAsString('BusProject_id','');

                                                              if not NxIsEmptyOID((mMon.BusinessObject[i].GetFieldValueAsString('StoreCard_id.X_BusTransaction_ID'))) then begin
                                                                         mBustransaction_ID:='';
                                                                         mBustransaction_ID:=(mMon.BusinessObject[i].GetFieldValueAsString('StoreCard_id.X_BusTransaction_ID'));
                                                                         //if mBustransaction_ID<>'' then  mMon.BusinessObject[i].SetFieldValueAsString('BusTransaction_id',mBustransaction_ID );
                                                                            if mBustransaction_ID<>'' then    mi:=mSite.BaseObjectSpace.SQLExecute('update issuedinvoices2 set BusTransaction_id=' + quotedstr(mBustransaction_ID) + ' where id=' + quotedstr(mMon.BusinessObject[i].oid));
                                                              end;

                                                          // if NxIsEmptyOID(mMon.BusinessObject[i].getFieldValueAsString('BusOrder_id')) then begin
                                                                mBusOrder_ID:='';

                                                                mBusOrder_ID:=GetBusOrder_ID(mMon.BusinessObject[i]);
                                                              //  if mBusOrder_ID<>'' then  mMon.BusinessObject[i].SetFieldValueAsString('BusOrder_id',mBusOrder_ID);
                                                            if mBusOrder_ID<>'' then mi:=mSite.BaseObjectSpace.SQLExecute('update issuedinvoices2 set BusOrder_id=' + quotedstr(mBusOrder_ID) + ' where id=' + quotedstr(mMon.BusinessObject[i].oid));

                                                        //   end;
                                                        //   if NxIsEmptyOID(mMon.BusinessObject[i].getFieldValueAsString('BusProject_id')) then begin
                                                                mBusProject_ID:='';

                                                                mBusProject_ID:=GetProject_ID(mMon.BusinessObject[i]);
                                                               // if mBusProject_ID<>'' then  mMon.BusinessObject[i].SetFieldValueAsString('BusProject_id',mBusProject_ID);
                                                            if mBusProject_ID<>'' then mi:=mSite.BaseObjectSpace.SQLExecute('update issuedinvoices2 set BusProject_id=' + quotedstr(mBusProject_ID) + ' where id=' + quotedstr(mMon.BusinessObject[i].oid));

                                                        //  end;
                                                    end;
                                                end;   // konec řádku
                                           //mbo.Save;

                                         //  mDBGrid.DataSource.DataSet.refresh;
                                            //TBusRollSiteForm(mSite).CurrentObject.Refresh;


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
          mMAction.Hint := 'Doplnění statistik';
          mMAction.Caption := 'Doplnění statistik';
          mMAction.Items.Add('Doplnění statistik');
          mMAction.Category := 'tabList';
          mMAction.OnExecuteItem := @OnExec;


end;


begin
end.





begin
end.