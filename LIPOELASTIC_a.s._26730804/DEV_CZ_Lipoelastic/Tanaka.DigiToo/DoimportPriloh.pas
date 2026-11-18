uses
  'Tanaka.DigiToo.Main';

procedure DoimportPriloh(pmSite: TSiteForm);
var
  lfProgress: TForm;
  loObj: TNxCustomBusinessObject;
  lcSQL, lcResult, lcFirm_ID, lcDocument_ID, lcDocumentType, lcDocDQ_ID, lcDocDC_ID, AUTH_TOKEN,
   lcDigitooID, lcDigitooURL: string;
  i, lnType: integer;
  laList, laPom, logs: TStringList;
  OS: TNxCustomObjectSpace;
begin
  if not(Assigned(pmSite)) then exit;
  loObj:= TBusRollSiteForm(pmSite).CurrentObject;
  if not Assigned(loObj) then exit;

  lcResult:= '';
  OS:= pmSite.SiteContext.GetObjectSpace;

  laList:= TStringList.Create;
  laPom:= TStringList.Create;
  laPom.Delimiter:= ';';
  logs:= TStringList.Create;
  try
    AUTH_TOKEN:= loObj.GetFieldValueAsString('U_Token');
    if (AUTH_TOKEN='') then lcResult:= lcResult+NxIifStr(lcResult<>'',#13#10,'')+'Není vyplněn autentifikační token.';
    lcDocDQ_ID:= loObj.GetFieldValueAsString('U_DocDQ_ID');
    if NxIsEmptyOID(lcDocDQ_ID) then lcResult:= lcResult+NxIifStr(lcResult<>'',#13#10,'')+'Není vyplněna řada pro dokumenty.';
    lcDocDC_ID:= loObj.GetFieldValueAsString('U_DocCateg_ID');
    if NxIsEmptyOID(lcDocDC_ID) then lcResult:= lcResult+NxIifStr(lcResult<>'',#13#10,'')+'Není vyplněna kategorie pro dokumenty.';
    if lcResult<>'' then begin
      ShowMessage(lcResult);
      exit;
    end;

    AUTH_TOKEN:= GetAccountToken(OS, AUTH_TOKEN, loObj.OID);
    if (AUTH_TOKEN='') then begin
      logs.Add('Nepodařilo se získat přístupový token.');
      exit;
    end;

    lnType:= loObj.GetFieldValueAsInteger('U_Type');
    case lnType of
      0:lcSQL:= 'Select A.ID, DQ.DocumentType, coalesce(F.Firm_ID, F.ID), A.X_DigitooDocumentUrl'
            +#13' from ReceivedInvoices A'
            +#13' join DocQueues DQ on DQ.ID=A.DocQueue_ID'
            +#13' join Firms F on F.ID=A.Firm_ID'
            +#13' where A.X_DigitooDocumentUrl<>'''''
            +#13' union all'
            +#13' Select A.ID, DQ.DocumentType, coalesce(F.Firm_ID, F.ID), A.X_DigitooDocumentUrl'
            +#13' from ReceivedDInvoices A'
            +#13' join DocQueues DQ on DQ.ID=A.DocQueue_ID'
            +#13' join Firms F on F.ID=A.Firm_ID'
            +#13' where A.X_DigitooDocumentUrl<>'''''
            +#13' union all'
            +#13' Select A.ID, DQ.DocumentType, coalesce(F.Firm_ID, F.ID), A.X_DigitooDocumentUrl'
            +#13' from VATReceivedDInvoices A'
            +#13' join DocQueues DQ on DQ.ID=A.DocQueue_ID'
            +#13' join Firms F on F.ID=A.Firm_ID'
            +#13' where A.X_DigitooDocumentUrl<>''''';
      1:lcSQL:= 'Select A.ID, DQ.DocumentType, coalesce(F.Firm_ID, F.ID), A.X_DigitooDocumentUrl'
            +#13' from IssuedInvoices A'
            +#13' join DocQueues DQ on DQ.ID=A.DocQueue_ID'
            +#13' join Firms F on F.ID=A.Firm_ID'
            +#13' where A.X_DigitooDocumentUrl<>''''';
      2:lcSQL:= 'Select A.ID, DQ.DocumentType, coalesce(F.Firm_ID, F.ID), A.X_DigitooDocumentUrl'
            +#13' from OtherExpenses A'
            +#13' join DocQueues DQ on DQ.ID=A.DocQueue_ID'
            +#13' join Firms F on F.ID=A.Firm_ID'
            +#13' where A.X_DigitooDocumentUrl<>'''''
            +#13' union all'
            +#13' Select A.ID, DQ.DocumentType, coalesce(F.Firm_ID, F.ID), A.X_DigitooDocumentUrl'
            +#13' from CashPaid A'
            +#13' join DocQueues DQ on DQ.ID=A.DocQueue_ID'
            +#13' join Firms F on F.ID=A.Firm_ID'
            +#13' where A.X_DigitooDocumentUrl<>''''';
    end;

    lfProgress := ShowProgress('Doimport chybějících příloh', 1, 0, 'Probíhá příprava doimportu ...', true);
    OS.SQLSelect(lcSQL, laList);
    for i:=0 to laList.Count-1 do begin
      if SetProgress(
        lfProgress,
        i+1,
        laList.Count,
        'Probíhá doimport příloh ('+IntToStr(i+1)+'/'+IntToStr(laList.Count)+')'
      ) then exit;
      laPom.DelimitedText:= laList[i];
      lcDocument_ID:= laPom[0];
      lcDocumentType:= laPom[1];
      lcFirm_ID:= laPom[2];
      lcDigitooURL:= laPom[3];
      lcDigitooID:= NxRest(lcDigitooURL, NxAtr('/',lcDigitooURL)+1);
      try
        downloadAttachments(OS, lcDocumentType, lcDigitooID, lcDocument_ID, lcFirm_ID, lcDocDQ_ID, lcDocDC_ID, AUTH_TOKEN, logs);
      except
        lcResult:= 'Při stahování příloh z Digitoo došlo k neočekávané chybě:'+#13#10+ExceptionMessage;
        ShowMessage(lcResult);
        exit;
      end;
    end;
    lfProgress.Hide;
    ShowMessage('Doimport chybějících příloh dokumentů dokončen.');
  finally
    lfProgress.Free;
    laList.Free;
    laPom.Free;
    logs.Free;
  end;
end;

begin
end.