procedure GetInvoiceForOtherPayment(OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
var
 mList:TStringList;
 i:integer;
 mII, mCR, mCRRow:TNxCustomBusinessObject;
 mRows:TNxCustomBusinessMonikerCollection;
begin
  mList:=TStringList.Create;
  OS.SQLSelect('SELECT a.id FROM IssuedInvoices A WHERE A.DOCQUEUE_ID IN ('+QuotedStr('1Z10000101')+') AND (A.PaymentType_ID = '
               +Quotedstr('6000000101')+' ) AND ((ABS(a.Amount-a.paidAmount)<1) and not((a.Amount-a.paidAmount)=0))',mList);
  if mlist.count>0 then begin
     for i:=0 to mlist.count-1 do begin
            mII:=OS.CreateObject(Class_IssuedInvoice);
            mII.Load(mlist.strings[i],nil);
            //mAmount:=mii.GetFieldValueAsFloat('NotPaidAmount');
            mCR:=OS.CreateObject(Class_OtherIncome);
            mCr.New;
            mCr.Prefill;
            mCR.SetFieldValueAsString('DocQueue_ID','6RT0000101');
            mCr.SetFieldValueAsBoolean('VATDocument',false);
            mCR.SetFieldValueAsString('Firm_ID',mII.GetFieldValueAsString('Firm_ID'));
            mCR.SetFieldValueAsString('Description', 'Zaplacení '+mII.DisplayName);
            mCR.SetFieldValueAsString('PDocumentType','03');
            mCR.SetFieldValueAsString('PDocument_ID',mII.OID);
            mRows:=mCR.GetCollectionMonikerForFieldCode(mCR.GetFieldCode('Rows'));
             mCRRow:=mRows.AddNewObject;
             //mCRRow.SetFieldValueAsInteger('RowType',1);
             mCRRow.SetFieldValueAsString('Text','Zaplacení '+mII.DisplayName);
             mCRRow.SetFieldValueAsFloat('TAmount',mii.GetFieldValueAsFloat('NotPaidAmount'));
             mCRRow.SetFieldValueAsString('Division_ID',mII.GetLoadedCollectionMonikerForFieldCode(mII.GetFieldCode('Rows')).BusinessObject[0].GetFieldValueAsString('Division_ID'));
            mCR.Save;
            mCR.Free;
            mII.Free;
    end;
  end;
  Success := True;
  LogInfoStr := '';
end;

begin
end.