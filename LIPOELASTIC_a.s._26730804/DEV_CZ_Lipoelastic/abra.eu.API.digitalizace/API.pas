const
	GetStockDynSQL = 'DCGGWH4VRREL3FWD002BG34ZPK';


//  POST http://localhost/data/script/API/Lib/Stock
//HTTP
//Tělo požadavku:

{
	"info_type": "Quantity",
	"Date": "2019-06-12",
	"Store_ID": "2100000101,3200000101",
	"StoreCard_ID": "2100000101,3100000101"
}


//POST http://localhost/demo15/issuedinvoices/import/receivedorders HTTP/1.1
//Host: localhost
//Content-Type: application/json
//Authorization: Basic QVBJOmFwaQ==
//Cache-Control: no-cache
//Postman-Token: ec6e4774-7468-46cf-ac0d-26d859ce962e
{
	"input_document_clsid": "ReceivedOrder",
	"output_document_clsid": "IssuedInvoice",
	"input_documents": "2500000101",
	"params": {
		"ImportDocuments": true,
		"UndeliveredQuantity": true,
		"DeliveryDate": "2018-06-27T15:57:00.000Z",
		"DocQueue_ID": "5600000101"
	}
//}





function GetMachine_ID(AContext: TNxContext; AInput: TJSONSuperObject; APath: String): TJSONSuperObject;
begin

end;

function GetWorker_ID(AContext: TNxContext; AInput: TJSONSuperObject; APath: String): TJSONSuperObject;
begin

end;


function POST_Stock(AContext: TNxContext; AInput: TJSONSuperObject; APath: String): TJSONSuperObject;
var
	mParams: TNxParameters;
	mApplication: Variant;
	mCond: TNxDynSQLConditionKind;
	mDynSQL, mDataset: Variant;
	mResult: Double;
	mInfoType: String;
begin
	mResult := 0;
	Result := TJSONSuperObject.Create;
	mInfoType := AInput.S['info_type'];
	if not NxIsBlank(mInfoType) then begin
		mApplication := GetAbraOLEApplication;
		mDynSQL := mApplication.CreateCustomCommand(GetStockDynSQL);
		SetupConditionList(mDynSQL, 'StoreCard_ID', AInput);
		SetupConditionList(mDynSQL, 'Store_ID', AInput);
		SetupConditionDate(mDynSQL, 'Date', AInput);

		mDataset := mDynSQL.RowsetByName('MAIN');
		mDataset.UsedFields := mInfoType;
		mDataset.Used := True;
		mDynSQL.Execute;
		while not mDataset.EOF do begin
			mResult := mResult + mDataset.Data.ValueByName(mInfoType);
			mDataset.Next;
		end;

		Result.S[mInfoType] := FloatToStr(mResult);
	end else begin
		RaiseException('Missing param info_type.');
	end;
end;

procedure SetupConditionList(const ADynSQL: Variant; const AField: String; const AInput: TJSONSuperObject);
var
	mValues: TStrings;
	mCond: Variant;
	i: Integer;
	mStringValues: String;
begin
	mStringValues := AInput.S[AField];
	if not NxIsBlank(mStringValues) then begin
		mValues := TStringList.Create;
		NxTokenToStrings(mStringValues, ',', mValues);

		mCond := ADynSQL.ConstraintByID(AField);
		mCond.UsedKind := ckList;
		mCond.ValueList.Clear;
		mCond.ValueList.BeginUpdate;

		for i := 0 to (mValues.Count - 1) do
		mCond.ValueList.Add('''' + mValues[i] + '''');

		mCond.ValueList.EndUpdate;
	end;
end;

procedure SetupConditionDate(const ADynSQL: Variant; const AField: String; AInput: TJSONSuperObject);
var
	mCond: Variant;
	mDate: TDateTime;
begin
	if not NxIsBlank(AInput.S[AField]) then begin
		mDate := AInput.DT8601[AField];
		if mDate <> 0 then begin
			mCond := ADynSQL.ConstraintByID(AField);
			mCond.UsedKind := ckRange;
			mCond.Value := FloatToStr(mDate);
		end;
	end;
end;

begin
end.


begin
end.