procedure GenerateIIfromOPV(OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
var
 mList, mLogs, mPrintList:TStringList;
 mSQL, mFVDocQueue_ID, mHorizontalSplitter, mTO:String;
 i:integer;
 mImportMan:TNxDocumentImportManager;
 mInputParams:TNxParameters;
 mParam:TNxParameter;
 mBO, mInvoiceBO, mTextBO:TNxCustomBusinessObject;
 mFileName, mSubject, mMailText, mInvoice_ID, mMena:string;
 //email do kopie Marek.zizka a tvůrce
 //faktury FV01
 //po faktuře změna procesního stavu na VO vyfakturováno
begin
  mFVDocQueue_ID:='H100000101';
  mList := TStringList.Create;
  mLogs := TStringList.Create;
  mHorizontalSplitter:=GetHorizontalSplitter(50);
  mLogs.Add(DateTimeToStr(Now)+'  začátek');
  mLogs.add(mHorizontalSplitter);
  mSQL:= 'SELECT RO.ID'#13#10 +
    'FROM ReceivedOrders RO'#13#10 +
    'WHERE RO.DocQueue_ID = ''7RQ0000101'''#13#10 +
    '  AND RO.PMState_ID = ''2080000101'''#13#10 +
    '  AND RO.Revided_ID IS NULL'#13#10 +
    '  AND RO.X_BoolForAutoInvoice=''A'''#13#10 +
    '  AND EXISTS ('#13#10 +
    '    SELECT 1'#13#10 +
    '    FROM StoreDocuments2 SD2'#13#10 +
    '    JOIN StoreDocuments SD ON SD.ID = SD2.Parent_ID'#13#10 +
    '    WHERE SD2.Provide_ID = RO.ID'#13#10 +
    '      AND SD.DocumentType = ''21'''#13#10 +
    '      AND SD.DocQueue_ID IN (''1100000101'', ''U200000101'')'#13#10 +
    '      AND SD.Finished = ''N'''#13#10 +
    '      AND SD.IsAvailableForDelivery = ''A'''#13#10 +
    '  )';
  try
    OS.sqlselect(mSQL, mList);
    if mList.Count > 0 then begin
      mBO:=OS.CreateObject(Class_ReceivedOrder);
      for i:=0 to mlist.Count-1 do begin
                      mBO.load(mList.Strings[i],nil);
                      mLogs.add('Objednávka '+mbo.DisplayName);
                      mTO:=mBO.GetFieldValueAsString('X_TargetEmail');
                      mInputParams := TNxParameters.Create;
                      mParam := mInputParams.GetOrCreateParam(dtString, 'DocQueue_ID');
                      mParam.AsString := mFVDocQueue_ID;
                      mParam := mInputParams.GetOrCreateParam(dtString, 'SelectedHeader');
                      mParam.AsString := mBO.OID;
                      mImportMan:=NxCreateDocumentImportManager(OS,Class_ReceivedOrder, Class_IssuedInvoice);
                      mImportMan.AddInputDocument(mBO.OID);
                      mImportMan.LoadParams(mInputParams);
                      mImportMan.Execute;
                      mImportMan.OutputDocument.SetFieldValueAsString('DocQueue_ID', mFVDocQueue_ID);
                      mImportMan.OutputDocument.SetFieldValueAsString('Firm_ID',mBO.GetFieldValueAsString('Firm_ID'));
                      mImportMan.OutputDocument.SetFieldValueAsString('FirmOffice_ID',mBO.GetFieldValueAsString('FirmOffice_ID'));
                      mImportMan.OutputDocument.SetFieldValueAsDateTime('VatDate$Date',Date);
                      mImportMan.OutputDocument.SetFieldValueAsString('CreatedBy_ID','AUTO000000');
                      mimportman.OutputDocument.save;
                      mLogs.add(mImportMan.OutputDocument.DisplayName);
                      mInvoice_ID:=mImportMan.OutputDocument.OID;
                      mTextBO:=OS.CreateObject('DCHDUXZ0S3RO1DVWDVB0PD51U0');
                      mTextBO.Load('70JB000101',nil);
                      mSubject:=mTextBO.GetFieldValueAsString('X_Subject');
                      mInvoiceBO:=Os.CreateObject(Class_IssuedInvoice);
                      mMailText:=mTextBO.GetFieldValueAsString('X_Note');
                      mPrintList:=TStringList.Create;
                      mPrintList.Add(mInvoiceBO.OID);
                      mFileName:=NxSearchReplace(mBO.DisplayName,'/','-',[srAll])+'.pdf';
                      mMena:= mBO.GetFieldValueAsString('Currency_ID.Symbol');
                      mMailText:= NxSearchReplace(mMailText, '#CISLOFAKTURY#',    mInvoiceBO.DisplayName,[srAll]);
                      mMailText:= NxSearchReplace(mMailText, '#VARSYMBOL#',       mInvoiceBO.GetFieldValueAsString('VarSymbol'), [srAll]);
                      mMailText:= NxSearchReplace(mMailText, '#DATUMVYSTAVENI#',  DateToStr(mInvoiceBO.GetFieldValueAsDateTime('DocDate$Date')), [srAll]);
                      mMailText:= NxSearchReplace(mMailText, '#DATUMSPLATNOSTI#', DateToStr(mInvoiceBO.GetFieldValueAsDateTime('DueDate$Date')), [srAll]);
                      mMailText:= NxSearchReplace(mMailText, '#CASTKA_MENA#',     NxFormatNumeric('0.00,', mInvoiceBO.GetFieldValueAsFloat('Amount')) + ' ' + mMena, [srAll]);
                      mMailText:= NxSearchReplace(mMailText, '#NEHRAZENACASTKA#', NxFormatNumeric('0.00,', mInvoiceBO.GetFieldValueAsFloat('Amount') - mInvoiceBO.GetFieldValueAsFloat('PaidAmount')) + ' ' + mMena,[srAll]);
                      CFxReportManager.PrintByIDs(NxCreateContext_1(mInvoiceBO),mPrintList,GetDynSource(OS,mtextbo.GetFieldValueAsString('X_Form_ID')), mtextbo.GetFieldValueAsString('X_Form_ID'),rtoFile,pekPDF,'D:\tmp',mFileName);
                      SendInternalMail(OS, mTO,'','marek.zizka@simonfm.cz',
                                       mSubject+' '+mInvoiceBO.DisplayName,mMailText,
                                       'D:\tmp'+'\'+ mFileName ,'',mInvoiceBO.GetFieldValueAsString('Firm_ID'),
                                       mInvoiceBO.GetLoadedCollectionMonikerForFieldCode(mbo.GetFieldCode('Rows')).BusinessObject[0].GetFieldValueAsString('Division_ID'),
                                       mInvoiceBO.GetLoadedCollectionMonikerForFieldCode(mbo.GetFieldCode('Rows')).BusinessObject[0].GetFieldValueAsString('BusTransaction_ID'), '2300000101', mInvoice_ID);
                      DeleteFile('D:\tmp'+mFileName);
        mLogs.add(mHorizontalSplitter);
      end;
      mbo.free;
    end;
  finally
   Success := True;
   LogInfoStr := ''+nxcrlf+mlogs.Text;
  end; 
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

function GetHorizontalSplitter(aLength: Integer): string;
var
  i: Integer;
begin
  Result := '';
  for i := 1 to aLength do
    Result := Result + '─';
end;

procedure SendInternalMail(AOS:TNxCustomObjectSpace; ATo:String; ACC:String; ABCC:String;
                           ASubject:String; ABody:String; AAtachement, AAtachement2:String; AFirm_ID:String; ADivision_ID:String; ABusTransaction_ID:String; aAccount_ID, aInvoice_ID:string);
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