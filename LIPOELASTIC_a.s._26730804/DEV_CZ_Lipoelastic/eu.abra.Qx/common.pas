

uses 'eu.abra.Qx.func';




function AWSCheckAlive(Self: TNxWebServicesHelper;Param: String):String;
begin
  NxScriptingLog.EnterSection('eu.abra.Qx/common.AWSCheckAlive', logNotice);
  try
    Result := 'I''m alive' + #13#10 + Param;
  finally
    NxScriptingLog.WriteEvent(logError, 'eu.abra.Qx/common.AWSCheckAlive' + ExceptionMessage);
  end;
end;

function AWSPrint(Self: TNxWebServicesHelper;CLSID: String;Report_ID: String;IDs: TStringDynArray;APrinter: String):String;
var
  T: TDateTime;
  mIDs : TStrings;
  i : integer;
begin
  Result := '';
  try
    NxScriptingLog.EnterSection('eu.abra.Qx/common.Print', logNotice);
    T := Now;
    try
      mIDs := TStringList.Create;
      try
        //mids.add('61Z6000101');
        for i := 0 to Length(IDs) - 1 do
          mIDs.Add(IDs[i]);
        NxScriptingLog.WriteEventFmt(logDebug, 'Print CLSID=''%s'', Printer=''%s'', IDs=%s', [CLSID, APrinter, mIDs.Text]);
//        NxPrintByIDs(Self.Context, mIDs, CLSID, Report_ID, rtoPrint, pekPDF, APrinter, '');
        CFxReportManager.PrintByIDs(Self.Context, mIDs, CLSID, Report_ID, rtoPrint, pekARP, APrinter, '');
        Result := 'OK';
      finally
        mIDs.Free;
      end;
    finally
      NxScriptingLog.LeaveSection_1('eu.abra.Qx/common.Print (Printer=%s) (%d ms)', [APrinter, MilliSecondsBetween(now, T)], logNotice);
    end;
  except
    NxScriptingLog.WriteEvent(logError, 'eu.abra.Qx/common.Print: ' + ExceptionMessage);
    Result := 'Err|' + ExceptionMessage;
  end;
end;




function AWSPrintPDF(Self: TNxWebServicesHelper; CLSID: string; Report_ID : string; IDs: TStringDynArray):String;
var
  mExportFileName, mPrint_Path : string;
  mIDs : TStrings;
  i : integer;
  T: TDateTime;
begin
  Result := '';
  try
    NxScriptingLog.EnterSection('eu.abra.Qx/common.PrintPDF', logNotice);
    T := Now;
    try
      mPrint_Path := NxGetTempDir + '\';
      mExportFileName := MakeTempFileName;
      try
          mIDs := TStringList.Create;
          try
            for i := 0 to Length(IDs) - 1 do
              mIDs.Add(IDs[i]);
            NxPrintByIDs(Self.Context, mIDs, CLSID, Report_ID, rtoFile, pekPDF, mPrint_Path, mExportFileName);
            Result := MakeOutputStreamFromFile(NxAddPathDelimiter(mPrint_Path) + mExportFileName, False);
          finally
            mIDs.Free;
          end;
      finally
        if FileExists(mPrint_Path + mExportFileName) then
          DeleteFile(mPrint_Path + mExportFileName);
      end;
    finally
      NxScriptingLog.LeaveSection_1('eu.abra.Qx/common.PrintPDF (tmpFile=%s) (%d ms)', [mExportFileName, MilliSecondsBetween(now, T)], logNotice);
    end;
  except
    NxScriptingLog.WriteEvent(logError, 'eu.abra.Qx/common.PrintPDF: ' + ExceptionMessage);
    Result := 'Err|' + ExceptionMessage;
  end;
end;



begin
end.