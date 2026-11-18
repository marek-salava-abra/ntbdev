uses
  '_Knihovny_ALL.SQL';


// vytvoření emailu odeslaného
//   ARecipients: adresáti oddělení čárkou
//   AAttachments: případné přílohy (cesty k souborům oddělené čárkou)

function CreateEmailSent(OS: TNxCustomObjectSpace; ARecipients, ASubejct, ABody, AAccountID, AFirmID: string; AHTML: boolean; var AErrorMsg: string; AAttachments: string = ''; ASendState: integer = 1): boolean;
var
  mEmail: TNxEmailSent;
  mRecipient: TNxCustomBusinessObject;
  mRecipients, mAttachments: TNxCustomBusinessMonikerCollection;
  mRecipList, mAttachList: TStringList;
  i: integer;
  mFS: TFileStream;
  mAttachment, mContent: TNxCustomBusinessObject;
begin

  mRecipList := TStringList.Create;
  mAttachList := TStringList.Create;
  mEmail := TNxEmailSent(OS.CreateObject(Class_EmailSent));
  try
    mEmail.New;
    mEmail.Prefill;
    mEmail.SetFieldValueAsString('EmailAccount_ID', AAccountID);
    if (not NxIsEmptyOID(AFirmID)) then
      mEmail.SetFieldValueAsString('Firm_ID', AFirmID);
    mEmail.SetFieldValueAsString('RecipientsInOneLine', ARecipients);
    mEmail.SetFieldValueAsString('Subject', ASubejct);
    if AHTML then mEmail.SetFieldValueAsInteger('BodySavedAs', 1)
    else mEmail.SetFieldValueAsInteger('BodySavedAs', 0);
    mEmail.SetFieldValueAsString('Body', ABody);
    mEmail.SetFieldValueAsInteger('SentState', ASendState);

    // adresáti
    mRecipList.CommaText := ARecipients;
    mRecipients := mEMail.GetLoadedCollectionMonikerForFieldCode(mEMail.GetFieldCode('Recipients'));
    for i := 0 to mRecipList.Count - 1 do begin
      mRecipient := mRecipients.AddNewObject;
      mRecipient.Prefill;
      mRecipient.SetFieldValueAsInteger('EmailType', 0);
      mRecipient.SetFieldValueAsString('Email', mRecipList[i]);
    end;

    // přílohy
    if (AAttachments <> '') then begin
      mAttachList.CommaText := AAttachments;
      mAttachments := mEmail.GetLoadedCollectionMonikerForFieldCode(mEmail.GetFieldCode('Attachments'));
      for i := 0 to mAttachList.Count - 1 do begin
        TNxEmailSent(mEmail).AttachFile(mAttachList[i]);
      end;
    end;


    mEmail.Save;
  finally
    mEmail.free;
  end;

  Result := true;

end;


// načtení emailu uživatele podle ID role
// může být i více rolí, vrátít to pak více emailů oddělených čárkou
function GetUserEmailByRoleID(OS: TNxCustomObjectSpace; ARoleIDs: TStringList): string;
var
  mQuery: string;
  mEmails: TStringList;
  i: integer;
begin
  Result := '';
  mEmails := TStringList.Create;
  try
    mQuery := 'SELECT A.Email FROM SecurityUserRoleLinks UR '+
    'JOIN SecurityUsers U ON U.ID = UR.User_ID '+
    'JOIN Addresses A ON A.ID = U.Address_ID '+
    'WHERE UR.Role_ID IN ('+SQLStringList(ARoleIDs)+')';
    mEmails := SQLSelectValues(OS, mQuery);
    for i := mEmails.Count - 1 downto 0 do begin
      if (Trim(mEmails[i]) = '') then mEmails.Delete(i);
    end;
    Result := mEmails.CommaText;
  finally
    mEmails.Free;
  end;
end;


begin
end.