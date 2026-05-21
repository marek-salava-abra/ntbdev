
{PrintToBase64 - eu.abra.alec.TPDF.qr.PrintToBase64(AReportHelper:TNxQRScriptHelper; AObjectID, ADynSource, AReportID:String):String;}

function PrintToBase64(AReportHelper:TNxQRScriptHelper; AObjectID, ADataSource, AReportID:String):String;
var
  mBytes: TBytes;
  mContext: TNxContext;
  mList: TStringList;
begin
  Result:= '';
  mContext:= NxCreateContext(AReportHelper.ObjectSpace);
  mList:= TStringList.Create;
  try
    mList.Add(AObjectID);
    mBytes:= CFxReportManager.PrintByIDsToBytes(mContext, mList, ADataSource, AReportID, pekPDF);
    Result:= EncodeBase64(mBytes);
  finally
    mList.Free;
  end;
end;

begin
end.