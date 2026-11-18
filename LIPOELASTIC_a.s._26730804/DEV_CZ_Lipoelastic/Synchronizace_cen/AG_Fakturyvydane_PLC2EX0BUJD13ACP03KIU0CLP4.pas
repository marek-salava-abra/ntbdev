uses '_Knihovny_ALL.Progress','_Knihovny_ALL.Parse','_Knihovny_ALL.VisualForms',
      'NxApiLib.lib';


Var
    mSite: TSiteForm;
    mDBGrid : TDBGrid;
    mTabList: TTabSheet;
    mCustomBusinessObject: TNxCustomBusinessObject;

    mHeaderBusinessObject : TNxHeaderBusinessObject;
    i : integer;
    mResult:Boolean;
    mBookmarkList:TBookmarkList ;
    aid:string;
    mTarget:string;
    mQuery:string;
    mString:string;

procedure OnExec(Sender: TComponent;index:integer;);       // přidělení objectspace a zadání zdrojového souboru
var
mMon:TNxCustomBusinessMonikerCollection;
mresult:string;
mValues:tstringlist;
mSourcePrice,mTargetPrice:double;
mBTN1caption,mBTN2caption,mBTN3caption,mBTN4caption:string;
mList:tstringlist;

begin
        mlist:=TStringList.create;
        mSourcePrice:=0;
        mTargetPrice:=0;
        mresult:='';
        mSite := NxFindSiteForm(Sender);
        mTabList := TTabSheet(NxFindChildControl(mSite.MainPanel, 'tabList'));
        if mTabList = nil then RaiseException('tabList nenalezen');
        mDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdList'));
        if mDBGrid = nil then RaiseException('DBGrid nenalezen');

        mBookmarkList := mDBGrid.SelectedRows; // *** v mBookmark jsou id označených záznamu

          if mBookmarkList.count=0 then begin
              mCustomBusinessObject:= TDynSiteForm(mSite).CurrentObject;
                   mTarget:='';
                        if NxIsEmptyOID(mCustomBusinessObject.GetFieldValueAsString('Firm_ID.X_API_Conect_ID')) then begin
                              NxShowSimpleMessage(' Firma ' + mCustomBusinessObject.GetFieldValueAsString('Firm_ID.Name') + ' nemá uvedenou API adresu , není možné pokračovat', nil);
                              exit;
                        end else begin
                              mTarget:=mCustomBusinessObject.GetFieldValueAsString('Firm_ID.X_API_Conect_ID.X_CLSID');
                        end;
                            mMon := mCustomBusinessObject.GetLoadedCollectionMonikerForFieldCode(mCustomBusinessObject.GetFieldCode('ROWS'));
                                  for i := 0 to mMon.Count - 1 do begin
                                    mSourcePrice:=mSourcePrice + mMon.BusinessObject[i].GetFieldValueAsFloat('Unitprice') ;
                                    if not NxIsEmptyOID(mMon.BusinessObject[i].GetFieldValueAsString('Providerow_ID')) then begin

                                              mQuery:='{';
                                                    mQuery:=mQuery + '"EAN":"' + mMon.BusinessObject[i].GetFieldValueAsString('Storecard_ID.EAN') + '",' +chr(10);
                                                    mQuery:=mQuery + '"DocumentType":"' + '20' + '",' +chr(10);

                                                    mQuery:=mQuery + '"X_Storedocument_ID":"' + mMon.BusinessObject[i].GetFieldValueAsString('ProvideRow_ID') + '",' ;

                                              mQuery:=mQuery + '}' ;
                                              mString:=APICallString(msite.BaseObjectSpace,'POST',mtarget+'/script/NxApiLib/lib/APINxIssuedPrice',mQuery, true);


                                              mValues:=tstringlist.create;
                                              try
                                                  mvalues:=fnParsevalue(mstring,';');
                                                  if mvalues.count>2 then begin
                                                  mlist.add(mstring);
                                                       mTargetPrice:=mTargetPrice + NxIBStrToFloat(mvalues.Strings[3]);
                                                       if NxIBStrToFloat(mvalues.Strings[3])=mMon.BusinessObject[i].GetFieldValueAsFloat('Unitprice') then begin
                                                            mlist.add(mstring);
                                                            mresult:=mresult  + chr(13) + chr(10) + mvalues.Strings[0] + ' položka: ' + mMon.BusinessObject[i].GetFieldValueAsString('StoreCard_ID.DisplayName') + ' z ' + NxFloatToIBStr(mMon.BusinessObject[i].GetFieldValueAsFloat('Unitprice')) +' na ' + NxFloatToIBStr(NxIBStrToFloat(mvalues.Strings[3])) ;
                                                       end else begin
                                                            //mresult:=mresult  + chr(13) + chr(10) + mvalues.Strings[0] + ' položka: ' + mMon.BusinessObject[i].GetFieldValueAsString('StoreCard_ID.DisplayName') + ' ________ OK') ;
                                                       end;
                                                   end;
                                              finally
                                                  mValues.free;
                                              end;

                                     end;
                                  end;




        end else begin
             ProgressInit(msite, 'Zpracování souboru ' + '', 100);
             for i := 0 to mBookmarkList.Count-1 do begin // projdu vsechny oznacene zaznamy
                   ProgressSetPos(1+NxFloor(i/mBookmarkList.Count*99), inttostr(i) +' z '+inttostr(mBookmarkList.Count));
                  mDBGrid.DataSource.DataSet.GotoBookmark(mBookmarkList.items(i));
                      mCustomBusinessObject:= TDynSiteForm(mSite).CurrentObject;

                        mTarget:='';
                        if NxIsEmptyOID(mCustomBusinessObject.GetFieldValueAsString('Firm_ID.X_API_Conect_ID')) then begin
                              NxShowSimpleMessage(' Firma ' + mCustomBusinessObject.GetFieldValueAsString('Firm_ID.Name') + ' nemá uvedenou API adresu , není možné pokračovat', nil);
                              exit;
                        end else begin
                              mTarget:=mCustomBusinessObject.GetFieldValueAsString('Firm_ID.X_API_Conect_ID.X_CLSID');
                        end;
                            mMon := mCustomBusinessObject.GetLoadedCollectionMonikerForFieldCode(mCustomBusinessObject.GetFieldCode('ROWS'));
                                  for i := 0 to mMon.Count - 1 do begin
                                    mSourcePrice:=mSourcePrice + mMon.BusinessObject[i].GetFieldValueAsFloat('Unitprice') ;
                                    if not NxIsEmptyOID(mMon.BusinessObject[i].GetFieldValueAsString('Providerow_ID')) then begin

                                              mQuery:='{';
                                                    mQuery:=mQuery + '"EAN":"' + mMon.BusinessObject[i].GetFieldValueAsString('Storecard_ID.EAN') + '",' +chr(10);
                                                    mQuery:=mQuery + '"DocumentType":"' + '20' + '",' +chr(10);

                                                    mQuery:=mQuery + '"X_Storedocument_ID":"' + mMon.BusinessObject[i].GetFieldValueAsString('ProvideRow_ID') + '",' ;

                                              mQuery:=mQuery + '}' ;
                                              mString:=APICallString(msite.BaseObjectSpace,'POST',mtarget+'/script/NxApiLib/lib/APINxIssuedPrice',mQuery, true);

                                              mValues:=tstringlist.create;
                                              try
                                                  mvalues:=fnParsevalue(mstring,';');

                                                  if mvalues.count>2 then begin
                                                       mTargetPrice:=mTargetPrice + NxIBStrToFloat(mvalues.Strings[3]);
                                                       if NxIBStrToFloat(mvalues.Strings[3])=mMon.BusinessObject[i].GetFieldValueAsFloat('Unitprice') then begin
                                                             mlist.add(mstring);
                                                            mresult:=mresult  + chr(13) + chr(10) + mvalues.Strings[0] + ' položka: ' + mMon.BusinessObject[i].GetFieldValueAsString('StoreCard_ID.DisplayName') + ' z ' + NxFloatToIBStr(mMon.BusinessObject[i].GetFieldValueAsFloat('Unitprice')) +' na ' + NxFloatToIBStr(NxIBStrToFloat(mvalues.Strings[3])) ;
                                                       end else begin
                                                            //mresult:=mresult  + chr(13) + chr(10) + mvalues.Strings[0] + ' položka: ' + mMon.BusinessObject[i].GetFieldValueAsString('StoreCard_ID.DisplayName') + ' ________ OK') ;
                                                       end;
                                                   end;
                                              finally
                                                  mValues.free;
                                              end;

                                     end;
                                  end;



              end;
              ProgressDispose()   ;
        end;
          if trim(mresult)='' then begin
                         mBTN1caption:='Pokračovat';
                         mBTN2caption:='';
          end else begin
                        mBTN1caption:='Pokračovat';
                        mBTN2caption:='Opravit příjemku';
          end;
          mresult:=mresult + chr(13) + chr(10);
          mresult:=mresult + chr(13) + chr(10) + ' Zdrojová cena: ' + NxFloatToIBStr(mSourcePrice);
          mresult:=mresult + chr(13) + chr(10) + ' Cílová cena: ' + NxFloatToIBStr(mTargetPrice);
          mstring:=FNResult_string(mSite,0,0,720,960, 'Výsledek',
                          'Hodnoty',mresult,'aaa','','','','','','','aaa');


          if mString<>'2' then begin
              NxShowSimpleMessage(mString + ' opearce' ,nil);
          end;
        mlist.free;
        //mDBGrid.Refresh;
        //mDBGrid.DataSource.DataSet.Refresh;
end;






procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TBasicAction;
  mMAction: TMultiAction;
  mCAction: TBasicAction;
  mAList: TActionList;
  i : integer;
  mUserFilter:Boolean;
  mUserFilterTL:string;
  muser:TNxCustomBusinessObject;
begin
          mMAction := Self.GetNewMultiAction;
          mMAction.ShowControl := True;
          mMAction.ShowMenuItem := True;
          mMAction.Hint := 'Synchronizace cen';
          mMAction.Caption := 'SK - Aktualizace cen PR';
          mMAction.Items.Add('Aktualizace cen SK ');
          mMAction.Category := 'tabList';
          mMAction.OnExecuteItem := @OnExec;

end;


begin
end.