  uses  '_Knihovny_ALL.Progress',
      '_Knihovny_ALL.Parse',
      'Synchronizace.API' ;

      const
mTable='IssuedInvoices';
mApiTable='IssuedInvoices';

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
 mMonRows:TNxCustomBusinessMonikerCollection;
 mMonBatches:TNxCustomBusinessMonikerCollection;
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

   if true then begin
   //NxGetUserName='mskacel' then begin
//   NxShowSimpleMessage('AAAA',nil);
   mTargetList:=tstringlist.create;
mMonRows := self.GetLoadedCollectionMonikerForFieldCode(self.GetFieldCode('ROWS'));
    TRY
          mTargetList:=CreateTargetList;

    for i:=0 to mTargetList.count-1 do begin // ****cyklus pro jednotlicá spojení
                mTarget:=mTargetList.strings[i];
          if true then begin // copy(self.GetFieldValueAsString('X_synchronizace_ID'),i+1,1)='1' then begin

                        //  NxShowSimpleMessage(inttostr(mTargetList.count),nil) ;
                        //             NxShowSimpleMessage(self.ObjectSpace.GetConnectionName,nil);
                     mQuery:='{}';

                     IF mManual then BEGIN                   // **** ruční vykopírování údajů
                        mQuery:='{'  ;
                        mQuery:=mQuery +'"ID": "' +                                    Self.OID +'", '                                                            ;
                          mQuery:=mQuery +'"Docqueue_ID": "' +                              Self.GetFieldValueAsstring('Docqueue_ID') +'", '                  ;
                          mQuery:=mQuery +'"tradetype": ' +                              IntToStr(Self.GetFieldValueAsInteger('tradetype')) +', '                  ;
                          mQuery:=mQuery +'"Firm_ID":"'  +                                  Self.GetFieldValueAsString('Firm_ID') +'", '                              ;
                          //NxShowSimpleMessage(copy(mTargetList.strings[i],21,1),nil);
                          mQuery:=mQuery +'"storedocqueue_id":"'  +          '8A10000101' + '", '                              ;

                          mQuery:=mQuery +'"Rows": [  ';
                        for i := 0 to mMonRows.Count-1 do begin
                                        mQuery:=mQuery +'{ ' ;
//                                        mQuery:=mQuery +'"id":"' +                            		  mMonRows.BusinessObject[i].GetFieldValueAsString('ID')+'", '   ;
                                        mQuery:=mQuery +'"PosIndex": ' +                            IntToStr(mMonRows.BusinessObject[i].GetFieldValueAsInteger('Posindex')) +', '                  ;
                                        mQuery:=mQuery +'"Rowtype": ' +                             IntToStr(mMonRows.BusinessObject[i].GetFieldValueAsInteger('Rowtype')) +', '                  ;
                                        mQuery:=mQuery +'"Text":"' +                            		mMonRows.BusinessObject[i].GetFieldValueAsString('Text')+'", ' ;
                                        mQuery:=mQuery +'"Store_ID":"' +                            mMonRows.BusinessObject[i].GetFieldValueAsString('Store_ID')+'", '   ;
                                        mQuery:=mQuery +'"Storecard_ID":"' +                        mMonRows.BusinessObject[i].GetFieldValueAsString('Storecard_ID')+'", '   ;

                                        mQuery:=mQuery +'"Quantity": ' +                            NxFloatToIBStr(mMonRows.BusinessObject[i].GetFieldValueAsFloat('Quantity')) +', '                  ;

                                        mQuery:=mQuery +'"Qunit":"' +                               mMonRows.BusinessObject[i].GetFieldValueAsString('Qunit')+'", '   ;

                                        mQuery:=mQuery +'"UnitPrice": ' +                           NxFloatToIBStr(mMonRows.BusinessObject[i].GetFieldValueAsFloat('UnitPrice')) +', '                  ;
                                        mQuery:=mQuery +'"TotalPrice": ' +                          NxFloatToIBStr(mMonRows.BusinessObject[i].GetFieldValueAsFloat('TotalPrice')) +', '                  ;

                                        mQuery:=mQuery +'"TAmount": ' +                             NxFloatToIBStr(mMonRows.BusinessObject[i].GetFieldValueAsFloat('TAmount')) +', '                  ;
                                        mQuery:=mQuery +'"TAmountWithoutVAT": ' +                   NxFloatToIBStr(mMonRows.BusinessObject[i].GetFieldValueAsFloat('TAmountWithoutVAT')) +', '                  ;

                                        mQuery:=mQuery +'"Division_ID":"' +                         mMonRows.BusinessObject[i].GetFieldValueAsString('Division_ID')+'", '   ;
                                        mQuery:=mQuery +'"BusOrder_ID":"' +                         mMonRows.BusinessObject[i].GetFieldValueAsString('BusOrder_ID')+'", '   ;
                                        mQuery:=mQuery +'"BusTransaction_ID":"' +                   mMonRows.BusinessObject[i].GetFieldValueAsString('BusTransaction_ID')+'", '   ;
                                        mQuery:=mQuery +'"BusProject_ID":"' +                       mMonRows.BusinessObject[i].GetFieldValueAsString('BusProject_ID')+'", '   ;


                                        mMonBatches:= mMonRows.BusinessObject[i].GetLoadedCollectionMonikerForFieldCode(mMonRows.BusinessObject[i].GetFieldCode('DocRowBatches'));

                                         mQuery:=mQuery +'"DocRowBatches": [  ';
                                                for ii := 0 to mMonBatches.Count-1 do begin
                                                     mQuery:=mQuery +'{ ' ;
                                                             mQuery:=mQuery +'"NewBatch":"' +                       mMonBatches.BusinessObject[ii].GetFieldValueAsString('NewBatch')+'", '   ;
                                                             mQuery:=mQuery +'"NewBatchName":"' +                       mMonBatches.BusinessObject[ii].GetFieldValueAsString('NewBatchName')+'", '   ;
                                                             mQuery:=mQuery +'"NewBatchComment":"' +                       mMonBatches.BusinessObject[ii].GetFieldValueAsString('NewBatchComment')+'", '   ;
                                                             mQuery:=mQuery +'"NewBatchSpecification":"' +                       mMonBatches.BusinessObject[ii].GetFieldValueAsString('NewBatchSpecification')+'", '   ;
                                                             mQuery:=mQuery +'"NewBatchExpirationDate":"' +                       mMonBatches.BusinessObject[ii].GetFieldValueAsString('NewBatchExpirationDate')+'", '   ;
                                                             mQuery:=mQuery +'"PosIndex":"' +                       mMonBatches.BusinessObject[ii].GetFieldValueAsString('PosIndex')+'", '   ;
                                                             mQuery:=mQuery +'"ProvideRowBatch_ID":"' +                       mMonBatches.BusinessObject[ii].GetFieldValueAsString('ProvideRowBatch_ID')+'", '   ;
                                                             mQuery:=mQuery +'"StoreBatch_ID ":"' +                       mMonBatches.BusinessObject[ii].GetFieldValueAsString('StoreBatch_ID ')+'", '   ;
                                                             mQuery:=mQuery +'"StoreSubBatch_ID ":"' +                       mMonBatches.BusinessObject[ii].GetFieldValueAsString('StoreSubBatch_ID ')+'", '   ;
                                                             mQuery:=mQuery +'"Quantity":"' +                       mMonBatches.BusinessObject[ii].GetFieldValueAsString('Quantity')+'", '   ;
                                                             mQuery:=mQuery +'"QUnit":"' +                       mMonBatches.BusinessObject[ii].GetFieldValueAsString('QUnit')+'", '   ;
                                                mQuery:=mQuery +' }, ';
                                                end;
                                        mQuery:=mQuery +' }, ';

                        end;

                               mQuery:=mQuery +' ] ';

                              mQuery:=mQuery +' } ';


                      end;

                    //  NxShowSimpleMessage(mQuery,nil) ;
                      // *** dohledání záznamu v cílové databázi
                        mQueryID:='{'
                              + ' "class": "' + mApiTable +'",'
                              +' "select": ["ID",],'
                              + ' "where": " id = ' + QuotedStr(Self.OID)
                              +' " '
                              +'}';
              //                NxShowSimpleMessage(mQueryID,nil);
//                              mID:= copy(CallRestApi(Self,'Post',mtarget,'query','',mQueryID),9,10);








                      mstring:=                      inputbox('Skladové karty - plné data','Put',mtarget+mApiTable+'/' + mid + '       ' + mQuery)    ;

//                             mString:= CallRestApi(self,'PUT',mtarget,mApiTable,'/' + mid ,mQuery);  // načtení záznamu
//                             mString:= CallRestApi(self,'POST',mtarget,mApiTable,'/' + mid ,mQuery);  // načtení záznamu




                  end;
                  end;
    finally
      mTargetList.free;
    end;

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
  mMAction.Caption := 'Synchronizace';
  mMAction.Hint := 'Synchronizace test';
  mMAction.Category := 'tabList';
  mMAction.Items.Add('SK ');
  mMAction.OnExecuteItem := @Synchronizace;

end;

begin
end.





