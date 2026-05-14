
////////////////////////////////////////////////////////////////////////////////
function GetCurrentUser(Self: TNxCustomBusinessObject): TNxOID;
begin
  //pokud si nastavim globalni promennou WS_User_ID (nastavuji si ji ve webove sluzbe pri)
  // tak tohoto uzivatele vlozim do CorrectedBy_ID misto aktualniho uzivatele
  if GlobParams.ParamExist('WS_User_ID') then begin
    result:= GlobParams.ParamAsString('WS_User_ID', '');
    //NxScriptingLog.WriteEvent(logDebug, 'Correct_CreatedCorrected_User: '+Self.ClassName+': '+result);
  end else
    result:= NxGetActualUserID_1(Self);
end;
////////////////////////////////////////////////////////////////////////////////

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
  if GlobParams.ParamExist('WS_User_ID') then begin
    WS_User_ID:= GlobParams.ParamAsString('WS_User_ID', '');
    if(not NxIsEmptyOID(WS_User_ID))then begin

      if(osNew in Self.State)then
        Self.SetFieldValueAsString('CreatedBy_ID', WS_User_ID);

      Self.SetFieldValueAsString('CorrectedBy_ID', WS_User_ID);
    end;
  end;
end;
////////////////////////////////////////////////////////////////////////////////

begin
end.