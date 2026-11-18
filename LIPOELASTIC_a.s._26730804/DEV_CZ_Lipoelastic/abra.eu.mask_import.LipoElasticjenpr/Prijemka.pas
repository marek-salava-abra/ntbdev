uses 'abra.eu.mask_import.LipoElasticjenPR.lib',
      'Synchronizace.API';


procedure ZpracujSouborZFronty (OS: TNxCustomObjectSpace; var ProcessContinue: Boolean; Directory: string; FileName: string;msite:TDynSiteForm);
begin
  ProcessContinue := ImportFile2(OS, Directory + '\' + FileName,Directory,filename,msite,False,false,0);
end;






function ImportFile2(OS: TNxCustomObjectSpace; AFileName: string;directory: string;filename: string;msite:TDynSiteForm;rucne:boolean;chyba:boolean;index:Integer) : Boolean;
var
mID_Docqueue_iD,mID_Store_iD:string;
mObchodniPripad,mdivision_id:string;
mstore_id:string;
mBustransaction_ID:string;
mfind_string:string;
mr,mx,mrsa,mxax,mxr:tstringlist;
mStoreCard_ID:string;
mBO_adress,mBO_Sarze,mBO_PohybSarze,mdocrowbatches:TNxCustomBusinessObject;
mAdress_id:string;
mi_result:integer;
mMon,mBO_MonikerBatches:TNxCustomBusinessMonikerCollection;
mstorecard_text:string;
mbo_docqueue:TNxCustomBusinessObject;
mQunit:string;
mPacName:string;
mabraqunit:string;
mTyp_Eshopu,MID_SARZE:string;
begin
    if not FileExists(AFileName) then begin
      Result := False;
      exit;
    end else begin

    try
      mXMLHead := TNxScriptingXMLWrapper.Create;
        mXMLHead.loadFromFile(AFileName);


        mexistuje:='';
 //     if mXMLHead.getElementAsString('ABRADocument.ExternalNumber')<>'' then begin
 //           if not(ErrtElementString(mXMLHead ,'ABRADocument.ExternalNumber') and (index=2)) then
 //               mexistuje:=getIDfromfield(os,'ID','ReceivedOrders','ExternalNumber',mXMLHead.getElementAsString('ABRADocument.ExternalNumber'),'','');
 //     end;
          mID_Division:='5O10000101';
          mID_Docqueue_ID:= '5G10000101';
          mID_odberatel:= 'JJHF800101';
          mstore_id:='3000000101';
        mHead := TNxHeaderBusinessObject(OS.CreateObject('E03ZNUMDTCC4PDAUIEY1MBTJC0'));
        try
                if ((nxisemptyoid(mexistuje)) or ( msite.CompanyCache.GetUserID='SUPER00000')) then begin
                      //if ((msite.CompanyCache.GetUserID='SUPER00000') and (rucne)) then NxShowSimpleMessage('Doklad již existuje - prosím zmažte',nil);
                      mHead.New;
                      mHead.Prefill;
                      //if rucne and chyba then NxShowSimpleMessage('Novy',nil);
                      mHead.SetFieldValueAsString('DocQueue_ID', mID_Docqueue_ID);
                      mHead.SetFieldValueAsString('Firm_ID', mID_odberatel);
                     // if not(ErrtElementString(mXMLHead ,'ABRADocument.ExternalNumber') and (index=2)) then
                     //         mHead.SetFieldValueAsString('ExternalNumber',mXMLHead.getElementAsString('ABRADocument.ExternalNumber'));
                      //if msite.CompanyCache.GetUserID='SUPER00000' then NxShowSimpleMessage('Hlavička v pořádku',nil);
                      mHead.SetFieldValueAsString('Description',copy(mXMLHead.getElementAsString('ABRADocument.Description'),1,49));
                      mHead.SetFieldValueAsinteger('Tradetype',2);
                      mHead.SetFieldValueAsstring('Country_ID','00000SK000');
                      mhead.SetFieldValueAsString('IntrastatTransactionType_ID','0101000000');
                       for i := 0 to mXMLHead.getElementsCountInArray('AbraDocument.Rows.Row') - 1 do begin

                            if strtoint(mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].RowType'))  = 3 then begin

                                          mRow := mHead.Rows.AddNewObject;
                                          mRow.Prefill;
                                          mStoreCard_ID:='';
                                          mstorecard_text:='';

                                            mRow.SetFieldValueAsInteger('PosIndex',i);



                                                    mRow.SetFieldValueAsInteger('RowType',3);

                                                    mRow.SetFieldValueAsString('Store_ID',mstore_id);


                                                    mStoreCard_ID:='';
                                                        mstorecard_text:='';
                                                         if not(ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].Commodity.EAN') and (index=2)) then begin
                                                                if (mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Commodity.EAN')<>'') then begin
                                                                         mr:=tstringlist.create;
                                                                          try
                                                                              msite.BaseObjectSpace.SQLSelect(format('select sc.id||su.code @{COLLATEUNICODE} from STOREEANS SE left join StoreUnits SU on SU.id=se.Parent_id left join Storecards SC on sc.id=su.parent_id where ((se.EAN=%s ) or (sc.EAN=%s )) and (sc.hidden=%s)',
                                                                              [quotedstr(mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Commodity.EAN')),quotedstr(mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Commodity.EAN')),QuotedStr('N')]),mr);

                                                        //NxShowSimpleMessage('Hledání skladové karty v počtu ' + inttostr(mr.count),nil);
                                                                                   if mr.count=0 then begin
                                                                                       //mstorecard_text:=mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Commodity.Ean') + ' - ' + mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Commodity.Name');

                                                                                       mStoreCard_ID:='3NQ1000101';
                                                                                       mQunit:='ks';
                                                                                   end else begin
                                                                                       mStoreCard_ID:=copy(

                                                                                        ReplaceStr(mr.Strings[0],'"',''),1,10);
                                                                                        //mStoreCard_ID:=Validate_API(msite.BaseObjectSpace,mStoreCard_ID);
                                                                                       mQunit:=copy(ReplaceStr(mr.Strings[0],'"',''),11,5);

                                                                                      // nxShowSimpleMessage(copy(mr.Strings[0],1,10),nil);

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

                                                           if not(ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].Unitprice') and (index=2)) then
                                                                mRow.SetFieldValueAsFloat('Unitprice',NxIBStrToFloat(mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Unitprice'))); //text bude  ...

                                                          // ceny z ceníku

{                                                          mxr:=tstringlist.create;
                                                          try
                                                               msite.BaseObjectSpace.SQLSelect('SELECT y2.Amount FROM  PriceLists A join StorePrices Y on Y.PriceList_ID=A.ID join StorePrices2 Y2 on y2.parent_ID=Y.id WHERE a.id=' + QuotedStr('6GT0000101') + ' and Y2.price_ID=' + quotedstr(mHead.getFieldValueAsString('Firm_ID.Price_ID')) + ' AND Y.StoreCard_ID = ' + quotedstr(mRow.getFieldValueAsString('Storecard_ID') ),mxr);
                                                                 if mxr.count>0 then begin
                                                                       mRow.SetFieldValueAsFloat('Unitprice',NxIBStrToFloat(mxr.Strings[0]));
                                                                       //NxShowSimpleMessage(mxr.Strings[0],nil);
                                                                 end;

                                                          finally
                                                              mxr.free;
                                                          end;
 }



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

                                                mRow.SetFieldValueAsString('Division_ID',mID_Division); //text bude  ...


                                                if not(ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].X_ProvideRow_ID') and (index=2)) then
                                                      mRow.SetFieldValueAsString('X_ProvideRow_ID',mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].X_ProvideRow_ID'));

                                                      mRow.SetFieldValueAsString('X_StoreDocuments2_ID',mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].X_StoreDocuments2_ID'));
                                                 if not(ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].Row_ID') ) then
                                                      mRow.SetFieldValueAsString('X_StoreDocuments2_ID',mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Row_ID'));


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



//                                                           if not NxIsEmptyOID((mRow.GetFieldValueAsString('StoreCard_id.X_BusTransaction_ID'))) then begin
//                                                                             mBustransaction_ID:=(mRow.GetFieldValueAsString('StoreCard_id.X_BusTransaction_ID'));
//                                                                             mRow.SetFieldValueAsString('BusTransaction_id',mBustransaction_ID );
                                                       //    end;


                                                            // šarže
                                                            if mRow.getFieldValueAsInteger('StoreCard_ID.Category')=2 then begin
                                                            //nxshowsimplemessage('AAA',nil);
                                                                      mBO_MonikerBatches:=mRow.GetLoadedCollectionMonikerForFieldCode(mRow.GetFieldCode('DocRowBatches'));
                                                                          //nxshowsimplemessage('BBB',nil);

                                                                            for ii := 0 to mXMLHead.getElementsCountInArray('AbraDocument.Rows.Row['+inttostr(i)+'].Batches.Batch') - 1 do begin
                                                                                        //nxshowsimplemessage('ccc',nil);
                                                                                        mdocrowbatches:=mBO_MonikerBatches.AddNewObject;
                                                                                         mdocrowbatches.Prefill;


                                                                                       // dohledání šarže
                                                                                           mx:=tstringlist.create;
                                                                                           try
                                                                                                msite.BaseObjectSpace.SQLSelect('SELECT ID FROM StoreBatches A WHERE name=' + quotedstr(mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Batches.Batch['+inttostr(ii)+'].name'))
                                                                                                                        +' and Storecard_ID=' + quotedstr(mrow.GetFieldValueAsString('StoreCard_ID'))
                                                                                                                ,mx);
                                                                                                if mx.count=0 then begin
                                                                                                      mdocrowbatches.setFieldValueAsboolean('NewBatch', true);
                                                                                                      mdocrowbatches.setFieldValueAsstring('NewBatchName',mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Batches.Batch['+inttostr(ii)+'].name'));
                                                                                                      mdocrowbatches.setFieldValueAsstring('NewBatchSpecification',mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Batches.Batch['+inttostr(ii)+'].Specification'));
                                                                                                      mdocrowbatches.setFieldValueAsdatetime('NewBatchExpirationDate$DATE',mXMLHead.getElementAsfloat('AbraDocument.Rows.Row['+inttostr(i)+'].Batches.Batch['+inttostr(ii)+'].ExpirationDate'));
                                                                                                    //  mdocrowbatches.setFieldValueAsdatetime('NewBatchProductionDate$DATE',mXMLHead.getElementAsfloat('AbraDocument.Rows.Row['+inttostr(i)+'].Batches.Batch['+inttostr(ii)+'].ProductionDate'));
                                                                                                end else begin
                                                                                                      mdocrowbatches.setFieldValueAsboolean('NewBatch', false);
                                                                                                      mdocrowbatches.setFieldValueAsstring('StoreBatch_ID',mx.strings[0]);
                                                                                                end;
                                                                                           finally
                                                                                              mx.free;
                                                                                           end;
                                                                                        mdocrowbatches.SetFieldValueAsFloat('Quantity',NxIBStrToFloat(mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Batches.Batch['+inttostr(ii)+'].quantity')));







                                                                               end;     // řádek šarže

                                                                            end;   // šarže


                          end;   // není skladový řádek
                       end;    // cyklus řádků


                        mhead.SetFieldValueAsString('IntrastatTransactionType_ID','0101000000');
                        mhead.SetFieldValueAsString('IntrastatDeliveryTerm_ID','3001000000');
                        mhead.SetFieldValueAsString('IntrastatTransportationType_ID','2000000000');






                              if rucne then begin
                                  mhead.ClearValidateErrors;
                                  if Not mhead.Validate() then begin
                                        mList := TStringList.Create;
                                        try
                                           mhead.GetValidateErrors(mList);
                                           mText := mList.Text;
                                           NxToken(mText, '=');
                                           MessageDlg('Automaticky vytvořenou objednávku nelze uložit z těchto důvodů:' + #13#10 + mText,

                                           mtWarning, [mbOK], 0);
                                         finally
                                           mList.Free;
                                         end;
                                         mSite.ShowDynFormWithNewDocument('B10I5SAOS3DL3ACU03KIU0CLP4', mSite.SiteContext, mhead);
                                         //mhead.refresh;
                                        msite.ActiveDataSet.RefreshCurrentItemMode;
                              end else begin
                                        mhead.Save;
                                        mhead.refresh;
                                        msite.ActiveDataSet.RefreshCurrentItemMode;
                                        if index<>3 then
                                            if rucne then NxShowSimpleMessage('Příjemka ' + mhead.GetFieldValueAsstring('Docqueue_ID.code') + '-' + inttostr(mhead.GetFieldValueAsinteger('Ordnumber')) + '/' +
                                                 mhead.GetFieldValueAsstring('Period_ID.code') + ' byla vytvořena',nil);
                                        result:=nxcopyfile(AFileName,Directory + '\Zpracovane\' + FileName);

                                        if result then begin
                                            DeleteFile(AFileName);
                                            if rucne and result and chyba then begin
                                                  if index<>3 then NxShowSimpleMessage('Soubor ' + afilename + ' byl přesunut do zpracovaných',nil);
                                            end;
                                        end;
                              end;





                    end else begin
                      //  if rucne then NxShowSimpleMessage('Doklad již existuje',nil);
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



begin
end.