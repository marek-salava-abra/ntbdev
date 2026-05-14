
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
  mDynSourceID := 'W0DR1FTE3JD13ACL03KIU0CLP4';
  mExportID := '1G00000101';
  mCommand := 2;
   mFileName := 'D:\E_SHOP\EXPORT\firms\Firmy.xml';     //pozor, cesta je vzhledem k autoserveru

  mSQL:='Select id from firms where hidden = ''N'' and X_eshop_schvaleno = ''A''';





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