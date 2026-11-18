uses 'abra.eu.API.digitalizace.Libs','abra.eu.API.digitalizace.Forms';

var
 mIDs_Document:string;
 mIDs_Office:string;
 mEAN,mOldEan:string;
 mBO_StoreCard,mBO_FirmOffice,mBO_StoreSubcards,mBO_StoreSubbatches:TNxCustomBusinessObject;
 mID_Provozovna,mID_Doklad:string;
 mJobOrder_ID,mOperace_ID,mWorker_ID:string;
 mMaterials,MCompetences:TMemo;



  function VydejMaterialu(xSite:TSiteForm;mIDs_dDocument:String;index:integer):string;
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
 IA:integer;
begin

mParams := TNxParameters.Create;
    try
     mInputParams := TNxParameters.Create;
         try
            mParam := mInputParams.GetOrCreateParam(dtString, 'DocQueue_ID');

                      mImportMan := NxCreateDocumentImportManager(xsite.BaseObjectSpace,'01CPMINJW3DL342X01C0CX3FCC','0P0I5SAOS3DL3ACU03KIU0CLP4');
                           try
                              mParam := mInputParams.GetOrCreateParam(dtString, 'DocQueue_ID');
                                   mParam.AsString :=mbo_ro.GetFieldValueAsString('DocQueue_ID.X_Prevodka_ID');

                                          // *** vstupni doklady
                                          for xx:=0 to mr_head.Count-1 do begin
                                              mImportMan.AddInputDocument(mr_head.Strings(xx));
                                          end;


                                          //    **** parametry importu
                                            mParam := mInputParams.GetOrCreateParam(dtString, 'DocQueue_ID');                       //string
                                                    mParam.AsString :='';
                                            mParam := mInputParams.GetOrCreateParam(dtString, 'Firm_ID');                           //string
                                                    mParam.AsString :='';
                                            mParam := mInputParams.GetOrCreateParam(dtDate, 'DocDate$DATE');                        //Date
                                                    mParam.AsDateTime :=Now;
                                            mParam := mInputParams.GetOrCreateParam(dtString, 'Division_ID');                       //string
                                                    mParam.AsString :='';
                                            mParam := mInputParams.GetOrCreateParam(dtString, 'SelectedRows');                      //string
                                                    mParam.AsString :='';
                                            mParam := mInputParams.GetOrCreateParam(dtInteger, 'MethodOfMD');                       //Int
                                                    mParam.AsInteger :=0;
                                            mParam := mInputParams.GetOrCreateParam(dtInteger, 'UnitChoice');                       //Int
                                                    mParam.AsInteger :=0;
                                            mParam := mInputParams.GetOrCreateParam(dtInteger, 'AutoPrepare');                      //Int
                                                    mParam.AsInteger :=0;
                                            //mParam := mInputParams.GetOrCreateParam(dtList, 'Stores');                              //List
                                            //        mParam.AsList :=mbo_ro.GetFieldValueAsString('DocQueue_ID.X_Prevodka_ID');
                                            mParam := mInputParams.GetOrCreateParam(dtInteger, 'BatchAutoFill');                    //Int
                                                    mParam.AsInteger :=0;
                                            mParam := mInputParams.GetOrCreateParam(dtInteger, 'SerialNumberAutoFill');             //Int
                                                    mParam.AsInteger :=0;
                                            mParam := mInputParams.GetOrCreateParam(dtInteger, 'StrategySelectionDisposition');     //Int
                                                    mParam.AsInteger :=0;
                                            mParam := mInputParams.GetOrCreateParam(dtInteger, 'ConsiderationDateExpiration');      //Int
                                                    mParam.AsInteger :=0;

                                          mImportMan.LoadParams(mInputParams);
                                          mImportMan.Execute;

                                          // kontrola
                                          //mImportMan.CheckOutputDocument;

                                                //  ****  práce s řádky výstupního dokladu
                                                {//mRowsOutput := mImportMan.OutputDocument.GetLoadedCollectionMonikerForFieldCode(mImportMan.OutputDocument.GetFieldCode('Rows'));
                                          //            for ii:=0 to mRowsOutput.Count-1 do begin
                                                //
                                                //              if not ((mRowsOutput.BusinessObject[ii].GetFieldValueAsString('Storecard_id.StoreCardCategory_ID.Code')='PB')
                                                //                 or (mRowsOutput.BusinessObject[ii].GetFieldValueAsString('Storecard_id.StoreCardCategory_ID.Code')='Px')) then begin
                                                //              end;
                                                //      end;   // for}

                                                          //  **** práce s šaržemi výstupního dokladu
                                                          {
                                                           }




                //                                          mImportMan.OutputDocument.setFieldValueAsString('Firm_id',mImportMan.InputDocuments[0].GetFieldValueAsString('Firm_id'));
                        //                                     if index=1 then begin
                        //                                          mS_result:=BarCodeDialog_DL(xSite,mImportMan.OutputDocument,mRowsOutput,
                        //                                                     0,0,360,480,'Expedice: ',
                        //                                                     0,0, mIDs_dDocument,
                        //                                                     'EAN','Storno','','přeskočit',
                        //                                                     'Šarže');
                        //                                      end;

                                          mImportMan.OutputDocument.Save;

                                          Result := mImportMan.OutputDocument.DisplayName;
                           finally
                              mImportMan.Free;
                           end;

         finally
            mInputParams.Free;
         end;
    finally
         mParams.Free;
    end;

end;











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
 mDouble:double;
  mOLE, mRoll, mOResult, _ss: Variant;
   mID:string;
   mr:tstringlist;
begin
mOldEan:='';
    //xSite := TComponent(Sender).DynSite;
    mI_Result99:=0;

    mBOWorker:=xsite.BaseObjectSpace.CreateObject('53FKKCM5GGGOZ3TF2DJ3E40GSK');
    mBOMachine:=xsite.BaseObjectSpace.CreateObject('5XGE0QFOGIWOB5ANMTYRIVKJ0O');
    try
    mBOWorker.load('6400000101',nil);
    mBOMachine.load('Q630000101',nil);


    while mI_Result99<>10 do begin
        mI_Result99:=mForm_Function(xsite,0,0,360,480,'Výběr','Uživatel: ' +mBOWorker.getfieldvalueasstring('WorkerName')  ,'Pracoviště: ' +mBOmachine.getfieldvalueasstring('DisplayName'),
                                 'Šití','Operátor','','Uživatel','Stroj','','','','Servis','Zpět');
        if (mI_Result99=1) then begin
              mI_Result1:=0;
              while mI_Result1<>10 do begin
                          mI_Result1:=mForm_Function(xsite,0,0,360,480, 'Práce' ,mBOWorker.getfieldvalueasstring('WorkerName'),mBOmachine.getfieldvalueasstring('DisplayName'),
                                                   'Běžná práce','Neshoda','','','','','','','_','Zpět');
                                 if (mI_Result1=1) then begin
                                    mJobOrder_ID:='';
                                    mJobOrder_ID:= BarCode_VP(xSite,'05CPMINJW3DL342X01C0CX3FCC',0,0,360,480, mID_doklad,'Výrobní příkaz ','Ean','Pokračovat','','');;
                                    mOperace_ID:='';
                                    mOperace_ID:=GetOperation_ID(xsite,mJobOrder_ID,mBOmachine.oid,mWorker_ID,0);

                                    //NxShowSimpleMessage(mOperace_ID,nil);
                                    if mOperace_ID<>'' then begin
                                       mBOOperace:=xsite.BaseObjectSpace.CreateObject('HRKADG42X2H4BJ2RL5KUAUG3PK');   // operace


                                              mBOOperace.load(mOperace_ID,nil);


                                              mDouble:= BarCodeOperation(xSite,mBOWorker.oid,mBOmachine.oid,
                                                                 mBOOperace,
                                                                 0,0,960,740,'Operace',
                                                                 'Šití','Storno','Neshoda','Uzavřít',
                                                                 '');
                                    end;
                                            //if (mI_Result1=4) then NxShowSimpleMessage('4',nil);
                                            //if (mI_Result1=5) then NxShowSimpleMessage('5',nil);
                                            //if (mI_Result1=6) then NxShowSimpleMessage('6',nil);
                                            //if (mI_Result1=7) then NxShowSimpleMessage('7',nil);
                                            //if (mI_Result1=8) then NxShowSimpleMessage('8',nil);
                                            //if (mI_Result1=9) then NxShowSimpleMessage('9',nil);
                                 end;

                               if (mI_Result1=10) then mI_Result99:=0;

              end;
        end;

        if (mI_Result99=2) then begin
               mB_Result:=InputQuery('Skupina cílového pracoviště', 'Skupina pracovišť',mBOmachine.oid);
                   if mB_Result then begin
                            mOLE := GetAbraOLEApplication;
                                  mroll := mOLE.GetAgenda('MHMY3UH1D3Z4T1DKS4XLO3HHKC');
                                   //mRoll.Params.Add('@X_Parent_ID=' + quotedstr(mBOmachine.oid) );
                                         _ss := mOLE.CreateStrings;
                                         mID := mroll.SingleSelectFromSelected2(_ss, 'Vybrat umístění', '');

                                         mJobOrder_ID:=' ';

                                         while mJobOrder_ID<>'' do begin
                                               mJobOrder_ID:= BarCode_VP(xSite,'05CPMINJW3DL342X01C0CX3FCC',0,0,360,480, mID_doklad,'Výrobní příkaz ','Ean','Pokračovat','','');;
                                               mr:=TStringList.create;
                                                    try
                                                           xsite.BaseObjectSpace.SQLSelect('SELECT Routines.id ' +
                                                                                                              'FROM PLMJobOrders A ' +
                                                                                                              'join PLMJONodes N on N.Parent_ID = A.ID ' +
                                                                                                              'JOIN PLMJOOutputItems MI ON N.ID = MI.Owner_ID ' +
                                                                                                              'join PLMJobOrdersRoutines Routines on Routines.Parent_ID=MI.ID ' +
                                                                                                              'join PLMOperations PLMOP on PLMOP.JobOrdersRoutines_ID=Routines.ID ' +
                                                                                                              ' where (A.id=' + quotedstr(mJobOrder_ID) +
                                                                                                              ') AND (plmop.TotalTime>0 ' +
                                                                                                              ') AND (Routines.X_closed=' +QuotedStr('N') +
                                                                                                              ') order by mi.id,Routines.Phase_ID,Routines.PosIndex', mr) ;

                                                            // ****** uzavření předešlé operace
                                                               if mr.count>0 then begin
                                                                        mi :=xsite.BaseObjectSpace.SQLExecute('update PLMJobOrdersRoutines set X_closed=' + quotedstr('A') + ' where id=' + quotedstr(mr.strings[0])) ;
                                                                   NxShowSimpleMessage('Operace uzavřena ' + mr.strings[0],nil);
                                                               end;

                                                    finally
                                                        mr.free;
                                                    end;




                                                    //   ****    přiřazení nové
                                               mr:=TStringList.create;
                                                    try
                                                           xsite.BaseObjectSpace.SQLSelect('SELECT Routines.id ' +
                                                                                                'FROM PLMJobOrders A ' +
                                                                                                'join PLMJONodes N on N.Parent_ID = A.ID ' +
                                                                                                'JOIN PLMJOOutputItems MI ON N.ID = MI.Owner_ID ' +
                                                                                                'join PLMJobOrdersRoutines Routines on Routines.Parent_ID=MI.ID ' +
                                                                                                ' where A.id=' + quotedstr(mJobOrder_ID) +
                                                                                                ' AND Routines.WorkPlace_ID=' + quotedstr(mBOmachine.oid) +
                                                                                                ' AND Routines.X_closed=' +QuotedStr('N') +
                                                                                                ' order by mi.id,Routines.Phase_ID,Routines.PosIndex', mr) ;

                                                            // ****** uzavření předešlé operace
                                                               if mr.count>0 then begin
                                                                        mi :=xsite.BaseObjectSpace.SQLExecute('update PLMJobOrdersRoutines set X_closed=' + quotedstr('A') + ' where id=' + quotedstr(mr.strings[0]))    ;
                                                                   NxShowSimpleMessage('Operace uzavřena ' + mr.strings[0],nil);
                                                               end;

                                                    finally
                                                        mr.free;
                                                    end;



                                               // nalezení a ukončení probíhající operace

                                               // nalezení následné operace

                                               // přiřazení operace ke konkrétnímu stroji


                                         end;

                   end;

        end;


        if (mI_Result99=4) then begin
             mIDs_dDocument:='';
             mIDs_dDocument:= BarCode_Worker(xSite,'05CPMINJW3DL342X01C0CX3FCC',0,0,360,480, mID_doklad,'Uživatel','Ean','Pokračovat','','');;
             mBOWorker.load(mIDs_dDocument,nil);

        end;
        if (mI_Result99=5) then begin
             mIDs_dDocument:='';
             mIDs_dDocument:= BarCode_Machine(xSite,'05CPMINJW3DL342X01C0CX3FCC',0,0,360,480, mID_doklad,'Stroj','Ean','Pokračovat','','');;
             mBOMachine.load(mIDs_dDocument,nil);
        end;

        if (mI_Result99=5) then begin
        end;





    end;
    //NxShowSimpleMessage('Funkce čtečky byla ukončena',nil);
    Beep;

    mI_Result99:=10;
    finally
        mBOWorker.free;
        mBOMachine.free;
    end;
end;

function Vyroba_orderItem(xSite:TSiteForm;mIDs_dDocument:string;mFirm_ID:string): string;
var
  mOVRows, mHeaderList,mrx,ARows,mrr,mrt,mrqw: TStringList;
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
  mpocet_pomoc:double;
  mObjednano:double;
begin
 mID_Docqueue:='7B10000101';
 ms_doklad:='';

  //NxShowSimpleMessage('bb',nil);
  mr_head:=tstringlist.create;
  try
       xsite.BaseObjectSpace.SQLSelect(format('select ro.id from Receivedorders2 RO2 left join Receivedorders RO on ro.id=ro2.parent_id where (RO.closed = ''N'' ) and RO.ID in (%s) group by ro.id'
       ,[mIDs_dDocument]),mr_head);
       //if mr_head.count>0 then begin
       if True then begin
                           //NxShowSimpleMessage('cc',nil);
                          Result := '';
                          try
                            mx_dokument:='';
                            mr:=tstringlist.create;
                            try
                                 xsite.BaseObjectSpace.SQLSelect('select docqueue_id from receivedorders where id=' + quotedstr(mr_head.Strings(0)),mr);
                                 if mr.count>0 then begin
                                       if mr.Strings(0)='1S00000101' then mID_Docqueue:='8B10000101' else mID_Docqueue:='7B10000101';
                                 end;
                            finally
                              mr.free;
                            end;


                             mr:=TStringList.create;
                               //NxShowSimpleMessage('AA',nil);
                               try
                                  ms_doklad:='';
                                   xsite.BaseObjectSpace.SQLSelect('select id from IssuedOrders where Confirmed=' + QuotedStr('N')+
                                   ' and Closed=' +quotedstr('N') + ' and Firm_id=' + quotedstr(mFirm_ID) + ' and Docqueue_ID=' + quotedstr(mID_Docqueue),mr);
                                   if mr.count>0 then begin
                                         mI_Resultc:=mDialogForm(xsite,'Výroba','Existuje ' + inttostr(mr.Count) + ' objednávek', 'Založit novou','Použít existující','','','','','','','','Storno');
                                                    if mI_Resultc<=1 then ms_doklad:='';
                                                    if mI_Resultc>1 then  ms_doklad:=mr.Strings[0] ;



                                   end else begin
                                      ms_doklad:='';
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

                                      if ms_doklad<>'' then begin
                                         mImportMan.OutputDocument.Load(ms_doklad,nil);
                                       //  NxShowSimpleMessage('Připojení k dokladu',nil);
                                      end else begin
                                          // NxShowSimpleMessage('Novy doklad',nil);
                                      end;
                                      mImportMan.LoadParams(mInputParams);
                                      mImportMan.Execute;

                                      //mImportMan.CheckOutputDocument;

                                      mImportMan.OutputDocument.SetFieldValueAsBoolean('WithPrices',false) ;
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
                                                                            mobjednano:=0;
                                                                             mRowsInputBO:=xSite.BaseObjectSpace.CreateObject('05CPMINJW3DL342X01C0CX3FCC');
                                                                             try
                                                                                mRowsInputBO.load(mRowsOutput.BusinessObject[ii].GetFieldValueAsString('X_provideRow_ID'),nil);

                                                                                   if mRowsInputBO.GetFieldValueAsString('QUnit') = mRowsInputBO.GetFieldValueAsString('Storecard_ID.MainUnitCode') then begin
                                                                                         //mrqw:=tstringlist.create;
                                                                                         //try
                                                                                         //    xsite.BaseObjectSpace.SQLSelect('select sum(quantity - DeliveredQuantity) from Issuediorders2 where X_provideRow_ID=' +
                                                                                         //               quotedstr(mRowsOutput.BusinessObject[ii].GetFieldValueAsString('X_provideRow_ID')),mrqw);
                                                                                         //    if mrqw.count>0 then  mobjednano:=NxIBStrToFloat(mrqw.Strings[0]);
                                                                                         //         mpocet_pomoc:=
                                                                                         //finally
                                                                                         //   mrqw.free;
                                                                                         //end;
                                                                                          //mpocet_pomoc:=(mRowsOutput.BusinessObject[ii].getFieldValueAsFloat('Quantity') -  mRowsOutput.BusinessObject[ii].getFieldValueAsFloat('X_vychystano'))  ;
                                                                                    // NxShowSimpleMessage(NxFloatToIBStr(mRowsInputBO.getFieldValueAsFloat('Quantity') ) + ' - '  + NxFloatToIBStr(mRowsInputBO.getFieldValueAsFloat('DeliveredQuantity')) + ' - '+NxFloatToIBStr(mRowsInputBO.getFieldValueAsFloat('X_vychystano')),nil);
                                                                                     mpocet_pomoc:=(mRowsInputBO.getFieldValueAsFloat('Quantity') - mRowsInputBO.getFieldValueAsFloat('DeliveredQuantity') -  mRowsInputBO.getFieldValueAsFloat('X_vychystano'))  ;

                                                                                    mRowsOutput.BusinessObject[ii].SetFieldValueAsFloat('Quantity',mpocet_pomoc) ;

                                                                                    //mRowsOutput.BusinessObject[ii].SetFieldValueAsFloat('Quantity',mRowsInputBO.getFieldValueAsFloat('Quantity') - mRowsInputBO.getFieldValueAsFloat('DeliveredQuantity') -  mRowsInputBO.getFieldValueAsFloat('X_vychystano'));

                                                                                    end else begin
                                                                                    //   NxShowSimpleMessage(NxFloatToIBStr(mRowsInputBO.getFieldValueAsFloat('Quantity') ) + ' - '  +NxFloatToIBStr(mRowsInputBO.getFieldValueAsFloat('DeliveredQuantity')) + ' - '+NxFloatToIBStr(mRowsInputBO.getFieldValueAsFloat('X_vychystano')),nil);

                                                                                       mpocet_pomoc:=(mRowsInputBO.getFieldValueAsFloat('Quantity') - mRowsInputBO.getFieldValueAsFloat('DeliveredQuantity') -  mRowsInputBO.getFieldValueAsFloat('X_vychystano'))  ;
                                                                                            // mpocet_pomoc:=(mRowsOutput.BusinessObject[ii].getFieldValueAsFloat('Quantity') -  mRowsOutput.BusinessObject[ii].getFieldValueAsFloat('X_vychystano')- mObjednano)  ;

                                                                                       // NxShowSimpleMessage(mRowsInputBO.getFieldValueAsstring('qunit')   +
                                                                                        //NxFloatToIBStr(mpocet_pomoc),nil);

                                                                                        mpocet_pomoc:=mpocet_pomoc/mRowsOutput.BusinessObject[ii].getFieldValueAsFloat('unitrate');

                                                                                        mRowsOutput.BusinessObject[ii].setFieldValueAsString('QUnit',mRowsOutput.BusinessObject[ii].GetFieldValueAsString('Storecard_ID.MainUnitCode')) ;




                                                                                        mRowsOutput.BusinessObject[ii].SetFieldValueAsFloat('Quantity',mpocet_pomoc) ;

                                                                                        mRowsOutput.BusinessObject[ii].SetFieldValueAsString('QUnit',mRowsOutput.BusinessObject[ii].GetFieldValueAsString('Storecard_ID.MainUnitCode')) ;

                                                                                        //NxShowSimpleMessage(mRowsOutput.BusinessObject[ii].getFieldValueAsstring('qunit')   +
                                                                                       // NxFloatToIBStr(mpocet_pomoc),nil);


                                                                                       // mRowsOutput.BusinessObject[ii].SetFieldValueAsFloat('Quantity',mRowsInputBO.getFieldValueAsFloat('Quantity') - mRowsInputBO.getFieldValueAsFloat('DeliveredQuantity') -  mRowsInputBO.getFieldValueAsFloat('X_vychystano'));
                                                                                    end;
                                                                             finally
                                                                                 mRowsInputBO.free;
                                                                             end;

                                                                             if mRowsOutput.BusinessObject[ii].getFieldValueAsFloat('Quantity')<=0 then begin
                                                                                       mRowsOutput.BusinessObject[ii].MarkForDelete;
                                                                                       mxpocet:=mxpocet-1;
                                                                             end;
                                                                             //mRowsOutput.BusinessObject[ii].SetFieldValueAsString('X_ProvideRow_ID',mpocet_pomoc) ;

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
 IA:integer;
begin
  for IA:=0 to 1 do begin

       mr_head:=tstringlist.create;
       try
       if ia=0 then
       xsite.BaseObjectSpace.SQLSelect(format('select max(ro.firm_id) from Receivedorders2 RO2 left join Receivedorders RO on ro.id=ro2.parent_id where (RO.closed = ''N'' ) and RO.ID in (%s) and RO.X_Cilovy_sklad is null group by ro.firm_id '
       ,[mIDs_dDocument]),mr_head);

       if ia=1 then
       xsite.BaseObjectSpace.SQLSelect(format('select max(ro.firm_id) from Receivedorders2 RO2 left join Receivedorders RO on ro.id=ro2.parent_id where (RO.closed = ''N'' ) and RO.ID in (%s) and RO.X_Cilovy_sklad is not null group by ro.firm_id '
       ,[mIDs_dDocument]),mr_head);


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

                                              if not ((mRowsOutput.BusinessObject[ii].GetFieldValueAsString('Storecard_id.StoreCardCategory_ID.Code')='PB')
                                                 or (mRowsOutput.BusinessObject[ii].GetFieldValueAsString('Storecard_id.StoreCardCategory_ID.Code')='Px')) then begin
                                                    //mRowsOutput.BusinessObject[ii].MarkForDelete;
                                                    //mxpocet:=mxpocet-1;
                                                 //end else begin
                                                    if index=1 then mRowsOutput.BusinessObject[ii].SetFieldValueAsFloat('Quantity',0);
                                                    if index=2 then begin
                                                       mRowsOutput.BusinessObject[ii].SetFieldValueAsFloat('Quantity',0);

                                                       mRowsInputBO:=xSite.BaseObjectSpace.CreateObject('05CPMINJW3DL342X01C0CX3FCC');

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
                                      mImportMan.OutputDocument.setFieldValueAsString('Firm_id',mImportMan.InputDocuments[0].GetFieldValueAsString('Firm_id'));
                                      mImportMan.OutputDocument.setFieldValueAsString('FirmOffice_ID',mImportMan.InputDocuments[0].GetFieldValueAsString('FirmOffice_ID'));
                                      mImportMan.OutputDocument.setFieldValueAsString('Person_id',mImportMan.InputDocuments[0].GetFieldValueAsString('Person_id'));


                                     if index=1 then begin
                                          mS_result:=BarCodeDialog_DL(xSite,mImportMan.OutputDocument,mRowsOutput,
                                                     0,0,360,480,'Expedice: ',
                                                     0,0, mIDs_dDocument,
                                                     'EAN','Storno','','přeskočit',
                                                     'Šarže');

                                            mxpocet:=mRowsOutput.Count;
                                           for ii:=0 to mRowsOutput.Count-1 do begin
                                                  for ii:=0 to mRowsOutput.Count-1 do begin

                                              if not ((mRowsOutput.BusinessObject[ii].GetFieldValueAsString('Storecard_id.StoreCardCategory_ID.Code')='PB')
                                                 or (mRowsOutput.BusinessObject[ii].GetFieldValueAsString('Storecard_id.StoreCardCategory_ID.Code')='Px')) then begin
                                                    //mRowsOutput.BusinessObject[ii].MarkForDelete;
                                                    //mxpocet:=mxpocet-1;
                                              //end else begin
                                                    if (index=1) or (index=3) then mRowsOutput.BusinessObject[ii].SetFieldValueAsFloat('Quantity',0);
                                                       mRowsOutput.BusinessObject[ii].SetFieldValueAsFloat('Quantity',0);

                                                       mRowsInputBO:=xSite.BaseObjectSpace.CreateObject('05CPMINJW3DL342X01C0CX3FCC');

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

                                 //     NxShowSimpleMessage(inttostr(mRowsOutput.Count) + ' - ' + inttostr(mRowsOutput.CountOfNotDeleted),nil);

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
     ia:=ia+1;
end;
end;













begin
end.