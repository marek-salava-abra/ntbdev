procedure Export(OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
var
  mContext: TNxContext;
  mIDs: TStrings;
  mDynSourceID, mExportID, mFileName, mSQL: String;
  mCommand: Integer;
begin
  Success := True;
  LogInfoStr := '';
  mContext := NxCreateContext(OS);
  mDynSourceID := 'WBFDIVPW1ZE13HBT00C5OG4NF4';
  mExportID := '9H00000101';
  mCommand := 2;
   mFileName := 'C:\ABRAG3\Export\Skladove_pohyby.xls';     //pozor, cesta je vzhledem k autoserveru

  mSQL:='Select sd2.id from StoreDocuments2 SD2 left join StoreDocuments SD on SD.id=SD2.Parent_id where SD.DocDate$DATE = %D ';


  try
    mIDs := TStringList.Create;
    OS.SQLSelect(format(mSQL,[trunc(Now)]),mIDs);
//    showmessage(inttostr(mids.count));
    NxPrintByIDs(mContext, mIDs, mDynSourceID, mExportID, mCommand,pekExcel,'C:\ABRAG3\Export\' ,'Skladove_pohyby.xls')

  finally
    mIDs.Free;
  end;
end;

begin
end.