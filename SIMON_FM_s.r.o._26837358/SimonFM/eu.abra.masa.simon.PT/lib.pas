const
 cBankAccount_ID = '7D30000101';

procedure CheckFile(OS: TNxCustomObjectSpace; var ProcessContinue: Boolean; Directory: string; FileName: string);
var
 mBSBO, mBSRowBO:TNxCustomBusinessObject;
 mBankAccount_ID, mPeriod_ID, mBS_ID:string;
 mRows:TNxCustomBusinessMonikerCollection;
 i:integer;
 mAmountCredit, mAmountDebet, mAmountDebet2:Extended;
 mList:TStringList;
 mObchodnik, mPOS, mUID, mNazev_obchodnika, mNazev_obchodu, mTyp_zaznamu, mCislo_vypisu, mDatum_vypisu, mDatum_platby: string;
 mCislo_platby, mPlne_cislo_platby, mPlatebni_schema, mDatum_transakce, mCas_transakce, mAutorizacni_kod, mZnacka_karty: string;
 mCislo_karty, mPlatba_brutto, mPlatba_poplatku, mUhrazena_castka, mMena_obchodnika, mCastka_brutto, mVyse_poplatku, mCastka_netto: string;
 mMena_transakce, mTyp_karty, mID_davky, mZalozni_rezim, mVariabilni_symbol, mKod_zamitnuti, mText_zamitnuti, mSmenny_kurz: string;
 mCislo_bankovniho_uctu, mIdentifikace_zasahu_pri_platbe: string;
 mDCC_castka, mDCC_mena, mDCC_smenny_kurz, mDCC_datum_kurzu, mDCC_markup, mDCC_reference, mDCC_poskytovatel, mDCC_profil, mTempStr:string;
begin
   mList:=TStringList.create;
   mList.LoadFromFile(Directory + '\' + FileName);
   if (NxSearch(FileName,'82159683',[srAll],0)>0) {prodejna} or (NxSearch(FileName,'82264580',[srAll],0)>0) {bar} then begin
     if mlist.Count>0 then begin
       mAmountCredit:=0;
       mAmountDebet:=0;
       mAmountDebet2:=0;
       mBankAccount_ID:='';
       for i:=1 to mList.Count-1 do begin
        mTempStr:=mList.strings[i];
        mObchodnik:=NxTrapStrTrim(mTempStr,';');
        mPOS:=NxTrapStrTrim(mTempStr,';');
        mUID:=NxTrapStrTrim(mTempStr,';');
        mNazev_obchodnika:=NxTrapStrTrim(mTempStr,';');
        mNazev_obchodu:=NxTrapStrTrim(mTempStr,';');
        mTyp_zaznamu:=NxTrapStrTrim(mTempStr,';');
        mCislo_vypisu:=NxTrapStrTrim(mTempStr,';');
        mDatum_vypisu:=NxTrapStrTrim(mTempStr,';');
        mDatum_platby:=NxTrapStrTrim(mTempStr,';');
        mCislo_platby:=NxTrapStrTrim(mTempStr,';');
        mPlne_cislo_platby:=NxTrapStrTrim(mTempStr,';');
        mPlatebni_schema:=NxTrapStrTrim(mTempStr,';');
        mDatum_transakce:=NxTrapStrTrim(mTempStr,';');
        mCas_transakce:=NxTrapStrTrim(mTempStr,';');
        mAutorizacni_kod:=NxTrapStrTrim(mTempStr,';');
        mZnacka_karty:=NxTrapStrTrim(mTempStr,';');
        mCislo_karty:=NxTrapStrTrim(mTempStr,';');
        mPlatba_brutto:=NxTrapStrTrim(mTempStr,';');
        mPlatba_poplatku:=NxTrapStrTrim(mTempStr,';');
        mUhrazena_castka:=NxTrapStrTrim(mTempStr,';');
        mMena_obchodnika:=NxTrapStrTrim(mTempStr,';');
        mCastka_brutto:=NxTrapStrTrim(mTempStr,';');
        mVyse_poplatku:=NxTrapStrTrim(mTempStr,';');
        mCastka_netto:=NxTrapStrTrim(mTempStr,';');
        mMena_transakce:=NxTrapStrTrim(mTempStr,';');
        mTyp_karty:=NxTrapStrTrim(mTempStr,';');
        mID_davky:=NxTrapStrTrim(mTempStr,';');
        mZalozni_rezim:=NxTrapStrTrim(mTempStr,';');
        mVariabilni_symbol:=NxTrapStrTrim(mTempStr,';');
        mKod_zamitnuti:=NxTrapStrTrim(mTempStr,';');
        mText_zamitnuti:=NxTrapStrTrim(mTempStr,';');
        mSmenny_kurz:=NxTrapStrTrim(mTempStr,';');
        mCislo_bankovniho_uctu:=NxTrapStrTrim(mTempStr,';');
        mIdentifikace_zasahu_pri_platbe:=NxTrapStrTrim(mTempStr,';');
        mDCC_castka:=NxTrapStrTrim(mTempStr,';');
        mDCC_mena:=NxTrapStrTrim(mTempStr,';');
        mDCC_smenny_kurz:=NxTrapStrTrim(mTempStr,';');
        mDCC_datum_kurzu:=NxTrapStrTrim(mTempStr,';');
        mDCC_markup:=NxTrapStrTrim(mTempStr,';');
        mDCC_reference:=NxTrapStrTrim(mTempStr,';');
        mDCC_poskytovatel:=NxTrapStrTrim(mTempStr,';');
        mDCC_profil:=NxTrapStrTrim(mTempStr,';');
        if NxIsEmptyOID(mBankAccount_ID) then mBankAccount_ID:=OS.SQLSelectFirstAsString('Select id from bankaccounts where bankaccount='+QuotedStr(mPOS)+' and hidden='+QuotedStr('N'),'');
        mAmountCredit:=NxIBStrToFloat(mPlatba_brutto);
        mAmountDebet:=mAmountDebet+NxIBStrToFloat(mPlatba_poplatku);
       if i=1 then begin
         mBSBO:=OS.CreateObject(Class_BankStatement);
         mBSBO.new;
         mBSBO.prefill;
         mBSBO.SetFieldValueAsString('BankAccount_ID',mBankAccount_ID);
         mBSBO.SetFieldValueAsDateTime('DocDate$Date',CFxDate.StrToDateEx(mDatum_vypisu,'yyyymmdd',''));
         mPeriod_ID:=os.SQLSelectFirstAsString('Select id from periods where code='+IntToStr(NxExtractYear(mBSBO.GetFieldValueAsDateTime('DocDate$Date'))),'');
         mBS_ID:=OS.SQLSelectFirstAsString('Select id from bankstatements where bankaccount_id='+
                             QuotedStr(mBankAccount_ID)+' and period_id='+QuotedStr(mPeriod_ID)+' and externalnumber='+Quotedstr(mCislo_platby),'');
         if NxIsEmptyOID(mBS_ID) then begin
           mBSBO.SetFieldValueAsString('Period_ID',mPeriod_ID);
           mBSBO.SetFieldValueAsString('ExternalNumber',mCislo_platby);
           mRows:=mBSBO.GetLoadedCollectionMonikerForFieldCode(mBSBO.GetFieldCode('Rows'));
         end;
       end;
           if mAmountCredit>0 then begin
                 mBSRowBO:=mRows.AddNewObject;
                 mBSRowBO.prefill;
                 mBSRowBO.SetFieldValueAsBoolean('Credit',true);
                 if mUID='18708537' then mVariabilni_symbol:=OS.SQLSelectFirstAsString('Select A.VarSymbol from OtherIncomes A WHERE (A.ElectronicPayment = ''A'' ) AND (A.ElectronicPaymentPaid = ''A'' ) '+
                                                             ' AND (A.ElectronicPaymentAuthCode LIKE '+QuotedStr('%'+mAutorizacni_kod+'%')+' ESCAPE ''~'' )','');
                 mBSRowBO.SetFieldValueAsString('VarSymbol',mVariabilni_symbol);
                 mBSRowBO.SetFieldValueAsFloat('Amount',mAmountCredit);
                 if NxIsEmptyOID(mBSRowBO.GetFieldValueAsString('Division_ID')) then
                  mBSRowBO.SetFieldValueAsString('Division_ID',mBSBO.GetFieldValueAsString('BankAccount_ID.Division_ID'));
                 //mBSRowBO.SetFieldValueAsString('AccPresetDef_ID','2100000101');
                 //if mUID='84698534' then mBSRowBO.SetFieldValueAsString('AccPresetDef_ID','5G80000101');
           end;

       end;
           if mAmountDebet>0 then begin
                 mBSRowBO:=mRows.AddNewObject;
                 mBSRowBO.prefill;
                 mBSRowBO.SetFieldValueAsBoolean('Credit',False);
                 mBSRowBO.SetFieldValueAsFloat('Amount',mAmountDebet);
                 mBSRowBO.SetFieldValueAsString('Division_ID',mBSBO.GetFieldValueAsString('BankAccount_ID.Division_ID'));
                 mBSRowBO.SetFieldValueAsString('AccPresetDef_ID','3E00000101');
           end;

           mBSBO.save;
         mBSBO.free;
     end;

   end;
   if (NxSearch(FileName,'82158925',[srAll],0)>0) {prodejna} or (NxSearch(FileName,'82304129',[srAll],0)>0) {bar} then begin
     if mlist.Count>0 then begin
       mAmountCredit:=0;
       mAmountDebet:=0;
       mAmountDebet2:=0;
       mBankAccount_ID:='';
       for i:=1 to mList.Count-1 do begin
        mTempStr:=mList.strings[i];
        mObchodnik:=NxTrapStrTrim(mTempStr,';');
        mPOS:=NxTrapStrTrim(mTempStr,';');
        mUID:=NxTrapStrTrim(mTempStr,';');
        mNazev_obchodnika:=NxTrapStrTrim(mTempStr,';');
        mNazev_obchodu:=NxTrapStrTrim(mTempStr,';');
        mTyp_zaznamu:=NxTrapStrTrim(mTempStr,';');
        mCislo_vypisu:=NxTrapStrTrim(mTempStr,';');
        mDatum_vypisu:=NxTrapStrTrim(mTempStr,';');
        mDatum_platby:=NxTrapStrTrim(mTempStr,';');
        mCislo_platby:=NxTrapStrTrim(mTempStr,';');
        mPlne_cislo_platby:=NxTrapStrTrim(mTempStr,';');
        mPlatebni_schema:=NxTrapStrTrim(mTempStr,';');
        mDatum_transakce:=NxTrapStrTrim(mTempStr,';');
        mCas_transakce:=NxTrapStrTrim(mTempStr,';');
        mAutorizacni_kod:=NxTrapStrTrim(mTempStr,';');
        mZnacka_karty:=NxTrapStrTrim(mTempStr,';');
        mCislo_karty:=NxTrapStrTrim(mTempStr,';');
        mPlatba_brutto:=NxTrapStrTrim(mTempStr,';');
        mPlatba_poplatku:=NxTrapStrTrim(mTempStr,';');
        mUhrazena_castka:=NxTrapStrTrim(mTempStr,';');
        mMena_obchodnika:=NxTrapStrTrim(mTempStr,';');
        mCastka_brutto:=NxTrapStrTrim(mTempStr,';');
        mVyse_poplatku:=NxTrapStrTrim(mTempStr,';');
        mCastka_netto:=NxTrapStrTrim(mTempStr,';');
        mMena_transakce:=NxTrapStrTrim(mTempStr,';');
        mTyp_karty:=NxTrapStrTrim(mTempStr,';');
        mID_davky:=NxTrapStrTrim(mTempStr,';');
        mZalozni_rezim:=NxTrapStrTrim(mTempStr,';');
        mVariabilni_symbol:=NxTrapStrTrim(mTempStr,';');
        mKod_zamitnuti:=NxTrapStrTrim(mTempStr,';');
        mText_zamitnuti:=NxTrapStrTrim(mTempStr,';');
        mSmenny_kurz:=NxTrapStrTrim(mTempStr,';');
        mCislo_bankovniho_uctu:=NxTrapStrTrim(mTempStr,';');
        mIdentifikace_zasahu_pri_platbe:=NxTrapStrTrim(mTempStr,';');
        mDCC_castka:=NxTrapStrTrim(mTempStr,';');
        mDCC_mena:=NxTrapStrTrim(mTempStr,';');
        mDCC_smenny_kurz:=NxTrapStrTrim(mTempStr,';');
        mDCC_datum_kurzu:=NxTrapStrTrim(mTempStr,';');
        mDCC_markup:=NxTrapStrTrim(mTempStr,';');
        mDCC_reference:=NxTrapStrTrim(mTempStr,';');
        mDCC_poskytovatel:=NxTrapStrTrim(mTempStr,';');
        mDCC_profil:=NxTrapStrTrim(mTempStr,';');
        if NxIsEmptyOID(mBankAccount_ID) then mBankAccount_ID:=OS.SQLSelectFirstAsString('Select id from bankaccounts where bankaccount='+QuotedStr(mPOS)+' and hidden='+QuotedStr('N'),'');
        mAmountCredit:=mAmountCredit+NxIBStrToFloat(mPlatba_brutto);
        if mUID='10974822' then mAmountDebet2:=mAmountDebet2+NxIBStrToFloat(mPlatba_poplatku) else mAmountDebet:=mAmountDebet+NxIBStrToFloat(mPlatba_poplatku);
       end;
       if mAmountCredit>0 then begin
         mBSBO:=OS.CreateObject(Class_BankStatement);
         mBSBO.new;
         mBSBO.prefill;
         mBSBO.SetFieldValueAsString('BankAccount_ID',mBankAccount_ID);
         mBSBO.SetFieldValueAsDateTime('DocDate$Date',CFxDate.StrToDateEx(mDatum_vypisu,'yyyymmdd',''));
         mPeriod_ID:=os.SQLSelectFirstAsString('Select id from periods where code='+IntToStr(NxExtractYear(mBSBO.GetFieldValueAsDateTime('DocDate$Date'))),'');
         mBS_ID:=OS.SQLSelectFirstAsString('Select id from bankstatements where bankaccount_id='+
                             QuotedStr(mBankAccount_ID)+' and period_id='+QuotedStr(mPeriod_ID)+' and externalnumber='+Quotedstr(mCislo_platby),'');
         if NxIsEmptyOID(mBS_ID) then begin
           mBSBO.SetFieldValueAsString('Period_ID',mPeriod_ID);
           mBSBO.SetFieldValueAsString('ExternalNumber',mCislo_platby);
           mRows:=mBSBO.GetLoadedCollectionMonikerForFieldCode(mBSBO.GetFieldCode('Rows'));
           if mAmountCredit>0 then begin
                 mBSRowBO:=mRows.AddNewObject;
                 mBSRowBO.prefill;
                 mBSRowBO.SetFieldValueAsBoolean('Credit',true);
                 mBSRowBO.SetFieldValueAsFloat('Amount',mAmountCredit);
                 mBSRowBO.SetFieldValueAsString('Division_ID',mBSBO.GetFieldValueAsString('BankAccount_ID.Division_ID'));
                 mBSRowBO.SetFieldValueAsString('AccPresetDef_ID','2100000101');
                 if mUID='30174593' then mBSRowBO.SetFieldValueAsString('AccPresetDef_ID','5G80000101');
           end;
           if mAmountDebet>0 then begin
                 mBSRowBO:=mRows.AddNewObject;
                 mBSRowBO.prefill;
                 mBSRowBO.SetFieldValueAsBoolean('Credit',False);
                 mBSRowBO.SetFieldValueAsFloat('Amount',mAmountDebet);
                 mBSRowBO.SetFieldValueAsString('Division_ID',mBSBO.GetFieldValueAsString('BankAccount_ID.Division_ID'));
                 mBSRowBO.SetFieldValueAsString('AccPresetDef_ID','3E00000101');
           end;
           if mAmountDebet2>0 then begin
                 mBSRowBO:=mRows.AddNewObject;
                 mBSRowBO.prefill;
                 mBSRowBO.SetFieldValueAsBoolean('Credit',False);
                 mBSRowBO.SetFieldValueAsFloat('Amount',mAmountDebet2);
                 mBSRowBO.SetFieldValueAsString('Division_ID','5100000101');
                 mBSRowBO.SetFieldValueAsString('AccPresetDef_ID','3E00000101');
           end;
           mBSBO.save;
         end;
         mBSBO.free;
       end;
     end;
  end;
  ProcessContinue := True;
end;

procedure CheckFileComGate(OS: TNxCustomObjectSpace; var ProcessContinue: Boolean; Directory: string; FileName: string);
var
  mList:TStringList;
  mMerchant: string;
  mDatum_zalozeni: string;
  mDatum_zaplaceni: string;
  mDatum_prevodu: string;
  mMesic_fakturace: string;
  mID_ComGate: string;
  mMetoda: string;
  mProdukt: string;
  mPopis: string;
  mE_mail_platce: string;
  mVariabilni_symbol_platce: string;
  mVariabilni_symbol_prevodu: string;
  mID_od_klienta: string;
  mMena: string;
  mPotvrzena_castka: string;
  mPrevedena_castka: string;
  mPoplatek_celkem: string;
  mPoplatek_mezibankovni: string;
  mPoplatek_asociace: string;
  mPoplatek_zpracovatel: string;
  mTyp_karty, mTempStr, mBS_ID, mPeriod_ID: string;
  i:integer;
  mBSBO, mBSRowBO:TNxCustomBusinessObject;
  mRows:TNxCustomBusinessMonikerCollection;
  mAmountCredit, mAmountDebet, mDocDate:Extended;
begin
   mList:=TStringList.create;
   mList.LoadFromFile(Directory + '\' + FileName);
   mAmountCredit:=0;
   mAmountDebet:=0;
   for i:=1 to mList.Count-1 do begin
        mTempStr:=NxSearchReplace(mList.strings[i],'"','',[srAll]);
        mMerchant := NxTrapStrTrim(mTempStr,';');
        mDatum_zalozeni := NxTrapStrTrim(mTempStr,';');
        mDatum_zaplaceni := NxTrapStrTrim(mTempStr,';');
        mDatum_prevodu := NxTrapStrTrim(mTempStr,';');
        mMesic_fakturace := NxTrapStrTrim(mTempStr,';');
        mID_ComGate := NxTrapStrTrim(mTempStr,';');
        mMetoda := NxTrapStrTrim(mTempStr,';');
        mProdukt := NxTrapStrTrim(mTempStr,';');
        mPopis := NxTrapStrTrim(mTempStr,';');
        mE_mail_platce := NxTrapStrTrim(mTempStr,';');
        mVariabilni_symbol_platce := NxTrapStrTrim(mTempStr,';');
        mVariabilni_symbol_prevodu := NxTrapStrTrim(mTempStr,';');
        mID_od_klienta := NxTrapStrTrim(mTempStr,';');
        mMena := NxTrapStrTrim(mTempStr,';');
        mPotvrzena_castka := NxTrapStrTrim(mTempStr,';');
        mPrevedena_castka := NxTrapStrTrim(mTempStr,';');
        mPoplatek_celkem := NxTrapStrTrim(mTempStr,';');
        mPoplatek_mezibankovni := NxTrapStrTrim(mTempStr,';');
        mPoplatek_asociace := NxTrapStrTrim(mTempStr,';');
        mPoplatek_zpracovatel := NxTrapStrTrim(mTempStr,';');
        mTyp_karty := NxTrapStrTrim(mTempStr,';');
        mAmountCredit:=NxIBStrToFloat(mPotvrzena_castka);
        mAmountDebet:=NxIBStrToFloat(mPoplatek_celkem);
        if mMerchant='502879' then begin
           if i=1 then begin
               mDocDate:=CFxDate.StrToDateEx(mDatum_prevodu,'yyyy-mm-dd','');
               mPeriod_ID:=os.SQLSelectFirstAsString('Select id from periods where code='+IntToStr(NxExtractYear(mDocDate)),'');
               mBS_ID:=OS.SQLSelectFirstAsString('Select id from bankstatements where bankaccount_id='+
                                   QuotedStr(cBankAccount_ID)+' and period_id='+QuotedStr(mPeriod_ID)+' and externalnumber='+Quotedstr(mVariabilni_symbol_prevodu),'');
               mBSBO:=OS.CreateObject(Class_BankStatement);
               if NxIsEmptyOID(mBS_ID) then begin
                 mBSBO.new;
                 mBSBO.prefill;
                 mBSBO.SetFieldValueAsString('BankAccount_ID',cBankAccount_ID);
                 mBSBO.SetFieldValueAsDateTime('DocDate$Date',mDocDate);
                 mBSBO.SetFieldValueAsString('Period_ID',mPeriod_ID);
                 mBSBO.SetFieldValueAsString('ExternalNumber',mVariabilni_symbol_prevodu);
               end else begin
                 mBSBO.load(mBS_ID,nil);
               end;
               mRows:=mBSBO.GetLoadedCollectionMonikerForFieldCode(mBSBO.GetFieldCode('Rows'));
            end;
           if Abs(mAmountCredit)>0 then begin
                 mBSRowBO:=mRows.AddNewObject;
                 mBSRowBO.prefill;
                 mBSRowBO.SetFieldValueAsBoolean('Credit',true);
                 mBSRowBO.SetFieldValueAsString('VarSymbol',mID_od_klienta);
                 mBSRowBO.SetFieldValueAsFloat('Amount',mAmountCredit);
                 if NxIsEmptyOID(mBSRowBO.GetFieldValueAsString('Division_ID')) then
                  mBSRowBO.SetFieldValueAsString('Division_ID',mBSBO.GetFieldValueAsString('BankAccount_ID.Division_ID'));
           end;
           if mAmountDebet>0 then begin
                 mBSRowBO:=mRows.AddNewObject;
                 mBSRowBO.prefill;
                 mBSRowBO.SetFieldValueAsBoolean('Credit',False);
                 mBSRowBO.SetFieldValueAsFloat('Amount',mAmountDebet);
                 mBSRowBO.SetFieldValueAsString('Division_ID',mBSBO.GetFieldValueAsString('BankAccount_ID.Division_ID'));
                 mBSRowBO.SetFieldValueAsString('AccPresetDef_ID','3E00000101');
           end;

         //mBSBO.save;
         //mBSBO.free;
        end;
   end;
   mBSBO.save;
end;

procedure SaveAttachCSV(OS: TNxCustomObjectSpace; var ProcessContinue: Boolean;
  Email, EmailAttachment: TNxCustomBusinessObject);
var
  mContent, mBO: TNxCustomBusinessObject;
  mM: TMemoryStream;
  mFile, mFileName, mArchive, mCheckResult: String;
  mLogWindow: TForm;

begin
  // Uložíme CSV soubor z přílohy
  ProcessContinue := True;
  // Pokud se nejedná o přílohu v CSV, tak není co dělat
  if Assigned(EmailAttachment) then begin
  mFile := EmailAttachment.GetFieldValueAsString('FileName');
  if UpperCase(NxRight(EmailAttachment.GetFieldValueAsString('FileName'),4)) <> '.CSV' then
    exit
  else
  begin
    mM:= TMemoryStream.Create;
    try
      // Uložím CSV soubor z přílohy emailu do složky
      case  Email.GetFieldValueAsString('Sender') of
        'noreply.e-Statement@kbsmartpay.cz' : mFileName := 'D:\import_pt\' + mFile;
        'payments@comgate.cz'               : mFileName := 'D:\import_cg\' + mFile;
       else
          mFileName := 'D:\import_csv\' + mFile;
      end;
      mM.SetBytes(EmailAttachment.GetFieldValueAsBytes('BlobData'));
      if NxSearch(Email.GetFieldValueAsString('Subject'),'|',[srAll],0)>0 then mFileName:='';
      if not(NxIsBlank(mFileName)) then mM.SaveToFile(mFileName);
    finally
      mM.Free;
    end;
   end;
  end;
end;

begin
end.