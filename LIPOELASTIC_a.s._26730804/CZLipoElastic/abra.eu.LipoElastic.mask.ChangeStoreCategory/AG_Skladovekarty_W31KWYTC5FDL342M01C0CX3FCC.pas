
procedure batchOnExec(Sender: TComponent;index:integer);       // přidělení objectspace a zadání zdrojového souboru
var
    mBO: TNxCustomBusinessObject;
    i : integer;
  mSite: TSiteForm;
  mbookmark:TBookmarkList;
  mdbgrid:TDBGrid;
  mr,mx:tstringlist;
  mBO_Batch,mBO_SubBatch,mBO_storesubcards:TNxCustomBusinessObject;
  mID_batch:string;

 mTabList: TTabSheet;
begin
    if Sender is TComponent then begin
          mSite := NxFindSiteForm(Sender);

          if Assigned(mSite) and (mSite is TBusRollSiteForm) then begin
               mTabList := TTabSheet(NxFindChildControl(mSite.MainPanel, 'tabList'));
                  if mTabList = nil then
                      RaiseException('tabList nenalezen');
                  mDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdList'));
                  if mDBGrid = nil then
                      RaiseException('DBGrid nenalezen');
                  mBookmark := mDBGrid.SelectedRows; // *** v mBookmark jsou id označených záznamu


               mbo:= TBusRollSiteForm(mSite).CurrentObject;
                    try
                            if mBookmark.count=0 then begin
                                        mBO := TBusRollSiteForm(mSite).CurrentObject;
                                        mbo.SetFieldValueAsInteger('Category',2);
                                        mbo.Save;


                                         mx:=tstringlist.create;
                                            try
                                                   mbo.ObjectSpace.SQLSelect('Select id from StoreBatches where name=' + quotedstr(mbo.GetFieldValueAsString('EAN')) + ' and Storecard_id=' + quotedstr(mbo.oid),mx);
                                                   if mx.count>0 then begin
                                                       mID_batch:=mx.Strings[0] ;
                                                   end else begin
                                                        mBO_Batch:= mbo.ObjectSpace.CreateObject('C32QXZWCTVDL342W01C0CX3FCC');
                                                        try
                                                              mBO_Batch.new;
                                                              mBO_Batch.Prefill;
                                                              mBO_Batch.SetFieldValueAsString('StoreCard_ID',mbo.OID) ;
                                                              mBO_Batch.SetFieldValueAsDateTime('ProductionDate$DATE',now) ;
                                                              mBO_Batch.SetFieldValueAsDateTime('ExpirationDate$Date',NxIncDate(Now,mbo.GetFieldValueAsInteger('ExpirationDue'),0,0)) ;   //1096
                                                              mBO_Batch.SetFieldValueAsString('Name',mbo.GetFieldValueAsString('EAN')) ;
                                                              mBO_Batch.SetFieldValueAsBoolean('SerialNumber',False) ;
                                                              //mBO_Batch.SetFieldValueAsString('Note','') ;
                                                              //mBO_Batch.SetFieldValueAsString('Specification','') ;

                                                             mBO_Batch.save;
                                                             mID_batch:=mBO_Batch.oid;
                                                        finally
                                                            mBO_Batch.free;
                                                        end;
                                                   end;
                                            finally
                                               mx.free;
                                            end;





                                        mr:=tstringlist.create;
                                        try
                                            mbo.ObjectSpace.SQLSelect('Select id from StoreSubCards where quantity>0 and Storecard_id=' + quotedstr(mbo.oid),mr);
                                            if mr.count>0 then begin


                                                                for i:=0 to mr.count-1 do begin

                                                                 end;
                                            end;
                                        finally
                                           mr.free;
                                        end;



                            end else begin
                               for i := 0 to mBookmark.Count-1 do begin // projdu vsechny oznacene zaznamy
                                        mDBGrid.DataSource.DataSet.GotoBookmark(mBookMark.items(i));
                                        mBO := TBusRollSiteForm(mSite).CurrentObject;
                                        mbo.SetFieldValueAsInteger('Category',2);
                                        mbo.Save;
                                       // NxShowSimpleMessage(inttostr(i)+ mbo.OID,nil);

                                         mx:=tstringlist.create;
                                            try
                                                   mbo.ObjectSpace.SQLSelect('Select id from StoreBatches where name=' + quotedstr(mbo.GetFieldValueAsString('EAN')) + ' and Storecard_id=' + quotedstr(mbo.oid),mx);
                                                   if mx.count>0 then begin
                                                       mID_batch:=mx.Strings[0] ;
                                                   end else begin
                                                        mBO_Batch:= mbo.ObjectSpace.CreateObject('C32QXZWCTVDL342W01C0CX3FCC');
                                                        try
                                                              mBO_Batch.new;
                                                              mBO_Batch.Prefill;
                                                              mBO_Batch.SetFieldValueAsString('StoreCard_ID',mbo.OID) ;
                                                              mBO_Batch.SetFieldValueAsDateTime('ProductionDate$DATE',now) ;
                                                              mBO_Batch.SetFieldValueAsDateTime('ExpirationDate$Date',NxIncDate(Now,mbo.GetFieldValueAsInteger('ExpirationDue'),0,0)) ;   //1096
                                                              mBO_Batch.SetFieldValueAsString('Name',mbo.GetFieldValueAsString('EAN')) ;
                                                              mBO_Batch.SetFieldValueAsBoolean('SerialNumber',False) ;
                                                              //mBO_Batch.SetFieldValueAsString('Note','') ;
                                                              //mBO_Batch.SetFieldValueAsString('Specification','') ;

                                                             mBO_Batch.save;
                                                             mID_batch:=mBO_Batch.oid;
                                                        finally
                                                            mBO_Batch.free;
                                                        end;
                                                   end;
                                            finally
                                               mx.free;
                                            end;





                                        mr:=tstringlist.create;
                                        try
                                            mbo.ObjectSpace.SQLSelect('Select id from StoreSubCards where quantity>0 and Storecard_id=' + quotedstr(mbo.oid),mr);
                                            if mr.count>0 then begin


                                                                for i:=0 to mr.count-1 do begin

                                                                 end;
                                            end;
                                        finally
                                           mr.free;
                                        end;

                                end;
                            end;
                   finally
                   end;
                 TBusRollSiteForm(mSite).RefreshData;



            end;
    end;
end;





procedure OnExec(Sender: TComponent;index:integer);       // přidělení objectspace a zadání zdrojového souboru
var
    mBO: TNxCustomBusinessObject;
    i : integer;
  mSite: TSiteForm;
  mbookmark:TBookmarkList;
  mdbgrid:TDBGrid;
  mstring:string;
begin



    if Sender is TComponent then begin
          mSite := NxFindSiteForm(Sender);
          if Assigned(mSite) and (mSite is TBusRollSiteForm) then begin
               mbo:= TBusRollSiteForm(mSite).CurrentObject;
                    try

                            if mBookmark.count=0 then begin
                                        mBO := TBusRollSiteForm(mSite).CurrentObject;
                                        if index<=4 then mbo.SetFieldValueAsInteger('Category',index);
                                        if index=5 then begin
                                            mstring:='';
                                            mstring:=mbo.getFieldValueAsString('X_verze');
                                                 mbo.setFieldValueAsString('X_verze','');
                                                 mbo.setFieldValueAsString('X_verze',mstring);

                                            mstring:='';
                                            mstring:=mbo.getFieldValueAsString('X_Parent_ID');
                                                 mbo.setFieldValueAsString('X_Parent_ID','');
                                                 mbo.setFieldValueAsString('X_Parent_ID',mstring);
                                        end;
                                        mbo.Save;
                            end else begin
                               for i := 0 to mBookmark.Count-1 do begin // projdu vsechny oznacene zaznamy
                                        mDBGrid.DataSource.DataSet.GotoBookmark(mBookMark.items(i));
                                              mBO := TBusRollSiteForm(mSite).CurrentObject;
                                             if index<=4 then mbo.SetFieldValueAsInteger('Category',index);
                                              if index=5 then begin
                                                mstring:='';
                                                  mstring:=mbo.getFieldValueAsString('X_verze');
                                                     mbo.setFieldValueAsString('X_verze','');
                                                     mbo.setFieldValueAsString('X_verze',mstring);

                                                  mstring:='';
                                                  mstring:=mbo.getFieldValueAsString('X_Parent_ID');
                                                     mbo.setFieldValueAsString('X_Parent_ID','');
                                                     mbo.setFieldValueAsString('X_Parent_ID',mstring);
                                        end;
                                             mbo.Save;
                                end;
                            end;
                   finally
                   end;
                 TBusRollSiteForm(mSite).RefreshData;



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
    mUserFilter:=true;
    mUser := Self.BaseObjectSpace.CreateObject('22AHIVDVAVE13C5S00CA141B44');
    try
      mUser.Load(Self.CompanyCache.GetUserID, nil);
            mUserFilter:= mUser.GetFieldValueAsBoolean('X_ChangeStoreCtaegory');

    finally
      mUser.Free;
    end;
        if mUserFilter then begin
          mMAction := Self.GetNewMultiAction;
          mMAction.ShowControl := True;
          mMAction.ShowMenuItem := True;
          mMAction.Hint := 'Změna typu skladové karty';
          mMAction.Caption := 'Hromadná změna typu skladové karty';
          mMAction.Items.Add('Jednoduchá karta');
          mMAction.Items.Add('Se seriovým číslem');
          mMAction.Items.Add('S šarží');
          mMAction.Items.Add('');
          mMAction.Items.Add('Obalový materiál');
          mMAction.Items.Add('Historie');
          mMAction.Category := 'tabList';
          mMAction.OnExecuteItem := @OnExec;


          mMAction := Self.GetNewMultiAction;
          mMAction.ShowControl := True;
          mMAction.ShowMenuItem := True;
          mMAction.Hint := 'Převod na šaržování';
          mMAction.Caption := 'Převod na šaržování';
          mMAction.Items.Add('Převod na šaržování');

          mMAction.Category := 'tabList';
          mMAction.OnExecuteItem := @BatchOnExec;



      end;
end;


begin
end.