uses  '_Knihovny_ALL.Progress',
      '_Knihovny_ALL.Parse',
      'Synchronizace.API';


function GetOrCreateAPIBatchCZ(mbo:TNxCustomBusinessObject;msite:TSiteForm;index:Integer):string;
var
mr:tstringlist;
mstring,mRow_ID:string;
mQueryID:string;
mCLSIDDocRow:string;
mApiTArget:string;
mboolean:Boolean;
mDoc_ID:string;
mBatch_ID:string;
mNewQueryID:string;
mCLSIDRowBatch:string;
begin
if index=0 then mApiTArget:=mSourceAPI+'/'  ;
if index=1 then mApiTArget:=mTargetAPI + '/'  ;
mCLSIDDocRow:='CHMK5QAWZZDL342X01C0CX3FCC';
mCLSIDRowBatch:='EC2R2HSFK5UOZ5MYVJWJOHUC4S' ;
      mr:=tstringlist.create;
      try
           mbo.ObjectSpace.SQLSelect('Select X_ProvideRow_ID from issuedorders2 where id=' + quotedstr(mbo.GetFieldValueAsString('X_Parent_ID') ),mr);
           if mr.count>0 then begin
                     // NxShowSimpleMessage('X_provideRow_ID' + mr.Strings[0],nil);
                       mQueryID:='{ "class": "' + mCLSIDDocRow +'", "select": ["ID","parent_ID"], "where": " X_ProvideRow_ID = ' + QuotedStr(mr.Strings[0]) +' and Storecard_ID=' +  QuotedStr(mbo.GetFieldValueAsString('X_Parent2_ID')) +'" }';
                      //    mboolean:=InputQuery('AA','AA', 'Post'+mApiTArget+'query'+''+mQueryID);
                               mString:=APICallRest(mbo,'Post',mApiTArget,'query','',mQueryID,True);

                               mString:=APICallRest(mbo,'Post',mApiTArget,'query','',mQueryID,True);
                             //  NxShowSimpleMessage('řádek cílového dokladu návrat api ' + mstring,nil);
                               if (copy(mString,1,3)='200')  then begin      // korektní odpověď
                                      if copy(mString,10,2)='ID' then begin      // záznam namezen

                                               mRow_ID:= copy(mString,15,10);
                                               mDoc_ID:= copy(mString,40,10);
                       //                        NxShowSimpleMessage('Dokument cílového z api dokladu' +mdoc_ID + ' - ' +  mRow_ID,nil);

                                            mBatch_ID:='';



                                            mBatch_ID:=API_GetOrCreateBatch(mSite,mApiTArget,mbo.GetFieldValueAsString('X_Batches'));

                                           // NxShowSimpleMessage('šarže ' + mBatch_ID,nil);



                                             mNewQueryID:='{'
                                                                               +'               "Code": "' + mDoc_ID + '", '
                                                                               +'               "X_Parent_ID": "' + mRow_ID + '", '
//                                                                               +'               "X_Firm_ID": "' + mfirm_id + '", '
                                                                               +'               "X_Parent2_ID": "' + mbo.GetFieldValueAsString('X_Storecard_ID') + '", '
                                                                               +'               "X_Storecard_ID": "' + mbo.GetFieldValueAsString('X_Storecard_ID') + '", '
                                                                               +'               "X_Batches": "' + mBatch_ID + '", '
                                                                               +'               "Name": "' + mbo.GetFieldValueAsString('Name')  + '", '
                                                                               +'               "X_quantity": "' + NxFloatToIBStr(mbo.GetFieldValueAsFloat('X_quantity')) + '", '
                                                                               +'}';


                                                                                   mString:= APICallRest(mbo,'post',mApiTArget,'PohybOV','' ,mNewQueryID,True);
                                                                                 //NxShowSimpleMessage('vytoření pohybu šarže' + mstring,nil);
                                                                                 if (copy(mString,1,3)='201') then begin   // stav založení
                                                                                              mQueryID:='{ "class": "' + mCLSIDRowBatch +'", "select": ["ID",], "where": " X_Parent_ID = ' + QuotedStr(mRow_ID) +' and X_batches=' +  QuotedStr(mBatch_ID) + '" }';

                                                                                              mString:= copy(APICallRest(mbo,'Post',mApiTArget,'query','',mQueryID,false),9,10);
                                                                                              if copy(mString,10,2)='ID' then result:= copy(mString,15,10);
                                                                                              //NxShowSimpleMessage('Záznam založen' + result, nil);
                                                                                  end else begin
                                                                                        //NxShowSimpleMessage('Chyba v přístupu k api' + mString,nil);
                                                                                        result:='';
                                                                                        exit;
                                                                                  end;



                                      end;
                                end;

           end;
      finally
         mr.free;
      end;
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


                          mid:=GetOrCreateAPIBatchCZ(TBusRollSiteForm(mSite).CurrentObject,msite,index);










                          //TBusRollSiteForm(mSite).ActiveDataSet.RefreshCurrentItem;
                      end;
                      if mBookmark.count>0 then  ProgressDispose()   ;
                end;
            end;
    end;


    TBusRollSiteForm(msite).Refresh;
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
  mMAction.Items.Add('Lipoelastik CZ ');
  mMAction.OnExecuteItem := @Synchronizace;

end;






begin
end.