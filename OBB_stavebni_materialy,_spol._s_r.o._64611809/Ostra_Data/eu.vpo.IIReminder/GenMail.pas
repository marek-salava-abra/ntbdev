uses 'eu.vpo.IIReminder.fce';
const
 mCode02='F21';
 mCode07='F07';
 mCode14='F14';
 mCode02Z='Z21';
 mCode07Z='Z07';
 mCode14Z='Z14';
procedure GenMail2 (OS: TNxCustomObjectSpace;
  var Success: Boolean; var LogInfoStr: String);

var
 mIIList:TStringList;
 mFirmMail,mDivisionMail, mDateString:String;
 mSQL:String;
 mIIBO, mTextBO:TNxCustomBusinessObject;
 mIIRow:TNxCustomBusinessMonikerCollection;
 mBusOrder_id, mDivision_ID:String;
 i,j :Integer;
 fName, mText_ID:String;
 mIDList:TStringList;
 mMail2dny:string;
begin
  mDateString:=IntToStr(trunc(Now-21));
  mIIList:=TStringList.Create;
  try
     mSQL:='Select id from issuedinvoices where amount-paidamount>0 and x_excluded=''N'' and duedate$date=''%s'' ';
      OS.SQLSelect(Format(mSQL, [mDateString]), mIIList);
      if mIIList.Count>0 then begin
      for i:=0 to mIIList.count-1 do begin
         mIDList:=TStringList.Create;
         mDivision_ID:='';
         mDivisionMail:='';
         mBusOrder_id:='';
         mIIBO:= OS.CreateObject(Class_IssuedInvoice);
         mTextBO:=OS.CreateObject('DCHDUXZ0S3RO1DVWDVB0PD51U0');
         mText_ID:=scrText(OS,mCode02);
         if not(NxIsEmptyOID(mText_ID)) then begin
          mTextBO.Load(mText_ID,nil);
          mMail2dny:=mTextBO.GetFieldValueAsString('X_note');
         end;
         mIIBO.Load(mIIList.Strings[i],nil);
         mIDList.Append(mIIBO.OID);
         mFirmMail:=mIIBO.GetFieldValueAsString('Firm_ID.ResidenceAddress_ID.Email');
         mIIRow:=mIIBO.GetLoadedCollectionMonikerForFieldCode(miibo.GetFieldCode('Rows'));
         for j:=0 to mIIRow.Count-1 do begin
           if NxIsBlank(mDivisionMail) then mDivisionMail:= mIIRow.BusinessObject[j].GetFieldValueAsString('Division_id.Address_ID.Email');
           if NxIsEmptyOID(mDivision_ID) then mDivision_ID := mIIRow.BusinessObject[j].GetFieldValueAsString('Division_id');
           if NxIsEmptyOID(mBusOrder_id) then mBusOrder_id:= mIIRow.BusinessObject[j].GetFieldValueAsString('BusOrder_ID');
         end;
         fname:=NxSearchReplace(mIIBO.DisplayName,'/','-',[srall])+'.pdf';
         CFxReportManager.PrintByIDs(NxCreateContext_1(mIIBO),mIDList,'40SBPEINEFD13ACM03KIU0CLP4','2J40000101',rtoFile,pekPDF,NxGetTempDir,fName);

         {if NxIsValidEMail(mFirmMail,false) then
         SendInternalMail(OS, mFirmMail,mDivisionMail,scremail(OS),
                         'Neuhrazena faktura '+miibo.DisplayName,mMail2dny,
                         NxGetTempDir+'\'+fName,mIIBO.GetFieldValueAsString('Firm_ID'),mDivision_ID,mBusOrder_id);

         if not(NxIsValidEMail(mFirmMail,false)) then  }
         SendInternalMail(OS, mDivisionMail,'',scremail(OS),
                         'Neuhrazena faktura '+miibo.DisplayName,mMail2dny,
                         NxGetTempDir+'\'+fName,mIIBO.GetFieldValueAsString('Firm_ID'),mDivision_ID,mBusOrder_id);

         LogInfoStr:=LogInfoStr+ mIIBO.GetFieldValueAsString('Firm_ID.name')+' '+mDivisionMail+Chr(10)+Chr(13);
         mIIBO.free;
         mIDList.free;
      end;
      end;
  finally
   mIIList.Free;
  end;
  Success := True;
  //LogInfoStr := '';
end;

procedure GenMail7 (OS: TNxCustomObjectSpace;
  var Success: Boolean; var LogInfoStr: String);

var
 mIIList:TStringList;
 mFirmMail,mDivisionMail, mDateString:String;
 mSQL:String;
 mIIBO, mTextBO:TNxCustomBusinessObject;
 mIIRow:TNxCustomBusinessMonikerCollection;
 mBusOrder_id, mDivision_ID:String;
 i,j :Integer;
 fName,mMail7dny, mText_ID:String;
 mIDList:TStringList;
begin
  mDateString:=IntToStr(trunc(Now-7));
  mIIList:=TStringList.Create;
  try
     mSQL:='Select id from issuedinvoices where amount-paidamount>0 and x_excluded=''N'' and duedate$date=''%s'' ';
      OS.SQLSelect(Format(mSQL, [mDateString]), mIIList);
      if mIIList.Count>0 then begin
      for i:=0 to mIIList.count-1 do begin
         mIDList:=TStringList.Create;
         mDivision_ID:='';
         mDivisionMail:='';
         mBusOrder_id:='';
         mIIBO:= OS.CreateObject(Class_IssuedInvoice);
         mTextBO:=OS.CreateObject('DCHDUXZ0S3RO1DVWDVB0PD51U0');
         mText_ID:=scrText(OS,mCode07);
         if not(NxIsEmptyOID(mText_ID)) then begin
          mTextBO.Load(mText_ID,nil);
          mMail7dny:=mTextBO.GetFieldValueAsString('X_note');
         end;
         mIIBO.Load(mIIList.Strings[i],nil);
         mIDList.Append(mIIBO.OID);
         mFirmMail:=mIIBO.GetFieldValueAsString('Firm_ID.ResidenceAddress_ID.Email');
         mIIRow:=mIIBO.GetLoadedCollectionMonikerForFieldCode(miibo.GetFieldCode('Rows'));
         for j:=0 to mIIRow.Count-1 do begin
           if NxIsBlank(mDivisionMail) then mDivisionMail:= mIIRow.BusinessObject[j].GetFieldValueAsString('Division_id.Address_ID.Email');
           if NxIsEmptyOID(mDivision_ID) then mDivision_ID := mIIRow.BusinessObject[j].GetFieldValueAsString('Division_id');
           if NxIsEmptyOID(mBusOrder_id) then mBusOrder_id:= mIIRow.BusinessObject[j].GetFieldValueAsString('BusOrder_ID');
         end;
         fname:=NxSearchReplace(mIIBO.DisplayName,'/','-',[srall])+'.pdf';
         CFxReportManager.PrintByIDs(NxCreateContext_1(mIIBO),mIDList,'40SBPEINEFD13ACM03KIU0CLP4','2J40000101',rtoFile,pekPDF,NxGetTempDir,fName);

         {if NxIsValidEMail(mFirmMail,false) then
         SendInternalMail(OS, mFirmMail,mDivisionMail,scremail(OS),
                         'Neuhrazena faktura '+miibo.DisplayName,mMail7dny,
                         NxGetTempDir+'\'+fName,mIIBO.GetFieldValueAsString('Firm_ID'),mDivision_ID,mBusOrder_id);

         if not(NxIsValidEMail(mFirmMail,false)) then }
         SendInternalMail(OS, mDivisionMail,'',scremail(OS),
                         'Neuhrazena faktura '+miibo.DisplayName,mMail7dny,
                         NxGetTempDir+'\'+fName,mIIBO.GetFieldValueAsString('Firm_ID'),mDivision_ID,mBusOrder_id);

         LogInfoStr:=LogInfoStr+ mIIBO.GetFieldValueAsString('Firm_ID.name')+' '+mDivisionMail+Chr(10)+Chr(13);
         mIIBO.free;
         mIDList.free;
      end;
     end;
  finally
   mIIList.Free;
  end;
  Success := True;
  //LogInfoStr := '';
end;

procedure GenMail14 (OS: TNxCustomObjectSpace;
  var Success: Boolean; var LogInfoStr: String);

var
 mIIList:TStringList;
 mFirmMail,mDivisionMail, mDateString:String;
 mSQL:String;
 mIIBO, mTextBO:TNxCustomBusinessObject;
 mIIRow:TNxCustomBusinessMonikerCollection;
 mBusOrder_id, mDivision_ID:String;
 i,j :Integer;
 fName,mMail14dny, mText_ID:String;
 mIDList:TStringList;
begin
  mDateString:=IntToStr(trunc(Now-14));
  mIIList:=TStringList.Create;
  try
     mSQL:='Select id from issuedinvoices where amount-paidamount>0 and x_excluded=''N'' and duedate$date=''%s'' ';
      OS.SQLSelect(Format(mSQL, [mDateString]), mIIList);
      if mIIList.Count>0 then begin
      for i:=0 to mIIList.count-1 do begin
         mIDList:=TStringList.Create;
         mDivision_ID:='';
         mDivisionMail:='';
         mBusOrder_id:='';
         mIIBO:= OS.CreateObject(Class_IssuedInvoice);
         mTextBO:=OS.CreateObject('DCHDUXZ0S3RO1DVWDVB0PD51U0');
         mText_ID:=scrText(OS,mCode14);
         if not(NxIsEmptyOID(mText_ID)) then begin
          mTextBO.Load(mText_ID,nil);
          mMail14dny:=mTextBO.GetFieldValueAsString('X_note');
         end;
         mIIBO.Load(mIIList.Strings[i],nil);
         mIDList.Append(mIIBO.OID);
         mFirmMail:=mIIBO.GetFieldValueAsString('Firm_ID.ResidenceAddress_ID.Email');
         mIIRow:=mIIBO.GetLoadedCollectionMonikerForFieldCode(miibo.GetFieldCode('Rows'));
         for j:=0 to mIIRow.Count-1 do begin
           if NxIsBlank(mDivisionMail) then mDivisionMail:= mIIRow.BusinessObject[j].GetFieldValueAsString('Division_id.Address_ID.Email');
           if NxIsEmptyOID(mDivision_ID) then mDivision_ID := mIIRow.BusinessObject[j].GetFieldValueAsString('Division_id');
           if NxIsEmptyOID(mBusOrder_id) then mBusOrder_id:= mIIRow.BusinessObject[j].GetFieldValueAsString('BusOrder_ID');
         end;
         fname:=NxSearchReplace(mIIBO.DisplayName,'/','-',[srall])+'.pdf';
         CFxReportManager.PrintByIDs(NxCreateContext_1(mIIBO),mIDList,'40SBPEINEFD13ACM03KIU0CLP4','2J40000101',rtoFile,pekPDF,NxGetTempDir,fName);

         {if NxIsValidEMail(mFirmMail,false) then
         SendInternalMail(OS, mFirmMail,mDivisionMail,scremail(OS),
                         'Neuhrazena faktura '+miibo.DisplayName,mMail14dny,
                         NxGetTempDir+'\'+fName,mIIBO.GetFieldValueAsString('Firm_ID'),mDivision_ID,mBusOrder_id);

         if not(NxIsValidEMail(mFirmMail,false)) then }
         SendInternalMail(OS, mDivisionMail,'',scremail(OS),
                         'Neuhrazena faktura '+miibo.DisplayName,mMail14dny,
                         NxGetTempDir+'\'+fName,mIIBO.GetFieldValueAsString('Firm_ID'),mDivision_ID,mBusOrder_id);

         LogInfoStr:=LogInfoStr+ mIIBO.GetFieldValueAsString('Firm_ID.name')+' '+mDivisionMail+Chr(10)+Chr(13);
         mIIBO.free;
         mIDList.free;
      end;
     end;
  finally
   mIIList.Free;
  end;
  Success := True;
  //LogInfoStr := '';
end;

procedure GenMailZ2 (OS: TNxCustomObjectSpace;
  var Success: Boolean; var LogInfoStr: String);

var
 mIIList:TStringList;
 mFirmMail,mDivisionMail, mDateString:String;
 mSQL:String;
 mIIBO, mTextBO:TNxCustomBusinessObject;
 mIIRow:TNxCustomBusinessMonikerCollection;
 mBusOrder_id, mDivision_ID:String;
 i,j :Integer;
 fName, mText_ID:String;
 mIDList:TStringList;
 mMail2dny:string;
begin
  mDateString:=IntToStr(trunc(Now-21));
  mIIList:=TStringList.Create;
  try
     mSQL:='Select id from issuedDinvoices where amount-paidamount>0 and x_excluded=''N'' and duedate$date=''%s'' '; //BOMA 20.6.2016 - bylo issuedDepositinvoices
      OS.SQLSelect(Format(mSQL, [mDateString]), mIIList);
      if mIIList.Count>0 then begin
      for i:=0 to mIIList.count-1 do begin
         mIDList:=TStringList.Create;
         mDivision_ID:='';
         mDivisionMail:='';
         mBusOrder_id:='';
         mIIBO:= OS.CreateObject(Class_IssuedDepositInvoice);
         mTextBO:=OS.CreateObject('DCHDUXZ0S3RO1DVWDVB0PD51U0');
         mText_ID:=scrText(OS,mCode02z);
         mTextBO.Load(mText_ID,nil);
         mMail2dny:=mTextBO.GetFieldValueAsString('X_note');
         mIIBO.Load(mIIList.Strings[i],nil);
         mIDList.Append(mIIBO.OID);
         mFirmMail:=mIIBO.GetFieldValueAsString('Firm_ID.ResidenceAddress_ID.Email');
         mIIRow:=mIIBO.GetLoadedCollectionMonikerForFieldCode(miibo.GetFieldCode('Rows'));
         for j:=0 to mIIRow.Count-1 do begin
           if NxIsBlank(mDivisionMail) then mDivisionMail:= mIIRow.BusinessObject[j].GetFieldValueAsString('Division_id.Address_ID.Email');
           if NxIsEmptyOID(mDivision_ID) then mDivision_ID := mIIRow.BusinessObject[j].GetFieldValueAsString('Division_id');
           if NxIsEmptyOID(mBusOrder_id) then mBusOrder_id:= mIIRow.BusinessObject[j].GetFieldValueAsString('BusOrder_ID');
         end;
         fname:=NxSearchReplace(mIIBO.DisplayName,'/','-',[srall])+'.pdf';
         CFxReportManager.PrintByIDs(NxCreateContext_1(mIIBO),mIDList,'S4STXJVRM3DL35J301C0CX3F40','1D10000101',rtoFile,pekPDF,NxGetTempDir,fName);

         {if NxIsValidEMail(mFirmMail,false) then
         SendInternalMail(OS, mFirmMail,mDivisionMail,scremail(OS),
                         'Neuhrazen zálohový list '+miibo.DisplayName,mMail2dny,
                         NxGetTempDir+'\'+fName,mIIBO.GetFieldValueAsString('Firm_ID'),mDivision_ID,mBusOrder_id);

         if not(NxIsValidEMail(mFirmMail,false)) then }
         SendInternalMail(OS, mDivisionMail,'',scremail(OS),
                         'Neuhrazen zálohový list '+miibo.DisplayName,mMail2dny,
                         NxGetTempDir+'\'+fName,mIIBO.GetFieldValueAsString('Firm_ID'),mDivision_ID,mBusOrder_id);

         LogInfoStr:=LogInfoStr+ mIIBO.GetFieldValueAsString('Firm_ID.name')+' '+mDivisionMail+Chr(10)+Chr(13);
         mIIBO.free;
         mIDList.free;
      end;
     end;
  finally
   mIIList.Free;
  end;
  Success := True;
  //LogInfoStr := '';
end;

procedure GenMailZ7 (OS: TNxCustomObjectSpace;
  var Success: Boolean; var LogInfoStr: String);

var
 mIIList:TStringList;
 mFirmMail,mDivisionMail, mDateString:String;
 mSQL:String;
 mIIBO, mTextBO:TNxCustomBusinessObject;
 mIIRow:TNxCustomBusinessMonikerCollection;
 mBusOrder_id, mDivision_ID:String;
 i,j :Integer;
 fName,mMail7dny, mText_ID:String;
 mIDList:TStringList;
begin
  mDateString:=IntToStr(trunc(Now-7));
  mIIList:=TStringList.Create;
  try
     mSQL:='Select id from issuedDinvoices where amount-paidamount>0 and x_excluded=''N'' and duedate$date=''%s'' ';  //BOMA 20.6.2016 - bylo issuedDepositinvoices
      OS.SQLSelect(Format(mSQL, [mDateString]), mIIList);
      if mIIList.Count>0 then begin
      for i:=0 to mIIList.count-1 do begin
         mIDList:=TStringList.Create;
         mDivision_ID:='';
         mDivisionMail:='';
         mBusOrder_id:='';
         mIIBO:= OS.CreateObject(Class_IssuedDepositInvoice);
         mTextBO:=OS.CreateObject('DCHDUXZ0S3RO1DVWDVB0PD51U0');
         mText_ID:=scrText(OS,mCode07z);
         mTextBO.Load(mText_ID,nil);
         mMail7dny:=mTextBO.GetFieldValueAsString('X_note');
         mIIBO.Load(mIIList.Strings[i],nil);
         mIDList.Append(mIIBO.OID);
         mFirmMail:=mIIBO.GetFieldValueAsString('Firm_ID.ResidenceAddress_ID.Email');
         mIIRow:=mIIBO.GetLoadedCollectionMonikerForFieldCode(miibo.GetFieldCode('Rows'));
         for j:=0 to mIIRow.Count-1 do begin
           if NxIsBlank(mDivisionMail) then mDivisionMail:= mIIRow.BusinessObject[j].GetFieldValueAsString('Division_id.Address_ID.Email');
           if NxIsEmptyOID(mDivision_ID) then mDivision_ID := mIIRow.BusinessObject[j].GetFieldValueAsString('Division_id');
           if NxIsEmptyOID(mBusOrder_id) then mBusOrder_id:= mIIRow.BusinessObject[j].GetFieldValueAsString('BusOrder_ID');
         end;
         fname:=NxSearchReplace(mIIBO.DisplayName,'/','-',[srall])+'.pdf';
         CFxReportManager.PrintByIDs(NxCreateContext_1(mIIBO),mIDList,'S4STXJVRM3DL35J301C0CX3F40','1D10000101',rtoFile,pekPDF,NxGetTempDir,fName);

         {if NxIsValidEMail(mFirmMail,false) then
         SendInternalMail(OS, mFirmMail,mDivisionMail,scremail(OS),
                         'Neuhrazen zálohový list '+miibo.DisplayName,mMail7dny,
                         NxGetTempDir+'\'+fName,mIIBO.GetFieldValueAsString('Firm_ID'),mDivision_ID,mBusOrder_id);

         if not(NxIsValidEMail(mFirmMail,false)) then    }
         SendInternalMail(OS, mDivisionMail,'',scremail(OS),
                         'Neuhrazen zálohový list '+miibo.DisplayName,mMail7dny,
                         NxGetTempDir+'\'+fName,mIIBO.GetFieldValueAsString('Firm_ID'),mDivision_ID,mBusOrder_id);

         LogInfoStr:=LogInfoStr+ mIIBO.GetFieldValueAsString('Firm_ID.name')+' '+mDivisionMail+Chr(10)+Chr(13);
         mIIBO.free;
         mIDList.free;
      end;
     end;
  finally
   mIIList.Free;
  end;
  Success := True;
  //LogInfoStr := '';
end;

procedure GenMailZ14 (OS: TNxCustomObjectSpace;
  var Success: Boolean; var LogInfoStr: String);

var
 mIIList:TStringList;
 mFirmMail,mDivisionMail, mDateString:String;
 mSQL:String;
 mIIBO, mTextBO:TNxCustomBusinessObject;
 mIIRow:TNxCustomBusinessMonikerCollection;
 mBusOrder_id, mDivision_ID:String;
 i,j :Integer;
 fName,mMail14dny, mText_ID:String;
 mIDList:TStringList;
begin
  mDateString:=IntToStr(trunc(Now-14));
  mIIList:=TStringList.Create;
  try
     mSQL:='Select id from issuedDinvoices where amount-paidamount>0 and x_excluded=''N'' and duedate$date=''%s'' '; //BOMA 20.6.2016 - bylo issuedDepositinvoices
      OS.SQLSelect(Format(mSQL, [mDateString]), mIIList);
      if mIIList.Count>0 then begin
      for i:=0 to mIIList.count-1 do begin
         mIDList:=TStringList.Create;
         mDivision_ID:='';
         mDivisionMail:='';
         mBusOrder_id:='';
         mIIBO:= OS.CreateObject(Class_IssuedDepositInvoice);
         mTextBO:=OS.CreateObject('DCHDUXZ0S3RO1DVWDVB0PD51U0');
         mText_ID:=scrText(OS,mCode14z);
         mTextBO.Load(mText_ID,nil);
         mMail14dny:=mTextBO.GetFieldValueAsString('X_note');
         mIIBO.Load(mIIList.Strings[i],nil);
         mIDList.Append(mIIBO.OID);
         mFirmMail:=mIIBO.GetFieldValueAsString('Firm_ID.ResidenceAddress_ID.Email');
         mIIRow:=mIIBO.GetLoadedCollectionMonikerForFieldCode(miibo.GetFieldCode('Rows'));
         for j:=0 to mIIRow.Count-1 do begin
           if NxIsBlank(mDivisionMail) then mDivisionMail:= mIIRow.BusinessObject[j].GetFieldValueAsString('Division_id.Address_ID.Email');
           if NxIsEmptyOID(mDivision_ID) then mDivision_ID := mIIRow.BusinessObject[j].GetFieldValueAsString('Division_id');
           if NxIsEmptyOID(mBusOrder_id) then mBusOrder_id:= mIIRow.BusinessObject[j].GetFieldValueAsString('BusOrder_ID');
         end;
         fname:=NxSearchReplace(mIIBO.DisplayName,'/','-',[srall])+'.pdf';
         CFxReportManager.PrintByIDs(NxCreateContext_1(mIIBO),mIDList,'S4STXJVRM3DL35J301C0CX3F40','1D10000101',rtoFile,pekPDF,NxGetTempDir,fName);

         {if NxIsValidEMail(mFirmMail,false) then
         SendInternalMail(OS, mFirmMail,mDivisionMail,scremail(OS),
                         'Neuhrazen zálohový list '+miibo.DisplayName,mMail14dny,
                         NxGetTempDir+'\'+fName,mIIBO.GetFieldValueAsString('Firm_ID'),mDivision_ID,mBusOrder_id);

         if not(NxIsValidEMail(mFirmMail,false)) then  }
         SendInternalMail(OS, mDivisionMail,'',scremail(OS),
                         'Neuhrazen zálohový list '+miibo.DisplayName,mMail14dny,
                         NxGetTempDir+'\'+fName,mIIBO.GetFieldValueAsString('Firm_ID'),mDivision_ID,mBusOrder_id);

         LogInfoStr:=LogInfoStr+ mIIBO.GetFieldValueAsString('Firm_ID.name')+' '+mDivisionMail+Chr(10)+Chr(13);
         mIIBO.free;
         mIDList.free;
      end;
     end;
  finally
   mIIList.Free;
  end;
  Success := True;
  //LogInfoStr := '';
end;



begin
end.