uses
  'StandardUnits.U_PrintReport';

const
  MsgSent_rctUser = 0; //uživatel
  MsgSent_rctRole = 1; //role
  MsgSent_rctGroup = 2; //skupina rolí
  MsgSent_rctAllUsers = 3; //všem uživatelum Gx
  MsgSent_rctExternalMail = 4; //externí mailové adresy


////////////////////////////////////////////////////////////////////////////////
//Vytvori a vrati interní zprávu
//Parametr slLinks - struktura: ClassID+OID=Titulek (Class_StoreCard+StoreCard.OID+'='+StoreCard.Code
function MsgSent_Create(AOS : TNxCustomObjectSpace; AMsgSubject, AMsgBody : String; slLinks: TStringList): TNxCustomBusinessObject;
var
  mMsgSent : TNxCustomBusinessObject;
  mMsgRecipient : TNxCustomBusinessObject;
  mMsgRecipients : TNxCustomBusinessMonikerCollection;
  mLinks : TNxCustomBusinessMonikerCollection;
  Link: TNxCustomBusinessObject;
  i: integer;
begin
  mMsgSent := AOS.CreateObject(Class_MsgSent);
  mMsgSent.ExplicitTransaction:= AOS.InTransaction;

  mMsgSent.New;
  mMsgSent.Prefill;
  mMsgSent.SetFieldValueAsString('MsgBody', AMsgBody);
  mMsgSent.SetFieldValueAsString('MsgSubject', AMsgSubject);

  //link
  mLinks := mMsgSent.GetLoadedCollectionMonikerForFieldCode(mMsgSent.GetFieldCode('Links'));
  for i:= 0 to slLinks.Count-1 do begin
    Link:= mLinks.AddNewObject;
    Link.Prefill;
    Link.SetFieldValueAsInteger('LinkType', 0);//proste nula. nc jinyho se sem nedava
    Link.SetFieldValueAsString('Link', slLinks.Names[i]);
    Link.SetFieldValueAsString('Title', slLinks.ValueFromIndex[i]);
  end;

  result:= mMsgSent;
end;
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//Prida prijemce do zpravy
procedure MsgSent_AddRecipient(aMsgSent : TNxCustomBusinessObject; aRecipientType: integer; aRecipient: TnxOID);
var
  mMsgRecipient : TNxCustomBusinessObject;
  mMsgRecipients : TNxCustomBusinessMonikerCollection;

begin
  mMsgRecipients := aMsgSent.GetLoadedCollectionMonikerForFieldCode(aMsgSent.GetFieldCode('Recipients'));
  mMsgRecipient := mMsgRecipients.AddNewObject;
  mMsgRecipient.SetFieldValueAsInteger('RecipientType', aRecipientType);
  case aRecipientType of
    MsgSent_rctUser        : mMsgRecipient.SetFieldValueAsString('SecurityUser_ID' , aRecipient);
    MsgSent_rctRole        : mMsgRecipient.SetFieldValueAsString('SecurityRole_ID' , aRecipient);
    MsgSent_rctGroup       : mMsgRecipient.SetFieldValueAsString('SecurityGroup_ID', aRecipient);
    MsgSent_rctAllUsers    : begin {nic neprirazuju} end;
    MsgSent_rctExternalMail: mMsgRecipient.SetFieldValueAsString('EmailAccount_ID ', aRecipient);
    else RaiseException('Nesprávná hodnota parametru aRecipientType.');
  end;
end;
////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////
//Vytvori a ulozi interní zprávu pro konkretniho uzivatele
//AUser_IDs - id oddelene carkou
function MsgSent_CreateAndSendToUser(AOS : TNxCustomObjectSpace; AUser_IDs : string;
  AMsgSubject, AMsgBody : String; slLinks: TStringList): TNxOID;
var
  mMsgSent : TNxCustomBusinessObject;
  sl: TStringList;
  i: integer;
begin
  if AUser_IDs='' then
    RaiseException('Není definován příjemce');

  sl:= TStringList.Create;
  mMsgSent := MsgSent_Create(AOS, AMsgSubject, AMsgBody, slLinks);
  try
    sl.CommaText:= AUser_IDs;
    for i:= 0 to sl.count-1 do
      MsgSent_AddRecipient(mMsgSent, MsgSent_rctUser, sl[i]);

    mMsgSent.Save;
    result:= mMsgSent.OID;
  finally
    sl.Free;
    mMsgSent.Free;
  end;
end;
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//Vytvori a ulozi interní zprávu pro konkretniho uzivatele
function MsgSent_CreateAndSendToRole(AOS : TNxCustomObjectSpace; ARole_ID : TNxOID;
  AMsgSubject, AMsgBody : String; slLinks: TStringList): TNxOID;
var
  mMsgSent : TNxCustomBusinessObject;
  mMsgRecipient : TNxCustomBusinessObject;
  mMsgRecipients : TNxCustomBusinessMonikerCollection;

begin
  if CFxOID.IsEmpty(ARole_ID) then
    RaiseException('Není definován příjemce');

  mMsgSent := MsgSent_Create(AOS, AMsgSubject, AMsgBody, slLinks);
  try
    MsgSent_AddRecipient(mMsgSent, MsgSent_rctRole, ARole_ID);

    mMsgSent.Save;
    result:= mMsgSent.OID;
  finally
    mMsgSent.Free;
  end;
end;
////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////
procedure MsgSent_AttachReportPdf(MsgSent: TNxCustomBusinessObject; BO: TNxCustomBusinessObject; Report_ID, DynSource_ID, AttachName: string);
var
  Size: integer;
  mAttachments: TNxCustomBusinessMonikerCollection;
  mAttachment : TNxCustomBusinessObject;
begin
  if(AttachName = '')then
    AttachName:= FileName_ForDocument(BO, CFxReportManager.GetFileExtensionFromPrintExportKind(pekPDF));

  mAttachments:= MsgSent.GetLoadedCollectionMonikerForFieldCode(MsgSent.GetFieldCode('Attachments'));
  mAttachment:= mAttachments.AddNewObject;
  mAttachment.Prefill;
  mAttachment.SetFieldValueAsString('Content_ID', PrintDocumentPDF2BusinesObject(BO, Class_MsgAttachContent, Report_ID, DynSource_ID, Size));
  mAttachment.SetFieldValueAsString('FileName', AttachName);
  mAttachment.SetFieldValueAsInteger('FileSize', Size);
end;
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
procedure MsgSent_AttachStream(MsgSent: TNxCustomBusinessObject; Stream: TMemoryStream; AttachName: string);
var
  mAttachments: TNxCustomBusinessMonikerCollection;
  mAttachment : TNxCustomBusinessObject;
  mData  : TNxCustomBusinessObject;
begin
  //ulozim stream do objektu Data
  mData := MsgSent.ObjectSpace.CreateObject(Class_MsgAttachContent);
  try
    mData.ExplicitTransaction:= MsgSent.ObjectSpace.InTransaction;
    mData.New;
    mData.Prefill;
    mData.SetFieldValueAsBytes('BlobData', Stream.GetBytes);
    mData.Save;

    mAttachments:= MsgSent.GetLoadedCollectionMonikerForFieldCode(MsgSent.GetFieldCode('Attachments'));
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