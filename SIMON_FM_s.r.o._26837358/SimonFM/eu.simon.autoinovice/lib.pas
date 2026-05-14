procedure GenerateZLV (OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
Var
 mZLV, mZLVRow, mFirmBO:TNxCustomBusinessObject;
 mRows:TNxCustomBusinessMonikerCollection;
 mForm_ID, mZLV_ID:String;
 mList, mPrintList:TStringList;
 mSQL1,mSQL2, mSQL3, mFileName:String;
 i:Integer;
 mDocList:TStringList;
 mDir:String;
 mCheckResult: integer;
 mCheckResultText: string;
 mCheckResultShortText: string;
 mLastCheckDateTime: TDateTime;
 mMessage:String;
begin
  mForm_ID:='7700000001';
  mSQL1:='select f.ID from userdata ud left join firms f on f.id=ud.id where clsid=''4K3EXM5PQBCL35CH000ILPWJF4'' and stringfieldvalue>0 and fieldcode=2000027 and f.hidden=''N'' and f.firm_id is null ';
  mList:=Tstringlist.Create;
  OS.SQLSelect(mSQL1,mlist);
  mDir:='D:\abragen\ZLV\';
  if mList.Count>0 then begin
    for i:=0 to mlist.Count-1 do begin
      mFirmBO:=OS.CreateObject(Class_Firm);
      mFirmBO.Load(mlist.Strings[i],nil);
      InsolvencyCheck.CheckSubject(mFirmBo,
      '', '', '', 0,
      mCheckResult, mCheckResultText, mCheckResultShortText, mLastCheckDateTime,
      mMessage,
      True);
      mZLV:=OS.CreateObject(Class_IssuedDepositInvoice);
      mZLV.New;
      mZLV.Prefill;
      mZLV.SetFieldValueAsString('DocQueue_ID','2C20000101');
      mZLV.SetFieldValueAsString('Firm_ID',mFirmBO.OID);
      mZLV.SetFieldValueAsDateTime('DueDate$Date',mZLV.GetFieldValueAsDateTime('DocDate$Date')+15);
      mZLV.SetFieldValueAsString('CreatedBy_ID','4000000101');
      mZLV.SetFieldValueAsString('X_VatRate_ID', mFirmBO.GetFieldValueAsString('U_zal1_dph'));
      mrows:=mZLV.GetCollectionMonikerForFieldCode(mZLV.GetFieldCode('Rows'));
      mZLVRow:=mrows.AddNewObject;
      mZLVRow.SetFieldValueAsInteger('RowType',4);
      mZLVRow.SetFieldValueAsString('Text', mFirmBO.GetFieldValueAsString('U_Zal1Text')+ ' '+FormatDateTime('MM/YYYY',Date));
      mZLVRow.SetFieldValueAsString('Division_ID','2600000101');
      mZLVRow.SetFieldValueAsString('BusTransaction_ID','1000000101');
      mZLVRow.SetFieldValueAsFloat('TAmount',mFirmBO.GetFieldValueAsFloat('U_Zal1castka'));
      mZLV.Save;
      mZLV_ID:=mzlv.OID;
        mPrintList:=TStringList.Create;
        mPrintList.add(mZLV.OID);
        mFileName:=NxSearchReplace(mZLV.DisplayName,'/','-',[srAll])+'.pdf';
        CFxReportManager.PrintByIDs(NxCreateContext_1(mZLV),mPrintList,GetDynSource(OS,mForm_ID),mForm_ID,rtoFile,pekPDF,mDir,mFileName);
        mPrintList.Free;
        LogInfoStr := LogInfoStr+mDir+mFileName+#13#10;

      SendInternalMail(OS,mZLV.GetFieldValueAsString('Firm_ID.ResidenceAddress_ID.Email'),'','', 'Zálohový list vydaný ', 'Zálohový list vydaný',mDir+'\'+mFileName, mZLV.GetFieldValueAsString('Firm_ID'),
                   '2600000101','1000000101');
      mZLV.free;
    end;
    mList.Free;
  end;
  mSQL2:='select f.ID from userdata ud left join firms f on f.id=ud.id where clsid=''4K3EXM5PQBCL35CH000ILPWJF4'' and stringfieldvalue>0 and fieldcode=2000028 and f.hidden=''N'' and f.firm_id is null ';
  mList:=Tstringlist.Create;
  OS.SQLSelect(mSQL2,mlist);
  if mList.Count>0 then begin
    for i:=0 to mlist.Count-1 do begin
      mFirmBO:=OS.CreateObject(Class_Firm);
      mFirmBO.Load(mlist.Strings[i],nil);
      InsolvencyCheck.CheckSubject(mFirmBO,
      '', '', '', 0,
      mCheckResult, mCheckResultText, mCheckResultShortText, mLastCheckDateTime,
      mMessage,
      True);
      mZLV:=OS.CreateObject(Class_IssuedDepositInvoice);
      mZLV.New;
      mZLV.Prefill;
      mZLV.SetFieldValueAsString('DocQueue_ID','2C20000101');
      mZLV.SetFieldValueAsString('Firm_ID',mFirmBO.OID);
      mZLV.SetFieldValueAsDateTime('DueDate$Date',mZLV.GetFieldValueAsDateTime('DocDate$Date')+15);
      mZLV.SetFieldValueAsString('CreatedBy_ID','4000000101');
      mZLV.SetFieldValueAsString('X_VatRate_ID', mFirmBO.GetFieldValueAsString('U_zal2_dph'));
      mrows:=mZLV.GetCollectionMonikerForFieldCode(mZLV.GetFieldCode('Rows'));
      mZLVRow:=mrows.AddNewObject;
      mZLVRow.SetFieldValueAsInteger('RowType',4);
      mZLVRow.SetFieldValueAsString('Text', mFirmBO.GetFieldValueAsString('U_Zal2Text')+ ' '+FormatDateTime('MM/YYYY',Date));
      mZLVRow.SetFieldValueAsString('Division_ID','2600000101');
      mZLVRow.SetFieldValueAsString('BusTransaction_ID','1000000101');
      mZLVRow.SetFieldValueAsFloat('TAmount',mFirmBO.GetFieldValueAsFloat('U_Zal2castka'));
      mZLV.Save;
      mZLV_ID:=mzlv.OID;
        mPrintList:=TStringList.Create;
        mPrintList.add(mZLV.OID);
        mFileName:=NxSearchReplace(mZLV.DisplayName,'/','-',[srAll])+'.pdf';
        CFxReportManager.PrintByIDs(NxCreateContext_1(mZLV),mPrintList,GetDynSource(OS,mForm_ID),mForm_ID,rtoFile,pekPDF,mDir,mFileName);
        mPrintList.free;
        LogInfoStr := LogInfoStr+mDir+mFileName+#13#10;
      SendInternalMail(OS,mZLV.GetFieldValueAsString('Firm_ID.ResidenceAddress_ID.Email'),'','', 'Zálohový list vydaný ', 'Zálohový list vydaný',mDir+'\'+mFileName, mZLV.GetFieldValueAsString('Firm_ID'),
                   '2600000101','1000000101');
      mZLV.free;
    end;
    mList.Free;
  end;
  mSQL3:='select f.ID from userdata ud left join firms f on f.id=ud.id where clsid=''4K3EXM5PQBCL35CH000ILPWJF4'' and stringfieldvalue>0 and fieldcode=2000029 and f.hidden=''N'' and f.firm_id is null ';
  mList:=Tstringlist.Create;
  OS.SQLSelect(mSQL3,mlist);
  if mList.Count>0 then begin
    for i:=0 to mlist.Count-1 do begin
      mFirmBO:=OS.CreateObject(Class_Firm);
      mFirmBO.Load(mlist.Strings[i],nil);
      InsolvencyCheck.CheckSubject(mFirmBO,
      '', '', '', 0,
      mCheckResult, mCheckResultText, mCheckResultShortText, mLastCheckDateTime,
      mMessage,
      True);
      mZLV:=OS.CreateObject(Class_IssuedDepositInvoice);
      mZLV.New;
      mZLV.Prefill;
      mZLV.SetFieldValueAsString('DocQueue_ID','2C20000101');
      mZLV.SetFieldValueAsString('Firm_ID',mFirmBO.OID);
      mZLV.SetFieldValueAsDateTime('DueDate$Date',mZLV.GetFieldValueAsDateTime('DocDate$Date')+15);
      mZLV.SetFieldValueAsString('CreatedBy_ID','4000000101');
      mZLV.SetFieldValueAsString('X_VatRate_ID', mFirmBO.GetFieldValueAsString('U_zal3_dph'));
      mrows:=mZLV.GetCollectionMonikerForFieldCode(mZLV.GetFieldCode('Rows'));
      mZLVRow:=mrows.AddNewObject;
      mZLVRow.SetFieldValueAsInteger('RowType',4);
      mZLVRow.SetFieldValueAsString('Text', mFirmBO.GetFieldValueAsString('U_Zal3Text')+ ' '+FormatDateTime('MM/YYYY',Date));
      mZLVRow.SetFieldValueAsString('Division_ID','2600000101');
      mZLVRow.SetFieldValueAsString('BusTransaction_ID','1000000101');
      mZLVRow.SetFieldValueAsFloat('TAmount',mFirmBO.GetFieldValueAsFloat('U_Zal3castka'));
      mZLV.Save;
      mZLV_ID:=mzlv.OID;
        mPrintList:=TStringList.Create;
        mPrintList.add(mZLV.OID);
        mFileName:=NxSearchReplace(mZLV.DisplayName,'/','-',[srAll])+'.pdf';
        CFxReportManager.PrintByIDs(NxCreateContext_1(mZLV),mPrintList,GetDynSource(OS,mForm_ID),mForm_ID,rtoFile,pekPDF,mDir,mFileName);
        mPrintList.Free;
        LogInfoStr := LogInfoStr+mDir+mFileName+#13#10;
      SendInternalMail(OS,mZLV.GetFieldValueAsString('Firm_ID.ResidenceAddress_ID.Email'),'','', 'Zálohový list vydaný ', 'Zálohový list vydaný',mDir+'\'+mFileName, mZLV.GetFieldValueAsString('Firm_ID'),
                   '2600000101','1000000101');
      mZLV.free;
    end;
    mList.Free;
  end;
  Success := True;

end;





procedure SendInternalMail(var AOS:TNxCustomObjectSpace;var ATo:String;var ACC:String;var ABCC:String;
                           var ASubject:String;var ABody:String;var AAtachement:String;var AFirm_ID:String;var ADivision_ID:String;var ABusTransaction_ID:String);
Var
  mMailBO:TNxCustomBusinessObject;
  mMRecipients:TNxCustomBusinessMonikerCollection;
  mMailRecipient:TNxCustomBusinessObject;
begin
  if not(ato='') then begin
     mMailBO:=AOS.CreateObject('5C1HWDQDR3J4NAAYZRO5PWHLWK');
     mMailBO.New;
     mMailBO.Prefill;
     mMailBO.SetFieldValueAsString('EmailAccount_ID','1000000101');
     mMailBO.SetFieldValueAsString('Subject',ASubject);
     mMailbo.SetFieldValueAsInteger('SentState',1);
     mMailBO.SetFieldValueAsString('Body',ABody);
     mMailBO.SetFieldValueAsString('Firm_ID',AFirm_ID);
     mMailBO.SetFieldValueAsString('Division_ID',ADivision_ID);
     mMailBO.SetFieldValueAsString('BusTransaction_ID',ABusTransaction_ID);
     mMRecipients:=mMailBO.GetCollectionMonikerForFieldCode(mMailBO.GetFieldCode('Recipients'));

     mMailRecipient:=mMRecipients.AddNewObject;
     mMailRecipient.SetFieldValueAsString('Email',ATo);
     mMailRecipient.SetFieldValueAsInteger('EmailType',0);
     if not(acc='') then begin
     mMailRecipient:=mMRecipients.AddNewObject;
     mMailRecipient.SetFieldValueAsString('Email',ACC);
     mMailRecipient.SetFieldValueAsInteger('EmailType',1);
     end;
     if not(ABCC='') then begin
     mMailRecipient:=mMRecipients.AddNewObject;
     mMailRecipient.SetFieldValueAsString('Email',ABCC);
     mMailRecipient.SetFieldValueAsInteger('EmailType',2);
     end;

     if not(AAtachement='') then begin
      TNxEmailSent(mMailBO).AttachFile(AAtachement);

     end;



     mMailBO.Save;
     mMailBO.free;

  end;
end;

procedure GenerateDZV(OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
var
 mList, mPrintList:TStringList;
 mZLVBO,mDZVBO:TNxCustomBusinessObject;
 i:integer;
 mDZV_ID, mFileName, mDir:string;
begin
  mList:=TStringList.Create;
  OS.SQLSelect('SELECT A.ID FROM IssuedDInvoices A WHERE (A.DocQueue_ID = '+QuotedStr('2C20000101')+') AND ((A.PaidAmount - A.UsedAmount) > 0 ) AND (a.X_VatRate_ID is not null) ',mList);
  if mList.count>0 then begin
    for i:=0 to mList.count-1 do begin
      mZLVBO:=os.CreateObject(Class_IssuedDepositInvoice);
      mZLVBO.Load(mList.strings[i],nil);
      mDZV_ID:=CreateDocDZL(mZLVBO, mZLVBO.GetFieldValueAsFloat('PaidAmount')- mZLVBO.GetFieldValueAsFloat('UsedAmount'), mZLVBO.GetFieldValueAsString('X_VatRate_ID'), Date);
      if not(NxIsEmptyOID(mDZV_ID)) then begin
          mDir:='D:\abragen\ZLV';
          mPrintList:=TStringList.create;
          mDZVBO:=OS.CreateObject(Class_VATIssuedDepositInvoice);
          mDZVBO.Load(mDZV_ID,nil);
          mPrintList.add(mDZVBO.OID);
          mFileName:=NxSearchReplace(mDZVBO.DisplayName,'/','-',[srAll])+'.pdf';
          CFxReportManager.PrintByIDs(NxCreateContext_1(mDZVBO),mPrintList,GetDynSource(OS,'FH00000001'),'FH00000001',rtoFile,pekPDF,mDir,mFileName);
          mPrintList.Free;
          LogInfoStr := LogInfoStr+mDir+mFileName+#13#10;
          SendInternalMail(OS,mDZVBO.GetFieldValueAsString('Firm_ID.ResidenceAddress_ID.Email'),'','', 'Daňový zálohový list vydaný '+mDZVBO.DisplayName,
          'Daňový zálohový list vydaný',mDir+'\'+mFileName, mDZVBO.GetFieldValueAsString('Firm_ID'),
                   '2600000101','1000000101');
      end;
      mZLVBO.free;
    end;
  end;
  Success := True;
  //LogInfoStr := '';
end;

procedure GenerateFO(OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
Var
 mFO, mFORow, mFirmBO:TNxCustomBusinessObject;
 mForm_ID, mSQL1, mDir, mFileName:String;
 mList, mPrintList:TStringList;
 mRows:TNxCustomBusinessMonikerCollection;
 i:Integer;
 mCheckResult: integer;
 mCheckResultText, mTO: string;
 mCheckResultShortText: string;
 mLastCheckDateTime: TDateTime;
 mMessage, mDivision_ID:String;
begin
  mForm_ID:='4VE1000101';
  mDivision_ID:='2600000101';
  mSQL1:='select f.ID from firms f where F.X_AutoFV=''A'' and f.hidden=''N'' and f.firm_id is Null ';
  mList:=Tstringlist.Create;
  OS.SQLSelect(mSQL1,mlist);
  mDir:=NxGetTempDir;
  if mList.Count>0 then begin
    for i:=0 to mlist.Count-1 do begin
      mFirmBO:=OS.CreateObject(Class_Firm);
      mFirmBO.Load(mlist.Strings[i],nil);
      InsolvencyCheck.CheckSubject(mFirmBO,
      '', '', '', 0,
      mCheckResult, mCheckResultText, mCheckResultShortText, mLastCheckDateTime,
      mMessage,
      True);
      mFO:=OS.CreateObject(Class_IssuedInvoice);
      mFO.New;
      mFO.Prefill;
      mFO.SetFieldValueAsString('DocQueue_ID',mFirmBO.GetFieldValueAsString('U_FVDQ_ID'));
      if not(NxIsEmptyOID(mFirmBO.GetFieldValueAsString('U_InvoiceDivisionID'))) then mDivision_ID:=mFirmBO.GetFieldValueAsString('U_InvoiceDivisionID');
      mFO.SetFieldValueAsString('Firm_ID',mFirmBO.OID);
      mFO.SetFieldValueAsDateTime('DueDate$Date',mFO.GetFieldValueAsDateTime('DocDate$Date')+15);
      mFO.SetFieldValueAsBoolean('PricesWithVAT',False);
      mFO.SetFieldValueAsString('CreatedBy_ID','4000000101');
      if not(NxIsEmptyOID(mFirmBO.GetFieldValueAsString('X_Currency_ID'))) then begin
       mFO.SetFieldValueAsString('Currency_ID',mFirmBO.GetFieldValueAsString('X_Currency_ID'));
       mFO.SetFieldValueAsString('BankAccount_ID','5100000101');
      end;
      mrows:=mFO.GetCollectionMonikerForFieldCode(mFO.GetFieldCode('Rows'));
      if mFirmBO.GetFieldValueAsFloat('U_fvamount_1')>0 then begin
      mFORow:=mrows.AddNewObject;
      mFORow.SetFieldValueAsInteger('RowType',1);
      mFORow.SetFieldValueAsString('Text',NxSearchReplace(mFirmBO.GetFieldValueAsString('U_fvtext_1'),'#date#',FormatDateTime('MM/YYYY',Date),[srall]));
      mFORow.SetFieldValueAsFloat('TotalPrice',mFirmBO.GetFieldValueAsFloat('U_fvamount_1'));
      mFORow.SetFieldValueAsString('VatRate_ID',mFirmBO.GetFieldValueAsString('U_dph_1'));
      mFORow.SetFieldValueAsString('IncomeType_ID',mFirmBO.GetFieldValueAsString('U_typp1'));
      mFORow.SetFieldValueAsString('Division_ID',mDivision_ID);
      if mFirmBO.GetFieldValueAsString('U_FVDQ_ID.Code')='FV03' then mFORow.SetFieldValueAsString('Division_ID','1000000101');
      mFORow.SetFieldValueAsString('BusTransaction_ID','1000000101');
      end;
      if mFirmBO.GetFieldValueAsFloat('U_fvamount_2')>0 then begin
      mFORow:=mrows.AddNewObject;
      mFORow.SetFieldValueAsInteger('RowType',1);
      mFORow.SetFieldValueAsString('Text',NxSearchReplace(mFirmBO.GetFieldValueAsString('U_fvtext_2'),'#date#',FormatDateTime('MM/YYYY',Date),[srall]));
      mFORow.SetFieldValueAsFloat('TotalPrice',mFirmBO.GetFieldValueAsFloat('U_fvamount_2'));
      mFORow.SetFieldValueAsString('VatRate_ID',mFirmBO.GetFieldValueAsString('U_dph_2'));
      mFORow.SetFieldValueAsString('IncomeType_ID',mFirmBO.GetFieldValueAsString('U_typp2'));
      mFORow.SetFieldValueAsString('Division_ID',mDivision_ID);
      if mFirmBO.GetFieldValueAsString('U_FVDQ_ID.Code')='FV03' then mFORow.SetFieldValueAsString('Division_ID','1000000101');
      mFORow.SetFieldValueAsString('BusTransaction_ID','1000000101');
      end;
      if mFirmBO.GetFieldValueAsFloat('U_fvamount_3')>0 then begin
      mFORow:=mrows.AddNewObject;
      mFORow.SetFieldValueAsInteger('RowType',1);
      mFORow.SetFieldValueAsString('Text',NxSearchReplace(mFirmBO.GetFieldValueAsString('U_fvtext_3'),'#date#',FormatDateTime('MM/YYYY',Date),[srall]));
      mFORow.SetFieldValueAsFloat('TotalPrice',mFirmBO.GetFieldValueAsFloat('U_fvamount_3'));
      mFORow.SetFieldValueAsString('VatRate_ID',mFirmBO.GetFieldValueAsString('U_dph_3'));
      mFORow.SetFieldValueAsString('IncomeType_ID',mFirmBO.GetFieldValueAsString('U_typp3'));
      mFORow.SetFieldValueAsString('Division_ID',mDivision_ID);
      if mFirmBO.GetFieldValueAsString('U_FVDQ_ID.Code')='FV03' then mFORow.SetFieldValueAsString('Division_ID','1000000101');
      mFORow.SetFieldValueAsString('BusTransaction_ID','1000000101');
      end;
      if mFirmBO.GetFieldValueAsFloat('U_fvamount_4')>0 then begin
      mFORow:=mrows.AddNewObject;
      mFORow.SetFieldValueAsInteger('RowType',1);
      mFORow.SetFieldValueAsString('Text',NxSearchReplace(mFirmBO.GetFieldValueAsString('U_fvtext_4'),'#date#',FormatDateTime('MM/YYYY',Date),[srall]));
      mFORow.SetFieldValueAsFloat('TotalPrice',mFirmBO.GetFieldValueAsFloat('U_fvamount_4'));
      mFORow.SetFieldValueAsString('VatRate_ID',mFirmBO.GetFieldValueAsString('U_dph_4'));
      mFORow.SetFieldValueAsString('IncomeType_ID',mFirmBO.GetFieldValueAsString('U_typp4'));
      mFORow.SetFieldValueAsString('Division_ID',mDivision_ID);
      if mFirmBO.GetFieldValueAsString('U_FVDQ_ID.Code')='FV03' then mFORow.SetFieldValueAsString('Division_ID','1000000101');
      mFORow.SetFieldValueAsString('BusTransaction_ID','1000000101');
      end;
      if mFirmBO.GetFieldValueAsFloat('U_fvamount_5')>0 then begin
      mFORow:=mrows.AddNewObject;
      mFORow.SetFieldValueAsInteger('RowType',1);
      mFORow.SetFieldValueAsString('Text',NxSearchReplace(mFirmBO.GetFieldValueAsString('U_fvtext_5'),'#date#',FormatDateTime('MM/YYYY',Date),[srall]));
      mFORow.SetFieldValueAsFloat('TotalPrice',mFirmBO.GetFieldValueAsFloat('U_fvamount_5'));
      mFORow.SetFieldValueAsString('VatRate_ID',mFirmBO.GetFieldValueAsString('U_dph_5'));
      mFORow.SetFieldValueAsString('IncomeType_ID',mFirmBO.GetFieldValueAsString('U_typp5'));
      mFORow.SetFieldValueAsString('Division_ID',mDivision_ID);
      if mFirmBO.GetFieldValueAsString('U_FVDQ_ID.Code')='FV03' then mFORow.SetFieldValueAsString('Division_ID','1000000101');
      mFORow.SetFieldValueAsString('BusTransaction_ID','1000000101');
      end;
      if mFirmBO.GetFieldValueAsFloat('U_fvamount_6')>0 then begin
        mFORow:=mrows.AddNewObject;
        mFORow.SetFieldValueAsInteger('RowType',1);
        mFORow.SetFieldValueAsString('Text',NxSearchReplace(mFirmBO.GetFieldValueAsString('U_fvtext_6'),'#date#',FormatDateTime('MM/YYYY',Date),[srall]));
        mFORow.SetFieldValueAsFloat('TotalPrice',mFirmBO.GetFieldValueAsFloat('U_fvamount_6'));
        mFORow.SetFieldValueAsString('VatRate_ID',mFirmBO.GetFieldValueAsString('U_dph_6'));
        mFORow.SetFieldValueAsString('IncomeType_ID',mFirmBO.GetFieldValueAsString('U_typp6'));
        mFORow.SetFieldValueAsString('Division_ID',mDivision_ID);
        if mFirmBO.GetFieldValueAsString('U_FVDQ_ID.Code')='FV03' then mFORow.SetFieldValueAsString('Division_ID','1000000101');
        mFORow.SetFieldValueAsString('BusTransaction_ID','1000000101');
      end;
      if mFirmBO.GetFieldValueAsFloat('U_fvamount_7')>0 then begin
        mFORow:=mrows.AddNewObject;
        mFORow.SetFieldValueAsInteger('RowType',1);
        mFORow.SetFieldValueAsString('Text',NxSearchReplace(mFirmBO.GetFieldValueAsString('U_fvtext_7'),'#date#',FormatDateTime('MM/YYYY',Date),[srall]));
        mFORow.SetFieldValueAsFloat('TotalPrice',mFirmBO.GetFieldValueAsFloat('U_fvamount_7'));
        mFORow.SetFieldValueAsString('VatRate_ID',mFirmBO.GetFieldValueAsString('U_dph_7'));
        mFORow.SetFieldValueAsString('IncomeType_ID',mFirmBO.GetFieldValueAsString('U_typp7'));
        mFORow.SetFieldValueAsString('Division_ID',mDivision_ID);
        if mFirmBO.GetFieldValueAsString('U_FVDQ_ID.Code')='FV03' then mFORow.SetFieldValueAsString('Division_ID','1000000101');
        mFORow.SetFieldValueAsString('BusTransaction_ID','1000000101');
      end;
      if mFirmBO.GetFieldValueAsFloat('U_fvamount_8')>0 then begin
        mFORow:=mrows.AddNewObject;
        mFORow.SetFieldValueAsInteger('RowType',1);
        mFORow.SetFieldValueAsString('Text',NxSearchReplace(mFirmBO.GetFieldValueAsString('U_fvtext_8'),'#date#',FormatDateTime('MM/YYYY',Date),[srall]));
        mFORow.SetFieldValueAsFloat('TotalPrice',mFirmBO.GetFieldValueAsFloat('U_fvamount_8'));
        mFORow.SetFieldValueAsString('VatRate_ID',mFirmBO.GetFieldValueAsString('U_dph_8'));
        mFORow.SetFieldValueAsString('IncomeType_ID',mFirmBO.GetFieldValueAsString('U_typp8'));
        mFORow.SetFieldValueAsString('Division_ID',mDivision_ID);
        if mFirmBO.GetFieldValueAsString('U_FVDQ_ID.Code')='FV03' then mFORow.SetFieldValueAsString('Division_ID','1000000101');
        mFORow.SetFieldValueAsString('BusTransaction_ID','1000000101');
      end;
      if mFirmBO.GetFieldValueAsFloat('U_fvamount_9')>0 then begin
        mFORow:=mrows.AddNewObject;
        mFORow.SetFieldValueAsInteger('RowType',1);
        mFORow.SetFieldValueAsString('Text',NxSearchReplace(mFirmBO.GetFieldValueAsString('U_fvtext_9'),'#date#',FormatDateTime('MM/YYYY',Date),[srall]));
        mFORow.SetFieldValueAsFloat('TotalPrice',mFirmBO.GetFieldValueAsFloat('U_fvamount_9'));
        mFORow.SetFieldValueAsString('VatRate_ID',mFirmBO.GetFieldValueAsString('U_dph_9'));
        mFORow.SetFieldValueAsString('IncomeType_ID',mFirmBO.GetFieldValueAsString('U_typp9'));
        mFORow.SetFieldValueAsString('Division_ID',mDivision_ID);
        if mFirmBO.GetFieldValueAsString('U_FVDQ_ID.Code')='FV03' then mFORow.SetFieldValueAsString('Division_ID','1000000101');
        mFORow.SetFieldValueAsString('BusTransaction_ID','1000000101');
      end;
      if mFirmBO.GetFieldValueAsFloat('U_fvamount_10')>0 then begin
        mFORow:=mrows.AddNewObject;
        mFORow.SetFieldValueAsInteger('RowType',1);
        mFORow.SetFieldValueAsString('Text',NxSearchReplace(mFirmBO.GetFieldValueAsString('U_fvtext_10'),'#date#',FormatDateTime('MM/YYYY',Date),[srall]));
        mFORow.SetFieldValueAsFloat('TotalPrice',mFirmBO.GetFieldValueAsFloat('U_fvamount_10'));
        mFORow.SetFieldValueAsString('VatRate_ID',mFirmBO.GetFieldValueAsString('U_dph_10'));
        mFORow.SetFieldValueAsString('IncomeType_ID',mFirmBO.GetFieldValueAsString('U_typp10'));
        mFORow.SetFieldValueAsString('Division_ID',mDivision_ID);
        if mFirmBO.GetFieldValueAsString('U_FVDQ_ID.Code')='FV03' then mFORow.SetFieldValueAsString('Division_ID','1000000101');
        mFORow.SetFieldValueAsString('BusTransaction_ID','1000000101');
      end;
      mFO.Save;
        mPrintList:=TStringList.Create;
        mPrintList.add(mFO.OID);
        mFileName:=NxSearchReplace(mFO.DisplayName,'/','-',[srAll])+'.pdf';
        //NxPrintByIDs(NxCreateContext_1(mFO),mPrintList,'40SBPEINEFD13ACM03KIU0CLP4','W400000001',rtoFile,pekPDF,mDir,mFileName);
        CFxReportManager.PrintByIDs(NxCreateContext_1(mFO),mPrintList,GetDynSource(OS,mForm_ID),mForm_ID,rtoFile,pekPDF,mDir,mFileName);
        mPrintList.Free;
        LogInfoStr := LogInfoStr+mDir+mFileName+#13#10;
        mTo:=mFO.GetFieldValueAsString('Firm_ID.ResidenceAddress_ID.Email');
        if not(NxIsValidEMail(mTO,False)) then mTO:='ucetni@simonfm.cz';                              //
        SendInternalMail(OS,mTO,'','', 'Faktura vydaná ', 'Faktura vydaná',mDir+'\'+mFileName, mFO.GetFieldValueAsString('Firm_ID'),
                   mDivision_ID,'1000000101');
      mFO.free;
    end;
    mList.Free;
  end;
  Success := True;

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

Function HledejID(What,Where,When,Alias,Res:string;mOS:TNxCustomObjectSpace):string;
 var
  mResult:TStrings;
  mSQL:String;
 begin
   try
     mResult := TStringList.Create;
     mSQL := 'Select '+ What +' from '+ Where + ' Where '+ When;
      //ShowMessage(mSQL);
      mOS.SQLSelect(mSQL, mResult);
      if (mResult.Count > 0) then begin
        Result:=mResult.Strings[0] ;
      end
      else begin
        Result:=Res;
      end;
    finally
      mResult := Nil;
    end;
end;

Function CreateDocDZL(AZL:TNxCustomBusinessObject; mAMount: double; mVatRate_ID: string; ADate: Double):string;
var mManager : TNxDocumentImportManager ;
  mParams : TNxParameters;
  mRow, mRow_OP, mOP, mUsage : TNxCustomBusinessObject;
  mRows, mRows_OP : TNxCustomBusinessMonikerCollection;
  mDate: TDateTime;
  mRowText, mUsageID, mQuery, mAccID : string;
  mList : TStringList;
begin
  result := '';
  mManager := NxCreateDocumentImportManager(AZL.ObjectSpace,Class_IssuedDepositInvoice,Class_VATIssuedDepositInvoice);
  mParams := TNxParameters.Create();
  //mList := tStringlist.create;
  try
    mRows_OP := AZL.GetLoadedCollectionMonikerForFieldCode(AZL.GetFieldCode('Rows'));
    mRow_OP := mRows_OP.BusinessObject[0];
    OutputDebugString('zálohový list vydaný '+AZL.DisplayName);
    mManager.AddInputDocument(AZL.OID);
    mParams.GetOrCreateParam(dtFloat, 'DepositAmount').AsFloat := mAmount;
    mParams.GetOrCreateParam(dtString, 'DocQueue_ID').AsString := 'B200000101';
    mParams.GetOrCreateParam(dtDateTime, 'VatDate').AsdateTime := mDate;
    mDate := ADate;
    mManager.LoadParams(mParams);
    mManager.Execute;
    mManager.OutputDocument.SetFieldValueAsDateTime('DocDate$DATE', mDate);
    mManager.OutputDocument.SetFieldValueAsDateTime('AccDate$DATE', mDate);
    mManager.OutputDocument.SetFieldValueAsDateTime('VATDate$DATE', mDate);
    mManager.OutputDocument.SetFieldValueAsBoolean('PricesWithVAT', True);
    mManager.OutputDocument.SetFieldValueAsString('Description', NxLeft('Zúčtování '+AZL.DisplayName, 50));
    mManager.OutputDocument.SetFieldValueAsString('CreatedBy_ID','4000000101');
    //JIPE doplněno dohledání období
     mManager.OutputDocument.SetFieldValueAsString('Period_ID',HledejID('ID','periods',
        'datefrom$date<=' + Floattostr(mManager.OutputDocument.GetFieldValueAsDateTime('DocDate$date'))
         + ' and dateto$date > ' + Floattostr(mManager.OutputDocument.GetFieldValueAsDateTime('DocDate$date')),'OID','',AZL.ObjectSpace));

    mRows := mManager.OutputDocument.GetLoadedCollectionMonikerForFieldCode(mManager.OutputDocument.GetFieldCode('Rows'));
    mRow := mRows.AddNewObject;
    mRow.Prefill;
    mRow.SetFieldValueAsInteger('RowType',4);
    mRow.SetFieldValueAsString('Division_ID',mRow_OP.GetFieldValueAsString('Division_ID'));
    mRow.SetFieldValueAsString('BusOrder_ID',mRow_OP.GetFieldValueAsString('BusOrder_ID'));
    mRow.SetFieldValueAsString('BusTransaction_ID',mRow_OP.GetFieldValueAsString('BusTransaction_ID'));
    mRow.SetFieldValueAsString('VATRate_ID',mVatRate_ID);
    mRowText := mRow_OP.GetFieldValueAsString('Text');
    mRow.SetFieldValueAsString('Text',mRowText);
    mRow.SetFieldValueAsFloat('PaymentAmount',mAmount);
    mManager.OutputDocument.Save;
    Result := mManager.OutputDocument.OID;

    // FINE: úprava data zúčtování - nechtějí aktuální den, ale stejné datum jako zdanění
    mUsageID := HledejID('ID', 'IssuedDepositUsages', 'DepositDocument_ID = '+QuotedStr(AZL.OID)+' AND PDocument_ID = '+QuotedStr(mManager.OutputDocument.OID), '', '', AZL.ObjectSpace);
    if (not NxIsEmptyOID(mUsageID)) then begin
      mUsage := AZL.ObjectSpace.CreateObject(Class_IssuedDepositUsage);
      try
        mUsage.Load(mUsageID, nil);
        mUsage.SetFieldValueAsDateTime('PaymentDate$DATE', mDate);
        mUsage.SetFieldValueAsDateTime('AccDate$DATE', mDate);
        mUsage.Save;
      finally
        mUsage.Free;
      end;
      // doklad zúčtování musíme ručně přeúčtovat
      mList := tStringlist.create;
      try
        mList.Add(mUsageID);
       // CFxAccounting.ReAccount(Class_IssuedDepositUsage, mList);
      finally
        mList.Free;
      end;

    end;

  finally
    mManager.Free;
    mOP.Free;
    mParams.free;
    //mList.Free;
  end;
end;

begin
end.