procedure ZLVEReminder (OS: TNxCustomObjectSpace;  var Success: Boolean; var LogInfoStr: String);
var
 mList, mPrintList:TStringList;
 mBO, mTextBO:TNxCustomBusinessObject;
 i:integer;
 mMailText, mFileName, mMena, mTO, mAccount_ID, mSubject:string;
begin
  mList:=TStringList.Create;
  OS.SQLSelect('Select i.id from IssuedDInvoices i left join firms f on f.id=i.firm_id where f.X_DoNotRemindZLVE='+QuotedStr('N')+' and i.docqueue_id='+Quotedstr('2920000101')+' and not(i.paymenttype_id='+QuotedStr('6000000101')+') and i.amount>0 and i.paidamount=0 and i.duedate$date='+IntToStr(Trunc(date+2)),mList);
  mTextBO:=OS.CreateObject('DCHDUXZ0S3RO1DVWDVB0PD51U0');
  mTextBO.Load('012B000101',nil);
  mSubject:=mTextBO.GetFieldValueAsString('X_Subject');
  if mlist.Count>0 then begin
      for i:=0 to mlist.count-1 do begin
        mPrintList:=TStringList.create;
        mBO:=Os.CreateObject(Class_IssuedDepositInvoice);
        mMailText:=mTextBO.GetFieldValueAsString('X_Note');
        mBO.Load(mlist.Strings[i],nil);
        mTO:=mBO.GetFieldValueAsString('FirmOffice_ID.Address_ID.Email');
        mPrintList:=TStringList.Create;
        mPrintList.Add(mBO.OID);
        mFileName:=NxSearchReplace(mBO.DisplayName,'/','-',[srAll])+'.pdf';
        mMena:= mBO.GetFieldValueAsString('Currency_ID.Symbol');
        mMailText:= NxSearchReplace(mMailText, '#CISLOZLVE#',    mBO.DisplayName,[srAll]);
        mMailText:= NxSearchReplace(mMailText, '#VARSYMBOL#',       mBO.GetFieldValueAsString('VarSymbol'), [srAll]);
        mMailText:= NxSearchReplace(mMailText, '#DATUMVYSTAVENI#',  DateToStr(mBO.GetFieldValueAsDateTime('DocDate$Date')), [srAll]);
        mMailText:= NxSearchReplace(mMailText, '#DATUMSPLATNOSTI#', DateToStr(mBO.GetFieldValueAsDateTime('DueDate$Date')), [srAll]);
        mMailText:= NxSearchReplace(mMailText, '#CASTKA_MENA#',     NxFormatNumeric('0.00,', mBO.GetFieldValueAsFloat('Amount')) + ' ' + mMena, [srAll]);
        mMailText:= NxSearchReplace(mMailText, '#NEHRAZENACASTKA#', NxFormatNumeric('0.00,', mBO.GetFieldValueAsFloat('Amount') - mBO.GetFieldValueAsFloat('PaidAmount')) + ' ' + mMena,[srAll]);
        CFxReportManager.PrintByIDs(NxCreateContext_1(mBO),mPrintList,GetDynSource(OS,'3O70000101'), '3O70000101',rtoFile,pekPDF,'D:\tmp',mFileName);
        SendInternalMail(OS, mTO,'','martin.bolf@naradi-simon.cz',
                         mSubject+' '+mbo.DisplayName,mMailText,
                         'D:\tmp'+'\'+ mFileName ,'',mbo.GetFieldValueAsString('Firm_ID'),
                         mbo.GetLoadedCollectionMonikerForFieldCode(mbo.GetFieldCode('Rows')).BusinessObject[0].GetFieldValueAsString('Division_ID'),
                         mbo.GetLoadedCollectionMonikerForFieldCode(mbo.GetFieldCode('Rows')).BusinessObject[0].GetFieldValueAsString('BusTransaction_ID'), '1300000101',
                         mbo.GetFieldValueAsString('ReceivedOrder_ID'));
        DeleteFile('D:\tmp'+mFileName);
        mbo.free;
      end;
  end;
  Success := True;
  LogInfoStr := IntToStr(mlist.count);
end;

procedure FVESReminder (OS: TNxCustomObjectSpace;  var Success: Boolean; var LogInfoStr: String);
var
 mList, mPrintList:TStringList;
 mBO, mTextBO, mReceivedOrderBO:TNxCustomBusinessObject;
 i:integer;
 mMailText, mFileName, mMena, mTO, mAccount_ID, mSubject, mReceivedOrder_ID:string;
begin
  mList:=TStringList.Create;
  OS.SQLSelect('Select i.id from IssuedInvoices i left join firms f on f.id=i.firm_id where f.X_ExcludeReminder='+QuotedStr('N')+' and i.transportationtype_id='+QuotedStr('00000O1000')+' and not(i.paymenttype_id='+QuotedStr('6000000101')+') and i.docqueue_id='+Quotedstr('1Z10000101')+' and i.amount>0 and i.paidamount=0 and i.docdate$date='+IntToStr(Trunc(date-4)),mList);
  mTextBO:=OS.CreateObject('DCHDUXZ0S3RO1DVWDVB0PD51U0');
  mTextBO.Load('C0CB000101',nil);
  if mlist.Count>0 then begin
      for i:=0 to mlist.count-1 do begin
        mBO:=Os.CreateObject(Class_IssuedInvoice);
        mMailText:=mTextBO.GetFieldValueAsString('X_Note');
        mSubject:=mTextBO.GetFieldValueAsString('X_Subject');
        mBO.Load(mlist.Strings[i],nil);
        mReceivedOrder_ID:=OS.SQLSelectFirstAsString('select sd2.provide_id from issuedinvoices2 ii2 left join storedocuments2 sd2 on sd2.id=ii2.providerow_id where ii2.parent_id='+QuotedStr(mBO.OID),'');
        mReceivedOrderBO:=OS.CreateObject(Class_ReceivedOrder);
        mReceivedOrderBO.Load(mReceivedOrder_ID,nil);
        mTO:=mBO.GetFieldValueAsString('FirmOffice_ID.Address_ID.Email');
        mFileName:=NxSearchReplace(mReceivedOrderBO.DisplayName,'/','-',[srAll])+'.pdf';
        mMena:= mBO.GetFieldValueAsString('Currency_ID.Symbol');
        mPrintList:=TStringList.Create;
        mPrintList.Add(mReceivedOrderBO.OID);
        mSubject:= NxSearchReplace(mSubject, '#CISOBJ#',    mReceivedOrderBO.GetFieldValueAsString('ExternalNumber'),[srAll]);
        mMailText:= NxSearchReplace(mMailText, '#CISOBJ#',    mReceivedOrderBO.GetFieldValueAsString('ExternalNumber'),[srAll]);
        //mMailText:= NxSearchReplace(mMailText, '#VARSYMBOL#',       mBO.GetFieldValueAsString('VarSymbol'), [srAll]);
        //mMailText:= NxSearchReplace(mMailText, '#DATUMVYSTAVENI#',  DateToStr(mBO.GetFieldValueAsDateTime('DocDate$Date')), [srAll]);
        //mMailText:= NxSearchReplace(mMailText, '#DATUMSPLATNOSTI#', DateToStr(mBO.GetFieldValueAsDateTime('DueDate$Date')), [srAll]);
        //mMailText:= NxSearchReplace(mMailText, '#CASTKA_MENA#',     NxFormatNumeric('0.00,', mBO.GetFieldValueAsFloat('Amount')) + ' ' + mMena, [srAll]);
        //mMailText:= NxSearchReplace(mMailText, '#NEHRAZENACASTKA#', NxFormatNumeric('0.00,', mBO.GetFieldValueAsFloat('Amount') - mBO.GetFieldValueAsFloat('PaidAmount')) + ' ' + mMena,[srAll]);
        CFxReportManager.PrintByIDs(NxCreateContext_1(mBO),mPrintList,GetDynSource(OS,'4VD0000101'), '4VD0000101',rtoFile,pekPDF,'D:\tmp',mFileName);
        SendInternalMail(OS, mTO,'','',
                         mSubject,mMailText,
                         'D:\tmp'+'\'+ mFileName ,'',mbo.GetFieldValueAsString('Firm_ID'),
                         mbo.GetLoadedCollectionMonikerForFieldCode(mbo.GetFieldCode('Rows')).BusinessObject[0].GetFieldValueAsString('Division_ID'),
                         mbo.GetLoadedCollectionMonikerForFieldCode(mbo.GetFieldCode('Rows')).BusinessObject[0].GetFieldValueAsString('BusTransaction_ID'), '1300000101',mReceivedOrder_ID);
        DeleteFile('D:\tmp'+mFileName);
        mbo.free
      end;
  end;
  Success := True;
  LogInfoStr := IntToStr(mlist.count);
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

procedure SendInternalMail(AOS:TNxCustomObjectSpace; ATo:String; ACC:String; ABCC:String;
                           ASubject:String; ABody:String; AAtachement, AAtachement2:String; AFirm_ID:String; ADivision_ID:String; ABusTransaction_ID:String; aAccount_ID, aOrder_ID:string);
Var
  mMailBO, mUserXLink:TNxCustomBusinessObject;
  mMRecipients:TNxCustomBusinessMonikerCollection;
  mMailRecipient:TNxCustomBusinessObject;
begin
  if not(ato='') then begin
     mMailBO:=AOS.CreateObject('5C1HWDQDR3J4NAAYZRO5PWHLWK');
     mMailBO.New;
     mMailBO.Prefill;
     mMailBO.SetFieldValueAsString('EmailAccount_ID',aAccount_ID);
     mMailBO.SetFieldValueAsString('Subject',ASubject);
     mMailBO.SetFieldValueAsString('BodySavedAs','1');
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

     if not(AAtachement2='') then begin
      TNxEmailSent(mMailBO).AttachFile(AAtachement2);

     end;



     mMailBO.Save;
     if not(NxIsEmptyOID(aOrder_ID)) then begin
     mUserXLink := aOS.CreateObject(Class_UserXLink);
      try
        mUserXLink.New;
        mUserXLink.Prefill;
        mUserXLink.SetFieldValueAsString('SourceCLSID', Class_ReceivedOrder);
        mUserXLink.SetFieldValueAsString('Source_ID', aOrder_ID);
        mUserXLink.SetFieldValueAsString('DestinationCLSID', Class_EmailSent);
        mUserXLink.SetFieldValueAsString('Destination_ID', mMailBO.OID);
        mUserXLink.SetFieldValueAsBoolean('DisplayAsSystem', True);
        mUserXLink.SetFieldValueAsString('Description',ASubject);
        mUserXLink.Save;
      finally
        mUserXLink.Free;
      end;
     end;
     mMailBO.free;

  end;
end;

begin
end.