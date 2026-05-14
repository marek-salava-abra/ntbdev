uses 'EU.Aabra.Mask.Validace.lib',
     '_Knihovny_ALL.Komunikace'
;
{
Vyvolává se po uložení vlastních dat objektu do databáze.
}
procedure AfterSave_Hook(Self: TNxCustomBusinessObject);
var
mImportMan: TNxDocumentImportManager;
  mParams,mInputParams: TNxParameters;
  mParam,mInputParam: TNxParameter;
  mselectedrows1,mselectedrows2:tstringlist;
  mRowsOutput,mRowsZL, mRows:TNxCustomBusinessMonikerCollection;
  mRowsOutputDocument:TNxCustomBusinessMonikerCollection;
  i,ii,x:integer;
  mNameVoucher:string;
  mr:TStringList;
  mstring,mfile:string;
begin
  try
       if (osNew in self.State) and (self.GetFieldValueAsString('DocQueue_ID.X_Email')<>'') then begin
                                 //NxShowSimpleMessage(self.GetFieldValueAsString('DocQueue_ID.X_Email'),nil);
                                if not NxIsBlank('') then mFile:=iPrintDocument(self,'') else mFile:='';
                                mRows:=self.GetLoadedCollectionMonikerForFieldCode(self.GetFieldCode('Rows'));
                                mstring:=iSendMailx(self.ObjectSpace, 'Doklad: ' + Self.DisplayName , 'Právě Vám byla odeslán doklad s číslem: ' +  Self.DisplayName ,
                                self.GetFieldValueAsString('DocQueue_ID.X_Email'), '','','1100000101', mfile,mRows.BusinessObject[0].GetFieldValueAsString('Division_ID'),self);
       end;
  Except
   if CFxNxRuntime.NxGetEnvironmentType=reRuntimeExe then
     NxShowSimpleMessage('Doklad se neodeslal',nil);
  end;



  if (osNew in self.State) and (not nxisemptyoid(self.GetFieldValueAsString('DocQueue_ID.X_IssuedDInvoice_ID'))) then begin
        if (self.GetFieldValueAsString('PaymentType_ID')='3A40000101') or (self.GetFieldValueAsString('PaymentType_ID')='2A40000101') or (self.GetFieldValueAsString('PaymentType_ID')='1100000101') or  (self.GetFieldValueAsString('PaymentType_ID')='9000000101') or (self.GetFieldValueAsString('PaymentType_ID')='B000000101') or (self.GetFieldValueAsString('PaymentType_ID')='1500000101')
            or (self.GetFieldValueAsString('PaymentType_ID')='3A50000101')
            or (self.GetFieldValueAsString('PaymentType_ID')='4A50000101')
        then begin
           //NxShowSimpleMessage('Záloha', nil);
           mselectedrows1:=tstringlist.create;
           mselectedrows2:=tstringlist.create;
           try
           mRowsOutput := self.GetLoadedCollectionMonikerForFieldCode(self.GetFieldCode('Rows'));

           for i:=0 to mRowsOutput.count-1 do begin
               if  (mRowsOutput.BusinessObject[i].GetFieldValueAsString('Storecard_ID.StoreCardCategory_ID')<>'~00000000L') then begin
                    mSelectedRows2.add(mRowsOutput.BusinessObject[i].oid);
               end else begin
                    if true then  begin
                          for ii:=0 to trunc(mRowsOutput.BusinessObject[i].GetFieldValueAsFloat('Quantity')-1) do begin
                                mSelectedRows1.add(mRowsOutput.BusinessObject[i].oid);



                                mParams := TNxParameters.Create;
                                mImportMan := NxCreateDocumentImportManager(self.ObjectSpace, '01CPMINJW3DL342X01C0CX3FCC', 'WEN033MLM3DL35J301C0CX3F40');
                                     try
                                              mImportMan.AddInputDocument(self.oid);
                                                mParam := mParams.GetOrCreateParam(dtString, 'SelectedHeader'); // musi se z nejake hlavicky prebirat hlavickova data
                                                                mParam.AsString := self.oid;
                                                mParam := mParams.GetOrCreateParam(dtString, 'SelectedRows'); // jen povolene radky
                                                        mParam.AsString := mSelectedRows1.Text;
                                                mParam := mParams.GetOrCreateParam(dtString, 'DocQueue_ID');
                                                        mParam.AsString :='47D2000101';
                                                        //
                                                mParam := mParams.GetOrCreateParam(dtString, 'Firm_ID');
                                                        mParam.AsString :=self.GetFieldValueAsString('Firm_id');

                                                mParam := mParams.GetOrCreateParam(dtString, 'Paymenttype_ID');
                                                        mParam.AsString :=self.GetFieldValueAsString('Paymenttype_ID');


                                                 mParam := mParams.GetOrCreateParam(dtString, 'Transportationtype_ID');
                                                        mParam.AsString :=self.GetFieldValueAsString('Transportationtype_ID');

                                                 mParam := mParams.GetOrCreateParam(dtString, 'Currency_ID');
                                                        mParam.AsString :=self.GetFieldValueAsString('Currency_ID');
                                                mNameVoucher:='';
                                                                     if ii=0 then mNameVoucher:=copy(mRowsOutput.BusinessObject[i].GetFieldValueAsString('text'),1,9);
                                                                     if ii=1 then mNameVoucher:=copy(mRowsOutput.BusinessObject[i].GetFieldValueAsString('text'),11,9);
                                                                     if ii=2 then mNameVoucher:=copy(mRowsOutput.BusinessObject[i].GetFieldValueAsString('text'),21,9);
                                                                     if ii=3 then mNameVoucher:=copy(mRowsOutput.BusinessObject[i].GetFieldValueAsString('text'),31,9);
                                                                     if ii=4 then mNameVoucher:=copy(mRowsOutput.BusinessObject[i].GetFieldValueAsString('text'),41,9);
                                                                     if ii=5 then mNameVoucher:=copy(mRowsOutput.BusinessObject[i].GetFieldValueAsString('text'),51,9);
                                                                     if ii=6 then mNameVoucher:=copy(mRowsOutput.BusinessObject[i].GetFieldValueAsString('text'),61,9);
                                                                     if ii=7 then mNameVoucher:=copy(mRowsOutput.BusinessObject[i].GetFieldValueAsString('text'),71,9);

                                                mImportMan.LoadParams(mParams);
                                                mImportMan.Execute;

                                                    mImportMan.OutputDocument.SetFieldValueAsString('Varsymbol',mImportMan.InputDocuments[0].getFieldValueAsString('X_varsymbol'));
                                                    mImportMan.OutputDocument.SetFieldValueAsString('DocQueue_ID','47D2000101');
                                                    mImportMan.OutputDocument.SetFieldValueAsString('Firm_ID',mImportMan.InputDocuments[0].GetFieldValueAsString('Firm_ID'));
                                                    mImportMan.OutputDocument.SetFieldValueAsString('Paymenttype_ID',mImportMan.InputDocuments[0].GetFieldValueAsString('Paymenttype_ID'));
                                                    mImportMan.OutputDocument.SetFieldValueAsString('Transportationtype_ID',mImportMan.InputDocuments[0].GetFieldValueAsString('Transportationtype_ID'));
                                                    mImportMan.OutputDocument.SetFieldValueAsString('BankAccount_ID',mImportMan.InputDocuments[0].GetFieldValueAsString('BankAccount_ID'));
                                                    mImportMan.OutputDocument.SetFieldValueAsString('Currency_ID',mImportMan.InputDocuments[0].GetFieldValueAsString('Currency_ID'));
                                                  mImportMan.OutputDocument.SetFieldValueAsString('X_Voucher',mNameVoucher);
                                              mRowszl := mImportMan.OutputDocument.GetLoadedCollectionMonikerForFieldCode(mImportMan.OutputDocument.GetFieldCode('Rows'));
                                                      for x:=0 to mRowsZL.count-1 do begin
                                                          mRowszl.BusinessObject[x].SetFieldValueAsFloat('Quantity',1);
                                                          if mRowszl.BusinessObject[x].GetFieldValueAsinteger('Rowtype')=4 then begin
                                                                mRowszl.BusinessObject[x].SetFieldValueAsString('Text',mNameVoucher);
                                                                mRowszl.BusinessObject[x].SetFieldValueAsFloat('Tamount',mRowsOutput.BusinessObject[i].GetFieldValueAsFloat('Unitprice'));
                                                          end;

                                                      end;
                                              mImportMan.OutputDocument.save ;
                                             // NxShowSimpleMessage('Záloha zboží ' + '05', nil);
                                     finally
                                                mImportMan.free;
                                                mInputParams.free;
                                     end;


                                        mSelectedRows1.free;
                                        mSelectedRows1:=TStringList.create;



                          end;   // konec cyklu jednotek
                    end;    // podminka
               end;


           end;

         //  NxShowSimpleMessage('Záloha zboží ' + IntToStr(mSelectedRows2.count), nil);
         //  NxShowSimpleMessage('Záloha voucher ' + IntToStr(mSelectedRows1.count) , nil);

           if mSelectedRows2.count>0 then begin
                     //NxShowSimpleMessage('Záloha zboží ' + '01', nil);
                    mParams := TNxParameters.Create;
                       mImportMan := NxCreateDocumentImportManager(self.ObjectSpace, '01CPMINJW3DL342X01C0CX3FCC', 'WEN033MLM3DL35J301C0CX3F40');
                       try
                                mImportMan.AddInputDocument(self.oid);
                                                mParam := mParams.GetOrCreateParam(dtString, 'SelectedHeader'); // musi se z nejake hlavicky prebirat hlavickova data
                                                                mParam.AsString := self.oid;
                                                mParam := mParams.GetOrCreateParam(dtString, 'SelectedRows'); // jen povolene radky
                                                        mParam.AsString := mSelectedRows2.Text;
                                                mParam := mParams.GetOrCreateParam(dtString, 'DocQueue_ID');
                                                        mParam.AsString :=self.GetFieldValueAsString('DocQueue_ID.X_IssuedDInvoice_ID');
                                                        //N200000101
                                                mParam := mParams.GetOrCreateParam(dtString, 'Firm_ID');
                                                        mParam.AsString :=self.GetFieldValueAsString('Firm_id');

                                                mParam := mParams.GetOrCreateParam(dtString, 'Paymenttype_ID');
                                                        mParam.AsString :=self.GetFieldValueAsString('Paymenttype_ID');


                                                 mParam := mParams.GetOrCreateParam(dtString, 'Transportationtype_ID');
                                                        mParam.AsString :=self.GetFieldValueAsString('Transportationtype_ID');

                                                 mParam := mParams.GetOrCreateParam(dtString, 'Currency_ID');
                                                        mParam.AsString :=self.GetFieldValueAsString('Currency_ID');


                        mImportMan.LoadParams(mParams);
                        mImportMan.Execute;
                      //  NxShowSimpleMessage('Záloha zboží ' + '04', nil);
                              if self.getFieldValueAsString('X_varsymbol')<>'0' then
                                     mImportMan.OutputDocument.SetFieldValueAsString('Varsymbol',mImportMan.InputDocuments[0].getFieldValueAsString('X_varsymbol'));
                              mImportMan.OutputDocument.SetFieldValueAsString('DocQueue_ID',mImportMan.InputDocuments[0].GetFieldValueAsString('DocQueue_ID.X_IssuedDInvoice_ID'));
                              mImportMan.OutputDocument.SetFieldValueAsString('Firm_ID',mImportMan.InputDocuments[0].GetFieldValueAsString('Firm_ID'));
                              mImportMan.OutputDocument.SetFieldValueAsString('Paymenttype_ID',mImportMan.InputDocuments[0].GetFieldValueAsString('Paymenttype_ID'));
                              mImportMan.OutputDocument.SetFieldValueAsString('Transportationtype_ID',mImportMan.InputDocuments[0].GetFieldValueAsString('Transportationtype_ID'));
                              mImportMan.OutputDocument.SetFieldValueAsString('BankAccount_ID',mImportMan.InputDocuments[0].GetFieldValueAsString('BankAccount_ID'));
                              mImportMan.OutputDocument.SetFieldValueAsString('Currency_ID',mImportMan.InputDocuments[0].GetFieldValueAsString('Currency_ID'));
                      mr:=tstringlist.create;
                              Try
                                    self.ObjectSpace.sqlselect('Select sum(Amount) from IssuedDInvoices where ReceivedOrder_ID=' + quotedstr(self.oid) + ' and docqueue_ID=' + quotedstr('47D2000101'),mr);
                                    //NxShowSimpleMessage(mr.Strings[0],nil);

                                    if NxIBStrToFloat(mr.Strings[0])>0 then begin
                                        //NxShowSimpleMessage(NxFloatToIBStr(self.GetFieldValueAsFloat('amount') - NxIBStrToFloat(mr.strings[0])),nil);

                                        //mImportMan.OutputDocument.SetFieldValueAsFloat('Amount',(self.GetFieldValueAsFloat('amount') - NxIBStrToFloat(mr.strings[0])));
                                    end;
                              finally
                                  mr.free;
                              end;
                        mImportMan.OutputDocument.save ;
                       // NxShowSimpleMessage('Záloha zboží ' + '05', nil);
                      finally
                          mImportMan.free;
                          mInputParams.free;
                      end;

           end;










          finally
              mselectedrows1.free;
              mselectedrows2.free;
          end;



      end;


  end;



end;



begin
end.