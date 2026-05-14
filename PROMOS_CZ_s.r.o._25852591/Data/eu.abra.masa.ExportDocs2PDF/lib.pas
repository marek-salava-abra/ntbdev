uses '.consts';

procedure GenerateDoc (OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
var
 mInvoiceList, mPrintList:TStringList;
 i,j:integer;
 mBO:TNxCustomBusinessObject;
 mFTP:TFTP;
 mFileName, mDir, mDateFrom, mDateTo:string;
begin
  mInvoiceList:=Tstringlist.Create;
  j:=0;
  mDateFrom:=FormatDateTime('d.m.yyyy hh:mm:ss',Now);
  OS.SQLSelect('SELECT a.id FROM IssuedInvoices A left join firms f on a.Firm_id=F.id WHERE (A.CreatedAt$DATE >='+IntToStr(Trunc(date-1))+' or A.Correctedat$Date>='+IntToStr(Trunc(date-1))+') ' +
               ' AND F.X_B2B='+Quotedstr('A'),mInvoiceList);
  if mInvoiceList.count>0 then begin
     j:=mInvoiceList.count;
     for i:=0 to mInvoiceList.count-1 do begin
        mBO:=OS.CreateObject(Class_IssuedInvoice);
        mBO.Load(mInvoiceList.Strings[i],nil);
        mFileName:=NxSearchReplace(mbo.DisplayName,'/','-',[srAll])+'.pdf';
        mDir:=mbo.GetFieldValueAsString('Firm_ID.OrgIdentNumber');
        mPrintList:=TStringList.create;
        mPrintList.Add(mBO.OID);
        CFxReportManager.PrintByIDs(NxCreateContext_1(mBO),mPrintList,GetDynSource(os,'6LH0000101'),'6LH0000101',rtoFile,pekPDF,NxGetTempDir,mFileName);
        mPrintList.free;
        try
             mFTP:= TFTP.Create;
             mFTP.Host:=cUrl;
             mftp.UserName:=cLogin;
             mFTP.Password:=cPass;
             mftp.Connect;
             mFTP.Passive:=true;

             try
              mFtp.MakeDir(mdir);
             except

             end;
             mftp.ChangeDir(mdir);
             try
              mFtp.MakeDir('faktury');
             except

             end;
             mftp.ChangeDir('faktury');
             mFTP.TransferType:=ftBinary;
             mftp.Put(NxGetTempDir+'\'+mFileName,mfileName);
             mFTP.Free;
           except

           end;
        DeleteFile(NxGetTempDir+'\'+mFileName);
     end;
  end;
  Success := True;
  mDateTo:=FormatDateTime('d.m.yyyy hh:mm:ss',Now);
  LogInfoStr := 'Počet dokladů '+IntToStr(j)+' od data '+mdatefrom+' do data '+mdateto;
end;


procedure GenerateDocOBP (OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
var
 mInvoiceList, mPrintList:TStringList;
 i,j:integer;
 mBO:TNxCustomBusinessObject;
 mFTP:TFTP;
 mFileName, mDir, mDateFrom, mDateTo:string;
begin
  mInvoiceList:=Tstringlist.Create;
  j:=0;
  mDateFrom:=FormatDateTime('d.m.yyyy hh:mm:ss',Now);
  OS.SQLSelect('SELECT a.id FROM ReceivedORders A left join firms f on a.Firm_id=F.id WHERE a.DocQueue_ID=''1B80000101'' and (A.CreatedAt$DATE >='+IntToStr(Trunc(date-40))+' or A.Correctedat$Date>='+IntToStr(Trunc(date-40))+') ' +
               ' AND F.X_B2B='+Quotedstr('A'),mInvoiceList);
  if mInvoiceList.count>0 then begin
     j:=mInvoiceList.count;
     for i:=0 to mInvoiceList.count-1 do begin
        mBO:=OS.CreateObject(Class_ReceivedOrder);
        mBO.Load(mInvoiceList.Strings[i],nil);
        mFileName:=NxSearchReplace(mbo.DisplayName,'/','-',[srAll])+'.pdf';
        mDir:=mbo.GetFieldValueAsString('Firm_ID.OrgIdentNumber');
        mPrintList:=TStringList.create;
        mPrintList.Add(mBO.OID);
        CFxReportManager.PrintByIDs(NxCreateContext_1(mBO),mPrintList,GetDynSource(os,'2400000101'),'2400000101',rtoFile,pekPDF,NxGetTempDir,mFileName);
        mPrintList.free;
        try
             mFTP:= TFTP.Create;
             mFTP.Host:=cUrl;
             mftp.UserName:=cLogin;
             mFTP.Password:=cPass;
             mftp.Connect;
             mFTP.Passive:=true;

             try
              mFtp.MakeDir(mdir);
             except

             end;
             mftp.ChangeDir(mdir);
             try
              mFtp.MakeDir('objednavky');
             except

             end;
             mftp.ChangeDir('objednavky');
             mFTP.TransferType:=ftBinary;
             mftp.Put(NxGetTempDir+'\'+mFileName,mfileName);
             mFTP.Free;
           except

           end;
        DeleteFile(NxGetTempDir+'\'+mFileName);
     end;
  end;
  Success := True;
  mDateTo:=FormatDateTime('d.m.yyyy hh:mm:ss',Now);
  LogInfoStr := 'Počet dokladů '+IntToStr(j)+' od data '+mdatefrom+' do data '+mdateto;
end;

procedure GenerateDocVR (OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
var
 mInvoiceList, mPrintList:TStringList;
 i,j:integer;
 mBO:TNxCustomBusinessObject;
 mFTP:TFTP;
 mFileName, mDir, mDateFrom, mDateTo:string;
begin
  mInvoiceList:=Tstringlist.Create;
  j:=0;
  mDateFrom:=FormatDateTime('d.m.yyyy hh:mm:ss',Now);
  OS.SQLSelect('SELECT a.id FROM StoreDocuments A left join firms f on a.Firm_id=F.id WHERE a.Documenttype=''23'' and (A.CreatedAt$DATE >='+IntToStr(Trunc(date-1))+' or A.Correctedat$Date>='+IntToStr(Trunc(date-1))+') ' +
               ' AND F.X_B2B='+Quotedstr('A'),mInvoiceList);
  if mInvoiceList.count>0 then begin
     j:=mInvoiceList.count;
     for i:=0 to mInvoiceList.count-1 do begin
        mBO:=OS.CreateObject(Class_RefundedBillOfDelivery);
        mBO.Load(mInvoiceList.Strings[i],nil);
        mFileName:=NxSearchReplace(mbo.DisplayName,'/','-',[srAll])+'.pdf';
        mDir:=mbo.GetFieldValueAsString('Firm_ID.OrgIdentNumber');
        mPrintList:=TStringList.create;
        mPrintList.Add(mBO.OID);
        CFxReportManager.PrintByIDs(NxCreateContext_1(mBO),mPrintList,GetDynSource(os,'7000000001'),'7000000001',rtoFile,pekPDF,NxGetTempDir,mFileName);
        mPrintList.free;
        try
             mFTP:= TFTP.Create;
             mFTP.Host:=cUrl;
             mftp.UserName:=cLogin;
             mFTP.Password:=cPass;
             mftp.Connect;
             mFTP.Passive:=true;

             try
              mFtp.MakeDir(mdir);
             except

             end;
             mftp.ChangeDir(mdir);
             try
              mFtp.MakeDir('vratky');
             except

             end;
             mftp.ChangeDir('vratky');
             mFTP.TransferType:=ftBinary;
             mftp.Put(NxGetTempDir+'\'+mFileName,mfileName);
             mFTP.Free;
           except

           end;
        DeleteFile(NxGetTempDir+'\'+mFileName);
     end;
  end;
  Success := True;
  mDateTo:=FormatDateTime('d.m.yyyy hh:mm:ss',Now);
  LogInfoStr := 'Počet dokladů '+IntToStr(j)+' od data '+mdatefrom+' do data '+mdateto;
end;

procedure GenerateDocDV (OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
var
 mInvoiceList, mPrintList:TStringList;
 i,j:integer;
 mBO:TNxCustomBusinessObject;
 mFTP:TFTP;
 mFileName, mDir, mDateFrom, mDateTo:string;
begin
  mInvoiceList:=Tstringlist.Create;
  j:=0;
  mDateFrom:=FormatDateTime('d.m.yyyy hh:mm:ss',Now);
  OS.SQLSelect('SELECT a.id FROM IssuedCreditNotes A left join firms f on a.Firm_id=F.id WHERE (A.CreatedAt$DATE >='+IntToStr(Trunc(date-1))+' or A.Correctedat$Date>='+IntToStr(Trunc(date-1))+') ' +
               ' AND F.X_B2B='+Quotedstr('A'),mInvoiceList);
  if mInvoiceList.count>0 then begin
     j:=mInvoiceList.count;
     for i:=0 to mInvoiceList.count-1 do begin
        mBO:=OS.CreateObject(Class_IssuedCreditNote);
        mBO.Load(mInvoiceList.Strings[i],nil);
        mFileName:=NxSearchReplace(mbo.DisplayName,'/','-',[srAll])+'.pdf';
        mDir:=mbo.GetFieldValueAsString('Firm_ID.OrgIdentNumber');
        mPrintList:=TStringList.create;
        mPrintList.Add(mBO.OID);
        CFxReportManager.PrintByIDs(NxCreateContext_1(mBO),mPrintList,GetDynSource(os,'T200000001'),'T200000001',rtoFile,pekPDF,NxGetTempDir,mFileName);
        mPrintList.free;
        try
             mFTP:= TFTP.Create;
             mFTP.Host:=cUrl;
             mftp.UserName:=cLogin;
             mFTP.Password:=cPass;
             mftp.Connect;
             mFTP.Passive:=true;

             try
              mFtp.MakeDir(mdir);
             except

             end;
             mftp.ChangeDir(mdir);
             try
              mFtp.MakeDir('dobropisy');
             except

             end;
             mftp.ChangeDir('dobropisy');
             mFTP.TransferType:=ftBinary;
             mftp.Put(NxGetTempDir+'\'+mFileName,mfileName);
             mFTP.Free;
           except

           end;
        DeleteFile(NxGetTempDir+'\'+mFileName);
     end;
  end;
  Success := True;
  mDateTo:=FormatDateTime('d.m.yyyy hh:mm:ss',Now);
  LogInfoStr := 'Počet dokladů '+IntToStr(j)+' od data '+mdatefrom+' do data '+mdateto;
end;

procedure GenerateDocZLV (OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
var
 mInvoiceList, mPrintList:TStringList;
 i,j:integer;
 mBO:TNxCustomBusinessObject;
 mFTP:TFTP;
 mFileName, mDir, mDateFrom, mDateTo:string;
begin
  mInvoiceList:=Tstringlist.Create;
  j:=0;
  mDateFrom:=FormatDateTime('d.m.yyyy hh:mm:ss',Now);
  OS.SQLSelect('SELECT a.id FROM IssuedDInvoices A left join firms f on a.Firm_id=F.id WHERE (A.CreatedAt$DATE >='+IntToStr(Trunc(date-1000))+' or A.Correctedat$Date>='+IntToStr(Trunc(date-1000))+') ' +
               ' AND F.X_B2B='+Quotedstr('A'),mInvoiceList);
  if mInvoiceList.count>0 then begin
     j:=mInvoiceList.count;
     for i:=0 to mInvoiceList.count-1 do begin
        mBO:=OS.CreateObject(Class_IssuedDepositInvoice);
        mBO.Load(mInvoiceList.Strings[i],nil);
        mFileName:=NxSearchReplace(mbo.DisplayName,'/','-',[srAll])+'.pdf';
        mDir:=mbo.GetFieldValueAsString('Firm_ID.OrgIdentNumber');
        mPrintList:=TStringList.create;
        mPrintList.Add(mBO.OID);
        CFxReportManager.PrintByIDs(NxCreateContext_1(mBO),mPrintList,GetDynSource(os,'7700000001'),'7700000001',rtoFile,pekPDF,NxGetTempDir,mFileName);
        mPrintList.free;
        try
             mFTP:= TFTP.Create;
             mFTP.Host:=cUrl;
             mftp.UserName:=cLogin;
             mFTP.Password:=cPass;
             mftp.Connect;
             mFTP.Passive:=true;

             try
              mFtp.MakeDir(mdir);
             except

             end;
             mftp.ChangeDir(mdir);
             try
              mFtp.MakeDir('zalohy');
             except

             end;
             mftp.ChangeDir('zalohy');
             mFTP.TransferType:=ftBinary;
             mftp.Put(NxGetTempDir+'\'+mFileName,mfileName);
             mFTP.Free;
           except

           end;
        DeleteFile(NxGetTempDir+'\'+mFileName);
     end;
  end;
  Success := True;
  mDateTo:=FormatDateTime('d.m.yyyy hh:mm:ss',Now);
  LogInfoStr := 'Počet dokladů '+IntToStr(j)+' od data '+mdatefrom+' do data '+mdateto;
end;

procedure GenerateDocRekl (OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
var
 mInvoiceList, mPrintList:TStringList;
 i,j:integer;
 mBO:TNxCustomBusinessObject;
 mFTP:TFTP;
 mFileName, mDir, mDateFrom, mDateTo:string;
begin
  mInvoiceList:=Tstringlist.Create;
  j:=0;
  mDateFrom:=FormatDateTime('d.m.yyyy hh:mm:ss',Now);
  OS.SQLSelect('SELECT a.id FROM CrmActivities A left join firms f on a.Firm_id=F.id WHERE (A.CreatedAt$DATE >='+IntToStr(Trunc(date-1))+' or A.Correctedat$Date>='+IntToStr(Trunc(date-1))+') ' +
               ' AND F.X_B2B='+Quotedstr('A'),mInvoiceList);
  if mInvoiceList.count>0 then begin
     j:=mInvoiceList.count;
     for i:=0 to mInvoiceList.count-1 do begin
        mBO:=OS.CreateObject(Class_CRMActivity);
        mBO.Load(mInvoiceList.Strings[i],nil);
        mFileName:=NxSearchReplace(mbo.DisplayName,'/','-',[srAll])+'.pdf';
        mDir:=mbo.GetFieldValueAsString('Firm_ID.OrgIdentNumber');
        mPrintList:=TStringList.create;
        mPrintList.Add(mBO.OID);
        CFxReportManager.PrintByIDs(NxCreateContext_1(mBO),mPrintList,GetDynSource(os,'1L70000101'),'1L70000101',rtoFile,pekPDF,NxGetTempDir,mFileName);
        mPrintList.free;
        try
             mFTP:= TFTP.Create;
             mFTP.Host:=cUrl;
             mftp.UserName:=cLogin;
             mFTP.Password:=cPass;
             mftp.Connect;
             mFTP.Passive:=true;

             try
              mFtp.MakeDir(mdir);
             except

             end;
             mftp.ChangeDir(mdir);
             try
              mFtp.MakeDir('reklamace');
             except

             end;
             mftp.ChangeDir('reklamace');
             mFTP.TransferType:=ftBinary;
             mftp.Put(NxGetTempDir+'\'+mFileName,mfileName);
             mFTP.Free;
           except

           end;
        DeleteFile(NxGetTempDir+'\'+mFileName);
     end;
  end;
  Success := True;
  mDateTo:=FormatDateTime('d.m.yyyy hh:mm:ss',Now);
  LogInfoStr := 'Počet dokladů '+IntToStr(j)+' od data '+mdatefrom+' do data '+mdateto;
end;

function GetDynSource (AOS : TNxCustomObjectSpace; AValue : string) : String;
const
  cSQL = 'SELECT DataSource FROM Reports WHERE ID=''%s'' ';
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