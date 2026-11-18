  uses  '_Knihovny_ALL.Progress',
      '_Knihovny_ALL.Parse',
      '_Knihovny_ALL.head',
      'Synchronizace.API' ;

      const
mTable='StoreDocuments';
mApiTable='StoreDocuments';


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


procedure InitSite_Hook(Self: TSiteForm);
var
  mMAction: TMultiAction;
  mAction: TBasicAction;
  mAList: TActionList;
  i: integer;
  mAct: TBasicAction;
begin
//  mMAction := Self.GetNewMultiAction;
//          mMAction.ShowControl := True;
//          mMAction.ShowMenuItem := True;
//          mMAction.Hint := 'Import z CZ LipoElastic SK z OV';
//          mMAction.Caption := 'Import z CZ LipoElastic SK z OV';
//          mMAction.Items.Add('Import z CZ LipoElasticSK ');
//          mMAction.Items.Add('Hromadný import');
//          mMAction.Category := 'tabList';
//          mMAction.OnExecuteItem := @OnExec;




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
  i,ii,iii:integer;
  mTarget:string;
 mr1:tstringlist;
 mMonRows:TNxCustomBusinessMonikerCollection;
 mMonBatches:TNxCustomBusinessMonikerCollection;
begin
  mids:='';
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
                          self:=TDynSiteForm(msite).CurrentObject;    // načtení objektu

   if true then begin
   //NxGetUserName='mskacel' then begin
//   NxShowSimpleMessage('AAAA',nil);
   mTargetList:=tstringlist.create;
mMonRows := self.GetLoadedCollectionMonikerForFieldCode(self.GetFieldCode('ROWS'));
    TRY
          mTargetList:=CreateTargetList;

    for i:=0 to mTargetList.count-1 do begin // ****cyklus pro jednotlicá spojení
                mTarget:=mTargetList.strings[i];
          if true then begin // copy(self.GetFieldValueAsString('X_synchronizace_ID'),i+1,1)='1' then begin

                        //  NxShowSimpleMessage(inttostr(mTargetList.count),nil) ;
                        //             NxShowSimpleMessage(self.ObjectSpace.GetConnectionName,nil);
                     mQuery:='{}';

                     IF mManual then BEGIN                   // **** ruční vykopírování údajů
                        mQuery:='{'  ;
                        mQuery:=mQuery +'"ID": "' +                                    Self.OID +'", '                                                            ;
                          mQuery:=mQuery +'"DocumentType ": "' +                              Self.GetFieldValueAsstring('DocumentType') +'", '                  ;
                          mQuery:=mQuery +'"Docqueue_ID": "' +                              Self.GetFieldValueAsstring('Docqueue_ID') +'", '                  ;
                          mQuery:=mQuery +'"tradetype": ' +                              IntToStr(Self.GetFieldValueAsInteger('tradetype')) +', '                  ;
                          mQuery:=mQuery +'"Firm_ID":"'  +                                  Self.GetFieldValueAsString('Firm_ID') +'", '                              ;
                          //NxShowSimpleMessage(copy(mTargetList.strings[i],21,1),nil);

                          mQuery:=mQuery +'"Rows": [  ';
                        for i := 0 to mMonRows.Count-1 do begin
                                        mQuery:=mQuery +'{ ' ;
//                                        mQuery:=mQuery +'"id":"' +                            		  mMonRows.BusinessObject[i].GetFieldValueAsString('ID')+'", '   ;
                                        mQuery:=mQuery +'"PosIndex": ' +                            IntToStr(mMonRows.BusinessObject[i].GetFieldValueAsInteger('Posindex')) +', '                  ;
                                        mQuery:=mQuery +'"Rowtype": ' +                             IntToStr(mMonRows.BusinessObject[i].GetFieldValueAsInteger('Rowtype')) +', '                  ;
                                        mQuery:=mQuery +'"Text":"' +                            		mMonRows.BusinessObject[i].GetFieldValueAsString('Text')+'", ' ;
                                        mQuery:=mQuery +'"Store_ID":"' +                            mMonRows.BusinessObject[i].GetFieldValueAsString('Store_ID')+'", '   ;
                                        mQuery:=mQuery +'"Storecard_ID":"' +                        mMonRows.BusinessObject[i].GetFieldValueAsString('Storecard_ID')+'", '   ;

                                        mQuery:=mQuery +'"Quantity": ' +                            NxFloatToIBStr(mMonRows.BusinessObject[i].GetFieldValueAsFloat('Quantity')) +', '                  ;

                                        mQuery:=mQuery +'"Qunit":"' +                               mMonRows.BusinessObject[i].GetFieldValueAsString('Qunit')+'", '   ;

                                        mQuery:=mQuery +'"UnitPrice": ' +                           NxFloatToIBStr(mMonRows.BusinessObject[i].GetFieldValueAsFloat('UnitPrice')) +', '                  ;
                                        mQuery:=mQuery +'"TotalPrice": ' +                          NxFloatToIBStr(mMonRows.BusinessObject[i].GetFieldValueAsFloat('TotalPrice')) +', '                  ;

                                        mQuery:=mQuery +'"TAmount": ' +                             NxFloatToIBStr(mMonRows.BusinessObject[i].GetFieldValueAsFloat('TAmount')) +', '                  ;

                                        mQuery:=mQuery +'"Division_ID":"' +                         mMonRows.BusinessObject[i].GetFieldValueAsString('Division_ID')+'", '   ;
                                        mQuery:=mQuery +'"BusOrder_ID":"' +                         mMonRows.BusinessObject[i].GetFieldValueAsString('BusOrder_ID')+'", '   ;
                                        mQuery:=mQuery +'"BusTransaction_ID":"' +                   mMonRows.BusinessObject[i].GetFieldValueAsString('BusTransaction_ID')+'", '   ;
                                        mQuery:=mQuery +'"BusProject_ID":"' +                       mMonRows.BusinessObject[i].GetFieldValueAsString('BusProject_ID')+'", '   ;


                                        mMonBatches:= mMonRows.BusinessObject[i].GetLoadedCollectionMonikerForFieldCode(mMonRows.BusinessObject[i].GetFieldCode('DocRowBatches'));

                                         mQuery:=mQuery +'"DocRowBatches": [  ';
                                                for ii := 0 to mMonBatches.Count-1 do begin
                                                     mQuery:=mQuery +'{ ' ;
                                                             mQuery:=mQuery +'"NewBatch":"' +                       mMonBatches.BusinessObject[ii].GetFieldValueAsString('NewBatch')+'", '   ;
                                                             mQuery:=mQuery +'"NewBatchName":"' +                       mMonBatches.BusinessObject[ii].GetFieldValueAsString('NewBatchName')+'", '   ;
                                                             mQuery:=mQuery +'"NewBatchComment":"' +                       mMonBatches.BusinessObject[ii].GetFieldValueAsString('NewBatchComment')+'", '   ;
                                                             mQuery:=mQuery +'"NewBatchSpecification":"' +                       mMonBatches.BusinessObject[ii].GetFieldValueAsString('NewBatchSpecification')+'", '   ;
                                                             //mQuery:=mQuery +'"NewBatchExpirationDate":"' +                       mMonBatches.BusinessObject[ii].GetFieldValueAsString('NewBatchExpirationDate')+'", '   ;
                                                             mQuery:=mQuery +'"PosIndex":"' +                       mMonBatches.BusinessObject[ii].GetFieldValueAsString('PosIndex')+'", '   ;
                                                             mQuery:=mQuery +'"ProvideRowBatch_ID":"' +                       mMonBatches.BusinessObject[ii].GetFieldValueAsString('ProvideRowBatch_ID')+'", '   ;
                                                             mQuery:=mQuery +'"StoreBatch_ID ":"' +                       mMonBatches.BusinessObject[ii].GetFieldValueAsString('StoreBatch_ID ')+'", '   ;
                                                             mQuery:=mQuery +'"StoreSubBatch_ID ":"' +                       mMonBatches.BusinessObject[ii].GetFieldValueAsString('StoreSubBatch_ID ')+'", '   ;
                                                             mQuery:=mQuery +'"Quantity":"' +                       mMonBatches.BusinessObject[ii].GetFieldValueAsString('Quantity')+'", '   ;
                                                             mQuery:=mQuery +'"QUnit":"' +                       mMonBatches.BusinessObject[ii].GetFieldValueAsString('QUnit')+'", '   ;
                                                mQuery:=mQuery +' }, ';
                                                end;
                                        mQuery:=mQuery +' }, ';

                        end;

                               mQuery:=mQuery +' ] ';

                              mQuery:=mQuery +' } ';


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
//                              mID:= copy(CallRestApi(Self,'Post',mtarget,'query','',mQueryID),9,10);








                      mstring:=                      inputbox('Skladové karty - plné data','Put',mtarget+mApiTable+'/' + mid + '       ' + mQuery)    ;

//                             mString:= CallRestApi(self,'PUT',mtarget,mApiTable,'/' + mid ,mQuery);  // načtení záznamu
//                             mString:= CallRestApi(self,'POST',mtarget,mApiTable,'/' + mid ,mQuery);  // načtení záznamu




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




    function ImportFilePR(OS: TNxCustomObjectSpace; AFileName: string;directory: string;filename: string;msite:TDynSiteForm;rucne:boolean;chyba:boolean;index:Integer) : string;
var
mID_Docqueue_iD,mID_Store_iD:string;
mObchodniPripad,mdivision_id:string;
mstore_id:string;
mBustransaction_ID:string;
mfind_string:string;
mr,mx,mrsa,mxax:tstringlist;
mStoreCard_ID:string;
mBO_adress,mBO_Sarze,mRowDocRowBatches,mBOIssuedOrderRow:TNxCustomBusinessObject;
mAdress_id:string;
mi_result:integer;
mMon,mMonBatches:TNxCustomBusinessMonikerCollection;
mstorecard_text:string;
mbo_docqueue:TNxCustomBusinessObject;
mQunit:string;
mPacName:string;
mabraqunit:string;
mTyp_Eshopu,MID_SARZE:string;
mi:double;
mInteger:Integer;
mWorkList:Tstringlist;
mSelectedRows,mDocLists:Tstringlist;
x:integer;
mFind:Boolean;
  mXMLHead : TNxScriptingXMLWrapper;
  mImportMan: TNxDocumentImportManager;
  mOS: TNxCustomObjectSpace;
  mInputParams: TNxParameters;
  mParam: TNxParameter;
  mCollRows: TNxCustomBusinessMonikerCollection;
  xx,xxx: integer;
  mList: TStringList;
  mRow: TNxCustomBusinessObject;
  mtext:string;
  mValidateList:tstringlist;
  mRowsOutput:TNxCustomBusinessMonikerCollection;
  msave:boolean;
  mIDoc:integer;
  mpomoc1,mpomoc2,mpomoc3,mpomoc4:string;
  price:double;
  mXStore_ID:string;
begin
    if not FileExists(AFileName) then begin
      Result := '';
      exit;
    end else begin

    try
      mXMLHead := TNxScriptingXMLWrapper.Create;
        mXMLHead.loadFromFile(AFileName);

        mSelectedRows:=TStringList.create;
        mDocLists:=TStringList.create;
         for i := 0 to mXMLHead.getElementsCountInArray('AbraDocument.Rows.Row') - 1 do begin
             if (mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].X_ProvideRow_ID'))<>'' then begin
                  mr:=tstringlist.create;
                  try
                  //   mi:=os.SQLExecute('update issuedorders2 set store_id=' + quotedstr('2Z00000101') + ' where id=' + quotedstr(mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].X_ProvideRow_ID'))) ;
                     os.SQLSelect('select Parent_ID,ID from issuedorders2 where X_ProvideRow_ID=' + quotedstr(mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].X_ProvideRow_ID')),mr) ;
                     if mr.count>0 then begin

                          mFind:=false;
                          for x:=0 to mDocLists.Count-1 do begin
                              if mDocLists.Strings[x]=copy(mr.Strings[0],1,10) then mFind:=true;
                          end;
                          if not mFind then mDocLists.add(copy(mr.Strings[0],1,10));
                          mSelectedRows.add(copy(mr.Strings[0],12,10));
                     end;
                  finally
                      mr.free;
                  end;
             end;

         end;

//      nxshowsimplemessage(inttostr(mSelectedRows.count),nil);
         mID_Division:='5O10000101';
          mID_Docqueue_ID:= 'G7N1000101';
          mID_odberatel:= '3010000101';
          //mstore_id:='1M00000101';

             // NxShowSimpleMessage('Doklad' + inttostr(mDocLists.count),nil);
             // NxShowSimpleMessage('Rádek' + inttostr(mSelectedRows.count),nil);

                //  mOS := msite.BaseObjectSpace;
                  try
 if mSelectedRows.count=0 then nxshowsimplemessage('není záznam',nil);
                    mInputParams := TNxParameters.Create;

                      if mID_Docqueue_ID<>'' then begin
                          mParam := mInputParams.GetOrCreateParam(dtString, 'DocQueue_ID');
                          mParam.AsString := mID_Docqueue_ID;
                      end;
                      if mID_odberatel<>'' then begin
                          mParam := mInputParams.GetOrCreateParam(dtString, 'Firm_ID');
                          mParam.AsString := mID_odberatel;
                      end;
                      if mSelectedRows.count>0 then begin
                           mParam := mInputParams.GetOrCreateParam(dtString, 'SelectedRows'); // jen povolene radky
                           mParam.AsString := mSelectedRows.Text;
                      end;

                      mParam := mInputParams.GetOrCreateParam(dtString, 'SelectedHeader'); // musi se z nejake hlavicky prebirat hlavickova data
                      mParam.AsString := mDocLists.Strings[0];

//                           nxshowsimplemessage('bb',nil);
                      mImportMan := NxCreateDocumentImportManager(OS, 'CDMK5QAWZZDL342X01C0CX3FCC', 'E03ZNUMDTCC4PDAUIEY1MBTJC0');
                      try

                        for mIDoc:=0 to mDocLists.count-1 do begin
                             mImportMan.AddInputDocument(mDocLists.Strings[mIDoc]);
                        end;

                        mImportMan.LoadParams(mInputParams);
                        mImportMan.Execute;
                       // mImportMan.CheckOutputDocument;

  //                           nxshowsimplemessage('cc',nil);
                        mHead:=TnxHeaderBusinessObject(mImportMan.OutputDocument);


                        mRowsOutput := mHead.GetLoadedCollectionMonikerForFieldCode(mHead.GetFieldCode('Rows'));

                       for i := 0 to mXMLHead.getElementsCountInArray('AbraDocument.Rows.Row') - 1 do begin
                                mFind:=false;
                              for ii := 0 to mRowsOutput.Count - 1 do begin
                                   //mRowsOutput.BusinessObject[ii].setFieldValueAsString('Store_ID','2Z00000101');
                                   mXstore_ID:=mRowsOutput.BusinessObject[ii].getFieldValueAsString('Store_ID');
                                   if mRowsOutput.BusinessObject[ii].GetFieldValueAsString('X_ProvideRow_ID')=mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].X_ProvideRow_ID') then begin
                                        mFind:=true;
                                               //if not(ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].Quantity') and (index=2)) then
                                                                mRowsOutput.BusinessObject[ii].setFieldValueAsFloat('Quantity',NxIBStrToFloat(mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Quantity'))); //text bude  ...
    //                                                           nxshowsimplemessage('cc2',nil);
                                                             {
                                                                if (mRowsOutput.BusinessObject[ii].GetFieldValueAsString('StoreCard_ID.StoreCardCategory_ID')='1700000101') or (mRowsOutput.BusinessObject[ii].GetFieldValueAsString('StoreCard_ID.StoreCardCategory_ID')='2H00000101') or (mRowsOutput.BusinessObject[ii].GetFieldValueAsString('StoreCard_ID.StoreCardCategory_ID')='1300000101') or (mRowsOutput.BusinessObject[ii].GetFieldValueAsString('StoreCard_ID.StoreCardCategory_ID')='A000000101') or (mRowsOutput.BusinessObject[ii].GetFieldValueAsString('StoreCard_ID.StoreCardCategory_ID')='1900000101') then begin
                                                                          if mRowsOutput.BusinessObject[ii].GetFieldValueAsString('Store_ID.X_Cena')='R' then begin
                                                                              price:=mRowsOutput.BusinessObject[ii].GetFieldValueAsFloat('StoreCard_ID.X_Cena_rozprac');

                                                                              if price>0 then begin
                                                                                  //mRowsOutput.BusinessObject[ii].SetFieldValueAsFloat('TotalPrice',0);
                                                                                  mRowsOutput.BusinessObject[ii].SetFieldValueAsFloat('UnitPrice',price);
                                                                               end;
                                                                          end;
                                                                          if mRowsOutput.BusinessObject[ii].GetFieldValueAsString('Store_ID.X_Cena')='S' then begin
                                                                              price:=mRowsOutput.BusinessObject[ii].GetFieldValueAsFloat('StoreCard_ID.X_Cena_skladova');
                                                                               if price>0 then begin
                                                                                  //mRowsOutput.BusinessObject[ii].SetFieldValueAsFloat('TotalPrice',0);
                                                                                  mRowsOutput.BusinessObject[ii].SetFieldValueAsFloat('UnitPrice',price);
                                                                               end;
                                                                          end;
                                                                           if mRowsOutput.BusinessObject[ii].GetFieldValueAsString('Store_ID.X_Cena')='P' then begin
                                                                              price:=mRowsOutput.BusinessObject[ii].GetFieldValueAsFloat('StoreCard_ID.X_Cena_precen');
                                                                               if price>0 then begin
                                                                                  //mRowsOutput.BusinessObject[ii].SetFieldValueAsFloat('TotalPrice',0);
                                                                                  mRowsOutput.BusinessObject[ii].SetFieldValueAsFloat('UnitPrice',price);
                                                                               end;
                                                                          end;
                                                                end;

                                                              }

      //                                                 nxshowsimplemessage('dd',nil);
                                                 // šarže
                                                // if mRow.getFieldValueAsInteger('Storecard_ID.category')=2 then begin
        //                                                       nxshowsimplemessage('ee',nil);
                                                            mMonBatches := mRowsOutput.BusinessObject[ii].GetLoadedCollectionMonikerForFieldCode(mRowsOutput.BusinessObject[ii].GetFieldCode('DocRowBatches'));
                                                            //mRowsOutput.BusinessObject[ii].SetFieldValueAsString('Store_ID','1M00000101');
                                                            for ii := 0 to mXMLHead.getElementsCountInArray('AbraDocument.Rows.Row['+inttostr(i)+'].Batches.Batch') - 1 do begin
                                                                    //if mXMLHead.getElementsCountInArray('AbraDocument.Rows.Row.Batches.Batch')>0 then begin
                                                                    //NxShowSimpleMessage('Sarze ' + mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Batches.Batch['+inttostr(ii)+'].name'),nil);
                                                                    if mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Batches.Batch['+inttostr(ii)+'].name')<>'' then begin
                                                                          mr:=tstringlist.create;
                                                                           // dohledání pohybu šarže
                                                                           try
                                                                                msite.BaseObjectSpace.SQLSelect('SELECT b.ID FROM StoreBatches b where b.name=' + quotedstr(mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Batches.Batch['+inttostr(ii)+'].name')) +
                                                                                                                ' and b.hidden=' + quotedstr('N') ,mr) ;
                                                                                mRowDocRowBatches := mMonBatches.AddNewObject;
                                                                                if mr.count=0 then begin
                                                                                              mRowDocRowBatches.Prefill;
                                                                                              //mRowDocRowBatches.SetFieldValueAsInteger('PosIndex',II);
                                                                                              mRowDocRowBatches.SetFieldValueAsBoolean('NewBatch',True);
                                                                                              //mRowDocRowBatches.SetFieldValueAsString('StoreBatch_ID ',mID_Sarze);
                                                                                              mRowDocRowBatches.SetFieldValueAsString('NewBatchComment','');
                                                                                              mRowDocRowBatches.SetFieldValueAsString('NewBatchName',mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Batches.Batch['+inttostr(ii)+'].name'));
                                                                                              mRowDocRowBatches.SetFieldValueAsString('NewBatchSpecification',mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Batches.Batch['+inttostr(ii)+'].Specification'));
                                                                                              mRowDocRowBatches.SetFieldValueAsDateTime('NewBatchExpirationDate$DATE',now);
                                                                                              mRowDocRowBatches.SetFieldValueAsFloat('Quantity',NxIBStrToFloat(mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Batches.Batch['+inttostr(ii)+'].quantity')));
                                                                                end else begin
                                                                                       mID_Sarze:=mr.Strings[0];
                                                                                             mRowDocRowBatches.Prefill;
                                                                                            //mRowDocRowBatches.SetFieldValueAsInteger('PosIndex',II);
                                                                                            mRowDocRowBatches.SetFieldValueAsBoolean('NewBatch',False);
                                                                                            mRowDocRowBatches.SetFieldValueAsString('StoreBatch_ID',mID_Sarze);
                                                                                            mRowDocRowBatches.SetFieldValueAsFloat('Quantity',NxIBStrToFloat(mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Batches.Batch['+inttostr(ii)+'].quantity')));
                                                                                end;

                                                                           finally
                                                                              mr.free;
                                                                           end;
                                                                    end;
                                                            //  end;
                                                          //    end;
                                                             end;   // konec batches
                                             //  end;

                                   end;     // ***** vazba na provide

                              end;  // konec prohledávacího cyklu


                              // *** nenalezeno , zakládá řádek
                                   if not (mFind) and nxisemptyoid(mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].X_ProvideRow_ID'))  then begin
                                      //NxShowSimpleMessage('Přidání řádku',nil);
                                      mRow := mRowsOutput.AddNewObject;
                                          mRow.Prefill;
                                          mStoreCard_ID:='';
                                          mstorecard_text:='';
                                          mRow.SetFieldValueAsString('Store_ID',mXstore_ID);
                                                    mStoreCard_ID:='';
                                                        mstorecard_text:='';
                                                         if not(ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].Commodity.EAN') and (index=2)) then begin
                                                                if (mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Commodity.EAN')<>'') then begin
                                                                         mr:=tstringlist.create;
                                                                          try
                                                                              msite.BaseObjectSpace.SQLSelect(format('select sc.id||su.code from STOREEANS SE left join StoreUnits SU on SU.id=se.Parent_id left join Storecards SC on sc.id=su.parent_id where ((se.EAN=%s ) or (sc.EAN=%s )) and (sc.hidden=%s)',
                                                                              [quotedstr(mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Commodity.EAN')),quotedstr(mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Commodity.EAN')),QuotedStr('N')]),mr);

                                                                                   if mr.count=0 then begin
                                                                                       //mstorecard_text:=mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Commodity.Ean') + ' - ' + mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Commodity.Name');
                                                                                       mStoreCard_ID:='3NQ1000101';
                                                                                       mQunit:='ks';
                                                                                   end else begin
                                                                                       mStoreCard_ID:=copy(
                                                                                        ReplaceStr(mr.Strings[0],'"',''),1,10);
                                                                                       mQunit:=copy(ReplaceStr(mr.Strings[0],'"',''),11,5);
                                                                                   end;
                                                                           finally
                                                                                mr.free;
                                                                           end;
                                                                 end else begin
                                                                      mStoreCard_ID:='3NQ1000101';
                                                                      mQunit:='ks';

                                                                 end;
                                                         end;
                                                         mRow.SetFieldValueAsString('Storecard_ID',mStoreCard_ID);
                                                          if not(ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].Quantity') and (index=2)) then begin
                                                                mRow.SetFieldValueAsFloat('Quantity',NxIBStrToFloat(mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Quantity'))); //text bude  ...
                                                                mRow.SetFieldValueAsString('Store_ID','5131000101');
                                                                mRow.SetFieldValueAsString('Division_ID',mID_Division); //text bude  ...
                                                          end;
                                                  if not NxIsEmptyOID((mRow.GetFieldValueAsString('StoreCard_id.X_BusTransaction_ID'))) then begin
                                                                             mBustransaction_ID:=(mRow.GetFieldValueAsString('StoreCard_id.X_BusTransaction_ID'));
                                                                             mRow.SetFieldValueAsString('BusTransaction_id',mBustransaction_ID );
                                                  end;

                                               {    if (mRow.GetFieldValueAsString('StoreCard_ID.StoreCardCategory_ID')='1700000101') or (mRow.GetFieldValueAsString('StoreCard_ID.StoreCardCategory_ID')='2H00000101') or (mRow.GetFieldValueAsString('StoreCard_ID.StoreCardCategory_ID')='1300000101') or (mRow.GetFieldValueAsString('StoreCard_ID.StoreCardCategory_ID')='A000000101') or (mRow.GetFieldValueAsString('StoreCard_ID.StoreCardCategory_ID')='1900000101') then begin
                                                                          if mRow.GetFieldValueAsString('Store_ID.X_Cena')='R' then begin
                                                                              price:=mRow.GetFieldValueAsFloat('StoreCard_ID.X_Cena_rozprac');
                                                                              if price>0 then mRow.SetFieldValueAsFloat('UnitPrice',price);
                                                                          end;
                                                                          if mRow.GetFieldValueAsString('Store_ID.X_Cena')='S' then begin
                                                                              price:=mRow.GetFieldValueAsFloat('StoreCard_ID.X_Cena_skladova');
                                                                               if price>0 then mRow.SetFieldValueAsFloat('UnitPrice',price);
                                                                          end;
                                                                           if mRow.GetFieldValueAsString('Store_ID.X_Cena')='P' then begin
                                                                              price:=mRow.GetFieldValueAsFloat('StoreCard_ID.X_Cena_precen');
                                                                               if price>0 then mRow.SetFieldValueAsFloat('UnitPrice',price);
                                                                          end;
                                                                end;
                                               }

                                               if mRow.getFieldValueAsInteger('Storecard_ID.category')=2 then begin
                                                  // šarže
                                                            mMonBatches := mrow.GetLoadedCollectionMonikerForFieldCode(mrow.GetFieldCode('DocRowBatches'));

                                                            for ii := 0 to mXMLHead.getElementsCountInArray('AbraDocument.Rows.Row['+inttostr(i)+'].Batches.Batch') - 1 do begin
                                                                    //if mXMLHead.getElementsCountInArray('AbraDocument.Rows.Row.Batches.Batch')>0 then begin
                                                                    //NxShowSimpleMessage('Sarze ' + mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Batches.Batch['+inttostr(ii)+'].name'),nil);
                                                                    if mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Batches.Batch['+inttostr(ii)+'].name')<>'' then begin
                                                                          mr:=tstringlist.create;
                                                                           // dohledání pohybu šarže
                                                                           try
                                                                                msite.BaseObjectSpace.SQLSelect('SELECT b.ID FROM StoreBatches b where b.name=' + quotedstr(mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Batches.Batch['+inttostr(ii)+'].name')) +
                                                                                                                ' and b.hidden=' + quotedstr('N') ,mr) ;
                                                                                mRowDocRowBatches := mMonBatches.AddNewObject;
                                                                                if mr.count=0 then begin
                                                                                              mRowDocRowBatches.Prefill;
                                                                                              mRowDocRowBatches.SetFieldValueAsBoolean('NewBatch',True);
                                                                                              //mRowDocRowBatches.SetFieldValueAsString('StoreBatch_ID ',mID_Sarze);
                                                                                              mRowDocRowBatches.SetFieldValueAsString('NewBatchComment','');
                                                                                              mRowDocRowBatches.SetFieldValueAsString('NewBatchName',mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Batches.Batch['+inttostr(ii)+'].name'));
                                                                                              mRowDocRowBatches.SetFieldValueAsString('NewBatchSpecification',mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Batches.Batch['+inttostr(ii)+'].Specification'));
                                                                                              mRowDocRowBatches.SetFieldValueAsDateTime('NewBatchExpirationDate$DATE',now);
                                                                                              mRowDocRowBatches.SetFieldValueAsFloat('Quantity',NxIBStrToFloat(mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Batches.Batch['+inttostr(ii)+'].quantity')));

                                                                                end else begin
                                                                                       mID_Sarze:=mr.Strings[0];
                                                                                            mRowDocRowBatches.Prefill;
                                                                                            mRowDocRowBatches.SetFieldValueAsBoolean('NewBatch',False);
                                                                                            mRowDocRowBatches.SetFieldValueAsString('StoreBatch_ID',mID_Sarze);
                                                                                            mRowDocRowBatches.SetFieldValueAsFloat('Quantity',NxIBStrToFloat(mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Batches.Batch['+inttostr(ii)+'].quantity')));
                                                                                end;

                                                                           finally
                                                                              mr.free;
                                                                           end;
                                                                    end;
                                                             end;   // konec batches
                                               end;
                                   end;



                       end;


                       mhead.SetFieldValueAsString('Description',copy(mImportMan.InputDocument.GetFieldValueAsString('Description') +   copy(FileName,11,50),1,50));


                                              if mRowsOutput.count>0 then begin
                                                  mhead.ClearValidateErrors;
                                                   // if true then begin
                                                  if Not mhead.Validate() then begin
                                                        mList := TStringList.Create;
                                                        try
                                                           mhead.GetValidateErrors(mList);
                                                           mText := mList.Text;
                                                           NxToken(mText, '=');
                                                           MessageDlg('Automaticky vytvořenou příjemku nelze uložit z těchto důvodů:' + #13#10 + mText,

                                                           mtWarning, [mbOK], 0);
                                                         finally
                                                           mList.Free;
                                                         end;
                                                         mSite.ShowDynFormWithNewDocument('B10I5SAOS3DL3ACU03KIU0CLP4', mSite.SiteContext, mhead);
                                                         //mhead.refresh;
                                                        //msite.ActiveDataSet.RefreshCurrentItemMode;
                                                  end else begin
                                                        mhead.Save;
                                                        result:=mhead.oid;
                                                        //mhead.refresh;
                                                        msite.ActiveDataSet.RefreshCurrentItemMode;

                                                        if index=0 then begin
                                                              if rucne then NxShowSimpleMessage('Prijemka ' + mhead.GetFieldValueAsstring('Docqueue_ID.code') + '-' + inttostr(mhead.GetFieldValueAsinteger('Ordnumber')) + '/' +
                                                                       mhead.GetFieldValueAsstring('Period_ID.code') + ' byla vytvořena',nil);
                                                        end;
                                                              nxcopyfile(AFileName,Directory + '\Zpracovane\' + FileName);

                                                        if True then begin
                                                            DeleteFile(AFileName);
                                                            if index=0 then begin
                                                                    if rucne  and chyba then begin
                                                                           NxShowSimpleMessage('Soubor ' + afilename + ' byl přesunut do zpracovaných',nil);
                                                                    end;
                                                            end;
                                                        end;
                                                  end;
                                              end;

                      finally
                        mImportMan.Free;
                        mhead.free;
                      end;
                    finally
                      mInputParams.Free;
                    end;

        finally
            mXMLHead.free;
            mDocLists.free;
        end;
   end;
    msite.refresh;
end;



    Function ErrtElementString(mXMLHead : TNxScriptingXMLWrapper;mElement:string):boolean;
var
mstring:string;
begin
result:=true;
    try
          mstring:=mXMLHead.getElementAsString(mElement);
          result:=false;
    except
          result:=true;
    end;
end;





   procedure OnExec(Sender: TComponent;index:integer);
var

  zadej:string;
  mfilename:string;
  mdir,mfile:string;
  mFileList:TStringList;
  mI_Result99:integer;
  mImportMan:TNxDocumentImportManager ;
  mDocument_ID:string;
  x : TNxParameters;
  mParam: TNxParameter;
  mbo:TNxCustomBusinessObject;
begin
  //mSite := NxFinddySiteForm(Sender);
  mDocument_ID:='';
  msite:=TComponent(Sender).DynSite;
  if index=0 then begin
         if PromptForFileName(mFileName, mfilter, '', 'Soubor ESHOP TOP', '\\CZVS0006\Slovensko\DL', False) then begin
              mdir:=copy(mfilename,0,NxCharPosR('\',mfilename));
              mFile:=copy(mfilename,1+NxCharPosR('\',mfilename),Length(mfilename));

         end;
         mDocument_ID:=ImportFilePR(TDynSiteForm(mSite).BaseObjectSpace, mfilename, mdir,mfile,msite,true,false,index);

         //NxShowSimpleMessage('PR hotovo  ' + mDocument_ID,nil);


        //   ****** volba zda dělat doklad
        mI_Result99:=0;

    //    mI_Result99:=mForm_Function(msite,0,0,360,480,'Vytvořit následný doklad','Byl vytvořen doklad','Příjemka'  ,
//                                 'Dodací list','Převodka výdej','','','','','','','','Nevytvářet nic');
                            if (mI_Result99=1) then begin
                               // nxshowsimplemessage('DL',nil);
                                mDocument_ID:=ImportFileDL(TDynSiteForm(mSite).BaseObjectSpace,  mdir+'zpracovane\' + mfile, mdir+'zpracovane\',mfile,msite,true,false,index);

                            end;
                            mbo:=TDynSiteForm(msite).CurrentObject;
                            mbo.load(mDocument_ID,nil);

                        //    mDocument_ID:= mIportmanager(mSite,mbo,'R7N1000101',0);




                            if false then begin // (mI_Result99=2) then begin
                                   nxshowsimplemessage('PRV',nil);
                                   x := TNxParameters.Create;
                                        mParam := x.GetOrCreateParam(dtString, 'DocQueue_ID');
                                        mParam.AsString := 'R7N1000101';
                                        mParam := x.GetOrCreateParam(dtString, 'SelectedHeader'); // musi se z nejake hlavicky prebirat hlavickova data
                                        mParam.AsString := mDocument_ID;
                                 mImportMan := NxCreateDocumentImportManager(msite.baseobjectspace, 'E03ZNUMDTCC4PDAUIEY1MBTJC0', '0P0I5SAOS3DL3ACU03KIU0CLP4');
                                        x := TNxParameters.Create;
                                        mParam := x.GetOrCreateParam(dtString, 'DocQueue_ID');
                                        mParam.AsString := 'R7N1000101';
                                        mParam := x.GetOrCreateParam(dtString, 'SelectedHeader'); // musi se z nejake hlavicky prebirat hlavickova data
                                        mParam.AsString := mDocument_ID;
                                         mImportMan.AddInputDocument(mDocument_ID);
                                            try
                                             nxshowsimplemessage('PRV x1',nil);
                                              mImportMan.Execute;
                                              mImportMan.outputdocument.ClearValidateErrors;
                                                   // if true then begin
                                                  if Not mhead.Validate() then begin
                                                        mList := TStringList.Create;
                                                        try
                                                           mhead.GetValidateErrors(mList);
                                                           mText := mList.Text;
                                                           NxToken(mText, '=');
                                                           MessageDlg('Automaticky vytvořenou Převodku výdej nelze uložit z těchto důvodů:' + #13#10 + mText,
                                                           mtWarning, [mbOK], 0);
                                                         finally
                                                           mList.Free;
                                                         end;
                                                         mSite.ShowDynFormWithNewDocument('BD0I5SAOS3DL3ACU03KIU0CLP4', mSite.SiteContext, mhead);
                                                         //mhead.refresh;
                                                        //msite.ActiveDataSet.RefreshCurrentItemMode;
                                                  end else begin
                                                        mhead.Save;
                                                        mhead.refresh;
                                                        msite.ActiveDataSet.RefreshCurrentItemMode;

                                                        NxShowSimpleMessage('Převodka výdej ' + mhead.GetFieldValueAsstring('Docqueue_ID.code') + '-' + inttostr(mhead.GetFieldValueAsinteger('Ordnumber')) + '/' +
                                                                       mhead.GetFieldValueAsstring('Period_ID.code') + ' byla vytvořena',nil);
                                                  end;

                                            finally

                                                mImportMan.free;
                                            end;
                                          x.Free;

                               //mDocument_ID:= ImportFilePRV(TDynSiteForm(mSite).BaseObjectSpace,  mdir+'zpracovane\' + mfile, mdir+'zpracovane\',mfile,msite,true,false,index);



                                         mImportMan := NxCreateDocumentImportManager(msite.baseobjectspace, '0P0I5SAOS3DL3ACU03KIU0CLP4', '1D0I5SAOS3DL3ACU03KIU0CLP4');
                                         mImportMan.AddInputDocument(mDocument_ID);
                                            x := TNxParameters.Create;
                                            try
                                            x.GetOrCreateParam(dtString, 'DocQueue_ID', pkInput).AsString := '2010000101' ;
                                              x.GetOrCreateParam(dtString, 'StoreID', pkInput).AsString := '7161000101' ;
                                              mImportMan.Execute;
                                              mImportMan.outputdocument.ClearValidateErrors;
                                                   // if true then begin
                                                  if Not mhead.Validate() then begin
                                                        mList := TStringList.Create;
                                                        try
                                                           mhead.GetValidateErrors(mList);
                                                           mText := mList.Text;
                                                           NxToken(mText, '=');
                                                           MessageDlg('Automaticky vytvořenou příjemku nelze uložit z těchto důvodů:' + #13#10 + mText,

                                                           mtWarning, [mbOK], 0);
                                                         finally
                                                           mList.Free;
                                                         end;
                                                         mSite.ShowDynFormWithNewDocument('B10I5SAOS3DL3ACU03KIU0CLP4', mSite.SiteContext, mhead);
                                                         //mhead.refresh;
                                                        //msite.ActiveDataSet.RefreshCurrentItemMode;
                                                  end else begin
                                                        mhead.Save;
                                                        mhead.refresh;
                                                        msite.ActiveDataSet.RefreshCurrentItemMode;

                                                        NxShowSimpleMessage('Převodka příjem ' + mhead.GetFieldValueAsstring('Docqueue_ID.code') + '-' + inttostr(mhead.GetFieldValueAsinteger('Ordnumber')) + '/' +
                                                                       mhead.GetFieldValueAsstring('Period_ID.code') + ' byla vytvořena',nil);
                                                  end;
                                            finally
                                               x.Free;
                                                mImportMan.free;
                                            end;

                            end;
  end;

    if index=1 then begin
        mFileList:=TStringList.create;
        try
                mdir:= '\\CZVS0006\Trebic\DL\Hromadne';
                NxGetFileList(mdir,mfilelist,'*.xml',true);
                     ProgressInit(msite, 'Načtení souboru ' + '', 100);
                                for i:=0 to mFileList.count-1 do begin
                                     ProgressSetPos(1+NxFloor(i/mfilelist.Count*99), inttostr(i) +' z '+inttostr(mfilelist.Count));

                                     mFile:=copy(mFileList.Strings[i],1+NxCharPosR('\',mFileList.Strings[i]),Length(mFileList.Strings[i]))+'.xml';
                                     mfilename:=mdir+'\' + mfile;
                                     //NxShowSimpleMessage(mfilename + ' - '+ mdir+' - ' +mfile,nil);
                                     ImportFilePR(TDynSiteForm(mSite).BaseObjectSpace, mfilename, mdir,mfile,msite,true,false,index);
                                end;
                     ProgressDispose()   ;
        finally
            mFileList.free;

        end;

    end;
//  if index=1 then begin
//      ShowMessage(Format('Bude importován soubor %s%s', [mdir,mfile]));
//      ImportFilePR(TDynSiteForm(mSite).BaseObjectSpace, mfilename, mdir,mfile,msite,true,true,index);
//  end;

//  if index=2 then begin
//      ShowMessage(Format('Bude importován soubor %s%s, chyby budou ignorovány', [mdir,mfile]));
//      ImportFilePR(TDynSiteForm(mSite).BaseObjectSpace, mfilename, mdir,mfile,msite,true,true,index);
//  end;
  //TDynSiteForm(mSite).Refreshdata;
//  msite.activedataset.RefreshCurrentItem;
end;



function ImportFileDL(OS: TNxCustomObjectSpace; AFileName: string;directory: string;filename: string;msite:TDynSiteForm;rucne:boolean;chyba:boolean;index:Integer) : string;
var
  mXMLHead : TNxScriptingXMLWrapper;
mID_Docqueue_iD,mID_Store_iD:string;
mObchodniPripad,mdivision_id:string;
mstore_id:string;
mBustransaction_ID:string;
mfind_string:string;
mr,mx,mrsa,mxax:tstringlist;
mStoreCard_ID:string;
mBO_adress,mBO_Sarze,mRowDocRowBatches,mBOIssuedOrderRow:TNxCustomBusinessObject;
mAdress_id:string;
mi_result:integer;
mMon,mMonBatches:TNxCustomBusinessMonikerCollection;
mstorecard_text:string;
mbo_docqueue:TNxCustomBusinessObject;
mQunit:string;
mPacName:string;
mabraqunit:string;
mTyp_Eshopu,MID_SARZE:string;
mi:double;
mInteger:Integer;
mWorkList:Tstringlist;
mSelectedRows,mDocLists:Tstringlist;
x:integer;
mFind:Boolean;
  mImportMan: TNxDocumentImportManager;
  mOS: TNxCustomObjectSpace;
  mInputParams: TNxParameters;
  mParam: TNxParameter;
  mCollRows: TNxCustomBusinessMonikerCollection;
  xx,xxx: integer;
  mList: TStringList;
  mRow: TNxCustomBusinessObject;
  mtext:string;
  mValidateList:tstringlist;
  mRowsOutput:TNxCustomBusinessMonikerCollection;
  msave:boolean;
  mIDoc:integer;
  mpomoc1,mpomoc2,mpomoc3,mpomoc4:string;
  price:double;
  mXStore_ID:string;
begin
    if not FileExists(AFileName) then begin
      Result := '';
      exit;
    end else begin

    try
      mXMLHead := TNxScriptingXMLWrapper.Create;
        mXMLHead.loadFromFile(AFileName);

        mSelectedRows:=TStringList.create;
        mDocLists:=TStringList.create;
         for i := 0 to mXMLHead.getElementsCountInArray('AbraDocument.Rows.Row') - 1 do begin
             if (mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].X_ProvideRow_ID'))<>'' then begin
                  mr:=tstringlist.create;
                  try
                  //   mi:=os.SQLExecute('update issuedorders2 set store_id=' + quotedstr('2Z00000101') + ' where id=' + quotedstr(mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].X_ProvideRow_ID'))) ;
                     os.SQLSelect('select Parent_ID,ID from receivedorders2 where ID=' + quotedstr(mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].X_ProvideRow_ID')),mr) ;
                     if mr.count>0 then begin

                          mFind:=false;
                          for x:=0 to mDocLists.Count-1 do begin
                              if mDocLists.Strings[x]=copy(mr.Strings[0],1,10) then mFind:=true;
                          end;
                          if not mFind then mDocLists.add(copy(mr.Strings[0],1,10));
                          mSelectedRows.add(copy(mr.Strings[0],12,10));
                     end;
                  finally
                      mr.free;
                  end;
             end;

         end;

//      nxshowsimplemessage(inttostr(mSelectedRows.count),nil);
         mID_Division:='5O10000101';
          mID_Docqueue_ID:= 'J7N1000101';
          //mstore_id:='1M00000101';

             // NxShowSimpleMessage('Doklad' + inttostr(mDocLists.count),nil);
             // NxShowSimpleMessage('Rádek' + inttostr(mSelectedRows.count),nil);

                //  mOS := msite.BaseObjectSpace;
                  try
 if mSelectedRows.count=0 then nxshowsimplemessage('není záznam',nil);
                    mInputParams := TNxParameters.Create;

                      if mID_Docqueue_ID<>'' then begin
                          mParam := mInputParams.GetOrCreateParam(dtString, 'DocQueue_ID');
                          mParam.AsString := mID_Docqueue_ID;
                      end;
                      if mID_odberatel<>'' then begin
                          mParam := mInputParams.GetOrCreateParam(dtString, 'Firm_ID');
                          mParam.AsString := mID_odberatel;
                      end;
                      if mSelectedRows.count>0 then begin
                           mParam := mInputParams.GetOrCreateParam(dtString, 'SelectedRows'); // jen povolene radky
                           mParam.AsString := mSelectedRows.Text;
                      end;

                      mParam := mInputParams.GetOrCreateParam(dtString, 'SelectedHeader'); // musi se z nejake hlavicky prebirat hlavickova data
                      mParam.AsString := mDocLists.Strings[0];

//                           nxshowsimplemessage('bb',nil);
                      mImportMan := NxCreateDocumentImportManager(OS, '01CPMINJW3DL342X01C0CX3FCC', '050I5SAOS3DL3ACU03KIU0CLP4');
                      try

                        for mIDoc:=0 to mDocLists.count-1 do begin
                             mImportMan.AddInputDocument(mDocLists.Strings[mIDoc]);
                        end;

                        mImportMan.LoadParams(mInputParams);
                        mImportMan.Execute;
                       // mImportMan.CheckOutputDocument;

  //                           nxshowsimplemessage('cc',nil);
                        mHead:=TnxHeaderBusinessObject(mImportMan.OutputDocument);


                        mRowsOutput := mHead.GetLoadedCollectionMonikerForFieldCode(mHead.GetFieldCode('Rows'));

                       for i := 0 to mXMLHead.getElementsCountInArray('AbraDocument.Rows.Row') - 1 do begin
                                mFind:=false;
                              for ii := 0 to mRowsOutput.Count - 1 do begin
                                   //mRowsOutput.BusinessObject[ii].setFieldValueAsString('Store_ID','2Z00000101');
                                   mXstore_ID:=mRowsOutput.BusinessObject[ii].getFieldValueAsString('Store_ID');
                                   if mRowsOutput.BusinessObject[ii].GetFieldValueAsString('ProvideRow_ID')=mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].X_ProvideRow_ID') then begin
                                        mFind:=true;
                                               //if not(ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].Quantity') and (index=2)) then
                                                                mRowsOutput.BusinessObject[ii].setFieldValueAsFloat('Quantity',NxIBStrToFloat(mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Quantity'))); //text bude  ...
    //                                                           nxshowsimplemessage('cc2',nil);
                                                             {
                                                                if (mRowsOutput.BusinessObject[ii].GetFieldValueAsString('StoreCard_ID.StoreCardCategory_ID')='1700000101') or (mRowsOutput.BusinessObject[ii].GetFieldValueAsString('StoreCard_ID.StoreCardCategory_ID')='2H00000101') or (mRowsOutput.BusinessObject[ii].GetFieldValueAsString('StoreCard_ID.StoreCardCategory_ID')='1300000101') or (mRowsOutput.BusinessObject[ii].GetFieldValueAsString('StoreCard_ID.StoreCardCategory_ID')='A000000101') or (mRowsOutput.BusinessObject[ii].GetFieldValueAsString('StoreCard_ID.StoreCardCategory_ID')='1900000101') then begin
                                                                          if mRowsOutput.BusinessObject[ii].GetFieldValueAsString('Store_ID.X_Cena')='R' then begin
                                                                              price:=mRowsOutput.BusinessObject[ii].GetFieldValueAsFloat('StoreCard_ID.X_Cena_rozprac');

                                                                              if price>0 then begin
                                                                                  //mRowsOutput.BusinessObject[ii].SetFieldValueAsFloat('TotalPrice',0);
                                                                                  mRowsOutput.BusinessObject[ii].SetFieldValueAsFloat('UnitPrice',price);
                                                                               end;
                                                                          end;
                                                                          if mRowsOutput.BusinessObject[ii].GetFieldValueAsString('Store_ID.X_Cena')='S' then begin
                                                                              price:=mRowsOutput.BusinessObject[ii].GetFieldValueAsFloat('StoreCard_ID.X_Cena_skladova');
                                                                               if price>0 then begin
                                                                                  //mRowsOutput.BusinessObject[ii].SetFieldValueAsFloat('TotalPrice',0);
                                                                                  mRowsOutput.BusinessObject[ii].SetFieldValueAsFloat('UnitPrice',price);
                                                                               end;
                                                                          end;
                                                                           if mRowsOutput.BusinessObject[ii].GetFieldValueAsString('Store_ID.X_Cena')='P' then begin
                                                                              price:=mRowsOutput.BusinessObject[ii].GetFieldValueAsFloat('StoreCard_ID.X_Cena_precen');
                                                                               if price>0 then begin
                                                                                  //mRowsOutput.BusinessObject[ii].SetFieldValueAsFloat('TotalPrice',0);
                                                                                  mRowsOutput.BusinessObject[ii].SetFieldValueAsFloat('UnitPrice',price);
                                                                               end;
                                                                          end;
                                                                end;

                                                              }

      //                                                 nxshowsimplemessage('dd',nil);
                                                 // šarže
                                                // if mRow.getFieldValueAsInteger('Storecard_ID.category')=2 then begin
        //                                                       nxshowsimplemessage('ee',nil);
                                                            mMonBatches := mRowsOutput.BusinessObject[ii].GetLoadedCollectionMonikerForFieldCode(mRowsOutput.BusinessObject[ii].GetFieldCode('DocRowBatches'));
                                                            //mRowsOutput.BusinessObject[ii].SetFieldValueAsString('Store_ID','1M00000101');
                                                            for ii := 0 to mXMLHead.getElementsCountInArray('AbraDocument.Rows.Row['+inttostr(i)+'].Batches.Batch') - 1 do begin
                                                                    //if mXMLHead.getElementsCountInArray('AbraDocument.Rows.Row.Batches.Batch')>0 then begin
                                                                    //NxShowSimpleMessage('Sarze ' + mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Batches.Batch['+inttostr(ii)+'].name'),nil);
                                                                    if mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Batches.Batch['+inttostr(ii)+'].name')<>'' then begin
                                                                          mr:=tstringlist.create;
                                                                           // dohledání pohybu šarže
                                                                           try
                                                                                msite.BaseObjectSpace.SQLSelect('SELECT b.ID FROM StoreBatches b where b.name=' + quotedstr(mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Batches.Batch['+inttostr(ii)+'].name')) +
                                                                                                                ' and b.hidden=' + quotedstr('N') ,mr) ;
                                                                                mRowDocRowBatches := mMonBatches.AddNewObject;
                                                                                if mr.count=0 then begin
                                                                                              mRowDocRowBatches.Prefill;
                                                                                              //mRowDocRowBatches.SetFieldValueAsInteger('PosIndex',II);
                                                                                              mRowDocRowBatches.SetFieldValueAsBoolean('NewBatch',True);
                                                                                              //mRowDocRowBatches.SetFieldValueAsString('StoreBatch_ID ',mID_Sarze);
                                                                                              mRowDocRowBatches.SetFieldValueAsString('NewBatchComment','');
                                                                                              mRowDocRowBatches.SetFieldValueAsString('NewBatchName',mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Batches.Batch['+inttostr(ii)+'].name'));
                                                                                              mRowDocRowBatches.SetFieldValueAsString('NewBatchSpecification',mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Batches.Batch['+inttostr(ii)+'].Specification'));
                                                                                              mRowDocRowBatches.SetFieldValueAsDateTime('NewBatchExpirationDate$DATE',now);
                                                                                              mRowDocRowBatches.SetFieldValueAsFloat('Quantity',NxIBStrToFloat(mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Batches.Batch['+inttostr(ii)+'].quantity')));
                                                                                end else begin
                                                                                       mID_Sarze:=mr.Strings[0];
                                                                                             mRowDocRowBatches.Prefill;
                                                                                            //mRowDocRowBatches.SetFieldValueAsInteger('PosIndex',II);
                                                                                            mRowDocRowBatches.SetFieldValueAsBoolean('NewBatch',False);
                                                                                            mRowDocRowBatches.SetFieldValueAsString('StoreBatch_ID',mID_Sarze);
                                                                                            mRowDocRowBatches.SetFieldValueAsFloat('Quantity',NxIBStrToFloat(mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Batches.Batch['+inttostr(ii)+'].quantity')));
                                                                                end;

                                                                           finally
                                                                              mr.free;
                                                                           end;
                                                                    end;
                                                            //  end;
                                                          //    end;
                                                             end;   // konec batches
                                             //  end;

                                   end;     // ***** vazba na provide

                              end;  // konec prohledávacího cyklu


                              // *** nenalezeno , zakládá řádek
                                   if not (mFind) and nxisemptyoid(mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].X_ProvideRow_ID'))  then begin
                                      //NxShowSimpleMessage('Přidání řádku',nil);
                                      mRow := mRowsOutput.AddNewObject;
                                          mRow.Prefill;
                                          mStoreCard_ID:='';
                                          mstorecard_text:='';
                                          mRow.SetFieldValueAsString('Store_ID',mXstore_ID);
                                                    mStoreCard_ID:='';
                                                        mstorecard_text:='';
                                                         if not(ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].Commodity.EAN') and (index=2)) then begin
                                                                if (mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Commodity.EAN')<>'') then begin
                                                                         mr:=tstringlist.create;
                                                                          try
                                                                              msite.BaseObjectSpace.SQLSelect(format('select sc.id||su.code from STOREEANS SE left join StoreUnits SU on SU.id=se.Parent_id left join Storecards SC on sc.id=su.parent_id where ((se.EAN=%s ) or (sc.EAN=%s )) and (sc.hidden=%s)',
                                                                              [quotedstr(mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Commodity.EAN')),quotedstr(mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Commodity.EAN')),QuotedStr('N')]),mr);

                                                                                   if mr.count=0 then begin
                                                                                       //mstorecard_text:=mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Commodity.Ean') + ' - ' + mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Commodity.Name');
                                                                                       mStoreCard_ID:='3NQ1000101';
                                                                                       mQunit:='ks';
                                                                                   end else begin
                                                                                       mStoreCard_ID:=copy(
                                                                                        ReplaceStr(mr.Strings[0],'"',''),1,10);
                                                                                       mQunit:=copy(ReplaceStr(mr.Strings[0],'"',''),11,5);
                                                                                   end;
                                                                           finally
                                                                                mr.free;
                                                                           end;
                                                                 end else begin
                                                                      mStoreCard_ID:='3NQ1000101';
                                                                      mQunit:='ks';

                                                                 end;
                                                         end;
                                                         mRow.SetFieldValueAsString('Storecard_ID',mStoreCard_ID);
                                                          if not(ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].Quantity') and (index=2)) then begin
                                                                mRow.SetFieldValueAsFloat('Quantity',NxIBStrToFloat(mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Quantity'))); //text bude  ...
                                                                mRow.SetFieldValueAsString('Store_ID',mXSTORE_ID);
                                                                mRow.SetFieldValueAsString('Division_ID',mID_Division); //text bude  ...
                                                          end;
                                                  if not NxIsEmptyOID((mRow.GetFieldValueAsString('StoreCard_id.X_BusTransaction_ID'))) then begin
                                                                             mBustransaction_ID:=(mRow.GetFieldValueAsString('StoreCard_id.X_BusTransaction_ID'));
                                                                             mRow.SetFieldValueAsString('BusTransaction_id',mBustransaction_ID );
                                                  end;

                                               {    if (mRow.GetFieldValueAsString('StoreCard_ID.StoreCardCategory_ID')='1700000101') or (mRow.GetFieldValueAsString('StoreCard_ID.StoreCardCategory_ID')='2H00000101') or (mRow.GetFieldValueAsString('StoreCard_ID.StoreCardCategory_ID')='1300000101') or (mRow.GetFieldValueAsString('StoreCard_ID.StoreCardCategory_ID')='A000000101') or (mRow.GetFieldValueAsString('StoreCard_ID.StoreCardCategory_ID')='1900000101') then begin
                                                                          if mRow.GetFieldValueAsString('Store_ID.X_Cena')='R' then begin
                                                                              price:=mRow.GetFieldValueAsFloat('StoreCard_ID.X_Cena_rozprac');
                                                                              if price>0 then mRow.SetFieldValueAsFloat('UnitPrice',price);
                                                                          end;
                                                                          if mRow.GetFieldValueAsString('Store_ID.X_Cena')='S' then begin
                                                                              price:=mRow.GetFieldValueAsFloat('StoreCard_ID.X_Cena_skladova');
                                                                               if price>0 then mRow.SetFieldValueAsFloat('UnitPrice',price);
                                                                          end;
                                                                           if mRow.GetFieldValueAsString('Store_ID.X_Cena')='P' then begin
                                                                              price:=mRow.GetFieldValueAsFloat('StoreCard_ID.X_Cena_precen');
                                                                               if price>0 then mRow.SetFieldValueAsFloat('UnitPrice',price);
                                                                          end;
                                                                end;
                                               }

                                               if mRow.getFieldValueAsInteger('Storecard_ID.category')=2 then begin
                                                  // šarže
                                                            mMonBatches := mrow.GetLoadedCollectionMonikerForFieldCode(mrow.GetFieldCode('DocRowBatches'));

                                                            for ii := 0 to mXMLHead.getElementsCountInArray('AbraDocument.Rows.Row['+inttostr(i)+'].Batches.Batch') - 1 do begin
                                                                    //if mXMLHead.getElementsCountInArray('AbraDocument.Rows.Row.Batches.Batch')>0 then begin
                                                                    //NxShowSimpleMessage('Sarze ' + mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Batches.Batch['+inttostr(ii)+'].name'),nil);
                                                                    if mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Batches.Batch['+inttostr(ii)+'].name')<>'' then begin
                                                                          mr:=tstringlist.create;
                                                                           // dohledání pohybu šarže
                                                                           try
                                                                                msite.BaseObjectSpace.SQLSelect('SELECT b.ID FROM StoreBatches b where b.name=' + quotedstr(mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Batches.Batch['+inttostr(ii)+'].name')) +
                                                                                                                ' and b.hidden=' + quotedstr('N') ,mr) ;
                                                                                mRowDocRowBatches := mMonBatches.AddNewObject;
                                                                                if mr.count=0 then begin
                                                                                              mRowDocRowBatches.Prefill;
                                                                                              mRowDocRowBatches.SetFieldValueAsBoolean('NewBatch',True);
                                                                                              //mRowDocRowBatches.SetFieldValueAsString('StoreBatch_ID ',mID_Sarze);
                                                                                              mRowDocRowBatches.SetFieldValueAsString('NewBatchComment','');
                                                                                              mRowDocRowBatches.SetFieldValueAsString('NewBatchName',mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Batches.Batch['+inttostr(ii)+'].name'));
                                                                                              mRowDocRowBatches.SetFieldValueAsString('NewBatchSpecification',mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Batches.Batch['+inttostr(ii)+'].Specification'));
                                                                                              mRowDocRowBatches.SetFieldValueAsDateTime('NewBatchExpirationDate$DATE',now);
                                                                                              mRowDocRowBatches.SetFieldValueAsFloat('Quantity',NxIBStrToFloat(mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Batches.Batch['+inttostr(ii)+'].quantity')));

                                                                                end else begin
                                                                                       mID_Sarze:=mr.Strings[0];
                                                                                            mRowDocRowBatches.Prefill;
                                                                                            mRowDocRowBatches.SetFieldValueAsBoolean('NewBatch',False);
                                                                                            mRowDocRowBatches.SetFieldValueAsString('StoreBatch_ID',mID_Sarze);
                                                                                            mRowDocRowBatches.SetFieldValueAsFloat('Quantity',NxIBStrToFloat(mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Batches.Batch['+inttostr(ii)+'].quantity')));
                                                                                end;

                                                                           finally
                                                                              mr.free;
                                                                           end;
                                                                    end;
                                                             end;   // konec batches
                                               end;
                                   end;



                       end;

try
                       mhead.SetFieldValueAsString('Description',FileName);
//                       mhead.SetFieldValueAsString('Description', FileName);
finally
end;

                                              if mRowsOutput.count>0 then begin
                                                  mhead.ClearValidateErrors;
                                                   // if true then begin
                                                  if Not mhead.Validate() then begin
                                                        mList := TStringList.Create;
                                                        try
                                                           mhead.GetValidateErrors(mList);
                                                           mText := mList.Text;
                                                           NxToken(mText, '=');
                                                           MessageDlg('Automaticky vytvořenou příjemku nelze uložit z těchto důvodů:' + #13#10 + mText,

                                                           mtWarning, [mbOK], 0);
                                                         finally
                                                           mList.Free;
                                                         end;
                                                         mSite.ShowDynFormWithNewDocument('B50I5SAOS3DL3ACU03KIU0CLP4', mSite.SiteContext, mhead);
                                                         //mhead.refresh;
                                                        //msite.ActiveDataSet.RefreshCurrentItemMode;
                                                  end else begin
                                                        mhead.Save;
                                                        result:=mhead.oid;
                                                        mhead.refresh;
                                                        msite.ActiveDataSet.RefreshCurrentItemMode;
                                                        if index=0 then begin
                                                              if rucne then NxShowSimpleMessage('Dodací líst  ' + mhead.GetFieldValueAsstring('Docqueue_ID.code') + '-' + inttostr(mhead.GetFieldValueAsinteger('Ordnumber')) + '/' +
                                                                       mhead.GetFieldValueAsstring('Period_ID.code') + ' byla vytvořena',nil);
                                                        end;
                                                      //        result:=nxcopyfile(AFileName,Directory + '\Zpracovane\' + FileName);

                                                      //  if result then begin
                                                      //      DeleteFile(AFileName);
                                                      //      if index=0 then begin
                                                      //              if rucne and result and chyba then begin
                                                      //                     NxShowSimpleMessage('Soubor ' + afilename + ' byl přesunut do zpracovaných',nil);
                                                      //              end;
                                                      //      end;
                                                     //   end;
                                                  end;
                                              end;

                      finally
                        mImportMan.Free;
                        mhead.free;
                      end;
                    finally
                      mInputParams.Free;
                    end;

        finally
            mXMLHead.free;
            mDocLists.free;
        end;
     end;
    msite.refresh;
end;






  function mIportmanager(mSite:tdynsiteform;Self: TNxCustomBusinessObject;mDocQueue_ID:string;index:integer):string;
Var
mresult:Boolean;
mOP_ID: string;
  mParams, mP : TNxParameters;
  mPar : TNxParameter;
  mManager : TNxDocumentImportManager ;
  mRow,mbo, mRow_OP, mOP ,mRowDocRowBatches: TNxCustomBusinessObject;
  mRows, mRows_OP : TNxCustomBusinessMonikerCollection;
  mRowsInput, mRowsOutput:TNxCustomBusinessMonikerCollection;
  mRowsInputBatch, mRowsOutputBatch:TNxCustomBusinessMonikerCollection;
  ii,jj,iib,jjb:integer;
  mmesage:string;
  mValidateList:tstringlist;
  mText:string;
begin

                mManager := NxCreateDocumentImportManager(self.ObjectSpace,'E03ZNUMDTCC4PDAUIEY1MBTJC0', '0P0I5SAOS3DL3ACU03KIU0CLP4');

                mParams := TNxParameters.Create();
                try
                  mManager.AddInputDocument(self.OID);
                  mParams.GetOrCreateParam(dtString, 'DocQueue_ID').AsString := mDocQueue_ID;


                  mManager.LoadParams(mParams);
                  mManager.Execute;
                  mManager.OutputDocument.SetFieldValueAsString('Description',mManager.InputDocument.GetFieldValueAsString('Description'));



                  //mManager.OutputDocument.SetFieldValueAsDateTime('DocDate$DATE', mDate);
                  //mRows := mManager.OutputDocument.GetLoadedCollectionMonikerForFieldCode(mManager.OutputDocument.GetFieldCode('Rows'));
                  //for ii:=0 to mRows.Count-1 do begin
                  //    mRows.BusinessObject[ii].SetFieldValueAsstring('Store_ID',0);
                  //end;


                  mRowsInput := mManager.InputDocument.GetLoadedCollectionMonikerForFieldCode(mManager.InputDocument.GetFieldCode('Rows'));
                  mRowsOutput := mManager.OutputDocument.GetLoadedCollectionMonikerForFieldCode(mManager.OutputDocument.GetFieldCode('Rows'));

                   for ii:=0 to mRowsOutput.Count-1 do begin
                                     for jj:=0 to mRowsinput.Count-1 do begin
                                          if mRowsOutput.BusinessObject[ii].getFieldValueAsString('Storecard_ID') = mrowsinput.BusinessObject[jj].getFieldValueAsString('Storecard_ID')  then begin



                                                 // ** šarže
                                                if mRowsOutput.BusinessObject[ii].getFieldValueAsinteger('Storecard_ID.Category')=2 then begin
                                                           mRowsInputBatch := mRowsInput.BusinessObject[ii].GetLoadedCollectionMonikerForFieldCode(mRowsInput.BusinessObject[ii].GetFieldCode('DocRowBatches'));
                                                           mRowsOutputBatch := mRowsOutput.BusinessObject[ii].GetLoadedCollectionMonikerForFieldCode(mRowsOutput.BusinessObject[ii].GetFieldCode('DocRowBatches'));

                                                          // for iib:=0 to mRowsOutputBatch.Count-1 do begin
                                                                  for jjb:=0 to mRowsInputBatch.Count-1 do begin
                                                                      // if mRowsOutputBatch.BusinessObject[iib].getFieldValueAsString('StoreBatch_ID') = mRowsInputBatch.BusinessObject[jjb].getFieldValueAsString('StoreBatch_ID')  then begin
                                                                            mRowDocRowBatches := mRowsOutputBatch.AddNewObject;
                                                                            mRowDocRowBatches.Prefill;
                                                                                mRowDocRowBatches.SetFieldValueAsInteger('PosIndex',jjb);
                                                                                mRowDocRowBatches.SetFieldValueAsBoolean('NewBatch',False);
                                                                                mRowDocRowBatches.SetFieldValueAsString('StoreBatch_ID',mRowsInputBatch.BusinessObject[jjb].getFieldValueAsString('StoreBatch_ID'));
                                                                                mRowDocRowBatches.SetFieldValueAsFloat('Quantity',mRowsInputBatch.BusinessObject[jjb].GetFieldValueAsFloat('quantity'));
                                                                      // end;
                                                                  end;
                                                           //end;

                                                            //mRowsOutput.BusinessObject[ii].SetFieldValueAsFloat('Quantity',mRowsinput.BusinessObject[jj].getFieldValueAsFloat('X_vychystano'));
                                                  end;




                                          end;
                                    end;
                  end;





                            mManager.OutputDocument.ClearValidateErrors;
                                      if Not mManager.OutputDocument.Validate() then begin
                                            mValidateList := TStringList.Create;
                                            try
                                               mManager.OutputDocument.GetValidateErrors(mValidateList);
                                               mText := mValidateList.Text;
                                               NxToken(mText, '=');
                                               MessageDlg('Automaticky vytvořený doklad nelze uložit z těchto důvodů:' + #13#10 + mText,

                                               mtWarning, [mbOK], 0);
                                             finally
                                               mValidateList.Free;
                                             end;
                                             //NxShowSimpleMessage('Chyba',nil);

                                             TDynSiteForm(mSite).ShowDynFormWithNewDocument('BD0I5SAOS3DL3ACU03KIU0CLP4', TDynSiteForm(mSite).SiteContext, mManager.OutputDocument);    // ov

                                             result:='Chyba';
                                      end else begin
                                          mManager.OutputDocument.Save;
                                           //NxShowSimpleMessage('Doklad uložen',nil);
                                      end;


                  result:= inttostr(mManager.OutputDocument.GetFieldValueAsInteger('Ordnumber'));



                 finally
                  mManager.Free;
                  mParams.free;
                 end;


end;






























procedure FormCreate_Hook(Self: TSiteForm);
var
  mAction: TAction;
  mMAction: TMultiAction;
begin
{  mMAction := Self.GetNewMultiAction;
  mMAction.ShowControl := True;
  mMAction.ShowMenuItem := True;
  mMAction.Caption := 'Synchronizace';
  mMAction.Hint := 'Synchronizace test';
  mMAction.Category := 'tabList';
  mMAction.Items.Add('SK ');
  mMAction.OnExecuteItem := @Synchronizace;  }

end;

begin
end.





