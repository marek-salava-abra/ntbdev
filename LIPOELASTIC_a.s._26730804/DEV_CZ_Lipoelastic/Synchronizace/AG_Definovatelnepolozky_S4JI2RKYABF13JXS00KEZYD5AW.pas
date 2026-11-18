uses  '_Knihovny_ALL.Progress',
      '_Knihovny_ALL.Parse',
      'Synchronizace.API' ;

const
mTable='UserFieldDefs';
mApiTable='UserFieldDefs';

var
mQuery:string;


function GetOrCreateAPI(mBO:TNxCustomBusinessObject;xsite: TDynSiteForm): string;
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
  mMonRows:TNxCustomBusinessMonikerCollection;
  mHead_id,mRow_ID:string;
  mzapis:boolean;
begin
 result:='';
 mzapis:=false;
   mTargetList:=tstringlist.create;
    TRY
          mTargetList:=CreateTargetList;

    for i:=0 to mTargetList.count-1 do begin // ****cyklus pro jednotlicá spojení
                mTarget:=mTargetList.strings[i];
//

                    mTarget:=mTargetAPI + '/';
           if mtarget<>msource then begin
                    // ***** dohledání hlavičky
                     mQueryID:='{'
                              + ' "class": "' + mApiTable +'",'
                              +' "select": ["ID",],'
                              + ' "where": " CLSID = ' + QuotedStr(mBO.GetFieldValueAsString('CLSID'))
                              +' " '
                              +'}';
                              mHead_id:='';
                              mString:= APICallRest(mBO,'Post',mtarget,'query','',mQueryID,true);

                             //  NxShowSimpleMessage(' - id ' + copy(mString,15,10),nil);
                             if (copy(mString,1,3)='200') or (copy(mString,1,3)='201') then begin
                                   // NxShowSimpleMessage('Dohledána hlavička ' + mbo.oid + '/'  + copy(mString,15,10),nil);
                                        if copy(mString,15,10)<>'' then begin
                                             mHead_id:= copy(mString,15,10);

                                         //    NxShowSimpleMessage('hlavička ' + mHead_id,nil);
                                        end else begin
                                        //     NxShowSimpleMessage('hlavička nenamezena' + mHead_id,nil);
                                        end;


                              end else begin
                                        NxShowSimpleMessage('Chyba v přístupu k api' + mString,nil);
                                        iSendmsgy(xsite.BaseObjectSpace,
                                                 ' API Error ' + mtable ,     // popis
                                                  mString  + '      Post'+mtarget+'query'+''+mQueryID,                          // tělo
                                                  mToMSG ,                      // komu
                                                  xsite.SiteContext.GetCompanyCache.GetUserID); // kdo
                                        mHead_id:='';
                                        //exit;
                              end;

                     mNewQueryID:='{ ' ;
                                                     mNewQueryID:= mNewQueryID + ' "clsid": "' + (mbo.GetFieldValueAsString('clsid')) + '",';
                                                     if mHead_id<>'' then mNewQueryID:= mNewQueryID + ' "id": "' + (mHead_id) + '",';
                                                     mNewQueryID:= mNewQueryID + ' "createdby_id": "SUPER00000",';
                                                     mNewQueryID:= mNewQueryID + ' "rows": [';








          mMonRows := mBO.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('ROWS'));
                for ii:=0 to mMonRows.count-1 do begin
                    // dohledíní položky
                    mQueryID:='{'
                              + ' "class": "WHMZBIJR3VF13JXR00KEZYD5AW",'
                              +' "select": ["ID",],'
                              + ' "where": "FieldName =' + quotedstr(mMonRows.BusinessObject[ii].GetFieldValueAsString('FieldNAme')) +
                                ' and ExtraField= ' + (NxBoolToString(mMonRows.BusinessObject[ii].GetFieldValueAsBoolean('ExtraField'))) +
                                ' and parent_ID=' + quotedstr(mHead_id)
                              +' " '
                              +'}';

                              mString:= APICallRest(mBO,'Post',mtarget,'query','',mQueryID,true);

                              mRow_ID:='';
                             if (copy(mString,1,3)='200') or (copy(mString,1,3)='201') then begin
                                   // NxShowSimpleMessage('Dohledána položka API ' +mMonRows.BusinessObject[ii].oid + '/' + copy(mString,15,10),nil);
                                   if copy(mString,13,50)<>'' then begin
                                             mRow_ID:= copy(mString,15,10);

                                             mNewQueryID:= mNewQueryID + '    {';
                                                           if mRow_ID<>'' then mNewQueryID:= mNewQueryID + ' "id": "' + (mRow_ID) + '",';
                                                   mNewQueryID:= mNewQueryID +          ' "fieldname": "' + (mMonRows.BusinessObject[ii].GetFieldValueAsString('fieldname')) + '",';
                                                   mNewQueryID:= mNewQueryID +          ' "system":"' + 	BoolToStr(mMonRows.BusinessObject[ii].GetFieldValueAsBoolean('system'))+'", '       ;
                                                          mNewQueryID:= mNewQueryID +          ' "extrafield":"' + 	BoolToStr(mMonRows.BusinessObject[ii].GetFieldValueAsBoolean('extrafield'))+'", '       ;
                                                          mNewQueryID:= mNewQueryID +          ' "fielddatatype":  ' + (mMonRows.BusinessObject[ii].GetFieldValueAsString('fielddatatype')) + ',';
                                                          mNewQueryID:= mNewQueryID +          ' "fielddbtype":  ' + (mMonRows.BusinessObject[ii].GetFieldValueAsString('fielddbtype')) + ',';
                                                          mNewQueryID:= mNewQueryID +          ' "fielddisplayhint": "' + (mMonRows.BusinessObject[ii].GetFieldValueAsString('fielddisplayhint')) + '",';
                                                          mNewQueryID:= mNewQueryID +          ' "fielddisplaylabel": "' + (mMonRows.BusinessObject[ii].GetFieldValueAsString('fielddisplaylabel')) + '",';
                                                          mNewQueryID:= mNewQueryID +          ' "fieldprecision":  ' + (mMonRows.BusinessObject[ii].GetFieldValueAsString('fieldprecision')) + ',';
                                                          mNewQueryID:= mNewQueryID +          ' "fieldrollclsid": "' + (mMonRows.BusinessObject[ii].GetFieldValueAsString('fieldrollclsid')) + '",';
                                                          mNewQueryID:= mNewQueryID +          ' "fieldsize":  ' + (mMonRows.BusinessObject[ii].GetFieldValueAsString('fieldsize')) + ',';
                                                          mNewQueryID:= mNewQueryID +          ' "fieldsuffix": "' + (mMonRows.BusinessObject[ii].GetFieldValueAsString('fieldsuffix')) + '",';
                                                          mNewQueryID:= mNewQueryID +          ' "fieldprefix": "' + (mMonRows.BusinessObject[ii].GetFieldValueAsString('fieldprefix')) + '",';
                                                          mNewQueryID:= mNewQueryID +          ' "defaultvalueboolean":"' + 	BoolToStr(mMonRows.BusinessObject[ii].GetFieldValueAsBoolean('defaultvalueboolean'))+'", '       ;
                                                          mNewQueryID:= mNewQueryID +          ' "isreadonly":"' + 	BoolToStr(mMonRows.BusinessObject[ii].GetFieldValueAsBoolean('isreadonly'))+'", '       ;
                                                          mNewQueryID:= mNewQueryID +          ' "issortable":"' + 	BoolToStr(mMonRows.BusinessObject[ii].GetFieldValueAsBoolean('issortable'))+'", '       ;
                                                          mNewQueryID:= mNewQueryID +          ' "iscasesensitive":"' + 	BoolToStr(mMonRows.BusinessObject[ii].GetFieldValueAsBoolean('iscasesensitive'))+'", '       ;
                                                          mNewQueryID:= mNewQueryID +          ' "maxvaluefloat": ' + (mMonRows.BusinessObject[ii].GetFieldValueAsString('maxvaluefloat')) + ',';
                                                          mNewQueryID:= mNewQueryID +          ' "fielddisplaywidth": ' + (mMonRows.BusinessObject[ii].GetFieldValueAsString('fielddisplaywidth')) + ',';

                                                                    mNewQueryID:= mNewQueryID +          '"currencysourcepath": "' + (mMonRows.BusinessObject[ii].GetFieldValueAsString('currencysourcepath')) + '",';
                                                                    mNewQueryID:= mNewQueryID +          '"defaultvalue":"' + 	BoolToStr(mMonRows.BusinessObject[ii].GetFieldValueAsBoolean('defaultvalue'))+'", '       ;
                                                                    mNewQueryID:= mNewQueryID +          '"defaultvaluefloat":  ' + (mMonRows.BusinessObject[ii].GetFieldValueAsString('defaultvaluefloat')) + ',';
                                                                    mNewQueryID:= mNewQueryID +          '"defaultvalueinteger":  ' + (mMonRows.BusinessObject[ii].GetFieldValueAsString('defaultvalueinteger')) + ',';
                                                                    mNewQueryID:= mNewQueryID +          '"editmethod":  ' + (mMonRows.BusinessObject[ii].GetFieldValueAsString('editmethod')) + ',';
                                                                    mNewQueryID:= mNewQueryID +          '"enumeration": "' + (mMonRows.BusinessObject[ii].GetFieldValueAsString('enumeration')) + '",';
                                                                    mNewQueryID:= mNewQueryID +          '"fieldalignment":  ' + (mMonRows.BusinessObject[ii].GetFieldValueAsString('fieldalignment')) + ',';
                                                         //           mNewQueryID:= mNewQueryID +          '"fieldclsid": "' + (mMonRows.BusinessObject[ii].GetFieldValueAsString('fieldclsid')) + '",';
                                                         //         mNewQueryID:= mNewQueryID +          '  "fieldcode": 1001012,
                                                                    mNewQueryID:= mNewQueryID +          '"fielddisplayformat": "' + (mMonRows.BusinessObject[ii].GetFieldValueAsString('fielddisplayformat')) + '",';
                                                                    mNewQueryID:= mNewQueryID +          '"fieldkind":  ' + (mMonRows.BusinessObject[ii].GetFieldValueAsString('fieldkind')) + ',';
                                                                    mNewQueryID:= mNewQueryID +          '"firstvalue":  ' + (mMonRows.BusinessObject[ii].GetFieldValueAsString('firstvalue')) + ',';
                                                                    mNewQueryID:= mNewQueryID +          '"flags": "' + (mMonRows.BusinessObject[ii].GetFieldValueAsString('flags')) + '",';
                                                                    mNewQueryID:= mNewQueryID +          '"forcedfield":"' + 	BoolToStr(mMonRows.BusinessObject[ii].GetFieldValueAsBoolean('forcedfield'))+'", '       ;
                                                                    mNewQueryID:= mNewQueryID +          '"hasforeignkey":"' + 	BoolToStr(mMonRows.BusinessObject[ii].GetFieldValueAsBoolean('hasforeignkey'))+'", '       ;
                                                                    mNewQueryID:= mNewQueryID +          '"hashistory":"' + 	BoolToStr(mMonRows.BusinessObject[ii].GetFieldValueAsBoolean('hashistory'))+'", '       ;
                                                                    mNewQueryID:= mNewQueryID +          '"importable":"' + 	BoolToStr(mMonRows.BusinessObject[ii].GetFieldValueAsBoolean('importable'))+'", '       ;
                                                                    mNewQueryID:= mNewQueryID +          '"indexname": "' + (mMonRows.BusinessObject[ii].GetFieldValueAsString('indexname')) + '",';
                                                                    mNewQueryID:= mNewQueryID +          '"isindexed":"' + 	BoolToStr(mMonRows.BusinessObject[ii].GetFieldValueAsBoolean('isindexed'))+'", '       ;
                                                                    mNewQueryID:= mNewQueryID +          '"ismultichangeable":"' + 	BoolToStr(mMonRows.BusinessObject[ii].GetFieldValueAsBoolean('ismultichangeable'))+'", '       ;
                                                                    mNewQueryID:= mNewQueryID +          '"maxvalue": "' + (mMonRows.BusinessObject[ii].GetFieldValueAsString('maxvalue')) + '",';
                                                                    mNewQueryID:= mNewQueryID +          '"maxvalueinteger":  ' + (mMonRows.BusinessObject[ii].GetFieldValueAsString('maxvalueinteger')) + ',';
                                                                    mNewQueryID:= mNewQueryID +          '"minvalue": "' + (mMonRows.BusinessObject[ii].GetFieldValueAsString('minvalue')) + '",';
                                                                    mNewQueryID:= mNewQueryID +          '"minvaluefloat":  ' + (mMonRows.BusinessObject[ii].GetFieldValueAsString('minvaluefloat')) + ',';
                                                                    mNewQueryID:= mNewQueryID +          '"minvalueinteger":  ' + (mMonRows.BusinessObject[ii].GetFieldValueAsString('minvalueinteger')) + ',';
                                                                    mNewQueryID:= mNewQueryID +          '"replicatable":"' + 	BoolToStr(mMonRows.BusinessObject[ii].GetFieldValueAsBoolean('replicatable'))+'", '       ;
                                                                    mNewQueryID:= mNewQueryID +          '"showtime":"' + 	BoolToStr(mMonRows.BusinessObject[ii].GetFieldValueAsBoolean('showtime'))+'", '       ;
                                                                    mNewQueryID:= mNewQueryID +          '"sortablerollfields": "' + (mMonRows.BusinessObject[ii].GetFieldValueAsString('sortablerollfields')) + '",';
                                                                    mNewQueryID:= mNewQueryID +          '"textfield": "' + (mMonRows.BusinessObject[ii].GetFieldValueAsString('textfield')) + '",';
                                                                    mNewQueryID:= mNewQueryID +          '"useindynsql":"' + 	BoolToStr(mMonRows.BusinessObject[ii].GetFieldValueAsBoolean('useindynsql'))+'", '       ;

                                                     mNewQueryID:= mNewQueryID + ' }, ';



                                   end else begin
                                       mRow_ID:='';
                                   end;

                              end else begin
                                        NxShowSimpleMessage('Chyba v přístupu k api' + mString,nil);
                                        iSendmsgy(xsite.BaseObjectSpace,
                                                 ' API Error ' + mtable ,     // popis
                                                  mString  + '      Post'+mtarget+'query'+''+mQueryID,                          // tělo
                                                  mToMSG ,                      // komu
                                                  xsite.SiteContext.GetCompanyCache.GetUserID); // kdo
                                        mID:='';
                                        //exit;
                              end;





                    // ***** položka v api nedohledána







                end;



      mNewQueryID:= mNewQueryID + ']';
mNewQueryID:= mNewQueryID + '}';

if mHead_id='' then begin
     mString:= APICallRest(mBO,'Post',mtarget,mtable,'',mNewQueryID,true);
end else begin
     mString:= APICallRest(mBO,'PUT',mtarget,mtable,'/' +mHead_id,mNewQueryID,true);
end;


                             if (copy(mString,1,3)='200') or (copy(mString,1,3)='201') then begin
                                 //   NxShowSimpleMessage('Záznam založen ' +mMonRows.BusinessObject[ii].oid + '/' + copy(mString,15,10),nil);

                              end else begin
                                        NxShowSimpleMessage('Chyba v přístupu k api' + mString,nil);

                                          if mHead_id='' then begin
                                               mString:= APICallRest(mBO,'Post',mtarget,mtable,'',mNewQueryID,true);
                                               iSendmsgy(xsite.BaseObjectSpace,
                                                    ' API Error ' + mtable ,     // popis
                                                    mString  + '      Post'+mtarget+mtable+''+mNewQueryID,                          // tělo
                                                    mToMSG ,                      // komu
                                                    xsite.SiteContext.GetCompanyCache.GetUserID); // kdo
                                          end else begin
                                               mString:= APICallRest(mBO,'PUT',mtarget,mtable,'/' +mHead_id,mNewQueryID,true);
                                                  iSendmsgy(xsite.BaseObjectSpace,
                                                    ' API Error ' + mtable ,     // popis
                                                      mString  + '      PUT'+mtarget+mtable+mHead_id+mNewQueryID,                          // tělo
                                                      mToMSG ,                      // komu
                                                      xsite.SiteContext.GetCompanyCache.GetUserID); // kdo
                                          end;




                                        mID:='';
                                        //exit;
                              end;

        end;
                  end;
    finally
    //  mTargetList.free;
    end;
end;





function GetQueryBO(self:TNxCustomBusinessObject;Itarget:integer;): string;
var
I:integer;
begin
    mQuery:='{'   ;

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
                                     +','+' "mSQL": "INSERT INTO ' + mtable + ' () VALUES (' +
                                            quotedstr(Self.GetFieldValueAsString('Code'))
                                            + ','+ quotedstr(Self.GetFieldValueAsString('Name'))
                                            + ','+ quotedstr(Self.OID)
                                            + ','+ quotedstr('N')
                                            + ','+ quotedstr('1000000101')
                                            + ')"}';
         result:=mNewQueryID;
end;




procedure xxx_AfterSave_PostHook(xsite: TRollSiteForm);
var
  mID:string;
begin
 //  mid:=GetOrCreateAPI(TDynSiteForm(xsite).CurrentObject,TDynSiteForm(xSite));
end;



{
Vyvolává se po provedení inicializace agendy/formuláře. V tento okamžik je již na formuláři dostupný SiteContext.
}
procedure InitSite_Hook(Self: TSiteForm);
begin

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
                        //  mid:=GetOrCreateAPI(TBusRollSiteForm(mSite).CurrentObject,TBusRollSiteForm(mSite));
                          mid:=GetOrCreateAPI(TDynSiteForm(msite).CurrentObject,TDynSiteForm(mSite));

                      end;
                      if mBookmark.count>0 then  ProgressDispose()   ;
                end;
            end;
    end;



end;



procedure xxxFormCreate_Hook(Self: TSiteForm);
var
  mAction: TAction;
  mMAction: TMultiAction;
begin
  {mMAction := Self.GetNewMultiAction;
  mMAction.ShowControl := True;
  mMAction.ShowMenuItem := True;
  mMAction.Caption := 'Synchronizace';
  mMAction.Hint := 'Synchronizace s ostatními abrami';
  mMAction.Category := 'tabList';
  mMAction.Items.Add('Základní s ID ');
  mMAction.Items.Add('Rozšířená ');
  mMAction.OnExecuteItem := @Synchronizace;
   }
end;

begin
end.





