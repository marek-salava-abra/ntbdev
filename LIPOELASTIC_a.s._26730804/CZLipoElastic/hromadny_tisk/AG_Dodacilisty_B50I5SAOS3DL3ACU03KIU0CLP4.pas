uses 'hromadny_tisk.lib',
     '_Knihovny_ALL.Progress',
     '_Knihovny_ALL.Parse',
     '_GlobalSettings.Konstanty';


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
    mStringlist,mFileList:TStringList;
    mid:string;
    adir:string;
    mid_report:string;
    mi:integer;
mOLE, mRoll, mOResult: Variant;
mUser:TNxCustomBusinessObject;
mpocet:string;
mzruseni:boolean;
mid_report1,mid_reportx:string;
mBoolean:boolean;
begin
        mSite := NxFindSiteForm(Sender);
        mTabList := TTabSheet(NxFindChildControl(mSite.MainPanel, 'tabList'));
        if mTabList = nil then RaiseException('tabList nenalezen');
        mDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdList'));
        if mDBGrid = nil then RaiseException('DBGrid nenalezen');


              mzruseni:=true;


      if index=0 then begin
          mid_reportx:='ATR0000101';
          adir:=Format('%s', ['\\CZVS0006\Slovensko\DL\Hromadne\ABRAGx_B2B_']);

           mFileList:=TStringList.create;
           try

                NxGetFileList('\\CZVS0006\Slovensko\DL\Hromadne\',mfilelist,'*.xml',true);
                if mfilelist.count>0 then begin

                      mBoolean:=InputQuery('Upozornění' , 'V úložišti je již ..... dokladů.', IntToStr(mfilelist.count) ,nil);
                      //if mfilelist.count<>mpocet then begin
                          PromptForFileName(mFileName, mfilter, '', 'Vymaž soubory z umístění', '\\CZVS0006\Slovensko\DL\Hromadne\', False);
                      //end;
                end;
           finally
                mFileList.free;
           end;



      end;

      if index=1 then begin

            mOLE:= GetAbraOLEApplication;
              mOResult:= mOLE.CreateStrings;
                  mRoll:=mOLE.GetRoll('4CQONRMN0ND13BYP02K2DBYMG4', 0);
                  mRoll.Params.Add('_PROGPOINT=42YXBPUMSZDL3FUD00C5OG4NF4');
                  mRoll.multiSelectDialog(False,mOResult) ;


                      mid_reportx:=mOResult.text ;
          adir:=Format('%s', ['\\CZVS0006\Slovensko\DL\Hromadne\']);
      end;

        mBookmarkList := mDBGrid.SelectedRows; // *** v mBookmark jsou id označených záznamu

          if mBookmarkList.count=0 then begin
              mCustomBusinessObject:= TDynSiteForm(mSite).CurrentObject;

                if not (trim(mCustomBusinessObject.GetFieldValueAsString('Firm_ID.X_API_Adress'))='') then begin
                       adir:=Format('%s', ['\\CZVS0006\Slovensko\DL\Hromadne\']);

                      //adir:=mExportDir + trim(copy(mCustomBusinessObject.GetFieldValueAsString('Firm_ID.X_API_Adress'),20,50)+'\Hromadne\');
                            if mCustomBusinessObject.GetFieldValueAsString('Docqueue_ID.Code')='DMA' then adir:=adir + 'DMA\';
                            if mCustomBusinessObject.GetFieldValueAsString('Docqueue_ID.Code')='DPPO' then adir:=adir + 'DPPO\';
                end else begin
                      adir:=Format('%s', ['\\CZVS0006\Slovensko\DL\Hromadne\']);
                end;


                    //mresult:=Create_folder(mCustomBusinessObject);

                    //if mresult then begin
                        mStringlist:=TStringList.create;
                        mStringlist.Add(mCustomBusinessObject.oid);
                        try

                           if index=0 then begin
                               mfilename:=Format('%s-%s-%s%s', [mCustomBusinessObject.GetFieldValueAsString('Docqueue_id.code'),inttostr(mCustomBusinessObject.GetFieldValueAsInteger('Ordnumber')),
                               mCustomBusinessObject.GetFieldValueAsString('Period_id.code'),'.xml'
                               ]);
                               mid:=iExportDocument(mCustomBusinessObject,'05DOXDMCSZDL3FUD00C5OG4NF4',mid_reportx,NxCreateContext(msite.BaseObjectSpace),mStringlist,mfilename,adir);
                           end;

                           if index=1 then begin
                               mfilename:=Format('%s-%s-%s%s', [mCustomBusinessObject.GetFieldValueAsString('Docqueue_id.code'),inttostr(mCustomBusinessObject.GetFieldValueAsInteger('Ordnumber')),
                               mCustomBusinessObject.GetFieldValueAsString('Period_id.code'),''
                               ]);
                               mid:=iPrintDocument(mCustomBusinessObject,'05DOXDMCSZDL3FUD00C5OG4NF4',mid_reportx,NxCreateContext(msite.BaseObjectSpace),mStringlist,mfilename,adir);
                           end;
                        finally
                            mStringlist.free;
                        end;


        end else begin
             ProgressInit(msite, 'Zpracování souboru ' + '', 100);
             for i := 0 to mBookmarkList.Count-1 do begin // projdu vsechny oznacene zaznamy
                   ProgressSetPos(1+NxFloor(i/mBookmarkList.Count*99), inttostr(i) +' z '+inttostr(mBookmarkList.Count));
                  mDBGrid.DataSource.DataSet.GotoBookmark(mBookmarkList.items(i));
                      mCustomBusinessObject:= TDynSiteForm(mSite).CurrentObject;

                  mCustomBusinessObject:= TDynSiteForm(mSite).CurrentObject;

                    //mresult:=Create_folder(mCustomBusinessObject);
                    //if mresult then begin
                        mStringlist:=TStringList.create;
                        mStringlist.Add(mCustomBusinessObject.oid);
                        try
                            if not (trim(mCustomBusinessObject.GetFieldValueAsString('Firm_ID.X_API_Adress'))='') then begin
                                  adir:=Format('%s', ['\\CZVS0006\Slovensko\DL\Hromadne\']);
                                  //adir:=mExportDir + trim(copy(mCustomBusinessObject.GetFieldValueAsString('Firm_ID.X_API_Adress'),20,50)+'\Hromadne\');
                                        if mCustomBusinessObject.GetFieldValueAsString('Docqueue_ID.Code')='DMA' then adir:=adir + 'DMA\';
                                        if mCustomBusinessObject.GetFieldValueAsString('Docqueue_ID.Code')='DPPO' then adir:=adir + 'DPPO\';
                            end else begin
                                  adir:=Format('%s', ['\\CZVS0006\Slovensko\DL\Hromadne\']);
                            end;

                           if index=0 then begin
                               mfilename:=Format('%s-%s-%s%s', [mCustomBusinessObject.GetFieldValueAsString('Docqueue_id.code'),inttostr(mCustomBusinessObject.GetFieldValueAsInteger('Ordnumber')),
                               mCustomBusinessObject.GetFieldValueAsString('Period_id.code'),'.xml'
                               ]);
                               NxShowSimpleMessage(adir + mfilename,nil);

                               mid:=iExportDocument(mCustomBusinessObject,'05DOXDMCSZDL3FUD00C5OG4NF4',mid_reportx,NxCreateContext(msite.BaseObjectSpace),mStringlist,mfilename,adir);
                           end;

                           if index=1 then begin
                               mfilename:=Format('%s-%s-%s%s', [mCustomBusinessObject.GetFieldValueAsString('Docqueue_id.code'),inttostr(mCustomBusinessObject.GetFieldValueAsInteger('Ordnumber')),
                               mCustomBusinessObject.GetFieldValueAsString('Period_id.code'),''
                               ]);
                               mid:=iPrintDocument(mCustomBusinessObject,'05DOXDMCSZDL3FUD00C5OG4NF4',mid_reportx,NxCreateContext(msite.BaseObjectSpace),mStringlist,mfilename,adir);
                           end;
                        finally
                            mStringlist.free;
                        end;

              end;
              ProgressDispose()   ;
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
          mMAction := Self.GetNewMultiAction;
          mMAction.ShowControl := True;
          mMAction.ShowMenuItem := True;
          mMAction.Hint := 'Hromadny Export/tisk 1:1 ';
          mMAction.Caption := 'Hromadny Export/tisk 1:1';
          mMAction.Items.Add('Hromadny Export 1:1');
          //mMAction.Items.Add('Hromadny tisk 1:1');
          mMAction.Category := 'tabList';
          mMAction.OnExecuteItem := @OnExec;

end;


begin
end.