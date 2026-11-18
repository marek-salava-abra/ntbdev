uses  '_Knihovny_ALL.Progress',
      '_Knihovny_ALL.Parse',
      'Synchronizace.API' ;

const
mTable='PLMWorkPlaces';
mApiTable='PLMWorkPlaces';

var
mQuery:string;




function GetQueryBO(self:TNxCustomBusinessObject;Itarget:integer;): string;
var
I:integer;
begin
    mQuery:='{'   ;
                  mquery:=mquery + '"id": "' +  Self.OID +'"'  ;
                  mquery:=mquery + ', "Code":"' +  Self.GetFieldValueAsString('Code') +'" ';
                  mquery:=mquery + ', "Name":"' +  Self.GetFieldValueAsString('Name') +'" ';
                  mquery:=mquery + ', "Hidden": '  +  BoolToStr(Self.GetFieldValueAsBoolean('Hidden')) +' ' ;
                  mquery:=mquery + ', "Division_ID":"' +  Self.GetFieldValueAsString('Division_ID') +'" ';
                  mquery:=mquery + ', "ShiftCalendar_ID":"' +  Self.GetFieldValueAsString('ShiftCalendar_ID') +'" ';
                  mquery:=mquery + ', "HourlyRate":' +  NxFloatToIBStr(Self.GetFieldValueAsFloat('HourlyRate')) +' ';
                  mquery:=mquery + ', "Capacity":' +  NxFloatToIBStr(Self.GetFieldValueAsFloat('Capacity')) +' ';
                  mquery:=mquery + ', "BatchSize":' +  NxFloatToIBStr(Self.GetFieldValueAsFloat('BatchSize')) +' ';
                  mquery:=mquery + ', "MachineCount":' +  NxFloatToIBStr(Self.GetFieldValueAsFloat('MachineCount')) +' ';
                  mquery:=mquery + ', "CRPGrain":' +  NxFloatToIBStr(Self.GetFieldValueAsFloat('CRPGrain')) +' ';
                  mquery:=mquery + ', "BatchBuffer":' +  IntToStr(Self.GetFieldValueAsInteger('BatchBuffer')) +' ';
                  mquery:=mquery + ', "CRPPlan":' +  IntToStr(Self.GetFieldValueAsInteger('CRPPlan')) +' ';
                  mquery:=mquery + ', "WorkplaceType":' +  IntToStr(Self.GetFieldValueAsInteger('WorkplaceType')) +' ';
                mquery:=mquery +'}';


         result:=mQuery;
end;


function GetNewQuery(self:TNxCustomBusinessObject;iTarget:integer): string;
var
I:integer;
mMon:TNxCustomBusinessMonikerCollection;
mNewQueryID:string;
begin
    mNewQueryID:='{"info_type": "New_value" '
                                     +','+' "mSQL": "INSERT INTO ' + mtable + ' (Code,Name,ID,Division_ID,Hidden) VALUES (' +
                                            quotedstr(Self.GetFieldValueAsString('Code'))
                                            + ','+ quotedstr(Self.GetFieldValueAsString('Name'))
                                            + ','+ quotedstr(Self.OID)
                                            + ','+ quotedstr(Self.GetFieldValueAsString('Division_ID'))
                                            + ','+ quotedstr('N')
                                            + ')"}';
         result:=mNewQueryID;
end;






function GetOrCreateAPI(mBO:TNxCustomBusinessObject;xsite: TRollSiteForm;mICount:integer;index:integer): string;
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
  mboolean:boolean;
begin
 result:='';
   mTargetList:=tstringlist.create;
    TRY
          mTargetList:=TStringList.create;
          xsite.BaseObjectSpace.SQLSelect('SELECT X_CLSID FROM DefRollData A WHERE (A.Hidden = '+quotedstr('N') + ' ) AND (A.CLSID = '+ quotedstr('C2HCXLEGT5H4340LIKNWZLXHI0') + ' ) AND (X_Parent_ID=' +quotedstr('AbraApi') +')',mTargetList);

       //NxShowSimpleMessage(IntToStr(mTargetList.count),nil);
    for i:=0 to mTargetList.count-1 do begin // ****cyklus pro jednotlicá spojení
                mTarget:=mTargetList.strings[i];
          if mTarget<>msource then begin
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
//                                    NxShowSimpleMessage('Dohledán ' + copy(mString,15,10),nil);
//                                    if copy(mString,9,2)='ID' then begin      // záznam namezen
                                             mID:= copy(mString,15,10);
                                             //NxShowSimpleMessage('doklad ' + mDoc_ID,nil);
//                                    end;
                              end else begin
                                        //NxShowSimpleMessage('Chyba v přístupu k api' + mString,nil);
                                       // iSendmsg(xsite.BaseObjectSpace,
                                      //           ' API Error ' + mtable ,     // popis
                                      //            mString  + '      Post'+mtarget+'query'+''+mQueryID,                          // tělo
                                      //            mToMSG ,                      // komu
                                      //            xsite.SiteContext.GetCompanyCache.GetUserID); // kdo
                                        mID:='';
                                        //exit;
                              end;

                        IF mid='' THEN BEGIN
                            //NxShowSimpleMessage('Nový záznam se stejným ID',nil);
                                 mNewQuery:=GetNewQuery(mBO,i);

                           if (xSite.CompanyCache.GetUserID='SUPER00000') and (mICount=0)  and (index=1) then
                                                                mboolean:=InputQuery('API','POST  - založení ID',mtarget+'/script/Synchronizace/API/NewValueWithID' + Chr(10) + chr(10) +mNewQuery);
                                 mString:=ApiCallNewValue(mBO,'POST',mtarget+'/script/Synchronizace/API/NewValueWithID',mNewQuery, true);


                                 if (copy(mString,1,3)='201') or (copy(mString,1,3)='200') or (copy(mString,1,3)='204')then begin

                                  end else begin
                                            //NxShowSimpleMessage('Chyba v přístupu k api' + mString,nil);
                                          //  iSendmsg(xsite.BaseObjectSpace,
                                          //       ' API Error ' + mApiTable,     // popis
                                          //        mString  + '      POST' +mtarget+'script/Synchronizace/API/NewValueWithID'+mNewQueryID,                          // tělo
                                          //        mToMSG ,                      // komu
                                          //        xsite.SiteContext.GetCompanyCache.GetUserID); // kdo
                                  //          mID:='';
                                            //exit;
                                  end;
                                mid:= mBO.oid;

                         end;




                              if (xSite.CompanyCache.GetUserID='SUPER00000') and (mICount=0) and (index=1) then
                                                                mboolean:=InputQuery('API','PUT  - doplnění a aktualizace',mtarget+'/'+mApiTable+'/' + mid + Chr(10) + chr(10) +mQuery);
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
                                       // iSendmsg(xsite.BaseObjectSpace,
                                       //          ' API Error ' + mApiTable,     // popis
                                       //           mString  + '      PUT' +mtarget+mtarget+mApiTable+'/' + mid +mQuery,                          // tělo
                                       //           mToMSG ,                      // komu
                                       //           xsite.SiteContext.GetCompanyCache.GetUserID); // kdo
                                        mID:='';
                                        //exit;
                              end;

                  end;
                  end;
    finally
     // mTargetList.free;
    end;
end;







procedure _AfterSave_PostHook(xsite: TRollSiteForm);
var
  mID:string;
begin
   mid:=GetOrCreateAPI(TBusRollSiteForm(xsite).CurrentObject,xsite,0,0);
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
  mPocet:integer;
begin
  mpocet:=0;
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
                           for mICount:=0 to mIBookmark do begin
                                if mBookmark.count>0 then begin
                                     mDBGrid.DataSource.DataSet.GotoBookmark(mBookMark.items(mICount));
                                     ProgressSetPos(1+NxFloor(mICount/mBookmark.Count*99), inttostr(mICount) +' z '+inttostr(mBookmark.Count));
                                end;
                           // ******** zpracování dat
                          mid:=GetOrCreateAPI(TBusRollSiteForm(mSite).CurrentObject,TBusRollSiteForm(mSite),mICount,index);
                          mpocet:=mpocet+1;
                      end;
                      if mBookmark.count>0 then  ProgressDispose()   ;
                      end else begin
                           mid:=GetOrCreateAPI(TBusRollSiteForm(mSite).CurrentObject,TBusRollSiteForm(mSite),mICount,index);
                           mpocet:=mpocet+1;
                      end;


                end;
            end;
    end;

NxShowSimpleMessage('Synchronizací bylo přeneseno ' + IntToStr(mpocet) + ' záznamů', nil);

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





