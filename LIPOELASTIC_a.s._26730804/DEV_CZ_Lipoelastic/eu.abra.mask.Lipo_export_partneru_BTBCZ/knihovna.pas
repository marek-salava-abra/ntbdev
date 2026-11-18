
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
   mFileName := 'D:\E_SHOP\EXPORT\firms\Firmy_B2B_CZ.xml';     //pozor, cesta je vzhledem k autoserveru

  mSQL:='SELECT A.ID FROM Firms A WHERE (A.Firm_ID is Null) and hidden = ''N'' and substring(A.K7,1,1) = ''1''';




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