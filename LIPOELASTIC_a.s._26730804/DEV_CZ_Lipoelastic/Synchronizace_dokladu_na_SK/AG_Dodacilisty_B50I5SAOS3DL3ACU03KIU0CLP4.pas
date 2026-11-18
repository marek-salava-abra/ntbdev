  uses  '_Knihovny_ALL.Progress',
      '_Knihovny_ALL.Parse',
      'Synchronizace_dokladu_na_SK.API' ;

      const
mTable='ReceivedOrders';
mApiTable='ReceivedOrders';

var
mSError :string;
mBoolean:boolean;

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
 mDocqueue_ID,mFirm_ID,mStore_ID,mdocnumber,mStorecard_ID,mDivision_ID:string   ;
 mBO:TNxCustomBusinessObject;
 mxa,mxb:tstringlist;
 mprice:double;
 mJson:TJSONSuperObject;
begin
  mdocnumber:='' ;
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
                                     if true then begin //NxGetUserName='mskacel' then begin
                                                  if index=0 then begin
                                                         //mbo:=TDynSiteForm(msite).CurrentObject;
                                                                      try
                                                                            mTarget:=mTargetAPI + '/';
                                                                            mSDocError:= CheckDocumentStorecard(TDynSiteForm(mSite).CurrentObject, mTarget) ;
                                                                                     if mSDocError<>'' then begin
                                                                                         mSError:=mSError+ mSDocError;
                                                                                     end;
                                                                                     if mSError='' then begin
                                                                                          //NxShowSimpleMessage('Test k synchronizaci doběhl',nil);
                                                                                      end else begin
                                                                                             mBoolean:=InputQuery('Doklad nejde synchronizovat', 'Problémové položky', mSError);
                                                                                             exit;
                                                                                      end;


                                                                            if self.getfieldvalueasstring('Docqueue_ID.code')<>'DVVS' then begin
                                                                                  mQuery:=GetDocQueryBatch(self,'20','G7N1000101','3010000101','','5131000101','5O10000101')  ;   //SPPV
                                                                                  mString:= CallRestApi(self,'POST',mtarget,'ReceiptCards','?select=displayname',mQuery);  // odeslání OV


                                                                                  //mJson := TJSONSuperObject.Create;
                                                                                  //mJson:= CallRestApiJSON(self,'POST',mtarget,'ReceiptCards','?select=displayname,id',mQuery);  // odeslání OV
                                                                                  //NxShowSimpleMessage(mJson.AsString,nil);
                                                                                  //mJson.free;



                                                                                  //if (copy(mString,1,3)='201') or (copy(mString,1,3)='200') then begin
                                                                                        //NxShowSimpleMessage('doklad ' + copy(mString,14,10),nil);
                                                                                        //if copy(mString,9,2)='ID' then begin      // záznam namezen
                                                                                                 //mdocnumber:=mdocnumber + ', ' + copy(mString,41,15);
                                                                                                 mdocnumber:=mdocnumber + ', ' + copy(mString,19,15);
                                                                                                 //mDoc_ID:= copy(mString,14,10);
                                                                                          //        mxid:=iSendMail(TDynSiteForm(msite).BaseObjectSpace, 'Byla synchronizována nová objenávka', 'Objednávka: ' + self.DisplayName , 'mskacel@lipoelastic.com;mskacel@lipoelastic.com', '','','2140000101', '' ,'1000000101','');

                                                                                                 //NxShowSimpleMessage('doklad ' + mDoc_ID,nil);
                                                                                        //end;
                                                                                //  end else begin
                                                                                           // NxShowSimpleMessage('Chyba v přístupu k api' + mString,nil);
                                                                                            // mstring:=                      inputbox('DL EXPORT PR new','POST',mtarget+'ReceiptCards'+'?select=displayname' + ' ' + mQuery)    ;
                                                                                            //exit;
                                                                                 // end;
                                                                                  //mQuery:='{"params":{"docqueue_id": "J7N1000101" } }';
                                                                            end else begin
                                                                                  // dvvs
                                                                                  mQuery:=GetDocQueryBatch(mbo,'20','H7N1000101','3010000101','','6131000101','5O10000101')  ;
                                                                                  mString:= CallRestApi(self,'POST',mtarget,'ReceiptCards','?select=id',mQuery);  // odeslání OV
                                                                                  mQuery:='{"params":{"docqueue_id": "H7N1000101" } }';
                                                                            end;

                                                                            //     mstring:=                      inputbox('DL','POST',mtarget+'ReceiptCards'+'?select=id' + ' ' + mQuery)    ;

                                                                            mString:= CallRestApi(self,'POST',mtarget,'ReceiptCards','?select=id',mQuery);  // odeslání OV
                                                                            //nxshowsimplemessage(copy(mstring,8,10),nil);




                                                                            mstring:=                      inputbox('DL import','POST',mtarget+'billsofdelivery'+'/import/ReceiptCards/'+copy(mstring,8,10) + '?select=id' + ' ' + mQuery)    ;

                                                                            mString:= CallRestApi(self,'POST',mtarget,'billsofdelivery','/import/ReceiptCards/'+copy(mstring,8,10) + '?select=id',mQuery);  // odeslání OV

                                                                      finally

                                                                      end;
                                                  end;
                                                  if index=1 then begin
                                                         //mbo:=TDynSiteForm(msite).CurrentObject;
                                                                      try
                                                                            mTarget:=mTargetAPI + '/';
                                                                            mSDocError:= CheckDocumentStorecard(TDynSiteForm(mSite).CurrentObject, mTarget) ;
                                                                                     if mSDocError<>'' then begin
                                                                                         mSError:=mSError+ mSDocError;
                                                                                     end;
                                                                                     if mSError='' then begin
                                                                                          //NxShowSimpleMessage('Test k synchronizaci doběhl',nil);
                                                                                      end else begin
                                                                                             mBoolean:=InputQuery('Doklad nejde synchronizovat', 'Problémové položky', mSError);
                                                                                             exit;
                                                                                      end;

                                                                            //mstring:=                      inputbox('DL import','POST',mtarget+'ReceiptCard'+'/import/Issuedinvoices/'+copy(mstring,8,10) + '?select=id' + ' ' + mQuery)    ;
                                                                            mQuery:='{"params":{"docqueue_id": "H7N1000101" } }';
                                                                            mString:= CallRestApi(self,'POST',mtarget,'ReceiptCard','/import/IssuedOrders/'+'2050000S01' + '?select=id',mQuery);  // odeslání OV
                                                                            mstring:=                      inputbox('PR import z OV','POST',mtarget+'ReceiptCard'+'/import/IssuedOrders/'+'2050000S01' + '?select=id' + ' ' + mQuery)    ;
                                                                      finally

                                                                      end;
                                                  end;





                                                  if index=2 then begin
                                                        mMonRows := self.GetLoadedCollectionMonikerForFieldCode(self.GetFieldCode('ROWS'));

                                                               mQueryID:='{'
                                                                                                  + ' "class": "' + 'StoreDocuments' +'",'
                                                                                                      +' "select": ["Parent_ID",],'
                                                                                                      + ' "where": " X_StoreDocuments2_ID = ' + QuotedStr(mMonRows.BusinessObject[0].oid)
                                                                                                      +' " '
                                                                                                      +'}';
                                                                                              mid:='';
                                                                                                mID:= copy(CallRestApi(Self,'Post',mTargetAPI + '/','query','',mQueryID),15,10);






                                                        mQuery:='{'  ;
                                                              // hlavička
                                                              mQuery:=mQuery +'"ID": "' +                                    mID +'", '  ;
                                                                  // řádky

                                                                  mQuery:=mQuery +'"Rows": [  ';
                                                                            for i := 0 to mMonRows.Count-1 do begin
                                                                                      mQueryID:='{'
                                                                                                  + ' "class": "' + 'StoreDocuments2' +'",'
                                                                                                      +' "select": ["ID",],'
                                                                                                      + ' "where": " X_StoreDocuments2_ID = ' + QuotedStr(mMonRows.BusinessObject[i].oid)
                                                                                                      +' " '
                                                                                                      +'}';
                                                                                              mid:='';
                                                                                                mID:= copy(CallRestApi(Self,'Post',mTargetAPI + '/','query','',mQueryID),25,10);



                                                                                            mQuery:=mQuery +'{ ' ;
                                                                                            mQuery:=mQuery +'"id":"' +                            		  mid+'", '   ;

                                                                                            mxa:=tstringlist.create;
                                                                                                     try
                                                                                                         self.ObjectSpace.SQLSelect('select ii2.TAmount/ii2.quantity from issuedinvoices2 ii2 join issuedinvoices ii on ii.id=ii2.parent_ID  where ProvideRow_ID =' + QuotedStr(mMonRows.BusinessObject[i].oid),mxa);
                                                                                                         if mxa.count>0 then begin
                                                                                                              mprice:=NxIBStrToFloat(mxa.Strings[0]);

                                                                                                         end else begin
                                                                                                              mxb:=tstringlist.create;
                                                                                                              try
                                                                                                                  self.ObjectSpace.SQLSelect('select ro2.TAmount/ro2.quantity from Receivedorders2 RO2 join Receivedorders RO on RO.id=RO2.parent_ID where ro2.ID =' + QuotedStr(mMonRows.BusinessObject[i].GetFieldValueAsString('ProvideRow_ID')),mxb);
                                                                                                                  if mxb.count>0 then begin
                                                                                                                          mprice:=NxIBStrToFloat(mxb.Strings[0]);

                                                                                                                  end;
                                                                                                              finally

                                                                                                              end;

                                                                                                         end;
                                                                                                     finally
                                                                                                         mxa.free;
                                                                                                     end;
                                                                                            mQuery:=mQuery +'"UnitPrice": ' +                           NxFloatToIBStr(mprice) +', '                  ;
                                                                                             mQuery:=mQuery +' }, ';
                                                                            end;
                                                                            mQuery:=mQuery +' ] ';
                                                                            mQuery:=mQuery +' }, ';



                                                       //                     NxShowSimpleMessage(mquery,nil); ;



                                                  end;
                                      end;

                      end;
                      if mBookmark.count>0 then  ProgressDispose()   ;
                end;
            end;
    end;

     nxshowsimplemessage('Import dokončen - ' + mdocnumber ,nil);

end;

procedure FormCreate_Hook(Self: TSiteForm);
var
  mAction: TAction;
  mMAction: TMultiAction;
begin
{  mMAction := Self.GetNewMultiAction;
  mMAction.ShowControl := True;
  mMAction.ShowMenuItem := True;
  mMAction.Caption := 'Synchronizace';
  mMAction.Hint := 'Synchronizace test';
  mMAction.Category := 'tabList';
  mMAction.Items.Add('Prijemka SK bez vazby');
  mMAction.Items.Add('Prijemka SK import z OV');
  mMAction.Items.Add('Aktualizace cen SK ');
  mMAction.OnExecuteItem := @Synchronizace;
 }
end;

begin
end.





















