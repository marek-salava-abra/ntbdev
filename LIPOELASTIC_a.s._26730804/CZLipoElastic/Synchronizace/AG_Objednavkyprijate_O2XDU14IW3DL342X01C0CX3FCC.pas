  uses  '_Knihovny_ALL.Progress',
      '_Knihovny_ALL.Parse',
      'Synchronizace.API' ;

      const
mTable='ReceivedOrders';
mApiTable='ReceivedOrders';

 procedure Synchronizace(Sender: TObject;index:integer);
var
  mSite: TSiteForm;
  mDBGrid : TDBGrid;
 mTabList: TTabSheet;
  mObj, mObj2: TNxCustomBusinessObject;
  mOLE, mRoll, mOResult: Variant;
  mid_reportx:tstringlist;
  mr,mr0:tstringlist;
  self:TNxCustomBusinessObject;
  mi:integer;
  mBookmark : TBookmarkList;
  mIBookmark:integer;
  mICount:integer;
  mids:string;
 aString:string;
  mstring:string;
  ARequest:string;

  mQuery,mQueryID:string;
  mID:string;
  mNewQueryID:string;
  mSQL:string;
  i,ii,iii:integer;
  mTarget:string;
 mr1:tstringlist;
 mMonRows:TNxCustomBusinessMonikerCollection;
 mMonBatches:TNxCustomBusinessMonikerCollection;
 mDocqueue_ID,mFirm_ID,mStore_ID,mStorecard_ID,mDivision_ID:string   ;
begin
  mids:='';
  if Sender is TComponent then mSite := TComponent(Sender).Site;

//  if Sender is TAction then mSite := NxFindSiteForm(Sender);

    if not Assigned(mSite) then begin
         NxMessageBox('Chyba', 'Agenda nebyla dohledána', mdConfirm, mdbOkCancel, 0, 0, true, nil) ;
         nxbeep(btfailure);
         exit;
    end else begin
        mTabList := TTabSheet(NxFindChildControl(mSite.MainPanel, 'tabList'));
            if mTabList = nil then begin
                  RaiseException('tabList nenalezen');
                  NxMessageBox('Chyba', 'abList nenalezen', mdConfirm, mdbOkCancel, 0, 0, true, nil) ;
                  nxbeep(btfailure);
                  exit;
            end else begin
            mDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdList'));
                if mDBGrid = nil then begin
                      RaiseException('DBGrid nenalezen');
                      NxMessageBox('Chyba', 'DBGrid nenalezen', mdConfirm, mdbOkCancel, 0, 0, true, nil) ;
                      nxbeep(btfailure);
                      exit;
                end else begin
                      mBookmark := mDBGrid.SelectedRows; // *** v mBookmark jsou id označených záznamu
                      mIBookmark:=0;
                      if mBookmark.count>0 then begin
                           mIBookmark:=mBookmark.count-1;
                           ProgressInit(msite, 'Zpracování dat ' + '', 100);
                      end;
                      for mICount:=0 to mIBookmark do begin
                          if mBookmark.count>0 then begin
                               mDBGrid.DataSource.DataSet.GotoBookmark(mBookMark.items(mICount));
                               ProgressSetPos(1+NxFloor(mICount/mBookmark.Count*99), inttostr(mICount) +' z '+inttostr(mBookmark.Count));
                          end;
                          self:=TDynSiteForm(msite).CurrentObject;    // načtení objektu
   if true then begin //NxGetUserName='mskacel' then begin
                if index=0 then begin
                      mTarget:=mTargetAPI + '/';
                      mQuery:=GetDocQuery(Self,'57Q1000101','3010000101','','5131000101','5O10000101','RO')  ;
                end;
//                      mstring:=                      inputbox('OP','POST',mtarget+mApiTable+'' + '       ' + mQuery)    ;
                             mString:= CallRestApi(self,'POST',mtarget,mApiTable,'',mQuery);  // načtení záznamu

    end;




                      end;
                      if mBookmark.count>0 then  ProgressDispose()   ;
                end;
            end;
    end;



end;

procedure FormCreate_Hook(Self: TSiteForm);
var
  mAction: TAction;
  mMAction: TMultiAction;
begin
 { mMAction := Self.GetNewMultiAction;
  mMAction.ShowControl := True;
  mMAction.ShowMenuItem := True;
  mMAction.Caption := 'Synchronizace';
  mMAction.Hint := 'Synchronizace test';
  mMAction.Category := 'tabList';
  mMAction.Items.Add('SK ');
  mMAction.OnExecuteItem := @Synchronizace;}

end;

begin
end.





