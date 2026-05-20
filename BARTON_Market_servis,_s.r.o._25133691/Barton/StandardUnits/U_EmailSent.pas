uses
  'StandardUnits.U_PrintReport';

const
  EMAILSENT_EmailAccount_ID = '1000000101';

////////////////////////////////////////////////////////////////////////////////
//vytvori a vrati objekt Odeslaneho emailu. NENI ULOZEN
//parametr Email - muze obsahovat emaily oddelene strednikem. Pokud zacina mail znakem #, da se do skryte kopie
//parametr AttachFile - muze obsahovat prilohy oddelene strednikem
//parametr EmailAccount_ID - pokud je prazdnej, pouzije se aktualne prihlaseny uzivatel. Pokud nema ucet, pouzije se default z konstanty
function EmailSent_Create(OS: TNxCustomObjectSpace; Email, Subject, Body, AttachFile: string; Doc: TNxCustomBusinessObject; EmailAccount_ID: TNxOID): TNxEmailSent;
var
  mSentEmail : TNxEmailSent;
  mRecipients: TNxCustomBusinessMonikerCollection;
  mRecipient : TNxCustomBusinessObject;
  sl  : TStringList;
  i   : integer;
  str :string;
  DefaultText :string;
  DocQueue_ID :string;
begin
  //Odeslu soubor mejlem interni mailovaci klient

  //pokud je prazdnej, pouzije se aktualne prihlaseny uzivatel
  if(NxIsEmptyOID(EmailAccount_ID))then
    EmailAccount_ID:= EmailSent_GetEmailAccount(OS, '');
  if(NxIsEmptyOID(EmailAccount_ID))then
    EmailAccount_ID:= EMAILSENT_EmailAccount_ID;

  //implicitni text. Vetsinou podpis.
  DefaultText:= getfieldfromid(OS, 'EmailAccounts', EmailAccount_ID, 'DefaultText');

  mSentEmail:=TNxEmailSent(OS.CreateObject(Class_EmailSent));
  sl:= TStringList.Create;
  try
    mSentEmail.ExplicitTransaction:= OS.InTransaction;

    //zjistim si radu
    OS.SQLSelect(
      'SELECT SendMailDocQueue_ID FROM EmailAccounts WHERE ID='+QuotedStr(EmailAccount_ID)
      ,sl
    );
    if(sl.Count=0)then RaiseException('Chyba při zjištění řady pro odeslání emailu.');
    DocQueue_ID:= sl.strings[0];

    mSentEmail.New;
    mSentEmail.Prefill;
    mSentEmail.SetFieldValueAsString('DocQueue_ID', DocQueue_ID);
    mSentEmail.SetFieldValueAsString('EmailAccount_ID', EmailAccount_ID);
    mSentEmail.SetFieldValueAsString('Subject',Subject);
    mSentEmail.SetFieldValueAsBoolean('AddSentIdent',false);

    if(Body = '')then
      mSentEmail.SetFieldValueAsString('Body', DefaultText)
   else
      mSentEmail.SetFieldValueAsString('Body', Body);
    mSentEmail.SetFieldValueAsInteger('SentState',1); //k odeslani

    if(Assigned(Doc))then begin
      if(Doc.HasField('Firm_ID') AND (not Doc.GetFieldValueAsBoolean('Firm_ID.Hidden')))then begin
        mSentEmail.SetFieldValueAsString('Firm_ID',Doc.GetFieldValueAsString('Firm_ID'));

        if(Doc.HasField('FirmOffice_ID') AND (not Doc.GetFieldValueAsBoolean('FirmOffice_ID.Hidden')))then
          mSentEmail.SetFieldValueAsString('FirmOffice_ID',Doc.GetFieldValueAsString('FirmOffice_ID'));
      end;

      if(Doc.HasField('Person_ID') AND (not Doc.GetFieldValueAsBoolean('Person_ID.Hidden')))then
        mSentEmail.SetFieldValueAsString('Person_ID',Doc.GetFieldValueAsString('Person_ID'));
    end;

    //prijemci
    mRecipients:= mSentEmail.GetCollectionMonikerForFieldCode(mSentEmail.GetFieldCode('Recipients'));

    sl.Delimiter:= ';';
    sl.DelimitedText:= Email;
    for i:= 0 to sl.Count-1 do begin
      str := sl.Strings[i];
      if(str = '')then continue;
      mRecipient:= mRecipients.AddNewObject;
      mRecipient.Prefill;
      mRecipient.SetFieldValueAsInteger('EmailType', 0);
      if copy(str,1,1) = '#' then begin
        mRecipient.SetFieldValueAsInteger('EmailType', 2);
        str := copy(str, 2, length(str)-1);
      end;
      mRecipient.SetFieldValueAsString('Email',str);
    end;

    if(AttachFile <> '')then
    begin
      sl.Delimiter:= ';';
      sl.DelimitedText:= AttachFile;
      for i:= 0 to sl.Count-1 do begin
        if(sl.Strings[i] = '')then continue;
        mSentEmail.AttachFile(sl.Strings[i]);
      end;
    end;
  finally
    sl.free;
  end;

  result:= mSentEmail;
end;
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//vytvori a ulozi odeslany email
//parametr Email - muze obsahovat emaily oddelene strednikem. Pokud zacina mail znakem #, da se do skryte kopie
//parametr AttachFile - muze obsahovat prilohy oddelene strednikem
function EmailSent_CreateAndSave(OS: TNxCustomObjectSpace; Email, Subject, Body, AttachFile: string; Doc: TNxCustomBusinessObject; EmailAccount_ID: TNxOID): TnxOID;
var
  mSentEmail : TNxEmailSent;
begin
  mSentEmail:= EmailSent_Create(OS, Email, Subject, Body, AttachFile, Doc, EmailAccount_ID);
  try
    mSentEmail.Save;
    result:= mSentEmail.OID;
  finally
    mSentEmail.free;
  end;
end;
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//Parametr User_ID - pokud je prazdny, pouzije se aktualni uzivatel
function EmailSent_GetEmailAccount(OS: TNxCustomObjectSpace; User_ID: TNxOID = ''): TNxOID;
begin
  if(NxIsEmptyOID(User_ID))then
    User_ID:= NxGetActualUserID(OS);

  result:= GetIdwhere(OS, 'EmailAccounts', 'AccountType=0 and Owner_ID='+quotedstr(User_ID));
end;
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
procedure EmailSent_AttachReportPdf(EmailSent: TNxCustomBusinessObject; BO: TNxCustomBusinessObject; Report_ID, DynSource_ID, AttachName: string);
var
  Size: integer;
  mAttachments: TNxCustomBusinessMonikerCollection;
  mAttachment : TNxCustomBusinessObject;
begin
  if(AttachName = '')then
    AttachName:= FileName_ForDocument(BO, CFxReportManager.GetFileExtensionFromPrintExportKind(pekPDF));

  mAttachments:= EmailSent.GetLoadedCollectionMonikerForFieldCode(EmailSent.GetFieldCode('Attachments'));
  mAttachment:= mAttachments.AddNewObject;
  mAttachment.Prefill;
  mAttachment.SetFieldValueAsString('Content_ID', PrintDocumentPDF2BusinesObject(BO, Class_EmailSentAttachContent, Report_ID, DynSource_ID, Size));
  mAttachment.SetFieldValueAsString('FileName', AttachName);
  mAttachment.SetFieldValueAsInteger('FileSize', Size);
end;
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
procedure EmailSent_AttachStream(EmailSent: TNxCustomBusinessObject; Stream: TMemoryStream; AttachName: string);
var
  mAttachments: TNxCustomBusinessMonikerCollection;
  mAttachment : TNxCustomBusinessObject;
  mData  : TNxCustomBusinessObject;
begin
  //ulozim stream do objektu Data
  mData := EmailSent.ObjectSpace.CreateObject(Class_EmailSentAttachContent);
  try
    mData.ExplicitTransaction:= EmailSent.ObjectSpace.InTransaction;
    mData.New;
    mData.Prefill;
    mData.SetFieldValueAsBytes('BlobData', Stream.GetBytes);
    mData.Save;

    mAttachments:= EmailSent.GetLoadedCollectionMonikerForFieldCode(EmailSent.GetFieldCode('Attachments'));
    mAttachment:= mAttachments.AddNewObject;
    mAttachment.Prefill;
    mAttachment.SetFieldValueAsString('Content_ID', mData.GetFieldValueAsString('ID'));
    mAttachment.SetFieldValueAsString('FileName', AttachName);
    mAttachment.SetFieldValueAsInteger('FileSize', Length(mData.GetFieldValueAsBytes('BlobData')));
  finally
    mdata.free;
  end;
end;
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
procedure EmailSent_AttachBytes(EmailSent: TNxCustomBusinessObject; Bytes: TBytes; AttachName: string);
var
  mAttachments: TNxCustomBusinessMonikerCollection;
  mAttachment : TNxCustomBusinessObject;
  mData  : TNxCustomBusinessObject;
begin
  //ulozim stream do objektu Data
  mData := EmailSent.ObjectSpace.CreateObject(Class_EmailSentAttachContent);
  try
    mData.ExplicitTransaction:= EmailSent.ObjectSpace.InTransaction;
    mData.New;
    mData.Prefill;
    mData.SetFieldValueAsBytes('BlobData', Bytes);
    mData.Save;

    mAttachments:= EmailSent.GetLoadedCollectionMonikerForFieldCode(EmailSent.GetFieldCode('Attachments'));
    mAttachment:= mAttachments.AddNewObject;
    mAttachment.Prefill;
    mAttachment.SetFieldValueAsString('Content_ID', mData.GetFieldValueAsString('ID'));
    mAttachment.SetFieldValueAsString('FileName', AttachName);
    mAttachment.SetFieldValueAsInteger('FileSize', Length(mData.GetFieldValueAsBytes('BlobData')));
  finally
    mdata.free;
  end;
end;
////////////////////////////////////////////////////////////////////////////////

begin
end.