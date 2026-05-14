uses
  'Tanaka.DigiToo.Common';

function IsVATDocument(annotationsMap: TJSONSuperObject): boolean;
var
  lbTaxDetailNotSent: boolean;
  SRow: TJSONSuperObject;
  i: integer;
begin
  Result:= False;
  lbTaxDetailNotSent:= False;
  try
    lbTaxDetailNotSent:= annotationsMap.A['tax_detail'].length=0;
    Result:= annotationsMap.A['tax_detail'].length>0;
  except
    lbTaxDetailNotSent:= True;
  end;
  if lbTaxDetailNotSent then begin
    try
      for i:=0 to annotationsMap.A['line_items'].length-1 do begin
        SRow:= annotationsMap.A['line_items'].N[i];
        if SRow.S['tax_rate']<>'' then begin
          Result:= True;
          exit;
        end;
      end;
    except
    end;
  end;
end;

function Login(OS:TNxCustomObjectSpace; pcUserEmail, pcUserPassword: string):string;
var
  Typ, url, headers, SQL, AUTH_TOKEN, str: String;
  reg: TJSONSuperObject;
  stream: TMemoryStream;
begin
  Result:= '';

  reg:=TJSONSuperObject.Create;
  stream:= TMemoryStream.Create;
  try
    try
      url:=URL_LOGIN_V2;
      reg.S('email'):= pcUserEmail;
      reg.S('password'):= pcUserPassword;

      reg.SaveToStream(stream);
      headers:= cAgentHeader+cScriptVersion;

      str:=HTTPReadOLE(url,stream,true,headers,'');
      if str='' then begin
        reg:=TJSONSuperObject.ParseString(TEncoding.UTF8.GetString(stream.GetBytes),true); // ABRA nekonvertuje z UTF-8 !
        Result:= reg.O['data'].S['access_token'];
      end;
    except
    end;
  finally
    reg.Free;
    stream.Free;
  end;
end;

function DownloadDocs(OS:TNxCustomObjectSpace; logs: TStrings; RunType: integer = -1):Boolean;
var
  Queue_ID, Typ, url, headers, lcFP_Name, lcError
  , SQL, AUTH_TOKEN, Def_Predkontace
  , Def_Firm_ID, Def_Division_ID, Def_DQ_ID, Document_ID, Def_Doc_DQ_ID, Def_Doc_DC_ID, str
  , lcDRCDocQueue_ID, lcDRCVATRate_ID, lcLogDir, lcUserEmail, lcUserPassword, lcRunTypeName, lcDigitoo_ID, lcPRDocQueues: String;
  digitoo, digitooRow, ret, row, laLogDirs, laPom: TStringList;
  obj, loUser: TNxCustomBusinessObject;
  reg, confirm: TJSONSuperObject;
  registers: TJSONSuperObjectArray;
  stream: TMemoryStream;
  i, k, lnPRDaysBack, lnPRSearchType: Integer;
  lbImportAllAttachments, lbDoNotUpdateFirms, lbImportDates, lbReserved, lbPairPR, lbOrgIdentNumberCheck, lbZkracenyLog: boolean;
begin
  Result:=true;
  Def_Firm_ID:='';
  Def_Division_ID:='';
  Def_DQ_ID:='';
  Typ:='';
  Queue_ID:='';
  Def_Predkontace:='';

  laLogDirs:= TStringList.Create;
  digitoo:= TStringList.Create;
  digitooRow:= TStringList.Create;
  laPom:= TStringList.Create;
  ret:= TStringList.Create;
  row:= TStringList.Create;
  reg:=TJSONSuperObject.Create;
  confirm:=TJSONSuperObject.Create;
  stream:= TMemoryStream.Create;
  obj:=OS.CreateObject(DIGITOO_CLSID);
  loUser:= OS.CreateObject(Class_SecurityUser);
  try
    loUser.Load(NxGetActualUserID(OS), nil);
    SQL:='SELECT F.StringFieldValue, D.StringFieldValue'
    +#13' , QID.StringFieldValue'
    +#13' , COALESCE(TYP.StringFieldValue,'+NxIifStr(NxIsOracle,'N','')+'''0''), X.StringFieldValue, DD.Code'
    +#13' , DocDQ.StringFieldValue, DocDC.StringFieldValue'
    +#13' , DRCDQ.StringFieldValue, DRCVR.StringFieldValue, DRLOG.StringFieldValue'
    +#13' , DRIMALL.StringFieldValue, DRUE.StringFieldValue, DRUP.StringFieldValue'
    +#13' , NOFIRMUPDATE.StringFieldValue, DRIMDA.StringFieldValue, DD.ID'
    +#13' , PRPair.StringFieldValue, PRDocQueues.StringFieldValue, PRDaysBack.StringFieldValue, PRSearchType.StringFieldValue'
    +#13' , OrgIdentNumberCheck.StringFieldValue, ZkrLog.StringFieldValue'
    +#13' FROM DefRollData DD'
    +#13' LEFT JOIN UserData F ON F.CLSID = DD.CLSID AND F.ID = DD.ID AND F.FieldCode='+IntToStr(obj.GetFieldCode('U_Firm_ID'))
    +#13' LEFT JOIN UserData D ON D.CLSID = DD.CLSID AND D.ID = DD.ID AND D.FieldCode='+IntToStr(obj.GetFieldCode('U_Division_ID'))
    //+#13' LEFT JOIN UserData DQ ON DQ.CLSID = DD.CLSID AND DQ.ID = DD.ID AND DQ.FieldCode='+IntToStr(obj.GetFieldCode('U_DocQueue_ID'))
    +#13' LEFT JOIN UserData QID ON QID.CLSID = DD.CLSID AND QID.ID = DD.ID AND QID.FieldCode='+IntToStr(obj.GetFieldCode('U_Queue_ID'))
    +#13' LEFT JOIN UserData TYP ON TYP.CLSID = DD.CLSID AND TYP.ID = DD.ID AND TYP.FieldCode='+IntToStr(obj.GetFieldCode('U_Type'))
    +#13' LEFT JOIN UserData X ON X.CLSID = DD.CLSID AND X.ID = DD.ID AND X.FieldCode='+IntToStr(obj.GetFieldCode('U_Token'))
    //+#13' LEFT JOIN UserData UP ON UP.CLSID = DD.CLSID AND UP.ID = DD.ID AND UP.FieldCode='+IntToStr(obj.GetFieldCode('U_AccPresetDefs_ID'))
    +#13' LEFT JOIN UserData DocDQ ON DocDQ.CLSID = DD.CLSID AND DocDQ.ID = DD.ID AND DocDQ.FieldCode='+IntToStr(obj.GetFieldCode('U_DocDQ_ID'))
    +#13' LEFT JOIN UserData DocDC ON DocDC.CLSID = DD.CLSID AND DocDC.ID = DD.ID AND DocDC.FieldCode='+IntToStr(obj.GetFieldCode('U_DocCateg_ID'))
    +#13' LEFT JOIN UserData DRCDQ ON DRCDQ.CLSID = DD.CLSID AND DRCDQ.ID = DD.ID AND DRCDQ.FieldCode='+IntToStr(obj.GetFieldCode('U_DRCDocQueue_ID'))
    +#13' LEFT JOIN UserData DRCVR ON DRCVR.CLSID = DD.CLSID AND DRCVR.ID = DD.ID AND DRCVR.FieldCode='+IntToStr(obj.GetFieldCode('U_DRCVATRate_ID'))
    +#13' LEFT JOIN UserData DRLOG ON DRLOG.CLSID = DD.CLSID AND DRLOG.ID = DD.ID AND DRLOG.FieldCode='+IntToStr(obj.GetFieldCode('U_LogDir'))
    +#13' LEFT JOIN UserData DRIMALL ON DRIMALL.CLSID = DD.CLSID AND DRIMALL.ID = DD.ID AND DRIMALL.FieldCode='+IntToStr(obj.GetFieldCode('U_ImportAllAttachments'))
    +#13' LEFT JOIN UserData DRUE ON DRUE.CLSID = DD.CLSID AND DRUE.ID = DD.ID AND DRUE.FieldCode='+IntToStr(obj.GetFieldCode('U_UserEmail'))
    +#13' LEFT JOIN UserData DRUP ON DRUP.CLSID = DD.CLSID AND DRUP.ID = DD.ID AND DRUP.FieldCode='+IntToStr(obj.GetFieldCode('U_UserPassword'))
    +#13' LEFT JOIN UserData NOFIRMUPDATE ON NOFIRMUPDATE.CLSID = DD.CLSID AND NOFIRMUPDATE.ID = DD.ID AND NOFIRMUPDATE.FieldCode='+IntToStr(obj.GetFieldCode('U_DoNotUpdateFirms'))
    +#13' LEFT JOIN UserData DRIMDA ON DRIMDA.CLSID = DD.CLSID AND DRIMDA.ID = DD.ID AND DRIMDA.FieldCode='+IntToStr(obj.GetFieldCode('U_ImportDates'))
    +#13' LEFT JOIN UserData PRPair ON PRPair.CLSID = DD.CLSID AND PRPair.ID = DD.ID AND PRPair.FieldCode='+IntToStr(obj.GetFieldCode('U_PRPair'))
    +#13' LEFT JOIN UserData PRDocQueues ON PRDocQueues.CLSID = DD.CLSID AND PRDocQueues.ID = DD.ID AND PRDocQueues.FieldCode='+IntToStr(obj.GetFieldCode('U_PRDocQueues'))
    +#13' LEFT JOIN UserData PRDaysBack ON PRDaysBack.CLSID = DD.CLSID AND PRDaysBack.ID = DD.ID AND PRDaysBack.FieldCode='+IntToStr(obj.GetFieldCode('U_PRDaysBack'))
    +#13' LEFT JOIN UserData PRSearchType ON PRSearchType.CLSID = DD.CLSID AND PRSearchType.ID = DD.ID AND PRSearchType.FieldCode='+IntToStr(obj.GetFieldCode('U_PRSearchType'))
    +#13' LEFT JOIN UserData OrgIdentNumberCheck ON OrgIdentNumberCheck.CLSID = DD.CLSID AND OrgIdentNumberCheck.ID = DD.ID AND OrgIdentNumberCheck.FieldCode='+IntToStr(obj.GetFieldCode('U_OrgIdentNumberCheck'))
    +#13' LEFT JOIN UserData ZkrLog ON ZkrLog.CLSID = DD.CLSID AND ZkrLog.ID = DD.ID AND ZkrLog.FieldCode='+IntToStr(obj.GetFieldCode('U_ZkracenyLog'))
    +#13' WHERE DD.CLSID='+QuotedStr(DIGITOO_CLSID)+' AND DD.Hidden=''N'''
    +NxIifStr(RunType=-1,'',' and coalesce(TYP.StringFieldValue,'+NxIifStr(NxIsOracle,'N','')+'''0'')='+QuotedStr(IntToStr(RunType)));

    OS.SQLSelect(SQL, digitoo);

    logs.Add('Verze skriptu '+cScriptVersion+'.');
    logs.Add('- - - - - - -');

    if digitoo.Count=0 then begin
      case RunType of
        0: lcRunTypeName:= 'received-invoice';
        1: lcRunTypeName:= 'issued-invoice';
        2: lcRunTypeName:= 'receipt';
        else lcRunTypeName:= '';
      end;
      logs.Add('V číselníku Digitoo nebyl nalezen žádný záznam '+NxIIfStr(RunType=-1,'.',' s typem '+lcRunTypeName+'.'));
      logs.Add('- - - - - - -');
    end
    else begin
      for k:=0 to digitoo.Count-1 do begin
        try
          try
            lbReserved:= False;
            digitooRow.Delimiter:=';';
            digitooRow.DelimitedText:=digitoo[k];

            Def_Firm_ID:=digitooRow[0];
            Def_Division_ID:=digitooRow[1];
            //Def_DQ_ID:=digitooRow[2];
            Queue_ID:=digitooRow[2];
            Typ:=digitooRow[3];
            AUTH_TOKEN:=trim(digitooRow[4]);
            //Def_Predkontace:=trim(digitooRow[6]);
            Def_Doc_DQ_ID:=trim(digitooRow[6]);
            Def_Doc_DC_ID:=trim(digitooRow[7]);
            lcDRCDocQueue_ID:= trim(digitooRow[8]);
            lcDRCVATRate_ID:= trim(digitooRow[9]);
            lcLogDir:= trim(digitooRow[10]);
            if lcLogDir<>'' then begin
              lcLogDir:= NxAddPathDelimiter(lcLogDir);
              if laLogDirs.IndexOf(lcLogDir)<0 then laLogDirs.Add(lcLogDir);
            end;
            lbImportAllAttachments:= trim(digitooRow[11])='A';
            lcUserEmail:= trim(digitooRow[12]);
            lcUserPassword:=  trim(digitooRow[13]);
            lbDoNotUpdateFirms:=  trim(digitooRow[14])='A';
            lbImportDates:=  trim(digitooRow[15])='A';
            lcDigitoo_ID:= trim(digitooRow[16]);
            lbPairPR:= trim(digitooRow[17])='A';
            lcPRDocQueues:= trim(digitooRow[18]);
            lnPRDaysBack:= StrToIntDef(trim(digitooRow[19]),0);
            lnPRSearchType:= StrToIntDef(trim(digitooRow[20]),0);
            lbOrgIdentNumberCheck:= trim(digitooRow[21])='A';
            lbZkracenyLog:= trim(digitooRow[22])='A';

            logs.Add('Zpracovávám záznam s kódem: '+trim(digitooRow[5]));
            if (AUTH_TOKEN='') then begin
              logs.Add('Není vyplněn autentifikační token.');
              continue;
            end;

            AUTH_TOKEN:= GetAccountToken(OS, AUTH_TOKEN, lcDigitoo_ID);
            if (AUTH_TOKEN='') then begin
              logs.Add('Nepodařilo se získat přístupový token.');
              continue;
            end;

            if Queue_ID<>'' then Queue_ID:= GetQueue_ID(OS, AUTH_TOKEN, Queue_ID);
            {
            if (lcUserEmail<>'') and (lcUserPassword<>'') then begin
              AUTH_TOKEN:= Login(OS, lcUserEmail, lcUserPassword);
//logs.Add(AUTH_TOKEN);
            end;

            if (AUTH_TOKEN='') then begin
              logs.Add('Nepodařilo se přihlásit do Digitoo. Zkontrolujte přihlašovací údaje do Digitoo.'+#13#10);
              continue;
            end;
            }
            {
            logs.Add('SQL '+trim(SQL));
            logs.Add('AUTH_TOKEN: '+trim(digitooRow[4]));
            logs.Add('Def_Doc_DQ_ID: '+trim(Def_Doc_DQ_ID));
            logs.Add('Def_Doc_DC_ID: '+trim(Def_Doc_DC_ID));
            logs.Add('Zpracovávám záznam s kódem: '+trim(digitooRow[5]));
            exit;
            }

            OS.SQLSelect('Select StringFieldValue'
                     +#13' from UserData'
                     +#13' where CLSID='+QuotedStr(DIGITOO_CLSID)
                     +#13'       and FieldCode='+QuotedStr(ccDigitooReservedFieldCode)
                     +#13'       and ID='+QuotedStr(lcDigitoo_ID), laPom);
            if laPom.Count>0 then begin
              logs.Add('Doklady již stahuje uživatel '+laPom[0]+'. Konec.');
              logs.Add('- - - - - - -');
              continue;
            end
            else begin
              lbReserved:= True;
            end;
            if lbReserved then begin
              OS.SQLExecute('Insert into UserData'
                        +#13' (CLSID, ID, FieldCode, StringFieldValue)'
                        +#13' values'
                        +#13' ('+QuotedStr(DIGITOO_CLSID)
                        +#13'  ,'+QuotedStr(lcDigitoo_ID)
                        +#13'  ,'+QuotedStr(ccDigitooReservedFieldCode)
                        +#13'  ,'+QuotedStr(loUser.DisplayName)+')');
            end;
//            sleep(5000);
            if not (Typ in ['0','1','2']) then begin
              Result:= false;
              logs.Add('Nepodporovaný typ. Konec');
              logs.Add('- - - - - - -');
              continue;
            end;

            {
            if AUTH_TOKEN='' then begin
              Result:=false;
              logs.Add('Vyplňte autorizační token v agendě DigiToo. Konec');
              logs.Add('- - - - - - -');
              continue;
            end;
            }

            url:=URL_READY_TO_EXPORT;
            if Queue_ID<>'' then begin
              url:=ReplaceStr(URL_READY_TO_EXPORT_QUEUE, '%QUEUE_ID%',Queue_ID);
            end;

            reg.SaveToStream(stream);
            headers:='Authorization:Bearer '+AUTH_TOKEN;
            headers:= headers+#13#10+cAgentHeader+cScriptVersion;
            str:= HTTPReadOLE(url,stream,false,headers,'');
            if str<>'' then begin
              Result:=false;
              logs.Add(str+'. Konec');
              logs.Add('- - - - - - -');
              continue;
            end
            else begin
              reg.Free;
              reg:=TJSONSuperObject.ParseString(TEncoding.UTF8.GetString(stream.GetBytes),true); // ABRA nekonvertuje z UTF-8 !

              // LOG
              if lcLogDir<>'' then begin
                try
                  stream.SaveToFile(lcLogDir+'digitoo_import_source_'+FormatDateTime('YYYYMMDD_HHNNSS', now)+'.txt');
                except
                end;
              end;

              if reg.A['data'].length=0 then begin
                Result:=false;
                logs.Add('Nic se nestáhlo. Konec');
                logs.Add('- - - - - - -');
                continue;
              end;

              for i:=0 to reg.A['data'].length-1 do begin
                logs.Add('Zpracovávám: '+reg.A['data'].N[i].O['annotations'].S['invoice_id']);
                try
                  lcFP_Name:= '';
                  case Typ of
                    '0':lcFP_Name:= CreateReceivedInvoiceType(OS, reg.A['data'].N[i], logs, Def_Firm_ID, Def_Division_ID, Def_Doc_DQ_ID,
                                                              Def_Doc_DC_ID, AUTH_TOKEN, reg.A['data'].N[i].S['id'], lcDRCDocQueue_ID, lcDRCVATRate_ID, Queue_ID,
                                                              lbImportAllAttachments, lbDoNotUpdateFirms, lbImportDates, lcError, lbPairPR, lcPRDocQueues, lnPRDaysBack, lnPRSearchType,
                                                              lbOrgIdentNumberCheck, lbZkracenyLog);
                    '1':lcFP_Name:= CreateIssuedInvoiceType(OS, reg.A['data'].N[i], logs, Def_Firm_ID, Def_Division_ID, Def_Doc_DQ_ID,
                                                            Def_Doc_DC_ID, AUTH_TOKEN, reg.A['data'].N[i].S['id'], Queue_ID,
                                                            lbImportAllAttachments, lbDoNotUpdateFirms, lbImportDates, lcError,
                                                            lbOrgIdentNumberCheck, lbZkracenyLog);
                    '2':lcFP_Name:= CreateReceiptType(OS, reg.A['data'].N[i], logs, Def_Firm_ID, Def_Division_ID, Def_Doc_DQ_ID,
                                                      Def_Doc_DC_ID, AUTH_TOKEN, reg.A['data'].N[i].S['id'], lcDRCDocQueue_ID, lcDRCVATRate_ID, Queue_ID,
                                                      lbImportAllAttachments, lbDoNotUpdateFirms, lbImportDates, lcError,
                                                      lbOrgIdentNumberCheck, lbZkracenyLog);
                  end;
                except
                  logs.Add('Neočekávaná chyba: '+ExceptionMessage);
                end;
                Document_ID:=reg.A['data'].N[i].S['id'];
//continue;  //testování = nepotvrzovat na Digitoo
//lcFP_Name:= '';  //testování = potvrdit vždy chybu
                if Document_ID<>'' then begin
                  stream.Clear;
                  url:=ReplaceStr(URL_MARK_AS_EXPORTED, '%DOCUMENT_ID%',Document_ID);
                  confirm.S['status']:= NxIifStr(lcFP_Name<>'','exported','export-errored');
                  confirm.S['internal_erp_id']:= NxIifStr(lcFP_Name<>'',lcFP_Name,'');
                  confirm.S['export_error']:= NxIifStr(lcFP_Name<>'','',UpravTextChyby(lcError));
                  confirm.SaveToStream(stream);
                  if not lbZkracenyLog then logs.Add('Potvrzuji'+NxIifStr(lcFP_Name<>'','',' chybu')+': '+Document_ID);
                  headers:='Authorization:Bearer '+AUTH_TOKEN;
                  headers:= headers+#13#10+cAgentHeader+cScriptVersion;
                  str:=HTTPReadOLE(url,stream,true,headers,'PATCH');
                  if str<>'' then begin
                    Result:=false;
                    if not lbZkracenyLog then logs.Add('Chyba potvrzení: '+str);
                  end;
                end;
                logs.Add('- - - - - - -');
              end;
            end;
          except
            logs.Add('Došlo k neočekávané chybě: '+ExceptionMessage);
          end;
        finally
          if lbReserved then begin
            OS.SQLExecute('Delete from UserData'
                      +#13' where FieldCode='+QuotedStr(ccDigitooReservedFieldCode)
                      +#13'       and CLSID='+QuotedStr(DIGITOO_CLSID)
                      +#13'       and ID='+QuotedStr(lcDigitoo_ID));
          end;
        end;
      end;
    end;
    logs.Add('Konec');
    for i:=0 to laLogDirs.Count-1 do begin
      try
        logs.SaveToFile(laLogDirs[i]+'digitoo_import_result_'+FormatDateTime('YYYYMMDD_HHNNSS', now)+'.txt');
      except
      end;
    end;

  finally
    loUser.Free;
    laPom.Free;
    digitoo.Free;
    digitooRow.Free;
    ret.Free;
    row.Free;
    reg.Free;
    confirm.Free;
    stream.Free;
    laLogDirs.Free;
  end;
end;

function CreateIssuedInvoiceType(OS:TNxCustomObjectSpace;
                                 jsonObj:TJSONSuperObject;
                                 logs:TStrings;
                                 Def_Firm_ID, Def_Division_ID,
                                 Def_Doc_DQ_ID, Def_Doc_DC_ID, AUTH_TOKEN, Document_ID, pcQueue_ID: string;
                                 pbImportAllAttachments: boolean;
                                 pbDoNotUpdateFirms, pbImportDates: boolean;
                                 var pcError: string;
                                 pbOrgIdentNumberCheck: boolean;
                                 pbZkracenyLog: boolean):string;
var
  lcResult: string;
begin
  lcResult:= '';
  Result:= '';
  pcError:= '';
  case AnsiUpperCase(jsonObj.O['annotations'].S['document_type']) of
    'TAX_INVOICE':
        lcResult:= CreateFV(OS, jsonObj, logs, Def_Firm_ID, Def_Division_ID, Def_Doc_DQ_ID,
                          Def_Doc_DC_ID, AUTH_TOKEN, Document_ID, pcQueue_ID,
                          pbImportAllAttachments, pbDoNotUpdateFirms, pbImportDates, pcError, pbOrgIdentNumberCheck, pbZkracenyLog);
    else begin
      lcResult:= '';
      pcError:= 'Nejedná se o podporovaný typ dokladu.';
      logs.Add(pcError);
    end;
  end;
  Result:= lcResult;
end;

function GetFirm_ID(OS: TNxCustomObjectSpace; pcICO, pcDIC, pcICDPH, pcFirmName, pcDigitooAddress, pcStreet, pcCity, pcPostCode, pcCountry: string; logs: TStrings; pbDoNotUpdateFirms: boolean; var pcError: string; var pcFirm_ID: string): boolean;
var
  laPom: TStringList;
  firm, loAddress: TNxCustomBusinessObject;
  Err, lcCountryCode, lcCountry_ID, lcPom: string;
  lmContext: TNxContext;
  lbFoundMore, lbEUmember, lbAbraSK: boolean;
begin
  Result:= True;
  try
    lbAbraSK:= AbraVersion.NationalLocalization='SK';
  except
    lbAbraSK:= False;
  end;
  if lbAbraSK then begin
    lcPom:= pcDIC;
    pcDic:= pcICDPH;
    pcICDPH:= lcPom;
  end;
  pcFirm_ID:= '';
  laPom:= TSTringList.Create;
  lmContext:= NxCreateContext(OS);
  try
    if (pcICO<>'') or (pcDIC<>'') or (pcICDPH<>'') or (pcFirmName<>'') then begin
      lbFoundMore:= False;
      if (pcDIC<>'')then begin
        logs.Add('Dohledávám firmu dle DIČ.');
        OS.SQLSelect('SELECT ID'
                +#13' FROM Firms'
                +#13' WHERE'
                +#13' Firm_ID IS NULL AND'
                +#13' Hidden=''N'' AND'
                +#13' Upper(VATIdentNumber)='+QuotedStr(AnsiUpperCase(pcDIC)),laPom);
      end;
      if laPom.Count>1 then lbFoundMore:= True;
      if (laPom.Count<>1) and (pcICO<>'') then begin
        logs.Add('Dohledávám firmu dle IČO.');
        OS.SQLSelect('SELECT ID'
                +#13' FROM Firms'
                +#13' WHERE'
                +#13' Firm_ID IS NULL AND'
                +#13' Hidden=''N'' AND'
                +#13' Upper(OrgIdentNumber)='+QuotedStr(AnsiUpperCase(pcICO)), laPom);
      end;
      if laPom.Count>1 then lbFoundMore:= True;
      if (laPom.Count<>1) and (pcICDPH<>'') then begin
        logs.Add('Dohledávám firmu dle IČ DPH.');
        OS.SQLSelect('SELECT ID'
                +#13' FROM Firms'
                +#13' WHERE'
                +#13' Firm_ID IS NULL AND'
                +#13' Hidden=''N'' AND'
                +#13' Upper(TAXIdentNumber)='+QuotedStr(AnsiUpperCase(pcICDPH)), laPom);
      end;
      if laPom.Count>1 then lbFoundMore:= True;
      if (laPom.Count<>1) and (pcFirmName<>'') then begin
        logs.Add('Dohledávám firmu dle názvu.');
        OS.SQLSelect('SELECT ID'
                +#13' FROM Firms'
                +#13' WHERE'
                +#13' Firm_ID IS NULL AND'
                +#13' Hidden=''N'' AND'
                +#13' Upper(Name)='+QuotedStr(AnsiUpperCase(pcFirmName)),laPom);
      end;
      if laPom.Count>1 then lbFoundMore:= True;
      if laPom.Count=1 then begin
        logs.Add('Firma nalezena.');
        pcFirm_ID:= laPom[0];
      end
      else begin
        if lbFoundMore then begin
          pcError:= 'V Abře se nepodařilo dohledat právě jednu firmu dle IČO, DIČ, IČ DPH a názvu.';
          logs.Add(pcError);
          Result:= False;
        end
        else begin
          logs.Add('Firmu se nepodařilo dohledat v Abře dle IČO, DIČ, IČ DPH, ani dle názvu.');
          if pbDoNotUpdateFirms then begin
            pcError:= 'Firmu se nepodařilo dohledat v Abře dle IČO, DIČ, IČ DPH, ani dle názvu. Firma nelze založit, protože není povoleno v Abře zakládat nové firmy.';
            logs.Add('Firma nelze založit, protože není povoleno v Abře zakládat nové firmy.');
            Result:= False;
          end
          else begin
            firm:= OS.CreateObject(Class_Firm);
            try
              firm.New;
              firm.Prefill;
              firm.SetFieldValueAsString('OrgIdentNumber',pcICO);
              firm.SetFieldValueAsString('VATIdentNumber',pcDIC);
              firm.SetFieldValueAsString('TAXIdentNumber',pcICDPH);
              firm.SetFieldValueAsString('Name',pcFirmName);
              if pcDIC<>'' then begin
                lcCountry_ID:= GetCountry_ID(OS, NxLeft(pcDIC, 2), lbEUmember);
                if lbEUmember and not NxIsEmptyOID(lcCountry_ID) then firm.SetFieldValueAsString('VATCountry_ID', lcCountry_ID);
              end;
              if lmContext.GetCompanyCache.OrgIdentNumber='27568377' then begin  //u tohoto zákazníka je X_BusTransaction_ID na provozovně povinná položka - musí se vyplnit
                try
                  firm.SetFieldValueAsString('X_BusTransaction_ID', '2800000101');
                except
                end;
              end;
              if Length(pcCountry)=10
                then lcCountryCode:= GetData(OS, 'Countries', 'ID', pcCountry, 'Code')
                else lcCountryCode:= NxLeft(pcCountry,3);
              if (pcICO<>'') and ((lcCountryCode='CZ') or (lcCountryCode='')) then begin
                // NAJDI FIRMU Z ARES
                logs.Add('Hledám firmu v ARES dle IČO.');
                if TNxFirm(firm).GetARESCZData(Err, True, nil) then begin
                  try
                    if firm.GetFieldValueAsString('ResidenceAddress_ID.CountryCode')='' then firm.SetFieldValueAsString('ResidenceAddress_ID.CountryCode', 'CZ');
                    if firm.GetFieldValueAsString('ResidenceAddress_ID.Country')='' then firm.SetFieldValueAsString('ResidenceAddress_ID.Country', 'Česká republika');
                    if lmContext.GetCompanyCache.OrgIdentNumber='27568377' then begin  //u tohoto zákazníka je X_BusTransaction_ID na provozovně povinná položka - musí se vyplnit
                      try
                        firm.GetLoadedCollectionMonikerForFieldCode(firm.getFieldCode('FirmOffices')).BusinessObject[0].SetFieldValueAsString('X_BusTransaction_ID', '2800000101');
                      except
                      end;
                    end;
                    firm.SetFieldValueAsString('VATIdentNumber',NxIifStr(lbAbraSK,pcICDPH,pcDIC));
                    firm.SetFieldValueAsString('TAXIdentNumber',NxIifStr(lbAbraSK,pcDIC,pcICDPH));
                    firm.Save;
                    logs.Add('Firma vytvořena na základě údajů z ARES.');
                    pcFirm_ID:= firm.OID;
                  except
                    pcError:= 'Při vytváření firmy došlo k neočekávané chybě: '+ExceptionMessage;
                    logs.Add(pcError);
                    Result:= False;
                  end;
                end
                else begin
                  logs.Add('Firma nebyla dohledána v ARES.');
                end;
              end;
              if NxIsEmptyOID(pcFirm_ID) and (pcError='') then begin
                try
                  lcCountryCode:= '';
                  firm.SetFieldValueAsString('X_DigitooAdresa', pcDigitooAddress);
                  loAddress:= firm.GetMonikerForFieldCode(firm.GetFieldCode('ResidenceAddress_ID')).BusinessObject;
                  try
                    loAddress.SetFieldValueAsString('Street', pcStreet);
                    loAddress.SetFieldValueAsString('City', pcCity);
                    loAddress.SetFieldValueAsString('PostCode', pcPostCode);
                    if Length(pcCountry)=10
                      then lcCountryCode:= GetData(OS, 'Countries', 'ID', pcCountry, 'Code')
                      else lcCountryCode:= NxLeft(pcCountry,3);
                  except
                  end;
                  if lcCountryCode='' then lcCountryCode:= AnsiUpperCase(NxLeft(pcDIC, 2));
                  if lcCountryCode<>'' then begin
                    loAddress.SetFieldValueAsString('CountryCode', lcCountryCode);
                    pcCountry:= GetData(OS, 'Countries', 'Code', lcCountryCode, 'Name');
                    pcCountry:= NxLeft(pcCountry, 40);
                    if pcCountry<>'' then loAddress.SetFieldValueAsString('Country', pcCountry);
                  end;
                  if lmContext.GetCompanyCache.OrgIdentNumber='27568377' then begin  //u tohoto zákazníka je X_BusTransaction_ID na provozovně povinná položka - musí se vyplnit
                    try
                      firm.GetLoadedCollectionMonikerForFieldCode(firm.getFieldCode('FirmOffices')).BusinessObject[0].SetFieldValueAsString('X_BusTransaction_ID', '2800000101');
                    except
                    end;
                  end;
                  firm.Save;
                  logs.Add('Firma vytvořena na základě údajů z Digitoo.');
                  pcFirm_ID:= firm.OID;
                except
                  pcError:= 'Při vytváření firmy došlo k neočekávané chybě: '+ExceptionMessage;
                  logs.Add(pcError);
                  exit;
                end;
              end;
            finally
              firm.Free;
            end;
          end;
        end;
      end;
    end
    else begin
      logs.Add('Firmu není možné v Abře dohledat, protože nebylo zasláno ani IČO, ani DIČ, ani název.');
    end;
  finally
    laPom.Free;
    lmContext.Free;
  end;
end;

function CreateReceiptType(OS:TNxCustomObjectSpace;
                           jsonObj:TJSONSuperObject;
                           logs:TStrings;
                           Def_Firm_ID, Def_Division_ID,
                           Def_Doc_DQ_ID, Def_Doc_DC_ID, AUTH_TOKEN, Document_ID, pcDRCDocQueue_ID, pcDRCVATRate_ID, pcQueue_ID: string;
                           pbImportAllAttachments: boolean;
                           pbDoNotUpdateFirms, pbImportDates: boolean;
                           var pcError: string;
                           pbOrgIdentNumberCheck: boolean;
                           pbZkracenyLog: boolean):string;
var
  DQ_ID, lcResult, lcSQL: string;
  laPom: TStringList;
begin
  lcResult:= '';
  Result:= '';
  pcError:= '';
  laPom:= TStringList.Create;
  try
    DQ_ID:= AnsiUpperCase(jsonObj.O['annotations'].S['accounting_sequence']);
    if NxIsEmptyOID(DQ_ID) then begin
      pcError:= 'Řada dokladu nezadána.';
      logs.Add(pcError);
      exit;
    end;
    lcSQL:= 'Select DocumentType from DocQueues where ID='+QuotedStr(DQ_ID);
    OS.SQLSelect(lcSQL, laPom);
    if laPom.Count>0 then begin
      case laPom[0] of
        '02':lcResult:= CreateOSV(OS, jsonObj, logs, Def_Firm_ID, Def_Division_ID, Def_Doc_DQ_ID,
                                  Def_Doc_DC_ID, AUTH_TOKEN, Document_ID, pcQueue_ID,
                                  pbImportAllAttachments, pbDoNotUpdateFirms, pbImportDates, pcError, pbOrgIdentNumberCheck, pbZkracenyLog);
        '06':lcResult:= CreatePV(OS, jsonObj, logs, Def_Firm_ID, Def_Division_ID, Def_Doc_DQ_ID,
                                 Def_Doc_DC_ID, AUTH_TOKEN, Document_ID, pcDRCDocQueue_ID, pcDRCVATRate_ID, pcQueue_ID,
                                 pbImportAllAttachments, pbDoNotUpdateFirms, pbImportDates, pcError, pbOrgIdentNumberCheck, pbZkracenyLog);
        else begin
          lcResult:= '';
          pcError:= 'Nejedná se o podporovaný typ dokladu.';
          logs.Add(pcError);
        end;
      end;
    end
    else begin
      lcResult:= '';
      pcError:= 'Řada dokladů nenalezena.';
      logs.Add(pcError);
    end;
    Result:= lcResult;
  finally
    laPom.Free;
  end;
end;

function CreatePV(OS:TNxCustomObjectSpace;
                  jsonObj:TJSONSuperObject;
                  logs:TStrings;
                  Def_Firm_ID, Def_Division_ID,
                  Def_Doc_DQ_ID, Def_Doc_DC_ID, AUTH_TOKEN, Document_ID, pcDRCDocQueue_ID, pcDRCVATRate_ID, pcQueue_ID: string;
                  pbImportAllAttachments: boolean;
                  pbDoNotUpdateFirms, pbImportDates: boolean;
                  var pcError: string;
                  pbOrgIdentNumberCheck: boolean;
                  pbZkracenyLog: boolean):string;
var
  ret, sqlRow: TStringList;
  fp, row, firm, bankAcc, obj, loAddress: TNxCustomBusinessObject;
  rows, rows2: TNxCustomBusinessMonikerCollection;
  annotationsMap, SRow: TJSONSuperObject;
  i, TradeType: Integer;
  Err, Firm_ID, Division_ID, SQL, FP_ID, headVATCode, lcFP_Name, lcFieldName, lcVATIndex_ID, lcVATRate_ID
  , headDivision, headBusOrder, selectedVAT
  , note, DQ_ID, headKontace, headExpenseType, headBusTransaction, strText, str, lcDocumentURL
  , lcICO, lcDIC, lcFirmName, lcCountry_ID, lcCountry_Code, lcElementName, lcAmountFieldName
  , lcCountry, lcSQL, lcIBAN, lcStreet, lcCity, lcPostCode, lcCurrency, lcCashDesk_ID, lcCurrency_ID, lcDigitooSourceFileName
  , headBusProject, lcICDPH: string;
  amount, q: Double;
  FromHeader, lbVATDocument: Boolean;
  lmContext: TNxContext;
begin
  Result:= '';
  FP_ID:= '';
  lcFP_Name:= '';
  pcError:= '';
  Err:='';

  lmContext:= NxCreateContext(OS);
  ret:=TStringList.Create;
  sqlRow:=TStringList.Create;
  sqlRow.Delimiter:=';';
  fp:=OS.CreateObject(Class_CashPaid);
  try

    if AnsiUpperCase(jsonObj.S['status'])<>'READY-TO-EXPORT' then begin
      pcError:= 'Nepodporovaný status dokladu, přeskakuji.';
      logs.Add(pcError);
      exit;
    end;

    annotationsMap:= jsonObj.O['annotations'];

    {
    if AnsiUpperCase(annotationsMap.S['document_type'])<>'TAX_INVOICE' then begin
      pcError:= 'Nejedná se o typ dokladu faktura přijatá.';
      logs.Add(pcError);
      exit;
    end;
    }

    lcDocumentURL:= jsonObj.S['document_url'];
    if lcDocumentURL='' then lcDocumentURL:= jsonObj.S['id'];
    lcDigitooSourceFileName:= jsonObj.S['file_name'];

    DQ_ID:= AnsiUpperCase(annotationsMap.S['accounting_sequence']);
    if NxIsEmptyOID(DQ_ID) then begin
      pcError:= 'Řada dokladu nezadána.';
      logs.Add(pcError);
      exit;
    end;

    try
      if pbOrgIdentNumberCheck then begin
        if (Trim(annotationsMap.S['recipient_register_id'])<>'')
            and (lmContext.GetCompanyCache.OrgIdentNumber<>'')
            and (Trim(annotationsMap.S['recipient_register_id'])<>lmContext.GetCompanyCache.OrgIdentNumber) then begin
          pcError:= 'IČO odběratele na dokladu neodpovídá IČO ve firemních údajích v Abře.';
          logs.Add(pcError);
          exit;
        end;
      end;
    except
    end;

    // Udaje z hlavičky, maji prednost na radcich
    headVATCode:=AnsiUpperCase(annotationsMap.S['vat_code']);
    headKontace:=AnsiUpperCase(annotationsMap.S['assignment']);
    headDivision:=AnsiUpperCase(annotationsMap.S['cost_center']);
    headBusOrder:=AnsiUpperCase(annotationsMap.S['contract']);
    headBusProject:=AnsiUpperCase(annotationsMap.S['project']);
    headExpenseType:=AnsiUpperCase(annotationsMap.S['account_code']);
    headBusTransaction:=AnsiUpperCase(annotationsMap.S['activity']); // obchodni pripad na hlavicce
    lcAmountFieldName:= 'TAmountWithoutVAT';

    fp.New;
    fp.Prefill;

    lbVATDocument:= IsVATDocument(annotationsMap);

    fp.SetFieldValueAsBoolean('VATDocument', lbVATDocument);

    // Firma - povinna polozka - dohledava se dle ICO
    lcICO:= NxLeft(Trim(annotationsMap.S['sender_register_id']),15);
    lcDIC:= NxLeft(Trim(annotationsMap.S['sender_tax_id']),20);
    lcICDPH:= NxLeft(Trim(annotationsMap.S['sender_vat_id']),20);
    lcFirmName:= NxLeft(Trim(annotationsMap.S['sender_name']),220);
    Firm_ID:= '';
    try
      Firm_ID:= Trim(annotationsMap.S['sender_internal_id']);
      if NxIsEmptyOID(Firm_ID) then Firm_ID:= '';
    except
    end;
    if NxIsEmptyOID(Firm_ID) then begin
      if not GetFirm_ID(OS, lcICO, lcDIC, lcICDPH, lcFirmName, NxLeft(Trim(annotationsMap.S['sender_address']),255),
                        NxLeft(Trim(annotationsMap.S['sender_street']),60),
                        NxLeft(Trim(annotationsMap.S['sender_city']),60),
                        NxLeft(Trim(annotationsMap.S['sender_post_code']),10),
                        Trim(annotationsMap.S['sender_country']),
                        logs, pbDoNotUpdateFirms, pcError, Firm_ID) then exit;
    end
    else begin
      if not pbZkracenyLog then logs.Add('Nastavuji zaslanou firmu "'+GetData(OS,'Firms','ID',Firm_ID,'Name')+'".');
    end;

    if (NxIsEmptyOID(Firm_ID)) AND (not NxIsEmptyOID(Def_Firm_ID))
    then begin
      Firm_ID:=Def_Firm_ID;
      if not pbZkracenyLog then logs.Add('Nastavuji výchozí firmu.');
    end;

    if NxIsEmptyOID(Firm_ID)
    then begin
      pcError:= 'Firmu se nepodařilo nastavit, přeskakuji.';
      logs.Add(pcError);
      exit;
    end;

    lcCashDesk_ID:= '';
    try
      lcCashDesk_ID:= Trim(annotationsMap.S['cash_register_type']);
    except
    end;
    lcCurrency:= Trim(annotationsMap.S['currency']);

    if NxIsEmptyOID(lcCashDesk_ID) then begin
      lcSQL:= 'Select CD.ID'
          +#13' from CashDesksDocQueues CDDQ'
          +#13' join CashDesks CD on CD.ID=CDDQ.CashDesk_ID'
          +#13' join Currencies C on C.ID=CD.Currency_ID'
          +#13' where DocQueue_ID='+QuotedStr(DQ_ID)
          +NxIifStr(lcCurrency<>'',' and C.Code='+QuotedStr(lcCurrency),'');
      OS.SQLSelect(lcSQL, ret);
      if ret.Count=1 then begin
        fp.SetFieldValueAsString('CashDesk_ID', ret[0]);
      end
      else begin
        pcError:= 'Pokladna nebyla zaslána a řada dokladů není přiřazena právě k jedné pokladně'+NxIifStr(lcCurrency<>'',' s měnou '+lcCurrency,'')+'.';
        logs.Add(pcError);
        exit;
      end;
    end
    else begin
      lcSQL:= 'Select CDDQ.CashDesk_ID'
          +#13' from CashDesksDocQueues CDDQ'
          +#13' where CDDQ.DocQueue_ID='+QuotedStr(DQ_ID)
          +#13'       and CDDQ.CashDesk_ID='+QuotedStr(lcCashDesk_ID);
      OS.SQLSelect(lcSQL, ret);
      if ret.Count=0 then begin
        pcError:= 'Zaslaná pokladna nemá přiřazenu zaslanou řadu dokladů.';
        logs.Add(pcError);
        exit;
      end
      else fp.SetFieldValueAsString('CashDesk_ID', lcCashDesk_ID);
    end;
    if NxIsEmptyOID(fp.GetFieldValueAsString('DocQueue_ID')) then fp.SetFieldValueAsString('DocQueue_ID',DQ_ID);
    // Kontace
    if not NxIsEmptyOID(headKontace) then begin
      fp.SetFieldValueAsString('AccPresetDef_ID',headKontace);
    end;

    //lcElementName:= 'report_code';
    lcElementName:= 'trade_code';
    if (annotationsMap.S['trade_code']<>'') then begin
      TradeType:= StrToIntDef(annotationsMap.S['trade_code'],0);
      if (TradeType>0) AND (TradeType<7) then fp.SetFieldValueAsInteger('TradeType', TradeType);
    end;

    fp.SetFieldValueAsString('Firm_ID', Firm_ID);
    fp.SetFieldValueAsString('ExternalNumber',trim(Copy(annotationsMap.S['invoice_id'],1,30)));
    if fp.GetFieldValueAsString('ExternalNumber')<>'' then begin
      lcSQL:= 'Select A.ID'
          +#13' from CashPaid A'
          +#13' join Firms F on F.ID=A.Firm_ID'
          +#13' where coalesce(F.Firm_ID,F.ID)='+QuotedStr(NxIIfStr(not NxIsEmptyOID(fp.GetFieldValueAsString('Firm_ID.Firm_ID')),fp.GetFieldValueAsString('Firm_ID.Firm_ID'),fp.GetFieldValueAsString('Firm_ID')))
          +#13'       and Upper(A.ExternalNumber)='+QuotedStr(AnsiUpperCase(fp.GetFieldValueAsString('ExternalNumber')));
      OS.SQLSelect(lcSQL, ret);
      if ret.Count>0 then begin
        pcError:= 'Pro firmu "'+fp.GetFieldValueAsString('Firm_ID.Name')+'" již existuje pokladní výdej s externím číslem "'+fp.GetFieldValueAsString('ExternalNumber')+'", přeskakuji.';
        logs.Add(pcError);
        exit;
      end;
    end;

    if lbVATDocument then begin
      if fp.GetFieldValueAsInteger('TradeType')=1 then begin
        fp.SetFieldValueAsInteger('DataEntryKind', 0);
      end
      else begin
        lcAmountFieldName:= 'TAmount';
      end;
    end
    else begin
      lcAmountFieldName:= 'TAmount';
    end;

    if fp.GetFieldValueAsInteger('TradeType') in [2,3,4] then begin
      lcCountry_Code:= '';
      try
        lcCountry_Code:= NxIifStr(Length(Trim(annotationsMap.S['sender_country']))=10,GetData(OS, 'Countries', 'ID', Trim(annotationsMap.S['sender_country']), 'Code'), NxLeft(Trim(annotationsMap.S['sender_country']),3));
      except
      end;
      if lcCountry_Code='' then lcCountry_Code:= NxLeft(fp.GetFieldValueAsString('Firm_ID.ResidenceAddress_ID.CountryCode'),2);
      if lcCountry_Code='' then lcCountry_Code:= NxLeft(fp.GetFieldValueAsString('Firm_ID.VATIdentNumber'),2);
      if lcCountry_Code='' then lcCountry_Code:= NxLeft(lcDIC,2);
      lcCountry_Code:= AnsiUpperCase(lcCountry_Code);
      lcCountry_ID:= GetData(OS, 'Countries', 'Code', lcCountry_Code, 'ID', True, 'Hidden=''N''');
      if not NxIsEmptyOID(lcCountry_ID) then fp.SetFieldValueAsString('Country_ID', lcCountry_ID);
      if fp.GetFieldValueAsInteger('TradeType')=2 then fp.SetFieldValueAsBoolean('IsReverseChargeDeclared', True);
    end;

    if lmContext.GetCompanyCache.OrgIdentNumber='26230224' then begin  //Magsy to chce jinak (dle Data uplatnění odpočtu)
      if annotationsMap.S['received_date']<>'' then begin
        fp.SetFieldValueAsDateTime('DocDate$DATE', annotationsMap.DT8601['received_date']);
        fp.SetFieldValueAsString('Period_ID',GetPeriodOS(OS,annotationsMap.DT8601['received_date']));
        if NxIsEmptyOID(fp.GetFieldValueAsString('Period_ID')) then begin
          pcError:= 'Dle data uplatnění odpočtu nebylo v Abře dohledáno odpovídající období.';
          logs.Add(pcError);
          exit;
        end;
      end
      else begin
        fp.SetFieldValueAsDateTime('DocDate$DATE', Date);
        fp.SetFieldValueAsString('Period_ID',GetPeriodOS(OS,fp.GetFieldValueAsDateTime('DocDate$DATE')));
        {
        pcError:= 'Nebyl zaslán datum uplatnění odpočtu';
        logs.Add(pcError);
        exit;
        }
      end;
    end
    else begin
      if annotationsMap.S['issue_date']<>'' then begin
        fp.SetFieldValueAsDateTime('DocDate$DATE', annotationsMap.DT8601['issue_date']);
        fp.SetFieldValueAsString('Period_ID',GetPeriodOS(OS,annotationsMap.DT8601['issue_date']));
        if NxIsEmptyOID(fp.GetFieldValueAsString('Period_ID')) then begin
          pcError:= 'Dle data vystavení nebylo v Abře dohledáno odpovídající období.';
          logs.Add(pcError);
          exit;
        end;
      end
      else begin
        fp.SetFieldValueAsDateTime('DocDate$DATE', Date);
        fp.SetFieldValueAsString('Period_ID',GetPeriodOS(OS,fp.GetFieldValueAsDateTime('DocDate$DATE')));
        {
        pcError:= 'Nebyl zaslán datum vystavení';
        logs.Add(pcError);
        exit;
        }
      end;
    end;
    if (annotationsMap.S['taxable_supply_date']<>'') and lbVATDocument then begin
      fp.SetFieldValueAsDateTime('VATAdmitDate$DATE', annotationsMap.DT8601['taxable_supply_date']);
    end;
    if annotationsMap.S['accounting_date']<>'' then begin
      fp.SetFieldValueAsDateTime('AccDate$DATE', annotationsMap.DT8601['accounting_date']);
    end;

    fp.SetFieldValueAsString('X_DigiTooInvoice_ID',annotationsMap.S['invoice_id']);
    fp.SetFieldValueAsString('X_DigitooDocumentUrl',lcDocumentURL);
    fp.SetFieldValueAsString('X_Poznamka',annotationsMap.S['note']);
    str:=trim(Copy(annotationsMap.S['description'],1,50));
    if str='' then str:=trim(Copy(annotationsMap.S['note'],1,50));
    fp.SetFieldValueAsString('Description',str);

    if (annotationsMap.S['received_date']<>'') and lbVATDocument then begin
      fp.SetFieldValueAsDateTime('VatDate$DATE', annotationsMap.DT8601['received_date']);
    end;

    if ExistujeUzaverkaDPH(OS, fp.GetFieldValueAsDateTime('VatDate$DATE')) then begin
      pcError:= 'Datum uplatnění odpočtu '+FormatDateTime('DD.MM.YYYY', fp.GetFieldValueAsDateTime('VatDate$DATE'))+' je již v Abře uzavřeno uzávěrkou DPH.';
      logs.Add(pcError);
      exit;
    end;

    fp.SetFieldValueAsFloat('RoundingAmount', GetFloatDef(annotationsMap.S['total_rounding']));

    rows:=fp.GetLoadedCollectionMonikerForFieldCode(fp.GetFieldCode('Rows'));
    try
      FromHeader:=false;
      try
        FromHeader:= annotationsMap.A['line_items'].length=0;
      except
        FromHeader:=true;
        if not pbZkracenyLog then logs.Add('Řádky se nepodařilo vytvořit, zkouším vytvořit řádek na základě údajů z hlavičky.');
      end;

      if not(FromHeader) then begin
        for i:=0 to annotationsMap.A['line_items'].length-1 do begin // radky
          SRow:=annotationsMap.A['line_items'].N[i];
          row:=rows.AddNewObject;
          row.Prefill;

          if lbVATDocument and (fp.GetFieldValueasInteger('TradeType')<>4) then begin
            // DPH
            if not NxIsEmptyOID(SRow.S['vat_code'])
            then begin
              OS.SQLSelect('SELECT VATRate_ID FROM VATIndexes WHERE ID='+QuotedStr(AnsiUpperCase(SRow.S['vat_code'])),ret);
              if ret.Count=0 then begin
                if not pbZkracenyLog then logs.Add('DPH sazba k DPH indexu nedohledána, přeskakuji.');
                row.MarkForDelete;
                continue;
              end;
              row.SetFieldValueAsString('VATRate_ID',ret[0]);
              row.SetFieldValueAsString('VATIndex_ID', AnsiUpperCase(SRow.S['vat_code']));
            end
            else begin
              case fp.GetFieldValueasInteger('TradeType') of
                2: lcFieldName:= 'OutcomeForeignEUDefVATIndex_ID';
                3: lcFieldName:= 'OutcomeForeignDefVATIndex_ID';
              else lcFieldName:= 'OutcomeDomesticDefVATIndex_ID';
              end;
              if SRow.S['tax_rate']<>'' then begin
                OS.SQLSelect('SELECT VR.ID, VR.'+lcFieldName
                +#13' FROM VATRates VR'
                +#13' JOIN COUNTRIES C ON C.ID = VR.Country_ID'
                +#13' WHERE C.ID='+QuotedStr(lmContext.GetCompanyCache.CountryID)
                +#13'       AND VR.Hidden=''N'''
                +#13'       AND VR.Tariff='+GetSQLFloat(GetFloatDef(SRow.S['tax_rate'])),ret);
                if ret.Count=0 then begin
                  if not pbZkracenyLog then logs.Add('DPH nenačteno, přeskakuji řádek.');
                  row.MarkForDelete;
                  continue;
                end;
                sqlrow.DelimitedText:= ret[0];
                lcVATRate_ID:= sqlrow[0];
                lcVATIndex_ID:= sqlrow[1];
                if not NxIsEmptyOID(headVATCode) then begin
                  if CheckIndexForVATRate(OS, headVATCode, lcVATRate_ID, fp.GetFieldValueAsInteger('TradeType'),True)
                    then lcVATIndex_ID:= headVATCode;
                end;
                if NxIsEmptyOID(lcVATIndex_ID) then begin
                  if not pbZkracenyLog then logs.Add('DPH index k DPH sazbě nedohledán, přeskakuji řádek.');
                  row.MarkForDelete;
                  continue;
                end;
                row.SetFieldValueAsString('VATRate_ID',lcVATRate_ID);
                row.SetFieldValueAsString('VATIndex_ID',lcVATIndex_ID);
              end
              else begin
                if not NxIsEmptyOID(headVATCode) then begin
                  OS.SQLSelect('SELECT VATRate_ID FROM VATIndexes WHERE ID='+QuotedStr(AnsiUpperCase(headVATCode)),ret);
                  if ret.Count=0 then begin
                    if not pbZkracenyLog then logs.Add('DPH sazba k DPH indexu nedohledána, přeskakuji.');
                    row.MarkForDelete;
                    continue;
                  end;
                  row.SetFieldValueAsString('VATRate_ID',ret[0]);
                  row.SetFieldValueAsString('VATIndex_ID', AnsiUpperCase(headVATCode));
                end
                else begin
                  // DPH neni zadano, preskakuji
                  if not pbZkracenyLog then logs.Add('DPH nenačteno, přeskakuji řádek.');
                  row.MarkForDelete;
                  continue;
                end;
              end;
            end;
          end;

          // Typ vydaje
          if not NxIsEmptyOID(AnsiUpperCase(SRow.S['account_code']))
          then begin
            row.SetFieldValueAsString('ExpenseType_ID', AnsiUpperCase(SRow.S['account_code']));
          end
          else begin
            if not NxIsEmptyOID(AnsiUpperCase(headExpenseType))
            then begin
              row.SetFieldValueAsString('ExpenseType_ID',AnsiUpperCase(headExpenseType));
            end
            else begin
              if not pbZkracenyLog then logs.Add('Typ výdaje nenačten.');
            end;
          end;

          if not NxIsEmptyOID(AnsiUpperCase(SRow.S['activity'])) then begin
            row.SetFieldValueAsString('BusTransaction_ID', AnsiUpperCase(SRow.S['activity']));
          end
          else begin
             if not NxIsEmptyOID(AnsiUpperCase(headBusTransaction))
            then begin
              row.SetFieldValueAsString('BusTransaction_ID',AnsiUpperCase(headBusTransaction));
            end
            else begin
              if not pbZkracenyLog then logs.Add('Obchodní případ nenačten.');
            end;
          end;

          // Division_ID
          if not NxIsEmptyOID(AnsiUpperCase(SRow.S['cost_center']))
          then begin
            row.SetFieldValueAsString('Division_ID', AnsiUpperCase(SRow.S['cost_center']));
          end
          else begin
            if not NxIsEmptyOID(AnsiUpperCase(headDivision))
            then begin
              row.SetFieldValueAsString('Division_ID',AnsiUpperCase(headDivision));
            end
            else begin
              if not NxIsEmptyOID(AnsiUpperCase(Def_Division_ID)) then begin
                if not pbZkracenyLog then logs.Add('Nastavuji výchozí středisko.');
                row.SetFieldValueAsString('Division_ID', AnsiUpperCase(Def_Division_ID));
              end
              else begin
                if not pbZkracenyLog then logs.Add('Středisko nenastaveno, přeskakuji řádek.');
                row.MarkForDelete;
                continue;
              end;
            end;
          end;

          // BusOrder
          if not NxIsEmptyOID(AnsiUpperCase(SRow.S['contract']))
          then begin
            row.SetFieldValueAsString('BusOrder_ID', AnsiUpperCase(SRow.S['contract']));
          end
          else begin
            if not NxIsEmptyOID(AnsiUpperCase(headBusOrder))
            then begin
              row.SetFieldValueAsString('BusOrder_ID',AnsiUpperCase(headBusOrder));
            end
            else begin
              if not pbZkracenyLog then logs.Add('Zakázka nenastavena.');
            end;
          end;

          // BusProject
          if not NxIsEmptyOID(AnsiUpperCase(SRow.S['project']))
          then begin
            row.SetFieldValueAsString('BusProject_ID', AnsiUpperCase(SRow.S['project']));
          end
          else begin
            if not NxIsEmptyOID(AnsiUpperCase(headBusProject))
            then begin
              row.SetFieldValueAsString('BusProject_ID',AnsiUpperCase(headBusProject));
            end
            else begin
              if not pbZkracenyLog then logs.Add('Projekt nenastaven.');
            end;
          end;

          // Text na radku
          strText:='';
          if SRow.S['code']<>'' then begin
            strText:=SRow.S['code'];
          end;
          if SRow.S['description']<>'' then begin
            if strText<>'' then begin
              strText:=strText+': ';
            end;
            strText:=strText+SRow.S['description'];
          end;
          row.SetFieldValueAsString('Text', Copy(strText,1,160));

          // Castka
          if GetFloatDef(SRow.S['total_base']) <> 0 then begin
            amount:= GetFloatDef(SRow.S['total_base']);
          end else begin
            q:= GetFloatDef(SRow.S['quantity']);
            if q=0 then begin
              q:=1;
            end;
            amount:=q*GetFloatDef(SRow.S['unit_base']);
          end;

          if Abs(amount)<0.000001 then begin
            if not pbZkracenyLog then logs.Add('Nulová částka na řádku, přeskakuji.');
            row.MarkForDelete;
            continue;
          end;
          row.SetFieldValueAsFloat(lcAmountFieldName, amount);
          if lbVATDocument and (SRow.S['total_tax']<>'') and (abs(row.GetFieldValueAsFloat('VATTAmount')-GetFloatDef(SRow.S['total_tax']))>0.00001)
            then row.SetFieldValueAsFloat('VATTAmount', GetFloatDef(SRow.S['total_tax']));
        end;
        if rows.CountOfNotDeleted=0 then begin
          if not pbZkracenyLog then logs.Add('Řádky se nepodařilo vytvořit, zkouším vytvořit řádek na základě údajů z hlavičky.');
          FromHeader:=true;
        end;
      end;
    except
      if not pbZkracenyLog then logs.Add('Řádky se nepodařilo vytvořit, zkouším vytvořit řádek na základě údajů z hlavičky.');
      row.MarkForDelete;
      FromHeader:=true;
    end;

    if FromHeader then begin
      // tax_detail - vytvor radky z rekapitulace
      if lbVATDocument and (fp.GetFieldValueasInteger('TradeType')<>4) then begin
        FromHeader:= False;
        try
          try
            FromHeader:= annotationsMap.A['tax_detail'].length=0;
          except
            FromHeader:=true;
            if not pbZkracenyLog then logs.Add('Rekapitulace nezadána.');
          end;

          if not(FromHeader) then begin
            annotationsMap.A['tax_detail'].length;
            logs.Add('Tvořím řádky z rekapitulace');
            for i:=0 to annotationsMap.A['tax_detail'].length-1 do begin // radky
              SRow:=annotationsMap.A['tax_detail'].N[i];
              if (SRow.S['rate']='')
                  OR ((SRow.S['base']='') AND (SRow.S['tax']=''))
              then begin
                if not pbZkracenyLog then logs.Add('Neúplné údaje na řádku rekapitulace, přeskakuji.');
                continue;
              end;
              if not pbZkracenyLog then logs.Add('Vytvářím řádek z rekapitulace.');

              row:=rows.AddNewObject;
              row.Prefill;

              if NxIsEmptyOID(AnsiUpperCase(headDivision)) then begin
                pcError:= 'Středisko na hlavičce nenastaveno, doklad nelze vytvořit.';
                logs.Add(pcError);
                exit;
              end;
              row.SetFieldValueAsString('Division_ID', AnsiUpperCase(headDivision));

              {if NxIsEmptyOID(AnsiUpperCase(headExpenseType)) then begin
                pcError:= 'Typ výdaje na hlavičce nenastaveno, doklad nelze vytvořit.';
                logs.Add(pcError);
                exit;
              end;}
              row.SetFieldValueAsString('ExpenseType_ID', AnsiUpperCase(headExpenseType));

              if not NxIsEmptyOID(AnsiUpperCase(headBusTransaction)) then begin
                row.SetFieldValueAsString('BusTransaction_ID', AnsiUpperCase(headBusTransaction));
              end;
              if not NxIsEmptyOID(AnsiUpperCase(headBusOrder)) then begin
                row.SetFieldValueAsString('BusOrder_ID', AnsiUpperCase(headBusOrder));
              end;

              if not NxIsEmptyOID(AnsiUpperCase(headBusProject)) then begin
                row.SetFieldValueAsString('BusProject_ID', AnsiUpperCase(headBusProject));
              end;

              case fp.GetFieldValueasInteger('TradeType') of
                2: lcFieldName:= 'OutcomeForeignEUDefVATIndex_ID';
                3: lcFieldName:= 'OutcomeForeignDefVATIndex_ID';
              else lcFieldName:= 'OutcomeDomesticDefVATIndex_ID';
              end;

              OS.SQLSelect('SELECT VR.ID, VR.'+lcFieldName
              +#13' FROM VATRates VR'
              +#13' JOIN COUNTRIES C ON C.ID = VR.Country_ID'
              +#13' WHERE C.ID='+QuotedStr(lmContext.GetCompanyCache.CountryID)
              +#13'       AND VR.Hidden=''N'''
              +#13'       AND VR.Tariff='+GetSQLFloat(GetFloatDef(SRow.S['rate'])),ret);
              if ret.Count=0 then begin
                if not pbZkracenyLog then logs.Add('DPH nenačteno, přeskakuji řádek.');
                row.MarkForDelete;
                continue;
              end;
              sqlrow.DelimitedText:= ret[0];
              lcVATRate_ID:= sqlrow[0];
              lcVATIndex_ID:= sqlrow[1];
              if not NxIsEmptyOID(headVATCode) then begin
                if CheckIndexForVATRate(OS, headVATCode, lcVATRate_ID, fp.GetFieldValueAsInteger('TradeType'),True)
                  then lcVATIndex_ID:= headVATCode;
              end;
              if NxIsEmptyOID(lcVATIndex_ID) then begin
                if not pbZkracenyLog then logs.Add('DPH index k DPH sazbě nedohledán, přeskakuji řádek.');
                row.MarkForDelete;
                continue;
              end;

              if ((SRow.S['rate']<>'')
                  AND
                  (SRow.S['base']<>''))
              then begin
                row.SetFieldValueAsString('VATRate_ID', lcVATRate_ID);
                row.SetFieldValueAsString('VATIndex_ID',lcVATIndex_ID);
                row.SetFieldValueAsFloat(lcAmountFieldName, GetFloatDef(SRow.S['base']));
                if lbVATDocument and (SRow.S['tax']<>'') and (abs(row.GetFieldValueAsFloat('VATTAmount')-GetFloatDef(SRow.S['tax']))>0.00001)
                  then row.SetFieldValueAsFloat('VATTAmount', GetFloatDef(SRow.S['tax']));
              end
              else begin
                if  ((SRow.S['rate']<>'')
                    AND
                    (GetFloatDef(SRow.S['rate'])<>0)
                    AND
                    (SRow.S['tax']<>''))
                then begin
                  row.SetFieldValueAsString('VATRate_ID', lcVATRate_ID);
                  row.SetFieldValueAsString('VATIndex_ID',lcVATIndex_ID);
                  row.SetFieldValueAsFloat(lcAmountFieldName, GetFloatDef(SRow.S['tax'])/(GetFloatDef(SRow.S['rate'])/100));
                  if lbVATDocument and (SRow.S['tax']<>'') and (abs(row.GetFieldValueAsFloat('VATTAmount')-GetFloatDef(SRow.S['tax']))>0.00001)
                    then row.SetFieldValueAsFloat('VATTAmount', GetFloatDef(SRow.S['tax']));
                end;
              end;
              row.SetFieldValueAsString('Text', Copy(annotationsMap.S['description'],1,160));
            end;

            if rows.CountOfNotDeleted=0 then begin
              pcError:= 'Řádky se nepodařilo založil z rekapitulace, přeskakuji.';
              logs.Add(pcError);
              exit;
            end;
          end;
        except
          pcError:= 'Rekapitulace nezadána. '+ExceptionMessage;
          logs.Add(pcError);
          exit;
        end;
      end;
    end;

    if FromHeader then begin
      // Vytvarim novy radek z hlavicky
      row:=rows.AddNewObject;
      row.Prefill;

      if lbVATDocument and (fp.GetFieldValueasInteger('TradeType')<>4) then begin
        if NxIsEmptyOID(headVATCode) then begin
          pcError:= 'DPH na hlavičce nenastaveno, doklad nelze vytvořit.';
          logs.Add(pcError);
          exit;
        end;

        OS.SQLSelect('SELECT VATRate_ID FROM VATIndexes WHERE ID='+QuotedStr(AnsiUpperCase(headVATCode)),ret);
        if ret.Count=0 then begin
          pcError:= 'DPH sazba k DPH indexu nedohledána, přeskakuji.';
          logs.Add(pcError);
          exit;
        end;
        row.SetFieldValueAsString('VATRate_ID',ret[0]);
        row.SetFieldValueAsString('VATIndex_ID', AnsiUpperCase(headVATCode));
      end;

      if not NxIsEmptyOID(AnsiUpperCase(headBusTransaction)) then begin
        row.SetFieldValueAsString('BusTransaction_ID', AnsiUpperCase(headBusTransaction));
      end;

      {if NxIsEmptyOID(AnsiUpperCase(headExpenseType)) then begin
        pcError:= 'Typ výdaje na hlavičce nenastaveno, doklad nelze vytvořit.';
        logs.Add(pcError);
        exit;
      end;}
      row.SetFieldValueAsString('ExpenseType_ID', AnsiUpperCase(headExpenseType));

      if NxIsEmptyOID(AnsiUpperCase(headDivision)) then begin
        pcError:= 'Středisko na hlavičce nenastaveno, doklad nelze vytvořit.';
        logs.Add(pcError);
        exit;
      end;
      row.SetFieldValueAsString('Division_ID', AnsiUpperCase(headDivision));
      {
      if NxIsEmptyOID(headBusOrder) then begin
        logs.Add('Zakázka na hlavičce nenastavena, doklad nelze vytvořit.');
        exit;
      end;
      }
      if not NxIsEmptyOID(AnsiUpperCase(headBusOrder)) then begin
        row.SetFieldValueAsString('BusOrder_ID', AnsiUpperCase(headBusOrder));
      end;

      if not NxIsEmptyOID(AnsiUpperCase(headBusProject)) then begin
        row.SetFieldValueAsString('BusProject_ID', AnsiUpperCase(headBusProject));
      end;

      row.SetFieldValueAsString('Text', Copy(annotationsMap.S['description'],1,160));
      row.SetFieldValueAsFloat(lcAmountFieldName, GetFloatDef(annotationsMap.S['total_base']));
      if lbVATDocument and (annotationsMap.S['total_tax']<>'') and (abs(row.GetFieldValueAsFloat('VATTAmount')-GetFloatDef(annotationsMap.S['total_tax']))>0.00001)
        then row.SetFieldValueAsFloat('VATTAmount', GetFloatDef(annotationsMap.S['total_tax']));
    end;

    // kurz
    if (annotationsMap.S['exchange_rate']<>'') and (AnsiUpperCase(fp.GetFieldValueasString('Currency_ID.Code'))<>'CZK') then begin
      fp.SetFieldValueAsFloat('CurrRate',GetFloatDef(annotationsMap.S['exchange_rate']));
    end;

    if not pbZkracenyLog then logs.Add('Ukládám');
    try
      if not fp.Validate then begin
        pcError:= 'Chyba při validaci pokladního výdeje: '+GetValidateErrs(fp);
        logs.Add(pcError);
      end
      else begin
        fp.Save;
        FP_ID:=fp.OID;
        lcFP_Name:= fp.DisplayName;
        logs.Add('Vytvořeno: '+lcFP_Name);
      end;

      //logs.Add('Def_Doc_DQ_ID: '+Def_Doc_DQ_ID);
      //logs.Add('Def_Doc_DC_ID: '+Def_Doc_DC_ID);
    except
      pcError:= 'Neočekávaná chyba při ukládání pokladního výdeje: '+ExceptionMessage;
      logs.Add(pcError);
    end;

    if not NxIsEmptyOID(FP_ID) then begin
      try
        // FILE
        if (not NxIsEmptyOID(Def_Doc_DQ_ID)) AND (not NxIsEmptyOID(Def_Doc_DC_ID))
        then begin
          str:= downloadFile(OS, '06', Document_ID, fp.OID, Firm_ID, Def_Doc_DQ_ID, Def_Doc_DC_ID, AUTH_TOKEN, pcQueue_ID, lcDigitooSourceFileName);
          if str<>'' then logs.Add('Došlo k chybě při stažení PDF dokladu: '+str);
        end
        else begin
          logs.Add('Vyplňte v agendě typ a řadu pro přílohu.');
        end;
      except
        logs.Add('Chyba při stahování PDF: '+ExceptionMessage);
      end;
      if pbImportAllAttachments then begin  //přílohy
        try
          if (not NxIsEmptyOID(Def_Doc_DQ_ID)) AND (not NxIsEmptyOID(Def_Doc_DC_ID))
            then downloadAttachments(OS, '06', Document_ID, fp.OID, Firm_ID, Def_Doc_DQ_ID, Def_Doc_DC_ID, AUTH_TOKEN, logs);
        except
          logs.Add('Chyba při stahování příloh: '+ExceptionMessage);
        end;
      end;
      if pbImportDates then begin  //časová razítka
        try
          GetTimeStamps(OS, '06', Document_ID, fp.OID, AUTH_TOKEN, logs, pbZkracenyLog);
        except
          logs.Add('Chyba při stahování časových razítek: '+ExceptionMessage);
        end;
      end;
    end;
  finally
    Result:= lcFP_Name;
    fp.Free;
    ret.Free;
    sqlRow.Free;
    lmContext.Free
  end;
end;

function CreateOSV(OS:TNxCustomObjectSpace;
                   jsonObj:TJSONSuperObject;
                   logs:TStrings;
                   Def_Firm_ID, Def_Division_ID,
                   Def_Doc_DQ_ID, Def_Doc_DC_ID, AUTH_TOKEN, Document_ID, pcQueue_ID: string;
                   pbImportAllAttachments: boolean;
                   pbDoNotUpdateFirms, pbImportDates: boolean;
                   var pcError: string;
                   pbOrgIdentNumberCheck: boolean;
                   pbZkracenyLog: boolean):string;
var
  ret, sqlRow: TStringList;
  fp, row, firm, bankAcc, obj, loAddress: TNxCustomBusinessObject;
  rows, rows2: TNxCustomBusinessMonikerCollection;
  annotationsMap, SRow: TJSONSuperObject;
  i: Integer;
  Err, Firm_ID, Division_ID, SQL, FP_ID, headVATCode, lcFP_Name, lcFieldName
  , headDivision, headBusOrder, selectedVAT, FirmBankAccount, FirmBankAccount_ID, lcVATIndex_ID, lcVATRate_ID
  , note, DQ_ID, headKontace, headExpenseType, headBusTransaction, strText, str, lcDocumentURL, lcCurrency_ID
  , lcICO, lcDIC, lcFirmName, lcCountry_ID, lcCountry_Code, lcElementName, lcAmountFieldName, headBusProject
  , lcCountry, lcSQL, lcIBAN, lcStreet, lcCity, lcPostCode, lcDigitooSourceFileName, lcSwiftCode, lcICDPH: string;
  amount, q: Double;
  FromHeader, lbVATDocument: Boolean;
  lmContext: TNxContext;
begin
  Result:= '';
  FP_ID:= '';
  lcFP_Name:= '';
  pcError:= '';
  Err:='';

  lmContext:= NxCreateContext(OS);
  ret:=TStringList.Create;
  sqlRow:=TStringList.Create;
  sqlRow.Delimiter:=';';
  fp:=OS.CreateObject(Class_OtherExpense);
  try

    if AnsiUpperCase(jsonObj.S['status'])<>'READY-TO-EXPORT' then begin
      pcError:= 'Nepodporovaný status dokladu, přeskakuji.';
      logs.Add(pcError);
      exit;
    end;

    annotationsMap:= jsonObj.O['annotations'];

    lcDocumentURL:= jsonObj.S['document_url'];
    if lcDocumentURL='' then lcDocumentURL:= jsonObj.S['id'];
    lcDigitooSourceFileName:= jsonObj.S['file_name'];

    DQ_ID:= AnsiUpperCase(annotationsMap.S['accounting_sequence']);
    if NxIsEmptyOID(DQ_ID) then begin
      pcError:= 'Řada dokladu nezadána.';
      logs.Add(pcError);
      exit;
    end;

    try
      if pbOrgIdentNumberCheck then begin
        if (Trim(annotationsMap.S['recipient_register_id'])<>'')
            and (lmContext.GetCompanyCache.OrgIdentNumber<>'')
            and (Trim(annotationsMap.S['recipient_register_id'])<>lmContext.GetCompanyCache.OrgIdentNumber) then begin
          pcError:= 'IČO odběratele na dokladu neodpovídá IČO ve firemních údajích v Abře.';
          logs.Add(pcError);
          exit;
        end;
      end;
    except
    end;

    // Udaje z hlavičky, maji prednost na radcich
    headVATCode:=AnsiUpperCase(annotationsMap.S['vat_code']);
    headKontace:=AnsiUpperCase(annotationsMap.S['assignment']);
    headDivision:=AnsiUpperCase(annotationsMap.S['cost_center']);
    headBusOrder:=AnsiUpperCase(annotationsMap.S['contract']);
    headBusProject:=AnsiUpperCase(annotationsMap.S['project']);
    headExpenseType:=AnsiUpperCase(annotationsMap.S['account_code']);
    headBusTransaction:=AnsiUpperCase(annotationsMap.S['activity']); // obchodni pripad na hlavicce
    lcAmountFieldName:= 'TAmountWithoutVAT';

    fp.New;
    fp.Prefill;

    lbVATDocument:= IsVATDocument(annotationsMap);

    fp.SetFieldValueAsBoolean('VATDocument', lbVATDocument);

    // Firma - povinna polozka - dohledava se dle ICO
    lcICO:= NxLeft(Trim(annotationsMap.S['sender_register_id']),15);
    lcDIC:= NxLeft(Trim(annotationsMap.S['sender_tax_id']),20);
    lcICDPH:= NxLeft(Trim(annotationsMap.S['sender_vat_id']),20);
    lcFirmName:= NxLeft(Trim(annotationsMap.S['sender_name']),220);
    Firm_ID:= '';
    try
      Firm_ID:= Trim(annotationsMap.S['sender_internal_id']);
      if NxIsEmptyOID(Firm_ID) then Firm_ID:= '';
    except
    end;
    if NxIsEmptyOID(Firm_ID) then begin
      if not GetFirm_ID(OS, lcICO, lcDIC, lcICDPH, lcFirmName, NxLeft(Trim(annotationsMap.S['sender_address']),255),
                        NxLeft(Trim(annotationsMap.S['sender_street']),60),
                        NxLeft(Trim(annotationsMap.S['sender_city']),60),
                        NxLeft(Trim(annotationsMap.S['sender_post_code']),10),
                        Trim(annotationsMap.S['sender_country']),
                        logs, pbDoNotUpdateFirms, pcError, Firm_ID) then exit;
    end
    else begin
      if not pbZkracenyLog then logs.Add('Nastavuji zaslanou firmu "'+GetData(OS,'Firms','ID',Firm_ID,'Name')+'".');
    end;

    // měna
    if annotationsMap.S['currency']<>'' then begin
      //logs.Add('Hledám měnu.');
      OS.SQLSelect('SELECT ID FROM Currencies WHERE Upper(Code)='+QuotedStr(AnsiUpperCase(annotationsMap.S['currency'])),ret);
      if ret.count>0 then
      begin
        lcCurrency_ID:= ret[0];
        if not pbZkracenyLog then logs.Add('Nastavuji měnu.');
        fp.SetFieldValueAsString('Currency_ID', lcCurrency_ID);
      end else begin
        if not pbZkracenyLog then logs.Add('Měna nedohledána.');
      end;
    end;

    if (NxIsEmptyOID(Firm_ID)) AND (not NxIsEmptyOID(Def_Firm_ID))
    then begin
      Firm_ID:=Def_Firm_ID;
      if not pbZkracenyLog then logs.Add('Nastavuji výchozí firmu.');
    end;

    if NxIsEmptyOID(Firm_ID)
    then begin
      pcError:= 'Firmu se nepodařilo nastavit, přeskakuji.';
      logs.Add(pcError);
      exit;
    end;

    fp.SetFieldValueAsString('DocQueue_ID',DQ_ID);
    // Kontace
    if not NxIsEmptyOID(headKontace) then begin
      fp.SetFieldValueAsString('AccPresetDef_ID',headKontace);
    end;

    fp.SetFieldValueAsString('Firm_ID', Firm_ID);
    if not NxIsEmptyOID(lcCurrency_ID) then fp.SetFieldValueAsString('Currency_ID', lcCurrency_ID);
    fp.SetFieldValueAsString('ExternalNumber',trim(Copy(annotationsMap.S['invoice_id'],1,30)));
    if fp.GetFieldValueAsString('ExternalNumber')<>'' then begin
      lcSQL:= 'Select A.ID'
          +#13' from OtherExpenses A'
          +#13' join Firms F on F.ID=A.Firm_ID'
          +#13' where coalesce(F.Firm_ID,F.ID)='+QuotedStr(NxIIfStr(not NxIsEmptyOID(fp.GetFieldValueAsString('Firm_ID.Firm_ID')),fp.GetFieldValueAsString('Firm_ID.Firm_ID'),fp.GetFieldValueAsString('Firm_ID')))
          +#13'       and Upper(A.ExternalNumber)='+QuotedStr(AnsiUpperCase(fp.GetFieldValueAsString('ExternalNumber')));
      OS.SQLSelect(lcSQL, ret);
      if ret.Count>0 then begin
        pcError:= 'Pro firmu "'+fp.GetFieldValueAsString('Firm_ID.Name')+'" již existuje ostatní výdaj s externím číslem "'+fp.GetFieldValueAsString('ExternalNumber')+'", přeskakuji.';
        logs.Add(pcError);
        exit;
      end;
    end;

    if lbVATDocument then begin
      if annotationsMap.S['trade_code'] in ['1',''] then begin
        fp.SetFieldValueAsInteger('DataEntryKind', 0);
      end
      else begin
        lcAmountFieldName:= 'TAmount';
      end;
    end
    else begin
      lcAmountFieldName:= 'TAmount';
    end;

    if annotationsMap.S['trade_code'] in ['2','3','4'] then begin
      lcCountry_Code:= '';
      try
        lcCountry_Code:= NxIifStr(Length(Trim(annotationsMap.S['sender_country']))=10,GetData(OS, 'Countries', 'ID', Trim(annotationsMap.S['sender_country']), 'Code'), NxLeft(Trim(annotationsMap.S['sender_country']),3));
      except
      end;
      if lcCountry_Code='' then lcCountry_Code:= NxLeft(fp.GetFieldValueAsString('Firm_ID.ResidenceAddress_ID.CountryCode'),2);
      if lcCountry_Code='' then lcCountry_Code:= NxLeft(fp.GetFieldValueAsString('Firm_ID.VATIdentNumber'),2);
      if lcCountry_Code='' then lcCountry_Code:= NxLeft(lcDIC,2);
      lcCountry_Code:= AnsiUpperCase(lcCountry_Code);
      lcCountry_ID:= GetData(OS, 'Countries', 'Code', lcCountry_Code, 'ID', True, 'Hidden=''N''');
      if not NxIsEmptyOID(lcCountry_ID) then begin
        fp.SetFieldValueAsString('Country_ID', lcCountry_ID);
        if not NxIsEmptyOID(lcCurrency_ID) then fp.SetFieldValueAsString('Currency_ID', lcCurrency_ID);
      end;
    end;

    if lmContext.GetCompanyCache.OrgIdentNumber='26230224' then begin  //Magsy to chce jinak (dle Data uplatnění odpočtu)
      if annotationsMap.S['received_date']<>'' then begin
        fp.SetFieldValueAsDateTime('DocDate$DATE', annotationsMap.DT8601['received_date']);
        fp.SetFieldValueAsString('Period_ID',GetPeriodOS(OS,annotationsMap.DT8601['received_date']));
        if NxIsEmptyOID(fp.GetFieldValueAsString('Period_ID')) then begin
          pcError:= 'Dle data uplatnění odpočtu nebylo v Abře dohledáno odpovídající období.';
          logs.Add(pcError);
          exit;
        end;
      end
      else begin
        fp.SetFieldValueAsDateTime('DocDate$DATE', Date);
        fp.SetFieldValueAsString('Period_ID',GetPeriodOS(OS,fp.GetFieldValueAsDateTime('DocDate$DATE')));
        {
        pcError:= 'Nebyl zaslán datum uplatnění odpočtu';
        logs.Add(pcError);
        exit;
        }
      end;
    end
    else begin
      if annotationsMap.S['issue_date']<>'' then begin
        fp.SetFieldValueAsDateTime('DocDate$DATE', annotationsMap.DT8601['issue_date']);
        fp.SetFieldValueAsString('Period_ID',GetPeriodOS(OS,annotationsMap.DT8601['issue_date']));
        if NxIsEmptyOID(fp.GetFieldValueAsString('Period_ID')) then begin
          pcError:= 'Dle data vystavení nebylo v Abře dohledáno odpovídající období.';
          logs.Add(pcError);
          exit;
        end;
      end
      else begin
        fp.SetFieldValueAsDateTime('DocDate$DATE', Date);
        fp.SetFieldValueAsString('Period_ID',GetPeriodOS(OS,fp.GetFieldValueAsDateTime('DocDate$DATE')));
        {
        pcError:= 'Nebyl zaslán datum vystavení';
        logs.Add(pcError);
        exit;
        }
      end;
    end;
    if (annotationsMap.S['taxable_supply_date']<>'') and lbVATDocument then begin
      fp.SetFieldValueAsDateTime('VATAdmitDate$DATE', annotationsMap.DT8601['taxable_supply_date']);
    end;
    if annotationsMap.S['accounting_date']<>'' then begin
      fp.SetFieldValueAsDateTime('AccDate$DATE', annotationsMap.DT8601['accounting_date']);
    end;

    fp.SetFieldValueAsString('X_DigiTooInvoice_ID',annotationsMap.S['invoice_id']);
    fp.SetFieldValueAsString('X_DigitooDocumentUrl',lcDocumentURL);
    fp.SetFieldValueAsString('VarSymbol',annotationsMap.S['var_sym']);
    fp.SetFieldValueAsString('X_Poznamka',annotationsMap.S['note']);
    str:=trim(Copy(annotationsMap.S['description'],1,50));
    if str='' then str:=trim(Copy(annotationsMap.S['note'],1,50));
    fp.SetFieldValueAsString('Description',str);

    if (annotationsMap.S['received_date']<>'') and lbVATDocument then begin
      fp.SetFieldValueAsDateTime('VatDate$DATE', annotationsMap.DT8601['received_date']);
    end;

    if ExistujeUzaverkaDPH(OS, fp.GetFieldValueAsDateTime('VatDate$DATE')) then begin
      pcError:= 'Datum uplatnění odpočtu  '+FormatDateTime('DD.MM.YYYY', fp.GetFieldValueAsDateTime('VatDate$DATE'))+' je již v Abře uzavřeno uzávěrkou DPH.';
      logs.Add(pcError);
      exit;
    end;

    if annotationsMap.S['due_date']<>'' then begin
      fp.SetFieldValueAsDateTime('DueDate$DATE', annotationsMap.DT8601['due_date']);
    end;
    fp.SetFieldValueAsFloat('RoundingAmount', GetFloatDef(annotationsMap.S['total_rounding']));

    // Bankovni ucet
    FirmBankAccount:= '';
    try
      if annotationsMap.A['bank_account'].length>0 then begin
        FirmBankAccount:= StringReplace(AnsiUpperCase(trim(annotationsMap.A['bank_account'].S[0])),' ','',[rfReplaceAll]);
      end;
    except
      if FirmBankAccount='' then FirmBankAccount:= StringReplace(AnsiUpperCase(trim(annotationsMap.S['bank_account'])),' ','',[rfReplaceAll]);
    end;
    lcIBAN:= '';
    try
      if annotationsMap.A['iban'].length>0 then begin
        lcIBAN:= StringReplace(AnsiUpperCase(trim(annotationsMap.A['iban'].S[0])),' ','',[rfReplaceAll]);
      end;
    except
      if lcIBAN='' then lcIBAN:= StringReplace(AnsiUpperCase(trim(annotationsMap.S['iban'])),' ','',[rfReplaceAll]);
    end;
    lcSwiftCode:= '';
    try
      if annotationsMap.A['bic'].length>0 then begin
        lcSwiftCode:= StringReplace(AnsiUpperCase(trim(annotationsMap.A['bic'].S[0])),' ','',[rfReplaceAll]);
      end;
    except
      if lcSwiftCode='' then lcSwiftCode:= StringReplace(AnsiUpperCase(trim(annotationsMap.S['bic'])),' ','',[rfReplaceAll]);
    end;
    if (FirmBankAccount<>'') or (lcIBAN<>'') then begin
      ret.Clear;
      SQL:='SELECT ID'
       +#13' FROM FirmBankAccounts'
       +#13' WHERE ('+NxIIfStr(FirmBankAccount<>'','Upper(Replace(BankAccount,'' '',''''))='+QuotedStr(FirmBankAccount),'')
       +#13'       '+NxIIfStr(lcIBAN<>'',NxIifStr(FirmBankAccount<>'','or','')+' (Upper(Replace(BankAccount,'' '',''''))='+QuotedStr(lcIBAN),'')
       +#13'       '+NxIIfStr((lcIBAN<>'') and (lcSwiftCode<>''),' and Upper(Replace(SwiftCode,'' '',''''))='+QuotedStr(lcSwiftCode)+')',NxIIfStr(lcIBAN<>'',')',''))+')'
       +#13'       and Parent_ID='+QuotedStr(Firm_ID);
      OS.SQLSelect(SQL, ret);
      if ret.Count>0 then begin
        FirmBankAccount_ID:= ret[0];
        if not NxIsEmptyOID(FirmBankAccount_ID) then
        begin
          fp.SetFieldValueAsString('FirmBankAccount_ID', FirmBankAccount_ID);
          if not pbZkracenyLog then logs.Add('Nastavuji bankovní účet.');
        end;
      end
      else begin
        if pbDoNotUpdateFirms then begin
          pcError:= 'Bankovní účet nelze založit, není povoleno přidávat nové bankovní účty k firmám v Abře.';
          logs.Add(pcError);
          exit;
        end
        else begin
          // v pripade, ze neni vybrana vychozi firma
          if Firm_ID<>Def_Firm_ID then begin
            firm:=OS.CreateObject(Class_Firm);
            try
              firm.Load(Firm_ID,nil);
              rows2:=firm.GetLoadedCollectionMonikerForFieldCode(firm.GetFieldCode('Rows'));
              bankAcc:=rows2.AddNewObject;
              bankAcc.Prefill;
              bankAcc.SetFieldValueAsString('BankAccount', NxIifStr((FirmBankAccount='') or ((lcIBAN<>'') and (NxLeft(lcIBAN,2)<>'CZ')),lcIBAN,FirmBankAccount));
              if (lcSwiftCode<>'') and (lcIBAN<>'') and ((FirmBankAccount='') or (NxLeft(lcIBAN,2)<>'CZ')) then bankAcc.SetFieldValueAsString('SwiftCode', lcSwiftCode);
              FirmBankAccount_ID:=bankAcc.OID;
              try
                firm.Save;
                fp.SetFieldValueAsString('FirmBankAccount_ID', FirmBankAccount_ID);
                if not pbZkracenyLog then logs.Add('Nastavuji bankovní účet.');
              except
                if not pbZkracenyLog then logs.Add('Bankovní účet nelze založit: '+ExceptionMessage);
              end;
            finally
              firm.Free;
            end;
          end
          else begin
            // Nemuzu zakladat
            if not pbZkracenyLog then logs.Add('Bankovní účet nelze založit, je vybrána výchozí firma.');
          end;
        end;
      end;
    end;

    rows:=fp.GetLoadedCollectionMonikerForFieldCode(fp.GetFieldCode('Rows'));
    try
      FromHeader:=false;
      try
        FromHeader:= annotationsMap.A['line_items'].length=0;
      except
        FromHeader:=true;
        if not pbZkracenyLog then logs.Add('Řádky se nepodařilo vytvořit, zkouším vytvořit řádek na základě údajů z hlavičky.');
      end;

      if not(FromHeader) then begin
        for i:=0 to annotationsMap.A['line_items'].length-1 do begin // radky
          SRow:=annotationsMap.A['line_items'].N[i];
          row:=rows.AddNewObject;
          row.Prefill;

          if lbVATDocument then begin
            // DPH
            if not NxIsEmptyOID(SRow.S['vat_code'])
            then begin
              OS.SQLSelect('SELECT VATRate_ID FROM VATIndexes WHERE ID='+QuotedStr(AnsiUpperCase(SRow.S['vat_code'])),ret);
              if ret.Count=0 then begin
                if not pbZkracenyLog then logs.Add('DPH sazba k DPH indexu nedohledána, přeskakuji.');
                row.MarkForDelete;
                continue;
              end;
              row.SetFieldValueAsString('VATRate_ID',ret[0]);
              row.SetFieldValueAsString('VATIndex_ID', AnsiUpperCase(SRow.S['vat_code']));
            end
            else begin
              case annotationsMap.S['trade_code'] of
                '2': lcFieldName:= 'OutcomeForeignEUDefVATIndex_ID';
                '3': lcFieldName:= 'OutcomeForeignDefVATIndex_ID';
              else lcFieldName:= 'OutcomeDomesticDefVATIndex_ID';
              end;
              if SRow.S['tax_rate']<>'' then begin
                OS.SQLSelect('SELECT VR.ID, VR.'+lcFieldName
                +#13' FROM VATRates VR'
                +#13' JOIN COUNTRIES C ON C.ID = VR.Country_ID'
                +#13' WHERE C.ID='+QuotedStr(lmContext.GetCompanyCache.CountryID)
                +#13'       AND VR.Hidden=''N'''
                +#13'       AND VR.Tariff='+GetSQLFloat(GetFloatDef(SRow.S['tax_rate'])),ret);
                if ret.Count=0 then begin
                  if not pbZkracenyLog then logs.Add('DPH nenačteno, přeskakuji řádek.');
                  row.MarkForDelete;
                  continue;
                end;
                sqlrow.DelimitedText:= ret[0];
                lcVATRate_ID:= sqlrow[0];
                lcVATIndex_ID:= sqlrow[1];
                if not NxIsEmptyOID(headVATCode) then begin
                  if CheckIndexForVATRate(OS, headVATCode, lcVATRate_ID, NxIIfInt(fp.GetFieldValueAsString('Country_ID')=lmContext.GetCompanyCache.CountryID,1,3),True)
                    then lcVATIndex_ID:= headVATCode;
                end;
                if NxIsEmptyOID(lcVATIndex_ID) then begin
                  if not pbZkracenyLog then logs.Add('DPH index k DPH sazbě nedohledán, přeskakuji řádek.');
                  row.MarkForDelete;
                  continue;
                end;
                row.SetFieldValueAsString('VATRate_ID',lcVATRate_ID);
                row.SetFieldValueAsString('VATIndex_ID',lcVATIndex_ID);
              end
              else begin
                if not NxIsEmptyOID(headVATCode) then begin
                  OS.SQLSelect('SELECT VATRate_ID FROM VATIndexes WHERE ID='+QuotedStr(AnsiUpperCase(headVATCode)),ret);
                  if ret.Count=0 then begin
                    if not pbZkracenyLog then logs.Add('DPH sazba k DPH indexu nedohledána, přeskakuji.');
                    row.MarkForDelete;
                    continue;
                  end;
                  row.SetFieldValueAsString('VATRate_ID',ret[0]);
                  row.SetFieldValueAsString('VATIndex_ID', AnsiUpperCase(headVATCode));
                end
                else begin
                  // DPH neni zadano, preskakuji
                  if not pbZkracenyLog then logs.Add('DPH nenačteno, přeskakuji řádek.');
                  row.MarkForDelete;
                  continue;
                end;
              end;
            end;
          end;

          // Typ vydaje
          if not NxIsEmptyOID(SRow.S['account_code'])
          then begin
            row.SetFieldValueAsString('ExpenseType_ID', AnsiUpperCase(SRow.S['account_code']));
          end
          else begin
            if not NxIsEmptyOID(AnsiUpperCase(headExpenseType))
            then begin
              row.SetFieldValueAsString('ExpenseType_ID',AnsiUpperCase(headExpenseType));
            end
            else begin
              if not pbZkracenyLog then logs.Add('Typ výdaje nenačten.');
            end;
          end;

          if not NxIsEmptyOID(AnsiUpperCase(SRow.S['activity'])) then begin
            row.SetFieldValueAsString('BusTransaction_ID', AnsiUpperCase(SRow.S['activity']));
          end
          else begin
             if not NxIsEmptyOID(AnsiUpperCase(headBusTransaction))
            then begin
              row.SetFieldValueAsString('BusTransaction_ID',AnsiUpperCase(headBusTransaction));
            end
            else begin
              if not pbZkracenyLog then logs.Add('Obchodní případ nenačten.');
            end;
          end;

          // Division_ID
          if not NxIsEmptyOID(AnsiUpperCase(SRow.S['cost_center']))
          then begin
            row.SetFieldValueAsString('Division_ID', AnsiUpperCase(SRow.S['cost_center']));
          end
          else begin
            if not NxIsEmptyOID(AnsiUpperCase(headDivision))
            then begin
              row.SetFieldValueAsString('Division_ID',AnsiUpperCase(headDivision));
            end
            else begin
              if not NxIsEmptyOID(AnsiUpperCase(Def_Division_ID)) then begin
                if not pbZkracenyLog then logs.Add('Nastavuji výchozí středisko.');
                row.SetFieldValueAsString('Division_ID', AnsiUpperCase(Def_Division_ID));
              end
              else begin
                if not pbZkracenyLog then logs.Add('Středisko nenastaveno, přeskakuji řádek.');
                row.MarkForDelete;
                continue;
              end;
            end;
          end;

          // BusOrder
          if not NxIsEmptyOID(AnsiUpperCase(SRow.S['contract']))
          then begin
            row.SetFieldValueAsString('BusOrder_ID', AnsiUpperCase(SRow.S['contract']));
          end
          else begin
            if not NxIsEmptyOID(AnsiUpperCase(headBusOrder))
            then begin
              row.SetFieldValueAsString('BusOrder_ID',AnsiUpperCase(headBusOrder));
            end
            else begin
              if not pbZkracenyLog then logs.Add('Zakázka nenastavena.');
            end;
          end;

          // BusProject
          if not NxIsEmptyOID(AnsiUpperCase(SRow.S['project']))
          then begin
            row.SetFieldValueAsString('BusProject_ID', AnsiUpperCase(SRow.S['project']));
          end
          else begin
            if not NxIsEmptyOID(AnsiUpperCase(headBusProject))
            then begin
              row.SetFieldValueAsString('BusProject_ID',AnsiUpperCase(headBusProject));
            end
            else begin
              if not pbZkracenyLog then logs.Add('Projekt nenastaven.');
            end;
          end;

          // Text na radku
          strText:='';
          if SRow.S['code']<>'' then begin
            strText:=SRow.S['code'];
          end;
          if SRow.S['description']<>'' then begin
            if strText<>'' then begin
              strText:=strText+': ';
            end;
            strText:=strText+SRow.S['description'];
          end;
          row.SetFieldValueAsString('Text', Copy(strText,1,160));

          // Castka
          if GetFloatDef(SRow.S['total_base'])<> 0 then begin
            amount:= GetFloatDef(SRow.S['total_base']);
          end else begin
            q:= GetFloatDef(SRow.S['quantity']);
            if q=0 then begin
              q:=1;
            end;
            amount:=q*GetFloatDef(SRow.S['unit_base']);
          end;

          if Abs(amount)<0.000001 then begin
            if not pbZkracenyLog then logs.Add('Nulová částka na řádku, přeskakuji.');
            row.MarkForDelete;
            continue;
          end;
          row.SetFieldValueAsFloat(lcAmountFieldName, amount);
          if lbVATDocument and (SRow.S['total_tax']<>'') and (abs(row.GetFieldValueAsFloat('VATTAmount')-GetFloatDef(SRow.S['total_tax']))>0.00001)
            then row.SetFieldValueAsFloat('VATTAmount', GetFloatDef(SRow.S['total_tax']));
        end;
        if rows.CountOfNotDeleted=0 then begin
          if not pbZkracenyLog then logs.Add('Řádky se nepodařilo vytvořit, zkouším vytvořit řádek na základě údajů z hlavičky.');
          FromHeader:=true;
        end;
      end;
    except
      if not pbZkracenyLog then logs.Add('Řádky se nepodařilo vytvořit, zkouším vytvořit řádek na základě údajů z hlavičky.');
      row.MarkForDelete;
      FromHeader:=true;
    end;

    if FromHeader then begin
      // tax_detail - vytvor radky z rekapitulace
      if lbVATDocument then begin
        FromHeader:= False;
        try
          try
            FromHeader:= annotationsMap.A['tax_detail'].length=0;
          except
            FromHeader:=true;
            if not pbZkracenyLog then logs.Add('Rekapitulace nezadána.');
          end;

          if not(FromHeader) then begin
            annotationsMap.A['tax_detail'].length;
            logs.Add('Tvořím řádky z rekapitulace');
            for i:=0 to annotationsMap.A['tax_detail'].length-1 do begin // radky
              SRow:=annotationsMap.A['tax_detail'].N[i];
              if (SRow.S['rate']='')
                  OR ((SRow.S['base']='') AND (SRow.S['tax']=''))
              then begin
                if not pbZkracenyLog then logs.Add('Neúplné údaje na řádku rekapitulace, přeskakuji.');
                continue;
              end;
              if not pbZkracenyLog then logs.Add('Vytvářím řádek z rekapitulace.');

              row:=rows.AddNewObject;
              row.Prefill;

              if NxIsEmptyOID(AnsiUpperCase(headDivision)) then begin
                pcError:= 'Středisko na hlavičce nenastaveno, doklad nelze vytvořit.';
                logs.Add(pcError);
                exit;
              end;
              row.SetFieldValueAsString('Division_ID', AnsiUpperCase(headDivision));

              {if NxIsEmptyOID(AnsiUpperCase(headExpenseType)) then begin
                pcError:= 'Typ výdaje na hlavičce nenastaveno, doklad nelze vytvořit.';
                logs.Add(pcError);
                exit;
              end;}
              row.SetFieldValueAsString('ExpenseType_ID', AnsiUpperCase(headExpenseType));

              if not NxIsEmptyOID(AnsiUpperCase(headBusTransaction)) then begin
                row.SetFieldValueAsString('BusTransaction_ID', AnsiUpperCase(headBusTransaction));
              end;
              if not NxIsEmptyOID(AnsiUpperCase(headBusOrder)) then begin
                row.SetFieldValueAsString('BusOrder_ID', AnsiUpperCase(headBusOrder));
              end;

              if not NxIsEmptyOID(AnsiUpperCase(headBusProject)) then begin
                row.SetFieldValueAsString('BusProject_ID', AnsiUpperCase(headBusProject));
              end;

              case annotationsMap.S['trade_code'] of
                '2': lcFieldName:= 'OutcomeForeignEUDefVATIndex_ID';
                '3': lcFieldName:= 'OutcomeForeignDefVATIndex_ID';
              else lcFieldName:= 'OutcomeDomesticDefVATIndex_ID';
              end;

              OS.SQLSelect('SELECT VR.ID, VR.'+lcFieldName
              +#13' FROM VATRates VR'
              +#13' JOIN COUNTRIES C ON C.ID = VR.Country_ID'
              +#13' WHERE C.ID='+QuotedStr(lmContext.GetCompanyCache.CountryID)
              +#13'       AND VR.Hidden=''N'''
              +#13'       AND VR.Tariff='+GetSQLFloat(GetFloatDef(SRow.S['rate'])),ret);
              if ret.Count=0 then begin
                if not pbZkracenyLog then logs.Add('DPH nenačteno, přeskakuji řádek.');
                row.MarkForDelete;
                continue;
              end;
              sqlrow.DelimitedText:= ret[0];
              lcVATRate_ID:= sqlrow[0];
              lcVATIndex_ID:= sqlrow[1];
              if not NxIsEmptyOID(headVATCode) then begin
                if CheckIndexForVATRate(OS, headVATCode, lcVATRate_ID, NxIIfInt(fp.GetFieldValueAsString('Country_ID')=lmContext.GetCompanyCache.CountryID,1,3),True)
                  then lcVATIndex_ID:= headVATCode;
              end;
              if NxIsEmptyOID(lcVATIndex_ID) then begin
                if not pbZkracenyLog then logs.Add('DPH index k DPH sazbě nedohledán, přeskakuji řádek.');
                row.MarkForDelete;
                continue;
              end;

              if ((SRow.S['rate']<>'')
                  AND
                  (SRow.S['base']<>''))
              then begin
                row.SetFieldValueAsString('VATRate_ID', lcVATRate_ID);
                row.SetFieldValueAsString('VATIndex_ID',lcVATIndex_ID);
                row.SetFieldValueAsFloat(lcAmountFieldName, GetFloatDef(SRow.S['base']));
                if lbVATDocument and (SRow.S['tax']<>'') and (abs(row.GetFieldValueAsFloat('VATTAmount')-GetFloatDef(SRow.S['tax']))>0.00001)
                  then row.SetFieldValueAsFloat('VATTAmount', GetFloatDef(SRow.S['tax']));
              end
              else begin
                if  ((SRow.S['rate']<>'')
                    AND
                    (GetFloatDef(SRow.S['rate'])<>0)
                    AND
                    (SRow.S['tax']<>''))
                then begin
                  row.SetFieldValueAsString('VATRate_ID', lcVATRate_ID);
                  row.SetFieldValueAsString('VATIndex_ID',lcVATIndex_ID);
                  row.SetFieldValueAsFloat(lcAmountFieldName, GetFloatDef(SRow.S['tax'])/(GetFloatDef(SRow.S['rate'])/100));
                  if lbVATDocument and (SRow.S['tax']<>'') and (abs(row.GetFieldValueAsFloat('VATTAmount')-GetFloatDef(SRow.S['tax']))>0.00001)
                    then row.SetFieldValueAsFloat('VATTAmount', GetFloatDef(SRow.S['tax']));
                end;
              end;
              row.SetFieldValueAsString('Text', Copy(annotationsMap.S['description'],1,160));
            end;

            if rows.CountOfNotDeleted=0 then begin
              pcError:= 'Řádky se nepodařilo založil z rekapitulace, přeskakuji.';
              logs.Add(pcError);
              exit;
            end;
          end;
        except
          pcError:= 'Rekapitulace nezadána. '+ExceptionMessage;
          logs.Add(pcError);
          exit;
        end;
      end;
    end;

    if FromHeader then begin
      // Vytvarim novy radek z hlavicky
      row:=rows.AddNewObject;
      row.Prefill;

      if lbVATDocument then begin
        if NxIsEmptyOID(headVATCode) then begin
          pcError:= 'DPH na hlavičce nenastaveno, doklad nelze vytvořit.';
          logs.Add(pcError);
          exit;
        end;

        OS.SQLSelect('SELECT VATRate_ID FROM VATIndexes WHERE ID='+QuotedStr(AnsiUpperCase(headVATCode)),ret);
        if ret.Count=0 then begin
          pcError:= 'DPH sazba k DPH indexu nedohledána, přeskakuji.';
          logs.Add(pcError);
          exit;
        end;
        row.SetFieldValueAsString('VATRate_ID',ret[0]);
        row.SetFieldValueAsString('VATIndex_ID', AnsiUpperCase(headVATCode));
      end;

      if not NxIsEmptyOID(AnsiUpperCase(headBusTransaction)) then begin
        row.SetFieldValueAsString('BusTransaction_ID', AnsiUpperCase(headBusTransaction));
      end;

      {if NxIsEmptyOID(AnsiUpperCase(headExpenseType)) then begin
        pcError:= 'Typ výdaje na hlavičce nenastaveno, doklad nelze vytvořit.';
        logs.Add(pcError);
        exit;
      end;}
      row.SetFieldValueAsString('ExpenseType_ID', AnsiUpperCase(headExpenseType));

      if NxIsEmptyOID(AnsiUpperCase(headDivision)) then begin
        pcError:= 'Středisko na hlavičce nenastaveno, doklad nelze vytvořit.';
        logs.Add(pcError);
        exit;
      end;
      row.SetFieldValueAsString('Division_ID', AnsiUpperCase(headDivision));
      {
      if NxIsEmptyOID(headBusOrder) then begin
        logs.Add('Zakázka na hlavičce nenastavena, doklad nelze vytvořit.');
        exit;
      end;
      }
      if not NxIsEmptyOID(AnsiUpperCase(headBusOrder)) then begin
        row.SetFieldValueAsString('BusOrder_ID', AnsiUpperCase(headBusOrder));
      end;

      if not NxIsEmptyOID(AnsiUpperCase(headBusProject)) then begin
        row.SetFieldValueAsString('BusProject_ID', AnsiUpperCase(headBusProject));
      end;

      row.SetFieldValueAsString('Text', Copy(annotationsMap.S['description'],1,160));
      row.SetFieldValueAsFloat(lcAmountFieldName, GetFloatDef(annotationsMap.S['total_base']));
      if lbVATDocument and (annotationsMap.S['total_tax']<>'') and (abs(row.GetFieldValueAsFloat('VATTAmount')-GetFloatDef(annotationsMap.S['total_tax']))>0.00001)
        then row.SetFieldValueAsFloat('VATTAmount', GetFloatDef(annotationsMap.S['total_tax']));
    end;

    // kurz
    if (annotationsMap.S['exchange_rate']<>'') and (AnsiUpperCase(fp.GetFieldValueasString('Currency_ID.Code'))<>'CZK') then begin
      fp.SetFieldValueAsFloat('CurrRate',GetFloatDef(annotationsMap.S['exchange_rate']));
    end;

    if not pbZkracenyLog then logs.Add('Ukládám');
    try
      if not fp.Validate then begin
        pcError:= 'Chyba při validaci ostatního výdaje: '+GetValidateErrs(fp);
        logs.Add(pcError);
      end
      else begin
        fp.Save;
        FP_ID:=fp.OID;
        lcFP_Name:= fp.DisplayName;
        logs.Add('Vytvořeno: '+lcFP_Name);
      end;

      //logs.Add('Def_Doc_DQ_ID: '+Def_Doc_DQ_ID);
      //logs.Add('Def_Doc_DC_ID: '+Def_Doc_DC_ID);
    except
      pcError:= 'Neočekávaná chyba při ukládání ostatního výdaje: '+ExceptionMessage;
      logs.Add(pcError);
    end;

    if not NxIsEmptyOID(FP_ID) then begin
      try
        // FILE
        if (not NxIsEmptyOID(Def_Doc_DQ_ID)) AND (not NxIsEmptyOID(Def_Doc_DC_ID))
        then begin
          str:= downloadFile(OS, '02', Document_ID, fp.OID, Firm_ID, Def_Doc_DQ_ID, Def_Doc_DC_ID, AUTH_TOKEN, pcQueue_ID, lcDigitooSourceFileName);
          if str<>'' then logs.Add('Došlo k chybě při stažení PDF dokladu: '+str);
        end
        else begin
          logs.Add('Vyplňte v agendě typ a řadu pro přílohu.');
        end;
      except
        logs.Add('Chyba při stahování PDF: '+ExceptionMessage);
      end;
      if pbImportAllAttachments then begin  //přílohy
        try
          if (not NxIsEmptyOID(Def_Doc_DQ_ID)) AND (not NxIsEmptyOID(Def_Doc_DC_ID))
            then downloadAttachments(OS, '02', Document_ID, fp.OID, Firm_ID, Def_Doc_DQ_ID, Def_Doc_DC_ID, AUTH_TOKEN, logs);
        except
          logs.Add('Chyba při stahování příloh: '+ExceptionMessage);
        end;
      end;
      if pbImportDates then begin  //časová razítka
        try
          GetTimeStamps(OS, '02', Document_ID, fp.OID, AUTH_TOKEN, logs, pbZkracenyLog);
        except
          logs.Add('Chyba při stahování časových razítek: '+ExceptionMessage);
        end;
      end;
    end;
  finally
    Result:= lcFP_Name;
    fp.Free;
    ret.Free;
    sqlRow.Free;
    lmContext.Free
  end;
end;

function CreateFP(OS:TNxCustomObjectSpace;
                  jsonObj:TJSONSuperObject;
                  logs:TStrings;
                  Def_Firm_ID, Def_Division_ID,
                  Def_Doc_DQ_ID, Def_Doc_DC_ID, AUTH_TOKEN, Document_ID, pcDRCDocQueue_ID, pcDRCVATRate_ID, pcQueue_ID: string;
                  pbImportAllAttachments: boolean;
                  pbDoNotUpdateFirms, pbImportDates: boolean;
                  var pcError: string;
                  pbPairPR: boolean; pcPRDocQueues: string; pnPRDaysBack, pnPRSearchType: integer;
                  pbOrgIdentNumberCheck: boolean;
                  pbZkracenyLog: boolean):string;
var
  ret, sqlRow, laFPRowsData: TStringList;
  fp, row, firm, bankAcc, obj, loAddress: TNxCustomBusinessObject;
  rows, rows2: TNxCustomBusinessMonikerCollection;
  annotationsMap, SRow: TJSONSuperObject;
  i, TradeType, lnTypDokladu, lnVATMode: Integer;
  Err, Firm_ID, Division_ID, SQL, FP_ID, headVATCode, lcFP_Name, lcFieldName, lcVATRate_ID, lcVATIndex_ID
  , headDivision, headBusOrder, selectedVAT, FirmBankAccount, FirmBankAccount_ID, lcCurrency_ID
  , note, DQ_ID, headKontace, headExpenseType, headBusTransaction, strText, str, lcDocumentURL
  , lcICO, lcDIC, lcFirmName, lcCountry_ID, lcCountry_Code, lcElementName, lcAmountFieldName, headBusProject, lcICDPH
  , lcCountry, lcSQL, lcIBAN, lcStreet, lcCity, lcPostCode, lcHeadBillOfDeliveryNmb, lcRowBillOfDeliveryNmb, lcDigitooDRCVATRate_ID, lcDigitooDRCVATIndex_ID
  , lcPrijemka, lcTypDokladu, lcVATType_ID, lcDigitooDRCVATRate, lcVATMode, lcDigitooSourceFileName, lcReceivedOrderNmb, lcSwiftCode, lcPrijemceSchvalovani_ID: string;
  amount, q, lfDigitooDRCVATRate, lfCastkaKUhrade: Double;
  FromHeader, lbVATDocument, lbReverseCharge: Boolean;
  lmContext: TNxContext;
begin
  Result:= '';
  FP_ID:= '';
  lcFP_Name:= '';
  pcError:= '';
  Err:='';
  lcHeadBillOfDeliveryNmb:= '';
  lcRowBillOfDeliveryNmb:= '';

  lmContext:= NxCreateContext(OS);
  ret:=TStringList.Create;
  sqlRow:=TStringList.Create;
  sqlRow.Delimiter:=';';
  laFPRowsData:= TStringList.Create;
  fp:=OS.CreateObject(Class_ReceivedInvoice);
  try

    if AnsiUpperCase(jsonObj.S['status'])<>'READY-TO-EXPORT' then begin
      pcError:= 'Nepodporovaný status dokladu, přeskakuji.';
      logs.Add(pcError);
      exit;
    end;

    annotationsMap:= jsonObj.O['annotations'];

    {
    if AnsiUpperCase(annotationsMap.S['document_type'])<>'TAX_INVOICE' then begin
      pcError:= 'Nejedná se o typ dokladu faktura přijatá.';
      logs.Add(pcError);
      exit;
    end;
    }

    lcDocumentURL:= jsonObj.S['document_url'];
    if lcDocumentURL='' then lcDocumentURL:= jsonObj.S['id'];
    lcDigitooSourceFileName:= jsonObj.S['file_name'];

    DQ_ID:= AnsiUpperCase(annotationsMap.S['accounting_sequence']);
    if NxIsEmptyOID(DQ_ID) then begin
      pcError:= 'Řada dokladu nezadána.';
      logs.Add(pcError);
      exit;
    end;

    try
      if pbOrgIdentNumberCheck then begin
        if (Trim(annotationsMap.S['recipient_register_id'])<>'')
            and (lmContext.GetCompanyCache.OrgIdentNumber<>'')
            and (Trim(annotationsMap.S['recipient_register_id'])<>lmContext.GetCompanyCache.OrgIdentNumber) then begin
          pcError:= 'IČO odběratele na dokladu neodpovídá IČO ve firemních údajích v Abře.';
          logs.Add(pcError);
          exit;
        end;
      end;
    except
    end;

    // Udaje z hlavičky, maji prednost na radcich
    headVATCode:=AnsiUpperCase(annotationsMap.S['vat_code']);
    headKontace:=AnsiUpperCase(annotationsMap.S['assignment']);
    headDivision:=AnsiUpperCase(annotationsMap.S['cost_center']);
    headBusOrder:=AnsiUpperCase(annotationsMap.S['contract']);
    headBusProject:=AnsiUpperCase(annotationsMap.S['project']);
    headExpenseType:=AnsiUpperCase(annotationsMap.S['account_code']);
    headBusTransaction:=AnsiUpperCase(annotationsMap.S['activity']); // obchodni pripad na hlavicce
    lcAmountFieldName:= 'TAmountWithoutVAT';

    fp.New;
    fp.Prefill;

    try
      lcHeadBillOfDeliveryNmb:= annotationsMap.S['delivery_note_id'];
      if fp.HasField('X_BillOfDeliveryNmb') and (lcHeadBillOfDeliveryNmb<>'')
        then fp.SetFieldValueAsString('X_BillOfDeliveryNmb', lcHeadBillOfDeliveryNmb);
    except
    end;

    try
      lcReceivedOrderNmb:= annotationsMap.S['order_id'];
      if fp.HasField('X_ReceivedOrderNmb') and (lcReceivedOrderNmb<>'')
        then fp.SetFieldValueAsString('X_ReceivedOrderNmb', lcReceivedOrderNmb);
    except
    end;

    lbVATDocument:= IsVATDocument(annotationsMap);

    fp.SetFieldValueAsBoolean('VATDocument', lbVATDocument);

    // Firma - povinna polozka - dohledava se dle ICO
    lcICO:= NxLeft(Trim(annotationsMap.S['sender_register_id']),15);
    lcDIC:= NxLeft(Trim(annotationsMap.S['sender_tax_id']),20);
    lcICDPH:= NxLeft(Trim(annotationsMap.S['sender_vat_id']),20);
    lcFirmName:= NxLeft(Trim(annotationsMap.S['sender_name']),220);
    Firm_ID:= '';
    try
      Firm_ID:= Trim(annotationsMap.S['sender_internal_id']);
      if NxIsEmptyOID(Firm_ID) then Firm_ID:= '';
    except
    end;
    if NxIsEmptyOID(Firm_ID) then begin
      if not GetFirm_ID(OS, lcICO, lcDIC, lcICDPH, lcFirmName, NxLeft(Trim(annotationsMap.S['sender_address']),255),
                        NxLeft(Trim(annotationsMap.S['sender_street']),60),
                        NxLeft(Trim(annotationsMap.S['sender_city']),60),
                        NxLeft(Trim(annotationsMap.S['sender_post_code']),10),
                        Trim(annotationsMap.S['sender_country']),
                        logs, pbDoNotUpdateFirms, pcError, Firm_ID) then exit;
    end
    else begin
      if not pbZkracenyLog then logs.Add('Nastavuji zaslanou firmu "'+GetData(OS,'Firms','ID',Firm_ID,'Name')+'".');
    end;

    // měna
    lcCurrency_ID:= '';
    if annotationsMap.S['currency']<>'' then begin
      //logs.Add('Hledám měnu.');
      OS.SQLSelect('SELECT ID FROM Currencies WHERE Upper(Code)='+QuotedStr(AnsiUpperCase(annotationsMap.S['currency'])),ret);
      if ret.count>0 then
      begin
        lcCurrency_ID:= ret[0];
        if not pbZkracenyLog then logs.Add('Nastavuji měnu.');
        fp.SetFieldValueAsString('Currency_ID', lcCurrency_ID);
      end else begin
        if not pbZkracenyLog then logs.Add('Měna nedohledána.');
      end;
    end;

    if (NxIsEmptyOID(Firm_ID)) AND (not NxIsEmptyOID(Def_Firm_ID))
    then begin
      Firm_ID:=Def_Firm_ID;
      if not pbZkracenyLog then logs.Add('Nastavuji výchozí firmu.');
    end;

    if NxIsEmptyOID(Firm_ID)
    then begin
      pcError:= 'Firmu se nepodařilo nastavit, přeskakuji.';
      logs.Add(pcError);
      exit;
    end;

    fp.SetFieldValueAsString('DocQueue_ID',DQ_ID);
    // Kontace
    if not NxIsEmptyOID(headKontace) then begin
      fp.SetFieldValueAsString('AccPresetDef_ID',headKontace);
    end;

    //lcElementName:= 'report_code';
    lcElementName:= 'trade_code';
    if (annotationsMap.S[lcElementName]<>'') and (Length(annotationsMap.S[lcElementName])<>10) then begin
      TradeType:=StrToInt(annotationsMap.S[lcElementName]);
      if (TradeType>0) AND (TradeType<7) then begin
      fp.SetFieldValueAsInteger('TradeType', TradeType);
      end;
    end;

    lbReverseCharge:= False;
    try
      lbReverseCharge:= UpperCase(annotationsMap.S['reverse_charge']) in ['TRUE','YES','ANO','A','Y','1'];
    except
      lbReverseCharge:= False;
    end;
    if fp.GetFieldValueAsBoolean('VATDocument')
        and (fp.GetFieldValueAsInteger('TradeType') in [1,2,3])
        and lbReverseCharge
      then fp.SetFieldValueAsBoolean('IsReverseChargeDeclared', True);

    fp.SetFieldValueAsString('Firm_ID', Firm_ID);
    if not NxIsEmptyOID(lcCurrency_ID) then fp.SetFieldValueAsString('Currency_ID', lcCurrency_ID);
    fp.SetFieldValueAsString('ExternalNumber',trim(Copy(annotationsMap.S['invoice_id'],1,30)));
    if fp.GetFieldValueAsString('ExternalNumber')<>'' then begin
      lcSQL:= 'Select RI.ID'
          +#13' from ReceivedInvoices RI'
          +#13' join Firms F on F.ID=RI.Firm_ID'
          +#13' where coalesce(F.Firm_ID,F.ID)='+QuotedStr(NxIIfStr(not NxIsEmptyOID(fp.GetFieldValueAsString('Firm_ID.Firm_ID')),fp.GetFieldValueAsString('Firm_ID.Firm_ID'),fp.GetFieldValueAsString('Firm_ID')))
          +#13'       and Upper(RI.ExternalNumber)='+QuotedStr(AnsiUpperCase(fp.GetFieldValueAsString('ExternalNumber')));
      OS.SQLSelect(lcSQL, ret);
      if ret.Count>0 then begin
        pcError:= 'Pro firmu "'+fp.GetFieldValueAsString('Firm_ID.Name')+'" již existuje faktura přijatá s externím číslem "'+fp.GetFieldValueAsString('ExternalNumber')+'", přeskakuji.';
        logs.Add(pcError);
        exit;
      end;
    end;

    if lbVATDocument then begin
      if fp.GetFieldValueAsInteger('TradeType')=1 then begin
        fp.SetFieldValueAsInteger('DataEntryKind', 0);
      end
      else begin
        lcAmountFieldName:= 'TAmount';
      end;
    end
    else begin
      lcAmountFieldName:= 'TAmount';
    end;

    if fp.GetFieldValueAsInteger('TradeType') in [2,3,4] then begin
      lcCountry_Code:= '';
      try
        lcCountry_Code:= NxIifStr(Length(Trim(annotationsMap.S['sender_country']))=10,GetData(OS, 'Countries', 'ID', Trim(annotationsMap.S['sender_country']), 'Code'), NxLeft(Trim(annotationsMap.S['sender_country']),3));
      except
      end;
      if lcCountry_Code='' then lcCountry_Code:= NxLeft(fp.GetFieldValueAsString('Firm_ID.ResidenceAddress_ID.CountryCode'),2);
      if lcCountry_Code='' then lcCountry_Code:= NxLeft(fp.GetFieldValueAsString('Firm_ID.VATIdentNumber'),2);
      if lcCountry_Code='' then lcCountry_Code:= NxLeft(lcDIC,2);
      lcCountry_Code:= AnsiUpperCase(lcCountry_Code);
      lcCountry_ID:= GetData(OS, 'Countries', 'Code', lcCountry_Code, 'ID', True, 'Hidden=''N''');
      if not NxIsEmptyOID(lcCountry_ID) then begin
        fp.SetFieldValueAsString('Country_ID', lcCountry_ID);
        if not NxIsEmptyOID(lcCurrency_ID) then fp.SetFieldValueAsString('Currency_ID', lcCurrency_ID);
      end;
      if fp.GetFieldValueAsInteger('TradeType')=2 then fp.SetFieldValueAsBoolean('IsReverseChargeDeclared', True);
    end;

    if lmContext.GetCompanyCache.OrgIdentNumber='26230224' then begin  //Magsy to chce jinak (dle Data uplatnění odpočtu)
      if annotationsMap.S['received_date']<>'' then begin
        fp.SetFieldValueAsDateTime('DocDate$DATE', annotationsMap.DT8601['received_date']);
        fp.SetFieldValueAsString('Period_ID',GetPeriodOS(OS,annotationsMap.DT8601['received_date']));
        if NxIsEmptyOID(fp.GetFieldValueAsString('Period_ID')) then begin
          pcError:= 'Dle data uplatnění odpočtu nebylo v Abře dohledáno odpovídající období.';
          logs.Add(pcError);
          exit;
        end;
      end
      else begin
        fp.SetFieldValueAsDateTime('DocDate$DATE', Date);
        fp.SetFieldValueAsString('Period_ID',GetPeriodOS(OS,fp.GetFieldValueAsDateTime('DocDate$DATE')));
        {
        pcError:= 'Nebyl zaslán datum uplatnění odpočtu';
        logs.Add(pcError);
        exit;
        }
      end;
    end
    else begin
      if annotationsMap.S['issue_date']<>'' then begin
        fp.SetFieldValueAsDateTime('DocDate$DATE', annotationsMap.DT8601['issue_date']);
        fp.SetFieldValueAsString('Period_ID',GetPeriodOS(OS,annotationsMap.DT8601['issue_date']));
        if NxIsEmptyOID(fp.GetFieldValueAsString('Period_ID')) then begin
          pcError:= 'Dle data vystavení nebylo v Abře dohledáno odpovídající období.';
          logs.Add(pcError);
          exit;
        end;
      end
      else begin
        fp.SetFieldValueAsDateTime('DocDate$DATE', Date);
        fp.SetFieldValueAsString('Period_ID',GetPeriodOS(OS,fp.GetFieldValueAsDateTime('DocDate$DATE')));
        {
        pcError:= 'Nebyl zaslán datum vystavení';
        logs.Add(pcError);
        exit;
        }
      end;
    end;
    if (annotationsMap.S['taxable_supply_date']<>'') and lbVATDocument then begin
      fp.SetFieldValueAsDateTime('VATAdmitDate$DATE', annotationsMap.DT8601['taxable_supply_date']);
    end;
    if annotationsMap.S['accounting_date']<>'' then begin
      fp.SetFieldValueAsDateTime('AccDate$DATE', annotationsMap.DT8601['accounting_date']);
    end;

    fp.SetFieldValueAsString('X_DigiTooInvoice_ID',annotationsMap.S['invoice_id']);
    fp.SetFieldValueAsString('X_DigitooDocumentUrl',lcDocumentURL);
    fp.SetFieldValueAsString('VarSymbol',annotationsMap.S['var_sym']);
    fp.SetFieldValueAsString('X_Poznamka',annotationsMap.S['note']);
    str:=trim(Copy(annotationsMap.S['description'],1,50));
    if str='' then str:=trim(Copy(annotationsMap.S['note'],1,50));
    fp.SetFieldValueAsString('Description',str);

    if (annotationsMap.S['received_date']<>'') and lbVATDocument then begin
      fp.SetFieldValueAsDateTime('VatDate$DATE', annotationsMap.DT8601['received_date']);
    end;

    if ExistujeUzaverkaDPH(OS, fp.GetFieldValueAsDateTime('VatDate$DATE')) then begin
      pcError:= 'Datum uplatnění odpočtu  '+FormatDateTime('DD.MM.YYYY', fp.GetFieldValueAsDateTime('VatDate$DATE'))+' je již v Abře uzavřeno uzávěrkou DPH.';
      logs.Add(pcError);
      exit;
    end;

    if annotationsMap.S['due_date']<>'' then begin
      fp.SetFieldValueAsDateTime('DueDate$DATE', annotationsMap.DT8601['due_date']);
    end;
    fp.SetFieldValueAsFloat('RoundingAmount', GetFloatDef(annotationsMap.S['total_rounding']));

    // Bankovni ucet
    FirmBankAccount:= '';
    try
      if annotationsMap.A['bank_account'].length>0 then begin
        FirmBankAccount:= StringReplace(AnsiUpperCase(trim(annotationsMap.A['bank_account'].S[0])),' ','',[rfReplaceAll]);
      end;
    except
      if FirmBankAccount='' then FirmBankAccount:= StringReplace(AnsiUpperCase(trim(annotationsMap.S['bank_account'])),' ','',[rfReplaceAll]);
    end;
    lcIBAN:= '';
    try
      if annotationsMap.A['iban'].length>0 then begin
        lcIBAN:= StringReplace(AnsiUpperCase(trim(annotationsMap.A['iban'].S[0])),' ','',[rfReplaceAll]);
      end;
    except
      if lcIBAN='' then lcIBAN:= StringReplace(AnsiUpperCase(trim(annotationsMap.S['iban'])),' ','',[rfReplaceAll]);
    end;
    lcSwiftCode:= '';
    try
      if annotationsMap.A['bic'].length>0 then begin
        lcSwiftCode:= StringReplace(AnsiUpperCase(trim(annotationsMap.A['bic'].S[0])),' ','',[rfReplaceAll]);
      end;
    except
      if lcSwiftCode='' then lcSwiftCode:= StringReplace(AnsiUpperCase(trim(annotationsMap.S['bic'])),' ','',[rfReplaceAll]);
    end;
    if (FirmBankAccount<>'') or (lcIBAN<>'') then begin
      ret.Clear;
      SQL:='SELECT ID'
       +#13' FROM FirmBankAccounts'
       +#13' WHERE ('+NxIIfStr(FirmBankAccount<>'','Upper(Replace(BankAccount,'' '',''''))='+QuotedStr(FirmBankAccount),'')
       +#13'       '+NxIIfStr(lcIBAN<>'',NxIifStr(FirmBankAccount<>'','or','')+' (Upper(Replace(BankAccount,'' '',''''))='+QuotedStr(lcIBAN),'')
       +#13'       '+NxIIfStr((lcIBAN<>'') and (lcSwiftCode<>''),' and Upper(Replace(SwiftCode,'' '',''''))='+QuotedStr(lcSwiftCode)+')',NxIIfStr(lcIBAN<>'',')',''))+')'
       +#13'       and Parent_ID='+QuotedStr(Firm_ID);
      OS.SQLSelect(SQL, ret);
      if ret.Count>0 then begin
        FirmBankAccount_ID:= ret[0];
        if not NxIsEmptyOID(FirmBankAccount_ID) then
        begin
          fp.SetFieldValueAsString('FirmBankAccount_ID', FirmBankAccount_ID);
          if not pbZkracenyLog then logs.Add('Nastavuji bankovní účet.');
        end;
      end
      else begin
        if pbDoNotUpdateFirms then begin
          pcError:= 'Bankovní účet nelze založit, není povoleno přidávat nové bankovní účty k firmám v Abře.';
          logs.Add(pcError);
          exit;
        end
        else begin
          // v pripade, ze neni vybrana vychozi firma
          if Firm_ID<>Def_Firm_ID then begin
            firm:=OS.CreateObject(Class_Firm);
            try
              firm.Load(Firm_ID,nil);
              rows2:=firm.GetLoadedCollectionMonikerForFieldCode(firm.GetFieldCode('Rows'));
              bankAcc:=rows2.AddNewObject;
              bankAcc.Prefill;
              bankAcc.SetFieldValueAsString('BankAccount', NxIifStr((FirmBankAccount='') or ((lcIBAN<>'') and (NxLeft(lcIBAN,2)<>'CZ')),lcIBAN,FirmBankAccount));
              if (lcSwiftCode<>'') and (lcIBAN<>'') and ((FirmBankAccount='') or (NxLeft(lcIBAN,2)<>'CZ')) then bankAcc.SetFieldValueAsString('SwiftCode', lcSwiftCode);
              FirmBankAccount_ID:=bankAcc.OID;
              try
                firm.Save;
                fp.SetFieldValueAsString('FirmBankAccount_ID', FirmBankAccount_ID);
                if not pbZkracenyLog then logs.Add('Nastavuji bankovní účet.');
              except
                if not pbZkracenyLog then logs.Add('Bankovní účet nelze založit: '+ExceptionMessage);
              end;
            finally
              firm.Free;
            end;
          end
          else begin
            // Nemuzu zakladat
            if not pbZkracenyLog then logs.Add('Bankovní účet nelze založit, je vybrána výchozí firma.');
          end;
        end;
      end;
    end;

    // Typ úhrady
    if (trim(annotationsMap.S['payment_type'])<>'') AND (not NxIsEmptyOID(trim(annotationsMap.S['payment_type']))) then begin
      fp.SetFieldValueAsString('PaymentType_ID',AnsiUpperCase(trim(annotationsMap.S['payment_type'])));
    end;

    {
    if not NxIsEmptyOID(Def_Predkontace) then begin
      fp.SetFieldValueAsString('AccPresetDef_ID',Def_Predkontace);
    end;
    }

    try
      lcTypDokladu:= '0';
      lcTypDokladu:= Trim(annotationsMap.S['typ_dokladu']);
      lnTypDokladu:= StrToIntDef(lcTypDokladu,0);
      {case lcTypDokladu of
        'zbozi': lnTypDokladu:= 0;
        'zbozi_vpn': lnTypDokladu:= 1;
        'vpn_doprava': lnTypDokladu:= 2;
        'vpn_ostatni': lnTypDokladu:= 3;
        'investicni': lnTypDokladu:= 4;
        else lnTypDokladu:= 0;
      end;}
      if fp.HasField('X_IntDocType') then fp.SetFieldValueAsInteger('X_IntDocType', lnTypDokladu);
    except
    end;
    try
      lcPrijemka:=Trim(annotationsMap.S['prijemka']);
      if fp.HasField('X_Receipts') and (lcPrijemka<>'')
        then fp.SetFieldValueAsString('X_Receipts', lcPrijemka);
    except
    end;

    rows:=fp.GetLoadedCollectionMonikerForFieldCode(fp.GetFieldCode('Rows'));
    try
      FromHeader:=false;
      try
        FromHeader:= annotationsMap.A['line_items'].length=0;
      except
        FromHeader:=true;
        if not pbZkracenyLog then logs.Add('Řádky se nepodařilo vytvořit, zkouším vytvořit řádek na základě údajů z hlavičky.');
      end;

      if not(FromHeader) then begin
        for i:=0 to annotationsMap.A['line_items'].length-1 do begin // radky
          SRow:=annotationsMap.A['line_items'].N[i];
          row:=rows.AddNewObject;
          row.Prefill;

          try
            lcRowBillOfDeliveryNmb:=AnsiUpperCase(SRow.S['delivery_note_id']);
            if lcRowBillOfDeliveryNmb='' then lcRowBillOfDeliveryNmb:= lcHeadBillOfDeliveryNmb;
            if row.HasField('X_BillOfDeliveryNmb') and (lcRowBillOfDeliveryNmb<>'')
              then row.SetFieldValueAsString('X_BillOfDeliveryNmb', lcRowBillOfDeliveryNmb);
          except
          end;

          try
            lcPrijemka:=Trim(SRow.S['line_prijemka']);
            if fp.HasField('X_Receipts') and (lcPrijemka<>'')
              then row.SetFieldValueAsString('X_Receipts', lcPrijemka);
          except
          end;

          try
            amount:= 0;
            q:= GetFloatDef(SRow.S['quantity']);
            if q=0 then q:=1;
            if GetFloatDef(SRow.S['unit_base']) <> 0 then begin
              amount:= GetFloatDef(SRow.S['unit_base']);
            end
            else begin
              amount:= GetFloatDef(SRow.S['total_base'])/q;
            end;
            if row.HasField('X_Quantity') then row.SetFieldValueAsFloat('X_Quantity', q);
            try
              if GetFloatDef(annotationsMap.S['exchange_rate'],0)>0
                then amount:= amount*GetFloatDef(annotationsMap.S['exchange_rate']);
            except
            end;
            if row.HasField('X_UnitPrice') then row.SetFieldValueAsFloat('X_UnitPrice', amount);
            amount:= 0;
          except
          end;

          if lbVATDocument and (fp.GetFieldValueasInteger('TradeType')<>4) then begin
            lcVATRate_ID:= '';
            lcVATIndex_ID:= '';
            lcVATIndex_ID:= AnsiUpperCase(SRow.S['vat_code']);
            if fp.GetFieldValueAsBoolean('IsReverseChargeDeclared') and (fp.GetFieldValueAsInteger('TradeType')=1) then begin
              try
                lcVATMode:= SRow.S['vat_mode'];
//                if lcVATMode<>'' then begin
                lnVATMode:= StrToIntDef(lcVATMode, 1);
                if lnVATMode in [0,1] then row.SetFieldValueAsInteger('VATMode', lnVATMode);
//                end;
              except
              end;
              try
                lcVATType_ID:= SRow.S['vat_type'];
                if not NxIsEmptyOID(lcVATType_ID) then row.SetFieldValueAsString('DRCArticle_ID', lcVATType_ID);
              except
              end;
              if (row.GetFieldValueAsInteger('VATMode')=1) and not NxIsEmptyOID(row.GetFieldValueAsString('DRCArticle_ID')) then begin
                q:= GetFloatDef(SRow.S['quantity']);
                row.SetFieldValueAsFloat('DRCQuantity', q);
              end;
              if (row.GetFieldValueAsInteger('VATMode')=1) and not NxIsEmptyOID(row.GetFieldValueAsString('DRCArticle_ID.X_DRCVatRate_ID')) then begin
                lcVATRate_ID:= row.GetFieldValueAsString('DRCArticle_ID.X_DRCVatRate_ID');
                lcVATIndex_ID:= row.GetFieldValueAsString('DRCArticle_ID.X_DRCVatRate_ID.OutcomeDomesticRCXVATIndex_ID');
              end;
            end;
            // DPH
            if not NxIsEmptyOID(lcVATIndex_ID) then begin
              if NxIsEmptyOID(lcVATRate_ID) then begin
                OS.SQLSelect('SELECT VATRate_ID FROM VATIndexes WHERE ID='+QuotedStr(AnsiUpperCase(lcVATIndex_ID)),ret);
                if ret.Count=0 then begin
                  if not pbZkracenyLog then logs.Add('DPH sazba k DPH indexu nedohledána, přeskakuji.');
                  row.MarkForDelete;
                  continue;
                end
                else begin
                  lcVATRate_ID:= ret[0];
                end;
              end;
              row.SetFieldValueAsString('VATRate_ID', lcVATRate_ID);
              row.SetFieldValueAsString('VATIndex_ID', lcVATIndex_ID);
            end
            else begin
              case fp.GetFieldValueAsInteger('TradeType') of
                2: lcFieldName:= 'OutcomeForeignEUDefVATIndex_ID';
                3: lcFieldName:= 'OutcomeForeignDefVATIndex_ID';
                else lcFieldName:= 'OutcomeDomesticDefVATIndex_ID';
              end;
              if (SRow.S['tax_rate']<>'') or not NxIsEmptyOID(lcVATRate_ID) then begin
                if NxIsEmptyOID(lcVATRate_ID) then begin
                  OS.SQLSelect('SELECT VR.ID, VR.'+lcFieldName
                  +#13' FROM VATRates VR'
                  +#13' JOIN COUNTRIES C ON C.ID = VR.Country_ID'
                  +#13' WHERE C.ID='+QuotedStr(lmContext.GetCompanyCache.CountryID)
                  +#13'       AND VR.Hidden=''N'''
                  +#13'       AND VR.Tariff='+GetSQLFloat(GetFloatDef(SRow.S['tax_rate'])),ret);
                  if ret.Count=0 then begin
                    if not pbZkracenyLog then logs.Add('DPH nenačteno, přeskakuji řádek.');
                    row.MarkForDelete;
                    continue;
                  end;
                  sqlrow.DelimitedText:= ret[0];
                  lcVATRate_ID:= sqlrow[0];
                  lcVATIndex_ID:= sqlrow[1];
                end;
                if NxIsEmptyOID(lcVATIndex_ID)
                    and fp.GetFieldValueAsBoolean('IsReverseChargeDeclared')
                    and (fp.GetFieldValueAsInteger('TradeType')=1)
                    and not NxIsEmptyOID(row.GetFieldValueAsString('DRCArticle_ID.X_DRCVatRate_ID')) then begin
                  lcVATIndex_ID:= row.GetFieldValueAsString('DRCArticle_ID.X_DRCVatRate_ID.OutcomeDomesticRCXVATIndex_ID');
                end;
                if not NxIsEmptyOID(headVATCode) then begin
                  if CheckIndexForVATRate(OS, headVATCode, lcVATRate_ID, fp.GetFieldValueAsInteger('TradeType'),True)
                    then lcVATIndex_ID:= headVATCode;
                end;
                if NxIsEmptyOID(lcVATIndex_ID) then begin
                  if not pbZkracenyLog then logs.Add('DPH index k DPH sazbě nedohledán, přeskakuji řádek.');
                  row.MarkForDelete;
                  continue;
                end;
                row.SetFieldValueAsString('VATRate_ID',lcVATRate_ID);
                row.SetFieldValueAsString('VATIndex_ID',lcVATIndex_ID);
              end
              else begin
                if not NxIsEmptyOID(headVATCode) then begin
                  OS.SQLSelect('SELECT VATRate_ID FROM VATIndexes WHERE ID='+QuotedStr(AnsiUpperCase(headVATCode)),ret);
                  if ret.Count=0 then begin
                    if not pbZkracenyLog then logs.Add('DPH sazba k DPH indexu nedohledána, přeskakuji.');
                    row.MarkForDelete;
                    continue;
                  end;
                  row.SetFieldValueAsString('VATRate_ID',ret[0]);
                  row.SetFieldValueAsString('VATIndex_ID', AnsiUpperCase(headVATCode));
                end
                else begin
                  // DPH neni zadano, preskakuji
                  if not pbZkracenyLog then logs.Add('DPH nenačteno, přeskakuji řádek.');
                  row.MarkForDelete;
                  continue;
                end;
              end;
            end;
          end;

          // Typ vydaje
          if not NxIsEmptyOID(AnsiUpperCase(SRow.S['account_code']))
          then begin
            row.SetFieldValueAsString('ExpenseType_ID', AnsiUpperCase(SRow.S['account_code']));
          end
          else begin
            if not NxIsEmptyOID(AnsiUpperCase(headExpenseType))
            then begin
              row.SetFieldValueAsString('ExpenseType_ID',AnsiUpperCase(headExpenseType));
            end
            else begin
              if not pbZkracenyLog then logs.Add('Typ výdaje nenačten.');
            end;
          end;

          if not NxIsEmptyOID(AnsiUpperCase(SRow.S['activity'])) then begin
            row.SetFieldValueAsString('BusTransaction_ID', AnsiUpperCase(SRow.S['activity']));
          end
          else begin
             if not NxIsEmptyOID(AnsiUpperCase(headBusTransaction))
            then begin
              row.SetFieldValueAsString('BusTransaction_ID',AnsiUpperCase(headBusTransaction));
            end
            else begin
              if not pbZkracenyLog then logs.Add('Obchodní případ nenačten.');
            end;
          end;

          // Division_ID
          if not NxIsEmptyOID(AnsiUpperCase(SRow.S['cost_center']))
          then begin
            row.SetFieldValueAsString('Division_ID', AnsiUpperCase(SRow.S['cost_center']));
          end
          else begin
            if not NxIsEmptyOID(AnsiUpperCase(headDivision))
            then begin
              row.SetFieldValueAsString('Division_ID',AnsiUpperCase(headDivision));
            end
            else begin
              if not NxIsEmptyOID(AnsiUpperCase(Def_Division_ID)) then begin
                if not pbZkracenyLog then logs.Add('Nastavuji výchozí středisko.');
                row.SetFieldValueAsString('Division_ID', AnsiUpperCase(Def_Division_ID));
              end
              else begin
                if not pbZkracenyLog then logs.Add('Středisko nenastaveno, přeskakuji řádek.');
                row.MarkForDelete;
                continue;
              end;
            end;
          end;

          // BusOrder
          if not NxIsEmptyOID(AnsiUpperCase(SRow.S['contract']))
          then begin
            row.SetFieldValueAsString('BusOrder_ID', AnsiUpperCase(SRow.S['contract']));
          end
          else begin
            if not NxIsEmptyOID(AnsiUpperCase(headBusOrder))
            then begin
              row.SetFieldValueAsString('BusOrder_ID',AnsiUpperCase(headBusOrder));
            end
            else begin
              if not pbZkracenyLog then logs.Add('Zakázka nenastavena.');
            end;
          end;

          // BusProject
          if not NxIsEmptyOID(AnsiUpperCase(SRow.S['project']))
          then begin
            row.SetFieldValueAsString('BusProject_ID', AnsiUpperCase(SRow.S['project']));
          end
          else begin
            if not NxIsEmptyOID(AnsiUpperCase(headBusProject))
            then begin
              row.SetFieldValueAsString('BusProject_ID',AnsiUpperCase(headBusProject));
            end
            else begin
              if not pbZkracenyLog then logs.Add('Projekt nenastaven.');
            end;
          end;

          // Text na radku
          strText:='';
          if SRow.S['item_code']<>'' then begin
            strText:=SRow.S['item_code'];
          end;
          if SRow.S['item_description']<>'' then begin
            if strText<>'' then begin
              strText:=strText+': ';
            end;
            strText:=strText+SRow.S['item_description'];
          end;
          if strText='' then begin
            strText:=SRow.S['description'];
          end;
          row.SetFieldValueAsString('Text', Copy(strText,1,160));

          // Castka
          if GetFloatDef(SRow.S['total_base']) <> 0 then begin
            amount:= GetFloatDef(SRow.S['total_base']);
          end else begin
            q:= GetFloatDef(SRow.S['quantity']);
            if q=0 then begin
              q:=1;
            end;
            amount:=q* GetFloatDef(SRow.S['unit_base']);
          end;

          if abs(amount)<0.000001 then begin
            if not pbZkracenyLog then logs.Add('Nulová částka na řádku, přeskakuji.');
            row.MarkForDelete;
            continue;
          end;
          row.SetFieldValueAsFloat(lcAmountFieldName, amount);
          if lbVATDocument and (fp.GetFieldValueAsInteger('TradeType')=1)
              and (SRow.S['total_tax']<>'') and (abs(row.GetFieldValueAsFloat('VATTAmount')-GetFloatDef(SRow.S['total_tax']))>0.00001)
            then row.SetFieldValueAsFloat('VATTAmount', GetFloatDef(SRow.S['total_tax']));
          laFPRowsData.Add(row.OID
                           +';'+AnsiQuotedStr(SRow.S['code'],'"')
                           +';'+AnsiQuotedStr(SRow.S['description'],'"')
                           +';'+AnsiQuotedStr(SRow.S['quantity'],'"')
                           +';'+AnsiQuotedStr(SRow.S['unit_measure'],'"')
                           +';'+GetSQLFloat(row.GetFieldValueAsFloat('TAmountWithoutVAT'))
                           +';'+GetSQLFloat(row.GetFieldValueAsFloat('LocalTAmountWithoutVAT')));
        end;
        if rows.CountOfNotDeleted=0 then begin
          if not pbZkracenyLog then logs.Add('Řádky se nepodařilo vytvořit, zkouším vytvořit řádek na základě údajů z hlavičky.');
          FromHeader:=true;
        end;
      end;
    except
      if not pbZkracenyLog then logs.Add('Řádky se nepodařilo vytvořit, zkouším vytvořit řádek na základě údajů z hlavičky.');
      row.MarkForDelete;
      FromHeader:=true;
    end;

    if FromHeader then begin
      // tax_detail - vytvor radky z rekapitulace
      if lbVATDocument and (fp.GetFieldValueasInteger('TradeType')<>4)  then begin
        FromHeader:= False;
        try
          try
            FromHeader:= annotationsMap.A['tax_detail'].length=0;
          except
            FromHeader:=true;
            if not pbZkracenyLog then logs.Add('Rekapitulace nezadána.');
          end;

          if not(FromHeader) then begin
            annotationsMap.A['tax_detail'].length;
            if not pbZkracenyLog then Logs.Add('Tvořím řádky z rekapitulace');
            for i:=0 to annotationsMap.A['tax_detail'].length-1 do begin // radky
              SRow:=annotationsMap.A['tax_detail'].N[i];
              if (SRow.S['rate']='')
                  OR ((SRow.S['base']='') AND (SRow.S['tax']=''))
              then begin
                if not pbZkracenyLog then logs.Add('Neúplné údaje na řádku rekapitulace, přeskakuji.');
                continue;
              end;
              if not pbZkracenyLog then logs.Add('Vytvářím řádek z rekapitulace.');

              row:=rows.AddNewObject;
              row.Prefill;

              if NxIsEmptyOID(AnsiUpperCase(headDivision)) then begin
                pcError:= 'Středisko na hlavičce nenastaveno, doklad nelze vytvořit.';
                logs.Add(pcError);
                exit;
              end;
              row.SetFieldValueAsString('Division_ID', AnsiUpperCase(headDivision));

              if NxIsEmptyOID(AnsiUpperCase(headExpenseType)) then begin
                pcError:= 'Typ výdaje na hlavičce nenastaveno, doklad nelze vytvořit.';
                logs.Add(pcError);
                exit;
              end;
              row.SetFieldValueAsString('ExpenseType_ID', AnsiUpperCase(headExpenseType));

              if not NxIsEmptyOID(AnsiUpperCase(headBusTransaction)) then begin
                row.SetFieldValueAsString('BusTransaction_ID', AnsiUpperCase(headBusTransaction));
              end;
              if not NxIsEmptyOID(AnsiUpperCase(headBusOrder)) then begin
                row.SetFieldValueAsString('BusOrder_ID', AnsiUpperCase(headBusOrder));
              end;

              if not NxIsEmptyOID(AnsiUpperCase(headBusProject)) then begin
                row.SetFieldValueAsString('BusProject_ID', AnsiUpperCase(headBusProject));
              end;

              case fp.GetFieldValueasInteger('TradeType') of
                2: lcFieldName:= 'OutcomeForeignEUDefVATIndex_ID';
                3: lcFieldName:= 'OutcomeForeignDefVATIndex_ID';
              else lcFieldName:= 'OutcomeDomesticDefVATIndex_ID';
              end;

              OS.SQLSelect('SELECT VR.ID, VR.'+lcFieldName
              +#13' FROM VATRates VR'
              +#13' JOIN COUNTRIES C ON C.ID = VR.Country_ID'
              +#13' WHERE C.ID='+QuotedStr(lmContext.GetCompanyCache.CountryID)
              +#13'       AND VR.Hidden=''N'''
              +#13'       AND VR.Tariff='+GetSQLFloat(GetFloatDef(SRow.S['rate'])),ret);
              if ret.Count=0 then begin
                if not pbZkracenyLog then logs.Add('DPH nenačteno, přeskakuji řádek.');
                row.MarkForDelete;
                continue;
              end;
              sqlrow.DelimitedText:= ret[0];
              lcVATRate_ID:= sqlrow[0];
              lcVATIndex_ID:= sqlrow[1];
              if not NxIsEmptyOID(headVATCode) then begin
                if CheckIndexForVATRate(OS, headVATCode, lcVATRate_ID, fp.GetFieldValueAsInteger('TradeType'),True)
                  then lcVATIndex_ID:= headVATCode;
              end;
              if NxIsEmptyOID(lcVATIndex_ID) then begin
                if not pbZkracenyLog then logs.Add('DPH index k DPH sazbě nedohledán, přeskakuji řádek.');
                row.MarkForDelete;
                continue;
              end;

              if ((SRow.S['rate']<>'')
                  AND
                  (SRow.S['base']<>''))
              then begin
                row.SetFieldValueAsString('VATRate_ID', lcVATRate_ID);
                row.SetFieldValueAsString('VATIndex_ID',lcVATIndex_ID);
                row.SetFieldValueAsFloat(lcAmountFieldName, GetFloatDef(SRow.S['base']));
                if lbVATDocument and (fp.GetFieldValueAsInteger('TradeType')=1)
                    and (SRow.S['tax']<>'') and (abs(row.GetFieldValueAsFloat('VATTAmount')-GetFloatDef(SRow.S['tax']))>0.00001)
                  then row.SetFieldValueAsFloat('VATTAmount', GetFloatDef(SRow.S['tax']));
              end
              else begin
                if  ((SRow.S['rate']<>'')
                    AND
                    (GetFloatDef(SRow.S['rate'])<>0)
                    AND
                    (SRow.S['tax']<>''))
                then begin
                  row.SetFieldValueAsString('VATRate_ID', lcVATRate_ID);
                  row.SetFieldValueAsString('VATIndex_ID',lcVATIndex_ID);
                  row.SetFieldValueAsFloat(lcAmountFieldName, GetFloatDef(SRow.S['tax'])/(GetFloatDef(SRow.S['rate'])/100));
                  if lbVATDocument and (fp.GetFieldValueAsInteger('TradeType')=1)
                      and (SRow.S['tax']<>'') and (abs(row.GetFieldValueAsFloat('VATTAmount')-GetFloatDef(SRow.S['tax']))>0.00001)
                    then row.SetFieldValueAsFloat('VATTAmount', GetFloatDef(SRow.S['tax']));
                end;
              end;
              row.SetFieldValueAsString('Text', Copy(annotationsMap.S['description'],1,160));
            end;

            if rows.CountOfNotDeleted=0 then begin
              pcError:= 'Řádky se nepodařilo založil z rekapitulace, přeskakuji.';
              logs.Add(pcError);
              exit;
            end;
          end;
        except
          pcError:= 'Rekapitulace nezadána. '+ExceptionMessage;
          logs.Add(pcError);
          exit;
        end;
      end;
    end;

    if FromHeader then begin
      // Vytvarim novy radek z hlavicky
      row:=rows.AddNewObject;
      row.Prefill;

      if lbVATDocument and (fp.GetFieldValueasInteger('TradeType')<>4) then begin
        if NxIsEmptyOID(headVATCode) then begin
          pcError:= 'DPH na hlavičce nenastaveno, doklad nelze vytvořit.';
          logs.Add(pcError);
          exit;
        end;

        OS.SQLSelect('SELECT VATRate_ID FROM VATIndexes WHERE ID='+QuotedStr(AnsiUpperCase(headVATCode)),ret);
        if ret.Count=0 then begin
          pcError:= 'DPH sazba k DPH indexu nedohledána, přeskakuji.';
          logs.Add(pcError);
          exit;
        end;
        row.SetFieldValueAsString('VATRate_ID',ret[0]);
        row.SetFieldValueAsString('VATIndex_ID', AnsiUpperCase(headVATCode));
      end;

      if not NxIsEmptyOID(AnsiUpperCase(headBusTransaction)) then begin
        row.SetFieldValueAsString('BusTransaction_ID', AnsiUpperCase(headBusTransaction));
      end;

      if NxIsEmptyOID(AnsiUpperCase(headExpenseType)) then begin
        pcError:= 'Typ výdaje na hlavičce nenastaveno, doklad nelze vytvořit.';
        logs.Add(pcError);
        exit;
      end;
      row.SetFieldValueAsString('ExpenseType_ID', AnsiUpperCase(headExpenseType));

      if NxIsEmptyOID(AnsiUpperCase(headDivision)) then begin
        pcError:= 'Středisko na hlavičce nenastaveno, doklad nelze vytvořit.';
        logs.Add(pcError);
        exit;
      end;
      row.SetFieldValueAsString('Division_ID', AnsiUpperCase(headDivision));
      {
      if NxIsEmptyOID(headBusOrder) then begin
        logs.Add('Zakázka na hlavičce nenastavena, doklad nelze vytvořit.');
        exit;
      end;
      }
      if not NxIsEmptyOID(AnsiUpperCase(headBusOrder)) then begin
        row.SetFieldValueAsString('BusOrder_ID', AnsiUpperCase(headBusOrder));
      end;

      if not NxIsEmptyOID(AnsiUpperCase(headBusProject)) then begin
        row.SetFieldValueAsString('BusProject_ID', AnsiUpperCase(headBusProject));
      end;

      row.SetFieldValueAsString('Text', Copy(annotationsMap.S['description'],1,160));
      row.SetFieldValueAsFloat(lcAmountFieldName, GetFloatDef(annotationsMap.S['total_base']));
      if lbVATDocument and (fp.GetFieldValueAsInteger('TradeType')=1)
           and (annotationsMap.S['total_tax']<>'') and (abs(row.GetFieldValueAsFloat('VATTAmount')-GetFloatDef(annotationsMap.S['total_tax']))>0.00001)
        then row.SetFieldValueAsFloat('VATTAmount', GetFloatDef(annotationsMap.S['total_tax']));
    end;

    // kurz
    if (GetFloatDef(annotationsMap.S['exchange_rate'])<>0) and (AnsiUpperCase(fp.GetFieldValueasString('Currency_ID.Code'))<>'CZK') then begin
      fp.SetFieldValueAsFloat('CurrRate',GetFloatDef(annotationsMap.S['exchange_rate']));
    end;

    if (AnsiUpperCase(NxLeft(fp.GetFieldValueAsString('Firm_ID.VATIdentNumber'),2))='CZ')
        and (AnsiUpperCase(fp.GetFieldValueAsString('Currency_ID.Code'))<>'CZK')
        and (GetFloatDef(annotationsMap.S['exchange_rate'])=0) then begin
      pcError:= 'Faktura je od českého plátce, v cizí měně, ale nemá zadán kurz.';
      logs.Add(pcError);
      exit;
    end;

    try
      if fp.HasField('X_PrijemceSchvalovani_ID') then begin
        lcPrijemceSchvalovani_ID:= annotationsMap.S['approverabra_id'];
        if not NxIsEmptyOID(lcPrijemceSchvalovani_ID) then fp.SetFieldValueAsString('X_PrijemceSchvalovani_ID', lcPrijemceSchvalovani_ID);
      end;
    except
    end;

    {
    // pridej poznamku
    note:=Copy(trim(annotationsMap.S['note']), 1, 160);
    if note<>'' then begin
      if rows.CountOfNotDeleted>0 then begin
        addNote(OS
          , rows.FirstBusinessObject.GetFieldValueAsString('VATIndex_ID')
          , rows.FirstBusinessObject.GetFieldValueAsString('Division_ID')
          , note
          , rows);
      end else begin
        addNote(OS, headVATCode, headDivision, note, rows);
      end;
    end;
    }

    if not pbZkracenyLog then logs.Add('Ukládám');
    try
      if not fp.Validate then begin
        pcError:= 'Chyba při validaci faktury: '+GetValidateErrs(fp);
        logs.Add(pcError);
      end
      else begin
        fp.Save;
        FP_ID:=fp.OID;
        lcFP_Name:= fp.DisplayName;
        logs.Add('Vytvořeno: '+lcFP_Name);
        if pbPairPR then begin
          logs.Add('Realizace párování na příjemky ('+NxIifStr(pnPRSearchType=0,'kód nebo EAN',NxIifStr(pnPRSearchType=1,'(kód nebo EAN) a název','název'))+') skončilo s následujícím výsledkem: '
                   +#13#10+PairPR(OS, laFPRowsData, fp.OID, fp.GetFieldValueasString('Firm_ID'), fp.GetFieldValueasString('Currency_ID'), pcPRDocQueues, pnPRDaysBack, pnPRSearchType)
                   );
        end;
      end;

      //logs.Add('Def_Doc_DQ_ID: '+Def_Doc_DQ_ID);
      //logs.Add('Def_Doc_DC_ID: '+Def_Doc_DC_ID);
    except
      pcError:= 'Neočekávaná chyba při ukládání faktury: '+ExceptionMessage;
      logs.Add(pcError);
    end;

    if not NxIsEmptyOID(FP_ID) then begin
      try
        // FILE
        if (not NxIsEmptyOID(Def_Doc_DQ_ID)) AND (not NxIsEmptyOID(Def_Doc_DC_ID))
        then begin
          str:= downloadFile(OS, '04', Document_ID, fp.OID, Firm_ID, Def_Doc_DQ_ID, Def_Doc_DC_ID, AUTH_TOKEN, pcQueue_ID, lcDigitooSourceFileName);
          if str<>'' then logs.Add('Došlo k chybě při stažení PDF dokladu: '+str);
        end
        else begin
          logs.Add('Vyplňte v agendě typ a řadu pro přílohu.');
        end;
      except
        logs.Add('Chyba při stahování PDF: '+ExceptionMessage);
      end;
      if pbImportAllAttachments  then begin  //přílohy
        try
          if (not NxIsEmptyOID(Def_Doc_DQ_ID)) AND (not NxIsEmptyOID(Def_Doc_DC_ID))
            then downloadAttachments(OS, '04', Document_ID, fp.OID, Firm_ID, Def_Doc_DQ_ID, Def_Doc_DC_ID, AUTH_TOKEN, logs);
        except
          logs.Add('Chyba při stahování příloh: '+ExceptionMessage);
        end;
      end;
      if pbImportDates then begin  //časová razítka
        try
          GetTimeStamps(OS, '04', Document_ID, fp.OID, AUTH_TOKEN, logs, pbZkracenyLog);
        except
          logs.Add('Chyba při stahování časových razítek: '+ExceptionMessage);
        end;
      end;
      if AnsiUpperCase(annotationsMap.S['payment_order'])='YES' then begin
        lfCastkaKUhrade:= 0;
        try
          lfCastkaKUhrade:= GetFloatDef(annotationsMap.S['total_due']);
        except
          lfCastkaKUhrade:= fp.GetFieldValueAsFloat('Amount');
        end;
        if lfCastkaKUhrade>0 then begin
          if not pbZkracenyLog then logs.Add('Generuji žádost platebního příkazu.');
          try
            GenerujZadostPP(fp,'04',lfCastkaKUhrade,logs, pbZkracenyLog);
          except
          end;
        end
        else begin
          logs.Add('Částka k úhradě je nulová, nemá smysl generovat žádost platebního příkazu, jak je požadováno.');
        end;
      end;
      if fp.GetFieldValueAsBoolean('IsReverseChargeDeclared') then begin
        str:= '';
        if not pbZkracenyLog then logs.Add('Generuji doklad DRC.');
        lfDigitooDRCVATRate:= -1;
        lcDigitooDRCVATIndex_ID:= '';
        lcDigitooDRCVATRate_ID:= '';
        try
          lcDigitooDRCVATRate:= annotationsMap.S['rch_vatrate'];
          lfDigitooDRCVATRate:= GetFloatDef(lcDigitooDRCVATRate, -1);
        except
        end;
        try
          lcDigitooDRCVATIndex_ID:= annotationsMap.S['rch_vatindex_id'];
        except
        end;
        if lfDigitooDRCVATRate>=0 then begin
          OS.SQLSelect('SELECT VR.ID'
                +#13' FROM VATRates VR'
                +#13' JOIN COUNTRIES C ON C.ID = VR.Country_ID'
                +#13' WHERE C.ID='+QuotedStr(lmContext.GetCompanyCache.CountryID)
                +#13'       AND VR.Hidden=''N'''
                +#13'       AND VR.Tariff='+GetSQLFloat(lfDigitooDRCVATRate),ret);
          if ret.Count>0 then lcDigitooDRCVATRate_ID:= ret[0];
        end;
        if not NxIsEmptyOID(lcDigitooDRCVATIndex_ID) then begin
          OS.SQLSelect('SELECT VATRate_ID FROM VATIndexes WHERE ID='+QuotedStr(AnsiUpperCase(lcDigitooDRCVATIndex_ID)),ret);
          if lfDigitooDRCVATRate<0 then begin
            if ret.Count=0 then begin
              str:= 'DPH sazba k DPH indexu nedohledána.';
            end
            else begin
              lcDigitooDRCVATRate_ID:= ret[0];
            end;
          end
          else begin
            OS.SQLSelect('SELECT Tariff FROM VATRates WHERE ID='+QuotedStr(AnsiUpperCase(ret[0]))+' AND VR.Hidden=''N''',ret);
            if Abs(GetFloatDef(ret[0])-lfDigitooDRCVATRate)>0.000001 then begin
              str:= 'DPH sazba neodpovídá DPH indexu.';
            end;
          end;
        end;
        try
          if str='' then str:= GenerujDRC(fp, pcDRCDocQueue_ID, NxIifStr(NxIsEmptyOID(lcDigitooDRCVATRate_ID),pcDRCVATRate_ID,lcDigitooDRCVATRate_ID), lcDigitooDRCVATIndex_ID);
          if str<>'' then str:= 'Chyba při vytváření dokladu DRC: '+str
                     else str:= 'Doklad DRC vygenerován.';
          logs.Add(str);
        except
        end;
      end;
    end;
  finally
    Result:= lcFP_Name;
    fp.Free;
    ret.Free;
    sqlRow.Free;
    lmContext.Free;
    laFPRowsData.Free;
  end;
end;

function CreateFV(OS:TNxCustomObjectSpace;
                  jsonObj:TJSONSuperObject;
                  logs:TStrings;
                  Def_Firm_ID, Def_Division_ID,
                  Def_Doc_DQ_ID, Def_Doc_DC_ID, AUTH_TOKEN, Document_ID, pcQueue_ID: string;
                  pbImportAllAttachments: boolean;
                  pbDoNotUpdateFirms, pbImportDates: boolean;
                  var pcError: string;
                  pbOrgIdentNumberCheck: boolean;
                  pbZkracenyLog: boolean):string;
var
  ret, sqlRow: TStringList;
  fp, row, firm, bankAcc, obj, loAddress: TNxCustomBusinessObject;
  rows, rows2: TNxCustomBusinessMonikerCollection;
  annotationsMap, SRow: TJSONSuperObject;
  i, TradeType: Integer;
  Err, Firm_ID, Division_ID, SQL, FP_ID, headVATCode, lcFP_Name, lcFieldName, lcVATIndex_ID, lcVATRate_ID
  , headDivision, headBusOrder, selectedVAT, FirmBankAccount, FirmBankAccount_ID, lcCurrency_ID, lcICDPH
  , note, DQ_ID, headKontace, headBusTransaction, strText, str, lcDocumentURL, headIncomeType, headBusProject
  , lcICO, lcDIC, lcFirmName, lcCountry_ID, lcCountry_Code, lcElementName, lcCountry, lcSQL, lcIBAN, lcStreet, lcCity, lcPostCode
  , lcHeadBillOfDeliveryNmb, lcRowBillOfDeliveryNmb, lcDigitooSourceFileName, lcSwiftCode: string;
  amount, q, lfCastkaKUhrade: Double;
  FromHeader, lbVATDocument: Boolean;
  lmContext: TNxContext;
begin
  Result:= '';
  FP_ID:= '';
  lcFP_Name:= '';
  pcError:= '';
  Err:='';
  lcHeadBillOfDeliveryNmb:= '';
  lcRowBillOfDeliveryNmb:= '';

  lmContext:= NxCreateContext(OS);
  ret:=TStringList.Create;
  sqlRow:=TStringList.Create;
  sqlRow.Delimiter:=';';
  fp:=OS.CreateObject(Class_IssuedInvoice);
  try

    if AnsiUpperCase(jsonObj.S['status'])<>'READY-TO-EXPORT' then begin
      pcError:= 'Nepodporovaný status dokladu, přeskakuji.';
      logs.Add(pcError);
      exit;
    end;

    annotationsMap:= jsonObj.O['annotations'];

    {
    if AnsiUpperCase(annotationsMap.S['document_type'])<>'TAX_INVOICE' then begin
      pcError:= 'Nejedná se o typ dokladu faktura přijatá.';
      logs.Add(pcError);
      exit;
    end;
    }

    lcDocumentURL:= jsonObj.S['document_url'];
    if lcDocumentURL='' then lcDocumentURL:= jsonObj.S['id'];
    lcDigitooSourceFileName:= jsonObj.S['file_name'];

    DQ_ID:= AnsiUpperCase(annotationsMap.S['accounting_sequence']);
    if NxIsEmptyOID(DQ_ID) then begin
      pcError:= 'Řada dokladu nezadána.';
      logs.Add(pcError);
      exit;
    end;

    try
      if pbOrgIdentNumberCheck then begin
        if (Trim(annotationsMap.S['sender_register_id'])<>'')
            and (lmContext.GetCompanyCache.OrgIdentNumber<>'')
            and (Trim(annotationsMap.S['sender_register_id'])<>lmContext.GetCompanyCache.OrgIdentNumber) then begin
          pcError:= 'IČO dodavatele na dokladu neodpovídá IČO ve firemních údajích v Abře.';
          logs.Add(pcError);
          exit;
        end;
      end;
    except
    end;

    // Udaje z hlavičky, maji prednost na radcich
    headVATCode:=AnsiUpperCase(annotationsMap.S['vat_code']);
    headKontace:=AnsiUpperCase(annotationsMap.S['assignment']);
    headDivision:=AnsiUpperCase(annotationsMap.S['cost_center']);
    headBusOrder:=AnsiUpperCase(annotationsMap.S['contract']);
    headBusProject:=AnsiUpperCase(annotationsMap.S['project']);
    headIncomeType:=AnsiUpperCase(annotationsMap.S['income_type_code']);
    headBusTransaction:=AnsiUpperCase(annotationsMap.S['activity']); // obchodni pripad na hlavicce

    fp.New;
    fp.Prefill;

    lbVATDocument:= IsVATDocument(annotationsMap);

    fp.SetFieldValueAsBoolean('VATDocument', lbVATDocument);
    if lbVATDocument then fp.SetFieldValueAsBoolean('PricesWithVAT', False);

    // Firma - povinna polozka - dohledava se dle ICO
    lcICO:= NxLeft(Trim(annotationsMap.S['recipient_register_id']),15);
    lcDIC:= NxLeft(Trim(annotationsMap.S['recipient_tax_id']),20);
    lcICDPH:= NxLeft(Trim(annotationsMap.S['recipient_vat_id']),20);
    lcFirmName:= NxLeft(Trim(annotationsMap.S['recipient_name']),220);
    Firm_ID:= '';
    try
      Firm_ID:= Trim(annotationsMap.S['recipient_internal_id']);
      if NxIsEmptyOID(Firm_ID) then Firm_ID:= '';
    except
    end;
    if NxIsEmptyOID(Firm_ID) then begin
      if not GetFirm_ID(OS, lcICO, lcDIC, lcICDPH, lcFirmName, NxLeft(Trim(annotationsMap.S['recipient_address']),255),
                        NxLeft(Trim(annotationsMap.S['recipient_street']),60),
                        NxLeft(Trim(annotationsMap.S['recipient_city']),60),
                        NxLeft(Trim(annotationsMap.S['recipient_post_code']),10),
                        Trim(annotationsMap.S['recipient_country']),
                        logs, pbDoNotUpdateFirms, pcError, Firm_ID) then exit;
    end
    else begin
      if not pbZkracenyLog then logs.Add('Nastavuji zaslanou firmu "'+GetData(OS,'Firms','ID',Firm_ID,'Name')+'".');
    end;

    // měna
    if annotationsMap.S['currency']<>'' then begin
      //logs.Add('Hledám měnu.');
      OS.SQLSelect('SELECT ID FROM Currencies WHERE Upper(Code)='+QuotedStr(AnsiUpperCase(annotationsMap.S['currency'])),ret);
      if ret.count>0 then
      begin
        lcCurrency_ID:= ret[0];
        if not pbZkracenyLog then logs.Add('Nastavuji měnu.');
        fp.SetFieldValueAsString('Currency_ID', lcCurrency_ID);
      end else begin
        if not pbZkracenyLog then logs.Add('Měna nedohledána.');
      end;
    end;

    if (NxIsEmptyOID(Firm_ID)) AND (not NxIsEmptyOID(Def_Firm_ID))
    then begin
      Firm_ID:=Def_Firm_ID;
      if not pbZkracenyLog then logs.Add('Nastavuji výchozí firmu.');
    end;

    if NxIsEmptyOID(Firm_ID)
    then begin
      pcError:= 'Firmu se nepodařilo nastavit, přeskakuji.';
      logs.Add(pcError);
      exit;
    end;

    fp.SetFieldValueAsString('DocQueue_ID',DQ_ID);
    // Kontace
    if not NxIsEmptyOID(headKontace) then begin
      fp.SetFieldValueAsString('AccPresetDef_ID',headKontace);
    end;

    //lcElementName:= 'report_code';
    lcElementName:= 'trade_code';
    if (annotationsMap.S[lcElementName]<>'') and (Length(annotationsMap.S[lcElementName])<>10) then begin
      TradeType:=StrToInt(annotationsMap.S[lcElementName]);
      if (TradeType>0) AND (TradeType<7) then begin
      fp.SetFieldValueAsInteger('TradeType', TradeType);
      end;
    end;

    fp.SetFieldValueAsString('Firm_ID', Firm_ID);
    if not NxIsEmptyOID(lcCurrency_ID) then fp.SetFieldValueAsString('Currency_ID', lcCurrency_ID);
    fp.SetFieldValueAsString('ExternalNumber',trim(Copy(annotationsMap.S['invoice_id'],1,30)));
    if fp.GetFieldValueAsString('ExternalNumber')<>'' then begin
      lcSQL:= 'Select A.ID'
          +#13' from IssuedInvoices A'
          +#13' join Firms F on F.ID=A.Firm_ID'
          +#13' where coalesce(F.Firm_ID,F.ID)='+QuotedStr(NxIIfStr(not NxIsEmptyOID(fp.GetFieldValueAsString('Firm_ID.Firm_ID')),fp.GetFieldValueAsString('Firm_ID.Firm_ID'),fp.GetFieldValueAsString('Firm_ID')))
          +#13'       and Upper(A.ExternalNumber)='+QuotedStr(AnsiUpperCase(fp.GetFieldValueAsString('ExternalNumber')));
      OS.SQLSelect(lcSQL, ret);
      if ret.Count>0 then begin
        pcError:= 'Pro firmu "'+fp.GetFieldValueAsString('Firm_ID.Name')+'" již existuje faktura vydaná s externím číslem "'+fp.GetFieldValueAsString('ExternalNumber')+'", přeskakuji.';
        logs.Add(pcError);
        exit;
      end;
    end;

    if fp.GetFieldValueAsInteger('TradeType') in [2,3,4] then begin
      lcCountry_Code:= '';
      try
        lcCountry_Code:= NxIifStr(Length(Trim(annotationsMap.S['recipient_country']))=10,GetData(OS, 'Countries', 'ID', Trim(annotationsMap.S['recipient_country']), 'Code'), NxLeft(Trim(annotationsMap.S['recipient_country']),3));
      except
      end;
      if lcCountry_Code='' then lcCountry_Code:= NxLeft(fp.GetFieldValueAsString('Firm_ID.ResidenceAddress_ID.CountryCode'),2);
      if lcCountry_Code='' then lcCountry_Code:= NxLeft(fp.GetFieldValueAsString('Firm_ID.VATIdentNumber'),2);
      if lcCountry_Code='' then lcCountry_Code:= NxLeft(lcDIC,2);
      lcCountry_Code:= AnsiUpperCase(lcCountry_Code);
      lcCountry_ID:= GetData(OS, 'Countries', 'Code', lcCountry_Code, 'ID', True, 'Hidden=''N''');
      if not NxIsEmptyOID(lcCountry_ID) then begin
        fp.SetFieldValueAsString('Country_ID', lcCountry_ID);
        if not NxIsEmptyOID(lcCurrency_ID) then fp.SetFieldValueAsString('Currency_ID', lcCurrency_ID);
      end;
    end;

    if lmContext.GetCompanyCache.OrgIdentNumber='26230224' then begin  //Magsy to chce jinak (dle Data uplatnění odpočtu)
      if annotationsMap.S['received_date']<>'' then begin
        fp.SetFieldValueAsDateTime('DocDate$DATE', annotationsMap.DT8601['received_date']);
        fp.SetFieldValueAsString('Period_ID',GetPeriodOS(OS,annotationsMap.DT8601['received_date']));
        if NxIsEmptyOID(fp.GetFieldValueAsString('Period_ID')) then begin
          pcError:= 'Dle data uplatnění odpočtu nebylo v Abře dohledáno odpovídající období.';
          logs.Add(pcError);
          exit;
        end;
      end
      else begin
        fp.SetFieldValueAsDateTime('DocDate$DATE', Date);
        fp.SetFieldValueAsString('Period_ID',GetPeriodOS(OS,fp.GetFieldValueAsDateTime('DocDate$DATE')));
        {
        pcError:= 'Nebyl zaslán datum uplatnění odpočtu';
        logs.Add(pcError);
        exit;
        }
      end;
    end
    else begin
      if annotationsMap.S['issue_date']<>'' then begin
        fp.SetFieldValueAsDateTime('DocDate$DATE', annotationsMap.DT8601['issue_date']);
        fp.SetFieldValueAsString('Period_ID',GetPeriodOS(OS,annotationsMap.DT8601['issue_date']));
        if NxIsEmptyOID(fp.GetFieldValueAsString('Period_ID')) then begin
          pcError:= 'Dle data vystavení nebylo v Abře dohledáno odpovídající období.';
          logs.Add(pcError);
          exit;
        end;
      end
      else begin
        fp.SetFieldValueAsDateTime('DocDate$DATE', Date);
        fp.SetFieldValueAsString('Period_ID',GetPeriodOS(OS,fp.GetFieldValueAsDateTime('DocDate$DATE')));
        {
        pcError:= 'Nebyl zaslán datum vystavení';
        logs.Add(pcError);
        exit;
        }
      end;
    end;
    if (annotationsMap.S['taxable_supply_date']<>'') and lbVATDocument then begin
      fp.SetFieldValueAsDateTime('VATAdmitDate$DATE', annotationsMap.DT8601['taxable_supply_date']);
    end;
    if annotationsMap.S['accounting_date']<>'' then begin
      fp.SetFieldValueAsDateTime('AccDate$DATE', annotationsMap.DT8601['accounting_date']);
    end;

    fp.SetFieldValueAsString('X_DigiTooInvoice_ID',annotationsMap.S['invoice_id']);
    fp.SetFieldValueAsString('X_DigitooDocumentUrl',lcDocumentURL);
    fp.SetFieldValueAsString('VarSymbol',annotationsMap.S['var_sym']);
    fp.SetFieldValueAsString('X_Poznamka',annotationsMap.S['note']);
    str:=trim(Copy(annotationsMap.S['description'],1,50));
    if str='' then str:=trim(Copy(annotationsMap.S['note'],1,50));
    fp.SetFieldValueAsString('Description',str);

    if (annotationsMap.S['received_date']<>'') and lbVATDocument then begin
      fp.SetFieldValueAsDateTime('VatDate$DATE', annotationsMap.DT8601['received_date']);
    end;

    if ExistujeUzaverkaDPH(OS, fp.GetFieldValueAsDateTime('VatDate$DATE')) then begin
      pcError:= 'Datum uplatnění odpočtu  '+FormatDateTime('DD.MM.YYYY', fp.GetFieldValueAsDateTime('VatDate$DATE'))+' je již v Abře uzavřeno uzávěrkou DPH.';
      logs.Add(pcError);
      exit;
    end;

    if annotationsMap.S['due_date']<>'' then begin
      fp.SetFieldValueAsDateTime('DueDate$DATE', annotationsMap.DT8601['due_date']);
    end;
    fp.SetFieldValueAsFloat('RoundingAmount', GetFloatDef(annotationsMap.S['total_rounding']));

    // Bankovni ucet
    FirmBankAccount:= '';
    try
      if annotationsMap.A['bank_account'].length>0 then begin
        FirmBankAccount:= StringReplace(AnsiUpperCase(trim(annotationsMap.A['bank_account'].S[0])),' ','',[rfReplaceAll]);
      end;
    except
      if FirmBankAccount='' then FirmBankAccount:= StringReplace(AnsiUpperCase(trim(annotationsMap.S['bank_account'])),' ','',[rfReplaceAll]);
    end;
    lcIBAN:= '';
    try
      if annotationsMap.A['iban'].length>0 then begin
        lcIBAN:= StringReplace(AnsiUpperCase(trim(annotationsMap.A['iban'].S[0])),' ','',[rfReplaceAll]);
      end;
    except
      if lcIBAN='' then lcIBAN:= StringReplace(AnsiUpperCase(trim(annotationsMap.S['iban'])),' ','',[rfReplaceAll]);
    end;
    lcSwiftCode:= '';
    try
      if annotationsMap.A['bic'].length>0 then begin
        lcSwiftCode:= StringReplace(AnsiUpperCase(trim(annotationsMap.A['bic'].S[0])),' ','',[rfReplaceAll]);
      end;
    except
      if lcSwiftCode='' then lcSwiftCode:= StringReplace(AnsiUpperCase(trim(annotationsMap.S['bic'])),' ','',[rfReplaceAll]);
    end;
    if (FirmBankAccount<>'') or (lcIBAN<>'') then begin
      ret.Clear;
      SQL:='SELECT ID'
       +#13' FROM BankAccounts'
       +#13' WHERE ('+NxIIfStr(FirmBankAccount<>'','Upper(Replace(BankAccount,'' '',''''))='+QuotedStr(FirmBankAccount),'')
       +#13'       '+NxIIfStr(lcIBAN<>'',NxIifStr(FirmBankAccount<>'','or','')+' (Upper(Replace(IBANCode,'' '',''''))='+QuotedStr(lcIBAN),'')
       +#13'       '+NxIIfStr((lcIBAN<>'') and (lcSwiftCode<>''),' and Upper(Replace(SwiftCode,'' '',''''))='+QuotedStr(lcSwiftCode)+')',NxIIfStr(lcIBAN<>'',')',''))+')';
      OS.SQLSelect(SQL, ret);
      if ret.Count>0 then begin
        FirmBankAccount_ID:= ret[0];
        fp.SetFieldValueAsString('BankAccount_ID', FirmBankAccount_ID);
        if not pbZkracenyLog then logs.Add('Nastavuji bankovní účet.');
      end
      else begin
        pcError:= 'Bankovní účet '+NxIIfStr(FirmBankAccount<>'',FirmBankAccount,lcIBAN)+' nedohledán, přeskakuji.';
        logs.Add(pcError);
        exit;
      end;
    end
    else begin
       pcError:= 'Bankovní účet nebyl zaslán, přeskakuji.';
      logs.Add(pcError);
      exit;
    end;

    // Typ úhrady
    if (trim(annotationsMap.S['payment_type'])<>'') AND (not NxIsEmptyOID(trim(annotationsMap.S['payment_type']))) then begin
      fp.SetFieldValueAsString('PaymentType_ID',AnsiUpperCase(trim(annotationsMap.S['payment_type'])));
    end;

    {
    if not NxIsEmptyOID(Def_Predkontace) then begin
      fp.SetFieldValueAsString('AccPresetDef_ID',Def_Predkontace);
    end;
    }

    rows:=fp.GetLoadedCollectionMonikerForFieldCode(fp.GetFieldCode('Rows'));
    try
      FromHeader:=false;
      try
        FromHeader:= annotationsMap.A['line_items'].length=0;
      except
        FromHeader:=true;
        if not pbZkracenyLog then logs.Add('Řádky se nepodařilo vytvořit, zkouším vytvořit řádek na základě údajů z hlavičky.');
      end;

      if not(FromHeader) then begin
        for i:=0 to annotationsMap.A['line_items'].length-1 do begin // radky
          SRow:=annotationsMap.A['line_items'].N[i];
          row:=rows.AddNewObject;
          row.Prefill;

          if lbVATDocument then begin
            // DPH
            if not NxIsEmptyOID(SRow.S['vat_code'])
            then begin
              OS.SQLSelect('SELECT VATRate_ID FROM VATIndexes WHERE ID='+QuotedStr(AnsiUpperCase(SRow.S['vat_code'])),ret);
              if ret.Count=0 then begin
                if not pbZkracenyLog then logs.Add('DPH sazba k DPH indexu nedohledána, přeskakuji.');
                row.MarkForDelete;
                continue;
              end;
              row.SetFieldValueAsString('VATRate_ID',ret[0]);
              row.SetFieldValueAsString('VATIndex_ID', AnsiUpperCase(SRow.S['vat_code']));
            end
            else begin
              case fp.GetFieldValueasInteger('TradeType') of
                2: lcFieldName:= 'IncomeForeignEUDefVATIndex_ID';
                3: lcFieldName:= 'IncomeForeignDefVATIndex_ID';
                4: lcFieldName:= 'IncomeForeignEUDefVATIndex_ID';
              else lcFieldName:= 'IncomeDomesticDefVATIndex_ID';
              end;
              if SRow.S['tax_rate']<>'' then begin
                OS.SQLSelect('SELECT VR.ID, VR.'+lcFieldName
                +#13' FROM VATRates VR'
                +#13' JOIN COUNTRIES C ON C.ID = VR.Country_ID'
                +#13' WHERE C.ID='+QuotedStr(lmContext.GetCompanyCache.CountryID)
                +#13'       AND VR.Hidden=''N'''
                +#13'       AND VR.Tariff='+GetSQLFloat(GetFloatDef(SRow.S['tax_rate'])),ret);
                if ret.Count=0 then begin
                  if not pbZkracenyLog then logs.Add('DPH nenačteno, přeskakuji řádek.');
                  row.MarkForDelete;
                  continue;
                end;
                sqlrow.DelimitedText:= ret[0];
                lcVATRate_ID:= sqlrow[0];
                lcVATIndex_ID:= sqlrow[1];
                if not NxIsEmptyOID(headVATCode) then begin
                  if CheckIndexForVATRate(OS, headVATCode, lcVATRate_ID, fp.GetFieldValueAsInteger('TradeType'),False)
                    then lcVATIndex_ID:= headVATCode;
                end;
                if NxIsEmptyOID(lcVATIndex_ID) then begin
                  if not pbZkracenyLog then logs.Add('DPH index k DPH sazbě nedohledán, přeskakuji řádek.');
                  row.MarkForDelete;
                  continue;
                end;
                row.SetFieldValueAsString('VATRate_ID',lcVATRate_ID);
                row.SetFieldValueAsString('VATIndex_ID',lcVATIndex_ID);
              end
              else begin
                if not NxIsEmptyOID(headVATCode) then begin
                  OS.SQLSelect('SELECT VATRate_ID FROM VATIndexes WHERE ID='+QuotedStr(AnsiUpperCase(headVATCode)),ret);
                  if ret.Count=0 then begin
                    if not pbZkracenyLog then logs.Add('DPH sazba k DPH indexu nedohledána, přeskakuji.');
                    row.MarkForDelete;
                    continue;
                  end;
                  row.SetFieldValueAsString('VATRate_ID',ret[0]);
                  row.SetFieldValueAsString('VATIndex_ID', AnsiUpperCase(headVATCode));
                end
                else begin
                  // DPH neni zadano, preskakuji
                  if not pbZkracenyLog then logs.Add('DPH nenačteno, přeskakuji řádek.');
                  row.MarkForDelete;
                  continue;
                end;
              end;
            end;
          end;

          // Typ příjmu
          if not NxIsEmptyOID(AnsiUpperCase(SRow.S['income_type_code']))
          then begin
            row.SetFieldValueAsString('IncomeType_ID', AnsiUpperCase(SRow.S['income_type_code']));
          end
          else begin
            if not NxIsEmptyOID(AnsiUpperCase(headIncomeType))
            then begin
              row.SetFieldValueAsString('IncomeType_ID',AnsiUpperCase(headIncomeType));
            end
            else begin
              if not pbZkracenyLog then logs.Add('Typ příjmu nenačten.');
            end;
          end;

          if not NxIsEmptyOID(AnsiUpperCase(SRow.S['activity'])) then begin
            row.SetFieldValueAsString('BusTransaction_ID', AnsiUpperCase(SRow.S['activity']));
          end
          else begin
             if not NxIsEmptyOID(AnsiUpperCase(headBusTransaction))
            then begin
              row.SetFieldValueAsString('BusTransaction_ID',AnsiUpperCase(headBusTransaction));
            end
            else begin
              if not pbZkracenyLog then logs.Add('Obchodní případ nenačten.');
            end;
          end;

          // Division_ID
          if not NxIsEmptyOID(AnsiUpperCase(SRow.S['cost_center']))
          then begin
            row.SetFieldValueAsString('Division_ID', AnsiUpperCase(SRow.S['cost_center']));
          end
          else begin
            if not NxIsEmptyOID(AnsiUpperCase(headDivision))
            then begin
              row.SetFieldValueAsString('Division_ID',AnsiUpperCase(headDivision));
            end
            else begin
              if not NxIsEmptyOID(AnsiUpperCase(Def_Division_ID)) then begin
                logs.Add('Nastavuji výchozí středisko.');
                row.SetFieldValueAsString('Division_ID', AnsiUpperCase(Def_Division_ID));
              end
              else begin
                if not pbZkracenyLog then logs.Add('Středisko nenastaveno, přeskakuji řádek.');
                row.MarkForDelete;
                continue;
              end;
            end;
          end;

          // BusOrder
          if not NxIsEmptyOID(AnsiUpperCase(SRow.S['contract']))
          then begin
            row.SetFieldValueAsString('BusOrder_ID', AnsiUpperCase(SRow.S['contract']));
          end
          else begin
            if not NxIsEmptyOID(AnsiUpperCase(headBusOrder))
            then begin
              row.SetFieldValueAsString('BusOrder_ID',AnsiUpperCase(headBusOrder));
            end
            else begin
              if not pbZkracenyLog then logs.Add('Zakázka nenastavena.');
            end;
          end;

          // BusProject
          if not NxIsEmptyOID(AnsiUpperCase(SRow.S['project']))
          then begin
            row.SetFieldValueAsString('BusProject_ID', AnsiUpperCase(SRow.S['project']));
          end
          else begin
            if not NxIsEmptyOID(AnsiUpperCase(headBusProject))
            then begin
              row.SetFieldValueAsString('BusProject_ID',AnsiUpperCase(headBusProject));
            end
            else begin
              if not pbZkracenyLog then logs.Add('Projekt nenastaven.');
            end;
          end;

          if SRow.S['quantity']<>'' then begin
            row.SetFieldValueAsInteger('RowType',2);
            row.SetFieldValueAsFloat('UnitQuantity',GetFloatDef(SRow.S['quantity']));
          end
          else begin
            row.SetFieldValueAsInteger('RowType',1);
          end;
          if GetFloatDef(SRow.S['total_base'])<>0 then begin
            row.SetFieldValueAsFloat('UnitPrice', 0);
            row.SetFieldValueAsFloat('TotalPrice', GetFloatDef(SRow.S['total_base']));
          end
          else begin
            row.SetFieldValueAsFloat('UnitPrice', GetFloatDef(SRow.S['unit_base']));
          end;

          // Text na radku
          strText:='';
          if SRow.S['code']<>'' then strText:=SRow.S['code'];
          if SRow.S['description']<>'' then strText:=strText+NXIifStr(strText<>'',': ','')+SRow.S['description'];
          row.SetFieldValueAsString('Text', Copy(strText,1,160));

          if fp.GetFieldValueAsInteger('TradeType')=2 then begin
            if trim(SRow.S['to_esl'])<>'' then row.SetFieldValueAsInteger('ESLStatus', StrToIntDef(trim(SRow.S['to_esl']),0));
            if not NxIsEmptyOID(trim(SRow.S['esl_indicator'])) then row.SetFieldValueAsString('ESLIndicator_ID', trim(SRow.S['esl_indicator']));
          end;
        end;
        if rows.CountOfNotDeleted=0 then begin
          if not pbZkracenyLog then logs.Add('Řádky se nepodařilo vytvořit, zkouším vytvořit řádek na základě údajů z hlavičky.');
          FromHeader:=true;
        end;
      end;
    except
      if not pbZkracenyLog then logs.Add('Řádky se nepodařilo vytvořit, zkouším vytvořit řádek na základě údajů z hlavičky.');
      row.MarkForDelete;
      FromHeader:=true;
    end;

    if FromHeader then begin
      // tax_detail - vytvor radky z rekapitulace
      if lbVATDocument then begin
        FromHeader:= False;
        try
          try
            FromHeader:= annotationsMap.A['tax_detail'].length=0;
          except
            FromHeader:=true;
            if not pbZkracenyLog then logs.Add('Rekapitulace nezadána.');
          end;

          if not(FromHeader) then begin
            annotationsMap.A['tax_detail'].length;
            if not pbZkracenyLog then logs.Add('Tvořím řádky z rekapitulace');
            for i:=0 to annotationsMap.A['tax_detail'].length-1 do begin // radky
              SRow:=annotationsMap.A['tax_detail'].N[i];
              if (SRow.S['rate']='')
                  OR ((SRow.S['base']='') AND (SRow.S['tax']=''))
              then begin
                if not pbZkracenyLog then logs.Add('Neúplné údaje na řádku rekapitulace, přeskakuji.');
                continue;
              end;
              if not pbZkracenyLog then logs.Add('Vytvářím řádek z rekapitulace.');

              row:=rows.AddNewObject;
              row.Prefill;
              row.SetFieldValueAsInteger('RowType', 1);

              if NxIsEmptyOID(AnsiUpperCase(headDivision)) then begin
                pcError:= 'Středisko na hlavičce nenastaveno, doklad nelze vytvořit.';
                logs.Add(pcError);
                exit;
              end;
              row.SetFieldValueAsString('Division_ID', AnsiUpperCase(headDivision));

              if NxIsEmptyOID(AnsiUpperCase(headIncomeType)) then begin
                pcError:= 'Typ příjmu na hlavičce nenastaveno, doklad nelze vytvořit.';
                logs.Add(pcError);
                exit;
              end;
              row.SetFieldValueAsString('IncomeType_ID', AnsiUpperCase(headIncomeType));

              if not NxIsEmptyOID(AnsiUpperCase(headBusTransaction)) then begin
                row.SetFieldValueAsString('BusTransaction_ID', AnsiUpperCase(headBusTransaction));
              end;
              if not NxIsEmptyOID(AnsiUpperCase(headBusOrder)) then begin
                row.SetFieldValueAsString('BusOrder_ID', AnsiUpperCase(headBusOrder));
              end;
              if not NxIsEmptyOID(AnsiUpperCase(headBusProject)) then begin
                row.SetFieldValueAsString('BusProject_ID', AnsiUpperCase(headBusProject));
              end;

              case fp.GetFieldValueasInteger('TradeType') of
                2: lcFieldName:= 'IncomeForeignEUDefVATIndex_ID';
                3: lcFieldName:= 'IncomeForeignDefVATIndex_ID';
                4: lcFieldName:= 'IncomeForeignEUDefVATIndex_ID';
              else lcFieldName:= 'IncomeDomesticDefVATIndex_ID';
              end;

              OS.SQLSelect('SELECT VR.ID, VR.'+lcFieldName
              +#13' FROM VATRates VR'
              +#13' JOIN COUNTRIES C ON C.ID = VR.Country_ID'
              +#13' WHERE C.ID='+QuotedStr(lmContext.GetCompanyCache.CountryID)
              +#13'       AND VR.Hidden=''N'''
              +#13'       AND VR.Tariff='+GetSQLFloat(GetFloatDef(SRow.S['rate'])),ret);
              if ret.Count=0 then begin
                if not pbZkracenyLog then logs.Add('DPH nenačteno, přeskakuji řádek.');
                row.MarkForDelete;
                continue;
              end;
              sqlrow.DelimitedText:= ret[0];
              lcVATRate_ID:= sqlrow[0];
              lcVATIndex_ID:= sqlrow[1];
              if not NxIsEmptyOID(headVATCode) then begin
                if CheckIndexForVATRate(OS, headVATCode, lcVATRate_ID, fp.GetFieldValueAsInteger('TradeType'),False)
                  then lcVATIndex_ID:= headVATCode;
              end;
              if NxIsEmptyOID(lcVATIndex_ID) then begin
                if not pbZkracenyLog then logs.Add('DPH index k DPH sazbě nedohledán, přeskakuji řádek.');
                row.MarkForDelete;
                continue;
              end;

              if ((SRow.S['rate']<>'')
                  AND
                  (SRow.S['base']<>''))
              then begin
                row.SetFieldValueAsString('VATRate_ID', lcVATRate_ID);
                row.SetFieldValueAsString('VATIndex_ID',lcVATIndex_ID);
                row.SetFieldValueAsFloat('TotalPrice', GetFloatDef(SRow.S['base']));
              end
              else begin
                if  ((SRow.S['rate']<>'')
                    AND
                    (GetFloatDef(SRow.S['rate'])<>0)
                    AND
                    (SRow.S['tax']<>''))
                then begin
                  row.SetFieldValueAsString('VATRate_ID', lcVATRate_ID);
                  row.SetFieldValueAsString('VATIndex_ID',lcVATIndex_ID);
                  row.SetFieldValueAsFloat('TotalPrice', GetFloatDef(SRow.S['tax'])/(GetFloatDef(SRow.S['rate'])/100));
                end;
              end;
              row.SetFieldValueAsString('Text', Copy(annotationsMap.S['description'],1,160));
            end;

            if rows.CountOfNotDeleted=0 then begin
              pcError:= 'Řádky se nepodařilo založil z rekapitulace, přeskakuji.';
              logs.Add(pcError);
              exit;
            end;
          end;
        except
          pcError:= 'Rekapitulace nezadána. '+ExceptionMessage;
          logs.Add(pcError);
          exit;
        end;
      end;
    end;

    if FromHeader then begin
      // Vytvarim novy radek z hlavicky
      row:=rows.AddNewObject;
      row.Prefill;
      row.SetFieldValueAsInteger('RowType', 1);

      if lbVATDocument then begin
        if NxIsEmptyOID(headVATCode) then begin
          pcError:= 'DPH na hlavičce nenastaveno, doklad nelze vytvořit.';
          logs.Add(pcError);
          exit;
        end;

        OS.SQLSelect('SELECT VATRate_ID FROM VATIndexes WHERE ID='+QuotedStr(AnsiUpperCase(headVATCode)),ret);
        if ret.Count=0 then begin
          pcError:= 'DPH sazba k DPH indexu nedohledána, přeskakuji.';
          logs.Add(pcError);
          exit;
        end;
        row.SetFieldValueAsString('VATRate_ID',ret[0]);
        row.SetFieldValueAsString('VATIndex_ID', AnsiUpperCase(headVATCode));
      end;

      if not NxIsEmptyOID(AnsiUpperCase(headBusTransaction)) then begin
        row.SetFieldValueAsString('BusTransaction_ID', AnsiUpperCase(headBusTransaction));
      end;

      if NxIsEmptyOID(AnsiUpperCase(headDivision)) then begin
        pcError:= 'Středisko na hlavičce nenastaveno, doklad nelze vytvořit.';
        logs.Add(pcError);
        exit;
      end;
      row.SetFieldValueAsString('Division_ID', AnsiUpperCase(headDivision));
      {
      if NxIsEmptyOID(headBusOrder) then begin
        logs.Add('Zakázka na hlavičce nenastavena, doklad nelze vytvořit.');
        exit;
      end;
      }

      if NxIsEmptyOID(AnsiUpperCase(headIncomeType)) then begin
        pcError:= 'Typ příjmu na hlavičce nenastaveno, doklad nelze vytvořit.';
        logs.Add(pcError);
        exit;
      end;
      row.SetFieldValueAsString('IncomeType_ID', AnsiUpperCase(headIncomeType));

      if not NxIsEmptyOID(AnsiUpperCase(headBusOrder)) then begin
        row.SetFieldValueAsString('BusOrder_ID', AnsiUpperCase(headBusOrder));
      end;
      if not NxIsEmptyOID(AnsiUpperCase(headBusProject)) then begin
        row.SetFieldValueAsString('BusProject_ID', AnsiUpperCase(headBusProject));
      end;

      row.SetFieldValueAsFloat('TotalPrice', GetFloatDef(annotationsMap.S['total_base']));
      row.SetFieldValueAsString('Text', Copy(annotationsMap.S['description'],1,160));
    end;

    // kurz
    if (annotationsMap.S['exchange_rate']<>'') and (AnsiUpperCase(fp.GetFieldValueasString('Currency_ID.Code'))<>'CZK') then begin
      fp.SetFieldValueAsFloat('CurrRate',GetFloatDef(annotationsMap.S['exchange_rate']));
    end;

    {
    // pridej poznamku
    note:=Copy(trim(annotationsMap.S['note']), 1, 160);
    if note<>'' then begin
      if rows.CountOfNotDeleted>0 then begin
        addNote(OS
          , rows.FirstBusinessObject.GetFieldValueAsString('VATIndex_ID')
          , rows.FirstBusinessObject.GetFieldValueAsString('Division_ID')
          , note
          , rows);
      end else begin
        addNote(OS, headVATCode, headDivision, note, rows);
      end;
    end;
    }

    if not pbZkracenyLog then logs.Add('Ukládám');
    try
      if not fp.Validate then begin
        pcError:= 'Chyba při validaci faktury: '+GetValidateErrs(fp);
        logs.Add(pcError);
      end
      else begin
        fp.Save;
        FP_ID:=fp.OID;
        lcFP_Name:= fp.DisplayName;
        logs.Add('Vytvořeno: '+lcFP_Name);
      end;

      //logs.Add('Def_Doc_DQ_ID: '+Def_Doc_DQ_ID);
      //logs.Add('Def_Doc_DC_ID: '+Def_Doc_DC_ID);
    except
      pcError:= 'Neočekávaná chyba při ukládání faktury: '+ExceptionMessage;
      logs.Add(pcError);
    end;

    if not NxIsEmptyOID(FP_ID) then begin
      try
        // FILE
        if (not NxIsEmptyOID(Def_Doc_DQ_ID)) AND (not NxIsEmptyOID(Def_Doc_DC_ID))
        then begin
          str:= downloadFile(OS, '03', Document_ID, fp.OID, Firm_ID, Def_Doc_DQ_ID, Def_Doc_DC_ID, AUTH_TOKEN, pcQueue_ID, lcDigitooSourceFileName);
          if str<>'' then logs.Add('Došlo k chybě při stažení PDF dokladu: '+str);
        end
        else begin
          logs.Add('Vyplňte v agendě typ a řadu pro přílohu.');
        end;
      except
        logs.Add('Chyba při stahování PDF: '+ExceptionMessage);
      end;
      if pbImportAllAttachments then begin  //přílohy
        try
          if (not NxIsEmptyOID(Def_Doc_DQ_ID)) AND (not NxIsEmptyOID(Def_Doc_DC_ID))
            then downloadAttachments(OS, '03', Document_ID, fp.OID, Firm_ID, Def_Doc_DQ_ID, Def_Doc_DC_ID, AUTH_TOKEN, logs);
        except
          logs.Add('Chyba při stahování příloh: '+ExceptionMessage);
        end;
      end;
      if pbImportDates then begin  //časová razítka
        try
          GetTimeStamps(OS, '03', Document_ID, fp.OID, AUTH_TOKEN, logs, pbZkracenyLog);
        except
          logs.Add('Chyba při stahování časových razítek: '+ExceptionMessage);
        end;
      end;
      if AnsiUpperCase(annotationsMap.S['payment_order'])='YES' then begin
        lfCastkaKUhrade:= 0;
        try
          lfCastkaKUhrade:= GetFloatDef(annotationsMap.S['total_due']);
        except
          lfCastkaKUhrade:= fp.GetFieldValueAsFloat('Amount');
        end;
        if lfCastkaKUhrade>0 then begin
          if not pbZkracenyLog then logs.Add('Generuji žádost platebního příkazu.');
          try
            GenerujZadostPP(fp,'03',lfCastkaKUhrade,logs, pbZkracenyLog);
          except
          end;
        end
        else begin
          logs.Add('Částka k úhradě je nulová, nemá smysl generovat žádost platebního příkazu, jak je požadováno.');
        end;
      end;
    end;
  finally
    Result:= lcFP_Name;
    fp.Free;
    ret.Free;
    sqlRow.Free;
    lmContext.Free
  end;
end;

function CreateReceivedInvoiceType(OS:TNxCustomObjectSpace;
                                   jsonObj:TJSONSuperObject;
                                   logs:TStrings;
                                   Def_Firm_ID, Def_Division_ID,
                                   Def_Doc_DQ_ID, Def_Doc_DC_ID, AUTH_TOKEN, Document_ID, pcDRCDocQueue_ID, pcDRCVATRate_ID, pcQueue_ID: string;
                                   pbImportAllAttachments: boolean;
                                   pbDoNotUpdateFirms, pbImportDates: boolean;
                                   var pcError: string;
                                   pbPairPR: boolean; pcPRDocQueues: string; pnPRDaysBack, pnPRSearchType: integer;
                                   pbOrgIdentNumberCheck: boolean;
                                   pbZkracenyLog: boolean):string;
var
  lcResult: string;
begin
  lcResult:= '';
  Result:= '';
  pcError:= '';
  case AnsiUpperCase(jsonObj.O['annotations'].S['document_type']) of
    'TAX_INVOICE':
        lcResult:= CreateFP(OS, jsonObj, logs, Def_Firm_ID, Def_Division_ID, Def_Doc_DQ_ID,
                          Def_Doc_DC_ID, AUTH_TOKEN, Document_ID, pcDRCDocQueue_ID, pcDRCVATRate_ID, pcQueue_ID,
                          pbImportAllAttachments, pbDoNotUpdateFirms, pbImportDates, pcError, pbPairPR, pcPRDocQueues, pnPRDaysBack, pnPRSearchType, pbOrgIdentNumberCheck, pbZkracenyLog);
    'PROFORMA':
        lcResult:= CreateZLP(OS, jsonObj, logs, Def_Firm_ID, Def_Division_ID, Def_Doc_DQ_ID,
                           Def_Doc_DC_ID, AUTH_TOKEN, Document_ID, pcQueue_ID,
                           pbImportAllAttachments, pbDoNotUpdateFirms, pbImportDates, pcError, pbOrgIdentNumberCheck, pbZkracenyLog);
    'TAX_PAYMENT_INVOICE':
        lcResult:= CreateDZLP(OS, jsonObj, logs, Def_Firm_ID, Def_Division_ID, Def_Doc_DQ_ID,
                          Def_Doc_DC_ID, AUTH_TOKEN, Document_ID, pcQueue_ID,
                          pbImportAllAttachments, pbDoNotUpdateFirms, pbImportDates, pcError, pbOrgIdentNumberCheck, pbZkracenyLog);
    else begin
      lcResult:= '';
      pcError:= 'Nejedná se o podporovaný typ dokladu.';
      logs.Add(pcError);
    end;
  end;
  Result:= lcResult;
end;

function CreateDZLP(OS:TNxCustomObjectSpace;
                    jsonObj:TJSONSuperObject;
                    logs:TStrings;
                    Def_Firm_ID, Def_Division_ID,
                    Def_Doc_DQ_ID, Def_Doc_DC_ID, AUTH_TOKEN, Document_ID, pcQueue_ID: string;
                    pbImportAllAttachments: boolean;
                    pbDoNotUpdateFirms, pbImportDates: boolean;
                    var pcError: string;
                    pbOrgIdentNumberCheck: boolean;
                    pbZkracenyLog: boolean):string;
var
  ret, sqlRow: TStringList;
  fp, row, firm, bankAcc, obj, loAddress: TNxCustomBusinessObject;
  rows, rows2: TNxCustomBusinessMonikerCollection;
  annotationsMap, SRow: TJSONSuperObject;
  i, TradeType: Integer;
  Err, Firm_ID, Division_ID, SQL, FP_ID, headVATCode, lcFP_Name, lcFieldName, lcVATIndex_ID, lcVATRate_ID
  , headDivision, headBusOrder, selectedVAT, FirmBankAccount, FirmBankAccount_ID, lcCurrency_ID, lcICDPH
  , note, DQ_ID, headKontace, headExpenseType, headBusTransaction, strText, str, lcDocumentURL
  , lcICO, lcDIC, lcFirmName, lcCountry_ID, lcCountry_Code, lcElementName, lcAmountFieldName
  , lcCountry, lcSQL, lcIBAN, lcStreet, lcCity, lcPostCode, lcRefDoc, lcRefDocType, headBusProject
  , lcRefDoc_ID, lcSourceDoc_CLSID, lcDigitooSourceFileName, lcSwiftCode: string;
  amount, q, lfDepositAmount: Double;
  FromHeader, lbVATDocument: Boolean;
  lmContext: TNxContext;
  lmImportManager: TNxDocumentImportManager;
  iPars: TNxParameters;
begin
  Result:= '';
  FP_ID:= '';
  lcFP_Name:= '';
  pcError:= '';
  Err:='';

  lmContext:= NxCreateContext(OS);
  ret:=TStringList.Create;
  sqlRow:=TStringList.Create;
  sqlRow.Delimiter:=';';
  iPars:= TNxParameters.Create;
  //fp:=OS.CreateObject(Class_VATReceivedDepositInvoice);
  try

    if AnsiUpperCase(jsonObj.S['status'])<>'READY-TO-EXPORT' then begin
      pcError:= 'Nepodporovaný status dokladu, přeskakuji.';
      logs.Add(pcError);
      exit;
    end;

    annotationsMap:= jsonObj.O['annotations'];

    DQ_ID:= AnsiUpperCase(annotationsMap.S['accounting_sequence']);
    if NxIsEmptyOID(DQ_ID) then begin
      pcError:= 'Řada dokladu nezadána.';
      logs.Add(pcError);
      exit;
    end;

    lcRefDoc:= annotationsMap.S['ref_invoice_id'];
    if lcRefDoc='' then begin
      pcError:= 'Referenční číslo není vyplněno. Je nutné k dohledání zdrojového dokladu (zálohový list přijatý, ostatní výdaj, pokladních výdej) pro vytvoření daňového zálohového listu vydaného.';
      logs.Add(pcError);
      exit;
    end;
    lcSQL:= 'Select A.ID, ''11'''
        +#13' from ReceivedDInvoices A'
        +#13' join DocQueues DQ on DQ.ID=A.DocQueue_ID'
        +#13' join Periods P on P.ID=A.Period_ID'
        +#13' where DQ.Code||''-''||cast(A.OrdNumber as varchar(10))||''/''||P.Code='+QuotedStr(lcRefDoc);
    OS.SQLSelect(lcSQL, ret);
    if ret.count=0 then begin
      lcSQL:= 'Select A.ID, ''11'''
          +#13' from ReceivedDInvoices A'
          +#13' join DocQueues DQ on DQ.ID=A.DocQueue_ID'
          +#13' join Periods P on P.ID=A.Period_ID'
          +#13' where A.VarSymbol='+QuotedStr(lcRefDoc);
      OS.SQLSelect(lcSQL, ret);
    end;
    if ret.count=0 then begin
      lcSQL:= 'Select A.ID, ''06'''
          +#13' from CashPaid A'
          +#13' join DocQueues DQ on DQ.ID=A.DocQueue_ID'
          +#13' join Periods P on P.ID=A.Period_ID'
          +#13' where DQ.Code||''-''||cast(A.OrdNumber as varchar(10))||''/''||P.Code='+QuotedStr(lcRefDoc);
      OS.SQLSelect(lcSQL, ret);
    end;
    if ret.count=0 then begin
      lcSQL:= 'Select A.ID, ''01'''
          +#13' from OtherExpenses A'
          +#13' join DocQueues DQ on DQ.ID=A.DocQueue_ID'
          +#13' join Periods P on P.ID=A.Period_ID'
          +#13' where DQ.Code||''-''||cast(A.OrdNumber as varchar(10))||''/''||P.Code='+QuotedStr(lcRefDoc);
      OS.SQLSelect(lcSQL, ret);
    end;
    if ret.count=0 then begin
      lcSQL:= 'Select A.ID, ''01'''
          +#13' from OtherExpenses A'
          +#13' join DocQueues DQ on DQ.ID=A.DocQueue_ID'
          +#13' join Periods P on P.ID=A.Period_ID'
          +#13' where A.VarSymbol='+QuotedStr(lcRefDoc);
      OS.SQLSelect(lcSQL, ret);
    end;
    if ret.count=0 then begin
      pcError:= 'Doklad dle referenčního čísla "'+lcRefDoc+'" nebyl nalezen v zálohových listech přijatých, ostatních výdajích ani v pokladních výdajích.';
      logs.Add(pcError);
      exit;
    end;

    sqlRow.DelimitedText:= ret[0];
    lcRefDoc_ID:= sqlRow[0];
    lcRefDocType:= sqlRow[1];

    case lcRefDocType of
      '11':begin
            lcSourceDoc_CLSID:= Class_ReceivedDepositInvoice;
            lfDepositAmount:= GetFloatDef(GetData(OS,'ReceivedDInvoices','ID',lcRefDoc_ID,'Amount'));
            if not NxIsEmptyOID(GetData(OS,'ReceivedDepositUsages','DepositDocument_ID',lcRefDoc_ID)) then begin
              pcError:= 'Zálohový list "'+lcRefDoc+'" je již zúčtován, daňový zálohový list nelze vytvořit.';
              logs.Add(pcError);
              exit;
            end;
           end;
      '06': lcSourceDoc_CLSID:= Class_CashPaid;
      '01': lcSourceDoc_CLSID:= Class_OtherExpense;
      else begin
        pcError:= 'Doklad s identifikací "'+lcRefDoc+'" není podporovaného typu.';
        logs.Add(pcError);
        exit;
      end;
    end;
    lmImportManager:= NxCreateDocumentImportManager(OS, lcSourceDoc_CLSID, Class_VATReceivedDepositInvoice);
    lmImportManager.AddInputDocument(lcRefDoc_ID);
    lmImportManager.SelectedHeader:= lmImportManager.InputDocuments[0];
    lmImportManager.SaveParams(iPars);
    iPars.GetOrCreateParam(dtString,'DocQueue_ID').AsString:= DQ_ID;
    if lcRefDocType='11' then iPars.GetOrCreateParam(dtFloat,'DepositAmount').AsFloat:= lfDepositAmount;
    lmImportManager.LoadParams(iPars);
    try
      lmImportManager.Execute;
      fp:= lmImportManager.OutputDocument;
    except
      pcError:= 'Při spuštění import managera ze zdrojového dokladu s identifikací "'+lcRefDoc+'" došlo k neočekávané chybě:'+#13#10+ExceptionMessage;
      logs.Add(pcError);
      exit;
    end;


    lcDocumentURL:= jsonObj.S['document_url'];
    if lcDocumentURL='' then lcDocumentURL:= jsonObj.S['id'];
    lcDigitooSourceFileName:= jsonObj.S['file_name'];

    try
      if pbOrgIdentNumberCheck then begin
        if (Trim(annotationsMap.S['recipient_register_id'])<>'')
            and (lmContext.GetCompanyCache.OrgIdentNumber<>'')
            and (Trim(annotationsMap.S['recipient_register_id'])<>lmContext.GetCompanyCache.OrgIdentNumber) then begin
          pcError:= 'IČO odběratele na dokladu neodpovídá IČO ve firemních údajích v Abře.';
          logs.Add(pcError);
          exit;
        end;
      end;
    except
    end;

    // Udaje z hlavičky, maji prednost na radcich
    headVATCode:=AnsiUpperCase(annotationsMap.S['vat_code']);
    headKontace:=AnsiUpperCase(annotationsMap.S['assignment']);
    headDivision:=AnsiUpperCase(annotationsMap.S['cost_center']);
    headBusOrder:=AnsiUpperCase(annotationsMap.S['contract']);
    headBusProject:=AnsiUpperCase(annotationsMap.S['project']);
    headExpenseType:=AnsiUpperCase(annotationsMap.S['account_code']);
    headBusTransaction:=AnsiUpperCase(annotationsMap.S['activity']); // obchodni pripad na hlavicce
    lcAmountFieldName:= 'TAmountWithoutVAT';

    lbVATDocument:= True;

    // Firma - povinna polozka - dohledava se dle ICO
    lcICO:= NxLeft(Trim(annotationsMap.S['sender_register_id']),15);
    lcDIC:= NxLeft(Trim(annotationsMap.S['sender_tax_id']),20);
    lcICDPH:= NxLeft(Trim(annotationsMap.S['sender_vat_id']),20);
    lcFirmName:= NxLeft(Trim(annotationsMap.S['sender_name']),220);
    Firm_ID:= '';
    try
      Firm_ID:= Trim(annotationsMap.S['sender_internal_id']);
      if NxIsEmptyOID(Firm_ID) then Firm_ID:= '';
    except
    end;
    if NxIsEmptyOID(Firm_ID) then begin
      if not GetFirm_ID(OS, lcICO, lcDIC, lcICDPH, lcFirmName, NxLeft(Trim(annotationsMap.S['sender_address']),255),
                        NxLeft(Trim(annotationsMap.S['sender_street']),60),
                        NxLeft(Trim(annotationsMap.S['sender_city']),60),
                        NxLeft(Trim(annotationsMap.S['sender_post_code']),10),
                        Trim(annotationsMap.S['sender_country']),
                        logs, pbDoNotUpdateFirms, pcError, Firm_ID) then exit;
    end
    else begin
      if not pbZkracenyLog then logs.Add('Nastavuji zaslanou firmu "'+GetData(OS,'Firms','ID',Firm_ID,'Name')+'".');
    end;

    // měna
    if annotationsMap.S['currency']<>'' then begin
      //logs.Add('Hledám měnu.');
      OS.SQLSelect('SELECT ID FROM Currencies WHERE Upper(Code)='+QuotedStr(AnsiUpperCase(annotationsMap.S['currency'])),ret);
      if ret.count>0 then
      begin
        lcCurrency_ID:= ret[0];
        if not pbZkracenyLog then logs.Add('Nastavuji měnu.');
        fp.SetFieldValueAsString('Currency_ID', lcCurrency_ID);
      end else begin
        if not pbZkracenyLog then logs.Add('Měna nedohledána.');
      end;
    end;

    if (NxIsEmptyOID(Firm_ID)) AND (not NxIsEmptyOID(Def_Firm_ID))
    then begin
      Firm_ID:=Def_Firm_ID;
      if not pbZkracenyLog then logs.Add('Nastavuji výchozí firmu.');
    end;

    if NxIsEmptyOID(Firm_ID)
    then begin
      pcError:= 'Firmu se nepodařilo nastavit, přeskakuji.';
      logs.Add(pcError);
      exit;
    end;

    fp.SetFieldValueAsString('DocQueue_ID',DQ_ID);
    // Kontace
    if not NxIsEmptyOID(headKontace) then begin
      fp.SetFieldValueAsString('AccPresetDef_ID',headKontace);
    end;

    //lcElementName:= 'report_code';
    lcElementName:= 'trade_code';
    if (annotationsMap.S[lcElementName]<>'') and (Length(annotationsMap.S[lcElementName])<>10) then begin
      TradeType:=StrToInt(annotationsMap.S[lcElementName]);
      if (TradeType>0) AND (TradeType<7) then begin
        fp.SetFieldValueAsInteger('TradeType', TradeType);
      end;
    end;

    fp.SetFieldValueAsString('Firm_ID', Firm_ID);
    if not NxIsEmptyOID(lcCurrency_ID) then fp.SetFieldValueAsString('Currency_ID', lcCurrency_ID);
    fp.SetFieldValueAsString('ExternalNumber',trim(Copy(annotationsMap.S['invoice_id'],1,30)));
    if fp.GetFieldValueAsString('ExternalNumber')<>'' then begin
      lcSQL:= 'Select A.ID'
          +#13' from VATReceivedDInvoices A'
          +#13' join Firms F on F.ID=A.Firm_ID'
          +#13' where coalesce(F.Firm_ID,F.ID)='+QuotedStr(NxIIfStr(not NxIsEmptyOID(fp.GetFieldValueAsString('Firm_ID.Firm_ID')),fp.GetFieldValueAsString('Firm_ID.Firm_ID'),fp.GetFieldValueAsString('Firm_ID')))
          +#13'       and Upper(A.ExternalNumber)='+QuotedStr(AnsiUpperCase(fp.GetFieldValueAsString('ExternalNumber')));
      OS.SQLSelect(lcSQL, ret);
      if ret.Count>0 then begin
        pcError:= 'Pro firmu "'+fp.GetFieldValueAsString('Firm_ID.Name')+'" již existuje daňový zálohový list přijatý s externím číslem "'+fp.GetFieldValueAsString('ExternalNumber')+'", přeskakuji.';
        logs.Add(pcError);
        exit;
      end;
    end;

    if lbVATDocument then begin
      if fp.GetFieldValueAsInteger('TradeType')=1 then begin
        fp.SetFieldValueAsInteger('DataEntryKind', 0);
      end
      else begin
        lcAmountFieldName:= 'TAmount';
      end;
    end
    else begin
      lcAmountFieldName:= 'TAmount';
    end;

    if fp.GetFieldValueAsInteger('TradeType') in [2,3,4] then begin
      lcCountry_Code:= '';
      try
        lcCountry_Code:= NxIifStr(Length(Trim(annotationsMap.S['sender_country']))=10,GetData(OS, 'Countries', 'ID', Trim(annotationsMap.S['sender_country']), 'Code'), NxLeft(Trim(annotationsMap.S['sender_country']),3));
      except
      end;
      if lcCountry_Code='' then lcCountry_Code:= NxLeft(fp.GetFieldValueAsString('Firm_ID.ResidenceAddress_ID.CountryCode'),2);
      if lcCountry_Code='' then lcCountry_Code:= NxLeft(fp.GetFieldValueAsString('Firm_ID.VATIdentNumber'),2);
      if lcCountry_Code='' then lcCountry_Code:= NxLeft(lcDIC,2);
      lcCountry_Code:= AnsiUpperCase(lcCountry_Code);
      lcCountry_ID:= GetData(OS, 'Countries', 'Code', lcCountry_Code, 'ID', True, 'Hidden=''N''');
      if not NxIsEmptyOID(lcCountry_ID) then begin
        fp.SetFieldValueAsString('Country_ID', lcCountry_ID);
        if not NxIsEmptyOID(lcCurrency_ID) then fp.SetFieldValueAsString('Currency_ID', lcCurrency_ID);
      end;
    end;

    if lmContext.GetCompanyCache.OrgIdentNumber='26230224' then begin  //Magsy to chce jinak (dle Data uplatnění odpočtu)
      if annotationsMap.S['received_date']<>'' then begin
        fp.SetFieldValueAsDateTime('DocDate$DATE', annotationsMap.DT8601['received_date']);
        fp.SetFieldValueAsString('Period_ID',GetPeriodOS(OS,annotationsMap.DT8601['received_date']));
        if NxIsEmptyOID(fp.GetFieldValueAsString('Period_ID')) then begin
          pcError:= 'Dle data uplatnění odpočtu nebylo v Abře dohledáno odpovídající období.';
          logs.Add(pcError);
          exit;
        end;
      end
      else begin
        fp.SetFieldValueAsDateTime('DocDate$DATE', Date);
        fp.SetFieldValueAsString('Period_ID',GetPeriodOS(OS,fp.GetFieldValueAsDateTime('DocDate$DATE')));
        {
        pcError:= 'Nebyl zaslán datum uplatnění odpočtu';
        logs.Add(pcError);
        exit;
        }
      end;
    end
    else begin
      if annotationsMap.S['issue_date']<>'' then begin
        fp.SetFieldValueAsDateTime('DocDate$DATE', annotationsMap.DT8601['issue_date']);
        fp.SetFieldValueAsString('Period_ID',GetPeriodOS(OS,annotationsMap.DT8601['issue_date']));
        if NxIsEmptyOID(fp.GetFieldValueAsString('Period_ID')) then begin
          pcError:= 'Dle data vystavení nebylo v Abře dohledáno odpovídající období.';
          logs.Add(pcError);
          exit;
        end;
      end
      else begin
        fp.SetFieldValueAsDateTime('DocDate$DATE', Date);
        fp.SetFieldValueAsString('Period_ID',GetPeriodOS(OS,fp.GetFieldValueAsDateTime('DocDate$DATE')));
        {
        pcError:= 'Nebyl zaslán datum vystavení';
        logs.Add(pcError);
        exit;
        }
      end;
    end;
    if (annotationsMap.S['taxable_supply_date']<>'') and lbVATDocument then begin
      fp.SetFieldValueAsDateTime('VATAdmitDate$DATE', annotationsMap.DT8601['taxable_supply_date']);
    end;
    if annotationsMap.S['accounting_date']<>'' then begin
      fp.SetFieldValueAsDateTime('AccDate$DATE', annotationsMap.DT8601['accounting_date']);
    end;

    fp.SetFieldValueAsString('X_DigiTooInvoice_ID',annotationsMap.S['invoice_id']);
    fp.SetFieldValueAsString('X_DigitooDocumentUrl',lcDocumentURL);
    fp.SetFieldValueAsString('X_Poznamka',annotationsMap.S['note']);
    str:=trim(Copy(annotationsMap.S['description'],1,50));
    if str='' then str:=trim(Copy(annotationsMap.S['note'],1,50));
    fp.SetFieldValueAsString('Description',str);

    if (annotationsMap.S['received_date']<>'') and lbVATDocument then begin
      fp.SetFieldValueAsDateTime('VatDate$DATE', annotationsMap.DT8601['received_date']);
    end;

    if ExistujeUzaverkaDPH(OS, fp.GetFieldValueAsDateTime('VatDate$DATE')) then begin
      pcError:= 'Datum uplatnění odpočtu  '+FormatDateTime('DD.MM.YYYY', fp.GetFieldValueAsDateTime('VatDate$DATE'))+' je již v Abře uzavřeno uzávěrkou DPH.';
      logs.Add(pcError);
      exit;
    end;

    if annotationsMap.S['due_date']<>'' then begin
      fp.SetFieldValueAsDateTime('DueDate$DATE', annotationsMap.DT8601['due_date']);
    end;
    fp.SetFieldValueAsFloat('RoundingAmount', GetFloatDef(annotationsMap.S['total_rounding']));

    // Bankovni ucet
    FirmBankAccount:= '';
    try
      if annotationsMap.A['bank_account'].length>0 then begin
        FirmBankAccount:= StringReplace(AnsiUpperCase(trim(annotationsMap.A['bank_account'].S[0])),' ','',[rfReplaceAll]);
      end;
    except
      if FirmBankAccount='' then FirmBankAccount:= StringReplace(AnsiUpperCase(trim(annotationsMap.S['bank_account'])),' ','',[rfReplaceAll]);
    end;
    lcIBAN:= '';
    try
      if annotationsMap.A['iban'].length>0 then begin
        lcIBAN:= StringReplace(AnsiUpperCase(trim(annotationsMap.A['iban'].S[0])),' ','',[rfReplaceAll]);
      end;
    except
      if lcIBAN='' then lcIBAN:= StringReplace(AnsiUpperCase(trim(annotationsMap.S['iban'])),' ','',[rfReplaceAll]);
    end;
    lcSwiftCode:= '';
    try
      if annotationsMap.A['bic'].length>0 then begin
        lcSwiftCode:= StringReplace(AnsiUpperCase(trim(annotationsMap.A['bic'].S[0])),' ','',[rfReplaceAll]);
      end;
    except
      if lcSwiftCode='' then lcSwiftCode:= StringReplace(AnsiUpperCase(trim(annotationsMap.S['bic'])),' ','',[rfReplaceAll]);
    end;
    if (FirmBankAccount<>'') or (lcIBAN<>'') then begin
      ret.Clear;
      SQL:='SELECT ID'
       +#13' FROM FirmBankAccounts'
       +#13' WHERE ('+NxIIfStr(FirmBankAccount<>'','Upper(Replace(BankAccount,'' '',''''))='+QuotedStr(FirmBankAccount),'')
       +#13'       '+NxIIfStr(lcIBAN<>'',NxIifStr(FirmBankAccount<>'','or','')+' (Upper(Replace(BankAccount,'' '',''''))='+QuotedStr(lcIBAN),'')
       +#13'       '+NxIIfStr((lcIBAN<>'') and (lcSwiftCode<>''),' and Upper(Replace(SwiftCode,'' '',''''))='+QuotedStr(lcSwiftCode)+')',NxIIfStr(lcIBAN<>'',')',''))+')'
       +#13'       and Parent_ID='+QuotedStr(Firm_ID);
      OS.SQLSelect(SQL, ret);
      if ret.Count>0 then begin
        FirmBankAccount_ID:= ret[0];
        if not NxIsEmptyOID(FirmBankAccount_ID) then
        begin
          fp.SetFieldValueAsString('FirmBankAccount_ID', FirmBankAccount_ID);
          if not pbZkracenyLog then logs.Add('Nastavuji bankovní účet.');
        end;
      end
      else begin
        if pbDoNotUpdateFirms then begin
          pcError:= 'Bankovní účet nelze založit, není povoleno přidávat nové bankovní účty k firmám v Abře.';
          logs.Add(pcError);
          exit;
        end
        else begin
          // v pripade, ze neni vybrana vychozi firma
          if Firm_ID<>Def_Firm_ID then begin
            firm:=OS.CreateObject(Class_Firm);
            try
              firm.Load(Firm_ID,nil);
              rows2:=firm.GetLoadedCollectionMonikerForFieldCode(firm.GetFieldCode('Rows'));
              bankAcc:=rows2.AddNewObject;
              bankAcc.Prefill;
              bankAcc.SetFieldValueAsString('BankAccount', NxIifStr((FirmBankAccount='') or ((lcIBAN<>'') and (NxLeft(lcIBAN,2)<>'CZ')),lcIBAN,FirmBankAccount));
              if (lcSwiftCode<>'') and (lcIBAN<>'') and ((FirmBankAccount='') or (NxLeft(lcIBAN,2)<>'CZ')) then bankAcc.SetFieldValueAsString('SwiftCode', lcSwiftCode);
              FirmBankAccount_ID:=bankAcc.OID;
              try
                firm.Save;
                fp.SetFieldValueAsString('FirmBankAccount_ID', FirmBankAccount_ID);
                if not pbZkracenyLog then logs.Add('Nastavuji bankovní účet.');
              except
                if not pbZkracenyLog then logs.Add('Bankovní účet nelze založit: '+ExceptionMessage);
              end;
            finally
              firm.Free;
            end;
          end
          else begin
            // Nemuzu zakladat
            if not pbZkracenyLog then logs.Add('Bankovní účet nelze založit, je vybrána výchozí firma.');
          end;
        end;
      end;
    end;

    // Typ úhrady
    if (trim(annotationsMap.S['payment_type'])<>'') AND (not NxIsEmptyOID(trim(annotationsMap.S['payment_type']))) then begin
      fp.SetFieldValueAsString('PaymentType_ID',AnsiUpperCase(trim(annotationsMap.S['payment_type'])));
    end;

    {
    if not NxIsEmptyOID(Def_Predkontace) then begin
      fp.SetFieldValueAsString('AccPresetDef_ID',Def_Predkontace);
    end;
    }

    rows:=fp.GetLoadedCollectionMonikerForFieldCode(fp.GetFieldCode('Rows'));
    try
      FromHeader:=false;
      try
        FromHeader:= annotationsMap.A['line_items'].length=0;
      except
        FromHeader:=true;
        if not pbZkracenyLog then logs.Add('Řádky se nepodařilo vytvořit, zkouším vytvořit řádek na základě údajů z rekapitulace.');
      end;

      if not(FromHeader) then begin
        for i:=0 to annotationsMap.A['line_items'].length-1 do begin // radky
          SRow:=annotationsMap.A['line_items'].N[i];
          row:=rows.AddNewObject;
          row.Prefill;

          if lbVATDocument and (fp.GetFieldValueasInteger('TradeType')<>4) then begin
            // DPH
            if not NxIsEmptyOID(SRow.S['vat_code'])
            then begin
              OS.SQLSelect('SELECT VATRate_ID FROM VATIndexes WHERE ID='+QuotedStr(AnsiUpperCase(SRow.S['vat_code'])),ret);
              if ret.Count=0 then begin
                if not pbZkracenyLog then logs.Add('DPH sazba k DPH indexu nedohledána, přeskakuji.');
                row.MarkForDelete;
                continue;
              end;
              row.SetFieldValueAsString('VATRate_ID',ret[0]);
              row.SetFieldValueAsString('VATIndex_ID', AnsiUpperCase(SRow.S['vat_code']));
            end
            else begin
              case fp.GetFieldValueasInteger('TradeType') of
                2: lcFieldName:= 'OutcomeForeignEUDefVATIndex_ID';
                3: lcFieldName:= 'OutcomeForeignDefVATIndex_ID';
              else lcFieldName:= 'OutcomeDomesticDefVATIndex_ID';
              end;
              if SRow.S['tax_rate']<>'' then begin
                OS.SQLSelect('SELECT VR.ID, VR.'+lcFieldName
                +#13' FROM VATRates VR'
                +#13' JOIN COUNTRIES C ON C.ID = VR.Country_ID'
                +#13' WHERE C.ID='+QuotedStr(lmContext.GetCompanyCache.CountryID)
                +#13'       AND VR.Hidden=''N'''
                +#13'       AND VR.Tariff='+GetSQLFloat(GetFloatDef(SRow.S['tax_rate'])),ret);
                if ret.Count=0 then begin
                  if not pbZkracenyLog then logs.Add('DPH nenačteno, přeskakuji řádek.');
                  row.MarkForDelete;
                  continue;
                end;
                sqlrow.DelimitedText:= ret[0];
                lcVATRate_ID:= sqlrow[0];
                lcVATIndex_ID:= sqlrow[1];
                if not NxIsEmptyOID(headVATCode) then begin
                  if CheckIndexForVATRate(OS, headVATCode, lcVATRate_ID, fp.GetFieldValueAsInteger('TradeType'),True)
                    then lcVATIndex_ID:= headVATCode;
                end;
                if NxIsEmptyOID(lcVATIndex_ID) then begin
                  if not pbZkracenyLog then logs.Add('DPH index k DPH sazbě nedohledán, přeskakuji řádek.');
                  row.MarkForDelete;
                  continue;
                end;
                row.SetFieldValueAsString('VATRate_ID',lcVATRate_ID);
                row.SetFieldValueAsString('VATIndex_ID',lcVATIndex_ID);
              end
              else begin
                if not NxIsEmptyOID(headVATCode) then begin
                  OS.SQLSelect('SELECT VATRate_ID FROM VATIndexes WHERE ID='+QuotedStr(AnsiUpperCase(headVATCode)),ret);
                  if ret.Count=0 then begin
                    if not pbZkracenyLog then logs.Add('DPH sazba k DPH indexu nedohledána, přeskakuji.');
                    row.MarkForDelete;
                    continue;
                  end;
                  row.SetFieldValueAsString('VATRate_ID',ret[0]);
                  row.SetFieldValueAsString('VATIndex_ID', AnsiUpperCase(headVATCode));
                end
                else begin
                  // DPH neni zadano, preskakuji
                  if not pbZkracenyLog then logs.Add('DPH nenačteno, přeskakuji řádek.');
                  row.MarkForDelete;
                  continue;
                end;
              end;
            end;
          end;

          if not NxIsEmptyOID(AnsiUpperCase(SRow.S['activity'])) then begin
            row.SetFieldValueAsString('BusTransaction_ID', AnsiUpperCase(SRow.S['activity']));
          end
          else begin
             if not NxIsEmptyOID(AnsiUpperCase(headBusTransaction))
            then begin
              row.SetFieldValueAsString('BusTransaction_ID',AnsiUpperCase(headBusTransaction));
            end
            else begin
              if not pbZkracenyLog then logs.Add('Obchodní případ nenačten.');
            end;
          end;

          // Division_ID
          if not NxIsEmptyOID(AnsiUpperCase(SRow.S['cost_center']))
          then begin
            row.SetFieldValueAsString('Division_ID', AnsiUpperCase(SRow.S['cost_center']));
          end
          else begin
            if not NxIsEmptyOID(AnsiUpperCase(headDivision))
            then begin
              row.SetFieldValueAsString('Division_ID',AnsiUpperCase(headDivision));
            end
            else begin
              if not NxIsEmptyOID(AnsiUpperCase(Def_Division_ID)) then begin
                if not pbZkracenyLog then logs.Add('Nastavuji výchozí středisko.');
                row.SetFieldValueAsString('Division_ID', AnsiUpperCase(Def_Division_ID));
              end
              else begin
                if not pbZkracenyLog then logs.Add('Středisko nenastaveno, přeskakuji řádek.');
                row.MarkForDelete;
                continue;
              end;
            end;
          end;

          // BusOrder
          if not NxIsEmptyOID(AnsiUpperCase(SRow.S['contract']))
          then begin
            row.SetFieldValueAsString('BusOrder_ID', AnsiUpperCase(SRow.S['contract']));
          end
          else begin
            if not NxIsEmptyOID(AnsiUpperCase(headBusOrder))
            then begin
              row.SetFieldValueAsString('BusOrder_ID',AnsiUpperCase(headBusOrder));
            end
            else begin
              if not pbZkracenyLog then logs.Add('Zakázka nenastavena.');
            end;
          end;

          // BusProject
          if not NxIsEmptyOID(AnsiUpperCase(SRow.S['project']))
          then begin
            row.SetFieldValueAsString('BusProject_ID', AnsiUpperCase(SRow.S['project']));
          end
          else begin
            if not NxIsEmptyOID(AnsiUpperCase(headBusProject))
            then begin
              row.SetFieldValueAsString('BusProject_ID',AnsiUpperCase(headBusProject));
            end
            else begin
              if not pbZkracenyLog then logs.Add('Projekt nenastaven.');
            end;
          end;

          // Text na radku
          strText:='';
          if SRow.S['item_code']<>'' then begin
            strText:=SRow.S['item_code'];
          end;
          if SRow.S['item_description']<>'' then begin
            if strText<>'' then begin
              strText:=strText+': ';
            end;
            strText:=strText+SRow.S['item_description'];
          end;
          if strText='' then begin
            strText:=SRow.S['description'];
          end;
          row.SetFieldValueAsString('Text', Copy(strText,1,160));

          // Castka
          if GetFloatDef(SRow.S['total_base']) <> 0 then begin
            amount:= GetFloatDef(SRow.S['total_base']);
          end else begin
            q:= GetFloatDef(SRow.S['quantity']);
            if q=0 then begin
              q:=1;
            end;
            amount:=q*GetFloatDef(SRow.S['unit_base']);
          end;

          if Abs(amount)<0.000001 then begin
            if not pbZkracenyLog then logs.Add('Nulová částka na řádku, přeskakuji.');
            row.MarkForDelete;
            continue;
          end;
          row.SetFieldValueAsFloat(lcAmountFieldName, amount);
        end;
        if rows.CountOfNotDeleted=0 then begin
          if not pbZkracenyLog then logs.Add('Řádky se nepodařilo vytvořit, zkouším vytvořit řádek na základě údajů z hlavičky.');
          FromHeader:=true;
        end;
      end;
    except
      if not pbZkracenyLog then logs.Add('Řádky se nepodařilo vytvořit, zkouším vytvořit řádek na základě údajů z hlavičky.');
      row.MarkForDelete;
      FromHeader:=true;
    end;

    if FromHeader then begin
      // tax_detail - vytvor radky z rekapitulace
      if lbVATDocument and (fp.GetFieldValueasInteger('TradeType')<>4) then begin
        FromHeader:= False;
        try
          try
            FromHeader:= annotationsMap.A['tax_detail'].length=0;
          except
            FromHeader:=true;
            if not pbZkracenyLog then logs.Add('Rekapitulace nezadána.');
          end;

          if not(FromHeader) then begin
            annotationsMap.A['tax_detail'].length;
            if not pbZkracenyLog then logs.Add('Tvořím řádky z rekapitulace');
            for i:=0 to annotationsMap.A['tax_detail'].length-1 do begin // radky
              SRow:=annotationsMap.A['tax_detail'].N[i];
              if (SRow.S['rate']='')
                  OR ((SRow.S['base']='') AND (SRow.S['tax']=''))
              then begin
                if not pbZkracenyLog then logs.Add('Neúplné údaje na řádku rekapitulace, přeskakuji.');
                continue;
              end;
              if not pbZkracenyLog then logs.Add('Vytvářím řádek z rekapitulace.');

              row:=rows.AddNewObject;
              row.Prefill;

              if NxIsEmptyOID(AnsiUpperCase(headDivision)) then begin
                pcError:= 'Středisko na hlavičce nenastaveno, doklad nelze vytvořit.';
                logs.Add(pcError);
                exit;
              end;
              row.SetFieldValueAsString('Division_ID', AnsiUpperCase(headDivision));

              if NxIsEmptyOID(AnsiUpperCase(headExpenseType)) then begin
                pcError:= 'Typ výdaje na hlavičce nenastaveno, doklad nelze vytvořit.';
                logs.Add(pcError);
                exit;
              end;

              if not NxIsEmptyOID(AnsiUpperCase(headBusTransaction)) then begin
                row.SetFieldValueAsString('BusTransaction_ID', AnsiUpperCase(headBusTransaction));
              end;
              if not NxIsEmptyOID(AnsiUpperCase(headBusOrder)) then begin
                row.SetFieldValueAsString('BusOrder_ID', AnsiUpperCase(headBusOrder));
              end;
              if not NxIsEmptyOID(AnsiUpperCase(headBusProject)) then begin
                row.SetFieldValueAsString('BusProject_ID', AnsiUpperCase(headBusProject));
              end;

              case fp.GetFieldValueasInteger('TradeType') of
                2: lcFieldName:= 'OutcomeForeignEUDefVATIndex_ID';
                3: lcFieldName:= 'OutcomeForeignDefVATIndex_ID';
              else lcFieldName:= 'OutcomeDomesticDefVATIndex_ID';
              end;

              OS.SQLSelect('SELECT VR.ID, VR.'+lcFieldName
              +#13' FROM VATRates VR'
              +#13' JOIN COUNTRIES C ON C.ID = VR.Country_ID'
              +#13' WHERE C.ID='+QuotedStr(lmContext.GetCompanyCache.CountryID)
              +#13'       AND VR.Hidden=''N'''
              +#13'       AND VR.Tariff='+GetSQLFloat(GetFloatDef(SRow.S['rate'])),ret);
              if ret.Count=0 then begin
                if not pbZkracenyLog then logs.Add('DPH nenačteno, přeskakuji řádek.');
                row.MarkForDelete;
                continue;
              end;
              sqlrow.DelimitedText:= ret[0];
              lcVATRate_ID:= sqlrow[0];
              lcVATIndex_ID:= sqlrow[1];
              if not NxIsEmptyOID(headVATCode) then begin
                if CheckIndexForVATRate(OS, headVATCode, lcVATRate_ID, fp.GetFieldValueAsInteger('TradeType'),True)
                  then lcVATIndex_ID:= headVATCode;
              end;
              if NxIsEmptyOID(lcVATIndex_ID) then begin
                if not pbZkracenyLog then logs.Add('DPH index k DPH sazbě nedohledán, přeskakuji řádek.');
                row.MarkForDelete;
                continue;
              end;

              if ((SRow.S['rate']<>'')
                  AND
                  (SRow.S['base']<>''))
              then begin
                row.SetFieldValueAsString('VATRate_ID', lcVATRate_ID);
                row.SetFieldValueAsString('VATIndex_ID',lcVATIndex_ID);
                row.SetFieldValueAsFloat(lcAmountFieldName, GetFloatDef(SRow.S['base']));
              end
              else begin
                if  ((SRow.S['rate']<>'')
                    AND
                    (GetFloatDef(SRow.S['rate'])<>0)
                    AND
                    (SRow.S['tax']<>''))
                then begin
                  row.SetFieldValueAsString('VATRate_ID', lcVATRate_ID);
                  row.SetFieldValueAsString('VATIndex_ID',lcVATIndex_ID);
                  row.SetFieldValueAsFloat(lcAmountFieldName, GetFloatDef(SRow.S['tax'])/(GetFloatDef(SRow.S['rate'])/100));
                end;
              end;
              row.SetFieldValueAsString('Text', Copy(annotationsMap.S['description'],1,160));
            end;

            if rows.CountOfNotDeleted=0 then begin
              pcError:= 'Řádky se nepodařilo založil z rekapitulace, přeskakuji.';
              logs.Add(pcError);
              exit;
            end;
          end;
        except
          pcError:= 'Rekapitulace nezadána. '+ExceptionMessage;
          logs.Add(pcError);
          exit;
        end;
      end;
    end;

    if FromHeader then begin
      // Vytvarim novy radek z hlavicky
      row:=rows.AddNewObject;
      row.Prefill;

      if lbVATDocument and (fp.GetFieldValueasInteger('TradeType')<>4) then begin
        if NxIsEmptyOID(headVATCode) then begin
          pcError:= 'DPH na hlavičce nenastaveno, doklad nelze vytvořit.';
          logs.Add(pcError);
          exit;
        end;

        OS.SQLSelect('SELECT VATRate_ID FROM VATIndexes WHERE ID='+QuotedStr(AnsiUpperCase(headVATCode)),ret);
        if ret.Count=0 then begin
          pcError:= 'DPH sazba k DPH indexu nedohledána, přeskakuji.';
          logs.Add(pcError);
          exit;
        end;
        row.SetFieldValueAsString('VATRate_ID',ret[0]);
        row.SetFieldValueAsString('VATIndex_ID', AnsiUpperCase(headVATCode));
      end;

      if not NxIsEmptyOID(AnsiUpperCase(headBusTransaction)) then begin
        row.SetFieldValueAsString('BusTransaction_ID', AnsiUpperCase(headBusTransaction));
      end;

      if NxIsEmptyOID(AnsiUpperCase(headDivision)) then begin
        pcError:= 'Středisko na hlavičce nenastaveno, doklad nelze vytvořit.';
        logs.Add(pcError);
        exit;
      end;
      row.SetFieldValueAsString('Division_ID', AnsiUpperCase(headDivision));
      {
      if NxIsEmptyOID(headBusOrder) then begin
        logs.Add('Zakázka na hlavičce nenastavena, doklad nelze vytvořit.');
        exit;
      end;
      }
      if not NxIsEmptyOID(AnsiUpperCase(headBusOrder)) then begin
        row.SetFieldValueAsString('BusOrder_ID', AnsiUpperCase(headBusOrder));
      end;
      if not NxIsEmptyOID(AnsiUpperCase(headBusProject)) then begin
        row.SetFieldValueAsString('BusProject_ID', AnsiUpperCase(headBusProject));
      end;

      row.SetFieldValueAsFloat(lcAmountFieldName, GetFloatDef(annotationsMap.S['total_base']));
      row.SetFieldValueAsString('Text', Copy(annotationsMap.S['description'],1,160));
    end;

    // kurz
    if (annotationsMap.S['exchange_rate']<>'') and (AnsiUpperCase(fp.GetFieldValueasString('Currency_ID.Code'))<>'CZK') then begin
      fp.SetFieldValueAsFloat('CurrRate',GetFloatDef(annotationsMap.S['exchange_rate']));
    end;

    if not pbZkracenyLog then logs.Add('Ukládám');
    try
      if not fp.Validate then begin
        pcError:= 'Chyba při validaci daňového zálohového listu přijatého: '+GetValidateErrs(fp);
        logs.Add(pcError);
      end
      else begin
        fp.Save;
        FP_ID:=fp.OID;
        lcFP_Name:= fp.DisplayName;
        logs.Add('Vytvořeno: '+lcFP_Name);
      end;

      //logs.Add('Def_Doc_DQ_ID: '+Def_Doc_DQ_ID);
      //logs.Add('Def_Doc_DC_ID: '+Def_Doc_DC_ID);
    except
      pcError:= 'Neočekávaná chyba při ukládání daňového zálohového listu přijatého: '+ExceptionMessage;
      logs.Add(pcError);
    end;

    if not NxIsEmptyOID(FP_ID) then begin
      try
        // FILE
        if (not NxIsEmptyOID(Def_Doc_DQ_ID)) AND (not NxIsEmptyOID(Def_Doc_DC_ID))
        then begin
          str:= downloadFile(OS, '64',Document_ID, fp.OID, Firm_ID, Def_Doc_DQ_ID, Def_Doc_DC_ID, AUTH_TOKEN, pcQueue_ID, lcDigitooSourceFileName);
          if str<>'' then logs.Add('Došlo k chybě při stažení PDF dokladu: '+str);
        end
        else begin
          logs.Add('Vyplňte v agendě typ a řadu pro přílohu.');
        end;
      except
        logs.Add('Chyba při stahování PDF: '+ExceptionMessage);
      end;
      if pbImportAllAttachments then begin  //přílohy
        try
          if (not NxIsEmptyOID(Def_Doc_DQ_ID)) AND (not NxIsEmptyOID(Def_Doc_DC_ID))
            then downloadAttachments(OS, '64', Document_ID, fp.OID, Firm_ID, Def_Doc_DQ_ID, Def_Doc_DC_ID, AUTH_TOKEN, logs);
        except
          logs.Add('Chyba při stahování příloh: '+ExceptionMessage);
        end;
      end;
      if pbImportDates then begin  //časová razítka
        try
          GetTimeStamps(OS, '64', Document_ID, fp.OID, AUTH_TOKEN, logs, pbZkracenyLog);
        except
          logs.Add('Chyba při stahování časových razítek: '+ExceptionMessage);
        end;
      end;
    end;
  finally
    Result:= lcFP_Name;
    fp.Free;
    ret.Free;
    sqlRow.Free;
    lmContext.Free;
    iPars.Free;
    if Assigned(lmImportManager) then lmImportManager.Free;
  end;
end;

function CreateZLP(OS:TNxCustomObjectSpace;
                   jsonObj:TJSONSuperObject;
                   logs:TStrings;
                   Def_Firm_ID, Def_Division_ID,
                   Def_Doc_DQ_ID, Def_Doc_DC_ID, AUTH_TOKEN, Document_ID, pcQueue_ID: string;
                   pbImportAllAttachments: boolean;
                   pbDoNotUpdateFirms, pbImportDates: boolean;
                   var pcError: string;
                   pbOrgIdentNumberCheck: boolean;
                   pbZkracenyLog: boolean):string;
var
  ret, sqlRow: TStringList;
  fp, row, firm, bankAcc, obj, loAddress: TNxCustomBusinessObject;
  rows, rows2: TNxCustomBusinessMonikerCollection;
  annotationsMap, SRow: TJSONSuperObject;
  i, TradeType: Integer;
  Err, Firm_ID, Division_ID, SQL, FP_ID, headVATCode, lcFP_Name, headBusProject, lcICDPH
  , headDivision, headBusOrder, selectedVAT, FirmBankAccount, FirmBankAccount_ID, lcCurrency_ID
  , note, DQ_ID, headKontace, headExpenseType, headBusTransaction, strText, str, lcDocumentURL
  , lcICO, lcDIC, lcFirmName, lcCountry_ID, lcCountry_Code, lcElementName, lcAmountFieldName
  , lcCountry, lcSQL, lcStreet, lcCity, lcPostCode, lcDigitooSourceFileName, lcIBAN, lcSwiftCode: string;
  amount, q, lfCastkaKUhrade: Double;
  FromHeader: Boolean;
  lmContext: TNxContext;
begin
  Result:= '';
  FP_ID:= '';
  lcFP_Name:= '';
  pcError:= '';
  Err:='';

  lmContext:= NxCreateContext(OS);
  ret:=TStringList.Create;
  sqlRow:=TStringList.Create;
  fp:=OS.CreateObject(Class_ReceivedDepositInvoice);
  try
    sqlRow.Delimiter:=';';

    if AnsiUpperCase(jsonObj.S['status'])<>'READY-TO-EXPORT' then begin
      pcError:= 'Nepodporovaný status dokladu, přeskakuji.';
      logs.Add(pcError);
      exit;
    end;

    annotationsMap:= jsonObj.O['annotations'];

    {
    if AnsiUpperCase(annotationsMap.S['document_type'])<>'PROFORMA' then begin
      pcError:= 'Nejedná se o typ dokladu zálohový list přijatý.';
      logs.Add(pcError);
      exit;
    end;
    }

    lcDocumentURL:= jsonObj.S['document_url'];
    if lcDocumentURL='' then lcDocumentURL:= jsonObj.S['id'];
    lcDigitooSourceFileName:= jsonObj.S['file_name'];

    DQ_ID:= AnsiUpperCase(annotationsMap.S['accounting_sequence']);
    if NxIsEmptyOID(DQ_ID) then begin
      pcError:= 'Řada dokladu nezadána.';
      logs.Add(pcError);
      exit;
    end;

    try
      if pbOrgIdentNumberCheck then begin
        if (Trim(annotationsMap.S['recipient_register_id'])<>'')
            and (lmContext.GetCompanyCache.OrgIdentNumber<>'')
            and (Trim(annotationsMap.S['recipient_register_id'])<>lmContext.GetCompanyCache.OrgIdentNumber) then begin
          pcError:= 'IČO odběratele na dokladu neodpovídá IČO ve firemních údajích v Abře.';
          logs.Add(pcError);
          exit;
        end;
      end;
    except
    end;

    // Udaje z hlavičky, maji prednost na radcich
    headVATCode:=AnsiUpperCase(annotationsMap.S['vat_code']);
    headKontace:=AnsiUpperCase(annotationsMap.S['assignment']);
    headDivision:=AnsiUpperCase(annotationsMap.S['cost_center']);
    headBusOrder:=AnsiUpperCase(annotationsMap.S['contract']);
    headBusProject:=AnsiUpperCase(annotationsMap.S['project']);
    headExpenseType:=AnsiUpperCase(annotationsMap.S['account_code']);
    headBusTransaction:=AnsiUpperCase(annotationsMap.S['activity']); // obchodni pripad na hlavicce
    lcAmountFieldName:= 'TAmount';

    fp.New;
    fp.Prefill;

    // Firma - povinna polozka - dohledava se dle ICO
    lcICO:= NxLeft(Trim(annotationsMap.S['sender_register_id']),15);
    lcDIC:= NxLeft(Trim(annotationsMap.S['sender_tax_id']),20);
    lcICDPH:= NxLeft(Trim(annotationsMap.S['sender_vat_id']),20);
    lcFirmName:= NxLeft(Trim(annotationsMap.S['sender_name']),220);
    Firm_ID:= '';
    try
      Firm_ID:= Trim(annotationsMap.S['sender_internal_id']);
      if NxIsEmptyOID(Firm_ID) then Firm_ID:= '';
    except
    end;
    if NxIsEmptyOID(Firm_ID) then begin
      if not GetFirm_ID(OS, lcICO, lcDIC, lcICDPH, lcFirmName, NxLeft(Trim(annotationsMap.S['sender_address']),255),
                        NxLeft(Trim(annotationsMap.S['sender_street']),60),
                        NxLeft(Trim(annotationsMap.S['sender_city']),60),
                        NxLeft(Trim(annotationsMap.S['sender_post_code']),10),
                        Trim(annotationsMap.S['sender_country']),
                        logs, pbDoNotUpdateFirms, pcError, Firm_ID) then exit;
    end
    else begin
      if not pbZkracenyLog then logs.Add('Nastavuji zaslanou firmu "'+GetData(OS,'Firms','ID',Firm_ID,'Name')+'".');
    end;

    // měna
    if annotationsMap.S['currency']<>'' then begin
      //logs.Add('Hledám měnu.');
      OS.SQLSelect('SELECT ID FROM Currencies WHERE Upper(Code)='+QuotedStr(AnsiUpperCase(annotationsMap.S['currency'])),ret);
      if ret.count>0 then
      begin
        lcCurrency_ID:= ret[0];
        if not pbZkracenyLog then logs.Add('Nastavuji měnu.');
        fp.SetFieldValueAsString('Currency_ID', lcCurrency_ID);
      end else begin
        if not pbZkracenyLog then logs.Add('Měna nedohledána.');
      end;
    end;

    {
    // Kontace
    if not NxIsEmptyOID(headKontace) then begin
      fp.SetFieldValueAsString('AccPresetDef_ID',headKontace);
    end;
    }

    if (NxIsEmptyOID(Firm_ID)) AND (not NxIsEmptyOID(Def_Firm_ID))
    then begin
      Firm_ID:=Def_Firm_ID;
      if not pbZkracenyLog then logs.Add('Nastavuji výchozí firmu.');
    end;

    if NxIsEmptyOID(Firm_ID)
    then begin
      pcError:= 'Firmu se nepodařilo nastavit, přeskakuji.';
      logs.Add(pcError);
      exit;
    end;

    fp.SetFieldValueAsString('DocQueue_ID',DQ_ID);

    {
    //lcElementName:= 'report_code';
    lcElementName:= 'trade_code';
    if (annotationsMap.S[lcElementName]<>'') and (Length(annotationsMap.S[lcElementName])<>10) then begin
      TradeType:=StrToInt(annotationsMap.S[lcElementName]);
      if (TradeType>0) AND (TradeType<7) then begin
      fp.SetFieldValueAsInteger('TradeType', TradeType);
      end;
    end;
    }

    fp.SetFieldValueAsString('Firm_ID', Firm_ID);
    if not NxIsEmptyOID(lcCurrency_ID) then fp.SetFieldValueAsString('Currency_ID', lcCurrency_ID);
    fp.SetFieldValueAsString('ExternalNumber',trim(Copy(annotationsMap.S['invoice_id'],1,30)));
    if fp.GetFieldValueAsString('ExternalNumber')<>'' then begin
      lcSQL:= 'Select RDI.ID'
          +#13' from ReceivedDInvoices RDI'
          +#13' join Firms F on F.ID=RDI.Firm_ID'
          +#13' where coalesce(F.Firm_ID,F.ID)='+QuotedStr(NxIIfStr(not NxIsEmptyOID(fp.GetFieldValueAsString('Firm_ID.Firm_ID')),fp.GetFieldValueAsString('Firm_ID.Firm_ID'),fp.GetFieldValueAsString('Firm_ID')))
          +#13'       and Upper(RDI.ExternalNumber)='+QuotedStr(AnsiUpperCase(fp.GetFieldValueAsString('ExternalNumber')));
      OS.SQLSelect(lcSQL, ret);
      if ret.Count>0 then begin
        pcError:= 'Pro firmu "'+fp.GetFieldValueAsString('Firm_ID.Name')+'" již existuje zálohový list přijatý s externím číslem "'+fp.GetFieldValueAsString('ExternalNumber')+'", přeskakuji.';
        logs.Add(pcError);
        exit;
      end;
    end;

    {
    if fp.GetFieldValueAsInteger('TradeType')=1 then begin
      fp.SetFieldValueAsInteger('DataEntryKind', 0);
    end
    else begin
      lcAmountFieldName:= 'TAmount';
    end;
    }

    if annotationsMap.S['trade_code']='2' then begin
      lcCountry_Code:= '';
      try
        lcCountry_Code:= NxIifStr(Length(Trim(annotationsMap.S['sender_country']))=10,GetData(OS, 'Countries', 'ID', Trim(annotationsMap.S['sender_country']), 'Code'), NxLeft(Trim(annotationsMap.S['sender_country']),3));
      except
      end;
      if lcCountry_Code='' then lcCountry_Code:= NxLeft(fp.GetFieldValueAsString('Firm_ID.ResidenceAddress_ID.CountryCode'),2);
      if lcCountry_Code='' then lcCountry_Code:= NxLeft(fp.GetFieldValueAsString('Firm_ID.VATIdentNumber'),2);
      if lcCountry_Code='' then lcCountry_Code:= NxLeft(lcDIC,2);
      lcCountry_Code:= AnsiUpperCase(lcCountry_Code);
      lcCountry_ID:= GetData(OS, 'Countries', 'Code', lcCountry_Code, 'ID', True, 'Hidden=''N''');
      if not NxIsEmptyOID(lcCountry_ID) then begin
        fp.SetFieldValueAsString('Country_ID', lcCountry_ID);
        if not NxIsEmptyOID(lcCurrency_ID) then fp.SetFieldValueAsString('Currency_ID', lcCurrency_ID);
      end;
      //fp.SetFieldValueAsBoolean('IsReverseChargeDeclared', True);
    end;

    if annotationsMap.S['issue_date']<>'' then begin
      fp.SetFieldValueAsDateTime('DocDate$DATE', annotationsMap.DT8601['issue_date']);
      fp.SetFieldValueAsString('Period_ID',GetPeriodOS(OS,annotationsMap.DT8601['issue_date']));
      if NxIsEmptyOID(fp.GetFieldValueAsString('Period_ID')) then begin
        pcError:= 'Dle data vystavení nebylo v Abře dohledáno odpovídající období.';
        logs.Add(pcError);
        exit;
      end;
    end
    else begin
      fp.SetFieldValueAsDateTime('DocDate$DATE', Date);
      fp.SetFieldValueAsString('Period_ID',GetPeriodOS(OS,fp.GetFieldValueAsDateTime('DocDate$DATE')));
      {
      pcError:= 'Nebyl zaslán datum vystavení';
      logs.Add(pcError);
      exit;
      }
    end;
    {
    if annotationsMap.S['taxable_supply_date']<>'' then begin
      fp.SetFieldValueAsDateTime('VATAdmitDate$DATE', annotationsMap.DT8601['taxable_supply_date']);
    end;
    if annotationsMap.S['accounting_date']<>'' then begin
      fp.SetFieldValueAsDateTime('AccDate$DATE', annotationsMap.DT8601['accounting_date']);
    end;
    }

    fp.SetFieldValueAsString('X_DigiTooInvoice_ID',annotationsMap.S['invoice_id']);
    fp.SetFieldValueAsString('X_DigitooDocumentUrl',lcDocumentURL);
    fp.SetFieldValueAsString('VarSymbol',annotationsMap.S['var_sym']);
    fp.SetFieldValueAsString('X_Poznamka',annotationsMap.S['note']);
    str:=trim(Copy(annotationsMap.S['description'],1,50));
    if str='' then str:=trim(Copy(annotationsMap.S['note'],1,50));
    fp.SetFieldValueAsString('Description',str);

    {
    if annotationsMap.S['received_date']<>'' then begin
      fp.SetFieldValueAsDateTime('VatDate$DATE', annotationsMap.DT8601['received_date']);
    end;
    }

    if annotationsMap.S['due_date']<>'' then begin
      fp.SetFieldValueAsDateTime('DueDate$DATE', annotationsMap.DT8601['due_date']);
    end;
    //fp.SetFieldValueAsFloat('RoundingAmount', GetFloatDef(annotationsMap.S['total_rounding']));

    // Bankovni ucet
    FirmBankAccount:= '';
    try
      if annotationsMap.A['bank_account'].length>0 then begin
        FirmBankAccount:= StringReplace(AnsiUpperCase(trim(annotationsMap.A['bank_account'].S[0])),' ','',[rfReplaceAll]);
      end;
    except
      if FirmBankAccount='' then FirmBankAccount:= StringReplace(AnsiUpperCase(trim(annotationsMap.S['bank_account'])),' ','',[rfReplaceAll]);
    end;
    lcIBAN:= '';
    try
      if annotationsMap.A['iban'].length>0 then begin
        lcIBAN:= StringReplace(AnsiUpperCase(trim(annotationsMap.A['iban'].S[0])),' ','',[rfReplaceAll]);
      end;
    except
      if lcIBAN='' then lcIBAN:= StringReplace(AnsiUpperCase(trim(annotationsMap.S['iban'])),' ','',[rfReplaceAll]);
    end;
    lcSwiftCode:= '';
    try
      if annotationsMap.A['bic'].length>0 then begin
        lcSwiftCode:= StringReplace(AnsiUpperCase(trim(annotationsMap.A['bic'].S[0])),' ','',[rfReplaceAll]);
      end;
    except
      if lcSwiftCode='' then lcSwiftCode:= StringReplace(AnsiUpperCase(trim(annotationsMap.S['bic'])),' ','',[rfReplaceAll]);
    end;
    if (FirmBankAccount<>'') or (lcIBAN<>'') then begin
      ret.Clear;
      SQL:='SELECT ID'
       +#13' FROM FirmBankAccounts'
       +#13' WHERE ('+NxIIfStr(FirmBankAccount<>'','Upper(Replace(BankAccount,'' '',''''))='+QuotedStr(FirmBankAccount),'')
       +#13'       '+NxIIfStr(lcIBAN<>'',NxIifStr(FirmBankAccount<>'','or','')+' (Upper(Replace(BankAccount,'' '',''''))='+QuotedStr(lcIBAN),'')
       +#13'       '+NxIIfStr((lcIBAN<>'') and (lcSwiftCode<>''),' and Upper(Replace(SwiftCode,'' '',''''))='+QuotedStr(lcSwiftCode)+')',NxIIfStr(lcIBAN<>'',')',''))+')'
       +#13'       and Parent_ID='+QuotedStr(Firm_ID);
      OS.SQLSelect(SQL, ret);
      if ret.Count>0 then begin
        FirmBankAccount_ID:= ret[0];
        if not NxIsEmptyOID(FirmBankAccount_ID) then
        begin
          fp.SetFieldValueAsString('FirmBankAccount_ID', FirmBankAccount_ID);
          if not pbZkracenyLog then logs.Add('Nastavuji bankovní účet.');
        end;
      end
      else begin
        if pbDoNotUpdateFirms then begin
          pcError:= 'Bankovní účet nelze založit, není povoleno přidávat nové bankovní účty k firmám v Abře.';
          logs.Add(pcError);
          exit;
        end
        else begin
          // v pripade, ze neni vybrana vychozi firma
          if Firm_ID<>Def_Firm_ID then begin
            firm:=OS.CreateObject(Class_Firm);
            try
              firm.Load(Firm_ID,nil);
              rows2:=firm.GetLoadedCollectionMonikerForFieldCode(firm.GetFieldCode('Rows'));
              bankAcc:=rows2.AddNewObject;
              bankAcc.Prefill;
              bankAcc.SetFieldValueAsString('BankAccount',NxIifStr((FirmBankAccount='') or ((lcIBAN<>'') and (NxLeft(lcIBAN,2)<>'CZ')),lcIBAN,FirmBankAccount));
              if (lcSwiftCode<>'') and (lcIBAN<>'') and ((FirmBankAccount='') or (NxLeft(lcIBAN,2)<>'CZ')) then bankAcc.SetFieldValueAsString('SwiftCode', lcSwiftCode);
              FirmBankAccount_ID:=bankAcc.OID;
              try
                firm.Save;
                fp.SetFieldValueAsString('FirmBankAccount_ID', FirmBankAccount_ID);
                if not pbZkracenyLog then logs.Add('Nastavuji bankovní účet.');
              except
                if not pbZkracenyLog then logs.Add('Bankovní účet nelze založit: '+ExceptionMessage);
              end;
            finally
              firm.Free;
            end;
          end
          else begin
            // Nemuzu zakladat
            if not pbZkracenyLog then logs.Add('Bankovní účet nelze založit, je vybrána výchozí firma.');
          end;
        end;
      end;
    end;

    {
    // Typ úhrady
    if (trim(annotationsMap.S['payment_type'])<>'') AND (not NxIsEmptyOID(trim(annotationsMap.S['payment_type']))) then begin
      fp.SetFieldValueAsString('PaymentType_ID',AnsiUpperCase(trim(annotationsMap.S['payment_type'])));
    end;
    }

    {
    if not NxIsEmptyOID(Def_Predkontace) then begin
      fp.SetFieldValueAsString('AccPresetDef_ID',Def_Predkontace);
    end;
    }

    rows:=fp.GetLoadedCollectionMonikerForFieldCode(fp.GetFieldCode('Rows'));
    try
      FromHeader:=false;
      try
        FromHeader:= annotationsMap.A['line_items'].length=0;
      except
        FromHeader:=true;
        if not pbZkracenyLog then logs.Add('Řádky se nepodařilo vytvořit, zkouším vytvořit řádek na základě údajů z hlavičky.');
      end;

      if not(FromHeader) then begin
        for i:=0 to annotationsMap.A['line_items'].length-1 do begin // radky
          SRow:=annotationsMap.A['line_items'].N[i];
          row:=rows.AddNewObject;
          row.Prefill;

          if not NxIsEmptyOID(AnsiUpperCase(SRow.S['activity'])) then begin
            row.SetFieldValueAsString('BusTransaction_ID', AnsiUpperCase(SRow.S['activity']));
          end
          else begin
             if not NxIsEmptyOID(AnsiUpperCase(headBusTransaction))
            then begin
              row.SetFieldValueAsString('BusTransaction_ID',AnsiUpperCase(headBusTransaction));
            end
            else begin
              if not pbZkracenyLog then logs.Add('Obchodní případ nenačten.');
            end;
          end;

          // Division_ID
          if not NxIsEmptyOID(AnsiUpperCase(SRow.S['cost_center']))
          then begin
            row.SetFieldValueAsString('Division_ID', AnsiUpperCase(SRow.S['cost_center']));
          end
          else begin
            if not NxIsEmptyOID(AnsiUpperCase(headDivision))
            then begin
              row.SetFieldValueAsString('Division_ID',AnsiUpperCase(headDivision));
            end
            else begin
              if not NxIsEmptyOID(AnsiUpperCase(Def_Division_ID)) then begin
                if not pbZkracenyLog then logs.Add('Nastavuji výchozí středisko.');
                row.SetFieldValueAsString('Division_ID', AnsiUpperCase(Def_Division_ID));
              end
              else begin
                if not pbZkracenyLog then logs.Add('Středisko nenastaveno, přeskakuji řádek.');
                row.MarkForDelete;
                continue;
              end;
            end;
          end;

          // BusOrder
          if not NxIsEmptyOID(AnsiUpperCase(SRow.S['contract']))
          then begin
            row.SetFieldValueAsString('BusOrder_ID', AnsiUpperCase(SRow.S['contract']));
          end
          else begin
            if not NxIsEmptyOID(AnsiUpperCase(headBusOrder))
            then begin
              row.SetFieldValueAsString('BusOrder_ID',AnsiUpperCase(headBusOrder));
            end
            else begin
              if not pbZkracenyLog then logs.Add('Zakázka nenastavena.');
            end;
          end;

          // BusProject
          if not NxIsEmptyOID(AnsiUpperCase(SRow.S['project']))
          then begin
            row.SetFieldValueAsString('BusProject_ID', AnsiUpperCase(SRow.S['project']));
          end
          else begin
            if not NxIsEmptyOID(AnsiUpperCase(headBusProject))
            then begin
              row.SetFieldValueAsString('BusProject_ID',AnsiUpperCase(headBusProject));
            end
            else begin
              if not pbZkracenyLog then logs.Add('Projekt nenastaven.');
            end;
          end;

          // Text na radku
          strText:='';
          if SRow.S['item_code']<>'' then begin
            strText:=SRow.S['item_code'];
          end;
          if SRow.S['item_description']<>'' then begin
            if strText<>'' then begin
              strText:=strText+': ';
            end;
            strText:=strText+SRow.S['item_description'];
          end;
          if strText='' then begin
            strText:=SRow.S['description'];
          end;
          row.SetFieldValueAsString('Text', Copy(strText,1,160));

          // Castka
          if abs(GetFloatDef(SRow.S['total_base'])+GetFloatDef(SRow.S['total_tax'])) > 0 then begin
            amount:= GetFloatDef(SRow.S['total_base'])+GetFloatDef(SRow.S['total_tax']);
          end else begin
            q:= GetFloatDef(SRow.S['quantity']);
            if q=0 then begin
              q:=1;
            end;
            amount:=q*GetFloatDef(SRow.S['unit_base'])+GetFloatDef(SRow.S['total_tax']);
          end;

          if abs(amount)<0.000001 then begin
            if not pbZkracenyLog then logs.Add('Nulová částka na řádku, přeskakuji.');
            row.MarkForDelete;
            continue;
          end;
          row.SetFieldValueAsFloat(lcAmountFieldName, amount);
        end;
        if rows.CountOfNotDeleted=0 then begin
          if not pbZkracenyLog then logs.Add('Řádky se nepodařilo vytvořit, zkouším vytvořit řádek na základě údajů z hlavičky.');
          FromHeader:=true;
        end;
      end;
    except
      if not pbZkracenyLog then logs.Add('Řádky se nepodařilo vytvořit, zkouším vytvořit řádek na základě údajů z hlavičky.');
      FromHeader:=true;
    end;

    if FromHeader then begin
      // tax_detail - vytvor radky z rekapitulace
      FromHeader:= False;
      try
        try
          FromHeader:= annotationsMap.A['tax_detail'].length=0;
        except
          FromHeader:=true;
          if not pbZkracenyLog then logs.Add('Rekapitulace nezadána.');
        end;

        if not(FromHeader) then begin
          annotationsMap.A['tax_detail'].length;
          logs.Add('Tvořím řádky z rekapitulace');
          for i:=0 to annotationsMap.A['tax_detail'].length-1 do begin // radky
            SRow:=annotationsMap.A['tax_detail'].N[i];
                if (SRow.S['rate']='')
                    OR ((SRow.S['base']='') AND (SRow.S['tax']=''))
            then begin
              if not pbZkracenyLog then logs.Add('Neúplné údaje na řádku rekapitulace, přeskakuji.');
              continue;
            end;
            if not pbZkracenyLog then logs.Add('Vytvářím řádek z rekapitulace.');

            row:=rows.AddNewObject;
            row.Prefill;
            if NxIsEmptyOID(AnsiUpperCase(headDivision)) then begin
              pcError:= 'Středisko na hlavičce nenastaveno, doklad nelze vytvořit.';
              logs.Add(pcError);
              exit;
            end;
            row.SetFieldValueAsString('Division_ID', AnsiUpperCase(headDivision));

            if not NxIsEmptyOID(AnsiUpperCase(headBusTransaction)) then begin
              row.SetFieldValueAsString('BusTransaction_ID', AnsiUpperCase(headBusTransaction));
            end;
            if not NxIsEmptyOID(AnsiUpperCase(headBusOrder)) then begin
              row.SetFieldValueAsString('BusOrder_ID', AnsiUpperCase(headBusOrder));
            end;
            if not NxIsEmptyOID(AnsiUpperCase(headBusProject)) then begin
              row.SetFieldValueAsString('BusProject_ID', AnsiUpperCase(headBusProject));
            end;

            if ((SRow.S['rate']<>'')
                AND
                (SRow.S['base']<>''))
            then begin
              {
              row.SetFieldValueAsString('VATIndex_ID', sqlRow[0]);
              row.SetFieldValueAsString('VATRate_ID',sqlRow[1]);
              }
              row.SetFieldValueAsFloat(lcAmountFieldName, GetFloatDef(SRow.S['base'])+GetFloatDef(SRow.S['tax']));
            end
            else begin
              if  ((SRow.S['rate']<>'')
                  AND
                  (GetFloatDef(SRow.S['rate'])<>0)
                  AND
                  (SRow.S['tax']<>''))
              then begin
                row.SetFieldValueAsFloat(lcAmountFieldName, (GetFloatDef(SRow.S['tax'])/(GetFloatDef(SRow.S['rate'])/100))+GetFloatDef(SRow.S['tax']));
              end;
            end;
            row.SetFieldValueAsString('Text', Copy(annotationsMap.S['description'],1,160));
          end;
          if rows.CountOfNotDeleted=0 then begin
            pcError:= 'Řádky se nepodařilo založil z rekapitulace, přeskakuji.';
            logs.Add(pcError);
            exit;
          end;
          FromHeader:=false;
        end;
      except
        pcError:= 'Rekapitulace nezadána. '+ExceptionMessage;
        logs.Add(pcError);
        exit;
      end;
    end;

    if FromHeader then begin
      // Vytvarim novy radek z hlavicky
      row:=rows.AddNewObject;
      row.Prefill;

      if not NxIsEmptyOID(AnsiUpperCase(headBusTransaction)) then begin
        row.SetFieldValueAsString('BusTransaction_ID', AnsiUpperCase(headBusTransaction));
      end;

      if NxIsEmptyOID(AnsiUpperCase(headDivision)) then begin
        pcError:= 'Středisko na hlavičce nenastaveno, doklad nelze vytvořit.';
        logs.Add(pcError);
        exit;
      end;
      row.SetFieldValueAsString('Division_ID', AnsiUpperCase(headDivision));

      if not NxIsEmptyOID(AnsiUpperCase(headBusOrder)) then begin
        row.SetFieldValueAsString('BusOrder_ID', AnsiUpperCase(headBusOrder));
      end;

      if not NxIsEmptyOID(AnsiUpperCase(headBusProject)) then begin
        row.SetFieldValueAsString('BusProject_ID', AnsiUpperCase(headBusProject));
      end;

      row.SetFieldValueAsFloat(lcAmountFieldName, GetFloatDef(annotationsMap.S['total_base'])+GetFloatDef(annotationsMap.S['total_tax'])+GetFloatDef(annotationsMap.S['total_rounding']));
      row.SetFieldValueAsString('Text', Copy(annotationsMap.S['description'],1,160));
    end;

    // kurz
    if (annotationsMap.S['exchange_rate']<>'') and (AnsiUpperCase(fp.GetFieldValueasString('Currency_ID.Code'))<>'CZK') then begin
      fp.SetFieldValueAsFloat('CurrRate',GetFloatDef(annotationsMap.S['exchange_rate']));
    end;

    if not pbZkracenyLog then logs.Add('Ukládám');
    try
      if not fp.Validate then begin
        pcError:= 'Chyba při validaci zálohové faktury: '+GetValidateErrs(fp);
        logs.Add(pcError);
      end
      else begin
        fp.Save;
        FP_ID:=fp.OID;
        lcFP_Name:= fp.DisplayName;
        logs.Add('Vytvořeno: '+lcFP_Name);
      end;

    except
      pcError:= 'Neočekávaná chyba při ukládání zálohové faktury: '+ExceptionMessage;
      logs.Add(pcError);
    end;

    if not NxIsEmptyOID(FP_ID) then begin
      try
        // FILE
        if (not NxIsEmptyOID(Def_Doc_DQ_ID)) AND (not NxIsEmptyOID(Def_Doc_DC_ID))
        then begin
          str:= downloadFile(OS, '11', Document_ID, fp.OID, Firm_ID, Def_Doc_DQ_ID, Def_Doc_DC_ID, AUTH_TOKEN, pcQueue_ID, lcDigitooSourceFileName);
          if str<>'' then logs.Add('Došlo k chybě při stažení PDF dokladu: '+str);
        end
        else begin
          logs.Add('Vyplňte v agendě typ a řadu pro přílohu.');
        end;
      except
        logs.Add('Chyba při stahování PDF: '+ExceptionMessage);
      end;
      if pbImportAllAttachments then begin  //přílohy
        try
          if (not NxIsEmptyOID(Def_Doc_DQ_ID)) AND (not NxIsEmptyOID(Def_Doc_DC_ID))
            then downloadAttachments(OS, '11', Document_ID, fp.OID, Firm_ID, Def_Doc_DQ_ID, Def_Doc_DC_ID, AUTH_TOKEN, logs);
        except
          logs.Add('Chyba při stahování příloh: '+ExceptionMessage);
        end;
      end;
      if pbImportDates then begin  //časová razítka
        try
          GetTimeStamps(OS, '11', Document_ID, fp.OID, AUTH_TOKEN, logs, pbZkracenyLog);
        except
          logs.Add('Chyba při stahování časových razítek: '+ExceptionMessage);
        end;
      end;
      if AnsiUpperCase(annotationsMap.S['payment_order'])='YES' then begin
        lfCastkaKUhrade:= 0;
        try
          lfCastkaKUhrade:= GetFloatDef(annotationsMap.S['total_due']);
        except
          lfCastkaKUhrade:= fp.GetFieldValueAsFloat('Amount');
        end;
        if lfCastkaKUhrade>0 then begin
          if not pbZkracenyLog then logs.Add('Generuji žádost platebního příkazu.');
          try
            GenerujZadostPP(fp,'11',lfCastkaKUhrade,logs,pbZkracenyLog);
          except
          end;
        end
        else begin
          logs.Add('Částka k úhradě je nulová, nemá smysl generovat žádost platebního příkazu, jak je požadováno.');
        end;
      end;
    end;
  finally
    Result:= lcFP_Name;
    fp.Free;
    ret.Free;
    sqlRow.Free;
    lmContext.Free;
  end;
end;

procedure GetTimeStamps(OS:TNxCustomObjectSpace;
                        pcDocumentType, Document_ID, FP_ID, AUTH_TOKEN: String; Logs: TStrings; pbZkracenyLog: boolean);
var
  url, headers, str, lcEvent, lcNewValue, CLSID: String;
  stream: TMemoryStream;
  reg: TJSONSuperObject;
  i: integer;
  loObj: TNxCustomBusinessObject;
  ldTimeStamp: TDateTime;
  laSchvalili: TStringList;
begin
//Document_ID:= '6340d212-c0c6-463d-9f26-b89052866ff8';
  if Document_ID='' then exit;
  if NxIsEmptyOID(FP_ID) then exit;

  case pcDocumentType of
   '04': CLSID:= Class_ReceivedInvoice;
   '11': CLSID:= Class_ReceivedDepositInvoice;
   '64': CLSID:= Class_VATReceivedDepositInvoice;
   '03': CLSID:= Class_IssuedInvoice;
   '06': CLSID:= Class_CashPaid;
   '02': CLSID:= Class_OtherExpense;
    else exit;
  end;


  url:= URL_AUDIT_LOG_V2;
  url:= ReplaceStr(url, '%DOCUMENT_ID%',Document_ID);

  loObj:= OS.CreateObject(CLSID);
  stream:=TMemoryStream.Create;
  laSchvalili:= TStringList.Create;
  laSchvalili.Delimiter:= ';';
  try
    try
      loObj.Load(FP_ID, nil);
      headers:='Authorization:Bearer '+AUTH_TOKEN;
      headers:= headers+#13#10+cAgentHeader+cScriptVersion;
      str:= HTTPReadOLE(url,stream,false,headers,'');
      if str<>'' then begin
        Logs.Add('Chyba při stahování časových razítek: '+str);
      end
      else begin
        reg.Free;
        reg:= TJSONSuperObject.ParseString(TEncoding.UTF8.GetString(stream.GetBytes),true); // ABRA nekonvertuje z UTF-8 !

        if reg.A['data'].length=0 then begin
          Logs.Add('Žádná časová razítka ke stažení.');
        end
        else begin
          if not pbZkracenyLog then Logs.Add('Stahuji časová razítka.');
          for i:=0 to reg.A['data'].length-1 do begin
            ldTimeStamp:= reg.A['data'].N[i].DT8601['created_at'];
            if i=0 then begin
              loObj.SetFieldValueAsDateTime('X_DigitooDate1$DATE', ldTimeStamp);
              loObj.SetFieldValueAsString('X_DigitooUser1', reg.A['data'].N[i].S['user_name']);
            end
            else begin
              lcEvent:= reg.A['data'].N[i].S['event'];
              lcNewValue:= reg.A['data'].N[i].S['new_value'];
              if (lcEvent='approval_status_change') and (lcNewValue='initiated') then begin
                loObj.SetFieldValueAsDateTime('X_DigitooDate2$DATE', ldTimeStamp);
                loObj.SetFieldValueAsString('X_DigitooUser2', reg.A['data'].N[i].S['user_name']);
              end;
              if (lcEvent='approval_status_change') and (lcNewValue='approved') then begin
                laSchvalili.Add(reg.A['data'].N[i].S['user_name']);
              end;
              if (lcEvent='status_change') and (lcNewValue='waiting-for-human-validation') then begin
                loObj.SetFieldValueAsDateTime('X_DigitooDate3$DATE', ldTimeStamp);
                loObj.SetFieldValueAsString('X_DigitooUser3', NxLeft(NxIifStr(laSchvalili.Count=0,reg.A['data'].N[i].S['user_name'],laSchvalili.DelimitedText),100));
              end;
              if (lcEvent='status_change') and (lcNewValue='ready-to-export') then begin
                loObj.SetFieldValueAsDateTime('X_DigitooDate4$DATE', ldTimeStamp);
                loObj.SetFieldValueAsString('X_DigitooUser4', reg.A['data'].N[i].S['user_name']);
              end;
            end;
          end;
        end;
        try
          if loObj.NeedSave then loObj.Save;
          Logs.Add('Časová razítka stažena.');
        except
          Logs.Add('Chyba při zápisu časových razítek na doklad: '+ExceptionMessage);
        end;
      end;
    except
      Logs.Add('Žádná časová razítka ke stažení.');
    end;
  finally
    laSchvalili.Free;
    stream.Free;
    loObj.Free;
  end;
end;

procedure downloadAttachments(OS:TNxCustomObjectSpace;
                              pcDocumentType, Document_ID, FP_ID, Firm_ID, Def_Doc_DQ_ID, Def_Doc_DC_ID, AUTH_TOKEN: String; Logs: TStrings);
var
  url, headers, str, lcID, lcFileName: String;
  stream: TMemoryStream;
  reg: TJSONSuperObject;
  i: integer;
begin
  if Document_ID='' then exit;
  if NxIsEmptyOID(FP_ID) then exit;
  url:=URL_DOWNLOAD_ATTACHMENTS_V2;
  url:=ReplaceStr(url, '%DOCUMENT_ID%',Document_ID);
  stream:=TMemoryStream.Create;
  try
    headers:= 'Authorization:Bearer '+AUTH_TOKEN;
    headers:= headers+#13#10+cAgentHeader+cScriptVersion;
    str:= HTTPReadOLE(url,stream,false,headers,'');
    if str<>'' then begin
      Logs.Add('Chyba při stahování příloh: '+str);
    end
    else begin
      reg:=TJSONSuperObject.ParseString(TEncoding.UTF8.GetString(stream.GetBytes),true); // ABRA nekonvertuje z UTF-8 !
      if reg.A['data'].length=0 then begin
        Logs.Add('Žádné přílohy ke stažení.');
      end
      else begin
        Logs.Add('Stahuji přílohy.');
        for i:=0 to reg.A['data'].length-1 do begin
          stream.Clear;
          lcID:= reg.A['data'].N[i].S['id'];
          lcFileName:= reg.A['data'].N[i].S['file_name'];
          url:= reg.A['data'].N[i].S['url'];
          str:= HTTPReadOLE(url,stream,false,headers,'');
          if str<>'' then begin
            Logs.Add('Při stahování přílohy "'+lcFileName+'" došlo k chybě: '+str);
          end
          else begin
            if not AttachmentExist(OS,pcDocumentType,FP_ID,stream.GetBytes) then begin
              str:= AddAttachment(OS,pcDocumentType,FP_ID,Firm_ID,lcFileName,Def_Doc_DQ_ID,Def_Doc_DC_ID,stream.GetBytes, lcID);
              if str=''
                then Logs.Add('Příloha "'+lcFileName+'" stažena a přiložena k dokladu.')
                else Logs.Add('Při ukládání přílohy "'+lcFileName+'" došlo k chybě: '+str);
            end;
          end;
        end;
      end;
    end;
  finally
    stream.free;
  end;
end;

function AttachmentExist(OS: TNxCustomObjectSpace; pcDocumentType, pcDocument_ID: string; tb: TBytes): boolean;
var
  lcSQL: string;
  laPom: TStringList;
  i, j, lnRelDef: integer;
  lmDocConts: TNxCustomBusinessMonikerCollection;
  loDoc, loDocCont, loData: TNxCustomBusinessObject;
begin
  Result:= False;
  laPom:= TStringList.Create;
  try
    case pcDocumentType of
      '04':lnRelDef:= 601;
      '06':lnRelDef:= 608;
      '02':lnRelDef:= 604;
      '03':lnRelDef:= 600;
      '11':lnRelDef:= 614;
      '64':lnRelDef:= 665;
      else exit;
    end;
    lcSQL:= 'Select D.ID'
        +#13' from Documents D'
        +#13' join Relations R on R.Rel_Def='+IntToStr(lnRelDef)+' and R.RightSide_ID=D.ID'
        +#13' where R.LeftSide_ID='+QuotedStr(pcDocument_ID);
    OS.SQLSelect(lcSQL, laPom);
    for i:=0 to laPom.Count-1 do begin
      loDoc:= OS.CreateObject(Class_Document);
      try
        loDoc.Load(laPom[i], nil);
        lmDocConts:= loDoc.GetLoadedCollectionMonikerForFieldCode(loDoc.GetFieldCode('Contents'));
        for j:=0 to lmDocConts.Count-1 do begin
          loDocCont:= lmDocConts.BusinessObject[j];
          loData:= loDocCont.GetMonikerForFieldCode(loDocCont.getFieldCode('Data_ID')).BusinessObject;
          if Length(tb)=loData.GetFieldValueAsFloat('OriginalSize') then
            if EncodeBase64(loData.GetFieldValueAsBytes('BlobData'))=EncodeBase64(tb) then begin
              Result:= True;
              exit;
            end;
        end;
      finally
        loDoc.Free;
      end;
    end;
  finally
    laPom.Free;
  end;
end;

function downloadFile(OS:TNxCustomObjectSpace;
                      pcDocumentType, Document_ID, FP_ID, Firm_ID, Def_Doc_DQ_ID, Def_Doc_DC_ID, AUTH_TOKEN, pcQueue_ID, pcDigitooSourceFileName: String): string;
var
  ret: TStringList;
  url, fileStr, headers, str: String;
  stream: TMemoryStream;
begin
  Result:= '';
  if Document_ID='' then exit;
  if NxIsEmptyOID(FP_ID) then exit;
  url:=URL_DOWNLOAD_FILE;
  {
  if pcQueue_ID<>'' then begin
    url:=ReplaceStr(URL_DOWNLOAD_FILE_QUEUE, '%QUEUE_ID%', pcQueue_ID);
  end;
  }
  url:=ReplaceStr(url, '%DOCUMENT_ID%',Document_ID);
  stream:=TMemoryStream.Create;
  try
    headers:= 'Authorization:Bearer '+AUTH_TOKEN;
    headers:= headers+#13#10+cAgentHeader+cScriptVersion;
    str:= HTTPReadOLE(url,stream,false,headers,'');
    if str=''
      then Result:= AddAttachment(OS,pcDocumentType,FP_ID,Firm_ID,NxIIfStr(pcDigitooSourceFileName<>'',pcDigitooSourceFileName,'Digitoo.pdf'),Def_Doc_DQ_ID,Def_Doc_DC_ID,stream.GetBytes)
      else Result:= str;
  finally
    stream.free;
  end;
end;

function AddAttachment(OS:TNxCustomObjectSpace;
                       pcDocumentType, Doc_ID, Firm_ID, FileName, DQ_ID, DC_ID: String; tb: TBytes; pcDocument_ID: string = ''): string;
var
  doc, loRow, loData: TNxCustomBusinessObject;
  loRows: TNxCustomBusinessMonikerCollection;
  i: integer;
begin
  Result:= '';
  doc:=OS.CreateObject(Class_Document);
  try
    doc.New;
    doc.Prefill;
    doc.SetFieldValueAsString('DocQueue_ID',DQ_ID);
    doc.SetFieldValueAsString('Category_ID',DC_ID);
    doc.SetFieldValueAsString('Firm_ID',Firm_ID);
    doc.SetFieldValueAsString('Description',FileName);
    try
      if pcDocument_ID<>'' then doc.SetFieldValueAsString('X_DigitooID',pcDocument_ID);
    except
    end;

    loRows:=doc.GetLoadedCollectionMonikerForFieldCode(doc.GetFieldCode('Contents'));
    loRow:=loRows.AddNewObject;
    loRow.Prefill;
    loRow.SetFieldValueAsString('FileName',FileName);
    loRow.SetFieldValueAsDateTime('CreationTime$DATE',Now);
    loRow.SetFieldValueAsBoolean('ExternalFile',false);

    if Length(tb)>0 then begin
      loData:=loRow.GetMonikerForFieldCode(loRow.GetFieldCode('Data_ID')).BusinessObject;
      loData.SetFieldValueAsBytes('BlobData',tb);
      if not(osNew in doc.State) then loData.SetFieldValueAsBytes('BlobData',tb); { ABRA totiz zlobi}
    end;

    try
      doc.Save;
      case pcDocumentType of
        '04':begin
               SetRelationOS(OS,601,Doc_ID,doc.OID);
               SetRelationOS(OS,1663,Doc_ID,doc.OID);
               SetRelationOS(OS,1662,doc.OID,Doc_ID);
             end;
        '06':SetRelationOS(OS,608,Doc_ID,doc.OID);
        '02':SetRelationOS(OS,604,Doc_ID,doc.OID);
        '03':begin
              SetRelationOS(OS,600,Doc_ID,doc.OID);
              SetRelationOS(OS,1671,Doc_ID,doc.OID);
              SetRelationOS(OS,1670,doc.OID,Doc_ID);
             end;
        '11':begin
               SetRelationOS(OS,614,Doc_ID,doc.OID);
               SetRelationOS(OS,1657,Doc_ID,doc.OID);
               SetRelationOS(OS,1656,doc.OID,Doc_ID);
             end;
        '64':begin
               SetRelationOS(OS,665,Doc_ID,doc.OID);
               SetRelationOS(OS,1659,Doc_ID,doc.OID);
               SetRelationOS(OS,1658,doc.OID,Doc_ID);
             end;
      end;
    except
      Result:= ExceptionMessage;
    end;
  finally
    doc.Free;
  end;
end;

procedure addNote(OS:TNxCustomObjectSpace;
                  DPH, Stredisko, Note:String;
                  Rows: TNxCustomBusinessMonikerCollection);
var
  row: TNxCustomBusinessObject;
  ret: TStringList;
begin
  if (Note='') OR (NxIsEmptyOID(DPH)) OR (NxIsEmptyOID(Stredisko)) then exit;
  ret:=TStringList.Create;
  try
    row:=Rows.AddNewObject;
    row.SetFieldValueAsString('Division_ID', AnsiUpperCase(Stredisko));
    row.SetFieldValueAsString('Text', Note);
    OS.SQLSelect('SELECT VATRate_ID FROM VATIndexes WHERE ID='+QuotedStr(AnsiUpperCase(DPH)),ret);
    if ret.Count=0 then begin
      exit;
    end;
    row.SetFieldValueAsString('VATRate_ID',ret[0]);
    row.SetFieldValueAsString('VATIndex_ID', AnsiUpperCase(DPH));
  finally
    ret.Free;
  end;
end;

function MassExport(OS:TNxCustomObjectSpace;logs: TStrings=nil):Boolean;
var
  ret, digitoo, digitooRow, retpart, laNames, laValues: TStringList;
  obj: TNxCustomBusinessObject;
  AUTH_TOKEN, lcSQLcond, SQL, lcObjectName, str, Typ, lcDocumentTypes, lcTypeName, lcRegisterName, lcNotExportedData,
    //lcUserEmail, lcUserPassword,
    lcDigitoo_ID: string;
  i, k, m, iLog, lnMaxRecordCount, lnLastRecord, lnIndex: integer;
  lmContext: TNxContext;
begin
  ret:= TStringList.Create;
  ret.Delimiter:= ';';
  retpart:= TStringList.Create;
  digitoo:= TStringList.Create;
  digitooRow:= TStringList.Create;
  obj:=OS.CreateObject(DIGITOO_CLSID);
  laNames:= TStringList.Create;
  laValues:= TStringList.Create;
  lmContext:= NxCreateContext(OS);
  try
    obj.New;
    SQL:='SELECT QID.StringFieldValue'
    +#13'  ,COALESCE(TYP.StringFieldValue,'+NxIifStr(NxIsOracle,'N','')+'''0'')'
    +#13'  ,X.StringFieldValue'
    +#13'  ,DD.Name'
    +#13'  ,coalesce(MAXREC.StringFieldValue,'+NxIifStr(NxIsOracle,'N','')+'''0'')'
    +#13'  ,NOEXPORT.StringFieldValue'
//    +#13'  ,DRUE.StringFieldValue'
//    +#13'  ,DRUP.StringFieldValue'
    +#13'  ,DD.ID'
    +#13' FROM DefRollData DD'
    +#13' LEFT JOIN UserData QID ON QID.CLSID = DD.CLSID AND QID.ID = DD.ID AND QID.FieldCode='+IntToStr(obj.GetFieldCode('U_Queue_ID'))
    +#13' LEFT JOIN UserData TYP ON TYP.CLSID = DD.CLSID AND TYP.ID = DD.ID AND TYP.FieldCode='+IntToStr(obj.GetFieldCode('U_Type'))
    +#13' LEFT JOIN UserData X ON X.CLSID = DD.CLSID AND X.ID = DD.ID AND X.FieldCode='+IntToStr(obj.GetFieldCode('U_Token'))
    +#13' LEFT JOIN UserData MAXREC ON MAXREC.CLSID = DD.CLSID AND MAXREC.ID = DD.ID AND MAXREC.FieldCode='+IntToStr(obj.GetFieldCode('U_MaxRecordCount'))
    +#13' LEFT JOIN UserData NOEXPORT ON NOEXPORT.CLSID = DD.CLSID AND NOEXPORT.ID = DD.ID AND NOEXPORT.FieldCode='+IntToStr(obj.GetFieldCode('U_NotExportedData'))
//    +#13' LEFT JOIN UserData DRUE ON DRUE.CLSID = DD.CLSID AND DRUE.ID = DD.ID AND DRUE.FieldCode='+IntToStr(obj.GetFieldCode('U_UserEmail'))
//    +#13' LEFT JOIN UserData DRUP ON DRUP.CLSID = DD.CLSID AND DRUP.ID = DD.ID AND DRUP.FieldCode='+IntToStr(obj.GetFieldCode('U_UserPassword'))
    +#13' WHERE DD.CLSID='+QuotedStr(DIGITOO_CLSID)+' AND DD.Hidden=''N''';
    OS.SQLSelect(SQL, digitoo);

    digitooRow.Delimiter:=';';
    for k:=0 to digitoo.Count-1 do begin
      laNames.Clear;
      laValues.Clear;
      digitooRow.DelimitedText:=digitoo[k];
      Typ:=digitooRow[1];
      AUTH_TOKEN:=trim(digitooRow[2]);
      lcTypeName:= digitooRow[3];
      lnMaxRecordCount:= StrToInt(digitooRow[4]);
      lcNotExportedData:= digitooRow[5];
      //lcUserEmail:= digitooRow[6];
      //lcUserPassword:= digitooRow[7];
      lcDigitoo_ID:= digitooRow[6];

      if Assigned(logs) then iLog:=logs.Add(NxIifStr(k>0,#13#10,'')+lcTypeName+': ');

      if (AUTH_TOKEN='') then begin
        if Assigned(logs) then iLog:=logs.Add('Není vyplněn autentifikační token.');
        continue;
      end;

      AUTH_TOKEN:= GetAccountToken(OS, AUTH_TOKEN, lcDigitoo_ID);
      if (AUTH_TOKEN='') then begin
        if Assigned(logs) then iLog:=logs.Add('Nepodařilo se získat přístupový token.');
        continue;
      end;

      {
      if (lcUserEmail<>'') and (lcUserPassword<>'') then begin
        AUTH_TOKEN:= Login(OS, lcUserEmail, lcUserPassword);
      end;

      if (AUTH_TOKEN='') then begin
        iLog:= logs.Add('Nepodařilo se přihlásit do Digitoo. Zkontrolujte přihlašovací údaje do Digitoo.'+#13#10);
        continue;
      end;
      }

      lcDocumentTypes:= '';
      case Typ of
        '0': lcDocumentTypes:= '(''04'',''11'',''64'')';
        '1': lcDocumentTypes:= '(''03'')';
        '2': lcDocumentTypes:= '(''02'',''06'')';
      end;

      lnIndex:= 0;
      lnIndex:= lnIndex+1;
      if not (UpperCase(Copy(lcNotExportedData, lnIndex, 1)) in ['A','1']) then begin
        // Zakázky: contract
        OS.SQLSelect('SELECT ID, Code||'': ''||Name AS Label FROM BusOrders WHERE Hidden=''N'' and X_NoSendToDigiToo=''N'' ORDER BY Code', ret);
        laNames.Add('zakázky=contract');
        laValues.Add(ret.DelimitedText);
      end;

      lnIndex:= lnIndex+1;
      if not (UpperCase(Copy(lcNotExportedData, lnIndex, 1)) in ['A','1']) then begin
      // Středisko: cost_center
        OS.SQLSelect('SELECT ID, Code||'': ''||Name AS Label FROM Divisions WHERE Hidden=''N'' and X_NoSendToDigiToo=''N'' ORDER BY Code', ret);
        laNames.Add('střediska=cost_center');
        laValues.Add(ret.DelimitedText);
      end;

      lnIndex:= lnIndex+1;
      if not (UpperCase(Copy(lcNotExportedData, lnIndex, 1)) in ['A','1']) then begin
        // Typ výdaje: account_code
        OS.SQLSelect('SELECT ID, Code||'': ''||Name AS Label FROM ExpenseTypes WHERE Hidden=''N'' and X_NoSendToDigiToo=''N'' ORDER BY Code', ret);
        laNames.Add('typy výdajů=account_code');
        laValues.Add(ret.DelimitedText);
      end;

      lnIndex:= lnIndex+1;
      if not (UpperCase(Copy(lcNotExportedData, lnIndex, 1)) in ['A','1']) then begin
        // Sazba DPH: tax_rate
        OS.SQLSelect('SELECT ID, Tariff AS Label, Tariff FROM VATRates WHERE Hidden=''N'' and X_NoSendToDigiToo=''N'' ORDER BY NAME, tariff', ret);
        laNames.Add('sazby DPH=tax_rate');
        laValues.Add(ret.DelimitedText);
      end;

      lnIndex:= lnIndex+1;
      if not (UpperCase(Copy(lcNotExportedData, lnIndex, 1)) in ['A','1']) then begin
        // DPH Index: vat_code
        lcSQLcond:= '';
        case Typ of
          '0': lcSQLcond:= ' and ((A.IsCommon=''A'') or (A.Income=''A''))';
          '1': lcSQLcond:= ' and ((A.IsCommon=''A'') or (A.Income=''N''))';
          '2': lcSQLcond:= ' and ((A.IsCommon=''A'') or (A.Income=''A''))';
        end;
        OS.SQLSelect('SELECT A.ID, A.Code||'': ''||cast(A.Tariff as VarChar(10))||'' (''||A.Description||'')'' FROM VATIndexes A'
                 +#13' JOIN Countries C ON C.ID = A.Country_ID'
                 +#13' WHERE C.ID='+QuotedStr(lmContext.GetCompanyCache.CountryID)
                 +#13'       AND A.Hidden=''N'''
                 +#13'       and A.X_NoSendToDigiToo=''N'''
                 +lcSQLcond
                 +#13' ORDER BY A.Code', ret);
        laNames.Add('DPH indexy=vat_code');
        laValues.Add(ret.DelimitedText);
      end;

      lnIndex:= lnIndex+1;
      if not (UpperCase(Copy(lcNotExportedData, lnIndex, 1)) in ['A','1']) then begin
        // Pokladny: cash_register_type
        OS.SQLSelect('SELECT A.ID, C.Code||'': ''||A.Name AS Label'
                 +#13' FROM CashDesks A'
                 +#13' JOIN Currencies C on C.ID=A.Currency_ID'
                 +#13' WHERE A.Hidden=''N'' and X_NoSendToDigiToo=''N'''
                 +#13' ORDER BY C.Code, A.Name', ret);
        laNames.Add('pokladny=cash_register_type');
        laValues.Add(ret.DelimitedText);
      end;

      lnIndex:= lnIndex+1;
      if not (UpperCase(Copy(lcNotExportedData, lnIndex, 1)) in ['A','1']) then begin
        // Řady dokladů: accounting_sequence
        OS.SQLSelect('SELECT ID, Code||'': ''||Name AS Label FROM DocQueues WHERE DocumentType in '+lcDocumentTypes+' AND Hidden=''N'' and X_NoSendToDigiToo=''N'' ORDER BY Code', ret);
        laNames.Add('řady dokladů=accounting_sequence');
        laValues.Add(ret.DelimitedText);
      end;

      lnIndex:= lnIndex+1;
      if not (UpperCase(Copy(lcNotExportedData, lnIndex, 1)) in ['A','1']) then begin
        // Kontace: assignment
        SQL:= 'SELECT ID,'
          +#13'      (case when DocumentType=''04'' then ''FP'''
          +#13'            when DocumentType=''11'' then ''ZLP'''
          +#13'            when DocumentType=''64'' then ''DZLP'''
          +#13'            when DocumentType=''03'' then ''FV'''
          +#13'            when DocumentType=''02'' then ''OSV'''
          +#13'            when DocumentType=''06'' then ''PV'''
          +#13'            else ''-'''
          +#13'       end)||'': ''||Name AS Label'
          +#13' FROM AccPresetDefs'
          +#13' WHERE DocumentType in '+lcDocumentTypes
          +#13'       and Hidden=''N'''
          +#13'       and X_NoSendToDigiToo=''N'''
          +#13' ORDER BY Code';
        OS.SQLSelect(SQL, ret);
        laNames.Add('předkontace=assignment');
        laValues.Add(ret.DelimitedText);
      end;

      lnIndex:= lnIndex+1;
      if not (UpperCase(Copy(lcNotExportedData, lnIndex, 1)) in ['A','1']) then begin
        // Obchodní případ: activity
        OS.SQLSelect('SELECT ID, Code||'': ''||Name AS Label FROM BusTransactions WHERE Hidden=''N'' and X_NoSendToDigiToo=''N'' ORDER BY Code', ret);
        laNames.Add('obchodní případy=activity');
        laValues.Add(ret.DelimitedText);
      end;

      lnIndex:= lnIndex+1;
      if not (UpperCase(Copy(lcNotExportedData, lnIndex, 1)) in ['A','1']) then begin
        // Typ úhrady: payment_type
        OS.SQLSelect('SELECT ID, Code||'': ''||Name AS Label FROM PaymentTypes WHERE Hidden=''N'' and X_NoSendToDigiToo=''N'' ORDER BY Code', ret);
        laNames.Add('typy úhrady=payment_type');
        laValues.Add(ret.DelimitedText);
      end;

      lnIndex:= lnIndex+1;
      if not (UpperCase(Copy(lcNotExportedData, lnIndex, 1)) in ['A','1']) then begin
        // Projekt: Project
        OS.SQLSelect('SELECT ID, Code||'': ''||Name AS Label FROM BusProjects WHERE Hidden=''N'' and X_NoSendToDigiToo=''N'' ORDER BY Code', ret);
        laNames.Add('projekty=project');
        laValues.Add(ret.DelimitedText);
      end;

      lnIndex:= lnIndex+1;
      if not (UpperCase(Copy(lcNotExportedData, lnIndex, 1)) in ['A','1']) then begin
        // Typ obchodu: trade_code - v abre tradetype https://help.abra.eu/cs/21.3/G3/Content/Part21_Obecna_pravidla/typy_obchodu.htm?cshid=103
        ret.Clear;
        case Typ of
          '0',
          '2':begin
                ret.Add('0;"0 - NEZADÁNO"');
                ret.Add('1;"1 - TUZEMSKÝ"');
                ret.Add('2;"2 - Z JINÉ ZEMĚ EU (REŽIM ''''REVERSE CHARGE'''' NEBO TŘÍSTRANNÝ OBCHOD)"');
                ret.Add('3;"3 - MIMO EU"');
                ret.Add('4;"4 - Z JINÉ ZEMĚ EU (DPH NEBUDE UPLATNĚNA)"');
                ret.Add('5;"5 - Z JINÉ ZEMĚ EU (DPH BUDE UPLATNĚNA V JINÉ ZEMI EU)"');
                ret.Add('6;"6 - Z JINÉ ZEMĚ EU"');
              end;
          '1':begin
                ret.Add('0;"0 - NEZADÁNO"');
                ret.Add('1;"1 - TUZEMSKÝ"');
                ret.Add('2;"2 - DO JINÉ ZEMĚ EU (PLNĚNÍ OSVOBOZENÉ NEBO MIMO DPH"');
                ret.Add('3;"3 - MIMO EU"');
                ret.Add('4;"4 - DO JINÉ ZEMĚ EU (DPH BUDE PŘIZNÁNA V TUZEMSKU)"');
                ret.Add('5;"5 - DO JINÉ ZEMĚ EU (DPH BUDE PŘIZNÁNA V JINÉ ZEMI EU)"');
              end;
        end;
        laNames.Add('typy obchodu=trade_code');
        laValues.Add(ret.DelimitedText);
      end;

      lnIndex:= lnIndex+1;
      if not (UpperCase(Copy(lcNotExportedData, lnIndex, 1)) in ['A','1']) then begin
        // Země dodavatele: sender_country
        OS.SQLSelect('SELECT Code, Name AS Label FROM Countries WHERE Hidden=''N'' ORDER BY Code', ret);
        laNames.Add('země dodavatele=sender_country');
        laValues.Add(ret.DelimitedText);
      end;

      lnIndex:= lnIndex+1;
      if not (UpperCase(Copy(lcNotExportedData, lnIndex, 1)) in ['A','1']) then begin
        // Režim DPH: vat_mode
        ret.Clear;
        ret.Add('0;"0 - S daní (DPH)"');
        ret.Add('1;"1 - Přenesení (PDP)"');
        laNames.Add('režim DPH=vat_mode');
        laValues.Add(ret.DelimitedText);
      end;

      lnIndex:= lnIndex+1;
      if not (UpperCase(Copy(lcNotExportedData, lnIndex, 1)) in ['A','1']) then begin
        // Typ plnění: vat_type
        OS.SQLSelect('SELECT ID, Code||'': ''||Name AS Label FROM DRCArticles WHERE Hidden=''N'' ORDER BY Code', ret);
        laNames.Add('typ plnění=vat_type');
        laValues.Add(ret.DelimitedText);
      end;

      lnIndex:= lnIndex+1;
      if not (UpperCase(Copy(lcNotExportedData, lnIndex, 1)) in ['A','1']) then begin
        // Firma: sender_internal_id
        OS.SQLSelect('SELECT F.ID, F.Code||'': ''||F.Name AS Label'
                    +' FROM Firms F'
                    +' LEFT JOIN Firms Fx on Fx.ID=F.Firm_ID'
                    +' WHERE F.Hidden=''N'''
                    //+'       and coalesce(Fx.ID,'+NxIifStr(NxIsOracle,'N','')+'''xxx'')='+NxIifStr(NxIsOracle,'N','')+'''xxx'''
                    +'       and coalesce(Fx.ID,''xxx'')=''xxx'''
                    +' ORDER BY F.Name', ret);
        laNames.Add('firmy=sender_internal_id');
        laValues.Add(ret.DelimitedText);
      end;

      lnIndex:= lnIndex+1;
      if not (UpperCase(Copy(lcNotExportedData, lnIndex, 1)) in ['A','1']) then begin
        // Typ příjmu: income_type_code
        OS.SQLSelect('SELECT ID, Code||'': ''||Name AS Label FROM IncomeTypes WHERE Hidden=''N'' and X_NoSendToDigiToo=''N'' ORDER BY Code', ret);
        laNames.Add('typy příjmů=income_type_code');
        laValues.Add(ret.DelimitedText);
      end;

      lnIndex:= lnIndex+1;
      if not (UpperCase(Copy(lcNotExportedData, lnIndex, 1)) in ['A','1']) then begin
        // Do ESL: to_esl
        ret.Clear;
        ret.Add('0;"0 - nezapočítávat"');
        ret.Add('1;"1 - započítávat"');
        laNames.Add('Do ESL=to_esl');
        laValues.Add(ret.DelimitedText);
      end;

      lnIndex:= lnIndex+1;
      if not (UpperCase(Copy(lcNotExportedData, lnIndex, 1)) in ['A','1']) then begin
        // Typ plnění ESL: esl_indicator
        OS.SQLSelect('SELECT ID, Code||'': ''||Description AS Label FROM ESLIndicators WHERE Hidden=''N'' and X_NoSendToDigiToo=''N'' ORDER BY Code', ret);
        laNames.Add('typ plnění ESL=esl_indicator');
        laValues.Add(ret.DelimitedText);
      end;

      lnIndex:= lnIndex+1;
      if not (UpperCase(Copy(lcNotExportedData, lnIndex, 1)) in ['A','1']) then begin
        // Země odběratele: recipient_country
        OS.SQLSelect('SELECT Code, Name AS Label FROM Countries WHERE Hidden=''N'' ORDER BY Code', ret);
        laNames.Add('země odběratele=recipient_country');
        laValues.Add(ret.DelimitedText);
      end;

      lnIndex:= lnIndex+1;
      if not (UpperCase(Copy(lcNotExportedData, lnIndex, 1)) in ['A','1']) then begin
        // Schvalovatel: approverabra_id
        OS.SQLSelect('SELECT ID, Name AS Label FROM SecurityRoles WHERE Hidden=''N'' ORDER BY Name', ret);
        laNames.Add('schvalovatel=approverabra_id');
        laValues.Add(ret.DelimitedText);
      end;

      lnIndex:= lnIndex+1;
      if not (UpperCase(Copy(lcNotExportedData, lnIndex, 1)) in ['A','1']) then begin
        // DPH Index DRC: rch_vatindex_id
        lcSQLcond:= '';
        case Typ of
          '0': lcSQLcond:= ' and ((A.IsCommon=''A'') or (A.Income=''A''))';
          '1': lcSQLcond:= ' and ((A.IsCommon=''A'') or (A.Income=''N''))';
          '2': lcSQLcond:= ' and ((A.IsCommon=''A'') or (A.Income=''A''))';
        end;
        OS.SQLSelect('SELECT A.ID, A.Code||'': ''||cast(A.Tariff as VarChar(10))||'' (''||A.Description||'')'' FROM VATIndexes A'
                 +#13' JOIN Countries C ON C.ID = A.Country_ID'
                 +#13' WHERE C.ID='+QuotedStr(lmContext.GetCompanyCache.CountryID)
                 +#13'       AND A.Hidden=''N'''
                 +#13'       and A.X_NoSendToDigiToo=''N'''
                 +lcSQLcond
                 +#13' ORDER BY A.Code', ret);
        laNames.Add('DPH indexy DRC=rch_vatindex_id');
        laValues.Add(ret.DelimitedText);
      end;

      for i:=0 to laNames.Count-1 do begin
        lcObjectName:= laNames.Names[i];
        lcRegisterName:= laNames.ValueFromIndex[i];
        ret.Clear;
        ret.DelimitedText:= laValues[i];
        iLog:=logs.Add(' - '+lcObjectName+': ');
        if ret.count>0 then begin
          if (lnMaxRecordCount<>0) and (lnMaxRecordCount<ret.count) then begin
            retpart.Clear;
            lnLastRecord:= 0;
            for m:=1 to ret.Count do begin
              retPart.Add(ret[m-1]);
              if ((m mod lnMaxRecordCount)=0) or (m=ret.Count) then begin
                MassExportPart(OS, AUTH_TOKEN, logs, digitooRow, retPart, lcRegisterName,str);
                if Assigned(logs) then begin
                  iLog:=logs.Add('      '+IntToStr(lnLastRecord+1)+' - '+IntToStr(m)+': ');
                  logs[iLog]:=logs[iLog]+NxIIfStr(str='','OK',str);
                end;
                retpart.Clear;
                lnLastRecord:= m;
              end;
            end;
          end
          else begin
            MassExportPart(OS, AUTH_TOKEN, logs, digitooRow, ret, lcRegisterName,str);
            if Assigned(logs) then begin
              logs[iLog]:=logs[iLog]+NxIIfStr(str='','OK',str);
            end;
          end;
        end
        else begin
          if Assigned(logs) then begin
            logs[iLog]:=logs[iLog]+' žádná data k exportování';
          end;
        end;
      end;
    end;
  finally
    digitoo.Free;
    digitooRow.Free;
    ret.Free;
    obj.Free;
    retpart.Free;
    laNames.Free;
    laValues.Free;
    lmContext.Free;
  end;
end;

function MassExportPart(OS:TNxCustomObjectSpace; AUTH_TOKEN: string; logs: TStrings=nil; digitooRow,ret:TStringList; pcRegisterName: string; var pcResult: string):Boolean;
var
  Queue_ID, Typ, url, headers, SQL, str: String;
  reg: TJSONSuperObject;
  registers: TJSONSuperObjectArray;
  stream: TMemoryStream;
begin
  Result:=true;
  pcResult:= '';
  Typ:='';
  Queue_ID:='';
//  AUTH_TOKEN:='';
  if not(Assigned(logs)) then logs:=GetProgressMemoLines(TForm(GlobParams.ParamAsObject('SOAPProgress',nil)));

  reg:=TJSONSuperObject.Create;
  stream:= TMemoryStream.Create;
  try
    Queue_ID:=digitooRow[0];
    Typ:=digitooRow[1];
    //AUTH_TOKEN:=trim(digitooRow[2]);

    if (AUTH_TOKEN='') then begin
      continue;
    end;

    if Queue_ID<>'' then Queue_ID:= GetQueue_ID(OS, AUTH_TOKEN, Queue_ID);

    reg.O['registers']:=reg.CreateJSONArray;
    registers:=reg.A('registers');

    {* Nove se posila: *}

    AppendRegisterType(pcRegisterName,ret, registers);

    {=Nove se posila=}

    url:=URL_UPLOAD_REGISTERS;
    reg.S['queue_id']:= Queue_ID;
    reg.S['method']:= 'replace';

    reg.SaveToStream(stream);
    headers:='Authorization: Bearer '+AUTH_TOKEN;
    headers:= headers+#13#10+cAgentHeader+cScriptVersion;

    {
    try
      stream.SaveToFile('digitoo_export.txt');
    except
      if Assigned(logs) then iLog:=logs.Add('Logování exportu selhalo.');
    end;
    }

    str:=HTTPReadOLE(url,stream,true,headers,'');

    if str<>'' then begin
      Result:=false;
      pcResult:= str;
    end;
  finally
    reg.Free;
    stream.Free;
  end;
end;

// spusteni ulohy, pripadne i pres napl. ulohu
// action = downloaddocs/massexport
// ForcedType = 1 - primo, 2 - pres ulohu (pokud existuje)
procedure RunTask(lmSite:TSiteForm;action:string;ForcedType:integer=0;RunType:integer=-1);
var
  OS: TNxCustomObjectSpace;
  prog: TForm;
  cap, task, ID: string;
  list: TStringList;
  logs: TStrings;
  loItem, loDoc, loSRow, loDRow: TNxCustomBusinessObject;
  loSRows, loDRows: TNxCustomBusinessMonikerCollection;
  r: integer;

  procedure CopyRowNotEmpty(FldName:string);
  begin
    if NxIsEmptyOID(loSRow.GetFieldValueAsString(FldName)) then exit;
    loDRow.SetFieldValueAsString(FldName,loSRow.GetFieldValueAsString(FldName));
  end;

begin
  OS:=lmSite.CompanyObjectSpace;
  // overeni
  action:=LowerCase(trim(action));
  case action of
    'downloaddocs':begin cap:='Stažení dokladů';task:='DigiTooFP';end;
    'massexport':begin cap:='Export číselníků';task:='DigiTooRolls';end;
    else RaiseException('Neznámá akce "'+action+'"');
  end;

  // ma se spoustet napl. uloha?
  if ForcedType<>1 then begin
    list:=TStringList.Create;
    try
      // dohledat ulohu, zda vubec existuje
      OS.SQLSelect('SELECT ID FROM AutoServerScheduler WHERE IsActive=''A'' AND UPPER(Code)='+QuotedStr(AnsiUpperCase(task)),list);
      if list.Count=0 then ForcedType:=1
      else ID:=list[0];

      // zjisteni typu dle U_RunByAutoserver
      if ForcedType<=0 then begin
        OS.SQLSelect('SELECT 1'
          +#13' FROM UserFieldDefs UFD'
          +#13'   JOIN UserFieldDefs2 UFD2 ON UFD2.Parent_ID=UFD.ID AND UFD2.FieldName=''RunByAutoserver'''
          +#13'   JOIN DefRollData A ON A.CLSID=UFD.CLSID AND A.Hidden=''N'''
          +#13'   JOIN UserData UD ON UD.CLSID=A.CLSID AND UD.ID=A.ID AND UD.FieldCode=UFD2.FieldCode'
          +#13' WHERE UFD.CLSID='+QuotedStr(DIGITOO_CLSID)+' AND UD.StringFieldValue=''A'''
          ,list);
        ForcedType:=NxIIfInt(list.Count=0,1,2);
      end;

      // pres autoserver
      if ForcedType=2 then begin
        // jiz je ve fronte/bezi?
        OS.SQLSelect('SELECT CASE WHEN L.ID IS NULL THEN 0 ELSE 1 END AS IsRunning'
          +#13' FROM AutoServerQueue Q'
          +#13'   LEFT JOIN AutoServerTaskLogs L ON L.QueueItem_ID=Q.ID'
          +#13' WHERE Q.SchedulerItem_ID='+QuotedStr(ID)
          ,list);
        if list.Count>0 then begin
          ShowMessage('Naplánovaná úloha '+NxIIfStr(list[0]='0','je již ve frontě','již běží'),lmSite);
          exit;
        end;

        loDoc:=OS.CreateObject(Class_AutoServerSchedulerItem);
        loItem:=OS.CreateObject(Class_AutoServerQueueItem);
        try
          loDoc.Load(ID,nil);
          //CFxAutoServerScheduleWiz.Schedule(lmSite.SiteContext,nil,loDoc);
          loItem.New;
          loItem.Prefill;
          loItem.SetFieldValueAsString('SchedulerItem_ID',ID);
          loItem.SetFieldValueAsString('TaskCLSID',loDoc.GetFieldValueAsString('TaskCLSID'));
          loItem.SetFieldValueAsString('TaskParameters',loDoc.GetFieldValueAsString('TaskParameters'));
          loItem.SetFieldValueAsString('Description','Skript');

          loSRows:=loDoc.GetLoadedCollectionMonikerForFieldCode(loDoc.GetFieldCode('Recipients'));
          loDRows:=loItem.GetLoadedCollectionMonikerForFieldCode(loItem.GetFieldCode('Recipients'));
          if loDRows.Count=0 then begin // ABRA bohuzel nezkopiruje
            for r:=0 to loSRows.Count-1 do begin
              loSRow:=loSRows.BusinessObject[r];
              if (osMarkForDelete in loSRow.State) or (osDeleted in loSRow.State) or (osInvalid in loSRow.State) then continue;
              loDRow:=loDRows.AddNewObject;
              loDRow.Prefill;
              loDRow.SetFieldValueAsInteger('RecipientType',loSRow.GetFieldValueAsInteger('RecipientType'));
              CopyRowNotEmpty('SecurityUser_ID');
              CopyRowNotEmpty('SecurityRole_ID');
              CopyRowNotEmpty('SecurityGroup_ID');
              if trim(loSRow.GetFieldValueAsString('Email'))<>'' then loDRow.SetFieldValueAsString('Email',loSRow.GetFieldValueAsString('Email'));
              loDRow.SetFieldValueAsInteger('SentKind',loSRow.GetFieldValueAsInteger('SentKind'));
            end;
          end;

          loItem.Save;
        finally
          loItem.Free;
          loDoc.Free;
        end;
        ShowMessage('Naplánovaná úloha zařazena do fronty',lmSite);

        exit;
      end;
    finally
      ForcedType:=0;
      list.Free;
    end;
  end;

  // spusteni naprimo
  prog:=ShowProgress(cap+' (ver.'+cScriptVersion+')',0,1,'',true,true,false,0);
  GlobParams.GetOrCreateParam(dtObject,'SOAPProgress').AsObject:=prog;
  try
    logs:=GetProgressMemoLines(prog);
    case action of
      'downloaddocs':DownloadDocs(OS,logs,RunType);
      'massexport':MassExport(OS,logs);
    end;
    SetProgress(prog,0,0,'');
    StopProgress(prog);
  finally
    GlobParams.DeleteByName('SOAPProgress');
    ForcedType:=0;
    prog.Free;
  end;
end;

function GenerujDRC(Self: TNxCustomBusinessObject; pcDRCDocQueue_ID, pcDRCVATRate_ID, pcDRCVATIndex_ID: string): string;
var
  lcResult: string;
  loDRC, loDRCRow, loFPRow: TNxCustomBusinessObject;
  lmDRCRows, lmFPRows: TNxCustomBusinessMonikerCollection;
  i: integer;
begin
  Result:= '';
  lcResult:= '';
  loDRC:= Self.ObjectSpace.CreateObject(Class_ReverseChargeDeclaration);
  try
    if NxIsEmptyOID(pcDRCVATRate_ID) then begin
      lcResult:= 'V nastavení Digitoo není vyplněna DPH sazba pro doklad reverse charge.';
      exit;
    end;
    loDRC.New;
    loDRC.Prefill;
    loDRC.SetFieldValueAsString('SDocument_ID', Self.OID);
    loDRC.SetFieldValueAsString('SDocumentType', '04');
    if not NxIsEmptyOID(pcDRCDocQueue_ID) then loDRC.SetFieldValueAsString('DocQueue_ID', pcDRCDocQueue_ID);
    loDRC.SetFieldValueAsString('Firm_ID', Self.GetFieldValueAsString('Firm_ID'));
    loDRC.SetFieldValueAsString('VATCountry_ID', Self.GetFieldValueAsString('VATCountry_ID'));
    loDRC.SetFieldValueAsDateTime('DocDate$DATE', Self.GetFieldValueAsDateTime('DocDate$DATE'));
    loDRC.SetFieldValueAsString('Period_ID', GetPeriod_ID(Self.ObjectSpace, loDRC.GetFieldValueAsDateTime('DocDate$DATE')));
    loDRC.SetFieldValueAsDateTime('AccDate$DATE', Self.GetFieldValueAsDateTime('AccDate$DATE'));
    loDRC.SetFieldValueAsDateTime('VATDate$DATE', Self.GetFieldValueAsDateTime('VATDate$DATE'));
    loDRC.SetFieldValueAsDateTime('VATDeductionDate$DATE', Self.GetFieldValueAsDateTime('VATDate$DATE'));
    loDRC.SetFieldValueAsString('InvoiceLocalRefCurrency_ID', Self.GetFieldValueAsString('LocalRefCurrency_ID'));
    loDRC.SetFieldValueAsString('InvoiceRefCurrency_ID', Self.GetFieldValueAsString('RefCurrency_ID'));
    loDRC.SetFieldValueAsFloat('InvoiceCurrRate', Self.GetFieldValueAsFloat('CurrRate'));
    loDRC.SetFieldValueAsFloat('InvoiceRefCurrRate', Self.GetFieldValueAsFloat('RefCurrRate'));

    lmDRCRows:= loDRC.GetLoadedCollectionMonikerForFieldCode(loDRC.GetFieldCode('Rows'));
    lmFPRows:= Self.GetLoadedCollectionMonikerForFieldCode(Self.GetfieldCode('Rows'));
    for i:=0 to lmFPRows.Count-1 do begin
      loFPRow:= lmFPRows.BusinessObject[i];
      if loFPRow.GetFieldValueAsFloat('TAmountWithoutVAT')=0 then continue;
      if (loFPRow.GetFieldValueAsFloat('VATRate')<>0) and (Self.GetFieldValueAsInteger('TradeType')<>1) then continue;
      if (Self.GetFieldValueAsInteger('TradeType')=1) and (loFPRow.GetFieldValueAsInteger('VATMode')=0) then continue;
      loDRCRow:= lmDRCRows.AddNewObject;
      loDRCRow.Prefill;
      if (Self.GetFieldValueAsInteger('TradeType')=1) and not NxIsEmptyOID(loFPRow.GetFieldValueAsString('DRCArticle_ID.X_DRCVatRate_ID')) then begin
        loDRCRow.SetFieldValueAsString('VATRate_ID', loFPRow.GetFieldValueAsString('DRCArticle_ID.X_DRCVatRate_ID'));
        if NxIsEmptyOID(loDRCRow.GetFieldValueAsString('VATIndex_ID')) and not NxIsEmptyOID(pcDRCVATIndex_ID) then loDRCRow.SetFieldValueAsString('VATIndex_ID', pcDRCVATIndex_ID);
        if not NxIsEmptyOID(loFPRow.GetFieldValueAsString('DRCArticle_ID')) then loDRCRow.SetFieldValueAsString('DRCArticle_ID', loFPRow.GetFieldValueAsString('DRCArticle_ID'));
      end
      else begin
        loDRCRow.SetFieldValueAsString('VATRate_ID', pcDRCVATRate_ID);
        if not NxIsEmptyOID(pcDRCVATIndex_ID) then loDRCRow.SetFieldValueAsString('VATIndex_ID', pcDRCVATIndex_ID);
      end;
      loDRCRow.SetFieldValueAsFloat('SourceAmount', loFPRow.GetFieldValueAsFloat('TAmountWithoutVAT'));
      loDRCRow.SetFieldValueAsString('Text', loFPRow.GetFieldValueAsString('Text'));
      loDRCRow.SetFieldValueAsString('Division_ID', loFPRow.GetFieldValueAsString('Division_ID'));
      loDRCRow.SetFieldValueAsString('BusOrder_ID', loFPRow.GetFieldValueAsString('BusOrder_ID'));
      loDRCRow.SetFieldValueAsString('BusProject_ID', loFPRow.GetFieldValueAsString('BusProject_ID'));
      loDRCRow.SetFieldValueAsString('BusTransaction_ID', loFPRow.GetFieldValueAsString('BusTransaction_ID'));
    end;

    try
      loDRC.Save;
    except
      lcResult:= ExceptionMessage;
    end;
  finally
    Result:= lcResult;
    loDRC.Free;
  end;
end;

procedure GenerujZadostPP(Self: TNxCustomBusinessObject; pcPDocumentType: string; pfCastkaKUhrade: Double; Logs: TStrings; pbZkracenyLog: boolean);
var
  lcResult, lcBankAccount_ID: string;
  loPP, loRow: TNxCustomBusinessObject;
  lmRows: TNxCustomBusinessMonikerCollection;
  lmContext: TNxContext;
begin
  lcResult:= '';
  lcBankAccount_ID:= Self.GetFieldValueAsString('Currency_ID.X_BankAccount_ID');
  if NxIsEmptyOID(lcBankAccount_ID) then begin
    lmContext:= NxCreateContext_1(Self);
    try
      lcBankAccount_ID:= lmContext.GetCompanyCache.GlobData.GetFieldValueAsString('BankAccount_ID');
      if not NxIsEmptyOID(lcBankAccount_ID) then if not pbZkracenyLog then logs.Add('Měna '+Self.GetFieldValueAsString('Currency_ID.Code')+' nemá vyplněn bankovní účet. Použil se výchozí bank.účet z firemních údajů.');
    finally
      lmContext.Free;
    end;
  end;
  if NxIsEmptyOID(lcBankAccount_ID) then begin
    logs.Add('Chyba při vytváření žádosti platebního příkazu: Měna '+Self.GetFieldValueAsString('Currency_ID.Code')+' nemá vyplněn bankovní účet a ani ve firemních údajích není vyplněn výchozí bank.účet.');
    exit;
  end;
  loPP:= Self.ObjectSpace.CreateObject(Class_PaymentOrderRow);
  try
    loPP.New;
    loPP.Prefill;
    loPP.SetFieldValueAsString('BankAccount_ID', lcBankAccount_ID);
    loPP.SetFieldValueAsString('Firm_ID', Self.GetFieldValueAsString('Firm_ID'));
    loPP.SetFieldValueAsString('VarSymbol', Self.GetFieldValueAsString('VarSymbol'));
    loPP.SetFieldValueAsString('TargetBankAccount', Self.GetFieldValueAsString('FirmBankAccount_ID.BankAccount'));
    loPP.SetFieldValueAsString('TargetBankCountry_ID', Self.GetFieldValueAsString('FirmBankAccount_ID.BankCountry_ID'));
    loPP.SetFieldValueAsString('SpecSymbol', Self.GetFieldValueAsString('FirmBankAccount_ID.SpecSymbol'));
    loPP.SetFieldValueAsString('SwiftCode', Self.GetFieldValueAsString('FirmBankAccount_ID.SwiftCode'));
    loPP.SetFieldValueAsDateTime('DueDate$DATE', Self.GetFieldValueAsDateTime('DueDate$DATE'));
    loPP.SetFieldValueAsString('Currency_ID', Self.GetFieldValueAsString('Currency_ID'));
    //loPP.SetFieldValueAsFloat('Amount', Self.GetFieldValueAsFloat('Amount'));
    loPP.SetFieldValueAsFloat('Amount', pfCastkaKUhrade);
    lmRows:= loPP.GetLoadedCollectionMonikerForFieldCode(loPP.GetFieldCode('PaymentOrderDocuments'));
    loRow:= lmRows.AddNewObject;
    loRow.Prefill;
    loRow.SetFieldValueAsString('PDocumentType', pcPDocumentType);
    loRow.SetFieldValueAsString('PDocument_ID', Self.OID);
    //loRow.SetFieldValueAsFloat('Amount', Self.GetFieldValueAsFloat('Amount'));
    loRow.SetFieldValueAsFloat('Amount', pfCastkaKUhrade);
    try
      loPP.Save;
    except
      lcResult:= ExceptionMessage;
    end;
  finally
    if lcResult<>'' then lcResult:= 'Chyba při vytváření žádosti platebního příkazu: '+lcResult
                    else lcResult:= 'Žádost platebního příkazu vygenerována.';
    logs.Add(lcResult);
    loPP.Free;
  end;
end;

procedure OpenInDigitoo(lmSite:TSiteForm);
var
  loObj: TNxCustomBusinessObject;
  lcDigitooDocumentURL: string;
begin
  if not(Assigned(lmSite)) then exit;
  loObj:= TDynSiteForm(lmSite).CurrentObject;
  if not Assigned(loObj) then exit;
  lcDigitooDocumentURL:= loObj.GetFieldValueAsString('X_DigitooDocumentURL');
  if lcDigitooDocumentURL<>''
    then ShellAPI.OpenFile(lcDigitooDocumentURL)
    else ShowMessage('Na faktuře není vyplněno URL do Digitoo.');
end;

function PairPR(OS: TNxCustomObjectSpace; paFPRowsData: TStringList; pcFP_ID, pcFirm_ID, pcCurrency_ID, pcPRDocQueues: string; pnPRDaysBack, pnPRSearchType: integer): string;
var
  i, j: integer;
  lcSQL, lcStoreCard_ID, lcCode, lcName, lcCodeOrig, lcNameOrig, lcQUnit, lcFPRow_ID, lcPRRow_ID, lcPR_ID, lcResult, lcResultTemp: string;
  laPom: TStringList;
  lfQuantity, lfAmount, lfLocalAmount: extended;
  loPR, loPRRow, loSC: TNxCustomBusinessObject;
  lmPRRows: TNxCustomBusinessMonikerCollection;
  lbError: boolean;
begin
  Result:= '';
  lcResult:= '';
  lbError:= False;
  if paFPRowsData.Count=0 then begin
    lcResult:= lcResult+NxIifStr(lcResult<>'',#13#10,'')+'Žádné řádky k párování.';
    exit;
  end;
  laPom:= TStringList.Create;
  laPom.Delimiter:= ';';
  loSC:= OS.CreateObject(Class_StoreCard);
  try
    try
      ParseCSV(pcPRDocQueues,';',laPom);
      pcPRDocQueues:= '';
      for i:=0 to laPom.Count-1 do begin
        pcPRDocQueues:= pcPRDocQueues+NxIifStr(pcPRDocQueues<>'',',','')+QuotedStr(laPom[i]);
      end;
      for i:=0 to paFPRowsData.Count-1 do begin
        ParseCSV(paFPRowsData[i],';',laPom);
        lcFPRow_ID:= laPom[0];
        lcCodeOrig:= laPom[1];
        lcNameOrig:= laPom[2];
        lfQuantity:= GetFloatDef(laPom[3]);
        lcQUnit:= laPom[4];
        lfAmount:= GetFloatDef(laPom[5]);
        lfLocalAmount:= GetFloatDef(laPom[6]);
        lcCode:= StringReplace(lcCodeOrig, ' ','',[rfReplaceAll,rfIgnoreCase]);
        lcCode:= StringReplace(lcCode, Chr(9),'',[rfReplaceAll,rfIgnoreCase]);
        lcCode:= StringReplace(lcCode, Chr(13),'',[rfReplaceAll,rfIgnoreCase]);
        lcCode:= StringReplace(lcCode, Chr(10),'',[rfReplaceAll,rfIgnoreCase]);
        lcName:= StringReplace(lcNameOrig, ' ','',[rfReplaceAll,rfIgnoreCase]);
        lcName:= StringReplace(lcName, Chr(9),'',[rfReplaceAll,rfIgnoreCase]);
        lcName:= StringReplace(lcName, Chr(13),'',[rfReplaceAll,rfIgnoreCase]);
        lcName:= StringReplace(lcName, Chr(10),'',[rfReplaceAll,rfIgnoreCase]);

        if NxIsEmptyOID(lcFPRow_ID) then continue;
        if lfQuantity<0.00001 then continue;
        if (lcCode='') and (lcName='') then continue;
        laPom.Clear;
        if ((pnPRSearchType=0) and (lcCode<>''))
            or ((pnPRSearchType=1) and ((lcCode<>'') or (lcName<>'')))
            or ((pnPRSearchType=2) and (lcName<>'')) then begin
          lcSQL:= 'Select distinct SC.ID'
              +#13' from Suppliers S'
              +#13' join StoreCards SC on SC.ID=S.StoreCard_ID'
              +#13' join Firms F on F.ID=S.Firm_ID'
              +#13' left join Firms Fx on Fx.ID=F.Firm_ID'
              +#13' where coalesce(Fx.ID,F.ID)='+QuotedStr(pcFirm_ID)
              +#13'       and SC.Hidden=''N'''
              +NxIifStr((pnPRSearchType in [0,1]) and (lcCode<>''),#13' and (Replace(Replace(Replace(Replace(S.ExternalNumber,'+QuotedStr(Chr(10))+',''''),'+QuotedStr(Chr(13))+',''''),'+QuotedStr(Chr(9))+',''''),'+QuotedStr(' ')+','''')='+QuotedStr(lcCode)+')'
                                                                       +#13' or (Replace(Replace(Replace(Replace(S.EAN,'+QuotedStr(Chr(10))+',''''),'+QuotedStr(Chr(13))+',''''),'+QuotedStr(Chr(9))+',''''),'+QuotedStr(' ')+','''')='+QuotedStr(lcCode)+')','')
              +NxIifStr((pnPRSearchType in [1,2]) and (lcName<>''),#13' and Replace(Replace(Replace(Replace(S.Name,'+QuotedStr(Chr(10))+',''''),'+QuotedStr(Chr(13))+',''''),'+QuotedStr(Chr(9))+',''''),'+QuotedStr(' ')+','''')='+QuotedStr(lcName),'');
          OS.SQLSelect(lcSQL, laPom);
          if laPom.Count=0 then begin
            lcSQL:= 'Select distinct SC.ID'
                +#13' from StoreCards SC'
                +#13' where SC.Hidden=''N'''
                +NxIifStr((pnPRSearchType in [0,1]) and (lcCode<>''),#13' and (Replace(Replace(Replace(Replace(SC.'+NxIifStr(loSC.HasField('X_SupplierCodes'),'X_SupplierCodes','Code')+','+QuotedStr(Chr(10))+',''''),'+QuotedStr(Chr(13))+',''''),'+QuotedStr(Chr(9))+',''''),'+QuotedStr(' ')+','''')'+NxIifStr(loSC.HasField('X_SupplierCodes'),' like '+QuotedStr('%'+lcCode+'%'),'='+QuotedStr(lcCode))+')'
                                                                         +#13' or (Replace(Replace(Replace(Replace(SC.EAN,'+QuotedStr(Chr(10))+',''''),'+QuotedStr(Chr(13))+',''''),'+QuotedStr(Chr(9))+',''''),'+QuotedStr(' ')+','''')='+QuotedStr(lcCode)+')','')
                +NxIifStr((pnPRSearchType in [1,2]) and (lcName<>''),#13' and Replace(Replace(Replace(Replace(SC.Name,'+QuotedStr(Chr(10))+',''''),'+QuotedStr(Chr(13))+',''''),'+QuotedStr(Chr(9))+',''''),'+QuotedStr(' ')+','''')='+QuotedStr(lcName),'');
            OS.SQLSelect(lcSQL, laPom);
          end;
        end;
        if laPom.Count=1 then begin
          lcStoreCard_ID:= laPom[0];
          lcSQL:= 'Select SU.UnitRate'
              +#13' from StoreUnits SU'
              +#13' join StoreCards SC on SC.ID=SU.Parent_ID'
              +#13' where SC.ID='+QuotedStr(lcStoreCard_ID)
             +#13+NxIifStr(lcQUnit='',' and SU.Code=SC.MainUnitCode',' and Upper(SU.Code)=Upper('+QuotedStr(lcQUnit)+')');
          OS.SQLSelect(lcSQL, laPom);
          if laPom.Count=0 then begin
            lbError:= True;
            lcResult:= lcResult+NxIifStr(lcResult<>'',#13#10,'')+'Dohledaná skladová karta nemá evidovánu jednotku "'+lcQUnit+'" (kód="'+lcCodeOrig+'",název="'+lcNameOrig+'",množství="'+GetSQLFloat(lfQuantity)+'",jednotka="'+lcQUnit+'").';
            continue;
          end;
          lcSQL:= 'Select distinct SD.ID, SD2.ID'
              +#13' from StoreDocuments2 SD2'
              +#13' join StoreDocuments SD on SD.ID=SD2.Parent_ID'
              +#13' join Firms F on F.ID=SD.Firm_ID'
              +#13' left join Firms Fx on Fx.ID=F.Firm_ID'
              +#13' where SD.DocumentType=''20'''
              +#13'       and SD.Currency_ID='+QuotedStr(pcCurrency_ID)
              +#13'       and coalesce(Fx.ID,F.ID)='+QuotedStr(pcFirm_ID)
              +#13'       and coalesce('+NxIifStr(CFxNxRuntime.NxGetDatabaseCode='MSSQL','LTrim(RTrim(SD2.X_ReceivedInvoiceRow_ID))','Trim(SD2.X_ReceivedInvoiceRow_ID)')+',''0'') in ('
                          +NxIifStr(NxIsOracle,'',''''',')+'''0'',''0000000000'')'
              +#13'       and SD2.StoreCard_ID='+QuotedStr(lcStoreCard_ID)
              +#13'       and SD.DocDate$DATE>='+IntToStr(Trunc(Date-pnPRDaysBack))
              +#13'       and Abs(SD2.Quantity-'+GetSQLFloat(lfQuantity*GetFloatDef(laPom[0]))+')<0.00001'
              +#13'       and SD2.ClosingOrder=0'
              +NxIifStr(pcPRDocQueues<>'',' and SD.DocQueue_ID in ('+pcPRDocQueues+')','')
              +#13' order by SD.DocDate$DATE';
          OS.SQLSelect(lcSQL, laPom);
          if laPom.Count=0 then begin
            lcSQL:= 'Select distinct SD.ID, SD2.ID'
                +#13' from StoreDocuments2 SD2'
                +#13' join StoreDocuments SD on SD.ID=SD2.Parent_ID'
                +#13' join Firms F on F.ID=SD.Firm_ID'
                +#13' left join Firms Fx on Fx.ID=F.Firm_ID'
                +#13' where SD.DocumentType=''20'''
                +#13'       and SD.Currency_ID='+QuotedStr(pcCurrency_ID)
                +#13'       and coalesce(Fx.ID,F.ID)='+QuotedStr(pcFirm_ID)
                +#13'       and coalesce('+NxIifStr(CFxNxRuntime.NxGetDatabaseCode='MSSQL','LTrim(RTrim(SD2.X_ReceivedInvoiceRow_ID))','Trim(SD2.X_ReceivedInvoiceRow_ID)')+',''0'') in ('
                            +NxIifStr(NxIsOracle,'',''''',')+'''0'',''0000000000'')'
                +#13'       and SD2.StoreCard_ID='+QuotedStr(lcStoreCard_ID)
                +#13'       and SD.DocDate$DATE>='+IntToStr(Trunc(Date-pnPRDaysBack))
                +#13'       and Abs(SD2.TotalPrice-'+GetSQLFloat(lfAmount)+')<0.00001'
                +#13'       and SD2.ClosingOrder=0'
                +NxIifStr(pcPRDocQueues<>'',' and SD.DocQueue_ID in ('+pcPRDocQueues+')','')
                +#13' order by SD.DocDate$DATE';
            OS.SQLSelect(lcSQL, laPom);
          end;
          if laPom.Count=0 then begin
            lbError:= True;
            lcResult:= lcResult+NxIifStr(lcResult<>'',#13#10,'')+'Nenalezena příjemka (kód="'+lcCodeOrig+'",název="'+lcNameOrig+'",množství="'+GetSQLFloat(lfQuantity)+'",jednotka="'+lcQUnit+'").';
            continue;
          end;
          laPom.DelimitedText:= laPom[0];
          lcPR_ID:= laPom[0];
          lcPRRow_ID:= laPom[1];
          loPR:= OS.CreateObject(Class_ReceiptCard);
          try
            loPR.Load(lcPR_ID, nil);
            lmPRRows:= loPR.GetLoadedCollectionMonikerForFieldCode(loPR.GetFieldCode('Rows'));
            for j:=0 to lmPRRows.Count-1 do begin
              loPRRow:= lmPRRows.BusinessObject[j];
              if loPRRow.OID=lcPRRow_ID then begin
                loPRRow.SetFieldValueAsString('X_ReceivedInvoiceRow_ID', lcFPRow_ID);
                if abs(loPRRow.GetFieldValueAsFloat('UnitPrice'))>0.00001 then loPRRow.SetFieldValueAsFloat('UnitPrice', 0);
                if abs(loPRRow.GetFieldValueAsFloat('TotalPrice')-lfAmount)>0.00001 then loPRRow.SetFieldValueAsFloat('TotalPrice', lfAmount);
                if not loPRRow.GetFieldValueAsBoolean('CompletePrices') then loPRRow.SetFieldValueAsBoolean('CompletePrices', True);
                break;
              end;
            end;
            try
              if loPR.NeedSave then loPR.Save;
              lcResult:= lcResult+NxIifStr(lcResult<>'',#13#10,'')+'Napárováno na příjemku '+loPR.DisplayName+' (kód="'+lcCodeOrig+'",název="'+lcNameOrig+'",množství="'+GetSQLFloat(lfQuantity)+'",jednotka="'+lcQUnit+'").';
              lcResultTemp:= SetRelation(OS, 1011, pcFP_ID, lcPR_ID, True, lfLocalAmount, True);
              if lcResultTemp<>'' then lcResult:= lcResult+NxIifStr(lcResult<>'',#13#10,'')+'Chyba při zápise vazby na příjemku '+loPR.DisplayName+' (kód="'+lcCodeOrig+'",název="'+lcNameOrig+'",množství="'+GetSQLFloat(lfQuantity)+'",jednotka="'+lcQUnit+'"): '+lcResultTemp;
              if pcCurrency_ID<>'0000CZK000' then begin
                lcResultTemp:= SetRelation(OS, 1111, pcFP_ID, lcPR_ID, True, lfAmount, True);
                if lcResultTemp<>'' then lcResult:= lcResult+NxIifStr(lcResult<>'',#13#10,'')+'Chyba při zápise vazby v cizí měně na příjemku '+loPR.DisplayName+' (kód="'+lcCodeOrig+'",název="'+lcNameOrig+'",množství="'+GetSQLFloat(lfQuantity)+'",jednotka="'+lcQUnit+'"): '+lcResultTemp;
              end;
            except
              lbError:= True;
              lcResult:= lcResult+NxIifStr(lcResult<>'',#13#10,'')+'Chyba při ukládání příjemky '+loPR.DisplayName+' (kód="'+lcCodeOrig+'",název="'+lcNameOrig+'",množství="'+GetSQLFloat(lfQuantity)+'",jednotka="'+lcQUnit+'"): '+ExceptionMessage;
            end;
          finally
            loPR.Free;
          end;
        end
        else begin
          lbError:= True;
          lcResult:= lcResult+NxIifStr(lcResult<>'',#13#10,'')+'Nenalezena právě jedna skladová karta (kód="'+lcCodeOrig+'",název="'+lcNameOrig+'",množství="'+GetSQLFloat(lfQuantity)+'",jednotka="'+lcQUnit+'").';
        end;
      end;
    except
      lbError:= True;
      lcResult:= lcResult+NxIifStr(lcResult<>'',#13#10,'')+'Neočekávaná chyba (kód="'+lcCodeOrig+'",název="'+lcNameOrig+'",množství="'+GetSQLFloat(lfQuantity)+'",jednotka="'+lcQUnit+'"): '+ExceptionMessage;
    end;
    if lbError then begin
      lcSQL:= 'Update ReceivedInvoices set Description='+GetDBSubStr(QuotedStr('<!PR>')+'||Description','1','50')+' where ID='+QuotedStr(pcFP_ID);
      try
        OS.SQLExecute(lcSQL);
      except
      end;
    end;
  finally
    loSC.Free;
    laPom.Free;
    Result:= lcResult;
  end;
end;

begin
end.