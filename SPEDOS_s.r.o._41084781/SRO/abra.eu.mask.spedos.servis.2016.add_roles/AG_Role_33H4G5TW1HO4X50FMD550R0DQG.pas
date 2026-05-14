var
    mBO_BusProject:TNxCustomBusinessObject;
    mF_doba:double;
    mRows : TNxCustomBusinessMonikerCollection;
    result:boolean;
    mresult:boolean;
      mBookmark : TBookmarkList;
      morigstate,mstate:string;
      mpotvrzeni:string;

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
          mWorker:=TStringList.create;
          mOLE:= GetAbraOLEApplication;
          mOResult:= mOLE.CreateStrings;
              mRoll:=mOLE.GetRoll('BAM0CP0G24CONI4CCOMFMW04CW', 0);
              if not mRoll.multiSelectDialog(true,mOResult) then Exit;
                mWorker.Text:= mOResult.Text;
                NxShowSimpleMessage(inttostr(mWorker.Count),nil);
                try
                        mBO := TBusRollSiteForm(mSite).CurrentObject;
                        if mBookmark.count=0 then begin
                            for ii:=0 to mWorker.count-1 do begin
                                MBO1:=mSite.BaseObjectSpace.CreateObject('5HNBHU3QW53OR01YZQ12NYG2BS') ;
                                mbo1.New;
                                mbo1.SetFieldValueAsString('Parent_ID',mWorker.Strings[ii]);
                                mbo1.SetFieldValueAsString('SecurityRole_ID',mbo.OID);
                                mbo1.save;
                                //NxShowSimpleMessage(mWorker.Strings[ii],nil);

                            end;
                        //
                              //mi:=msite.BaseObjectSpace.SQLExecute('update ServiceDocuments set ServiceDocState_ID=' + quotedstr(mstate) + ' where id=' +quotedstr(mbo.oid));
                        end else begin
                           for i := 0 to mBookmark.Count-1 do begin // projdu vsechny oznacene zaznamy
                                    mDBGrid.DataSource.DataSet.GotoBookmark(mBookMark.items(i));
                                    mBO := TBusRollSiteForm(mSite).CurrentObject;
                                    for ii:=0 to mWorker.count-1 do begin
                                        MBO1:=mSite.BaseObjectSpace.CreateObject('5HNBHU3QW53OR01YZQ12NYG2BS') ;
                                        mbo1.New;
                                        mbo1.SetFieldValueAsString('Parent_ID',mWorker.Strings[ii]);
                                        mbo1.SetFieldValueAsString('SecurityRole_ID',mbo.OID);
                                        mbo1.save;
                                        //NxShowSimpleMessage(mWorker.Strings[ii],nil);

                                    end;
                           end;
                        end;
               finally
               end;
         mworker.free;
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
            if mUser.GetFieldValueAsString('Name')='Supervisor' then mUserFilter:= true;
  finally
    mUser.Free;
  end;
  mMAction := Self.GetNewMultiAction;
  mMAction.ShowControl := True;
  mMAction.ShowMenuItem := True;
  mMAction.Caption := 'Přidání do pracovišť';
  mMAction.Hint := 'Přidání do pracovišť';
  mMAction.Category := 'tabList';
  mMAction.OnExecuteItem := @FVExecuteItem;
  mMAction.Items.Add('Přidání do pracovišť');



end;


begin
end.




