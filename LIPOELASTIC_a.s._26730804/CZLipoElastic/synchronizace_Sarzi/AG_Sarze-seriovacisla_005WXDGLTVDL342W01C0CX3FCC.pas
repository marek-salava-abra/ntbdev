  uses  '_Knihovny_ALL.Progress',
      '_Knihovny_ALL.Parse',
       '_Knihovny_ALL.VisualForms',
       'Synchronizace_dokladu_na_SK.API' ;



 procedure Checkbatchec(Sender: TObject;index:integer);
var
  mSite: TSiteForm;
  mDBGrid : TDBGrid;
 mTabList: TTabSheet;
  mObj, mObj2: TNxCustomBusinessObject;
  i: integer;
  mOLE, mRoll, mOResult: Variant;
  mid_reportx:tstringlist;
  mr,mr0:tstringlist;
  mBO:TNxCustomBusinessObject;
  mi:integer;
  mBookmark : TBookmarkList;
  mIBookmark:integer;
  mICount:integer;
  mids:string;
  mString:string;
   mform:TForm;
 result:integer;
 mMat1,mMat2,mMat3,mMat4,mMat5,mMat6:TRollComboEdit;
 mPMat1,mPMat2,mPMat3,mPMat4,mPMat5,mPMat6:TEdit;
 mBtn:TButton;
 mSMat1,mSMat2,mSMat3,mSMat4,mSMat5,mSMat6:String;
 mSPMat1,mSPMat2,mSPMat3,mSPMat4,mSPMat5,mSPMat6:string;
 mBatch_ID:string;
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
                            try
                                  if copy(TBusRollSiteForm(msite).CurrentObject.GetFieldValueAsString('StoreCard_ID.X_Synchronizace_ID'),3,1)='1' then begin
                                       if (TBusRollSiteForm(msite).CurrentObject.GetFieldValueAsDateTime('ExpirationDate$DATE'))>0  then begin
                                          mBatch_ID:=API_UpdateOrCreateBatch(mSite,mTargetDocumentAPI,TBusRollSiteForm(msite).CurrentObject);
                                       end;
                                  end;
                            finally

                            end;


                      end;
                      if mBookmark.count>0 then  ProgressDispose()   ;
                end;
            end;
    end;



end;




procedure FormCreate_Hook(Self: TSiteForm);
var
  mAction: TAction;
  mMAction: TMultiAction;
begin
  mMAction := Self.GetNewMultiAction;
  mMAction.ShowControl := True;
  mMAction.ShowMenuItem := True;
  mMAction.Caption := 'Synchronizace šarží';
  mMAction.Hint := 'Synchronizace šarží';
  mMAction.Category := 'tabList';
  mMAction.Items.Add('Synchronizace šarží');
  mMAction.OnExecuteItem := @Checkbatchec;



end;





function API_UpdateOrCreateBatch(mSite:TSiteForm;mApiTArget:string;mBatchBo:TNxCustomBusinessObject):string;
var
mQueryID:string;
mNewQueryID :string;
mString :string;
begin
result:='';
   mQueryID:='{ "class": "' + 'StoreBatches' +'", "select": ["ID",], "where": " Name = ' + QuotedStr(mBatchBo.GetFieldValueAsString('name')) +' and Storecard_ID=' +  QuotedStr(mBatchBo.GetFieldValueAsString('Storecard_ID')) + '" }';
                   mString:=APICallRest(mBatchBO,'Post',mApiTArget,'query','',mQueryID,True);
                   //NxShowSimpleMessage('AAA .' +copy(mString,10,2) +'.'+  copy(mString,15,10),nil);

                   mNewQueryID:='{'
                                            //+' "serialnumber": false, '
                                            //+'               "storecard_id": "' + mBatchBo.GetFieldValueAsString('storecard_id') + '", '
                                            //+'               "name": "' + mBatchBo.GetFieldValueAsString('name') + '", '
                                            +'               "specification": "' + mBatchBo.GetFieldValueAsString('specification') + '", '
                                            +'               "x_verze": "' + mBatchBo.GetFieldValueAsString('x_verze') + '", '
                                            +'               "ExpirationDate$DATE":"' +FormatDateTime('YYYY-MM-DD',mBatchBo.GetFieldValueAsDateTime('ExpirationDate$DATE')) +'", '
                                            +'               "productiondate$date":"' +FormatDateTime('YYYY-MM-DD',mBatchBo.GetFieldValueAsDateTime('productiondate$date')) +'", '

                                            //+'               "X_parent_ID": "' + mBatchBo.GetFieldValueAsString('X_parent_ID') + '", '
                                            //+'               "X_Specifikace_order": "' + mBatchBo.GetFieldValueAsString('X_Specifikace_order') + '", '
                                            +'               "X_MAT1": "' + mBatchBo.GetFieldValueAsString('X_MAT1') + '", '
                                            +'               "X_MAT2": "' + mBatchBo.GetFieldValueAsString('X_MAT2') + '", '
                                            +'               "X_MAT3": "' + mBatchBo.GetFieldValueAsString('X_MAT3') + '", '
                                            +'               "X_MAT4": "' + mBatchBo.GetFieldValueAsString('X_MAT4') + '", '
                                            +'               "X_MAT5": "' + mBatchBo.GetFieldValueAsString('X_MAT5') + '", '
                                            +'               "X_MAT1_PROC": "' + inttostr(mBatchBo.GetFieldValueAsInteger('X_MAT1_PROC')) + '", '
                                            +'               "X_MAT2_PROC": "' + inttostr(mBatchBo.GetFieldValueAsInteger('X_MAT2_PROC')) + '", '
                                            +'               "X_MAT3_PROC": "' + inttostr(mBatchBo.GetFieldValueAsInteger('X_MAT3_PROC')) + '", '
                                            +'               "X_MAT4_PROC": "' + inttostr(mBatchBo.GetFieldValueAsInteger('X_MAT4_PROC')) + '", '
                                            +'               "X_MAT5_PROC": "' + inttostr(mBatchBo.GetFieldValueAsInteger('X_MAT5_PROC')) + '", '
                                             +'}';







                   if (copy(mString,1,3)='200')  then begin      // korektní odpověď
                          if copy(mString,10,2)='ID' then begin      // záznam namezen
                                 {
                                   NxShowSimpleMessage('Šarže v cíli '  +  copy(mString,15,10),nil);
                                   iSendmsg(mSite.BaseObjectSpace,
                                                 ' API Error ' + 'Storebatches' ,     // popis
                                                  mString  + '      PUT'+mApiTArget+'StoreBatches/'+copy(mString,15,10)+''+mNewQueryID,                          // tělo
                                                  mToMSG ,                      // komu
                                                  mSite.SiteContext.GetCompanyCache.GetUserID); // kdo}
                                   mString:= APICallRest(mBatchBO,'PUT',mApiTArget,'StoreBatches/' + copy(mString,15,10),'' ,mNewQueryID,True);
                                   result:= copy(mString,15,10);



                            end;
                   end else begin

                   end;
end;





begin
end.












