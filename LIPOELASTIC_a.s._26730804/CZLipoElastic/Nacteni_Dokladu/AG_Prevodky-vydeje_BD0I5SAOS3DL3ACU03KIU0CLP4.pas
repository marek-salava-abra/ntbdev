uses '_Knihovny_ALL.head', '_Knihovny_ALL.Progress','_Knihovny_ALL.Parse',
'abra.eu.mask_import.2018.Objednavka_prijata' ,'Nacteni_Dokladu.lib'
;




procedure InsertDoc(Sender: TComponent;index:integer);
var
  mSite: TSiteForm;
  mControl: TControl;
  mDataset: TNxRowsObjectDataSet;
  mRow: TNxCustomBusinessObject;
  mvalue:TStringList;
  mStoreCard_ID, mBatch_ID,mstring,mInputString:string;
  mQuantity:double;
  mboolean:Boolean;
  mGRows:TMultiGrid;
  mList:TStringList;
  mfind,mFindBatch:boolean;
  mImportFile:tstringlist;
  mstringline:string;
  mMon,mBO_Batches: TNxCustomBusinessMonikerCollection;
  mStore_ID,mDivision_ID,mBusProject_id,mBusOrder_ID,mAdress_ID:string;
  mHead:TNxHeaderBusinessObject;
  mIDs_dDocument:string;
  mIRadku , mIKusu,mIsarzi:double;
  mr:tstringlist;
  mQuantityBatch:double;
  mBO_PohybSarze:TNxCustomBusinessObject;
  mi:integer;
begin
    mIRadku:=0;
    mIKusu:=0;
    mIsarzi:=0;

    mAdress_ID:='';
    mSite := NxFindSiteForm(Sender);
    mHead:=TNxHeaderBusinessObject(TDynSiteForm(msite).CurrentObject.clone);
    mHead.setFieldValueAsString('Address_id','FSR4000101');
    try
    mStore_ID:='';
    mDivision_ID:='';
    mBusProject_id:='';
    mBusOrder_ID:='';
    //NxShowSimpleMessage(inttostr(index),nil);
    mMon := mHead.GetLoadedCollectionMonikerForFieldCode(mhead.GetFieldCode('ROWS'));
            for i := 0 to mMon.Count-1 do begin
                                if mStore_ID='' then begin
                                      mStore_ID:=mMon.BusinessObject[i].GetFieldValueAsstring('Store_ID');
                                      mDivision_ID:=mMon.BusinessObject[i].GetFieldValueAsstring('Division_ID');
                                      mBusProject_id:=mMon.BusinessObject[i].GetFieldValueAsstring('BusProject_id');
                                      mBusOrder_ID:=mMon.BusinessObject[i].GetFieldValueAsstring('BusOrder_ID');
                                end;
                                mMon.BusinessObject[i].MarkForDelete;

            end;
                    //mIDs_dDocument:=BarCode_document(mSite,'05CPMINJW3DL342X01C0CX3FCC',0,0,720,960, 'Obsah potvrzení','Položky : ','','Pokračovat','','');;

            If index=0 then begin
                    mImportFile:=TStringList.create;
                              ParsevalueRow(BarCode_document(mSite,'05CPMINJW3DL342X01C0CX3FCC',0,0,720,960, 'Obsah potvrzení','Položky : ','','Pokračovat','',''), chr(10),mImportFile);
                              ProgressInit(msite, 'Načítání dat ' + '', 100);
                              for i:=0 to mImportFile.Count-1 do begin   // načtení souboru

                                        ProgressSetPos(1+NxFloor((i/mImportFile.Count)*99), inttostr(i) +' z '+inttostr(mImportFile.Count));
                                        mstringline:= mImportFile.strings[i];
                                        if trim(mstringline)<>'' then begin
                                            mvalue:=tstringlist.create;
                                               try
                                                   //NxShowSimpleMessage(mImportFile.strings[i],nil);
                                                   ParsevalueRow(mstringline, chr(09),mvalue);

                                                     if mvalue.count>=3 then begin
                                                            //NxShowSimpleMessage(mvalue.strings[0],nil);
                                                            //NxShowSimpleMessage(,nil);
                                                            //NxShowSimpleMessage(copy(trim(mvalue.Strings[2]),1,AnsiPos(' ',trim(mvalue.Strings[2]))),nil);
                                                           mstorecard_ID:='';
                                                           mstorecard_ID:=TDynSiteForm(msite).BaseObjectSpace.SQLSelectFirstAsString('Select id from storecards where EAN=' + quotedstr(mvalue.Strings[0]));


                                                           if mstorecard_ID<>'' then begin
                                                                  mRow := mHead.Rows.AddNewObject;

                                                                  mRow.Prefill;
                                                                  //mRow.SetFieldValueAsInteger('PosIndex',i);
                                                                  mRow.SetFieldValueAsInteger('RowType',3);
                                                                  mRow.SetFieldValueAsString('Store_ID',mstore_id);
                                                                  mRow.SetFieldValueAsString('Storecard_ID',mStoreCard_ID);
                                                                  mRow.SetFieldValueAsFloat('Quantity',NxIBStrToFloat(copy(trim(mvalue.Strings[1]),1,AnsiPos(' ',trim(mvalue.Strings[1]))))) ;
                                                                  mIRadku:=mIRadku+1;
                                                                  mIKusu:=mIKusu +mRow.getFieldValueAsFloat('Quantity');

                                                                  mRow.SetFieldValueAsFloat('Unitprice',NxIBStrToFloat(copy(trim(mvalue.Strings[2]),1,AnsiPos(' ',trim(mvalue.Strings[2]))))/NxIBStrToFloat(copy(trim(mvalue.Strings[1]),1,AnsiPos(' ',trim(mvalue.Strings[1]))))) ;
                                                                  mRow.SetFieldValueAsString('Division_ID',mDivision_ID); //text bude  ...

                                                                  if not NxIsEmptyOID((mRow.GetFieldValueAsString('StoreCard_id.X_BusTransaction_ID'))) then begin
                                                                             mBustransaction_ID:=(mRow.GetFieldValueAsString('StoreCard_id.X_BusTransaction_ID'));
                                                                             mRow.SetFieldValueAsString('BusTransaction_id',mBustransaction_ID );
                                                                  end;
                                                                  if NxIsEmptyOID(mRow.GetFieldValueAsString('BusOrder_id')) then begin
                                                                      mBusOrder_ID:=GetBusOrder_ID(mRow);
                                                                      if not nxisblank(mBusOrder_ID) then mRow.SetFieldValueAsString('BusOrder_id',mBusOrder_ID);
                                                                      end;
                                                                      if NxIsEmptyOID(mRow.GetFieldValueAsString('BusProject_id')) then begin
                                                                          mBusProject_ID:=GetProject_ID(mRow);
                                                                          if not nxisblank(mBusProject_ID) then mRow.SetFieldValueAsString('BusProject_id',mBusProject_ID);
                                                                      end;

                                                            end;



                                                     end;


                                                finally
                                                    mvalue.free;
                                                end;
                                        end;
                              end;
            end;
            if index=1 then begin
                      mImportFile:=TStringList.create;
                         ParsevalueRow(BarCode_document(mSite,'05CPMINJW3DL342X01C0CX3FCC',0,0,720,960, 'Obsah ','Datamatrix : ','','Pokračovat','',''), chr(10),mImportFile);
                         ProgressInit(msite, 'Načítání dat ' + '', 100);
                          for i:=0 to mImportFile.Count-1 do begin   // načtení souboru

                                        ProgressSetPos(1+NxFloor((i/mImportFile.Count)*99), inttostr(i) +' z '+inttostr(mImportFile.Count));
                                        mstringline:= mImportFile.strings[i];
                                        if trim(mstringline)<>'' then begin
                                            mStoreCard_ID:='';
                                             mBatch_ID:='';
                                             mQuantity:=0;
                                             mInputString:='';
                                            mvalue:=tstringlist.create;
                                            try

                                                mstring:= DatamatrixDecodeBatches(TDynSiteForm(msite).BaseObjectSpace,mstringline);
                                                ParsevalueRow(mstring, ';',mvalue);

                                                mStoreCard_ID:=mvalue.Strings[1];
                                                mBatch_ID:=mvalue.Strings[2];
                                                mQuantity:=NxIBStrToFloat(mvalue.Strings[3]);


                                              finally
                                                   mvalue.free;
                                              end;

                                if mStoreCard_ID<>'' then begin
                                        mMon := mHead.GetLoadedCollectionMonikerForFieldCode(mHead.GetFieldCode('ROWS'));
                                        mFind:=False;
                                        for ii := 0 to mMon.Count - 1 do begin
                                                 if mMon.BusinessObject[ii].getFieldValueAsstring('Storecard_ID')= mStoreCard_ID then begin
                                                                          mMon.BusinessObject[ii].SetFieldValueAsFloat('Quantity',(mMon.BusinessObject[ii].GetFieldValueAsFloat('Quantity') + mQuantity));
                                                                           //mDataSet.FieldByName('Quantity').AsFloat:=(mDataSet.FieldByName('Quantity').AsFloat + mqauntity);
                                                                           mFind:=True;

                                                                           if mBatch_ID<>'' then begin


                                                                                 mfindbatch:=false;


                                                                                 try
                                                                                     if ((mhead.CLSID<>'01CPMINJW3DL342X01C0CX3FCC') and (mhead.CLSID<>'CDMK5QAWZZDL342X01C0CX3FCC')) then begin
                                                                                               mBO_Batches:=mMon.BusinessObject[ii].GetLoadedCollectionMonikerForFieldCode(mMon.BusinessObject[ii].GetFieldCode('DocRowBatches'));
                                                                                                    mfindbatch:=false;
                                                                                                    for x:=0 to mBO_Batches.count-1 do begin
                                                                                                         if mBO_Batches.BusinessObject[x].GetFieldValueAsString('StoreBatch_ID')= mBatch_ID then begin
                                                                                                              mQuantityBatch:= mBO_Batches.BusinessObject[x].GetFieldValueAsFloat('Quantity') + mQuantity;
                                                                                                              mBO_Batches.BusinessObject[x].SetFieldValueAsFloat('Quantity',mQuantityBatch);
                                                                                                              mfindbatch:=true;
                                                                                                         end;
                                                                                                    end;
                                                                                                    If not mfindbatch then begin
                                                                                                    mBO_PohybSarze:= mBO_Batches.AddNewObject;
                                                                                                        mBO_PohybSarze.Prefill;
                                                                                                                    mBO_PohybSarze.setFieldValueAsString('StoreBatch_ID',mBatch_ID);
                                                                                                                    mBO_PohybSarze.SetFieldValueAsFloat('Quantity',mQuantity);
                                                                                                                    mBO_PohybSarze.setFieldValueAsString('Qunit',mMon.BusinessObject[ii].getFieldValueAsstring('Qunit'));
                                                                                                    end;


                                                                                     end;
                                                                                     if (mhead.CLSID='01CPMINJW3DL342X01C0CX3FCC') then begin
                                                                                          // OP
                                                                                           mr:= tstringlist.create;
                                                                                             try
                                                                                                 msite.BaseObjectSpace.SQLSelect('Select a.id,a.X_quantity from DefRollData A WHERE A.CLSID = ' + quotedstr('SLARSB0H4CK4T32XPZTP33J3XS') +
                                                                                                        ' AND (A.X_parent_id =' + QuotedStr(mMon.BusinessObject[ii].OID) + ') AND  (A.X_Batches =' + QuotedStr(mBatch_ID) + ')' ,mr);
                                                                                                        if mr.count>0 then begin
                                                                                                              mfindbatch:=true;
                                                                                                              mQuantityBatch:=NxIBStrToFloat(trim(copy(mr.Strings[0],12,20))) + mQuantity;
                                                                                                              mi:=msite.BaseObjectSpace.SQLExecute('update DefRollData set X_quantity=' + NxFloatToIBStr(mQuantityBatch) +  ' WHERE CLSID = ' + quotedstr('SLARSB0H4CK4T32XPZTP33J3XS') +
                                                                                                                  ' AND (id =' + QuotedStr(copy(mr.strings[0],1,10)) + ')') ;
                                                                                                        end else begin
                                                                                                              mBO_PohybSarze:=msite.BaseObjectSpace.CreateObject('SLARSB0H4CK4T32XPZTP33J3XS');
                                                                                                                     try
                                                                                                                            mBO_PohybSarze.new;
                                                                                                                            mBO_PohybSarze.Prefill;
                                                                                                                            mBO_PohybSarze.SetFieldValueAsFloat('X_quantity',mQuantity);
                                                                                                                            mBO_PohybSarze.SetFieldValueAsstring('Code',mHead.OID);
                                                                                                                            mBO_PohybSarze.SetFieldValueAsstring('X_Parent_ID',mMon.BusinessObject[ii].OID);
                                                                                                                            mBO_PohybSarze.SetFieldValueAsstring('X_Firm_ID',mHead.GetFieldValueAsString('Firm_ID'));
                                                                                                                            mBO_PohybSarze.SetFieldValueAsstring('X_Parent2_ID',mStoreCard_ID);
                                                                                                                            mBO_PohybSarze.SetFieldValueAsstring('X_Batches',mBatch_ID);
                                                                                                                            mBO_PohybSarze.SetFieldValueAsstring('Name',
                                                                                                                            copy(mMon.BusinessObject[i].GetFieldValueAsString('Storecard_ID.name'),1,40));
                                                                                                                            //mBO_PohybSarze.SetFieldValueAsstring('Code',mMon.BusinessObject[i].GetFieldValueAsString('Storecard_ID.Code'));
                                                                                                                             if mBO_PohybSarze.GetFieldValueAsstring('X_Batches.NAme')<>'0' then mBO_PohybSarze.save;
                                                                                                                     finally
                                                                                                                         mBO_PohybSarze.free;
                                                                                                                     end;
                                                                                                        end;
                                                                                              finally
                                                                                                  mr.free;
                                                                                              end;
                                                                                     end;
                                                                                     if (mhead.CLSID='CDMK5QAWZZDL342X01C0CX3FCC') then begin
                                                                                          // OV
                                                                                          mr:= tstringlist.create;
                                                                                             try
                                                                                                 msite.BaseObjectSpace.SQLSelect('Select a.id,a.X_quantity from DefRollData A WHERE A.CLSID = ' + quotedstr('EC2R2HSFK5UOZ5MYVJWJOHUC4S') +
                                                                                                        ' AND (A.X_parent_id =' + QuotedStr(mMon.BusinessObject[ii].OID) + ') AND  (A.X_Batches =' + QuotedStr(mBatch_ID) + ')' ,mr);
                                                                                                        if mr.count>0 then begin
                                                                                                              mfindbatch:=true;
                                                                                                              mQuantityBatch:=NxIBStrToFloat(trim(copy(mr.Strings[0],12,20))) + mQuantity;
                                                                                                              mi:=msite.BaseObjectSpace.SQLExecute('update DefRollData set X_quantity=' + NxFloatToIBStr(mQuantityBatch) +  ' WHERE CLSID = ' + quotedstr('EC2R2HSFK5UOZ5MYVJWJOHUC4S') +
                                                                                                                  ' AND (id =' + QuotedStr(copy(mr.strings[0],1,10)) + ')') ;
                                                                                                        end else begin
                                                                                                              mBO_PohybSarze:=msite.BaseObjectSpace.CreateObject('EC2R2HSFK5UOZ5MYVJWJOHUC4S');
                                                                                                                     try
                                                                                                                            mBO_PohybSarze.new;
                                                                                                                            mBO_PohybSarze.Prefill;
                                                                                                                            mBO_PohybSarze.SetFieldValueAsFloat('X_quantity',mQuantity);
                                                                                                                            mBO_PohybSarze.SetFieldValueAsstring('Code',mHead.OID);
                                                                                                                            mBO_PohybSarze.SetFieldValueAsstring('X_Parent_ID',mMon.BusinessObject[ii].OID);
                                                                                                                            mBO_PohybSarze.SetFieldValueAsstring('X_Firm_ID',mHead.GetFieldValueAsString('Firm_ID'));
                                                                                                                            mBO_PohybSarze.SetFieldValueAsstring('X_Parent2_ID',mStoreCard_ID);
                                                                                                                            mBO_PohybSarze.SetFieldValueAsstring('X_Batches',mBatch_ID);
                                                                                                                            mBO_PohybSarze.SetFieldValueAsstring('Name',
                                                                                                                            copy(mMon.BusinessObject[i].GetFieldValueAsString('Storecard_ID.name'),1,40));
                                                                                                                            //mBO_PohybSarze.SetFieldValueAsstring('Code',mMon.BusinessObject[i].GetFieldValueAsString('Storecard_ID.Code'));
                                                                                                                             if mBO_PohybSarze.GetFieldValueAsstring('X_Batches.Name')<>'0' then mBO_PohybSarze.save;
                                                                                                                     finally
                                                                                                                         mBO_PohybSarze.free;
                                                                                                                     end;
                                                                                                        end;
                                                                                              finally
                                                                                                  mr.free;
                                                                                              end;







































                                                                                     end;
                                                                                 finally

                                                                                 end;
                                                                  end;

                                                  end;
                                        end;
                                        if not mFind then begin
                                                      mRow := mHead.Rows.AddNewObject;
                                                      mRow.Prefill;
                                                      //mRow.SetFieldValueAsInteger('PosIndex',i);
                                                      mRow.SetFieldValueAsInteger('RowType',3);
                                                      mRow.SetFieldValueAsString('Store_ID',mstore_id);
                                                      mRow.SetFieldValueAsString('Storecard_ID',mStoreCard_ID);
                                                      mRow.SetFieldValueAsFloat('Quantity', mQuantity);
                                                      mIRadku:=mIRadku+1;
                                                      mIKusu:=mIKusu +mRow.getFieldValueAsFloat('Quantity');
                                                      mRow.SetFieldValueAsString('Division_ID',mDivision_ID); //text bude  ...

                                                      if not NxIsEmptyOID((mRow.GetFieldValueAsString('StoreCard_id.X_BusTransaction_ID'))) then begin
                                                                 mBustransaction_ID:=(mRow.GetFieldValueAsString('StoreCard_id.X_BusTransaction_ID'));
                                                                 mRow.SetFieldValueAsString('BusTransaction_id',mBustransaction_ID );
                                                      end;
                                                      mBusOrder_ID:=GetBusOrder_ID(mRow);
                                                      mRow.SetFieldValueAsString('BusOrder_id',mBusOrder_ID);
                                                      mBusProject_ID:=GetProject_ID(mRow);
                                                      mRow.SetFieldValueAsString('BusProject_id',mBusProject_ID);

                                                      if ((mhead.CLSID<>'01CPMINJW3DL342X01C0CX3FCC') and (mhead.CLSID<>'CDMK5QAWZZDL342X01C0CX3FCC')) then begin
                                                                                               mBO_Batches:=mMon.BusinessObject[ii].GetLoadedCollectionMonikerForFieldCode(mMon.BusinessObject[ii].GetFieldCode('DocRowBatches'));
                                                                                                    mfindbatch:=false;
                                                                                                    for x:=0 to mBO_Batches.count-1 do begin
                                                                                                         if mBO_Batches.BusinessObject[x].GetFieldValueAsString('StoreBatch_ID')= mBatch_ID then begin
                                                                                                              mQuantityBatch:= mBO_Batches.BusinessObject[x].GetFieldValueAsFloat('Quantity') + mQuantity;
                                                                                                              mBO_Batches.BusinessObject[x].SetFieldValueAsFloat('Quantity',mQuantityBatch);
                                                                                                              mfindbatch:=true;
                                                                                                         end;
                                                                                                    end;
                                                                                                    If not mfindbatch then begin
                                                                                                    mBO_PohybSarze:= mBO_Batches.AddNewObject;
                                                                                                        mBO_PohybSarze.Prefill;
                                                                                                                    mBO_PohybSarze.setFieldValueAsString('StoreBatch_ID',mBatch_ID);
                                                                                                                    mBO_PohybSarze.SetFieldValueAsFloat('Quantity',mQuantity);
                                                                                                                    mBO_PohybSarze.setFieldValueAsString('Qunit',mMon.BusinessObject[ii].getFieldValueAsstring('Qunit'));
                                                                                                    end;


                                                                                     end;


                                                      if ((mhead.CLSID='01CPMINJW3DL342X01C0CX3FCC') or (mhead.CLSID='CDMK5QAWZZDL342X01C0CX3FCC')) then begin
                                                          if (mhead.CLSID='01CPMINJW3DL342X01C0CX3FCC') then mBO_PohybSarze:=msite.BaseObjectSpace.CreateObject('SLARSB0H4CK4T32XPZTP33J3XS');
                                                          if (mhead.CLSID='CDMK5QAWZZDL342X01C0CX3FCC') then mBO_PohybSarze:=msite.BaseObjectSpace.CreateObject('EC2R2HSFK5UOZ5MYVJWJOHUC4S');
                                                                                                               try
                                                                                                                      mBO_PohybSarze.new;
                                                                                                                      mBO_PohybSarze.Prefill;
                                                                                                                      mBO_PohybSarze.SetFieldValueAsFloat('X_quantity',mQuantity);

                                                                                                                      mBO_PohybSarze.SetFieldValueAsstring('Code',mHead.OID);
                                                                                                                      mBO_PohybSarze.SetFieldValueAsstring('X_Parent_ID',mRow.OID);
                                                                                                                      mBO_PohybSarze.SetFieldValueAsstring('X_Firm_ID',mHead.GetFieldValueAsString('Firm_ID'));
                                                                                                                      mBO_PohybSarze.SetFieldValueAsstring('X_Parent2_ID',mStoreCard_ID);
                                                                                                                      mBO_PohybSarze.SetFieldValueAsstring('X_Batches',mBatch_ID);
                                                                                                                      mBO_PohybSarze.SetFieldValueAsstring('Name',
                                                                                                                      copy(mRow.GetFieldValueAsString('Storecard_ID.name'),1,40));
                                                                                                                      //mBO_PohybSarze.SetFieldValueAsstring('Code',mMon.BusinessObject[i].GetFieldValueAsString('Storecard_ID.Code'));

                                                                                                                      if mBO_PohybSarze.GetFieldValueAsstring('X_Batches.Name')<>'0' then mBO_PohybSarze.save;

                                                                                                               finally
                                                                                                                   mBO_PohybSarze.free;
                                                                                                               end;
                                                       end;

                                        end;
                                end;


                                         end;
                          end;
            end;

            If ((index=2) or (index=3) )then begin
                    mImportFile:=TStringList.create;
                              ParsevalueRow(BarCode_document(mSite,'05CPMINJW3DL342X01C0CX3FCC',0,0,720,960, 'Obsah potvrzení','Položky : ','','Pokračovat','',''), chr(10),mImportFile);
                              ProgressInit(msite, 'Načítání dat ' + '', 100);
                              for i:=0 to mImportFile.Count-1 do begin   // načtení souboru

                                        ProgressSetPos(1+NxFloor((i/mImportFile.Count)*99), inttostr(i) +' z '+inttostr(mImportFile.Count));
                                        mstringline:= mImportFile.strings[i];
                                        if trim(mstringline)<>'' then begin
                                            mvalue:=tstringlist.create;
                                               try
                                                   //NxShowSimpleMessage(mImportFile.strings[i],nil);
                                                   ParsevalueRow(mstringline, chr(09),mvalue);
                                                     if mvalue.count<6 then begin
                                                         for ii:=mvalue.count to 6 do begin
                                                             mvalue.Add('0');
                                                         end;
                                                     end;

                                                     if mvalue.count>=5 then begin
                                                            //NxShowSimpleMessage(mvalue.strings[0],nil);
                                                            //NxShowSimpleMessage(,nil);
                                                            //NxShowSimpleMessage(copy(trim(mvalue.Strings[2]),1,AnsiPos(' ',trim(mvalue.Strings[2]))),nil);
                                                           mstorecard_ID:='';
                                                           mstorecard_ID:=TDynSiteForm(msite).BaseObjectSpace.SQLSelectFirstAsString('Select id from storecards where EAN=' + quotedstr(mvalue.Strings[2]));


                                                           if mstorecard_ID<>'' then begin
                                                                  mfind:=false;
                                                                  if (index=2) and (trim(mvalue.Strings[4])<>'') and (trim(mvalue.Strings[4])<>'0') then mfind:=true ;
                                                                  if (index=3) and (trim(mvalue.Strings[5])<>'') and (trim(mvalue.Strings[5])<>'0') then mfind:=true ;

                                                                  if mfind then begin
                                                                                mRow := mHead.Rows.AddNewObject;
                                                                                mRow.Prefill;
                                                                                //mRow.SetFieldValueAsInteger('PosIndex',i);
                                                                                mRow.SetFieldValueAsInteger('RowType',3);
                                                                                mRow.SetFieldValueAsString('Store_ID',mstore_id);
                                                                                mRow.SetFieldValueAsString('Storecard_ID',mStoreCard_ID);

                                                                                //mRow.SetFieldValueAsFloat('Quantity',NxIBStrToFloat(copy(trim(mvalue.Strings[1]),1,AnsiPos(' ',trim(mvalue.Strings[1]))))) ;
                                                                                // debug

                                                                                if index=2 then begin
                                                                                     mRow.SetFieldValueAsFloat('Quantity',NxIBStrToFloat(trim(mvalue.Strings[4]))) ;
                                                                                end;
                                                                                if (index=3) and (NxIBStrToFloat(trim(mvalue.Strings[5]))>0) then begin
                                                                                      mRow.SetFieldValueAsFloat('Quantity',NxIBStrToFloat(trim(mvalue.Strings[5]))) ;
                                                                                end;
                                                                                mIRadku:=mIRadku+1;
                                                                                mIKusu:=mIKusu +mRow.getFieldValueAsFloat('Quantity');

                                                                                //mRow.SetFieldValueAsFloat('Unitprice',NxIBStrToFloat(copy(trim(mvalue.Strings[2]),1,AnsiPos(' ',trim(mvalue.Strings[2]))))/NxIBStrToFloat(copy(trim(mvalue.Strings[1]),1,AnsiPos(' ',trim(mvalue.Strings[1]))))) ;
                                                                                mRow.SetFieldValueAsString('Division_ID',mDivision_ID); //text bude  ...

                                                                                if not NxIsEmptyOID((mRow.GetFieldValueAsString('StoreCard_id.X_BusTransaction_ID'))) then begin
                                                                                           mBustransaction_ID:=(mRow.GetFieldValueAsString('StoreCard_id.X_BusTransaction_ID'));
                                                                                           mRow.SetFieldValueAsString('BusTransaction_id',mBustransaction_ID );
                                                                                end;
                                                                                if NxIsEmptyOID(mRow.GetFieldValueAsString('BusOrder_id')) then begin
                                                                                    mBusOrder_ID:=GetBusOrder_ID(mRow);
                                                                                    if not nxisblank(mBusOrder_ID) then mRow.SetFieldValueAsString('BusOrder_id',mBusOrder_ID);
                                                                                end;
                                                                                    if NxIsEmptyOID(mRow.GetFieldValueAsString('BusProject_id')) then begin
                                                                                        mBusProject_ID:=GetProject_ID(mRow);
                                                                                        if not nxisblank(mBusProject_ID) then mRow.SetFieldValueAsString('BusProject_id',mBusProject_ID);
                                                                                    end;


                                                                  end;
                                                           end;

                                                     end;


                                                finally
                                                    mvalue.free;
                                                end;
                                        end;
                              end;
              end;

                    ProgressDispose()   ;
                   NxShowSimpleMessage('Import proběhl' + chr(10) +
                                       'naplněno ' + NxFloatToIBStr(mIRadku) + ' položek ' + chr(10) +
                                       'v poctu ' + NxFloatToIBStr(mIKusu) + ' jednotek ' ,nil);

               if  mhead.CLSID='01CPMINJW3DL342X01C0CX3FCC' then TDynSiteForm(mSite).ShowDynFormWithNewDocument('O2XDU14IW3DL342X01C0CX3FCC', mSite.SiteContext, mhead);    //op
               if  mhead.CLSID='CDMK5QAWZZDL342X01C0CX3FCC' then TDynSiteForm(mSite).ShowDynFormWithNewDocument('GF53HAH3WBDL3C5P00CA141B44', mSite.SiteContext, mhead);    // ov
               if  mhead.CLSID='E03ZNUMDTCC4PDAUIEY1MBTJC0' then TDynSiteForm(mSite).ShowDynFormWithNewDocument('B10I5SAOS3DL3ACU03KIU0CLP4', mSite.SiteContext, mhead);    // PR
               if  mhead.CLSID='050I5SAOS3DL3ACU03KIU0CLP4' then TDynSiteForm(mSite).ShowDynFormWithNewDocument('B50I5SAOS3DL3ACU03KIU0CLP4', mSite.SiteContext, mhead);    // DL
               if  mhead.CLSID='0P0I5SAOS3DL3ACU03KIU0CLP4' then TDynSiteForm(mSite).ShowDynFormWithNewDocument('BD0I5SAOS3DL3ACU03KIU0CLP4', mSite.SiteContext, mhead);    // PRV

  finally

  end;
end;





{
Přidání řádku do rozeditovaného dokladu
}
procedure InsertRow(Sender: TComponent;index:integer);
var
  mSite: TSiteForm;
  mControl: TControl;
  mDataset: TNxRowsObjectDataSet;
  mRow: TNxCustomBusinessObject;
  mvalue:TStringList;
  mStoreCard_ID, mBatch_ID,mstring,mInputString:string;
  mQuantity:double;
  mboolean:Boolean;
  mGRows:TMultiGrid;
  mList:TStringList;
  mfind:boolean;
  mImportFile:tstringlist;
  mstringline:string;
begin

  try
    mSite := NxFindSiteForm(Sender);
    mControl:= mSite.FindChildControl('tabRows.grdRows');
    mDataset := TNxRowsObjectDataSet(TMultiGrid(mControl).DataSource.DataSet);
    mboolean:=True;
    if Assigned(mDataset) then begin




                  if index=1  then begin
                      while mboolean do begin
                          // vstup a idetifikace kodu
                             mStoreCard_ID:='';
                             mBatch_ID:='';
                             mQuantity:=0;
                             mInputString:='';
                             mvalue:=tstringlist.create;
                                try
                                          mboolean:=InputQuery('Identifikace ', 'Datamatrix:',mInputString) ;
                                          if mboolean then begin
                                                mstring:= DatamatrixDecodeBatches(TDynSiteForm(msite).BaseObjectSpace,mInputString);
                                                Parsevalue(mstring,';',mstring,mvalue,4);
                                                mStoreCard_ID:=mvalue.Strings[1];
                                                mBatch_ID:=mvalue.Strings[2];
                                                mQuantity:=NxIBStrToFloat(mvalue.Strings[3]);
                                          end;

                                finally
                                     mvalue.free;
                                end;

                                if mStoreCard_ID<>'' then begin
                                                  if mDataSet.Active then begin
                                                              mDataSet.First;
                                                              mFind:=False;
                                                              while not mDataSet.Eof do begin
                                                                    //dohledání , zda již je položka
                                                                    if mDataSet.FieldByName('Storecard_ID').AsString= mStoreCard_ID then begin
                                                                          mdataset.CurrentObject.SetFieldValueAsFloat('Quantity',(mdataset.CurrentObject.getFieldValueAsFloat('Quantity') + mQuantity));
                                                                           //mDataSet.FieldByName('Quantity').AsFloat:=(mDataSet.FieldByName('Quantity').AsFloat + mqauntity);
                                                                           mFind:=True;
                                                                           TDynSiteForm(mSite).ActiveDataSet.UpdateFields;
                                                                           mDataset.RefreshAndRestoreLastSelectedItem;
                                                                    end;
                                                                    mDataSet.Next;

                                                              end;
                                                  end;

                                                              if not mFind then begin
                                                                            mDataSet.DisableControls;
                                                                            mRow := mDataSet.CreateBusinessObject;
                                                                            mRow.Prefill;
                                                                            mRow.SetFieldValueAsInteger('RowType',3);
                                                                            //mRow.SetFieldValueAsInteger('PosIndex',1);
                                                                            //mRow.SetFieldValueAsString('Store_Id','2100000101');
                                                                            //mRow.SetFieldValueAsString('Division_ID','2100000101');



                                                                             mRow.SetFieldValueAsString('Storecard_Id',mStoreCard_ID);
                                                                             mRow.SetFieldValueAsFloat('Quantity', mQuantity);

                                                                             TDynSiteForm(mSite).ActiveDataSet.UpdateFields; //Aby se o změně dozvěděl hlavičkový dataset
                                                                             mDataset.RefreshAndRestoreLastSelectedItem;
                                                                             mDataSet.EnableControls;
                                                              end;
                              end;


                      end;


                   end;
                   if index=0  then begin
                         mImportFile:=TStringList.create;

                              ParsevalueRow(TDynSiteForm(msite).CurrentObject.GetFieldValueAsString('X_Poznam_exp_ext'), chr(10),mImportFile);
                              //mImportFile:=ParsevalueRow(TDynSiteForm(msite).CurrentObject.GetFieldValueAsString('U_popis_sconto'));
                              for i:=0 to mImportFile.Count-1 do begin   // načtení souboru
                                        //ProgressSetPos(1+NxFloor((i/mImportFile.Count)*99), inttostr(i) +' z '+inttostr(mImportFile.Count));
                                        mstringline:= mImportFile.strings[i];
                                        if trim(mstringline)<>'' then begin
                                            mvalue:=tstringlist.create;
                                               try
                                                   //NxShowSimpleMessage(mImportFile.strings[i],nil);
                                                   ParsevalueRow(mstringline, chr(09),mvalue);

                                                     if mvalue.count>=3 then begin
                                                            //NxShowSimpleMessage(mvalue.strings[0],nil);
                                                            //NxShowSimpleMessage(,nil);
                                                            //NxShowSimpleMessage(copy(trim(mvalue.Strings[2]),1,AnsiPos(' ',trim(mvalue.Strings[2]))),nil);
                                                           mstorecard_ID:='';
                                                           mstorecard_ID:=TDynSiteForm(msite).BaseObjectSpace.SQLSelectFirstAsString('Select id from storecards where EAN=' + quotedstr(mvalue.Strings[0]));


                                                           if mstorecard_ID<>'' then begin

                                                                  mDataSet.DisableControls;
                                                                                  mRow := mDataSet.CreateBusinessObject;
                                                                                  mRow.Prefill;
                                                                                  mRow.SetFieldValueAsInteger('RowType',3);
                                                                                  //mRow.SetFieldValueAsInteger('PosIndex',1);
                                                                                  mRow.SetFieldValueAsString('Store_Id','1120000101');
                                                                                  //mRow.SetFieldValueAsString('Division_ID','2100000101');
                                                                                  mRow.SetFieldValueAsString('Storecard_Id',mStoreCard_ID);
                                                                                  mRow.SetFieldValueAsFloat('Quantity', NxIBStrToFloat(copy(trim(mvalue.Strings[1]),1,AnsiPos(' ',trim(mvalue.Strings[1]))))) ;
                                                                                  mRow.SetFieldValueAsFloat('Unitprice', NxIBStrToFloat(copy(trim(mvalue.Strings[2]),1,AnsiPos(' ',trim(mvalue.Strings[2]))))/NxIBStrToFloat(copy(trim(mvalue.Strings[1]),1,AnsiPos(' ',trim(mvalue.Strings[1]))))) ;



                                                                                   TDynSiteForm(mSite).ActiveDataSet.UpdateFields; //Aby se o změně dozvěděl hlavičkový dataset
                                                                                   mDataset.RefreshAndRestoreLastSelectedItem;
                                                                                   mDataSet.EnableControls;
                                                             end;



                                                     end;


                                                finally
                                                    mvalue.free;
                                                end;
                                        end;
                              end;


                   TDynSiteForm(msite).CurrentObject.setFieldValueAsString('X_Poznam_exp_ext','')    ;

                   end;
    end;
  finally

  end;
end;

{
Vyvolává se po vytvoření instance formuláře.
}
procedure FormCreate_Hook(Self: TSiteForm);
var
  mMAction: TMultiAction;
begin
  mMAction := Self.GetNewMultiAction;
          mMAction.ShowControl := True;
          mMAction.ShowMenuItem := True;
          mMAction.Hint := 'Čtečka';
          mMAction.Caption := 'Naplnění dokladu';
          mMAction.Items.Add('Datamatrix');
          mMAction.Items.Add('Natažení řádků z potvrzení eshop');
          mMAction.Category := 'tabDetail';
          mMAction.OnExecuteItem := @InsertRow;

  mMAction := Self.GetNewMultiAction;
          mMAction.ShowControl := True;
          mMAction.ShowMenuItem := True;
          mMAction.Hint := 'Čtečka';
          mMAction.Caption := 'Vytvoření dokladu';
          mMAction.Items.Add('Import z potvrzení ');
          mMAction.Items.Add('Import z datamatrix ');
          mMAction.Items.Add('Import z spotřeba ');
          mMAction.Items.Add('Import z Doplnění ');
          mMAction.Category := 'tabList';
          mMAction.OnExecuteItem := @InsertDoc;
end;


begin
end.