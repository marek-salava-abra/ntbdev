procedure ExportForRetino (OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
const
  cSQL = 'SELECT distinct(A.ID) FROM receivedorders A left join receivedorders2 ro2 on a.id=ro2.parent_id WHERE ro2.busorder_id=''1700000101'' and a.CreatedAt$Date>'+NxFloatToIBStr(date-7);
var
  mList, mList2 : TStringList;
  mFileName:String;
  mFTP:TFTP;
begin
  mList := TStringList.create;
  mList2 :=TStringList.create;
  mFileName:=NxGetTempDir+'retino.xml';
  try
    OS.SQLSelect(cSQL, mList);
    if mList.Count > 0 then begin
      CfxReportManager.ExportByIDs(NxCreateContext(OS),mList,GetDynSourceE(OS,'CTV0000101'),'CTV0000101',0,'',mFileName);
    end;
  finally
    mList.Free;
  end;
         mFTP:= TFTP.Create;
         mFTP.Host:='exact.lipoelastic.com';
         //mFTP.Port:=34000;
         mftp.UserName:='exact.lipoelastic.com';
         mFTP.Password:='6VV-Jt2ePUwdegPdvdCy';
         mftp.Connect;
         mFTP.Passive:=true;
         mFTP.TransferType:=ftBinary;
         mFTP.ChangeDir('78d655baaa3e682a38b9bd5ca94d6c7e');
         mftp.Put(mFileName, 'retino.xml');
         mFTP.Free;

  Success := True;
  LogInfoStr := ''+NxGetTempDir;
end;

function GetDynSourceE (AOS : TNxCustomObjectSpace; AValue : string) : String;

const
  cSQL = 'SELECT DataSource FROM Exports WHERE ID=''%s'' ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    Result:='';
    AOS.SQLSelect(Format(cSQL, [ AValue]), mList);
    if mList.Count > 0 then
      Result := (mList.Strings[0]);
  finally
    mList.Free;
  end;
end;

begin
end.