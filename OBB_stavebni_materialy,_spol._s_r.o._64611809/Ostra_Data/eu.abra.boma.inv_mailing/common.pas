const
  cPATH = '\\192.168.200.65\abra_data\inventarizace\'; //kam se ukládá, Rok je vayplněn automaticky. Adresář musí existovat
  cReport_ID = '2610000101'; //Id tiskové sestavy
  cDynSource = 'UOW3MCRXZULO3JZ4KFJUGO1HGW'; //DYNSQL na tiskové sestavě
  cEmailAccount_ID = '3000000101'; //abra automat
  cSubject = 'Inventarizace pohledávek k 31.12.';
  cBody = 'Vážení obchodní přátelé,' + #13#10 +
          've smyslu zákona o účetnictví Vás žádáme o potvrzení správnosti námi vykázaného zůstatku dle rozpisu jednotlivých dokladů vůči OBB stavební materiály, spol. s r.o. ke dni 31.12.' + #13#10 +
          '' + #13#10 +
          'Žádáme Vás o odsouhlasení stavu a v případě zjištění rozdílů o upřesnění dle Vaší evidence. Potvrzenou kopii nám, prosíme, zašlete zpět na adresu inventarizace@obb.cz.' + #13#10 +
          '' + #13#10 +
          'Neobdržíme-li do 14-ti dnů od odeslání žádnou zprávu, budeme považovat výši pohledávek za schválenou.' + #13#10 +
          'Tato zpráva je generována automaticky z nemonitorované emailové schránky (neodpovídejte). V případě nesrovnalostí, nebo dalších dotazů, prosím kontaktujte účetní oddělení:' + #13#10 +
          '' + #13#10 +
          'email: inventarizace@obb.cz' + #13#10 +
          'tel. 777 920 044';

procedure AUTO_SendReport(OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
var
  mBO: TNxCustomBusinessObject;
  mList: TStringList;
  i: Integer;
begin
  Success := True;
  LogInfoStr := '';
  mList:= TStringList.Create;
  try
    OS.SQLSelect('Select top 250 ID From dbo.EmailsSent where SentState = 0 and EmailAccount_ID = ' + QuotedStr(cEmailAccount_ID) + ' and Note = ' + QuotedStr('eu.abra.boma.inv_mailing'),mList);
    for i:= 0 to mList.Count -1 do
    begin
      mBO := OS.CreateObject(Class_EmailSent);
      try
        mBO.Load(mList[i],nil);
        mBO.SetFieldValueAsInteger('SentState', 1);
        try
          mBO.Save;
          LogInfoStr := LogInfoStr + #13#10 + mBO.DisplayName + ' změněno k odeslání';
        except
          LogInfoStr := LogInfoStr + #13#10 + mBO.DisplayName + ' chyba: ' + ExceptionMessage;
          Success := False;
        end;
      finally
        mBO.Free;
      end;
    end;
  finally
    mList.Free;
  end;
end;

procedure AUTO_ProcessReport(OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
begin
  Success := True;
  LogInfoStr := '';
  ProcessReports(OS, Success, LogInfoStr);
end;

Procedure ProcessReports(OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
var
  mPath, mFilename, mEMail: String;
  mFirms: TStringList;
  mFirmBO: TNxCustomBusinessObject;
  i, iOK, iErr: Integer;
begin
  iOK := 0;
  iErr := 0;
  mPath := cPath + IntToStr(CurrentYear - 1) + '\';
  mFirms := TStringList.Create;
  try
    fillFirms(OS, mFirms);
    for i:= 0 to mFirms.Count -1 do
    begin
      mFirmBO := OS.CreateObject(Class_Firm);
      try
        mFirmBO.Load(mFirms[i], nil);
        mEMail := mFirmBO.GetFieldValueAsString('ResidenceAddress_ID.Email');
        if NxIsValidEMail(mEMail, False) then
        begin
          OutputDebugString('mail ok');
        end else begin
          LogInfoStr := LogInfoStr + #13#10 + 'OK - ' + mFirmBO.DisplayName + ' - ' + mEMail + ' - chybná emailová adresa, posíláme na inventarizace@obb.cz';
          mEMail := 'inventarizace@obb.cz';
        end;
        mFileName := mFirmBO.GetFieldValueAsString('Name') +  ' inventarizace pohledávek.pdf';
        if saveReport(mFirmBO, mPath, mFilename) then
        begin
          LogInfoStr := LogInfoStr + #13#10 + 'OK - ' + mFirmBO.DisplayName + ' - ' + mPath + mFilename;
          //vytvoříme email
          if createEmail(mFirmBO,mPath + mFilename, mEMail) then
          begin
            iOK := iOK + 1;
            LogInfoStr := LogInfoStr + #13#10 + 'OK - ' + mFirmBO.DisplayName + ' - ' + mEMail;
          end else begin
            iErr := iErr + 1;
            LogInfoStr := LogInfoStr + #13#10 + 'ERROR - ' + mFirmBO.DisplayName + ' - ' + mEMail + ' - chyba při vytvoření emailu';
          end;
        end else begin
          iErr := iErr + 1;
        end;

      finally
        mFirmBO.Free;
      end;
    end;
  finally
    mFirms.Free;
    Success := (iErr = 0);
    LogInfoStr := LogInfoStr + #13#10 + #13#10 + 'Úspěšně zpracováno ' + IntToStr(iOK) + ' záznamů';
    LogInfoStr := LogInfoStr + #13#10 + 'Počet chyb: ' + IntToStr(iErr);
  end;
end;

function createEmail(mFirm: TNxCustomBusinessObject; aAttachment, aEmail: String): Boolean;
var
  mEmail: TNxCustomBusinessObject;
  i: Integer;
  mMon: TNxCustomBusinessMonikerCollection;
  mRecipient: TNxCustomBusinessObject;
begin
  try
    mEmail:= mFirm.ObjectSpace.CreateObject(Class_EmailSent);
    try
      mEmail.New;
      mEmail.Prefill;
      mEmail.SetFieldValueAsString('EmailAccount_ID', cEmailAccount_ID);
      mEmail.SetFieldValueAsString('Firm_ID', mFirm.OID);
      mEmail.SetFieldValueAsString('Subject', cSubject);
      mEmail.SetFieldValueAsString('Body', cBody);
      TNxEmailSent(mEmail).AttachFile(aAttachment);
      mMon := mEmail.GetLoadedCollectionMonikerForFieldCode(mEmail.GetFieldCode('Recipients'));
      for i:=0 to mMon.Count -1 do mMon.BusinessObject[i].MarkForDelete;
      mRecipient := mMon.AddNewObject;
      mRecipient.SetFieldValueAsInteger('EmailType',0);
      mRecipient.SetFieldValueAsString('EMail', aEmail);
      mEmail.SetFieldValueAsInteger('SentState',0);
      mEmail.SetFieldValueAsString('Note', 'eu.abra.boma.inv_mailing');
      mEmail.Save;
      Result := True;
    finally
      mEmail.Free;
    end;
  except
    OutputDebugString('Saving email: ' + ExceptionMessage);
    Result := False;
  end;
end;


function saveReport(mFirm: TNxCustomBusinessObject; mPath, mFileName: String): Boolean;
var
  mContext: TNxContext;
  mList: TStringList;
begin
  try
    mContext := NxCreateContext_1(mFirm);
    try
      mList := TStringList.Create;
      try
        fillInvoices(mFirm.ObjectSpace, mList, mFirm.OID);
        OutputDebugString('Pro firmu ' + mFirm.DisplayName + ' máme ' + IntToStr(mList.Count) + ' záznamů.');
        OutputDebugString(mPath + mFileName + ' generuji');
        CFxReportManager.PrintByIDs(mContext, mList, cDynSource, cReport_ID, rtoFile, pekPDF, mPath, mFileName);
        OutputDebugString(mPath + mFileName + ' uloženo');
        Result := True;
      finally
        mList.Free;
      end;
    finally
      mContext.Free;
    end;
  except
    OutputDebugString('Saving reports: ' + ExceptionMessage);
    Result := False;
  end;
end;

Procedure fillInvoices(OS: TNxCustomObjectSpace; aList: TStringList; aFirm: TNxOID);
var
  mSQL, sLastDate: String;
begin
  if Assigned(aList) then
  begin
    sLastDate := NxFloatToIBStr(GetLastDateOfYear(CurrentYear - 1));
    mSQL := 'SELECT A.id FROM dbo.IssuedInvoices A WHERE (A.Firm_ID = ' + QuotedStr(aFirm) + ' or A.Firm_ID in (Select ID from dbo.Firms where Firm_ID= ' + QuotedStr(aFirm) + ')) AND (NOT (A.Period_ID = ' + QuotedStr(GetPeriodIDForDate(OS,Today)) + ')) AND ' +
    '(NOT ((  (A.Amount + (SELECT PAmount FROM   PaymentAmountsForICreditNote(A.ID, ' + sLastDate + ')   ) - ' +
    '(SELECT COALESCE(SUM(PAmount),0) FROM   PaymentsForDocument (''03'',A.ID, ' + sLastDate + ')   ) -  (SELECT Amount FROM   PaymentAmountsForICreditNote(A.ID, ' + sLastDate + ')   )) = 0 ))) ';
    OutputDebugString(mSQL);
    OS.SQLSelect(mSQL, aList);
  end;
end;

Procedure fillFirms(OS: TNxCustomObjectSpace; aList: TStringList);
var
  mSQL, sLastDate: String;
begin
  if Assigned(aList) then
  begin
    sLastDate := NxFloatToIBStr(GetLastDateOfYear(CurrentYear - 1));
    mSQL := 'SELECT distinct  coalesce(f.firm_id, f.id) FROM dbo.IssuedInvoices A left join dbo.firms f on f.id=a.firm_id WHERE (NOT (A.Period_ID = ' + QuotedStr(GetPeriodIDForDate(OS,Today)) + ')) AND ' +
    '(NOT ((  (A.Amount + (SELECT PAmount FROM   PaymentAmountsForICreditNote(A.ID, ' + sLastDate + ')   ) - ' +
    '(SELECT COALESCE(SUM(PAmount),0) FROM   PaymentsForDocument (''03'',A.ID, ' + sLastDate + ')   ) -  (SELECT Amount FROM   PaymentAmountsForICreditNote(A.ID, ' + sLastDate + ')   )) = 0 ))) ';
    OutputDebugString(mSQL);
    OS.SQLSelect(mSQL, aList);
  end;
end;

function GetLastDateOfYear(aYear: Word): TDateTime;
begin
  Result := EncodeDate(aYear, 12, 31);
end;

function GetPeriodIDForDate(AOS : TNxCustomObjectSpace; ADate: TDateTime): string;
var
  mSQL: string;
  mValues: TStringList;
begin
  Result := '';
  mValues := TStringList.Create;
  try
    mSQL := Format('select ID from Periods where DateFrom$DATE <= %s and DateTo$DATE > %s', [IntToStr(Trunc(ADate)), IntToStr(Trunc(ADate))]);
    AOS.SQLSelect(mSQL, mValues);
    if mValues.Count > 0 then
      Result := mValues.Strings[0]; //1500000101
  finally
    mValues.Free;
  end;
end;

begin
end.