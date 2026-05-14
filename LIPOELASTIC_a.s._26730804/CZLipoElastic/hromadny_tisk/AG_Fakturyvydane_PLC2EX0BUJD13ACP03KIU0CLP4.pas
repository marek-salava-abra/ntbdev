uses 'hromadny_tisk.lib';


Var
    mSite: TSiteForm;
    mDBGrid : TDBGrid;
    mTabList: TTabSheet;
    mCustomBusinessObject: TNxCustomBusinessObject;

    mHeaderBusinessObject : TNxHeaderBusinessObject;
    i : integer;
    mResult:Boolean;
    mBookmarkList:TBookmarkList ;
    aid:string;



procedure OnExec(Sender: TComponent;index:integer;);       // přidělení objectspace a zadání zdrojového souboru
var
    zadej:string;
    mfilename:string;
    mdir,mfile:string;
    mfilter:string;
    mresult:Boolean;
    mStringlist:TStringList;
    mid:string;
    adir:string;
    mid_report:string;
    mi:integer;
mOLE, mRoll, mOResult: Variant;
mUser:TNxCustomBusinessObject;
mpocet:string;
mzruseni:boolean;
mid_report1,mid_reportx:string;
begin
        mSite := NxFindSiteForm(Sender);
        mTabList := TTabSheet(NxFindChildControl(mSite.MainPanel, 'tabList'));
        if mTabList = nil then RaiseException('tabList nenalezen');
        mDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdList'));
        if mDBGrid = nil then RaiseException('DBGrid nenalezen');


              mzruseni:=true;

      {
            mOLE:= GetAbraOLEApplication;
              mOResult:= mOLE.CreateStrings;
                  mRoll:=mOLE.GetRoll('4CQONRMN0ND13BYP02K2DBYMG4', 0);
                  mRoll.Params.Add('_PROGPOINT=MASKJM5IU3D13ACP03KIU0CLP4');
                  mRoll.multiSelectDialog(False,mOResult) ;
                                                  }

     //                 mid_reportx:=mOResult.text ;

        mid_reportx:='3W07000101';
       adir:=Format('%s', ['\\CZVS0006\Slovensko\DL\']);




        mBookmarkList := mDBGrid.SelectedRows; // *** v mBookmark jsou id označených záznamu

          if mBookmarkList.count=0 then begin
              mCustomBusinessObject:= TDynSiteForm(mSite).CurrentObject;

                    //mresult:=Create_folder(mCustomBusinessObject);

                    //if mresult then begin
                        mStringlist:=TStringList.create;
                        mStringlist.Add(mCustomBusinessObject.oid);
                        try

                           mfilename:=Format('%s_%s_%s_%s', [inttostr(mCustomBusinessObject.GetFieldValueAsInteger('Ordnumber')),
                           mCustomBusinessObject.GetFieldValueAsString('Docqueue_id.code'),
                           mCustomBusinessObject.GetFieldValueAsString('Period_id.code'),
                           ''
                           ]);
                          mid:=iPrintDocument(mCustomBusinessObject,'40SBPEINEFD13ACM03KIU0CLP4',mid_reportx,NxCreateContext(msite.BaseObjectSpace),mStringlist,mfilename,adir);
             //               mid:=iexportDocument(mCustomBusinessObject,'40SBPEINEFD13ACM03KIU0CLP4',mid_reportx,NxCreateContext(msite.BaseObjectSpace),mStringlist,mfilename,adir);
                        finally
                            mStringlist.free;
                        end;


        end else begin
             for i := 0 to mBookmarkList.Count-1 do begin // projdu vsechny oznacene zaznamy
                  mDBGrid.DataSource.DataSet.GotoBookmark(mBookmarkList.items(i));
                      mCustomBusinessObject:= TDynSiteForm(mSite).CurrentObject;

                  mCustomBusinessObject:= TDynSiteForm(mSite).CurrentObject;

                    //mresult:=Create_folder(mCustomBusinessObject);
                    //if mresult then begin
                        mStringlist:=TStringList.create;
                        mStringlist.Add(mCustomBusinessObject.oid);
                        try

                           mfilename:=Format('%s_%s_%s_%s', [inttostr(mCustomBusinessObject.GetFieldValueAsInteger('Ordnumber')),
                           mCustomBusinessObject.GetFieldValueAsString('Docqueue_id.code'),
                           mCustomBusinessObject.GetFieldValueAsString('Period_id.code'),
                           ''
                           ]);

                          mid:=iPrintDocument(mCustomBusinessObject,'40SBPEINEFD13ACM03KIU0CLP4',mid_reportx,NxCreateContext(msite.BaseObjectSpace),mStringlist,mfilename,adir);
                         // mid:=iexportDocument(mCustomBusinessObject,'40SBPEINEFD13ACM03KIU0CLP4',mid_reportx,NxCreateContext(msite.BaseObjectSpace),mStringlist,mfilename,adir);
                        finally
                            mStringlist.free;
                        end;

              end;

        end;

        msite.Refresh;
        mDBGrid.Refresh;
        mDBGrid.DataSource.DataSet.Refresh;
end;






procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TBasicAction;
  mMAction: TMultiAction;
  mCAction: TBasicAction;
  mAList: TActionList;
  i : integer;
  mUserFilter:Boolean;
  mUserFilterTL:string;
  muser:TNxCustomBusinessObject;
begin
          if false then begin
              mMAction := Self.GetNewMultiAction;
              mMAction.ShowControl := True;
              mMAction.ShowMenuItem := True;
              mMAction.Hint := 'Hromadny tisk ';
              mMAction.Caption := 'Hromadny tisk';
              mMAction.Items.Add('Hromadny tisk');
              mMAction.Category := 'tabList';
              mMAction.OnExecuteItem := @OnExec;
          end;

end;


begin
end.