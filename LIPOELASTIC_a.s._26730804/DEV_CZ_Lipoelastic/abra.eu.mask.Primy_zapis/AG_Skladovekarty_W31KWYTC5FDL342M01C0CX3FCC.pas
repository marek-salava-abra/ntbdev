
var
     mBookmark : TBookmarkList;

procedure primy_zapis(Sender: TAction; Index: integer);
var
 mbo, mbo_target:TNxCustomBusinessObject;
 mSite: TSiteForm;
 mDBGrid : TDBGrid;
 mTabList: TTabSheet;
 i,ii:integer;
   mForm: TBusRollSiteForm;
   mtext:string;
   mB_Result:boolean;
   mi:integer;
   mr:tstringlist;
   mid:string;
   mole,mroll:variant;
begin
  mtext:='Code=' + quotedstr('');

 exit;
  mSite := NxFindSiteForm(Sender);
    mTabList := TTabSheet(NxFindChildControl(mSite.MainPanel, 'tabList'));
    if mTabList = nil then
        RaiseException('tabList nenalezen');
    mDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdList'));
    if mDBGrid = nil then
        RaiseException('DBGrid nenalezen');
    mBookmark := mDBGrid.SelectedRows; // *** v mBookmark jsou id označených záznamu
    mbo:= TBusRollSiteForm(mSite).CurrentObject;
    //mB_Result:=InputQuery('Zadaj parametry', 'Změna ', mtext);
     mID:='';
     mOLE := GetAbraOLEApplication;
             mroll := mOLE.GetAgenda('N1C2EX0BUJD13ACP03KIU0CLP4');
             mID:=mroll.SingleSelect2('', '');


    if mBookmark.count=0 then begin
                            mr:=tstringlist.create;
                            try
                                  mbo_target:=msite.BaseObjectSpace.CreateObject('O0F5OHLYGNDL342T01C0CX3FCC');
                                  msite.BaseObjectSpace.SQLSelect('select id from Suppliers SP where sp.StoreCard_ID=' + QuotedStr(TBusRollSiteForm(mSite).CurrentObject.oid),mr)  ;
                                  FOR ii:=0 TO mr.count -1 do begin
                                      mbo_target.Load(mr.Strings[ii],nil) ;
                                      mbo_target.Delete;
                                  END;
                                  mbo_target.free;
                                //  TBusRollSiteForm(mSite).CurrentObject.Refresh;

                            finally
                                mr.free;
                            end;

                                      mbo_target:=msite.BaseObjectSpace.CreateObject('O0F5OHLYGNDL342T01C0CX3FCC');
                                      mbo_target.new;
                                      mbo_target.Prefill;
                                      mbo_target.SetFieldValueAsString('Firm_ID',mID)  ;
                                      mbo_target.SetFieldValueAsString('Storecard_ID',TBusRollSiteForm(mSite).CurrentObject.oid)  ;
                                      mbo_target.SetFieldValueAsString('QUnit',TBusRollSiteForm(mSite).CurrentObject.getFieldValueAsString('MainUnitCode'))  ;
                                      //StoreCard_ID ;
                                      mbo_target.save;
                            mi:=msite.BaseObjectSpace.SQLExecute('update storecards set MainSupplier_ID=' + QuotedStr(mbo_target.OID) + ' where id=' + QuotedStr(TBusRollSiteForm(mSite).CurrentObject.oid))  ;
                            //TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('MainSupplier_ID',mbo_target.OID);
                            //TBusRollSiteForm(mSite).CurrentObject.save;
                            mbo_target.free;


                              //TBusRollSiteForm(mSite).CurrentObject.Refresh;
    end else begin
         for i := 0 to mBookmark.Count- 1 do begin
                          mDBGrid.DataSource.DataSet.GotoBookmark(mBookMark.items(i));
                         mr:=tstringlist.create;
                            try
                                  mbo_target:=msite.BaseObjectSpace.CreateObject('O0F5OHLYGNDL342T01C0CX3FCC');
                                  msite.BaseObjectSpace.SQLSelect('select id from Suppliers SP where sp.StoreCard_ID=' + QuotedStr(TBusRollSiteForm(mSite).CurrentObject.oid),mr)  ;
                                  FOR ii:=0 TO mr.count -1 do begin
                                      mbo_target.Load(mr.Strings[ii],nil) ;
                                      mbo_target.Delete;
                                  END;
                                  mbo_target.free;
                                //  TBusRollSiteForm(mSite).CurrentObject.Refresh;

                            finally
                                mr.free;
                            end;

                                      mbo_target:=msite.BaseObjectSpace.CreateObject('O0F5OHLYGNDL342T01C0CX3FCC');
                                      mbo_target.new;
                                      mbo_target.Prefill;
                                      mbo_target.SetFieldValueAsString('Firm_ID',mID)  ;
                                      mbo_target.SetFieldValueAsString('Storecard_ID',TBusRollSiteForm(mSite).CurrentObject.oid)  ;
                                      mbo_target.SetFieldValueAsString('QUnit',TBusRollSiteForm(mSite).CurrentObject.getFieldValueAsString('MainUnitCode'))  ;
                                      //StoreCard_ID ;
                                      mbo_target.save;

                            mi:=msite.BaseObjectSpace.SQLExecute('update storecards set MainSupplier_ID=' + QuotedStr(mbo_target.OID) + ' where id=' + QuotedStr(TBusRollSiteForm(mSite).CurrentObject.oid))  ;
                            mbo_target.free;

         end;

    end;





end;


procedure InitSite_Hook(Self: TBusRollSiteForm);
var
mAction: TAction;
  mMAction: TMultiAction;
begin
if (NxGetActualUserID(self.BaseObjectSpace)='SUPER00000') or (NxGetActualUserID(self.BaseObjectSpace)='1Z10000101') then begin
  mmAction := Self.GetNewMultiAction;
  mmAction.ShowControl := True;
  mmAction.ShowMenuItem := True;
  mmAction.Caption := 'Přímý zápis';
  mmAction.Hint := 'Přímý zápis';
  mmAction.Category := 'tabList';
  mMAction.Items.Add('Pásy');
  mMAction.Items.Add('bandáže');
  mMAction.Items.Add('Podprsenky');

  mmAction.OnExecute:= @primy_zapis;
 end;


end;


begin
end.