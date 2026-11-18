uses '_Knihovny_ALL.head', '_Knihovny_ALL.Progress','_Knihovny_ALL.Parse',
'abra.eu.mask_import.2018.Objednavka_prijata';

const
    mFilter='*.csv';

 function ImportFileX3(OS: TNxCustomObjectSpace; AFileName: string;directory: string;filename: string;msite:TDynSiteForm;rucne:boolean;chyba:boolean;index:Integer) : Boolean;
var
mhead:TNxHeaderBusinessObject;
mID_Docqueue_iD,mID_Store_iD:string;
mObchodniPripad,mdivision_id:string;
mstore_id:string;
mBustransaction_ID:string;
mfind_string:string;
mr,mrsa,mxax:tstringlist;
mStoreCard_ID:string;
mBO_adress:TNxCustomBusinessObject;
mAdress_id:string;
mi_result:integer;
mMon,mBAtches:TNxCustomBusinessMonikerCollection;
mstorecard_text:string;
mbo_docqueue,mbatch:TNxCustomBusinessObject;
mQunit:string;
mPacName:string;
mabraqunit:string;
mTyp_Eshopu:string;
mUnicodeName,mUnicodeCity,mUnicodeStreet,mUnicodeLocation,mUnicodeFullName:string;
mCode: integer;
mBusOrder_ID,mBusProject_ID,mbo_id:string;
mTariff: String;
mShowError:boolean;
mrx:tstringlist;
mpocet:double;
mError:boolean;
mImportFile:TStringList;
    mid :string;
    moddelovac:string;
    mOLE, mRoll, mOResult: Variant;
  mGrid: TdbGrid;
  mControl: TControl;
  mDataSource: TDataSource;
  mDataset: TNxRowsObjectDataSet;
    _ss:Variant;
    mfirm_id:string;
    mstringline:string;
  mCountField:integer;
  mfieldValue,mRSql:tstringlist;
  mbatch_ID:string;
  mlist:tstringlist;
  mFirmOffice_id:string;
  mBO_PohybSarze:TNxCustomBusinessObject;
  mstring:string;
  mvalue:tstringlist;
  mBoolean:Boolean;
  mSourceSC,mTargetSC,mSourceBatch,mTargetBatch:string;
  msourceQuantity , mTargetQuantity, mBatchQuantity:double;
  mBO_MonikerBatches,mRowsOutput:TNxCustomBusinessMonikerCollection;
  mID_sourdce_doc:string;
  mParams, mP : TNxParameters;
  mPar : TNxParameter;
  mManager : TNxDocumentImportManager ;
  mValidateList:tstringlist;
  mBO_Batch:TNxCustomBusinessObject;
  mTextReport:string;
  mSourceList,mTargetList:tstringlist;
  mFError,mSError:string;
  mID_source_doc:string;
begin
  mError:=false;
  mFError:='';
  mSError:='';
    mTextReport:='';
//NxShowSimpleMessage('Aa',nil);
    if not FileExists(AFileName) then begin
      Result := False;
      exit;
    end;


  mOLE := GetAbraOLEApplication;
    mroll := mOLE.GetAgenda('OFZO2K155FDL3CL100C4RHECN0');
    _ss := mOLE.CreateStrings;

   mstore_ID:= mroll.SingleSelectFromSelected2(_ss, 'Vyber sklad', '');
//NxShowSimpleMessage('bb',nil);
 mImportFile:=TStringList.create;
 mImportFile.LoadFromFile(AFileName);

  mr:=tstringlist.create;
  try
       os.SQLSelect('Select X_Firm_ID from Stores where id=' + quotedstr(mstore_id),mr);
       if mr.count>0 then begin
           mfirm_id:=mr.Strings[0];
       end else begin
           mfirm_id:='';
       end;
  finally
     mr.free;
  end;

  //NxShowSimpleMessage('cc',nil);
  mr:=tstringlist.create;
  try
       os.SQLSelect('Select id from FirmOffices where X_Store_ID=' + quotedstr(mstore_id) + ' and Parent_ID=' + quotedstr(mfirm_id) ,mr);
       if mr.count>0 then begin
           mFirmOffice_id:=mr.Strings[0];
       end else begin
           mFirmOffice_id:='';
       end;
  finally
     mr.free;
  end;

//NxShowSimpleMessage('dd',nil);
mSourceSC:='';
mSourceBatch:='';
msourceQuantity:=0;
mTargetSC:='';
mTargetBatch:='';
mTargetQuantity:=0;



 mlist:=tstringlist.create;
 mSourceList:=tstringlist.create;
 mTargetList:=tstringlist.create;
 try
      for i:=0 to mImportFile.Count-1 do begin   // načtení souboru

             //ProgressSetPos(1+NxFloor((i/mImportFile.Count)*99), inttostr(i) +' z '+inttostr(mImportFile.Count));
            mstringline:= mImportFile.strings[i];
            if trim(mstringline)<>'' then begin
                mvalue:=tstringlist.create;
                   try
                       Parsevalue(mstringline,';',mstringline,mvalue,6);
                       if NxIBStrToFloat(mvalue.Strings[5])<>0 then begin
                              mr:=TStringList.create;
                                        try
                                            os.SQLSelect('Select ID from StoreCards where EAN=' + quotedstr(mvalue.Strings[1]),mr);
                                            if mr.count>0 then begin
                                                 mSourceSC:=mr.Strings[0];
                                            end else begin
                                                 mError:=True;
                                                 mSError:= mSError + 'Karta: ' + mvalue.Strings[1] + ' , EAN: ' + mvalue.Strings[1] + ' nebyla dohledána' + chr(10);
                                            end;

                                        finally
                                            mr.free;
                                        end;

                                        mr:=TStringList.create;
                                        try
                                            os.SQLSelect('Select id from StoreBatches where Name=' + quotedstr(mvalue.Strings[2]) + ' And Storecard_ID=' + quotedstr(mSourceSC)  ,mr);
                                            if mr.count>0 then begin
                                                 mSourceBatch:=mr.Strings[0];
                                            end else begin
                                                 mError:=True;
                                                 mSError:= mSError + 'Šarže: ' + mvalue.Strings[2] + ' , pro kartu: ' + mvalue.Strings[0] + ' nebyla dohledána' + chr(10);
                                            end;

                                        finally
                                            mr.free;
                                        end;

                           if NxIBStrToFloat(mvalue.Strings[5])<0 then begin
                                  mSourceList.add(mSourceSC+';'+mSourceBatch+';'+NxFloatToIBStr(abs(NxIBStrToFloat(mvalue.Strings[5]))))  ;
                           end;
                           if NxIBStrToFloat(mvalue.Strings[5])>0 then begin
                                  mTargetList.add(mSourceSC+';'+mSourceBatch+';'+NxFloatToIBStr(abs(NxIBStrToFloat(mvalue.Strings[5]))))  ;
                           end;
                       end;
                   finally
                        mvalue.free;
                   end;

            end;
      end;





      mSourceList.Sort;
      mTargetList.sort;
      msourceQuantity:=0;
      mTargetQuantity:=0;
      mBatchQuantity:=0;
      for i:=0 to mSourceList.Count-1 do begin
      //  NxShowSimpleMessage(copy(mSourceList.Strings[i],23,10),nil);
         if (i=0) then begin
            msourceQuantity:=msourceQuantity + NxIBStrToFloat(copy( mSourceList.Strings[i],23,10));
            mBatchQuantity:=mBatchQuantity + NxIBStrToFloat(copy( mSourceList.Strings[i],23,10));
         end else begin
            // STEJNÁ SKLADOVÁ KARTA

            //if copy(mSourceList.Strings[i],1,10)=copy(mSourceList.Strings[i-1],1,10) then begin
            if false then begin
               msourceQuantity:=msourceQuantity+ NxIBStrToFloat(copy( mSourceList.Strings[i],23,10));
                                 // STEJNÁ ŠARŽE
                                 if copy(mSourceList.Strings[i],1,21)=copy(mSourceList.Strings[i-1],1,21) then begin
                                    mBatchQuantity:=mBatchQuantity+ NxIBStrToFloat(copy( mSourceList.Strings[i],23,10));
                                 end else begin
                                     // KONTROLA NOŽSTVÍ
                                     mr:=TStringList.create;
                                     try
                                       os.SQLSelect('Select sum(quantity) from StoreSubBatches where Storebatch_ID=' + quotedstr(copy(mSourceList.Strings[i-1],12,10)) + ' And Store_ID=' + quotedstr(mstore_ID)  ,mr);
                                          if NxIBStrToFloat(mr.Strings[0])< mBatchQuantity then begin
                                              //NxShowSimpleMessage('y' + inttostr(i) + '  - '  +    mSourceList.Strings[i-1],nil);
                                              mrx:=TStringList.create;
                                               try
                                                 msite.BaseObjectSpace.SQLSelect('Select name from storeBatches where id= ' + QuotedStr(copy(mSourceList.Strings[i-1],12,10)),mrx);
                                                 if mrx.count>0 then begin

                                                         mSError:= mSError + 'Na uvedeném skladě není dostatečné množství šarže: ' + quotedstr(mrx.Strings[0]) + ' , požadavek:  ' + NxFloatToIBStr(mBatchQuantity) + ' skladem ' +  mr.strings[0] + chr(10);
                                                         mError:=True;
                                                 end;
                                               finally
                                               mrx.free;
                                               end;
                                              mError:=True;

                                          end;
                                          mBatchQuantity:= NxIBStrToFloat(copy(mSourceList.Strings[i],23,10));
                                     finally
                                         mr.free;
                                     end;

                                 end;
            end else begin

                                 //if copy(mSourceList.Strings[i],1,21)=copy(mSourceList.Strings[i-1],1,21) then begin
                                 if false then begin
                                    mBatchQuantity:=mBatchQuantity+ NxIBStrToFloat(copy( mSourceList.Strings[i],23,10));
                                 end else begin
                                     // KONTROLA NOŽSTVÍ
                                     mr:=TStringList.create;
                                     try
                                       os.SQLSelect('Select sum(quantity) from StoreSubBatches where Storebatch_ID=' + quotedstr(copy(mSourceList.Strings[i-1],12,10)) + ' And Store_ID=' + quotedstr(mstore_ID)  ,mr);
                                          if NxIBStrToFloat(mr.Strings[0])< mBatchQuantity then begin
                                              //NxShowSimpleMessage('x' + inttostr(i) + '  - '  +    mSourceList.Strings[i-1],nil);
                                              mrx:=TStringList.create;
                                               try
                                                 msite.BaseObjectSpace.SQLSelect('Select name from storeBatches where id= ' + QuotedStr(copy(mSourceList.Strings[i-1],12,10)),mrx);
                                                 if mrx.count>0 then begin

                                                         mSError:= mSError + 'Na uvedeném skladě není dostatečné množství šarže: ' + quotedstr(mrx.Strings[0]) + ' , požadavek:  ' + NxFloatToIBStr(mBatchQuantity) + ' skladem ' +  mr.strings[0] + chr(10);
                                                         mError:=True;
                                                 end;
                                               finally
                                               mrx.free;
                                               end;
                                              mError:=True;

                                          end;
                                          mBatchQuantity:=NxIBStrToFloat(copy(mSourceList.Strings[i],23,10));
                                     finally
                                         mr.free;
                                     end;

                                 end;



               // NAPOČTENÍ CÍLOVÉHO MNOŽSTVÍ
                             msourceQuantity:=mTargetQuantity;
                            // for x:=0 to mTargetList.count-1 do begin
                            //     if copy(mSourceList.Strings[i-1],1,10)=copy(mTargetList.Strings[x],1,10) then begin
                            //        mTargetQuantity:=mTargetQuantity+ NxIBStrToFloat(copy(mTargetList.Strings[x],23,10));
                            //     end;
                            // end;

                            // NxShowSimpleMessage('Položky si neodpovídají ' + copy(mSourceList.Strings[i],1,10) + ' : ' +  NxFloatToIBStr(msourceQuantity) + '/' +NxFloatToIBStr(mTargetQuantity),nil);


                             // VYHODNOCENÍ
                                       if (msourceQuantity<>mTargetQuantity) then begin
                                          mr:=tstringlist.create;
                                           try
                                              msite.BaseObjectSpace.SQLSelect('Select Name from StoreCards where id=' + QuotedStr(copy(mSourceList.Strings[i-1],1,10)),mr);
                                              if mr.count>0 then begin
                                                  mSError:= mSError + 'Nesoulad ' + mr.Strings[0] + ' : ' +  NxFloatToIBStr(msourceQuantity) + '/' +NxFloatToIBStr(mTargetQuantity)+ chr(10);
                                              end;
                                              mError:=True;
                                           finally
                                               mr.free;
                                           end;

                                       end;
                                                     msourceQuantity:=0;
                              mTargetQuantity:=0;
                              msourceQuantity:=NxIBStrToFloat(copy( mSourceList.Strings[i],23,10));



            end;
         end;


            // POSLEDNÍ ZÁZNAM
            if i=(mSourceList.Count-1) then begin
                  //  msourceQuantity:=msourceQuantity+ NxIBStrToFloat(copy( mSourceList.Strings[i],23,10));
                   // KONTROLA STAVU NA SKLADĚ
                   //mBatchQuantity:=NxIBStrToFloat(copy(mSourceList.Strings[i],23,10));
                   mr:=TStringList.create;
                   try
                     os.SQLSelect('Select sum(quantity) from StoreSubBatches where Storebatch_ID=' + quotedstr(copy(mSourceList.Strings[i],12,10)) + ' And Store_ID=' + quotedstr(mstore_ID)  ,mr);
                        if NxIBStrToFloat(mr.Strings[0])<mBatchQuantity then begin
                             mError:=True;
                             mrx:=TStringList.create;
                             try
                               msite.BaseObjectSpace.SQLSelect('Select name from storeBatches where id= ' + quotedstr(copy(mSourceList.Strings[i],12,10)),mrx);
                               if mrx.count>0 then begin
                                     mSError:= mSError + 'Na uvedeném skladě není dostatečné množství šarže: ' + quotedstr(mrx.strings[0]) + ' , požadavek: ' + NxFloatToIBStr(msourceQuantity) + ' skladem ' +  mr.strings[0] + chr(10);
                                     mError:=true;
                               end;
                             finally
                             mrx.free;
                             end;
                        end;
                   finally
                       mr.free;
                   end;




               // NAPOČTENÍ CÍLOVÉHO MNOŽSTVÍ
               mTargetQuantity:=msourceQuantity;
               //for x:=0 to mTargetList.count-1 do begin
               ///    if copy(mSourceList.Strings[i],1,10)=copy(mTargetList.Strings[x],1,10) then begin
               //       mTargetQuantity:=mTargetQuantity+ NxIBStrToFloat(copy( mTargetList.Strings[x],23,10));
               //    end;
               //end;
               // VYHODNOCENÍ
               if msourceQuantity<>mTargetQuantity then begin
                   mr:=tstringlist.create;
                   try
                      msite.BaseObjectSpace.SQLSelect('Select Name from StoreCards where id=' + QuotedStr(copy(mSourceList.Strings[i],1,10)),mr);
                      if mr.count>0 then begin
                          mSError:= mSError + 'Nesoulad x ' + mr.Strings[0] + ' : ' +  NxFloatToIBStr(msourceQuantity) + '/' +NxFloatToIBStr(mTargetQuantity)+ chr(10);
                      end;
                      mError:=True;
                   finally
                       mr.free;
                   end;
               end;
            end;
               end;
  //NxShowSimpleMessage( mSError + CHR(10) + inttostr(mSourceList.count) + ' - ' + inttostr(mTargetList.count), nil);

  if mError then begin
      NxShowSimpleMessage('###   chyba   ###   ' +  CHR(10) +   CHR(10) + mSError + CHR(10) + ' Zvažte další zpracování . ' + Chr(10) + 'Prosím opravte chyby a operaci zopakujte' , nil);
      //exit;
  end;

  msourceQuantity:=0;
  mTargetQuantity:=0;

//      NxShowSimpleMessage(inttostr(mlist.count),nil);
         mHead := TNxHeaderBusinessObject(msite.BaseObjectSpace.CreateObject('E32A1GVWPYY4BJZFV5NFSRAODW'));
                try
                             mHead.New;
                             mHead.Prefill;
                                      mHead.SetFieldValueAsString('DocQueue_ID', '27B0000101');                   // dl
                                      mHead.SetFieldValueAsString('Firm_ID', mfirm_id);
                                      mHead.SetFieldValueAsString('FirmOffice_ID', mFirmOffice_id);

                                    mTargetQuantity:=0;
                                    mBatchquantity:=0;
                                    for i:=0 to mSourceList.count-1 do begin

                                       mvalue:=tstringlist.create;
                                       try

                                            Parsevalue(mSourceList.strings[i],';',mSourceList.strings[i],mvalue,6);


                                            //NxShowSimpleMessage('Položka ' + inttostr(i) , nil);
                                                          mRow := mHead.Rows.AddNewObject;
                                                     // NxShowSimpleMessage(mvalue.Strings[0] + ' / ' + mvalue.Strings[5],nil);
                                                                   mRow.Prefill;
                                                                   msourceQuantity:=NxIBStrToFloat(mvalue.Strings[2]);
                                                                   mRow.SetFieldValueAsInteger('RowType',3);
                                                                   mRow.SetFieldValueAsString('Store_ID',mstore_id);
                                                                   mRow.SetFieldValueAsString('StoreCard_ID',mvalue.Strings[0]);
                                                                   //mRow.SetFieldValueAsstring('Division_ID','1N00000101');
                                                                   mRow.SetFieldvalueAsString('Division_Id','~000000402');
                                                                   if NxIsEmptyOID(mRow.GetFieldValueAsString('BusTransaction_id')) then begin
                                                                        if not NxIsEmptyOID((mRow.GetFieldValueAsString('StoreCard_id.X_BusTransaction_ID'))) then begin
                                                                                     mBustransaction_ID:=(mRow.GetFieldValueAsString('StoreCard_id.X_BusTransaction_ID'));
                                                                                     mRow.SetFieldValueAsString('BusTransaction_id',mBustransaction_ID );
                                                                        end;
                                                                    end;
                                                                    if NxIsEmptyOID(mRow.GetFieldValueAsString('BusOrder_id')) then begin
                                                                              mBusOrder_ID:=GetBusOrder_ID(mRow);
                                                                              if not nxisblank(mBusOrder_ID) then mRow.SetFieldValueAsString('BusOrder_id',mBusOrder_ID);
                                                                    end;
                                                                    if NxIsEmptyOID(mRow.GetFieldValueAsString('BusProject_id')) then begin
                                                                        mBusProject_ID:=GetProject_ID(mRow);
                                                                        if not nxisblank(mBusProject_ID) then mRow.SetFieldValueAsString('BusProject_id',mBusProject_ID);
                                                                    end;
                                                                    msourceQuantity:=NxIBStrToFloat(mvalue.Strings[2]) ;
                                                                    mrow.setFieldValueAsFloat('Quantity',msourceQuantity);
                                                                    mrow.setFieldValueAsstring('X_note',mTargetList.strings[i]);

                                                                    mBatchquantity:=NxIBStrToFloat(mvalue.Strings[2]) ;
                                                                    mBO_MonikerBatches:=mRow.GetLoadedCollectionMonikerForFieldCode(mRow.GetFieldCode('DocRowBatches'));
                                                                             mBatch:=mBO_MonikerBatches.AddNewObject;
                                                                             mBatch.Prefill;
                                                                                      mBatchquantity:= NxIBStrToFloat(mvalue.Strings[2]);
                                                                                      mBatch.SetFieldValueAsstring('StoreBatch_ID',mvalue.Strings[1]);
                                                                                      mBatch.setFieldValueAsFloat('Quantity',mBatchquantity);



                                       finally
                                           mvalue.free;
                                       end;
                                    end;
                                    //mBatch.setFieldValueAsFloat('Quantity',mBatchquantity);
                                    //mrow.setFieldValueAsFloat('Quantity',msourceQuantity);



                                     //ProgressDispose()   ;
                                          //NxShowSimpleMessage('AAA',nil);
                                          mhead.ClearValidateErrors;
                                          if Not mhead.Validate() then begin
                                                mList := TStringList.Create;
                                                try
                                                   mhead.GetValidateErrors(mList);
                                                   mText := mList.Text;
                                                   NxToken(mText, '=');
                                                   MessageDlg('Automaticky vytvořenou zámenu výdej nelze uložit z těchto důvodů:' + #13#10 + mText,

                                                   mtWarning, [mbOK], 0);
                                                 finally
                                                   mList.Free;
                                                 end;
                                                 mSite.ShowDynFormWithNewDocument('RQE0MPXTACU4B2B5HGG053P44C', mSite.SiteContext, mhead);             //                       B50I5SAOS3DL3ACU03KIU0CLP4
                                                 //exit;

                                          end else begin
                                                //mhead.Save;
                                                //mSite.ShowDynFormWithNewDocument('O2XDU14IW3DL342X01C0CX3FCC', mSite.SiteContext, mhead);
                                                //NxShowSimpleMessage('Objednávka přijatá ' + mhead.GetFieldValueAsString('displayname')  ,nil);               //         B50I5SAOS3DL3ACU03KIU0CLP4
                                                mhead.save;
                                                mID_source_doc:=mhead.oid;
                                                mTextReport:=mhead.DisplayName;
                                                //mSite.ShowDynFormWithNewDocument('O2XDU14IW3DL342X01C0CX3FCC', mSite.SiteContext, mhead);

                                          end;



                    finally
                         mhead.free;
                    end;
            Result := True;
 finally
     mlist.free;
 end;


 if mID_source_doc<>'' then begin

      mManager := NxCreateDocumentImportManager(msite.BaseObjectSpace,'E32A1GVWPYY4BJZFV5NFSRAODW','JFQYSEOTKPC4RAMLQVLUK5NV34');   // op to fv

                mParams := TNxParameters.Create();
                try
                  mManager.AddInputDocument(mID_source_doc);
                  mParams.GetOrCreateParam(dtString, 'DocQueue_ID').AsString := '37B0000101';
                  mParams.GetOrCreateParam(dtString, 'Store_ID').AsString := mStore_id;



                  mManager.LoadParams(mParams);
                  mManager.Execute;
                  mManager.OutputDocument.SetFieldValueAsString('Firm_ID',mManager.InputDocument.GetFieldValueAsString('Firm_ID'));
                  mManager.OutputDocument.SetFieldValueAsString('FirmOffice_ID',mManager.InputDocument.GetFieldValueAsString('FirmOffice_ID'));
                  mManager.OutputDocument.SetFieldValueAsString('Person_ID',mManager.InputDocument.GetFieldValueAsString('Person_ID'));
                  mManager.OutputDocument.SetFieldValueAsString('Description',mManager.InputDocument.GetFieldValueAsString('Description'));

                  mRowsOutput := mManager.OutputDocument.GetLoadedCollectionMonikerForFieldCode(mManager.OutputDocument.GetFieldCode('Rows'));

                  for ii:=0 to mRowsOutput.Count-1 do begin
                        mRow:=mRowsOutput.BusinessObject[ii];
                        //for i:=0 to mTargetList.count-1 do begin

                                  mRowsOutput.BusinessObject[ii].SetFieldValueAsstring('Storecard_ID',copy(mRowsOutput.BusinessObject[ii].getFieldValueAsstring('X_note'),1,10));


                                   mBO_MonikerBatches:=mRowsOutput.BusinessObject[ii].GetLoadedCollectionMonikerForFieldCode(mRowsOutput.BusinessObject[ii].GetFieldCode('DocRowBatches'));
                                           mBO_Batch:=mBO_MonikerBatches.AddNewObject;
                                           //NxShowSimpleMessage( copy(mrow.getFieldValueAsstring('X_note'),12,10),nil);
                                           mBO_Batch.SetFieldValueAsString('StoreBatch_ID',copy(mRowsOutput.BusinessObject[ii].getFieldValueAsstring('X_note'),12,10));
                                           mBO_Batch.SetFieldValueAsFloat('Quantity',NxIBStrToFloat(copy(mRowsOutput.BusinessObject[ii].getFieldValueAsstring('X_note'),23,10)));
                                           mBO_Batch.SetFieldValueAsString('QUnit',mrow.getFieldValueAsString('qunit'));



                        //end;

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

                                             TDynSiteForm(mSite).ShowDynFormWithNewDocument('EGVDANSIQWY4V2Y52YRUPRHAK4', TDynSiteForm(mSite).SiteContext, mManager.OutputDocument);  // fv

                                      end else begin

                                          mManager.OutputDocument.Save;
                                          mTextReport:=  mTextReport + ' / ' + mManager.OutputDocument.DisplayName;
                                           NxShowSimpleMessage('Záměna proběhla ' + mTextReport,nil);
                                      end;


//                  result:= inttostr(mManager.OutputDocument.GetFieldValueAsInteger('Ordnumber'));



                 finally
                  mManager.Free;
                  mParams.free;
                 end;


end;












end;














function ImportFileX2(OS: TNxCustomObjectSpace; AFileName: string;directory: string;filename: string;msite:TDynSiteForm;rucne:boolean;chyba:boolean;index:Integer) : Boolean;
var
mhead:TNxHeaderBusinessObject;
mID_Docqueue_iD,mID_Store_iD:string;
mObchodniPripad,mdivision_id:string;
mstore_id:string;
mBustransaction_ID:string;
mfind_string:string;
mr,mrsa,mxax:tstringlist;
mStoreCard_ID:string;
mBO_adress:TNxCustomBusinessObject;
mAdress_id:string;
mi_result:integer;
mMon,mBAtches:TNxCustomBusinessMonikerCollection;
mstorecard_text:string;
mbo_docqueue,mbatch:TNxCustomBusinessObject;
mQunit:string;
mPacName:string;
mabraqunit:string;
mTyp_Eshopu:string;
mUnicodeName,mUnicodeCity,mUnicodeStreet,mUnicodeLocation,mUnicodeFullName:string;
mCode: integer;
mBusOrder_ID,mBusProject_ID,mbo_id:string;
mTariff: String;
mShowError:boolean;
mrx:tstringlist;
mpocet:double;
mError:boolean;
mImportFile:TStringList;
    mid :string;
    moddelovac:string;
    mOLE, mRoll, mOResult: Variant;
  mGrid: TdbGrid;
  mControl: TControl;
  mDataSource: TDataSource;
  mDataset: TNxRowsObjectDataSet;
    _ss:Variant;
    mfirm_id:string;
    mstringline:string;
  mCountField:integer;
  mfieldValue,mRSql:tstringlist;
  mbatch_ID:string;
  mlist:tstringlist;
  mFirmOffice_id:string;
  mBO_PohybSarze:TNxCustomBusinessObject;
  mstring:string;
  mvalue:tstringlist;
  mBoolean:Boolean;
  mSourceSC,mTargetSC,mSourceBatch,mTargetBatch:string;
  msourceQuantity , mTargetQuantity, mBatchQuantity:double;
  mBO_MonikerBatches,mRowsOutput:TNxCustomBusinessMonikerCollection;
  mID_sourdce_doc:string;
  mParams, mP : TNxParameters;
  mPar : TNxParameter;
  mManager : TNxDocumentImportManager ;
  mValidateList:tstringlist;
  mBO_Batch:TNxCustomBusinessObject;
  mTextReport:string;
  mSourceList,mTargetList:tstringlist;
  mFError,mSError:string;
  mID_source_doc:string;
begin
  mError:=false;
  mFError:='';
  mSError:='';
    mTextReport:='';
//NxShowSimpleMessage('Aa',nil);
    if not FileExists(AFileName) then begin
      Result := False;
      exit;
    end;


  mOLE := GetAbraOLEApplication;
    mroll := mOLE.GetAgenda('OFZO2K155FDL3CL100C4RHECN0');
    _ss := mOLE.CreateStrings;

   mstore_ID:= mroll.SingleSelectFromSelected2(_ss, 'Vyber sklad', '');
//NxShowSimpleMessage('bb',nil);
 mImportFile:=TStringList.create;
 mImportFile.LoadFromFile(AFileName);

  mr:=tstringlist.create;
  try
       os.SQLSelect('Select X_Firm_ID from Stores where id=' + quotedstr(mstore_id),mr);
       if mr.count>0 then begin
           mfirm_id:=mr.Strings[0];
       end else begin
           mfirm_id:='';
       end;
  finally
     mr.free;
  end;

  //NxShowSimpleMessage('cc',nil);
  mr:=tstringlist.create;
  try
       os.SQLSelect('Select id from FirmOffices where X_Store_ID=' + quotedstr(mstore_id) + ' and Parent_ID=' + quotedstr(mfirm_id) ,mr);
       if mr.count>0 then begin
           mFirmOffice_id:=mr.Strings[0];
       end else begin
           mFirmOffice_id:='';
       end;
  finally
     mr.free;
  end;

//NxShowSimpleMessage('dd',nil);
mSourceSC:='';
mSourceBatch:='';
msourceQuantity:=0;
mTargetSC:='';
mTargetBatch:='';
mTargetQuantity:=0;



 mlist:=tstringlist.create;
 mSourceList:=tstringlist.create;
 mTargetList:=tstringlist.create;
 try
      for i:=0 to mImportFile.Count-1 do begin   // načtení souboru

             //ProgressSetPos(1+NxFloor((i/mImportFile.Count)*99), inttostr(i) +' z '+inttostr(mImportFile.Count));
            mstringline:= mImportFile.strings[i];
            if trim(mstringline)<>'' then begin
                mvalue:=tstringlist.create;
                   try
                       mvalue:=FNParsevalue(mstringline,';');
                       //NxShowSimpleMessage(IntToStr(mvalue.count),nil);
                       if NxIBStrToFloat(mvalue.Strings[6])<>0 then begin
                              mr:=TStringList.create;
                                        try
                                            os.SQLSelect('Select ID from StoreCards where EAN=' + quotedstr(mvalue.Strings[1]),mr);
                                            if mr.count>0 then begin
                                                 mSourceSC:=mr.Strings[0];
                                            end else begin
                                                 mError:=True;
                                                 mSError:= mSError + 'Karta: ' + mvalue.Strings[1] + ' , EAN: ' + mvalue.Strings[1] + ' nebyla dohledána' + chr(10);
                                            end;

                                        finally
                                            mr.free;
                                        end;

                                        mr:=TStringList.create;
                                        try
                                            os.SQLSelect('Select id from StoreBatches where Name=' + quotedstr(mvalue.Strings[2]) + ' And Storecard_ID=' + quotedstr(mSourceSC)  ,mr);
                                            if mr.count>0 then begin
                                                 mSourceBatch:=mr.Strings[0];
                                            end else begin
                                                 mError:=True;
                                                 mSError:= mSError + 'Šarže: ' + mvalue.Strings[2] + ' , pro kartu: ' + mvalue.Strings[0] + ' nebyla dohledána' + chr(10);
                                            end;

                                        finally
                                            mr.free;
                                        end;

                           if NxIBStrToFloat(mvalue.Strings[6])<0 then begin
                                  mSourceList.add(mSourceSC+';'+mSourceBatch+';'+NxFloatToIBStr(abs(NxIBStrToFloat(mvalue.Strings[6]))))  ;
                           end;
                           if NxIBStrToFloat(mvalue.Strings[6])>0 then begin
                                  mTargetList.add(mSourceSC+';'+mSourceBatch+';'+NxFloatToIBStr(abs(NxIBStrToFloat(mvalue.Strings[6]))))  ;
                           end;
                       end;
                   finally
                        mvalue.free;
                   end;

            end;
      end;





      mSourceList.Sort;
      mTargetList.sort;
      msourceQuantity:=0;
      mTargetQuantity:=0;
      mBatchQuantity:=0;
      for i:=0 to mSourceList.Count-1 do begin
      //  NxShowSimpleMessage(copy(mSourceList.Strings[i],23,10),nil);
         if (i=0) then begin
            msourceQuantity:=msourceQuantity + NxIBStrToFloat(copy( mSourceList.Strings[i],23,10));
            mBatchQuantity:=mBatchQuantity + NxIBStrToFloat(copy( mSourceList.Strings[i],23,10));
         end else begin
            // STEJNÁ SKLADOVÁ KARTA
            if copy(mSourceList.Strings[i],1,10)=copy(mSourceList.Strings[i-1],1,10) then begin
               msourceQuantity:=msourceQuantity+ NxIBStrToFloat(copy( mSourceList.Strings[i],23,10));
                                 // STEJNÁ ŠARŽE
                                 if copy(mSourceList.Strings[i],1,21)=copy(mSourceList.Strings[i-1],1,21) then begin
                                    mBatchQuantity:=mBatchQuantity+ NxIBStrToFloat(copy( mSourceList.Strings[i],23,10));
                                 end else begin
                                     // KONTROLA NOŽSTVÍ
                                     mr:=TStringList.create;
                                     try
                                       os.SQLSelect('Select sum(quantity) from StoreSubBatches where Storebatch_ID=' + quotedstr(copy(mSourceList.Strings[i-1],12,10)) + ' And Store_ID=' + quotedstr(mstore_ID)  ,mr);
                                          if NxIBStrToFloat(mr.Strings[0])< mBatchQuantity then begin
                                              //NxShowSimpleMessage('y' + inttostr(i) + '  - '  +    mSourceList.Strings[i-1],nil);
                                              mrx:=TStringList.create;
                                               try
                                                 msite.BaseObjectSpace.SQLSelect('Select name from storeBatches where id= ' + QuotedStr(copy(mSourceList.Strings[i-1],12,10)),mrx);
                                                 if mrx.count>0 then begin

                                                         mSError:= mSError + 'Na uvedeném skladě není dostatečné množství šarže: ' + quotedstr(mrx.Strings[0]) + ' , požadavek:  ' + NxFloatToIBStr(mBatchQuantity) + ' skladem ' +  mr.strings[0] + chr(10);
                                                         mError:=True;
                                                 end;
                                               finally
                                               mrx.free;
                                               end;
                                              mError:=True;

                                          end;
                                          mBatchQuantity:= NxIBStrToFloat(copy(mSourceList.Strings[i],23,10));
                                     finally
                                         mr.free;
                                     end;

                                 end;
            end else begin

                                 if copy(mSourceList.Strings[i],1,21)=copy(mSourceList.Strings[i-1],1,21) then begin
                                    mBatchQuantity:=mBatchQuantity+ NxIBStrToFloat(copy( mSourceList.Strings[i],23,10));
                                 end else begin
                                     // KONTROLA NOŽSTVÍ
                                     mr:=TStringList.create;
                                     try
                                       os.SQLSelect('Select sum(quantity) from StoreSubBatches where Storebatch_ID=' + quotedstr(copy(mSourceList.Strings[i-1],12,10)) + ' And Store_ID=' + quotedstr(mstore_ID)  ,mr);
                                          if NxIBStrToFloat(mr.Strings[0])< mBatchQuantity then begin
                                              //NxShowSimpleMessage('x' + inttostr(i) + '  - '  +    mSourceList.Strings[i-1],nil);
                                              mrx:=TStringList.create;
                                               try
                                                 msite.BaseObjectSpace.SQLSelect('Select name from storeBatches where id= ' + QuotedStr(copy(mSourceList.Strings[i-1],12,10)),mrx);
                                                 if mrx.count>0 then begin

                                                         mSError:= mSError + 'Na uvedeném skladě není dostatečné množství šarže: ' + quotedstr(mrx.Strings[0]) + ' , požadavek:  ' + NxFloatToIBStr(mBatchQuantity) + ' skladem ' +  mr.strings[0] + chr(10);
                                                         mError:=True;
                                                 end;
                                               finally
                                               mrx.free;
                                               end;
                                              mError:=True;

                                          end;
                                          mBatchQuantity:=NxIBStrToFloat(copy(mSourceList.Strings[i],23,10));
                                     finally
                                         mr.free;
                                     end;

                                 end;



               // NAPOČTENÍ CÍLOVÉHO MNOŽSTVÍ
                             mTargetQuantity:=0;
                             for x:=0 to mTargetList.count-1 do begin
                                 if copy(mSourceList.Strings[i-1],1,10)=copy(mTargetList.Strings[x],1,10) then begin
                                    mTargetQuantity:=mTargetQuantity+ NxIBStrToFloat(copy(mTargetList.Strings[x],23,10));
                                 end;
                             end;

                            // NxShowSimpleMessage('Položky si neodpovídají ' + copy(mSourceList.Strings[i],1,10) + ' : ' +  NxFloatToIBStr(msourceQuantity) + '/' +NxFloatToIBStr(mTargetQuantity),nil);


                             // VYHODNOCENÍ
                                       if (msourceQuantity<>mTargetQuantity) then begin
                                          mr:=tstringlist.create;
                                           try
                                              msite.BaseObjectSpace.SQLSelect('Select Name from StoreCards where id=' + QuotedStr(copy(mSourceList.Strings[i-1],1,10)),mr);
                                              if mr.count>0 then begin
                                                  mSError:= mSError + 'Nesoulad ' + mr.Strings[0] + ' : ' +  NxFloatToIBStr(msourceQuantity) + '/' +NxFloatToIBStr(mTargetQuantity)+ chr(10);
                                              end;
                                              mError:=True;
                                           finally
                                               mr.free;
                                           end;

                                       end;
                                                     msourceQuantity:=0;
                              mTargetQuantity:=0;
                              msourceQuantity:=NxIBStrToFloat(copy( mSourceList.Strings[i],23,10));



            end;
         end;


            // POSLEDNÍ ZÁZNAM
            if i=(mSourceList.Count-1) then begin
                  //  msourceQuantity:=msourceQuantity+ NxIBStrToFloat(copy( mSourceList.Strings[i],23,10));
                   // KONTROLA STAVU NA SKLADĚ
                   //mBatchQuantity:=NxIBStrToFloat(copy(mSourceList.Strings[i],23,10));
                   mr:=TStringList.create;
                   try
                     os.SQLSelect('Select sum(quantity) from StoreSubBatches where Storebatch_ID=' + quotedstr(copy(mSourceList.Strings[i],12,10)) + ' And Store_ID=' + quotedstr(mstore_ID)  ,mr);
                        if NxIBStrToFloat(mr.Strings[0])<mBatchQuantity then begin
                             mError:=True;
                             mrx:=TStringList.create;
                             try
                               msite.BaseObjectSpace.SQLSelect('Select name from storeBatches where id= ' + quotedstr(copy(mSourceList.Strings[i],12,10)),mrx);
                               if mrx.count>0 then begin
                                     mSError:= mSError + 'Na uvedeném skladě není dostatečné množství šarže: ' + quotedstr(mrx.strings[0]) + ' , požadavek: ' + NxFloatToIBStr(msourceQuantity) + ' skladem ' +  mr.strings[0] + chr(10);
                                     mError:=true;
                               end;
                             finally
                             mrx.free;
                             end;
                        end;
                   finally
                       mr.free;
                   end;




               // NAPOČTENÍ CÍLOVÉHO MNOŽSTVÍ
               mTargetQuantity:=0;
               for x:=0 to mTargetList.count-1 do begin
                   if copy(mSourceList.Strings[i],1,10)=copy(mTargetList.Strings[x],1,10) then begin
                      mTargetQuantity:=mTargetQuantity+ NxIBStrToFloat(copy( mTargetList.Strings[x],23,10));
                   end;
               end;
               // VYHODNOCENÍ
               if msourceQuantity<>mTargetQuantity then begin
                   mr:=tstringlist.create;
                   try
                      msite.BaseObjectSpace.SQLSelect('Select Name from StoreCards where id=' + QuotedStr(copy(mSourceList.Strings[i],1,10)),mr);
                      if mr.count>0 then begin
                          mSError:= mSError + 'Nesoulad x ' + mr.Strings[0] + ' : ' +  NxFloatToIBStr(msourceQuantity) + '/' +NxFloatToIBStr(mTargetQuantity)+ chr(10);
                      end;
                      mError:=True;
                   finally
                       mr.free;
                   end;
               end;
            end;
               end;
  //NxShowSimpleMessage( mSError + CHR(10) + inttostr(mSourceList.count) + ' - ' + inttostr(mTargetList.count), nil);

  if mError then begin
      NxShowSimpleMessage('###   chyba   ###   ' +  CHR(10) +   CHR(10) + mSError + CHR(10) + ' V dalším zpracování není možné pokračovat . ' + Chr(10) + 'Prosím opravte chyby a operaci zopakujte' , nil);
      exit;
  end;

  msourceQuantity:=0;
  mTargetQuantity:=0;

//      NxShowSimpleMessage(inttostr(mlist.count),nil);
         mHead := TNxHeaderBusinessObject(msite.BaseObjectSpace.CreateObject('E32A1GVWPYY4BJZFV5NFSRAODW'));
                try
                             mHead.New;
                             mHead.Prefill;
                                      mHead.SetFieldValueAsString('DocQueue_ID', '27B0000101');                   // dl
                                      mHead.SetFieldValueAsString('Firm_ID', mfirm_id);
                                      mHead.SetFieldValueAsString('FirmOffice_ID', mFirmOffice_id);

                                    mTargetQuantity:=0;
                                    mBatchquantity:=0;

                                  //  NxShowSimpleMessage('Položka ' + inttostr(mSourceList.count) , nil);
                                    for i:=0 to mSourceList.count-1 do begin

                                       mvalue:=tstringlist.create;
                                       try



                                            mvalue:=FNParsevalue(mSourceList.strings[i],';');


                                            //NxShowSimpleMessage('Položka ' + inttostr(i) , nil);

                                            if i=0 then begin                                   // první záznam
                                               mRow := mHead.Rows.AddNewObject;
                                                      //NxShowSimpleMessage(mvalue.Strings[0] + ' / ' + mvalue.Strings[6],nil);
                                                                   mRow.Prefill;
                                                                   msourceQuantity:=NxIBStrToFloat(mvalue.Strings[2]);
                                                                   mRow.SetFieldValueAsInteger('RowType',3);
                                                                   mRow.SetFieldValueAsString('Store_ID',mstore_id);
                                                                   mRow.SetFieldValueAsString('StoreCard_ID',mvalue.Strings[0]);
                                                                   //mRow.SetFieldValueAsstring('Division_ID','1N00000101');
                                                                   mRow.SetFieldValueAsstring('Division_ID','~000000402');
                                                                   if NxIsEmptyOID(mRow.GetFieldValueAsString('BusTransaction_id')) then begin
                                                                        if not NxIsEmptyOID((mRow.GetFieldValueAsString('StoreCard_id.X_BusTransaction_ID'))) then begin
                                                                                     mBustransaction_ID:=(mRow.GetFieldValueAsString('StoreCard_id.X_BusTransaction_ID'));
                                                                                     mRow.SetFieldValueAsString('BusTransaction_id',mBustransaction_ID );
                                                                        end;
                                                                    end;
                                                                    if NxIsEmptyOID(mRow.GetFieldValueAsString('BusOrder_id')) then begin
                                                                              mBusOrder_ID:=GetBusOrder_ID(mRow);
                                                                              if not nxisblank(mBusOrder_ID) then mRow.SetFieldValueAsString('BusOrder_id',mBusOrder_ID);
                                                                    end;
                                                                    if NxIsEmptyOID(mRow.GetFieldValueAsString('BusProject_id')) then begin
                                                                        mBusProject_ID:=GetProject_ID(mRow);
                                                                        if not nxisblank(mBusProject_ID) then mRow.SetFieldValueAsString('BusProject_id',mBusProject_ID);
                                                                    end;
                                                                    msourceQuantity:=NxIBStrToFloat(mvalue.Strings[2]) ;
                                                                    mrow.setFieldValueAsFloat('Quantity',msourceQuantity);
                                                                    mBatchquantity:=NxIBStrToFloat(mvalue.Strings[2]) ;
                                                                    mBO_MonikerBatches:=mRow.GetLoadedCollectionMonikerForFieldCode(mRow.GetFieldCode('DocRowBatches'));
                                                                             mBatch:=mBO_MonikerBatches.AddNewObject;
                                                                             mBatch.Prefill;
                                                                                      mBatchquantity:= NxIBStrToFloat(mvalue.Strings[2]);
                                                                                      mBatch.SetFieldValueAsstring('StoreBatch_ID',mvalue.Strings[1]);
                                                                                      mBatch.setFieldValueAsFloat('Quantity',mBatchquantity);
                                            end else begin   // následné záznamy
                                                  if copy(mSourceList.Strings[i],1,10)=copy(mSourceList.Strings[i-1],1,10) then begin // novy pohyb row
                                                         msourceQuantity:=msourceQuantity+NxIBStrToFloat(mvalue.Strings[2]);
                                                         if copy(mSourceList.Strings[i],1,22)=copy(mSourceList.Strings[i-1],1,22) then begin // novy pohyb šarže
                                                              mBatchquantity:= mBatchquantity+ NxIBStrToFloat(mvalue.Strings[2]) + NxIBStrToFloat(mvalue.Strings[2]);
                                                         end else begin
                                                              mBatch.setFieldValueAsFloat('Quantity',mBatchquantity);
                                                              mBatchquantity:=0;
                                                              mBO_MonikerBatches:=mRow.GetLoadedCollectionMonikerForFieldCode(mRow.GetFieldCode('DocRowBatches'));
                                                                             mBatch:=mBO_MonikerBatches.AddNewObject;
                                                                             mBatch.Prefill;
                                                                                      mBatchquantity:= NxIBStrToFloat(mvalue.Strings[2]);
                                                                                      mBatch.SetFieldValueAsstring('StoreBatch_ID',mvalue.Strings[1]);
                                                                                      mBatch.setFieldValueAsFloat('Quantity',mBatchquantity);
                                                          end;
                                                          mrow.setFieldValueAsFloat('Quantity',msourceQuantity);
                                                          //msourceQuantity:=0;
                                                  end else begin
                                                          mRow := mHead.Rows.AddNewObject;
                                                      //NxShowSimpleMessage(mvalue.Strings[0] + ' / ' + mvalue.Strings[6],nil);
                                                                   mRow.Prefill;
                                                                   msourceQuantity:=NxIBStrToFloat(mvalue.Strings[2]);
                                                                   mRow.SetFieldValueAsInteger('RowType',3);
                                                                   mRow.SetFieldValueAsString('Store_ID',mstore_id);
                                                                   mRow.SetFieldValueAsString('StoreCard_ID',mvalue.Strings[0]);
                                                                   //mRow.SetFieldValueAsstring('Division_ID','1N00000101');
                                                                   mRow.SetFieldvalueAsString('Division_Id','~000000402');
                                                                   if NxIsEmptyOID(mRow.GetFieldValueAsString('BusTransaction_id')) then begin
                                                                        if not NxIsEmptyOID((mRow.GetFieldValueAsString('StoreCard_id.X_BusTransaction_ID'))) then begin
                                                                                     mBustransaction_ID:=(mRow.GetFieldValueAsString('StoreCard_id.X_BusTransaction_ID'));
                                                                                     mRow.SetFieldValueAsString('BusTransaction_id',mBustransaction_ID );
                                                                        end;
                                                                    end;
                                                                    if NxIsEmptyOID(mRow.GetFieldValueAsString('BusOrder_id')) then begin
                                                                              mBusOrder_ID:=GetBusOrder_ID(mRow);
                                                                              if not nxisblank(mBusOrder_ID) then mRow.SetFieldValueAsString('BusOrder_id',mBusOrder_ID);
                                                                    end;
                                                                    if NxIsEmptyOID(mRow.GetFieldValueAsString('BusProject_id')) then begin
                                                                        mBusProject_ID:=GetProject_ID(mRow);
                                                                        if not nxisblank(mBusProject_ID) then mRow.SetFieldValueAsString('BusProject_id',mBusProject_ID);
                                                                    end;
                                                                    msourceQuantity:=NxIBStrToFloat(mvalue.Strings[2]) ;
                                                                    mrow.setFieldValueAsFloat('Quantity',msourceQuantity);
                                                                    mBatchquantity:=NxIBStrToFloat(mvalue.Strings[2]) ;
                                                                    mBO_MonikerBatches:=mRow.GetLoadedCollectionMonikerForFieldCode(mRow.GetFieldCode('DocRowBatches'));
                                                                             mBatch:=mBO_MonikerBatches.AddNewObject;
                                                                             mBatch.Prefill;
                                                                                      mBatchquantity:= NxIBStrToFloat(mvalue.Strings[2]);
                                                                                      mBatch.SetFieldValueAsstring('StoreBatch_ID',mvalue.Strings[1]);
                                                                                      mBatch.setFieldValueAsFloat('Quantity',mBatchquantity);
                                                  end;



                                            end;



                                       finally
                                           mvalue.free;
                                       end;
                                    end;
                                    //mBatch.setFieldValueAsFloat('Quantity',mBatchquantity);
                                    //mrow.setFieldValueAsFloat('Quantity',msourceQuantity);



                                     //ProgressDispose()   ;
                                          //NxShowSimpleMessage('AAA',nil);
                                          mhead.ClearValidateErrors;
                                          if Not mhead.Validate() then begin
                                                mList := TStringList.Create;
                                                try
                                                   mhead.GetValidateErrors(mList);
                                                   mText := mList.Text;
                                                   NxToken(mText, '=');
                                                   MessageDlg('Automaticky vytvořenou zámenu výdej nelze uložit z těchto důvodů:' + #13#10 + mText,

                                                   mtWarning, [mbOK], 0);
                                                 finally
                                                   mList.Free;
                                                 end;
                                                 mSite.ShowDynFormWithNewDocument('RQE0MPXTACU4B2B5HGG053P44C', mSite.SiteContext, mhead);             //                       B50I5SAOS3DL3ACU03KIU0CLP4
                                                 //exit;

                                          end else begin
                                                //mhead.Save;
                                                //mSite.ShowDynFormWithNewDocument('O2XDU14IW3DL342X01C0CX3FCC', mSite.SiteContext, mhead);
                                                //NxShowSimpleMessage('Objednávka přijatá ' + mhead.GetFieldValueAsString('displayname')  ,nil);               //         B50I5SAOS3DL3ACU03KIU0CLP4
                                                mhead.save;
                                                mID_source_doc:=mhead.oid;
                                                mTextReport:=mhead.DisplayName;
                                                //mSite.ShowDynFormWithNewDocument('O2XDU14IW3DL342X01C0CX3FCC', mSite.SiteContext, mhead);

                                          end;



                    finally
                         mhead.free;
                    end;
            Result := True;
 finally
     mlist.free;
 end;


 if mID_source_doc<>'' then begin

      mManager := NxCreateDocumentImportManager(msite.BaseObjectSpace,'E32A1GVWPYY4BJZFV5NFSRAODW','JFQYSEOTKPC4RAMLQVLUK5NV34');   // op to fv

                mParams := TNxParameters.Create();
                try
                  mManager.AddInputDocument(mID_source_doc);
                  mParams.GetOrCreateParam(dtString, 'DocQueue_ID').AsString := '37B0000101';
                  mParams.GetOrCreateParam(dtString, 'Store_ID').AsString := mStore_id;



                  mManager.LoadParams(mParams);
                  mManager.Execute;
                  mManager.OutputDocument.SetFieldValueAsString('Firm_ID',mManager.InputDocument.GetFieldValueAsString('Firm_ID'));
                  mManager.OutputDocument.SetFieldValueAsString('FirmOffice_ID',mManager.InputDocument.GetFieldValueAsString('FirmOffice_ID'));
                  mManager.OutputDocument.SetFieldValueAsString('Person_ID',mManager.InputDocument.GetFieldValueAsString('Person_ID'));
                  mManager.OutputDocument.SetFieldValueAsString('Description',mManager.InputDocument.GetFieldValueAsString('Description'));

                  mRowsOutput := mManager.OutputDocument.GetLoadedCollectionMonikerForFieldCode(mManager.OutputDocument.GetFieldCode('Rows'));

                  for ii:=0 to mRowsOutput.Count-1 do begin
                        mRow:=mRowsOutput.BusinessObject[ii];
                        for i:=0 to mTargetList.count-1 do begin
                             if mRowsOutput.BusinessObject[ii].getFieldValueAsstring('Storecard_ID')=copy(mTargetList.Strings[i],1,10) then begin  // dohledán řádek
                                   mBO_MonikerBatches:=mRowsOutput.BusinessObject[ii].GetLoadedCollectionMonikerForFieldCode(mRowsOutput.BusinessObject[ii].GetFieldCode('DocRowBatches'));
                                           mBO_Batch:=mBO_MonikerBatches.AddNewObject;
                                           //NxShowSimpleMessage( copy(mrow.getFieldValueAsstring('X_note'),12,10),nil);
                                           mBO_Batch.SetFieldValueAsString('StoreBatch_ID',copy(mTargetList.Strings[i],12,10));
                                           mBO_Batch.SetFieldValueAsFloat('Quantity',NxIBStrToFloat(copy(mTargetList.Strings[i],23,10)));
                                           mBO_Batch.SetFieldValueAsString('QUnit',mrow.getFieldValueAsString('qunit'));
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

                                             TDynSiteForm(mSite).ShowDynFormWithNewDocument('EGVDANSIQWY4V2Y52YRUPRHAK4', TDynSiteForm(mSite).SiteContext, mManager.OutputDocument);  // fv

                                      end else begin

                                          mManager.OutputDocument.Save;
                                          mTextReport:=  mTextReport + ' / ' + mManager.OutputDocument.DisplayName;
                                           NxShowSimpleMessage('Záměna proběhla ' + mTextReport,nil);
                                      end;


//                  result:= inttostr(mManager.OutputDocument.GetFieldValueAsInteger('Ordnumber'));



                 finally
                  mManager.Free;
                  mParams.free;
                 end;


end;












end;



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
          mMAction.Hint := 'Záměna šarží Inventura';
          mMAction.Caption := 'Záměna šarží Inventura';
          mMAction.Items.Add('Záměna jen šarží(sc musí být stejné)');
          mMAction.Items.Add('Záměna sc i šarží po řádcích');
          mMAction.Category := 'tabList';
          mMAction.OnExecuteItem := @OnExec;


end;


procedure OnExec1(Sender: TComponent;index:integer);
var

  zadej:string;
  mfilename:string;
  mdir,mfile:string;
  mFileList:tstringlist;
  mString:string;
begin
  //mSite := NxFinddySiteForm(Sender);
  mstring:='';
  msite:=TComponent(Sender).DynSite;
  mstring:=InputBox('zadej kod', 'Kod', mstring);
  mstring:=DatamatrixDecodeBatches(TDynSiteForm(msite).BaseObjectSpace, mstring);
  NxShowSimpleMessage(mstring,nil);
end;


procedure OnExec(Sender: TComponent;index:integer);
var

  zadej:string;
  mfilename:string;
  mdir,mfile:string;
  mFileList:tstringlist;
  mBoolean:Boolean;
begin
  //mSite := NxFinddySiteForm(Sender);
  msite:=TComponent(Sender).DynSite;
        if PromptForFileName(mFileName, '*.csv', '', 'Soubory Inventury', '', False,msite) then begin
                      mdir:=copy(mfilename,0,NxCharPosR('\',mfilename));
                      mFile:=copy(mfilename,1+NxCharPosR('\',mfilename),Length(mfilename));
        end;
        if index=0 then ImportFilex2(TDynSiteForm(mSite).BaseObjectSpace, mfilename, mdir,mfile,msite,true,false,index);
        if index=1 then ImportFilex3(TDynSiteForm(mSite).BaseObjectSpace, mfilename, mdir,mfile,msite,true,false,index);

  TDynSiteForm(mSite).Refreshdata;
end;





begin
end.
