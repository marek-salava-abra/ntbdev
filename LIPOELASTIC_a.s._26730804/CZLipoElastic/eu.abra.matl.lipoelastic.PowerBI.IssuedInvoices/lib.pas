procedure ExportForPowerBI (OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
const
  cSQL ='SELECT II2.ID '+
        'FROM IssuedInvoices2 II2 '+
        'left join IssuedInvoices II on II.ID=II2.Parent_ID '+
        'where (II.createdat$date >='+ FloatToStr(NxTrunc(Now)) +' and II.createdat$date <'+ FloatToStr(NxTrunc(Now)+1)+')';
var
  mIDList : TStringList;
  mFileName:String;
  mFTP:TFTP;
  i:integer;
  mGUID:string;
begin
  mIDList := TStringList.create;
  mFileName:=NxGetTempDir+'IssuedInvoices.csv';
  try
    OS.SQLSelect(cSQL, mIDList);
    mGUID:=GetDynSourceE(OS, '~000000601');
    CFxReportManager.ExportByIDs(NxCreateContext(OS), mIDList,mGUID, '~000000601', 0,'',mFileName);
  finally
    mIDList.Free;
  end;
         mFTP:= TFTP.Create;
         mFTP.Host:='www.lipoelastic-medical-products.com.uvirt35.active24.cz';
         //mFTP.Port:=34000;
         mftp.UserName:='lipoelasti20';
         mFTP.Password:='iMO4Jxf9MI';
         mftp.Connect;
         mFTP.Passive:=true;
         mFTP.TransferType:=ftBinary;
         mFTP.ChangeDir('803d1d72d39a50559c96225092f73f4f');
         mftp.Put(mFileName, 'IssuedInvoices.csv');
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