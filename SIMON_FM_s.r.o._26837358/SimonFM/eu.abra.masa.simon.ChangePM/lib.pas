procedure SendDocuments(OS: TNxCustomObjectSpace;
  var Success: Boolean; var LogInfoStr: String);
begin
  {
   najít OP ve stavu STOBJ11 bez emailu z tohoto stavu a poslat  DZV FV pokud existuje text mmailu ze stavu objednávky
  }
  Success := True;
  LogInfoStr := '';
end;

procedure  FormalnePrijato(OS: TNxCustomObjectSpace;
  var Success: Boolean; var LogInfoStr: String);
var
 mList, mLogs,mPrintList:TStringList;
 i, mCount:integer;
 mBO:TNxCustomBusinessObject;
 mBody, mFileName2:string;
begin
   mList:=TStringList.create;
   mLogs:=TStringList.create;
   OS.SQLSelect(    'SELECT a.id FROM'#13#10 +
    '  ReceivedOrders A '#13#10 +
    '  '#13#10 +
    'WHERE (A.DocDate$DATE >= '+NxFloatToIBStr(date-5)+' ) '#13#10 +
    'AND (((A.PMSTATE_ID IN (''2000000101'')) )) '#13#10 +
    'AND (exists (SELECT 1 FROM USERDATA WHERE FIELDCODE=2000003 AND CLSID=''01CPMINJW3DL342X01C0CX3FCC'' AND ID = A.ID '#13#10 +
    'AND (STRINGFIELDVALUE IN (''5C92000101'',''IURB000101''))))  AND ((''N'' = ''A'') OR ((''N'' = ''N'') AND (A.Revided_ID IS NUL' +
    'L)) )',mList);
    if mlist.count>0 then begin
    for i:=0 to mList.count-1 do begin
      mBO:=Os.CreateObject(Class_ReceivedOrder);
      mBO.Load(mlist.strings[i],nil);
      mLogs.add('Objednávka: '+mBO.DisplayName);
      if mbo.GetFieldValueAsString('TransportationType_ID.Code') in ['O1','O2'] then
       mbo.SetFieldValueAsString('U_orderState_ID','70T5000101')
       else mbo.SetFieldValueAsString('U_orderState_ID','6C92000101');
      mLogs.Add('Cílový stav objednávky: '+mbo.GetFieldValueAsString('U_orderState_ID.code'));
      mBO.save;
      mCount:=OS.SQLSelectFirstAsInteger('Select count(id) from EmailsSent where X_receivedorderID='+QuotedStr(mBO.OID)+' and x_OrderState_ID='+QuotedStr(mBO.GetFieldValueAsString('U_OrderState_ID')),0);
      mLogs.Add('Počet mailů: '+IntToStr(mCount));
      if mCount=0 then begin
        mBody:=mBO.GetFieldValueAsString('U_OrderState_ID.X_Note');
        mBody:=NxSearchReplace(mBody,'#CISOBJ#',mBO.GetFieldValueAsString('ExternalNumber'),[srAll]);
        mPrintList:=TStringList.Create;
        mPrintList.Add(mBO.OID);
        mFileName2:=NxSearchReplace(mBO.DisplayName,'/','-',[srAll]);
        CFxReportManager.PrintByIDs(NxCreateContext(OS), mPrintList, '40V53DORW3DL342X01C0CX3FCC', '4VD0000101', rtoFile, pekPDF, NxGetTempDir, mFileName2 + '.pdf');
        SendInternalMail(OS,mBO.GetFieldValueAsString('FirmOffice_id.Address_id.Email'),
                           '','',
                           mBO.GetFieldValueAsString('ExternalNumber')+' '+mBO.GetFieldValueAsString('U_OrderState_ID.Name') ,
                           mBody,NxGetTempDir+'\'+ mFileName2 + '.pdf','', mBO.GetFieldValueAsString('Firm_ID'),
                           '1400000101','','1300000101',mBO.OID,mBO.GetFieldValueAsString('U_OrderState_ID'));
        mLogs.add('Email odeslán na: '+mBO.GetFieldValueAsString('FirmOffice_id.Address_id.Email'));
        DeleteFile(NxGetTempDir+'\'+ mFileName2 + '.pdf');
        mPrintList.free;
      end;
      mbo.Free;
    end;
  end;
  Success := True;
  LogInfoStr := ''+NxCrLf+mLogs.Text;
end;


procedure SendInternalMail(AOS:TNxCustomObjectSpace; ATo:String; ACC:String; ABCC:String;
                           ASubject:String; ABody:String; AAtachement,AAtachement2:String; AFirm_ID:String; ADivision_ID:String; ABusTransaction_ID:String; aAccount_ID, aOrder_ID, aOrderState_ID:string);
Var
  mMailBO,mUserXLink:TNxCustomBusinessObject;
  mMRecipients:TNxCustomBusinessMonikerCollection;
  mMailRecipient:TNxCustomBusinessObject;
begin
  if not(ato='') then begin
     mMailBO:=AOS.CreateObject('5C1HWDQDR3J4NAAYZRO5PWHLWK');
     mMailBO.New;
     mMailBO.Prefill;
     mMailBO.SetFieldValueAsString('EmailAccount_ID',aAccount_ID);
     mMailBO.SetFieldValueAsString('Subject',ASubject);
     mMailBO.SetFieldValueAsInteger('BodySavedAs',1);
     mMailbo.SetFieldValueAsInteger('SentState',1);
     mMailBO.SetFieldValueAsString('Body',ABody);
     mMailBO.SetFieldValueAsString('Firm_ID',AFirm_ID);
     mMailBO.SetFieldValueAsString('Division_ID',ADivision_ID);
     mMailBO.SetFieldValueAsString('BusTransaction_ID',ABusTransaction_ID);
     mMailBO.SetFieldValueAsString('X_ReceivedOrderID',aOrder_ID);
     mMailBO.SetFieldValueAsString('X_OrderState_ID',aOrderState_ID);
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
     mMailBO.free;

  end;
end;


procedure ZmenNaPrijato(OS: TNxCustomObjectSpace;
  var Success: Boolean; var LogInfoStr: String);
var
 mList, mLogs:TStringList;
 i:integer;
 mBO:TNxCustomBusinessObject;
 mPaid:Extended;
 mZLV_ID, mDZV_ID:string;
begin
  mList:=TStringList.create;
  mLogs:=TStringList.create;
  OS.SQLSelect('Select id from receivedorders where pmstate_id=''5010000101'' ',mList);
  if mlist.count>0 then begin
    for i:=0 to mList.count-1 do begin
      mBO:=Os.CreateObject(Class_ReceivedOrder);
      mBO.Load(mlist.strings[i],nil);
      //dohledat DZV
      mZLV_ID:=OS.SQLSelectFirstAsString('Select Distinct ID from issueddinvoices where receivedorder_id='+QuotedStr(mbo.OID),'');
      mDZV_ID:=OS.SQLSelectFirstAsString('Select pDocument_ID from IssuedDepositUsages where depositdocument_id='+QuotedStr(mZLV_ID),'');
      mLogs.add('Objednávka: '+mBO.DisplayName+'   DZV: '+mDZV_ID);
      if not(NxIsEmptyOID(mDZV_ID)) then begin
       mbo.PMChangeState('2000000101');
       mLogs.add('Měnil jsem stav');
       if not(mbo.GetFieldValueAsString('U_orderState_ID')='90F7000101') then
        mbo.SetFieldValueAsString('U_orderState_ID','90F7000101');
       mLogs.add('Stav objednávky je '+ mbo.GetFieldValueAsString('U_orderState_ID.code'));
      end else begin
       mLogs.add('Neměnil jsem stav');
      end;
      if mbo.NeedSave then mbo.save;
      mbo.Free;
    end;
  end;
  Success := True;
  LogInfoStr := ''+NxCrLf+mLogs.Text;
end;



begin
end.