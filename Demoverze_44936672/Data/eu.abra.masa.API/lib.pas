
{POST_InvoicesForPaymentDate}

procedure POST_InvoicesForPaymentDate(AContext:TNxContext; ARequest: TAPIRequest; AResponse: TAPIResponse);
var
  mHeaders,mInvoiceList: TStringList;
  i: Integer;
  mInputJSON, mOutputJSON, mInvJSON:TJSONSuperObject;
  mName, mValue, mSQL: string;
  mDateFrom,mDateTo:extended;
begin
  mHeaders := TStringList.Create;
  mOutputJSON:=TJSONSuperObject.Create;
  mInputJSON:=TJSONSuperObject.Create;
  try
    ARequest.GetHeaders(mHeaders);
    mInputJSON:=TJSONSuperObject.ParseString(ARequest.Body,True);
    for i := 0 to mHeaders.Count - 1 do begin
      mName:=mHeaders.Strings[i];
      mValue:=ARequest.GetHeaderValue(mName);
      //mOutputJSON.S[mName]:=mValue;
    end;
    mDateFrom:=mInputJSON.DT8601['DateFrom'];
    mDateTo:=mInputJSON.DT8601['DateTo'];
    if (mDateFrom<mDateTo) then begin
        mSQL:='SELECT A.ID FROM IssuedInvoices A WHERE EXISTS (SELECT 1 FROM PaymentsForDocument_VIEW PFD WHERE PFD.DocDate$DATE >= '
              +IntToStr(trunc(mDateFrom))+' AND PFD.DocDate$DATE < '+IntToStr(trunc(mDateTo))+
              ' AND PFD.PDocumentType = ''03'' AND PFD.PDocument_ID = A.ID)';
        mInvoiceList:=TStringList.Create;
        AContext.SQLSelect(mSQL,mInvoiceList);
        mOutputJSON.O['Invoices'] := mOutputJSON.CreateJSONArray;
        if mInvoiceList.count>0 then begin
         for i:=0 to mInvoiceList.count-1 do begin
           mInvJSON:=TJSONSuperObject.Create;
           mInvJSON.S['ID']:=mInvoiceList.strings[i];
           mOutputJSON.A['Invoices'].Add(mInvJSON);
         end;
        end;
        //mOutputJSON.S['body']:=mSQL;
        AResponse.Body:=mOutputJSON.AsString;
        AResponse.SetHeader('Content-Type','application/json');
        AResponse.Status := 200;
    end else begin
        mOutputJSON.S['body']:='Wrong Content, DateFrom > DateTo';
        AResponse.Body:=mOutputJSON.AsString;
        AResponse.SetHeader('Content-Type','application/json');
        AResponse.Status := 422;
    end;
  finally
    mHeaders.Free;
  end;
end;

begin
end.