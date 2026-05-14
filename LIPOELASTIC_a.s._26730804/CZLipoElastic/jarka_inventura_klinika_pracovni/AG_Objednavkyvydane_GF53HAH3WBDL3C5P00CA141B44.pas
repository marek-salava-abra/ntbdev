uses '_Knihovny_ALL.head', '_Knihovny_ALL.Progress','_Knihovny_ALL.Parse',
'abra.eu.mask_import.2018.Objednavka_prijata';

const
    mFilter='*.csv';





function ZamImportFileX2(OS: TNxCustomObjectSpace; AFileName: string;directory: string;filename: string;msite:TDynSiteForm;rucne:boolean;chyba:boolean;index:Integer) : Boolean;
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
  mquantity:double;
  mBatchquantity:double;
  mlist:tstringlist;
  mFirmOffice_id:string;
  mBO_PohybSarze:TNxCustomBusinessObject;
  mstring:string;
  mvalue:tstringlist;
  mBoolean:Boolean;
  mSourceSC,mTargetSC,mSourceBatch,mTargetBatch:string;
  msourceQuantity , mTargetQuantity:double;
  mBO_MonikerBatches,mRowsOutput:TNxCustomBusinessMonikerCollection;
  mID_sourdce_doc:string;
  mParams, mP : TNxParameters;
  mPar : TNxParameter;
  mManager : TNxDocumentImportManager ;
  mValidateList:tstringlist;
  mBO_Batch:TNxCustomBusinessObject;
  mTextReport:string;
begin
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

 try
      for i:=0 to mImportFile.Count-1 do begin   // načtení souboru
            //ProgressSetPos(1+NxFloor((i/mImportFile.Count)*99), inttostr(i) +' z '+inttostr(mImportFile.Count));
            mstringline:= mImportFile.strings[i];
            if trim(mstringline)<>'' then begin
                mvalue:=tstringlist.create;
                   try
                       Parsevalue(mstringline,';',mstringline,mvalue,6);
                       if NxIBStrToFloat(mvalue.Strings[5])<>0 then begin
                           if NxIBStrToFloat(mvalue.Strings[5])<0 then begin
                                if mSourceSC='' then begin

                                        mr:=TStringList.create;
                                        try
                                            os.SQLSelect('Select id from storecards where EAN=' + quotedstr(mvalue.Strings[1]),mr);
                                            if mr.count>0 then begin
                                                 mSourceSC:=mr.Strings[0];
                                            end;

                                        finally
                                            mr.free;
                                        end;

                                        mr:=TStringList.create;
                                        try
                                            os.SQLSelect('Select id from StoreBatches where Name=' + quotedstr(mvalue.Strings[2]),mr);
                                            if mr.count>0 then begin
                                                 mSourceBatch:=mr.Strings[0];
                                            end;

                                        finally
                                            mr.free;
                                        end;
                                        msourceQuantity:=NxIBStrToFloat(mvalue.Strings[5]);
                                end else begin
                                    NxShowSimpleMessage('Došlo k problémům v posloupnosti dat kladné '
                                     + mSourceSC+';'+mSourceBatch+';'+mTargetSC+';'+mTargetBatch+';'+NxFloatToIBStr(abs(msourceQuantity))+';'+NxFloatToIBStr(abs(mTargetQuantity))
                                    ,nil);
                                end;
                                //NxShowSimpleMessage(mvalue.Strings[1] + ' - ' + mvalue.Strings[2] + '  - ' + mvalue.Strings[5],nil);
                           end;
                           if NxIBStrToFloat(mvalue.Strings[5])>0 then begin
                                if mTargetSC='' then begin

                                        mr:=TStringList.create;
                                        try
                                            os.SQLSelect('Select id from storecards where EAN=' + quotedstr(mvalue.Strings[1]),mr);
                                            if mr.count>0 then begin
                                                 mTargetSC:=mr.Strings[0];
                                            end;

                                        finally
                                            mr.free;
                                        end;

                                        mr:=TStringList.create;
                                        try
                                            os.SQLSelect('Select id from StoreBatches where Name=' + quotedstr(mvalue.Strings[2]),mr);
                                            if mr.count>0 then begin
                                                 mTargetBatch:=mr.Strings[0];
                                            end;

                                        finally
                                            mr.free;
                                        end;
                                        mtargetQuantity:=abs(NxIBStrToFloat(mvalue.Strings[5]));
                                end else begin
                                    NxShowSimpleMessage('Došlo k problémům v posloupnosti dat záporné ' +
                                    mSourceSC+';'+mSourceBatch+';'+mTargetSC+';'+mTargetBatch+';'+NxFloatToIBStr(abs(msourceQuantity))+';'+NxFloatToIBStr(abs(mTargetQuantity))
                                    ,nil);
                                end;
                           end;

                            if NxIBStrToFloat(mvalue.Strings[5])<>0 then begin
                                if (mSourceSC<>'') and (mTargetSC<>'') then begin
                                  mlist.add(mSourceSC+';'+mSourceBatch+';'+mTargetSC+';'+mTargetBatch+';'+NxFloatToIBStr(abs(msourceQuantity))+';'+NxFloatToIBStr(abs(mTargetQuantity)))  ;

                                  mSourceSC:='';
                                  mSourceBatch:='';
                                  msourceQuantity:=0;
                                  mTargetSC:='';
                                  mTargetBatch:='';
                                  mTargetQuantity:=0;
                               end;
                            end;
                       end;

                   finally
                        mvalue.free;
                   end;



            end;
      end;










//      NxShowSimpleMessage(inttostr(mlist.count),nil);
         mHead := TNxHeaderBusinessObject(msite.BaseObjectSpace.CreateObject('CDMK5QAWZZDL342X01C0CX3FCC'));
         mBO_PohybSarze:=msite.BaseObjectSpace.CreateObject('EC2R2HSFK5UOZ5MYVJWJOHUC4S');
                try
                             mHead.New;
                             mHead.Prefill;
                                      mHead.SetFieldValueAsString('DocQueue_ID', '1540000101');                   // dl
                                      mHead.SetFieldValueAsString('Firm_ID', mfirm_id);
                                      mHead.SetFieldValueAsString('FirmOffice_ID', mFirmOffice_id);

                                    mquantity:=0;
                                    mBatchquantity:=0;
                                    for i:=0 to mlist.count-1 do begin

                                       mvalue:=tstringlist.create;
                                       try

                                            Parsevalue(mlist.strings[i],';',mlist.strings[i],mvalue,6);


                                            //NxShowSimpleMessage('Položka ' + inttostr(i) , nil);

                                            if i=0 then begin                                   // první záznam



                                                      mRow := mHead.Rows.AddNewObject;
                                                     // NxShowSimpleMessage(mvalue.Strings[0] + ' / ' + mvalue.Strings[5],nil);
                                                                   mRow.Prefill;
                                                                   mquantity:=NxIBStrToFloat(mvalue.Strings[5]);
                                                                   mRow.SetFieldValueAsInteger('RowType',3);
                                                                   mRow.SetFieldValueAsString('Store_ID',mstore_id);
                                                                   mRow.SetFieldValueAsString('StoreCard_ID',mvalue.Strings[0]);
                                                                   mRow.SetFieldValueAsstring('Division_ID','1N00000101');
                                                                   mRow.SetFieldValueAsFloat('Quantity',NxIBStrToFloat(mvalue.Strings[5]));
                                                                   mRow.SetFieldValueAsstring('X_note',mvalue.Strings[2] + ';' +mvalue.Strings[3] + ';' +mvalue.Strings[4]);
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
                                                                    //    mBO_MonikerBatches:=mRow.GetLoadedCollectionMonikerForFieldCode(mRow.GetFieldCode('DocRowBatches'));
                                                                    //         mBatch:=mBO_MonikerBatches.AddNewObject;
                                                                    //         mBatch.Prefill;

                                                                    //                  mBatch.SetFieldValueAsstring('StoreBatch_ID',mvalue.Strings[1]);
                                                                    //                  mBatch.setFieldValueAsFloat('Quantity',NxIBStrToFloat(mvalue.Strings[5]));
                                                                              mBO_PohybSarze.new;
                                                                                    mBO_PohybSarze.Prefill;
                                                                                    mBatchquantity:= NxIBStrToFloat(mvalue.Strings[5]);
                                                                                    mBO_PohybSarze.SetFieldValueAsstring('Code',mhead.OID);
                                                                                    mBO_PohybSarze.SetFieldValueAsstring('X_Parent_ID',mRow.OID);
                                                                                    mBO_PohybSarze.SetFieldValueAsstring('X_Firm_ID',mfirm_id);
                                                                                    mBO_PohybSarze.SetFieldValueAsstring('X_Parent2_ID',mRow.GetFieldValueAsString('Storecard_ID'));
                                                                                    mBO_PohybSarze.SetFieldValueAsstring('X_Batches',mvalue.Strings[1]);
                                                                                    mBO_PohybSarze.SetFieldValueAsstring('Name', copy(mRow.GetFieldValueAsString('Storecard_ID.name'),1,30));
                                                                                    mBO_PohybSarze.SetFieldValueAsFloat('X_quantity', mBatchquantity);
                                                                                    //mBO_PohybSarze.save;






                                            end else begin   // následné záznamy
                                                         if copy(mlist.Strings[i],1,22)<>copy(mlist.Strings[i-1],1,22) then begin // novy pohyb sc
                                                                mRow.SetFieldValueAsFloat('Quantity',mquantity);   // uložení množství do řádku

                                                                    mBO_PohybSarze.SetFieldValueAsFloat('X_quantity', mBatchquantity);
                                                                    //if (mbatch.getFieldValueAsFloat('X_quantity')>0) and (not NxIsEmptyOID(mBO_PohybSarze.getFieldValueAsstring('X_Batches'))) then  mBO_PohybSarze.save;
                                                                    mBO_PohybSarze.save;

                                                                mRow := mHead.Rows.AddNewObject;
                                                                   mRow.Prefill;     // nová skladová karta
                                                                   mquantity:=NxIBStrToFloat(mvalue.Strings[5]);
                                                                   mRow.SetFieldValueAsInteger('RowType',3);
                                                                   mRow.SetFieldValueAsString('Store_ID',mstore_id);
                                                                   mRow.SetFieldValueAsString('StoreCard_ID',mvalue.Strings[0]);
                                                                   mRow.SetFieldValueAsstring('Division_ID','1N00000101');
                                                                   mRow.SetFieldValueAsstring('X_note',mvalue.Strings[2] + ';' +mvalue.Strings[3] + ';' +mvalue.Strings[4]);
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

                                                                      //                mBO_MonikerBatches:=mRow.GetLoadedCollectionMonikerForFieldCode(mRow.GetFieldCode('DocRowBatches'));
                                                                      //                      mBatch:=mBO_MonikerBatches.AddNewObject;
                                                                      //                      mBatch.Prefill;
                                                                      //                      mBatchquantity:= NxIBStrToFloat(mvalue.Strings[5]);
                                                                      //                      mBatch.SetFieldValueAsstring('StoreBatch_ID',mvalue.Strings[1]);
                                                                      //                      mBatch.SetFieldValueAsFloat('Quantity',NxIBStrToFloat(mvalue.Strings[5]));

                                                                       mBO_PohybSarze.new;
                                                                                    mBO_PohybSarze.Prefill;
                                                                                    mBatchquantity:= NxIBStrToFloat(mvalue.Strings[5]);
                                                                                    mBO_PohybSarze.SetFieldValueAsstring('Code',mhead.OID);
                                                                                    mBO_PohybSarze.SetFieldValueAsstring('X_Parent_ID',mRow.OID);
                                                                                    mBO_PohybSarze.SetFieldValueAsstring('X_Firm_ID',mfirm_id);
                                                                                    mBO_PohybSarze.SetFieldValueAsstring('X_Parent2_ID',mRow.GetFieldValueAsString('Storecard_ID'));
                                                                                    mBO_PohybSarze.SetFieldValueAsstring('X_Batches',mvalue.Strings[1]);
                                                                                    mBO_PohybSarze.SetFieldValueAsstring('Name', copy(mRow.GetFieldValueAsString('Storecard_ID.name'),1,30));
                                                                                    mBO_PohybSarze.SetFieldValueAsFloat('X_quantity', mBatchquantity);




                                                         end else begin  // stejná skladová karta
                                                                    mquantity:=mquantity + NxIBStrToFloat(mvalue.Strings[5]);
                                                                          if copy(mlist.Strings[i],1,22)<>copy(mlist.Strings[i-1],1,22) then begin // rozdílná šarže

                                                                                        mBO_PohybSarze.SetFieldValueAsfloat('X_quantity',mBatchquantity)  ;
                                                                                        mBO_PohybSarze.save;
                                                                                        //xxx
                                                                                        //    mBO_MonikerBatches:=mRow.GetLoadedCollectionMonikerForFieldCode(mRow.GetFieldCode('DocRowBatches'));
                                                                                        //    mBatch:=mBO_MonikerBatches.AddNewObject;
                                                                                        //    mBatch.Prefill;
                                                                                        //    mBatchquantity:= NxIBStrToFloat(mvalue.Strings[5]);
                                                                                        //    mBatch.SetFieldValueAsstring('StoreBatch_ID',mvalue.Strings[1]);
                                                                                        //    mBatch.SetFieldValueAsfloat('Quantity',NxIBStrToFloat(mvalue.Strings[5]));
                                                                                    mBO_PohybSarze.new;
                                                                                    mBO_PohybSarze.Prefill;
                                                                                    mBatchquantity:= NxIBStrToFloat(mvalue.Strings[5]);
                                                                                    mBO_PohybSarze.SetFieldValueAsstring('Code',mhead.OID);
                                                                                    mBO_PohybSarze.SetFieldValueAsstring('X_Parent_ID',mRow.OID);
                                                                                    mBO_PohybSarze.SetFieldValueAsstring('X_Firm_ID',mfirm_id);
                                                                                    mBO_PohybSarze.SetFieldValueAsstring('X_Parent2_ID',mRow.GetFieldValueAsString('Storecard_ID'));
                                                                                    mBO_PohybSarze.SetFieldValueAsstring('X_Batches',mvalue.Strings[1]);
                                                                                    mBO_PohybSarze.SetFieldValueAsstring('Name', copy(mRow.GetFieldValueAsString('Storecard_ID.name'),1,30));
                                                                                    mBO_PohybSarze.SetFieldValueAsFloat('X_quantity', mBatchquantity);




                                                                         end else begin   // stejná šarže
                                                                              mBatchquantity:=mBatchquantity+NxIBStrToFloat(mvalue.Strings[5]);
                                                                         end;

                                                         end;


                                            end;
                                       finally
                                           mvalue.free;
                                       end;
                                    end;

                                    mRow.SetFieldValueAsFloat('Quantity',mquantity);   // uložení na konci dokladu
                                         //mBatch.SetFieldValueAsfloat('X_quantity',mBatchquantity)  ;
                                         mBO_PohybSarze.SetFieldValueAsFloat('X_quantity', mBatchquantity);
                                         mBO_PohybSarze.save;


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
                                                 mSite.ShowDynFormWithNewDocument('GF53HAH3WBDL3C5P00CA141B44', mSite.SiteContext, mhead);             //                       B50I5SAOS3DL3ACU03KIU0CLP4

                                          end else begin
                                                //mhead.Save;
                                                //mSite.ShowDynFormWithNewDocument('O2XDU14IW3DL342X01C0CX3FCC', mSite.SiteContext, mhead);
                                                //NxShowSimpleMessage('Objednávka přijatá ' + mhead.GetFieldValueAsString('displayname')  ,nil);               //         B50I5SAOS3DL3ACU03KIU0CLP4
                                                mhead.save;
                                                mID_sourdce_doc:=mhead.oid;
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


{ if mID_sourdce_doc<>'' then begin

      mManager := NxCreateDocumentImportManager(msite.BaseObjectSpace,'E32A1GVWPYY4BJZFV5NFSRAODW','JFQYSEOTKPC4RAMLQVLUK5NV34');   // op to fv

                mParams := TNxParameters.Create();
                try
                  mManager.AddInputDocument(mID_sourdce_doc);
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
                        if mRowsOutput.BusinessObject[ii].getFieldValueAsstring('Storecard_ID')<>copy(mRowsOutput.BusinessObject[ii].getFieldValueAsstring('X_note'),1,10) then begin
                                 mRowsOutput.BusinessObject[ii].SetFieldValueAsstring('Storecard_ID',copy(mRowsOutput.BusinessObject[ii].getFieldValueAsstring('X_note'),1,10));
                        end;
                                 mBO_MonikerBatches:=mRowsOutput.BusinessObject[ii].GetLoadedCollectionMonikerForFieldCode(mRowsOutput.BusinessObject[ii].GetFieldCode('DocRowBatches'));
                                           mBO_Batch:=mBO_MonikerBatches.AddNewObject;
                                           //NxShowSimpleMessage( copy(mrow.getFieldValueAsstring('X_note'),12,10),nil);
                                           mBO_Batch.SetFieldValueAsString('StoreBatch_ID',copy(mrow.getFieldValueAsstring('X_note'),12,10));
                                           mBO_Batch.SetFieldValueAsFloat('Quantity',1);
                                           mBO_Batch.SetFieldValueAsString('QUnit',mrow.getFieldValueAsString('qunit'));
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

        }










end;






function CorrectBatch(OS: TNxCustomObjectSpace;msite:TDynSiteForm;index:Integer;MBO:TNxCustomBusinessObject) : Boolean;
var
    i,ii,aa:integer;
    mMon:TNxCustomBusinessMonikerCollection;
    mr, mr1:tstringlist;
    mBO_OPDocRowBatches:TNxCustomBusinessObject;
    mOLE, mRoll,mAgenda, mOResult: Variant;
    mr2,mx:TStringList;
    mSelected ,_ss:Variant;
    mstring:string;
begin
     mBO_OPDocRowBatches:=os.CreateObject('EC2R2HSFK5UOZ5MYVJWJOHUC4S');
     try
     mMon := mbo.GetLoadedCollectionMonikerForFieldCode(mbo.GetFieldCode('ROWS'));
                             for i := 0 to mMon.Count - 1 do begin

                                  mr:=TStringList.create ;
                                  try
                                     os.sqlselect('SELECT a.id FROM DefRollData A WHERE (A.Hidden = ' + quotedstr('N') + ' ) AND (A.CLSID = ' + quotedstr('EC2R2HSFK5UOZ5MYVJWJOHUC4S') + ' ) AND (Upper(A.X_Parent_ID)=' + quotedstr(mMon.BusinessObject[i].oid) + ')'
                                                  ,mr);
                                     if mr.count>0 then begin
                                         for ii:=0 to mr.count-1 do begin
                                              mBO_OPDocRowBatches.load(mr.Strings[ii],nil);
                                                  mr1:=tstringlist.create;
                                                  try
                                                               os.sqlselect('select sum(quantity) from StoreSubBatches where Store_ID='+ quotedstr(mMon.BusinessObject[i].GetFieldValueAsString('Store_ID')) + ' and StoreBatch_ID=' + QuotedStr(mBO_OPDocRowBatches.GetFieldValueAsString('X_Batches')),mr1) ;
                                                               //NxShowSimpleMessage(NxFloatToIBStr(mBO_OPDocRowBatches.GetFieldValueAsFloat('X_quantity')) + ' / ' + mr1.Strings[0] , nil);
                                                               if NxIBStrToFloat(mr1.Strings[0])<mBO_OPDocRowBatches.GetFieldValueAsFloat('X_quantity') then begin
                                                                   // není dostatek na šarži  = záměna
                                                                   //NxShowSimpleMessage(NxFloatToIBStr(mBO_OPDocRowBatches.GetFieldValueAsFloat('X_quantity')) + ' / ' + mr1.Strings[0] , nil);

                                                                   mOLE := GetAbraOLEApplication;
                                                                   mroll := mOLE.GetAgenda('A1TAS3OJNGU4HE5WCEMWHOQDFO');
                                                                   mSelected := mOLE.CreateStrings;
                                                                   mr2:=TStringList.create;
                                                                      try
                                                                            os.SQLSelect('SELECT ssb.id FROM StoreSubBatches SSB where ssb.Store_ID=' + quotedstr(mMon.BusinessObject[i].GetFieldValueAsString('Store_ID'))
                                                                                                      + ' and (ssb.StoreCard_ID='+ quotedstr(mBO_OPDocRowBatches.GetFieldValueAsString('X_Batches.StoreCard_ID')) + ') and (ssb.quantity>0)  and (ssb.id<>' + quotedstr(mBO_OPDocRowBatches.GetFieldValueAsString('X_Batches')) + ')' ,mr2);
                                                                             for aa := 0 to mr2.Count - 1 do begin
                                                                                 mSelected.Add(mr2.Strings[aa]);
                                                                             end;
                                                                          if mr2.count>0 then begin
                                                                                mstring:= mroll.SingleSelectFromSelected2(mSelected, 'Náhrada šarže: ' + mBO_OPDocRowBatches.GetFieldValueAsString('X_Batches.name') + ' - , ' +mBO_OPDocRowBatches.GetFieldValueAsString('X_Batches.Storecard_ID.displayname')  , '');

                                                                                if mstring<>'' then begin
                                                                                     mx:= tstringlist.create;
                                                                                     try
                                                                                            os.SQLSelect('SELECT ssb.StoreBatch_ID FROM StoreSubBatches SSB where ssb.ID=' + quotedstr(mstring) ,mx);
                                                                                               //NxShowSimpleMessage('náhrada šarže ' +mBO_OPDocRowBatches.GetFieldValueAsString('X_Batches') + ' za  ' + mx.Strings[0],nil);
                                                                                                 mBO_OPDocRowBatches.setFieldValueAsString('X_Batches',mx.Strings[0]) ;
                                                                                                 mBO_OPDocRowBatches.save;
                                                                                     finally
                                                                                          mx.free;
                                                                                     end;
                                                                                end;
                                                                          end else begin
                                                                                 NxShowSimpleMessage('Pro položku ' +mBO_OPDocRowBatches.GetFieldValueAsString('X_Batches.Storecard_ID.displayname') + ' nejsou na skladě k dispozici žádné šarže-',nil);
                                                                          end;
                                                                      finally
                                                                          mr2.free;
                                                                      end;




                                                               end else begin
                                                                   // je dostatek pro šarži
                                                               end;


                                                  finally
                                                      mr1.free;
                                                  end;
//                                              NxShowSimpleMessage( mBO_OPDocRowBatches.OID,nil);
                                              // kontrola , zda šarže je možná
                                         end;

                                     end;

                                  finally
                                      mr.free;
                                  end;

                             end;
      finally
        mBO_OPDocRowBatches.free;
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
  mquantity:double;
  mBatchquantity:double;
  mlist:tstringlist;
  mFirmOffice_id:string;
  mBO_PohybSarze:TNxCustomBusinessObject;
  mstring:string;
  mvalue:tstringlist;
  mBoolean:Boolean;
  mStoreBatch_ID:string;
begin

//NxShowSimpleMessage('Aa',nil);
    if not FileExists(AFileName) then begin
      Result := False;
      exit;
    end;
    mlist:=tstringlist.create;
    try
           if ((index=0) or (index= 1) or (index= 4)) then begin
               mOLE := GetAbraOLEApplication;
               mroll := mOLE.GetAgenda('OFZO2K155FDL3CL100C4RHECN0');
               _ss := mOLE.CreateStrings;
               mstore_ID:= mroll.SingleSelectFromSelected2(_ss, 'Vyber sklad', '');
          //NxShowSimpleMessage('bb',nil);

               mImportFile:=TStringList.create;
               mImportFile.LoadFromFile(AFileName);

               for i:=0 to mImportFile.Count-1 do begin   // načtení souboru
                      //ProgressSetPos(1+NxFloor((i/mImportFile.Count)*99), inttostr(i) +' z '+inttostr(mImportFile.Count));
                      mstringline:= mImportFile.strings[i];
                      if trim(mstringline)<>'' then begin
                          mstring:='';
                          if index=4 then begin
                              mstring:= DecodeBatches(TDynSiteForm(msite).BaseObjectSpace,mstringline);
                          end else begin
                              mstring:= DatamatrixDecodeBatches(TDynSiteForm(msite).BaseObjectSpace,mstringline);
                          end;
                         if (mstring)<>'' then begin
                               mlist.add(mstring)  ;
                         end else begin
                              //if i<>0 then begin
                              //    //mlist.add('XXXXX' + mstringline)  ;
                              //    NxShowSimpleMessage('pro položku ' + mstringline + ' nebylo možné dohledat šarži',nil);
                              ///end;
                              mBoolean:=InputQuery('Nebylo možé dekodovat záznam' , mstringline,mstringline);
                                   if mBoolean then begin
                                        mstring:= DatamatrixDecodeBatches(TDynSiteForm(msite).BaseObjectSpace,mstringline);
                                        if (mstring)<>'' then begin
                                              mlist.add(mstring)  ;
                                        end else begin
                                            NxShowSimpleMessage('Ani oprava se nepodařila , prosím zadejte ručně',nil);
                                        end;
                                   end else begin
                                        NxShowSimpleMessage('Položka bude při importu ignorována , prosím doplňte ručn',nil);
                                   end;
                          end;
                      end;
               end;
           end;

            if index=3 then begin
              try
                  mXMLHead := TNxScriptingXMLWrapper.Create;
                  mXMLHead.loadFromFile(AFileName);
                  ProgressInit(msite, 'Načtení souboru ' + '', 100);
                  for i := 0 to mXMLHead.getElementsCountInArray('Doc.Row') - 1 do begin
                      mr:=TStringList.create;
                         try
                             os.SQLSelect('Select id from stores where code=' + quotedstr(mXMLHead.getElementAsString('Doc.Row[' + inttostr(i) +'].Storecode')),mr);
                             if mr.count>0 then begin
                                   mstore_id:=mr.strings[0];
                             end;
                         finally
                            mr.free;
                         end;

                          mr:=TStringList.create;
                         try
                             os.SQLSelect('Select id from Storecards where EAN=' + quotedstr(mXMLHead.getElementAsString('Doc.Row[' + inttostr(i) +'].Ean')),mr);
                             mStoreCard_ID:='';
                             if mr.count>0 then begin
                                   mStoreCard_ID:=mr.strings[0];
                             end else begin
                                 mStoreCard_ID:='3NQ1000101';
                                 mError:=true;
                             end;
                         finally
                            mr.free;
                         end;

                         for ii:=0 to (mXMLHead.getElementsCountInArray('Doc.Row[' + inttostr(i) +'].batch')) -1 do begin
                            mStoreBatch_ID:='';
                            mQuantity:=0;
                            mr:=TStringList.create;
                                 try
                                     os.SQLSelect('Select id from Storebatches where Name=' + quotedstr(mXMLHead.getElementAsString('Doc.Row[' + inttostr(i) +'].batch['+ inttostr(ii) +'].Name')),mr);
                                     if mr.count>0 then begin
                                           mStoreBatch_ID:=mr.strings[0];
                                     end else begin
                                         mError:=true;
                                     end;
                                 finally
                                    mr.free;
                                 end;
                            mQuantity:=NxIBStrToFloat(mXMLHead.getElementAsString('Doc.Row[' + inttostr(i) +'].batch['+ inttostr(ii) +'].quantity'));

                            mstring:='';
                            mstring:='0000000000' + ';' +  mStorecard_ID + ';' + mStoreBatch_ID+';' + NxFloatToIBStr(mQuantity);
                            if mstring<>'' then mlist.add(mstring)  ;
                         end;
                  end;


                  finally
                      ProgressDispose()   ;
                      mXMLHead.free;
                  end;
              END;    // INDEX 3 XML





          if index<> 4 then begin
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
           end;
//NxShowSimpleMessage('dd',nil);



      mlist.Sort;

      NxShowSimpleMessage('počet položek' + inttostr(mlist.count) , nil);
 mHead := TNxHeaderBusinessObject(OS.CreateObject('CDMK5QAWZZDL342X01C0CX3FCC'));                                       //   dl         050I5SAOS3DL3ACU03KIU0CLP4
 if ((index=0) OR (index= 3) OR (index= 4)) then mBO_PohybSarze:=msite.BaseObjectSpace.CreateObject('EC2R2HSFK5UOZ5MYVJWJOHUC4S');
        try
                     mHead.New;
                     mHead.Prefill;
                              mHead.SetFieldValueAsString('DocQueue_ID', '1540000101');                  // dl
                              if index<> 4 then begin
                                   mHead.SetFieldValueAsString('Firm_ID', mfirm_id);
                                   mHead.SetFieldValueAsString('FirmOffice_ID', mFirmOffice_id);
                              end;

                            mquantity:=0;
                             mBatchquantity:=0;
                            for i:=0 to mlist.count-1 do begin

                               mvalue:=tstringlist.create;
                               try

                                    Parsevalue(mlist.strings[i],';',mlist.strings[i],mvalue,4);


                                    //NxShowSimpleMessage('Položka ' + inttostr(i) , nil);

                                    if i=0 then begin                                   // první záznam



                                              mRow := mHead.Rows.AddNewObject;
                                                           mRow.Prefill;
                                                           mquantity:=NxIBStrToFloat(mvalue.Strings[3]);
                                                           mRow.SetFieldValueAsInteger('RowType',3);
                                                           mRow.SetFieldValueAsString('Store_ID',mstore_id);
                                                           mRow.SetFieldValueAsString('StoreCard_ID',mvalue.Strings[1]);
                                                           mRow.SetFieldValueAsstring('Division_ID','1N00000101');
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
                                                              if ((index=0) or (index=3) or (index=4)) then begin

                                                                              mBO_PohybSarze.new;
                                                                              mBO_PohybSarze.Prefill;
                                                                              mBatchquantity:= NxIBStrToFloat(mvalue.Strings[3]);
                                                                              mBO_PohybSarze.SetFieldValueAsstring('Code',mhead.OID);
                                                                              mBO_PohybSarze.SetFieldValueAsstring('X_Parent_ID',mRow.OID);
                                                                              mBO_PohybSarze.SetFieldValueAsstring('X_Firm_ID',mfirm_id);
                                                                              mBO_PohybSarze.SetFieldValueAsstring('X_Parent2_ID',mRow.GetFieldValueAsString('Storecard_ID'));
                                                                              //NxShowSimpleMessage (copy(mlist.Strings[i-1],23,10),nil);
                                                                              mBO_PohybSarze.SetFieldValueAsstring('X_Batches',mvalue.Strings[2]);
                                                                              mBO_PohybSarze.SetFieldValueAsstring('Name', copy(mRow.GetFieldValueAsString('Storecard_ID.name'),1,30));
                                                               end;

                                    end else begin   // následné záznamy
                                                 if copy(mlist.Strings[i],1,22)<>copy(mlist.Strings[i-1],1,22) then begin // novy pohyb sc
                                                        mRow.SetFieldValueAsFloat('Quantity',mquantity);   // uložení množství do řádku
                                                        if ((index=0) or (index=3) or (index=4)) then begin
                                                            mBO_PohybSarze.SetFieldValueAsfloat('X_quantity',mBatchquantity)  ;
                                                            if (mBO_PohybSarze.getFieldValueAsFloat('X_quantity')>0) and (not NxIsEmptyOID(mBO_PohybSarze.getFieldValueAsstring('X_Batches'))) then  mBO_PohybSarze.save;
                                                        end;


                                                        mRow := mHead.Rows.AddNewObject;
                                                           mRow.Prefill;     // nová skladová karta
                                                           mquantity:=NxIBStrToFloat(mvalue.Strings[3]);
                                                           mRow.SetFieldValueAsInteger('RowType',3);
                                                           mRow.SetFieldValueAsString('Store_ID',mstore_id);
                                                           mRow.SetFieldValueAsString('StoreCard_ID',mvalue.Strings[1]);
                                                           mRow.SetFieldValueAsstring('Division_ID','1N00000101');
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
                                                              if ((index=0) or (index=3) or (index=4)) then begin
                                                                              mBO_PohybSarze.new;
                                                                              mBO_PohybSarze.Prefill;
                                                                              mBatchquantity:= NxIBStrToFloat(mvalue.Strings[3]);
                                                                              mBO_PohybSarze.SetFieldValueAsstring('Code',mhead.OID);
                                                                              mBO_PohybSarze.SetFieldValueAsstring('X_Parent_ID',mRow.OID);
                                                                              mBO_PohybSarze.SetFieldValueAsstring('X_Firm_ID',mfirm_id);
                                                                              mBO_PohybSarze.SetFieldValueAsstring('X_Parent2_ID',mRow.GetFieldValueAsString('Storecard_ID'));
                                                                              mBO_PohybSarze.SetFieldValueAsstring('X_Batches',mvalue.Strings[2]);
                                                                              mBO_PohybSarze.SetFieldValueAsstring('Name', copy(mRow.GetFieldValueAsString('Storecard_ID.name'),1,30));
                                                              end;

                                                 end else begin  // stejná skladová karta
                                                            mquantity:=mquantity + NxIBStrToFloat(mvalue.Strings[3]);
                                                                  if copy(mlist.Strings[i],1,33)<>copy(mlist.Strings[i-1],1,33) then begin // rozdílná šarže
                                                                             if ((index=0) or (index=3) or (index=4)) then begin
                                                                                mBO_PohybSarze.SetFieldValueAsfloat('X_quantity',mBatchquantity)  ;
                                                                                //xxx
                                                                                if (mBO_PohybSarze.getFieldValueAsFloat('X_quantity')>0) and (not NxIsEmptyOID(mBO_PohybSarze.getFieldValueAsstring('X_Batches'))) then  mBO_PohybSarze.save;

                                                                                    mBO_PohybSarze.new;
                                                                                    mBO_PohybSarze.Prefill;
                                                                                    mBatchquantity:= NxIBStrToFloat(mvalue.Strings[3]);
                                                                                    mBO_PohybSarze.SetFieldValueAsstring('Code',mhead.OID);
                                                                                    mBO_PohybSarze.SetFieldValueAsstring('X_Parent_ID',mRow.OID);
                                                                                    mBO_PohybSarze.SetFieldValueAsstring('X_Firm_ID',mfirm_id);
                                                                                    mBO_PohybSarze.SetFieldValueAsstring('X_Parent2_ID',mRow.GetFieldValueAsString('Storecard_ID'));
                                                                                    mBO_PohybSarze.SetFieldValueAsstring('X_Batches',mvalue.Strings[2]);
                                                                                    mBO_PohybSarze.SetFieldValueAsstring('Name', copy(mRow.GetFieldValueAsString('Storecard_ID.name'),1,30));
                                                                                    mBatchquantity:=NxIBStrToFloat(mvalue.Strings[3]);
                                                                                end;
                                                                 end else begin   // stejná šarže
                                                                     if ((index=0) or (index=3) or (index=4)) then mBatchquantity:=mBatchquantity+NxIBStrToFloat(mvalue.Strings[3]);
                                                                 end;

                                                 end;


                                    end;
                               finally
                                   mvalue.free;
                               end;
                            end;

                            mRow.SetFieldValueAsFloat('Quantity',mquantity);   // uložení na konci dokladu
                            if ((index=0) or (index=3) or (index=4)) then begin
                                 mBO_PohybSarze.SetFieldValueAsfloat('X_quantity',mBatchquantity)  ;
                                 if (mBO_PohybSarze.getFieldValueAsFloat('X_quantity')>0) and (not NxIsEmptyOID(mBO_PohybSarze.getFieldValueAsstring('X_Batches'))) then  mBO_PohybSarze.save;
                            end;



                             //ProgressDispose()   ;
                                  //NxShowSimpleMessage('AAA',nil);
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
                                         mSite.ShowDynFormWithNewDocument('GF53HAH3WBDL3C5P00CA141B44', mSite.SiteContext, mhead);             //                       B50I5SAOS3DL3ACU03KIU0CLP4

                                  end else begin
                                        //mhead.Save;
                                        //mSite.ShowDynFormWithNewDocument('O2XDU14IW3DL342X01C0CX3FCC', mSite.SiteContext, mhead);
                                        //NxShowSimpleMessage('Objednávka přijatá ' + mhead.GetFieldValueAsString('displayname')  ,nil);               //         B50I5SAOS3DL3ACU03KIU0CLP4
                                        mhead.save;
                                        //mSite.ShowDynFormWithNewDocument('O2XDU14IW3DL342X01C0CX3FCC', mSite.SiteContext, mhead);

                                  end;



            finally
                 mhead.free;
                if (index=0) or (index=4) then  mBO_PohybSarze.free;
            end;
    Result := True;
 finally
     mlist.free;
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
         { mMAction := Self.GetNewMultiAction;
          mMAction.ShowControl := True;
          mMAction.ShowMenuItem := True;
          mMAction.Hint := 'Import dokladu z datamatrix';
          mMAction.Caption := 'Import dokladu z datamatrix ';
          mMAction.Items.Add('Import OP spotřeba šarže ');
          mMAction.Items.Add('Import OP spotřeba EAN ');
          mMAction.Items.Add('Nahrad problémové EAN ');
          mMAction.Items.Add('Import spotřeby XML ');
          mMAction.Items.Add('Import inventury šarže,množství ');
          mMAction.Category := 'tabList';
          mMAction.OnExecuteItem := @OnExec; }


        {  mMAction := Self.GetNewMultiAction;
          mMAction.ShowControl := True;
          mMAction.ShowMenuItem := True;
          mMAction.Hint := 'decodedatamatrix';
          mMAction.Caption := 'decodedatamatrix ';
          mMAction.Items.Add('decodedatamatrix ');
          mMAction.Category := 'tabList';
          mMAction.OnExecuteItem := @OnExec1;
         }


      {    mMAction := Self.GetNewMultiAction;
          mMAction.ShowControl := True;
          mMAction.ShowMenuItem := True;
          mMAction.Hint := 'Záměna šarží Inventura podklad';
          mMAction.Caption := 'Záměna šarží Inventura podklad';
          mMAction.Category := 'tabList';
          mMAction.OnExecuteItem := @ZAMOnExec;}

end;



procedure zamOnExec(Sender: TComponent;index:integer);
var

  zadej:string;
  mfilename:string;
  mdir,mfile:string;
  mFileList:tstringlist;
  mBoolean:Boolean;
begin
  //mSite := NxFinddySiteForm(Sender);
  msite:=TComponent(Sender).DynSite;
     if ((index<2)) then begin
        if PromptForFileName(mFileName, '*.csv', '', 'Soubory Inventury', '', False) then begin
                      mdir:=copy(mfilename,0,NxCharPosR('\',mfilename));
                      mFile:=copy(mfilename,1+NxCharPosR('\',mfilename),Length(mfilename));
        end;
        zamImportFilex2(TDynSiteForm(mSite).BaseObjectSpace, mfilename, mdir,mfile,msite,true,false,index);
     end;

  TDynSiteForm(mSite).Refreshdata;
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
     if ((index<2) or (index=4)) then begin
        if PromptForFileName(mFileName, '*.csv', '', 'Soubory SP', '', False) then begin
                      mdir:=copy(mfilename,0,NxCharPosR('\',mfilename));
                      mFile:=copy(mfilename,1+NxCharPosR('\',mfilename),Length(mfilename));
        end;
        ImportFilex2(TDynSiteForm(mSite).BaseObjectSpace, mfilename, mdir,mfile,msite,true,false,index);
     end;

     if index=2 then begin
        mBoolean:=CorrectBatch(TDynSiteForm(mSite).BaseObjectSpace,msite,index,TDynSiteForm(mSite).CurrentObject);
     end;

     if index=3 then begin
        if PromptForFileName(mFileName, '*.XML', '', 'Soubory SP', '', False) then begin
                      mdir:=copy(mfilename,0,NxCharPosR('\',mfilename));
                      mFile:=copy(mfilename,1+NxCharPosR('\',mfilename),Length(mfilename));
        end;
        ImportFilex2(TDynSiteForm(mSite).BaseObjectSpace, mfilename, mdir,mfile,msite,true,false,index);
     end;

  TDynSiteForm(mSite).Refreshdata;
end;





begin
end.
