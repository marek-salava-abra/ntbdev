uses 'abra.eu.MASK.funkce_ctecky2017_vyr.Libs','abra.eu.MASK.funkce_ctecky2017_vyr.Forms';

var
 mIDs_Document:string;
 mIDs_Office:string;
 mEAN,mOldEan:string;
 mBO_StoreCard,mBO_FirmOffice,mBO_StoreSubcards,mBO_StoreSubbatches:TNxCustomBusinessObject;

 mID_Provozovna,mID_Doklad:string;







function CteckaItem(xsite:TDynSiteForm):boolean;
var
 mI_Result,mI_ResultSC,mI_Result1,mI_Result2,mI_Result3,mI_Result4:integer;
 mr_local,mr_zapis,mr_Head:tstringlist;
 i,ii,mi_SQL:integer;
 mIDs_dDocument:string;
 mOffice_ID:string;
 mEAN:string;
 mStoreCard,mFirmOffice,mBO:TNxCustomBusinessObject;
 //mI_Result,mI_ResultSC,mI_Result1,mI_Result2,mI_Result3,mI_Result4:integer;
 mID_Provozovna,mID_Doklad:string;
 mB_Result:Boolean;
 mOldEan:string;
 mS_result:string;
 mID_document:string;
 mbo_ReceivedOrder_row:TNxCustomBusinessObject;
 mPocet_zapis,mRow_zapis:double;
 mS_Doklad:string;
 mRows:TNxCustomBusinessMonikerCollection;
 mstorecard_id:string;
 mI_Result99,mI_Resultc:integer;
 mx_result:String;
 mi:integer;
begin
mOldEan:='';
    //xSite := TComponent(Sender).DynSite;
    mI_Result99:=0;
    while mI_Result99<>10 do begin
        mI_Result99:=mForm_Function(xsite,0,0,360,480,'Výběr','Volba','Operace',
                                 'Výroba','','','','','','','','','Zpět');
        if (mI_Result99=1) then begin
                    mI_Result1:=0;
              while mI_Result1<>10 do begin
                          mI_Result1:=mForm_Function(xsite,0,0,360,480,'Vychystávání','_','_',
                                                   'Kontrola','Naskladnění','','','','','','','_','Zpět');
                                 //if (mI_Result1=1) or (mI_Result1=2) or (mI_Result3=1) then begin
                                    mIDs_dDocument:='';
                                    mIDs_dDocument:= BarCode_document(xSite,'CDMK5QAWZZDL342X01C0CX3FCC',0,0,360,480, mID_doklad,'Zdrojový doklad: ','Ean','Pokračovat','','');;
                                 //end;
                                     //NxShowSimpleMessage(inttostr(mI_Result1) + ' - ' + mIDs_dDocument,nil);
                                            if (mI_Result1=1) then begin
                                                 //NxShowSimpleMessage(mIDs_dDocument,nil);
                                                 if mIDs_dDocument<>'' then begin
                                                     //NxShowSimpleMessage(inttostr(mI_Result1) + ' - ' + 'Před vychystáváním',nil);
                                                     mB_result:=Vychystavani_RO(xsite,mIDs_dDocument);




                                                    end;


                                            end;
                                            if (mI_Result1=2) then begin
                                                  if mIDs_dDocument<>'' then  begin
                                                      mx_result:='';
                                                        mx_result:=ExpediceRO_krize(xsite,mIDs_dDocument,mI_Result1);

                                                        if mx_result<>'' then begin
                                                            NxShowSimpleMessage('Proběhlo vyskladnění doklady: ' + mx_result,nil);
                                                            mi:=xsite.BaseObjectSpace.SQLExecute(format('update IssuedOrders2 RO2 set ro2.X_vychystano=0 where RO2.parent_ID in (%s)',
                                                            [mIDs_dDocument]));
                                                            nxbeep(btSuccess);
                                                        end;

                                                 end;
                                            end;

              end;
        end;
    end;
    //NxShowSimpleMessage('Funkce čtečky byla ukončena',nil);
    Beep;

    mI_Result99:=10;
end;

function Vyroba_orderItem(xSite:TSiteForm;mIDs_dDocument:string;mFirm_ID:string): string;
var
  mOVRows, mHeaderList,mrx,ARows,mrr,mrt: TStringList;
  mHeaderBO, mRowBO,mSourceRow,mRowsInputBO: TNxCustomBusinessObject;
  mCollRows,mRowsInput,mRowsOutput: TNxCustomBusinessMonikerCollection;
  mProceed: Boolean;
  mImportMan: TNxDocumentImportManager;
  mParams, mInputParams: TNxParameters;
  mParam: TNxParameter;
  i, z, x: integer;
  mPRRowParam_OID, mParamSC_OID, mSQL, mFirmOID: string;
  mParamQuantity: Extended;
  kk:integer;
  mr:tstringlist;
  mID_Docqueue,mx_dokument:string;
  mr_head:tstringlist;
  ms_doklad:string;
  mI_Resultc:integer;
  xPocet_pomoc,mxpocet,my_pocet:double;
  ii,JJ,xx:integer;
begin
 mID_Docqueue:='7B10000101';
 ms_doklad:='';
 mr:=TStringList.create;
 //NxShowSimpleMessage('AA',nil);
 try
     xsite.BaseObjectSpace.SQLSelect('select id from IssuedOrders where Firm_ID=' + quotedstr(mFirm_ID)+ ' and Confirmed=' + QuotedStr('N')+
     ' and Closed=' +quotedstr('N'),mr);
     if mr.count>0 then begin
           mI_Resultc:=mDialogForm(xsite,'Výroba','Existuje ' + inttostr(mr.Count) + ' objednávek', 'Založit novou','Použít existující','','','','','','','','Storno');
                      if mI_Resultc<>1 then begin

                             ms_doklad:=mr.Strings[0] ;
                             NxShowSimpleMessage('existující doklad je ' + ms_doklad,nil);
                             nxbeep(btfailure);
                      end else begin
                         ms_doklad:='';
                      end;

     end else begin
        ms_doklad:='';
     end;
 finally
    mr.free;
 end;
  //NxShowSimpleMessage('bb',nil);
  mr_head:=tstringlist.create;
  try
       xsite.BaseObjectSpace.SQLSelect(format('select ro.id from IssuedOrders2 RO2 left join IssuedOrders RO on ro.id=ro2.parent_id where (RO.closed = ''N'' ) and RO.ID in (%s) group by ro.id'
       ,[mIDs_dDocument]),mr_head);
       //if mr_head.count>0 then begin
       if True then begin
                           //NxShowSimpleMessage('cc',nil);
                          Result := '';
                          try
                            mx_dokument:='';
                            mr:=tstringlist.create;
                            try
                                 xsite.BaseObjectSpace.SQLSelect('select docqueue_id from IssuedOrders where id=' + quotedstr(mr_head.Strings(0)),mr);
                                 if mr.count>0 then begin
                                       if mr.Strings(0)='1S00000101' then mID_Docqueue:='8B10000101' else mID_Docqueue:='7B10000101';
                                 end;
                            finally
                              mr.free;
                            end;

                            mParams := TNxParameters.Create;
                             try
                                  mInputParams := TNxParameters.Create;
                                  try
                                   mParam := mInputParams.GetOrCreateParam(dtString, 'DocQueue_ID');
                                       mParam.AsString :=mID_Docqueue;//mID_Docqueue;
                                   if mr_head.count>1 then begin
                                      mParam := mInputParams.GetOrCreateParam(dtString, 'SelectedHeader'); // musi se z nejake hlavicky prebirat hlavickova data
                                      mParam.AsString := mr_head.Strings[0];
                                   end;
                                    //mParam := mInputParams.GetOrCreateParam(dtString, 'SelectedRows'); // jen povolene radky
                                    //mParam.AsString := ARows.Text;


                                    try

                                      mImportMan := NxCreateDocumentImportManager(xsite.BaseObjectSpace, Class_ReceivedOrder, Class_IssuedOrder);
                                      for xx:=0 to mr_head.Count-1 do begin
                                          mImportMan.AddInputDocument(mr_head.Strings(xx));
                                      end;

                                      mImportMan.LoadParams(mInputParams);
                                      mImportMan.Execute;

                                      //mImportMan.CheckOutputDocument;


                                      mRowsOutput := mImportMan.OutputDocument.GetLoadedCollectionMonikerForFieldCode(mImportMan.OutputDocument.GetFieldCode('Rows'));

//                                      NxShowSimpleMessage('Počet vstupních dokladu' + IntToStr(mr_head.count),nil);
//                                      NxShowSimpleMessage('Počet výstupních řídků' + IntToStr(mRowsOutput.count),nil);
                                     mxpocet:=mRowsOutput.Count;
                                      for ii:=0 to mRowsOutput.Count-1 do begin
                                              mRowsOutput.BusinessObject[ii].SetFieldValueAsString('Busproject_ID','');
                                              mRowsOutput.BusinessObject[ii].SetFieldValueAsString('BusOrder_ID','');
                                              if ((mRowsOutput.BusinessObject[ii].GetFieldValueAsString('Storecard_id.StoreCardCategory_ID.Code')='PB')
                                                 or (mRowsOutput.BusinessObject[ii].GetFieldValueAsString('Storecard_id.StoreCardCategory_ID.Code')='Px')) then begin
                                                    mRowsOutput.BusinessObject[ii].MarkForDelete;
                                                    mxpocet:=mxpocet-1;
                                                 end else begin ;


                                                      //NxShowSimpleMessage(inttostr(ii) + ' z  ' + inttostr(mRowsOutput.Count) + ' - - ' + mRowsOutput.BusinessObject[ii].GetFieldValueAsString('X_provideRow_ID'),nil);
                                                        mrx:=TStringList.create;
                                                        try
                                                            xsite.BaseObjectSpace.SQLSelect('select id from Suppliers where StoreCard_ID=' + quotedstr(mRowsOutput.BusinessObject[ii].GetFieldValueAsString('StoreCard_ID')) +
                                                            ' and Firm_ID=' + quotedstr(mfirm_id),mrx);
                                                                if mrx.count=0 then begin

                                                                       mRowsOutput.BusinessObject[ii].MarkForDelete;
                                                                        mxpocet:=mxpocet-1;
                                                                        //NxShowSimpleMessage('Není pro firmu odmazání',nil);
                                                                end else begin

                                                                             mRowsInputBO:=xSite.BaseObjectSpace.CreateObject('CDMK5QAWZZDL342X01C0CX3FCC');
                                                                             try
                                                                                mRowsInputBO.load(mRowsOutput.BusinessObject[ii].GetFieldValueAsString('X_provideRow_ID'),nil);
                                                                                        mRowsOutput.BusinessObject[ii].SetFieldValueAsFloat('Quantity',mRowsInputBO.getFieldValueAsFloat('Quantity') - mRowsInputBO.getFieldValueAsFloat('DeliveredQuantity') -  mRowsInputBO.getFieldValueAsFloat('X_vychystano'));

                                                                             finally
                                                                                 mRowsInputBO.free;
                                                                             end;

                                                                             if mRowsOutput.BusinessObject[ii].getFieldValueAsFloat('Quantity')<=0 then begin
                                                                                       mRowsOutput.BusinessObject[ii].MarkForDelete;
                                                                                       mxpocet:=mxpocet-1;
                                                                             end;

                                                                end;
                                                         finally
                                                             mrx.free;

                                                         end;

                                                 end;

                                      end;   // for

                                      if mxpocet>0 then begin
                                          mImportMan.OutputDocument.setFieldValueAsString('Docqueue_id',mID_Docqueue);
                                          mImportMan.OutputDocument.setFieldValueAsString('Firm_id',mFirm_ID);



                                              mImportMan.OutputDocument.Save;
                                              Result := mImportMan.OutputDocument.DisplayName;
                                      end else begin
                                              Result:='Nejsou čerpatelné řádky'
                                      end;





                                    finally
                                      mImportMan.Free;
                                    end;
                                  finally
                                    mInputParams.Free;
                                  end;

                              finally
                                 mParams.Free;
                              end;
                            {finally

                              aRows.Free;
                            end;}

                          finally
                          //  Result := '';
                            //RaiseException('Chyba při generování OV podle OP. Znění chyby: ' + ExceptionMessage);
                          end;
        end;
   finally
       mr_head.free;
   end;
end;



 function ExpediceRO(xSite:TSiteForm;mIDs_dDocument:String;index:integer):string;
var
  mOVRows, mHeaderList,mrx,ARows,mrr,mrt: TStringList;
  mHeaderBO, mRowBO,mSourceRow,mRowsInputBO,mbo_ro: TNxCustomBusinessObject;
  mCollRows,mRowsInput,mRowsOutput: TNxCustomBusinessMonikerCollection;
  mProceed: Boolean;
  mImportMan: TNxDocumentImportManager;
  mParams, mInputParams: TNxParameters;
  mParam: TNxParameter;
  i, z, x: integer;
  mPRRowParam_OID, mParamSC_OID, mSQL, mFirmOID: string;
  mParamQuantity: Extended;
  kk:integer;
  mr:tstringlist;
  mID_Docqueue,mx_dokument:string;
  mr_head:tstringlist;
  ms_doklad:string;
  mI_Resultc:integer;
  xPocet_pomoc,mxpocet,my_pocet:double;
  ii,JJ,xx:integer;
  mS_result:string;
  mStore_id:string;
  mix:integer;
begin


 for mix:=0 to 1 do begin
        mr_head:=TStringList.create;
           try
            if mix=0 then begin
                xsite.BaseObjectSpace.SQLSelect(format('select ro.id from IssuedOrders2 RO2 left join IssuedOrders RO on ro.id=ro2.parent_id where (RO.closed = ''N'' ) and RO.ID in (%s) and ro.X_store_id is null group by ro.id'
                ,[mIDs_dDocument]),mr_head);
            end;
            if mix=1 then begin
                xsite.BaseObjectSpace.SQLSelect(format('select ro.id from IssuedOrders2 RO2 left join IssuedOrders RO on ro.id=ro2.parent_id where (RO.closed = ''N'' ) and RO.ID in (%s) and ro.X_store_id is not null group by ro.id'
                ,[mIDs_dDocument]),mr_head);
            end;

       if mr_head.count>0 then begin


               mbo_ro:=xSite.BaseObjectSpace.CreateObject('01CPMINJW3DL342X01C0CX3FCC');
               try
                  mbo_ro.load(mr_head.Strings[0],nil) ;

                           mParams := TNxParameters.Create;
                             try
                                  mInputParams := TNxParameters.Create;
                                  try
                                         if NxIsEmptyOID(mbo_ro.GetFieldValueAsString('X_Cilovy_sklad')) then begin
                                                        mImportMan := NxCreateDocumentImportManager(xsite.BaseObjectSpace,'01CPMINJW3DL342X01C0CX3FCC','050I5SAOS3DL3ACU03KIU0CLP4') ;
                                                        mParam := mInputParams.GetOrCreateParam(dtString, 'DocQueue_ID');
                                                        mParam.AsString :=mbo_ro.GetFieldValueAsString('DocQueue_ID.X_Delivery_ID');
                                          end else begin
                                                        mImportMan := NxCreateDocumentImportManager(xsite.BaseObjectSpace,'01CPMINJW3DL342X01C0CX3FCC','0P0I5SAOS3DL3ACU03KIU0CLP4');
                                                        mParam := mInputParams.GetOrCreateParam(dtString, 'DocQueue_ID');
                                                        mParam.AsString :=mbo_ro.GetFieldValueAsString('DocQueue_ID.X_Prevodka_ID');

                                          end;
                                      try
                                      for xx:=0 to mr_head.Count-1 do begin
                                          mImportMan.AddInputDocument(mr_head.Strings(xx));
                                      end;


                                         if mr_head.count>1 then begin
                                                mParam := mInputParams.GetOrCreateParam(dtString, 'SelectedHeader'); // musi se z nejake hlavicky prebirat hlavickova data
                                                mParam.AsString := mr_head.Strings[0];
                                         end;
                                    //mParam := mInputParams.GetOrCreateParam(dtString, 'SelectedRows'); // jen povolene radky
                                    //mParam.AsString := ARows.Text;

                                    mImportMan.LoadParams(mInputParams);
                                      mImportMan.Execute;

                                      //mImportMan.CheckOutputDocument;



                                      mRowsOutput := mImportMan.OutputDocument.GetLoadedCollectionMonikerForFieldCode(mImportMan.OutputDocument.GetFieldCode('Rows'));

//                                      NxShowSimpleMessage('Počet vstupních dokladu' + IntToStr(mr_head.count),nil);
//                                      NxShowSimpleMessage('Počet výstupních řídků' + IntToStr(mRowsOutput.count),nil);
                                     mxpocet:=mRowsOutput.Count;
                                      for ii:=0 to mRowsOutput.Count-1 do begin

                                              if ((mRowsOutput.BusinessObject[ii].GetFieldValueAsString('Storecard_id.StoreCardCategory_ID.Code')='PB')
                                                 or (mRowsOutput.BusinessObject[ii].GetFieldValueAsString('Storecard_id.StoreCardCategory_ID.Code')='Px')) then begin
                                                    //mRowsOutput.BusinessObject[ii].MarkForDelete;
                                                    //mxpocet:=mxpocet-1;
                                                 end else begin
                                                    if index=1 then mRowsOutput.BusinessObject[ii].SetFieldValueAsFloat('Quantity',0);
                                                    if index=2 then begin
                                                       mRowsOutput.BusinessObject[ii].SetFieldValueAsFloat('Quantity',0);

                                                       mRowsInputBO:=xSite.BaseObjectSpace.CreateObject('CDMK5QAWZZDL342X01C0CX3FCC');

                                                       try
                                                         mRowsInputBO.load(mRowsOutput.BusinessObject[ii].GetFieldValueAsString('ProvideRow_ID'),nil);
                                                         mRowsOutput.BusinessObject[ii].SetFieldValueAsFloat('Quantity',mRowsInputBO.getFieldValueAsFloat('X_vychystano'));

                                                        finally
                                                            mRowsInputBO.free;
                                                        end;

                                                        if mRowsOutput.BusinessObject[ii].getFieldValueAsFloat('Quantity')<=0 then begin
                                                             mRowsOutput.BusinessObject[ii].MarkForDelete;
                                                             mxpocet:=mxpocet-1;
                                                         end;
                                                     end;
                                              end;
                                      end;   // for
                                      mImportMan.OutputDocument.setFieldValueAsString('Firm_id',mbo_ro.GetFieldValueAsString('Firm_id'));
                                      mImportMan.OutputDocument.setFieldValueAsString('FirmOffice_ID',mbo_ro.GetFieldValueAsString('FirmOffice_ID'));
                                      mImportMan.OutputDocument.setFieldValueAsString('Person_id',mbo_ro.GetFieldValueAsString('Person_id'));


                                     if index=1 then begin
                                          mS_result:=BarCodeDialog_DL(xSite,mImportMan.OutputDocument,mRowsOutput,
                                                     0,0,360,480,'Expedice: ',
                                                     0,0, mIDs_dDocument,
                                                     'EAN','Storno','','přeskočit',
                                                     'Šarže');

                                            mxpocet:=mRowsOutput.Count;
                                           for ii:=0 to mRowsOutput.Count-1 do begin
                                                  for ii:=0 to mRowsOutput.Count-1 do begin

                                              if ((mRowsOutput.BusinessObject[ii].GetFieldValueAsString('Storecard_id.StoreCardCategory_ID.Code')='PB')
                                                 or (mRowsOutput.BusinessObject[ii].GetFieldValueAsString('Storecard_id.StoreCardCategory_ID.Code')='Px')) then begin
                                                    //mRowsOutput.BusinessObject[ii].MarkForDelete;
                                                    //mxpocet:=mxpocet-1;
                                              end else begin
                                                    if (index=1) or (index=3) then mRowsOutput.BusinessObject[ii].SetFieldValueAsFloat('Quantity',0);
                                                       mRowsOutput.BusinessObject[ii].SetFieldValueAsFloat('Quantity',0);

                                                       mRowsInputBO:=xSite.BaseObjectSpace.CreateObject('CDMK5QAWZZDL342X01C0CX3FCC');

                                                       try
                                                         mRowsInputBO.load(mRowsOutput.BusinessObject[ii].GetFieldValueAsString('ProvideRow_ID'),nil);
                                                         mRowsOutput.BusinessObject[ii].SetFieldValueAsFloat('Quantity',mRowsInputBO.getFieldValueAsFloat('X_dodano'));

                                                        finally
                                                            mRowsInputBO.free;
                                                        end;
                                                    end;
                                                        if mRowsOutput.BusinessObject[ii].getFieldValueAsFloat('Quantity')<=0 then begin
                                                             mRowsOutput.BusinessObject[ii].MarkForDelete;
                                                             mxpocet:=mxpocet-1;
                                                         end;
                                              end;

                                      end;   // for



                                      end;


                                      if mxpocet>=0 then begin
                                          //mImportMan.OutputDocument.setFieldValueAsString('Docqueue_id',mID_Docqueue);

                                              mImportMan.OutputDocument.Save;
                                              Result := mImportMan.OutputDocument.DisplayName;
                                      end else begin
                                              Result:='Nejsou čerpatelné řádky';
                                      end;
                                  finally
                              mImportMan.Free;
                          end;

                                  finally
                                    mInputParams.Free;
                                  end;

                              finally
                                 mParams.Free;
                              end;

               finally
                  mbo_ro.free;
               end;

        end;
   finally
       mr_head.free;
       //RaiseException('Chyba při generování DL podle OP. Znění chyby: ' + ExceptionMessage);
   end;
 end;
end;










function ExpediceRO_krize(xSite:TSiteForm;mIDs_dDocument:String;index:integer):string;
var
  mOVRows, mHeaderList,mrx,ARows,mrr,mrt: TStringList;
  mHeaderBO, mRowBO,mSourceRow,mRowsInputBO,mbo_ro: TNxCustomBusinessObject;
  mCollRows,mRowsInput,mRowsOutput: TNxCustomBusinessMonikerCollection;
  mProceed: Boolean;
  mImportMan: TNxDocumentImportManager;
  mParams, mInputParams: TNxParameters;
  mParam: TNxParameter;
  i, z, x: integer;
  mPRRowParam_OID, mParamSC_OID, mSQL, mFirmOID: string;
  mParamQuantity: Extended;
  kk,iaa:integer;
  mr:tstringlist;
  mID_Docqueue,mx_dokument:string;
  mr_head:tstringlist;
  ms_doklad:string;
  mI_Resultc:integer;
  xPocet_pomoc,mxpocet,my_pocet:double;
  ii,JJ,xx:integer;
  mS_result:string;
  maa:TStringList;
begin
       maa:=tstringlist.create;
       xsite.BaseObjectSpace.SQLSelect(format('select max(ro.firm_id) from IssuedOrders2 RO2 left join IssuedOrders RO on ro.id=ro2.parent_id where (RO.closed = ''N'' ) and RO.ID in (%s) group by ro.firm_id '
       ,[mIDs_dDocument]),maa);

       if maa.count>0 then begin

           for iaa:=0 to maa.Count-1 do begin
                   mr_head:=TStringList.create;
                   try
                   xsite.BaseObjectSpace.SQLSelect(format('select ro.id from IssuedOrders2 RO2 left join IssuedOrders RO on ro.id=ro2.parent_id where (RO.closed = ''N'' ) and RO.ID in (%s) and ro.firm_id=%s group by ro.id'
                   ,[mIDs_dDocument,quotedstr(maa.Strings[iaa])]),mr_head);


                   if mr_head.count>0 then begin


                           mbo_ro:=xSite.BaseObjectSpace.CreateObject('01CPMINJW3DL342X01C0CX3FCC');
                           try
                              mbo_ro.load(mr_head.Strings[0],nil) ;

                                       mParams := TNxParameters.Create;
                                         try
                                              mInputParams := TNxParameters.Create;
                                              try
                                                     if NxIsEmptyOID(mbo_ro.GetFieldValueAsString('X_Cilovy_sklad')) then begin
                                                                    mImportMan := NxCreateDocumentImportManager(xsite.BaseObjectSpace,'01CPMINJW3DL342X01C0CX3FCC','050I5SAOS3DL3ACU03KIU0CLP4') ;
                                                                    mParam := mInputParams.GetOrCreateParam(dtString, 'DocQueue_ID');
                                                                    mParam.AsString :=mbo_ro.GetFieldValueAsString('DocQueue_ID.X_Delivery_ID');
                                                      end else begin
                                                                    mImportMan := NxCreateDocumentImportManager(xsite.BaseObjectSpace,'01CPMINJW3DL342X01C0CX3FCC','0P0I5SAOS3DL3ACU03KIU0CLP4');
                                                                    mParam := mInputParams.GetOrCreateParam(dtString, 'DocQueue_ID');
                                                                    mParam.AsString :=mbo_ro.GetFieldValueAsString('DocQueue_ID.X_Prevodka_ID');

                                                      end;
                                                  try
                                                  for xx:=0 to mr_head.Count-1 do begin
                                                      mImportMan.AddInputDocument(mr_head.Strings(xx));
                                                  end;


                                                     if mr_head.count>1 then begin
                                                            mParam := mInputParams.GetOrCreateParam(dtString, 'SelectedHeader'); // musi se z nejake hlavicky prebirat hlavickova data
                                                            mParam.AsString := mr_head.Strings[0];
                                                     end;
                                                //mParam := mInputParams.GetOrCreateParam(dtString, 'SelectedRows'); // jen povolene radky
                                                //mParam.AsString := ARows.Text;

                                                mImportMan.LoadParams(mInputParams);
                                                  mImportMan.Execute;

                                                  //mImportMan.CheckOutputDocument;



                                                  mRowsOutput := mImportMan.OutputDocument.GetLoadedCollectionMonikerForFieldCode(mImportMan.OutputDocument.GetFieldCode('Rows'));

            //                                      NxShowSimpleMessage('Počet vstupních dokladu' + IntToStr(mr_head.count),nil);
            //                                      NxShowSimpleMessage('Počet výstupních řídků' + IntToStr(mRowsOutput.count),nil);
                                                 mxpocet:=mRowsOutput.Count;
                                                  for ii:=0 to mRowsOutput.Count-1 do begin

                                                          if ((mRowsOutput.BusinessObject[ii].GetFieldValueAsString('Storecard_id.StoreCardCategory_ID.Code')='PB')
                                                             or (mRowsOutput.BusinessObject[ii].GetFieldValueAsString('Storecard_id.StoreCardCategory_ID.Code')='Px')) then begin
                                                                //mRowsOutput.BusinessObject[ii].MarkForDelete;
                                                                //mxpocet:=mxpocet-1;
                                                             end else begin
                                                                  mRowsOutput.BusinessObject[ii].SetFieldValueAsFloat('Quantity',0);


                                                                   mRowsInputBO:=xSite.BaseObjectSpace.CreateObject('CDMK5QAWZZDL342X01C0CX3FCC');

                                                                   try
                                                                     mRowsOutput.BusinessObject[ii].SetFieldValueAsFloat('Quantity',0);
                                                                     mRowsInputBO.load(mRowsOutput.BusinessObject[ii].GetFieldValueAsString('ProvideRow_ID'),nil);
                                                                     if (index=1)  or (index=3) then begin
                                                                        if mRowsInputBO.getFieldValueAsFloat('X_dodano')>0 then begin
                                                                            mRowsOutput.BusinessObject[ii].SetFieldValueAsFloat('Quantity',mRowsInputBO.getFieldValueAsFloat('X_dodano'));
                                                                         end else begin
                                                                            mRowsOutput.BusinessObject[ii].MarkForDelete;
                                                                            mxpocet:=mxpocet-1;
                                                                         end;
                                                                      end;
                                                                     if index=2 then begin
                                                                         if mRowsInputBO.getFieldValueAsFloat('X_vychystano')>0 then begin
                                                                            mRowsOutput.BusinessObject[ii].SetFieldValueAsFloat('Quantity',mRowsInputBO.getFieldValueAsFloat('X_vychystano'));
                                                                         end else begin
                                                                            mRowsOutput.BusinessObject[ii].MarkForDelete;
                                                                            mxpocet:=mxpocet-1;
                                                                         end;
                                                                     end;


                                                                    finally
                                                                        mRowsInputBO.free;
                                                                    end;




                                                                 end;
                                                          end;
                                                  //end;   // for
                                                  mImportMan.OutputDocument.setFieldValueAsString('Firm_id',mbo_ro.GetFieldValueAsString('Firm_id'));
                                                  //mImportMan.OutputDocument.setFieldValueAsString('FirmOffice_ID',mbo_ro.GetFieldValueAsString('FirmOffice_ID'));
                                                  //mImportMan.OutputDocument.setFieldValueAsString('Person_id',mbo_ro.GetFieldValueAsString('Person_id'));




                                                  if (mxpocet>=0)
                                                  and (mRowsOutput.Count>0) then begin
                                                      //mImportMan.OutputDocument.setFieldValueAsString('Docqueue_id',mID_Docqueue);

                                                          mImportMan.OutputDocument.Save;
                                                          Result := mImportMan.OutputDocument.DisplayName;
                                                  end else begin
                                                          Result:='Nejsou čerpatelné řádky';
                                                  end;
                                              finally
                                          mImportMan.Free;
                                      end;

                                              finally
                                                mInputParams.Free;
                                              end;

                                          finally
                                             mParams.Free;
                                          end;

                           finally
                              mbo_ro.free;
                           end;

                    end;
               finally
                   mr_head.free;
                   //RaiseException('Chyba při generování DL podle OP. Znění chyby: ' + ExceptionMessage);
               end;

           end;  ///for
        end;          // if
end;












function Vychystavani_RO(xsite:TSiteForm;mIDs_dDocument:string):boolean;
var
 mr_local,mr_zapis,mr_Head:tstringlist;
 i,ii,mi_SQL:integer;
 mEAN:string;
 mStoreCard,mFirmOffice,mBO:TNxCustomBusinessObject;
 mID_Provozovna,mID_Doklad:string;
 xresult:Boolean;
 mOldEan:string;
 mS_result:Boolean;
 mx_result:string;
 mID_document:string;
 mbo_IssuedOrder_row:TNxCustomBusinessObject;
 mPocet_zapis,mRow_zapis:double;
 mS_Doklad:string;
 mRows:TNxCustomBusinessMonikerCollection;
 mstorecard_id:string;
 mi_resultc:integer;
 mpokracuj:boolean;
begin
 mr_local:=TStringList.create;
       try
           xsite.BaseObjectSpace.SQLSelect(format(mSQL_Doklad,[quotedstr('1120000101'),mIDs_dDocument]),mr_local);
           //NxShowSimpleMessage(inttostr(mr_local.count),nil);
           //xresult:=InputQuery('AA','AAA',format(mSQL_Doklad,[quotedstr('1120000101'),mIDs_dDocument]));


           if mr_local.count>0 then begin

                 mpokracuj:=true;
                  for ii:=0 to mr_local.count-1 do begin
                               if mpokracuj then begin
                                       mbo_IssuedOrder_row:=xsite.BaseObjectSpace.CreateObject('CDMK5QAWZZDL342X01C0CX3FCC');
                                       try
                                       mbo_IssuedOrder_row.load(copy(mr_local.Strings[ii],1,10),nil);
                                       mstorecard_id:='';
                                                  mPocet_zapis:=BarCodeDialog(xSite,'CDMK5QAWZZDL342X01C0CX3FCC',false,
                                                                 mbo_IssuedOrder_row,
                                                                 0,0,360,480,'Zdrojový doklad: ',
                                                                 0,0, mIDs_dDocument,
                                                                 'EAN','Storno','','přeskočit',
                                                                 'Šarže');
                                                  //NxShowSimpleMessage(NxFloatToIBStr(mPocet_zapis),nil);
                                        mstorecard_id:=mbo_IssuedOrder_row.GetFieldValueAsString('Storecard_ID');
                                        finally
                                           mbo_IssuedOrder_row.free;
                                        end;

                                        if mPocet_zapis<0 then begin
                                             mPocet_zapis:=(mPocet_zapis*(-1)) + 1;
                                             mpokracuj:=false;
                                        end;
                                        if mPocet_zapis>0 then begin
                                                mr_zapis:=TStringList.create;
                                                     try
                                                            xsite.BaseObjectSpace.SQLSelect(
                                                            format('select ro2.id from IssuedOrders2 RO2 left join IssuedOrders RO on ro.id=ro2.parent_id where (RO.closed = ''N'') and ((ro2.X_specifikace_id is null) and (ro2.X_ExternalSpecification ='''')) and ((RO2.Quantity - Ro2.DeliveredQuantity-Ro2.X_vychystano)>0) and (RO2.Storecard_ID=%s and (RO.ID in (%s)))',
                                                            [quotedstr(mstorecard_id),mIDs_dDocument])
                                                            ,mr_zapis);
                                                            if mr_zapis.count>0 then begin
                                                                for i:=0 to mr_zapis.Count-1 do begin
                                                                       mbo_IssuedOrder_row:=xsite.BaseObjectSpace.CreateObject('CDMK5QAWZZDL342X01C0CX3FCC');
                                                                              try
                                                                                  mbo_IssuedOrder_row.load(copy(mr_zapis.Strings[i],1,10),nil);
                                                                                  if mPocet_zapis>0 then begin
                                                                                          if mbo_IssuedOrder_row.GetFieldValueAsFloat('Quantity')-mbo_IssuedOrder_row.GetFieldValueAsFloat('DeliveredQuantity')-mbo_IssuedOrder_row.GetFieldValueAsFloat('X_vychystano')>0 then begin
                                                                                              mRow_zapis:=mPocet_zapis-
                                                                                                          mbo_IssuedOrder_row.GetFieldValueAsFloat('Quantity')-mbo_IssuedOrder_row.GetFieldValueAsFloat('DeliveredQuantity')-mbo_IssuedOrder_row.GetFieldValueAsFloat('X_vychystano');
                                                                                                   if mRow_zapis>=0 then begin
                                                                                                           mRow_zapis:=mbo_IssuedOrder_row.GetFieldValueAsFloat('Quantity')-mbo_IssuedOrder_row.GetFieldValueAsFloat('DeliveredQuantity')-mbo_IssuedOrder_row.GetFieldValueAsFloat('X_vychystano');
                                                                                                           mi_SQL:=xsite.BaseObjectSpace.SQLExecute('update IssuedOrders2 set x_vychystano=' + NxFloatToIBStr(mbo_IssuedOrder_row.GetFieldValueAsFloat('X_vychystano') + mRow_zapis) + ' where id=' + QuotedStr(mbo_IssuedOrder_row.OID));;
                                                                                                           mPocet_zapis:= mPocet_zapis-mRow_zapis;
                                                                                                   end else begin
                                                                                mi_SQL:=xsite.BaseObjectSpace.SQLExecute('update IssuedOrders2 set x_vychystano=' + NxFloatToIBStr(mbo_IssuedOrder_row.GetFieldValueAsFloat('X_vychystano') + mPocet_zapis) + ' where id=' + QuotedStr(mbo_IssuedOrder_row.OID));;
                                                                                                           mPocet_zapis:=0
                                                                                                   end;

                                                                                          end;
                                                                                  end;
                                                                              finally

                                                                              end;

                                                                end;
                                                            end;
                                                     finally
                                                         mr_zapis.free;
                                                     end;

                                        end;

                               end;
                end;






           end;
       finally
           mr_local.free;
       end;


end;


begin
end.