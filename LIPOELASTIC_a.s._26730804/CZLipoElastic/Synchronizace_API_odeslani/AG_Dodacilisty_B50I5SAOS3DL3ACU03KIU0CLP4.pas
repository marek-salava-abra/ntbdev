  uses  '_Knihovny_ALL.Progress',
      '_Knihovny_ALL.Parse',
      '_Knihovny_ALL.head',
      'NxApiLib.lib','NxApiProp.Prop' ;



var
  mSite : TDynSiteForm;
  mfilter:string;
    mDoklad : string;
  i,ii : integer;
  mres,mres1,mr2: TStringList;
  mID: String;
  aaaaa: string;
  x:integer;
  aa:Double;
  mrResult:string;
  mfirm,mfirm_office: TNxCustomBusinessObject;
  mrow: TNxCustomBusinessObject;
  mbusorder,mbustransaction,mbusproject,mbankacount: TNxCustomBusinessObject;
  maddress: TNxCustomBusinessObject;
  mhead: TNxHeaderBusinessObject;
  mID_Store,mID_StoreCard,mIDdoklad,mID_odberatel, mID_dodavatel, mID_Docqueue, mID_BusOrder,mID_Division, mID_VatCountry,mID_Country, mID_Currency,mID_Vatrate,mID_Row: string;
  aresult:Boolean;
  mexistuje:string;
  oprava : boolean;
  mMon : TNxCustomBusinessMonikerCollection;
   mForm : TForm;
  mBtn : TButton;
  mLbl : TLabel;
  mEdtIC, mEdtDIC,mEdtName,mEdtStreet,mEdtCity,mEdtPostCode,mEdtCountry : TEdit;
  cbSrcUnits, cbDstUnits, cbStores, cbDivisions : TEdit;
  mP1, mP2, mP3 : TPanel;
  mI_modalresult:integer;
  mS_code:string;
  mList,mRowList:TStringList;
  mtext:string;
  mID_kost_symbol,mID_payment,mID_delivery:string;
  mCountryName:string;
  mtoESL:boolean;
  mKumulovane:boolean;



 procedure Synchronizace(Sender: TObject;index:integer;mKumulovane:boolean;mOnline:boolean);
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
  i,ii,iii,x:integer;
  mTarget:string;
 mr1:tstringlist;
 mMonRows,mMonBAtch:TNxCustomBusinessMonikerCollection;
 mMonBatches:TNxCustomBusinessMonikerCollection;
 mjson,mTargetJson,mQueryJson:TJSONSuperObject;
 mboolean:boolean;
 mNewQueryrow:string;
 mParseListValue:tstringlist;
 iRow,IBatch:integer;
 mDocrowbatchList:tstringlist;
 mReturnJSON:TJSONSuperObject;
 mReturnImportRow,mReturnOtherRow:double;
 mReturnNewDocNumber,mReturnNewDocID,mReturnSourceDoc:string;
 mxString:string;
 mTypImportu:string ;
 mFind:boolean;
 mUser:string;
 mQueryStringList:tstringlist;
begin
  mids:='';
  mReturnNewDocID:='';
  mReturnNewDocNumber:='';
  mReturnSourceDoc:='';
  mReturnImportRow:=0;
  mReturnOtherRow:=0;
  mfind:=true;

  if Sender is TComponent then mSite := TComponent(Sender).Site;
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

                  if (not mKumulovane) and (mBookmark.count=0) then begin
                  //   NxShowSimpleMessage('Pro operaci musíte mít označené položky', nil);
                  //   exit;
                  end;


                  mr:=tstringlist.create;
                  try
                       msite.BaseObjectSpace.SQLSelect('Select LoginName from SecurityUsers where ID=' + quotedstr(mSite.CompanyCache.GetUserID),mr);
                       if mr.count>0 then begin

                           mUser:=ReplaceText(mr.strings[0],'"','') ;
                       end;
                  finally
                      mr.free;
                  end;


                                              mIBookmark:=0;
                                              if mBookmark.count>0 then begin
                                                   mIBookmark:=mBookmark.count-1;
                                                   ProgressInit(msite, 'Zpracování dat ' + '', 100);
                                              end;
                                               mTypImportu:='';
                                                       if (index=0)  then mTypImportu:='OP';
                                                       if (index=1)  then mTypImportu:='OV';
                                                       if (index=2)  then mTypImportu:='PR';
                                                       if (index=3) then mTypImportu:='DL';
                                                       if (index=4)  then mTypImportu:='PRV';
                                                       if (index=5)  then mTypImportu:='PRP';
                                                       if (index=6)  then mTypImportu:='FV';





                                              for mICount:=0 to mIBookmark do begin
                                                  if mIBookmark>0 then begin
                                                       mDBGrid.DataSource.DataSet.GotoBookmark(mBookMark.items(mICount));
                                                       ProgressSetPos(1+NxFloor(mICount/mBookmark.Count*99), inttostr(mICount) +' z '+inttostr(mBookmark.Count));
                                                  end;
                                                  self:=TDynSiteForm(msite).CurrentObject;    // načtení objektu






                                                  if (not mKumulovane) or ((mKumulovane) and (mICount=0)) then begin
                                                           mquery:=NxGetAPIHeadJSON(msite.BaseObjectSpace,self,mTypImportu,mUser);
                                                  end;

                                                  mquery:=mquery + NxGetAPIDocument(msite.BaseObjectSpace,self);
                                                  if mICount<>mIBookmark then begin
                                                        mquery:=mquery + ',' + chr(10);
                                                  end;


                                                   if not mKumulovane then begin      // index=1 then begin
                                                           mquery:=mquery + ']';
                                                           mquery:=mquery + '}';

                                                        mquery:=mquery + '}';



                                                    if mOnline then begin
                                                          mTarget:='';
                                                          if NxIsEmptyOID(self.GetFieldValueAsString('Firm_ID.X_API_Conect_ID')) then begin
                                                                NxShowSimpleMessage(' Firma ' + self.GetFieldValueAsString('Firm_ID.Name') + ' nemá uvedenou API adresu , není možné pokračovat', nil);
                                                                exit;
                                                       end else begin
                                                                mTarget:=self.GetFieldValueAsString('Firm_ID.X_API_Conect_ID.X_CLSID');
                                                        end;


                                                           if (mSite.CompanyCache.GetUserID='SUPER00000') and (mICount=0) then
                                                                mboolean:=InputQuery('API','Post 1 doklad',mtarget+'/script/NxApiLib/lib/APINxImporManager' + Chr(10) + chr(10) +mQuery);


                                                           mxString:=APICallString(msite.BaseObjectSpace,'POST',mtarget+'/script/NxApiLib/lib/APINxImporManager',mQuery, true);
                                                                    //mReturnNewDocNumber:='';
                                                                    //mReturnSourceDoc:='';
                                                                    mReturnJSON:=TJSONSuperObject.create;
                                                                       try
                                                                       mReturnJSON:= TJSONSuperObject.ParseString(mxString,true);
                                                                           //mReturnNewDocID:=mReturnNewDocID + mReturnJSON.S['ID'] + ';';

                                                                             //if mIBookmark>0 then begin

                                                                                //if (copy(mReturnJSON.S['New'],1,29)<>'### Doklad nebyl vytvořen ###') and (mReturnJSON.S['New']<>'') then begin
                                                                                         // uživatel
                                                                                         // mxString:=APINxSQL_String(msite.BaseObjectSpace,mtarget,'UPDATE','CreatedBy_ID=' + QuotedStr('SUPER00000'),'StoreDocuments','ID=' + quotedstr(mReturnJSON.S['ID']));

                                                                                          mReturnNewDocNumber:=mReturnNewDocNumber + mReturnJSON.S['New'] ;
                                                                                          if NxIBStrToFloat(mReturnJSON.S['Other'])>0 then begin
                                                                                              mReturnNewDocNumber:=mReturnNewDocNumber + ',   Bez vazby: ' + mReturnJSON.S['Other'];
                                                                                          end;
                                                                                          if NxIBStrToFloat(mReturnJSON.S['Import'])>0 then begin
                                                                                              mReturnNewDocNumber:=mReturnNewDocNumber + '   Import.: ' + mReturnJSON.S['Import']
                                                                                                                 +' z dokladů: ' + mReturnJSON.S['Source']+ chr(10);
                                                                                          end;
                                                                                          mReturnNewDocNumber:=mReturnNewDocNumber + chr(10) ;

                                                                                    mReturnImportRow:=mReturnImportRow+ NxIBStrToFloat(mReturnJSON.S['Import']);
                                                                                    mReturnOtherRow:=mReturnOtherRow+NxIBStrToFloat(mReturnJSON.S['Other']);
                                                                                //end;

                                                                             //end;
                                                                    finally
                                                                        mReturnJSON.free;
                                                                    end;

                                                    end else begin


                                                          mTarget:='';
                                                          if NxIsEmptyOID(self.GetFieldValueAsString('Firm_ID.X_API_Conect_ID')) then begin
                                                                NxShowSimpleMessage(' Firma ' + self.GetFieldValueAsString('Firm_ID.Name') + ' nemá uvedenou API adresu , není možné pokračovat', nil);
                                                                exit;
                                                       end else begin
                                                               mTarget:=mExportDir + trim(copy(self.GetFieldValueAsString('Firm_ID.X_API_Conect_ID.X_CLSID'),20,50));

                                                                              mQueryStringList := TStringList.Create;
                                                                             try
                                                                                 mQueryStringList.add(mQuery);
                                                                                 mQueryStringList.SaveToFile(mTarget + '\'+mTypImportu+'\'
                                                                                         + self.GetFieldValueAsString('DocQueue_ID.CODE') + '_'
                                                                                         + inttostr(self.GetFieldValueAsinteger('Ordnumber')) + '_'
                                                                                         + self.GetFieldValueAsString('Period_ID.CODE')
                                                                                         + '.json');
                                                                              finally
                                                                                mQueryStringList.free;
                                                                              end;
                                                                         end;
                                                    end;
                                                   end;
                                              end;
                                                // ukončení abradocuments
                                                  if mKumulovane then begin
                                                      mquery:=mquery + ']';

                                                      mquery:=mquery + '}';

                                                      // mquery:=mquery + '}';
                                                    IF mOnline then begin
                                                           mTarget:='';
                                                          if NxIsEmptyOID(self.GetFieldValueAsString('Firm_ID.X_API_Conect_ID')) then begin
                                                                NxShowSimpleMessage(' Firma ' + self.GetFieldValueAsString('Firm_ID.Name') + ' nemá uvedenou API adresu , není možné pokračovat', nil);
                                                                exit;
                                                       end else begin
                                                                mTarget:=self.GetFieldValueAsString('Firm_ID.X_API_Conect_ID.X_CLSID');
                                                       end;
                                                    //************
                                                            if (mSite.CompanyCache.GetUserID='SUPER00000') and (mICount=0) then
                                                                  mboolean:=InputQuery('API','Post 1 doklad',mtarget+'/script/NxApiLib/lib/APINxImporManager' + Chr(10) + chr(10) +mQuery);
                                                          mString:=APICallString(msite.BaseObjectSpace,'POST',mtarget+'/script/NxApiLib/lib/APINxImporManager',mQuery, true);



                                                               //mReturnNewDocNumber:='';
                                                               //mReturnSourceDoc:='';
                                                               mReturnJSON:=TJSONSuperObject.create;
                                                               try
                                                               mReturnJSON:= TJSONSuperObject.ParseString(mString,true);
                                                                   if (copy(mReturnJSON.S['New'],1,29)<>'### Doklad nebyl vytvořen ###') and (mReturnJSON.S['New']<>'') then begin
                                                                     mReturnNewDocNumber:=mReturnNewDocNumber + mReturnJSON.S['New'] ;
                                                                                          if NxIBStrToFloat(mReturnJSON.S['Other'])>0 then begin
                                                                                              mReturnNewDocNumber:=mReturnNewDocNumber + ',   Bez vazby: ' + mReturnJSON.S['Other'];
                                                                                          end;
                                                                                          if NxIBStrToFloat(mReturnJSON.S['Import'])>0 then begin
                                                                                              mReturnNewDocNumber:=mReturnNewDocNumber + '   Import.: ' + mReturnJSON.S['Import']
                                                                                                                 +' z dokladů: ' + mReturnJSON.S['Source']+ chr(10);
                                                                                          end;
                                                                                          mReturnNewDocNumber:=mReturnNewDocNumber + chr(10) ;

                                                                                    mReturnImportRow:=mReturnImportRow+ NxIBStrToFloat(mReturnJSON.S['Import']);
                                                                                    mReturnOtherRow:=mReturnOtherRow+NxIBStrToFloat(mReturnJSON.S['Other']);
                                                                   end;
                                                              finally
                                                               mReturnJSON.free;
                                                              end;


                                                    end else begin
                                                           mTarget:='';
                                                          if NxIsEmptyOID(self.GetFieldValueAsString('Firm_ID.X_API_Conect_ID')) then begin
                                                                NxShowSimpleMessage(' Firma ' + self.GetFieldValueAsString('Firm_ID.Name') + ' nemá uvedenou API adresu , není možné pokračovat', nil);
                                                                exit;
                                                          end else begin
                                                                mTarget:=mExportDir + trim(copy(self.GetFieldValueAsString('Firm_ID.X_API_Conect_ID.X_CLSID'),20,50));

                                                          end;

                                                             mQueryStringList := TStringList.Create;
                                                               try
                                                                   mQueryStringList.add(mQuery);

                                                                   mQueryStringList.SaveToFile(mTarget + '\' + mTypImportu + '\'
                                                                                         + self.GetFieldValueAsString('DocQueue_ID.CODE') + '_'
                                                                                         + inttostr(self.GetFieldValueAsinteger('Ordnumber')) + '_'
                                                                                         + self.GetFieldValueAsString('Period_ID.CODE')
                                                                                         + '.json');
                                                                finally
                                                                  mQueryStringList.free;
                                                                end;
                                                    end;




                                                  end;

                                              end;
                                              if mBookmark.count>0 then ProgressDispose()   ;
                                              if mKumulovane then begin


                                                      if mOnline then begin

                                                                        mstring:='';
                                                                        mstring:=mstring + 'Operace dokončena: ' + chr(10)+ chr(10);
                                                                        if mReturnNewDocNumber<>'' then begin

                                                                            mstring:=mstring + 'Byl vytvořen doklad: ' + mReturnNewDocNumber + chr(10);
                                                                            if mReturnImportRow>0 then begin
                                                                                mstring:=mstring + 'Importovaných řádků: ' + NxFloatToIBStr(mReturnImportRow)
                                                                                                   +' z dokladů: ' + mReturnSourceDoc + chr(10);
                                                                            end;
                                                                            if mReturnOtherRow>0 then begin
                                                                                mstring:=mstring + 'Bez vazby: ' + NxFloatToIBStr(mReturnOtherRow) +chr(10);
                                                                            end;
                                                                            NxShowSimpleMessage(mstring,nil);
                                                                        end else begin
                                                                            mstring:=mstring + 'Doklad nebyl vytvořen: ' + chr(10);
                                                                             //NxShowSimpleMessage(mstring,nil);
                                                                              NxMessageBox('Chyba', 'Přenost dokladu neproběhl', mdConfirm, mdbOkCancel, 0, 0, true, nil) ;
                                                                              nxbeep(btfailure);
                                                                              exit;
                                                                        end;


                                                      end;


                                              end;

                                              if not mKumulovane then begin
                                                if monline then begin
                                                            mstring:='';
                                                            mstring:=mstring + 'Operace dokončena: ' + chr(10)+ chr(10);
                                                            mstring:=mstring + 'Byl vytvořen doklad: ' +chr(10);
                                                            mstring:=mstring + mReturnNewDocNumber + chr(10);



                                                           mstring:=mstring + 'Celkem řádků : ' + chr(10);
                                                            if mReturnImportRow>0 then begin
                                                                mstring:=mstring + 'Importovaných: ' + NxFloatToIBStr(mReturnImportRow);
                                                                if mReturnOtherRow>0 then mstring:=mstring +' , ' ;
                                                            end;
                                                            if mReturnOtherRow>0 then begin
                                                                mstring:=mstring + ' Bez vazby: ' + NxFloatToIBStr(mReturnOtherRow) +chr(10);
                                                            end;



                                                        if mReturnNewDocNumber<>'' then begin
                                                              NxShowSimpleMessage(mstring,nil);
                                                        end else begin
                                                              //NxShowSimpleMessage(mstring,nil);
                                                              NxMessageBox('Chyba', 'Přenost dokladu neproběhl', mdConfirm, mdbOkCancel, 0, 0, true, nil) ;
                                                              nxbeep(btfailure);
                                                              exit;
                                                        end


                                                end;



                                              end;

            end;
    end;

end;







//procedure FormCreate_Hook(Self: TSiteForm);
procedure x_InitSite_Hook(Self: TSiteForm);
var
  mAction: TBasicAction;
  mMAction: TMultiAction;
  mCAction: TBasicAction;
  mAList: TActionList;
  i : integer;
  mUserFilter: Boolean;
  mUser: TNxCustomBusinessObject;
begin
  mUser := Self.BaseObjectSpace.CreateObject('22AHIVDVAVE13C5S00CA141B44');            // přihlášený uživatel
  try
      mUser.Load(Self.CompanyCache.GetUserID, nil);

    if copy(muser.GetFieldValueAsString('X_Button_parametr'),9,1)='1' then begin    // hromadná změna stavu

            {    mMAction := Self.GetNewMultiAction;
                mMAction.ShowControl := True;
                mMAction.ShowMenuItem := True;
                mMAction.Caption := 'Offline Odeslání položky';
                mMAction.Hint := 'Odeslání položky ';
                mMAction.Category := 'tabList';
                mMAction.Items.Add('Offline API SK OP');
                mMAction.Items.Add('Offline API SK OV-OV');
                mMAction.Items.Add('Offline API SK OV-PR');
                mMAction.Items.Add('Offline API SK OP-DL');
                //mMAction.Items.Add('API SK OP-PRV');
                //mMAction.Items.Add('API SK OP-PRP');
                //mMAction.Items.Add('API SK OP-FV');
                mMAction.OnExecuteItem := @Souhrne_offline;  }



               { mMAction := Self.GetNewMultiAction;
                mMAction.ShowControl := True;
                mMAction.ShowMenuItem := True;
                mMAction.Caption := 'Online Odeslání položky';
                mMAction.Hint := 'Odeslání položky ';
                mMAction.Category := 'tabList';
                mMAction.Items.Add('Online API SK OP');
                mMAction.Items.Add('Online API SK OV-OV');
                mMAction.Items.Add('Online API SK OV-PR');
                mMAction.Items.Add('Online API SK OP-DL');
                //mMAction.Items.Add('API SK OP-PRV');
                //mMAction.Items.Add('API SK OP-PRP');
                //mMAction.Items.Add('API SK OP-FV');
                mMAction.OnExecuteItem := @Souhrne_Online;  }

                 mMAction := Self.GetNewMultiAction;
                mMAction.ShowControl := True;
                mMAction.ShowMenuItem := True;
                mMAction.Caption := 'Lipoelastic Export OFFline';
                mMAction.Hint := 'Odeslání položky 1:1 ';
                mMAction.Category := 'tabList';
                mMAction.Items.Add('Export Offline API OP 1:1');
                mMAction.Items.Add('Export Offline API OV-OV 1:1');
                mMAction.Items.Add('Export Offline API OV-PR 1:1');
                mMAction.Items.Add('Export Offline API OP-DL 1:1');
                //mMAction.Items.Add('API SK OP-PRV 1:1');
                //mMAction.Items.Add('API SK OP-PRP 1:1');
                //mMAction.Items.Add('API SK OP-FV 1:1');
                mMAction.OnExecuteItem := @PoDokladu_offline;


                mMAction := Self.GetNewMultiAction;
                mMAction.ShowControl := True;
                mMAction.ShowMenuItem := True;
                mMAction.Caption := 'Lipoelastic Export ONline';
                mMAction.Hint := 'Odeslání položky 1:1 ';
                mMAction.Category := 'tabList';
                mMAction.Items.Add('Export Online API OP 1:1');
                mMAction.Items.Add('Export Online API OV-OV 1:1');
                mMAction.Items.Add('Export Online API OV-PR 1:1');
                mMAction.Items.Add('Export Online API OP-DL 1:1');
                //mMAction.Items.Add('API SK OP-PRV 1:1');
                //mMAction.Items.Add('API SK OP-PRP 1:1');
                //mMAction.Items.Add('API SK OP-FV 1:1');
                mMAction.OnExecuteItem := @PoDokladu_Online;

          mMAction := Self.GetNewMultiAction;
                mMAction.ShowControl := True;
                mMAction.ShowMenuItem := True;
                mMAction.Hint := 'Lipoelastic OFFline import';
                mMAction.Caption := 'Hromadný import JSON z úložiště';
                mMAction.Items.Add('Offline import JSON');
                mMAction.Category := 'tabList';
                mMAction.OnExecuteItem := @OnExec;

   end;
finally
    muser.free;
end;

end;


procedure PoDokladu_online(Sender: TObject;index:integer);
begin
    mKumulovane:=false;
    Synchronizace(Sender,index,mKumulovane,true);
end;


procedure Souhrne_online(Sender: TObject;index:integer);
begin
    mKumulovane:=true;
    Synchronizace(Sender,index,mKumulovane,true);
end;

procedure PoDokladu_offline(Sender: TObject;index:integer);
begin
    mKumulovane:=false;
    Synchronizace(Sender,index,mKumulovane,false);
end;


procedure Souhrne_Offline(Sender: TObject;index:integer);
begin
    mKumulovane:=true;
    Synchronizace(Sender,index,mKumulovane,false);
end;



procedure OnExec(Sender: TComponent;index:integer);
var
   mDocrowbatchList:tstringlist;
 mReturnJSON:TJSONSuperObject;
 mReturnImportRow,mReturnOtherRow:double;
 mReturnNewDocNumber,mReturnNewDocID,mReturnSourceDoc:string;
  zadej:string;
  mfilename:string;
  mdir,mfile:string;
  mFileList:tstringlist;
  mStringlist:tstringlist;
  mQuery:string;
   mSite: TSiteForm;
  mDBGrid : TDBGrid;
 mTabList: TTabSheet;
 i,ii:integer;
 mString:string;
 mresult:boolean;
begin
  //mSite := NxFinddySiteForm(Sender);
  msite:=TComponent(Sender).DynSite;
        mFileList:=TStringList.create;
        try
                mdir:= msourceDir + '\DL\';
                NxGetFileList(mdir,mfilelist,'*.json',true);
                     ProgressInit(msite, 'Načtení souboru ' + '', 100);
                                for i:=0 to mFileList.count-1 do begin
                                     ProgressSetPos(1+NxFloor(i/mfilelist.Count*99), inttostr(i) +' z '+inttostr(mfilelist.Count));

                                     //NxShowSimpleMessage(mdir + mFileList.Strings[i]+'.json',nil);

                                     if not FileExists(mdir + mFileList.Strings[i]+'.json') then begin
                                          NxShowSimpleMessage('Soubor neexistuje , přerušuji', nil);
                                          //exit;
                                     end else begin

                                          mStringlist := TStringList.Create;
                                          try

                                              mfile:= mdir + mFileList.Strings[i]+'.json';
                                              mStringlist.loadFromFile(mfile);
                                              mQuery:='';
                                              for ii:=0 to mStringlist.count-1 do begin
                                                  mQuery:=mQuery+ mStringlist.Strings[ii]
                                              end;








                                              mString:=APICallString(msite.BaseObjectSpace,'POST',mSourceAPI + '/script/NxApiLib/lib/APINxImporManager',mQuery, true);

                                              mReturnJSON:=TJSONSuperObject.create;
                                                   try
                                                      mReturnJSON:= TJSONSuperObject.ParseString(mString,true);
                                                          if mReturnJSON.S['New']<>'' then begin
                                                                     // uživatel
                                                                     // mxString:=APINxSQL_String(msite.BaseObjectSpace,mtarget,'UPDATE','CreatedBy_ID=' + QuotedStr('SUPER00000'),'StoreDocuments','ID=' + quotedstr(mReturnJSON.S['ID']));

                                                                      mReturnNewDocNumber:=mReturnNewDocNumber + mReturnJSON.S['New'] ;
                                                                      if NxIBStrToFloat(mReturnJSON.S['Other'])>0 then begin
                                                                          mReturnNewDocNumber:=mReturnNewDocNumber + ',   Bez vazby: ' + mReturnJSON.S['Other'];
                                                                      end;
                                                                      if NxIBStrToFloat(mReturnJSON.S['Import'])>0 then begin
                                                                          mReturnNewDocNumber:=mReturnNewDocNumber + '   Import.: ' + mReturnJSON.S['Import']
                                                                                             +' z dokladů: ' + mReturnJSON.S['Source']+ chr(10);
                                                                      end;
                                                                      mReturnNewDocNumber:=mReturnNewDocNumber + chr(10) ;

                                                                mReturnImportRow:=mReturnImportRow+ NxIBStrToFloat(mReturnJSON.S['Import']);
                                                                mReturnOtherRow:=mReturnOtherRow+NxIBStrToFloat(mReturnJSON.S['Other']);




                                                             //   přesun souboru



                                                             mresult:=nxcopyfile(mfile,mdir + 'Zpracovane\' + mFileList.Strings[i]+'.json');

                                                                      if mresult then begin
                                                                          DeleteFile(mfile);
                                                                      end;




                                                          end;
                                                    finally
                                                        mReturnJSON.free;
                                                    end;





                                          finally
                                              mStringlist.free;
                                          end;


                                     end;


                                end;

                     ProgressDispose()   ;

                     mstring:='';
                                                            mstring:=mstring + 'Operace dokončena: ' + chr(10)+ chr(10);
                                                            mstring:=mstring + 'Byl vytvořen doklad: ' +chr(10);
                                                            mstring:=mstring + mReturnNewDocNumber + chr(10);



                                                           mstring:=mstring + 'Celkem řádků : ' + chr(10);
                                                            if mReturnImportRow>0 then begin
                                                                mstring:=mstring + 'Importovaných: ' + NxFloatToIBStr(mReturnImportRow);
                                                                if mReturnOtherRow>0 then mstring:=mstring +' , ' ;
                                                            end;
                                                            if mReturnOtherRow>0 then begin
                                                                mstring:=mstring + ' Bez vazby: ' + NxFloatToIBStr(mReturnOtherRow) +chr(10);
                                                            end;


                                                        if mReturnNewDocNumber<>'' then begin
                                                              NxShowSimpleMessage(mstring,nil);
                                                        end else begin
                                                              //NxShowSimpleMessage(mstring,nil);
                                                              NxMessageBox('Chyba', 'Přenost dokladu neproběhl', mdConfirm, mdbOkCancel, 0, 0, true, nil) ;
                                                              nxbeep(btfailure);
                                                              exit;
                                                        end;


        finally
            mFileList.free;

        end;



  //TDynSiteForm(mSite).Refreshdata;
//  msite.activedataset.RefreshCurrentItem;
 // msite.activedataset.RefreshAndRestoreLastSelectedItem;
end;




begin
end.





