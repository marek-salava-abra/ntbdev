uses  '_Knihovny_ALL.Progress',
      '_Knihovny_ALL.Parse',
      'Synchronizace.API' ,
      'Synchronizace.Query_DefrollData';

const
mTable='StoreCards';
mApiTable='StoreCards';
var
mQuery:string;



function GetOrCreateAPI(mBO:TNxCustomBusinessObject;xsite: TBusRollSiteForm;index:integer): string;
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
  mJSON: TJSONSuperObject;
begin
 result:='';
   mTargetList:=tstringlist.create;
    TRY
        //  mTargetList:=CreateTargetList;

   // for i:=0 to mTargetList.count-1 do begin // ****cyklus pro jednotlicá spojení
        if index=0 then begin
             mTarget:=mTargetAPI + '/';

          if mTarget<>msource then begin
                     mQuery:='{}';

                    //  NxShowSimpleMessage(mQuery,nil) ;
                      // *** dohledání záznamu v cílové databázi
                        mQueryID:='{'
                              + ' "class": "' + 'StoreSubCards' +'",'
                              +' "select": ["sum(quantity)",],'
                              + ' "where": " StoreCard_ID = ' + QuotedStr(mBO.GetFieldValueAsString('ID'))
                              +' " '
                              +'}';
                              mString:= APICallRest(mBO,'Post',mtarget,'query','',mQueryID,true);


                             if (copy(mString,1,3)='200') or (copy(mString,1,3)='201') then begin

                             mString:=copy(mstring,25,20);
                             mString:= copy(mstring,1, Length(mstring)-7);


                            // NxShowSimpleMessage('Dohledán ' +  mString ,nil);

                             mbo.SetFieldValueAsFloat('X_SK_quantity', NxIBStrToFloat(mstring))  ;
                             mbo.save;
          end;



 //
 // mJSON := TJSONSuperObject.create;
 //
 // try
 //         mJSON:= APICallRestJSON(mBO,'Post',mtarget,'query','',mQueryID,true);
 //
 //        NxShowSimpleMessage('Dohledán ' +  mJSON.AsString,nil);
  //   mJSON.S['Quantity'];     // -> vrati retezec 'Praha'
 // finally
 //   mJSON.Free;
 // end;
  //


















                                             mID:= copy(mString,15,10);
                                             //NxShowSimpleMessage('doklad ' + mDoc_ID,nil);
                                             mIKUprave:=mIKUprave + 1;
//                                    end;
                              end else begin
                                        //NxShowSimpleMessage('Chyba v přístupu k api' + mString,nil);
                                        iSendmsgx(xsite.BaseObjectSpace,
                                                 ' API Error ' + mtable ,     // popis
                                                  mString  + '      Post'+mtarget+'query'+''+mQueryID,                          // tělo
                                                  mToMSG ,                      // komu
                                                  xsite.SiteContext.GetCompanyCache.GetUserID); // kdo
                                        mID:='';
                                        //exit;
                              end;


          end;
  //  end;
    finally
      mTargetList.free;
    end;
end;







procedure _AfterSave_PostHook(xsite: TRollSiteForm);
var
  mID:string;
begin
 //  mid:=GetOrCreateAPI(TDynSiteForm(xsite).CurrentObject,xsite);
end;



{
Vyvolává se při ukládání vlastností formuláře.
}
procedure SavingProperties_Hook(Self: TSiteForm; AParams: TNxParameters);
begin
  //NxShowSimpleMessage('AA',nil);
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
  mINovych:=0;
  mIKuprave:=0;
  mIUpravenych:=0;
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
                          if index = 0 then mid:=GetOrCreateAPI(TBusRollSiteForm(mSite).CurrentObject,TBusRollSiteForm(mSite),index);
                          if index = 1 then begin
                              //TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsFloat('Quantity', 0)  ;
                              TBusRollSiteForm(mSite).CurrentObject.save;
                          end;
                          //TDynSiteForm(mSite).ActiveDataSet.RefreshCurrentItem;
                      end;
                      if mBookmark.count>0 then  ProgressDispose()   ;
                end;
            end;
    end;

     if mINovych+mIKuprave+mIUpravenych>0 then begin
         //NxShowSimpleMessage('Počet nových záznamů: ' + inttostr(mINovych)  ,nil);
     end;
    TBusRollSiteForm(msite).Refresh;
end;


procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TAction;
  mMAction: TMultiAction;
   mUser: TNxCustomBusinessObject;
begin
  mUser := TBusRollSiteForm(Self).BaseObjectSpace.CreateObject('22AHIVDVAVE13C5S00CA141B44');            // přihlášený uživatel
  try
      mUser.Load(TBusRollSiteForm(Self).CompanyCache.GetUserID, nil);

    if copy(muser.GetFieldValueAsString('X_Button_parametr'),8,1)='1' then begin    // hromadná změna stavu
              mMAction := Self.GetNewMultiAction;
              mMAction.ShowControl := True;
              mMAction.ShowMenuItem := True;
              mMAction.Caption := 'Aktualizace množství z SK';
              mMAction.Hint := 'Aktualizace množství z SK';
              mMAction.Category := 'tabList';
              mMAction.Items.Add('Aktualizace množství sk ');
              mMAction.Items.Add('Smazání množství SK ');
              mMAction.OnExecuteItem := @Synchronizace;
    end;
  finally
    muser.free;
  end;
end;



begin
end.