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
  mDynSourceID := 'O4M3U5YQ5RD132VA02K2CQM5AW';
  mExportID := '1K00000101';
  mCommand := 2;
  mFileName := '\\g3\abrag3\Exchange\Servis\BOV' + NxFloatToIBStr(nxroundbyvalue(now(),3,0.001))+ '.xml' ;     //pozor, cesta je vzhledem k autoserveru


  mSQL:='SELECT A.ID FROM BusOrders A WHERE substring(A.Code from 1 for 1 )=''V'' AND (A.Date$DATE >= 42860 and A.Date$DATE < 42861 )';




  try
    mIDs := TStringList.Create;
    OS.SQLSelect(mSQL,mIDs);
//    showmessage(inttostr(mids.count));
    NxExportByIDs(mContext, mIDs, mDynSourceID, mExportID, mCommand, '', mFileName);
  finally
    mIDs.Free;
  end;
end;

begin
end.