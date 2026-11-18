uses 'eu.abra.cemat.IIReminder.fce';
const
 mCode02='F21';
 mCode07='F01';
 mCode14='F02';
 mCode28='F03';
 mCode31='F31';
 mCode02Z='Z21';
 mCode07Z='Z07';
 mCode14Z='Z14';


procedure GenMail01 (OS: TNxCustomObjectSpace;
  var Success: Boolean; var LogInfoStr: String);

var
 mIIList:TStringList;
 mFirmMail,mBusTransactionMail, mDateString:String;
 mSQL:String;
 mIIBO, mTextBO:TNxCustomBusinessObject;
 mIIRow, mUPRows:TNxCustomBusinessMonikerCollection;
 mBusTransaction_ID, mDivision_ID:String;
 i,j :Integer;
 fName,mMail7dny, mText_ID,fName2:String;
 mIDList, mIDList2:TStringList;
 mUPBo, mUPRowBO:TNxCustomBusinessObject;
begin
  mDateString:=IntToStr(trunc(Now-7));
  mIIList:=TStringList.Create;
  try
     //mSQL:='Select id from issuedinvoices where amount-paidamount>0 and x_excluded=''N'' and duedate$date=''%s'' ';
     mSQL:='Select ii.id from issuedinvoices ii left join firms f on f.id=ii.firm_id where ii.amount-ii.paidamount-ii.creditamount>0 and f.x_vyloucena=''N'' and II.x_vyloucena=''N'' and ii.duedate$date>=%s and ii.duedate$date<%s ';
      OS.SQLSelect(Format(mSQL, [IntToStr(Trunc(date)-21),IntToStr(Trunc(date)-15)]), mIIList);
      if mIIList.Count>0 then begin
      for i:=0 to mIIList.count-1 do begin
         mIDList:=TStringList.Create;
         mIDlist2:=TStringList.Create;
         mDivision_ID:='';
         mBusTransactionMail:='';
         mBusTransaction_ID:='';
         mIIBO:= OS.CreateObject(Class_IssuedInvoice);
         mTextBO:=OS.CreateObject('LS4NPV5K0AAOVGXY0RJGORE4C4');
         mText_ID:='1NH0000101';
         if not(NxIsEmptyOID(mText_ID)) then begin
          mTextBO.Load(mText_ID,nil);
          mMail7dny:=mTextBO.GetFieldValueAsString('X_note');
         end;
         mIIBO.Load(mIIList.Strings[i],nil);
         mIDList.Append(mIIBO.OID);
         mMail7dny:=NxSearchReplace(mMail7dny,'#cislo#',mIIBO.DisplayName,[srAll]);
         mMail7dny:=NxSearchReplace(mMail7dny,'#datum#',DateToStr(mIIBO.GetFieldValueAsDateTime('DocDate$Date')),[srAll]);
         mMail7dny:=NxSearchReplace(mMail7dny,'#popis#',mIIBO.GetFieldValueAsString('Description'),[srAll]);
         mMail7dny:=NxSearchReplace(mMail7dny,'#splatnost#',DateToStr(mIIBO.GetFieldValueAsDateTime('DueDate$Date')),[srAll]);

         mMail7dny:=NxSearchReplace(mMail7dny,'#castka#',NxformatNumeric('0.00,',(mIIBO.GetFieldValueAsFloat('Amount')-mIIBO.GetFieldValueAsFloat('PaidAmount')))+' '+miibo.GetFieldValueAsString('currency_id.code'),[srAll]);
         mFirmMail:=mIIBO.GetFieldValueAsString('Firm_ID.ElectronicAddress_ID.Email');
         //mFirmMail:='uctarna.praha@cemat.cz';
         mIIRow:=mIIBO.GetLoadedCollectionMonikerForFieldCode(miibo.GetFieldCode('Rows'));
         for j:=0 to mIIRow.Count-1 do begin
           //if NxIsBlank(mBusTransactionMail) then mBusTransactionMail:= mIIRow.BusinessObject[j].GetFieldValueAsString('BusTransaction_id.U_Email');
           if NxIsEmptyOID(mDivision_ID) then mDivision_ID := mIIRow.BusinessObject[j].GetFieldValueAsString('Division_id');
           if NxIsEmptyOID(mBusTransaction_ID) then mBusTransaction_ID:= mIIRow.BusinessObject[j].GetFieldValueAsString('BusTransaction_ID');
         end;
         //generovani upominky
         { try
             mUPBo:=os.CreateObject(Class_PaymentReminder);
             mUPBo.New;
             mupbo.Prefill;
             mupbo.SetFieldValueAsString('IssuedInvoice_ID',miibo.OID);
             mUPBo.SetFieldValueAsString('Firm_ID',miibo.GetFieldValueAsString('Firm_ID'));
             mUPBo.SetFieldValueAsString('Currency_ID',mIIBO.GetFieldValueAsString('Currency_ID'));
             mupbo.SetFieldValueAsString('DocQueue_ID','4200000101');
             mUPbo.SetFieldValueAsInteger('DocOrder',1);
             mUPBo.SetFieldValueAsString('CreatedBy_ID','2D00000101');
             //mupBO.SetFieldValueAsFloat('PenaltyPercent',0);
             mUPRows:=mUPBo.GetLoadedCollectionMonikerForFieldCode(mupbo.GetFieldCode('Rows'));
             mUPRowBO:=mUPRows.AddNewObject;
             mUpRowBo.Prefill;
             mUProwbo.SetFieldValueAsString('Division_ID',mDivision_ID);
             mUProwbo.setfieldvalueasString('Text','Upomínka faktury '+miibo.DisplayName);
             mUPRowBO.SetFieldValueAsFloat('AmountInvoice',mIIBO.GetFieldValueAsFloat('amount'));
             mUProwbo.SetFieldValueAsDateTime('DatePenaltyFrom$DATE', miibo.GetFieldValueAsDateTime('duedate$date'));
             mUProwbo.SetFieldValueAsDateTime('DatePenaltyTo$DATE', Date);
             mupbo.save;
             fname2:=NxSearchReplace(mUPBO.DisplayName,'/','-',[srall])+'.pdf';
             mIDList2.Add(mUPBo.OID);
             mupbo.free;
          finally

          end;
         //konec generovani upo }
         fname:=NxSearchReplace(mIIBO.DisplayName,'/','-',[srall])+'.pdf';
         CFxReportManager.PrintByIDs(NxCreateContext_1(mIIBO),mIDList,'40SBPEINEFD13ACM03KIU0CLP4','1500000101',rtoFile,pekPDF,NxGetTempDir,fName);
         //CFxReportManager.PrintByIDs(NxCreateContext_1(mIIBO),mIDList2,'ZIGJSEDS3Q3OH0QFH0CQ3KMUZ0','6900000001',rtoFile,pekPDF,NxGetTempDir,fName2);
         if NxIsValidEMail(mFirmMail,false) then
         SendInternalMail(OS, mFirmMail,'','uctarna.praha@cemat.cz',
                         'Upomínka neuhrazené faktury '+miibo.DisplayName+ ' VS:'+miibo.GetFieldValueAsString('VarSymbol'),mMail7dny,
                         NxGetTempDir+'\'+fName,'',mIIBO.GetFieldValueAsString('Firm_ID'),mDivision_ID,mBusTransaction_ID);

         LogInfoStr:=LogInfoStr+ mIIBO.GetFieldValueAsString('Firm_ID.name')+' '+mBusTransactionMail+Chr(10)+Chr(13);
         mIIBO.free;
         mIDList.free;
         mIDList2.Free;
      end;
     end;
  finally
   mIIList.Free;
  end;
  Success := True;
  //LogInfoStr := '';
end;

procedure GenMail02 (OS: TNxCustomObjectSpace;
  var Success: Boolean; var LogInfoStr: String);

var
 mIIList:TStringList;
 mFirmMail,mBusTransactionMail, mDateString:String;
 mSQL:String;
 mIIBO, mTextBO:TNxCustomBusinessObject;
 mIIRow, mUPRows:TNxCustomBusinessMonikerCollection;
 mBusTransaction_ID, mDivision_ID:String;
 i,j :Integer;
 fName,mMail7dny, mText_ID,fName2:String;
 mIDList, mIDList2:TStringList;
 mUPBo, mUPRowBO:TNxCustomBusinessObject;
begin
  mDateString:=IntToStr(trunc(Now-7));
  mIIList:=TStringList.Create;
  try
     //mSQL:='Select id from issuedinvoices where amount-paidamount>0 and x_excluded=''N'' and duedate$date=''%s'' ';
     mSQL:='Select ii.id from issuedinvoices ii left join firms f on f.id=ii.firm_id where ii.amount-ii.paidamount-ii.creditamount>0 and f.x_vyloucena=''N'' and II.x_vyloucena=''N'' and ii.duedate$date>=%s and ii.duedate$date<%s ';
      OS.SQLSelect(Format(mSQL, [IntToStr(Trunc(date)-28),IntToStr(Trunc(date)-22)]), mIIList);
      if mIIList.Count>0 then begin
      for i:=0 to mIIList.count-1 do begin
         mIDList:=TStringList.Create;
         mIDlist2:=TStringList.Create;
         mDivision_ID:='';
         mBusTransactionMail:='';
         mBusTransaction_ID:='';
         mIIBO:= OS.CreateObject(Class_IssuedInvoice);
         mTextBO:=OS.CreateObject('LS4NPV5K0AAOVGXY0RJGORE4C4');
         mText_ID:='2NH0000101';
         if not(NxIsEmptyOID(mText_ID)) then begin
          mTextBO.Load(mText_ID,nil);
          mMail7dny:=mTextBO.GetFieldValueAsString('X_note');
         end;
         mIIBO.Load(mIIList.Strings[i],nil);
         mIDList.Append(mIIBO.OID);
         mMail7dny:=NxSearchReplace(mMail7dny,'#cislo#',mIIBO.DisplayName,[srAll]);
         mMail7dny:=NxSearchReplace(mMail7dny,'#datum#',DateToStr(mIIBO.GetFieldValueAsDateTime('DocDate$Date')),[srAll]);
         mMail7dny:=NxSearchReplace(mMail7dny,'#popis#',mIIBO.GetFieldValueAsString('Description'),[srAll]);
         mMail7dny:=NxSearchReplace(mMail7dny,'#splatnost#',DateToStr(mIIBO.GetFieldValueAsDateTime('DueDate$Date')),[srAll]);
         mMail7dny:=NxSearchReplace(mMail7dny,'#datum+7#',DateToStr(date+7),[srAll]);
          mMail7dny:=NxSearchReplace(mMail7dny,'#ucet#',mIIBO.GetFieldValueAsString('BankAccount_ID.BankAccount'),[srAll]);
         mMail7dny:=NxSearchReplace(mMail7dny,'#castka#',NxformatNumeric('0.00,',(mIIBO.GetFieldValueAsFloat('Amount')-mIIBO.GetFieldValueAsFloat('PaidAmount')))+' '+miibo.GetFieldValueAsString('currency_id.code'),[srAll]);
         mFirmMail:=mIIBO.GetFieldValueAsString('Firm_ID.ElectronicAddress_ID.Email');
         //mFirmMail:='uctarna.praha@cemat.cz';
         mIIRow:=mIIBO.GetLoadedCollectionMonikerForFieldCode(miibo.GetFieldCode('Rows'));
         for j:=0 to mIIRow.Count-1 do begin
           //if NxIsBlank(mBusTransactionMail) then mBusTransactionMail:= mIIRow.BusinessObject[j].GetFieldValueAsString('BusTransaction_id.U_Email');
           if NxIsEmptyOID(mDivision_ID) then mDivision_ID := mIIRow.BusinessObject[j].GetFieldValueAsString('Division_id');
           if NxIsEmptyOID(mBusTransaction_ID) then mBusTransaction_ID:= mIIRow.BusinessObject[j].GetFieldValueAsString('BusTransaction_ID');
         end;
         //generovani upominky
         { try
             mUPBo:=os.CreateObject(Class_PaymentReminder);
             mUPBo.New;
             mupbo.Prefill;
             mupbo.SetFieldValueAsString('IssuedInvoice_ID',miibo.OID);
             mUPBo.SetFieldValueAsString('Firm_ID',miibo.GetFieldValueAsString('Firm_ID'));
             mUPBo.SetFieldValueAsString('Currency_ID',mIIBO.GetFieldValueAsString('Currency_ID'));
             mupbo.SetFieldValueAsString('DocQueue_ID','4200000101');
             mUPbo.SetFieldValueAsInteger('DocOrder',1);
             mUPBo.SetFieldValueAsString('CreatedBy_ID','2D00000101');
             //mupBO.SetFieldValueAsFloat('PenaltyPercent',0);
             mUPRows:=mUPBo.GetLoadedCollectionMonikerForFieldCode(mupbo.GetFieldCode('Rows'));
             mUPRowBO:=mUPRows.AddNewObject;
             mUpRowBo.Prefill;
             mUProwbo.SetFieldValueAsString('Division_ID',mDivision_ID);
             mUProwbo.setfieldvalueasString('Text','Upomínka faktury '+miibo.DisplayName);
             mUPRowBO.SetFieldValueAsFloat('AmountInvoice',mIIBO.GetFieldValueAsFloat('amount'));
             mUProwbo.SetFieldValueAsDateTime('DatePenaltyFrom$DATE', miibo.GetFieldValueAsDateTime('duedate$date'));
             mUProwbo.SetFieldValueAsDateTime('DatePenaltyTo$DATE', Date);
             mupbo.save;
             fname2:=NxSearchReplace(mUPBO.DisplayName,'/','-',[srall])+'.pdf';
             mIDList2.Add(mUPBo.OID);
             mupbo.free;
          finally

          end;
         //konec generovani upo }
         fname:=NxSearchReplace(mIIBO.DisplayName,'/','-',[srall])+'.pdf';
         CFxReportManager.PrintByIDs(NxCreateContext_1(mIIBO),mIDList,'40SBPEINEFD13ACM03KIU0CLP4','1500000101',rtoFile,pekPDF,NxGetTempDir,fName);
         //CFxReportManager.PrintByIDs(NxCreateContext_1(mIIBO),mIDList2,'ZIGJSEDS3Q3OH0QFH0CQ3KMUZ0','6900000001',rtoFile,pekPDF,NxGetTempDir,fName2);
         if NxIsValidEMail(mFirmMail,false) then
         SendInternalMail(OS, mFirmMail,'','uctarna.praha@cemat.cz',
                         'Upomínka neuhrazené faktury '+miibo.DisplayName+ ' VS:'+miibo.GetFieldValueAsString('VarSymbol'),mMail7dny,
                         NxGetTempDir+'\'+fName,'',mIIBO.GetFieldValueAsString('Firm_ID'),mDivision_ID,mBusTransaction_ID);

         LogInfoStr:=LogInfoStr+ mIIBO.GetFieldValueAsString('Firm_ID.name')+' '+mBusTransactionMail+Chr(10)+Chr(13);
         mIIBO.free;
         mIDList.free;
         mIDList2.Free;
      end;
     end;
  finally
   mIIList.Free;
  end;
  Success := True;
  //LogInfoStr := '';
end;

procedure GenMail03 (OS: TNxCustomObjectSpace;
  var Success: Boolean; var LogInfoStr: String);

var
 mIIList:TStringList;
 mFirmMail,mBusTransactionMail, mDateString:String;
 mSQL:String;
 mIIBO, mTextBO:TNxCustomBusinessObject;
 mIIRow, mUPRows:TNxCustomBusinessMonikerCollection;
 mBusTransaction_ID, mDivision_ID:String;
 i,j :Integer;
 fName,mMail7dny, mText_ID,fName2:String;
 mIDList, mIDList2:TStringList;
 mUPBo, mUPRowBO:TNxCustomBusinessObject;
begin
  mDateString:=IntToStr(trunc(Now-7));
  mIIList:=TStringList.Create;
  try
     //mSQL:='Select id from issuedinvoices where amount-paidamount>0 and x_excluded=''N'' and duedate$date=''%s'' ';
     mSQL:='Select ii.id from issuedinvoices ii left join firms f on f.id=ii.firm_id where ii.amount-ii.paidamount-ii.creditamount>0 and f.x_vyloucena=''N'' and II.x_vyloucena=''N'' and ii.duedate$date>=%s and ii.duedate$date<%s ';
      OS.SQLSelect(Format(mSQL, [IntToStr(Trunc(date)-100),IntToStr(Trunc(date)-29)]), mIIList);
      if mIIList.Count>0 then begin
      for i:=0 to mIIList.count-1 do begin
         mIDList:=TStringList.Create;
         mIDlist2:=TStringList.Create;
         mDivision_ID:='';
         mBusTransactionMail:='';
         mBusTransaction_ID:='';
         mIIBO:= OS.CreateObject(Class_IssuedInvoice);
         mTextBO:=OS.CreateObject('LS4NPV5K0AAOVGXY0RJGORE4C4');
         mText_ID:='3NH0000101';
         if not(NxIsEmptyOID(mText_ID)) then begin
          mTextBO.Load(mText_ID,nil);
          mMail7dny:=mTextBO.GetFieldValueAsString('X_note');
         end;
         mIIBO.Load(mIIList.Strings[i],nil);
         mIDList.Append(mIIBO.OID);
         mMail7dny:=NxSearchReplace(mMail7dny,'#cislo#',mIIBO.DisplayName,[srAll]);
         mMail7dny:=NxSearchReplace(mMail7dny,'#datum#',DateToStr(mIIBO.GetFieldValueAsDateTime('DocDate$Date')),[srAll]);
         mMail7dny:=NxSearchReplace(mMail7dny,'#popis#',mIIBO.GetFieldValueAsString('Description'),[srAll]);
         mMail7dny:=NxSearchReplace(mMail7dny,'#splatnost#',DateToStr(mIIBO.GetFieldValueAsDateTime('DueDate$Date')),[srAll]);
         mMail7dny:=NxSearchReplace(mMail7dny,'#datum+7#',DateToStr(date+7),[srAll]);
          mMail7dny:=NxSearchReplace(mMail7dny,'#ucet#',mIIBO.GetFieldValueAsString('BankAccount_ID.BankAccount'),[srAll]);
         mMail7dny:=NxSearchReplace(mMail7dny,'#castka#',NxformatNumeric('0.00,',(mIIBO.GetFieldValueAsFloat('Amount')-mIIBO.GetFieldValueAsFloat('PaidAmount')))+' '+miibo.GetFieldValueAsString('currency_id.code'),[srAll]);
         mFirmMail:=mIIBO.GetFieldValueAsString('Firm_ID.ElectronicAddress_ID.Email');
         //mFirmMail:='uctarna.praha@cemat.cz';
         mIIRow:=mIIBO.GetLoadedCollectionMonikerForFieldCode(miibo.GetFieldCode('Rows'));
         for j:=0 to mIIRow.Count-1 do begin
           //if NxIsBlank(mBusTransactionMail) then mBusTransactionMail:= mIIRow.BusinessObject[j].GetFieldValueAsString('BusTransaction_id.U_Email');
           if NxIsEmptyOID(mDivision_ID) then mDivision_ID := mIIRow.BusinessObject[j].GetFieldValueAsString('Division_id');
           if NxIsEmptyOID(mBusTransaction_ID) then mBusTransaction_ID:= mIIRow.BusinessObject[j].GetFieldValueAsString('BusTransaction_ID');
         end;
         //generovani upominky
         { try
             mUPBo:=os.CreateObject(Class_PaymentReminder);
             mUPBo.New;
             mupbo.Prefill;
             mupbo.SetFieldValueAsString('IssuedInvoice_ID',miibo.OID);
             mUPBo.SetFieldValueAsString('Firm_ID',miibo.GetFieldValueAsString('Firm_ID'));
             mUPBo.SetFieldValueAsString('Currency_ID',mIIBO.GetFieldValueAsString('Currency_ID'));
             mupbo.SetFieldValueAsString('DocQueue_ID','4200000101');
             mUPbo.SetFieldValueAsInteger('DocOrder',1);
             mUPBo.SetFieldValueAsString('CreatedBy_ID','2D00000101');
             //mupBO.SetFieldValueAsFloat('PenaltyPercent',0);
             mUPRows:=mUPBo.GetLoadedCollectionMonikerForFieldCode(mupbo.GetFieldCode('Rows'));
             mUPRowBO:=mUPRows.AddNewObject;
             mUpRowBo.Prefill;
             mUProwbo.SetFieldValueAsString('Division_ID',mDivision_ID);
             mUProwbo.setfieldvalueasString('Text','Upomínka faktury '+miibo.DisplayName);
             mUPRowBO.SetFieldValueAsFloat('AmountInvoice',mIIBO.GetFieldValueAsFloat('amount'));
             mUProwbo.SetFieldValueAsDateTime('DatePenaltyFrom$DATE', miibo.GetFieldValueAsDateTime('duedate$date'));
             mUProwbo.SetFieldValueAsDateTime('DatePenaltyTo$DATE', Date);
             mupbo.save;
             fname2:=NxSearchReplace(mUPBO.DisplayName,'/','-',[srall])+'.pdf';
             mIDList2.Add(mUPBo.OID);
             mupbo.free;
          finally

          end;
         //konec generovani upo }
         fname:=NxSearchReplace(mIIBO.DisplayName,'/','-',[srall])+'.pdf';
         CFxReportManager.PrintByIDs(NxCreateContext_1(mIIBO),mIDList,'40SBPEINEFD13ACM03KIU0CLP4','1500000101',rtoFile,pekPDF,NxGetTempDir,fName);
         //CFxReportManager.PrintByIDs(NxCreateContext_1(mIIBO),mIDList2,'ZIGJSEDS3Q3OH0QFH0CQ3KMUZ0','6900000001',rtoFile,pekPDF,NxGetTempDir,fName2);
         if NxIsValidEMail(mFirmMail,false) then
         SendInternalMail(OS, mFirmMail,'','',
                         'Pokus o smír u neuhrazené faktury '+miibo.DisplayName+ ' VS:'+miibo.GetFieldValueAsString('VarSymbol'),mMail7dny,
                         NxGetTempDir+'\'+fName,'',mIIBO.GetFieldValueAsString('Firm_ID'),mDivision_ID,mBusTransaction_ID);

         LogInfoStr:=LogInfoStr+ mIIBO.GetFieldValueAsString('Firm_ID.name')+' '+mBusTransactionMail+Chr(10)+Chr(13);
         mIIBO.free;
         mIDList.free;
         mIDList2.Free;
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
 mFirmMail,mBusTransactionMail, mDateString:String;
 mSQL:String;
 mIIBO, mTextBO:TNxCustomBusinessObject;
 mIIRow, mUPRows:TNxCustomBusinessMonikerCollection;
 mBusTransaction_ID, mDivision_ID:String;
 i,j :Integer;
 fName,mMail7dny, mText_ID,fName2:String;
 mIDList, mIDList2:TStringList;
 mUPBo, mUPRowBO:TNxCustomBusinessObject;
begin
  mDateString:=IntToStr(trunc(Now-14));
  mIIList:=TStringList.Create;
  try
     //mSQL:='Select id from issuedinvoices where amount-paidamount>0 and x_excluded=''N'' and duedate$date=''%s'' ';
     mSQL:='Select ii.id from issuedinvoices ii left join firms f on f.id=ii.firm_id where ii.amount-ii.paidamount-ii.creditamount>0 and ii.duedate$date=''%s'' ';
      OS.SQLSelect(Format(mSQL, [mDateString]), mIIList);
      if mIIList.Count>0 then begin
      for i:=0 to mIIList.count-1 do begin
         mIDList:=TStringList.Create;
         mIDlist2:=TStringList.Create;
         mDivision_ID:='';
         mBusTransactionMail:='';
         mBusTransaction_ID:='';
         mIIBO:= OS.CreateObject(Class_IssuedInvoice);
         mTextBO:=OS.CreateObject('DCHDUXZ0S3RO1DVWDVB0PD51U0');
         mText_ID:=scrText(OS,mCode14);
         if not(NxIsEmptyOID(mText_ID)) then begin
          mTextBO.Load(mText_ID,nil);
          mMail7dny:=mTextBO.GetFieldValueAsString('X_note');
         end;
         mIIBO.Load(mIIList.Strings[i],nil);
         mIDList.Append(mIIBO.OID);
         mFirmMail:=mIIBO.GetFieldValueAsString('Firm_ID.ElectronicAddress_ID.Email');
         mIIRow:=mIIBO.GetLoadedCollectionMonikerForFieldCode(miibo.GetFieldCode('Rows'));
         for j:=0 to mIIRow.Count-1 do begin
           //if NxIsBlank(mBusTransactionMail) then mBusTransactionMail:= mIIRow.BusinessObject[j].GetFieldValueAsString('BusTransaction_id.U_Email');
           if NxIsEmptyOID(mDivision_ID) then mDivision_ID := mIIRow.BusinessObject[j].GetFieldValueAsString('Division_id');
           if NxIsEmptyOID(mBusTransaction_ID) then mBusTransaction_ID:= mIIRow.BusinessObject[j].GetFieldValueAsString('BusTransaction_ID');
         end;
        { //generovani upominky
          try
             mUPBo:=os.CreateObject(Class_PaymentReminder);
             mUPBo.New;
             mupbo.Prefill;
             mupbo.SetFieldValueAsString('IssuedInvoice_ID',miibo.OID);
             mUPBo.SetFieldValueAsString('Firm_ID',miibo.GetFieldValueAsString('Firm_ID'));
             mUPBo.SetFieldValueAsString('Currency_ID',mIIBO.GetFieldValueAsString('Currency_ID'));
             mupbo.SetFieldValueAsString('DocQueue_ID','4200000101');
             mUPbo.SetFieldValueAsInteger('DocOrder',2);
             mUPBo.SetFieldValueAsString('CreatedBy_ID','2D00000101');
             //mupBO.SetFieldValueAsFloat('PenaltyPercent',0);
             mUPRows:=mUPBo.GetLoadedCollectionMonikerForFieldCode(mupbo.GetFieldCode('Rows'));
             mUPRowBO:=mUPRows.AddNewObject;
             mUpRowBo.Prefill;
             mUProwbo.SetFieldValueAsString('Division_ID',mDivision_ID);
             mUProwbo.setfieldvalueasString('Text','Upomínka faktury '+miibo.DisplayName);
             mUPRowBO.SetFieldValueAsFloat('AmountInvoice',mIIBO.GetFieldValueAsFloat('amount'));
             mUProwbo.SetFieldValueAsDateTime('DatePenaltyFrom$DATE', miibo.GetFieldValueAsDateTime('duedate$date'));
             mUProwbo.SetFieldValueAsDateTime('DatePenaltyTo$DATE', Date);
             mupbo.save;
             fname2:=NxSearchReplace(mUPBO.DisplayName,'/','-',[srall])+'.pdf';
             mIDList2.Add(mUPBo.OID);
             mupbo.free;
          finally

          end;
         //konec generovani upo }
         fname:=NxSearchReplace(mIIBO.DisplayName,'/','-',[srall])+'.pdf';
         CFxReportManager.PrintByIDs(NxCreateContext_1(mIIBO),mIDList,'40SBPEINEFD13ACM03KIU0CLP4','1Q00000101',rtoFile,pekPDF,NxGetTempDir,fName);
         CFxReportManager.PrintByIDs(NxCreateContext_1(mIIBO),mIDList2,'ZIGJSEDS3Q3OH0QFH0CQ3KMUZ0','6900000001',rtoFile,pekPDF,NxGetTempDir,fName2);
         if NxIsValidEMail(mFirmMail,false) then
         SendInternalMail(OS, mFirmMail,'','',
                         'Neuhrazená faktura '+miibo.DisplayName+ ' VS:'+miibo.GetFieldValueAsString('VarSymbol'),mMail7dny,
                         NxGetTempDir+'\'+fName,NxGetTempDir+'\'+fName2,mIIBO.GetFieldValueAsString('Firm_ID'),mDivision_ID,mBusTransaction_ID);

         LogInfoStr:=LogInfoStr+ mIIBO.GetFieldValueAsString('Firm_ID.name')+' '+mBusTransactionMail+Chr(10)+Chr(13);
         mIIBO.free;
         mIDList.free;
         mIDList2.Free;
      end;
     end;
  finally
   mIIList.Free;
  end;
  Success := True;
  //LogInfoStr

end;

procedure GenMail28 (OS: TNxCustomObjectSpace;
  var Success: Boolean; var LogInfoStr: String);

var
 mIIList:TStringList;
 mFirmMail,mBusTransactionMail, mDateString:String;
 mSQL:String;
 mIIBO, mTextBO:TNxCustomBusinessObject;
 mIIRow, mUPRows:TNxCustomBusinessMonikerCollection;
 mBusTransaction_ID, mDivision_ID:String;
 i,j :Integer;
 fName,mMail7dny, mText_ID,fName2:String;
 mIDList, mIDList2:TStringList;
 mUPBo, mUPRowBO:TNxCustomBusinessObject;
begin
  mDateString:=IntToStr(trunc(Now-28));
  mIIList:=TStringList.Create;
  try
     //mSQL:='Select id from issuedinvoices where amount-paidamount>0 and x_excluded=''N'' and duedate$date=''%s'' ';
     mSQL:='Select ii.id from issuedinvoices ii left join firms f on f.id=ii.firm_id where ii.amount-ii.paidamount-ii.creditamount>0 and ii.duedate$date=''%s'' ';
      OS.SQLSelect(Format(mSQL, [mDateString]), mIIList);
      if mIIList.Count>0 then begin
      for i:=0 to mIIList.count-1 do begin
         mIDList:=TStringList.Create;
         mIDlist2:=TStringList.Create;
         mDivision_ID:='';
         mBusTransactionMail:='';
         mBusTransaction_ID:='';
         mIIBO:= OS.CreateObject(Class_IssuedInvoice);
         mTextBO:=OS.CreateObject('DCHDUXZ0S3RO1DVWDVB0PD51U0');
         mText_ID:=scrText(OS,mCode28);
         if not(NxIsEmptyOID(mText_ID)) then begin
          mTextBO.Load(mText_ID,nil);
          mMail7dny:=mTextBO.GetFieldValueAsString('X_note');
         end;
         mIIBO.Load(mIIList.Strings[i],nil);
         mIDList.Append(mIIBO.OID);
         mFirmMail:=mIIBO.GetFieldValueAsString('Firm_ID.ElectronicAddress_ID.Email');
         mIIRow:=mIIBO.GetLoadedCollectionMonikerForFieldCode(miibo.GetFieldCode('Rows'));
         for j:=0 to mIIRow.Count-1 do begin
           //if NxIsBlank(mBusTransactionMail) then mBusTransactionMail:= mIIRow.BusinessObject[j].GetFieldValueAsString('BusTransaction_id.U_Email');
           if NxIsEmptyOID(mDivision_ID) then mDivision_ID := mIIRow.BusinessObject[j].GetFieldValueAsString('Division_id');
           if NxIsEmptyOID(mBusTransaction_ID) then mBusTransaction_ID:= mIIRow.BusinessObject[j].GetFieldValueAsString('BusTransaction_ID');
         end;
        { //generovani upominky
          try
             mUPBo:=os.CreateObject(Class_PaymentReminder);
             mUPBo.New;
             mupbo.Prefill;
             mupbo.SetFieldValueAsString('IssuedInvoice_ID',miibo.OID);
             mUPBo.SetFieldValueAsString('Firm_ID',miibo.GetFieldValueAsString('Firm_ID'));
             mUPBo.SetFieldValueAsString('Currency_ID',mIIBO.GetFieldValueAsString('Currency_ID'));
             mupbo.SetFieldValueAsString('DocQueue_ID','4200000101');
             mUPbo.SetFieldValueAsInteger('DocOrder',3);
             mUPBo.SetFieldValueAsString('CreatedBy_ID','2D00000101');
             //mupBO.SetFieldValueAsFloat('PenaltyPercent',0);
             mUPRows:=mUPBo.GetLoadedCollectionMonikerForFieldCode(mupbo.GetFieldCode('Rows'));
             mUPRowBO:=mUPRows.AddNewObject;
             mUpRowBo.Prefill;
             mUProwbo.SetFieldValueAsString('Division_ID',mDivision_ID);
             mUProwbo.setfieldvalueasString('Text','Upomínka faktury '+miibo.DisplayName);
             mUPRowBO.SetFieldValueAsFloat('AmountInvoice',mIIBO.GetFieldValueAsFloat('amount'));
             mUProwbo.SetFieldValueAsDateTime('DatePenaltyFrom$DATE', miibo.GetFieldValueAsDateTime('duedate$date'));
             mUProwbo.SetFieldValueAsDateTime('DatePenaltyTo$DATE', Date);
             mupbo.save;
             fname2:=NxSearchReplace(mUPBO.DisplayName,'/','-',[srall])+'.pdf';
             mIDList2.Add(mUPBo.OID);
             mupbo.free;
          finally

          end;
         //konec generovani upo   }
         fname:=NxSearchReplace(mIIBO.DisplayName,'/','-',[srall])+'.pdf';
         CFxReportManager.PrintByIDs(NxCreateContext_1(mIIBO),mIDList,'40SBPEINEFD13ACM03KIU0CLP4','1Q00000101',rtoFile,pekPDF,NxGetTempDir,fName);
         CFxReportManager.PrintByIDs(NxCreateContext_1(mIIBO),mIDList2,'ZIGJSEDS3Q3OH0QFH0CQ3KMUZ0','6900000001',rtoFile,pekPDF,NxGetTempDir,fName2);
         if NxIsValidEMail(mFirmMail,false) then
         SendInternalMail(OS, mFirmMail,'','',
                         'Neuhrazená faktura '+miibo.DisplayName+ ' VS:'+miibo.GetFieldValueAsString('VarSymbol'),mMail7dny,
                         NxGetTempDir+'\'+fName,NxGetTempDir+'\'+fName2,mIIBO.GetFieldValueAsString('Firm_ID'),mDivision_ID,mBusTransaction_ID);

         LogInfoStr:=LogInfoStr+ mIIBO.GetFieldValueAsString('Firm_ID.name')+' '+mBusTransactionMail+Chr(10)+Chr(13);
         mIIBO.free;
         mIDList.free;
         mIDList2.Free;
      end;
     end;
  finally
   mIIList.Free;
  end;
  Success := True;
  //LogInfoStr

end;

begin
end.