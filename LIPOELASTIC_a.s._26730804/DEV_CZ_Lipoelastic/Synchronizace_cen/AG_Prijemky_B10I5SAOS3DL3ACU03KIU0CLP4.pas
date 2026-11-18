uses '_Knihovny_ALL.Progress',
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
    mXresult:string;
    mi:string;
procedure OnExec(Sender: TComponent;index:integer;);       // přidělení objectspace a zadání zdrojového souboru
var
mMon:TNxCustomBusinessMonikerCollection;
begin
        mXresult:='';
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
                                    if not NxIsEmptyOID(mMon.BusinessObject[i].GetFieldValueAsString('X_Providerow_ID')) then begin

                                              mQuery:='{' + chr(10);
                                                    mQuery:=mQuery + '"X_Providerow_ID":"' + mMon.BusinessObject[i].GetFieldValueAsString('X_Providerow_ID') + '",' +chr(10);
                                                    mQuery:=mQuery + '"Storecard_ID":"' + mMon.BusinessObject[i].GetFieldValueAsString('StoreCard_ID') + '",' +chr(10);
                                                    mQuery:=mQuery + '"EAN":"' + mMon.BusinessObject[i].GetFieldValueAsString('StoreCard_ID.EAN') + '",' +chr(10);
                                                    mQuery:=mQuery + '"Firm_Name":"' + 'LIPOELASTIC a.s.' + '",' +chr(10);
                                                    mQuery:=mQuery + '"X_Storedocument_ID":"' + mMon.BusinessObject[i].GetFieldValueAsString('X_StoreDocuments2_ID') + '",' +chr(10);

                                              mQuery:=mQuery + '}' + chr(10);
                                             //if NxGetUserName='Supervisor' then
                                              //mi:=InputBox('Post','Cena','POST    '+  mtarget+'/script/NxApiLib/lib/APINxStorePrice' + chr(10) + chr(13) +mQuery);

                                              mString:=APICallString(msite.BaseObjectSpace,'POST',mtarget+'/script/NxApiLib/lib/APINxStorePrice',mQuery, true);

                                            //  NxShowSimpleMessage(mstring,nil);
                                              if NxIBStrToFloat(mstring)<>0 then begin
                                                 if NxIBStrToFloat(mstring)<>mMon.BusinessObject[i].GetFieldValueAsFloat('Unitprice') then begin
                                                        mXresult:=mXresult +  mCustomBusinessObject.displayname + ' - ' + mMon.BusinessObject[i].GetFieldValueAsString('Storecard_id.Displayname') + ' z ' + NxFloatToIBStr(mMon.BusinessObject[i].GetFieldValueAsFloat('Unitprice')) + ' na ' + mString +chr(10) +chr(13);

                                                        mMon.BusinessObject[i].SetFieldValueAsFloat('Unitprice',NxIBStrToFloat(mstring));

                                                        //NxShowSimpleMessage('Změna ceny pro ' + mMon.BusinessObject[i].GetFieldValueAsString('StoreCard_ID.DisplayName') + ' z ' + NxFloatToIBStr(mMon.BusinessObject[i].GetFieldValueAsFloat('Unitprice')) +' na ' + NxFloatToIBStr(NxIBStrToFloat(mstring)) ,nil);
                                                 end;
                                              end;
                                     end;
                                  end;
                          mCustomBusinessObject.save;
                          TDynSiteForm(msite).ActiveDataSet.RefreshCurrentItemMode;

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
                                     if not NxIsEmptyOID(mMon.BusinessObject[i].GetFieldValueAsString('X_Providerow_ID')) then begin
                                                  mQuery:='{' + chr(10);
                                                        mQuery:=mQuery + '"X_Providerow_ID":"' + mMon.BusinessObject[i].GetFieldValueAsString('X_Providerow_ID') + '",' +chr(10);
                                                        mQuery:=mQuery + '"Storecard_ID":"' + mMon.BusinessObject[i].GetFieldValueAsString('StoreCard_ID') + '",' +chr(10);
                                                        mQuery:=mQuery + '"EAN":"' + mMon.BusinessObject[i].GetFieldValueAsString('StoreCard_ID.EAN') + '",' +chr(10);
                                                    mQuery:=mQuery + '"Firm_Name":"' + 'LIPOELASTIC a.s.' + '",' +chr(10);
                                                    mQuery:=mQuery + '"X_Storedocument_ID":"' + mMon.BusinessObject[i].GetFieldValueAsString('X_StoreDocuments2_ID') + '",' +chr(10);

                                                  mQuery:=mQuery + '}' + chr(10);
                                                 // mi:=InputBox('Post','Cena','POST    '+  mtarget+'/script/NxApiLib/lib/APINxStorePrice' + chr(10) + chr(13) +mQuery);

                                                  mString:=APICallString(msite.BaseObjectSpace,'POST',mtarget+'/script/NxApiLib/lib/APINxStorePrice',mQuery, true);
                                                  if NxIBStrToFloat(mstring)<>0 then begin
                                                     if NxIBStrToFloat(mstring)<>mMon.BusinessObject[i].GetFieldValueAsFloat('Unitprice') then begin
                                                            mXresult:=mXresult +  mCustomBusinessObject.displayname + ' - ' + mMon.BusinessObject[i].GetFieldValueAsString('Storecard_id.Displayname') + ' z ' + NxFloatToIBStr(mMon.BusinessObject[i].GetFieldValueAsFloat('Unitprice')) + ' na ' + mString +chr(10) +chr(13);
                                                            mMon.BusinessObject[i].SetFieldValueAsFloat('Unitprice',NxIBStrToFloat(mstring));
                                                            //NxShowSimpleMessage('Změna ceny pro ' + mMon.BusinessObject[i].GetFieldValueAsString('StoreCard_ID.DisplayName') + ' z ' + NxFloatToIBStr(mMon.BusinessObject[i].GetFieldValueAsFloat('Unitprice')) +' na ' + NxFloatToIBStr(NxIBStrToFloat(mstring)) ,nil);
                                                     end;
                                                  end;
                                      end;
                                  end;
                      mCustomBusinessObject.save;
                      TDynSiteForm(msite).ActiveDataSet.RefreshCurrentItemMode;

              end;
              ProgressDispose()   ;
          if mXresult<>'' then NxShowSimpleMessage('Provedené změna na dokladech:' + chr(10)+chr(13) +mXResult,nil) else NxShowSimpleMessage('Aktualizace ukončena:',nil);
        end;
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
          mMAction.Hint := 'Doplnění cen ';
          mMAction.Caption := 'Aktializace cen API';
          mMAction.Items.Add('Aktualizace cen API ');
          mMAction.Category := 'tabList';
          mMAction.OnExecuteItem := @OnExec;

end;


begin
end.