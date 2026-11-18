uses '.lib';

procedure ProcessIssuedInvoiceQueue(OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
var
  mQueueBO, mRIBO: TNxCustomBusinessObject;
  mList: TStringList;
  mErrLog, mReceivedInvoiceName, mQueueName, mRI_ID: string;
  mJSON, mResultJSON: TJSONSuperObject;
  i: Integer;
begin
  Success := True;
  LogInfoStr := '';
  mJSON:= TJSONSuperObject.Create;
  mResultJSON:= TJSONSuperObject.Create;
  //Najdeme všechny záznamy z fronty, které jsou nezpracované
  mList:= TStringList.Create;
  try
    OS.SQLSelect(
      ' SELECT ID FROM DefRollData '+
      ' WHERE CLSID='+QuotedStr(Class_BO_Temp_Invoice_SK)+
      ' AND X_Check = ''N'' ', mList);

    LogInfoStr:= LogInfoStr + nxCrLf + 'Počet záznamů ke zpracování: '+IntToStr(mList.Count);
    for i:= 0 to mList.Count -1 do begin
      //mJSON:= mJSON.CreateJSON;
      mErrLog:= '';
      mQueueName:= '';
      mQueueBO:= OS.CreateObject(Class_BO_Temp_Invoice_SK);
      mRIBO:= OS.CreateObject(Class_ReceivedInvoice);
      try
        mQueueBO.Load(mList[i], nil);
        //Vytvoří se FP a napárují se příjemky
        if ProcessJSONData(mQueueBO, mErrLog) then begin
          mRI_ID:= OS.SQLSelectFirstAsString(
            ' SELECT A.ID FROM ReceivedInvoices A '+     //CAST(DQ.Code AS VARCHAR) ||''-''|| CAST(A.OrdNumber AS VARCHAR) || ''/'' || CAST(PE.Code AS VARCHAR)
            //' JOIN DocQueues DQ ON DQ.ID = A.DocQueue_ID '+
            //' JOIN Periods PE ON PE.ID = A.Period_ID '+
            ' WHERE (exists (SELECT 1 FROM USERDATA WHERE FIELDCODE='+IntToStr(mRIBO.GetFieldCode('U_SKIssuedInvoice_ID'))+
            ' AND CLSID='+Quotedstr(Class_ReceivedInvoice)+
            ' AND ID = A.ID AND (STRINGFIELDVALUE LIKE '+Quotedstr(mQueueBO.GetFieldValueAsString('X_Synchronizace_ID'))+')))','');
          mRIBO.Load(mRI_ID, nil);
          mReceivedInvoiceName:= mRIBO.DisplayName;
          mQueueName:= mQueueBO.GetFieldValueAsString('Name');
          mJSON.S['U_ReceivedInvoice_CZ']:= mReceivedInvoiceName;

          mResultJSON:= API_PUT(mJSON, 'IssuedInvoices', mQueueBO.GetFieldValueAsString('X_Synchronizace_ID'));
          if NxIsEmptyOID(mResultJSON.S['id']) then begin
            LogInfoStr:= LogInfoStr + nxCrLf + mQueueName + ' - Nepodařilo se provést aktualizaci čísla dokladu FV v ABRA SK.';
            LogInfoStr:= LogInfoStr + nxCrLf + 'ResultJSON: '+mResultJSON.AsString;
            LogInfoStr:= LogInfoStr + nxCrLf + 'JSON: '+mJSON.AsString;
            Success:= false;
          end;


          LogInfoStr:= LogInfoStr + nxCrLf + 'FV SK: ' + mQueueName + '--> ' + mReceivedInvoiceName + ' - Zpracováno';
        end else begin
          LogInfoStr:= LogInfoStr + nxCrLf + mQueueName + ' - Nezpracováno. Vyskytly se chyby: '+mErrLog;
          Success:= false;
        end;
      finally
        mQueueBO.Free;
        mRIBO.Free;
        //mJSON.Free;
      end;
    end;
  finally
    mList.Free;
  end;

  LogInfoStr:= LogInfoStr + nxCrLf + nxCrLf;

  //Dohledáme si všechny zpracované záznamy z fronty a provedeme jejich vymazání
  mList:= TStringList.Create;
  try
    OS.SQLSelect(
      ' SELECT ID FROM DefRollData '+
      ' WHERE CLSID='+QuotedStr(Class_BO_Temp_Invoice_SK)+
      ' AND X_Check = ''A'' ', mList);

    LogInfoStr:= LogInfoStr + nxCrLf + 'Počet záznamů ke smazání: '+IntToStr(mList.Count);

    for i:= 0 to mList.Count -1 do begin
      mQueueName:= '';
      mQueueBO:= OS.CreateObject(Class_BO_Temp_Invoice_SK);
      try
        try
          mQueueBO.Load(mList[i], nil);
          mQueueName:= mQueueBO.GetFieldValueAsString('Name');
          mQueueBO.Delete;
          LogInfoStr:= LogInfoStr + nxCrLf + 'Záznam k '+ mQueueName + ' smazán.';
        except
          LogInfoStr:= LogInfoStr + nxCrLf + 'Záznam k '+ mQueueName + ' se nepodařilo smazat. Chyba: '+ExceptionMessage;
        end;
      finally
        mQueueBO.Free;
      end;
    end;
  finally
    mList.Free;
  end;
end;

begin
end.

{
procedure ProcessIssuedInvoiceQueue(OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
var
  mQueueBO, mRIBO: TNxCustomBusinessObject;
  mList: TStringList;
  mErrLog, mReceivedInvoiceName, mQueueName: string;
  i: Integer;
begin
  Success := True;
  LogInfoStr := '';

  //Najdeme všechny záznamy z fronty, které jsou nezpracované
  mList:= TStringList.Create;
  try
    OS.SQLSelect(
      ' SELECT ID FROM DefRollData '+
      ' WHERE CLSID='+QuotedStr(Class_BO_Temp_Invoice_SK)+
      ' AND X_Check = ''N'' ', mList);

    LogInfoStr:= LogInfoStr + nxCrLf + 'Počet záznamů ke zpracování: '+IntToStr(mList.Count);

    for i:= 0 to mList.Count -1 do begin
      mErrLog:= '';
      mQueueName:= '';
      mQueueBO:= OS.CreateObject(Class_BO_Temp_Invoice_SK);
      mRIBO:= OS.CreateObject(Class_ReceivedInvoice);
      try
        mQueueBO.Load(mList[i], nil);
        //Vytvoří se FP a napárují se příjemky
        if ProcessJSONData(mQueueBO, mErrLog) then begin
          mReceivedInvoiceName:= OS.SQLSelectFirstAsString(
            ' SELECT CAST(DQ.Code AS VARCHAR) ||''-''|| CAST(A.OrdNumber AS VARCHAR) || ''/'' || CAST(PE.Code AS VARCHAR) FROM ReceivedInvoices A '+
            ' JOIN DocQueues DQ ON DQ.ID = A.DocQueue_ID '+
            ' JOIN Periods PE ON PE.ID = A.Period_ID '+
            ' WHERE (exists (SELECT 1 FROM USERDATA WHERE FIELDCODE='+IntToStr(mRIBO.GetFieldCode('U_SKIssuedInvoice_ID'))+
            ' AND CLSID='+Quotedstr(Class_ReceivedInvoice)+
            ' AND ID = A.ID AND (STRINGFIELDVALUE LIKE '+Quotedstr(mQueueBO.GetFieldValueAsString('X_Synchronizace_ID'))+')))','');

          mQueueName:= mQueueBO.GetFieldValueAsString('Name');
          LogInfoStr:= LogInfoStr + nxCrLf + 'FV SK: ' + mQueueName + '--> ' + mReceivedInvoiceName + ' - Zpracováno';
        end else begin
          LogInfoStr:= LogInfoStr + nxCrLf + mQueueName + ' - Nezpracováno. Vyskytly se chyby: '+mErrLog;
          Success:= false;
        end;
      finally
        mQueueBO.Free;
        mRIBO.Free;
      end;
    end;
  finally
    mList.Free;
  end;

  LogInfoStr:= LogInfoStr + nxCrLf + nxCrLf;

  //Dohledáme si všechny zpracované záznamy z fronty a provedeme jejich vymazání
  mList:= TStringList.Create;
  try
    OS.SQLSelect(
      ' SELECT ID FROM DefRollData '+
      ' WHERE CLSID='+QuotedStr(Class_BO_Temp_Invoice_SK)+
      ' AND X_Check = ''A'' ', mList);

    LogInfoStr:= LogInfoStr + nxCrLf + 'Počet záznamů ke smazání: '+IntToStr(mList.Count);

    for i:= 0 to mList.Count -1 do begin
      mQueueName:= '';
      mQueueBO:= OS.CreateObject(Class_BO_Temp_Invoice_SK);
      try
        try
          mQueueBO.Load(mList[i], nil);
          mQueueName:= mQueueBO.GetFieldValueAsString('Name');
          mQueueBO.Delete;
          LogInfoStr:= LogInfoStr + nxCrLf + 'Záznam k '+ mQueueName + ' smazán.';
        except
          LogInfoStr:= LogInfoStr + nxCrLf + 'Záznam k '+ mQueueName + ' se nepodařilo smazat. Chyba: '+ExceptionMessage;
        end;
      finally
        mQueueBO.Free;
      end;
    end;
  finally
    mList.Free;
  end;
end;
}

begin
end.