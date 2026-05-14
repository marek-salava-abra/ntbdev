uses 'abra.eu.mask.AutoArchiv.Folder.lib';

const
mid_report='1CB0000101';
mclsid='40SBPEINEFD13ACM03KIU0CLP4';
mtype='03';

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
begin
        mSite := NxFindSiteForm(Sender);
        mTabList := TTabSheet(NxFindChildControl(mSite.MainPanel, 'tabList'));
        if mTabList = nil then RaiseException('tabList nenalezen');
        mDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdList'));
        if mDBGrid = nil then RaiseException('DBGrid nenalezen');

        muser:=msite.BaseObjectSpace.CreateObject('22AHIVDVAVE13C5S00CA141B44');
        try
           muser.load(mSite.SiteContext.GetCompanyCache.GetUserID,nil);
           if muser.GetFieldValueAsBoolean('X_archiv') then begin
              mzruseni:=true;
           end else begin
              mzruseni:=false;
           end;
        finally
          muser.free;
        end;
// if mSite.SiteContext.GetCompanyCache.GetUserID<>'SUPER00000' then begin
      if index=0 then begin
            mOLE:= GetAbraOLEApplication;
              mOResult:= mOLE.CreateStrings;
                  mRoll:=mOLE.GetRoll('4CQONRMN0ND13BYP02K2DBYMG4', 0);
                  mRoll.Params.Add('_PROGPOINT=MASKJM5IU3D13ACP03KIU0CLP4');
                  if not mRoll.multiSelectDialog(False,mOResult) then Exit;
                  //mStringlist:=tstringlist.create;
                  //try
                  //   mStringlist:=mOResult;
                     if mStringlist.count>0 then mid_report:=mOResult.text;
                  //finally
                  //    mStringlist.free;
                  //end;

       end;
//  end else begin

//  end;





        mBookmarkList := mDBGrid.SelectedRows; // *** v mBookmark jsou id označených záznamu

          if mBookmarkList.count=0 then begin
              mCustomBusinessObject:= TDynSiteForm(mSite).CurrentObject;
              if index=0 then begin
                    mresult:=Create_folder(mCustomBusinessObject);
                    //if mresult then begin
                        mStringlist:=TStringList.create;
                        mStringlist.Add(mCustomBusinessObject.oid);
                        try
                           adir:=Format('%s\%s\%s\%s', [constStoragePath,mtype, mCustomBusinessObject.GetFieldValueAsString('Period_id.code'),mCustomBusinessObject.GetFieldValueAsString('Docqueue_id.code')]);
                           mfilename:=Format('%s_%s_%s_%s', [inttostr(mCustomBusinessObject.GetFieldValueAsInteger('Ordnumber')),
                           mCustomBusinessObject.GetFieldValueAsString('Docqueue_id.code'),
                           mCustomBusinessObject.GetFieldValueAsString('Period_id.code'),
                           mCustomBusinessObject.GetFieldValueAsString('varsymbol')
                           ]);
                          //NxShowSimpleMessage(adir+'\'+mfilename+'.pdf',nil);
                          if FileExists(adir+'\'+mfilename+'.pdf') then begin    // subor již existuje

                          //NxShowSimpleMessage('Existuje',nil);
                                          if NxCopyFile(adir+'\'+mfilename+'.pdf',constStoragePath+'\historie\'+mfilename+'_'+(FormatDateTime('YYYY_MM_DD_HH_NN',now))) then begin
                                              //NxShowSimpleMessage(constStoragePath+'\historie\'+mfilename+'_'+(FormatDateTime('YYYY_MM_DD_HH',now)),nil);
                                              //NxShowSimpleMessage('zkopirovan',nil);
                                              if NxDeleteFiles(adir,mfilename+'.pdf') then begin

                                              //NxShowSimpleMessage('uvolněni',nil);
                                              end;
                                          end;
                                      end;
                          mid:=iPrintDocument(mCustomBusinessObject,mclsid,mid_report,NxCreateContext(msite.BaseObjectSpace),mStringlist,mfilename,adir);

                          //mCustomBusinessObject.SetFieldValueAsString('X_PrintReport_ID',aid);
                          //mCustomBusinessObject.SetFieldValueAsBoolean('X_Uzamceno',True);
                          //mCustomBusinessObject.save;
                          //mi:=mCustomBusinessObject.ObjectSpace.SQLExecute('update issuedinvoices set X_PrintReport_ID=' + quotedstr(mid_report) + ' where id='+ quotedstr(mCustomBusinessObject.oid));
                          mi:=mCustomBusinessObject.ObjectSpace.SQLExecute('update issuedinvoices set X_Uzamceno=' + quotedstr('A') + ' where id='+ quotedstr(mCustomBusinessObject.oid));
                        finally
                            mStringlist.free;
                        end;
              end;

        end else begin
             for i := 0 to mBookmarkList.Count-1 do begin // projdu vsechny oznacene zaznamy
                  mDBGrid.DataSource.DataSet.GotoBookmark(mBookmarkList.items(i));
                      mCustomBusinessObject:= TDynSiteForm(mSite).CurrentObject;
                      if index=0 then begin
                            mresult:=Create_folder(mCustomBusinessObject);
                                    mStringlist:=TStringList.create;
                                    mStringlist.Add(mCustomBusinessObject.oid);
                                    try
                                       adir:=Format('%s\%s\%s', [constStoragePath, mCustomBusinessObject.GetFieldValueAsString('Period_id.code'),mCustomBusinessObject.GetFieldValueAsString('Docqueue_id.code')]);
                                       mfilename:=Format('%s_%s_%s_%s', [inttostr(mCustomBusinessObject.GetFieldValueAsInteger('Ordnumber')),
                                       mCustomBusinessObject.GetFieldValueAsString('Docqueue_id.code'),
                                       mCustomBusinessObject.GetFieldValueAsString('Period_id.code'),
                                       mCustomBusinessObject.GetFieldValueAsString('varsymbol')
                                       ]);
                                       if FileExists(adir+'\'+mfilename) then begin    // subor již existuje
                                          if NxCopyFile(adir+'\'+mfilename,constStoragePath+'\historie\'+mfilename+(FormatDateTime('YYYY_MM_DD_HH',now))) then begin
                                              mresult:= NxDeleteFiles(adir+'\'+mfilename,constStoragePath+'\historie\'+mfilename) ;
                                          end;
                                      end;
                                      mid:=iPrintDocument(mCustomBusinessObject,'40SBPEINEFD13ACM03KIU0CLP4',mid_report,NxCreateContext(msite.BaseObjectSpace),mStringlist,mfilename,adir);
                                    finally
                                        mStringlist.free;
                                    end;
                          mi:=mCustomBusinessObject.ObjectSpace.SQLExecute('update issuedinvoices set X_PrintReport_ID=' + quotedstr(mid_report) + ' where id='+ quotedstr(mCustomBusinessObject.oid));
                          mi:=mCustomBusinessObject.ObjectSpace.SQLExecute('update issuedinvoices set X_Uzamceno=' + quotedstr('A') + ' where id='+ quotedstr(mCustomBusinessObject.oid));
                      end;

             end;
        end;
     try




        //                    mCustomBusinessObject.save;
        finally
        end;
        msite.Refresh;
        mDBGrid.Refresh;
        mDBGrid.DataSource.DataSet.Refresh;
end;



{
Vyvoláva sa po vykonaní inicializácie agendy/formulára. V tomto okamihu je už na formulári dostupný SiteContext.
}
procedure _CanEdit_Hook(Self: TDynSiteForm; var ACanEdit: Boolean);

begin
       if not nxisemptyoid(self.CurrentObject.GetFieldValueAsString('X_PrintReport_ID')) then begin
        ACanEdit := False;
        NxShowSimpleMessage('Doklad je již archivován',self);
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
            mUserFilter:= mUser.GetFieldValueAsBoolean('X_archiv');

    finally
      mUser.Free;
    end;
        if mUserFilter then begin
                  mMAction := Self.GetNewMultiAction;
          mMAction.ShowControl := True;
          mMAction.ShowMenuItem := True;
          mMAction.Hint := 'Archivace dokladu';
          mMAction.Caption := 'Archivace dokladu';
          mMAction.Items.Add('Archivace dokladu');
          mMAction.Items.Add('Zruš archivace');
          //mMAction.Items.Add('Doplň archivované soubory');
          mMAction.Category := 'tabList';
          mMAction.OnExecuteItem := @OnExec;
        end;
end;


begin
end.