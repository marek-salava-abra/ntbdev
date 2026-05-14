  uses  '_Knihovny_ALL.Progress',
      '_Knihovny_ALL.Parse',
      '_Knihovny_ALL.head',
      'NxApiLib.lib' ;

      //Function NxGetAPIHeadJSON(msite:TSiteForm;self:TNxCustomBusinessObject;mTypImportu:string;mUser:string):string;

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



 procedure Synchronizace(Sender: TObject;index:integer;mKumulovane:boolean);
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

                  if index=0 then begin

                  end;
                  mBookmark := mDBGrid.SelectedRows; // *** v mBookmark jsou id označených záznamu
                  if (not mKumulovane) and (mBookmark.count=0) then begin
                     NxShowSimpleMessage('Pro operaci musíte mít označené položky', nil);
                     exit;
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
                                                  if mBookmark.count>0 then begin
                                                       mDBGrid.DataSource.DataSet.GotoBookmark(mBookMark.items(mICount));
                                                       ProgressSetPos(1+NxFloor(mICount/mBookmark.Count*99), inttostr(mICount) +' z '+inttostr(mBookmark.Count));
                                                  end;
                                                  self:=TDynSiteForm(msite).CurrentObject;    // načtení objektu

                                                  if (not mKumulovane) or ((mKumulovane) and (mICount=0)) then begin
                                                              mquery:='{'   +chr(10);

                                                                   // op
                                                                   if mTypImportu='OP' then begin
                                                                              mquery:=mquery + ' "input_document_clsid":"' +  '01CPMINJW3DL342X01C0CX3FCC'  +'", ';
                                                                              mquery:=mquery + ' "output_document_clsid":"' +  '01CPMINJW3DL342X01C0CX3FCC'  +'", '+chr(10);
                                                                              mfind:=false;
                                                                                   case self.GetFieldValueAsString('DocQueue_ID.CODE') of
                                                                                     '': begin
                                                                                               mquery:=mquery + ' "DocQueue_Code":"' +  'OP'  +'", ';
                                                                                               mquery:=mquery + ' "Store_Code":"' +  'S22'  +'", ';
                                                                                                 mfind:=true;
                                                                                             end;
                                                                                   end;
                                                                                     if not mFind then begin
                                                                                          mquery:=mquery + ' "DocQueue_Code":"' +  'OP'  +'", ';
                                                                                          mquery:=mquery + ' "Store_Code":"' +  'S22'  +'", ';
                                                                                          mFind:=true;
                                                                                     end;
                                                                              mquery:=mquery + ' "Debug":"' +  'False'  +'",'+chr(10);
                                                                              mquery:=mquery + ' "WithPrices":"' +  'True'  +'",'+chr(10);
                                                                              mquery:=mquery + ' "Sales":"' +  'False'  +'",'+chr(10);
                                                                              mquery:=mquery + ' "Email":"' +  'mskacel@lipoelastic.com'  +'",'+chr(10);
                                                                              mquery:=mquery + ' "Report_ID":"' +  '1WI0000101'  +'",'+chr(10);
                                                                              mquery:=mquery + ' "Msg":"' +  'SUPER00000'  +'",'+chr(10);
                                                                              mquery:=mquery + ' "DocumentType":"' +  ''  +'",'+chr(10);
                                                                              mquery:=mquery + ' "ImportAllDocument":"' +  'False'  +'",'+chr(10);
                                                                              mquery:=mquery + ' "Firm_Name":"' +  TDynSiteForm(msite).CurrentObject.GetFieldValueAsString('Firm_ID.name')  +'", ';

                                                                   end;

                                                                   // ov
                                                                   if mTypImportu='OV' then begin
                                                                              mquery:=mquery + ' "input_document_clsid":"' +  '01CPMINJW3DL342X01C0CX3FCC'  +'", ';
                                                                              mquery:=mquery + ' "output_document_clsid":"' +  'CDMK5QAWZZDL342X01C0CX3FCC'  +'", '+chr(10);
                                                                                   mfind:=false;
                                                                                   case self.GetFieldValueAsString('DocQueue_ID.CODE') of
                                                                                     '': begin
                                                                                               mquery:=mquery + ' "DocQueue_Code":"' +  'OV'  +'", ';
                                                                                               mquery:=mquery + ' "Store_Code":"' +  'S22'  +'", ';
                                                                                                 mfind:=true;
                                                                                             end;
                                                                                   end;
                                                                                     if not mFind then begin
                                                                                          mquery:=mquery + ' "DocQueue_Code":"' +  'OV'  +'", ';
                                                                                          mquery:=mquery + ' "Store_Code":"' +  'S22'  +'", ';
                                                                                          mFind:=true;
                                                                                     end;

                                                                              mquery:=mquery + ' "Debug":"' +  'False'  +'",'+chr(10);
                                                                              mquery:=mquery + ' "WithPrices":"' +  'True'  +'",'+chr(10);
                                                                              mquery:=mquery + ' "Sales":"' +  'False'  +'",'+chr(10);
                                                                              mquery:=mquery + ' "Email":"' +  'mskacel@lipoelastic.com'  +'",'+chr(10);
                                                                              mquery:=mquery + ' "Report_ID":"' +  '2NI0000101'  +'",'+chr(10);
                                                                              mquery:=mquery + ' "Msg":"' +  'SUPER00000'  +'",'+chr(10);
                                                                              mquery:=mquery + ' "DocumentType":"' +  ''  +'",'+chr(10);
                                                                              mquery:=mquery + ' "ImportAllDocument":"' +  'False'  +'",'+chr(10);
                                                                              mquery:=mquery + ' "Firm_Name":"' +  TDynSiteForm(msite).CurrentObject.GetFieldValueAsString('Firm_ID.name')  +'", ';
                                                                   end;


                                                                   // pr
                                                                   if mTypImportu='PR' then begin
                                                                              mquery:=mquery + ' "input_document_clsid":"' +  'CDMK5QAWZZDL342X01C0CX3FCC'  +'", ';
                                                                              mquery:=mquery + ' "output_document_clsid":"' +  'E03ZNUMDTCC4PDAUIEY1MBTJC0'  +'", '+chr(10);

                                                                              mfind:=false;
                                                                         case self.GetFieldValueAsString('DocQueue_ID.CODE') of
                                                                           'DPE': begin
                                                                                     mquery:=mquery + ' "DocQueue_Code":"' +  'SPPT'  +'", ';
                                                                                     mquery:=mquery + ' "Store_Code":"' +  'S22'  +'", ';
                                                                                       mfind:=true;
                                                                                   end;
                                                                            'DPPO': begin
                                                                                     mquery:=mquery + ' "DocQueue_Code":"' +  'SPVM'  +'", ';
                                                                                     mquery:=mquery + ' "Store_Code":"' +  'S0103'  +'", ';
                                                                                       mfind:=true;
                                                                                   end;
                                                                         end;
                                                                           if not mFind then begin
                                                                                mquery:=mquery + ' "DocQueue_Code":"' +  'SPPT'  +'", ';
                                                                                mquery:=mquery + ' "Store_Code":"' +  'S22'  +'", ';
                                                                                mFind:=true;
                                                                           end;


                                                                              // mquery:=mquery + ' "DocQueue_Code":"' +  'PVRO'  +'", ';

                                                                              mquery:=mquery + ' "Debug":"' +  'False'  +'",'+chr(10);
                                                                              mquery:=mquery + ' "WithPrices":"' +  'True'  +'",'+chr(10);
                                                                              mquery:=mquery + ' "Sales":"' +  'False'  +'",'+chr(10);
                                                                              mquery:=mquery + ' "Email":"' +  ''  +'",'+chr(10);
                                                                              mquery:=mquery + ' "Report_ID":"' +  ''  +'",'+chr(10);
                                                                              mquery:=mquery + ' "Msg":"' +  ''  +'",'+chr(10);
                                                                              mquery:=mquery + ' "DocumentType":"' +  ''  +'",'+chr(10);
                                                                              mquery:=mquery + ' "ImportAllDocument":"' +  'False'  +'",'+chr(10);
                                                                              mquery:=mquery + ' "Firm_Name":"' +  'LIPOELASTIC a.s.'  +'", ';
                                                                   end;

                                                                   // dl
                                                                   if mTypImportu='DL' then begin
                                                                              mquery:=mquery + ' "input_document_clsid":"' +  '01CPMINJW3DL342X01C0CX3FCC'  +'", ';
                                                                              mquery:=mquery + ' "output_document_clsid":"' +  '050I5SAOS3DL3ACU03KIU0CLP4'  +'", '+chr(10);

                                                                        mfind:=false;
                                                                         case copy(self.GetFieldValueAsString('Description'),1,4) of
                                                                           'SOVB': begin
                                                                                     mquery:=mquery + ' "DocQueue_Code":"' +  'SDPE'  +'", ';
                                                                                     mquery:=mquery + ' "Store_Code":"' +  'S22'  +'", ';
                                                                                       mfind:=true;
                                                                                   end;
                                                                           'SOVE': begin
                                                                                     mquery:=mquery + ' "DocQueue_Code":"' +  'SDPI'  +'", ';
                                                                                     mquery:=mquery + ' "Store_Code":"' +  'S22'  +'", ';
                                                                                     mfind:=true;
                                                                                   end;
                                                                          end;
                                                                           if not mFind then begin
                                                                               mquery:=mquery + ' "DocQueue_Code":"' +  'SDPI'  +'", ';
                                                                               mquery:=mquery + ' "Store_Code":"' +  'S22'  +'", ';
                                                                               mFind:=true;
                                                                           end;

                                                                             //if copy(self.GetFieldValueAsString('Description'),1,4)='SOVB' then begin
                                                                             //     mquery:=mquery + ' "DocQueue_Code":"' +  'SDPE'  +'", ';
                                                                             // end else begin
                                                                             //     mquery:=mquery + ' "DocQueue_Code":"' +  'SDPI'  +'", ';
                                                                             // end;
                                                                              mquery:=mquery + ' "Debug":"' +  'False'  +'",'+chr(10);
                                                                              mquery:=mquery + ' "WithPrices":"' +  'False'  +'",'+chr(10);
                                                                              mquery:=mquery + ' "Sales":"' +  'False'  +'",'+chr(10);
                                                                              mquery:=mquery + ' "Email":"' +  ''  +'",'+chr(10);
                                                                              mquery:=mquery + ' "Report_ID":"' +  ''  +'",'+chr(10);
                                                                              mquery:=mquery + ' "Msg":"' +  ''  +'",'+chr(10);
                                                                              mquery:=mquery + ' "DocumentType":"' +  '20'  +'",'+chr(10);
                                                                              mquery:=mquery + ' "ImportAllDocument":"' +  'True'  +'",'+chr(10);
                                                                              mquery:=mquery + ' "Firm_Name":"' +  '' +'", ';
                                                                   end;

                                                                   // prev
                                                                   if mTypImportu='PRV' then begin
                                                                              mquery:=mquery + ' "input_document_clsid":"' +  '01CPMINJW3DL342X01C0CX3FCC'  +'", ';
                                                                              mquery:=mquery + ' "output_document_clsid":"' +  '0P0I5SAOS3DL3ACU03KIU0CLP4'  +'", '+chr(10);
                                                                         mfind:=false;
                                                                         case copy(self.GetFieldValueAsString('Description'),1,4) of
                                                                           '': begin
                                                                                     mquery:=mquery + ' "DocQueue_Code":"' +  'XPT'  +'", ';
                                                                                     mquery:=mquery + ' "Store_Code":"' +  'S22'  +'", ';
                                                                                       mfind:=true;
                                                                                   end;
                                                                          end;
                                                                           if not mFind then begin
                                                                               mquery:=mquery + ' "DocQueue_Code":"' +  'XPT'  +'", ';
                                                                               mquery:=mquery + ' "Store_Code":"' +  'S22'  +'", ';
                                                                               mFind:=true;
                                                                           end;
                                                                              mquery:=mquery + ' "Debug":"' +  'False'  +'",'+chr(10);
                                                                              mquery:=mquery + ' "Sales":"' +  'False'  +'",'+chr(10);
                                                                              mquery:=mquery + ' "Email":"' +  ''  +'",'+chr(10);
                                                                              mquery:=mquery + ' "Report_ID":"' +  ''  +'",'+chr(10);
                                                                              mquery:=mquery + ' "Msg":"' +  ''  +'",'+chr(10);
                                                                              mquery:=mquery + ' "DocumentType":"' +  ''  +'",'+chr(10);
                                                                              mquery:=mquery + ' "ImportAllDocument":"' +  'False'  +'",'+chr(10);
                                                                              mquery:=mquery + ' "Firm_Name":"' +  TDynSiteForm(msite).CurrentObject.GetFieldValueAsString('Firm_ID.name')  +'", ';
                                                                   end;
                                                                   // prep
                                                                   if mTypImportu='PRP' then begin
                                                                              mquery:=mquery + ' "input_document_clsid":"' +  '0P0I5SAOS3DL3ACU03KIU0CLP4'  +'", ';
                                                                              mquery:=mquery + ' "output_document_clsid":"' +  'E03ZNUMDTCC4PDAUIEY1MBTJC0'  +'", '+chr(10);
                                                                               mfind:=false;
                                                                         case copy(self.GetFieldValueAsString('Description'),1,4) of
                                                                           '': begin
                                                                                     mquery:=mquery + ' "DocQueue_Code":"' +  'YPT'  +'", ';
                                                                                     mquery:=mquery + ' "Store_Code":"' +  'S22'  +'", ';
                                                                                       mfind:=true;
                                                                                   end;
                                                                          end;
                                                                           if not mFind then begin
                                                                               mquery:=mquery + ' "DocQueue_Code":"' +  'YPT'  +'", ';
                                                                               mquery:=mquery + ' "Store_Code":"' +  'S22'  +'", ';
                                                                               mFind:=true;
                                                                           end;
                                                                              mquery:=mquery + ' "Debug":"' +  'False'  +'",'+chr(10);
                                                                              mquery:=mquery + ' "Store_Code":"' +  'S22'  +'", ';
                                                                              mquery:=mquery + ' "Sales":"' +  'False'  +'",'+chr(10);
                                                                              mquery:=mquery + ' "Email":"' +  'mskacel@lipoelastic.com'  +'",'+chr(10);
                                                                              mquery:=mquery + ' "Report_ID":"' +  ''  +'",'+chr(10);
                                                                              mquery:=mquery + ' "Msg":"' +  'SUPER00000'  +'",'+chr(10);
                                                                              mquery:=mquery + ' "DocumentType":"' +  ''  +'",'+chr(10);
                                                                              mquery:=mquery + ' "ImportAllDocument":"' +  'False'  +'",'+chr(10);
                                                                              mquery:=mquery + ' "Firm_Name":"' +  TDynSiteForm(msite).CurrentObject.GetFieldValueAsString('Firm_ID.name')  +'", ';
                                                                   end;
                                                                   if mTypImportu='FV' then begin
                                                                              mquery:=mquery + ' "input_document_clsid":"' +  '01CPMINJW3DL342X01C0CX3FCC'  +'", ';
                                                                              mquery:=mquery + ' "output_document_clsid":"' +  'O3BDOKTWEFD13ACM03KIU0CLP4'  +'", '+chr(10);
                                                                               mfind:=false;
                                                                         case copy(self.GetFieldValueAsString('Description'),1,4) of
                                                                           '': begin
                                                                                     mquery:=mquery + ' "DocQueue_Code":"' +  'FVT'  +'", ';
                                                                                     mquery:=mquery + ' "Store_Code":"' +  'S22'  +'", ';
                                                                                       mfind:=true;
                                                                                   end;
                                                                          end;
                                                                           if not mFind then begin
                                                                               mquery:=mquery + ' "DocQueue_Code":"' +  'FVT'  +'", ';
                                                                               mquery:=mquery + ' "Store_Code":"' +  'S22'  +'", ';
                                                                               mFind:=true;
                                                                           end;
                                                                              mquery:=mquery + ' "Debug":"' +  'False'  +'",'+chr(10);
                                                                              mquery:=mquery + ' "Sales":"' +  'False'  +'",'+chr(10);
                                                                              mquery:=mquery + ' "Email":"' +  'mskacel@lipoelastic.com'  +'",'+chr(10);
                                                                              mquery:=mquery + ' "Report_ID":"' +  ''  +'",'+chr(10);
                                                                              mquery:=mquery + ' "Msg":"' +  'SUPER00000'  +'",'+chr(10);
                                                                              mquery:=mquery + ' "DocumentType":"' +  ''  +'",'+chr(10);
                                                                              mquery:=mquery + ' "ImportAllDocument":"' +  'False'  +'",'+chr(10);
                                                                              mquery:=mquery + ' "Firm_Name":"' +  TDynSiteForm(msite).CurrentObject.GetFieldValueAsString('Firm_ID.name')  +'", ';
                                                                   end;


                                                                              mquery:=mquery + ' "User":"' +  mUser  +'",'+chr(10);



                                                                              mquery:=mquery + ' "InputDocuments":["' +  ''  +'" ' + '],';
                                                                              mquery:=mquery + ' "SelectedHeader":"' +  ''  +'" ,';
                                                                              mquery:=mquery + ' "SelectedRows":["' +  ''  +'" ' + '],'+chr(10);
                                                                              mquery:=mquery + ' "StoreDocQueue_Code":"' +  ''  +'", ';
                                                                              mquery:=mquery + ' "ImportBatches":"' +  'True'  +'", ';


                                                                              mquery:=mquery + ' "Division_Code":"' +  'SK'  +'", '+chr(10);

                                                                              mquery:=mquery + ' "AbraDocuments":[';
                                                  end;

                                                  mquery:=mquery + NxGetAPIDocument(msite,self);
                                                  if mICount<>mIBookmark then begin
                                                        mquery:=mquery + ',' + chr(10);

                                                  end;


                                                   if not mKumulovane then begin      // index=1 then begin
                                                           mquery:=mquery + ']';
                                                           mquery:=mquery + '}';

                                                        mquery:=mquery + '}';
                                                     mTarget:=self.GetFieldValueAsString('Firm_ID.X_API_Adress');
                                                     if mTarget='' then begin
                                                          NxShowSimpleMessage(' Firma ' + self.GetFieldValueAsString('Firm_ID.Name') + ' nemá uvedenou API adresu , není možné pokračovat', nil);
                                                          exit ;
                                                     end;


                                                        // mboolean:=InputQuery('API','Post 1:1 ',mTarget+'/script/NxApiLib/lib/APINxImporManager' + Chr(10) + chr(10) +mQuery);
                                                        mString:=APICallString(msite.BaseObjectSpace,'POST',mTarget+'/script/NxApiLib/lib/APINxImporManager',mQuery, true);
                                                            mReturnJSON:=TJSONSuperObject.create;
                                                               try
                                                               mReturnJSON:= TJSONSuperObject.ParseString(mString,true);
                                                                   //mReturnNewDocID:=mReturnNewDocID + mReturnJSON.S['ID'] + ';';

                                                                     if mBookmark.count>0 then begin

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
                                                                        end;

                                                                     end;
                                                            finally
                                                                mReturnJSON.free;
                                                            end;


                                                   end;
                                              end;
                                                // ukončení abradocuments
                                                  if mKumulovane then begin
                                                      mquery:=mquery + ']';

                                                      mquery:=mquery + '}';

                                                       mquery:=mquery + '}';
                                                     mTarget:=self.GetFieldValueAsString('Firm_ID.X_API_Adress');
                                                     if mTarget='' then begin
                                                          NxShowSimpleMessage(' Firma ' + self.GetFieldValueAsString('Firm_ID.Name') + ' nemá uvedenou API adresu , není možné pokračovat', nil);
                                                          exit ;
                                                     end;


                                                      //mboolean:=InputQuery('API','Post 1 doklad',mTarget+'/script/NxApiLib/lib/APINxImporManager' + Chr(10) + chr(10) +mQuery);
                                                      mString:=APICallString(msite.BaseObjectSpace,'POST',mTarget+'/script/NxApiLib/lib/APINxImporManager',mQuery, true);

                                                     // NxShowSimpleMessage(mString,nil);


                                                               mReturnJSON:=TJSONSuperObject.create;
                                                               try
                                                               mReturnJSON:= TJSONSuperObject.ParseString(mString,true);
                                                                   if mReturnJSON.S['New']<>'' then begin
                                                                     //mReturnNewDocID:=mReturnJSON.S['ID'];
                                                                     mReturnNewDocNumber:=mReturnJSON.S['New'];
                                                                      // uživatel
                                                                      //mxString:=APINxSQL_String(msite.BaseObjectSpace,mtarget,'UPDATE','CreatedBy_ID=' + QuotedStr('SUPER00000'),'StoreDocuments','ID=' + quotedstr(mReturnJSON.S['ID']));
                                                                      mReturnSourceDoc:=mReturnJSON.S['Source'];
                                                                       mReturnImportRow:=mReturnImportRow+NxIBStrToFloat( mReturnJSON.S['Import']);
                                                                        mReturnOtherRow:=mReturnOtherRow+NxIBStrToFloat(  mReturnJSON.S['Other']);
                                                                   end;
                                                              finally
                                                               mReturnJSON.free;
                                                              end;

                                                  end;







                                              end;
                                              if mBookmark.count>0 then ProgressDispose()   ;
                                              if mKumulovane then begin


                                                    mstring:='';
                                                    mstring:=mstring + 'Operace dokončena: ' + chr(10)+ chr(10);
                                                    mstring:=mstring + 'Byl vytvořen doklad: ' + mReturnNewDocNumber + chr(10);
                                                    if mReturnImportRow>0 then begin
                                                        mstring:=mstring + 'Importovaných řádků: ' + NxFloatToIBStr(mReturnImportRow)
                                                                           +' z dokladů: ' + mReturnSourceDoc + chr(10);
                                                    end;
                                                    if mReturnOtherRow>0 then begin
                                                        mstring:=mstring + 'Bez vazby: ' + NxFloatToIBStr(mReturnOtherRow) +chr(10);
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

                                              if not mKumulovane then begin
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
                mMAction.Caption := 'Odeslání položky';
                mMAction.Hint := 'Odeslání položky ';
                mMAction.Category := 'tabList';
                mMAction.Items.Add('API SK OP');
                mMAction.Items.Add('API SK OV-OV');
                mMAction.Items.Add('API SK OV-PR');
                mMAction.Items.Add('API SK OP-DL');
                //mMAction.Items.Add('API SK OP-PRV');
                //mMAction.Items.Add('API SK OP-PRP');
                //mMAction.Items.Add('API SK OP-FV');
                mMAction.OnExecuteItem := @Souhrne;

                mMAction := Self.GetNewMultiAction;
                mMAction.ShowControl := True;
                mMAction.ShowMenuItem := True;
                mMAction.Caption := 'Odeslání položky 1:1';
                mMAction.Hint := 'Odeslání položky 1:1 ';
                mMAction.Category := 'tabList';
                mMAction.Items.Add('API SK OP 1:1');
                mMAction.Items.Add('API SK OV-OV 1:1');
                mMAction.Items.Add('API SK OV-PR 1:1');
                mMAction.Items.Add('API SK OP-DL 1:1');
                //mMAction.Items.Add('API SK OP-PRV 1:1');
                //mMAction.Items.Add('API SK OP-PRP 1:1');
                //mMAction.Items.Add('API SK OP-FV 1:1');
                mMAction.OnExecuteItem := @PoDokladu;
   end;
finally
    muser.free;
end;

end;


procedure PoDokladu(Sender: TObject;index:integer);
begin
    mKumulovane:=false;
    Synchronizace(Sender,index,mKumulovane);
end;


procedure Souhrne(Sender: TObject;index:integer);
begin
    mKumulovane:=true;
    Synchronizace(Sender,index,mKumulovane);
end;



begin
end.





