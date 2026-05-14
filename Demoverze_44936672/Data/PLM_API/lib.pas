function POST_Workers(AContext: TNXContext; AInput: TJSONSuperObject; APath: String): TJSONSuperObject;
var
 aBO, mOperationBO, mVYPBO:TNxCustomBusinessObject;
 mWorker_ID, mOperation_ID:string;
begin
  Result:=TJSONSuperObject.Create;
  if not(NxIsEmptyOID(AInput.S['id'])) then begin
   mWorker_ID:=AContext.SQLSelectFirstAsString('Select id from plmworkers where hidden=''N'' and id='+QuotedStr(AInput.S['id']),'');
   if not(NxIsEmptyOID(mWorker_ID)) then begin
     aBO:=AContext.GetObjectSpace.CreateObject(Class_PLMWorker);
     aBO.Load(mWorker_ID);
     Result.S['id']:=aBO.OID;
     Result.S['name']:=aBO.GetFieldValueAsString('Person_ID.FirstName')+' '+aBO.GetFieldValueAsString('Person_ID.LastName');
     mOperation_ID:=AContext.SQLSelectFirstAsString('Select id from plmoperations where finishedat$date=0 and performedby_id='+QuotedStr(AInput.S['id']),'');
     if not(NxIsEmptyOID(mOperation_ID)) then begin
        mOperationBO:=AContext.GetObjectSpace.CreateObject(Class_PLMOperation);
        mOperationBO.Load(mOperation_ID,nil);
        mVYPBO:=AContext.GetObjectSpace.CreateObject(Class_PLMJobOrder);
        mVYPBO.Load(mOperationBO.GetFieldValueAsString('JobOrdersRoutines_ID.Parent_ID.Owner_ID.Parent_ID'),nil);
        Result.S['storecard']:=mVYPBO.GetFieldValueAsString('StoreCard_ID.Code')+' '+mVYPBO.GetFieldValueAsString('StoreCard_ID.Name');
        Result.S['VYPname']:=mVYPBO.displayName;
        Result.S['Qunit']:=mVYPBO.GetFieldValueAsString('Qunit');
        Result.S['operation_name']:=mOperationBO.GetFieldValueAsString('JobOrdersRoutines_ID.Title');
        Result.S['operation_id']:=mOperationBO.oid;
        mVYPBO.free;
        mOperationBO.free;
     end else begin
        Result.S['storecard']:='';
        Result.S['VYPname']:='';
        Result.S['operation_name']:='';
        Result.S['operation_id']:='';
        Result.S['Qunit']:='';
     end;
   end else begin
     Result.S['id']:='';
     Result.S['name']:=ExceptionMessage;
     Result.S['storecard']:='';
     Result.S['VYPname']:='';
     Result.S['operation_name']:='';
     Result.S['operation_id']:='';
     Result.S['Qunit']:='';
   end;
  end;
end;

function POST_Operation(AContext: TNXContext; AInput: TJSONSuperObject; APath: String): TJSONSuperObject;
var
 aBO, mVypBO:TNxCustomBusinessObject;
 mRoutine_ID:string;
begin
  Result:=TJSONSuperObject.Create;
  if not(NxIsEmptyOID(AInput.S['operation_id'])) then begin
   mRoutine_ID:=AContext.SQLSelectFirstAsString('Select id from PLMJobOrdersRoutines where  id='+QuotedStr(AInput.S['operation_id']),'');
   if not(NxIsEmptyOID(mRoutine_ID)) then begin
     aBO:=AContext.GetObjectSpace.CreateObject(Class_PLMJobOrdersRoutine);
     aBO.Load(mRoutine_ID,nil);
     mVYPBO:=AContext.GetObjectSpace.CreateObject(Class_PLMJobOrder);
     mVYPBO.Load(aBO.GetFieldValueAsString('PArent_ID.Owner_ID.Parent_ID'),nil);
     Result.S['operation_id']:=aBO.OID;
     Result.S['name']:=mVYPBO.displayName;
     Result.S['operation_name']:=aBO.GetFieldValueAsString('Title');
     Result.S['storecard']:=mVYPBO.GetFieldValueAsString('StoreCard_ID.Code')+' '+mVYPBO.GetFieldValueAsString('StoreCard_ID.Name');
     if mVypBO.GetFieldValueAsDateTime('FinishedAt$DATE')>0 then Result.B['Finished']:=True else Result.B['Finished']:=False;
   end else begin
     Result.S['operation_id']:='';
     Result.S['name']:='';
     Result.S['operation_name']:='';
     Result.B['Finished']:=False;
   end;
  end;
end;

function POST_CreateOperation(AContext: TNXContext; AInput: TJSONSuperObject; APath: String): TJSONSuperObject;
var
 mOperation, mVYPBO, aBO:TNxCustomBusinessObject;
begin
 Result:=TJSONSuperObject.Create;
 if not(NxIsEmptyOID(AInput.S['operation_id'])) and not(NxIsEmptyOID(AInput.S['worker_id'])) then begin
   mOperation:=AContext.GetObjectSpace.CreateObject(Class_PLMOperation);
    try
     aBO:=AContext.GetObjectSpace.CreateObject(Class_PLMJobOrdersRoutine);
     aBO.Load(AInput.S['operation_id'],nil);
     mVYPBO:=AContext.GetObjectSpace.CreateObject(Class_PLMJobOrder);
     mVYPBO.Load(aBO.GetFieldValueAsString('Parent_ID.Owner_ID.Parent_ID'),nil);
     mOperation.New;
     mOperation.Prefill;
     mOperation.SetFieldValueAsString('BusOrder_ID', mVYPBO.GetFieldValueAsString('BusOrder_ID'));
     mOperation.SetFieldValueAsString('BusTransaction_ID', mVYPBO.GetFieldValueAsString('BusTransaction_ID'));
     mOperation.SetFieldValueAsString('Division_ID', mVYPBO.GetFieldValueAsString('Division_ID'));
     mOperation.SetFieldValueAsString('JobOrdersRoutines_ID',aBO.OID);
     mOperation.SetFieldValueAsString('SalaryClass_ID',mOperation.GetFieldValueAsString('JobOrdersRoutines_ID.SalaryClass_ID'));
     mOperation.SetFieldValueAsString('WorkPlace_ID',mOperation.GetFieldValueAsString('JobOrdersRoutines_ID.WorkPlace_ID'));
     mOperation.SetFieldValueAsDateTime('StartedAt$DATE',Now);
     moperation.SetFieldValueAsString('PerformedBy_ID',AInput.S['worker_id']);
     moperation.SetFieldValueAsBoolean('OperationResult',True);
     mOperation.Save;
     Result.S['status']:='ok';
     Result.S['displayname']:=mOperation.DisplayName;
    finally
     mOperation.free;
    end;

 end else begin
  Result.S['status']:='error';
  Result.S['displayname']:='';
 end;
end;

function POST_EndOperation(AContext: TNXContext; AInput: TJSONSuperObject; APath: String): TJSONSuperObject;
var
 mOperation, mVYPBO, aBO:TNxCustomBusinessObject;
begin
 Result:=TJSONSuperObject.Create;
 if not(NxIsEmptyOID(AInput.S['operation_id'])) then begin
   mOperation:=AContext.GetObjectSpace.CreateObject(Class_PLMOperation);
    try
     mOperation.load(AInput.S['operation_id'],nil);
     mOperation.SetFieldValueAsDateTime('FinishedAt$DATE',Now);
     moperation.SetFieldValueAsFloat('Quantity',AInput.D['quantity']);
     mOperation.SetFieldValueAsFloat('Duration',24*(mOperation.GetFieldValueAsDateTime('FinishedAt$DATE')- mOperation.GetFieldValueAsDateTime('StartedAt$DATE')));
     mOperation.Save;
     Result.S['status']:='ok';
     Result.S['displayname']:=mOperation.DisplayName;
    finally
     mOperation.free;
    end;

 end else begin
  Result.S['status']:='error';
  Result.S['displayname']:='';
 end;
end;


begin
end.