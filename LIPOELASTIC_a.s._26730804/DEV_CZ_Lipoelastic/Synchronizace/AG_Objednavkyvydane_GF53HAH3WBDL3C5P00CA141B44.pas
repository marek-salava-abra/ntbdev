uses  '_Knihovny_ALL.Progress',
      '_Knihovny_ALL.Parse',
      'Synchronizace.API' ;

      const
mTable='IssuedOrders';
mApiTable='IssuedOrders';

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
                      for mICount:=0 to mIBookmark do begin
                          if mBookmark.count>0 then begin
                               mDBGrid.DataSource.DataSet.GotoBookmark(mBookMark.items(mICount));
                               ProgressSetPos(1+NxFloor(mICount/mBookmark.Count*99), inttostr(mICount) +' z '+inttostr(mBookmark.Count));
                          end;
                          self:=TDynSiteForm(msite).CurrentObject;    // načtení objektu
                          //NxShowSimpleMessage(IntToStr(index),nil);
                                     if true then begin //NxGetUserName='mskacel' then begin
                                     mDoc_ID:='';
                                                         if true then begin                     // načtení BO OV

                                                                            mTarget:=mTargetAPI + '/';

                                                                            if index=0 then begin
                                                                                   mQuery:=GetDocQuery(self,'A7N1000101','3010000101','','5131000101','5O10000101','RO')  ;
                                                                                   mString:= APICallRest(self,'POST',mtarget,'ReceivedOrders','?select=id',mQuery,true);  // odeslání OV
                                                                            end;
                                                                            if index=1 then begin
                                                                                   mQuery:=GetDocQuery(self,'D7N1000101','3010000101','','5131000101','5O10000101','IO')  ;
                                                                                   mString:= APICallRest(self,'POST',mtarget,'IssuedOrders','?select=id',mQuery,true);  // odeslání OV
                                                                            end;
                                                                            if index=2 then begin
                                                                                   mQuery:=GetDocQuery(self,'D7N1000101','3010000101','','5131000101','5O10000101','20')  ;
                                                                                   mString:= APICallRest(self,'POST',mtarget,'ReceiptCard','?select=id',mQuery,true);  // odeslání OV
                                                                            end;
                                                                            if index=3 then begin
                                                                                   mQuery:=GetDocQuery(self,'D7N1000101','3010000101','','5131000101','5O10000101','21')  ;
                                                                                   mString:= APICallRest(self,'POST',mtarget,'BillOfDelivery','?select=id',mQuery,true);  // odeslání OV
                                                                            end;

                                                                        //  if msite.SiteContext.GetCompanyCache.GetUserID='SUPER00000' then  mstring:= inputbox('OV','POST',mtarget+mApiTable+'' + '       ' + mQuery)    ;


                                                                            if (copy(mString,1,3)='201') then begin
                                                                                  //NxShowSimpleMessage('doklad ' + copy(mString,14,10),nil);
                                                                                  //if copy(mString,9,2)='ID' then begin      // záznam namezen
                                                                                           mDoc_ID:= copy(mString,14,10);
                                                                                           //NxShowSimpleMessage('doklad ' + mDoc_ID,nil);
                                                                                  //end;
                                                                            end else begin
                                                                                      NxShowSimpleMessage('Chyba v přístupu k api' + mString,nil);
                                                                                      //exit;
                                                                            end;

//if (msite.SiteContext.GetCompanyCache.GetUserID='SUPER00000') then begin
if true then begin
                                                      // *******  dotaz na šarží
    mMonRows := Self.GetLoadedCollectionMonikerForFieldCode(Self.GetFieldCode('ROWS'));
        for i := 0 to mMonRows.Count-1 do begin
            //NxShowSimpleMessage(' Řádek ' + mMonRows.BusinessObject[i].GetFieldValueAsString('ID'),nil);
            mr:=TStringList.create;
            try

                mSite.BaseObjectSpace.SQLSelect('Select id FROM DefRollData A WHERE (A.Hidden = ' + quotedstr('N') + ' ) AND (A.CLSID = ' + quotedstr('EC2R2HSFK5UOZ5MYVJWJOHUC4S') +
                                                ' ) AND (A.X_Parent_ID ) = ' + quotedstr(mMonRows.BusinessObject[i].GetFieldValueAsString('ID')),mr);

                if mr.count>0 then
                      if index=0 then mDocBatchRow:=msite.BaseObjectSpace.CreateObject('EC2R2HSFK5UOZ5MYVJWJOHUC4S');
                         try
                            for ii:=0 to mr.count-1 do begin
                                  mDocBatchRow.load(mr.Strings[ii],nil);
                                      //NxShowSimpleMessage(' Pohyb šarže ' + mDocBatchRow.GetFieldValueAsString('ID'),nil);

                                      mBatch_ID:='';
                                      mBatch_ID:=API_GetOrCreateBatch(mSite,mtarget,mDocBatchRow.GetFieldValueAsString('X_Batches'));
                                      //NxShowSimpleMessage('******* Šarže založena, ' + mBatch_ID , nil);


                                   if index=0 then begin   // ** objednávky vydané
                                        // ***   **** **** doplnění pohybu
                                      mDocRowOP_ID:='';
                                      mDocRowOP_ID:= API_GetOrCreateOPDocRowBatch(mSite,mtarget,mDoc_ID,mMonRows.BusinessObject[i],mBatch_ID,mDocBatchRow.GetFieldValueAsFloat('X_quantity'),index);
                                 //     NxShowSimpleMessage('******* Pohyb šarže založen, ' + mDocRowOP_ID , nil);
                                   end;

                                  if index=1 then begin   // ** objednávky vydané
                                //        // ***   **** **** doplnění pohybu
                                      mDocRowOV_ID:='';
                                      mDocRowOV_ID:= API_GetOrCreateOVDocRowBatch(mSite,mtarget,mDoc_ID,mMonRows.BusinessObject[i],mBatch_ID,mDocBatchRow.GetFieldValueAsFloat('X_quantity'),index);
                                //      NxShowSimpleMessage('******* Pohyb šarže založen, ' + mDocRowOV_ID , nil);
                                   end;

                            end;
                      finally
                         mDocBatchRow.free;
                      end;
            finally
                mr.free;

            end;
           if i=mMonRows.Count-1 then NxShowSimpleMessage('Doklad s šaržemi je synchronizován',nil);
        end;












end;
//                                                                             mTarget:=mTargetList.strings[i];
//                                                                                  mQueryID:='{ "class": "' + 'StoreBatches' +'", "select": ["ID",], "where": " Name = ' + QuotedStr(Self.GetFieldValueAsString('name') +'" }';
//
//                                                                                  mID:= copy(CallRestApi(Self,'Post',mtarget,'query','',mQueryID),9,10);
//



//




                                                                //  ********** pohyb šarže


//                                                                 mNewQueryID:='{'
//                                                                                  +' "hidden": false, '
//                                                                                  +'               "code": "", '
//                                                                                  +'               "name": "", '
//                                                                                  +'               "x_batches": "", '
//                                                                                  +'               "x_firm_id": "", '
//                                                                                  +'               "x_parent2_id": "", '
//                                                                                  +'               "x_parent_id": "", '
//                                                                                  +'               "x_quantity": 4, '
//                                                                                  +'               "x_storecard_id": "", '
//                                                                                  +'               "x_unit": "", '
//                                                                                  +'}';






                                                         end;

                                      end;

                      end;
                      if mBookmark.count>0 then  ProgressDispose()   ;
                end;
            end;
    end;

     nxshowsimplemessage('Import dokončen' ,nil);

end;

procedure FormCreate_Hook(Self: TSiteForm);
var
  mAction: TAction;
  mMAction: TMultiAction;
begin
  mMAction := Self.GetNewMultiAction;
  mMAction.ShowControl := True;
  mMAction.ShowMenuItem := True;
  mMAction.Caption := 'Odeslání OV obchodní do SK';
  mMAction.Hint := 'Odeslání obchodní OV do SK';
  mMAction.Category := 'tabList';
  mMAction.Items.Add('SK - vytvoření objednávky přijatá ');
//  mMAction.Items.Add('SK - Objednávky vydamá');
//  mMAction.Items.Add('Lipoelastik SK PR ');
//  mMAction.Items.Add('Lipoelastik SK DL ');
//  mMAction.Items.Add('Lipoelastik CZ test ');
  mMAction.OnExecuteItem := @Synchronizace;

end;




begin
end.


