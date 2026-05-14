uses 'abra.eu.mask.Spedos_Digi_Archiv.lib';




Var
    mSite: TDynSiteForm;
    mDBGrid : TDBGrid;
    mTabList: TTabSheet;

    mHeaderBusinessObject : TNxHeaderBusinessObject;
    i : integer;
    mResult:Boolean;
    mBookmarkList:TBookmarkList ;
    aid:string;




procedure _DeleteObject_PostHook(Self: TDynSiteForm; AObject: TNxCustomBusinessObject);
Var
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

mALLstringlist:TStringList;
begin
        //mSite := TDynSiteForm(NxFindSiteForm(Sender));


                          mStringlist:=TStringList.create;
                          mStringlist.Add(AObject.oid);
                          try
                                   adir:=Format('%s\%s\%s', [constStoragePath, AObject.GetFieldValueAsString('Period_id.code'),AObject.GetFieldValueAsString('Docqueue_id.code')]);
                                   mfilename:=Format('%s_%s_%s_%s', [inttostr(AObject.GetFieldValueAsInteger('Ordnumber')),AObject.GetFieldValueAsString('Docqueue_id.code'),AObject.GetFieldValueAsString('Period_id.code'),AObject.GetFieldValueAsString('varsymbol')]);
                                  if FileExists(adir+'\'+mfilename+'.pdf') then begin    // subor již existuje
                                                            if NxDeleteFiles(adir,mfilename+'.pdf') then begin
                                                            end;

                                   end;
                           finally
                              mStringlist.free;
                          end;




end;

procedure OnExec(Sender: TComponent;index:integer);       // přidělení objectspace a zadání zdrojového souboru
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
mALLstringlist:TStringList;
begin

        mSite := TDynSiteForm(NxFindSiteForm(Sender));
        mTabList := TTabSheet(NxFindChildControl(mSite.MainPanel, 'tabList'));
        if mTabList = nil then RaiseException('tabList nenalezen');
        mDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdList'));
        if mDBGrid = nil then RaiseException('DBGrid nenalezen');

        muser:=msite.BaseObjectSpace.CreateObject('22AHIVDVAVE13C5S00CA141B44');
        try
           muser.load(mSite.SiteContext.GetCompanyCache.GetUserID,nil);
          // if muser.GetFieldValueAsBoolean('X_archiv') then begin
          //    mzruseni:=true;
          // end else begin
          //    mzruseni:=false;
          // end;
        finally
          muser.free;
        end;
   mid_report:='';
   if (index=0) then mid_report:=mreport1 ;
   if (index=1) then mid_report:=mreport2 ;

if (index=2) or (index=3)then begin
            mOLE:= GetAbraOLEApplication;
              mOResult:= mOLE.CreateStrings;
                  mRoll:=mOLE.GetRoll('4CQONRMN0ND13BYP02K2DBYMG4', 0);
                  mRoll.Params.Add('_PROGPOINT=MASKJM5IU3D13ACP03KIU0CLP4');
                  if not mRoll.multiSelectDialog(False,mOResult) then Exit;
                  mStringlist:=tstringlist.create;
                  mStringlist.text:=mOResult.text;
                  mid_report:=mStringlist.Strings[0] ;
       end;


 mALLstringlist:=tstringlist.create;
 try

        mBookmarkList := mDBGrid.SelectedRows; // *** v mBookmark jsou id označených záznamu

          if mBookmarkList.count=0 then begin
              mresult:=true;

              if index=3 then begin
                  mresult:=false;
                        if DirectoryExists(Format('%s', [constStoragePath]))  then begin   // uloziste je pristupne
                                mResult:=DirectoryExists(Format('%s\%s', [constStoragePath, TDynSiteForm(mSite).CurrentObject.GetFieldValueAsString('Period_id.code')]));
                                if  not mresult then begin    // období
                                        mResult:=NxCreateDir(Format('%s\%s', [constStoragePath, TDynSiteForm(mSite).CurrentObject.GetFieldValueAsString('Period_id.code')]));
                                end;
                                mResult:=DirectoryExists(Format('%s\%s\%s', [constStoragePath, TDynSiteForm(mSite).CurrentObject.GetFieldValueAsString('Period_id.code'),TDynSiteForm(mSite).CurrentObject.GetFieldValueAsString('Docqueue_id.code')]));
                                if not mresult then begin    // řada
                                        mResult:=NxCreateDir(Format('%s\%s\%s', [constStoragePath, TDynSiteForm(mSite).CurrentObject.GetFieldValueAsString('Period_id.code'),TDynSiteForm(mSite).CurrentObject.GetFieldValueAsString('Docqueue_id.code')]));
                                end;
                                mResult:=DirectoryExists(Format('%s\%s\%s\%s', [constStoragePath, TDynSiteForm(mSite).CurrentObject.GetFieldValueAsString('Period_id.code'),TDynSiteForm(mSite).CurrentObject.GetFieldValueAsString('Docqueue_id.code'),'historie']));
                                if not mresult then begin    // řada
                                        mResult:=NxCreateDir(Format('%s\%s\%s\%s', [constStoragePath, TDynSiteForm(mSite).CurrentObject.GetFieldValueAsString('Period_id.code'),TDynSiteForm(mSite).CurrentObject.GetFieldValueAsString('Docqueue_id.code'),'historie']));
                                end;
                       end;



                      if (mresult) and (index=3)  then begin
                          mStringlist:=TStringList.create;
                          mStringlist.Add(TDynSiteForm(mSite).CurrentObject.oid);
                          mALLstringlist.add(TDynSiteForm(mSite).CurrentObject.oid);
                          try
                                   adir:=Format('%s\%s\%s', [constStoragePath, TDynSiteForm(mSite).CurrentObject.GetFieldValueAsString('Period_id.code'),TDynSiteForm(mSite).CurrentObject.GetFieldValueAsString('Docqueue_id.code')]);
                                   mfilename:=Format('%s_%s_%s_%s', [inttostr(TDynSiteForm(mSite).CurrentObject.GetFieldValueAsInteger('Ordnumber')),TDynSiteForm(mSite).CurrentObject.GetFieldValueAsString('Docqueue_id.code'),TDynSiteForm(mSite).CurrentObject.GetFieldValueAsString('Period_id.code'),TDynSiteForm(mSite).CurrentObject.GetFieldValueAsString('varsymbol')]);
                                  if FileExists(adir+'\'+mfilename+'.pdf') then begin    // subor již existuje
                                                  NxShowSimpleMessage('Doklad již byl dříve archivován, archivace proběhne znovu',nil);
                                                  mResult:=DirectoryExists(Format('%s\%s\%s\%s', [constStoragePath, TDynSiteForm(mSite).CurrentObject.GetFieldValueAsString('Period_id.code'),TDynSiteForm(mSite).CurrentObject.GetFieldValueAsString('Docqueue_id.code'),'historie']));
                                                        if not mresult then begin    // řada
                                                                mResult:=NxCreateDir(Format('%s\%s\%s\%s', [constStoragePath, TDynSiteForm(mSite).CurrentObject.GetFieldValueAsString('Period_id.code'),TDynSiteForm(mSite).CurrentObject.GetFieldValueAsString('Docqueue_id.code'),'historie']));
                                                        end;


                                                        if NxCopyFile(adir+'\'+mfilename+'.pdf',adir+'\historie\'+mfilename+'_'+(FormatDateTime('YYYY_MM_DD_HH_NN',now))) then begin
                                                            if NxDeleteFiles(adir,mfilename+'.pdf') then begin
                                                            end;
                                                        end;
                                   end;
                                  mid:=iPrintDocument(TDynSiteForm(mSite).CurrentObject,mACLSID,mid_report,NxCreateContext(msite.BaseObjectSpace),mStringlist,mfilename,adir);
                                 // mi:=TDynSiteForm(mSite).CurrentObject.ObjectSpace.SQLExecute('update issuedinvoices set X_Print_ID=' + quotedstr(mid_report) + ' where id='+ quotedstr(TDynSiteForm(mSite).CurrentObject.oid));
                           finally
                              mStringlist.free;
                          end;
                       end;



                 TDynSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_Print_id',mid_report);
                 TDynSiteForm(mSite).CurrentObject.save;
                 //TDynSiteForm(mSite).CurrentObject.Refresh;

                end;



           if index<3 THEN MI:=msite.BaseObjectSpace.SQLExecute('Update issuedinvoices set X_Print_ID=' + quotedstr(mid_report) + ' where id=' + QuotedStr(TDynSiteForm(mSite).CurrentObject.oid));




        end else begin
             for i := 0 to mBookmarkList.Count-1 do begin // projdu vsechny oznacene zaznamy
                  mDBGrid.DataSource.DataSet.GotoBookmark(mBookmarkList.items(i));
                      mresult:=true;

                                  if index=3 then begin
                                      mresult:=false;
                                            if DirectoryExists(Format('%s', [constStoragePath]))  then begin   // uloziste je pristupne
                                                    mResult:=DirectoryExists(Format('%s\%s', [constStoragePath, TDynSiteForm(mSite).CurrentObject.GetFieldValueAsString('Period_id.code')]));
                                                    if  not mresult then begin    // období
                                                            mResult:=NxCreateDir(Format('%s\%s', [constStoragePath, TDynSiteForm(mSite).CurrentObject.GetFieldValueAsString('Period_id.code')]));
                                                    end;
                                                    mResult:=DirectoryExists(Format('%s\%s\%s', [constStoragePath, TDynSiteForm(mSite).CurrentObject.GetFieldValueAsString('Period_id.code'),TDynSiteForm(mSite).CurrentObject.GetFieldValueAsString('Docqueue_id.code')]));
                                                    if not mresult then begin    // řada
                                                            mResult:=NxCreateDir(Format('%s\%s\%s', [constStoragePath, TDynSiteForm(mSite).CurrentObject.GetFieldValueAsString('Period_id.code'),TDynSiteForm(mSite).CurrentObject.GetFieldValueAsString('Docqueue_id.code')]));
                                                    end;
                                                    mResult:=DirectoryExists(Format('%s\%s\%s\%s', [constStoragePath, TDynSiteForm(mSite).CurrentObject.GetFieldValueAsString('Period_id.code'),TDynSiteForm(mSite).CurrentObject.GetFieldValueAsString('Docqueue_id.code'),'historie']));
                                                    if not mresult then begin    // řada
                                                            mResult:=NxCreateDir(Format('%s\%s\%s\%s', [constStoragePath, TDynSiteForm(mSite).CurrentObject.GetFieldValueAsString('Period_id.code'),TDynSiteForm(mSite).CurrentObject.GetFieldValueAsString('Docqueue_id.code'),'historie']));
                                                    end;
                                           end;



                                          if (mresult) and (index=3)  then begin
                                              mStringlist:=TStringList.create;
                                              mStringlist.Add(TDynSiteForm(mSite).CurrentObject.oid);
                                              mALLstringlist.add(TDynSiteForm(mSite).CurrentObject.oid);
                                              try
                                                       adir:=Format('%s\%s\%s', [constStoragePath, TDynSiteForm(mSite).CurrentObject.GetFieldValueAsString('Period_id.code'),TDynSiteForm(mSite).CurrentObject.GetFieldValueAsString('Docqueue_id.code')]);
                                                       mfilename:=Format('%s_%s_%s_%s', [inttostr(TDynSiteForm(mSite).CurrentObject.GetFieldValueAsInteger('Ordnumber')),TDynSiteForm(mSite).CurrentObject.GetFieldValueAsString('Docqueue_id.code'),TDynSiteForm(mSite).CurrentObject.GetFieldValueAsString('Period_id.code'),TDynSiteForm(mSite).CurrentObject.GetFieldValueAsString('varsymbol')]);
                                                      if FileExists(adir+'\'+mfilename+'.pdf') then begin    // subor již existuje
                                                                      NxShowSimpleMessage('Doklad již byl dříve archivován, archivace proběhne znovu',nil);
                                                                      mResult:=DirectoryExists(Format('%s\%s\%s\%s', [constStoragePath, TDynSiteForm(mSite).CurrentObject.GetFieldValueAsString('Period_id.code'),TDynSiteForm(mSite).CurrentObject.GetFieldValueAsString('Docqueue_id.code'),'historie']));
                                                                            if not mresult then begin    // řada
                                                                                    mResult:=NxCreateDir(Format('%s\%s\%s\%s', [constStoragePath, TDynSiteForm(mSite).CurrentObject.GetFieldValueAsString('Period_id.code'),TDynSiteForm(mSite).CurrentObject.GetFieldValueAsString('Docqueue_id.code'),'historie']));
                                                                            end;


                                                                            if NxCopyFile(adir+'\'+mfilename+'.pdf',adir+'\historie\'+mfilename+'_'+(FormatDateTime('YYYY_MM_DD_HH_NN',now))) then begin
                                                                                if NxDeleteFiles(adir,mfilename+'.pdf') then begin
                                                                                end;
                                                                            end;
                                                       end;
                                                      mid:=iPrintDocument(TDynSiteForm(mSite).CurrentObject,mACLSID,mid_report,NxCreateContext(msite.BaseObjectSpace),mStringlist,mfilename,adir);
                                                     // mi:=TDynSiteForm(mSite).CurrentObject.ObjectSpace.SQLExecute('update issuedinvoices set X_Print_ID=' + quotedstr(mid_report) + ' where id='+ quotedstr(TDynSiteForm(mSite).CurrentObject.oid));
                                               finally
                                                  mStringlist.free;
                                              end;
                                           end;



                                     TDynSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_Print_id',mid_report);
                                     TDynSiteForm(mSite).CurrentObject.save;
                                     //TDynSiteForm(mSite).CurrentObject.Refresh;

                                    end;
                                    if index<3 THEN MI:=msite.BaseObjectSpace.SQLExecute('Update issuedinvoices set X_Print_ID=' + quotedstr(mid_report) + ' where id=' + QuotedStr(TDynSiteForm(mSite).CurrentObject.oid));


             end;


        end;

        //mdbgrid.Refresh;
                                    //msite.RefreshData;
                                    //msite.ActiveDataSet.seekid(mid);

     msite.ActiveDataSet.RefreshAndRestoreLastSelectedItem;
  finally
      mALLstringlist.free;
  end;

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
    mUserFilter:=true;
    mUser := Self.BaseObjectSpace.CreateObject('22AHIVDVAVE13C5S00CA141B44');
    try
      mUser.Load(Self.CompanyCache.GetUserID, nil);
            mUserFilter:= true; //mUser.GetFieldValueAsBoolean('X_archiv');


        if muser.GetFieldValueAsBoolean('X_Archiv') then begin
          mMAction := Self.GetNewMultiAction;
          mMAction.ShowControl := True;
          mMAction.ShowMenuItem := True;
          mMAction.Hint := 'Archivuj soubory';
          mMAction.Caption := 'Archivuj soubory';
          mMAction.Items.Add('Automat Plna');
           mMAction.Items.Add('Automat light');
          mMAction.Items.Add('Automat - výběrem');
          mMAction.Items.Add('Plná archivace výběrem');
          //if muser.GetFieldValueAsBoolean('X_Change_archiv') then mMAction.Items.Add('Zruš blokaci archívu');
          mMAction.Category := 'tabList';
          mMAction.OnExecuteItem := @OnExec;
        end;

     finally
      mUser.Free;
     end;
end;




begin
end.