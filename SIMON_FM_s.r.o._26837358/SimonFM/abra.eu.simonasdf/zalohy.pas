
function CreateDepositPPZ(AOS:  TNxCustomObjectSpace; AFirm_ID:string; APerson_ID:String; ADescription:String; aAmount:Double; AActivityNumber: String; AActivityOID:String; ADivision:String): string;
var
  mOS: TNxCustomObjectSpace;
  mCashReceived, mCashReceivedRows, mRelation: TNxCustomBusinessObject;
  mCashReceived_ID:String;
  mPPZRows:TNxCustomBusinessMonikerCollection;
begin
  mOS := AOS;

      if aAmount>0 then begin
         mCashReceived:= mos.CreateObject(Class_CashReceived);
         mCashReceived.New;
         mCashReceived.Prefill;
         mCashReceived.SetFieldValueAsString('CashDesk_ID','1000000101');
         mCashReceived.SetFieldValueAsString('DocQueue_ID','7100000101');
         if NxIsEmptyOID(AFirm_ID) then mCashReceived.SetFieldValueAsString('Firm_ID','AAA1000000');
         if not(NxIsEmptyOID(AFirm_ID)) then mCashReceived.SetFieldValueAsString('Firm_ID',AFirm_ID);
         mCashReceived.SetFieldValueAsString('Person_ID',APerson_ID);
         mCashReceived.SetFieldValueAsString('Description',ADescription);
         
         //ShowMessage(mCashReceived.DisplayName);
         mPPZRows:= mCashReceived.GetLoadedCollectionMonikerForFieldCode(mCashReceived.GetFieldCode('Rows'));
         mCashReceivedRows:=mPPZRows.AddNewObject;
         mCashReceivedRows.SetFieldValueAsInteger('RowType',1);
         mCashReceivedRows.SetFieldValueAsString('Text', 'Manipulační poplatek k přijeti servisu '+AActivityNumber);
         mCashReceivedRows.SetFieldValueAsFloat('TotalPrice', aAmount);
         mCashReceivedRows.SetFieldValueAsString('VatRate_ID','02100X0000');
         mCashReceivedRows.SetFieldValueAsString('Division_ID',ADivision);
         mCashReceivedRows.SetFieldValueAsString('BusTransaction_ID','1000000101');
         mCashReceivedRows.SetFieldValueAsString('IncomeType_ID','1300000101');
         mCashReceived.save;
         Result:=mCashReceived.OID;

            mRelation := mOS.CreateObject('01ZXNDSYDVD135SA02K2CQM5AW');
            mRelation.New;
            mRelation.SetFieldValueAsString('LEFTSIDE_ID', AActivityOID);
            mRelation.SetFieldValueAsString('RIGHTSIDE_ID', mCashReceived.OID);
            mRelation.SetFieldValueAsInteger('REL_DEF', 1213);
            mRelation.Save;
            mRelation.free;

        mCashReceived.Free;
      end;


end;

function CreateDepositFV(AOS:  TNxCustomObjectSpace; AFirm_ID:string; APerson_ID:String; ADescription:String; aAmount:Double; AActivityNumber: String; AActivityOID:String; ADivision:String): string;
var
  mOS: TNxCustomObjectSpace;
  mIssuedInvoice, mIssuedInvoiceRows, mRelation: TNxCustomBusinessObject;
  mIssuedInvoice_ID:String;
  mFVRows:TNxCustomBusinessMonikerCollection;
begin
  mOS := AOS;

      if aAmount>0 then begin
         mIssuedInvoice:= mos.CreateObject(Class_IssuedInvoice);
         mIssuedInvoice.New;
         mIssuedInvoice.Prefill;
         mIssuedInvoice.SetFieldValueAsString('DocQueue_ID','I100000101');
         if NxIsEmptyOID(AFirm_ID) then mIssuedInvoice.SetFieldValueAsString('Firm_ID','AAA1000000');
         if not(NxIsEmptyOID(AFirm_ID)) then mIssuedInvoice.SetFieldValueAsString('Firm_ID',AFirm_ID);
         mIssuedInvoice.SetFieldValueAsString('Person_ID',APerson_ID);
         mIssuedInvoice.SetFieldValueAsString('Description',ADescription);
         mIssuedInvoice.SetFieldValueAsString('PaymentType_ID', '6000000101');

         //ShowMessage(mCashReceived.DisplayName);
         mFVRows:= mIssuedInvoice.GetLoadedCollectionMonikerForFieldCode(mIssuedInvoice.GetFieldCode('Rows'));
         mIssuedInvoiceRows:=mFVRows.AddNewObject;
         mIssuedInvoiceRows.SetFieldValueAsInteger('RowType',1);
         mIssuedInvoiceRows.SetFieldValueAsString('Text', 'Manipulační poplatek k přijeti servisu '+AActivityNumber);
         mIssuedInvoiceRows.SetFieldValueAsFloat('TotalPrice', aAmount);
         mIssuedInvoiceRows.SetFieldValueAsString('VatRate_ID','02100X0000');
         mIssuedInvoiceRows.SetFieldValueAsString('Division_ID',ADivision);
         mIssuedInvoiceRows.SetFieldValueAsString('BusTransaction_ID','1000000101');
         mIssuedInvoiceRows.SetFieldValueAsString('IncomeType_ID','1300000101');
         mIssuedInvoice.save;
         Result:=mIssuedInvoice.OID;

            mRelation := mOS.CreateObject('01ZXNDSYDVD135SA02K2CQM5AW');
            mRelation.New;
            mRelation.SetFieldValueAsString('LEFTSIDE_ID', AActivityOID);
            mRelation.SetFieldValueAsString('RIGHTSIDE_ID', mIssuedInvoice.OID);
            mRelation.SetFieldValueAsInteger('REL_DEF', 1200);
            mRelation.Save;
            mRelation.free;

         mIssuedInvoice.free;
      end;

end;


begin
end.