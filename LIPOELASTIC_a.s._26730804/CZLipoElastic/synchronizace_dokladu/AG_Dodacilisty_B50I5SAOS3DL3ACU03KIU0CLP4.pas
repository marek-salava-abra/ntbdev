  uses  '_Knihovny_ALL.Progress',
      '_Knihovny_ALL.Parse',
      'Synchronizace.API' ;

      const
mTable='ReceiptCards';
mApiTable='ReceiptCards';

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
 mBO:TNxCustomBusinessObject;
begin
  mids:='';
  if Sender is TComponent then mSite := TComponent(Sender).Site;

//  if Sender is TAction then mSite := NxFindSiteForm(Sender);

                          self:=TDynSiteForm(msite).CurrentObject;    // načtení objektu
                                     if true then begin //NxGetUserName='mskacel' then begin
                                                  if index=0 then begin
                                                         mid:='';



                                                                            mTarget:='http://10.5.5.11:83/SK_LipoElastic/';


                                                                                  mQuery:=GetDocQuery(self,'I7N1000101','3010000101','','7131000101','5O10000101')  ;


                                                                              mString:= CallRestApi(self,'POST',mtarget,mApiTable,'',mQuery);  // odeslání OV
                                                                                                 mstring:=                      inputbox('PR','POST',mtarget+mApiTable+'' + '       ' + mQuery)    ;
                                                                            //nxshowsimplemessage(mstring,nil);


                                                  end;
                                      end;


     nxshowsimplemessage('Import dokončen' ,nil);

end;

procedure FormCreate_Hook(Self: TSiteForm);
var
  mAction: TAction;
  mMAction: TMultiAction;
begin
  mMAction := Self.GetNewMultiAction;
  mMAction.ShowControl := True;
  mMAction.ShowMenuItem := True;
  mMAction.Caption := 'Synchronizace';
  mMAction.Hint := 'Synchronizace test';
  mMAction.Category := 'tabList';
  mMAction.Items.Add('Lipoelastik CZ ');
  mMAction.OnExecuteItem := @Synchronizace;

end;

begin
end.





