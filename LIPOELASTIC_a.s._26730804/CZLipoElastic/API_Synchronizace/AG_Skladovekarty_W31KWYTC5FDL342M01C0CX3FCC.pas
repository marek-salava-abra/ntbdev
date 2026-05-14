  uses  '_Knihovny_ALL.Progress',
      '_Knihovny_ALL.Parse',
      'API_Synchronizace.API' ;

      const
mTable='Storecards';
mApiTable='Storecards';

var
mQuery:string;


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
 mMon:TNxCustomBusinessMonikerCollection;
 mError:string;
begin
  mids:='';
  mError:='';
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
                          self:=TBusRollSiteForm(msite).CurrentObject;    // načtení objektu

if true then begin
   //NxGetUserName='mskacel' then begin
//   NxShowSimpleMessage('AAAA',nil);
   mTargetList:=tstringlist.create;
mMon := self.GetLoadedCollectionMonikerForFieldCode(self.GetFieldCode('StoreUnits'));
    TRY
          mTargetList:=CreateTargetList;

    for i:=0 to mTargetList.count-1 do begin // ****cyklus pro jednotlicá spojení
                mTarget:=mTargetList.strings[i];
          if copy(self.GetFieldValueAsString('X_synchronizace_ID'),i+1,1)='1' then begin

                        //  NxShowSimpleMessage(inttostr(mTargetList.count),nil) ;
                        //             NxShowSimpleMessage(self.ObjectSpace.GetConnectionName,nil);
                     mQuery:='{}';

                     IF mManual then BEGIN                   // **** ruční vykopírování údajů
                         mQuery:=GetQuerySC(self);




                      END ELSE BEGIN                   // **** celkové vykopírování BO do JSON
              //             mQuery:= CallRestApi(TBusRollSiteForm(msite).CurrentObject,'GET',msource,mApiTable,'/'+Self.OID,'{}');
                          // mQuery:= CorrectQuery(mQuery, '"classid":');
                          // mQuery:= CorrectQuery(mQuery, '"clsid":');
                          // mQuery:= CorrectQuery(mQuery, '"ObjVersion":');
                          // mQuery:= CorrectQuery(mQuery, '"DisplayName":');
                          // mQuery:=NxRemoveDiacritics(mQuery);

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
                              mID:= copy(CallRestApi(Self,'Post',mtarget,'query','',mQueryID),9,10);








//                      mstring:=                      inputbox('Skladové karty - plné data','Put',mtarget+mApiTable+'/' + mid + '       ' + mQuery)    ;



                        IF mid='' THEN BEGIN
                            //NxShowSimpleMessage('Nový záznam se stejným ID',nil);

                                 mNewQueryID:='{"info_type": "New_value" '
                                           +','+' "mSQL": "INSERT INTO ' + mtable + ' (ID,category,code,name,hidden,mainunitcode,EAN,storecardcategory_id,x_busdivision_id,CreatedBy_ID,Country_ID) VALUES (' +
                                                          quotedstr(Self.oid)
                                                          + ','+ inttostr(Self.GetFieldValueAsinteger('category'))
                                                          + ','+ quotedstr(Self.GetFieldValueAsString('Code'))
                                                          + ','+ quotedstr(copy(Self.GetFieldValueAsString('X_Name_SK'),1,80))
                                                          + ','+ quotedstr('N')
                                                          + ','+ quotedstr(Self.GetFieldValueAsString('mainunitcode'))
                                                          + ','+ quotedstr(Self.GetFieldValueAsString('EAN'))
                                                          + ','+ quotedstr('1000000101')
                                                          + ','+ quotedstr('SUPER00000')
                                                          + ','+ quotedstr('1000000101')
                                                          + ','+ quotedstr('00000SK000')
                                                         + ')"}';

                                 //    NxShowSimpleMessage(mNewQueryID,nil);
                                 aString:=CallNewValueWithID(self,'POST',mtarget+'script/Synchronizace/API/NewValueWithID',mNewQueryID);

                                 if (copy(mString,1,3)<>'200') and (copy(mString,1,3)<>'201') AND (index=1) then begin
                                        mError:=mError + ',' + quotedstr(self.oid);

                                        if index=1 then mstring:=  inputbox('Skladové karty - insert','Post',mtarget+'script/Synchronizace/API/NewValueWithID'+ '       ' + mNewQueryID)    ;
                                  end;




                                  if copy(self.GetFieldValueAsString('X_synchronizace_ID'),2,1)='1' then begin
                                       mNewQueryID:='{'
                                              +' "vatrate_id": "02100X0000", '
                                             +'       "vatrates": [         '
                                             +'           {                 '
                                             +'               "country_id": "00000CZ000", '
                                             +'               "vatrate_id": "02100X0000" '
                                             +'           }     '
                                             +'}';
                                   end;



                                  if copy(self.GetFieldValueAsString('X_synchronizace_ID'),2,1)='1' then begin
                                       mNewQueryID:='{'
                                              +' "vatrate_id": "02000X0000", '
                                             +'       "vatrates": [         '
                                             +'           {                 '
                                             +'               "country_id": "00000SK000", '
                                             +'               "vatrate_id": "02000X0000" '
                                             +'           }     '
                                             +'}';
                                   end;
                                //    mstring:=                      inputbox('DPH','PUT' + '   ' + mtarget+mApiTable+'/' + SELF.OID ,mNewQueryID)    ;
                                //NxShowSimpleMessage(mtarget+mApiTable+'/' + SELF.OID  ,nil);
                                         mString:= CallRestApi(self,'PUT',mtarget,mApiTable,'/' + SELF.OID ,mNewQueryID);







                         end;

                               if mid='' then begin
                                  //  NxShowSimpleMessage('založení záznamu v ' + mtarget +  ' selhalo',nil);
                                end else begin
                                //    mString:= CallRestApi(self,'PUT',mtarget,mApiTable,'/' + mid ,mQuery);  // načtení záznamu
                                end;

                               if mid='' then begin
                                 mr:=tstringlist.create;
                                 try
                                     self.ObjectSpace.SQLSelect('Select id,code from storeunits where parent_id=' + quotedstr(self.oid),mr);
                                     if mr.count>0 then begin
                                         for ii:=0 to mr.count-1 do begin
                                             if copy(mr.Strings[ii],12,5)<>'' then begin
                                                mNewQueryID:='{"info_type": "New_value" '
                                                           +','+' "mSQL": "INSERT INTO ' + 'storeunits' + ' (id,Parent_ID,code) VALUES (' +
                                                          quotedstr(copy(mr.Strings[ii],1,10))
                                                          + ','+ quotedstr(Self.oid)
                                                          + ','+ quotedstr(copy(mr.Strings[ii],12,5))
                                                         + ')"}';
                       //    mstring:=                      inputbox('Jednotka','Jednotka',mNewQueryID)    ;


                                                         aString:=CallNewValueWithIDNoErr(self,'POST',mtarget+'script/Synchronizace/API/NewValueWithID',mNewQueryID);
                                                       mr1:=tstringlist.create;
                                                       try
                                                           self.ObjectSpace.sqlselect('select id,ean from StoreEANs where parent_id=' + quotedstr(copy(mr.Strings[ii],1,10)),mr1);
                                                               if mr1.count>0 then begin
                                                                             for iii:=0 to mr1.count-1 do begin
                                                                                      for iii:=0 to mr1.count-1 do begin
                                                                                            mNewQueryID:='{"info_type": "New_value" '
                                                                                                       +','+' "mSQL": "INSERT INTO ' + 'StoreEANs' + ' (id,Parent_ID,EAN) VALUES (' +
                                                                                                      quotedstr(copy(mr1.Strings[iii],1,10))
                                                                                                      + ','+ quotedstr(copy(mr.Strings[ii],1,10))
                                                                                                      + ','+ quotedstr(copy(mr1.Strings[iii],12,20))
                                                                                                     + ')"}';
                                                                                                   //  mstring:=                      inputbox('EAN','AA',mNewQueryID)    ;
                                                                                                     aString:=CallNewValueWithIDNoerr(self,'POST',mtarget+'script/Synchronizace/API/NewValueWithID',mNewQueryID);
                                                                                      end;
                                                                             end;
                                                               end;
                                                       finally
                                                           mr1.free;
                                                       end;
                                             end;
                                         end;
                                     end;

                                 finally
                                    mr.free;
                                 end;
                               end;
                             // mstring:=                      inputbox('Skladové karty - plné data','Put',mtarget+mApiTable+'/' + mid + '       ' + mQuery)    ;
                              mString:= CallRestApi1(self,'PUT',mtarget,mApiTable,'/' + mid ,mQuery);  // načtení záznamu


                              if (copy(mString,1,3)<>'200') and (copy(mString,1,3)<>'201') AND (index=1) then begin
                                  mError:=mError + ',' + quotedstr(self.oid);
                                  if index=1 then mstring:=                      inputbox('Skladové karty - plné data','Put',mtarget+mApiTable+'/' + mid + '       ' + mQuery)    ;
                              end;

                             //                   skladové menu
                                 mr:=tstringlist.create;
                                 try
                                     self.ObjectSpace.sqlselect('select a.Storecard_ID, a.StoreMenuItem_ID from StoreCardMenuItemLinks a left join StoreMenu SM on sm.id=a.StoreMenuItem_ID where a.Storecard_ID=' + QuotedStr(self.oid) + ' and sm.hidden=' + QuotedStr('N'),mr) ;
                                        if mr.count>0 then begin
                                                for i:=0 to mr.count-1 do begin
                                                    try
                                                                  mQuery:='{'
                                                                       +'"Storecard_ID":"'  +  copy(mr.Strings[i],1,10) +'", '
                                                                       +'"StoreMenuItem_ID":"' +  copy(mr.Strings[i],12,10) +'"'
                                                                     + '}';
                                                              //  mstring:= inputbox('Skladové menu','AA',mQuery + '     ' + copy(mr.Strings[i],1,10)  + '   ' +copy(mr.Strings[i],12,10) )    ;
                                                                  mQueryID:='{'
                                                                          + ' "class": "StoreCardMenuItemLinks",'
                                                                          +' "select": ["ID",],'
                                                                          + ' "where": " Storecard_ID = ' + QuotedStr(copy(mr.Strings[i],1,10)) + ' and StoreMenuItem_ID=' + QuotedStr(copy(mr.Strings[i],12,10))
                                                                          +' " '
                                                                          + '}';
              //                                                                                             mstring:= inputbox('Skladové menu','Dotaz na existenci ',mQueryID)    ;
                                                                      mID:= copy(CallRestApi(Self,'Post',mtarget,'query','',mQueryID),9,10);
                                                                 //     NxShowSimpleMessage(mid,nil);
                                                                  if mID='' then begin
                                                                        mID:= CallRestApi(TBusRollSiteForm(msite).CurrentObject,'Post',mtarget,'StoreCardMenuItemLinks','',mQuery);
                                                                      //   mstring:= inputbox('Skladové menu','Založení vazby skladového menu',mQuery)    ;
                                                                  end else begin
                                                                        //mQuery:= CallRestApi(TBusRollSiteForm(msite).CurrentObject,'put',msource,'StoreCardMenuItemLinks','/'+mid,mQuery);
                                                                        //mstring:= inputbox('Skladové menu','Oprava vazby skladového menu',mQuery)    ;
                                                                  end;
                                                    finally

                                                    end;


                                                end;
                                        end;
                                 finally
                                      mr.free;
                                 end;







                                //  NxShowSimpleMessage(astring,nil);
                                // ověření založení karty
                            //    mQueryID:='{'
                            //  + ' "class": "' + mApiTable +'",'
                            //  +' "select": ["ID",],'
                            //  + ' "where": " id = ' + QuotedStr(Self.OID)
                            //  +' " '
                            //  +'}';
              //                NxShowSimpleMessage(mQueryID,nil);
                              //mID:= copy(CallRestApi(Self,'Post',mtarget,'query','',mQueryID),9,10);









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
  mMAction.Hint := 'Zobrazuje normy pro výrobu';
  mMAction.Category := 'tabList';
  mMAction.Items.Add('Základní s ID ');
  mMAction.Items.Add('Rozšířená ');
  mMAction.OnExecuteItem := @Synchronizace;

end;

begin
end.





