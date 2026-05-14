uses  '_Knihovny_ALL.Progress',
      '_Knihovny_ALL.Parse',
      'Synchronizace.API' ;

const
mTable='PLMPictures';
mApiTable='PLMPictures';

var
mQuery:string;



function GetQueryBO(self:TNxCustomBusinessObject;Itarget:integer;): string;
var
I:integer;
begin
     mQuery:='{}';

                   mQuery:='{}';

                  mQuery:='{'   ;
                  //mquery:=mquery + '"id": "' +  Self.OID +'"'  ;
                  mquery:=mquery + ' "Name":"' +  Self.GetFieldValueAsString('Name') +'" ';
                  mquery:=mquery + ', "Picture_ID":"' +  Self.GetFieldValueAsString('Picture_ID') +'" ';
                  mquery:=mquery + ', "X_ref_ID":"' +  Self.GetFieldValueAsString('X_ref_ID') +'" ';
                                     mquery:=mquery + '}' ;
//                  mquery:=mquery + ', "X_SK_Nazev":"'  +  Self.GetFieldValueAsString('X_SK_Nazev') +'" ' ;

         result:=mQuery;

end;

function GetNewQuery(self:TNxCustomBusinessObject;iTarget:integer): string;
var
I:integer;
mMon:TNxCustomBusinessMonikerCollection;
mNewQueryID:string;
begin
     mNewQueryID:='{"info_type": "New_value" '
                                     +','+' "mSQL": "INSERT INTO ' + mtable + ' (Name,ID,X_ref_ID) VALUES (' +
                                            quotedstr(Self.GetFieldValueAsString('Name'))
                                            + ','+ quotedstr(Self.OID)
                                            + ','+ quotedstr(Self.GetFieldValueAsString('X_ref_ID'))
                                            + ')"}';
   result:=mNewQueryID;
end;





function GetOrCreateAPI(mBO:TNxCustomBusinessObject;xsite: TRollSiteForm;mICount:integer): string;
var
  mQueryID:string;
  mID:string;
  mNewQueryID:string;
  mSQL:string;
  i,ii,iii:integer;
  mTarget:string;
  mr1:tstringlist;
  astring:string;
  mr:TStringList;
  mString:string;
  mNewQuery:string;
  mParentBO:TNxCustomBusinessObject;
  mBoolean:boolean;
begin
 result:='';
  mTargetList:=tstringlist.create;
    TRY
    //mTargetList.add('http://10.5.5.96:809/CZ_PRE_produkce/');
    mTargetList.Add(mTargetAPI + '/');

    for i:=0 to mTargetList.count-1 do begin // ****cyklus pro jednotlicá spojení
                mTarget:=mTargetList.strings[i];
          //if copy(mBO.GetFieldValueAsString('X_synchronizace_ID'),i+1,1)='1' then begin
          if mTarget<>msource then begin



                    mID:='';
                    // vlastní záznam
                     mQuery:='{}';





                    //  NxShowSimpleMessage(mQuery,nil) ;
                      // *** dohledání záznamu v cílové databázi
                        mQueryID:='{'
                              + ' "class": "' + mApiTable +'",'
                              +' "select": ["ID",],'
                              + ' "where": " id = ' + QuotedStr(mBO.OID)
                              +' " '
                              +'}';
                              mString:= APICallRest(mBO,'Post',mtarget,'query','',mQueryID,true);

                             // NxShowSimpleMessage('ID ' + '{'
                             // + ' "class": "' + mApiTable +'",'
                             // +' "select": ["ID",],'
                             // + ' "where": " id = ' + QuotedStr(mBO.OID)
                             // +' " '
                             // +'}',nil);


                             if (copy(mString,1,3)='200') or (copy(mString,1,3)='201') then begin
//                                    NxShowSimpleMessage('Dohledán ' + copy(mString,15,10),nil);
                                    if copy(mString,9,2)='ID' then begin      // záznam namezen
                                             mID:= copy(mString,15,10);
                                             //NxShowSimpleMessage('doklad ' + mDoc_ID,nil);
                                    end;
                              end else begin
                                        //NxShowSimpleMessage('Chyba v přístupu k api' + mString,nil);
                                        iSendmsgy(xsite.BaseObjectSpace,
                                                 ' API Error ' + mtable ,     // popis
                                                  mString  + '      Post'+mtarget+'query'+''+mQueryID,                          // tělo
                                                  mToMSG ,                      // komu
                                                  xsite.SiteContext.GetCompanyCache.GetUserID); // kdo
                                        mID:='';
                                        //exit;
                              end;

                               mQuery:=GetQueryBO(mBO,i);

                        IF mID='' THEN BEGIN
                            //NxShowSimpleMessage('Nový záznam se stejným ID',nil);
                                 mNewQuery:=GetNewQuery(mBO,i);
                                 mString:=ApiCallNewValue(mBO,'POST',mtarget+'script/Synchronizace/API/NewValueWithID',mNewQuery, true);

                                   if (xSite.CompanyCache.GetUserID='SUPER00000') and (mICount=0) then
                                                                mboolean:=InputQuery('API','post doklad',mtarget+'script/Synchronizace/API/NewValueWithID' + '     ' + mNewQuery);



                                 if (copy(mString,1,3)='201') or (copy(mString,1,3)='200') or (copy(mString,1,3)='204')then begin

                                  end else begin
                                            //NxShowSimpleMessage('Chyba v přístupu k api' + mString,nil);
                                            iSendmsgy(xsite.BaseObjectSpace,
                                                 ' API Error ' + mApiTable,     // popis
                                                  mString  + '      POST' +mtarget+'script/Synchronizace/API/NewValueWithID'+mNewQueryID,                          // tělo
                                                  mToMSG ,                      // komu
                                                  xsite.SiteContext.GetCompanyCache.GetUserID); // kdo
                                  //          mID:='';
                                            //exit;
                                  end;
                                mid:= mBO.oid;

                         end;




                             // mstring:=                      inputbox('BO - plné data','Put',mtarget+mApiTable+'/' + mid + '       ' + mQuery)    ;


                             if (xSite.CompanyCache.GetUserID='SUPER00000') and (mICount=0) then begin
                                    mQuery:= APICallRest(mBO,'GET',msource,'Pictures','/' + mbo.GetFieldValueAsString('Picture_ID') ,'{}',true);  // načtení záznamu
                                    mboolean:=InputQuery('API','GET doklad','Get '+msource + 'Pictures'+'/' + mbo.GetFieldValueAsString('Picture_ID')  + '              ' + mQuery)  ;
                                    //mboolean:=InputQuery('API','GET doklad','Get '+mtarget + mApiTable+'/' + mid  + '              ' + mQuery)  ;
                             end;

                              mString:= APICallRest(mBO,'PUT',mtarget,mApiTable,'/' + mid ,mQuery,true);  // načtení záznamu


                              if (copy(mString,1,3)='201') or (copy(mString,1,3)='200') or (copy(mString,1,3)='204')then begin
                                //NxShowSimpleMessage('Aktualizace max ' + mtable +  '  ' + copy(mString,15,10),nil);
                                //if copy(mString,9,2)='ID' then begin      // záznam namezen
                                         mID:= copy(mString,15,10);
                                         //NxShowSimpleMessage('doklad ' + mDoc_ID,nil);
                                         result:=mbo.oid;
                                //end;
                              end else begin
                                        //NxShowSimpleMessage('Chyba v přístupu k api' + mString,nil);
                                        iSendmsgy(xsite.BaseObjectSpace,
                                                 ' API Error ' + mApiTable,     // popis
                                                  mString  + '      PUT' +mtarget+mtarget+mApiTable+'/' + mid +mQuery,                          // tělo
                                                  mToMSG ,                      // komu
                                                  xsite.SiteContext.GetCompanyCache.GetUserID); // kdo
                                        mID:='';
                                        //exit;
                              end;

                  end;
                  end;
    finally
   //   mTargetList.free;
    end;
end;







procedure _AfterSave_PostHook(xsite: TRollSiteForm);
var
  mID:string;
begin
   mid:=GetOrCreateAPI(TBusRollSiteForm(xsite).CurrentObject,xsite,0);
end;



 procedure Synchronizace(Sender: TObject;index:integer);
var
  mSite: TSiteForm;
  mDBGrid : TDBGrid;
 mTabList: TTabSheet;
  mBookmark : TBookmarkList;
  mIBookmark:integer;
  mICount:integer;
  mID:string;
  mr:tstringlist;
  mBO:TNxCustomBusinessObject;
begin
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
                      if index<2 then begin
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
                                   // ******** zpracování dat
                                  mid:=GetOrCreateAPI(TBusRollSiteForm(mSite).CurrentObject,TBusRollSiteForm(mSite),mICount);

                              end;
                              if mBookmark.count>0 then  ProgressDispose()   ;
                      end else begin
                          mr:=TStringList.create;
                          try
                               msite.BaseObjectSpace.SQLSelect('select id from ' + mtable  ,mr);
                               if mr.count>0 then begin
                                    ProgressInit(msite, 'Zpracování dat ' + '', 100);
                                    mbo:=TBusRollSiteForm(msite).CurrentObject;
                                    try
                                          for mICount:=0 to mr.count-1 do begin
                                               ProgressSetPos(1+NxFloor(mICount/mr.Count*99), inttostr(mICount) +' z '+inttostr(mr.Count));
                                               mbo.load(mr.Strings[mICount],nil);
                                                  mid:=GetOrCreateAPI(mbo,TBusRollSiteForm(mSite),mICount);
                                          end;
                                    finally
                                       mbo.free;
                                    end;
                                    ProgressDispose()
                               end;

                          finally
                              mr.free;
                          end;
                      end;
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
  mMAction.Caption := 'Synchronizace def new ';
  mMAction.Hint := 'Synchronizace s ostatními abrami';
  mMAction.Category := 'tabList';
  mMAction.Items.Add('Základní s ID ');
  mMAction.Items.Add('Rozšířená ');
  mMAction.Items.Add('Kompletní ( i skryté) ');
  mMAction.OnExecuteItem := @Synchronizace;

end;



procedure _xAfterDelete_Hook(xsite: TBusRollSiteForm);
var
  aString:string;
  mstring:string;
  ARequest:string;
  mSite:TSiteForm;
  mQuery,mQueryID:string;
  mID:string;
  mNewQueryID:string;
  mSQL:string;
  i:integer;
  mTarget:string;
  mbo:TNxCustomBusinessObject;
begin
   //NxGetUserName='mskacel' then begin
   mbo:=TBusRollSiteForm(xsite).CurrentObject;
   mTargetList:=tstringlist.create;
    TRY
          mTargetList:=CreateTargetList;
          //  NxShowSimpleMessage(inttostr(mTargetList.count),nil) ;
          //             NxShowSimpleMessage(self.ObjectSpace.GetConnectionName,nil);
          for i:=0 to mTargetList.count-1 do begin // ****cyklus pro jednotlicá spojení
                      mTarget:=mTargetList.strings[i];

                    mQueryID:='{'
                              + ' "class": "' + mApiTable +'",'
                              +' "select": ["ID",],'
                              + ' "where": " id = ' + QuotedStr(mBO.OID)
                              +' " '
                              +'}';
                              mString:= APICallRest(mBO,'Post',mtarget,'query','',mQueryID,true);


                             if (copy(mString,1,3)='200') or (copy(mString,1,3)='201') then begin
                                             mID:= copy(mString,15,10);

                              end else begin
                                        iSendmsgy(xsite.BaseObjectSpace,
                                                 ' API Error ' + mtable ,     // popis
                                                  mString  + '      Post'+mtarget+'query'+''+mQueryID,                          // tělo
                                                  mToMSG ,                      // komu
                                                  xsite.SiteContext.GetCompanyCache.GetUserID); // kdo
                                        mID:='';
                                        //exit;
                              end;

                          if mid<>'' then begin
                                   mString:= APICallRest(TBusRollSiteForm(Xsite).CurrentObject,'DELETE',mtarget,mApiTable,'/' + mid ,'{}',true);

                                    if (copy(mString,1,3)='200') or (copy(mString,1,3)='201') then begin
                                             mID:= copy(mString,15,10);

                                    end else begin
                                        iSendmsgy(xsite.BaseObjectSpace,
                                                 ' API Error ' + mtable ,     // popis
                                                  mString  + '      DELETE'+mtarget+mApiTable+'/' + mid +'{}',                          // tělo
                                                  mToMSG ,                      // komu
                                                  xsite.SiteContext.GetCompanyCache.GetUserID); // kdo
                                    end;
                          end;
          end;
    finally
      mTargetList.free;
    end;

end;


begin
end.































