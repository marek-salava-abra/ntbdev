procedure UpdateDocumentBlockingsValidTo(OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
var
  mDocumentBlockingBO: TNxCustomBusinessObject;
  mDocumentBlockingIDs: TStringList;
  i: Integer;
begin
  Success := True;
  LogInfoStr := '';

  mDocumentBlockingIDs := TStringList.Create;
  try
    OS.SQLSelect(
      'SELECT ID FROM DocumentBlockings '+
      'WHERE DocumentType IN (''03'', ''60'')',
      mDocumentBlockingIDs);

    for i := 0 to mDocumentBlockingIDs.Count - 1 do
    begin
      mDocumentBlockingBO := OS.CreateObject(Class_DocumentBlocking);
      try
        mDocumentBlockingBO.Load(mDocumentBlockingIDs[i], nil);
        mDocumentBlockingBO.SetFieldValueAsDateTime('ValidTo$DATE', IncDay(Date, -1));
        mDocumentBlockingBO.Save;
        LogInfoStr:= LogInfoStr + nxCrLf + mDocumentBlockingBO.DisplayName + ' - ' + FormatDateTime('DD/MM/YYYY', IncDay(Date, -1));
      finally
        mDocumentBlockingBO.Free;
      end;
    end;
  finally
    mDocumentBlockingIDs.Free;
  end;
end;


begin
end.
