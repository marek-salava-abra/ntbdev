uses 'eu.simon.IIReminder.fce';
procedure GenMail00 (mObjectSpace: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
  var
    mTextList: TStringList;
    k: Integer;
    mTextBO: TNxCustomBusinessObject;
    mDateString: String;
    mIIList: TStringList;
    mSQL: String;
    i: Integer;
    mIDList: TStringList;
    mDivision_ID: String;
    mBusOrder_ID: String;
    mIIBO: TNxCustomBusinessObject;
    mMailText: String;
    mMena: String;
    mReplyTo: String;
    mFirmMail: String;
    mFileName: String;
    mIIRow: TNxCustomBusinessMonikerCollection;
    j: Integer;
    mSubject: String;
    mMail_ID: String;
    mActivityBO: TNxCustomBusinessObject;
    mRelationBO: TNxCustomBusinessObject;
    mActivity_ID: String;

  begin
    mTextList:= TStringList.Create();

    // hledam nastaveni upominek
    mObjectSpace.SQLSelect('SELECT DRD.ID FROM DefRollData DRD WHERE (DRD.ClsID = ''DCHDUXZ0S3RO1DVWDVB0PD51U0'') AND (DRD.Hidden = ''N'') AND (DRD.X_DayAfter > 0)', mTextList);

    for k:= 0 to (mTextList.Count() - 1) do
      begin

        mTextBO:= mObjectSpace.CreateObject('DCHDUXZ0S3RO1DVWDVB0PD51U0');
        mTextBO.Load(mTextList.Strings[k], nil);
        mDateString:= IntToStr(trunc(Now() - mTextBO.GetFieldValueAsInteger('X_DayAfter')));   //Počet dní po splatnosti
        mIIList:= TStringList.Create();

        try

          mSQL:= 'SELECT II.ID ' +
                 'FROM IssuedInvoices II ' +
                 'LEFT JOIN Firms F ON (F.ID = II.Firm_ID) ' +
                 'WHERE not(ii.docqueue_id=''2B50000101'') and ((II.Amount - ii.CreditAmount- II.PaidAmount) > 0) ' +
                 '       AND ' +
                 '       (F.X_ExcludeReminder = ''N'') ' +
                 '       AND ' +
                 '       (II.X_Excluded = ''N'') ' +
                 '       AND ' +
                 '       (II.DueDate$Date = ' + mDateString + ') ';

          mObjectSpace.SQLSelect(mSQL, mIIList);

          if mIIList.Count() > 0 then
            begin

              for i:= 0 to (mIIList.count() - 1) do
                begin

                  mIDList:= TStringList.Create();
                  mDivision_ID:= '';
                  mBusOrder_ID:= '';

                  mIIBO:= mObjectSpace.CreateObject(Class_IssuedInvoice);
                  mIIBO.Load(mIIList.Strings[i], nil);

                  mMailText:= mTextBO.GetFieldValueAsString('X_note');
                  if (mIIBO.GetFieldValueAsFloat('Amount') - mIIBO.GetFieldValueAsFloat('PaidAmount')) > 0 then
                    begin

                      mMena:= mIIBO.GetFieldValueAsString('Currency_ID.Symbol');

                      mMailText:= NxSearchReplace(mMailText, '#CISLOFAKTURY#',    mIIBO.DisplayName,[srAll]);
                      mMailText:= NxSearchReplace(mMailText, '#VARSYMBOL#',       mIIBO.GetFieldValueAsString('VarSymbol'), [srAll]);
                      mMailText:= NxSearchReplace(mMailText, '#DATUMVYSTAVENI#',  DateToStr(mIIBO.GetFieldValueAsDateTime('DocDate$Date')), [srAll]);
                      mMailText:= NxSearchReplace(mMailText, '#DATUMSPLATNOSTI#', DateToStr(mIIBO.GetFieldValueAsDateTime('DueDate$Date')), [srAll]);
                      mMailText:= NxSearchReplace(mMailText, '#CASTKA_MENA#',     NxFormatNumeric('0.00,', mIIBO.GetFieldValueAsFloat('Amount')) + ' ' + mMena, [srAll]);
                      mMailText:= NxSearchReplace(mMailText, '#NEHRAZENACASTKA#', NxFormatNumeric('0.00,', mIIBO.GetFieldValueAsFloat('Amount') - mIIBO.GetFieldValueAsFloat('PaidAmount')) + ' ' + mMena,[srAll]);

                      mIDList.Append(mIIBO.OID);

                      mReplyTo:= 'ucetni@kingtony.cz';
                      mFirmMail:= mIIBO.GetFieldValueAsString('Firm_ID.ElectronicAddress_ID.Email');

                      //if not(NxIsValidEMail(mFirmMail,False)) then mFirmMail:= mIIBO.GetFieldValueAsString('Firm_ID.ResidenceAddress_ID.Email');
                      mSubject:= mTextBO.GetFieldValueAsString('X_Subject') + ' ' + mIIBO.DisplayName+{+' cílový mail:' +mFirmMail};
                      if not(NxIsValidEMail(mFirmMail,False)) then mFirmMail:= 'asistent@kingtony.cz';
                      //mFirmMail:='marek.zizka@kingtony.cz ';
                      mFileName:= NxSearchReplace(mIIBO.DisplayName, '/', '-', [srall]) + '.pdf';
                      CFxReportManager.PrintByIDs(NxCreateContext_1(mIIBO), mIDList, GetDynSource(mObjectSpace,mTextBO.GetFieldValueAsString('X_Form_ID')), mTextBO.GetFieldValueAsString('X_Form_ID'), rtoFile, pekPDF, NxGetTempDir, mFileName);

                      mIIRow:= mIIBO.GetLoadedCollectionMonikerForFieldCode(mIIBO.GetFieldCode('Rows'));

                      for j:=0 to (mIIRow.Count() - 1) do
                        begin

                          if NxIsEmptyOID(mDivision_ID) then mDivision_ID:= mIIRow.BusinessObject[j].GetFieldValueAsString('Division_ID');
                          if NxIsEmptyOID(mBusOrder_ID) then mBusOrder_ID:= mIIRow.BusinessObject[j].GetFieldValueAsString('BusOrder_ID');

                        end;



                      mMail_ID:= SendInternalMail(mObjectSpace, mFirmMail, '', '', mSubject, mMailText,
                      NxGetTempDir + '\' + mFileName, mIIBO.GetFieldValueAsString('Firm_ID'), mDivision_ID, mBusOrder_ID, mReplyTo);

                      DeleteFile(NxGetTempDir + '\' + mFileName);

                      LogInfoStr:= LogInfoStr + mIIBO.GetFieldValueAsString('Firm_ID.name') + ' email pro upomínky ' + mFirmMail + Chr(10) + Chr(13);



                    end; // end pro IF zjisteni ze opravdu je dluznik

                  mIIBO.Free();
                  mIDList.Free();

                end; // end for i:=

            end; // end if mIIList.Count() > 0 then

        finally
          mIIList.Free();
        end;

      end; // end for k:= 0

    Success:= True;

end;



procedure GenInfoMail3Days (OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
var
 mFirmList, mInvoiceList:TStringList;
 i,j,k, mOffset:integer;
 mInvoiceBO,mTextBO:TNxCustomBusinessObject;
 mMessage, mInvoiceMessage, mBody, mSubject, mSearchStr, mTO, mMena:string;
 mTotal:extended;
 mFirm_ID, mDivision_ID, mBusOrder_ID, mReplyTo:string;
begin
 //mOffset:=0;
 mOffset:=3;
  mSearchStr:='</table><br>';
  mFirmList:=TStringList.create;
  mReplyTo:= 'asistent@kingtony.cz';
  OS.SQLSelect('select distinct(firm_id) from IssuedInvoices A WHERE (A.DueDate$DATE = '+NxFloatToIBStr(date-mOffset)+' ) '+
          'AND (((((A.Amount>=0) and ((A.PaidAmount<=0) and ((A.Amount + A.PaidCreditAmount - A.PaidAmount - A.CreditAmount) > 0))) or '+
          '((A.Amount <0) and ((A.PaidAmount>=0) and ((A.Amount + A.PaidCreditAmount - A.PaidAmount - A.CreditAmount) < 0)))))) ', mFirmList);
  if mFirmList.count>0 then begin
    for i:=0 to mFirmList.count-1 do begin
       mInvoiceList:=TStringList.Create;
       OS.SQLSelect('select a.id from IssuedInvoices A left join firms f on f.id=A.firm_id where not(a.docqueue_id=''2B50000101'') and (F.ID='+Quotedstr(mFirmList.strings[i])+' OR ((F.Firm_ID IS NOT NULL) AND (F.Firm_ID='+Quotedstr(mFirmList.strings[i])+'))) '+
                    'AND (((((A.Amount>=0) and ((A.PaidAmount<=0) and ((A.Amount + A.PaidCreditAmount - A.PaidAmount - A.CreditAmount) > 0))) or '+
                    '((A.Amount <0) and ((A.PaidAmount>=0) and ((A.Amount + A.PaidCreditAmount - A.PaidAmount - A.CreditAmount) < 0)))))) and F.X_ExcludeReminder = ''N'' order by duedate$date', mInvoiceList);
       if mInvoiceList.count>0 then begin
         mMessage:='<tbody>';
         mFirm_ID:='';
         mBusOrder_ID:='';
         mDivision_ID:='';
         mTotal:=0;
         for j:=0 to mInvoiceList.count-1 do begin
           mInvoiceBO:=OS.CreateObject(Class_IssuedInvoice);
           mInvoiceBO.load(mInvoiceList.strings[j],nil);
           mTotal:=mTotal+(mInvoiceBO.GetFieldValueAsFloat('Amount') - mInvoiceBO.GetFieldValueAsFloat('PaidAmount'));
           mMena:= mInvoiceBO.GetFieldValueAsString('Currency_ID.Symbol');
           mTO:=mInvoiceBO.GetFieldValueAsString('Firm_ID.ElectronicAddress_ID.Email');
           //mTO:='marek.zizka@kingtony.cz ';
           if not(NxIsValidEMail(mTO,False)) then mTO:= 'asistent@kingtony.cz';
           if NxIsEmptyOID(mFirm_ID) then mFirm_ID:=mInvoiceBO.GetFieldValueAsString('Firm_ID');
           if NxIsEmptyOID(mDivision_ID) then
            mDivision_ID:=mInvoiceBO.GetLoadedCollectionMonikerForFieldCode(mInvoiceBO.GetFieldCode('Rows')).FirstBusinessObject.GetFieldValueAsString('Division_ID');
           if NxIsEmptyOID(mBusOrder_ID) then
            mBusOrder_ID:=mInvoiceBO.GetLoadedCollectionMonikerForFieldCode(mInvoiceBO.GetFieldCode('Rows')).FirstBusinessObject.GetFieldValueAsString('BusOrder_ID');
           if mInvoiceBO.GetFieldValueAsDateTime('DueDate$Date')<(date-mOffset) then begin
             mInvoiceMessage:='<tr>'+
                              '<td><i><a href="https://api.kingtony.cz/Data/issuedinvoices/'+mInvoiceBO.OID+'.pdf?select=id&report=6LH0000101&Auth=UHJpbnRJbnZvaWNlOlRpc2thcg">'+mInvoiceBO.DisplayName+'</a></i></td>'+
                              //'<td>'+mInvoiceBO.DisplayName+'</td>'+
                              '<td><i>'+mInvoiceBO.GetFieldValueAsString('VarSymbol')+'</i></td>'+
                              '<td align ="right"><i>'+DateToStr(mInvoiceBO.GetFieldValueAsDateTime('DocDate$Date'))+'</i></td>'+
                              '<td align ="right"><i>'+DateToStr(mInvoiceBO.GetFieldValueAsDateTime('DueDate$Date'))+'</i></td>'+
                              '<td align ="right"><i>'+NxFormatNumeric('0.00,', mInvoiceBO.GetFieldValueAsFloat('Amount'))+'</i></td>'+
                              '<td align ="right"><i>'+NxFormatNumeric('0.00,', mInvoiceBO.GetFieldValueAsFloat('Amount') - mInvoiceBO.GetFieldValueAsFloat('PaidAmount'))+'</i></td>'+
                              '<td><i>&nbsp;'+mMena+'</i></td>'+
                              '</tr>';
           end;
           if mInvoiceBO.GetFieldValueAsDateTime('DueDate$Date')=(date-mOffset) then begin
             mInvoiceMessage:='<tr>'+
                              '<td><a href="https://api.kingtony.cz/Data/issuedinvoices/'+mInvoiceBO.OID+'.pdf?select=id&report=6LH0000101&Auth=UHJpbnRJbnZvaWNlOlRpc2thcg">'+mInvoiceBO.DisplayName+'</a></td>'+
                              //'<td><b>'+mInvoiceBO.DisplayName+'</b></td>'+
                              '<td><b>'+mInvoiceBO.GetFieldValueAsString('VarSymbol')+'</b></td>'+
                              '<td align ="right"><b>'+DateToStr(mInvoiceBO.GetFieldValueAsDateTime('DocDate$Date'))+'</b></td>'+
                              '<td align ="right"><b>'+DateToStr(mInvoiceBO.GetFieldValueAsDateTime('DueDate$Date'))+'</b></td>'+
                              '<td align ="right"><b>'+NxFormatNumeric('0.00,', mInvoiceBO.GetFieldValueAsFloat('Amount'))+'</b></td>'+
                              '<td align ="right"><b>'+NxFormatNumeric('0.00,', mInvoiceBO.GetFieldValueAsFloat('Amount') - mInvoiceBO.GetFieldValueAsFloat('PaidAmount'))+'</b></td>'+
                              '<td><b>&nbsp;'+mMena+'</td>'+
                              '</tr>';
           end;
           if mInvoiceBO.GetFieldValueAsDateTime('DueDate$Date')>(date-mOffset) then begin
             mInvoiceMessage:='<tr>'+
                              '<td><a href="https://api.kingtony.cz/Data/issuedinvoices/'+mInvoiceBO.OID+'.pdf?select=id&report=6LH0000101&Auth=UHJpbnRJbnZvaWNlOlRpc2thcg">'+mInvoiceBO.DisplayName+'</a></td>'+
                              //'<td>'+mInvoiceBO.DisplayName+'</td>'+
                              '<td>'+mInvoiceBO.GetFieldValueAsString('VarSymbol')+'</td>'+
                              '<td align ="right">'+DateToStr(mInvoiceBO.GetFieldValueAsDateTime('DocDate$Date'))+'</td>'+
                              '<td align ="right">'+DateToStr(mInvoiceBO.GetFieldValueAsDateTime('DueDate$Date'))+'</td>'+
                              '<td align ="right">'+NxFormatNumeric('0.00,', mInvoiceBO.GetFieldValueAsFloat('Amount'))+'</td>'+
                              '<td align ="right">'+NxFormatNumeric('0.00,', mInvoiceBO.GetFieldValueAsFloat('Amount') - mInvoiceBO.GetFieldValueAsFloat('PaidAmount'))+'</td>'+
                              '<td>&nbsp;'+mMena+'</td>'+
                              '</tr>';
           end;
           mMessage:=mMessage+mInvoiceMessage;
           mInvoiceBO.free;
         end;
         mMessage:=mMessage+'</tbody></table><br>';
         mTextBO:= OS.CreateObject('DCHDUXZ0S3RO1DVWDVB0PD51U0');
         mTextBO.Load('V2S0000101', nil);
         mBody:= mTextBO.GetFieldValueAsString('X_note');
         mSubject:=mTextBO.GetFieldValueAsString('X_Subject');
         mBody:=NxSearchReplace(mBody,'#DATUM#',DateToStr(date),[srAll]);
         mBody:=NxSearchReplace(mBody,'#CASTKA#',NxFormatNumeric('0.00,',mTotal),[srAll]);
         //mBody:=NxSearchReplace(mBody,'<table ','<p><table ',[srAll]);
         mBody:=NxSearchReplace(mBody,mSearchStr,mMessage,[srAll]);
         SendInternalMail(OS, mTO, '', '', mSubject, mBody,
                      '',  mFirm_ID, mDivision_ID, mBusOrder_ID, mReplyTo);
       end;
    end;
  end;
  LogInfoStr:='select distinct(firm_id) from IssuedInvoices A WHERE (A.DueDate$DATE = '+NxFloatToIBStr(date-mOffset)+' ) '+
          'AND (((((A.Amount>=0) and ((A.PaidAmount<=0) and ((A.Amount + A.PaidCreditAmount - A.PaidAmount - A.CreditAmount) > 0))) or '+
          '((A.Amount <0) and ((A.PaidAmount>=0) and ((A.Amount + A.PaidCreditAmount - A.PaidAmount - A.CreditAmount) < 0)))))) and firm_id='+Quotedstr('039N100101');
  Success:= True;
end;

begin
end.