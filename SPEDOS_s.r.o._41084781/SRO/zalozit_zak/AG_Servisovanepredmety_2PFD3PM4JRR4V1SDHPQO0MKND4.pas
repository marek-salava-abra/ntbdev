var
    mFSazba_hod_den,mFDoprava_km,mF_doprava_pausal,mFSazba_hod:double;
    mBO_BusProject:TNxCustomBusinessObject;
    mF_pausal_prace,mF_pausal_Vyjezd,mF_prace,mF_km:double;
    // doby + termíny
    mF_doba:double;
    mRows : TNxCustomBusinessMonikerCollection;
    result:boolean;
    mresult:boolean;
      mBookmark : TBookmarkList;
          mOLE, mRoll, mOResult: Variant;
    mids:tstringlist;

procedure SloucitExecuteItem(Sender: TAction; Index: integer);
var
 mresult:Boolean;
 mtext:string;
 mImportMan:TNxDocumentImportManager;
 mbo:TNxCustomBusinessObject;
 mbo_busOrder:TNxCustomBusinessObject;
 mSite: TSiteForm;
  mDBGrid : TDBGrid;
    mTabList: TTabSheet;
  mUser:TNxCustomBusinessObject;
  i,ii:integer;
  mr,mIDs_MLRow:TStringList;
   mForm: TRollSiteForm;
   mMon: TNxCustomBusinessMonikerCollection;
   mRow, mNewRow,mbo1: TNxCustomBusinessObject;
   mdate:Double;
   morig:string;
   mi:Integer;
   mlist:TStringList;
   mfirm_ID,mPayerFirm_ID:string;
   mprefix:string;
   mDivision_Code,mPersNumber,mPeriod:string;
begin
    mSite := NxFindSiteForm(TComponent(Sender));
    mUser := mSite.BaseObjectSpace.CreateObject('22AHIVDVAVE13C5S00CA141B44');            // přihlášený uživatel
    mprefix:='';
  try
      mUser.Load(mSite.CompanyCache.GetUserID, nil);
            mDivision_Code:=copy(muser.GetFieldValueAsString('X_Division_ID.Code'),1,3);
            mPersNumber:=copy(muser.GetFieldValueAsString('ShortName'),1,3);
            mPeriod:=copy(inttostr(NxGetYear(now)),2,3);
  finally
    mUser.Free;
  end;
    mTabList := TTabSheet(NxFindChildControl(mSite.MainPanel, 'tabList'));
    if mTabList = nil then RaiseException('tabList nenalezen');
    mDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdList'));
    if mDBGrid = nil then RaiseException('DBGrid nenalezen');
    mBookmark := mDBGrid.SelectedRows; // *** v mBookmark jsou id označených záznamu
       morig:=TBusRollSiteForm(mSite).CurrentObject.oid;
        mprefix:='S'+mPeriod + mDivision_Code+mPersNumber+'S' ;




        if mBookmark.count=0 then begin
            mBO := TBusRollSiteForm(mSite).CurrentObject;
                   if NxIsEmptyOID(mBO.getFieldValueAsstring('BusOrder_id')) then begin
                        mr:=tstringlist.create;
                             try
                               msite.BaseObjectSpace.SQLSelect('select max(substring(code from 12 for 4)) from BusOrders where substring(code from 1 for 11)='+quotedstr(mprefix),mr);
                               if mr.Strings[0]<>'""' then begin
                                  NxShowSimpleMessage(mprefix+inttostr(strtoint(mr.Strings[0])+1),nil);
                               end else begin
                                  NxShowSimpleMessage(mprefix+'0001',nil);
                               end;
                            {   mbo_busOrder:=mbo.ObjectSpace.CreateObject('K2WTYL304VD13ACL03KIU0CLP4');
                                      try
                                          mbo_busOrder.new;
                                          mbo_busOrder.Prefill;
                                          mbo_busOrder.SetFieldValueAsString('Code',mPrefix);
                                          mbo_busOrder.SetFieldValueAsString('Name',mbo.GetFieldValueAsString('Name'));

                                          mbo_busOrder.Save;
                                      finally
                                          mbo_busOrder.free;
                                      end;
                                   }

                             finally
                                mr.free;
                             end;

                    end;



        end else begin
            for i := 0 to mBookmark.Count-1 do begin // projdu vsechny oznacene zaznamy
                    mDBGrid.DataSource.DataSet.GotoBookmark(mBookMark.items(i));
                    mBO := TBusRollSiteForm(mSite).CurrentObject;
                   if NxIsEmptyOID(mBO.getFieldValueAsstring('BusOrder_id')) then begin
                        mr:=tstringlist.create;
                             try
                               msite.BaseObjectSpace.SQLSelect('select substring(max(code) from 12 for 4) from BusOrders where substring(code from 1 for 11]='+quotedstr(mprefix),mr);
                               if mr.count>0 then begin
                                  //mprefix:=mprefix + NxTrimR(('0000'+inttostr(strtoint(mr.Strings[0])+1)),4);
                                  NxShowSimpleMessage(mprefix,nil);
                               end else begin
                                  mprefix:=mprefix + '0001';
                                  NxShowSimpleMessage(mprefix,nil);
                               end;
                              { mbo_busOrder:=mbo.ObjectSpace.CreateObject('K2WTYL304VD13ACL03KIU0CLP4');
                                      try
                                          mbo_busOrder.new;
                                          mbo_busOrder.Prefill;
                                          mbo_busOrder.SetFieldValueAsString('Code',mPrefix);
                                          mbo_busOrder.SetFieldValueAsString('Name',mbo.GetFieldValueAsString('Name'));

                                          mbo_busOrder.Save;
                                      finally
                                          mbo_busOrder.free;
                                      end;

                                        }
                             finally
                                mr.free;
                             end;

                    end;
        end;
    end;

 TBusRollSiteForm(mSite).Refresh;
 mDBGrid.Refresh;
     msite.Refresh;
     //msite.ActiveDataSet.seekid(mbo.oid);
     //msite.ActiveDataSet.RefreshAndRestoreLastSelectedItem;
end;

procedure InitSite_Hook(Self: TSiteForm);
var
mAction: TAction;
  mMAction: TMultiAction;
  mUserFilter: Boolean;
  mUser: TNxCustomBusinessObject;
begin

     mMAction := Self.GetNewMultiAction;
  mMAction.ShowControl := True;
  mMAction.ShowMenuItem := True;
  mMAction.Caption := 'zal zakakzku';
  mMAction.Hint := 'zal zakakzku';
  mMAction.Category := 'tabList';
  mMAction.OnExecuteItem := @SloucitExecuteItem;
  mMAction.Items.Add('zal zakakzku');


end;


begin
end.