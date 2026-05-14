{GetName}
function GetName(AReportHelper:TNxQRScriptHelper;ShortName:String):String;
var mPicList:TStringList;
    mResult : String;
    i: integer;
begin
  mPicList:=TStringList.Create;
  mPicList.Sorted:=True;
  try
    NxGetFileList('\\elkoshop\images\'+ShortName+'\',mPicList,'*.*', false);
    i := 0;
    mResult := '';
    if mPicList.Count>0 then begin
      mPicList.Sort;
      for i := 0 to mPicList.Count -1 do begin
        if (AnsiUpperCase(ExtractFileExt(mPicList.Strings[i]))='.JPG') or
         (AnsiUpperCase(ExtractFileExt(mPicList.Strings[i]))='.PNG') or
         (AnsiUpperCase(ExtractFileExt(mPicList.Strings[i]))='.BMP') or
         (AnsiUpperCase(ExtractFileExt(mPicList.Strings[i]))='.TIF')
         then begin
           mResult := mPicList.Strings[i];
           mResult := NxSearchReplace(mResult, '/', '_',[srAll]);
           break;
        end;
      end;
      result := mResult;
    end
    else
      result:='';
  finally
    mPicList.Free;
  end;
end;


begin
end.