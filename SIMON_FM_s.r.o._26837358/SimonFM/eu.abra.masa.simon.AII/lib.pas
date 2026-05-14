procedure CreateAutoInvoice(OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
var
 mFirmList, mDLList, mTempDLList, mPrintlist:TStringList;
 mDLBO, mInvoiceBO, mBO, mTextBO:TNxCustomBusinessObject;
 i,j,k,l, mType:integer;
 mMessage:string;
 mAmount, mProdej, mSklad, mMarze:Extended;
 mImportMan:TNxDocumentImportManager;
 mInputParams:TNxParameters;
 mParam:TNxParameter;
 mInvoice_ID, mOrder_ID, mSubject, mMailText, mTo, mFileName, mMena:string;
 mCastka, mPatek, mPosledniDen, mNulovaCena, mNizkaMarze:boolean;
 mInvoiceRows:TNxCustomBusinessMonikerCollection;
begin
  mPatek:=(DayOfWeek(Date)=6);
  mPosledniDen:=(DayOfTheMonth(Date) = DaysInMonth(Date));
  mMessage:='';
  mMessage:='dnes je den v týdnu :'+IntToStr(DayOfWeek(Date));
  mFirmList:=TStringList.create;
  os.SQLSelect('Select id from firms where hidden=''N'' and firm_id is null and X_TypeOfAutoInvoice>0 ', mFirmList);
  if mFirmList.count>0 then begin
    for i:=0 to mFirmList.count-1 do begin
      mTempDLList:=TStringList.create;
      OS.SQLSelect('select distinct(sd.id) from storedocuments sd left join storedocuments2 sd2 on sd.id=sd2.parent_id '+
                   'left join firms f on sd.firm_id=f.id where sd.isAvailablefordelivery='+Quotedstr('A')+
                   ' and sd.docqueue_id in (''1100000101'',''U200000101'') and sd.documenttype='+Quotedstr('21')+' and sd.finished='+Quotedstr('N')+' and sd2.provide_id is null '+
                   ' and (F.ID='+Quotedstr(mFirmList.strings[i])+' OR ((F.Firm_ID IS NOT NULL) AND (F.Firm_ID='+Quotedstr(mFirmList.strings[i])+')))',mTempDLList);
      if mTempDLList.count>0 then begin
        mDLList:=TStringList.Create;
        for l:=0 to mTempDLList.count-1 do begin
          mOrder_ID:=OS.SQLSelectFirstAsString('Select max(provide_id) from storedocuments2 where parent_id='+QuotedStr(mTempDLList.Strings[l]),'');
          if NxIsEmptyOID(mOrder_ID) then mDLList.Add(mTempDLList.Strings[l]);
        end;
        if mDLList.count>0 then begin
        mAmount:=0;
        for j:=0 to mDLList.count-1 do begin
           mDLBO:=OS.CreateObject(Class_BillOfDelivery);
           mDLBO.Load(mDLList.Strings[j],nil);
           if j=0 then begin
            mMessage:=mMessage+#13#10+mDLBO.GetFieldValueAsString('Firm_ID.Name');
            mBO:=os.CreateObject(Class_BillOfDelivery);
            mBO.load(mDLList.Strings[j],nil);
           end;
           mAmount:=mAmount+mDLBO.GetFieldValueAsFloat('Amount');
           mMessage:=mMessage+#13#10+mDLBO.DisplayName+'  ze dne: '+DateTimeToStr(mDLBO.GetFieldValueAsDateTime('DocDate$Date'))+'   částka DL: '+FloatToStr(mDLBO.GetFieldValueAsFloat('Amount'));
           mDLBO.Free;
        end;
        mMessage:=mMessage+#13#10+'Částka celkem za firmu: '+FloatToStr(mAmount);
        mMessage:=mMessage+#13#10+'---------------------------------------------';
        //doplnit generování na poslední den v měsíci
        mCastka:=(mAmount>2000);
        if mCastka or mPatek or mPosledniDen then begin
                try
                      mInputParams := TNxParameters.Create;
                      mParam := mInputParams.GetOrCreateParam(dtString, 'DocQueue_ID');
                      mParam.AsString := 'H100000101';
                      mParam := mInputParams.GetOrCreateParam(dtString, 'SelectedHeader');
                      mParam.AsString := mBO.OID;
                      mMessage:=mMessage+#13#10+'Hlavičkový DL: '+mBO.DisplayName;
                      mImportMan:=NxCreateDocumentImportManager(OS,Class_BillOfDelivery, Class_IssuedInvoice);
                      mImportMan.AddInputDocuments(mDLList);
                      mImportMan.LoadParams(mInputParams);
                      mImportMan.Execute;
                      mImportMan.OutputDocument.SetFieldValueAsString('DocQueue_ID', 'H100000101');
                      mImportMan.OutputDocument.SetFieldValueAsString('Firm_ID',mBO.GetFieldValueAsString('Firm_ID'));
                      mImportMan.OutputDocument.SetFieldValueAsString('FirmOffice_ID',mBO.GetFieldValueAsString('FirmOffice_ID'));
                      mImportMan.OutputDocument.SetFieldValueAsFloat('DocumentDiscount',10);
                      mImportMan.OutputDocument.SetFieldValueAsDateTime('VatDate$Date',Date);
                      mImportMan.OutputDocument.SetFieldValueAsString('CreatedBy_ID','AUTO000000');
                      mimportman.OutputDocument.save;
                      mInvoiceRows:=mImportMan.OutputDocument.GetLoadedCollectionMonikerForFieldCode(mImportMan.OutputDocument.GetFieldCode('Rows'));
                      mNulovaCena:=False;
                      mNizkaMarze:=False;
                      for k:=0 to mInvoiceRows.count-1 do begin
                        if not(mNulovaCena) then begin
                         if mInvoiceRows.BusinessObject[k].GetFieldValueAsFloat('UnitPrice')=0 then mNulovaCena:=True;
                        end;
                        if not(mNizkaMarze) then begin
                         mProdej:=mInvoiceRows.BusinessObject[k].GetFieldValueAsFloat('LocalTAmountWithoutVAT');
                         mSklad:= OS.SQLSelectFirstAsExtended('Select localtamount from storedocuments2 where id='+
                                                              QuotedStr(mInvoiceRows.BusinessObject[k].GetFieldValueAsString('ProvideRow_ID')),0);
                         if mProdej>0 then begin
                            mMarze:=(mProdej-mSklad)/mProdej;
                            if mMarze<0.1 then mNizkaMarze:=true
                         end;
                        end;
                      end;
                      mInvoice_ID:=mImportMan.OutputDocument.OID;
                      mbo.free;
                      mTextBO:=OS.CreateObject('DCHDUXZ0S3RO1DVWDVB0PD51U0');
                      mTextBO.Load('70JB000101',nil);
                      mSubject:=mTextBO.GetFieldValueAsString('X_Subject');
                      mPrintList:=TStringList.create;
                      mBO:=Os.CreateObject(Class_IssuedInvoice);
                      mMailText:=mTextBO.GetFieldValueAsString('X_Note');
                      mBO.Load(mInvoice_ID,nil);
                      mMessage:=mMessage+#13#10+'Vystavena faktura číslo: '+mBO.DisplayName+' pro firmu '+mbo.GetFieldValueAsString('Firm_ID.Name');
                      if mNulovaCena then mMessage:=mMessage+#13#10+'Tato faktura obsahuje položku s nulovou cenou.';
                      if mNizkaMarze then mMessage:=mMessage+#13#10+'Tato faktura obsahuje položku s nízkou marží.';
                      mMessage:=mMessage+#13#10+'_____________________________________________';
                      if mNizkaMarze or mNulovaCena then mTo:='klara.zidkova@simonfm.cz;sarka.skotnicova@simonfm.cz' else
                      //mto:='klara.zidkova@simonfm.cz;sarka.skotnicova@simonfm.cz';
                      mTO:=mBO.GetFieldValueAsString('Firm_ID.ElectronicAddress_ID.Email');
                      if not(NxIsValidEMail(mTo,false)) then mTO:='klara.zidkova@simonfm.cz;sarka.skotnicova@simonfm.cz';
                      mPrintList:=TStringList.Create;
                      mPrintList.Add(mBO.OID);
                      mFileName:=NxSearchReplace(mBO.DisplayName,'/','-',[srAll])+'.pdf';
                      mMena:= mBO.GetFieldValueAsString('Currency_ID.Symbol');
                      mMailText:= NxSearchReplace(mMailText, '#CISLOFAKTURY#',    mBO.DisplayName,[srAll]);
                      mMailText:= NxSearchReplace(mMailText, '#VARSYMBOL#',       mBO.GetFieldValueAsString('VarSymbol'), [srAll]);
                      mMailText:= NxSearchReplace(mMailText, '#DATUMVYSTAVENI#',  DateToStr(mBO.GetFieldValueAsDateTime('DocDate$Date')), [srAll]);
                      mMailText:= NxSearchReplace(mMailText, '#DATUMSPLATNOSTI#', DateToStr(mBO.GetFieldValueAsDateTime('DueDate$Date')), [srAll]);
                      mMailText:= NxSearchReplace(mMailText, '#CASTKA_MENA#',     NxFormatNumeric('0.00,', mBO.GetFieldValueAsFloat('Amount')) + ' ' + mMena, [srAll]);
                      mMailText:= NxSearchReplace(mMailText, '#NEHRAZENACASTKA#', NxFormatNumeric('0.00,', mBO.GetFieldValueAsFloat('Amount') - mBO.GetFieldValueAsFloat('PaidAmount')) + ' ' + mMena,[srAll]);
                      CFxReportManager.PrintByIDs(NxCreateContext_1(mBO),mPrintList,GetDynSource(OS,mtextbo.GetFieldValueAsString('X_Form_ID')), mtextbo.GetFieldValueAsString('X_Form_ID'),rtoFile,pekPDF,'D:\tmp',mFileName);
                      SendInternalMail(OS, mTO,'','mario.zizka@simonfm.cz',
                                       mSubject+' '+mbo.DisplayName,mMailText,
                                       'D:\tmp'+'\'+ mFileName ,'',mbo.GetFieldValueAsString('Firm_ID'),
                                       mbo.GetLoadedCollectionMonikerForFieldCode(mbo.GetFieldCode('Rows')).BusinessObject[0].GetFieldValueAsString('Division_ID'),
                                       mbo.GetLoadedCollectionMonikerForFieldCode(mbo.GetFieldCode('Rows')).BusinessObject[0].GetFieldValueAsString('BusTransaction_ID'), '2300000101');
                      DeleteFile('D:\tmp'+mFileName);
                      mbo.free;
               except
                 mMessage:=mMessage+#13#10+ExceptionMessage;
               end;
        end;
       end;
      end;
    end;
  end;
  Success := True;
  LogInfoStr := ''+mMessage;
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
                           ASubject:String; ABody:String; AAtachement, AAtachement2:String; AFirm_ID:String; ADivision_ID:String; ABusTransaction_ID:String; aAccount_ID:string);
Var
  mMailBO:TNxCustomBusinessObject;
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
     mMailBO.free;

  end;
end;

begin
end.