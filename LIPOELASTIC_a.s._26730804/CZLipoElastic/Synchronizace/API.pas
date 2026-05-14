uses '_Knihovny_ALL.Parse',
'_Knihovny_ALL.Komunikace','_GlobalSettings.Konstanty';

//"expr": "NxScript('\''eu.abra.API.Function.Firms.FxFirm_MajorCorrection'\'','\''3UR4000101'\'')"
Const
mManual=true;
mdebug=true;
msource=mSourceAPI + '/';
mTargetDocumentAPI=mTargetAPI + '/';
mTArgetFirm_ID='3010000101';

mSourceCountry='CZ';
mTargetCountry='SK';
mStoreCalc_ID='51A1000101';
mBsentemail=false;
//mSTargetemail='mskacel@lipoelastic.com';
mSTargetemail='kondrickova@lipoelastic.sk;zorlikova@lipoelastic.sk;kdivinska@lipoelastic.sk';

mShowError=false;
mToMSG='SUPER00000';

var
mINovych:integer;
mIUpravenych:integer;
mIKuprave:integer;
mPrintList:tstringlist;
mSDocError:string;



function POST_APIStringImpormanager(AContext: TNxContext; ABody: string; APath: String): string;
var
  mWinHTTP: Variant;
  AOS: TNxCustomObjectSpace;
  mstring:string;
  mr:tstringlist;
  i,x,y,mIRows,mIBatchs,mri: integer;
  iJSONDocuments,iJSONRows,iJSONBatches:integer;
  mQuery:string;
  mInputDocumentClsid,mOutputDocumentClsid,mDocqueue_ID:string;
  AInput,mDocument:TJSONSuperObject;
  mInputDocuments:tstringlist;
  mFindDoc,mFindRow:boolean;
  mParams, mP : TNxParameters;
  mPar : TNxParameter;
  mManager : TNxDocumentImportManager ;
  mRow,mbo, mRow_OP, mOP,mOutputDocument,mBatch,mBO_PohybSarze : TNxCustomBusinessObject;
  mRows, mRows_OP,mRowsOutput,mMonBatches : TNxCustomBusinessMonikerCollection;
  mValidateList,mSelectedRows,mrx:tstringlist;
  mText,mSelectedHeader:string;
  mImportMan: TNxDocumentImportManager;
  mFind:boolean;
  mJSONDocuments,mJSONRows,mJSONBatches: TJSONSuperObjectArray;
  mJSONDocument,mJSONRow,mJSONBatch:TJSONSuperObject;
  mDocuments:string;
  mImportdocuments,mImportRows,mImportBatches,mOtherRows,mOtherBatches:TStringList;
  mStore_ID,mFirm_ID,mDivision_ID:string;
  mpomocpocet,mUseQuantity:double;
  mPomocSarze,mUseSarze:double;
begin
  try
      AInput:=TJSONSuperObject.create;
      AInput:= TJSONSuperObject.ParseString(ABody,true);

         mInputDocumentClsid:=AInput.S['input_document_clsid'];
         mOutputDocumentClsid:=AInput.S['output_document_clsid'];


        mDocQueue_ID:='';
        mr:=TStringList.create;
        try
             AContext.GetObjectSpace.SQLSelect('select id from Docqueues where code=' + quotedstr(AInput.S['DocQueue_Code']) + ' and hidden=' + quotedstr('N') ,mr);
             if mr.count>0 then begin
                 mDocQueue_ID:=mr.Strings[0];
             end;
        finally
            mr.free;
        end;




        mFirm_ID:='';
        mr:=TStringList.create;
        try
             AContext.GetObjectSpace.SQLSelect('select id from firms where name=' + quotedstr(AInput.S['Firm_Name']) + ' and hidden=' + quotedstr('N')
                                             + ' and Firm_id is null',mr);
             if mr.count>0 then begin
                 mFirm_ID:=mr.Strings[0];
             end;
        finally
            mr.free;
        end;

        mStore_ID:='';
        mr:=TStringList.create;
        try
             AContext.GetObjectSpace.SQLSelect('select id from Stores where code=' + quotedstr(AInput.S['Store_Code']) + ' and hidden=' + quotedstr('N') ,mr);
             if mr.count>0 then begin
                 mStore_ID:=mr.Strings[0];
             end;
        finally
            mr.free;
        end;

        mDivision_ID:='';
        mr:=TStringList.create;
        try
             AContext.GetObjectSpace.SQLSelect('select id from Divisions where code=' + quotedstr(AInput.S['Division_Code']) + ' and hidden=' + quotedstr('N') ,mr);
             if mr.count>0 then begin
                 mDivision_ID:=mr.Strings[0];
             end;
        finally
            mr.free;
        end;


  finally

  end;
  mImportdocuments:=TStringList.create;
  mImportRows:=TStringList.create;
  mOtherRows:=TStringList.create;
  mOtherBatches:=TStringList.create;
  mImportBatches:=TStringList.create;
  mSelectedRows:=TstringList.Create;
  mParams := TNxParameters.Create();
  try





      if AInput.A['AbraDocuments'].Length>0 then begin                // v poli jSON jsou uvedeny doklady
          for iJSONDocuments := 0 to AInput.A['AbraDocuments'].Length - 1 do begin  // cyklus dokladu
                   mJSONDocument:=TJSONSuperObject.create;
                  mJSONDocument:= TJSONSuperObject.ParseString(AInput.A['AbraDocuments'].S[iJSONDocuments],true);   // pole dokladu

                 // mImportdocuments.add(mJSONDocument.S['ID']);

                      if mJSONDocument.A['Rows'].Length>0 then begin
                             for iJSONRows := 0 to mJSONDocument.A['Rows'].Length - 1 do begin  // cyklus řádku dokladu
                                mJSONRow:=TJSONSuperObject.create;
                                mJSONRow:= TJSONSuperObject.ParseString(mJSONDocument.A['Rows'].S[iJSONRows],true);    //pole řádku
                                mpomocpocet:=NxIBStrToFloat(mJSONRow.S['Quantity']);
                                mr:=tstringlist.create;
                                try
                                    if mInputDocumentClsid='01CPMINJW3DL342X01C0CX3FCC' then begin
                                            AContext.GetObjectSpace.SQLSelect('Select RO.id,RO2.id,RO2.Store_ID,RO2.Storecard_id,RO2.X_ProvideRow_ID,(ro2.quantity-ro2.DeliveredQuantity)'  //  ,(RO2.quantity-ro2.DeliveredQuantity)
                                                                      + ' from ReceivedOrders2 RO2 left join ReceivedOrders RO on RO.id=RO2.parent_id '
                                                                      + ' where RO2.X_providerow_ID=' + quotedstr(mJSONRow.S['X_ProvideRow_ID'])
                                                                      + ' and RO2.Storecard_ID=' + quotedstr(mJSONRow.S['Storecard_ID'])
                                                                      + ' and RO.Closed=' + quotedstr('N')
                                                                      + ' and RO.IsAvailableForDelivery=' + quotedstr('A')
                                                                      + ' and RO2.quantity>ro2.DeliveredQuantity'
                                                                       ,mr);
                                     end;
                                     if mInputDocumentClsid='CDMK5QAWZZDL342X01C0CX3FCC' then begin
                                            AContext.GetObjectSpace.SQLSelect('Select io.id,io2.id,io2.Store_ID,IO2.Storecard_id,io2.X_ProvideRow_ID,(io2.quantity-io2.DeliveredQuantity)'     //,(io2.quantity-io2.DeliveredQuantity)
                                                                      + ' from issuedorders2 io2 left join Issuedorders IO on io.id=io2.parent_id '
                                                                      + ' where io2.X_providerow_ID=' + quotedstr(mJSONRow.S['X_ProvideRow_ID'])
                                                                      + ' and io2.Storecard_ID=' + quotedstr(mJSONRow.S['Storecard_ID'])
                                                                      + ' and io.Closed=' + quotedstr('N')
//                                                                      + ' and io.IsAvailableForDelivery=' + quotedstr('A')
                                                                      + ' and io2.quantity>io2.DeliveredQuantity'
                                                                       ,mr);
                                     end;


                                    if mr.count> 0 then begin

                                         for mri:=0 to mr.count-1 do begin

                                                 if mpomocpocet>0 then begin

                                                           if mpomocpocet>=NxIBStrToFloat(copy(mr.Strings[mri],56,10))  then begin
                                                                          mUseQuantity:=0;
                                                                          mUseQuantity:=NxIBStrToFloat(copy(mr.Strings[mri],56,10));
                                                                          mImportRows.add(mr.Strings[mri] +';'+ NxFloatToIBStr(mUseQuantity) ) ;
                                                                          mpomocpocet:=mpomocpocet-mUseQuantity;
                                                           end else begin
                                                                          mUseQuantity:=0;
                                                                          mUseQuantity:=mPomocPocet;
                                                                          mImportRows.add(mr.Strings[mri] +';'+ (NxFloatToIBStr(mpomocpocet)) ) ;
                                                                          mpomocpocet:=mpomocpocet-mpomocpocet;
                                                           end;



                                                           result:=result+ chr(10) + chr(13) +  'Počet' + ' : ' +NxFloatToIBStr(mUseQuantity);


                                                           if mJSONRow.A['docrowbatches'].Length>0 then begin
                                                               for iJSONBatches := 0 to mJSONRow.A['docrowbatches'].Length - 1 do begin  // cyklus řádku dokladu
                                                                  mJSONBatch:=TJSONSuperObject.create;
                                                                  mJSONBatch:= TJSONSuperObject.ParseString(mJSONRow.A['docrowbatches'].S[iJSONBatches],true);    //pole šarže
                                                                  mPomocSarze:=NxIBStrToFloat(mJSONBatch.S['Quantity']);
                                                                  mrx:=tstringlist.create;
                                                                  try
                                                                       AContext.GetObjectSpace.SQLSelect('Select id from StoreBatches where name=' + quotedstr(mJSONBatch.S['Name']) + ' and Storecard_ID=' + QuotedStr(mJSONRow.S['Storecard_ID']),mrx);
                                                                       if mrx.count> 0 then begin

                                                                          if mUseQuantity>=mPomocSarze then begin
                                                                              mImportBatches.add(mJSONRow.S['X_ProvideRow_ID'] + ';' +mJSONRow.S['Storecard_ID']  + ';' + mrx.Strings[0] +';'+NxFloatToIBStr(mPomocSarze));
                                                                          end else begin
                                                                              mImportBatches.add(mJSONRow.S['X_ProvideRow_ID'] + ';' +mJSONRow.S['Storecard_ID']  + ';' + mrx.Strings[0] +';'+NxFloatToIBStr(mUseQuantity));
                                                                          end;




                                                                       end else begin
                                                                            //mImportBatches.add('0000000000' + ';' + 'Založit š.' +';'+mJSONBatch.S['Quantity']);
                                                                       end;

                                                                  finally
                                                                      mrx.free;
                                                                  end;
                                                                  mJSONBatch.free;

                                                               end;
                                                          end;
                                                   end;
                                         end;
                                         if mpomocpocet>0 then begin                          // není možné čerpat
                                                     mOtherRows.add('0000000000' + ';'                  // doklad
                                                        +mJSONRow.S['ID']+ ';'
                                                        +mJSONRow.S['Store_ID']+ ';'
                                                        +mJSONRow.S['Storecard_ID']+ ';'
                                                        +mJSONRow.S['X_ProvideRow_ID']+ ';'                //io2.X_ProvideRow_ID
                                                        +NxFloatToIBStr(mpomocpocet)) ;

                                                        result:=result+ chr(10) + chr(13) +  'Počet' + ' : ' +NxFloatToIBStr(mpomocpocet);

                                                        if mJSONRow.A['docrowbatches'].Length>0 then begin
                                                             for iJSONBatches := 0 to mJSONRow.A['docrowbatches'].Length - 1 do begin  // cyklus řádku dokladu
                                                                mJSONBatch:=TJSONSuperObject.create;
                                                                mJSONBatch:= TJSONSuperObject.ParseString(mJSONRow.A['docrowbatches'].S[iJSONBatches],true);    //pole šarže
                                                                mrx:=tstringlist.create;
                                                                try
                                                                     AContext.GetObjectSpace.SQLSelect('Select id from StoreBatches where name=' + quotedstr(mJSONBatch.S['Name']) + ' and Storecard_ID=' + QuotedStr(mJSONRow.S['Storecard_ID']),mrx);
                                                                     if mrx.count> 0 then begin
                                                                          mOtherBatches.add(mJSONRow.S['X_ProvideRow_ID'] + ';' +mJSONRow.S['Storecard_ID'] + ';' + mrx.Strings[0] +';'+mJSONBatch.S['Quantity']);
                                                                     end else begin
                                                                          //mImportBatches.add('0000000000' + ';' + 'Založit š.' +';'+mJSONBatch.S['Quantity']);
                                                                     end;

                                                                finally
                                                                    mrx.free;
                                                                end;
                                                                mJSONBatch.free;

                                                             end;
                                                        end;













                                         end;
                                    end else begin
                                         mOtherRows.add('0000000000' + ';'                  // doklad
                                                        +mJSONRow.S['ID']+ ';'
                                                        +mJSONRow.S['Store_ID']+ ';'
                                                        +mJSONRow.S['Storecard_ID']+ ';'
                                                        +mJSONRow.S['X_ProvideRow_ID']+ ';'                //io2.X_ProvideRow_ID
                                                        +mJSONRow.S['Quantity']) ;

                                                        result:=result+ chr(10) + chr(13) +  'Počet' + ' : ' +mJSONRow.S['Quantity'];

                                        if mJSONRow.A['docrowbatches'].Length>0 then begin
                                             for iJSONBatches := 0 to mJSONRow.A['docrowbatches'].Length - 1 do begin  // cyklus řádku dokladu
                                                mJSONBatch:=TJSONSuperObject.create;
                                                mJSONBatch:= TJSONSuperObject.ParseString(mJSONRow.A['docrowbatches'].S[iJSONBatches],true);    //pole šarže
                                                mrx:=tstringlist.create;
                                                try
                                                     AContext.GetObjectSpace.SQLSelect('Select id from StoreBatches where name=' + quotedstr(mJSONBatch.S['Name']) + ' and Storecard_ID=' + QuotedStr(mJSONRow.S['Storecard_ID']),mrx);
                                                     if mrx.count> 0 then begin
                                                          mOtherBatches.add(mJSONRow.S['X_ProvideRow_ID'] + ';' +mJSONRow.S['Storecard_ID'] + ';' + mrx.Strings[0] +';'+mJSONBatch.S['Quantity']);
                                                     end else begin
                                                          //mImportBatches.add('0000000000' + ';' + 'Založit š.' +';'+mJSONBatch.S['Quantity']);
                                                     end;

                                                finally
                                                    mrx.free;
                                                end;
                                                mJSONBatch.free;

                                             end;
                                        end;

                                    end;
                                finally
                                    mr.free;
                                end;





                             end;
                      end;
          end;
      end;

{

       mImportdocuments:=TstringList.Create;
              try
                 if AInput.A['InputDocuments'].Length>0 then begin
                  for i := 0 to AInput.A['InputDocuments'].Length - 1 do begin
                         mImportdocuments.Add(AInput.A['InputDocuments'].S[i]);
                  end;
                 end;
              finally
              end;

               mSelectedHeader:=AInput.S['SelectedHeader'];
 }

              try
                  if mImportRows.count>0 then begin
                      for i:=0 to mImportRows.count-1 do begin

                          mfind:=false;   // dohledání Dokladu
                          for x:=0 to mImportdocuments.count-1 do begin
                              if  mImportdocuments.Strings[x]=copy(mImportRows.Strings[i],1,10) then mfind:=true;
                          end;
                          if not mFind then mImportdocuments.add(copy(mImportRows.Strings[i],1,10)) ;


                          mfind:=false;   // dohledání řádku
                          for x:=0 to mSelectedRows.count-1 do begin
                              if  mSelectedRows.Strings[x]=copy(mImportRows.Strings[i],12,10) then mfind:=true;
                          end;
                          if not mFind then mSelectedRows.add(copy(mImportRows.Strings[i],12,10));


                      end;
                  end;
              finally

              end;











             if mImportdocuments.count>0 then begin     // import dokladu
                                  mImportMan := NxCreateDocumentImportManager(AContext.GetObjectSpace, mInputDocumentClsid, mOutputDocumentClsid);
                                      try
                                         if mImportdocuments.count>0 then begin
                                            for i:=0 to mImportdocuments.count-1 do begin
                                                mImportMan.AddInputDocument(mImportdocuments.Strings[i]);
                                            end;
                                          end;

                                         if trim(mSelectedHeader)='' then begin
                                             if mInputDocuments.count>1 then mParams.GetOrCreateParam(dtString, 'SelectedHeader').AsString := mImportdocuments.Strings[0];
                                         end else begin
                                             mParams.GetOrCreateParam(dtString, 'SelectedHeader').AsString := AInput.S['SelectedHeader'];
                                         end;

                                         if mDocQueue_ID<>'' then mParams.GetOrCreateParam(dtString, 'DocQueue_ID').AsString := mDocQueue_ID;

                                         if mSelectedRows.count>0 then mParams.GetOrCreateParam(dtString, 'SelectedRows').AsString := mSelectedRows.Text;

                                    //      mParams.GetOrCreateParam(dtBoolean, 'ImportBatches').AsBoolean := True;

                                         mImportMan.LoadParams(mParams);
                                         mImportMan.Execute;

                                         mOutputDocument:=mImportMan.OutputDocument;

                                         mRowsOutput := mOutputDocument.GetLoadedCollectionMonikerForFieldCode(mOutputDocument.GetFieldCode('Rows'));
                                         for mIRows:=0 to mRowsOutput.Count-1 do begin
                                              if mStore_ID='' then mStore_ID:=mRowsOutput.BusinessObject[mIRows].GetFieldValueAsString('Store_ID');
                                              if mDivision_ID='' then mDivision_ID:=mRowsOutput.BusinessObject[mIRows].GetFieldValueAsString('Division_ID');
                                              mMonBatches :=  mRowsOutput.BusinessObject[mIRows].GetLoadedCollectionMonikerForFieldCode( mRowsOutput.BusinessObject[mIRows].GetFieldCode('DocRowBatches'));
                                              if mMonBatches.count>0 then begin
                                                    for mIBatchs := 0 to mMonBatches.Count - 1 do begin
                                                        mMonBatches.BusinessObject[mIBatchs].MarkForDelete;
                                                    end;
                                              end;
                                         end;



                                         mRowsOutput := mOutputDocument.GetLoadedCollectionMonikerForFieldCode(mOutputDocument.GetFieldCode('Rows'));
                                         for mIRows:=0 to mRowsOutput.Count-1 do begin
                                                        for i:=0 to mImportRows.count-1 do begin
                                                            if mRowsOutput.BusinessObject[mIRows].GetFieldValueAsString('X_provideRow_ID')=copy(mImportRows.strings[i],45,10) then begin
                                                                   mRowsOutput.BusinessObject[mIRows].setFieldValueAsFloat('Quantity',NxIBStrToFloat(copy(mImportRows.strings[i],56,10)));
                                                                    // Result:=result + chr(10) + chr(13) + '   ' +copy(mImportRows.strings[i],56,10);
                                                                      //result:=  result + copy(mImportBatches.Strings[mIBatchs],1,10) + '   '+ copy(mImportBatches.Strings[mIBatchs],12,10) + '    '+copy(mImportBatches.Strings[mIBatchs],23,10);
                                                                          if mRowsOutput.BusinessObject[mIRows].GetFieldValueAsinteger('StoreCard_ID.category')=2 then begin
                                                                                 if mOutputDocumentClsid='01CPMINJW3DL342X01C0CX3FCC' then begin   // op
                                                                                 // op
                                                                                      for mIBatchs := 0 to mImportBatches.Count - 1 do begin
                                                                                                  mBO_PohybSarze:=AContext.GetObjectSpace.CreateObject('SLARSB0H4CK4T32XPZTP33J3XS');
                                                                                                     try
                                                                                                            mBO_PohybSarze.new;
                                                                                                            mBO_PohybSarze.Prefill;
                                                                                                            mBO_PohybSarze.SetFieldValueAsFloat('X_quantity',NxIBStrToFloat(copy(mImportBatches.Strings[mIBatchs],23,10)));
                                                                                                            mBO_PohybSarze.SetFieldValueAsstring('Code',mOutputDocument.OID);
                                                                                                            mBO_PohybSarze.SetFieldValueAsstring('X_Parent_ID',mRowsOutput.BusinessObject[mIRows].OID);
                                                                                                            mBO_PohybSarze.SetFieldValueAsstring('X_Firm_ID',mOutputDocument.GetFieldValueAsString('Firm_ID'));
                                                                                                            mBO_PohybSarze.SetFieldValueAsstring('X_Parent2_ID',mRowsOutput.BusinessObject[mIRows].GetFieldValueAsString('Storecard_ID'));
                                                                                                            mBO_PohybSarze.SetFieldValueAsstring('X_Batches',copy(mImportBatches.Strings[mIBatchs],12,10));
                                                                                                            mBO_PohybSarze.SetFieldValueAsstring('Name', copy(mRowsOutput.BusinessObject[mIRows].GetFieldValueAsString('Storecard_ID.name'),1,40));
                                                                                                            //mBO_PohybSarze.SetFieldValueAsstring('Code',mMon.BusinessObject[i].GetFieldValueAsString('Storecard_ID.Code'));
                                                                                                     finally
                                                                                                         mBO_PohybSarze.free;
                                                                                                     end;
                                                                                      end;
                                                                                 end;
                                                                                 if mOutputDocumentClsid='CDMK5QAWZZDL342X01C0CX3FCC' then begin   // ov
                                                                                 //      ov
                                                                                   for mIBatchs := 0 to mImportBatches.Count - 1 do begin
                                                                                        mBO_PohybSarze:=AContext.GetObjectSpace.CreateObject('EC2R2HSFK5UOZ5MYVJWJOHUC4S');
                                                                                                     try
                                                                                                            mBO_PohybSarze.new;
                                                                                                            mBO_PohybSarze.Prefill;
                                                                                                            mBO_PohybSarze.SetFieldValueAsFloat('X_quantity',NxIBStrToFloat(copy(mImportBatches.Strings[mIBatchs],23,10)));
                                                                                                            mBO_PohybSarze.SetFieldValueAsstring('Code',mOutputDocument.OID);
                                                                                                            mBO_PohybSarze.SetFieldValueAsstring('X_Parent_ID',mRowsOutput.BusinessObject[mIRows].OID);
                                                                                                            mBO_PohybSarze.SetFieldValueAsstring('X_Firm_ID',mOutputDocument.GetFieldValueAsString('Firm_ID'));
                                                                                                            mBO_PohybSarze.SetFieldValueAsstring('X_Parent2_ID',mRowsOutput.BusinessObject[mIRows].GetFieldValueAsString('Storecard_ID'));
                                                                                                            mBO_PohybSarze.SetFieldValueAsstring('X_Batches',copy(mImportBatches.Strings[mIBatchs],12,10));
                                                                                                            mBO_PohybSarze.SetFieldValueAsstring('Name', copy(mRowsOutput.BusinessObject[mIRows].GetFieldValueAsString('Storecard_ID.name'),1,40));
                                                                                                            //mBO_PohybSarze.SetFieldValueAsstring('Code',mMon.BusinessObject[i].GetFieldValueAsString('Storecard_ID.Code'));
                                                                                                     finally
                                                                                                         mBO_PohybSarze.free;
                                                                                                     end;

                                                                                  end;

                                                                                 end;

                                                                                 if ((mOutputDocumentClsid<>'CDMK5QAWZZDL342X01C0CX3FCC')) then begin   // stredocuments
                                                                                      mMonBatches :=  mRowsOutput.BusinessObject[mIRows].GetLoadedCollectionMonikerForFieldCode( mRowsOutput.BusinessObject[mIRows].GetFieldCode('DocRowBatches'));
                                                                                          for mIBatchs := 0 to mImportBatches.Count - 1 do begin

                                                                                               if copy(mImportBatches.Strings[mIBatchs],1,10)=mRowsOutput.BusinessObject[mIRows].GetFieldValueAsString('X_provideRow_ID') then begin
                                                                                                   //result:= result +  copy(mImportBatches.Strings[mIBatchs],1,10) + '   '+ copy(mImportBatches.Strings[mIBatchs],12,10) + '    '+copy(mImportBatches.Strings[mIBatchs],23,10);
                                                                                                   mBatch:=mMonBatches.AddNewObject;
                                                                                                   mBatch.Prefill;
                                                                                                   mBatch.SetFieldValueAsString('StoreBatch_ID',copy(mImportBatches.Strings[mIBatchs],23,10));
                                                                                                   mBatch.SetFieldValueAsFloat('Quantity',NxIBStrToFloat(copy(mImportBatches.Strings[mIBatchs],34,10)));
                                                                                                   mBatch.SetFieldValueAsString('Qunit',mRowsOutput.BusinessObject[mIRows].GetFieldValueAsstring('Qunit'));
                                                                                                  // Result:=result + '   ' +(copy(mImportBatches.Strings[mIBatchs],34,10));
                                                                                               end;

                                                                                          end;
                                                                                 end;
                                                                           end;

                                                            end;

                                                        end;
                                         end;

                                   finally
                                       mParams.free;
                                       mImportMan.free;
                                   end;



             end else begin
                                mOutputDocument:=AContext.GetObjectSpace.CreateObject(mOutputDocumentClsid);
                                mOutputDocument.new;
                                mOutputDocument.prefill;
                                mOutputDocument.setfieldvalueasstring('Docqueue_ID',mDocqueue_ID);
                                mOutputDocument.setfieldvalueasstring('Firm_ID',mFirm_ID);
                                mRowsOutput := mOutputDocument.GetLoadedCollectionMonikerForFieldCode(mOutputDocument.GetFieldCode('Rows'));
           end;


           if mOtherRows.count>0 then begin
                      for i:=0 to mOtherRows.count-1 do begin
                            mRow := mRowsOutput.AddNewObject;
                            mrow.Prefill;
                            if mOutputDocumentClsid<>'E03ZNUMDTCC4PDAUIEY1MBTJC0' then mrow.SetFieldValueAsInteger('Rowtype',3);
                            mrow.SetFieldValueAsString('Store_ID',mstore_ID);
                            mrow.SetFieldValueAsString('Storecard_ID',copy(mOtherRows.strings[i],34,10));
                            mrow.SetFieldValueAsString('X_ProvideRow_ID',copy(mOtherRows.strings[i],45,10));
                            mrow.SetFieldValueAsFloat('Quantity',NxIBStrToFloat(copy(mOtherRows.strings[i],56,10)));
                            mrow.SetFieldValueAsString('Division_ID',mDivision_ID);

                           // Result:=result + chr(10) + chr(13) + '   ' +copy(mOtherRows.strings[i],56,10);

                            if mrow.GetFieldValueAsinteger('StoreCard_ID.category')=2 then begin
                                                                                 if mOutputDocumentClsid='01CPMINJW3DL342X01C0CX3FCC' then begin   // op

                                                                                 end;
                                                                                 if mOutputDocumentClsid='CDMK5QAWZZDL342X01C0CX3FCC' then begin   // ov

                                                                                 end;



                                                                                 if ((mOutputDocumentClsid<>'01CPMINJW3DL342X01C0CX3FCC') AND (mOutputDocumentClsid<>'CDMK5QAWZZDL342X01C0CX3FCC')) then begin   // stredocuments
                                                                                      mMonBatches :=  mrow.GetLoadedCollectionMonikerForFieldCode(mrow.GetFieldCode('DocRowBatches'));
                                                                                          for mIBatchs := 0 to mOtherBatches.Count - 1 do begin
                                                                                               if (copy(mOtherBatches.Strings[mIBatchs],1,10)=mrow.GetFieldValueAsString('X_provideRow_ID')) and
                                                                                                  (copy(mOtherBatches.Strings[mIBatchs],12,10)=mrow.GetFieldValueAsString('Storecard_ID'))
                                                                                                then begin
                                                                                                   mBatch:=mMonBatches.AddNewObject;
                                                                                                   mBatch.Prefill;
                                                                                                   mBatch.SetFieldValueAsString('StoreBatch_ID',copy(mOtherBatches.Strings[mIBatchs],23,10));
                                                                                                   mBatch.SetFieldValueAsFloat('Quantity',NxIBStrToFloat(copy(mOtherBatches.Strings[mIBatchs],34,10)));
                                                                                                   mBatch.SetFieldValueAsString('Qunit',mrow.GetFieldValueAsstring('Qunit'));
                                                                                           //    Result:=result + '   ' +(copy(mOtherBatches.Strings[mIBatchs],34,10));
                                                                                               end;

                                                                                          end;
                                                                                 end;
                                                                           end;
                             end;


                   end;




                mOutputDocument.SetFieldValueAsString('DocQueue_ID',mDocQueue_ID);
                if mFirm_ID<>'' then mOutputDocument.SetFieldValueAsString('Firm_ID',mFirm_ID);


                mOutputDocument.Save;
            //     result:=mOutputDocument.oid  +';'+ mOutputDocument.DisplayName   ;

                  result:=result+ chr(10) + chr(13) + 'Dokument : ' +  mImportdocuments.strings[0] + chr(10) + chr(13) + 'Importovane radky :' +  inttostr(mImportRows.count)   +
                  chr(10) + chr(13) + ' Ostatní radky :' +  inttostr(mOtherRows.count)

              // result:=inttostr(mImportBatches.count);





  finally
          mImportdocuments.free;
          mImportRows.free;
          mOtherRows.free;
          mOtherBatches.free;
          mImportBatches.free;
          mSelectedRows.free;
          mParams.free;
  end;



end;














Function CheckDocumentStorecard(mBO:TNxCustomBusinessObject; mtarget:string) :string;
var
mMonRows:TNxCustomBusinessMonikerCollection;
mString:string;
mhead:TNxHeaderBusinessObject;
i:integer;
begin
    mSDocError:='';
    mHead:= TnxHeaderBusinessObject(mbo);    // načtení objektu
                          mMonRows := mHead.GetLoadedCollectionMonikerForFieldCode(mHead.GetFieldCode('Rows'));

                          for i := 0 to mMonRows.count - 1 do begin
                                mString:=API_SK_Check_string(mbo.ObjectSpace,'ID','Storecards','code=' + quotedstr(mMonRows.BusinessObject[i].GetFieldValueAsString('Storecard_ID.code')));
                                if Length(mString)=10 then begin
                                    //NxShowSimpleMessage('  dohledáno ' + mstring,nil);
                                end else begin
                                    mSDocError:=mSDocError + mMonRows.BusinessObject[i].GetFieldValueAsString('Storecard_ID.Displayname') +', ' + chr(10) + chr(13) ;
//                                    NxShowSimpleMessage('Nedohledáno' +  ,nil);
                                end;
                          end;
     result:=mSDocError;
end;



function API_SK_Check_string(os:TNxCustomObjectSpace;mfields:string;mtable:string;mwhere:string):string;
var
mquery:string;
begin

 mQuery:='{';
                                     mQuery:=mQuery +'"Typ": "SELECT",';
                                      mQuery:=mQuery +'"Fields": "'+ mfields + '", ';
                                       mQuery:=mQuery +'"Dotaz": "' + ' from ' + mtable + ' where ' + mwhere + '" } ' ;

          //NxShowSimpleMessage(POST_APISQL_String(NxCreateContext(os),mQuery,''),nil);



    result:=APICallString(os,'POST',mTargetDocumentAPI +'script/Synchronizace/API/APISQL_string',mQuery, true);
end;


{


 function iSendMailx(AOS : TNxCustomObjectSpace; const ASubject : string; const ABody : string; ATo : string;mS_CopyEmail:string;mS_BccEmail:string; AFrom : string = '';afilename:string;mDivision_ID:string;mBO_source:TNxCustomBusinessObject):string;
var
  mbo,mRecipient : TNxCustomBusinessObject;
  mAttachmentColl: TNxCustomBusinessMonikerCollection ;
  mSL : TStringList;
  i : integer;
  mAttachments: TNxCustomBusinessMonikerCollection;
begin
  result:='';
  mBO := AOS.CreateObject('5C1HWDQDR3J4NAAYZRO5PWHLWK');
  try
    mBO.New;
    mBO.Prefill;
    if not NxIsBlank(AFrom) then
      mBO.SetFieldValueAsString('EmailAccount_ID',AFrom);
        mBO.SetFieldValueAsString('Firm_ID',mbo_source.GetFieldValueAsString('Firm_ID'));
        mBO.SetFieldValueAsString('FirmOffice_ID',mbo_source.GetFieldValueAsString('FirmOffice_ID'));
        mBO.SetFieldValueAsString('Person_ID',mbo_source.GetFieldValueAsString('Person_ID'));
    mBO.SetFieldValueAsString('Subject', ASubject);
    mBO.SetFieldValueAsInteger('BodySavedAs', 1);
    mBO.SetFieldValueAsString('Body', ABody);

    mBO.SetFieldValueAsInteger('SentState', 1);
    mBO.SetFieldValueAsString('Division_ID', mDivision_ID);
    mSL := TStringList.Create;
    try
      NxTokenToStrings(ATO, ';', mSL);
      for i := 0 to mSL.Count - 1 do begin
        mRecipient := mBO.GetCollectionMonikerForFieldCode(mBO.GetFieldCode('Recipients')).AddNewObject;
        mRecipient.SetFieldValueAsInteger('EmailType', 0);
        mRecipient.SetFieldValueAsString('email', mSL.Strings[i]);
      end;
    finally
      mSL.Free;
    end;

    //mSL := TStringList.Create;
    //try
      //NxTokenToStrings(mS_CopyEmail, ';', mSL);
      //for i := 0 to mSL.Count - 1 do begin
    //    mRecipient := mBO.GetCollectionMonikerForFieldCode(mBO.GetFieldCode('Recipients')).AddNewObject;
    //    mRecipient.SetFieldValueAsInteger('EmailType', 1);
    //    mRecipient.SetFieldValueAsString('email', 'archiv@lipoelastic.com');
        //mRecipient.SetFieldValueAsString('email', mSL.Strings[i]);
      //end;
    //finally
    //  mSL.Free;
    //end;

  // mSL := TStringList.Create;
  //  try
  //    NxTokenToStrings(mS_BccEmail, ';', mSL);
  //    for i := 0 to mSL.Count - 1 do begin
        mRecipient := mBO.GetCollectionMonikerForFieldCode(mBO.GetFieldCode('Recipients')).AddNewObject;
        mRecipient.SetFieldValueAsInteger('EmailType', 2);
        mRecipient.SetFieldValueAsString('email', 'archiv@lipoelastic.com');
//        mRecipient.SetFieldValueAsString('email', mSL.Strings[i]);
  //    end;
  //  finally
  //    mSL.Free;
  //  end;

    if (afilename <> '') then begin
          mAttachments := mBO.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('Attachments'));
          TNxEmailSent(mbo).AttachFile(afilename);

    end;



    mbo.save;
   // NxShowSimpleMessage('Vytvořen email: ' + mbo.oid,nil);
    result:=mbo.oid;
 //   mSite.ShowDynForm('KJAGOM3EAOI45GTB45MXJQTD0S', Nil, Nil, False, 'DoEdit;'+mbo.oid);

       // NxShowSimpleMessage('Saved',nil)
    finally
       mbo.free;
    end;
end;



    }

   function GetFileNameBOLog(mBO:TNxCustomBusinessObject;aname:string):string;
var s:string;
begin
        s:=aname;
        s:=NxRemoveDiacritics(s);
                while pos('.',s)>0 do delete(s,pos('.',s),1);
                while pos('/',s)>0 do delete(s,pos('/',s),1);
                while pos('-',s)>0 do delete(s,pos('-',s),1);
                while pos(':',s)>0 do delete(s,pos(':',s),1);
                while pos(',',s)>0 do delete(s,pos(',',s),1);
                while pos(' ',s)>0 do delete(s,pos(' ',s),1);
                while pos('"',s)>0 do delete(s,pos('"',s),1);
                result:=s+'.pdf';
end;


{ function iPrintDocument(Obj:TNxCustomBusinessObject;ADynCLSID:string;ReportID:string;Acontext:TNxContext;mprintlist:TStrings;AName:string):string;
var
        mOLEApp: Variant;
        mCommand: Variant;
        mCond: Variant;
        FName:string;
        mbo: TNxCustomBusinessObject;
        mDynCLSID:string;
begin
        if  NxIsBlank(ADynCLSID) then begin
            mDynCLSID := Obj.DefaultDynSourceID;
        end else begin
            mDynCLSID:=ADynCLSID;
        end;
        try
                mOLEApp := GetAbraOLEApplication;
                        mCommand := mOLEApp.CreateCustomCommand(mDynCLSID);  // ZL
                        mCond := mCommand.ConstraintByID('ID');
                        mCond.UsedKind := 1;
                        mCond.Value := QuotedStr(Obj.OID);
                mCommand.Execute;
        finally
        end;
       try
       // if not (mCommand.RowSets[0].EOF) then
       //         begin
                        FName:=GetFileNameBOLog(Obj,aname);
                        mCommand.Print(ReportID,8,NxGetTempDir,FName);
       //         end;
             //   NxPrintByIDs(Acontext, mPrintList, mDynCLSID, ReportID, rtofile, pekpdf, NxGetTempDir, FName) ;

           // NxShowSimpleMessage('Vytvořen soubor: ' + NxGetTempDir+FName,nil);
                result:=NxGetTempDir+FName;
        finally

        end;
end;

 }


























function APICallRestJSON(mSO: TNxCustomBusinessObject; mTyp: string;mUrl: string;mHead: string;mID: string;TJSONSuperObject:string;mStatus:Boolean):TJSONSuperObject;
var
  mWinHTTP: Variant;
  AOS: TNxCustomObjectSpace;
  mJson: TJSONSuperObject;
begin
  AOS := mSO.ObjectSpace;

    try
         if GetHTTP(mWinHTTP) then begin
              mWinHTTP.Open(mTyp, mUrl +mHead +mid);      //   NxShowSimpleMessage(mTyp + ' - ' +mUrl +mHead +mid + mRequest, nil);
              mWinHTTP.SetRequestHeader('Authorization', 'Basic QVBJX1N5bmNocm9uaXphY2U6YzNsdVkyaHliMjVwZW1GalpRPT0=');
              //    mWinHTTP.SetRequestHeader('Content-Type', 'application/json; charset=CP1250'); //');
              mWinHTTP.SetRequestHeader('Accept', '*/*');
              mWinHTTP.SetRequestHeader('Accept-Encoding', 'gzip, deflate, br');
              mWinHTTP.SetRequestHeader('Connection', 'keep-alive');

              mWinHTTP.Send(mRequest);

              try
                    if mStatus then begin
                           result.S['Status'] := FloatToStr(mWinHTTP.Status);
                           result.S['ResponseText'] := mWinHTTP.ResponseText;
                           result.S['StatusText'] := mWinHTTP.StatusText;
                    end else begin
                          result.S['ResponseText'] := mWinHTTP.ResponseText;
                    end;

              finally
                  mjSON.free;
              end;
         end;
    finally
    end;
end;



procedure iSendmsgx(AOS : TNxCustomObjectSpace;const ASubject : string; const ABody : string; ATo : string; AFrom : string = '');
 var
 mBO,aBO, mRecipient : TNxCustomBusinessObject;
  mSL : TStringList;
  i : integer;
 begin
// aBO:= aos.CreateObject('C3V5QDVZ5BDL342M01C0CX3FCC');
// try
//    abo.load(moid,nil);
        mBO := AOS.CreateObject('33XZARXR1BM4L55MOX54NTRBWG');
            try
                mBO.New;
                mBO.Prefill;
                    mBO.SetFieldValueAsString('SenderUser_ID',AFrom);
                    mBO.SetFieldValueAsString('MsgSubject', ASubject);
                    mBO.SetFieldValueAsString('MsgBody', ABody);
                    mBO.SetFieldValueAsDateTime('validtodate$date',now()+14);
                    mBO.SetFieldValueAsBoolean('DeleteAfterDeletingByAll',True);
                    mBO.SetFieldValueAsBoolean('ConfirmReading',False);
                    mSL := TStringList.Create;
                    try
                        NxTokenToStrings(ATO, ';', mSL);
                        for i := 0 to mSL.Count - 1 do begin
                            mRecipient := mBO.GetCollectionMonikerForFieldCode(mBO.GetFieldCode('Recipients')).AddNewObject;
                            mRecipient.SetFieldValueAsInteger('RecipientType', 0);
                            mRecipient.SetFieldValueAsString('SecurityUser_ID', Ato);
                        end;
                    finally
                        mSL.Free;
                    end;
                mBO.Save;
            finally
                mBO.Free;
            end;
//finally
//        abo.free;
//end;
end;


procedure iSendmsgStavx(AOS : TNxCustomObjectSpace;const ASubject : string; const ABody : string; ATo : string; AFrom : string = '';mStav,mTable,mStorecard_ID,mID:string);
 var
 mBO,aBO, mRecipient : TNxCustomBusinessObject;
  mSL : TStringList;
  i : integer;
 begin
// aBO:= aos.CreateObject('C3V5QDVZ5BDL342M01C0CX3FCC');
// try
//    abo.load(moid,nil);
        mBO := AOS.CreateObject('33XZARXR1BM4L55MOX54NTRBWG');
            try
                mBO.New;
                mBO.Prefill;
                    mBO.SetFieldValueAsString('SenderUser_ID',AFrom);
                    mBO.SetFieldValueAsString('MsgSubject', ASubject);
                    mBO.SetFieldValueAsString('MsgBody', ABody);
                    mBO.SetFieldValueAsDateTime('validtodate$date',now()+14);
                    mBO.SetFieldValueAsBoolean('DeleteAfterDeletingByAll',True);
                    mBO.SetFieldValueAsBoolean('ConfirmReading',False);

                    mBO.SetFieldValueAsString('X_stav', mStav);
                    mBO.SetFieldValueAsString('X_Table', mTable);
                    mBO.SetFieldValueAsString('X_Storecard_ID', mStorecard_ID);
                    mBO.SetFieldValueAsString('X_ID', mID);
                    mSL := TStringList.Create;
                    try
                        NxTokenToStrings(ATO, ';', mSL);
                        for i := 0 to mSL.Count - 1 do begin
                            mRecipient := mBO.GetCollectionMonikerForFieldCode(mBO.GetFieldCode('Recipients')).AddNewObject;
                            mRecipient.SetFieldValueAsInteger('RecipientType', 0);
                            mRecipient.SetFieldValueAsString('SecurityUser_ID', Ato);
                        end;
                    finally
                        mSL.Free;
                    end;
                mBO.Save;
            finally
                mBO.Free;
            end;
//finally
//        abo.free;
//end;
end;

var
mTargetList:TStringList;


function APICallNewValue(mSO: TNxCustomBusinessObject; mTyp: string;mUrl: string;mJSON:string;mStatus:Boolean):string;
var
  mWinHTTP: Variant;
  AOS: TNxCustomObjectSpace;
begin
  AOS := mSO.ObjectSpace;
  try
         if GetHTTP(mWinHTTP) then begin
              mWinHTTP.Open(mTyp, mUrl );
             // NxShowSimpleMessage(mUrl + ' - ' + mJSON, nil);
              mWinHTTP.SetRequestHeader('Authorization', 'Basic QVBJX1N5bmNocm9uaXphY2U6YzNsdVkyaHliMjVwZW1GalpRPT0=');  //    mWinHTTP.SetRequestHeader('Content-Type', 'application/json; charset=CP1250'); //'); //mWinHTTP.SetRequestHeader('Accept', 'application/json; charset=UTF-8');
              mWinHTTP.Send(mJson);
              if mStatus then begin
                    result:= FloatToStr(mWinHTTP.Status) + ' - '+mWinHTTP.ResponseText + ' - ' + mWinHTTP.StatusText ;
              end else begin
                    result:= mWinHTTP.ResponseText;
              end;
        end;
      finally
      end;

end;


function APICallRest(mSO: TNxCustomBusinessObject; mTyp: string;mUrl: string;mHead: string;mID: string;mRequest:string;mStatus:Boolean):string;
var
  mWinHTTP: Variant;
  AOS: TNxCustomObjectSpace;
begin
  AOS := mSO.ObjectSpace;
    try
         if GetHTTP(mWinHTTP) then begin
              mWinHTTP.Open(mTyp, mUrl +mHead +mid);      //   NxShowSimpleMessage(mTyp + ' - ' +mUrl +mHead +mid + mRequest, nil);
              mWinHTTP.SetRequestHeader('Authorization', 'Basic QVBJX1N5bmNocm9uaXphY2U6YzNsdVkyaHliMjVwZW1GalpRPT0=');
              //    mWinHTTP.SetRequestHeader('Content-Type', 'application/json; charset=CP1250'); //');
              mWinHTTP.SetRequestHeader('Accept', '*/*');
              mWinHTTP.SetRequestHeader('Accept-Encoding', 'gzip, deflate, br');
              mWinHTTP.SetRequestHeader('Connection', 'keep-alive');

              mWinHTTP.Send(mRequest);
              if mStatus then begin
                    result:= FloatToStr(mWinHTTP.Status) + ' - '+mWinHTTP.ResponseText + ' - ' + mWinHTTP.StatusText ;
              end else begin
                    result:= mWinHTTP.ResponseText;
              end;
         end;
    finally
    end;
end;












function API_GetOrCreateOVDocRowBatch(mSite:TSiteForm;mApiTArget:string;mDoc_ID:string;mRowBO:TNxCustomBusinessObject;mBatch_ID:String;mquantity:double;index:integer):string;
var
mQueryID:string;
mNewQueryID :string;
mString :string;
mDisplayName:string;
mFirm_ID:string;
mRow_ID:string;
mDocRowBatch_ID:string;
mCLSIDDoc:string;
mCLSIDDocRow:string;
mCLSIDRowBatch:string;
begin
result:='';
mCLSIDDoc:='';
mCLSIDDocRow:='';
mCLSIDRowBatch:='';
mCLSIDDoc:='4K3EXM5PQBCL35CH000ILPWJF4';
mCLSIDDocRow:='CHMK5QAWZZDL342X01C0CX3FCC';
mCLSIDRowBatch:='EC2R2HSFK5UOZ5MYVJWJOHUC4S' ;

         if mBatch_ID<>'' then begin
                  mfirm_ID:='';
 //                 mQueryID:='{ "class": "' + mCLSIDDoc +'", "select": ["Firm_ID",], "where": " ID = ' + QuotedStr(mDoc_ID) +'" }';
 //                  mString:=APICallRest(mRowBO,'Post',mApiTArget,'query','',mQueryID,True);
 //                  //NxShowSimpleMessage('řádek cílového dokladu' + mstring,nil);
 //                  if (copy(mString,1,3)='200')  then begin      // korektní odpověď
 //                         if copy(mString,10,2)='ID' then begin      // záznam namezen
 //                                  mFirm_ID:= copy(mString,15,10);
 //                         end;
 //                  end;

                   mDisplayName:=APICallRest(mRowBO,'GET',mApiTArget,'issuedorders/' + mDoc_ID + '?select=displayname','','',True);
//NxShowSimpleMessage(mDisplayName,nil);
                   mDisplayName:=copy(mDisplayName,19,20);
//NxShowSimpleMessage(mDisplayName,nil);


                  // řádek v cílovém dokladu
                  mQueryID:='{ "class": "' + mCLSIDDocRow +'", "select": ["ID",], "where": " X_ProvideRow_ID = ' + QuotedStr(mRowBO.GetFieldValueAsString('X_ProvideRow_ID')) +' and Storecard_ID=' +  QuotedStr(mRowBO.GetFieldValueAsString('Storecard_ID')) +' and Parent_ID=' +  QuotedStr(mDoc_ID)+'" }';
                   mString:=APICallRest(mRowBO,'Post',mApiTArget,'query','',mQueryID,True);
                   //NxShowSimpleMessage('řádek cílového dokladu' + mstring,nil);
                   if (copy(mString,1,3)='200')  then begin      // korektní odpověď
                          if copy(mString,10,2)='ID' then begin      // záznam namezen
                                   mRow_ID:= copy(mString,15,10);
                                         //NxShowSimpleMessage('ID řádek cílového dokladu' + mRow_ID,nil);
                                         //NxShowSimpleMessage('existující pohyb šarže v cíli'  +  mid,nil);
                                         mQueryID:='{ "class": "' + 'mCLSIDRowBatch' +'", "select": ["ID",], "where": " X_Parent_ID = ' + QuotedStr(mRow_ID) +' and X_batches=' +  QuotedStr(mBatch_ID)+' and Code=' +  QuotedStr(mDoc_ID) + '" }';
                                         mString:=APICallRest(mRowBO,'Post',mApiTArget,'query','',mQueryID,True);
                                         //NxShowSimpleMessage('řádek pohybu šarže' + mstring,nil);
                                                      if (copy(mString,1,3)='200')  then begin      // korektní odpověď
                                                            if copy(mString,10,2)='ID' then begin      // záznam namezen
                                                                  mDocRowBatch_ID:= copy(mString,15,10);
                                                                  result:=mDocRowBatch_ID;
                                                            end else begin
                                                                  mNewQueryID:='{'
                                                                               +'               "Code": "' + mDoc_ID + '", '
                                                                               +'               "X_Parent_ID": "' + mRow_ID + '", '
//                                                                               +'               "X_Firm_ID": "' + mfirm_id + '", '
                                                                               +'               "X_Parent2_ID": "' + mRowBO.GetFieldValueAsString('Storecard_ID') + '", '
                                                                               +'               "X_Storecard_ID": "' + mRowBO.GetFieldValueAsString('Storecard_ID') + '", '
                                                                               +'               "X_Batches": "' + mBatch_ID + '", '
//                                                                               +'               "Name": "' + copy(mDisplayName +' - ' + mRowBO.GetFieldValueAsString('Storecard_ID.Name'),1,40) + '", '
                                                                               +'               "X_quantity": "' + NxFloatToIBStr(mquantity) + '", '
                                                                               +'}';


                                                                                   mString:= APICallRest(mRowBO,'post',mApiTArget,'PohybOV','' ,mNewQueryID,True);
                                                                                 //NxShowSimpleMessage('vytoření pohybu šarže' + mstring,nil);
                                                                                 if (copy(mString,1,3)='201') then begin   // stav založení
                                                                                              mQueryID:='{ "class": "' + mCLSIDRowBatch +'", "select": ["ID",], "where": " X_Parent_ID = ' + QuotedStr(mRow_ID) +' and X_batches=' +  QuotedStr(mBatch_ID) + '" }';

                                                                                              mString:= copy(APICallRest(mRowBO,'Post',mApiTArget,'query','',mQueryID,false),9,10);
                                                                                              if copy(mString,10,2)='ID' then result:= copy(mString,15,10);
                                                                                  end else begin
                                                                                        NxShowSimpleMessage('Chyba v přístupu k api' + mString,nil);
                                                                                        result:='';
                                                                                        exit;
                                                                                  end;
                                                            end;
                                                      end else begin
                                                          NxShowSimpleMessage('Chyba v přístupu k api' + mString,nil);
                                                          result:='';
                                                          exit;
                                                      end;
                          end;
                   end else begin
                        NxShowSimpleMessage('Chyba v přístupu k api' + mString,nil);
                        result:='';
                        exit;
                   end;
         end;


end;


function API_GetOrCreateOPDocRowBatch(mSite:TSiteForm;mApiTArget:string;mDoc_ID:string;mRowBO:TNxCustomBusinessObject;mBatch_ID:String;mquantity:double;index:integer):string;
var
mQueryID:string;
mNewQueryID :string;
mString :string;
mDisplayName:string;
mFirm_ID:string;
mRow_ID:string;
mDocRowBatch_ID:string;
mCLSIDDoc:string;
mCLSIDDocRow:string;
mCLSIDRowBatch:string;
begin
result:='';
mCLSIDDoc:='';
mCLSIDDocRow:='';
mCLSIDRowBatch:='';
mCLSIDDoc:='01CPMINJW3DL342X01C0CX3FCC';
mCLSIDDocRow:='05CPMINJW3DL342X01C0CX3FCC';
mCLSIDRowBatch:='SLARSB0H4CK4T32XPZTP33J3XS' ;



         if mBatch_ID<>'' then begin
  //                mfirm_ID:='';
  //                mQueryID:='{ "class": "' + mCLSIDDoc +'", "select": ["Firm_ID",], "where": " ID = ' + QuotedStr(mDoc_ID) +'" }';
  //                 mString:=APICallRest(mRowBO,'Post',mApiTArget,'query','',mQueryID,True);
  //                 //NxShowSimpleMessage('řádek cílového dokladu' + mstring,nil);
  //                 if (copy(mString,1,3)='200')  then begin      // korektní odpověď
  //                        if copy(mString,10,2)='ID' then begin      // záznam namezen
  //                                 mFirm_ID:= copy(mString,15,10);
  //                        end;
  //                 end;

//try
//                   mDisplayName:=APICallRest(mRowBO,'GET',mApiTArget,'ReceivedOrders/' + mDoc_ID+ '?select=displayname','','',True);
//=DocQueue_ID.Code || '-' || OrdNumber || '/' || Period_ID.Code+as+DisplayName

//                   mDisplayName:=copy(mDisplayName,23,20);
//                   mDisplayName:=copy(mDisplayName,23, AnsiPos('"', mDisplayName));




//NxShowSimpleMessage(mDisplayName,nil);
//NxShowSimpleMessage(mDisplayName,nil);
//finally

//end;

                  // řádek v cílovém dokladu
                  mQueryID:='{ "class": "' + mCLSIDDocRow +'", "select": ["ID",], "where": " posindex=' + inttostr(mRowBO.GetFieldValueAsinteger('Posindex')) +' and Storecard_ID=' +  QuotedStr(mRowBO.GetFieldValueAsString('Storecard_ID')) +' and Parent_ID=' +  QuotedStr(mDoc_ID)+'" }';
                 // mstring:= inputbox('OP - řádek v cílovém dokladu','POST',mApiTArget+'query'+'' + '       ' + mQueryID)    ;
                   mString:=APICallRest(mRowBO,'Post',mApiTArget,'query','',mQueryID,True);


                  // NxShowSimpleMessage('řádek cílového dokladu' + mstring,nil);
                   if (copy(mString,1,3)='200')  then begin      // korektní odpověď
                          //if copy(mString,10,2)='ID' then begin      // záznam namezen
                          if true then begin
                                   mRow_ID:= copy(mString,15,10);
                                         //NxShowSimpleMessage('ID řádek cílového dokladu' + mRow_ID,nil);
                                    //     NxShowSimpleMessage('existující pohyb na řádku OP v cíli - '  +  mRow_ID,nil);
                                         mQueryID:='{ "class": "' + mCLSIDRowBatch +'", "select": ["ID",], "where": " X_Parent_ID = ' + QuotedStr(mRow_ID) +' and X_batches=' +  QuotedStr(mBatch_ID)+' and Code=' +  QuotedStr(mDoc_ID) + '" }';

                                         //mstring:= inputbox('Pohyb šarže OP existující -','POST',mApiTArget+'query'+'' + '       ' + mQueryID)    ;
                                         mString:=APICallRest(mRowBO,'Post',mApiTArget,'query','',mQueryID,True);
                                         //NxShowSimpleMessage('řádek pohybu šarže' + mstring,nil);
                                                      if (copy(mString,1,3)='200')  then begin      // korektní odpověď
                                                            if copy(mString,10,2)='ID' then begin      // záznam namezen
                                                                  mDocRowBatch_ID:= copy(mString,15,10);
                                                                  result:=mDocRowBatch_ID;
                                                            end else begin
                                                                  mNewQueryID:='{'
                                                                               +'               "Code": "' + mDoc_ID + '", '
                                                                               +'               "X_Parent_ID": "' + mRow_ID + '", '
                                                                               +'               "X_Firm_ID": "' + mfirm_id + '", '
                                                                               +'               "X_Parent2_ID": "' + mRowBO.GetFieldValueAsString('Storecard_ID') + '", '
                                                                               +'               "X_Storecard_ID": "' + mRowBO.GetFieldValueAsString('Storecard_ID') + '", '
                                                                               +'               "X_Batches": "' + mBatch_ID + '", '
                                                                               +'               "Name": "' + copy(mDisplayName +' - ' + mRowBO.GetFieldValueAsString('Storecard_ID.Name'),1,40) + '", '
                                                                               +'               "X_quantity": "' + NxFloatToIBStr(mquantity) + '", '
                                                                               +'}';


                                                                                 //   mstring:= inputbox('Založení pohybu šarže -','POST',mApiTArget+'Pohyby_sarzi_OP'+'' + '       ' + mNewQueryID)    ;
                                                                                   mString:= APICallRest(mRowBO,'post',mApiTArget,'Pohyby_sarzi_OP','' ,mNewQueryID,True);


                                                                                 //NxShowSimpleMessage('vytoření pohybu šarže' + mstring,nil);
                                                                                 if (copy(mString,1,3)='201') then begin   // stav založení
                                                                                              mQueryID:='{ "class": "' + mCLSIDRowBatch +'", "select": ["ID",], "where": " X_Parent_ID = ' + QuotedStr(mRow_ID) +' and X_batches=' +  QuotedStr(mBatch_ID) + '" }';

                                                                                              mString:= copy(APICallRest(mRowBO,'Post',mApiTArget,'query','',mQueryID,false),9,10);
                                                                                              //if copy(mString,10,2)='ID' then
                                                                                              result:= copy(mString,15,10);
                                                                                  end else begin
                                                                                        NxShowSimpleMessage('Chyba v přístupu k api' + mString,nil);
                                                                                        result:='';
                                                                                        exit;
                                                                                  end;
                                                            end;
                                                      end else begin
                                                          NxShowSimpleMessage('Chyba v přístupu k api' + mString,nil);
                                                          result:='';
                                                          exit;
                                                      end;
                          end;
                   end else begin
                        NxShowSimpleMessage('Chyba v přístupu k api' + mString,nil);
                        result:='';
                        exit;
                   end;
         end;


end;
function GetDocQueryB(Self:TNxCustomBusinessObject;mDocType_ID,mDocqueue_ID,mFirm_ID,mFirmOffice_ID,mStore_ID,mDivision_ID:string):string;
var
i:integer;
mQuery:string;
mMonRows:TNxCustomBusinessMonikerCollection;
mprice:double;
mX_providerow_ID:string;
mr:tstringlist;
begin

mMonRows := self.GetLoadedCollectionMonikerForFieldCode(self.GetFieldCode('ROWS'));
//          if true then begin // copy(self.GetFieldValueAsString('X_synchronizace_ID'),i+1,1)='1' then begin
                        mQuery:='{'  ;
                        mQuery:=mQuery +'"ID": "' +                                    Self.OID +'", '                                                            ;
                          mQuery:=mQuery +'"Docqueue_ID": "' +                         mDocqueue_ID +'", '                  ;
                          mQuery:=mQuery +'"tradetype": ' +                            IntToStr(2) +', '                  ;
                          mQuery:=mQuery +'"Currency_ID":"' +                         Self.GetFieldValueAsString('Currency_ID') +'", '                  ;
                          mQuery:=mQuery +'"Firm_ID":"'  +                             mFirm_ID +'", '                              ;
                          mQuery:=mQuery +'"Externalnumber":" ' +                      Self.GetFieldValueAsString('Externalnumber') +'", '                  ;
                          //mQuery:=mQuery +'"DocumentDiscount":" ' + NxFloatToIBStr(Self.GetFieldValueAsFloat('DocumentDiscount')) + '", '                  ;

                          mQuery:=mQuery +'"Description": "' +                         Self.GetFieldValueAsString('Description') +'", '                  ;
                          mQuery:=mQuery +'"X_poznamka": "' +                         Self.GetFieldValueAsString('X_poznamka') +'", '                  ;
//                          mQuery:=mQuery +'"Country_ID ": "' +                          Self.GetFieldValueAsString('Country_ID') +'", '                  ;

                          mQuery:=mQuery +'"Country_ID": "00000SK000", '                  ;
                          mQuery:=mQuery +'"IntrastatDeliveryTerm_ID": "1000000101", '                  ;
                          mQuery:=mQuery +'"IntrastatTransactionType_ID": "0101000000", '                  ;
                          mQuery:=mQuery +'"IntrastatTransportationType_ID": "2000000000", '                  ;

                          //NxShowSimpleMessage(copy(mTargetList.strings[i],21,1),nil);

                          mQuery:=mQuery +'"Rows": [  ';
                        for i := 0 to mMonRows.Count-1 do begin
                                        mQuery:=mQuery +'{ ' ;
//                                        mQuery:=mQuery +'"id":"' +                            		  mMonRows.BusinessObject[i].GetFieldValueAsString('ID')+'", '   ;
                                        mQuery:=mQuery +'"PosIndex": ' +                            IntToStr(mMonRows.BusinessObject[i].GetFieldValueAsInteger('Posindex')) +', '                  ;
                                        mQuery:=mQuery +'"Rowtype": ' +                             IntToStr(mMonRows.BusinessObject[i].GetFieldValueAsInteger('Rowtype')) +', '                  ;
                                        mQuery:=mQuery +'"Text":"' +                            		mMonRows.BusinessObject[i].GetFieldValueAsString('Text')+'", ' ;
                                        mQuery:=mQuery +'"Store_ID":"' +                            mStore_ID+'", '   ;
                                        mQuery:=mQuery +'"Storecard_ID":"' +                        mMonRows.BusinessObject[i].GetFieldValueAsString('Storecard_ID')+'", '   ;

                                        mQuery:=mQuery +'"Quantity": ' +                            NxFloatToIBStr(mMonRows.BusinessObject[i].GetFieldValueAsFloat('Quantity')) +', '                  ;

                                        mQuery:=mQuery +'"Qunit":"' +                               mMonRows.BusinessObject[i].GetFieldValueAsString('Qunit')+'", '   ;

//                                        mTargetAPI + '/qrexpr'
//                                      {
//                                            	"expr" : "NxGetStoreCardUnitPriceDef(mfirm_ID,mStore_ID,mMonRows.BusinessObject[i].GetFieldValueAsString('Storecard_ID'),'5100000101',mMonRows.BusinessObject[i].GetFieldValueAsString('Qunit'),False,'0000CZK000',Date)"
//                                        }
                                        // cena z dokladu


                                         mprice:=0  ;
                                        if (mprice=0) then begin
                                             if mMonRows.BusinessObject[i].GetFieldValueAsString('X_providerow_ID')<>'' then begin
                                                    mX_providerow_ID:='';
                                                  try
                                                     mX_providerow_ID:=mMonRows.BusinessObject[i].GetFieldValueAsString('X_providerow_ID');
                                                  finally
                                                  end;


                                                   mr:=tstringlist.create;
                                                   try
                                                      Self.ObjectSpace.SQLSelect('Select ii2.TAmountWithoutVAT/ii2.Quantity  '
                                                            + ' from Issuedinvoices2 ii2 left join storedocuments2 SD2 on sd2.id=ii2.ProvideRow_ID '
                                                            + ' where sd2.X_providerow_ID=' + quotedstr(mMonRows.BusinessObject[i].GetFieldValueAsString('X_Providerow_ID'))
                                                            + ' and sd2.Storecard_ID=' + quotedstr(mMonRows.BusinessObject[i].GetFieldValueAsString('StoreCard_ID'))
                                                             ,mr);

                                                            // if mdebug then begin result:=result + 'Select ii2.unitprice '
                                                            //                  + ' from Issuedinvoices2 ii2 left join storedocuments2 SD2 on sd2.id=ii2.ProvideRow_ID '
                                                            //                  + ' where sd2.X_providerow_ID=' + quotedstr(quotedstr(mMonRows.BusinessObject[i].GetFieldValueAsString('X_Providerow_ID')))
                                                            //                  + ' and sd2.Storecard_ID=' + quotedstr(mMonRows.BusinessObject[i].GetFieldValueAsString('StoreCard_ID')) + chr(10);
                                                            //end;

                                                        if mr.count>0 then begin
                                                            mprice:=  NxIBStrToFloat(mr.Strings[0]);                                // cena z faktury
                                                        end;
                                                   finally
                                                       mr.free;
                                                   end;
                                             end;
                                          end;

                                        if mprice=0 then begin
                                           mprice:=NxEvalObjectExprAsFloatDef(Self,'NxGetStoreCardUnitPriceDef('+Quotedstr(self.GetFieldValueAsString('Firm_ID'))+', '
                                                                                                                  +Quotedstr(mMonRows.BusinessObject[i].GetFieldValueAsString('Store_ID'))+', '
                                                                                                                  +QuotedStr(mMonRows.BusinessObject[i].GetFieldValueAsString('StoreCard_ID')) + ','
                                                                                                                  +Quotedstr(self.GetFieldValueAsString('Firm_ID.Price_ID'))+', '
                                                                                                                  +Quotedstr(mMonRows.BusinessObject[i].GetFieldValueAsString('Qunit'))+',False,'
                                                                                                                  +QuotedStr(self.GetFieldValueAsString('Firm_ID.Price_ID.Currency_ID'))+','
                                                                                                                  +inttostr(trunc(Date))+')',0);
                                         end;

                                    if mprice=0 then begin

                                        mprice:= mMonRows.BusinessObject[i].GetFieldValueAsFloat('UnitPrice');

                                    end;



                                        mQuery:=mQuery +'"UnitPrice": ' +                           NxFloatToIBStr(mprice) +', '                  ;
                                        mQuery:=mQuery +'"TotalPrice": ' +                          NxFloatToIBStr(mprice * mMonRows.BusinessObject[i].GetFieldValueAsFloat('quantity')) +', '                  ;








                                        //mQuery:=mQuery +'"TAmount": ' +                             NxFloatToIBStr(mMonRows.BusinessObject[i].GetFieldValueAsFloat('TAmountWithoutVAT')) +', '                  ;
                                        //mQuery:=mQuery +'"TAmountWithoutVAT": ' +                   NxFloatToIBStr(mMonRows.BusinessObject[i].GetFieldValueAsFloat('TAmountWithoutVAT')) +', '    ;
                                        mQuery:=mQuery +'"Division_ID":"' +                         mDivision_ID+'", '   ;
                                        mQuery:=mQuery +'"BusOrder_ID":"' +                         mMonRows.BusinessObject[i].GetFieldValueAsString('BusOrder_ID')+'", '   ;
                                        mQuery:=mQuery +'"BusTransaction_ID":"' +                   mMonRows.BusinessObject[i].GetFieldValueAsString('BusTransaction_ID')+'", '   ;
                                        mQuery:=mQuery +'"BusProject_ID":"' +                       mMonRows.BusinessObject[i].GetFieldValueAsString('BusProject_ID')+'", '   ;
                                        mQuery:=mQuery +'"X_ProvideRow_ID":"' +                   mMonRows.BusinessObject[i].GetFieldValueAsString('X_ProvideRow_ID')+'", '   ;



                                        mQuery:=mQuery +' }, ';

                        end;
                               mQuery:=mQuery +' ] ';

                              mQuery:=mQuery +' } ';


//                      end;


    result:=mQuery;
end;







function Parsevalue1( AData : string; ASeparator: string): tstringlist;
// rozdělení hodnot pro import
var
    mStr, mToken : string;
    mPos, i : integer;
    mList:tstringlist;
    mstring:string;
begin
    mList:=tstringlist.create;
    mStr := AData;
    try
        for i := 0 to NxCharCount(ASeparator,mStr)  do begin
            mPos := AnsiPos(ASeparator, mStr);
            if mPos = 0 then mPos := Length(mStr) + 1;
                mList.Add(NxLeft(mStr, mPos - 1));
                mStr := copy(mStr, mPos +Length(ASeparator), Length(mStr) - mPos);
         end;
           result:=mlist;
     finally
        mList.free;
     end;
end;












function POST_API_GS_DecodeDatamatrix(AContext: TNxContext; AInput: TJSONSuperObject; APath: String): TJSONSuperObject;
var
  msBody:string;
  mDatamatrix:string;
  mStorecard_ID , mStorebatch_ID,mStore_id,mStore:string;
  mBatchquantity, mQuantityCard:string;
  mvalue:tstringlist;
  mstring:string;
  mBO:TNxCustomBusinessObject;
  mr:tstringlist;
  gs01,gs10,gs17:string;
  mquantity:double;
begin

  mDatamatrix := '';
	mStore := '';
  mStore_id:='';
  mDatamatrix := AInput.S['Datamatrix'];
	mStore := AInput.S['Store'];

  try
  if mstore<>'' then begin
      mr:=tstringlist.create;
      try
           AContext.GetObjectSpace.SQLSelect('select ID COLLATE Czech_CS_AS from Stores where code= ' + quotedstr(mStore),mr);
           if mr.count>0 then begin
               mStore_id:=mr.Strings[0];
           end;
      finally
          mr.free;
      end;
  end;
  finally

  end;


 mvalue:=tstringlist;
 try
    mvalue:= fnParsevalue(GS_DecodeDatamatrix(AContext.GetObjectSpace,mDatamatrix),';');
    if mvalue.count>1 then begin
        gs01:=mvalue.Strings[1];
        gs10:=mvalue.Strings[0];
        gs17:=mvalue.Strings[2];
        //mquantity:=NxIBStrToFloat(mvalue.Strings[3]);
    end;
 finally
    mvalue.free;
 end;

 mvalue:=tstringlist;
 try
 mvalue:= fnParsevalue(ID_from_GS_DecodeDatamatrix(AContext.GetObjectSpace,gs01,gs10,mquantity),';') ;
 if mvalue.count>1 then begin
      if mvalue.Strings[0]='0000000000' then mStoreBatch_ID:='' else mStoreBatch_ID:=mvalue.Strings[0];
      if mvalue.Strings[1]='0000000000' then mStoreCard_ID:='' else mStoreCard_ID:=mvalue.Strings[1];
      if NxIBStrToFloat(mvalue.Strings[2])=0 then mquantity:=1 else mquantity:=NxIBStrToFloat(mvalue.Strings[2]);
    end;

 finally
     mvalue.free;
 end;



    if mStorecard_ID='' then begin
        msbody:='[' ;
           msbody:=msbody + '{';
                   msbody:=msbody + '"Datamatrix" : "' + mDatamatrix + '",' ;
                   msbody:=msbody + '"Stav" : "' + 'Nedohledano' + '",' ;

                                  msbody:=msbody + '"GS1Data" : [   ' ;
                                       msbody:=msbody + ' { ' ;
                                            msbody:=msbody + '"(01)0" : "' + gs01 + '",' ;
                                            msbody:=msbody + '"(10)" : "' + gs10 + '",' ;
                                            msbody:=msbody + '"(17)" : "' + gs17 + '",' ;
                                        msbody:=msbody + ' } ' ;
                                   msbody:=msbody + '  ], ' ;

                                  msbody:=msbody + '"IDData" : [   ' ;
                                       msbody:=msbody + ' { ' ;
                                            msbody:=msbody + '"Storecard_ID" : "' + mStorecard_ID + '",' ;
                                            msbody:=msbody + '"Storebatch_ID" : "' + mStoreBatch_ID + '",' ;
                                            msbody:=msbody + '"Quantity" : "' +NxFloatToIBStr(mQuantity) + '",' ;
                                        msbody:=msbody + ' } ' ;
                                   msbody:=msbody + '  ], ' ;

                           msbody:=msbody + '}';
                        msbody:=msbody + ']' ;

                result := TJSONSuperObject.ParseString(msbody, True);
         //result:=msbody;

    end else begin
       if not NxIsEmptyOID(mStoreBatch_ID) then begin
               mbo:=AContext.GetObjectSpace.CreateObject('C32QXZWCTVDL342W01C0CX3FCC');
               mbo.load(mStoreBatch_ID,nil);
                          // *** JSON
                          msbody:='[' ;
                             msbody:=msbody + '{';
                                     msbody:=msbody + '"Datamatrix" : "' + mDatamatrix + '",' ;
                                     msbody:=msbody + '"Stav" : "' + 'OK_SB' + '",' ;

                                                    // *** GS1
                                                    msbody:=msbody + '"GS1Data" : [   ' ;
                                                         msbody:=msbody + ' { ' ;
                                                              msbody:=msbody + '"(01)0" : "' + gs01 + '",' ;
                                                              msbody:=msbody + '"(10)" : "' + gs10 + '",' ;
                                                              msbody:=msbody + '"(17)" : "' + gs17 + '",' ;
                                                          msbody:=msbody + ' } ' ;
                                                     msbody:=msbody + '  ], ' ;

                                                    // *** StoreBatch  - šarže
                                                    msbody:=msbody + '"StoreBatch_ID" : "' + mStorebatch_ID + '",' ;
                                                        msbody:=msbody + '"StoreBatch_ID_Data" : [   ' ;
                                                               msbody:=msbody + ' { ' ;
                                                                      msbody:=msbody + '"Name" : "' + mbo.GetFieldValueAsString('Name') + '",' ;
                                                                      if mStore_id<>'' then begin
                                                                         mr:=tstringlist.create;
                                                                         try
                                                                            AContext.GetObjectSpace.SQLSelect('Select sum(quantity) from StoreSubBatches where StoreBatch_ID=' + quotedstr(mStorebatch_ID) + ' and Store_ID=' + quotedstr(mStore_id),mr) ;
                                                                              if mr.count>0 then begin
                                                                                  msbody:=msbody + '"Quantity" : "' + mr.Strings[0] + '",' ;
                                                                              end;
                                                                         finally

                                                                         end;
                                                                      end;
                                                                      msbody:=msbody + '"Specification" : "' + mbo.GetFieldValueAsString('Specification') + '",' ;
                                                               msbody:=msbody + ' } ' ;
                                                           msbody:=msbody + '  ], ' ;
                                                    // *** StoreCard - skladová karta
                                                    msbody:=msbody + '"Storecard_ID" : "' + mStorecard_ID + '",' ;
                                                          msbody:=msbody + '"StoreCard_ID_Data" : [   ' ;
                                                               msbody:=msbody + ' { ' ;
                                                                    msbody:=msbody + '"Code" : "' + mbo.GetFieldValueAsString('Storecard_ID.Code') + '",' ;
                                                                    msbody:=msbody + '"Name" : "' + mbo.GetFieldValueAsString('Storecard_ID.Name') + '",' ;
                                                                    msbody:=msbody + '"Ean" : "' + mbo.GetFieldValueAsString('Storecard_ID.Ean') + '",' ;
                                                                    msbody:=msbody + '"Unit" : "' + mbo.GetFieldValueAsString('Storecard_ID.MainUnitCode') + '",' ;
                                                                    if mStore_id<>'' then begin
                                                                         mr:=tstringlist.create;
                                                                         try
                                                                            AContext.GetObjectSpace.SQLSelect('Select sum(quantity) from StoreSubCards where StoreCard_ID=' + quotedstr(mStoreCard_ID) + ' and Store_ID=' + quotedstr(mStore_id),mr) ;
                                                                              if mr.count>0 then begin
                                                                                  msbody:=msbody + '"Quantity" : "' + mr.Strings[0] + '",' ;
                                                                              end;
                                                                         finally

                                                                         end;
                                                                      end;
                                                                msbody:=msbody + ' } ' ;
                                                           msbody:=msbody + '  ], ' ;

                                             msbody:=msbody + '}';
                                          msbody:=msbody + ']' ;

                result := TJSONSuperObject.ParseString(msbody, True);
           //result:=msbody;
       end else begin
           if not NxIsEmptyOID(mStoreCard_ID) then begin
               mbo:=AContext.GetObjectSpace.CreateObject('C3V5QDVZ5BDL342M01C0CX3FCC');
               mbo.load(mStoreCard_ID,nil);
                          // *** JSON
                          msbody:='[' ;
                             msbody:=msbody + '{';
                                     msbody:=msbody + '"Datamatrix" : "' + mDatamatrix + '",' ;
                                     msbody:=msbody + '"Stav" : "' + 'OK_SC' + '",' ;

                                                    // *** GS1
                                                    msbody:=msbody + '"GS1Data" : [   ' ;
                                                         msbody:=msbody + ' { ' ;
                                                              msbody:=msbody + '"(01)0" : "' + gs01 + '",' ;
                                                              msbody:=msbody + '"(10)" : "' + gs10 + '",' ;
                                                              msbody:=msbody + '"(17)" : "' + gs17 + '",' ;
                                                          msbody:=msbody + ' } ' ;
                                                     msbody:=msbody + '  ], ' ;

                                                    // *** StoreBatch  - šarže
                                                    msbody:=msbody + '"StoreBatch_ID" : "' + mStorebatch_ID + '",' ;
                                                        msbody:=msbody + '"StoreBatch_ID_Data" : [   ' ;
                                                               msbody:=msbody + ' { ' ;
                                                                      msbody:=msbody + '"Name" : "' + '' + '",' ;
                                                                      msbody:=msbody + '"Specification" : "' + '' + '",' ;
                                                               msbody:=msbody + ' } ' ;
                                                           msbody:=msbody + '  ], ' ;
                                                    // *** StoreCard - skladová karta
                                                    msbody:=msbody + '"Storecard_ID" : "' + mStorecard_ID + '",' ;
                                                          msbody:=msbody + '"StoreCard_ID_Data" : [   ' ;
                                                               msbody:=msbody + ' { ' ;
                                                                    msbody:=msbody + '"Code" : "' + mbo.GetFieldValueAsString('Code') + '",' ;
                                                                    msbody:=msbody + '"Name" : "' + mbo.GetFieldValueAsString('Name') + '",' ;
                                                                    msbody:=msbody + '"Ean" : "' + mbo.GetFieldValueAsString('Ean') + '",' ;
                                                                    msbody:=msbody + '"Unit" : "' + mbo.GetFieldValueAsString('MainUnitCode') + '",' ;


                                                                msbody:=msbody + ' } ' ;
                                                           msbody:=msbody + '  ], ' ;

                                             msbody:=msbody + '}';
                                          msbody:=msbody + ']' ;

                result := TJSONSuperObject.ParseString(msbody, True);
           //result:=msbody;
           end;
       end;
  end;








 // result := TJSONSuperObject.ParseString(mstring, True);

end;
















function POST_APIDecodeDatamatrix(AContext: TNxContext; AInput: TJSONSuperObject; APath: String): TJSONSuperObject;
var
  msBody:string;
  mDatamatrix:string;
  mStorecard_ID , mStorebatch_ID,mStore_id,mStore:string;
  mBatchquantity, mQuantityCard:string;
  mvalue:tstringlist;
  mstring:string;
  mBO:TNxCustomBusinessObject;
  mr:tstringlist;
begin

  mDatamatrix := '';
	mStore := '';
  mStore_id:='';
  mDatamatrix := AInput.S['Datamatrix'];
	mStore := AInput.S['Store'];


  if mstore<>'' then begin
      mr:=tstringlist.create;
      try
           AContext.GetObjectSpace.SQLSelect('select ID COLLATE Czech_CS_AS from Stores where code= ' + quotedstr(mStore),mr);
           if mr.count>0 then begin
               mStore_id:=mr.Strings[0];
           end;
      finally
          mr.free;
      end;
  end;



  mstring:= DatamatrixDecodeBatches(AContext.GetObjectSpace,mDatamatrix);
  mStorecard_ID:='';
  mStorebatch_ID:='';
  mBatchquantity:='';
  mQuantityCard:='';
  mStore_ID:='';

  mStore_ID:=mstore ;

   mvalue:=tstringlist.create;
        try

              Parsevalue(mstring,';',mstring,mvalue,4);
                     mStore:=mstore_id;
                     mStorebatch_ID:=mvalue.Strings[2];
                     mStorecard_ID:=mvalue.Strings[1];
                     mBatchquantity:= mvalue.Strings[3];

         finally
             mvalue.free;
         end;

  result:=TJSONSuperObject.create;
  mbo:=AContext.GetObjectSpace.CreateObject('C32QXZWCTVDL342W01C0CX3FCC');
  try
  if copy(mDatamatrix,1,3)='MAT' then mStorebatch_ID:= AContext.GetObjectSpace.SQLSelectFirstAsString('Select id from Storebatches where name=' + quotedstr(mDatamatrix))    ;
            if not NxIsBlank(mDatamatrix) then begin
               mbo.load(mStorebatch_ID,nil);
                        msbody:='[' ;
                          msbody:=msbody + '{';

                                           msbody:=msbody + '"Datamatrix" : "' + mDatamatrix + '",' ;

                                                                                msbody:=msbody + '"StoreBatch_ID" : "' + mStorebatch_ID + '",' ;
                                                                                    msbody:=msbody + '"StoreBatchData" : [   ' ;
                                                                                           msbody:=msbody + ' { ' ;
                                                                                           msbody:=msbody + '"Name" : "' + mbo.GetFieldValueAsString('Name') + '",' ;
                                                                                           msbody:=msbody + '"Specification" : "' + mbo.GetFieldValueAsString('Specification') + '",' ;
                                                                                                     if mStore_ID<>'' then begin
                                                                                                            mr:=TStringList.create;
                                                                                                            try
                                                                                                                   AContext.GetObjectSpace.SQLSelect('select sum(quantity) from StoreSubBatches where StoreBatch_ID= ' + quotedstr(mStorebatch_ID) + ' and Store_ID=' + quotedstr(mStore_ID),mr);
                                                                                                                    if mr.count>0 then begin
                                                                                                                         msbody:=msbody + '"StoreBatch_Quantity" : "' + mr.Strings[0] + '",' ;
                                                                                                                     end;

                                                                                                            finally
                                                                                                                mr.free;
                                                                                                            end;
                                                                                                     end;
                                                                                             msbody:=msbody + ' } ' ;
                                                                                            msbody:=msbody + '  ], ' ;


                                                                                msbody:=msbody + '"Storecard_ID" : "' + mStorecard_ID + '",' ;
                                                                                      msbody:=msbody + '"StorecardData" : [   ' ;
                                                                                           msbody:=msbody + ' { ' ;
                                                                                                msbody:=msbody + '"Code" : "' + mbo.GetFieldValueAsString('Storecard_ID.Code') + '",' ;
                                                                                                msbody:=msbody + '"Name" : "' + mbo.GetFieldValueAsString('Storecard_ID.Name') + '",' ;
                                                                                                msbody:=msbody + '"Ean" : "' + mbo.GetFieldValueAsString('Storecard_ID.Ean') + '",' ;
                                                                                                msbody:=msbody + '"Unit" : "' + mbo.GetFieldValueAsString('Storecard_ID.MainUnitCode') + '",' ;


                                                                                                    if mStore_ID<>'' then begin
                                                                                                            mr:=TStringList.create;
                                                                                                            try
                                                                                                                   AContext.GetObjectSpace.SQLSelect('select sum(quantity) from StoreSubCards where StoreCard_ID= ' + quotedstr(mStorecard_ID) + ' and Store_ID=' + quotedstr(mStore_ID),mr);
                                                                                                                    if mr.count>0 then begin
                                                                                                                         msbody:=msbody + '"Storecard_Quantity" : "' + mr.Strings[0] + '",' ;
                                                                                                                     end;

                                                                                                            finally
                                                                                                                mr.free;
                                                                                                            end;
                                                                                                     end;







                                                                                            msbody:=msbody + ' } ' ;
                                                                                       msbody:=msbody + '  ], ' ;
                                                    //
                                                           msbody:=msbody + ' } ' ;
                                                       msbody:=msbody + '  ] ' ;

                          msbody:=msbody + '}';
                        msbody:=msbody + ']' ;

                result := TJSONSuperObject.ParseString(msbody, True);

          	end else begin

          	end;
   finally
       mbo.free;
   end;
end;






        function POST_APINXSQLSELECT_String(AContext: TNxContext; ABody: string; APath: String): string;
var
	mParams: TNxParameters;
	mApplication: Variant;
	mCond: TNxDynSQLConditionKind;
	mDynSQL, mDataset: Variant;
	mResult: Double;
	mInfoType: String;
  mType,mField,mTable,mWhere,mGroupBy,mOrderBy:string;
  mSMSQL:string;
  mr,mFields,mValues:TStringList;
  msBody:string;
  xxx:string;
  i, iField,iValue,ax:integer;
  a:string;
  mSeparator:string;
  mString:string;
  mJSON:TJSONSuperObject;
begin
  mJSON:=TJSONSuperObject.create;
  mjson.ParseString(ABody,true);

  mType := mjson.S['Type'];
  mSMSQL := mjson.S['Type'] + ' ' + mjson.S['Fields'] + ' ' + mjson.S['Dotaz'];
  mField := mjson.S['Fields'];
  mSeparator:= mjson.S['Separator'];

  NxShowSimpleMessage(abody,nil);
  result:='';

  if not NxIsBlank(mType) then begin

      if mType='SELECT' then begin

          mr:=TStringList.create;
          try

                AContext.sqlselect(mSMSQL,mr);

              msbody:='[' ;

                                       mFields:=TStringList.create;
                                       try
                                       mFields:=fnParsevalue(mField,',');

                                               for i:=0 to mr.count-1 do begin


                                                 msbody:=msbody + ' { ' ;
                                                      //msbody:=msbody + '"' + 'Value' + '" : "' + mr.strings[0] + '",' ;
                                                           mValues:=TStringList.create;
                                                              try
                                                                  mValues:=fnParsevalue(mr.strings[i],mSeparator);

                                                                 for ifield:=0 to mFields.count-1 do begin



                                                                      msbody:=msbody + '"' + mFields.strings[ifield] + '" : "' + mValues.strings[ifield] + '"' ;

                                                                        if ifield<mFields.count-1  then msbody:=msbody + ',';
                                                                  end;
                                                               finally
                                                                    mValues.free;
                                                               end;

                                                 msbody:=msbody + ' } ' ;
                                                 if i<mr.count-1 then msbody:=msbody + ',';


                                               end;


                                       finally
                                          mFields.free;
                                       end;


               msbody:=msbody + ']' ;

      result := msbody;

          finally
              mr.free;
          end;

      end;

	end else begin
		RaiseException('Missing param info_type.');
	end;
  mjson.free;

end;










function POST_APINXSQLSELECT_JSON(AContext: TNxContext; ABody: TJSONSuperObject; APath: String): TJSONSuperObject;
var
	mParams: TNxParameters;
	mApplication: Variant;
	mCond: TNxDynSQLConditionKind;
	mDynSQL, mDataset: Variant;
	mResult: Double;
	mInfoType: String;
  mType,mField,mTable,mWhere,mGroupBy,mOrderBy:string;
  mSMSQL:string;
  mr,mFields,mValues:TStringList;
  msBody:string;
  xxx:string;
  i, iField,iValue,ax:integer;
  a:string;
  mSeparator:string;
  mString:string;
begin
	mType := ABody.S['Type'];
  mSMSQL := ABody.S['Type'] + ' ' + ABody.S['Fields'] + ' ' + ABody.S['Dotaz'];
  mField := ABody.S['Fields'];
  mSeparator:= ABody.S['Separator'];


  //result:=TJSONSuperObject.create;

  if not NxIsBlank(mType) then begin

      if mType='SELECT' then begin

          mr:=TStringList.create;
          try

                AContext.sqlselect(mSMSQL,mr);

              msbody:='[' ;

                                       mFields:=TStringList.create;
                                       try
                                       mFields:=fnParsevalue(mField,',');

                                               for i:=0 to mr.count-1 do begin


                                                 msbody:=msbody + ' { ' ;
                                                      //msbody:=msbody + '"' + 'Value' + '" : "' + mr.strings[0] + '",' ;
                                                           mValues:=TStringList.create;
                                                              try
                                                                  mValues:=fnParsevalue(mr.strings[i],mSeparator);

                                                                 for ifield:=0 to mFields.count-1 do begin



                                                                      msbody:=msbody + '"' + mFields.strings[ifield] + '" : "' + mValues.strings[ifield] + '"' ;

                                                                        if ifield<mFields.count-1  then msbody:=msbody + ',';
                                                                  end;
                                                               finally
                                                                    mValues.free;
                                                               end;

                                                 msbody:=msbody + ' } ' ;
                                                 if i<mr.count-1 then msbody:=msbody + ',';


                                               end;


                                       finally
                                          mFields.free;
                                       end;


               msbody:=msbody + ']' ;

            //   NxShowSimpleMessage(msbody,nil);
      result := TJSONSuperObject.ParseString(msbody, True);

          finally
              mr.free;
          end;

      end;

	end else begin
		RaiseException('Missing param info_type.');
	end;


end;







function POST_APISQL(AContext: TNxContext; AInput: TJSONSuperObject; APath: String): TJSONSuperObject;
var
	mParams: TNxParameters;
	mApplication: Variant;
	mCond: TNxDynSQLConditionKind;
	mDynSQL, mDataset: Variant;
	mResult: Double;
	mInfoType: String;
  mType,mField,mTable,mWhere,mGroupBy,mOrderBy:string;
  mSMSQL:string;
  mr,mFields,mValues:TStringList;
  msBody:string;
  xxx:string;
  i, iField,iValue,ax:integer;
  a:string;
  mSeparator:string;
  mString:string;
begin
	mType := AInput.S['Type'];
  mField := AInput.S['Field'];
  mTable := AInput.S['Table'];
  mWhere := AInput.S['Where'];
  mGroupBy := AInput.S['Group by'];
  mOrderBy := AInput.S['Order by'];

  result:=TJSONSuperObject.create;
  mSMSQL:='';
  mSBody:='';

  mSeparator:='|';
  xxx:=ReplaceText(mField,',','+' + quotedstr(mSeparator) + '+');

  if not NxIsBlank(mType) then begin
      if mType='SELECT' then begin

          mSMSQL:=mType + ' ' + xxx + ' FROM '  + mTable ;
                if trim(mWhere)<>'' then mSMSQL:=mSMSQL + ' WHERE ' + mWhere;
                if trim(mGroupBy)<>'' then mSMSQL:=mSMSQL + ' GroupBy ' + mGroupBy;
                if trim(mOrderBy)<>'' then mSMSQL:=mSMSQL + ' Order BY ' + mOrderBy;

          mr:=TStringList.create;
          try

                AContext.sqlselect(mSMSQL,mr);

              msbody:='[' ;
                msbody:=msbody + '{';
                MSMSQL:=mType + ' ' + mField + ' FROM '  + mTable ;
                if trim(mWhere)<>'' then mSMSQL:=mSMSQL + ' WHERE ' + mWhere;
                if trim(mGroupBy)<>'' then mSMSQL:=mSMSQL + ' GroupBy ' + mGroupBy;
                if trim(mOrderBy)<>'' then mSMSQL:=mSMSQL + ' Order BY ' + mOrderBy;

                                 msbody:=msbody + '"Pocet" : "' + inttostr(mr.count) + '",' ;
                                 msbody:=msbody + '"Dotaz SQL" : "' + mSMSQL + '", ' ;
                                       mFields:=TStringList.create;
                                       try
                                       mFields:=fnParsevalue(mField,',');
                                             msbody:=msbody + '"Data" : [   ' ;
                                               for i:=0 to mr.count-1 do begin


                                                 msbody:=msbody + ' { ' ;
                                                    //  msbody:=msbody + '"' + 'Value' + '" : "' + mr.strings[0] + '",' ;
                                                           mValues:=TStringList.create;
                                                              try

                                                                 // mValues:=Parsevalue1(mr.strings[i],mSeparator);
                                                                 mValues:=fnParsevalue(mr.strings[i],mSeparator);
                                                                 if mValues.count>0 then begin
                                                                         for ifield:=0 to mFields.count-1 do begin



                                                                              msbody:=msbody + '"' + mFields.strings[ifield] + '" : "' + mValues.strings[ifield] + '"' ;

                                                                                if ifield<mFields.count-1  then msbody:=msbody + ',';
                                                                          end;
                                                                  end;
                                                               finally
                                                                 //   mValues.free;
                                                               end;

                                                 msbody:=msbody + ' } ' ;
                                                 if i<mr.count-1 then msbody:=msbody + ',';


                                               end;

                                             msbody:=msbody + '  ] ' ;
                                       finally
                                        //  mFields.free;
                                       end;

                msbody:=msbody + '}';
               msbody:=msbody + ']' ;

      result := TJSONSuperObject.ParseString(msbody, True);

          finally
              mr.free;
          end;

      end;

	end else begin
		RaiseException('Missing param info_type.');
	end;


end;





function POST_Drimal1(AContext: TNxContext; AInput: TJSONSuperObject; APath: String): string;
var
	mParams: TNxParameters;
	mApplication: Variant;
	mCond: TNxDynSQLConditionKind;
	mDynSQL, mDataset: Variant;
	mResult: Double;
	mInfoType: String;
  mSQL:string;
  mr,mx:tstringlist;
  i,ii:integer;
  mbo:TNxCustomBusinessObject;
  mOStorecard ,mX_typ_produktu,mU_Druh_ID,mU_Provedeni_ID ,mX_verze,mU_Barva_ID :TJSONSuperObject;
  mQuery:string;
  mstring:string;
begin


 //   Result := TJSONSuperObject.Create;

    mSQL:= AInput.S['lipoman'];

    mr:=tstringlist.create;
    try
//          acontext.SQLSelect('Select id from storecards where X_STATISTIKA in(''PZX4000101'',''1Z42000101'',''QZ0U100101'',''2Z42000101'',''3Z42000101'') or sc.X_OBCHODNI_PRIPAD = ''1S10000101'') '
//                             ,mr);

acontext.SQLSelect('select sc.id from storecards sc left join USERDATA UD on 2000016=UD.FIELDCODE AND UD.CLSID=' + quotedstr('C3V5QDVZ5BDL342M01C0CX3FCC') + ' AND sc.ID = ud.id  ' +
' left join Defrolldata d on UD.StringFieldValue=d.id where (sc.hidden = ' + quotedstr('N') + ') and (sc.x_aktivni = '+quotedstr('A') + ') and (sc.x_matka  = ' + quotedstr('A') + ')' +
' and ( sc.X_STATISTIKA in (' + quotedstr('PZX4000101') + ','+quotedstr('1Z42000101') + ',' +quotedstr('QZ0U100101') + ', '+quotedstr('2Z42000101') + ', '+quotedstr('3Z42000101') + ' ) or sc.X_OBCHODNI_PRIPAD = '+quotedstr('1S10000101') + ')' +
' and sc.X_OBCHODNI_PRIPAD != '+quotedstr('4U10000101') +' and (d.id is null or d.id != '+quotedstr('1QS0000101') + ' or d.id != '+quotedstr('1V10000101')+' or d.id != '+quotedstr('1DS0000101') + ' or d.id != '+quotedstr('1V10000101') + ' )' +
' order by sc.x_typ_produktu' ,mr);




                        mQuery:= ' [ '  ;



            if mr.count>0 then begin
               for i:=0 to 10 do begin
                    mbo:=AContext.GetObjectSpace.CreateObject('C3V5QDVZ5BDL342M01C0CX3FCC');
                    try
                        mbo.Load(mr.strings[i],nil);


                                        mQuery:=mQuery + '{ ';
                                              mQuery:=mQuery +' "ID": "' +  mbo.oid +'", ';
                                              mQuery:=mQuery +' "X_STATISTIKA": "' +  mbo.GetFieldValueAsString('X_STATISTIKA')+'", ';
                                              mQuery:=mQuery +' "U_Material": "' +  mbo.GetFieldValueAsString('U_Material')+'", ';
                                              mQuery:=mQuery +' "ACT_verze": "' +  mbo.GetFieldValueAsString('X_verze')+'", ';

                                              mQuery:=mQuery +' "x_typ_produktu": { '  ;
                                                     mQuery:=mQuery +' "ID": "' +  mbo.GetFieldValueAsString('x_typ_produktu') +'", ';
                                                     mQuery:=mQuery +' "Code": "' +  mbo.GetFieldValueAsString('x_typ_produktu.code') +'", ';
                                                     mQuery:=mQuery +' "Name": "' +  mbo.GetFieldValueAsString('x_typ_produktu.Name') +'", ';
                                              mQuery:=mQuery +' }, ';

                                                mQuery:=mQuery +' "U_Druh_ID": { '  ;
                                                     mQuery:=mQuery +' "ID": "' +  mbo.GetFieldValueAsString('U_Druh_ID') +'", ';
                                                     mQuery:=mQuery +' "Code": "' +  mbo.GetFieldValueAsString('U_Druh_ID.code') +'", ';
                                                     mQuery:=mQuery +' "Name": "' +  mbo.GetFieldValueAsString('U_Druh_ID.Name') +'", ';
                                              mQuery:=mQuery +' }, ';

                                              mQuery:=mQuery +' "U_Provedeni_ID": { '  ;
                                                     mQuery:=mQuery +' "ID": "' +  mbo.GetFieldValueAsString('U_Provedeni_ID') +'", ';
                                                     mQuery:=mQuery +' "Code": "' +  mbo.GetFieldValueAsString('U_Provedeni_ID.code') +'", ';
                                                     mQuery:=mQuery +' "Name": "' +  mbo.GetFieldValueAsString('U_Provedeni_ID.Name') +'", ';
                                                     mQuery:=mQuery +' }, ';

                                              mQuery:=mQuery +' "Verze": { '  ;
                                                       mx:=tstringlist.create;
                                                            try
                                                                 AContext.SQLSelect('select stringfieldvalue from historydata where clsid=' + quotedstr('C3V5QDVZ5BDL342M01C0CX3FCC') + ' and fieldcode=' + quotedstr('900121') + ' and id=' + quotedstr('P310000101') + ' order by validfrom$date ',mx);
                                                                 if mx.count>0 then begin
                                                                        // mQuery:= mQuery + ' [ '  ;


                                                                       //  mQuery:= mQuery + ' [ '  ;
                                                                        for ii:=0 to mx.count-1 do begin
                                                                            if mx.Strings[ii]<>'' then begin
                                                                             //     mQuery:=mQuery +' { ';
                                                                             //           mQuery:=mQuery +'"'+ inttostr(ii) +'": "' +  mx.Strings[ii]+'", ';
                                                                             //     mQuery:=mQuery +'"'+ inttostr(ii) +'": "' + mx.Strings[ii]+'", ';
                                                                             //     mQuery:=mQuery +' }, ';
                                                                            end;
                                                                        end;
                                                                       //   mQuery:= mQuery + ' ] '  ;
                                                                    //    mQuery:=mQuery +' }, ';
                                                                    //   mQuery:=mQuery +' ], ';
                                                                 end;
                                                             finally
                                                                 mx.free;
                                                             end;
                                                         mQuery:=mQuery +' }, ';


                                                     mQuery:=mQuery +' }, ';



                    finally
                       mbo.free;
                    end;
                        mQuery:=mQuery + ' ] '  ;
               end;
             end;

  result:=mQuery;
 // result := TJSONSuperObject.ParseString(mQuery, True);
    finally
        mr.free;
    end;
end;






function GetDocQueryBatch(Self:TNxCustomBusinessObject;mDocType_ID,mDocqueue_ID,mFirm_ID,mFirmOffice_ID,mStore_ID,mDivision_ID:string):string;
var
i,ii:integer;
mQuery,mQueryID:string;
mMonRows,mMonBatch:TNxCustomBusinessMonikerCollection;
mid:string;
mPrice:double;
mxg:tstringlist;
mxa,mxb,mxc:tstringlist;
mcurrency_ID,mCountry_ID:string;
mtradetype:integer;
begin

 mtradetype:=self.GetFieldValueAsInteger('tradetype');
 mCurrency_ID:=self.GetFieldValueAsString('Currency_ID');
 mCountry_ID:=self.GetFieldValueAsString('Country_ID');


mMonRows := self.GetLoadedCollectionMonikerForFieldCode(self.GetFieldCode('ROWS'));
//          if true then begin // copy(self.GetFieldValueAsString('X_synchronizace_ID'),i+1,1)='1' then begin
                        mQuery:='{'  ;
                        mQuery:=mQuery +'"ID": "' +                                    Self.OID +'", '                                                            ;
//                          mQuery:=mQuery +'"DocumentType": "' +                         '20' +'", '                  ;
                          mQuery:=mQuery +'"Docqueue_ID": "' +                         mDocqueue_ID +'", '                  ;


                          mQuery:=mQuery +'"Firm_ID":"'  +                             mFirm_ID +'", '                              ;
                          //mQuery:=mQuery +'"Externalnumber":" ' +                      Self.GetFieldValueAsString('DisplayName') +'", '                  ;
                          mQuery:=mQuery +'"Description": "' +                         Self.GetFieldValueAsString('Description') +'", '                  ;


                           try

                                        if mMonRows.BusinessObject[0].GetFieldValueAsInteger('RowType')=3 then begin

                                               mxa:=tstringlist.create;
                                               try
                                                   self.ObjectSpace.SQLSelect('select ii.Currency_ID,ii.tradetype,ii.vatcountry_ID,(ii2.TAmount/ii2.quantity) COLLATE Czech_CS_AS from issuedinvoices2 ii2 join issuedinvoices ii on ii.id=ii2.parent_ID  where ProvideRow_ID =' + QuotedStr(mMonRows.BusinessObject[0].oid),mxa);
                                                   if mxa.count>0 then begin
                                                                     mCountry_ID:=copy(mxa.Strings[0],14,10);
                                                                    mcurrency_ID:=copy(mxa.Strings[0],1,10);
                                                                    mtradetype:=StrToInt(copy(mxa.Strings[0],12,1));
                                                   end else begin
                                                        mxb:=tstringlist.create;
                                                        try
                                                            self.ObjectSpace.SQLSelect('select ro.Currency_ID,ro.tradetype,ro.vatcountry_ID,(ro2.TAmount/ro2.quantity) COLLATE Czech_CS_AS from Receivedorders2 RO2 join Receivedorders RO on RO.id=RO2.parent_ID where ro2.ID =' + QuotedStr(mMonRows.BusinessObject[0].GetFieldValueAsString('ProvideRow_ID')),mxb);
                                                            if mxb.count>0 then begin

                                                                    mCountry_ID:=copy(mxb.Strings[0],14,10);
                                                                    mcurrency_ID:=copy(mxb.Strings[0],1,10);
                                                                    mtradetype:=StrToInt(copy(mxb.Strings[0],12,1));
                                                            end;
                                                        finally

                                                        end;

                                                   end;
                                               finally
                                                   mxa.free;
                                               end;
                                        end;


                                         finally

                                         end;

                          mQuery:=mQuery +'"tradetype": ' +                            IntToStr(mtradetype) +', '                  ;
                          mQuery:=mQuery +'"Currency_ID":"' +                         mCurrency_ID +'", '                  ;
                          mQuery:=mQuery +'"Country_ID": "' +                        mCountry_ID +'", '                  ;
















                          mQuery:=mQuery +'"Rows": [  ';
                        for i := 0 to mMonRows.Count-1 do begin
                                        mQuery:=mQuery +'{ ' ;
//                                        mQuery:=mQuery +'"id":"' +                            		  mMonRows.BusinessObject[i].GetFieldValueAsString('ID')+'", '   ;
                                        mQuery:=mQuery +'"PosIndex": ' +                            IntToStr(mMonRows.BusinessObject[i].GetFieldValueAsInteger('Posindex')) +', '                  ;
                                        mQuery:=mQuery +'"Rowtype": ' +                             IntToStr(mMonRows.BusinessObject[i].GetFieldValueAsInteger('Rowtype')) +', '                  ;
                                        mQuery:=mQuery +'"Text":"' +                            		mMonRows.BusinessObject[i].GetFieldValueAsString('Text')+'", ' ;
                                        mQuery:=mQuery +'"Store_ID":"' +                            mStore_ID+'", '   ;
                                        mQuery:=mQuery +'"Storecard_ID":"' +                        mMonRows.BusinessObject[i].GetFieldValueAsString('Storecard_ID')+'", '   ;
                                        mQuery:=mQuery +'"X_StoreDocuments2_ID":"' +                  mMonRows.BusinessObject[i].oid+'", '   ;
                                        mQuery:=mQuery +'"X_ProvideRow_ID":"' +                  mMonRows.BusinessObject[i].GetFieldValueAsString('X_ProvideRow_ID')+'", '   ;



                                        mQuery:=mQuery +'"Quantity": ' +                            NxFloatToIBStr(mMonRows.BusinessObject[i].GetFieldValueAsFloat('Quantity')) +', '                  ;

                                        mQuery:=mQuery +'"Qunit":"' +                               mMonRows.BusinessObject[i].GetFieldValueAsString('Qunit')+'", '   ;




                                        mprice:=0;
                                        mprice:=mMonRows.BusinessObject[i].GetFieldValueAsFloat('Storecard_ID.X_Cena_skladova_SK')  ;



                                      try

                                        if mMonRows.BusinessObject[i].GetFieldValueAsInteger('RowType')=3 then begin

                                               mxa:=tstringlist.create;
                                               try
                                                   self.ObjectSpace.SQLSelect('select ii2.TAmount/ii2.quantity from issuedinvoices2 ii2 join issuedinvoices ii on ii.id=ii2.parent_ID  where ProvideRow_ID =' + QuotedStr(mMonRows.BusinessObject[i].oid),mxa);
                                                   if mxa.count>0 then begin
                                                        mprice:=NxIBStrToFloat(mxa.Strings[0]);

                                                   end else begin
                                                        mxb:=tstringlist.create;
                                                        try
                                                            self.ObjectSpace.SQLSelect('select ro2.TAmount/ro2.quantity from Receivedorders2 RO2 join Receivedorders RO on RO.id=RO2.parent_ID where ro2.ID =' + QuotedStr(mMonRows.BusinessObject[i].GetFieldValueAsString('ProvideRow_ID')),mxb);
                                                            if mxb.count>0 then begin
                                                                    mprice:=NxIBStrToFloat(mxb.Strings[0]);

                                                            end;
                                                        finally

                                                        end;

                                                   end;
                                               finally
                                                   mxa.free;
                                               end;
                                        end;


                                         finally

                                         end;

                                        mQuery:=mQuery +'"UnitPrice": ' +                           NxFloatToIBStr(mprice) +', '                  ;




//                                        mQuery:=mQuery +'"TotalPrice": ' +                          NxFloatToIBStr(mMonRows.BusinessObject[i].GetFieldValueAsFloat('TotalPrice')) +', '                  ;

//                                        mQuery:=mQuery +'"TAmount": ' +                             NxFloatToIBStr(mMonRows.BusinessObject[i].GetFieldValueAsFloat('TAmount')) +', '                  ;
//                                        mQuery:=mQuery +'"TAmountWithoutVAT": ' +                   NxFloatToIBStr(mMonRows.BusinessObject[i].GetFieldValueAsFloat('TAmountWithoutVAT')) +', '    ;
                                        mQuery:=mQuery +'"Division_ID":"' +                         mDivision_ID+'", '   ;
                                        mQuery:=mQuery +'"BusOrder_ID":"' +                         mMonRows.BusinessObject[i].GetFieldValueAsString('BusOrder_ID')+'", '   ;
                                        mQuery:=mQuery +'"BusProject_ID":"' +                       mMonRows.BusinessObject[i].GetFieldValueAsString('BusProject_ID')+'", '   ;
                                        mQuery:=mQuery +'"BusTransaction_ID":"' +                   mMonRows.BusinessObject[i].GetFieldValueAsString('BusTransaction_ID')+'", '   ;






                                        mQuery:=mQuery +  ' "docrowbatches": [ ' ;
                                        mMonBatch := mMonRows.BusinessObject[i].GetLoadedCollectionMonikerForFieldCode(mMonRows.BusinessObject[i].GetFieldCode('DocRowBatches'));
                                                  for ii := 0 to mMonBatch.Count-1 do begin
                                                       mQuery:=mQuery +'{ ' ;
                                                           mQuery:=mQuery +'"PosIndex": ' +                               IntToStr(mMonBatch.BusinessObject[ii].GetFieldValueAsInteger('Posindex')) +', '                  ;


                                                           mQueryID:='{'
                                                              + ' "class": "' + 'StoreBatches' +'",'
                                                                  +' "select": ["ID",],'
                                                                  + ' "where": " Name = ' + QuotedStr(mMonBatch.BusinessObject[ii].GetFieldValueAsString('storebatch_id.name'))
                                                                  +' " '
                                                                  +'}';
              //                NxShowSimpleMessage(mQueryID,nil);
                                                          mid:='';
                                                            mID:= copy(CallRestApi(Self,'Post',mTargetAPI + '/','query','',mQueryID),9,10);







                                                          IF mid='' THEN BEGIN
                                                                     mQuery:=mQuery +'"newbatch": ' +                      BoolToStr(True) +', '                  ;
                                                                     mQuery:=mQuery +'"newbatchname":"' +                 mMonBatch.BusinessObject[ii].GetFieldValueAsString('storebatch_id.name')+'", '   ;
                                                                     mQuery:=mQuery +'"newbatchspecification":"' +        mMonBatch.BusinessObject[ii].GetFieldValueAsString('storebatch_id.specification')+'", '   ;
                                                                     mQuery:=mQuery +'"newbatchcomment":"' +              mMonBatch.BusinessObject[ii].GetFieldValueAsString('storebatch_id.comment')+'", '   ;
                                                  //                   mQuery:=mQuery +'"newbatchexpirationdate$date":"' +  mMonBatch.BusinessObject[ii].GetFieldValueAsString('storebatch_id.expirationdate$date')+'", '   ;
                                                           end else begin
                                                                     mQuery:=mQuery +'"storebatch_id":"' +                mid+'", '   ;
                                                                     //mQuery:=mQuery +'"storesubbatch_id":"' +             mMonBatch.BusinessObject[ii].GetFieldValueAsString('storesubbatch_id')+'", '   ;
                                                           end;

                                                           mQuery:=mQuery +'"quantity": ' +                                NxFloatToIBStr(mMonBatch.BusinessObject[ii].GetFieldValueAsFloat('quantity')) +', '                  ;
                                                           mQuery:=mQuery +'"qunit":"' +                                  mMonBatch.BusinessObject[ii].GetFieldValueAsString('qunit')+'", '   ;
                                                           mQuery:=mQuery +' }, ';

                                                  end;
                                                  mQuery:=mQuery +' ], ';





                                        mQuery:=mQuery +' }, ';

                        end;
                               mQuery:=mQuery +' ] ';



                              mQuery:=mQuery +' } ';


//                      end;


    result:=mQuery;
end;



function CorrectQuery(Self:TNxCustomBusinessObject;mDocqueue_ID,mFirm_ID,mFirmOffice_ID,mStore_ID,mDivision_ID:string):string;
var
i:integer;
mQuery:string;
mMonRows:TNxCustomBusinessMonikerCollection;
begin

end;

function GetDocQuery(Self:TNxCustomBusinessObject;mDocqueue_ID,mFirm_ID,mFirmOffice_ID,mStore_ID,mDivision_ID,mDocumentType:string):string;
var
i:integer;
mQuery:string;
mMonRows:TNxCustomBusinessMonikerCollection;
mprice:double;
begin

mMonRows := self.GetLoadedCollectionMonikerForFieldCode(self.GetFieldCode('ROWS'));
//          if true then begin // copy(self.GetFieldValueAsString('X_synchronizace_ID'),i+1,1)='1' then begin
                        mQuery:='{'  ;
                        mQuery:=mQuery +'"ID": "' +                                    Self.OID +'", '                                                            ;
                          mQuery:=mQuery +'"Docqueue_ID": "' +                         mDocqueue_ID +'", '                  ;


                          if mDocumentType='RO' then begin
                                mQuery:=mQuery +'"X_Termin_dodani":"' +                       FormatDateTime('YYYY-MM-DD',Self.GetFieldValueAsDateTime('X_datum_dodani')) +'", '                  ;
                          end;
                          if mDocumentType='OV' then begin
                                mQuery:=mQuery +'"X_datum_dodani":"' +                       FormatDateTime('YYYY-MM-DD',Self.GetFieldValueAsDateTime('X_datum_dodani')) +'", '                  ;
                          end;

                          mQuery:=mQuery +'"X_Poznam_exp": "' +                         Self.GetFieldValueAsString('X_Poznam_exp_ext') +'", '                  ;
                          mQuery:=mQuery +'"X_Poznam_exp_ext": "' +                         Self.GetFieldValueAsString('X_Poznam_exp') +'", '                  ;

                          mQuery:=mQuery +'"Firm_ID":"'  +                             mFirm_ID +'", '                              ;

                         if NxIsBlank(Self.GetFieldValueAsString('X_ExternalDocument'))  then begin
                              mQuery:=mQuery +'"X_ExternalDocument": "' +                         Self.DisplayName +'", ';
                          end else begin
                              mQuery:=mQuery +'"X_ExternalDocument": "' +                         Self.GetFieldValueAsString('X_ExternalDocument') +'", ';
                          end;
                          if ((mDocumentType='IO') or  (mDocumentType='RO')) then begin
                               mQuery:=mQuery +'"Confirmed":"' +                         BoolToStr(True)+'", '    ;
                               mQuery:=mQuery +'"Currency_ID":"' +                         Self.GetFieldValueAsString('Currency_ID') +'", '                  ;
                          end;
                          //mQuery:=mQuery +'"DocumentDiscount":" ' + NxFloatToIBStr(Self.GetFieldValueAsFloat('DocumentDiscount')) + '", '                  ;
                          try
                          mQuery:=mQuery +'"Description": "' +                         Self.GetFieldValueAsString('Description') +'", '                  ;
                          finally end;


                          try
                              mQuery:=mQuery +'"X_poznamka": "' +                         Self.GetFieldValueAsString('X_poznamka') +'", '                  ;
                          finally end;
//  mQuery:=mQuery +'"Country_ID ": "' +                          Self.GetFieldValueAsString('Country_ID') +'", '                  ;

                          mQuery:=mQuery +'"Country_ID":" ' +                      Self.GetFieldValueAsString('Country_ID') +'", '                  ;

                          if (mDocumentType<>'RO') and (mDocumentType<>'IO') then begin

                              mQuery:=mQuery +'"tradetype": ' +                            IntToStr(Self.GetFieldValueAsInteger('tradetype')) +', '                  ;
                              mQuery:=mQuery +'"IntrastatDeliveryTerm_ID":"' +                         Self.GetFieldValueAsString('IntrastatDeliveryTerm_ID') +'", '                  ;
                              mQuery:=mQuery +'"IntrastatTransactionType_ID":"' +                         Self.GetFieldValueAsString('IntrastatTransactionType_ID') +'", '                  ;
                              mQuery:=mQuery +'"IntrastatTransportationType_ID":"' +                         Self.GetFieldValueAsString('IntrastatTransportationType_ID') +'", '                  ;
                          end else begin
                              mQuery:=mQuery +'"tradetype": 0, '

                          end;
                          if (mDocumentType='IO') then begin

                          //     mQuery:=mQuery +'"WithPrices":"' +                         BoolToStr(Self.GetFieldValueAsBoolean('WithPrices'))+'", '    ;                 // ": false,
                          end;
                          //mQuery:=mQuery +'"IntrastatDeliveryTerm_ID": "1000000101", '                  ;
                          //mQuery:=mQuery +'"IntrastatTransactionType_ID": "1001000000", '                  ;
                          //mQuery:=mQuery +'"IntrastatTransportationType_ID": "2000000000", '                  ;

                          //NxShowSimpleMessage(copy(mTargetList.strings[i],21,1),nil);

                          mQuery:=mQuery +'"Rows": [  ';
                        for i := 0 to mMonRows.Count-1 do begin
                                        mQuery:=mQuery +'{ ' ;
//                                        mQuery:=mQuery +'"id":"' +                            		  mMonRows.BusinessObject[i].GetFieldValueAsString('ID')+'", '   ;
                                        mQuery:=mQuery +'"PosIndex": ' +                            IntToStr(mMonRows.BusinessObject[i].GetFieldValueAsInteger('Posindex')) +', '                  ;
                                        mQuery:=mQuery +'"Rowtype": ' +                             IntToStr(mMonRows.BusinessObject[i].GetFieldValueAsInteger('Rowtype')) +', '                  ;
                                        mQuery:=mQuery +'"Text":"' +                            		mMonRows.BusinessObject[i].GetFieldValueAsString('Text')+'", ' ;
                                        mQuery:=mQuery +'"Store_ID":"' +                            mStore_ID+'", '   ;
                                        mQuery:=mQuery +'"Storecard_ID":"' +                        mMonRows.BusinessObject[i].GetFieldValueAsString('Storecard_ID')+'", '   ;

                                        mQuery:=mQuery +'"Quantity": ' +                            NxFloatToIBStr(mMonRows.BusinessObject[i].GetFieldValueAsFloat('Quantity')) +', '                  ;

                                        mQuery:=mQuery +'"Qunit":"' +                               mMonRows.BusinessObject[i].GetFieldValueAsString('Qunit')+'", '   ;
                                        mQuery:=mQuery +'"DeliveryDate$DATE":"' +FormatDateTime('YYYY-MM-DD',mMonRows.BusinessObject[i].GetFieldValueAsDateTime('DeliveryDate$DATE'))+'", '                  ;
//                                        mTargetAPI + '/qrexpr'
//                                      {
//                                            	"expr" : "NxGetStoreCardUnitPriceDef(mfirm_ID,mStore_ID,mMonRows.BusinessObject[i].GetFieldValueAsString('Storecard_ID'),'5100000101',mMonRows.BusinessObject[i].GetFieldValueAsString('Qunit'),False,'0000CZK000',Date)"
//                                        }
                                        // cena z dokladu
                                        mQuery:=mQuery +'"UnitPrice": ' +                           NxFloatToIBStr(mMonRows.BusinessObject[i].GetFieldValueAsFloat('UnitPrice') ) +', '                  ;
                                        mQuery:=mQuery +'"TotalPrice": ' +                          NxFloatToIBStr(mMonRows.BusinessObject[i].GetFieldValueAsFloat('TotalPrice')) +', '                  ;

                                        //mQuery:=mQuery +'"TAmount": ' +                             NxFloatToIBStr(mMonRows.BusinessObject[i].GetFieldValueAsFloat('TAmountWithoutVAT')) +', '                  ;
                                        //mQuery:=mQuery +'"TAmountWithoutVAT": ' +                   NxFloatToIBStr(mMonRows.BusinessObject[i].GetFieldValueAsFloat('TAmountWithoutVAT')) +', '    ;
                                        mQuery:=mQuery +'"Division_ID":"' +                         mDivision_ID+'", '   ;
                                        mQuery:=mQuery +'"BusOrder_ID":"' +                         mMonRows.BusinessObject[i].GetFieldValueAsString('BusOrder_ID')+'", '   ;
                                       // mquery:=mquery +'"DeliveryDate$DATE":' +NxFloatToIBStr(Self.GetFieldValueAsDateTime('DeliveryDate$DATE')) +', ';
                                        mQuery:=mQuery +'"BusTransaction_ID":"' +                   mMonRows.BusinessObject[i].GetFieldValueAsString('BusTransaction_ID')+'", '   ;
                                        mQuery:=mQuery +'"BusProject_ID":"' +                       mMonRows.BusinessObject[i].GetFieldValueAsString('BusProject_ID')+'", '   ;
                                        mQuery:=mQuery +'"X_ProvideRow_ID":"' +                   mMonRows.BusinessObject[i].GetFieldValueAsString('X_ProvideRow_ID')+'", '   ;

                                        //if (mDocumentType='RO') or (mDocumentType<>'IO') then begin
                                             mQuery:=mQuery +'"X_specifikace_id":"' +                   mMonRows.BusinessObject[i].GetFieldValueAsString('X_specifikace_id')+'", '   ;
                                             mQuery:=mQuery +'"X_ExternalSpecification":"' +                   mMonRows.BusinessObject[i].GetFieldValueAsString('X_ExternalSpecification')+'", '   ;
                                        //end;


                                        mQuery:=mQuery +' }, ';

                        end;
                               mQuery:=mQuery +' ] ';

                              mQuery:=mQuery +' } ';


//                      end;


    result:=mQuery;
end;




function POST_Drimal(AContext: TNxContext; AInput: TJSONSuperObject; APath: String): TJSONSuperObject;
var
	mParams: TNxParameters;
	mApplication: Variant;
	mCond: TNxDynSQLConditionKind;
	mDynSQL, mDataset: Variant;
	mResult: Double;
	mInfoType: String;
  mSQL:string;
  mr,mx:tstringlist;
  i,ii:integer;
  mbo:TNxCustomBusinessObject;
  mOStorecard ,mX_typ_produktu,mU_Druh_ID,mU_Provedeni_ID ,mX_verze,mU_Barva_ID :TJSONSuperObject;
  mQuery:string;
  mstring:string;
begin


    Result := TJSONSuperObject.Create;








    mSQL:= AInput.S['lipoman'];

    mr:=tstringlist.create;
    try
//          acontext.SQLSelect('Select id from storecards where X_STATISTIKA in(''PZX4000101'',''1Z42000101'',''QZ0U100101'',''2Z42000101'',''3Z42000101'') or sc.X_OBCHODNI_PRIPAD = ''1S10000101'') '
//                             ,mr);

acontext.SQLSelect('select sc.id from storecards sc left join USERDATA UD on 2000016=UD.FIELDCODE AND UD.CLSID=' + quotedstr('C3V5QDVZ5BDL342M01C0CX3FCC') + ' AND sc.ID = ud.id  ' +
' left join Defrolldata d on UD.StringFieldValue=d.id where (sc.hidden = ' + quotedstr('N') + ') and (sc.x_aktivni = '+quotedstr('A') + ') and (sc.x_matka  = ' + quotedstr('A') + ')' +
' and ( sc.X_STATISTIKA in (' + quotedstr('PZX4000101') + ','+quotedstr('1Z42000101') + ',' +quotedstr('QZ0U100101') + ', '+quotedstr('2Z42000101') + ', '+quotedstr('3Z42000101') + ' ) or sc.X_OBCHODNI_PRIPAD = '+quotedstr('1S10000101') + ')' +
' and sc.X_OBCHODNI_PRIPAD != '+quotedstr('4U10000101') +' and (d.id is null or d.id != '+quotedstr('1QS0000101') + ' or d.id != '+quotedstr('1V10000101')+' or d.id != '+quotedstr('1DS0000101') + ' or d.id != '+quotedstr('1V10000101') + ' )' +
' order by sc.x_typ_produktu' ,mr);



          if mr.count>0 then begin
               for i:=0 to mr.count-1 do begin
                    mbo:=AContext.GetObjectSpace.CreateObject('C3V5QDVZ5BDL342M01C0CX3FCC');
                    try
                        mbo.Load(mr.strings[i],nil);

                        mOStorecard:=Result.CreateJSON;

                                  mOStorecard.i['Pocet'] := mr.count;
                                  mOStorecard.S['ID'] := mbo.oid;
                                  mOStorecard.S['X_STATISTIKA'] := mbo.GetFieldValueAsString('X_STATISTIKA');
                                  mOStorecard.S['U_Material'] := mbo.GetFieldValueAsString('U_Material');
                                  mOStorecard.S['ACT_verze'] := mbo.GetFieldValueAsString('X_verze');
                                  // vytvorime vnoreny objekt ...

                                  mX_typ_produktu := mOStorecard.CreateJSON; // Pozor, CreateJSON není konstruktor ani class-metoda!
                                      mX_typ_produktu.S['ID'] := mbo.GetFieldValueAsString('x_typ_produktu');
                                      mX_typ_produktu.S['Code'] := mbo.GetFieldValueAsString('x_typ_produktu.code');
                                      mX_typ_produktu.S['NAme'] := mbo.GetFieldValueAsString('x_typ_produktu.name');
                                  mOStorecard.O['X_typ_produktu'] := mX_typ_produktu; // ... a pripojime jej jako hodnotu

                                  mU_Druh_ID := mOStorecard.CreateJSON; // Pozor, CreateJSON není konstruktor ani class-metoda!
                                      mU_Druh_ID.S['ID'] := mbo.GetFieldValueAsString('U_Druh_ID');
                                      mU_Druh_ID.S['Code'] := mbo.GetFieldValueAsString('U_Druh_ID.code');
                                      mU_Druh_ID.S['NAme'] := mbo.GetFieldValueAsString('U_Druh_ID.name');
                                  mOStorecard.O['U_Druh_ID'] := mU_Druh_ID; // ... a pripojime jej jako hodnotu

                                  mU_Barva_ID := mOStorecard.CreateJSON; // Pozor, CreateJSON není konstruktor ani class-metoda!
                                      mU_Barva_ID.S['ID'] := mbo.GetFieldValueAsString('U_Provedeni_ID');
                                      mU_Barva_ID.S['Code'] := mbo.GetFieldValueAsString('U_Provedeni_ID.code');
                                      mU_Barva_ID.S['NAme'] := mbo.GetFieldValueAsString('U_Provedeni_ID.name');
                                  mOStorecard.O['U_Barva_ID'] := mU_Barva_ID; // ... a pripojime jej jako hodnotu

                                  mU_Provedeni_ID := mOStorecard.CreateJSON; // Pozor, CreateJSON není konstruktor ani class-metoda!
                                      mU_Provedeni_ID.S['ID'] := mbo.GetFieldValueAsString('U_Provedeni_ID');
                                      mU_Provedeni_ID.S['Code'] := mbo.GetFieldValueAsString('U_Provedeni_ID.code');
                                      mU_Provedeni_ID.S['NAme'] := mbo.GetFieldValueAsString('U_Provedeni_ID.name');
                                  mOStorecard.O['U_Provedeni_ID'] := mU_Provedeni_ID; // ... a pripojime jej jako hodnotu


                                   mX_verze := mOStorecard.CreateJSON; // Pozor, CreateJSON není konstruktor ani class-metoda!
                                      mX_verze.S['Oznaceni'] := mbo.GetFieldValueAsString('x_Verze');
                                      mX_verze.S['Oznaceni'] := mbo.GetFieldValueAsString('x_Verze');
                                      mX_verze.S['Oznaceni'] := mbo.GetFieldValueAsString('x_Verze');

                                  mOStorecard.O['X_Verze'] := mX_verze; // ... a pripojime jej jako hodnotu


                                  mX_verze := mOStorecard.CreateJSON; // Pozor, CreateJSON není konstruktor ani class-metoda!
                                    mx:=tstringlist.create;
                                    try
                                         AContext.SQLSelect('select stringfieldvalue from historydata where clsid=' + quotedstr('C3V5QDVZ5BDL342M01C0CX3FCC') + ' and fieldcode=' + quotedstr('900121') + ' and id=' + quotedstr('P310000101') + ' order by validfrom$date ',mx);
                                         if mx.count>0 then begin
                                                for ii:=0 to mx.count-1 do begin
                                                    if mx.Strings[ii]<>'' then mX_verze.S[inttostr(ii)] := mx.Strings[ii];
                                                end;
                                         end;
                                     finally
                                         mx.free;
                                     end;
                                  mOStorecard.O['X_Verze'] := mX_verze; // ... a pripojime jej jako hodnotu





                                 // mData.AsString; // vypise: {"Manzelka":{"Jmeno":"Zdena Nováková","JeMuz":false},"PocetDeti":2,"Jmeno":"Josef Novák","JeMuz":true}



                               Result.O['Storecard'] := mOStorecard; // ... a pripojime jej jako hodnotu


                    finally
                        mbo.free;
                    end;

               end;


          end;
    finally
        mr.free;
    end;
end;



function POST_Lipoman(AContext: TNxContext; AInput: TJSONSuperObject; APath: String): string;
var
	mParams: TNxParameters;
	mApplication: Variant;
	mCond: TNxDynSQLConditionKind;
	mDynSQL, mDataset: Variant;
	mResult: Double;
	mInfoType: String;
  mSQL:string;
begin
//	Result := TJSONSuperObject.Create;
//	mInfoType := AInput.S['info_type'];
//  mSQL:= AInput.S['mSQL'];
//	if not NxIsBlank(mInfoType) then begin
//
//    Result.I['Value'] := acontext.SQLExecute(msql);
//    Result.S['mInfoType'] := FloatToStr(mResult);
//    Result.S['MSQL'] := mSQL;
//	end else begin
//		RaiseException('Missing param info_type.');
//	end;





  Result := '';
//  mInfoType := AInput.S['info_type'];
//  mSQL:= ' select distinct hd.stringfieldvalue, sc.id, sc.X_STATISTIKA, sc.X_OBCHODNI_PRIPAD, t.id as id_typ,' +
//          't.name as typ,t.code as tcode,d.id as id_druh,d.name as druh,p.id as id_provedeni,p.name as provedeni,ud4.stringfieldvalue as material ' +
//' from storecards sc ' +
//
//' join HistoryData HD on (hd.CLSID=''C3V5QDVZ5BDL342M01C0CX3FCC'') and (hd.FieldCode=''900121'') and ( hd.id=sc.id)' +
//' join DefRollData t on ''TJDIA05IJCBON5S3EGRD4K5FXC''=t.CLSID and sc.x_typ_produktu=t.ID ' +
//' where sc.hidden = ''N'' and sc.x_aktivni = ''A'' ' +
//' and (sc.X_STATISTIKA in(''PZX4000101'', ''1Z42000101'',''QZ0U100101'',''2Z42000101'',''3Z42000101'') or sc.X_OBCHODNI_PRIPAD = ''1S10000101'') +
//' and sc.X_OBCHODNI_PRIPAD = ''4U10000101'' and (d.id is null or (d.id in ''1QS0000101'',''1V10000101'',''1DS0000101'',''1V10000101'')) order by typ ' +


result:=
'[ '

+'    {'
+'        "id": "0010000101", '
+'        "X_STATISTIKA": "1Z42000101", '
+'        "Verze": { '
+'            "id": "B1I1000101",'
+'            "code": "B-VD",'
+'            "name": "VD" '
+'        }, '
+'        "X_OBCHODNI_PRIPAD": "AB10000101", '
+'        "x_typ_produktu": { '
+'            "id": "B1I1000101",'
+'            "code": "B-VD",'
+'            "name": "VD" '
+'        }, '
+'        "U_Druh_ID": { '
+'            "id": "B1I1000101",'
+'            "code": "B-VD",'
+'            "name": "VD" '
+'        },  '
+'        "U_Provedeni_ID": { '
+'            "id": "B1I1000101",'
+'            "name": "VD" '
+'        },   '
+'        "U_Material": "CLASSIC"'
+'    }'
+ ']'


end;






function APICallRestImp(mSO: TNxCustomBusinessObject; mTyp: string;mUrl: string;mSourceDoc: string;mTargetDoc: string;mID: string;mDocqueue_ID:string;mStoreDocqueue_ID:string;ReturnField:string;mStatus:Boolean;mshow:boolean):string;
var
  mWinHTTP: Variant;
  AOS: TNxCustomObjectSpace;
  mRequest:string;
  mstring:string;
begin
  AOS := mSO.ObjectSpace;
    try
         if GetHTTP(mWinHTTP) then begin
             mRequest:=mRequest+ '{';
                                               mRequest:=mRequest+   	'"params": { ';
                                               mRequest:=mRequest+   	'	"docqueue_id": "' + mDocqueue_ID +'" ';
                                              // if mStoreDocqueue_ID<>'' then   mRequest:=mRequest+   	',	"Storedocqueue_id": "' + mStoreDocqueue_ID +'" ';
                                               mRequest:=mRequest+   	'}';
                                               mRequest:=mRequest+   '}';

              mWinHTTP.Open(mTyp, mUrl +mTargetDoc+'/import/'+mSourceDoc + '/' +mid+ReturnField);      //   NxShowSimpleMessage(mTyp + ' - ' +mUrl +mHead +mid + mRequest, nil);
                     if mshow then mstring:= inputbox('Importmanager','mTyp',mUrl +mTargetDoc+'/import/'+mSourceDoc + '/' +mid+ReturnField+   '     ' +mRequest )    ;



              mWinHTTP.SetRequestHeader('Authorization', 'Basic QVBJX1N5bmNocm9uaXphY2U6YzNsdVkyaHliMjVwZW1GalpRPT0=');
              //    mWinHTTP.SetRequestHeader('Content-Type', 'application/json; charset=CP1250'); //');
              mWinHTTP.SetRequestHeader('Accept', '*/*');
              mWinHTTP.SetRequestHeader('Accept-Encoding', 'gzip, deflate, br');
              mWinHTTP.SetRequestHeader('Connection', 'keep-alive');

              mWinHTTP.Send(mRequest);
              if mStatus then begin
                    result:= FloatToStr(mWinHTTP.Status) + ' - '+mWinHTTP.ResponseText + ' - ' + mWinHTTP.StatusText ;
              end else begin
                    result:= mWinHTTP.ResponseText;
              end;
         end;
    finally
    end;
end;




function GetQuery(Self:TNxCustomBusinessObject):string;
 begin
result:='{'
             +'"id": "' +  Self.OID +'", '
             +'"code":"'  +  Self.GetFieldValueAsString('Code') +'", '
             +'"name":"' +  Self.GetFieldValueAsString('Name') +'", '
             +'"X_synchronizace_ID":"' +  Self.GetFieldValueAsString('X_synchronizace_ID') +'", '
             +'"X_EN_NAZEV":"' +  Self.GetFieldValueAsString('X_EN_NAZEV') +'", '
             +'"X_DE_NAZEV":"' +  Self.GetFieldValueAsString('X_DE_NAZEV') +'", '
             +'"X_MX_NAZEV":"' +  Self.GetFieldValueAsString('X_MX_NAZEV') +'", '
             +'"X_ES_NAZEV":"' +  Self.GetFieldValueAsString('X_ES_NAZEV') +'", '
             +'"X_IT_Nazev":"' +  Self.GetFieldValueAsString('X_IT_Nazev') +'", '
             +'"X_FR_Nazev":"' +  Self.GetFieldValueAsString('X_FR_Nazev') +'", '
             +'"X_NL_Nazev":"' +  Self.GetFieldValueAsString('X_NL_Nazev') +'", '
             +'"X_US_Nazev":"' +  Self.GetFieldValueAsString('X_US_Nazev') +'", '
             +'"X_UK_NAZEV":"' +  Self.GetFieldValueAsString('X_UK_NAZEV') +'", '
             +'"X_amoena":"' +  Self.GetFieldValueAsString('X_amoena') +'", '
             +'"X_MEX_Nazev":"' +  Self.GetFieldValueAsString('X_MEX_Nazev') +'", '
             //+'"X_CZ_Nazev":"' +  Self.GetFieldValueAsString('X_CZ_Nazev') +'", '
//             +'"X_SK_Nazev":"' +  Self.GetFieldValueAsString('X_SK_Nazev') +'"'
             +'}';
end;



function CreateTargetList():tstringlist;
var
    mStringlist:tstringlist;
begin
   mStringlist:=tstringlist.create;
   try
         mStringlist.Add(mSourceAPI + '/');
         mStringlist.Add('');
         mStringlist.Add(mTargetAPI + '/');
         result:=mStringlist;
   finally
       mStringlist.free;
   end;
end;


function CallNewValueWithIDNoERR(mSO: TNxCustomBusinessObject; mTyp: string;mUrl: string;mJSON:string):string;
var
  mWinHTTP: Variant;
  AOS: TNxCustomObjectSpace;
begin
  AOS := mSO.ObjectSpace;
  try
         if GetHTTP(mWinHTTP) then begin
              mWinHTTP.Open(mTyp, mUrl );
             // NxShowSimpleMessage(mUrl + ' - ' + mJSON, nil);
              mWinHTTP.SetRequestHeader('Authorization', 'Basic QVBJX1N5bmNocm9uaXphY2U6YzNsdVkyaHliMjVwZW1GalpRPT0=');  //    mWinHTTP.SetRequestHeader('Content-Type', 'application/json; charset=CP1250'); //'); //mWinHTTP.SetRequestHeader('Accept', 'application/json; charset=UTF-8');
              mWinHTTP.Send(mJson);
          if (mWinHTTP.Status <> 204) and (mWinHTTP.Status <> 200) and (mWinHTTP.Status <> 201) then begin     //              NxShowMessage('Response - SC', mWinHTTP.ResponseText, mdInformation, false, nil);
            //if NxGetActualUserID(AOS) <> 'AUTO000000' then begin
              //NxShowMessage('API status ', FloatToStr(mWinHTTP.Status) + ' - ' + mWinHTTP.StatusText, mdInformation, false, nil);
            //end;
          end else begin
            // result:= TEncoding.Convert(mWinHTTP.ResponseText, Encoding_cp1250, Encoding_cpUTF_8);
                 ;
               Result := FloatToStr(mWinHTTP.Status) + ' - ' + mWinHTTP.StatusText;

          end;
        end;
      finally
      end;

end;


function CallNewValueWithID(mSO: TNxCustomBusinessObject; mTyp: string;mUrl: string;mJSON:string):string;
var
  mWinHTTP: Variant;
  AOS: TNxCustomObjectSpace;
begin
  AOS := mSO.ObjectSpace;
  try
         if GetHTTP(mWinHTTP) then begin
              mWinHTTP.Open(mTyp, mUrl );
             // NxShowSimpleMessage(mUrl + ' - ' + mJSON, nil);
              mWinHTTP.SetRequestHeader('Authorization', 'Basic QVBJX1N5bmNocm9uaXphY2U6YzNsdVkyaHliMjVwZW1GalpRPT0=');  //    mWinHTTP.SetRequestHeader('Content-Type', 'application/json; charset=CP1250'); //'); //mWinHTTP.SetRequestHeader('Accept', 'application/json; charset=UTF-8');
              mWinHTTP.Send(mJson);
          if (mWinHTTP.Status <> 204) and (mWinHTTP.Status <> 200) and (mWinHTTP.Status <> 201) then begin     //              NxShowMessage('Response - SC', mWinHTTP.ResponseText, mdInformation, false, nil);
            //if NxGetActualUserID(AOS) <> 'AUTO000000' then begin
              //if mShowError then NxShowMessage('API status ', FloatToStr(mWinHTTP.Status) + ' - ' + mWinHTTP.StatusText, mdInformation, false, nil);
            //end;
          end else begin
            // result:= TEncoding.Convert(mWinHTTP.ResponseText, Encoding_cp1250, Encoding_cpUTF_8);
                 ;
               Result := FloatToStr(mWinHTTP.Status) + ' - ' + mWinHTTP.StatusText +  mWinHTTP.ResponseText;

          end;
        end;
      finally
      end;

end;


function CorrectString(mString:string):string;
begin
      mString:=NxSearchReplace(mString,chr(39),'',[srCase,srAll]);      // apostrof
      mString:=NxSearchReplace(mString,chr(34),'',[srCase,srAll]);      // uvozovky
      mString:=NxSearchReplace(mString,chr(132),'',[srCase,srAll]);     // dvojité uvozovky
result:=mString;
end;


function POST_IdFromDisplayname(AContext: TNxContext; AInput: TJSONSuperObject; APath: String): TJSONSuperObject;
 { "Table": "Storedocuments" ,
    "DisplayName": "DLK-1159/2022"
  }
var
	mParams: TNxParameters;
	mApplication: Variant;
	mCond: TNxDynSQLConditionKind;
	mDynSQL, mDataset: Variant;
	mResult: Double;
	mDisplayName: String;
  mTable:string;
  mr:tstringlist;
  m_ID:string;
  mDocqueue,mOrdnumber,mPeriod:string;
begin
	Result := TJSONSuperObject.Create;
  mTable := AInput.S['Table'];
  mDisplayName:= AInput.S['DisplayName'];
 mr:=tstringlist.create;
 try


  mDocqueue:=copy(mDisplayName,1,AnsiPos('-', mDisplayName)-1);
      mDisplayName:=copy(mDisplayName,AnsiPos('-', mDisplayName)+1,100);
  mOrdnumber:=copy(mDisplayName,1,AnsiPos('/', mDisplayName)-1);
     mDisplayName:=copy(mDisplayName,AnsiPos('/', mDisplayName)+1,100);
  mPeriod:=trim(mDisplayName);

  if mTable='Storedocuments' then begin
      AContext.SQLSelect('Select H.id,H.DocumentType from ' + mTable + ' H join Docqueues DQ on DQ.id=H.Docqueue_ID join Periods P on P.id=H.Period_ID where ' +
                         'dq.code=' + QuotedStr(mDocqueue) + ' and H.ordnumber=' + mOrdnumber + ' and P.Code=' + QuotedStr(mPeriod) ,mr);
  end else begin
      AContext.SQLSelect('Select H.id from ' + mTable + ' H join Docqueues DQ on DQ.id=H.Docqueue_ID join Periods P on P.id=H.Period_ID where ' +
                         'dq.code=' + QuotedStr(mDocqueue) + ' and H.ordnumber=' + mOrdnumber + ' and P.Code=' + QuotedStr(mPeriod) ,mr);
  end;


      if mr.count>0 then begin
            if mTable='Storedocuments' then begin
                    if copy(mr.Strings[0],12,2)='20' then Result.S['Table'] := 'ReceiptCard';
                    if copy(mr.Strings[0],12,2)='21' then Result.S['Table'] := 'BillOfDelivery';
                    if copy(mr.Strings[0],12,2)='22' then Result.S['Table'] := 'OutgoingTransfers';
                    if copy(mr.Strings[0],12,2)='24' then Result.S['Table'] := 'IncomingTransfers';
                    if copy(mr.Strings[0],12,2)='30' then Result.S['Table'] := 'RefundedReceiptCard';
                    if copy(mr.Strings[0],12,2)='23' then Result.S['Table'] := 'RefundedBillOfDelivery';
                    if copy(mr.Strings[0],12,2)='26' then Result.S['Table'] := '';
                    if copy(mr.Strings[0],12,2)='27' then Result.S['Table'] := '';
                    if copy(mr.Strings[0],12,2)='28' then Result.S['Table'] := '';
            end else begin
                 mTable:=trim(mTable);
                 mTable:=copy(mtable,1,Length(mtable)-1);
                Result.S['Table'] := mTable;
            end;
            //Result.S['mDocqueue'] := mDocqueue;
            //Result.S['mOrdnumber'] := mOrdnumber;
            //Result.S['mPeriod'] := mPeriod;
            Result.S['ID'] := copy(mr.Strings[0],1,10);
       end;
finally
    mr.free;
end;


end;


function POST_NXSQL_String(AContext: TNxContext; ABody: string; APath: String): string;
 var
	mParams: TNxParameters;
	mApplication: Variant;
	mCond: TNxDynSQLConditionKind;
	mDynSQL, mDataset: Variant;
	mResult: Double;
	mInfoType: String;
  mType,mField,mTable,mWhere,mGroupBy,mOrderBy:string;
  mSMSQL:string;
  mr,mFields,mValues:TStringList;
  msBody:string;
  xxx:string;
  i, iField,iValue,ax:integer;
  a:string;
  mSeparator:string;
  mString:string;
  mjson:TJSONSuperObject;
begin
  mjson.ParseString(ABody,true);

	mType := mjson.S['Type'];
  mSMSQL := mjson.S['Type'] + ' ' + mjson.S['Fields'] + ' ' + mjson.S['Dotaz'];
  mField := mjson.S['Fields'];
  mSeparator:= mjson.S['Separator'];


  //result:=TJSONSuperObject.create;

  if not NxIsBlank(mType) then begin

      if mType='SELECT' then begin

          mr:=TStringList.create;
          try

                AContext.sqlselect(mSMSQL,mr);

              msbody:='[' ;

                                       mFields:=TStringList.create;
                                       try
                                       mFields:=fnParsevalue(mField,',');

                                               for i:=0 to mr.count-1 do begin


                                                 msbody:=msbody + ' { ' ;
                                                      //msbody:=msbody + '"' + 'Value' + '" : "' + mr.strings[0] + '",' ;
                                                           mValues:=TStringList.create;
                                                              try
                                                                  mValues:=fnParsevalue(mr.strings[i],mSeparator);

                                                                 for ifield:=0 to mFields.count-1 do begin



                                                                      msbody:=msbody + '"' + mFields.strings[ifield] + '" : "' + mValues.strings[ifield] + '"' ;

                                                                        if ifield<mFields.count-1  then msbody:=msbody + ',';
                                                                  end;
                                                               finally
                                                                    mValues.free;
                                                               end;

                                                 msbody:=msbody + ' } ' ;
                                                 if i<mr.count-1 then msbody:=msbody + ',';


                                               end;


                                       finally
                                          mFields.free;
                                       end;


               msbody:=msbody + ']' ;

            //   NxShowSimpleMessage(msbody,nil);
      result := msbody;

          finally
              mr.free;
          end;

      end;

	end else begin
		RaiseException('Missing param info_type.');
	end;
end;


function POST_NXSQL_JSON(AContext: TNxContext; ABody: TJSONSuperObject; APath: String): TJSONSuperObject;
 var
	mParams: TNxParameters;
	mApplication: Variant;
	mCond: TNxDynSQLConditionKind;
	mDynSQL, mDataset: Variant;
	mResult: Double;
	mInfoType: String;
  mType,mField,mTable,mWhere,mGroupBy,mOrderBy:string;
  mSMSQL:string;
  mr,mFields,mValues:TStringList;
  msBody:string;
  xxx:string;
  i, iField,iValue,ax:integer;
  a:string;
  mSeparator:string;
  mString:string;
begin
	Result := TJSONSuperObject.Create;
	mType := ABody.S['Type'];
  mSMSQL := ABody.S['Type'] + ' ' + ABody.S['Fields'] + ' ' + ABody.S['Dotaz'];
  mField := ABody.S['Fields'];
  mSeparator:= ABody.S['Separator'];


  result:=ABody ;




end;


 function APICallString(mSO: TNxCustomObjectSpace; mTyp: string;mUrl: string;mstring:string;mStatus:Boolean):string;
var
  mWinHTTP: Variant;
begin
  try
         if GetHTTP(mWinHTTP) then begin
              mWinHTTP.Open(mTyp, mUrl );
             // NxShowSimpleMessage(mUrl + ' - ' + mJSON, nil);
              mWinHTTP.SetRequestHeader('Authorization', 'Basic QVBJX1N5bmNocm9uaXphY2U6YzNsdVkyaHliMjVwZW1GalpRPT0=');  //    mWinHTTP.SetRequestHeader('Content-Type', 'application/json; charset=CP1250'); //'); //mWinHTTP.SetRequestHeader('Accept', 'application/json; charset=UTF-8');
              mWinHTTP.Send(mstring);
              if mStatus then begin
                    if copy(FloatToStr(mWinHTTP.Status),1,1)='2' then begin
                         result:= mWinHTTP.ResponseText
                    end else begin
                        result:= mWinHTTP.ResponseText ;
                    end;
              end else begin
                    result:= mWinHTTP.ResponseText;
              end;
        end;
      finally
      end;

end;

 function APICallJSON(mSO: TNxCustomBusinessObject; mTyp: string;mUrl: string;mJSON:TJSONSuperObject;mStatus:Boolean):TJSONSuperObject;
var
  mWinHTTP: Variant;
  AOS: TNxCustomObjectSpace;
begin
  AOS := mSO.ObjectSpace;
  try
         if GetHTTP(mWinHTTP) then begin
              mWinHTTP.Open(mTyp, mUrl );
             // NxShowSimpleMessage(mUrl + ' - ' + mJSON, nil);
              mWinHTTP.SetRequestHeader('Authorization', 'Basic QVBJX1N5bmNocm9uaXphY2U6YzNsdVkyaHliMjVwZW1GalpRPT0=');  //    mWinHTTP.SetRequestHeader('Content-Type', 'application/json; charset=CP1250'); //'); //mWinHTTP.SetRequestHeader('Accept', 'application/json; charset=UTF-8');
              mWinHTTP.Send(mJson);
              if mStatus then begin
                    //result:= FloatToStr(mWinHTTP.Status) + ' - '+mWinHTTP.ResponseText + ' - ' + mWinHTTP.StatusText ;
              end else begin
                    //result:= mWinHTTP.ResponseText;
              end;
        end;
      finally
      end;

end;



function POST_APISQL_String(AContext: TNxContext; Astring: string; APath: String): string;
var
  mWinHTTP: Variant;
  AOS: TNxCustomObjectSpace;
  mstring:string;
  mr:tstringlist;
  i: integer;
  mQuery:string;
  mTyp,mFields,mDotaz,mSeparator:string;
  AInput:TJSONSuperObject;
begin
  try
      AInput:=TJSONSuperObject.create;
      AInput:= TJSONSuperObject.ParseString(astring,true);
       mTyp := AInput.S['Typ'];
       mFields := AInput.S['Fields'];
       mDotaz := AInput.S['Dotaz'];

   if true then begin
       mr:=tstringlist.create;
       try
          AContext.SQLSelect(mtyp + ' ' + mFields + ' ' + mDotaz,mr);
          if mr.Count>0 then begin
             result:= mr.Strings[0] ;
          end;
       finally
           mr.free;
       end;
    end;
  finally

  end;
end;








function POST_APISQL_Strings(AContext: TNxContext; Astring: string; APath: String): string;
var
  mWinHTTP: Variant;
  AOS: TNxCustomObjectSpace;
  mstring:string;
  mr:tstringlist;
  i: integer;
  mQuery:string;
  mTyp,mFields,mDotaz,mSeparator:string;
  AInput:TJSONSuperObject;
  mParseFields,mParseValues:tstringlist;
begin
  try
      AInput:=TJSONSuperObject.create;
      AInput:= TJSONSuperObject.ParseString(astring,true);
       mTyp := AInput.S['Typ'];
       mFields := AInput.S['Fields'];
       mDotaz := AInput.S['Dotaz'];
       mParseFields:=TStringList.Create;
       try

   if true then begin
       mr:=tstringlist.create;
       try
          AContext.SQLSelect(mtyp + ' ' + mFields + ' ' + mDotaz,mr);
          if mr.Count>0 then begin
             for i:=0 to mr.count-1 do begin
                 result:= result + NxSearchReplace(mr.Strings[i],'"','',[srAll]) ;
                 if i<>mr.count-1 then result:= result +chr(13)+chr(10)
             end;
          end;
       finally
           mr.free;
       end;
    end;

    finally
       mParseFields.free;
    end;


  finally

  end;
end;


function POST_APISQL_Json(AContext: TNxContext; AInput: TJSONSuperObject; APath: String): TJSONSuperObject;
var
  mWinHTTP: Variant;
  AOS: TNxCustomObjectSpace;
  mstring:string;
  mr:tstringlist;
  i,x: integer;
  mQuery:string;
  mTyp,mField,mDotaz,mSeparator:string;
  mFields, mValues: Tstringlist;
begin
        result:=TJSONSuperObject.create;
  try

       mTyp := AInput.S['Typ'];
       mField := AInput.S['Fields'];
       mDotaz := AInput.S['Dotaz'];
        mSeparator := AInput.S['Separator'];

       mFields:=tstringlist.create;
       try
         mFields:=fnParsevalue(mField,',');

      //  NxShowSimpleMessage(inttostr(mFields.count),nil);


          mQuery:= '[';
       // mQuery:=mQuery + '{';
      //  mQuery:=mQuery + '[';

   if true then begin
       mr:=tstringlist.create;
       try
          AContext.SQLSelect(mtyp + ' ' + mField + ' ' + mDotaz,mr);
          if mr.Count>0 then begin
              for i:=0 to mr.count-1 do begin
                    mValues:=tstringlist.create;
                         try
                           mValues:=fnParsevalue(mr.Strings[i],';');


                            mQuery:=mQuery + '{';

                                         for x:=0 to mFields.Count-1 do begin
                                            mQuery:=mQuery + '"' + mFields.Strings[x] +'":"' + mValues.Strings[x] +'"' ;
                                            if x<>(mFields.count-1) then mQuery:=mQuery + ',';
                                         end;
                            mQuery:=mQuery + '}';
                            if i<>(mr.count-1) then mQuery:=mQuery + ',';
                        finally
                           mValues.free;
                        end;
              end;
          end;
       finally
           mr.free;
       end;
    end;
      //  mQuery:=mQuery + '"xxx":"' + 'AAAA' +'"' ;
     //   mQuery:=mQuery + '}';
            mQuery:=mQuery + ']';

      finally
          mFields.free;
      end;

        result:= TJSONSuperObject.ParseString(mQuery,true);

  finally

  end;
end;




 function POST_API_JSON(mSO: TNxCustomBusinessObject; mTyp: string;mUrl: string;mJSON:TJSONSuperObject;mStatus:Boolean):TJSONSuperObject;
var
  mWinHTTP: Variant;
  AOS: TNxCustomObjectSpace;
  mstring:string;
begin
  AOS := mSO.ObjectSpace;
  try
        result:=TJSONSuperObject.create;
         if GetHTTP(mWinHTTP) then begin
              mWinHTTP.Open(mTyp, mUrl );
             // NxShowSimpleMessage(mUrl + ' - ' + mJSON, nil);
              mWinHTTP.SetRequestHeader('Authorization', 'Basic QVBJX1N5bmNocm9uaXphY2U6YzNsdVkyaHliMjVwZW1GalpRPT0=');  //    mWinHTTP.SetRequestHeader('Content-Type', 'application/json; charset=CP1250'); //'); //mWinHTTP.SetRequestHeader('Accept', 'application/json; charset=UTF-8');
              mWinHTTP.Send(mJson);
               if mStatus then begin
                       if copy(inttostr(mWinHTTP.Status),1,1) ='2'  then begin
                                  result.S['Status']:=  FloatToStr(mWinHTTP.Status)   ;
                                  result.S['ResponseText']:=mWinHTTP.ResponseText;

                       end else begin
                            result.S['Status']:=  FloatToStr(mWinHTTP.Status)   ;
                                  result.S['StatusText']:=  mWinHTTP.StatusText     ;

                       end;
                end else begin
                                  result.S['Status']:=  FloatToStr(mWinHTTP.Status)   ;
                                  result.S['ResponseText']:=mWinHTTP.ResponseText;
               end;
           end;
      finally
      end;

end;




function POST_NewValueWithID(AContext: TNxContext; AInput: TJSONSuperObject; APath: String): TJSONSuperObject;
var
	mParams: TNxParameters;
	mApplication: Variant;
	mCond: TNxDynSQLConditionKind;
	mDynSQL, mDataset: Variant;
	mResult: Double;
	mInfoType: String;
  mSQL:string;
begin
	Result := TJSONSuperObject.Create;
	mInfoType := AInput.S['info_type'];
  mSQL:= AInput.S['mSQL'];
	if not NxIsBlank(mInfoType) then begin

    Result.I['Value'] := acontext.SQLExecute(msql);
//    Result.S['mInfoType'] := FloatToStr(mResult);
    Result.S['MSQL'] := mSQL;
    Result.S['aaa'] := 'aaa';
	end else begin
		RaiseException('Missing param info_type.');
	end;
end;


 // post dotaz API pmocí JSON



 // post dotaz API pmocí JSON
function CallRestApiNoerr(mSO: TNxCustomBusinessObject; mTyp: string;mUrl: string;mHead: string;mID: string;mRequest:string):string;
var
  mWinHTTP: Variant;
  AOS: TNxCustomObjectSpace;
begin
  AOS := mSO.ObjectSpace;
  try
         if GetHTTP(mWinHTTP) then begin
              mWinHTTP.Open(mTyp, mUrl +mHead +mid);      //   NxShowSimpleMessage(mTyp + ' - ' +mUrl +mHead +mid + mRequest, nil);
              mWinHTTP.SetRequestHeader('Authorization', 'Basic QVBJX1N5bmNocm9uaXphY2U6YzNsdVkyaHliMjVwZW1GalpRPT0=');
              //    mWinHTTP.SetRequestHeader('Content-Type', 'application/json; charset=CP1250'); //');
              mWinHTTP.SetRequestHeader('Accept', '*/*');
              mWinHTTP.SetRequestHeader('Accept-Encoding', 'gzip, deflate, br');
              mWinHTTP.SetRequestHeader('Connection', 'keep-alive');

              mWinHTTP.Send(mRequest);
          if  (mWinHTTP.Status <> 204) and (mWinHTTP.Status <> 200) and (mWinHTTP.Status <> 201) then begin     //              NxShowMessage('Response - SC', mWinHTTP.ResponseText, mdInformation, false, nil);
            //if NxGetActualUserID(AOS) <> 'AUTO000000' then begin
                  if mShowError then   NxShowMessage('API Status ', FloatToStr(mWinHTTP.Status) + ' - ' + mWinHTTP.StatusText, mdInformation, false, nil);
                  result:= FloatToStr(mWinHTTP.Status) + ' - ' + mWinHTTP.StatusText;
            //end;
          end else begin
             result:= mWinHTTP.ResponseText;
          end;
        end;
      finally
      end;
end;






function CallRestApiJSON(mSO: TNxCustomBusinessObject; mTyp: string;mUrl: string;mHead: string;mID: string;mRequest:string):TJSONSuperObject;
var
  mWinHTTP: Variant;
  AOS: TNxCustomObjectSpace;
  mdata:TJSONSuperObject;
begin
  AOS := mSO.ObjectSpace;
  try
        mData := TJSONSuperObject.Create;
         if GetHTTP(mWinHTTP) then begin
              mWinHTTP.Open(mTyp, mUrl +mHead +mid);      //   NxShowSimpleMessage(mTyp + ' - ' +mUrl +mHead +mid + mRequest, nil);
              mWinHTTP.SetRequestHeader('Authorization', 'Basic QVBJX1N5bmNocm9uaXphY2U6YzNsdVkyaHliMjVwZW1GalpRPT0=');
              //    mWinHTTP.SetRequestHeader('Content-Type', 'application/json; charset=CP1250'); //');
              mWinHTTP.SetRequestHeader('Accept', '*/*');
              mWinHTTP.SetRequestHeader('Accept-Encoding', 'gzip, deflate, br');
              mWinHTTP.SetRequestHeader('Connection', 'keep-alive');

              mWinHTTP.Send(mRequest);
          if  (mWinHTTP.Status <> 204) and (mWinHTTP.Status <> 200) and (mWinHTTP.Status <> 201) then begin     //              NxShowMessage('Response - SC', mWinHTTP.ResponseText, mdInformation, false, nil);
            //if NxGetActualUserID(AOS) <> 'AUTO000000' then begin
             // if mShowError then NxShowMessage('API Status ', FloatToStr(mWinHTTP.Status) + ' - ' + mWinHTTP.StatusText, mdInformation, false, nil);
              mData.S['_NrState'] := mWinHTTP.Status;
              mData.S['State_text'] := mWinHTTP.StatusText;
              mData.S['Text'] := mWinHTTP.ResponseText;
              result:=mdata;



            //end;
          end else begin
              mData.S['_NrState'] := mWinHTTP.Status;
              mData.S['State_text'] := mWinHTTP.StatusText;
              mData.S['Text'] := mWinHTTP.ResponseText;
              result:=mdata;
          end;
        end;
      finally

      mdata.free;
      end;
end;




function CallRestApi1(mSO: TNxCustomBusinessObject; mTyp: string;mUrl: string;mHead: string;mID: string;mRequest:string):string;
var
  mWinHTTP: Variant;
  AOS: TNxCustomObjectSpace;
begin
  AOS := mSO.ObjectSpace;
  try
         if GetHTTP(mWinHTTP) then begin
              mWinHTTP.Open(mTyp, mUrl +mHead +mid);      //   NxShowSimpleMessage(mTyp + ' - ' +mUrl +mHead +mid + mRequest, nil);
              mWinHTTP.SetRequestHeader('Authorization', 'Basic QVBJX1N5bmNocm9uaXphY2U6YzNsdVkyaHliMjVwZW1GalpRPT0=');
              //    mWinHTTP.SetRequestHeader('Content-Type', 'application/json; charset=CP1250'); //');
              mWinHTTP.SetRequestHeader('Accept', '*/*');
              mWinHTTP.SetRequestHeader('Accept-Encoding', 'gzip, deflate, br');
              mWinHTTP.SetRequestHeader('Connection', 'keep-alive');

              mWinHTTP.Send(mRequest);
          if  (mWinHTTP.Status <> 204) and (mWinHTTP.Status <> 200) and (mWinHTTP.Status <> 201) then begin     //              NxShowMessage('Response - SC', mWinHTTP.ResponseText, mdInformation, false, nil);
            //if NxGetActualUserID(AOS) <> 'AUTO000000' then begin
             // if mShowError then NxShowMessage('API Status ', FloatToStr(mWinHTTP.Status) + ' - ' + mWinHTTP.StatusText, mdInformation, false, nil);
              result:= FloatToStr(mWinHTTP.Status) + ' - ' + mWinHTTP.StatusText + mWinHTTP.ResponseText;
            //end;
          end else begin
             result:= FloatToStr(mWinHTTP.Status) + ' - ' + mWinHTTP.StatusText + mWinHTTP.ResponseText;
          end;
        end;
      finally
      end;
end;













// post dotaz API pmocí JSON
function CallRestApi(mSO: TNxCustomBusinessObject; mTyp: string;mUrl: string;mHead: string;mID: string;mRequest:string):string;
var
  mWinHTTP: Variant;
  AOS: TNxCustomObjectSpace;
begin
  AOS := mSO.ObjectSpace;
  try
         if GetHTTP(mWinHTTP) then begin
              mWinHTTP.Open(mTyp, mUrl +mHead +mid);      //   NxShowSimpleMessage(mTyp + ' - ' +mUrl +mHead +mid + mRequest, nil);
              mWinHTTP.SetRequestHeader('Authorization', 'Basic QVBJX1N5bmNocm9uaXphY2U6YzNsdVkyaHliMjVwZW1GalpRPT0=');
              //    mWinHTTP.SetRequestHeader('Content-Type', 'application/json; charset=CP1250'); //');
              mWinHTTP.SetRequestHeader('Accept', '*/*');
              mWinHTTP.SetRequestHeader('Accept-Encoding', 'gzip, deflate, br');
              mWinHTTP.SetRequestHeader('Connection', 'keep-alive');

              mWinHTTP.Send(mRequest);
          if  (mWinHTTP.Status <> 204) and (mWinHTTP.Status <> 200) and (mWinHTTP.Status <> 201) then begin     //              NxShowMessage('Response - SC', mWinHTTP.ResponseText, mdInformation, false, nil);
            //if NxGetActualUserID(AOS) <> 'AUTO000000' then begin
              //if mShowError then NxShowMessage('API Status ', FloatToStr(mWinHTTP.Status) + ' - ' + mWinHTTP.StatusText, mdInformation, false, nil);
              result:= FloatToStr(mWinHTTP.Status) + ' - ' + mWinHTTP.StatusText + mWinHTTP.ResponseText;
            //end;
          end else begin
             result:= mWinHTTP.ResponseText;
          end;
        end;
      finally
      end;
end;

// otevření API
function GetHTTP(var WinHttpRequest: Variant): Boolean;
begin
  try
    if not VarIsType(WinHttpRequest, varDispatch) then begin
      WinHttpRequest := CreateOleObject('WinHttp.WinHttpRequest.5.1');
    end;
    Result:=True;
  except
    Result := False;
    OutputDebugString(ExceptionMessage);
    WinHttpRequest := nil;
  end;
end;

procedure StorQuantityAPI (OS: TNxCustomObjectSpace;  var Success: Boolean; var LogInfoStr: String);
Var
mQueryID:string;
  mID:string;
  mNewQueryID:string;
  mSQL:string;
  i,ii,iii:integer;
  mTarget:string;
  mr1:tstringlist;
  astring:string;
  mr:TStringList;
  mString:string;
  mNewQuery:string;
  mJSON: TJSONSuperObject;
  mBO: TNxCustomBusinessObject;
  mQuery:string;
  mpomoc:double;
  mQuantity , mLowLimit,mHighLimit:string;
begin
  Success := True;
  LogInfoStr := '';
             mTarget:=mTargetAPI + '/';

   mr:=tstringlist.create;
   try
       os.SQLSelect('SELECT id FROM StoreCards A WHERE (( ((0 = 1) AND ((A.StoreMenuItem_ID = (select Bx.ID from StoreMenu Bx where Bx.ID = (' + QuotedStr('2L40000101') + ') and Bx.Hidden = ' + quotedstr('N')
       + ')) or (1 = 1 AND (A.StoreMenuItem_ID in (select Bx.ID from StoreMenu Bx where Bx.ID in (select B2x.ID from SYS$StoreMenu2 B2x where B2x.Superior_ID = (' + QuotedStr('2L40000101') + ')) and  Bx.Hidden = ' + quotedstr('N') +
       '))  ))) OR ((0 = 0) AND (   (A.ID IN (Select SL.StoreCard_ID from StoreCardMenuItemLinks SL where SL.StoreMenuItem_ID = (' + QuotedStr('2L40000101')
       + '))) OR    (1 = 1 AND     (A.ID IN (Select SL.StoreCard_ID from StoreCardMenuItemLinks SL where SL.StoreMenuItem_ID IN (Select B2x.ID from SYS$StoreMenu2 B2x where B2x.Superior_ID = ('+quotedstr('2L40000101')
       + ')))) ) )) ) ) AND (A.Hidden = ' + QuotedStr('N') + ' ) AND ( ( A.X_synchronizace_ID LIKE '+QuotedStr('__1%') + ' ) )',mr);

      if mr.count>0 then begin
                   mBO:= os.CreateObject('C3V5QDVZ5BDL342M01C0CX3FCC');
                   try;
                    for i:=0 to mr.count-1 do begin
                        mQuantity:='0';
                        mHighLimit:='0';
                        mLowLimit:='0';
                        mbo.Load(mr.Strings[i],nil);
                        mpomoc:=0;
                        if mTarget<>msource then begin
                                   mQuery:='{}';
                                      mQueryID:='{'
                                            + ' "class": "' + 'StoreSubCards' +'",'
                                            +' "select": ["sum(quantity)"],'
                                            + ' "where": "(StoreCard_ID = ' + QuotedStr(mBO.GetFieldValueAsString('ID')) + ') AND (Store_ID = ' + QuotedStr('6131000101')  +')'
                                            +' " '
                                            +'}';
                                            mString:= APICallRest(mBO,'Post',mtarget,'query','',mQueryID,true);
                                                     if (copy(mString,1,3)='200') or (copy(mString,1,3)='201') then begin
                                                          mString:=copy(mstring,25,20);
                                                          mQuantity:= copy(mstring,1, Length(mstring)-7);
                                                      end else begin
                                                                //NxShowSimpleMessage('Chyba v přístupu k api' + mString,nil);
                                                          iSendmsgx(os,
                                                                  ' API Error ' + 'Storecards' ,     // popis
                                                                   mString  + '      Post'+mtarget+'query'+''+mQueryID,                          // tělo
                                                                   mToMSG ,                      // komu
                                                                   '1L20000101'); // kdo
                                                                mID:='';
                                                                LogInfoStr :=   LogInfoStr + 'Chyba ' + chr(13)  +chr(10) +  mbo.oid + ' -' +mbo.GetFieldValueAsString('Name')
                                                                                         + ' z hodnoty ' + NxFloatToIBStr(mpomoc) + ' na ' + mstring   ;
                                                                Success := False;
                                                                //exit;
                                                      end;

                                mQuery:='{}';
                                      mQueryID:='{'
                                            + ' "class": "' + 'StoreSubCards' +'",'
                                            +' "select": ["sum(LowLimitQuantity)"],'
                                            + ' "where": " (StoreCard_ID = ' + QuotedStr(mBO.GetFieldValueAsString('ID')) + ') AND (Store_ID = ' + QuotedStr('6131000101')  +')'
                                            +' " '
                                            +'}';
                                            mString:= APICallRest(mBO,'Post',mtarget,'query','',mQueryID,true);

                                                     if (copy(mString,1,3)='200') or (copy(mString,1,3)='201') then begin
                                                          mString:=copy(mstring,33,20);
                                                          mLowLimit:= copy(mstring,1, Length(mstring)-7);

                                                      end else begin
                                                                //NxShowSimpleMessage('Chyba v přístupu k api' + mString,nil);
                                                          iSendmsgx(os,
                                                                  ' API Error ' + 'Storecards' ,     // popis
                                                                   mString  + '      Post'+mtarget+'query'+''+mQueryID,                          // tělo
                                                                   mToMSG ,                      // komu
                                                                   '1L20000101'); // kdo
                                                                mID:='';
                                                                LogInfoStr :=   LogInfoStr + 'Chyba ' + chr(13)  +chr(10) +  mbo.oid + ' -' +mbo.GetFieldValueAsString('Name')
                                                                                         + ' na ' + mLowLimit   ;
                                                                Success := False;
                                                                //exit;
                                                      end;


                                 mQuery:='{}';
                                      mQueryID:='{'
                                            + ' "class": "' + 'StoreSubCards' +'",'
                                            +' "select": ["sum(HighLimitQuantity)"],'
                                            + ' "where": " (StoreCard_ID = ' + QuotedStr(mBO.GetFieldValueAsString('ID'))  + ') AND (Store_ID = ' + QuotedStr('6131000101')  +')'
                                            +' " '
                                            +'}';
                                            mString:= APICallRest(mBO,'Post',mtarget,'query','',mQueryID,true);
                                                     if (copy(mString,1,3)='200') or (copy(mString,1,3)='201') then begin
                                                          mString:=copy(mstring,34,20);
                                                          mHighLimit:= copy(mstring,1, Length(mstring)-7);

                                                      end else begin
                                                                //NxShowSimpleMessage('Chyba v přístupu k api' + mString,nil);
                                                          iSendmsgx(os,
                                                                  ' API Error ' + 'Storecards' ,     // popis
                                                                   mString  + '      Post'+mtarget+'query'+''+mQueryID,                          // tělo
                                                                   mToMSG ,                      // komu
                                                                   '1L20000101'); // kdo
                                                                mID:='';
                                                                LogInfoStr :=   LogInfoStr + 'Chyba ' + chr(13)  +chr(10) +  mbo.oid + ' -' +mbo.GetFieldValueAsString('Name')
                                                                                        + ' na ' + mHighLimit   ;
                                                                Success := False;
                                                                //exit;
                                                      end;





                                                          if (mbo.getFieldValueAsFloat('X_SK_quantity')<> NxIBStrToFloat(mQuantity))
                                                                or  (mbo.getFieldValueAsFloat('X_SK_LowLimit')<> NxIBStrToFloat(mLowLimit))
                                                                or  (mbo.getFieldValueAsFloat('X_SK_HighLimit')<> NxIBStrToFloat(mHighLimit))
                                                              then begin
                                                                 LogInfoStr :=   LogInfoStr + chr(13)  +chr(10) + '*** Upraveno ' + mbo.oid + ' -' + mbo.GetFieldValueAsString('Name') ;
                                                                   if (mbo.getFieldValueAsFloat('X_SK_quantity')<> NxIBStrToFloat(mQuantity)) then begin
                                                                        mbo.SetFieldValueAsFloat('X_SK_quantity', NxIBStrToFloat(mQuantity))  ;
                                                                        LogInfoStr :=   LogInfoStr + ' množství : '  + (mQuantity) + ','  ;
                                                                   end;
                                                                   if (mbo.getFieldValueAsFloat('X_SK_LowLimit')<> NxIBStrToFloat(mLowLimit)) then begin
                                                                        mbo.SetFieldValueAsFloat('X_SK_LowLimit', NxIBStrToFloat(mLowLimit))  ;
                                                                        LogInfoStr :=   LogInfoStr + ' spodní : '  + (mLowLimit) + ','  ;
                                                                   end;
                                                                   if (mbo.getFieldValueAsFloat('X_SK_HighLimit')<> NxIBStrToFloat(mHighLimit)) then begin
                                                                        mbo.SetFieldValueAsFloat('X_SK_HighLimit', NxIBStrToFloat(mHighLimit))  ;
                                                                        LogInfoStr :=   LogInfoStr + ' horní : '  + (mHighLimit) + ','  ;
                                                                   end;
                                                                   mbo.save;

                                                              mIKUprave:=mIKUprave + 1;
                                                           end else begin
                                                                LogInfoStr :=  LogInfoStr + chr(13)  +chr(10) + '*** Nezměněno ' + mbo.oid + ' -' +mbo.GetFieldValueAsString('Name');

                                                          end;



                        end;
                    end;
                 finally
                     mbo.free;
                 end;
     end;
   finally
       mr.free;
   end;
   LogInfoStr :=  chr(13) + LogInfoStr +  ' Upravených ' + inttostr(mIKUprave) + ' záznamů ';

end;


procedure StoreSubQuantityAPI (OS: TNxCustomObjectSpace;  var Success: Boolean; var LogInfoStr: String);
Var
mQueryID:string;
  mID:string;
  mNewQueryID:string;
  mSQL:string;
  i,ii,iii:integer;
  mTarget:string;
  mr1:tstringlist;
  astring:string;
  mr:TStringList;
  mString:string;
  mNewQuery:string;
  mJSON: TJSONSuperObject;
  mBO: TNxCustomBusinessObject;
  mQuery:string;
  mpomoc:double;
  mQuantity , mLowLimit,mHighLimit:string;
begin
  Success := True;
  LogInfoStr := '';
             mTarget:=mTargetAPI + '/';

   mr:=tstringlist.create;
   try
       os.SQLSelect('SELECT SSC.id from Storesubcards SSC join Stores S on (SSC.Store_ID=s.id) AND (s.Hidden = ' + QuotedStr('N') + ' ) AND (  s.X_synchronizace_ID LIKE '+QuotedStr('__1%') +') join StoreCards A on (ssc.Storecard_ID=a.id) AND (A.Hidden = ' + QuotedStr('N') + ' ) AND (A.X_synchronizace_ID LIKE '+QuotedStr('__1%') + ' )   WHERE (( ((0 = 1) AND ((A.StoreMenuItem_ID = (select Bx.ID from StoreMenu Bx where Bx.ID = (' + QuotedStr('2L40000101') + ') and Bx.Hidden = ' + quotedstr('N')
       + ')) or (1 = 1 AND (A.StoreMenuItem_ID in (select Bx.ID from StoreMenu Bx where Bx.ID in (select B2x.ID from SYS$StoreMenu2 B2x where B2x.Superior_ID = (' + QuotedStr('2L40000101') + ')) and  Bx.Hidden = ' + quotedstr('N') +
       '))  ))) OR ((0 = 0) AND (   (A.ID IN (Select SL.StoreCard_ID from StoreCardMenuItemLinks SL where SL.StoreMenuItem_ID = (' + QuotedStr('2L40000101')
       + '))) OR    (1 = 1 AND     (A.ID IN (Select SL.StoreCard_ID from StoreCardMenuItemLinks SL where SL.StoreMenuItem_ID IN (Select B2x.ID from SYS$StoreMenu2 B2x where B2x.Superior_ID = ('+quotedstr('2L40000101')
       + ')))) ) )) ) )',mr);

      if mr.count>0 then begin
                   mBO:= os.CreateObject('GAWVAN4GFNDL342T01C0CX3FCC');
                   try;
                    for i:=0 to mr.count-1 do begin
                        mQuantity:='0';
                        mHighLimit:='0';
                        mLowLimit:='0';
                        mbo.Load(mr.Strings[i],nil);
                        mpomoc:=0;
                        if mTarget<>msource then begin
                                   mQuery:='{}';
                                      mQueryID:='{'
                                            + ' "class": "' + 'StoreSubCards' +'",'
                                            +' "select": ["sum(quantity)"],'
                                            + ' "where": " StoreCard_ID = ' + QuotedStr(mBO.GetFieldValueAsString('Storecard_ID')) + ' AND Store_ID = ' + QuotedStr(mBO.GetFieldValueAsString('Store_ID'))
                                            +' " '
                                            +'}';
                                            mString:= APICallRest(mBO,'Post',mtarget,'query','',mQueryID,true);
                                                     if (copy(mString,1,3)='200') or (copy(mString,1,3)='201') then begin
                                                          mString:=copy(mstring,25,20);
                                                          mQuantity:= copy(mstring,1, Length(mstring)-7);
                                                      end else begin
                                                                //NxShowSimpleMessage('Chyba v přístupu k api' + mString,nil);
                                                          iSendmsgx(os,
                                                                  ' API Error ' + 'StoreSubcards' ,     // popis
                                                                   mString  + '      Post'+mtarget+'query'+''+mQueryID,                          // tělo
                                                                   mToMSG ,                      // komu
                                                                   '1L20000101'); // kdo
                                                                mID:='';
                                                                LogInfoStr :=   LogInfoStr + 'Chyba ' + chr(13)  +chr(10) +  mbo.oid + ' -' +mbo.GetFieldValueAsString('Name')
                                                                                         + ' z hodnoty ' + NxFloatToIBStr(mpomoc) + ' na ' + mstring   ;
                                                                Success := False;
                                                                //exit;
                                                      end;

                                mQuery:='{}';
                                      mQueryID:='{'
                                            + ' "class": "' + 'StoreSubCards' +'",'
                                            +' "select": ["sum(LowLimitQuantity)"],'
                                            + ' "where": " StoreCard_ID = ' + QuotedStr(mBO.GetFieldValueAsString('Storecard_ID')) + ' AND Store_ID = ' + QuotedStr(mBO.GetFieldValueAsString('Store_ID'))
                                            +' " '
                                            +'}';
                                            mString:= APICallRest(mBO,'Post',mtarget,'query','',mQueryID,true);

                                                     if (copy(mString,1,3)='200') or (copy(mString,1,3)='201') then begin
                                                          mString:=copy(mstring,33,20);
                                                          mLowLimit:= copy(mstring,1, Length(mstring)-7);

                                                      end else begin
                                                                //NxShowSimpleMessage('Chyba v přístupu k api' + mString,nil);
                                                          iSendmsgx(os,
                                                                  ' API Error ' + 'StoreSubcards' ,     // popis
                                                                   mString  + '      Post'+mtarget+'query'+''+mQueryID,                          // tělo
                                                                   mToMSG ,                      // komu
                                                                   '1L20000101'); // kdo
                                                                mID:='';
                                                                LogInfoStr :=   LogInfoStr + 'Chyba ' + chr(13)  +chr(10) +  mbo.oid + ' -' +mbo.GetFieldValueAsString('Name')
                                                                                         + ' na ' + mLowLimit   ;
                                                                Success := False;
                                                                //exit;
                                                      end;


                                 mQuery:='{}';
                                      mQueryID:='{'
                                            + ' "class": "' + 'StoreSubCards' +'",'
                                            +' "select": ["sum(HighLimitQuantity)"],'
                                            + ' "where": " StoreCard_ID = ' + QuotedStr(mBO.GetFieldValueAsString('Storecard_ID')) + ' AND Store_ID = ' + QuotedStr(mBO.GetFieldValueAsString('Store_ID'))
                                            +' " '
                                            +'}';
                                            mString:= APICallRest(mBO,'Post',mtarget,'query','',mQueryID,true);
                                                     if (copy(mString,1,3)='200') or (copy(mString,1,3)='201') then begin
                                                          mString:=copy(mstring,34,20);
                                                          mHighLimit:= copy(mstring,1, Length(mstring)-7);

                                                      end else begin
                                                                //NxShowSimpleMessage('Chyba v přístupu k api' + mString,nil);
                                                          iSendmsgx(os,
                                                                  ' API Error ' + 'StoreSubcards' ,     // popis
                                                                   mString  + '      Post'+mtarget+'query'+''+mQueryID,                          // tělo
                                                                   mToMSG ,                      // komu
                                                                   '1L20000101'); // kdo
                                                                mID:='';
                                                                LogInfoStr :=   LogInfoStr + 'Chyba ' + chr(13)  +chr(10) +  mbo.oid + ' -' +mbo.GetFieldValueAsString('Name')
                                                                                        + ' na ' + mHighLimit   ;
                                                                Success := False;
                                                                //exit;
                                                      end;





                                                          if (mbo.getFieldValueAsFloat('X_quantity')<> NxIBStrToFloat(mQuantity))
                                                                or  (mbo.getFieldValueAsFloat('X_LowLimit')<> NxIBStrToFloat(mLowLimit))
                                                                or  (mbo.getFieldValueAsFloat('X_HighLimit')<> NxIBStrToFloat(mHighLimit))
                                                              then begin
                                                                 LogInfoStr :=   LogInfoStr + chr(13)  +chr(10) + '*** Upraveno ' + mbo.oid + ' -' + mbo.GetFieldValueAsString('Storecard_ID.Name') ;
                                                                   if (mbo.getFieldValueAsFloat('X_quantity')<> NxIBStrToFloat(mQuantity)) then begin
                                                                        mbo.SetFieldValueAsFloat('X_quantity', NxIBStrToFloat(mQuantity))  ;
                                                                        LogInfoStr :=   LogInfoStr + ' množství : '  + (mQuantity) + ','  ;
                                                                   end;
                                                                   if (mbo.getFieldValueAsFloat('X_LowLimit')<> NxIBStrToFloat(mLowLimit)) then begin
                                                                        mbo.SetFieldValueAsFloat('X_LowLimit', NxIBStrToFloat(mLowLimit))  ;
                                                                        LogInfoStr :=   LogInfoStr + ' spodní : '  + (mLowLimit) + ','  ;
                                                                   end;
                                                                   if (mbo.getFieldValueAsFloat('X_HighLimit')<> NxIBStrToFloat(mHighLimit)) then begin
                                                                        mbo.SetFieldValueAsFloat('X_HighLimit', NxIBStrToFloat(mHighLimit))  ;
                                                                        LogInfoStr :=   LogInfoStr + ' horní : '  + (mHighLimit) + ','  ;
                                                                   end;
                                                                   mbo.save;

                                                              mIKUprave:=mIKUprave + 1;
                                                           end else begin
                                                                LogInfoStr :=  LogInfoStr + chr(13)  +chr(10) + '*** Nezměněno ' + mbo.oid + ' -' +mbo.GetFieldValueAsString('Storecard_ID.Name');

                                                          end;



                        end;
                    end;
                 finally
                     mbo.free;
                 end;
     end;
   finally
       mr.free;
   end;
   LogInfoStr :=  chr(13) + LogInfoStr +  ' Upravených ' + inttostr(mIKUprave) + ' záznamů ';

end;




function API_GetOrCreateBatch(mSite:TSiteForm;mApiTArget:string;mBatch_ID:String):string;
var
mQueryID:string;
mNewQueryID :string;
mString :string;
mBatchBO:TNxCustomBusinessObject;

begin
result:='';
mBatchBO:=mSite.BaseObjectSpace.CreateObject('C32QXZWCTVDL342W01C0CX3FCC')   ;
      try
         if mBatch_ID<>'' then begin
             mBatchBo.load(mBatch_ID,nil);
                  mQueryID:='{ "class": "' + 'StoreBatches' +'", "select": ["ID",], "where": " Name = ' + QuotedStr(mBatchBo.GetFieldValueAsString('name')) +' and Storecard_ID=' +  QuotedStr(mBatchBo.GetFieldValueAsString('Storecard_ID')) + '" }';
                   mString:=APICallRest(mBatchBO,'Post',mApiTArget,'query','',mQueryID,True);
                   //NxShowSimpleMessage('AAA .' +copy(mString,10,2) +'.'+  copy(mString,15,10),nil);
                   if (copy(mString,1,3)='200')  then begin      // korektní odpověď
                          if copy(mString,10,2)='ID' then begin      // záznam namezen
                                   result:= copy(mString,15,10);
                                         //NxShowSimpleMessage('Šarže v cíli '  +  mid,nil);

                           end else begin
                                  //NxShowSimpleMessage('Šarže v cíli nenalezena - zakládám' ,nil);
                                  // ********    založení šarže
                                        mNewQueryID:='{'
                                            +' "serialnumber": false, '
                                            +'               "storecard_id": "' + mBatchBo.GetFieldValueAsString('storecard_id') + '", '
                                            +'               "name": "' + mBatchBo.GetFieldValueAsString('name') + '", '
                                            +'               "specification": "' + mBatchBo.GetFieldValueAsString('specification') + '", '
                                            +'               "x_verze": "' + mBatchBo.GetFieldValueAsString('x_verze') + '", '
                                            +'               "ExpirationDate$DATE":"' +FormatDateTime('YYYY-MM-DD',mBatchBo.GetFieldValueAsDateTime('ExpirationDate$DATE')) +'", '
                                            +'               "productiondate$date":"' +FormatDateTime('YYYY-MM-DD',mBatchBo.GetFieldValueAsDateTime('productiondate$date')) +'", '

                                            +'               "X_parent_ID": "' + mBatchBo.GetFieldValueAsString('X_parent_ID') + '", '
                                            +'               "X_Specifikace_order": "' + mBatchBo.GetFieldValueAsString('X_Specifikace_order') + '", '
                                            +'               "X_MAT1": "' + mBatchBo.GetFieldValueAsString('X_MAT1') + '", '
                                            +'               "X_MAT2": "' + mBatchBo.GetFieldValueAsString('X_MAT2') + '", '
                                            +'               "X_MAT3": "' + mBatchBo.GetFieldValueAsString('X_MAT3') + '", '
                                            +'               "X_MAT4": "' + mBatchBo.GetFieldValueAsString('X_MAT4') + '", '
                                            +'               "X_MAT5": "' + mBatchBo.GetFieldValueAsString('X_MAT5') + '", '
                                            +'               "X_MAT1_PROC": "' + inttostr(mBatchBo.GetFieldValueAsInteger('X_MAT1_PROC')) + '", '
                                            +'               "X_MAT2_PROC": "' + inttostr(mBatchBo.GetFieldValueAsInteger('X_MAT2_PROC')) + '", '
                                            +'               "X_MAT3_PROC": "' + inttostr(mBatchBo.GetFieldValueAsInteger('X_MAT3_PROC')) + '", '
                                            +'               "X_MAT4_PROC": "' + inttostr(mBatchBo.GetFieldValueAsInteger('X_MAT4_PROC')) + '", '
                                            +'               "X_MAT5_PROC": "' + inttostr(mBatchBo.GetFieldValueAsInteger('X_MAT5_PROC')) + '", '
                                             +'}';



                                        // *** kontrola json    mstring:=                      inputbox('Šarže','POST' + '   ' + mtarget+StoreBatches+' ,mNewQueryID)    ;
                                        mString:= APICallRest(mBatchBO,'post',mApiTArget,'StoreBatches','' ,mNewQueryID,True);
//                                        NxShowSimpleMessage('Kontrola stavu založení šarže' + copy(mstring,1,3) , nil);
                                        if (copy(mString,1,3)='201') then begin   // stav založení
                                                    mQueryID:='{ "class": "' + 'StoreBatches' +'", "select": ["ID",], "where": " Name = ' + QuotedStr(mBatchBo.GetFieldValueAsString('name')) +' and Storecard_ID=' +  QuotedStr(mBatchBo.GetFieldValueAsString('storecard_id')) + '" }';

                                                    mString:= copy(APICallRest(mBatchBO,'Post',mApiTArget,'query','',mQueryID,false),9,10);
                                                    if copy(mString,10,2)='ID' then result:= copy(mString,15,10);
                                        end else begin
                                                          NxShowSimpleMessage('Chyba v přístupu k api' + mString,nil);
                                                          result:='';
                                                          exit;
                                        end;
                            end;
                   end else begin
                        NxShowSimpleMessage('Chyba v přístupu k api' + mString,nil);
                        result:='';
                        exit;
                   end;
         end;
      finally
         mBatchBO.free;
      end;

end;


function APICallExactstring(mSO: TNxCustomBusinessObject; mTyp: string;mUrl: string;mHead: string;mID: string;mRequest:string;mStatus:Boolean):TJSONSuperObject;
var
  mWinHTTP: Variant;
  AOS: TNxCustomObjectSpace;
  mdata:TJSONSuperObject;
  mRequest1:string;
begin
  AOS := mSO.ObjectSpace;
    try
         if GetHTTP(mWinHTTP) then begin
              mWinHTTP.Open(mTyp, mUrl +mHead +mid);      //   NxShowSimpleMessage(mTyp + ' - ' +mUrl +mHead +mid + mRequest, nil);
              mWinHTTP.SetRequestHeader('Authorization', 'Basic bGlwbzphUWFrN0ZTRg==');
              mWinHTTP.SetRequestHeader('Content-Type', 'application/json');
              //mWinHTTP.SetRequestHeader('Accept', '*/*');
              ///mWinHTTP.SetRequestHeader('Accept-Encoding', 'gzip, deflate, br');
              //mWinHTTP.SetRequestHeader('Connection', 'keep-alive');
              mWinHTTP.Send(mRequest);
              if mStatus then begin
                    //result:= FloatToStr(mWinHTTP.Status) + ' - '+mWinHTTP.success + ' - ' + mWinHTTP.StatusText ;
                    result := TJSONSuperObject.ParseString(mWinHTTP.ResponseText, True);
              end else begin
                    //result:= mWinHTTP.ResponseText;
                    result := TJSONSuperObject.ParseString(mWinHTTP.ResponseText, True);
              end;
         end;
    finally
    end;
end;





function APICallExact(mSO: TNxCustomBusinessObject; mTyp: string;mUrl: string;mHead: string;mID: string;mRequest:TJSONSuperObject;mStatus:Boolean):TJSONSuperObject;
var
  mWinHTTP: Variant;
  AOS: TNxCustomObjectSpace;
  mdata:TJSONSuperObject;
  mRequest1:string;
begin
  AOS := mSO.ObjectSpace;
    try
         if GetHTTP(mWinHTTP) then begin
              mWinHTTP.Open(mTyp, mUrl +mHead +mid);      //   NxShowSimpleMessage(mTyp + ' - ' +mUrl +mHead +mid + mRequest, nil);
              mWinHTTP.SetRequestHeader('Authorization', 'Basic bGlwbzphUWFrN0ZTRg==');
              mWinHTTP.SetRequestHeader('Content-Type', 'application/json');
              //mWinHTTP.SetRequestHeader('Accept', '*/*');
              ///mWinHTTP.SetRequestHeader('Accept-Encoding', 'gzip, deflate, br');
              //mWinHTTP.SetRequestHeader('Connection', 'keep-alive');

              //mRequest.AsString;
              //NxShowSimpleMessage(mRequest.S['countryCode'],nil);
              //NxShowSimpleMessage(NxFloatToIBStr(mRequest.D['orderNumber']),nil);
              //NxShowSimpleMessage(inttostr(mRequest.i['state']),nil);
              mWinHTTP.Send(mRequest);
              //NxShowSimpleMessage('Odesláno',nil);
              if mStatus then begin
                    //result:= FloatToStr(mWinHTTP.Status) + ' - '+mWinHTTP.success + ' - ' + mWinHTTP.StatusText ;

                    result := TJSONSuperObject.ParseString(mWinHTTP.ResponseText, True);

              end else begin
                    //result:= mWinHTTP.ResponseText;
                    result := TJSONSuperObject.ParseString(mWinHTTP.ResponseText, True);
              end;
         end;
    finally
    end;
end;


begin
end.