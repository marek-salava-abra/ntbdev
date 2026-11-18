uses '_Knihovny_ALL.head', '_Knihovny_ALL.Progress','_Knihovny_ALL.Parse';

Var
mTyp_obchodu:string;
  mXMLHead : TNxScriptingXMLWrapper;
  mSite : TDynSiteForm;
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

const
    mFilter='*.xml';


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



    function ImportFile20(OS: TNxCustomObjectSpace; AFileName: string;directory: string;filename: string;msite:TDynSiteForm;rucne:boolean;chyba:boolean;index:Integer) : Boolean;
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
begin
    if not FileExists(AFileName) then begin
      Result := False;
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
                     os.SQLSelect('select Parent_ID from issuedorders2 where id=' + quotedstr(mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].X_ProvideRow_ID')),mr) ;
                     if mr.count>0 then begin

                          mFind:=false;
                          for x:=0 to mDocLists.Count-1 do begin
                              if mDocLists.Strings[x]=mr.Strings[0] then mFind:=true;
                          end;
                          if not mFind then mDocLists.add(mr.Strings[0]);
                          mSelectedRows.add(mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].X_ProvideRow_ID'));
                     end;
                  finally
                      mr.free;
                  end;
             end;

         end;

     if mSelectedRows.count>0 then begin
         mID_Division:='1300000101';
          mID_Docqueue_ID:= '6A10000101';
          mID_odberatel:= 'DFW6400101';
          //mstore_id:='1M00000101';

             // NxShowSimpleMessage('Doklad' + inttostr(mDocLists.count),nil);
             // NxShowSimpleMessage('Rádek' + inttostr(mSelectedRows.count),nil);

                //  mOS := msite.BaseObjectSpace;
                  try
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


                      mImportMan := NxCreateDocumentImportManager(OS, 'CDMK5QAWZZDL342X01C0CX3FCC', 'E03ZNUMDTCC4PDAUIEY1MBTJC0');
                      try

                        for mIDoc:=0 to mDocLists.count-1 do begin
                             mImportMan.AddInputDocument(mDocLists.Strings[mIDoc]);
                        end;

                        mImportMan.LoadParams(mInputParams);
                        mImportMan.Execute;
                       // mImportMan.CheckOutputDocument;


                        mHead:=TnxHeaderBusinessObject(mImportMan.OutputDocument);
                        mRowsOutput := mHead.GetLoadedCollectionMonikerForFieldCode(mHead.GetFieldCode('Rows'));

                       for i := 0 to mXMLHead.getElementsCountInArray('AbraDocument.Rows.Row') - 1 do begin
                                mFind:=false;
                              for ii := 0 to mRowsOutput.Count - 1 do begin
                                   //mRowsOutput.BusinessObject[ii].setFieldValueAsString('Store_ID','2Z00000101');
                                   if mRowsOutput.BusinessObject[ii].GetFieldValueAsString('ProvideRow_ID')=mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].X_ProvideRow_ID') then begin
                                        mFind:=true;
                                               //if not(ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].Quantity') and (index=2)) then
                                                                mRowsOutput.BusinessObject[ii].setFieldValueAsFloat('Quantity',NxIBStrToFloat(mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Quantity'))); //text bude  ...


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




                                                 // šarže
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
                                                                                              mRowDocRowBatches.SetFieldValueAsDateTime('NewBatchExpirationDate$DATE',mXMLHead.getElementAsFloat('AbraDocument.Rows.Row['+inttostr(i)+'].Batches.Batch['+inttostr(ii)+'].ExpirationDate'));
                                                                                              mRowDocRowBatches.SetFieldValueAsFloat('Quantity',NxIBStrToFloat(mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Batches.Batch['+inttostr(ii)+'].quantity')));
                                                                                end else begin
                                                                                       mID_Sarze:=mr.Strings[0];
                                                                                             mRowDocRowBatches.Prefill;
                                                                                            //mRowDocRowBatches.SetFieldValueAsInteger('PosIndex',II);
                                                                                            mRowDocRowBatches.SetFieldValueAsBoolean('NewBatch',False);
                                                                                            mRowDocRowBatches.SetFieldValueAsString('StoreBatch_ID',mID_Sarze);

                                                                                            mRowDocRowBatches.SetFieldValueAsFloat('Quantity',NxIBStrToFloat(mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Batches.Batch['+inttostr(ii)+'].quantity')));
                                                                                            mi:=mHead.ObjectSpace.SQLExecute('update StoreBatches set ExpirationDate$Date= ' + mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Batches.Batch['+inttostr(ii)+'].ExpirationDate')
                                                                                                     + ' where id=' + quotedstr(mID_Sarze));
                                                                                end;

                                                                           finally
                                                                              mr.free;
                                                                           end;
                                                                    end;
                                                            //  end;
                                                          //    end;
                                                             end;   // konec batches

                                   end;     // ***** vazba na provide

                              end;  // konec prohledávacího cyklu


                              // *** nenalezeno , zakládá řádek
                                   if not mFind then begin
                                      //NxShowSimpleMessage('Přidání řádku',nil);
                                      mRow := mRowsOutput.AddNewObject;
                                          mRow.Prefill;
                                          mStoreCard_ID:='';
                                          mstorecard_text:='';
                                          mRow.SetFieldValueAsString('Store_ID','1M00000101');
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
                                                                mRow.SetFieldValueAsString('Store_ID','1M00000101');
                                                                mRow.SetFieldValueAsString('Division_ID',mID_Division); //text bude  ...
                                                          end;
                                                  if not NxIsEmptyOID((mRow.GetFieldValueAsString('StoreCard_id.X_BusTransaction_ID'))) then begin
                                                                             mBustransaction_ID:=(mRow.GetFieldValueAsString('StoreCard_id.X_BusTransaction_ID'));
                                                                             mRow.SetFieldValueAsString('BusTransaction_id',mBustransaction_ID );
                                                  end;

                                                   if (mRow.GetFieldValueAsString('StoreCard_ID.StoreCardCategory_ID')='1700000101') or (mRow.GetFieldValueAsString('StoreCard_ID.StoreCardCategory_ID')='2H00000101') or (mRow.GetFieldValueAsString('StoreCard_ID.StoreCardCategory_ID')='1300000101') or (mRow.GetFieldValueAsString('StoreCard_ID.StoreCardCategory_ID')='A000000101') or (mRow.GetFieldValueAsString('StoreCard_ID.StoreCardCategory_ID')='1900000101') then begin
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
                                                                                              mRowDocRowBatches.SetFieldValueAsDateTime('NewBatchExpirationDate$DATE',mXMLHead.getElementAsFloat('AbraDocument.Rows.Row['+inttostr(i)+'].Batches.Batch['+inttostr(ii)+'].ExpirationDate'));
                                                                                              mRowDocRowBatches.SetFieldValueAsFloat('Quantity',NxIBStrToFloat(mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Batches.Batch['+inttostr(ii)+'].quantity')));

                                                                                end else begin
                                                                                       mID_Sarze:=mr.Strings[0];
                                                                                            mRowDocRowBatches.Prefill;
                                                                                            mRowDocRowBatches.SetFieldValueAsBoolean('NewBatch',False);
                                                                                            mRowDocRowBatches.SetFieldValueAsString('StoreBatch_ID',mID_Sarze);
                                                                                            mRowDocRowBatches.SetFieldValueAsFloat('Quantity',NxIBStrToFloat(mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Batches.Batch['+inttostr(ii)+'].quantity')));
                                                                                            mi:=mHead.ObjectSpace.SQLExecute('update StoreBatches set ExpirationDate$Date= ' + mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Batches.Batch['+inttostr(ii)+'].ExpirationDate')
                                                                                                     + ' where id=' + quotedstr(mID_Sarze));
                                                                                end;

                                                                           finally
                                                                              mr.free;
                                                                           end;
                                                                    end;
                                                             end;   // konec batches

                                   end;



                       end;


                       mhead.SetFieldValueAsString('Description',FileName);


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
                                                        mhead.refresh;
                                                        msite.ActiveDataSet.RefreshCurrentItemMode;
                                                        if index=0 then begin
                                                              if rucne then NxShowSimpleMessage('Prijemka ' + mhead.GetFieldValueAsstring('Docqueue_ID.code') + '-' + inttostr(mhead.GetFieldValueAsinteger('Ordnumber')) + '/' +
                                                                       mhead.GetFieldValueAsstring('Period_ID.code') + ' byla vytvořena',nil);
                                                        end;
                                                              result:=nxcopyfile(AFileName,Directory + '\Zpracovane\' + FileName);

                                                        if result then begin
                                                            DeleteFile(AFileName);
                                                            if index=0 then begin
                                                                    if rucne and result and chyba then begin
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
                end else begin
                     NxShowSimpleMessage('Soubor ' + AFileName + ' nelze importovat , protože neobsahuje žádné čerpatelné řádky',nil);
                end;
        finally
            mXMLHead.free;
            mDocLists.free;
        end;


   end;
    result:=true;
end;



{

    function ImportFile20(OS: TNxCustomObjectSpace; AFileName: string;directory: string;filename: string;msite:TDynSiteForm;rucne:boolean;chyba:boolean;index:Integer) : Boolean;
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
begin
    if not FileExists(AFileName) then begin
      Result := False;
      exit;
    end else begin

    try
      mXMLHead := TNxScriptingXMLWrapper.Create;
        mXMLHead.loadFromFile(AFileName);



    //  if not(ErrtElementString(mXMLHead ,'ABRADocument.ExternalNumber') and (index=2)) then
    //      mexistuje:=getIDfromfield(os,'ID','ReceivedOrders','ExternalNumber',mXMLHead.getElementAsString('ABRADocument.ExternalNumber'),'','');
          mID_Division:='1000000101';
          mID_Docqueue_ID:= '6A10000101';
          mID_odberatel:= 'DFW6400101';
          mstore_id:='1M00000101';

        mHead := TNxHeaderBusinessObject(OS.CreateObject('E03ZNUMDTCC4PDAUIEY1MBTJC0'));
        try
                if ((nxisemptyoid(mexistuje)) or ( msite.CompanyCache.GetUserID='SUPER00000')) then begin
                     // if ((msite.CompanyCache.GetUserID='SUPER00000') and (rucne)) then NxShowSimpleMessage('Doklad již existuje - prosím zmažte',nil);
                      mHead.New;
                      mHead.Prefill;
                      if rucne and chyba then NxShowSimpleMessage('Novy',nil);
                      mHead.SetFieldValueAsString('DocQueue_ID', mID_Docqueue_ID);
                      mHead.SetFieldValueAsString('Firm_ID', mID_odberatel);
                     // if not(ErrtElementString(mXMLHead ,'ABRADocument.ExternalNumber') and (index=2)) then
                     //         mHead.SetFieldValueAsString('ExternalNumber',mXMLHead.getElementAsString('ABRADocument.ExternalNumber'));
                     // if msite.CompanyCache.GetUserID='SUPER00000' then NxShowSimpleMessage('Hlavička v pořádku',nil);



                       for i := 0 to mXMLHead.getElementsCountInArray('AbraDocument.Rows.Row') - 1 do begin
                                          mRow := mHead.Rows.AddNewObject;
                                          mRow.Prefill;
                                          mStoreCard_ID:='';
                                          mstorecard_text:='';

                                            mRow.SetFieldValueAsInteger('PosIndex',i);
                                                    //mRow.SetFieldValueAsInteger('RowType',3);

                                                    mRow.SetFieldValueAsString('Store_ID','1M00000101');


                                                    mStoreCard_ID:='';
                                                        mstorecard_text:='';
                                                         if not(ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].Commodity.EAN') and (index=2)) then begin
                                                                if (mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Commodity.EAN')<>'') then begin
                                                                         mr:=tstringlist.create;
                                                                          try
                                                                              msite.BaseObjectSpace.SQLSelect(format('select sc.id||su.code from STOREEANS SE left join StoreUnits SU on SU.id=se.Parent_id left join Storecards SC on sc.id=su.parent_id where ((se.EAN=%s ) or (sc.EAN=%s )) and (sc.hidden=%s)',
                                                                              [quotedstr(mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Commodity.EAN')),quotedstr(mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Commodity.EAN')),QuotedStr('N')]),mr);

                                                        //NxShowSimpleMessage('Hledání skladové karty v počtu ' + inttostr(mr.count),nil);
                                                                                   if mr.count=0 then begin
                                                                                       //mstorecard_text:=mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Commodity.Ean') + ' - ' + mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Commodity.Name');

                                                                                       mStoreCard_ID:='3NQ1000101';
                                                                                       mQunit:='ks';
                                                                                   end else begin
                                                                                       mStoreCard_ID:=copy(

                                                                                        ReplaceStr(mr.Strings[0],'"',''),1,10);
                                                                                       mQunit:=copy(ReplaceStr(mr.Strings[0],'"',''),11,5);

                                                                                       //nxShowSimpleMessage(copy(mr.Strings[0],1,10),nil);

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
                                                          if not(ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].Quantity') and (index=2)) then
                                                                mRow.SetFieldValueAsFloat('Quantity',NxIBStrToFloat(mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Quantity'))); //text bude  ...
                                                          //mRow.SetFieldValueAsstring('QUnit',mQunit);




                                                        // mabraqunit :='';
                                                        // mr:=tstringlist.create;
                                                        // try
                                                        //      msite.BaseObjectSpace.SQLSelect('SELECT ID FROM DefRollData A WHERE A.CLSID = ''TE4DZNKNND34R3SQOPGPEE1TU4'' and code=' + quotedstr(mQunit),mr) ;
                                                        //      if mr.count>0 then begin
                                                        //         mAbraQunit:=copy(mr.Strings[0],1,10);
                                                        //      end;
                                                        // finally
                                                        //    mr.free;
                                                        // end;
                                                mRow.SetFieldValueAsString('Store_ID','1M00000101');
                                                mRow.SetFieldValueAsString('Division_ID',mID_Division); //text bude  ...






                                                  if not NxIsEmptyOID((mRow.GetFieldValueAsString('StoreCard_id.X_BusTransaction_ID'))) then begin
                                                                             mBustransaction_ID:=(mRow.GetFieldValueAsString('StoreCard_id.X_BusTransaction_ID'));
                                                                             mRow.SetFieldValueAsString('BusTransaction_id',mBustransaction_ID );
                                                           end;
                                                 mRow.SetFieldValueAsString('Store_ID','1M00000101');

                                                  if not(ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].X_ProvideRow_ID') ) then begin
                                                mr:=tstringlist.create;
                                                    try
                                                       os.SQLSelect('Select id from issuedorders2 where id=' + quotedstr(mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].X_ProvideRow_ID')),mr);
                                                       if mr.count>0 then begin


                                                                        // vazba na OV
                                                                        mBOIssuedOrderRow:= os.CreateObject('CHMK5QAWZZDL342X01C0CX3FCC');
                                                                               try
                                                                                       mBOIssuedOrderRow.load(mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].X_ProvideRow_ID'),nil);

                                                                                       mRow.SetFieldValueAsString('ProvideRowType','IO');
                                                                                       mRow.SetFieldValueAsString('Provide_ID',mBOIssuedOrderRow.GetFieldValueAsString('Parent_id'));
                                                                                       mRow.SetFieldValueAsString('ProvideRow_ID',mBOIssuedOrderRow.OID);
                                                                                       //NxShowSimpleMessage( mBOIssuedOrderRow.oid,nil);



                                                                                       try

                                                                                              mi:=0;
                                                                                              mi:=mBOIssuedOrderRow.GetFieldValueAsFloat('DeliveredQuantity') + mrow.GetFieldValueAsFloat('Quantity') ;
                                                                                              mBOIssuedOrderRow.SetFieldValueAsFloat('DeliveredQuantity',mi);
                                                                                              mBOIssuedOrderRow.SetFieldValueAsDateTime('DeliveryDate$DATE',mrow.GetFieldValueAsDateTime('parent_id.docdate$date'))  ;

                                                                                              mBOIssuedOrderRow.save;
                                                                                               minteger:=os.SQLExecute('update issuedOrders set closed=''A'' where id=' + quotedstr(mRow.getFieldValueAsString('Provide_ID'))) ;

                                                                                           finally
                                                                                            mBOIssuedOrderRow.free;

                                                                                           end;



                                                                               finally
                                                                                  mBOIssuedOrderRow.free;
                                                                               end;

                                                                        end;

                                                       finally
                                                            mr.free;
                                                       end;

                                                        mRow.SetFieldValueAsString('Store_ID','1M00000101');


                                                            // šarže
                                                            mMonBatches := mrow.GetLoadedCollectionMonikerForFieldCode(mrow.GetFieldCode('DocRowBatches'));
                                                            mRow.SetFieldValueAsString('Store_ID','1M00000101');
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
                                                              end;
                                                          //    end;
                                                             end;   // konec batches














                                                     //    mr:=tstringlist.create;
                                                     //    try
                                                     //         msite.BaseObjectSpace.SQLSelect('SELECT ID FROM Vatrates A WHERE a.Tariff=' + quotedstr(mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].VATRate')),mr) ;
                                                     //         if mr.count>0 then begin
                                                     //            mRow.SetFieldValueAsString('VatRate_ID',copy(mr.Strings[0],1,10));
                                                     //            NxShowSimpleMessage(copy(mr.Strings[0],1,10),nil);
                                                     //         end;
                                                     //    finally
                                                     //       mr.free;
                                                     //    end;






                       end;    // cyklus řádků








                              if rucne then begin
                                  mhead.ClearValidateErrors;
                                  if Not mhead.Validate() then begin
                                        mList := TStringList.Create;
                                        try
                                           mhead.GetValidateErrors(mList);
                                           mText := mList.Text;
                                           NxToken(mText, '=');
                                           MessageDlg('Automaticky vytvořenou fakturu nelze uložit z těchto důvodů:' + #13#10 + mText,

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
                                        if rucne then NxShowSimpleMessage('Objednávka ' + mhead.GetFieldValueAsstring('Docqueue_ID.code') + '-' + inttostr(mhead.GetFieldValueAsinteger('Ordnumber')) + '/' +
                                                 mhead.GetFieldValueAsstring('Period_ID.code') + ' byla vytvořena',nil);
                                        result:=nxcopyfile(AFileName,Directory + '\Zpracovane\' + FileName);

                                        if result then begin
                                            DeleteFile(AFileName);
                                            if rucne and result and chyba then begin
                                                   NxShowSimpleMessage('Soubor ' + afilename + ' byl přesunut do zpracovaných',nil);
                                            end;
                                        end;
                              end;





                    end else begin
                        if rucne then NxShowSimpleMessage('Doklad již existuje',nil);
                    end;
                end;
            finally
                 mhead.free;
            end;
     finally
      mXMLHead.Free;
     end;
    Result := True;

end;
end;
      }
{
Vyvolává se po provedení inicializace agendy/formuláře. V tento okamžik je již na formuláři dostupný SiteContext.
}
procedure InitSite_Hook(Self: TSiteForm);
var
  mMAction: TMultiAction;
  mAction: TBasicAction;
  mAList: TActionList;
  i: integer;
  mAct: TBasicAction;
begin
 if false then begin
      mMAction := Self.GetNewMultiAction;
          mMAction.ShowControl := True;
          mMAction.ShowMenuItem := True;
          mMAction.Hint := 'Import z LipoStocking';
          mMAction.Caption := 'Import z LipoStocking';
          mMAction.Items.Add('Import z LipoStocking');
          mMAction.Items.Add('Hromadný import');
          mMAction.Category := 'tabList';
          mMAction.OnExecuteItem := @OnExec;
  end;

    //      mMAction := Self.GetNewMultiAction;
    //      mMAction.ShowControl := True;
    //      mMAction.ShowMenuItem := True;
    //      mMAction.Hint := 'Aktivace výrobou';
    //      mMAction.Caption := 'Aktivace výrobou';
    //      mMAction.Items.Add('Aktivace výrobou');
    //      mMAction.Category := 'tabList';
    //      mMAction.OnExecuteItem := @AdditionalCostOnExec;

end;



procedure AdditionalCostOnExec(Sender: TComponent;index:integer);
var
mBO, mRow:TNxCustomBusinessObject;
mMon,mMonAdditionalCost:TNxCustomBusinessMonikerCollection;
mprice:double;
begin
  msite:=TComponent(Sender).DynSite;
  mbo:=TDynSiteForm(msite).CurrentObject;
       mMon := mbo.GetLoadedCollectionMonikerForFieldCode(mbo.GetFieldCode('ROWS'));
            if mMon.count>0 then begin
                 try
                    for i:=0 to mmon.Count-1 do begin
                       // mRow:=mMon.BusinessObject[i];
                          mprice:=0;
                          mprice:=mMon.BusinessObject[i].GetFieldValueAsFloat('quantity') * mMon.BusinessObject[i].GetFieldValueAsFloat('Unitrate') *
                                  (mMon.BusinessObject[i].GetFieldValueAsFloat('storecard_ID.X_cena_skladova') -
                                  mMon.BusinessObject[i].GetFieldValueAsFloat('storecard_ID.X_cena_rozprac')
                                  )    ;
                          mMon.BusinessObject[i].SetFieldValueAsBoolean('AdditionalCosts_ID.OtherCostUsed',true);
                          mMon.BusinessObject[i].SetFieldValueAsBoolean('AdditionalCosts_ID.OtherCostIsLocal',false);
                          mMon.BusinessObject[i].SetFieldValueAsFloat('AdditionalCosts_ID.OtherCostAmount',mprice);
                          mMon.BusinessObject[i].SetFieldValueAsFloat('AdditionalCosts_ID.OtherCostTariff',mprice);






                        //  NxShowSimpleMessage('AAAA',nil);
                    end;




                 finally

                 end;
            end;
        mbo.save;
     //   NxShowSimpleMessage('ulozeno',nil);
  msite.activedataset.RefreshCurrentItem;
end;






procedure OnExec(Sender: TComponent;index:integer);
var

  zadej:string;
  mfilename:string;
  mdir,mfile:string;
  mFileList:TStringList;
begin
  //mSite := NxFinddySiteForm(Sender);
  msite:=TComponent(Sender).DynSite;
  if index=0 then begin
         if PromptForFileName(mFileName, mfilter, '', 'Soubor ESHOP TOP', '\\CZVS0006\Trebic\DL', False) then begin
              mdir:=copy(mfilename,0,NxCharPosR('\',mfilename));
              mFile:=copy(mfilename,1+NxCharPosR('\',mfilename),Length(mfilename));

         end;
         ImportFile20(TDynSiteForm(mSite).BaseObjectSpace, mfilename, mdir,mfile,msite,true,false,index);
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
                                     ImportFile20(TDynSiteForm(mSite).BaseObjectSpace, mfilename, mdir,mfile,msite,true,false,index);
                                end;
                     ProgressDispose()   ;
        finally
            mFileList.free;

        end;

    end;
//  if index=1 then begin
//      ShowMessage(Format('Bude importován soubor %s%s', [mdir,mfile]));
//      ImportFile20(TDynSiteForm(mSite).BaseObjectSpace, mfilename, mdir,mfile,msite,true,true,index);
//  end;

//  if index=2 then begin
//      ShowMessage(Format('Bude importován soubor %s%s, chyby budou ignorovány', [mdir,mfile]));
//      ImportFile20(TDynSiteForm(mSite).BaseObjectSpace, mfilename, mdir,mfile,msite,true,true,index);
//  end;
  //TDynSiteForm(mSite).Refreshdata;
  msite.activedataset.RefreshCurrentItem;
end;






{
Vyvolává se při ukládání vlastností formuláře.
}
procedure SavingProperties_Hook(Self: TSiteForm; AParams: TNxParameters);
begin

end;

begin
end.
