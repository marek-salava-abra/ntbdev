

procedure SetReservedQuantity (OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
var
 mList:tstringlist;
 mBO:TNxCustomBusinessObject;
 i:integer;
begin
  mList:=TStringList.Create;
  os.SQLExecute('update storesubcards set X_orderedQuantity=0 where X_orderedQuantity>0');
  OS.SQLSelect('select SSC.ID from storesubcards ssc '+
              'left join storecards sc on sc.id=ssc.storecard_id '+
              'left join stores s on s.id=ssc.store_id where sc.X_EshopExport=''A'' and ssc.quantity>0 and s.id in (''1000000101'',''3000000101'',''5000000101'',''1200000101'',''7000000101'',''A000000101'',''C000000101'',''#000000001'',''E000000101'',''#000000201'',''G000000101'') ',mList);
  for i:=0 to mlist.count-1 do begin
    try
     mBO:=OS.CreateObject(Class_StoreSubCard);
     mBO.Load(mlist.strings[i],nil);
     mbo.SetFieldValueAsFloat('X_orderedQuantity',NxEvalObjectExprAsFloatDef(mbo,'NxGetReservedQuantity('+ QuotedStr(mbo.GetFieldValueAsString('StoreCard_ID')) + ','+ QuotedStr(mbo.GetFieldValueAsString('Store_ID')) + ')',0));
     mbo.save;
     mbo.free;
    except
    end;
  end;
  Success := True;
  LogInfoStr := '';
end;

procedure CreateFile (OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
var
 mList:TStringList;
 mContext:TNxContext;
 mFileName:string;
 mFTP:TFTP;
 mInfo:String;
begin
  mList:=TStringList.Create;
  //mList.Add('#000000007');
  os.SQLSelect('Select id from storecards where hidden=''N'' ',mList);
  mfileName:='karty.csv';
  CFxReportManager.ExportByIDs(NxCreateContext(OS),mlist,'OGQQA2C25JDL342N01C0CX3FCC','#000000303',0,'',NxGetTempDir+mFileName);
  if FileExists(NxGetTempDir+mfilename) then NxCopyFile(NxGetTempDir+mfilename,'C:\abra_export\karty.csv');
  if FileExists('C:\abra_export\karty.csv') then begin
      mInfo:='soubor se povedlo  vytvořit.';
      mFTP:= TFTP.Create;
      mFTP.Host:='primadum.prod.oxyshop.cz';
      mFTP.Port:=21;
      mftp.UserName:='primadum_connector_products';
      mFTP.Password:='5D58r..dLido!-lKll';
      mftp.Connect;
      mFTP.Passive:=true;
      mFTP.TransferType:=ftBinary;
    {   mftp.ChangeDir('strechyplneodmen.cz'); }
      mftp.Put('C:\abra_export\karty.csv', 'export_karet.csv');
      mInfo:=mInfo+#13#10+'soubor se povedlo  odeslat na ftp.';
  {  DeleteFile(mFileName);}
  end;
  Success := True;
  LogInfoStr := ''+mInfo;
end;

procedure ExportStavy (OS: TNxCustomObjectSpace;  var Success: Boolean; var LogInfoStr: String);
var
 mIDsList:TStringList;
 mContext:TNxContext;
 mZIP:TZipFile;
 mFileName1, mFileName4, mInfo:string;
 mFTP:TFTP;
begin
   mInfo:='';
   {mIDsList:=TStringList.Create;
   mContext:=NxCreateContext(OS);
   if FileExists('c:\abra_export\karty_mnozstvi.csv') then DeleteFile('c:\abra_export\karty_mnozstvi.csv');
   OS.SQLSelect('Select id from StoreSubCards', mIDsList);
   mFileName1:=NxGetTempDir+'karty_mnozstvi.csv';
   CFxReportManager.ExportByIDs(mContext,mIDsList,'G0XYJHQFQVDL342W01C0CX3FCC','#000000101',0,'',mfileName1);
   NxCopyFile(mFileName1,'c:\abra_export\karty_mnozstvi.csv');
   mIDsList.Clear; }
   if FileExists('c:\data_exchange\storeQuantity.csv') then begin
      mInfo:='soubor se povedlo  vytvořit.';
      mFTP:= TFTP.Create;
      mFTP.Host:='primadum.prod.oxyshop.cz';
      mFTP.Port:=21;
      mftp.UserName:='primadum_connector_products';
      mFTP.Password:='5D58r..dLido!-lKll';
      mftp.Connect;
      mFTP.Passive:=true;
    {   mftp.ChangeDir('strechyplneodmen.cz'); }
      mftp.Put('c:\data_exchange\storeQuantity.csv', 'karty_mnozstvi.csv');
      mInfo:=mInfo+#13#10+'soubor se povedlo  odeslat na ftp.';
  {  DeleteFile(mFileName);}
  end;
  Success := True;
  LogInfoStr := ''+mInfo;
end;

begin
end.