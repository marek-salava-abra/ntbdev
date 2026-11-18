const
 cPrefix = 'P';
 cFTPlogin2='sftp://cemat:4f31o17gj0tk@edi.contitrade.com/ -hostkey="ssh-rsa 1024 F9e8nULg5rO/nGeTfyB2jNZ2cvkKSFSip43QeECQCVo';
 cFTPexec='C:\Program Files (x86)\WinSCP\winscp.com /console /script="%s" ';
 cEnviroment='/Live/';

procedure CheckFile(OS: TNxCustomObjectSpace; var ProcessContinue: Boolean; Directory: string; FileName: string);
var
 mXMLHead:TNxScriptingXMLWrapper;
 i,j:integer;
 mBO, mRowBO:TNxCustomBusinessObject;
 mRows:TNxCustomBusinessMonikerCollection;
 mStoreCard_ID, mFirmOffice_ID:string;
 mQuantity:Extended;
begin
  try
    mXMLHead:=TNxScriptingXMLWrapper.Create;
    mXMLHead.loadFromFile(Directory+'\'+FileName);
    mBO:=OS.CreateObject(Class_ReceivedOrder);
    mBO.new;
    mbo.Prefill;
    mBO.SetFieldValueAsString('DocQueue_ID','4R00000101');
    mBO.SetFieldValueAsString('Firm_ID',OS.SQLSelectFirstAsString('Select id from firms where hidden=''N'' and firm_ID is null and orgidentnumber=''41193598'' ',''));
    mFirmOffice_ID:=OS.SQLSelectFirstAsString('Select id from firmoffices where code='+QuotedStr(mXMLHead.getElementAsString('OrderA2.BuyerParty.PartyID'))+
                                              ' and parent_id='+QuotedStr(mBO.GetFieldValueAsString('Firm_ID')),'');
    if not(NxIsEmptyOID(mFirmOffice_ID)) then mBO.SetFieldValueAsString('FirmOffice_ID',mFirmOffice_ID);
    mbo.SetFieldValueAsString('PaymentType_ID','1000000101');
    mbo.SetFieldValueAsString('TransportationType_ID','1200000101');
    mbo.SetFieldValueAsString('ExternalNumber',mXMLHead.getElementAsString('OrderA2.CustomerReference.DocumentID'));
    mbo.SetFieldValueAsString('X_BranchID',mXMLHead.getElementAsString('OrderA2.BuyerParty.PartyID'));
    mbo.SetFieldValueAsString('X_BranchName',mXMLHead.getElementAsString('OrderA2.BuyerParty.Contact.Name'));
    mRows:=mBO.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('Rows'));
    for i:=0 to mXMLHead.getElementsCountInArray('OrderA2.OrderLine')-1 do begin
      mStoreCard_ID:=GetSCID(OS, mXMLHead.getElementAsString('OrderA2.OrderLine['+IntToStr(i)+'].OrderedArticle.ArticleIdentification.EANUCCArticleID'));
      mQuantity:= NxIBStrToFloat(mXMLHead.getElementAsString('OrderA2.OrderLine['+IntToStr(i)+'].OrderedArticle.RequestedQuantity.QuantityValue'));
      if (mQuantity>0) and not(NxIsEmptyOID(mStoreCard_ID)) then begin
       mRowBO:=mRows.AddNewObject;
       mRowBO.prefill;
       mrowbo.SetFieldValueAsInteger('RowType',3);
       mRowBO.SetFieldValueAsString('Store_ID','3ZA0000101');
       mRowBO.SetFieldValueAsString('StoreCard_ID',mStoreCard_ID);
       mRowBO.SetFieldValueAsFloat('Quantity',mQuantity);
       mRowBO.SetFieldValueAsString('Division_ID','1000000101');
       mRowBO.SetFieldValueAsString('BusTransaction_ID','1700000101');
       mRowBO.SetFieldValueAsString('X_QuantityValue',mXMLHead.getElementAsString('OrderA2.OrderLine['+IntToStr(i)+'].OrderedArticle.RequestedQuantity.QuantityValue'));
       mRowBO.SetFieldValueAsString('X_SuppliersArticleID',mXMLHead.getElementAsString('OrderA2.OrderLine['+IntToStr(i)+'].OrderedArticle.ArticleIdentification.SuppliersArticleID'));
       mRowBO.SetFieldValueAsString('X_BuyerArticleID',mXMLHead.getElementAsString('OrderA2.OrderLine['+IntToStr(i)+'].OrderedArticle.ArticleIdentification.BuyerArticleID'));
       mRowBO.SetFieldValueAsString('X_BD_LineID',mXMLHead.getElementAsString('OrderA2.OrderLine['+IntToStr(i)+'].LineID'));
      end;
    end;
    mbo.save;
    if Assigned(mbo) then begin
       //odeslání mailu kvapulinsky@cemat.cz
       SendInternalMail(OS,'kvapulinsky@cemat.cz','petvaldsky@cemat.cz','','Nová objednávka '+mbo.DisplayName,'Nová objednávka '+mbo.DisplayName+' od firmy '+mbo.GetFieldValueAsString('Firm_ID.Name'),
                           '',mbo.GetFieldValueAsString('Firm_ID'),'1000000101','1700000101');
    end;
    mbo.free;
    ProcessContinue := True;
  except
    NxShowSimpleMessage(ExceptionMessage,nil);
    ProcessContinue := false;
  end;

  
end;

procedure  SendORDRSP(OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
var
 mList,mExportList, mLog:TStringList;
 mBO:TNxCustomBusinessObject;
 i:integer;
 mFileName:string;
begin
  mList:=TStringList.Create;
  mLog:=TStringList.Create;
  mLog.add('_________________');
  os.SQLSelect('Select id from receivedorders where X_Send_ORDRSP=''A'' and X_ORDRSP_Sent=''N'' ',mList);
  if mList.Count>0 then begin
    for i:=0 to mlist.count-1 do begin
      mBO:=OS.CreateObject(Class_ReceivedOrder);
      mBO.Load(mList.Strings[i],nil);
      mfileName:=NxGetTempDir+cPrefix+'ORDRSPCEMCZB'+FormatDateTime('YYYYMMDDhhnnss',Now)+'.'+mbo.GetFieldValueAsString('X_BranchID');
      mLog.Add(DateTimeToStr(Now)+' Objednávka přijatá '+mbo.DisplayName);
      mLog.Add(DateTimeToStr(Now)+' Název souboru '+mfileName);
      mExportList:=TStringList.Create;
      mExportList.add(mbo.OID);
      CfxReportManager.ExportByIDs(NxCreateContext(OS),mExportList,GetDynSourceE(OS,'67O0000101'),'67O0000101',0,'',mFileName);
      FTPUploadEDI(OS,mFileName,cEnviroment+'Order');
      mBO.SetFieldValueAsBoolean('X_ORDRSP_Sent',true);
      mBO.save;
      mbo.free;
      mExportList.free;
    end;
  end;
  Success := True;
  LogInfoStr := ''+mLog.Text;
end;

procedure  SendDESADV(OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
var
 mList,mExportList, mLog:TStringList;
 mBO:TNxCustomBusinessObject;
 i:integer;
 mFileName:string;
begin
  mList:=TStringList.Create;
  mLog:=TStringList.Create;
  mLog.add('_________________');
  os.SQLSelect('Select id from StoreDocuments where X_Send_DESADV=''A'' and X_DESADV_Sent=''N'' ',mList);
  if mList.Count>0 then begin
    for i:=0 to mlist.count-1 do begin
      mBO:=OS.CreateObject(Class_BillOfDelivery);
      mBO.Load(mList.Strings[i],nil);
      mfileName:=NxGetTempDir+cPrefix+'DESADVCEMCZB'+FormatDateTime('YYYYMMDDhhnnss',Now)+'.'+mbo.GetFieldValueAsString('X_BranchID');
      mLog.Add(DateTimeToStr(Now)+' Dodací list '+mbo.DisplayName);
      mLog.Add(DateTimeToStr(Now)+' Název souboru '+mfileName);
      mExportList:=TStringList.Create;
      mExportList.add(mbo.OID);
      CfxReportManager.ExportByIDs(NxCreateContext(OS),mExportList,GetDynSourceE(OS,'77O0000101'),'77O0000101',0,'',mFileName);
      FTPUploadEDI(OS,mFileName,cEnviroment+'Order');
      mBO.SetFieldValueAsBoolean('X_DESADV_Sent',true);
      mBO.save;
      mbo.free;
      mExportList.free;
    end;
  end;
  Success := True;
  LogInfoStr := ''+#13#10+mLog.Text;
end;

procedure SendINVOIC(OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
var
 mList,mExportList, mLog:TStringList;
 mBO:TNxCustomBusinessObject;
 i:integer;
 mFileName, mPFileName:string;
begin
  mList:=TStringList.Create;
  mLog:=TStringList.Create;
  mLog.add('_________________');
  os.SQLSelect('Select id from IssuedInvoices where X_Send_INVOIC=''A'' and X_INVOIC_Sent=''N'' ',mList);
  if mList.Count>0 then begin
    mfileName:=NxGetTempDir+cPrefix+'INVOICCEMCZB'+FormatDateTime('YYYYMMDDhhnnss',Now)+'.6000';
    mLog.Add(DateTimeToStr(Now)+' Název souboru '+mfileName);
    CfxReportManager.ExportByIDs(NxCreateContext(OS),mList,GetDynSourceE(OS,'87O0000101'),'87O0000101',0,'',mFileName);
    FTPUploadEDI(OS,mFileName,cEnviroment+'IncInvoice');
    for i:=0 to mlist.count-1 do begin
      mBO:=OS.CreateObject(Class_IssuedInvoice);
      mBO.Load(mList.Strings[i],nil);
      //6000_603000576_InvoiceNumber_yyyyMMdd(InvoiceIssueDate).pdf
      mPFileName:='6000_603000576_'+mbo.GetFieldValueAsString('VarSymbol')+'_'+FormatDateTime('YYYYMMDD',mbo.GetFieldValueAsDateTime('DocDate$Date'))+'.pdf';
      mLog.Add(DateTimeToStr(Now)+' Faktura vydaná '+mbo.DisplayName);
      mLog.Add(DateTimeToStr(Now)+' Název pdf '+NxGetTempdir+mPFileName);
      mExportList:=TStringList.Create;
      mExportList.add(mbo.OID);
      CFxReportManager.PrintByIDs(NxCreateContext(OS), mExportList, GetDynSource(OS,'1BU0000101'), '1BU0000101', rtoFile, pekPDF, NxGetTempDir,mPFileName);
      FTPUploadEDI(OS,NxGetTempdir+mPFileName,cEnviroment+'IncInvoice_PDF_CZCT/In');
      mBO.SetFieldValueAsBoolean('X_INVOIC_Sent',true);
      mBO.save;
      mbo.free;
      mExportList.free;
    end;
  end;
  Success := True;
  LogInfoStr := ''+#13#10+mLog.Text;
end;

Function GetSCID(var aOS:TNxCustomObjectSpace; var aCode:string):string;
var
 mStoreCard_ID:string;
begin
  Result:='';
  if NxIsNumeric(aCode) and (Length(aCode)=13) then begin
   mStoreCard_ID:=aOS.SQLSelectFirstAsString('SELECT  A.id FROM StoreCards A WHERE (((A.EAN LIKE '+QuotedStr(aCode)+' ESCAPE '+QuotedStr('~')+') OR '+
                                             '(A.ID IN (SELECT SU.Parent_ID FROM StoreEANs SE JOIN StoreUnits SU ON SE.Parent_Id = SU.Id '+
                                             'WHERE SU.Parent_ID = A.ID AND SE.Ean LIKE '+QuotedStr(aCode)+' ESCAPE '+QuotedStr('~')+')))) AND A.Hidden = '+Quotedstr('N'),'');
   Result:=mStoreCard_ID
  end;
end;

procedure SendInternalMail(AOS:TNxCustomObjectSpace; ATo:String; ACC:String; ABCC:String; ASubject:String; ABody:String; AAtachement:String; AFirm_ID:String; ADivision_ID:String; ABusTransaction_ID:String);
Var
  mMailBO:TNxCustomBusinessObject;
  mMRecipients:TNxCustomBusinessMonikerCollection;
  mMailRecipient:TNxCustomBusinessObject;
begin
  if not(ato='') then begin
     mMailBO:=AOS.CreateObject('5C1HWDQDR3J4NAAYZRO5PWHLWK');
     mMailBO.New;
     mMailBO.Prefill;
     mMailBO.SetFieldValueAsString('EmailAccount_ID','1000000101');
     mMailBO.SetFieldValueAsString('Subject',ASubject);
     mMailBO.SetFieldValueAsBoolean('AddSentIdent',False);
     mMailbo.SetFieldValueAsInteger('SentState',1);
     mmailbo.SetFieldValueAsInteger('BodySavedAs',1);
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
      if FileExists(AAtachement) then TNxEmailSent(mMailBO).AttachFile(AAtachement);

     end;
     mMailBO.Save;
     mMailBO.free;
  end;
end;


function FTPUploadEDI(AOS: TNxCustomobjectSpace; AFileName, aPath: String; AHide: Boolean = true): Boolean;
var
  mExportBatch: TStringList;
  mFileBatch: String;
  mCanDeleteFile: Boolean;
begin
  Result := False;
  mCanDeleteFile := False;
  mExportBatch := TStringList.Create;
  try
    mExportBatch.Add(Format('open %s', [cFTPlogin2]));
    mExportBatch.add('cd '+aPath);
    mExportBatch.Add(Format('mput  "%s"', [AFileName]));
    if AHide then
      mExportBatch.Add('bye');
    if NxCreateTempFile(mFileBatch) then begin
      mExportBatch.SaveToFile(mFileBatch);
      mExportBatch.savetofile('C:\AbraG3\_batch\batch.txt');
      if NxExecFile(Format(cFTPexec, [mFileBatch]), AHide, True) then
        Result:= True;
    end;
  finally
    mExportBatch.Free;
  end;
end;

function GetDynSourceE (AOS : TNxCustomObjectSpace; AValue : string) : String;

const
  cSQL = 'SELECT DataSource FROM Exports WHERE ID=''%s'' ';
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

begin
end.