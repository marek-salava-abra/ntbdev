uses 'eu.simon.EmailEshop.mail';


{Vyvolává se po uložení vlastních dat objektu do databáze.   }

procedure AfterSave_Hook(Self: TNxCustomBusinessObject);
var
 mRows:TNxCustomBusinessMonikerCollection;
 mZLBO, mIIBO:TNxCustomBusinessObject;
 mAccount_id, mDivision_ID:String;
 mBody, mFileName:String;
 mList:TStringList;
 mInputParams:TNxParameters;
 mParam:TNxParameter;
 mImportMan:TNxDocumentImportManager;
 mZL_ID:string;
 mzllist:TStringList;
begin

  if (self.GetFieldValueAsString('PAYMENTTYPE_ID')='1000000101') and (self.GetFieldValueAsString('DocQueue_ID')='1W10000101') then begin
        mRows:=self.GetLoadedCollectionMonikerForFieldCode(self.GetFieldCode('Rows'));
        mDivision_ID:=mRows.BusinessObject[0].GetFieldValueAsString('Division_ID');
        mzllist:=TStringList.create;
        self.ObjectSpace.SQLSelect(format('Select id from issueddinvoices where ReceivedOrder_ID=''%s'' ',[self.OID]),mzllist);
        if mZLList.count=0 then begin
        mInputParams := TNxParameters.Create;
            try
              mParam := mInputParams.GetOrCreateParam(dtString, 'DocQueue_ID');
              mParam.AsString := '2920000101';
              mImportMan := NxCreateDocumentImportManager(self.ObjectSpace, Class_ReceivedOrder, Class_IssuedDepositInvoice);
              try
                mImportMan.AddInputDocument(self.OID);
                mImportMan.LoadParams(mInputParams);
                mImportMan.Execute;
                mImportMan.CheckOutputDocument;
                if Assigned(mImportMan.OutputDocument) then begin
                  mImportMan.OutputDocument.SetFieldValueAsString('DocQueue_ID', '2920000101');
                  mImportMan.OutputDocument.SetFieldValueAsString('ReceivedOrder_ID',self.OID);
                  mImportMan.OutputDocument.SetFieldValueAsString('PaymentType_ID', self.GetFieldValueAsString('PaymentType_ID'));
                  mImportMan.OutputDocument.SetFieldValueAsString('TransportationType_ID', self.GetFieldValueAsString('TransportationType_ID'));
                  mImportMan.OutputDocument.SetFieldValueAsString('Firm_ID',self.GetFieldValueAsString('Firm_ID'));
                  mImportMan.OutputDocument.SetFieldValueAsString('FirmOffice_ID',self.GetFieldValueAsString('FirmOffice_ID'));
                  mImportMan.OutputDocument.SetFieldValueAsString('Currency_ID',self.GetFieldValueAsString('Currency_ID'));
                  if self.GetFieldValueAsString('Currency_ID.code')='EUR' then mImportMan.OutputDocument.SetFieldValueAsString('BankAccount_ID','5100000101');
                  mImportMan.OutputDocument.SetFieldValueAsString('VarSymbol',self.GetFieldValueAsString('ExternalNumber'));
                  mImportMan.OutputDocument.SetFieldValueAsDateTime('DueDate$Date',date+7);
                  mImportMan.OutputDocument.Save;
                  mFilename:=NxSearchReplace(mImportMan.OutputDocument.DisplayName,'/','-',[srAll])+'.pdf';
                  mZL_ID:=mImportMan.OutputDocument.OID;
                end;
              finally
                mImportMan.Free;
              end;
           finally

           end;

      end;
    end;
   if (self.GetFieldValueAsString('PAYMENTTYPE_ID')='6000000101') and (self.GetFieldValueAsString('DocQueue_ID')='1W10000101') {and (self.GetFieldValueAsString('PMState_ID') in ['2030000101','1010000101'])} then begin
        //podmínka na procesní stav vypnuta dne 6.3.2026
        mRows:=self.GetLoadedCollectionMonikerForFieldCode(self.GetFieldCode('Rows'));
        mDivision_ID:=mRows.BusinessObject[0].GetFieldValueAsString('Division_ID');
        mzllist:=TStringList.create;
        self.ObjectSpace.SQLSelect(format('Select id from issueddinvoices where ReceivedOrder_ID=''%s'' ',[self.OID]),mzllist);
        if mZLList.count=0 then begin
        mInputParams := TNxParameters.Create;
            try
              mParam := mInputParams.GetOrCreateParam(dtString, 'DocQueue_ID');
              mParam.AsString := '2920000101';
              mImportMan := NxCreateDocumentImportManager(self.ObjectSpace, Class_ReceivedOrder, Class_IssuedDepositInvoice);
              try
                mImportMan.AddInputDocument(self.OID);
                mImportMan.LoadParams(mInputParams);
                mImportMan.Execute;
                mImportMan.CheckOutputDocument;
                if Assigned(mImportMan.OutputDocument) then begin
                  mImportMan.OutputDocument.SetFieldValueAsString('DocQueue_ID', '2920000101');
                  mImportMan.OutputDocument.SetFieldValueAsString('ReceivedOrder_ID',self.OID);
                  mImportMan.OutputDocument.SetFieldValueAsString('PaymentType_ID', self.GetFieldValueAsString('PaymentType_ID'));
                  mImportMan.OutputDocument.SetFieldValueAsString('TransportationType_ID', self.GetFieldValueAsString('TransportationType_ID'));
                  mImportMan.OutputDocument.SetFieldValueAsString('Firm_ID',self.GetFieldValueAsString('Firm_ID'));
                  mImportMan.OutputDocument.SetFieldValueAsString('FirmOffice_ID',self.GetFieldValueAsString('FirmOffice_ID'));
                  mImportMan.OutputDocument.SetFieldValueAsString('Currency_ID',self.GetFieldValueAsString('Currency_ID'));
                  if self.GetFieldValueAsString('Currency_ID.code')='EUR' then mImportMan.OutputDocument.SetFieldValueAsString('BankAccount_ID','5100000101');
                  mImportMan.OutputDocument.SetFieldValueAsString('VarSymbol',self.GetFieldValueAsString('ExternalNumber'));
                  mImportMan.OutputDocument.Save;
                  mFilename:=NxSearchReplace(mImportMan.OutputDocument.DisplayName,'/','-',[srAll])+'.pdf';
                  mZL_ID:=mImportMan.OutputDocument.OID;
                end;
              finally
                mImportMan.Free;
              end;
           finally

           end;

      end;
    end;


end;




{
Vyvolává se po změně každé položky. A to pouze, pokud k této změně nedochází díky načítání objektu z databáze nebo díky vytváření kopie.
}
procedure AfterSetFieldValue_Hook(Self: TNxCustomBusinessObject; AFieldCode: Integer; AValue: TNxParameter; AOriginalValue: TNxParameter);
begin
  if (AFieldCode=self.GetFieldCode('Confirmed')) and not(AValue.AsBoolean=AOriginalValue.AsBoolean) then begin
     if self.GetFieldValueAsString('Paymenttype_ID')='1000000101' then self.SetFieldValueAsString('U_OrderState_ID','7C92000101') else self.SetFieldValueAsString('U_OrderState_ID','6C92000101');


  end;
end;

begin
end.