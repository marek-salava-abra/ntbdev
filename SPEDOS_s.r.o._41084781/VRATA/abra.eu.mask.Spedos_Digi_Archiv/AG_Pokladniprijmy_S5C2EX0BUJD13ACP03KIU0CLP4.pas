uses 'abra.eu.mask.Spedos_Digi_Archiv.lib';




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

{
Vyvolává se po načtení vlastností formuláře.
}
procedure LoadingProperties_Hook(Self: TSiteForm; AParams: TNxParameters);
begin

end;

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
          // if muser.GetFieldValueAsBoolean('X_archiv') then begin
          //    mzruseni:=true;
          // end else begin
          //    mzruseni:=false;
          // end;
        finally
          muser.free;
        end;
      if (index=0) or (index=1) then begin
            mOLE:= GetAbraOLEApplication;
              mOResult:= mOLE.CreateStrings;
                  mRoll:=mOLE.GetRoll('4CQONRMN0ND13BYP02K2DBYMG4', 0);
                  mRoll.Params.Add('_PROGPOINT=IJ4R1NY0FJDL3BLX00C5OG4NF4');
                  if not mRoll.multiSelectDialog(False,mOResult) then Exit;
                  mStringlist:=tstringlist.create;

       end;
       mid_report:='X400000001';





        mBookmarkList := mDBGrid.SelectedRows; // *** v mBookmark jsou id označených záznamu

          if mBookmarkList.count=0 then begin
              mCustomBusinessObject:= TDynSiteForm(mSite).CurrentObject;
              if index=1 then begin
                 //mCustomBusinessObject.SetFieldValueAsString('X_Print_id',mid_report);
                 //mCustomBusinessObject.save;

              end;
              if index=0 then begin
                    mresult:=Create_folder(mCustomBusinessObject);
                    //if mresult then begin
                        mStringlist:=TStringList.create;
                        mStringlist.Add(mCustomBusinessObject.oid);
                        try
                           adir:=Format('%s\%s\%s', [constStoragePath, mCustomBusinessObject.GetFieldValueAsString('Period_id.code'),mCustomBusinessObject.GetFieldValueAsString('Docqueue_id.code')]);
                           //NxShowSimpleMessage(adir,nil)   ;
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
                          mid:=iPrintDocument(mCustomBusinessObject,'0Z4R1NY0FJDL3BLX00C5OG4NF4',mid_report,NxCreateContext(msite.BaseObjectSpace),mStringlist,mfilename,adir);

                          //mCustomBusinessObject.SetFieldValueAsString('X_Print_id',aid);
                          //mCustomBusinessObject.SetFieldValueAsBoolean('X_Uzamceno',True);
                          //mCustomBusinessObject.save;
                    {      mi:=mCustomBusinessObject.ObjectSpace.SQLExecute('update issuedinvoices set X_PrintReport_ID=' + quotedstr(mid_report) + ' where id='+ quotedstr(mCustomBusinessObject.oid));
                          mi:=mCustomBusinessObject.ObjectSpace.SQLExecute('update issuedinvoices set X_Uzamceno=' + quotedstr('A') + ' where id='+ quotedstr(mCustomBusinessObject.oid));
                        }finally
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
                                      mid:=iPrintDocument(mCustomBusinessObject,'0Z4R1NY0FJDL3BLX00C5OG4NF4',mid_report,NxCreateContext(msite.BaseObjectSpace),mStringlist,mfilename,adir);
                                    finally
                                        mStringlist.free;
                                    end;
                          //mi:=mCustomBusinessObject.ObjectSpace.SQLExecute('update issuedinvoices set X_Print_id=' + quotedstr(mid_report) + ' where id='+ quotedstr(mCustomBusinessObject.oid));
                       {   mi:=mCustomBusinessObject.ObjectSpace.SQLExecute('update issuedinvoices set X_Uzamceno=' + quotedstr('A') + ' where id='+ quotedstr(mCustomBusinessObject.oid));
                      }end;

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
procedure _AfterBeforePrint_Hook(Self: TSiteForm; APrintID: string; AParams: TNxParameters);
begin

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
          mMAction.Items.Add('Archivuj soubory');
          mMAction.Items.Add('Tisková sestava');
          if muser.GetFieldValueAsBoolean('X_Change_archiv') then mMAction.Items.Add('Zruš blokaci archívu');
          mMAction.Category := 'tabList';
          mMAction.OnExecuteItem := @OnExec;
        end;

     finally
      mUser.Free;
     end;
end;


begin
end.