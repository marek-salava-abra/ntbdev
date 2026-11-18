procedure DIMPHV (OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
var
 mList:TStringList;
 mMessage:string;
 mManager:TNxDocumentImportManager;
 mParams:TNxParameters;
 mParam:TNxParameter;
 i:integer;
begin
  try
    mList:=TStringList.Create;
    OS.SQLSelect('SELECT a.id FROM PLMFinishedProducts2 A '+
                 'JOIN PLMFinishedProducts FP ON A.Parent_ID = FP.ID '+
                 'JOIN PLMJOOutputItems MI ON MI.ID = A.JOOutputItem_ID '+
                 'JOIN PLMJONodes N ON N.ID = MI.Owner_ID '+
                 'JOIN PLMJobOrders JO ON JO.ID = N.Parent_ID '+
                 'WHERE A.ReceivedBy_ID is null '+
                 'AND JO.DocQueue_ID in (''~000000O03'') '+
                 'AND EXISTS (SELECT ID FROM StoreDocuments2 WHERE FlowType = ''27'' AND ProductionTask_ID = JO.ProductionTask_ID) ',mList);
    if mList.count>0 then begin
      for i:=0 to mList.count-1 do begin
        mManager := NxCreateDocumentImportManager(OS,Class_PLMFinishedProductRow,Class_ProductReception);
      	mParams := TNxParameters.Create;
        mManager.AddInputDocument(mList.strings[i]);
      	mManager.ForcedParams := True;
      	mManager.SelectedHeader := mManager.InputHeaders(0);
      	mParams.GetOrCreateParam(dtString, 'DocQueue_ID').AsString := '~000000P03';
        mParams.GetOrCreateParam(dtString, 'Firm_ID').AsString := mManager.SelectedHeader.GetFieldValueAsString('Parent_ID.JobOrder_ID.Firm_ID');
        mParams.GetOrCreateParam(dtString, 'Store_ID').AsString:= mManager.SelectedHeader.GetFieldValueAsString('Parent_ID.JobOrder_ID.Store_ID');
      	mManager.LoadParams(mParams);
      	mManager.Execute;
      	mManager.OutputDocument.Save;
        mManager.free;
      end;
    end;
    mList.Free;
  except
   mMessage:=ExceptionMessage;
  end;
  Success := True;
  LogInfoStr := ''+mMessage;
end;


{POST_DIMPHV}

procedure POST_DIMPHV(AContext:TNxContext; ARequest: TAPIRequest; AResponse: TAPIResponse);
var
  mHeaders: TStringList;
  i,j: Integer;
  mList:TStringList;
  mMessage:string;
  mManager:TNxDocumentImportManager;
  mParams:TNxParameters;
  mParam:TNxParameter;
  mInputJSON, mOutputJSON, mRowJSON:TJSONSuperObject;
  mOS: TNxCustomObjectSpace;
begin
  j:=0;
  mOutputJSON:=TJSONSuperObject.Create;
  mInputJSON:=TJSONSuperObject.Create;
  mInputJSON:=TJSONSuperObject.ParseString(ARequest.Body,True);
  if mInputJSON.B['createPHV'] then begin
    mOS:=AContext.GetObjectSpace;
    try
      try
          mList:=TStringList.Create;
          mOutputJSON.O['rows'] := mOutputJSON.CreateJSONArray;
          mOS.SQLSelect('SELECT a.id FROM PLMFinishedProducts2 A '+
                       'JOIN PLMFinishedProducts FP ON A.Parent_ID = FP.ID '+
                       'JOIN PLMJOOutputItems MI ON MI.ID = A.JOOutputItem_ID '+
                       'JOIN PLMJONodes N ON N.ID = MI.Owner_ID '+
                       'JOIN PLMJobOrders JO ON JO.ID = N.Parent_ID '+
                       'WHERE A.ReceivedBy_ID is null '+
                       'AND JO.DocQueue_ID in (''~000000O03'') '+
                       'AND EXISTS (SELECT ID FROM StoreDocuments2 WHERE FlowType = ''27'' AND ProductionTask_ID = JO.ProductionTask_ID) ',mList);
            if mList.count>0 then begin
              for i:=0 to mList.count-1 do begin
                mRowJSON:=TJSONSuperObject.Create;
                mManager := NxCreateDocumentImportManager(mOS,Class_PLMFinishedProductRow,Class_ProductReception);
              	mParams := TNxParameters.Create;
                mManager.AddInputDocument(mList.strings[i]);
              	mManager.ForcedParams := True;
              	mManager.SelectedHeader := mManager.InputHeaders(0);
              	mParams.GetOrCreateParam(dtString, 'DocQueue_ID').AsString := '~000000P03';
                mParams.GetOrCreateParam(dtString, 'Firm_ID').AsString := mManager.SelectedHeader.GetFieldValueAsString('Parent_ID.JobOrder_ID.Firm_ID');
                mParams.GetOrCreateParam(dtString, 'Store_ID').AsString:= mManager.SelectedHeader.GetFieldValueAsString('Parent_ID.JobOrder_ID.Store_ID');
              	mManager.LoadParams(mParams);
              	mManager.Execute;
              	mManager.OutputDocument.Save;
                mRowJSON.S['DocNumber']:=mManager.OutputDocument.DisplayName;
                mOutputJSON.A['rows'].Add(mRowJSON);
                j:=j+1;
                mManager.free;
              end;
            end;
            mList.Free;
            mOutputJSON.S['body']:='created';
            mOutputJSON.I['count']:=j;
            AResponse.Body:=mOutputJSON.AsString;
            AResponse.SetHeader('Content-Type','application/json');
            AResponse.Status := 200;
          except
           mMessage:=ExceptionMessage;
          end;

    except
        mOutputJSON.S['body']:='Except '+ExceptionMessage;
        mOutputJSON.I['count']:=j;
        AResponse.Body:=mOutputJSON.AsString;
        AResponse.SetHeader('Content-Type','application/json');
        AResponse.Status := 422;
    end;


  end;
end;

begin
end.