var
    mFSazba_hod_den,mFDoprava_km,mF_doprava_pausal,mFSazba_hod:double;
    mBO_BusProject:TNxCustomBusinessObject;
    mF_pausal_prace,mF_pausal_Vyjezd,mF_prace,mF_km:double;
    // doby + termíny
    mF_doba:double;
    mRows : TNxCustomBusinessMonikerCollection;
    result:boolean;
    mresult:boolean;
      mBookmark : TBookmarkList;
    mBustrasaction_ID:string;

procedure Protokol(Sender: TAction; Index: integer);
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
begin
  mSite := NxFindSiteForm(Sender);
    mTabList := TTabSheet(NxFindChildControl(mSite.MainPanel, 'tabList'));
    if mTabList = nil then RaiseException('tabList nenalezen');
    mDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdList'));
    if mDBGrid = nil then RaiseException('DBGrid nenalezen');
    mBookmark := mDBGrid.SelectedRows; // *** v mBookmark jsou id označených záznamu

    if mBookmark.count=0 then begin
               // pro aktuální záznam
               mfile:='';
               mfile:=autocopy_protocol(TDynSiteForm(mSite).CurrentObject);
               if mfile='' then begin
                   mfile:=manualcopy_protocol(TDynSiteForm(mSite).CurrentObject);
               end;
               if mfile<>'' then begin
                  TDynSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_Spedos_formular',mfile);
                  TDynSiteForm(mSite).CurrentObject.save;
                  TDynSiteForm(mSite).ActiveDataSet.RefreshCurrentItem;
               end;
    end else begin
         for i := 0 to mBookmark.Count- 1 do begin
                          mDBGrid.DataSource.DataSet.GotoBookmark(mBookMark.items(i));
                          mBO:= TDynSiteForm(mSite).CurrentObject;
                                         // pro aktuální záznam
                               mfile:='';
                               mfile:=autocopy_protocol(TDynSiteForm(mSite).CurrentObject);
                               if mfile='' then begin
                                   mfile:=manualcopy_protocol(TDynSiteForm(mSite).CurrentObject);
                               end;
                               if mfile<>'' then begin
                                  TDynSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_Spedos_formular',mfile);
                                  TDynSiteForm(mSite).CurrentObject.save;
                                  TDynSiteForm(mSite).ActiveDataSet.RefreshCurrentItem;
                                end;
         end;

    end;





end;


function autocopy_protocol(mbo:TNxCustomBusinessObject):string;
var
   mfilelist:tstringlist;
   mPAthList:TStringList;
   i,ii:integer;
   mpath:string;
   mFileName,mfilter:string;
begin
    result:='';
                   mpath:='\\192.168.0.3\disk_r\servis_foto\';
                   mPAthList:=TStringList.create;
                   try
                      mbo.ObjectSpace.SQLSelect('select SR.X_path_protokol from ServiceAssemblyForms2 SA2 left join SecurityRoles SR on sr.id=Sa2.X_WorkerRole_ID where (SR.X_path_protokol is not null) and SA2.Parent_ID=' + quotedstr(mbo.oid) + ' group by SR.X_path_protokol',mPAthList);
                      for ii:=0 to mPAthList.count-1 do begin
                            mfilelist:=TStringList.create;
                            try

                                 NxGetFileList(mpath+mPAthList.Strings[ii],mFileList,'*.*');
                                 for i:=0 to mFileList.count-1 do begin

                                     if pos((mbo.GetFieldValueAsString('X_Protokol_prefix') + mbo.GetFieldValueAsString('X_Protokol')), mfilelist.Strings[i])>0 then begin


                                          if NxCopyFile(mpath+mPAthList.Strings[ii]+'\'+mfilelist.Strings[i], (Format('%s\%s\%s\%s\%s\%s', ['\\192.168.0.36\abra\Servis', mbo.GetFieldValueAsString('ServiceDocument_ID.ServicedObject_ID'),
                                          'Servisni listy',mbo.GetFieldValueAsString('ServiceDocument_ID'),'ML',mbo.oid])) +'\'+ mfilelist.Strings[i])
                                          then begin
                                               NxShowSimpleMessage('Přiložen formulář: ' + mfilelist.Strings[i],nil);
                                               result:=mfilelist.Strings[i];
                                               if not DeleteFile(mpath+mPAthList.Strings[ii]+'\' +mfilelist.Strings[i]) then NxShowSimpleMessage('nepodařilo se přesunout protokol, prosím smažte',nil)  ;
                                          end else begin
                                              NxShowSimpleMessage('Nepodařilo se překopírovat soubor: ' + mfilelist.Strings[i],nil);
                                          end;
                                     end;
                                 end;
                             finally
                                mfilelist.free;
                             end;
                       end;
                   finally
                      mPAthList.free;
                   end;






end;


function manualcopy_protocol(mbo:TNxCustomBusinessObject):string;
var
   mfilelist,mPAthList:tstringlist;
   i:integer;
   mpath:string;
   mFileName,mfilter,mfile:string;
begin


                   mPAthList:=TStringList.create;
                   try
                      mbo.ObjectSpace.SQLSelect('select max(SR.X_path_protokol) from ServiceAssemblyForms2 SA2 left join SecurityRoles SR on sr.id=Sa2.X_WorkerRole_ID where (SR.X_path_protokol is not null) and SA2.Parent_ID=' + quotedstr(mbo.oid) + ' group by SR.X_path_protokol',mPAthList);
                        if trim(mPAthList.Strings[0])<>'' then begin
                            mpath:='\\192.168.0.3\disk_r\servis_foto\'+mPAthList.Strings[0];
                        end else begin
                            mpath:='\\192.168.0.3\disk_r\servis_foto\';
                        end;

                   finally

                   end;


         if PromptForFileName(mFileName, '', '', 'Dohledejte protokol', mpath, False) then begin
                if mFileName<>'' then begin
                    mpath:=copy(mfilename,0,NxCharPosR('\',mfilename));
                    mFile:=copy(mfilename,1+NxCharPosR('\',mfilename),Length(mfilename));
                    if NxCopyFile(mFileName, (Format('%s\%s\%s\%s\%s\%s', ['\\192.168.0.36\abra\Servis', mbo.GetFieldValueAsString('ServiceDocument_ID.ServicedObject_ID'),
                        'Servisni listy',mbo.GetFieldValueAsString('ServiceDocument_ID'),'ML',mbo.oid])) +'\'+ mfile)
                        then begin
                            if not DeleteFile(mFileName) then NxShowSimpleMessage('nepodařilo se přesunout protokol, prosím smažte',nil)  ;
                            result:=mFile;
                    end else begin
                            NxShowSimpleMessage('Nepodařilo se překopírovat soubor: ' + mfile,nil);
                    end;
                            //Import_SP_V(msite.baseobjectspace, mfilename, mdir,mfile,msite,true,false);
                            result:=mFileName;
                end;
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
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := 'Protokoly';
  mAction.Hint := 'Protokol';
  mAction.Category := 'tabList';
  mAction.OnExecute:= @Protokol;



end;

begin
end.