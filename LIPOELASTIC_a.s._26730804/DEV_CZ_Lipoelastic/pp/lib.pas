
{POST_Print}

procedure POST_Print(AContext:TNxContext; ARequest: TAPIRequest; AResponse: TAPIResponse);
var
  mFileName, mPrinterName, mLog:string;
  mInputJSON, mOutputJSON:TJSONSuperObject;
  mPokus, mBool, mBool2:Boolean;
  mPrinters:TStringList;

begin
  mInputJSON:=TJSONSuperObject.Create;
  mOutputJSON:=TJSONSuperObject.Create;
  mInputJSON:=TJSONSuperObject.ParseString(ARequest.Body,True);
  mPokus:=mInputJSON.B['pokus'];
  mFileName:='C:\ABRA_CZ\print\~S0000830Z.pdf';
  mPrinterName:='"T69"';
  mPrinters:=TStringList.Create;
  mPrinters.AddStrings(Printer.Printers);
  if FileExists(mFilename) and mPokus then begin
      //mBool:=ShellAPI.PrintFile(mFilename,mPrinterName);
      mBool := ShellAPI.Execute(
                'open',
                'C:\ABRA_CZ\_exe\PDFXCview\PDFXCview.exe',
                '/printto '+mPrinterName+' "' + mFileName + '"',
                'C:\ABRA_CZ\_exe\PDFXCview'
              );

      mLog:=NxGetUserName+NxCrlF+mFilename+NxCrlf+mPrinters.Text+NxCrLf+'Print  #'+BoolToStr(mBool,true)+'#';
      CFxLog.SaveLog(NxCreateContext(AContext.GetObjectSpace),'LA','Print  #'+BoolToStr(mBool,true)+'#',mLog,ltScripting,Now);
      mOutputJSON.S['log']:=mLog;
  end;
  try
        AResponse.Body:=mOutputJSON.AsString;
        AResponse.SetHeader('Content-Type','application/json');
        AResponse.Status := 200;

  finally

  end;
end;

begin
end.