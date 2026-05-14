uses  '_Knihovny_ALL.Progress',
      '_Knihovny_ALL.Parse',
      'abra.eu.mask.Vicenasobne_importy1to1.lib';

const
     mid_report='3100000001' ;
     mSuffixDir='/FP'   ;

var
    result:boolean;
    mresult:boolean;
    mBookmark : TBookmarkList;
    mBustrasaction_ID:string;



procedure mPrintToAll(Sender: TAction; Index: integer);
var
 mresult:Boolean;
 mtext:string;
 mbo:TNxCustomBusinessObject;
 mSite: TSiteForm;
 mDBGrid : TDBGrid;
 mTabList: TTabSheet;
 self:TNxCustomBusinessObject;
 i,ii:integer;
  mr,mIDs_MLRow:TStringList;
   mForm: TDynSiteForm;
   mMon: TNxCustomBusinessMonikerCollection;
   mRow, mNewRow,mbo1: TNxCustomBusinessObject;
   mdate:Double;
   mdoc_number:string;
   mcount:integer;
   mfile:string;
   mpath:string;
   mBtn : TButton;
  mLbl : TLabel;
  cbStores : TComboBox;
  mRg : TRadioGroup;
  mRbS, mRbA : TRadioButton;
  mActualRow : TBookmark;
  mReport_ID:string;
  mmesage:string;
  mParam:string;
  mOLE, mRoll, mOResult: Variant;
  mStringlist:tstringlist;
  mid:string;
  mfilename:string;
begin
  mparam:='';

  mSite := NxFindSiteForm(Sender);
    mTabList := TTabSheet(NxFindChildControl(mSite.MainPanel, 'tabList'));
    if mTabList = nil then
        RaiseException('tabList nenalezen');
    mDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdList'));
    if mDBGrid = nil then
        RaiseException('DBGrid nenalezen');



    mBookmark := mDBGrid.SelectedRows; // *** v mBookmark jsou id označených záznamu

    if mid_report<>'' then begin

              if mBookmark.count=0 then begin
                         //mIportmanager(TDynSiteForm(mSite).CurrentObject,mDocQueue_ID);
                          mStringlist:=TStringList.create;
                                       try
                                            mStringlist.Add(TDynSiteForm(mSite).CurrentObject.oid);
                                            mfilename:=Format('%s_%s_%s_', [TDynSiteForm(mSite).CurrentObject.GetFieldValueAsString('Docqueue_id.code'),
                                                     inttostr(TDynSiteForm(mSite).CurrentObject.GetFieldValueAsInteger('Ordnumber')),
                                                     TDynSiteForm(mSite).CurrentObject.GetFieldValueAsString('Period_id.code'),
                                                     ]);

                                            mid:=iPrintDocument(TDynSiteForm(mSite).CurrentObject,'',mid_report,NxCreateContext(msite.BaseObjectSpace),mStringlist,mfilename,exportdir+mSuffixDir);
                                       finally
                                          mStringlist.free;
                                       end;
              end else begin
                   ProgressInit(msite, 'Zpracování souboru ' + '', 100);
                   for i := 0 to mBookmark.Count- 1 do begin
                                    ProgressSetPos(1+NxFloor(i/mBookmark.Count*99), inttostr(i) +' z '+inttostr(mBookmark.Count));
                                    mDBGrid.DataSource.DataSet.GotoBookmark(mBookMark.items(i));
                                    mStringlist:=TStringList.create;
                                       try
                                            mStringlist.Add(TDynSiteForm(mSite).CurrentObject.oid);
                                            mfilename:=Format('%s_%s_%s_%s', [TDynSiteForm(mSite).CurrentObject.GetFieldValueAsString('Docqueue_id.code'),
                                                     inttostr(TDynSiteForm(mSite).CurrentObject.GetFieldValueAsInteger('Ordnumber')),
                                                     TDynSiteForm(mSite).CurrentObject.GetFieldValueAsString('Period_id.code'),
                                                     TDynSiteForm(mSite).CurrentObject.GetFieldValueAsString('Varsymbol') ,

                                                     ]);


                                            mid:=iPrintDocument(TDynSiteForm(mSite).CurrentObject,'',mid_report,NxCreateContext(msite.BaseObjectSpace),mStringlist,mfilename,exportdir+mSuffixDir);
                                       finally
                                          mStringlist.free;
                                       end;
                   end;
                   ProgressDispose()   ;
              end;


             NxShowSimpleMessage('Bylo vytvořeno  ' + inttostr(mBookmark.Count) + ' doklad(ů)' ,nil) ;


          end;
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

  mmAction := Self.GetNewMultiAction;
  mmAction.ShowControl := True;
  mmAction.ShowMenuItem := True;
  mmAction.Caption := 'Vícenásobný Tisk/export dokladu';
  mmAction.Hint := 'Tisk/export po jednotlivém záznamu do více souborů';
  mmAction.Category := 'tabList';
  mMAction.Items.Add('Tisk');
  //mMAction.Items.Add('Export');

  mmAction.OnExecuteItem:= @mPrintToAll;



end;

begin
end.