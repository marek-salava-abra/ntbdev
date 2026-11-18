


procedure GenSheet(OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
var
 mList:TStringList;
begin
  mList:=TStringList.Create;
  OS.SQLSelect('Select id from storecards where Name like '+QuotedStr('_/%')+' and IsProduct=''A'' and hidden=''N'' order by name', mList);
  if mList.count>0 then begin
    CFxReportManager.ExportByIDs(NxCreateContext(OS),mList,GetDynSourceE(OS,'~000000C01'),'~000000C01',0,'',NxGetTempDir+'stavy.xlsx');
    SendInternalMail(OS,'vkocmanek@lipoelastic.com','XLS Stavy','Tělo mailu','3130000101',NxGetTempDir+'stavy.xlsx')
  end;
  Success := True;
  LogInfoStr := ''+NxGetTempDir+'stavy.xlsx';
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

procedure SendInternalMail(var AOS:TNxCustomObjectSpace;var ATo, ASubject,ABody,aAccount_ID,AAtachement:string);
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
     mMailBO.SetFieldValueAsString('BodySavedAs','1');
     mMailbo.SetFieldValueAsInteger('SentState',1);
     mMailBO.SetFieldValueAsString('Body',ABody);
     mMRecipients:=mMailBO.GetCollectionMonikerForFieldCode(mMailBO.GetFieldCode('Recipients'));

     mMailRecipient:=mMRecipients.AddNewObject;
     mMailRecipient.SetFieldValueAsString('Email',ATo);
     mMailRecipient.SetFieldValueAsInteger('EmailType',0);
     if not(AAtachement='') then begin
      if FileExists(AAtachement) then TNxEmailSent(mMailBO).AttachFile(AAtachement);

     end;
     mMailBO.Save;
     mMailBO.free;

  end;
end;


begin
end.