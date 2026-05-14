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
                 'WHERE A.ReceivedBy_ID is null AND JO.DocQueue_ID=''2L20000101'' ',mList);
    if mList.count>0 then begin
      mManager := NxCreateDocumentImportManager(OS,Class_PLMFinishedProductRow,Class_ProductReception);
    	mParams := TNxParameters.Create;
      mManager.AddInputDocuments(mList);
    	mManager.ForcedParams := True;
    	mManager.SelectedHeader := mManager.InputHeaders(0);
    	mParams.GetOrCreateParam(dtString, 'DocQueue_ID').AsString := '1J10000101';
    //  mParams.GetOrCreateParam(dtString, 'Store_ID').AsString := '1B00000101';        GAJDOS
    	mManager.LoadParams(mParams);
    	mManager.Execute;
    	mManager.OutputDocument.Save;
      mManager.free;
    end;
    mList.Free;
  except
   mMessage:=ExceptionMessage;
  end;

  Success := True;
  LogInfoStr := ''+mMessage;
end;

begin
end.