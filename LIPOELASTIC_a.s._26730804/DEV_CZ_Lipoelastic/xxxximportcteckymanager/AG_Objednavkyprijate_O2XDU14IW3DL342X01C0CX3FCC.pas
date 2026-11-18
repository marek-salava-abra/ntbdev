procedure _AfterSave_PostHook(Self: TDynSiteForm);
var
mImportMan: TNxDocumentImportManager;
  mParams: TNxParameters;
  mParam: TNxParameter;
begin
//  if osNew in TDynSiteForm(self).CurrentObject.State then begin
//        if copy(TDynSiteForm(self).CurrentObject.GetFieldValueAsString('Paymenttype_ID.Code'),1,1)='U' then begin
                           mParams := TNxParameters.Create;
                            try
                                       mImportMan := NxCreateDocumentImportManager(self.BaseObjectSpace,'01CPMINJW3DL342X01C0CX3FCC','WEN033MLM3DL35J301C0CX3F40') ;
                                         try
                                                        mImportMan.AddInputDocument(TDynSiteForm(self).CurrentObject.oid);


                                                        mParam := mParams.GetOrCreateParam(dtString, 'DocQueue_ID');
                                                        mParam.AsString :=TDynSiteForm(self).CurrentObject.GetFieldValueAsString('DocQueue_ID.X_IssuedDInvoice_ID');
                                                        mParam := mParams.GetOrCreateParam(dtString, 'Firm_ID');
                                                        mParam.AsString :=TDynSiteForm(self).CurrentObject.GetFieldValueAsString('Firm_id');

                                                         mParam := mParams.GetOrCreateParam(dtString, 'Paymenttype_ID');
                                                        mParam.AsString :=TDynSiteForm(self).CurrentObject.GetFieldValueAsString('Paymenttype_ID');


                                                         mParam := mParams.GetOrCreateParam(dtString, 'Transportationtype_ID');
                                                        mParam.AsString :=TDynSiteForm(self).CurrentObject.GetFieldValueAsString('Transportationtype_ID');

                                                         mParam := mParams.GetOrCreateParam(dtString, 'Currency_ID');
                                                        mParam.AsString :=TDynSiteForm(self).CurrentObject.GetFieldValueAsString('Currency_ID');



                                                                mParam := mParams.GetOrCreateParam(dtString, 'SelectedHeader'); // musi se z nejake hlavicky prebirat hlavickova data
                                                                mParam.AsString := TDynSiteForm(self).CurrentObject.oid;


                                                    mImportMan.LoadParams(mParams);
                                                      mImportMan.Execute;
                                                              mImportMan.OutputDocument.SetFieldValueAsString('Varsymbol',mImportMan.InputDocuments[0].getFieldValueAsString('X_varsymbol'));
                                                              mImportMan.OutputDocument.SetFieldValueAsString('DocQueue_ID',TDynSiteForm(self).CurrentObject.GetFieldValueAsString('DocQueue_ID.X_IssuedDInvoice_ID'));
                                                              mImportMan.OutputDocument.SetFieldValueAsString('Firm_ID',TDynSiteForm(self).CurrentObject.GetFieldValueAsString('Firm_ID'));

                                                              mImportMan.OutputDocument.SetFieldValueAsString('Paymenttype_ID',TDynSiteForm(self).CurrentObject.GetFieldValueAsString('Paymenttype_ID'));

                                                              mImportMan.OutputDocument.SetFieldValueAsString('Transportationtype_ID',TDynSiteForm(self).CurrentObject.GetFieldValueAsString('Transportationtype_ID'));
                                                               mImportMan.OutputDocument.SetFieldValueAsString('Currency_ID',TDynSiteForm(self).CurrentObject.GetFieldValueAsString('Currency_ID'));


                                                              mImportMan.OutputDocument.Save;
                                                                  NxShowSimpleMessage('doklad vytvořen',nil);
                                        finally
                                                mImportMan.Free;
                                        end;


                              finally
                                 mParams.Free;
                              end;
 //      end;
//end;

end;










begin
end.