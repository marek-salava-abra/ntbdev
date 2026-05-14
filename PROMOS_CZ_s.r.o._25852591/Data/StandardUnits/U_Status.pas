(*
unita pro praci se stavama.

-zjisteni ID stavu podle kodu
-zjisteni, zda se zmenil stav ze stavu na stav
-zjisteni ID prechodoveho pravidla podle stavu z/na
-zjisteni zda muzu provest prechod podle pravidla
*)

////////////////////////////////////////////////////////////////////////////////
//Pro zadanou tridu BO vrati ID stavu podle jeho nazvu
function Status_GetIDFromCode(OS: TNxCustomObjectSpace; CLSID: string; UserStatusCode: string): TNxOID;
var
  list : TStringList;
begin
  list:= TStringList.create;
  try
    OS.SQLSelect('SELECT Id FROM UserStatuses WHERE hidden=''N'' and UserStatusCode='+QuotedStr(UserStatusCode)+' and CLSID='+QuotedStr(CLSID), list);

    if(list.count > 0)then
      result:= trim(list.strings[0])
    else
      result:= '';
  finally
    list.free;
  end;

  if(result = '')then
    RaiseException(Format('"Function StatusID_GetFromCode": Neexistuje stav %s pro třídu %s', [UserStatusCode, CLSID]));
end;
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//Pro zadanou tridu BO, radu dokladu (muze byt prazdne, pokud neni na typu dokladu zapnute procesni rizeni)
//  a nazvy stavu vrati ID prechodoveho pravidla
function SwitchRule_GetIDFromCode(OS: TNxCustomObjectSpace; CLSID: string;
  DocQueue_ID: TNxOID; UserStatusCode_From, UserStatusCode_To: string): TNxOID;
var
  list : TStringList;
  DocumentType: TNxCustomBusinessObject;
begin
  //pokud si predam radku, tak musim zjistit zda je na dokladech zapnute procesni rizeni
  //TODO: toto zadim nevim jak udelat
  if(not NxIsEmptyOID(DocQueue_ID))then
    RaiseException('"Function StatusID_GetFromCode": Není podporováno zjišťování přechodu pro konkrétní řadu.');

  list:= TStringList.create;
  //DocumentType:= OS.CreateObject(Class_DocumentType);
  try
    //TODO: neumim z CLSID zjistit ID v DocumentType, kde je ulozena informace WorkflowByQueue
    //zjistim zda je na tride zapnute procesni rizeni
    //DocumentType.Load(CLSID, nil);

    OS.SQLSelect(
      'select a.ID '+
      'from UserStatusesSwitchRules a '+
      'join UserStatuses b1 on a.UserStatusesFrom_ID=b1.ID '+
      'join UserStatuses b2 on a.UserStatusesTo_ID=b2.ID '+
      'where a.hidden=''N'' and a.CLSID='+QuotedStr(CLSID)+' and b1.UserStatusCode='+QuotedStr(UserStatusCode_From)+' and b2.UserStatusCode='+QuotedStr(UserStatusCode_To)
      , list);

    if(list.count > 0)then
      result:= trim(list.strings[0])
    else
      result:= '';
  finally
    list.free;
    //DocumentType.free;
  end;

  if(result = '')then
    RaiseException(Format('"Function StatusID_GetFromCode": Neexistuje přechod %s-->%s pro třídu %s', [UserStatusCode_From, UserStatusCode_To, CLSID]));
end;
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//Pro zadanou tridu BO, radu dokladu (muze byt prazdne, pokud neni na typu dokladu zapnute procesni rizeni)
//  a stavy ID prechodoveho pravidla
function SwitchRule_GetIDFromID(OS: TNxCustomObjectSpace; CLSID: string;
  DocQueue_ID, Status_ID_From, Status_ID_To: TNxOID): TNxOID;
var
  list : TStringList;
begin
  //pokud si predam radku, tak musim zjistit zda je na dokladech zapnute procesni rizeni
  //TODO: toto zadim nevim jak udelat
  if(not NxIsEmptyOID(DocQueue_ID))then
    RaiseException('"Function StatusID_GetFromCode": Není podporováno zjišťování přechodu pro konkrétní řadu.');

  list:= TStringList.create;
  try
    OS.SQLSelect(
      'select a.ID '+
      'from UserStatusesSwitchRules a '+
      'where a.hidden=''N'' and a.CLSID='+QuotedStr(CLSID)+' and a.UserStatusesFrom_ID='+QuotedStr(Status_ID_From)+' and a.UserStatusesTo_ID='+QuotedStr(Status_ID_To)
      , list);

    if(list.count > 0)then
      result:= trim(list.strings[0])
    else
      result:= '';
  finally
    list.free;
  end;

  if(result = '')then
    RaiseException(Format('"Function StatusID_GetFromCode": Neexistuje přechod %s-->%s pro třídu %s', [Status_ID_From, Status_ID_To, CLSID]));
end;
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//Z objektu pred ulozenim zjisti, zda se menil stav z/na zadany stav (podle ID stavu)
//pokud je Status_ID_From prazdne, tak nezalezi na puvodnim stavu
function SwitchRule_IsTransition(BO: TNxCustomBusinessObject;
  Status_ID_From, Status_ID_To: TNxOID): boolean;
var
  Status_From: string;
begin
  if(not BO.DifferentFromOriginal_1('Status_ID'))then begin
    result:= false;
    exit;
  end;

  if(NxIsEmptyOID(Status_ID_From))then begin
    //zajima me pouze prechod na konkretni stav
    result:= (BO.GetFieldValueAsString('Status_ID') = Status_ID_To);
  end else begin
    //zajima me pouze prechod ze konkretniho do konkretniho stavu
    BO.GetOriginalValue('Status_ID', Status_From);
    result:= (Status_From = Status_ID_From) AND (BO.GetFieldValueAsString('Status_ID') = Status_ID_To);
  end;
end;
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//Z objektu pred ulozenim zjisti, zda se menil stav z/na zadany stav (podle codu stavu)
//pokud je Status_ID_From prazdne, tak nezalezi na puvodnim stavu
function SwitchRule_IsTransitionCode(BO: TNxCustomBusinessObject;
  UserStatusCode_From, UserStatusCode_To: string): boolean;
var
  Status_From: string;
begin
  if(not BO.DifferentFromOriginal_1('Status_ID'))then begin
    result:= false;
    exit;
  end;

  if(UserStatusCode_From = '')then begin
    //zajima me pouze prechod na konkretni stav
    result:= (BO.GetFieldValueAsString('Status_ID.UserStatusCode') = UserStatusCode_To);
  end else begin
    //zajima me pouze prechod ze konkretniho do konkretniho stavu
    BO.GetOriginalValue('Status_ID', Status_From);
    result:=
      (Status_From = Status_GetIDFromCode(Bo.ObjectSpace, BO.GetFieldValueAsString('ClassID'), UserStatusCode_From))
      AND (BO.GetFieldValueAsString('Status_ID.UserStatusCode') = UserStatusCode_To);
  end;
end;
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//kontrola zda muzu provest prechod podle pravidla
function SwitchRule_CanSwitch(BO: TNxCustomBusinessObject; SwitchRule_ID: TNxOID; Exc: boolean): boolean;
var
  list : TStringList;
  str: string;
begin
  list:= TStringList.create;
  try
    BO.ObjectSpace.SQLSelect(
      'select UserStatusesFrom_ID from UserStatusesSwitchRules '+
      'where CLSID='+QuotedStr(BO.GetFieldValueAsString('ClassID'))+
      ' and id='+QuotedStr(SwitchRule_ID)
      , list);
    if(list.count = 0)then str:= '' else str:= trim(list.strings[0]);

    if(str <> BO.GetFieldValueAsString('Status_ID'))then begin
      result:= false;
      if(Exc)then begin
        list.Clear;
        BO.ObjectSpace.SQLSelect(
          'SELECT UserStatusCode FROM UserStatuses WHERE id='+QuotedStr(str)+' and CLSID='+QuotedStr(BO.GetFieldValueAsString('ClassID'))
          , list);
        if(list.count = 0)then str:= '' else str:= trim(list.strings[0]);

        RaiseException(BO.DisplayTypeName+' '+BO.DisplayName+' není ve stavu '+str);
      end;
    end else
      result:= true;

    if(list.count = 0)then str:= '' else str:= trim(list.strings[0]);
  finally
    list.free;
  end;
end;
////////////////////////////////////////////////////////////////////////////////

begin
end.