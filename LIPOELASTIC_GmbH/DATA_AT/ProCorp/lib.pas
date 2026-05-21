
{POST_GetInvoiceID4DisplayName}

procedure POST_GetDocumentID4DisplayName(AContext:TNxContext; ARequest: TAPIRequest; AResponse: TAPIResponse);
var
  mInputJSON, mOutputJSON:TJSONSuperObject;
  mDQCode, mOrdNumber, mPeriodCode, mDisplayName, mDocumentType, mTableName, mID:string;
begin
  mInputJSON:=TJSONSuperObject.Create;
  mOutputJSON:=TJSONSuperObject.Create;
  mInputJSON:=TJSONSuperObject.ParseString(ARequest.Body,True);
  mDisplayName:=mInputJSON.S['DisplayName'];
  mDocumentType:=mInputJSON.S['DocumentType'];
  mDQCode:=NxTrapStrTrim(mDisplayName,'-');
  mOrdNumber:=NxTrapStrTrim(mDisplayName,'/');
  mPeriodCode:=mDisplayName;
   case mDocumentType of
     '03': mTableName:='IssuedInvoices';
     '04': mTableName:='ReceivedInvoices';
     '21': mTableName:='StoreDocuments';
     'RO': mTableName:='ReceivedOrders';
   end;
  mID:=AContext.SQLSelectFirstAsString('Select t.id from '+mTableName+' t left join docqueues dq on dq.id=t.docqueue_id left join periods p on p.id=t.period_id '+
                                       ' where dq.code='+QuotedStr(mDQCode)+' and p.code='+QuotedStr(mPeriodCode)+' and t.ordnumber='+mOrdNumber,'');
  try
        mOutputJSON.S['DisplayName']:=mInputJSON.S['DisplayName'];
        mOutputJSON.S['DocQueueCode']:=mDQCode;
        mOutputJSON.I['OrdNumber']:=StrToInt(mOrdNumber);
        mOutputJSON.S['PeriodCode']:=mPeriodCode;
        mOutputJSON.S['DocumentID']:=mID;
        AResponse.Body:=mOutputJSON.AsString;
        AResponse.SetHeader('Content-Type','application/json');
        AResponse.Status := 200;
  finally
    mOutputJSON.Free;
  end;
end;

begin
end.