uses 'abra.eu.MASK.funkce_ctecky2017.Base_function','abra.eu.MASK.funkce_ctecky2017.Libs','abra.eu.MASK.funkce_ctecky2017.Forms';
 {
procedure AfterSiteOpen_Hook(Self: TSiteForm);
var
xsite:tSiteform;
mBResult:boolean;
begin
xSite := self;
    mBresult:=CteckaItem(xsite);
   xsite.Refresh;
end;

   }

procedure InitSite_Hook(Self: TSiteForm);
var

  mUser: TNxCustomBusinessObject;
  mAList: TActionList;
  i: integer;
  mAction: TBasicAction;
  mMAction: TMultiAction;
  mC: TControl;
begin
  mUser := Self.BaseObjectSpace.CreateObject('22AHIVDVAVE13C5S00CA141B44');            // přihlášený uživatel
  try
      mUser.Load(Self.CompanyCache.GetUserID, nil);
   {        // if (mUser.GetFieldValueAsBoolean('X_funkce_ctecky')) then begin
                 mAList := Self.GetMainActionList;
                  for i := 0 to mAList.ActionCount-1 do begin
                    mAction := mALIst.Actions[i];
                          if (mAction.Name = 'actFind') then begin
                              mAction.Visible := False;
                          end;
                          if (mAction.Name = 'actFindNext') then begin
                              mAction.Visible := False;
                          end;
                          //if (mAction.Name = 'actShowAgenda') then begin
                          //    mAction.Visible := False;
                          //end;
                   end; }


          if false then begin
                  mMAction := Self.GetNewMultiAction;
                  mMAction.ShowControl := True;
                  mMAction.ShowMenuItem := True;
                  mMAction.Caption := 'Ctecka';
                  mMAction.Hint := 'Čtečka';
                  mMAction.Category := 'tabList';
                  mMAction.OnExecuteItem := @StartItem;
                  mMAction.Items.Add('čtečka');
                  mMAction.Items.Add('Vychystavani průvodce');
                  mMAction.Items.Add('Vychystavani ');
                  mMAction.Items.Add('Zajištění výroby');
                  mMAction.Items.Add('Expedice');
          end;

             {     mMAction := Self.GetNewMultiAction;
                  mMAction.ShowControl := True;
                  mMAction.ShowMenuItem := True;
                  mMAction.Caption := 'Predobjednavka';
                  mMAction.Hint := 'Předobjednavka';
                  mMAction.Category := 'tabList';
                  mMAction.OnExecuteItem := @Predobjednavka;
                  mMAction.Items.Add('Předobjednavka');
              }

  finally
      mUSer.free;
  end;
end;


procedure Predobjednavka(Sender: Tcomponent;index:integer);
begin
    Predobjednavka_start(Sender,index,'4D15000101');
    Predobjednavka_start(Sender,index,'3D15000101');

end;


procedure Predobjednavka_start(Sender: Tcomponent;index:integer;mfirm_id:string);


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
  xSite :TDynSiteForm;
begin
 xSite := TComponent(Sender).DynSite;
 mID_Docqueue:='7B10000101';
 ms_doklad:=TDynSiteForm(xsite).CurrentObject.oid;

  //NxShowSimpleMessage('bb',nil);

                                              if TDynSiteForm(xsite).CurrentObject.GetFieldValueAsString('Docqueue_ID')='1S00000101' then mID_Docqueue:='8B10000101' else mID_Docqueue:='7B10000101';





                            mParams := TNxParameters.Create;
                             try
                                  mInputParams := TNxParameters.Create;
                                  try
                                   mParam := mInputParams.GetOrCreateParam(dtString, 'DocQueue_ID');
                                       mParam.AsString :=mID_Docqueue;//mID_Docqueue;
                                   if mr_head.count>1 then begin
                                      mParam := mInputParams.GetOrCreateParam(dtString, 'SelectedHeader'); // musi se z nejake hlavicky prebirat hlavickova data
                                      mParam.AsString := TDynSiteForm(xsite).CurrentObject.oid ;
                                   end;
                                    //mParam := mInputParams.GetOrCreateParam(dtString, 'SelectedRows'); // jen povolene radky
                                    //mParam.AsString := ARows.Text;
                                    mImportMan := NxCreateDocumentImportManager(xsite.BaseObjectSpace, Class_ReceivedOrder, Class_IssuedOrder);
                                    try

                                      for xx:=0 to mr_head.Count-1 do begin
                                          mImportMan.AddInputDocument(mr_head.Strings(xx));
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
                                                                            mr:=tstringlist.create;
                                                                            try
                                                                              xsite.BaseObjectSpace.SQLSelect(format('select sum(quantity) from StoreSubcards where storecard_id=%s and Store_id=%s',[quotedstr(mRowsOutput.BusinessObject[ii].GetFieldValueAsString('StoreCard_ID')),quotedstr(mRowsOutput.BusinessObject[ii].GetFieldValueAsString('Store_ID'))]),mr);
                                                                              if mr.count>0 then begin
                                                                                  mpocet_pomoc:=mRowsOutput.BusinessObject[ii].getFieldValueAsfloat('Quantity');
                                                                                  if mpocet_pomoc>=NxIBStrToFloat(mr.Strings[0]) then begin
                                                                                         mpocet_pomoc:=mpocet_pomoc-NxIBStrToFloat(mr.Strings[0]) ;
                                                                                         mRowsOutput.BusinessObject[ii].setFieldValueAsFloat('Quantity',mpocet_pomoc);
                                                                                  end else begin
                                                                                         mRowsOutput.BusinessObject[ii].setFieldValueAsFloat('Quantity',0);
                                                                                  end;
                                                                               end;
                                                                            finally
                                                                               mr.free;
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
                                              //Result := mImportMan.OutputDocument.DisplayName;
                                      end else begin
                                              //Result:='Nejsou čerpatelné řádky'
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




end;




procedure StartItem(Sender: Tcomponent;index:integer);
var
  xSite : TDynSiteForm;
  mB_result:boolean;
  mS_result:string;
  mIDs_Document:string;

begin
 xSite := TComponent(Sender).DynSite;
      mIDs_Document:=BarCode_document_Agenda (xsite,'');

  if index=1 then mB_result:=Vychystavani_RO(xsite,mIDs_Document);
  if index=2 then mS_result:=BarCodeDialog_prepravka(xSite,'05CPMINJW3DL342X01C0CX3FCC',false,
                                                     0,0,360,480,'Zdrojový doklad: ',
                                                     0,0, mIDs_Document,
                                                     'EAN','Storno','','přeskočit',
                                                     'Šarže');
  if index=3 then begin
       mS_result:=Vyroba_orderItem(xSite,mIDs_Document,'4D15000101');  // výroba bandáže  //  var AErrList: TStringList; var ADoc_OID: string;

       //mS_result:=mS_result + ' , ' + Vyroba_orderItem(xSite,mIDs_Document,'3D15000101');  // výroba bandáže  //  var AErrList: TStringList; var ADoc_OID: string;
                 if mS_result<>' , ' then
                 NxShowSimpleMessage('Proběhlo zajišténí výroby doklady: ' + mS_result,nil)
                 else NxShowSimpleMessage('Nebylo možné zajistit výrobu ',nil)
                 ;
  end;
end;

begin
end.
