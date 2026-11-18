uses  '_Knihovny_ALL.Progress',
      '_Knihovny_ALL.Parse',
      'Synchronizace_dokladu_na_SK.API';
      // 'NxApiLib.lib' ;

      const
mTable='IssuedOrders';
mApiTable='IssuedOrders';


var
mSError:string;
mboolean:boolean;





 procedure Print_document(Sender: TObject;index:integer);
var
  mSite: TSiteForm;
  mDBGrid : TDBGrid;
 mTabList: TTabSheet;
  mObj, mObj2: TNxCustomBusinessObject;
  mOLE, mRoll, mOResult: Variant;
  mid_reportx:tstringlist;
  mr,mr0:tstringlist;
  self:TNxCustomBusinessObject;
  mi:integer;
  mBookmark : TBookmarkList;
  mIBookmark:integer;
  mICount:integer;
  mids:string;
 aString:string;
  mstring:string;
  ARequest:string;

  mQuery,mQueryID:string;
  mID:string;
  mNewQueryID:string;
  mSQL:string;
  i,ii,iii:integer;
  mTarget:string;
 mr1:tstringlist;
 mDocBatchRow:TNxCustomBusinessObject;
 mMonRows:TNxCustomBusinessMonikerCollection;
 mMonBatches:TNxCustomBusinessMonikerCollection;
 mDocqueue_ID,mFirm_ID,mStore_ID,mStorecard_ID,mDivision_ID:string   ;
 mBO:TNxCustomBusinessObject;
 mBatch_ID:string;
 mRow_ID:string;
 mDocRowOV_ID:string;
 mDoc_ID:string;
 mDocRowOP_ID:string;
 mxid:string;
 blat_from,blat_to, Blat_subject,Blat_body, Blat_File:string;
  aname:string;
  msestava:string;
  mPrintList:tstringlist;
  mdocnumber,mSDocError,mSError:string;
  mB:boolean;
  mBoolean:boolean;
begin
  mids:='';
  if Sender is TComponent then mSite := TComponent(Sender).Site;

//  if Sender is TAction then mSite := NxFindSiteForm(Sender);

    if not Assigned(mSite) then begin
         NxMessageBox('Chyba', 'Agenda nebyla dohledána', mdConfirm, mdbOkCancel, 0, 0, true, nil) ;
         nxbeep(btfailure);
         exit;
    end else begin
        mTabList := TTabSheet(NxFindChildControl(mSite.MainPanel, 'tabList'));
            if mTabList = nil then begin
                  RaiseException('tabList nenalezen');
                  NxMessageBox('Chyba', 'abList nenalezen', mdConfirm, mdbOkCancel, 0, 0, true, nil) ;
                  nxbeep(btfailure);
                  exit;
            end else begin
            mDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdList'));
                if mDBGrid = nil then begin
                      RaiseException('DBGrid nenalezen');
                      NxMessageBox('Chyba', 'DBGrid nenalezen', mdConfirm, mdbOkCancel, 0, 0, true, nil) ;
                      nxbeep(btfailure);
                      exit;
                end else begin

                      mBookmark := mDBGrid.SelectedRows; // *** v mBookmark jsou id označených záznamu
                      mIBookmark:=0;
                      if mBookmark.count>0 then begin
                           mIBookmark:=mBookmark.count-1;
                           ProgressInit(msite, 'Zpracování dat ' + '', 100);
                      end;
                      mdocnumber:='';
                      for mICount:=0 to mIBookmark do begin

                          if mBookmark.count>0 then begin
                               mDBGrid.DataSource.DataSet.GotoBookmark(mBookMark.items(mICount));
                               ProgressSetPos(1+NxFloor(mICount/mBookmark.Count*99), inttostr(mICount) +' z '+inttostr(mBookmark.Count));
                          end;
                          //TDynSiteForm(mSite).ActiveDataSet.RefreshCurrentItem;
                          self:=TDynSiteForm(msite).CurrentObject;    // načtení objektu

                          //mTarget:=mTargetAPI + '/';
                          mTarget:=mSourceAPI + '/'  ;
                                                                            // vytvoření dokladu
                           mSDocError:= CheckDocumentStorecard(TDynSiteForm(mSite).CurrentObject, mTarget) ;
                           if mSDocError<>'' then begin
                               mSError:=mSError+ mSDocError;
                           end;
                           if mSError='' then begin
                                //NxShowSimpleMessage('Test k synchronizaci doběhl',nil);
                            end else begin
                                   mb:=InputQuery('Doklad nejde synchronizovat', 'Problémové položky', mSError);
                            end;



                          //mString:= APICallRest(self,'POST',mtarget,'ReceivedOrders','?select=id,displayname',mQuery,true);  // odeslání OV

                          //mString:= APICallRest(self,'GET',mtarget,'ReceivedOrders','/YBOBJ00101.pdf?select=id&report=1WI0000101','',true);  // odeslání OV


                        //  mdocnumber:=mdocnumber + ', ' + copy(mString,1,1000000);


                       //   if (copy(mString,1,3)='200') then begin
                            //mDoc_ID:= copy(mString,14,10);
                        //  end else begin
                            //NxShowSimpleMessage('Chyba v přístupu k api' + mString,nil);
                        //  end;

                          mstring:='';
                          //   vytvoření OV
                          //mdocnumber:= ReplaceStr(mdocnumber + ', ' + copy(mString,41,15),'\','');;
                          TDynSiteForm(mSite).ActiveDataSet.RefreshCurrentItem;


                      end;
                      if mBookmark.count>0 then  ProgressDispose()   ;
                end;
            end;
    end;

     nxshowsimplemessage('Dokument vytištěn' + mdocnumber ,nil);

end;





 procedure Synchronizace(Sender: TObject;index:integer);
var
  mSite: TSiteForm;
  mDBGrid : TDBGrid;
 mTabList: TTabSheet;
  mObj, mObj2: TNxCustomBusinessObject;
  mOLE, mRoll, mOResult: Variant;
  mid_reportx:tstringlist;
  mr,mr0:tstringlist;
  self:TNxCustomBusinessObject;
  mi:integer;
  mBookmark : TBookmarkList;
  mIBookmark:integer;
  mICount:integer;
  mids:string;
 aString:string;
  mstring:string;
  ARequest:string;

  mQuery,mQueryID:string;
  mID:string;
  mNewQueryID:string;
  mSQL:string;
  i,ii,iii:integer;
  mTarget:string;
 mr1:tstringlist;
 mDocBatchRow:TNxCustomBusinessObject;
 mMonRows:TNxCustomBusinessMonikerCollection;
 mMonBatches:TNxCustomBusinessMonikerCollection;
 mDocqueue_ID,mFirm_ID,mStore_ID,mStorecard_ID,mDivision_ID:string   ;
 mBO:TNxCustomBusinessObject;
 mBatch_ID:string;
 mRow_ID:string;
 mDocRowOV_ID:string;
 mDoc_ID:string;
 mDocRowOP_ID:string;
 mxid:string;
 blat_from,blat_to, Blat_subject,Blat_body, Blat_File:string;
  aname:string;
  msestava:string;
  mPrintList:tstringlist;
  mdocnumber:string;
  mB:boolean;
  mExtUser:string;
  mExtNumber:string;
begin
  mids:='';
  if Sender is TComponent then mSite := TComponent(Sender).Site;

//  if Sender is TAction then mSite := NxFindSiteForm(Sender);

    if not Assigned(mSite) then begin
         NxMessageBox('Chyba', 'Agenda nebyla dohledána', mdConfirm, mdbOkCancel, 0, 0, true, nil) ;
         nxbeep(btfailure);
         exit;
    end else begin
        mTabList := TTabSheet(NxFindChildControl(mSite.MainPanel, 'tabList'));
            if mTabList = nil then begin
                  RaiseException('tabList nenalezen');
                  NxMessageBox('Chyba', 'abList nenalezen', mdConfirm, mdbOkCancel, 0, 0, true, nil) ;
                  nxbeep(btfailure);
                  exit;
            end else begin
            mDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdList'));
                if mDBGrid = nil then begin
                      RaiseException('DBGrid nenalezen');
                      NxMessageBox('Chyba', 'DBGrid nenalezen', mdConfirm, mdbOkCancel, 0, 0, true, nil) ;
                      nxbeep(btfailure);
                      exit;
                end else begin

                      mBookmark := mDBGrid.SelectedRows; // *** v mBookmark jsou id označených záznamu
                      mIBookmark:=0;
                      if mBookmark.count>0 then begin
                           mIBookmark:=mBookmark.count-1;
                           ProgressInit(msite, 'Zpracování dat ' + '', 100);
                      end;
                      mdocnumber:='';
                      for mICount:=0 to mIBookmark do begin

                          if mBookmark.count>0 then begin
                               mDBGrid.DataSource.DataSet.GotoBookmark(mBookMark.items(mICount));
                               ProgressSetPos(1+NxFloor(mICount/mBookmark.Count*99), inttostr(mICount) +' z '+inttostr(mBookmark.Count));
                          end;
                          //TDynSiteForm(mSite).ActiveDataSet.RefreshCurrentItem;
                          self:=TDynSiteForm(msite).CurrentObject;    // načtení objektu
                          mExtNumber:='';
                          //self.Refresh;
                          //NxShowSimpleMessage(IntToStr(index),nil);
                                     if self.GetFieldValueAsDateTime('X_SendDate$Date')<>0 then begin
                                           NxShowSimpleMessage('Doklad již byl zpracován dříve',nil);
                                     end else begin  //NxGetUserName='mskacel' then begin
                                          mDoc_ID:='';
                                           try
                                           mSDocError:= CheckDocumentStorecard(self, mTarget) ;
                                                   if mSDocError<>'' then begin
                                                       mSError:=mSError+ mSDocError;
                                                   end;
                                                   if mSError='' then begin
                                                        //NxShowSimpleMessage('Test k synchronizaci doběhl',nil);
                                                    end else begin
                                                           mboolean:=InputQuery('Doklad nejde synchronizovat', 'Problémové položky', mSError);
                                                           exit;
                                                    end;
                                            finally

                                            end;


                                                         if true then begin                     // načtení BO OV

                                                                            mTarget:=mTargetAPI + '/';
                                                                            // vytvoření dokladu
                                                                            if index=0 then begin
                                                                                   if self.GetFieldValueAsString('Docqueue_ID.code')='OVG' then begin
                                                                                        mQuery:=GetDocQuery(self,'5772000101','3010000101','','5151000101','5O10000101','RO')  ;
                                                                                   end else begin
                                                                                         mQuery:=GetDocQuery(self,'4722000101','3010000101','','7131000101','5O10000101','RO')  ;

                                                                                   end;
                                                                                   mstring:='';
                                                                                //  if index=3 then mb:=InputQuery('Kontrola API','POST',mtarget+'ReceivedOrders?select=displayname'+mQuery) ;

                                                                            //mboolean:=InputQuery('TEST','JSON','POST'+mtarget+'ReceivedOrders'+'?select=id+displayname          ' + mQuery)  ;
                                                                                   mString:= APICallRest(self,'POST',mtarget,'ReceivedOrders','?select=id,displayname',mQuery,true);  // odeslání OV
                                                                            mdocnumber:=mdocnumber + ', ' + copy(mString,41,15);
                                                                            mExtNumber:= copy(mString,41,15);
                                                                             mDoc_ID:= copy(mString,14,10);

                                                                            // uživatel
                                                                            //(Self.CompanyCache.GetUserID,
                                                                            mExtUser:='';
                                                                            mExtUser:=msite.CompanyCache.GetFieldFromRoll('G1W2A2CBNNDL3DZ403KIU0CLP4',0,'X_Other_User_ID',msite.CompanyCache.GetUserID) ;
                                                                            //if msite.CompanyCache.GetUserID='SUPER00000' then NxShowSimpleMessage(' dokument: ' + mDoc_ID + ' Ext user : '+ mExtUser,nil);
                                                                           // if mExtUser<>'' then mString:=APINxSQL_String(msite.BaseObjectSpace,mtarget,'UPDATE','CreatedBy_ID=' + QuotedStr(mExtUser),'ReceivedOrders','ID=' + quotedstr(mDoc_ID));


                                                                            end;

                                                                                  //if (copy(mString,1,3)='201') then begin
                                                                                  if true then begin
                                                                                        //NxShowSimpleMessage('doklad ' + copy(mString,14,10),nil);
                                                                                        //if copy(mString,9,2)='ID' then begin      // záznam namezen
                                                                                             //    mDoc_ID:= copy(mString,14,10);





                                                                                             //if mBsentemail then begin
                                                                                                mPrintList := TStringList.Create;
                                                                                                try
                                                                                                   //NxShowSimpleMessage('sestava vytvářena ',nil);
                                                                                                   mPrintList.Add(self.OID);
                                                                                                   AName := self.GetFieldValueAsString('Docqueue_ID.CODE') +'-' + inttostr(self.GetFieldValueAsInteger('Ordnumber'))  +'-' + self.GetFieldValueAsString('Period_id.CODE')+'.pdf' ;
                                                                                                   //mSestava:='3W07000101';
                                                                                                   //AName := self.DisplayName+'.pdf' ;
                                                                                                   try
                                                                                                      CFxReportManager.PrintByIDs(NxCreateContext(self.ObjectSpace),mPrintList,'W0NZQGROZZDL342X01C0CX3FCC', '2NI0000101', rtofile, pekPDF,NxGetTempDir,aname);
                                                                                                      Blat_File:=NxGetTempDir+'\'+aname;
                                                                                                      //NxShowSimpleMessage('Report vytvořen ' + aname,nil);
                                                                                                      try

                                                                                                          //NxShowSimpleMessage('email vytvářen',nil);
                                                                                                              Blat_File:=NxGetTempDir+aname;
                                                                                                              mxid:='';
                                                                                                              mxid:=iSendMailx(self.ObjectSpace, 'Objednávka: ' + self.DisplayName , 'Právě Vám byla odeslána objednávka ze společnosti LIPOELASTIC a.s. s číslem: ' +  self.DisplayName, mSTargetemail, '','','3130000101', Blat_File,'1N00000101',self);
                                                                                                              //NxShowSimpleMessage('email odeslán ' + aname,nil);
                                                                                                      except
                                                                                                      end;
                                                                                                   except
                                                                                                   end;
                                                                                                finally
                                                                                                    mPrintList.free;
                                                                                                end;
                                                                                             //end;


                      end else begin
                             NxShowSimpleMessage('Chyba v přístupu k api' + mString,nil);
                             //exit;
                      end;


                                                                                                if true then begin       // *******  dotaz na šarží
                                                                                                    mMonRows := Self.GetLoadedCollectionMonikerForFieldCode(Self.GetFieldCode('ROWS'));
                                                                                                        for i := 0 to mMonRows.Count-1 do begin
                                                                                                            //NxShowSimpleMessage(' Řádek ' + mMonRows.BusinessObject[i].GetFieldValueAsString('ID'),nil);
                                                                                                            mr:=TStringList.create;
                                                                                                            try
                                                                                                                mSite.BaseObjectSpace.SQLSelect('Select id FROM DefRollData A WHERE (A.Hidden = ' + quotedstr('N') + ' ) AND (A.CLSID = ' + quotedstr('EC2R2HSFK5UOZ5MYVJWJOHUC4S') +
                                                                                                                                                ' ) AND (A.X_Parent_ID ) = ' + quotedstr(mMonRows.BusinessObject[i].GetFieldValueAsString('ID')),mr);
                                                                                                                if mr.count>0 then
                                                                                                                      //if index=0 then
                                                                                                                      mDocBatchRow:=msite.BaseObjectSpace.CreateObject('EC2R2HSFK5UOZ5MYVJWJOHUC4S');
                                                                                                                         try
                                                                                                                            for ii:=0 to mr.count-1 do begin
                                                                                                                                  mDocBatchRow.load(mr.Strings[ii],nil);
                                                                                                                                      //NxShowSimpleMessage(' Pohyb šarže ' + mDocBatchRow.GetFieldValueAsString('ID'),nil);

                                                                                                                                      mBatch_ID:='';
                                                                                                                                      mBatch_ID:=API_GetOrCreateBatch(mSite,mtarget,mDocBatchRow.GetFieldValueAsString('X_Batches'));
                                                                                                                                      mDocRowOP_ID:='';
                                                                                                                                      mDocRowOP_ID:= API_GetOrCreateOPDocRowBatch(mSite,mtarget,mDoc_ID,mMonRows.BusinessObject[i],mBatch_ID,mDocBatchRow.GetFieldValueAsFloat('X_quantity'),index);
                                                                                                                            end;
                                                                                                                      finally
                                                                                                                      //   mDocBatchRow.free;
                                                                                                                      end;
                                                                                                            finally
                                                                                                                mr.free;

                                                                                                            end;
                                                                                                          // if i=mMonRows.Count-1 then NxShowSimpleMessage('Doklad s šaržemi je synchronizován',nil);
                                                                                                        end;
                                                                                                end;

                                                         end;
                                          mstring:='';
                                          //   vytvoření OV
                                          if self.GetFieldValueAsString('Docqueue_ID.code')='OVG' then begin
                                                  mQueryID:='';
                                                         mQueryID:=mQueryID+ '{';
                                                         mQueryID:=mQueryID+   	'"params": { ';
                                                         mQueryID:=mQueryID+   	'	"docqueue_id": "6772000101" ';
                                                         mQueryID:=mQueryID+   	'}';
                                                         mQueryID:=mQueryID+   '}';

                                                    //mstring:= inputbox('Importmanager','POST',mtarget+'issuedorders/import/receivedorders/' + mDoc_ID +'?select=id,displayname'+   '     ' +mQueryID )    ;
                                                     mstring:= APICallRestImp(self, 'POST',mtarget,'receivedorders','issuedorders',mDoc_ID,'6772000101','','?select=id,displayname',true,false);

                                          end else begin
                                                  mQueryID:='';
                                                         mQueryID:=mQueryID+ '{';
                                                         mQueryID:=mQueryID+   	'"params": { ';
                                                         mQueryID:=mQueryID+   	'	"docqueue_id": "5722000101" ';
                                                         mQueryID:=mQueryID+   	'}';
                                                         mQueryID:=mQueryID+   '}';

                                                    //mstring:= inputbox('Importmanager','POST',mtarget+'issuedorders/import/receivedorders/' + mDoc_ID +'?select=id,displayname'+   '     ' +mQueryID )    ;
                                                     mstring:= APICallRestImp(self, 'POST',mtarget,'receivedorders','issuedorders',mDoc_ID,'5722000101','','?select=id,displayname',true,false);


                                          end;

                                          mdocnumber:= ReplaceStr(mdocnumber + ', ' + copy(mString,41,15),'\','');;
                                            mDoc_ID:= copy(mString,14,10);


                                                                            // uživatel
                                                                            //(Self.CompanyCache.GetUserID,
                                                                            mExtUser:='';
                                                                            mExtUser:=msite.CompanyCache.GetFieldFromRoll('G1W2A2CBNNDL3DZ403KIU0CLP4',0,'X_Other_User_ID',msite.CompanyCache.GetUserID) ;
                                                                            //if msite.CompanyCache.GetUserID='SUPER00000' then NxShowSimpleMessage(' dokument: ' + mDoc_ID + ' Ext user : '+ mExtUser,nil);
                                                                           // if mExtUser<>'' then mString:=APINxSQL_String(msite.BaseObjectSpace,mtarget,'UPDATE','CreatedBy_ID=' + QuotedStr(mExtUser),'ReceivedOrders','ID=' + quotedstr(mDoc_ID));










                                          // if Blat_to<>'' then begin
                                                    mPrintList := TStringList.Create;
                                                    try
                                                       //NxShowSimpleMessage('sestava vytvářena ',nil);
                                                       mPrintList.Add(self.OID);
                                                       AName := self.GetFieldValueAsString('Docqueue_ID.CODE') +'-' + inttostr(self.GetFieldValueAsInteger('Ordnumber'))  +'-' + self.GetFieldValueAsString('Period_id.CODE')+'.pdf' ;
                                                       //mSestava:='3W07000101';
                                                       //AName := self.DisplayName+'.pdf' ;
                                                       try
                                                          CFxReportManager.PrintByIDs(NxCreateContext(self.ObjectSpace),mPrintList,'W0NZQGROZZDL342X01C0CX3FCC', '2NI0000101', rtofile, pekPDF,NxGetTempDir,aname);
                                                          Blat_File:=NxGetTempDir+'\'+aname;
                                                          //NxShowSimpleMessage('Report vytvořen ' + aname,nil);
                                                          try

                                                              //NxShowSimpleMessage('email vytvářen',nil);
                                                                  Blat_File:=NxGetTempDir+aname;
                                                                  mxid:='';
                                                             //     mxid:=iSendMailx(self.ObjectSpace, 'Objednávka: ' + self.DisplayName , 'Právě Vám byla odeslána objednávka ze společnosti LIPOELASTIC a.s. s číslem: ' +  self.DisplayName, 'kondrickova@lipoelastic.sk;zorlikova@lipoelastic.sk;kdivinska@lipoelastic.sk', '','','3130000101', Blat_File,'1N00000101',self);
                                                                  //NxShowSimpleMessage('email odeslán ' + aname,nil);
                                                          except
                                                          end;
                                                       except
                                                       end;
                                                    finally
                                                        mPrintList.free;
                                                    end;
                                       //    end;
                                           //NxShowSimpleMessage(copy(mstring,15,10), nil);


//                                          mString:= APICallRest(self,'Post',mtarget,'/issuedorder/import/receivedorders/' + mDoc_ID +'?select=id,displayname','',mQueryID,false);



                                    //NxShowSimpleMessage('update issuedorders set X_SendDate$Date = ' +NxFloatToIBStr(now()) + ' where id=' + quotedstr(self.oid),nil);

                                     mi:=self.ObjectSpace.SQLExecute('update issuedorders set X_SendDate$Date = ' +NxFloatToIBStr(now()) + ',Issued=' + quotedstr('A') + '  where id=' + quotedstr(self.oid));
                                     if trim(self.GetFieldValueAsString('X_ExternalDocument'))='' then begin
                                           if mExtNumber<>'' then begin
                                               mi:=self.ObjectSpace.SQLExecute('update issuedorders set X_ExternalDocument =' + quotedstr(mExtNumber) + ' where id=' + quotedstr(self.oid));
                                           end;
                                     end;
                                     //self.SetFieldValueAsDateTime('X_SendDate$Date',now());
                                     //self.save;
                                     TDynSiteForm(mSite).ActiveDataSet.RefreshCurrentItem;
                                     //msite.Refresh;
                                     //mDBGrid.Refresh;
                                      end;

                      end;
                      if mBookmark.count>0 then  ProgressDispose()   ;
                end;
            end;
    end;

     nxshowsimplemessage('Synchronizace dokončena' + mdocnumber ,nil);

end;

procedure FormCreate_Hook(Self: TSiteForm);
var
  mAction: TAction;
  mMAction: TMultiAction;
begin
  mMAction := Self.GetNewMultiAction;
  mMAction.ShowControl := True;
  mMAction.ShowMenuItem := True;
  mMAction.Caption := 'Objednávka výroby do SK';
  mMAction.Hint := 'Odeslání OV výroby do SK';
  mMAction.Category := 'tabList';
  mMAction.Items.Add('SK - vytvoření OP s(bez) šarží ');
//  mMAction.Items.Add('SK - Objednávky vydamá');
//  mMAction.Items.Add('Lipoelastik SK PR ');
//  mMAction.Items.Add('Lipoelastik SK DL ');
//  mMAction.Items.Add('Lipoelastik CZ test ');
  mMAction.OnExecuteItem := @Synchronizace;

//  mMAction := Self.GetNewMultiAction;
//  mMAction.ShowControl := True;
//  mMAction.ShowMenuItem := True;
//  mMAction.Caption := 'Tisk objednávky z SK';
//  mMAction.Hint := 'Tisk objednávkky z SK';
//  mMAction.Category := 'tabList';
//  mMAction.Items.Add('Tisk Objednávky z SK ');
//  mMAction.Items.Add('SK - Objednávky vydamá');
//  mMAction.Items.Add('Lipoelastik SK PR ');
//  mMAction.Items.Add('Lipoelastik SK DL ');
//  mMAction.Items.Add('Lipoelastik CZ test ');
//  mMAction.OnExecuteItem := @Print_document;


end;




begin
end.


