  uses  '_Knihovny_ALL.Progress',
      '_Knihovny_ALL.Parse',
      '_Knihovny_ALL.head',
      'NxApiLib.lib','NxApiProp.Prop'

;
const
mtable='Storedocuments';


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









  procedure x_CanDelete_Hook(Self: TDynSiteForm; var ACanDelete: Boolean);
begin
 if not(osNew in self.CurrentObject.State) then begin
   if trim(self.CurrentObject.GetFieldValueAsString('X_ExternalDocument'))<>'' then begin
           ACanDelete:=false;
           NxShowSimpleMessage('Vymazání zamítnuto. Doklad byl ' + FormatDateTime('DD.MM.YYYY',self.CurrentObject.GetFieldValueAsDateTime('X_Synchronizace$Date')) +' odeslán na Slovensko, vymažte napřed doklad ' + self.CurrentObject.GetFieldValueAsString('X_ExternalDocument') + ' na Slovensku.',Self);
   end;
 end;
end;

procedure x_CanEdit_Hook(Self: TDynSiteForm; var ACanEdit: Boolean);
begin
 if not(osNew in self.CurrentObject.State) then begin
   if trim(self.CurrentObject.GetFieldValueAsString('X_ExternalDocument'))<>'' then begin
           ACanEdit:=false;
           NxShowSimpleMessage('Oprava zamítnuta. Doklad byl ' + FormatDateTime('DD.MM.YYYY',self.CurrentObject.GetFieldValueAsDateTime('X_Synchronizace$Date')) +' odeslán na Slovensko, vymažte napřed doklad ' + self.CurrentObject.GetFieldValueAsString('X_ExternalDocument') + ' na Slovensku.',Self);
   end;
 end;
end;













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
  i,ii,iii,x:integer;
  mTarget:string;
 mr1:tstringlist;
 mMonRows,mMonBAtch:TNxCustomBusinessMonikerCollection;
 mMonBatches:TNxCustomBusinessMonikerCollection;
 mJSON,mTargetJson,mQueryJson:TJSONSuperObject;
 mJSONArraynHead,mJSONArrayRows,mJSONArrayBatches:TJSONSuperObjectArray;
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
 mStore_Code,mDivison_Code:string;
 mImport:boolean;
 mOK:string;
 mChyba:string;
 mInfo:string;
 mVystup:string;
 mKumulovane:boolean;mOnline:boolean ;
 mPocetDokladu:integer;
begin
mPocetDokladu:=0;
mKumulovane:=false;
mOnline:=true;
  mids:='';
  mReturnNewDocID:='';
  mReturnNewDocNumber:='';
  mReturnSourceDoc:='';
  mReturnImportRow:=0;
  mReturnOtherRow:=0;
  mfind:=true;
  mOK:='';
  mChyba:='';
  mInfo:='';


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




                                              for mICount:=0 to mIBookmark do begin
                                                  mJSON:=TJSONSuperObject.create;
                                                  try
                                                  if mIBookmark>0 then begin
                                                       mDBGrid.DataSource.DataSet.GotoBookmark(mBookMark.items(mICount));
                                                       ProgressSetPos(1+NxFloor(mICount/mBookmark.Count*99), inttostr(mICount) +' z '+inttostr(mBookmark.Count));
                                                  end;
                                                  self:=TDynSiteForm(msite).CurrentObject;    // načtení objektu

                                                             mTypImportu:='';
                                                             case inttostr(index) of
                                                                  '0': begin
                                                                       mChyba:= mChyba + Chr(13)+ Chr(10) + 'Doklad: ' + self.DisplayName  ;
                                                                                                    mchyba:= mchyba  + Chr(13)+ Chr(10) + '       Chyba: ' + 'Stavovost dokladu zatím není podporována'  ;
                                                                                //exit;
                                                                       end;
                                                                  '1': begin
                                                                            mTypImportu:='OP';
                                                                            if (trim(self.GetFieldValueAsString('DocQueue_ID.X_API_OP'))='') or
                                                                               (trim(self.GetFieldValueAsString('DocQueue_ID.X_API_OP'))='{}') then begin
                                                                                mChyba:= mChyba + Chr(13)+ Chr(10) + 'Doklad: ' + self.DisplayName  ;
                                                                                                    mchyba:= mchyba  + Chr(13)+ Chr(10) + '       Chyba: ' + 'Není možné synchronizovat - nejsou parametry'  ;
                                                                                //exit;
                                                                            end else begin
                                                                                mJSON := TJSONSuperObject.ParseString(self.GetFieldValueAsString('DocQueue_ID.X_API_OP'), True);
                                                                            end;
                                                                       end;
                                                                  '2': begin
                                                                            mTypImportu:='OV';
                                                                            if (trim(self.GetFieldValueAsString('DocQueue_ID.X_API_OV'))='') or
                                                                               (trim(self.GetFieldValueAsString('DocQueue_ID.X_API_OV'))='{}') then begin
                                                                                mChyba:= mChyba + Chr(13)+ Chr(10) + 'Doklad: ' + self.DisplayName  ;
                                                                                                    mchyba:= mchyba  + Chr(13)+ Chr(10) + '       Chyba: ' + 'Není možné synchronizovat - nejsou parametry'  ;
                                                                                //exit;
                                                                            end else begin
                                                                                mJSON := TJSONSuperObject.ParseString(self.GetFieldValueAsString('DocQueue_ID.X_API_OV'), True);
                                                                            end;
                                                                       end;
                                                                  '3': begin
                                                                            mTypImportu:='PR';
                                                                            if (trim(self.GetFieldValueAsString('DocQueue_ID.X_API_PR'))='') or
                                                                               (trim(self.GetFieldValueAsString('DocQueue_ID.X_API_PR'))='{}') then begin
                                                                                mChyba:= mChyba + Chr(13)+ Chr(10) + 'Doklad: ' + self.DisplayName  ;
                                                                                                    mchyba:= mchyba  + Chr(13)+ Chr(10) + '       Chyba: ' + 'Není možné synchronizovat - nejsou parametry'  ;
                                                                                //exit;
                                                                            end else begin
                                                                                mJSON := TJSONSuperObject.ParseString(self.GetFieldValueAsString('DocQueue_ID.X_API_PR'), True);
                                                                            end;
                                                                       end;
                                                                  '4': begin
                                                                            mTypImportu:='DL';
                                                                            if (trim(self.GetFieldValueAsString('DocQueue_ID.X_API_DL'))='') or
                                                                               (trim(self.GetFieldValueAsString('DocQueue_ID.X_API_DL'))='{}') then begin
                                                                                mChyba:= mChyba + Chr(13)+ Chr(10) + 'Doklad: ' + self.DisplayName  ;
                                                                                                    mchyba:= mchyba  + Chr(13)+ Chr(10) + '       Chyba: ' + 'Není možné synchronizovat - nejsou parametry'  ;
                                                                                //exit;
                                                                            end else begin
                                                                                mJSON := TJSONSuperObject.ParseString(self.GetFieldValueAsString('DocQueue_ID.X_API_DL'), True);
                                                                                    if UpperCase(trim(self.GetFieldValueAsString('DocQueue_ID.code')))='DPE' then begin
                                                                                       if TDynSiteForm(msite).BaseObjectSpace.SQLSelectFirstAsString('select DQ.Code from storedocuments2 sd2 left join Receivedorders RO on ro.id=sd2.Provide_ID left join docqueues DQ on dq.id=ro.docqueue_ID where parent_ID=' + QuotedStr(self.oid),'') = 'OPSB' then begin
                                                                                             mJSON.S['DocQueue_Code']:='SDPE';
                                                                                       end;
                                                                                    end;
                                                                            end;
                                                                       end;
                                                                   '5': begin
                                                                            mTypImportu:='PRE';
                                                                            if (trim(self.GetFieldValueAsString('DocQueue_ID.X_API_PRE'))='') or
                                                                               (trim(self.GetFieldValueAsString('DocQueue_ID.X_API_PRE'))='{}') then begin
                                                                                mChyba:= mChyba + Chr(13)+ Chr(10) + 'Doklad: ' + self.DisplayName  ;
                                                                                                    mchyba:= mchyba  + Chr(13)+ Chr(10) + '       Chyba: ' + 'Není možné synchronizovat - nejsou parametry'  ;
                                                                                //exit;
                                                                            end else begin
                                                                                mJSON := TJSONSuperObject.ParseString(self.GetFieldValueAsString('DocQueue_ID.X_API_PRE'), True);
                                                                            end;
                                                                       end;
                                                               end;
                                                       mJSON.S['User']:=mUser;
                                                       mStore_Code:=mJSON.S['Store_Code'];
                                                       mDivison_Code:=mJSON.S['Division_Code'];
                                                       if UpperCase(mJSON.S['Import'])='TRUE' then mImport:=true else mImport:=false;

                                                       // **** vyjímky *****





                                                  if true then begin     //mOnline
                                                         if NxIsEmptyOID(self.GetFieldValueAsString('Firm_ID.X_API_Conect_ID')) then begin
                                                                NxShowSimpleMessage(' Firma ' + self.GetFieldValueAsString('Firm_ID.Name') + ' nemá uvedenou API adresu , není možné pokračovat', nil);
                                                       end else begin
                                                                mTarget:=self.GetFieldValueAsString('Firm_ID.X_API_Conect_ID.X_CLSID');
                                                                   mJSON:=GetDocJSON_new(mJSON,self,mStore_Code,mDivison_Code,mImport, NxCreateContext_1(self),0,mTarget);
                                                                  if (mSite.CompanyCache.GetUserID='SUPER00000') and (mICount=0) then begin


                                                                       //mboolean:=InputQuery('API','Post 1 doklad',);
                                                                       mstring:=BarCode_document(mSite,'05CPMINJW3DL342X01C0CX3FCC',0,0,720,960, 'Target document ' + IntToStr(micount),'Json : ',
                                                                       mtarget+'/script/NxApiLib/lib/APINxJSONImportManager' + Chr(10) + chr(10) +mJSON.AsString
                                                                       ,'Pokračovat','','');

                                                                  end;

                                                                       mString:=APICallString(msite.BaseObjectSpace,'POST',mtarget+'/script/NxApiLib/lib/APINxJSONImportManager',mJSON.AsString, true);
                                                                       //NxShowSimpleMessage(mString,nil);
                                                                       mReturnJSON:=TJSONSuperObject.create;
                                                                             try
                                                                             mReturnJSON:= TJSONSuperObject.ParseString(mString,true);

                                                                                  case Trim(UpperCase(mReturnJSON.S['State'])) of
                                                                                        '201': begin
                                                                                             mOK:= mOK  + Chr(13)+ Chr(10) + 'Z ' +  'dokladu: ' + self.DisplayName + ' vznikl doklad ' + NxSearchReplace(mReturnJSON.S['New'],'_','/',[srCase,srAll]) ;
                                                                                                 if NxIBStrToFloat(mReturnJSON.S['Import'])>0 then begin
                                                                                                          mOK:= mOK  + Chr(13)+ Chr(10) + '       čerpáním ' + mReturnJSON.S['Import'] + ' řádků / '  + mReturnJSON.S['Imp_batch'] + ' šarží';
                                                                                                  end;
                                                                                                  if NxIBStrToFloat(mReturnJSON.S['Other'])>0 then begin
                                                                                                          mOK:= mOK  + Chr(13)+ Chr(10) + '       bez vazby ' + mReturnJSON.S['Other'] + ' řádků / '  + mReturnJSON.S['Oth_batch'] + ' šarží';
                                                                                                  end;
                                                                                                  if nxisblank(self.GetFieldValueAsString('X_ExternalDocument')) then begin
                                                                                                         try
                                                                                                               mi:=msite.BaseObjectSpace.SQLExecute('Update ' + mtable + ' set X_Synchronizace$Date=' + quotedstr(NxFloatToIBStr(Now)) + ', X_ExternalDocument=' + quotedstr(NxSearchReplace(mReturnJSON.S['New'],'_','/',[srCase,srAll])) + ' where id= ' + quotedstr(self.oid));
                                                                                                          finally
                                                                                                          end;
                                                                                                  end;
                                                                                                  mPocetDokladu:=mPocetDokladu+1;
                                                                                             end;
                                                                                        '400': begin
                                                                                             mChyba:= mChyba + Chr(13)+ Chr(10) + 'Doklad: ' + self.DisplayName  ;
                                                                                                    mchyba:= mchyba  + Chr(13)+ Chr(10) + '       Chyba: ' + mReturnJSON.S['Error']  ;

                                                                                             end;
                                                                                        '200': begin
                                                                                             mInfo:= mInfo +  Chr(13)+ Chr(10) + 'Doklad: ' + self.DisplayName  ;
                                                                                                    mInfo:= mInfo + Chr(13)+ Chr(10)
                                                                                                    + 'Dne: ' + FormatDateTime('D.M.YY',NxIBStrToFloat(mReturnJSON.S['Error']))
                                                                                                    + ' byl již vytvořen : ' +NxSearchReplace(mReturnJSON.S['New'],'_','/',[srCase,srAll])+ ' uživatelem ' +  mReturnJSON.S['Created_by'] +   Chr(10)+ Chr(13);

                                                                                             end;
                                                                                   end;

                                                                            finally
                                                                             mReturnJSON.free;
                                                                            end;









                                                           end;
                                                    end;






                                                      finally
                                                          mJSON.free;
                                                      end;

                                              end;
                                              end;
                                              if mBookmark.count>0 then ProgressDispose()   ;


            end;


    TDynSiteForm(msite).ActiveDataSet.RefreshAndRestoreLastSelectedItem;

    end;
  mVystup:='';
  if mChyba<>'' then begin
      mVystup:=mVystup + ' # # #  Chyba importu  # # # ' ;
      mVystup:=mVystup + chr(13) + chr(10) ;
      mVystup:=mVystup + mChyba ;
      mVystup:=mVystup + chr(13) + chr(10) ;
      mVystup:=mVystup + ' - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - ' ;
      mVystup:=mVystup + chr(13) + chr(10) ;
      mVystup:=mVystup + chr(13) + chr(10) ;
      mVystup:=mVystup + chr(13) + chr(10) ;
  end;

  if mInfo<>'' then begin
      mVystup:=mVystup + ' # # #  Import neproveden  # # # ' ;
      mVystup:=mVystup + chr(13) + chr(10) ;
      mVystup:=mVystup + mInfo ;
      mVystup:=mVystup + chr(13) + chr(10) ;
      mVystup:=mVystup + ' - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - ' ;
      mVystup:=mVystup + chr(13) + chr(10) ;
      mVystup:=mVystup + chr(13) + chr(10) ;
      mVystup:=mVystup + chr(13) + chr(10) ;
  end;

  if mOK<>'' then begin
      mVystup:=mVystup + ' * * *  Importováno  * * * ' ;
      mVystup:=mVystup + chr(13) + chr(10) ;
      mVystup:=mVystup + mOK ;
      mVystup:=mVystup + chr(13) + chr(10) ;
      mVystup:=mVystup + ' - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - ' ;
      mVystup:=mVystup + chr(13) + chr(10) ;
      mVystup:=mVystup + chr(13) + chr(10) ;
      mVystup:=mVystup + chr(13) + chr(10) ;
      mVystup:=mVystup + 'Bylo vytvořeno ' + inttostr(mPocetDokladu) + ' dokladu' +  chr(13) + chr(10) ;
  end;

 if mVystup<>'' then begin
                           mstring:=BarCode_document(mSite,'05CPMINJW3DL342X01C0CX3FCC',0,0,720,960, 'Výsledek','Doklady : ',mVystup,'Pokračovat','','');
  end else begin
      NxShowSimpleMessage('Nespecifikovaná chyba , prosím kontaktujte administrátora',nil);
  end;
            //TDynSiteForm(msite).RefreshData

end;







//procedure FormCreate_Hook(Self: TSiteForm);
procedure InitSite_Hook(Self: TSiteForm);
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




                mMAction := Self.GetNewMultiAction;
                mMAction.ShowControl := True;
                mMAction.ShowMenuItem := True;
                mMAction.Caption := 'Doklad v ABRA SK';
                mMAction.Hint := 'Odeslání položky 1:1 ';
                mMAction.Category := 'tabList';
                mMAction.Items.Add('Podle stavu dokladu');
                mMAction.Items.Add('Objednávka přijatá');
                mMAction.Items.Add('Objednávka vydaná');
                mMAction.Items.Add('Příjemka');
                mMAction.Items.Add('Dodací list');
                mMAction.Items.Add('Převodka výdej');
                mMAction.OnExecuteItem := @Synchronizace;



   end;
finally
    muser.free;
end;

end;









begin
end.





