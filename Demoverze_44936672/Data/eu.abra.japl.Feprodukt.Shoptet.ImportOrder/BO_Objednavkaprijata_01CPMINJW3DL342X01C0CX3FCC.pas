uses 'eu.abra.japl.Feprodukt.Shoptet.ImportOrder.fce';
procedure AfterSave_Hook(Self: TNxCustomBusinessObject);
var
mParams: TNxParameters;
mManager: TNxDocumentImportManager;
mObj2: TNxCustomBusinessObject;
ID:string;
begin
      if (osNew in self.state) and (self.GetFieldValueAsString('DocQueue_ID')='1R00000101') and
         (Self.GetFieldValueAsString('PaymentType_ID') IN ['1100000101', '1400000101', '1500000101', '2520000101'])   then begin
        mParams := TNxParameters.Create();
        mManager := NxCreateDocumentImportManager(self.ObjectSpace,Class_ReceivedOrder,Class_IssuedDepositInvoice);
        mManager.AddInputDocument(self.OID);
        mParams.GetOrCreateParam(dtString, 'DocQueue_ID').AsString := 'D600000101';
        mManager.LoadParams(mParams);
        mManager.Execute;
        mManager.OutputDocument.SetFieldValueAsString('VarSymbol',self.GetFieldValueAsString('ExternalNumber'));
        mManager.OutputDocument.SetFieldValueAsString('Currency_ID',self.GetFieldValueAsString('Currency_ID'));
        mManager.OutputDocument.SetFieldValueAsString('Country_ID',self.GetFieldValueAsString('Country_ID'));
        mManager.OutputDocument.SetFieldValueAsString('Firm_id',self.GetFieldValueAsString('Firm_id'));
        mManager.OutputDocument.SetFieldValueAsString('FirmOffice_id',self.GetFieldValueAsString('FirmOffice_id'));
        mManager.OutputDocument.SetFieldValueAsString('BankAccount_ID',self.GetFieldValueAsString('BankAccount_ID'));
        mManager.OutputDocument.SetFieldValueAsString('ReceivedOrder_ID',self.OID);
        mManager.OutputDocument.SetFieldValueAsString('Description', 'Záloha k: '+self.DisplayName);
        mManager.OutputDocument.Save;
        //ID:= mManager.OutputDocument.OID;
        mManager.free;
        mParams.Clear;
      end;

      if (Self.GetFieldValueAsInteger('TradeType') = 1)and (osNew in self.state) and (self.GetFieldValueAsString('DocQueue_ID')='1R00000101') and (self.GetFieldValueAsString('PMState_ID')='2000000101') then begin
        ID:= GetDeposit_inv(self.ObjectSpace,self.OID);
        mObj2:= self.ObjectSpace.CreateObject(Class_IssuedDepositInvoice);
        mObj2.load(ID,nil);
        mParams := TNxParameters.Create();
        mManager := NxCreateDocumentImportManager(self.ObjectSpace,Class_IssuedDepositInvoice,Class_VATIssuedDepositInvoice);
        mManager.AddInputDocument(ID);
        mParams.GetOrCreateParam(dtString, 'DocQueue_ID').AsString := '9700000101';
        mParams.GetOrCreateParam(dtBoolean, 'ImportDepositRows').AsBoolean := true;
        //mParams.GetOrCreateParam(dtBoolean, 'ImportTextRows').AsBoolean := true;
        mParams.GetOrCreateParam(dtString, 'VATRateIDOnRow').AsString := '02100X0000';
        mParams.GetOrCreateParam(dtFloat, 'DepositAmount').Asfloat := mObj2.getFieldValueAsFloat('Amount');
        mManager.LoadParams(mParams);
        mManager.Execute;
        mManager.OutputDocument.SetFieldValueAsString('Currency_ID',mObj2.GetFieldValueAsString('Currency_ID'));
        mManager.OutputDocument.SetFieldValueAsString('Country_ID',mObj2.GetFieldValueAsString('Country_ID'));
        mManager.OutputDocument.SetFieldValueAsString('Firm_id',mObj2.GetFieldValueAsString('Firm_id'));
        mManager.OutputDocument.SetFieldValueAsString('FirmOffice_id',mObj2.GetFieldValueAsString('FirmOffice_id'));
        mManager.OutputDocument.SetFieldValueAsString('Description', 'Zdaněná záloha k: '+mObj2.DisplayName);
        mManager.OutputDocument.Save;
        mManager.free;
        mParams.Clear;
        //mObj.SetFieldValueAsBoolean('Confirmed',true);
        //self.SetFieldValueAsString('PMState_ID','2000000101');
        mObj2.free;
      end;
end;


begin
end.