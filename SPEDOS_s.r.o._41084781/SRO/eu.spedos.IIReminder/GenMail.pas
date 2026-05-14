uses 'eu.spedos.IIReminder.fce';
const
 mCode00='F00';
 mCode07='F07';
 mCode14='F14';
 mCode02Z='Z21';
 mCode07Z='Z07';
 mCode14Z='Z14';
procedure GenMail00 (OS: TNxCustomObjectSpace;
  var Success: Boolean; var LogInfoStr: String);

var
 mIIList:TStringList;
 mFirmMail,mDivisionMail, mDateString, mReplyTo, mReminderEmail:String;
 mSQL:String;
 mIIBO, mTextBO:TNxCustomBusinessObject;
 mIIRow:TNxCustomBusinessMonikerCollection;
 mBusOrder_id, mDivision_ID:String;
 i,j :Integer;
 fName, mText_ID:String;
 mIDList:TStringList;
 mMailText, mMena:string;
begin
  mDateString:=IntToStr(trunc(Now-3));   //Počet dní po splatnosti
  mIIList:=TStringList.Create;
  try
     mSQL:='Select i.id from issuedinvoices i left join firms f on f.id=i.firm_id where i.amount-i.paidamount>0 and not(i.amount=i.creditamount) and f.X_ExcludeReminder=''N'' and i.x_excluded=''N'' and i.duedate$date=''%s'' ';
      OS.SQLSelect(Format(mSQL, [mDateString]), mIIList);
      if mIIList.Count>0 then begin
      for i:=0 to mIIList.count-1 do begin
         mIDList:=TStringList.Create;
         mDivision_ID:='';
         mDivisionMail:='';
         mBusOrder_id:='';
         mReminderEmail:='Prázdný';
         mIIBO:= OS.CreateObject(Class_IssuedInvoice);
         mTextBO:=OS.CreateObject('DCHDUXZ0S3RO1DVWDVB0PD51U0');
         mText_ID:=scrText(OS,'F00'); // kód textu emailu z číselníků texty emailu
         if not(NxIsEmptyOID(mText_ID)) then begin
          mTextBO.Load(mText_ID,nil);
          mMailText:=mTextBO.GetFieldValueAsString('X_note');
         end;
         mIIBO.Load(mIIList.Strings[i],nil);
           if (mIIBO.GetFieldValueAsFloat('Amount')-mIIBO.GetFieldValueAsFloat('PaidAmount'))>(0.1*mIIBO.GetFieldValueAsFloat('Amount')) then begin
               if mIIBO.GetFieldValueAsString('Currency_ID.Code')='CZK' then mMena:='Kč' else mMena:=mIIBO.GetFieldValueAsString('Currency_ID.Code');
               mMailText:=NxSearchReplace(mMailText,'#CISLOFAKTURY#',mIIBO.DisplayName,[srAll]);
               mMailText:=NxSearchReplace(mMailText,'#VARSYMBOL#',mIIBO.GetFieldValueAsString('VarSymbol'),[srAll]);
               mMailText:=NxSearchReplace(mMailText,'#DATUMVYSTAVENI#',DateToStr(mIIBO.GetFieldValueAsDateTime('DocDate$Date')),[srAll]);
               mMailText:=NxSearchReplace(mMailText,'#DATUMSPLATNOSTI#',DateToStr(mIIBO.GetFieldValueAsDateTime('DueDate$Date')),[srAll]);
               mMailText:=NxSearchReplace(mMailText,'#CASTKA_MENA#',NxFormatNumeric('0,00,',mIIBO.GetFieldValueAsFloat('Amount'))+' '+mMena,[srAll]);
               mMailText:=NxSearchReplace(mMailText,'#NEHRAZENACASTKA#',NxFormatNumeric('0,00,',mIIBO.GetFieldValueAsFloat('Amount')-mIIBO.GetFieldValueAsFloat('PaidAmount'))+' '+mMena,[srAll]);
               //if NxIsValidEMail(mIIBO.GetFieldValueAsString('Firm_ID.U_EmailReminder'),false) then mReminderEmail:=mIIBO.GetFieldValueAsString('Firm_ID.U_EmailReminder');
               mIDList.Append(mIIBO.OID);
               //mReplyTo:=mIIBO.GetFieldValueAsString('CreatedBy_ID.Address_ID.Email');
               mReplyTo:='juroskova@spedos.cz';
               mFirmMail:=mIIBO.GetFieldValueAsString('Firm_ID.U_EmailReminder');
               //if not(NxIsValidEMail(mFirmMail,false)) then mFirmMail:=mIIBO.GetFieldValueAsString('Firm_ID.U_EmailReminder');
               mIIRow:=mIIBO.GetLoadedCollectionMonikerForFieldCode(miibo.GetFieldCode('Rows'));
               for j:=0 to mIIRow.Count-1 do begin
                 if NxIsBlank(mDivisionMail) then mDivisionMail:= 'bacak@spedos.cz';
                 if NxIsEmptyOID(mDivision_ID) then mDivision_ID := mIIRow.BusinessObject[j].GetFieldValueAsString('Division_id');
                 if NxIsEmptyOID(mBusOrder_id) then mBusOrder_id:= mIIRow.BusinessObject[j].GetFieldValueAsString('BusOrder_ID');
               end;
               if mIIBO.GetFieldValueAsBoolean('X_Archiv') then fName:='\\192.168.0.80\abradata\Archiv\SRO\'+mIIBO.GetFieldValueAsString('Period_ID.Code')+'\'+mIIBO.GetFieldValueAsString('DocQueue_ID.Code')+'\'+Inttostr(mIIBO.GetFieldValueAsInteger('Ordnumber'))+'_'+mIIBO.GetFieldValueAsString('Docqueue_id.code')+'_'+mIIBO.GetFieldValueAsString('Period_id.code')+'_'+mIIBO.GetFieldValueAsString('varsymbol')+'.pdf';
               SendInternalMail(OS, mFirmMail,'juroskova@spedos.cz',
                               'Neuhrazená faktura '+miibo.DisplayName,mMailText,
                               fName,mIIBO.GetFieldValueAsString('Firm_ID'),mDivision_ID,mBusOrder_id, mReplyTo);
               LogInfoStr:=LogInfoStr+ mIIBO.GetFieldValueAsString('Firm_ID.name')+' '+mDivisionMail+' email pro upomínky '+mFirmMail+Chr(10)+Chr(13);
           end;
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


procedure GenMail01 (OS: TNxCustomObjectSpace;
  var Success: Boolean; var LogInfoStr: String);

var
 mIIList:TStringList;
 mFirmMail,mDivisionMail, mDateString, mReplyTo, mReminderEmail:String;
 mSQL:String;
 mIIBO, mTextBO:TNxCustomBusinessObject;
 mIIRow:TNxCustomBusinessMonikerCollection;
 mBusOrder_id, mDivision_ID:String;
 i,j :Integer;
 fName, mText_ID:String;
 mIDList:TStringList;
 mMailText, mMena:string;
begin
  mDateString:=IntToStr(trunc(Now-12));   //Počet dní po splatnosti
  mIIList:=TStringList.Create;
  try
     mSQL:='Select i.id from issuedinvoices i left join firms f on f.id=i.firm_id where i.amount-i.paidamount>0 and not(i.amount=i.creditamount) and f.X_ExcludeReminder=''N'' and i.x_excluded=''N'' and i.duedate$date=''%s'' ';
      OS.SQLSelect(Format(mSQL, [mDateString]), mIIList);
      if mIIList.Count>0 then begin
      for i:=0 to mIIList.count-1 do begin
         mIDList:=TStringList.Create;
         mDivision_ID:='';
         mDivisionMail:='';
         mBusOrder_id:='';
         mReminderEmail:='Prázdný';
         mIIBO:= OS.CreateObject(Class_IssuedInvoice);
         mTextBO:=OS.CreateObject('DCHDUXZ0S3RO1DVWDVB0PD51U0');
         mText_ID:=scrText(OS,'F12');      // kód textu emailu z číselníků texty emailu
         if not(NxIsEmptyOID(mText_ID)) then begin
          mTextBO.Load(mText_ID,nil);
          mMailText:=mTextBO.GetFieldValueAsString('X_note');
         end;
         mIIBO.Load(mIIList.Strings[i],nil);
           if (mIIBO.GetFieldValueAsFloat('Amount')-mIIBO.GetFieldValueAsFloat('PaidAmount'))>(0.1*mIIBO.GetFieldValueAsFloat('Amount')) then begin
               if mIIBO.GetFieldValueAsString('Currency_ID.Code')='CZK' then mMena:='Kč' else mMena:=mIIBO.GetFieldValueAsString('Currency_ID.Code');
               mMailText:=NxSearchReplace(mMailText,'#CISLOFAKTURY#',mIIBO.DisplayName,[srAll]);
               mMailText:=NxSearchReplace(mMailText,'#VARSYMBOL#',mIIBO.GetFieldValueAsString('VarSymbol'),[srAll]);
               mMailText:=NxSearchReplace(mMailText,'#DATUMVYSTAVENI#',DateToStr(mIIBO.GetFieldValueAsDateTime('DocDate$Date')),[srAll]);
               mMailText:=NxSearchReplace(mMailText,'#DATUMSPLATNOSTI#',DateToStr(mIIBO.GetFieldValueAsDateTime('DueDate$Date')),[srAll]);
               mMailText:=NxSearchReplace(mMailText,'#CASTKA_MENA#',NxFormatNumeric('0,00,',mIIBO.GetFieldValueAsFloat('Amount'))+' '+mMena,[srAll]);
               mMailText:=NxSearchReplace(mMailText,'#NEHRAZENACASTKA#',NxFormatNumeric('0,00,',mIIBO.GetFieldValueAsFloat('Amount')-mIIBO.GetFieldValueAsFloat('PaidAmount'))+' '+mMena,[srAll]);
               //if NxIsValidEMail(mIIBO.GetFieldValueAsString('Firm_ID.U_EmailReminder'),false) then mReminderEmail:=mIIBO.GetFieldValueAsString('Firm_ID.U_EmailReminder');
               mIDList.Append(mIIBO.OID);
                mReplyTo:='juroskova@spedos.cz';
               mFirmMail:=mIIBO.GetFieldValueAsString('Firm_ID.U_EmailReminder');
               //if not(NxIsValidEMail(mFirmMail,false)) then mFirmMail:=mIIBO.GetFieldValueAsString('Firm_ID.U_EmailReminder');
               mIIRow:=mIIBO.GetLoadedCollectionMonikerForFieldCode(miibo.GetFieldCode('Rows'));
               for j:=0 to mIIRow.Count-1 do begin
                 if NxIsBlank(mDivisionMail) then mDivisionMail:= 'bacak@spedos.cz';
                 if NxIsEmptyOID(mDivision_ID) then mDivision_ID := mIIRow.BusinessObject[j].GetFieldValueAsString('Division_id');
                 if NxIsEmptyOID(mBusOrder_id) then mBusOrder_id:= mIIRow.BusinessObject[j].GetFieldValueAsString('BusOrder_ID');
               end;
               if mIIBO.GetFieldValueAsBoolean('X_Archiv') then fName:='\\192.168.0.80\abradata\Archiv\SRO\'+mIIBO.GetFieldValueAsString('Period_ID.Code')+'\'+mIIBO.GetFieldValueAsString('DocQueue_ID.Code')+'\'+Inttostr(mIIBO.GetFieldValueAsInteger('Ordnumber'))+'_'+mIIBO.GetFieldValueAsString('Docqueue_id.code')+'_'+mIIBO.GetFieldValueAsString('Period_id.code')+'_'+mIIBO.GetFieldValueAsString('varsymbol')+'.pdf';
               SendInternalMail(OS, mFirmMail,'juroskova@spedos.cz',
                               'Neuhrazená faktura '+miibo.DisplayName,mMailText,
                               fName,mIIBO.GetFieldValueAsString('Firm_ID'),mDivision_ID,mBusOrder_id, mReplyTo);
               LogInfoStr:=LogInfoStr+ mIIBO.GetFieldValueAsString('Firm_ID.name')+' '+mDivisionMail+' email pro upomínky '+mFirmMail+Chr(10)+Chr(13);
           end;
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


procedure GenMail02 (OS: TNxCustomObjectSpace;
  var Success: Boolean; var LogInfoStr: String);

var
 mIIList:TStringList;
 mFirmMail,mDivisionMail, mDateString, mReplyTo, mReminderEmail:String;
 mSQL:String;
 mIIBO, mTextBO:TNxCustomBusinessObject;
 mIIRow:TNxCustomBusinessMonikerCollection;
 mBusOrder_id, mDivision_ID:String;
 i,j :Integer;
 fName, mText_ID:String;
 mIDList:TStringList;
 mMailText, mMena:string;
begin
  mDateString:=IntToStr(trunc(Now-23));   //Počet dní po splatnosti
  mIIList:=TStringList.Create;
  try
     mSQL:='Select i.id from issuedinvoices i left join firms f on f.id=i.firm_id where i.amount-i.paidamount>0 and not(i.amount=i.creditamount) and f.X_ExcludeReminder=''N'' and i.x_excluded=''N'' and i.duedate$date=''%s'' ';
      OS.SQLSelect(Format(mSQL, [mDateString]), mIIList);
      if mIIList.Count>0 then begin
      for i:=0 to mIIList.count-1 do begin
         mIDList:=TStringList.Create;
         mDivision_ID:='';
         mDivisionMail:='';
         mBusOrder_id:='';
         mReminderEmail:='Prázdný';
         mIIBO:= OS.CreateObject(Class_IssuedInvoice);
         mTextBO:=OS.CreateObject('DCHDUXZ0S3RO1DVWDVB0PD51U0');
         mText_ID:=scrText(OS,'F23');      // kód textu emailu z číselníků texty emailu
         if not(NxIsEmptyOID(mText_ID)) then begin
          mTextBO.Load(mText_ID,nil);
          mMailText:=mTextBO.GetFieldValueAsString('X_note');
         end;
         mIIBO.Load(mIIList.Strings[i],nil);
           if (mIIBO.GetFieldValueAsFloat('Amount')-mIIBO.GetFieldValueAsFloat('PaidAmount'))>(0.1*mIIBO.GetFieldValueAsFloat('Amount')) then begin
               if mIIBO.GetFieldValueAsString('Currency_ID.Code')='CZK' then mMena:='Kč' else mMena:=mIIBO.GetFieldValueAsString('Currency_ID.Code');
               mMailText:=NxSearchReplace(mMailText,'#CISLOFAKTURY#',mIIBO.DisplayName,[srAll]);
               mMailText:=NxSearchReplace(mMailText,'#VARSYMBOL#',mIIBO.GetFieldValueAsString('VarSymbol'),[srAll]);
               mMailText:=NxSearchReplace(mMailText,'#DATUMVYSTAVENI#',DateToStr(mIIBO.GetFieldValueAsDateTime('DocDate$Date')),[srAll]);
               mMailText:=NxSearchReplace(mMailText,'#DATUMSPLATNOSTI#',DateToStr(mIIBO.GetFieldValueAsDateTime('DueDate$Date')),[srAll]);
               mMailText:=NxSearchReplace(mMailText,'#CASTKA_MENA#',NxFormatNumeric('0,00,',mIIBO.GetFieldValueAsFloat('Amount'))+' '+mMena,[srAll]);
               mMailText:=NxSearchReplace(mMailText,'#NEHRAZENACASTKA#',NxFormatNumeric('0,00,',mIIBO.GetFieldValueAsFloat('Amount')-mIIBO.GetFieldValueAsFloat('PaidAmount'))+' '+mMena,[srAll]);
               //if NxIsValidEMail(mIIBO.GetFieldValueAsString('Firm_ID.U_EmailReminder'),false) then mReminderEmail:=mIIBO.GetFieldValueAsString('Firm_ID.U_EmailReminder');
               mIDList.Append(mIIBO.OID);
                mReplyTo:='juroskova@spedos.cz';
               mFirmMail:=mIIBO.GetFieldValueAsString('Firm_ID.U_EmailReminder');
               //if not(NxIsValidEMail(mFirmMail,false)) then mFirmMail:=mIIBO.GetFieldValueAsString('Firm_ID.U_EmailReminder');
               mIIRow:=mIIBO.GetLoadedCollectionMonikerForFieldCode(miibo.GetFieldCode('Rows'));
               for j:=0 to mIIRow.Count-1 do begin
                 if NxIsBlank(mDivisionMail) then mDivisionMail:= 'bacak@spedos.cz';
                 if NxIsEmptyOID(mDivision_ID) then mDivision_ID := mIIRow.BusinessObject[j].GetFieldValueAsString('Division_id');
                 if NxIsEmptyOID(mBusOrder_id) then mBusOrder_id:= mIIRow.BusinessObject[j].GetFieldValueAsString('BusOrder_ID');
               end;
               if mIIBO.GetFieldValueAsBoolean('X_Archiv') then fName:='\\192.168.0.80\abradata\Archiv\SRO\'+mIIBO.GetFieldValueAsString('Period_ID.Code')+'\'+mIIBO.GetFieldValueAsString('DocQueue_ID.Code')+'\'+Inttostr(mIIBO.GetFieldValueAsInteger('Ordnumber'))+'_'+mIIBO.GetFieldValueAsString('Docqueue_id.code')+'_'+mIIBO.GetFieldValueAsString('Period_id.code')+'_'+mIIBO.GetFieldValueAsString('varsymbol')+'.pdf';
               SendInternalMail(OS, mFirmMail,'juroskova@spedos.cz',
                               'Neuhrazená faktura '+miibo.DisplayName,mMailText,
                               fName,mIIBO.GetFieldValueAsString('Firm_ID'),mDivision_ID,mBusOrder_id, mReplyTo);
               LogInfoStr:=LogInfoStr+ mIIBO.GetFieldValueAsString('Firm_ID.name')+' '+mDivisionMail+' email pro upomínky '+mFirmMail+Chr(10)+Chr(13);
           end;
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