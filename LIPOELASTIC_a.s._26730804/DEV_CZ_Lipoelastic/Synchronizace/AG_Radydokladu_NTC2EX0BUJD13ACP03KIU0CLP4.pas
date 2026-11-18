uses  '_Knihovny_ALL.Progress',
      '_Knihovny_ALL.Parse',
      'Synchronizace.API' ;

const
mTable='DocQueues';
mApiTable='DocQueues';


var
mQuery:string;




function GetQueryBO(self:TNxCustomBusinessObject;Itarget:integer;): string;
var
I:integer;
begin
    mQuery:='{}';

                  mQuery:='{'   ;
                  mquery:=mquery + '"id": "' +  Self.OID +'"'  ;
                  mquery:=mquery + ', "Code":"' +  Self.GetFieldValueAsString('Code') +'" ';
                  mquery:=mquery + ', "Name":"' +  Self.GetFieldValueAsString('Name') +'" ';
                  mquery:=mquery + ', "hidden":'  + booltostr(Self.GetFieldValueAsBoolean('hidden')) +' ' ;
                  mquery:=mquery + ', "documenttype":"' +  Self.GetFieldValueAsString('documenttype') +'" ';
                  mquery:=mquery + ', "note":"' +  Self.GetFieldValueAsString('note') +'" ';
                  mquery:=mquery + ', "PrefixVar":"' +  inttostr(Self.GetFieldValueAsInteger('PrefixVar')) +'" ';
                mquery:=mquery + ', "toaccount":'  + booltostr(Self.GetFieldValueAsBoolean('toaccount')) +' ' ;
                mquery:=mquery + ', "x_delivery_id":"' +  Self.GetFieldValueAsString('x_delivery_id') +'" ';
                mquery:=mquery + ', "x_import_docqueue_id":"' +  Self.GetFieldValueAsString('x_import_docqueue_id') +'" ';
                mquery:=mquery + ', "x_issueddinvoice_id":"' +  Self.GetFieldValueAsString('x_issueddinvoice_id') +'" ';
                mquery:=mquery + ', "x_issuedinvoice_id":"' +  Self.GetFieldValueAsString('x_issuedinvoice_id') +'" ';
                mquery:=mquery + ', "x_prevodka_id":"' +  Self.GetFieldValueAsString('x_prevodka_id') +'" ';
                mquery:=mquery + ', "x_priceswithvat":'  + booltostr(Self.GetFieldValueAsBoolean('x_priceswithvat')) +' ' ;
                mquery:=mquery + ', "x_rada_zobrazovaci":"' +  Self.GetFieldValueAsString('x_rada_zobrazovaci') +'" ';
                mquery:=mquery + ', "x_receiptcard_id":"' +  Self.GetFieldValueAsString('x_receiptcard_id') +'" ';
                mquery:=mquery + ', "x_store_id":"' +  Self.GetFieldValueAsString('x_store_id') +'" ';
                mquery:=mquery + ', "x_stredisko":"' +  Self.GetFieldValueAsString('x_stredisko') +'" ';
                mquery:=mquery + ', "x_typ_pripadu":"' +  Self.GetFieldValueAsString('x_typ_pripadu') +'" ';
                mquery:=mquery + ', "x_use_box_number":'  + booltostr(Self.GetFieldValueAsBoolean('x_use_box_number')) +' ' ;
                mquery:=mquery + ', "X_StoreAccount_ID":"'  + Self.GetFieldValueAsString('X_StoreAccount_ID') +'" ' ;





//




//    mquery:=mquery + ', ""allowvarsymbolduplicates": false,
//    mquery:=mquery + ', ""autofillhole": true,
//
//    mquery:=mquery + ', ""createreservations": false,

//    mquery:=mquery + ', ""editextnumonrows": false,
//    mquery:=mquery + ', ""eetestablishment_id": null,
//    mquery:=mquery + ', ""expensetype_id": null,

//    mquery:=mquery + ', ""forceaccounting": false,


//    mquery:=mquery + ', ""incometype_id": null,
//    mquery:=mquery + ', ""lastnumbers": [],
//    mquery:=mquery + ', ""multireversegroupbysourcedoc": false,


//    mquery:=mquery + ', ""otherdocelectronicpayment": false,
//    mquery:=mquery + ', ""outofuse": true,
//    mquery:=mquery + ', ""prefillcurrencyfromfirm": true,
//    mquery:=mquery + ', ""prefixvar": 0,
//    mquery:=mquery + ', ""rowaccountusage": 0,
//    mquery:=mquery + ', ""rowaccountusageastext": "Nelze použít",
//    mquery:=mquery + ', ""singleaccdocqueue_id": {
//    mquery:=mquery + ', "    "accountwhere": true,
//    mquery:=mquery + ', "    "autofillhole": false,
//    mquery:=mquery + ', "    "code": "GPRZ",
//    mquery:=mquery + ', "    "documenttype": "00",
//    mquery:=mquery + ', "    "hidden": false,
//    mquery:=mquery + ', "    "id": "Y000000101",
//    mquery:=mquery + ', "    "lastnumbers": [],
//    mquery:=mquery + ', "    "name": "Zboží-příjemka na sklad        001/01",
//    mquery:=mquery + ', "    "note": "",
//    mquery:=mquery + ', "    "objversion": 3,
//    mquery:=mquery + ', "    "reverseaccounting": false,
//    mquery:=mquery + ', "    "reversedepositaccounting": false,
//    mquery:=mquery + ', "    "summaryaccounted": false
//    mquery:=mquery + ', "},
//    mquery:=mquery + ', ""storeclosingselectivevaluation": 0,
//mquery:=mquery + ', "}
                mquery:=mquery +'}';


         result:=mQuery;
end;

function GetNewQuery(self:TNxCustomBusinessObject;iTarget:integer): string;
var
I:integer;
mMon:TNxCustomBusinessMonikerCollection;
mNewQueryID:string;
begin
    mNewQueryID:='{"info_type": "New_value" '                                                                        //    mquery:=mquery + ', """: "1000000101",
                                     +','+' "mSQL": "INSERT INTO ' + mtable + ' (Code,Name,ID,hidden,documenttype,firstopenperiod_id,Lastopenperiod_id,note) VALUES (' +
                                            quotedstr(Self.GetFieldValueAsString('Code'))
                                            + ','+ quotedstr(Self.GetFieldValueAsString('Name'))
                                            + ','+ quotedstr(Self.OID)
                                            + ','+ quotedstr('N')
                                            + ','+ quotedstr(Self.GetFieldValueAsString('documenttype'))
                                            + ','+ quotedstr('2000000301')
                                            + ','+ quotedstr('2000000301')
                                            + ','+ quotedstr(Self.GetFieldValueAsString('note'))
                                            + ')"}';
result:=mNewQueryID;
end;






function GetOrCreateAPI(mBO:TNxCustomBusinessObject;xsite: TRollSiteForm): string;
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
begin
 result:='';
 mTargetList:=tstringlist.create;
    TRY
    mTargetList.add(mTargetDocumentAPI);


    for i:=0 to mTargetList.count-1 do begin // ****cyklus pro jednotlicá spojení
                mTarget:=mTargetList.strings[i];
          if copy(mBO.GetFieldValueAsString('X_synchronizace_ID'),i+1,1)='1' then begin
                     mQuery:='{}';

                     IF mManual then BEGIN                   // **** ruční vykopírování údajů
                            mQuery:=GetQueryBO(mBO,i);
                    end;

                    //  NxShowSimpleMessage(mQuery,nil) ;
                      // *** dohledání záznamu v cílové databázi
                        mQueryID:='{'
                              + ' "class": "' + mApiTable +'",'
                              +' "select": ["ID",],'
                              + ' "where": " id = ' + QuotedStr(mBO.OID)
                              +' " '
                              +'}';
                              mString:= APICallRest(mBO,'Post',mtarget,'query','',mQueryID,true);


                             if (copy(mString,1,3)='200') or (copy(mString,1,3)='201') then begin
//                                    if copy(mString,9,2)='ID' then begin      // záznam namezen
                                             mID:= trim(copy(mString,15,10));
                                             NxShowSimpleMessage('doklad ' + mID,nil);
//                                    end;
                              end else begin
                                        //NxShowSimpleMessage('Chyba v přístupu k api' + mString,nil);
                                        iSendmsgy(xsite.BaseObjectSpace,
                                                 ' API Error ' + mtable  + ' ' + mBO.OID + ' Find',     // popis
                                                  mString  + '      Post'+mtarget+'query'+''+mQueryID,                          // tělo
                                                  mToMSG ,                      // komu
                                                  xsite.SiteContext.GetCompanyCache.GetUserID); // kdo
                                        mID:='';
                                        //exit;
                              end;

                            IF mid='' THEN BEGIN
                                mNewQueryID:= GetNewQuery(mBO,i);


                             //   mString:=InputBox('','','POST'+mtarget+'script/Synchronizace/API/NewValueWithID     '  +mNewQueryID);

                                 mString:=ApiCallNewValue(mBO,'POST',mtarget+'script/Synchronizace/API/NewValueWithID',mNewQueryID, true);
                                 if (copy(mString,1,3)='201') or (copy(mString,1,3)='200') or (copy(mString,1,3)='204')then begin
                                    mINovych:=mINovych+1;
                                    //NxShowSimpleMessage('vytvořena SC ',nil);
                                    //if copy(mString,9,2)='ID' then begin      // záznam namezen
                                    //         mID:= copy(mString,15,10);
                                             //NxShowSimpleMessage('doklad ' + mDoc_ID,nil);
                                    //end;
                                  end else begin
                                            //NxShowSimpleMessage('Chyba v přístupu k api' + mString,nil);
                                            iSendmsgy(xsite.BaseObjectSpace,
                                                 ' API Error ' + mtable  + ' ' + mBO.OID + ' UPDATE',     // popis
                                                  mString  + '      POST' +mtarget+'script/Synchronizace/API/NewValueWithID'+mNewQueryID,                          // tělo
                                                  mToMSG ,                      // komu
                                                  xsite.SiteContext.GetCompanyCache.GetUserID); // kdo
                                  //          mID:='';
                                            //exit;
                                  end;


                                mid:= mBO.oid;

                         end;




                             // mstring:=                      inputbox('BO - plné data','Put',mtarget+mApiTable+'/' + mid + '       ' + mQuery)    ;



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
  //    mTargetList.free;
    end;
end;







procedure _AfterSave_PostHook(xsite: TRollSiteForm);
var
  mID:string;
begin
   mid:=GetOrCreateAPI(TBusRollSiteForm(xsite).CurrentObject,xsite);
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
                          mid:=GetOrCreateAPI(TBusRollSiteForm(mSite).CurrentObject,TBusRollSiteForm(mSite));

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
  mMAction.Hint := 'Synchronizace s ostatními abrami';
  mMAction.Category := 'tabList';
  mMAction.Items.Add('Základní s ID ');
  mMAction.Items.Add('Rozšířená ');
  mMAction.OnExecuteItem := @Synchronizace;

end;

begin
end.





