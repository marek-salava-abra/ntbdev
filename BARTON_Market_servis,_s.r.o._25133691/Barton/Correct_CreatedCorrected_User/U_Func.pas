// vrati uzivatele z globalni promenne
function GetCurrentUser(Self: TNxCustomBusinessObject): TNxOID;
begin
  if GlobParams.ParamExist('WS_User_ID') then
  begin
    Result := GlobParams.ParamAsString('WS_User_ID', '');
  end
  else
    Result := NxGetActualUserID_1(Self);
end;

////////////////////////////////////////////////////////////////////////////////
// funkce na nastaveni CreatedBy_ID a CorrectedBy_ID na uzivatele
// nastaveneho v globalnim parametru WS_User_ID
//POUZITO pro agendy, ktere nemaji nase stavy. (napr odeslana posta)
procedure SetCreatedUser(Self: TNxCustomBusinessObject);
var
  WS_User_ID: string;
begin
  //pokud si nastavim globalni promennou WS_User_ID (nastavuji si ji ve webove sluzbe pri)
  // tak tohoto uzivatele vlozim do CorrectedBy_ID misto aktualniho uzivatele
  if GlobParams.ParamExist('WS_User_ID') then
  begin
    WS_User_ID := GlobParams.ParamAsString('WS_User_ID', '');
    if(not NxIsEmptyOID(WS_User_ID))then
    begin
      if(osNew in Self.State) then
        Self.SetFieldValueAsString('CreatedBy_ID', WS_User_ID);

      Self.SetFieldValueAsString('CorrectedBy_ID', WS_User_ID);
    end;
  end;
end;
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
// nastavi uzivatele do poli Vytvoril, Zmenil, pokud je vyplnena globalni promenna
// nastavi take Vyridil, pokud je to parametrem vyzadovano
procedure SetUser(Self: TNxCustomBusinessObject; ASetConfirmedBy: Boolean);
var
  mUserID: String;
begin
  mUserID := GlobParams.ParamAsString('WS_User_ID', '');
  if not CFxOID.IsEmpty(mUserID) then
  begin
    if(osNew in Self.State) then
      Self.SetFieldValueAsString('CreatedBy_ID', mUserID);
    Self.SetFieldValueAsString('CorrectedBy_ID', mUserID);

  if ASetConfirmedBy
    and (Self.DifferentFromOriginal_1('PMState_ID')) and (Self.GetFieldValueAsInteger('PMState_ID.SystemState') = 3)
  then
    Self.SetFieldValueAsString('FinishedBy_ID', mUserID);
  end;
end;
////////////////////////////////////////////////////////////////////////////////

begin
end.