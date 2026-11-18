uses 'abra.eu.mask.Lipoelastic.Archiv.lib';


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
mzruseni, mboolean:boolean;
mid_report1,mid_reportx:string;
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
       mid_report:='3WF7000101';
       mid_report1:='3WF7000101';
       mid_reportx:='0000000000';
      if index=0 then begin
            mOLE:= GetAbraOLEApplication;
              mOResult:= mOLE.CreateStrings;
                  mRoll:=mOLE.GetRoll('4CQONRMN0ND13BYP02K2DBYMG4', 0);
                  mRoll.Params.Add('_PROGPOINT=MASKJM5IU3D13ACP03KIU0CLP4');
                  mRoll.multiSelectDialog(False,mOResult) ;


                      mid_reportx:=mOResult.text ;


       end;
//  end else begin

//  end;





        mBookmarkList := mDBGrid.SelectedRows; // *** v mBookmark jsou id označených záznamu

          if mBookmarkList.count=0 then begin
              mCustomBusinessObject:= TDynSiteForm(mSite).CurrentObject;

                    mresult:=Create_folder(mCustomBusinessObject);
                     if index=0 then begin
                    //if mresult then begin
                        mStringlist:=TStringList.create;
                        mStringlist.Add(mCustomBusinessObject.oid);
                        try
                           adir:=Format('%s%s\%s', [constStoragePath, mCustomBusinessObject.GetFieldValueAsString('Period_id.code'),mCustomBusinessObject.GetFieldValueAsString('Docqueue_id.code')]);
                           mfilename:=Format('%s_%s_%s_%s', [inttostr(mCustomBusinessObject.GetFieldValueAsInteger('Ordnumber')),
                           mCustomBusinessObject.GetFieldValueAsString('Docqueue_id.code'),
                           mCustomBusinessObject.GetFieldValueAsString('Period_id.code'),
                           mCustomBusinessObject.GetFieldValueAsString('varsymbol')
                           ]);
                          //mboolean:=InputQuery('Soubor','_',(adir+'\'+mfilename+'.pdf'));
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

                                     if mid_reportx='0000000000' then begin
                                    //                  if mCustomBusinessObject.GetFieldValueAsString('DocQueue_ID.Code')='FVR' then begin
                                                     //  NxShowSimpleMessage('Archivace auto',nil);
                                    //                  mid:=iPrintDocument(mCustomBusinessObject,'40SBPEINEFD13ACM03KIU0CLP4',mid_report1,NxCreateContext(msite.BaseObjectSpace),mStringlist,mfilename,adir);
                                    //             end else begin
                                                  //NxShowSimpleMessage('Archivace auto  ' + mid_reportx,nil);
                                                      mid:=iPrintDocumentx(mCustomBusinessObject,'40SBPEINEFD13ACM03KIU0CLP4',mid_report,NxCreateContext(msite.BaseObjectSpace),mStringlist,mfilename,adir);


                                    //             end;

                                     end else begin
                                    //              NxShowSimpleMessage('Archivace výběrem ' + mid_reportx,nil);
                                          NxShowSimpleMessage(adir+'\'+mfilename+'.pdf',nil);                // ******
                                                            mid:=iPrintDocumentx(mCustomBusinessObject,'40SBPEINEFD13ACM03KIU0CLP4',mid_reportx,NxCreateContext(msite.BaseObjectSpace),mStringlist,mfilename,adir);


                                     end;
                          //mCustomBusinessObject.SetFieldValueAsString('X_PrintReport_ID',aid);
                          //mCustomBusinessObject.SetFieldValueAsBoolean('X_Uzamceno',True);
                          //mCustomBusinessObject.save;
                          mi:=mCustomBusinessObject.ObjectSpace.SQLExecute('update issuedinvoices set X_PrintReport_ID=' + quotedstr(mid_report) + ' where id='+ quotedstr(mCustomBusinessObject.oid));
                          mi:=mCustomBusinessObject.ObjectSpace.SQLExecute('update issuedinvoices set X_Uzamceno=' + quotedstr('A') + ' where id='+ quotedstr(mCustomBusinessObject.oid));
                        finally
                            mStringlist.free;
                        end;
              end;
              if index=2 then begin
                        if mCustomBusinessObject.GetFieldValueAsBoolean('X_Uzamceno') then begin
                                     // mpocet:=NxFloatToIBStr(mCustomBusinessObject.GetFieldValueAsFloat('U_kartony'));
                                    //  mResult:=InputQuery('Zadej data', 'počet kartonů', mpocet);
                                    //      if mresult then mi:=mCustomBusinessObject.ObjectSpace.SQLExecute('update issuedinvoices set U_Kartony=' + mpocet + ' where id='+ quotedstr(mCustomBusinessObject.oid));

                                   //   mpocet:=NxFloatToIBStr(mCustomBusinessObject.GetFieldValueAsFloat('U_Weight'));
                                  //    mResult:=InputQuery('Zadej data', 'Váha', mpocet);
                                 //     mi:=mCustomBusinessObject.ObjectSpace.SQLExecute('update issuedinvoices set U_Weight=' + mpocet + ' where id='+ quotedstr(mCustomBusinessObject.oid));
                         end else begin
                            NxShowSimpleMessage('Doklad ještě nebyl archovován',nil);
                         end;
              end;
              if index=1 then begin
                    if mzruseni then begin
                         if mCustomBusinessObject.GetFieldValueAsBoolean('X_Uzamceno') then begin

                        adir:=Format('%s\%s\%s', [constStoragePath, mCustomBusinessObject.GetFieldValueAsString('Period_id.code'),mCustomBusinessObject.GetFieldValueAsString('Docqueue_id.code')]);
                                       mfilename:=Format('%s_%s_%s_%s', [inttostr(mCustomBusinessObject.GetFieldValueAsInteger('Ordnumber')),
                                       mCustomBusinessObject.GetFieldValueAsString('Docqueue_id.code'),
                                       mCustomBusinessObject.GetFieldValueAsString('Period_id.code'),
                                       mCustomBusinessObject.GetFieldValueAsString('varsymbol')
                                       ]);


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
                            mi:=mCustomBusinessObject.ObjectSpace.SQLExecute('update issuedinvoices set X_PrintReport_ID=' + quotedstr('0000000000') + ' where id='+ quotedstr(mCustomBusinessObject.oid));
                            mi:=mCustomBusinessObject.ObjectSpace.SQLExecute('update issuedinvoices set X_Uzamceno=' + quotedstr('N') + ' where id='+ quotedstr(mCustomBusinessObject.oid));
                         end else begin
                            NxShowSimpleMessage('Doklad ještě nebyl archovován',nil);
                         end;
                    end else begin
                        NxShowSimpleMessage('Na zrušení archívu nemáte oprávnění',nil);
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
                                       if mid_reportx<>'' then begin
                                                       mid:=iPrintDocumentx(mCustomBusinessObject,'40SBPEINEFD13ACM03KIU0CLP4',mid_reportx,NxCreateContext(msite.BaseObjectSpace),mStringlist,mfilename,adir);
//                                                       mid:=iPrintDocument(mCustomBusinessObject,'40SBPEINEFD13ACM03KIU0CLP4',mid_report,NxCreateContext(os),mStringlist,mfilename,adir);
                                     //
                                     end else begin
                                                 //if mCustomBusinessObject.GetFieldValueAsString('DocQueue_ID.Code')='FVR' then begin
                                                 //     mid:=iPrintDocument(mCustomBusinessObject,'40SBPEINEFD13ACM03KIU0CLP4',mid_report1,NxCreateContext(mCustomBusinessObject.ObjectSpace),mStringlist,mfilename,adir);
                                                 //end else begin
                                                 //NxShowSimpleMessage(mdir+mfilename,nil);
                                                      mid:=iPrintDocumentx(mCustomBusinessObject,'40SBPEINEFD13ACM03KIU0CLP4',mid_report,NxCreateContext(msite.BaseObjectSpace),mStringlist,mfilename,adir);
                                                 //end;
                                     end;

                                    finally
                                        mStringlist.free;
                                    end;
                          mi:=mCustomBusinessObject.ObjectSpace.SQLExecute('update issuedinvoices set X_PrintReport_ID=' + quotedstr(mid_report) + ' where id='+ quotedstr(mCustomBusinessObject.oid));
                          mi:=mCustomBusinessObject.ObjectSpace.SQLExecute('update issuedinvoices set X_Uzamceno=' + quotedstr('A') + ' where id='+ quotedstr(mCustomBusinessObject.oid));
                      end;
                      if index=2 then begin
                            if mCustomBusinessObject.GetFieldValueAsBoolean('X_Uzamceno') then begin
                                            mpocet:=NxFloatToIBStr(mCustomBusinessObject.GetFieldValueAsFloat('U_kartony'));
                                            mResult:=InputQuery('Zadej data', 'počet kartonů', mpocet);
                                                if mresult then mi:=mCustomBusinessObject.ObjectSpace.SQLExecute('update issuedinvoices set U_Kartony=' + mpocet + ' where id='+ quotedstr(mCustomBusinessObject.oid));

                                            mpocet:=NxFloatToIBStr(mCustomBusinessObject.GetFieldValueAsFloat('U_Weight'));
                                            mResult:=InputQuery('Zadej data', 'Váha', mpocet);
                                            mi:=mCustomBusinessObject.ObjectSpace.SQLExecute('update issuedinvoices set U_Weight=' + mpocet + ' where id='+ quotedstr(mCustomBusinessObject.oid));
                               end else begin
                                  NxShowSimpleMessage('Doklad ještě nebyl archovován',nil);
                               end;
                      end;
                      if index=1 then begin
                         if mzruseni then begin
                               if mCustomBusinessObject.GetFieldValueAsBoolean('X_Uzamceno') then begin

                                  adir:=Format('%s\%s\%s', [constStoragePath, mCustomBusinessObject.GetFieldValueAsString('Period_id.code'),mCustomBusinessObject.GetFieldValueAsString('Docqueue_id.code')]);
                                       mfilename:=Format('%s_%s_%s_%s', [inttostr(mCustomBusinessObject.GetFieldValueAsInteger('Ordnumber')),
                                       mCustomBusinessObject.GetFieldValueAsString('Docqueue_id.code'),
                                       mCustomBusinessObject.GetFieldValueAsString('Period_id.code'),
                                       mCustomBusinessObject.GetFieldValueAsString('varsymbol')
                                       ]);


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

                                  mi:=mCustomBusinessObject.ObjectSpace.SQLExecute('update issuedinvoices set X_PrintReport_ID=' + quotedstr('0000000000') + ' where id='+ quotedstr(mCustomBusinessObject.oid));
                                  mi:=mCustomBusinessObject.ObjectSpace.SQLExecute('update issuedinvoices set X_Uzamceno=' + quotedstr('N') + ' where id='+ quotedstr(mCustomBusinessObject.oid));
                               end else begin
                                  NxShowSimpleMessage('Doklad ještě nebyl archovován',nil);
                               end;
                          end else begin
                                NxShowSimpleMessage('Na zrušení archívu nemáte oprávnění',nil);
                          end;
                      end;
             end;
        end;

        msite.Refresh;
        mDBGrid.Refresh;
        mDBGrid.DataSource.DataSet.Refresh;
end;




procedure _CanEdit_Hook(Self: TDynSiteForm; var ACanEdit: Boolean);

begin

                      if not nxisemptyoid(self.CurrentObject.GetFieldValueAsString('X_PrintReport_ID')) then begin
                            if (NxGetUserName='Supervisor') or (NxGetUserName = 'abraadmin') then begin
                                 NxShowSimpleMessage('Upozornění: Doklad je již archivován. S vaším omezením lze opravovat',self);
                            end else begin

                                ACanEdit := False;
                                NxShowSimpleMessage('Faktura je již archivovaná',self);
                            end;
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
          mMAction.Hint := 'Archivuj soubory';
          mMAction.Caption := 'Archivuj soubory';
          mMAction.Items.Add('Archivuj soubory');
          mMAction.Items.Add('Zruš blokaci archívu');
          mMAction.Items.Add('Doplň archivované soubory');
          mMAction.Category := 'tabList';
          mMAction.OnExecuteItem := @OnExec;
        end;



end;


   function iPrintDocumentx(Obj:TNxCustomBusinessObject;ADynCLSID:string;ReportID:string;Acontext:TNxContext;mprintlist:TStrings;AName:string;Adir:string):string;
var
        mOLEApp: Variant;
        mCommand: Variant;
        mCond: Variant;
        FName:string;
        mbo: TNxCustomBusinessObject;
        mDynCLSID:string;
begin
        if  NxIsBlank(ADynCLSID) then begin
            mDynCLSID := Obj.DefaultDynSourceID;
        end else begin
            mDynCLSID:=ADynCLSID;
        end;

         FName:=aname+'.pdf';;
        //                mCommand.Print(ReportID,8,adir,FName);

               // NxShowSimpleMessage(adir+ FName,nil);
                NxPrintByIDs(Acontext, mPrintList, mDynCLSID, ReportID, rtofile, pekpdf, adir, FName) ;
                result:=adir+FName;
end;



begin
end.