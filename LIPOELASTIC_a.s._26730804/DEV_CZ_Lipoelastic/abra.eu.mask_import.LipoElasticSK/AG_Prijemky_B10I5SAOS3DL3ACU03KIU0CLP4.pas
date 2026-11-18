uses '_Knihovny_ALL.head', '_Knihovny_ALL.Progress','_Knihovny_ALL.Parse', 'Synchronizace.API'
     ;






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

function ImportFileDL(OS: TNxCustomObjectSpace; AFileName: string;directory: string;filename: string;msite:TDynSiteForm;rucne:boolean;chyba:boolean;index:Integer) : string;
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
  mXStore_ID:string;
begin
   mstore_ID:='';
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
                     os.SQLSelect('select Parent_ID,ID @{COLLATEUNICODE} from receivedorders2 where ID=' + quotedstr(mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].X_ProvideRow_ID')),mr) ;
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
          mID_Docqueue_ID:= '5G10000101';
          mstore_id:='3000000101';

             // NxShowSimpleMessage('Doklad' + inttostr(mDocLists.count),nil);
             // NxShowSimpleMessage('Rádek' + inttostr(mSelectedRows.count),nil);

                //  mOS := msite.BaseObjectSpace;
                  try
               if mSelectedRows.count=0 then begin
                      nxshowsimplemessage('není záznam',nil);
                      exit;
               end else begin
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
                                               if not(ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].Row_ID') ) then
                                                      mRowsOutput.BusinessObject[ii].SetFieldValueAsString('X_StoreDocuments2_ID',mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Row_ID'));


                                               //if not(ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].Quantity') and (index=2)) then

                                                                if mstore_id<>'' then begin
                                                                   mRowsOutput.BusinessObject[ii].SetFieldValueAsString('Store_ID',mstore_id); //text bude  ...
                                                                end;
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
                                                                                msite.BaseObjectSpace.SQLSelect('SELECT b.ID FROM StoreBatches b where b.name=' + quotedstr(mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Batches.Batch['+inttostr(ii)+'].name'))
                                                                                                                +' and Storecard_ID=' + quotedstr(mRowsOutput.BusinessObject[ii].GetFieldValueAsString('StoreCard_ID'))
                                                                                                                +' and b.hidden=' + quotedstr('N') ,mr) ;
                                                                                mRowDocRowBatches := mMonBatches.AddNewObject;
                                                                                if mr.count=0 then begin
                                                                                              mRowDocRowBatches.Prefill;
                                                                                              //mRowDocRowBatches.SetFieldValueAsInteger('PosIndex',II);
                                                                                              mRowDocRowBatches.SetFieldValueAsBoolean('NewBatch',True);
                                                                                              //mRowDocRowBatches.SetFieldValueAsString('StoreBatch_ID ',mID_Sarze);
                                                                                              mRowDocRowBatches.SetFieldValueAsString('NewBatchComment','');
                                                                                              mRowDocRowBatches.SetFieldValueAsString('NewBatchName',mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Batches.Batch['+inttostr(ii)+'].name'));
                                                                                              mRowDocRowBatches.SetFieldValueAsString('NewBatchSpecification',mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Batches.Batch['+inttostr(ii)+'].Specification'));
                                                                                              mRowDocRowBatches.SetFieldValueAsDateTime('NewBatchExpirationDate$DATE',mXMLHead.getElementAsfloat('AbraDocument.Rows.Row['+inttostr(i)+'].Batches.Batch['+inttostr(ii)+'].ExpirationDate'));
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
                                                                              msite.BaseObjectSpace.SQLSelect(format('select sc.id||su.code @{COLLATEUNICODE} from STOREEANS SE left join StoreUnits SU on SU.id=se.Parent_id left join Storecards SC on sc.id=su.parent_id where ((se.EAN=%s ) or (sc.EAN=%s )) and (sc.hidden=%s)',
                                                                              [quotedstr(mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Commodity.EAN')),quotedstr(mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Commodity.EAN')),QuotedStr('N')]),mr);

                                                                                   if mr.count=0 then begin
                                                                                       //mstorecard_text:=mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Commodity.Ean') + ' - ' + mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Commodity.Name');
                                                                                       mStoreCard_ID:='3NQ1000101';
                                                                                       mQunit:='ks';
                                                                                   end else begin
                                                                                       mStoreCard_ID:=copy(
                                                                                        ReplaceStr(mr.Strings[0],'"',''),1,10);
                                                                                        //mStoreCard_ID:=Validate_API(msite.BaseObjectSpace,mStoreCard_ID);

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
                                                                                msite.BaseObjectSpace.SQLSelect('SELECT b.ID FROM StoreBatches b where b.name=' + quotedstr(mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Batches.Batch['+inttostr(ii)+'].name'))
                                                                                                                + ' and Storecard_ID=' + quotedstr(mrow.GetFieldValueAsString('StoreCard_ID'))
                                                                                                                + ' and b.hidden=' + quotedstr('N') ,mr) ;
                                                                                mRowDocRowBatches := mMonBatches.AddNewObject;
                                                                                if mr.count=0 then begin
                                                                                              mRowDocRowBatches.Prefill;
                                                                                              mRowDocRowBatches.SetFieldValueAsBoolean('NewBatch',True);
                                                                                              //mRowDocRowBatches.SetFieldValueAsString('StoreBatch_ID ',mID_Sarze);
                                                                                              mRowDocRowBatches.SetFieldValueAsString('NewBatchComment','');
                                                                                              mRowDocRowBatches.SetFieldValueAsString('NewBatchName',mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Batches.Batch['+inttostr(ii)+'].name'));
                                                                                              mRowDocRowBatches.SetFieldValueAsString('NewBatchSpecification',mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Batches.Batch['+inttostr(ii)+'].Specification'));
                                                                                              mRowDocRowBatches.SetFieldValueAsDateTime('NewBatchExpirationDate$DATE',mXMLHead.getElementAsfloat('AbraDocument.Rows.Row['+inttostr(i)+'].Batches.Batch['+inttostr(ii)+'].ExpirationDate'));
                                                                                              //mRowDocRowBatches.SetFieldValueAsDateTime('ProductionDate$DATE',mXMLHead.getElementAsfloat('AbraDocument.Rows.Row['+inttostr(i)+'].Batches.Batch['+inttostr(ii)+'].ProductionDate'));
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
                  //      mhead.SetFieldValueAsString('IntrastatTransactionType_ID','0101000000');
                  //      mhead.SetFieldValueAsString('IntrastatDeliveryTerm_ID','3001000000');
                  //      mhead.SetFieldValueAsString('IntrastatTransportationType_ID','2000000000');




                       mhead.SetFieldValueAsString('Description',copy(FileName,1,49));
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






function ImportFilePRV(OS: TNxCustomObjectSpace; AFileName: string;directory: string;filename: string;msite:TDynSiteForm;rucne:boolean;chyba:boolean;index:Integer) : string;
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
  mXStore_ID:string;
begin
    if not FileExists(AFileName) then begin
      Result := '';
      exit;
    end else begin
                   //nxshowsimplemessage('00',nil);
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
          mID_Docqueue_ID:= 'R7N1000101';
          //mstore_id:='1M00000101';
              //       nxshowsimplemessage('aa',nil);
             // NxShowSimpleMessage('Doklad' + inttostr(mDocLists.count),nil);
             // NxShowSimpleMessage('Rádek' + inttostr(mSelectedRows.count),nil);

                //  mOS := msite.BaseObjectSpace;
                  try
 if mSelectedRows.count=0 then begin
      nxshowsimplemessage('Nenalezen žádný čerpatelný doklad , import je přerušen.',nil);
      exit;
 end else begin
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

                  //         nxshowsimplemessage('bb',nil);
                      mImportMan := NxCreateDocumentImportManager(OS, '01CPMINJW3DL342X01C0CX3FCC', '0P0I5SAOS3DL3ACU03KIU0CLP4');
                      try

                        for mIDoc:=0 to mDocLists.count-1 do begin
                             mImportMan.AddInputDocument(mDocLists.Strings[mIDoc]);
                        end;

                        mImportMan.LoadParams(mInputParams);
                        mImportMan.Execute;
                        //           nxshowsimplemessage('cc',nil);
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

                                                                mRowsOutput.BusinessObject[ii].setFieldValueAsstring('X_StoreDocuments2_ID',(mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].X_StoreDocuments2_ID'))); //text bude  ...
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
                                                                                msite.BaseObjectSpace.SQLSelect('SELECT b.ID FROM StoreBatches b where b.name=' + quotedstr(mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Batches.Batch['+inttostr(ii)+'].name'))
                                                                                                                +' and Storecard_ID=' + quotedstr(mRowsOutput.BusinessObject[ii].GetFieldValueAsString('StoreCard_ID'))
                                                                                                                +' and b.hidden=' + quotedstr('N') ,mr) ;
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
                                                                              msite.BaseObjectSpace.SQLSelect(format('select sc.id||su.code @{COLLATEUNICODE} from STOREEANS SE left join StoreUnits SU on SU.id=se.Parent_id left join Storecards SC on sc.id=su.parent_id where ((se.EAN=%s ) or (sc.EAN=%s )) and (sc.hidden=%s)',
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
                                                                mRow.SetFieldValueAsstring('X_StoreDocuments2_ID',(mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].X_StoreDocuments2_ID'))); //text bude  ...

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
                                                                                msite.BaseObjectSpace.SQLSelect('SELECT b.ID FROM StoreBatches b where b.name=' + quotedstr(mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Batches.Batch['+inttostr(ii)+'].name'))
                                                                                                                +' and Storecard_ID=' + quotedstr(mRow.GetFieldValueAsString('StoreCard_ID'))
                                                                                                                + ' and b.hidden=' + quotedstr('N') ,mr) ;
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
                                                         mSite.ShowDynFormWithNewDocument('BD0I5SAOS3DL3ACU03KIU0CLP4', mSite.SiteContext, mhead);
                                                         //mhead.refresh;
                                                        //msite.ActiveDataSet.RefreshCurrentItemMode;
                                                  end else begin
                                                        mhead.Save;
                                                        result:=mhead.oid;
                                                        mhead.refresh;
                                                        msite.ActiveDataSet.RefreshCurrentItemMode;
                                                        if index=0 then begin
                                                              if rucne then NxShowSimpleMessage('Převodka výdej líst  ' + mhead.GetFieldValueAsstring('Docqueue_ID.code') + '-' + inttostr(mhead.GetFieldValueAsinteger('Ordnumber')) + '/' +
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
  iii:integer;
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
                     os.SQLSelect('select Parent_ID,ID @{COLLATEUNICODE} from issuedorders2 where X_ProvideRow_ID=' + quotedstr(mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].X_ProvideRow_ID')),mr) ;
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
          mID_Docqueue_ID:= '5G10000101';
 //         mID_odberatel:= '3010000101';
          //mstore_id:='1M00000101';

             // NxShowSimpleMessage('Doklad' + inttostr(mDocLists.count),nil);
             // NxShowSimpleMessage('Rádek' + inttostr(mSelectedRows.count),nil);

                //  mOS := msite.BaseObjectSpace;
                  try
 if mSelectedRows.count=0 then begin
       nxshowsimplemessage('Nenalezen čerpatelný doklad , import je přerušen',nil);
       exit;
  end else begin
                    mInputParams := TNxParameters.Create;

                      if mID_Docqueue_ID<>'' then begin
                          mParam := mInputParams.GetOrCreateParam(dtString, 'DocQueue_ID');
                          if index=2 then mParam.AsString := '2B30000101' else mParam.AsString := mID_Docqueue_ID;
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
                            for ii := 0 to mRowsOutput.Count - 1 do begin
                                mMonBatches := mRowsOutput.BusinessObject[ii].GetLoadedCollectionMonikerForFieldCode(mRowsOutput.BusinessObject[ii].GetFieldCode('DocRowBatches'));
                                     for iii := 0 to mMonBatches.Count - 1 do begin
                                           mMonBatches.BusinessObject[iii].MarkForDelete;
                                     end;
                            end;



                       for i := 0 to mXMLHead.getElementsCountInArray('AbraDocument.Rows.Row') - 1 do begin
                                mFind:=false;
                              for ii := 0 to mRowsOutput.Count - 1 do begin
                                   //mRowsOutput.BusinessObject[ii].setFieldValueAsString('Store_ID','3000000101');
                                   mXstore_ID:=mRowsOutput.BusinessObject[ii].getFieldValueAsString('Store_ID');
                                   if mRowsOutput.BusinessObject[ii].GetFieldValueAsString('X_ProvideRow_ID')=mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].X_ProvideRow_ID') then begin
                                        mFind:=true;
                                               //if not(ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].Quantity') and (index=2)) then
                                                                //mRowsOutput.BusinessObject[ii].setFieldValueAsString('Store_ID','3000000101');
                                                                mRowsOutput.BusinessObject[ii].setFieldValueAsstring('X_StoreDocuments2_ID',(mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].X_StoreDocuments2_ID'))); //text bude  ...

                                                                mRowsOutput.BusinessObject[ii].setFieldValueAsFloat('Quantity',NxIBStrToFloat(mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Quantity'))); //text bude  ...


    //                                                           nxshowsimplemessage('cc2',nil);
                                                                 price:=0;
                                                                if (mRowsOutput.BusinessObject[ii].GetFieldValueAsString('StoreCard_ID.StoreCardCategory_ID')='1700000101') or (mRowsOutput.BusinessObject[ii].GetFieldValueAsString('StoreCard_ID.StoreCardCategory_ID')='2H00000101') or (mRowsOutput.BusinessObject[ii].GetFieldValueAsString('StoreCard_ID.StoreCardCategory_ID')='1300000101') or (mRowsOutput.BusinessObject[ii].GetFieldValueAsString('StoreCard_ID.StoreCardCategory_ID')='A000000101') or (mRowsOutput.BusinessObject[ii].GetFieldValueAsString('StoreCard_ID.StoreCardCategory_ID')='1900000101') then begin
                                                                          case mRowsOutput.BusinessObject[ii].GetFieldValueAsString('Store_ID.X_Cena') of
                                                                           'R': price:=mRowsOutput.BusinessObject[ii].GetFieldValueAsFloat('StoreCard_ID.X_Cena_rozprac');
                                                                           'S': price:=mRowsOutput.BusinessObject[ii].GetFieldValueAsFloat('StoreCard_ID.X_Cena_skladova');
                                                                           'P': price:=mRowsOutput.BusinessObject[ii].GetFieldValueAsFloat('StoreCard_ID.X_Cena_precen');

                                                                          else price:= NxIBStrToFloat(mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].TAmountWithoutVAT'))/mRowsOutput.BusinessObject[ii].getFieldValueAsFloat('Quantity') ;
                                                                          end;
                                                                 end else begin
                                                                             price:= NxIBStrToFloat(mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].TAmountWithoutVAT'))/mRowsOutput.BusinessObject[ii].getFieldValueAsFloat('Quantity') ;
                                                                 end;

                                                                           if price>0 then begin
                                                                                  //mRowsOutput.BusinessObject[ii].SetFieldValueAsFloat('TotalPrice',0);
                                                                                  mRowsOutput.BusinessObject[ii].SetFieldValueAsFloat('UnitPrice',price);
                                                                           end;






      //                                                 nxshowsimplemessage('dd',nil);
                                                 // šarže
                                                // if mRow.getFieldValueAsInteger('Storecard_ID.category')=2 then begin
        //                                                       nxshowsimplemessage('ee',nil);
                                                            mMonBatches := mRowsOutput.BusinessObject[ii].GetLoadedCollectionMonikerForFieldCode(mRowsOutput.BusinessObject[ii].GetFieldCode('DocRowBatches'));
                                                            //mRowsOutput.BusinessObject[ii].SetFieldValueAsString('Store_ID','1M00000101');
                                                            for iii := 0 to mXMLHead.getElementsCountInArray('AbraDocument.Rows.Row['+inttostr(i)+'].Batches.Batch') - 1 do begin
                                                                    //if mXMLHead.getElementsCountInArray('AbraDocument.Rows.Row.Batches.Batch')>0 then begin
                                                                    //NxShowSimpleMessage('Sarze ' + mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Batches.Batch['+inttostr(ii)+'].name'),nil);
                                                                    if mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Batches.Batch['+inttostr(iii)+'].name')<>'' then begin
                                                                          mr:=tstringlist.create;
                                                                           // dohledání pohybu šarže
                                                                           try
                                                                                msite.BaseObjectSpace.SQLSelect('SELECT b.ID FROM StoreBatches b where b.name=' + quotedstr(mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Batches.Batch['+inttostr(iii)+'].name'))
                                                                                                                +' and Storecard_ID=' + quotedstr(mRowsOutput.BusinessObject[ii].GetFieldValueAsString('StoreCard_ID'))
                                                                                                                + ' and b.hidden=' + quotedstr('N') ,mr) ;
                                                                                mRowDocRowBatches := mMonBatches.AddNewObject;
                                                                                if mr.count=0 then begin
                                                                                              mRowDocRowBatches.Prefill;
                                                                                              //mRowDocRowBatches.SetFieldValueAsInteger('PosIndex',II);
                                                                                              mRowDocRowBatches.SetFieldValueAsBoolean('NewBatch',True);
                                                                                              //mRowDocRowBatches.SetFieldValueAsString('StoreBatch_ID ',mID_Sarze);
                                                                                              mRowDocRowBatches.SetFieldValueAsString('NewBatchComment','');
                                                                                              mRowDocRowBatches.SetFieldValueAsString('NewBatchName',mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Batches.Batch['+inttostr(iii)+'].name'));
                                                                                              mRowDocRowBatches.SetFieldValueAsString('NewBatchSpecification',mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Batches.Batch['+inttostr(iii)+'].Specification'));
                                                                                              mRowDocRowBatches.SetFieldValueAsDateTime('NewBatchExpirationDate$DATE',now);
                                                                                              mRowDocRowBatches.SetFieldValueAsFloat('Quantity',NxIBStrToFloat(mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Batches.Batch['+inttostr(iii)+'].quantity')));
                                                                                end else begin
                                                                                       mID_Sarze:=mr.Strings[0];
                                                                                             mRowDocRowBatches.Prefill;
                                                                                            //mRowDocRowBatches.SetFieldValueAsInteger('PosIndex',II);
                                                                                            mRowDocRowBatches.SetFieldValueAsBoolean('NewBatch',False);
                                                                                            mRowDocRowBatches.SetFieldValueAsString('StoreBatch_ID',mID_Sarze);
                                                                                            mRowDocRowBatches.SetFieldValueAsFloat('Quantity',NxIBStrToFloat(mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Batches.Batch['+inttostr(iii)+'].quantity')));
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
                                   if not (mFind)  then begin
                                        if nxisemptyoid(mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].X_ProvideRow_ID')) then begin
                                           NxShowSimpleMessage('Položka se odkazuje na již vyčerpaný doklad, bude imporována bez vazby. Prosím zkontrolujte',nil);
                                        end else begin
                                           NxShowSimpleMessage('Položka nemá uvedenou vazbu na objednávku , bude importována bez vazby',nil);
                                        end;
                                      //NxShowSimpleMessage('Přidání řádku',nil);
                                      mRow := mRowsOutput.AddNewObject;
                                          mRow.Prefill;
                                          mStoreCard_ID:='';
                                          mstorecard_text:='';
                                          mRow.SetFieldValueAsString('Store_ID','3000000101');
                                                    mStoreCard_ID:='';
                                                        mstorecard_text:='';
                                                         if not(ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].Commodity.EAN') and (index=2)) then begin
                                                                if (mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Commodity.EAN')<>'') then begin
                                                                         mr:=tstringlist.create;
                                                                          try
                                                                              msite.BaseObjectSpace.SQLSelect(format('select sc.id||su.code @{COLLATEUNICODE} from STOREEANS SE left join StoreUnits SU on SU.id=se.Parent_id left join Storecards SC on sc.id=su.parent_id where ((se.EAN=%s ) or (sc.EAN=%s )) and (sc.hidden=%s)',
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
                                                   {
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
                                                    }

                                               if mRow.getFieldValueAsInteger('Storecard_ID.category')=2 then begin
                                                  // šarže
                                                            mMonBatches := mrow.GetLoadedCollectionMonikerForFieldCode(mrow.GetFieldCode('DocRowBatches'));

                                                            for iii := 0 to mXMLHead.getElementsCountInArray('AbraDocument.Rows.Row['+inttostr(i)+'].Batches.Batch') - 1 do begin
                                                                    //if mXMLHead.getElementsCountInArray('AbraDocument.Rows.Row.Batches.Batch')>0 then begin
                                                                    //NxShowSimpleMessage('Sarze ' + mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Batches.Batch['+inttostr(ii)+'].name'),nil);
                                                                    if mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Batches.Batch['+inttostr(iii)+'].name')<>'' then begin
                                                                          mr:=tstringlist.create;
                                                                           // dohledání pohybu šarže
                                                                           try
                                                                                msite.BaseObjectSpace.SQLSelect('SELECT b.ID FROM StoreBatches b where b.name=' + quotedstr(mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Batches.Batch['+inttostr(iii)+'].name'))
                                                                                                                +' and Storecard_ID=' + quotedstr(mRow.GetFieldValueAsString('StoreCard_ID'))
                                                                                                                +' and b.hidden=' + quotedstr('N') ,mr) ;
                                                                                mRowDocRowBatches := mMonBatches.AddNewObject;
                                                                                if mr.count=0 then begin
                                                                                              mRowDocRowBatches.Prefill;
                                                                                              mRowDocRowBatches.SetFieldValueAsBoolean('NewBatch',True);
                                                                                              //mRowDocRowBatches.SetFieldValueAsString('StoreBatch_ID ',mID_Sarze);
                                                                                              mRowDocRowBatches.SetFieldValueAsString('NewBatchComment','');
                                                                                              mRowDocRowBatches.SetFieldValueAsString('NewBatchName',mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Batches.Batch['+inttostr(iii)+'].name'));
                                                                                              mRowDocRowBatches.SetFieldValueAsString('NewBatchSpecification',mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Batches.Batch['+inttostr(iii)+'].Specification'));
                                                                                              mRowDocRowBatches.SetFieldValueAsDateTime('NewBatchExpirationDate$DATE',now);
                                                                                              mRowDocRowBatches.SetFieldValueAsFloat('Quantity',NxIBStrToFloat(mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Batches.Batch['+inttostr(iii)+'].quantity')));

                                                                                end else begin
                                                                                       mID_Sarze:=mr.Strings[0];
                                                                                            mRowDocRowBatches.Prefill;
                                                                                            mRowDocRowBatches.SetFieldValueAsBoolean('NewBatch',False);
                                                                                            mRowDocRowBatches.SetFieldValueAsString('StoreBatch_ID',mID_Sarze);
                                                                                            mRowDocRowBatches.SetFieldValueAsFloat('Quantity',NxIBStrToFloat(mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Batches.Batch['+inttostr(iii)+'].quantity')));
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
  mMAction := Self.GetNewMultiAction;
          mMAction.ShowControl := True;
          mMAction.ShowMenuItem := True;
          mMAction.Hint := 'Příjem polotovaru z SK z OV';
          mMAction.Caption := 'Příjem polotovaru z SK z OV';
          mMAction.Items.Add('Příjem polotovaru z SK z OV');
          mMAction.Items.Add('Hromadný import');
         // mMAction.Items.Add('Import 2023');
          mMAction.Category := 'tabList';
          mMAction.OnExecuteItem := @OnExec;


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
  if (index=0) or (index=2) then begin
         if PromptForFileName(mFileName, mfilter, '', 'Soubor ESHOP TOP', '\\CZVS0006\Import\DL', False) then begin
              mdir:=copy(mfilename,0,NxCharPosR('\',mfilename));
              mFile:=copy(mfilename,1+NxCharPosR('\',mfilename),Length(mfilename));

         end;
         mDocument_ID:=ImportFilePR(TDynSiteForm(mSite).BaseObjectSpace, mfilename, mdir,mfile,msite,true,false,index);

         //NxShowSimpleMessage('PR hotovo  ' + mDocument_ID,nil);


        //   ****** volba zda dělat doklad


  end;

  if index=1 then begin
        mFileList:=TStringList.create;
        try
                mdir:= '\\CZVS0006\Import\DL\Hromadne';
                NxGetFileList(mdir,mfilelist,'*.xml',true);
                     ProgressInit(msite, 'Načtení souboru ' + '', 100);
                                for i:=0 to mFileList.count-1 do begin
                                     ProgressSetPos(1+NxFloor(i/mfilelist.Count*99), inttostr(i) +' z '+inttostr(mfilelist.Count));

                                     mFile:=copy(mFileList.Strings[i],1+NxCharPosR('\',mFileList.Strings[i]),Length(mFileList.Strings[i]))+'.xml';
                                     mfilename:=mdir+'\' + mfile;
                                     //NxShowSimpleMessage(mfilename + ' - '+ mdir+' - ' +mfile,nil);
                                     mDocument_ID:=ImportFilePR(TDynSiteForm(mSite).BaseObjectSpace, mfilename, mdir,mfile,msite,true,false,index);
                                end;
                     ProgressDispose()   ;
        finally
            mFileList.free;

        end;


    end;


  //TDynSiteForm(mSite).Refreshdata;
//  msite.activedataset.RefreshCurrentItem;
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



begin
end.
