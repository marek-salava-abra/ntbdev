uses
  'REST_SkladTerm.U_Const',
  'REST_SkladTerm.U_Func',
  'REST_SkladTerm.U_TemporaryStorage',
  'StandardUnits.U_GetId';

function ReadParam(AReportHelper: TNxQRScriptHelper; AParameterName: String) : String;
begin
  Result := GlobParams.GetOrCreateParam(dtString, AParameterName).AsString;
  gLog.WriteEventFmt(logDebug, 'ReadParam-> %s = %s', [AParameterName, Result]);
end;

////////////////////////////////////////////////////////////////////////////////
procedure PA_PrintReports (OS: TNxCustomObjectSpace;
  var Success: Boolean; var LogInfoStr: String);
var
  ds: TMemTable;
  mInTransaction: boolean;
  mTempFile: String;
  mResponse: TMemoryStream;
  listPrint : TStringList;
begin
  Success := True;
  LogInfoStr := '';

  gLog := TNxCustomLog.Create(REST_LogName);
  ds := TMemTable.Create(nil);
  try
    //nekonecny cyklus. koncim v 22:00
    repeat
      Sleep(10000);
      gLog.InitInternalLog;

      if(ds.Active)then begin
        ds.Close;
        ds.Fields.Clear;
      end;

      OS.SQLSelect2(
        'SELECT id, Document_ID, DynSource_ID, Report_ID, Filepath, PrinterName, Copies, Parameters' + nxCrLf +
        'FROM ' + REST_TABLE_Print + ' WHERE Status=0 ORDER BY id',
        ds);
      if (not ds.Active) or (ds.RecordCount = 0) then
        continue;

      ds.first;
      while(not ds.Eof) do
      begin
        //test, zda objekt stale existuje

        //tisknu v transakci. potrebuju zamknout prave tisknutej tisk, aby se nevytiskl v jine
        //pl. uloze novu
        mInTransaction := true; //nebudu zapinat transakci. dela to nejakej problem //OS.InTransaction;
        if not mInTransaction then
          OS.StartTransaction(taReadCommited);
        try
          //zapisu ze jsem vytiskl (aby to uz nikdo nebral). pokud chyba, tak odroluju zpet
          OS.SQLExecute('UPDATE ' + REST_TABLE_Print + nxCrLf +
            'SET Status=1, DatePrint$DATE = ' + NxFloatToIBStr(now) + nxCrLf +
            'WHERE id='+QuotedStr(ds.FieldByName('id').AsString));

          // nastavim globalni promenou pro sestavu
          GlobParams.GetOrCreateParam(dtString, PRINT_GLOBAL_PARAM_NAME).AsString := ds.FieldByName('Parameters').AsString;
          try
            // tisknu buď report nebo soubor
            if not CFxOID.IsEmpty(trim(ds.FieldByName('Report_ID').AsString)) then
            begin
              // do souboru
              if trim(ds.FieldByName('Filepath').AsString) <> '' then
              begin
                if not DirectoryExists(ExtractFilePath(trim(ds.FieldByName('Filepath').AsString))) then
                  RaiseException('Cesta neexistuje: ' + ExtractFilePath(trim(ds.FieldByName('Filepath').AsString)));

                listPrint := TStringList.Create;
                try
                  listPrint.Add(ds.FieldByName('Document_ID').AsString);
                  NxPrintByIDs(
                    NxCreateContext(OS),
                    listPrint,
                    ds.FieldByName('DynSource_ID').AsString,
                    ds.FieldByName('Report_ID').AsString,
                    rtoFile, pekPDF,
                    ExtractFilePath(trim(ds.FieldByName('Filepath').AsString)),
                    ExtractFileName(trim(ds.FieldByName('Filepath').AsString))
                  );
                finally
                  listPrint.Free;
                end;
              end
              else  //na tiskárnu
              begin
                if(not checkPrinterName(OS, trim(ds.FieldByName('PrinterName').AsString)))then
                  RaiseException('Tiskarna neexistuje: '+trim(ds.FieldByName('PrinterName').AsString));

                PrintReportToPrinterByID(
                  NxCreateContext(OS),
                  ds.FieldByName('Document_ID').AsString,
                  ds.FieldByName('DynSource_ID').AsString,
                  ds.FieldByName('Report_ID').AsString,
                  trim(ds.FieldByName('PrinterName').AsString),
                  ds.FieldByName('Copies').AsInteger
                );
              end;
            end
            else if trim(ds.FieldByName('Filepath').AsString) <> '' then
            begin
              mTempFile := '';
              // pokud jde o web. odkaz, tak ho musim stahnout
              if StartsStr('http', ds.FieldByName('Filepath').AsString) then
              begin
                mResponse := TMemoryStream.Create;
                try
                  mTempFile := NxGetTempDir + ds.FieldByName('Document_ID').AsString + '.pdf';
                  CFxInternet.HTTPGetBinary(ds.FieldByName('Filepath').AsString, '', mResponse);
                  mResponse.SaveToFile(mTempFile);
                finally
                  mResponse.Free;
                end;
              end
              else
              begin
                mTempFile := ds.FieldByName('Filepath').AsString;
              end;

              if (mTempFile <> '') then
              begin
                if PrintWithPDFtoPrinter then
                begin
                  NxExecFile('cmd /C C:\FloresSystem\PDFPrint\PDFtoPrinter.exe "' + mTempFile + '" "' + ds.FieldByName('PrinterName').AsString + '"', True, True);
                  gLog.WriteEventFmt(logDebug,'cmd /C C:\FloresSystem\PDFPrint\PDFtoPrinter.exe "' + mTempFile + '" "' + ds.FieldByName('PrinterName').AsString + '" %s', ['']);
                end
                else
                  ShellAPI.PrintFile(mTempFile, ds.FieldByName('PrinterName').AsString);
              end
              else
              begin
                RaiseException('Nepodařilo se získat cestu k souboru');
              end;
            end
            else
            begin
              RaiseException('Není vyplněno ID reportu ani cesta k souboru');
            end;
          finally
            // smazu globalni promenout
            GlobParams.Delete(GlobParams.IndexOf(GlobParams.GetOrCreateParam(dtString, PRINT_GLOBAL_PARAM_NAME)));
          end;

          //commit
          if not mInTransaction then
            OS.Commit;

          //zaloguju projistotu v chranene sekci
          try
            gLog.WriteEventFmt(logNotice, 'PRINT OK: ID=%d,Document_ID=%s,DynSource_ID=%s,Report_ID=%s,Filepath=%s,PrinterName=%s,Parameters=%s', [
              ds.FieldByName('ID').AsInteger,
              ds.FieldByName('Document_ID').AsString,
              ds.FieldByName('DynSource_ID').AsString,
              ds.FieldByName('Report_ID').AsString,
              ds.FieldByName('Filepath').AsString,
              ds.FieldByName('PrinterName').AsString,
              ds.FieldByName('Parameters').AsString]);
          except
          end;

        except
          //chyba
          OS.SQLExecute('UPDATE ' + REST_TABLE_Print + nxCrLf +
            ' SET'+ nxCrLf +
            ' Status=2,' + nxCrLf +
            ' DatePrint$DATE = ' + NxFloatToIBStr(now) + ',' + nxCrLf +
            ' Error = ' + QuotedStr(ExceptionMessage) + nxCrLf +
            ' WHERE id = ' + QuotedStr(ds.FieldByName('id').AsString));


          if not mInTransaction then
            OS.Commit;

          gLog.WriteEventFmt(logError, 'PRINT ERR: ID=%d,Document_ID=%s,DynSource_ID=%s,Report_ID=%s,Filepath=%s,PrinterName=%s,Error:%s', [
            ds.FieldByName('ID').AsInteger,
            ds.FieldByName('Document_ID').AsString,
            ds.FieldByName('DynSource_ID').AsString,
            ds.FieldByName('Report_ID').AsString,
            ds.FieldByName('Filepath').AsString,
            ds.FieldByName('PrinterName').AsString,
            ExceptionMessage
            ]);
        end;
        ds.next;
      end;
    until(HourOf(now) < 5)OR(HourOf(now) >= 22);
  finally
    ds.Free;
    gLog.Free;
  end;
end;

procedure PA_DeleteTemporaryStorage(OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
const
  FUNCTION_NAME = 'PA_DeleteTemporaryStorage';
  MAX_ROW_AT_ONCE = 1000;
  REPEAT_COUNT = 10;
  SQL_SELECT =
    'from ' + REST_TABLE_TemporaryStorage + nxCrLf +
    'where' + nxCrLf +
    '  Date$DATE < ' + NxFloatToIBStr(Now - TEMPORARY_STORAGE_DELETE_AFTER) + nxCrLf +
    '  and Status in (' + IntToStr(TempStorageStatus_SAVED) + ', ' +
      IntToStr(TempStorageStatus_STORNO) + ', ' + IntToStr(TempStorageStatus_DELETE) + ')' + nxCrLf +
    'order by' + nxCrLf +
    '  Date$DATE' + nxCrLf;

var
  mSql: String;
  mRecords: TMemTable;
  mCount: Integer;

  procedure Log(AMessage: String);
  begin
    LogWriteEvent(AMessage);
    LogInfoStr := LogInfoStr + AMessage + nxCrLf;
  end;
begin
  gLog := TNxCustomLog.Create(REST_LogName);
  try
    LogWriteSectionStart(FUNCTION_NAME);
    CFxProfiler.EnterProc(REST_LogName, FUNCTION_NAME);
    try
      Success := True;
      LogInfoStr := '';

      mCount := 0;
      while mCount < REPEAT_COUNT do
      begin
        LogWriteSectionStart(Format('Iteration %d', [mCount + 1]));
        LogInfoStr := LogInfoStr + Format('Iteration %d', [mCount + 1]) + nxCrLf;
        mRecords := TMemTable.Create(nil);
        try
          mSql :=
            'select' + FIRST_TOP(MAX_ROW_AT_ONCE) + nxCrLf +
            '  id, Filepath' + nxCrLf +
            SQL_SELECT +
            FIRST_TOP_ORACLE(MAX_ROW_AT_ONCE);
          OS.SQLSelect2(mSql, mRecords);

          if mRecords.Active then
          begin
            Log(Format('Found %d rows to delete', [mRecords.RecordCount]));
            Log('Deleting files...');
            mRecords.First;
            while not mRecords.Eof do
            begin
              if (Trim(mRecords.FieldByName('Filepath').AsString) <> '')
                  and FileExists(mRecords.FieldByName('Filepath').AsString) then
                DeleteFile(mRecords.FieldByName('Filepath').AsString);
              mRecords.Next;
            end;

            Log('Deleting database records...');
            if DB_TYPE = 0 then
              mSql :=
                'delete' + nxCrLf +
                SQL_SELECT + nxCrLf +
                'rows ' + IntToStr(MAX_ROW_AT_ONCE)
            else
              mSql :=
                'delete' + nxCrLf +
                'from ' + REST_TABLE_TemporaryStorage + nxCrLf +
                'where' + nxCrLf +
                '  id in (' + nxCrLf +
                '    select' + FIRST_TOP(MAX_ROW_AT_ONCE) + nxCrLf +
                '      id' + nxCrLf +
                '    ' + ReplaceStr(SQL_SELECT, nxCrLf, nxCrLf + '    ') +
                '    ' + FIRST_TOP_ORACLE(MAX_ROW_AT_ONCE) + nxCrLf +
                '  )';
            OS.SQLExecute(mSql);
          end
          else
            break;
        finally
          mRecords.Free;
          LogWriteSectionEnd;
        end;
        mCount := mCount + 1;
        Sleep(5000);
      end;
    finally
      CFxProfiler.ExitProc(REST_LogName, FUNCTION_NAME);
      LogWriteSectionEnd;
    end;
  finally
    gLog.Free;
  end;
end;

begin
end.