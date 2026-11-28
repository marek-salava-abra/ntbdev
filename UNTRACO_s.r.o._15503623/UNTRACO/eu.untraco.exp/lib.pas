Const
 conSQL2='Select id from PriceLists where hidden= ''N'' ';
 conExportID2='K200000101';
 conDynSource2='WBZSRQS0AZE1342Y01C0CX3FCC';
 conFileName2='C:\SERVER\ABRA\AbraG2\htdocs\prices.xml';
 conSQL2f='Select id from firms where hidden= ''N'' ';
 conExportID2f='J200000101';
 conDynSource2f='W0DR1FTE3JD13ACL03KIU0CLP4';
 conFileName2f='C:\SERVER\ABRA\AbraG2\htdocs\firms.xml';
 conSQL1='Select id from storecards where  hidden= ''N'' ';
 conExportID1='N200000101';
 conExportID10='O200000101';
 conDynSource1='OGQQA2C25JDL342N01C0CX3FCC';
 conFileName1='C:\SERVER\ABRA\AbraG2\htdocs\StoreCards.xml';
 conFileName10='C:\SERVER\ABRA\AbraG2\htdocs\SCQuantity.xml';
 conSQL22='Select id from ActionPriceLists where hidden= ''N'' ';
 conExportID22='L200000101';
 conDynSource22='LFE4AI3GSCL4DHC4LQ04IMNRCG';
 conFileName22='C:\SERVER\ABRA\AbraG2\htdocs\actionprices.xml';

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
    mZIP.Open('C:\SERVER\ABRA\AbraG2\htdocs\Prices.zip', zfomWrite);
    mZIP.AddFile(conFileName2);
    mZIP.Close;
   finally
     mZIP.Free;
   end;
   mIDsList.Clear;

  Success := True;
  LogInfoStr := '';
end;

procedure Exp4mForceAP (OS: TNxCustomObjectSpace;  var Success: Boolean; var LogInfoStr: String);
var
 mIDsList:TStringList;
 mContext:TNxContext;
 mZIP:TZipFile;
begin
   mIDsList:=TStringList.Create;
   mContext:=NxCreateContext(OS);
   OS.SQLSelect(conSQL22, mIDsList);
   CFxReportManager.ExportByIDs(mContext,mIDsList,conDynSource22,conExportID22,0,'',conFileName22);
   mZIP:=TZipFile.Create;
   try
    mZIP.Open('C:\SERVER\ABRA\AbraG2\htdocs\ActionPrices.zip', zfomWrite);
    mZIP.AddFile(conFileName22);
    mZIP.Close;
   finally
     mZIP.Free;
   end;
   mIDsList.Clear;

  Success := True;
  LogInfoStr := '';
end;

procedure Exp4mForceSC (OS: TNxCustomObjectSpace;  var Success: Boolean; var LogInfoStr: String);
var
 mIDsList:TStringList;
 mContext:TNxContext;
 mZIP:TZipFile;
begin
   mIDsList:=TStringList.Create;
   mContext:=NxCreateContext(OS);
   OS.SQLSelect(conSQL1, mIDsList);
   CFxReportManager.ExportByIDs(mContext,mIDsList,conDynSource1,conExportID1,0,'',conFileName1);
   mZIP:=TZipFile.Create;
   try
    mZIP.Open('C:\SERVER\ABRA\AbraG2\htdocs\StoreCards.zip', zfomWrite);
    mZIP.AddFile(conFileName1);
    mZIP.Close;
   finally
     mZIP.Free;
   end;
   mIDsList.Clear;

  Success := True;
  LogInfoStr := '';
end;

procedure Exp4mForceSCQ (OS: TNxCustomObjectSpace;  var Success: Boolean; var LogInfoStr: String);
var
 mIDsList:TStringList;
 mContext:TNxContext;
 mZIP:TZipFile;
begin
   mIDsList:=TStringList.Create;
   mContext:=NxCreateContext(OS);
   OS.SQLSelect(conSQL1, mIDsList);
   CFxReportManager.ExportByIDs(mContext,mIDsList,conDynSource1,conExportID10,0,'',conFileName10);
   mZIP:=TZipFile.Create;
   try
    mZIP.Open('C:\SERVER\ABRA\AbraG2\htdocs\SCQuantity.zip', zfomWrite);
    mZIP.AddFile(conFileName10);
    mZIP.Close;
   finally
     mZIP.Free;
   end;
   mIDsList.Clear;

  Success := True;
  LogInfoStr := '';
end;


procedure Exp4mForceFirm (OS: TNxCustomObjectSpace;  var Success: Boolean; var LogInfoStr: String);
var
 mIDsList:TStringList;
 mContext:TNxContext;
 mZIP:TZipFile;
begin
   mIDsList:=TStringList.Create;
   mContext:=NxCreateContext(OS);
   OS.SQLSelect(conSQL2f, mIDsList);
   CFxReportManager.ExportByIDs(mContext,mIDsList,conDynSource2f,conExportID2f,0,'',conFileName2f);
   mZIP:=TZipFile.Create;
   try
    mZIP.Open('C:\SERVER\ABRA\AbraG2\htdocs\Firms.zip', zfomWrite);
    mZIP.AddFile(conFileName2f);
    mZIP.Close;
   finally
     mZIP.Free;
   end;
   mIDsList.Clear;

  Success := True;
  LogInfoStr := '';
end;

begin
end.