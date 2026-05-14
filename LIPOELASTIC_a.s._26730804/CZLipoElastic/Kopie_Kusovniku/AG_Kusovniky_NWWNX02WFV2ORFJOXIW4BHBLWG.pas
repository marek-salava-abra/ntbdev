
procedure MojeCopyOnExecute(Sender: TObject);
var
  mSite: TDynSiteForm;
  mObj, mObj2: TNxCustomBusinessObject;
  i: integer;
  mOLE, mRoll, mOResult: Variant;
  mid_reportx:tstringlist;
  mr:tstringlist;
  mBO:TNxCustomBusinessObject;
begin
  if Sender is TComponent then begin
    //OutputDebugString('Sender je TComponent.');
    mSite := TComponent(Sender).DynSite;
    if Assigned(mSite) then begin
      //OutputDebugString('Nalezen nadřízený SiteForm.');
      mObj := TDynSiteForm(msite).CurrentObject;
      try
        if Assigned(mObj) then begin
            mid_reportx:=tstringlist.create;
                  try
                      mOLE:= GetAbraOLEApplication;
                        try
                          mOResult:= mOLE.CreateStrings;
                            mRoll:=mOLE.GetRoll('S3WZQKDB5FDL342M01C0CX3FCC', 0);
                            //mRoll.Params.Add('_PROGPOINT=MASKJM5IU3D13ACP03KIU0CLP4');
                            mRoll.multiSelectDialog(False,mOResult) ;
                                    for i := 0 to mOResult.Count-1 do begin
                                            mObj2 := mObj.Clone;
                                            try
                                              mobj2.SetFieldValueAsString('StoreCard_ID',mOResult.Strings[i]);
                                              mobj2.SetFieldValueAsString('X_StoreCard_ID',mOResult.Strings[i]);
                                              mobj2.SetFieldValueAsString('Qunit',mobj.getFieldValueAsString('X_StoreCard_ID.MainUnitCode'));
                                              mobj2.SetFieldValueAsString('Name',mobj2.getFieldValueAsString('StoreCard_ID.code') + ' - ' +mobj2.getFieldValueAsString('StoreCard_ID.Name')) ;


                                              // **********  načtení dat z již existujícího jiného kusovníku
                                        {      mr:=TStringList.create;
                                                   try
                                                      msite.BaseObjectSpace.SQLSelect('Select id from PLMPieceLists where storecard_ID=' + quotedstr(mOResult.Strings[i]),mr)  ;
                                                           if mr.count>0 then begin
                                                               mbo:=TDynSiteForm(msite).BaseObjectSpace.CreateObject('031N4GRZ4OT4TC5LYFK2WV1IFS');
                                                               try
                                                                  mbo.load(mr.Strings[0],nil);
                                                                       mObj2.SetFieldValueAsFloat('PlanedMaterial',mBO.getFieldValueAsFloat('PlanedMaterial'));
                                                                       mObj2.SetFieldValueAsFloat('PlanedCoopMat',mBO.getFieldValueAsFloat('PlanedCoopMat'));
                                                                       mObj2.SetFieldValueAsFloat('PlanedCooperation',mBO.getFieldValueAsFloat('PlanedCooperation'));
                                                                       mObj2.SetFieldValueAsFloat('DevelopmentCosts',mBO.getFieldValueAsFloat('DevelopmentCosts'));
                                                                       mObj2.SetFieldValueAsFloat('PriceForReceipt',mBO.getFieldValueAsFloat('PriceForReceipt'));

                                                                        mObj2.SetFieldValueAsString('BusOrder_ID',mBO.GetFieldValueAsString('BusOrder_ID'));
                                                                        mObj2.SetFieldValueAsString('BusTransaction_ID',mBO.GetFieldValueAsString('BusTransaction_ID'));
                                                                        mObj2.SetFieldValueAsString('BusProject_ID',mBO.GetFieldValueAsString('BusProject_ID'));
                                                              finally
                                                                   mbo.free;
                                                               end;
                                                           end;
                                                   finally
                                                       mr.free;
                                                   end;}
                                                 // ******** při nevyplněné ceně dotažení ceny ze skladové karty
                                             {    if mObj2.getFieldValueAsFloat('PriceForReceipt')=0 then begin
                                                          mbo:=TDynSiteForm(msite).BaseObjectSpace.CreateObject('C3V5QDVZ5BDL342M01C0CX3FCC');
                                                                 try
                                                                    mbo.load(mOResult.Strings[i],nil);
                                                                    mObj2.SetFieldValueAsFloat('PriceForReceipt',mBO.getFieldValueAsFloat('X_cena_skladova'));
                                                                 finally
                                                                     mbo.free;
                                                                 end;



                                                 end;    }



                                              mObj2.Save;
                                            finally
                                              mObj2.Free;
                                            end;
                                    end;
                                    ShowMessage('Bylo vytvořeno ' + inttostr(mOResult.count) + ' kusovníků. Občerstvěte si seznam.');
                         finally

                         end;
                  finally
                      mid_reportx.free;
                  end;
        end;
      finally
        mObj.Free;
      end;
    end;
  end;
end;


procedure FormCreate_Hook(Self: TSiteForm);
var
  mAction: TAction;
  mMAction: TMultiAction;
begin
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := 'Kopie kusovníku';
  mAction.Hint := 'Vytvoří kopie kusovníku pro vybrané skladové karty';
  mAction.Category := 'tabDetail, tabList';
  mAction.OnExecute := @MojeCopyOnExecute;

end;

begin
end.






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
       mid_report:='1CB0000101';
       mid_report1:='3100000101';
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
                           adir:=Format('%s\%s\%s', [constStoragePath, mCustomBusinessObject.GetFieldValueAsString('Period_id.code'),mCustomBusinessObject.GetFieldValueAsString('Docqueue_id.code')]);
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

                                     if mid_reportx='0000000000' then begin
                                                      if mCustomBusinessObject.GetFieldValueAsString('DocQueue_ID.Code')='FVR' then begin
                                                     //  NxShowSimpleMessage('Archivace auto',nil);
                                                      mid:=iPrintDocument(mCustomBusinessObject,'40SBPEINEFD13ACM03KIU0CLP4',mid_report1,NxCreateContext(msite.BaseObjectSpace),mStringlist,mfilename,adir);
                                                 end else begin
                                                 // NxShowSimpleMessage('Archivace auto',nil);
                                                      mid:=iPrintDocument(mCustomBusinessObject,'40SBPEINEFD13ACM03KIU0CLP4',mid_report,NxCreateContext(msite.BaseObjectSpace),mStringlist,mfilename,adir);

                                                 end;

                                     end else begin
                                                  NxShowSimpleMessage('Archivace výběrem ' + mid_reportx,nil);
                                                            mid:=iPrintDocument(mCustomBusinessObject,'40SBPEINEFD13ACM03KIU0CLP4',mid_reportx,NxCreateContext(msite.BaseObjectSpace),mStringlist,mfilename,adir);


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
                                                       mid:=iPrintDocument(mCustomBusinessObject,'40SBPEINEFD13ACM03KIU0CLP4',mid_reportx,NxCreateContext(mCustomBusinessObject.ObjectSpace),mStringlist,mfilename,adir);

                                     end else begin
                                                 if mCustomBusinessObject.GetFieldValueAsString('DocQueue_ID.Code')='FVR' then begin
                                                      mid:=iPrintDocument(mCustomBusinessObject,'40SBPEINEFD13ACM03KIU0CLP4',mid_report1,NxCreateContext(mCustomBusinessObject.ObjectSpace),mStringlist,mfilename,adir);
                                                 end else begin
                                                      mid:=iPrintDocument(mCustomBusinessObject,'40SBPEINEFD13ACM03KIU0CLP4',mid_report,NxCreateContext(mCustomBusinessObject.ObjectSpace),mStringlist,mfilename,adir);
                                                 end;
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








begin
end.
