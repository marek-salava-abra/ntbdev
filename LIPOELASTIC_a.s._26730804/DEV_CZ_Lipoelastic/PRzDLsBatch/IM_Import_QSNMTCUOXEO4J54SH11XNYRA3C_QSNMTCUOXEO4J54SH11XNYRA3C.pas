procedure AfterFillOutputRowFromInputRow_Hook(Self: TNxDocumentImportManager; AInputRow: TNxCustomBusinessObject; aOutputRow: TNxCustomBusinessObject);
var
mr:tstringlist;
i:integer;
mBO_pohyb_sarze,mdocrowbatches:TNxCustomBusinessObject;
mBO_MonikerInput,mBO_MonikerOutput:TNxCustomBusinessMonikerCollection;
mBOReceivedOrder2:TNxCustomBusinessObject;
mi:double;
minteger:integer;
begin
     //if AInputRow.GetFieldValueAsInteger('Storecard_ID.Category') =2 then begin
             //mr:=TStringList.create;
               //   try
                 //       mBO_MonikerInput:=AInputRow.GetLoadedCollectionMonikerForFieldCode(AInputRow.GetFieldCode('DocRowBatches'));
                 //       mBO_MonikerOutput:=aOutputRow.GetLoadedCollectionMonikerForFieldCode(aOutputRow.GetFieldCode('DocRowBatches'));
                          // for i:=0 to mBO_MonikerInput.Count-1 do begin
                          //                   mdocrowbatches:=mBO_MonikerOutput.AddNewObject;
                          //
                          //                                                mdocrowbatches.Prefill;
                          //                                                mdocrowbatches.setFieldValueAsstring('QUnit',mBO_MonikerInput.BusinessObject[i].getFieldValueAsString('QUnit'));
                          //                                                mdocrowbatches.SetFieldValueAsFloat('Unitrate',mBO_MonikerInput.BusinessObject[i].GetFieldValueAsFloat('unitrate'));
                          //                                                mdocrowbatches.SetFieldValueAsFloat('Quantity',mBO_MonikerInput.BusinessObject[i].GetFieldValueAsFloat('Quantity'));
                          //                                                mdocrowbatches.setFieldValueAsstring('StoreBatch_ID',mBO_MonikerInput.BusinessObject[i].GetFieldValueAsstring('StoreBatch_ID'));
                          // end;


                 // finally
                 //     mr.free;
                 // end;
                 mr:=tstringlist.create;
                 try

                      if not NxIsEmptyOID(aOutputRow.getFieldValueAsString('ProvideRow_ID')) then begin   // pokud není vytvořena vazba na RO
                       AInputRow.ObjectSpace.SQLSelect('select io2.SourceHeader_ID||io2.Source_ID||ro2.X_ProvideRow_ID from storedocuments2 sd2 left join issuedorders2 ii2 on ii2.id=sd2.ProvideRow_ID left join ReceivedOrdersToIssuedOrders io2 on io2.Target_ID=ii2.id left join ReceivedOrders2 ro2 on ro2.id=io2.Source_ID' +
                                                      ' where sd2.id=' +  quotedstr(AInputRow.OID),mr);
                       if mr.count>0 then begin

                            aOutputRow.SetFieldValueAsString('ProvideRowType','RO');// vytvoření  vazby
                            aOutputRow.SetFieldValueAsString('Provide_ID',copy(mr.Strings[0],1,10));
                            aOutputRow.SetFieldValueAsString('ProvideRow_ID',copy(mr.Strings[0],11,10));
                             if not NxIsBlank(copy(mr.Strings[0],11,10)) then begin   // pokud není vazba na OP
                                mBOReceivedOrder2:= AInputRow.ObjectSpace.CreateObject('05CPMINJW3DL342X01C0CX3FCC');
                                         try
                                            mBOReceivedOrder2.load(copy(mr.Strings[0],11,10),nil);
                                            mi:=0;
                                            mi:=mBOReceivedOrder2.GetFieldValueAsFloat('DeliveredQuantity') + aOutputRow.GetFieldValueAsFloat('Quantity') ; // zápis čerpání
                                            mBOReceivedOrder2.SetFieldValueAsFloat('DeliveredQuantity',mi);
                                            mBOReceivedOrder2.SetFieldValueAsDateTime('DeliveryDate$DATE',aOutputRow.GetFieldValueAsDateTime('parent_id.docdate$date'))  ;
                                            if not NxIsEmptyOID(AInputRow.getFieldValueAsString('X_ProvideRow_ID')) then begin
                                                  aOutputRow.SetFieldValueAsString('X_ProvideRow_ID', AInputRow.getFieldValueAsString('X_ProvideRow_ID')) ;
                                            end;
                                            mBOReceivedOrder2.save;
                                         finally
                                          mBOReceivedOrder2.free;

                                         end;
                              end;
                        //minteger:=AInputRow.ObjectSpace.SQLExecute('update ReceivedOrders set closed=''A'' where id=' + quotedstr(copy(mr.Strings[0],1,10))) ;
                      end;
                    end;
                finally
                    mr.free;
                end;

     //end;
end;
begin
end.