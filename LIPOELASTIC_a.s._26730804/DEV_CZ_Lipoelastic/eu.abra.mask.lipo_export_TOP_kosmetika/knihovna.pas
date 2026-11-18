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
  mDynSourceID := '1OANOJ4ODGP45AYZ5KDXT3ZT5C';
  mExportID := '1U00000101';
  mCommand := 2;
   mFileName := 'D:\E_SHOP\EXPORT\Storecards\TOP_Stav_zasob.xml';     //pozor, cesta je vzhledem k autoserveru

  mSQL:='Select id from storecards where hidden = ''N'' ';





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