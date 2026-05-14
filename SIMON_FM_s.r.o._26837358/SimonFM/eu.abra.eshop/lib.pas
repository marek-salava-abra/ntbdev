Const
 conSQL2='Select id from PriceLists where id=''1800000101'' and hidden= ''N'' ';
 conExportID2='4X00000101';
 conDynSource2='WBZSRQS0AZE1342Y01C0CX3FCC';
 conFileName2='d:\wamp\www\images\prices.xml';
 conSQL2f='Select id from firms where hidden= ''N'' ';
 conExportID2f='J200000001';
 conDynSource2f='W0DR1FTE3JD13ACL03KIU0CLP4';
 conFileName2f='d:\wamp\www\images\firms.xml';
 conSQL1='Select id from storecards where hidden= ''N'' and X_ESCard=''A'' ';
 conExportID1='4250000101';
 conDynSource1='2K3MZAL0Z1L4ZGUYUU1CSTSQNS';
 conFileName1='d:\wamp\www\images\StoreCards.xml';
 conSQL22='Select id from ActionPriceLists where code=''ES-T'' and (datefrom$date<='+IntToStr(Trunc(date))+') and (dateto$date>='+IntToStr(Trunc(date))+') and hidden= ''N'' ';
 conExportID22='6X00000101';
 conDynSource22='LFE4AI3GSCL4DHC4LQ04IMNRCG';
 conFileName22='d:\wamp\www\images\actionprices.xml';
 conSQL4='Select a.id from storecards a where A.X_ESCard=''A'' and a.hidden= ''N'' ';
 conExportID4='2W00000101';
 conDynSource4='OGQQA2C25JDL342N01C0CX3FCC';
 conFileName4='d:\wamp\www\images\StoreCardsQuantity.xml';


procedure CancelNewLetter(OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
var
 mList:TStringList;
 mdate:Extended;
 i:Integer;
 mBO:TNxCustomBusinessObject;
begin
  mList:=TStringList.create;
  mDate:=NxIncYear(Date,-3);
  OS.SQLSelect('SELECT  a.id FROM FirmOffices A JOIN Firms F ON F.ID=A.Parent_ID WHERE ( ( (F.Firm_ID is null) )) AND ( ( (F.Hidden = ''N'') ) '+
               ') AND (A.Hidden = ''N'' ) AND (A.X_CommercialsAgreement= ''A'') and A.X_AgreementFrom$Date<'+NxFloatToIBStr(mdate),mList);
  for i:=0 to mList.count-1 do begin
    mBO:=os.CreateObject(Class_FirmOffice);
    mbo.load(mlist.Strings[i],nil);
     mBO.SetFieldValueAsBoolean('X_CommercialsAgreement',false);
     mBO.SetFieldValueAsDateTime('X_AgreementFrom',0);
    mbo.save;
    mbo.free;
  end;
  Success := True;
  LogInfoStr := 'Smazáno souhlasů '+IntToStr(mList.count);
end;

procedure Exp4mForce (OS: TNxCustomObjectSpace;  var Success: Boolean; var LogInfoStr: String);
var
 mIDsList:TStringList;
 mContext:TNxContext;
 mZIP:TZipFile;
begin
 {  mIDsList:=TStringList.Create;
   mContext:=NxCreateContext(OS);
   OS.SQLSelect(conSQL2, mIDsList);
   CFxReportManager.ExportByIDs(mContext,mIDsList,conDynSource2,conExportID2,0,'',conFileName2);
   mZIP:=TZipFile.Create;
   try
    mZIP.Open('d:\wamp\www\images\Prices.zip', zfomWrite);
    mZIP.AddFile(conFileName2);
    mZIP.Close;
   finally
     mZIP.Free;
   end;
   mIDsList.Clear;}

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
    mZIP.Open('d:\wamp\www\images\ActionPrices.zip', zfomWrite);
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
   CFxReportManager.ExportByIDs(mContext,mIDsList,GetExpSource(OS, conExportID1),conExportID1,0,'','d:\wamp\www\images\StoreCards2.xml');
   mZIP:=TZipFile.Create;
   try
    mZIP.Open('d:\wamp\www\images\StoreCards2.zip', zfomWrite);
    mZIP.AddFile('d:\wamp\www\images\StoreCards2.xml');
    mZIP.Close;
   finally
     mZIP.Free;
   end;
   mIDsList.Clear;

  Success := True;
  LogInfoStr := '';
end;

function GetExpSource (AOS : TNxCustomObjectSpace; AValue : string) : String;

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

procedure Exp4mForceSCQ (OS: TNxCustomObjectSpace;  var Success: Boolean; var LogInfoStr: String);
var
 mIDsList:TStringList;
 mContext:TNxContext;
 mZIP:TZipFile;
begin
   mIDsList:=TStringList.Create;
   mContext:=NxCreateContext(OS);
   OS.SQLSelect(conSQL4, mIDsList);
   CFxReportManager.ExportByIDs(mContext,mIDsList,conDynSource4,conExportID4,0,'',conFileName4);
   mZIP:=TZipFile.Create;
   try
    mZIP.Open('d:\wamp\www\images\StoreCardsQuantity.zip', zfomWrite);
    mZIP.AddFile(conFileName4);
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
    mZIP.Open('d:\wamp\www\images\Firms.zip', zfomWrite);
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