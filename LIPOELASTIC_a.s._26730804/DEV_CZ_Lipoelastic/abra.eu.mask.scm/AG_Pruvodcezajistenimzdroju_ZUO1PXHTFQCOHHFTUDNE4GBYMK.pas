uses  '_Knihovny_ALL.Progress',
      '_Knihovny_ALL.Parse';

var
    result:boolean;
    mresult:boolean;
    mBookmark : TBookmarkList;
    mBustrasaction_ID:string;




function iSelectDocqueue(AOLE: Variant;mparam:string;) : TNxOID;
var
  mRoll : variant;
  mXX : string;
begin
  Result := '';
  mXX := '0000000000';
  mRoll := AOLE.GetRoll('W2XNBCJK3ZD13ACL03KIU0CLP4', 0);
  mRoll.Params.Add(mparam);
  Result := mRoll.SelectDialog2(False, mXX);
end;



function iSelectReport(mProgPoint:string) : TNxOID;
var
  mOLE, mRoll, mOResult: Variant;
begin
            mOLE:= GetAbraOLEApplication;
              mOResult:= mOLE.CreateStrings;
                  mRoll:=mOLE.GetRoll('4CQONRMN0ND13BYP02K2DBYMG4', 0);
                  mRoll.Params.Add('_PROGPOINT=' + mProgPoint);
                  mRoll.multiSelectDialog(False,mOResult) ;
                      result:=mOResult.text ;
end;














function GetFileNameBOLog(mBO:TNxCustomBusinessObject;aname:string):string;
var s:string;
begin
        s:=aname;
        s:=NxRemoveDiacritics(s);
                while pos('.',s)>0 do delete(s,pos('.',s),1);
                while pos('/',s)>0 do delete(s,pos('/',s),1);
                while pos('-',s)>0 do delete(s,pos('-',s),1);
                while pos(':',s)>0 do delete(s,pos(':',s),1);
                while pos(',',s)>0 do delete(s,pos(',',s),1);
                while pos(' ',s)>0 do delete(s,pos(' ',s),1);
                while pos('"',s)>0 do delete(s,pos('"',s),1);
                result:=s+'.pdf';
end;

function iPrintDocument(Obj:TNxCustomBusinessObject;ADynCLSID:string;ReportID:string;Acontext:TNxContext;mprintlist:TStrings;AName:string;Adir:string):string;
var
        mOLEApp: Variant;
        mCommand: Variant;
        mCond: Variant;
        FName:string;
        mbo: TNxCustomBusinessObject;
        mDynCLSID:string;
        mr:tstringlist;
begin
        if  NxIsBlank(trim(ADynCLSID)) then begin
            mr:=tstringlist.create;
            try
                 obj.ObjectSpace.SQLSelect('select DataSource from Reports where id=' + quotedstr(ReportID),mr);
                 if mr.count>0 then mDynCLSID := mr.Strings[0] ;
            finally
                mr.free;
            end;

       end else begin
            mDynCLSID:=ADynCLSID;
        end;

       { try
                mOLEApp := GetAbraOLEApplication;
                        mCommand := mOLEApp.CreateCustomCommand(mDynCLSID);  // ZL
                        mCond := mCommand.ConstraintByID('ID');
                        mCond.UsedKind := 1;
                        mCond.Value := QuotedStr(Obj.OID);
                mCommand.Execute;
        finally
        end;
        if not (mCommand.RowSets[0].EOF) then
                begin
                        FName:=GetFileNameBOLog(Obj,aname);
                        mCommand.Print(ReportID,8,adir,FName);

                end; }
                NxPrintByIDs(Acontext, mPrintList, mDynCLSID, ReportID, rtofile, pekpdf, adir, FName) ;
                result:=adir+FName;
end;

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
  mid_report:string;
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

  mid_report:=iSelectReport('44V53DORW3DL342X01C0CX3FCC') ;

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

                                            mid:=iPrintDocument(TDynSiteForm(mSite).CurrentObject,'',mid_report,NxCreateContext(msite.BaseObjectSpace),mStringlist,mfilename,'c:\A');
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
                                            mfilename:=Format('%s_%s_%s_', [TDynSiteForm(mSite).CurrentObject.GetFieldValueAsString('Docqueue_id.code'),
                                                     inttostr(TDynSiteForm(mSite).CurrentObject.GetFieldValueAsInteger('Ordnumber')),
                                                     TDynSiteForm(mSite).CurrentObject.GetFieldValueAsString('Period_id.code'),
                                                     ]);


                                            mid:=iPrintDocument(TDynSiteForm(mSite).CurrentObject,'',mid_report,NxCreateContext(msite.BaseObjectSpace),mStringlist,mfilename,'c:\A');
                                       finally
                                          mStringlist.free;
                                       end;
                   end;
                   ProgressDispose()   ;
              end;


             NxShowSimpleMessage('Bylo vytvořeno  ' + inttostr(mBookmark.Count) + ' doklad(ů)' ,nil) ;


          end;
end;




procedure mSourceToTarget(Sender: TAction; Index: integer);
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
  mDocQueue_ID:string;
  mmesage:string;
  mParam:string;
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

//    mDocQueue_ID:='';
//    mDocQueue_ID := iSelectDocqueue(mSite.GetAbraOLEApplication,mParam);
//    if mDocQueue_ID<>'' then begin
//              mr:=TStringList.create;
//              try
//                       msite.BaseObjectSpace.SQLSelect('select code from DocQueues where id=' + QuotedStr(mDocQueue_ID),mr);
//                       if mr.count>0 then mmesage:=mr.Strings[0] + '-';
//
//              finally
//                 mr.free;
//              end;
              if mBookmark.count=0 then begin
                         //mIportmanager(TDynSiteForm(mSite).CurrentObject,mDocQueue_ID);
                        // mmesage:=mmesage + ', ' + mIportmanager(TDynSiteForm(mSite),TDynSiteForm(mSite).CurrentObject,mDocQueue_ID,index);
              end else begin
                   ProgressInit(msite, 'Zpracování souboru ' + '', 100);
                   for i := 0 to mBookmark.Count- 1 do begin
                                    ProgressSetPos(1+NxFloor(i/mBookmark.Count*99), inttostr(i) +' z '+inttostr(mBookmark.Count));
                                    mDBGrid.DataSource.DataSet.GotoBookmark(mBookMark.items(i));


                   end;
                   ProgressDispose()   ;
              end;


             NxShowSimpleMessage('Byl vytvořen doklad(y)' + mmesage + '/' + TDynSiteForm(mSite).CurrentObject.GetFieldValueAsString('Period_id.Code')
                            ,nil) ;


//          end;
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
  mMAction.Items.Add('Export');

  mmAction.OnExecuteItem:= @mPrintToAll;



end;

begin
end.