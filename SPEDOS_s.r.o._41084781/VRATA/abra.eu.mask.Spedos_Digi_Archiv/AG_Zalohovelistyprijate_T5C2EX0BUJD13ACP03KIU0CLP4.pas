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
    mid_report:string;
    mi:integer;
    adir,afilename:string;
mOLE, mRoll, mOResult: Variant;
mUser:TNxCustomBusinessObject;
mpocet:string;
mzruseni:boolean;
stav:boolean;
mr:tstringlist;
begin
        mSite := NxFindSiteForm(Sender);
        mTabList := TTabSheet(NxFindChildControl(mSite.MainPanel, 'tabList'));
        if mTabList = nil then RaiseException('tabList nenalezen');
        mDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdList'));
        if mDBGrid = nil then RaiseException('DBGrid nenalezen');
         mr:=tstringlist.create;
                try
                        mSite.BaseObjectSpace.SQLSelect('select max(Directory) from FileQueues where code='+ quotedstr('Archiv'),mr);
                      //  if mr.count=1 then constStoragePath:=mr.Strings[0];
                finally
                    mr.free;
                end;

        muser:=msite.BaseObjectSpace.CreateObject('22AHIVDVAVE13C5S00CA141B44');

        mBookmarkList := mDBGrid.SelectedRows; // *** v mBookmark jsou id označených záznamu

          if mBookmarkList.count=0 then begin
              mCustomBusinessObject:= TDynSiteForm(mSite).CurrentObject;

              adir:=Format('%s\%s\%s', [constStoragePath, mCustomBusinessObject.GetFieldValueAsString('Period_id.code'),mCustomBusinessObject.GetFieldValueAsString('Docqueue_id.code')]);
              afilename:=Format('%s_%s_%s_%s', [mCustomBusinessObject.GetFieldValueAsString('Docqueue_id.code'),
                           inttostr(mCustomBusinessObject.GetFieldValueAsInteger('Ordnumber'))
                           ,
                           mCustomBusinessObject.GetFieldValueAsString('Period_id.code'),
                           mCustomBusinessObject.GetFieldValueAsString('varsymbol')
                           ]);

              if true then begin
                       if PromptForFileName(mFileName, mfilter, '', 'Soubor ' + afilename, mdir, False) then begin
                               mdir:=copy(mfilename,0,NxCharPosR('\',mfilename));
                                mFile:=copy(mfilename,1+NxCharPosR('\',mfilename),Length(mfilename));
                       end;
                       if not FileExists(mFileName) then begin
                          exit;
                        end;

                    mresult:=Create_folder(mCustomBusinessObject);
                    //if mresult then begin
                          //NxShowSimpleMessage(adir+'\'+mfilename+'.pdf',nil);
                        stav:=nxcopyfile(mFileName,adir + '\' + aFileName+copy(mfilename,NxCharPosR('.',mfilename),4));
                              if stav then begin
                                  DeleteFile(mFileName);

                              end;


              end;
        end else begin
             for i := 0 to mBookmarkList.Count-1 do begin // projdu vsechny oznacene zaznamy
                  mDBGrid.DataSource.DataSet.GotoBookmark(mBookmarkList.items(i));
                      mCustomBusinessObject:= TDynSiteForm(mSite).CurrentObject;

                      adir:=Format('%s\%s\%s', [constStoragePath, mCustomBusinessObject.GetFieldValueAsString('Period_id.code'),mCustomBusinessObject.GetFieldValueAsString('Docqueue_id.code')]);
                      afilename:=Format('%s_%s_%s_%s', [mCustomBusinessObject.GetFieldValueAsString('Docqueue_id.code'),
                                   inttostr(mCustomBusinessObject.GetFieldValueAsInteger('Ordnumber'))
                                   ,
                                   mCustomBusinessObject.GetFieldValueAsString('Period_id.code'),
                                   mCustomBusinessObject.GetFieldValueAsString('varsymbol')
                                   ]);

                      if true then begin
                               if PromptForFileName(mFileName, mfilter, '', 'Soubor ' + afilename, mdir, False) then begin
                                       mdir:=copy(mfilename,0,NxCharPosR('\',mfilename));
                                        mFile:=copy(mfilename,1+NxCharPosR('\',mfilename),Length(mfilename));
                               end;
                               if not FileExists(mFileName) then begin
                                  exit;
                                end;

                            mresult:=Create_folder(mCustomBusinessObject);
                            //if mresult then begin
                                  //NxShowSimpleMessage(adir+'\'+mfilename+'.pdf',nil);
                                stav:=nxcopyfile(mFileName,adir + '\' + aFileName+copy(mfilename,NxCharPosR('.',mfilename),4));
                                      if stav then begin
                                          DeleteFile(mFileName);

                                      end;


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
          //mMAction.Items.Add('Tisková sestava');
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