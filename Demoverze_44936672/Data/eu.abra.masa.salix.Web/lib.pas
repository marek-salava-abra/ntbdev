function POST_Note(AContext: TNXContext; AInput: TJSONSuperObject; APath: String): TJSONSuperObject;
var
 mBO:TNxCustomBusinessObject;
 mStoreCard_ID:String;
begin
 Result:=TJSONSuperObject.Create;
  if not(NxIsBlank(AInput.S['code'])) then begin
    mStoreCard_ID:=AContext.SQLSelectFirstAsString('Select id from StoreCards where hidden=''N'' and ean='+QuotedStr(AInput.S['code']),'');
    if not(NxIsEmptyOID(mStoreCard_ID)) then begin
      mBO:=AContext.GetObjectSpace.CreateObject(Class_StoreCard);
      mBO.Load(mStoreCard_ID,nil);
      Result.S['status']:='ok';
      Result.S['code']:=AInput.S['code'];
      Result.S['note']:=mBO.GetFieldValueAsString('note');
      Result.S['name']:=mBO.GetFieldValueAsString('name');
      mbo.free;
    end else begin
      Result.S['status']:='error';
      Result.S['code']:=AInput.S['code'];
      Result.S['note']:='';
      Result.S['name']:='';
   end;
  end else begin
    Result.S['status']:='error';
    Result.S['code']:=AInput.S['code'];
    Result.S['note']:='';
    Result.S['name']:='';
  end;
end;

begin
end.