uses 'abra.eu.MASK.funkce_ctecky2017.Libs','abra.eu.MASK.funkce_ctecky2017.Forms';

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
                                 'Vychystávání','Expedice','','','','','','','','Zpět');
        if (mI_Result99=1) then begin
                    mI_Result1:=0;
              while mI_Result1<>10 do begin
                          mI_Result1:=mForm_Function(xsite,0,0,360,480,'Vychystávání','_','_',
                                                   'Lokace','Přepravky','Zajištění výroby','','','','','','_','Zpět');
                                 //if (mI_Result1=1) or (mI_Result1=2) or (mI_Result3=1) then begin
                                    mIDs_dDocument:='';
                                    mIDs_dDocument:= BarCode_document(xSite,'05CPMINJW3DL342X01C0CX3FCC',0,0,360,480, mID_doklad,'Zdrojový doklad: ','Ean','Pokračovat','','');;
                                 //end;
                                     //NxShowSimpleMessage(inttostr(mI_Result1) + ' - ' + mIDs_dDocument,nil);
                                            if (mI_Result1=1) then begin
                                                 //NxShowSimpleMessage(mIDs_dDocument,nil);
                                                 if mIDs_dDocument<>'' then begin
                                                     //NxShowSimpleMessage(inttostr(mI_Result1) + ' - ' + 'Před vychystáváním',nil);
                                                     mB_result:=Vychystavani_RO(xsite,mIDs_dDocument);

                                                      mI_Resultc:=0;
                                                     mI_Resultc:=mDialogForm(xsite,'Výroba','Zajistit výrobu nevychystaných položek', 'Vyrobit','','','','','','','','','Storno');
                                                                    if mI_Resultc=1 then begin
                                                                              if mIDs_dDocument<>'' then begin
                                                                                                    mx_result:='';
                                                                                                    mx_result:=Vyroba_orderItem(xSite,mIDs_dDocument,'4D15000101');  // výroba bandáže  //  var AErrList: TStringList; var ADoc_OID: string;
                                                                                                    mx_result:=mx_result + ' , ' + Vyroba_orderItem(xSite,mIDs_dDocument,'3D15000101');  // výroba bandáže  //  var AErrList: TStringList; var ADoc_OID: string;
                                                                                                    if mx_result<>' , ' then  begin
                                                                                                        NxShowSimpleMessage('Proběhlo zajišténí výroby doklady: ' + mx_result,nil) ;
                                                                                                        nxbeep(btSuccess);
                                                                                                        end else begin
                                                                                                        NxShowSimpleMessage('Nebylo možné zajistit výrobu ',nil);
                                                                                                        nxbeep(btfailure);
                                                                                                   end;
                                                                                                end;


                                                    end;

                                                 end;
                                            end;
                                            if (mI_Result1=2) then begin
                                                 // ********************    podle zboží
                                                 //NxShowSimpleMessage(mIDs_dDocument,nil);
                                                 if mIDs_dDocument<>'' then  begin
                                                     //NxShowSimpleMessage(inttostr(mI_Result1) + ' - ' + 'Před lokaci',nil);
                                                     mS_result:=BarCodeDialog_prepravka(xSite,'05CPMINJW3DL342X01C0CX3FCC',false,
                                                      0,0,360,480,'Zdrojový doklad: ',
                                                      0,0, mIDs_dDocument,
                                                      'EAN','Storno','','přeskočit',
                                                      'Šarže');
                                                 end;
                                                 {   mI_Resultc:=0;
                                                     mI_Resultc:=mDialogForm(xsite,'Výroba','Zajistit výrobu nevychystaných položek', 'Vyrobit','','','','','','','','','Storno');
                                                                    if mI_Resultc=1 then begin
                                                                              if mIDs_dDocument<>'' then begin
                                                                                                mx_result:='';
                                                                                                    mx_result:=Vyroba_orderItem(xSite,mIDs_dDocument,'4D15000101');  // výroba bandáže  //  var AErrList: TStringList; var ADoc_OID: string;
                                                                                                    mx_result:=mx_result + ' , ' + Vyroba_orderItem(xSite,mIDs_dDocument,'3D15000101');  // výroba bandáže  //  var AErrList: TStringList; var ADoc_OID: string;
                                                                                                    if mx_result<>' , ' then
                                                                                                        NxShowSimpleMessage('Proběhlo zajišténí výroby doklady: ' + mx_result,nil)
                                                                                                    else NxShowSimpleMessage('Nebylo možné zajistit výrobu ',nil);
                                                                                                end;


                                                    end;  }
                                            end;

                                            if (mI_Result1=3) then begin

                                                 if mIDs_dDocument<>'' then begin
                                                      //NxShowSimpleMessage(inttostr(mI_Result1) + ' - ' + 'výroba',nil);
                                                      mS_result:='';
                                                      mS_result:=Vyroba_orderItem(xSite,mIDs_dDocument,'4D15000101');  // výroba bandáže  //  var AErrList: TStringList; var ADoc_OID: string;
                                                      mS_result:=mS_result + ' , ' + Vyroba_orderItem(xSite,mIDs_dDocument,'3D15000101');  // výroba bandáže  //  var AErrList: TStringList; var ADoc_OID: string;
                                                      if mS_result<>' , ' then begin
                                                          NxShowSimpleMessage('Proběhlo zajišténí výroby doklady: ' + mS_result,nil) ;
                                                          nxbeep(btSuccess);

                                                      end else begin
                                                      NxShowSimpleMessage('Nebylo možné zajistit výrobu ',nil);
                                                      end;
                                                  end;
                                            end;


                                            //if (mI_Result1=4) then NxShowSimpleMessage('4',nil);
                                            //if (mI_Result1=5) then NxShowSimpleMessage('5',nil);
                                            //if (mI_Result1=6) then NxShowSimpleMessage('6',nil);
                                            //if (mI_Result1=7) then NxShowSimpleMessage('7',nil);
                                            //if (mI_Result1=8) then NxShowSimpleMessage('8',nil);
                                            //if (mI_Result1=9) then NxShowSimpleMessage('9',nil);

                                            if (mI_Result1=10) then mI_Result99:=0;

                  end;
        end;

        if (mI_Result99=2) then begin
              mI_Result1:=0;
              while mI_Result1<>10 do begin
                          mI_Result1:=mForm_Function(xsite,0,0,360,480,'Expedice','','',
                                                   'Expedice','Krize','','','','','','','','Zpět');

                                 mIDs_dDocument:='';
                                 mIDs_dDocument:= BarCode_document(xSite,'05CPMINJW3DL342X01C0CX3FCC',0,0,360,480, mID_doklad,'Zdrojový doklad: ','Ean','Pokračovat','','');;

                                            if (mI_Result1=1) then begin
                                                if mIDs_dDocument<>'' then  begin
                                                      mi:=xsite.BaseObjectSpace.SQLExecute(format('update Receivedorders2 RO2 set ro2.X_dodano=0 where RO2.parent_ID in (%s)',[mIDs_dDocument])) ;


                                                     mS_result:=BarCodeDialogDL_krize(xSite,'05CPMINJW3DL342X01C0CX3FCC',false,
                                                      0,0,360,480,'Zdrojový doklad pro vyskladnění: ',
                                                      0,0, mIDs_dDocument,
                                                      'EAN','Storno','','přeskočit',
                                                      'Šarže');

                                                      mx_result:='';
                                                        mx_result:=ExpediceRO_krize(xsite,mIDs_dDocument,mI_Result1);

                                                        if mx_result<>'' then begin
                                                            NxShowSimpleMessage('Proběhlo vyskladnění doklady: ' + mx_result,nil);
                                                            nxbeep(btSuccess);
                                                            mi:=xsite.BaseObjectSpace.SQLExecute(format('update Receivedorders2 RO2 set ro2.X_dodano=0 where RO2.parent_ID in (%s)',[mIDs_dDocument]));
                                                        end;

                                                 end;

                                              end;






                                                 {if mIDs_dDocument<>'' then begin
                                                        mx_result:='';
                                                        mx_result:=ExpediceRO(xsite,mIDs_dDocument,mI_Result1);

                                                        if mx_result<>'' then begin
                                                            NxShowSimpleMessage('Proběhlo vyskladnění doklady: ' + mx_result,nil);
                                                            mi:=xsite.BaseObjectSpace.SQLExecute(format('update receivedorders2 set X_vychystano=0 where (ID in (%s))',[mIDs_dDocument]));
                                                        end;
                                                 end; }


                                            if (mI_Result1=2) then begin
                                              if mIDs_dDocument<>'' then  begin
                                                      mx_result:='';
                                                        mx_result:=ExpediceRO_krize(xsite,mIDs_dDocument,mI_Result1);

                                                        if mx_result<>'' then begin
                                                            NxShowSimpleMessage('Proběhlo vyskladnění doklady: ' + mx_result,nil);
                                                            mi:=xsite.BaseObjectSpace.SQLExecute(format('update Receivedorders2 RO2 set ro2.X_vychystano=0 where RO2.parent_ID in (%s)',
                                                            [mIDs_dDocument]));
                                                            nxbeep(btSuccess);
                                                        end;

                                                 end;
                                            end;
                                        {
                                            if (mI_Result1=3) then begin
                                              if mIDs_dDocument<>'' then  begin
                                                      mx_result:='';
                                                        mx_result:=ExpediceRO_Lokace(xsite,mIDs_dDocument,mI_Result1);

                                                        if mx_result<>'' then begin
                                                            NxShowSimpleMessage('Proběhlo vyskladnění doklady: ' + mx_result,nil);
                                                            mi:=xsite.BaseObjectSpace.SQLExecute(format('update Receivedorders2 RO2 set ro2.X_vychystano=0 where RO2.parent_ID in (%s)',
                                                            [mIDs_dDocument]));
                                                            nxbeep(btSuccess);
                                                        end;

                                                 end;
                                            end;    }
                                          {

                                            if (mI_Result1=3) then begin
                                                if mIDs_dDocument<>'' then  begin
                                                      mi:=xsite.BaseObjectSpace.SQLExecute(format('update Receivedorders2 RO2 set ro2.X_dodano=0 where RO2.parent_ID in (%s)',[mIDs_dDocument])) ;


                                                     mS_result:=BarCodeDialogDL_prepravka(xSite,'05CPMINJW3DL342X01C0CX3FCC',false,
                                                      0,0,360,480,'Zdrojový doklad pro vyskladnění: ',
                                                      0,0, mIDs_dDocument,
                                                      'EAN','Storno','','přeskočit',
                                                      'Šarže');

                                                      mx_result:='';
                                                        mx_result:=ExpediceRO_krize(xsite,mIDs_dDocument,mI_Result1);

                                                        if mx_result<>'' then begin
                                                            NxShowSimpleMessage('Proběhlo vyskladnění doklady: ' + mx_result,nil);
                                                            mi:=xsite.BaseObjectSpace.SQLExecute(format('update Receivedorders2 RO2 set ro2.X_dodano=0 where RO2.parent_ID in (%s)',[mIDs_dDocument]));
                                                        end;

                                                 end;

                                              end;           }






                                            //if (mI_Result1=4) then NxShowSimpleMessage('4',nil);
                                            //if (mI_Result1=5) then NxShowSimpleMessage('5',nil);
                                            //if (mI_Result1=6) then NxShowSimpleMessage('6',nil);
                                            //if (mI_Result1=7) then NxShowSimpleMessage('7',nil);
                                            //if (mI_Result1=8) then NxShowSimpleMessage('8',nil);
                                            //if (mI_Result1=9) then NxShowSimpleMessage('9',nil);



                  end;
        end;
    end;
    //NxShowSimpleMessage('Funkce čtečky byla ukončena',nil);
    Beep;

    mI_Result99:=10;
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
                                              if ((mRowsOutput.BusinessObject[ii].GetFieldValueAsString('Storecard_id.StoreCardCategory_ID')='~00000000G')
                                                 or (mRowsOutput.BusinessObject[ii].GetFieldValueAsString('Storecard_id.StoreCardCategory_ID')='~000000002')) then begin
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
  ia:integer;
begin

for IA:=0 to 1 do begin

       maa:=tstringlist.create;

       if ia=0 then
       xsite.BaseObjectSpace.SQLSelect(format('select max(ro.firm_id) from Receivedorders2 RO2 left join Receivedorders RO on ro.id=ro2.parent_id where (RO.closed = ''N'' ) and RO.ID in (%s) and RO.X_Cilovy_sklad is null group by ro.firm_id '
       ,[mIDs_dDocument]),maa);

       if ia=1 then
       xsite.BaseObjectSpace.SQLSelect(format('select max(ro.firm_id) from Receivedorders2 RO2 left join Receivedorders RO on ro.id=ro2.parent_id where (RO.closed = ''N'' ) and RO.ID in (%s) and RO.X_Cilovy_sklad is not null group by ro.firm_id '
       ,[mIDs_dDocument]),maa);

       if maa.count>0 then begin

           for iaa:=0 to maa.Count-1 do begin
                   mr_head:=TStringList.create;
                   try
                   xsite.BaseObjectSpace.SQLSelect(format('select ro.id from Receivedorders2 RO2 left join Receivedorders RO on ro.id=ro2.parent_id where (RO.closed = ''N'' ) and RO.ID in (%s) and ro.firm_id=%s group by ro.id'
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


                                                                   mRowsInputBO:=xSite.BaseObjectSpace.CreateObject('05CPMINJW3DL342X01C0CX3FCC');

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
                                                  mImportMan.OutputDocument.setFieldValueAsString('Firm_id',mImportMan.InputDocuments[0].GetFieldValueAsString('Firm_id'));
                                                  mImportMan.OutputDocument.setFieldValueAsString('FirmOffice_ID',mImportMan.InputDocuments[0].GetFieldValueAsString('FirmOffice_ID'));
                                                  mImportMan.OutputDocument.setFieldValueAsString('Person_id',mImportMan.InputDocuments[0].GetFieldValueAsString('Person_id'));





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
        ia:=ia+1;
end;
end;





function ExpediceRO_lokace(xSite:TSiteForm;mIDs_dDocument:String;index:integer):string;
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
                                      mImportMan.OutputDocument.setFieldValueAsString('Firm_id',mbo_ro.GetFieldValueAsString('Firm_id'));
                                      mImportMan.OutputDocument.setFieldValueAsString('FirmOffice_ID',mbo_ro.GetFieldValueAsString('FirmOffice_ID'));
                                      mImportMan.OutputDocument.setFieldValueAsString('Person_id',mbo_ro.GetFieldValueAsString('Person_id'));


                                     if index=1 then begin
                                          mS_result:=BarCodeDialog_DL(xSite,mImportMan.OutputDocument,mRowsOutput,
                                                     0,0,360,480,'Expedice: ',
                                                     0,0, mIDs_dDocument,
                                                     'EAN','Storno','','přeskočit',
                                                     'Šarže');
                                     end;

                                      if index=2 then begin
                                          mS_result:=BarCodeDialog_DL_lokace(xSite,mImportMan.OutputDocument,mRowsOutput,
                                                     0,0,360,480,'Expedice: ',
                                                     0,0, mIDs_dDocument,
                                                     'EAN','Storno','','přeskočit',
                                                     'Šarže');
                                     end;

                                     if (index=1) or (index=2 ) then begin
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
 mbo_ReceivedOrder_row:TNxCustomBusinessObject;
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
                                       mbo_ReceivedOrder_row:=xsite.BaseObjectSpace.CreateObject('05CPMINJW3DL342X01C0CX3FCC');
                                       try
                                       mbo_ReceivedOrder_row.load(copy(mr_local.Strings[ii],1,10),nil);
                                       mstorecard_id:='';
                                                  mPocet_zapis:=BarCodeDialog(xSite,'05CPMINJW3DL342X01C0CX3FCC',false,
                                                                 mbo_ReceivedOrder_row,
                                                                 0,0,360,480,'Zdrojový doklad: ',
                                                                 0,0, mIDs_dDocument,
                                                                 'EAN','Storno','','přeskočit',
                                                                 'Šarže');
                                                  //NxShowSimpleMessage(NxFloatToIBStr(mPocet_zapis),nil);
                                        mstorecard_id:=mbo_ReceivedOrder_row.GetFieldValueAsString('Storecard_ID');
                                        finally
                                           mbo_ReceivedOrder_row.free;
                                        end;

                                        if mPocet_zapis<0 then begin
                                             mPocet_zapis:=(mPocet_zapis*(-1)) + 1;
                                             mpokracuj:=false;
                                        end;
                                        if mPocet_zapis>0 then begin
                                                mr_zapis:=TStringList.create;
                                                     try
                                                            xsite.BaseObjectSpace.SQLSelect(
                                                            format('select ro2.id from Receivedorders2 RO2 left join Receivedorders RO on ro.id=ro2.parent_id where (RO.closed = ''N'') and ((ro2.X_specifikace_id is null) and (ro2.X_ExternalSpecification ='''')) and ((RO2.Quantity - Ro2.DeliveredQuantity-Ro2.X_vychystano)>0) and (RO2.Storecard_ID=%s and (RO.ID in (%s)))',
                                                            [quotedstr(mstorecard_id),mIDs_dDocument])
                                                            ,mr_zapis);
                                                            if mr_zapis.count>0 then begin
                                                                for i:=0 to mr_zapis.Count-1 do begin
                                                                       mbo_ReceivedOrder_row:=xsite.BaseObjectSpace.CreateObject('05CPMINJW3DL342X01C0CX3FCC');
                                                                              try
                                                                                  mbo_ReceivedOrder_row.load(copy(mr_zapis.Strings[i],1,10),nil);
                                                                                  if mPocet_zapis>0 then begin
                                                                                          if mbo_ReceivedOrder_row.GetFieldValueAsFloat('Quantity')-mbo_ReceivedOrder_row.GetFieldValueAsFloat('DeliveredQuantity')-mbo_ReceivedOrder_row.GetFieldValueAsFloat('X_vychystano')>0 then begin
                                                                                              mRow_zapis:=mPocet_zapis-
                                                                                                          mbo_ReceivedOrder_row.GetFieldValueAsFloat('Quantity')-mbo_ReceivedOrder_row.GetFieldValueAsFloat('DeliveredQuantity')-mbo_ReceivedOrder_row.GetFieldValueAsFloat('X_vychystano');
                                                                                                   if mRow_zapis>=0 then begin
                                                                                                           mRow_zapis:=mbo_ReceivedOrder_row.GetFieldValueAsFloat('Quantity')-mbo_ReceivedOrder_row.GetFieldValueAsFloat('DeliveredQuantity')-mbo_ReceivedOrder_row.GetFieldValueAsFloat('X_vychystano');
                                                                                                           mi_SQL:=xsite.BaseObjectSpace.SQLExecute('update receivedorders2 set x_vychystano=' + NxFloatToIBStr(mbo_ReceivedOrder_row.GetFieldValueAsFloat('X_vychystano') + mRow_zapis) + ' where id=' + QuotedStr(mbo_ReceivedOrder_row.OID));;
                                                                                                           mPocet_zapis:= mPocet_zapis-mRow_zapis;
                                                                                                   end else begin
                                                                                mi_SQL:=xsite.BaseObjectSpace.SQLExecute('update receivedorders2 set x_vychystano=' + NxFloatToIBStr(mbo_ReceivedOrder_row.GetFieldValueAsFloat('X_vychystano') + mPocet_zapis) + ' where id=' + QuotedStr(mbo_ReceivedOrder_row.OID));;
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