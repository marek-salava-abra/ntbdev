 function mSQLUpdate(AReportHelper:TNxQRScriptHelper;AvalueMSQ:String):integer;
var
mr:tstringlist;
i:integer;
begin
  I:=0;
  if AvalueMSQ<>'' then begin
       try
           I:=AReportHelper.ObjectSpace.SQLExecute(AvalueMSQ);
                   result:=i ;
       finally
       end;
  end;
end;





function GetTranslatorDocument(AReportHelper:TNxQRScriptHelper;Avalue:String;ALanguage:string;ASecondLanguage:string;):String;
var
mr:tstringlist;
i:integer;
begin
  if aValue<>'' then begin
     mr:=tstringlist.create;
       try
           AReportHelper.ObjectSpace.SQLSelect('SELECT (A.' + ALanguage + ') FROM DefRollData A WHERE (A.Hidden = ''N'' ) AND (A.CLSID = ''CJ42KRF5CFDOVHMHOFT3PLYXZG'') AND ' +
           ' (A.code ='+ quotedstr(Avalue)+ ')',mr);
               if mr.count=0 then begin

               end else begin
                   result:=mr.Strings[0] ;
               end;
       finally
           mr.free;

       end;
  end;
end;



 function GetDataMatrixPicture1(AReportHelper:TNxQRScriptHelper;Avalue:String;AFileName:string):String;
var
  mWinHTTP,aa: variant;
  mRequest: string;
  mFileName:string;
  AStream:TMemoryStream;
begin
  try
    mWinHTTP:= CreateOleObject('WinHttp.WinHttpRequest.5.1');
    mWinHTTP.Open('POST', 'http://10.5.5.38:26300' + '/api/v1/data-matrixes');
    mWinHTTP.SetRequestHeader('Content-Type', 'application/json');

    mRequest :='{"data":["'+AValue+ '"],'+
           '"useSeparator":true,'+
            '"useGS1":true,'+
            '"transparent":false,'+
            '"save":true,'+
            '"size":256}' ;
    mWinHTTP.Send(mRequest);
    if mWinHTTP.Status <> 201 then begin    //kód <> 200 = dotaz vůbec neprošel
          if CFxNxRuntime.NxGetEnvironmentType = reRuntimeExe then ShowMessage('Nebylo možné vygenerovat datamatrixcode: ' + IntToStr(mWinHTTP.Status) +': '+ mWinHTTP.StatusText + ' '+mWinHTTP.ResponseText);
          result:='nopicture.png'
    end
    else begin
        AStream := TMemoryStream.Create;
                 astream.SetBytes(mWinHTTP.Responsebody);
                 mFileName:=(NxGetTempDir+Afilename+'.png') ;
                 AStream.SaveToFile(mFileName)  ;
                 //'\\CZVS0006\Logy\Datamatrix.png');
      NxSleep(100);
      Result:= mFileName;

    end;
  except
  //  if CFxNxRuntime.NxGetEnvironmentType = reRuntimeExe then ShowMessage('Nastala neočekávaná chyba při získávání tokenu: '+ExceptionMessage);
  end;

end;






function GetDataMatrixPicture2(AReportHelper:TNxQRScriptHelper;Avalue,aValue2,avalue3:String;AFileName:string):String;
var
  mWinHTTP,aa: variant;
  mRequest: string;
  mFileName:string;
  AStream:TMemoryStream;
begin
  try
    mWinHTTP:= CreateOleObject('WinHttp.WinHttpRequest.5.1');
    mWinHTTP.Open('POST', 'http://10.5.5.38:26300' + '/api/v1/data-matrixes');
    mWinHTTP.SetRequestHeader('Content-Type', 'application/json');

    mRequest :='{"data":["'+AValue+'","' + avalue2 + '"],'+
           '"useSeparator":true,'+
            '"useGS1":true,'+
            '"transparent":false,'+
            '"save":true,'+
            '"size":256}' ;
    mWinHTTP.Send(mRequest);
    if mWinHTTP.Status <> 201 then begin    //kód <> 200 = dotaz vůbec neprošel
          if CFxNxRuntime.NxGetEnvironmentType = reRuntimeExe then ShowMessage('Nebylo možné vygenerovat datamatrixcode: ' + IntToStr(mWinHTTP.Status) +': '+ mWinHTTP.StatusText + ' '+mWinHTTP.ResponseText);
          result:='nopicture.png'
    end
    else begin
        AStream := TMemoryStream.Create;
                 astream.SetBytes(mWinHTTP.Responsebody);
                 mFileName:=(NxGetTempDir+Afilename+'.png') ;
                 AStream.SaveToFile(mFileName)  ;
                 //'\\CZVS0006\Logy\Datamatrix.png');
      NxSleep(100);
      Result:= mFileName;

    end;
  except
  //  if CFxNxRuntime.NxGetEnvironmentType = reRuntimeExe then ShowMessage('Nastala neočekávaná chyba při získávání tokenu: '+ExceptionMessage);
  end;

end;








function GetDataMatrixPicture3(AReportHelper:TNxQRScriptHelper;Avalue,aValue2,avalue3:String;AFileName:string):String;
var
  mWinHTTP,aa: variant;
  mRequest: string;
  mFileName:string;
  AStream:TMemoryStream;
begin
  try
    mWinHTTP:= CreateOleObject('WinHttp.WinHttpRequest.5.1');
    mWinHTTP.Open('POST', 'http://10.5.5.38:26300' + '/api/v1/data-matrixes');
    mWinHTTP.SetRequestHeader('Content-Type', 'application/json');

    mRequest :='{"data":["'+AValue+'","' + avalue2 + '","' + avalue3 + '"],'+
           '"useSeparator":true,'+
            '"useGS1":true,'+
            '"transparent":false,'+
            '"save":true,'+
            '"size":256}' ;
    mWinHTTP.Send(mRequest);
    if mWinHTTP.Status <> 201 then begin    //kód <> 200 = dotaz vůbec neprošel
          if CFxNxRuntime.NxGetEnvironmentType = reRuntimeExe then ShowMessage('Nebylo možné vygenerovat datamatrixcode: ' + IntToStr(mWinHTTP.Status) +': '+ mWinHTTP.StatusText + ' '+mWinHTTP.ResponseText);
          result:='nopicture.png'
    end
    else begin
        AStream := TMemoryStream.Create;
                 astream.SetBytes(mWinHTTP.Responsebody);
                 mFileName:=(NxGetTempDir+Afilename+'.png') ;
                 AStream.SaveToFile(mFileName)  ;
                 //'\\CZVS0006\Logy\Datamatrix.png');
      NxSleep(100);
      Result:= mFileName;

    end;
  except
  //  if CFxNxRuntime.NxGetEnvironmentType = reRuntimeExe then ShowMessage('Nastala neočekávaná chyba při získávání tokenu: '+ExceptionMessage);
  end;

end;




function GetDataMatrixPicture(AReportHelper:TNxQRScriptHelper;Avalue,aValue2,avalue3:String;AFileName:string):String;
var
  mWinHTTP,aa: variant;
  mRequest: string;
  mFileName:string;
  AStream:TMemoryStream;
begin
  try
    mWinHTTP:= CreateOleObject('WinHttp.WinHttpRequest.5.1');
    mWinHTTP.Open('POST', 'http://10.5.5.38:26300' + '/api/v1/data-matrixes');
    mWinHTTP.SetRequestHeader('Content-Type', 'application/json');

    mRequest :='{"data":["'+AValue+'","' + avalue2 + '","' + avalue3 + '"],'+
           '"useSeparator":true,'+
            '"useGS1":true,'+
            '"transparent":false,'+
            '"save":true,'+
            '"size":256}' ;
    mWinHTTP.Send(mRequest);
    if mWinHTTP.Status <> 201 then begin    //kód <> 200 = dotaz vůbec neprošel
          if CFxNxRuntime.NxGetEnvironmentType = reRuntimeExe then ShowMessage('Nebylo možné vygenerovat datamatrixcode: ' + IntToStr(mWinHTTP.Status) +': '+ mWinHTTP.StatusText + ' '+mWinHTTP.ResponseText);
          result:='nopicture.png'
    end
    else begin
        AStream := TMemoryStream.Create;
                 astream.SetBytes(mWinHTTP.Responsebody);
                 mFileName:=(NxGetTempDir+Afilename+'.png') ;
                 AStream.SaveToFile(mFileName)  ;
                 //'\\CZVS0006\Logy\Datamatrix.png');
      NxSleep(100);
      Result:= mFileName;

    end;
  except
  //  if CFxNxRuntime.NxGetEnvironmentType = reRuntimeExe then ShowMessage('Nastala neočekávaná chyba při získávání tokenu: '+ExceptionMessage);
  end;

end;









function GetBarcode(AReportHelper:TNxQRScriptHelper; AFileName:String; AType:Integer; AInputData:String):String;
const cZintExePath = '"'+ExtractFilePath(ParamStr(0))+'zint\zint.exe"';
var mOutputFile : string;
begin
  result := '';
  mOutputFile := NxAddSlash(NxGetTempDir) + AFileName;
  if NxExecFile(cZintExePath + ' -o ' + mOutputFile + ' -b ' + IntToStr(AType) + ' -d ' + AInputData , true, false) then begin
    Sleep(100);
    result := mOutputFile;
  end;
end;

function GetDataMatrixGs1FNC1(AReportHelper:TNxQRScriptHelper; AFileName:String; AType:Integer; AInputData:String):String;
const cZintExePath = '"'+ExtractFilePath(ParamStr(0))+'zint\zint.exe"';
var mOutputFile : string;
begin
  result := '';
  mOutputFile := NxAddSlash(NxGetTempDir) + AFileName;
  if NxExecFile(cZintExePath + ' -o ' + mOutputFile + ' --gs1 --gssep -b ' + IntToStr(AType) + ' -d ' + AInputData , true, false) then begin
    Sleep(100);
    result := mOutputFile;
  end;
end;

function GetDataMatrixGs1(AReportHelper:TNxQRScriptHelper; AFileName:String; AType:Integer; AInputData:String):String;
const cZintExePath = '"'+ExtractFilePath(ParamStr(0))+'zint\zint.exe"';
var mOutputFile : string;
begin
  result := '';
  mOutputFile := NxAddSlash(NxGetTempDir) + AFileName;
  if NxExecFile(cZintExePath + ' -o ' + mOutputFile + ' --gs1 -b ' + IntToStr(AType) + ' -d ' + AInputData , true, false) then begin
    Sleep(100);
    result := mOutputFile;
  end;
end;


function GetDataMatrix(AReportHelper:TNxQRScriptHelper; AFileName:String; AType:Integer; AInputData:String):String;
const cZintExePath = '"'+ExtractFilePath(ParamStr(0))+'zint\zint.exe"';
var mOutputFile : string;
begin
  result := '';
  mOutputFile := NxAddSlash(NxGetTempDir) + AFileName;
  if NxExecFile(cZintExePath + ' -o ' + mOutputFile + ' -b ' + IntToStr(AType) + ' -d ' + AInputData , true, false) then begin
    Sleep(100);
    result := mOutputFile;
  end;
end;



function GetDMatrix(AReportHelper:TNxQRScriptHelper; AFileName:String; AType:Integer; AInputData:String; NTimeOut:Integer):String;
const cZintExePath = '"'+ExtractFilePath(ParamStr(0))+'zint\zint.exe"';
var mOutputFile : string;
begin
  result := '';
  if NTimeOut=0 then NTimeOut:=200  ;
  mOutputFile := NxAddSlash(NxGetTempDir) + AFileName;
  if NxExecFile(cZintExePath + ' -o ' + mOutputFile + ' -gs1 -gssep -b ' + IntToStr(AType) + ' -d ' + AInputData , true, false) then begin
    Sleep(NTimeOut);
    result := mOutputFile;
  end else begin
    result := 'Generator error';
  end;
end;

function GetExePath(AReportHelper:TNxQRScriptHelper; AFileName:String; AType:Integer; AInputData:String):String;
const cZintExePath = '"'+ExtractFilePath(ParamStr(0))+'zint\zint.exe"';
const cExePath = '"'+ExtractFilePath(ParamStr(0))+'"';
begin
   result := cZintExePath + ' - '+cExePath;
end;

begin

{xxxxxxx}



end.