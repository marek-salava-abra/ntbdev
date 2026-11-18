Const
 conSQL2='Select id from firms where hidden= ''N'' ';
 conSQL2d='Select id from firms where hidden= ''N'' and (correctedat$date>=%s or createdat$date>=%s) ';
 conExportID2='1N00000101';
 conDynSource2='W0DR1FTE3JD13ACL03KIU0CLP4';
 conFileName2='C:\ABRAG3\htDocs\firm.xml';

 conSQL4='Select id from storeSubcards ';
 conExportID4='3S00000101';
 conDynSource4='G0XYJHQFQVDL342W01C0CX3FCC';
 conFileName4='C:\ABRAG3\htDocs\storeQuantity.xml';

 conSQL8='Select id from issuedinvoices where docdate$date>42369';
 conSQL8d='Select id from issuedinvoices where (correctedat$date>=%s or createdat$date>=%s) ';
 conExportID8='1O00000101';
 conDynSource8='40SBPEINEFD13ACM03KIU0CLP4';
 conFileName8='C:\ABRAG3\htDocs\issuedinvoices.xml';

 conSQL10='Select id from ReceivedOrders where docdate$date>42369';
 conSQL10d='Select id from ReceivedOrders where (correctedat$date>=%s or createdat$date>=%s) ';
 conExportID10='1P00000101';
 conDynSource10='40V53DORW3DL342X01C0CX3FCC';
 conFileName10='C:\ABRAG3\htDocs\ReceivedOrders.xml';

procedure Exp4mForce (OS: TNxCustomObjectSpace;  var Success: Boolean; var LogInfoStr: String);
var
 mIDsList:TStringList;
 mContext:TNxContext;
 mZIP:TZipFile;
begin
   mIDsList:=TStringList.Create;
   mContext:=NxCreateContext(OS);
   OS.SQLSelect(conSQL2, mIDsList);
   CFxReportManager.ExportByIDs(mContext,mIDsList,conDynSource2,conExportID2,0,'',conFileName2);
   mZIP:=TZipFile.Create;
   try
    mZIP.Open('C:\ABRAG3\htDocs\firm.zip', zfomWrite);
    mZIP.AddFile(conFileName2);
    mZIP.Close;
   finally
     mZIP.Free;
   end;
   mIDsList.Clear;
   OS.SQLSelect(conSQL4, mIDsList);
   CFxReportManager.ExportByIDs(mContext,mIDsList,conDynSource4,conExportID4,0,'',conFileName4);
   mIDsList.Clear;
   mZIP:=TZipFile.Create;
   try
    mZIP.Open('C:\ABRAG3\htDocs\storeQuantity.zip', zfomWrite);
    mZIP.AddFile(conFileName4);
    mZIP.Close;
   finally
     mZIP.Free;
   end;
   mIDsList.Clear;
   OS.SQLSelect(conSQL8, mIDsList);
   CFxReportManager.ExportByIDs(mContext,mIDsList,conDynSource8,conExportID8,0,'',conFileName8);
   mIDsList.Clear;
   mZIP:=TZipFile.Create;
   try
    mZIP.Open('C:\ABRAG3\htDocs\issuedinvoices.zip', zfomWrite);
    mZIP.AddFile(conFileName8);
    mZIP.Close;
   finally
     mZIP.Free;
   end;
   mIDsList.Clear;
   OS.SQLSelect(conSQL10, mIDsList);
   CFxReportManager.ExportByIDs(mContext,mIDsList,conDynSource10,conExportID8,0,'',conFileName10);
   mIDsList.Clear;
   mZIP:=TZipFile.Create;
   try
    mZIP.Open('C:\ABRAG3\htDocs\ReceivedOrders.zip', zfomWrite);
    mZIP.AddFile(conFileName10);
    mZIP.Close;
   finally
     mZIP.Free;
   end;
  Success := True;
  LogInfoStr := '';
end;

begin
end.