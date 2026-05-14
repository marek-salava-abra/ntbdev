uses
  'Correct_CreatedCorrected_User.U_Func';

{
Umožňuje nastavit do Vytvořil/Změnil jiné hodnoty než aktuálně přihlášeného uživatele a aktuální čas
}
{procedure _GetCreatedCorrectedUserAndDate_Hook(Self: TNxCustomBusinessObject; var AUser_ID: TNxOID; var ADateTime: TDateTime);
begin
  AUser_ID:= GetCurrentUser(Self);
end;}


procedure _BeforeSaveBlock_PostHook(Self: TNxCustomBusinessObject);
var
  mUser_ID, mStatus_ID: String;
begin
  if GlobParams.ParamExist('WS_User_ID') then
  begin
    mUser_ID := GlobParams.ParamAsString('WS_User_ID', '');
  end else
    mUser_ID := NxGetActualUserID_1(Self);

  if(osNew in Self.State)then
    Self.SetFieldValueAsString('CreatedBy_ID', mUser_ID);

  Self.SetFieldValueAsString('CorrectedBy_ID', mUser_ID);

  mStatus_ID := '';
  mStatus_ID := Self.GetFieldValueAsString('PMState_ID');
  //Self.GetOriginalValue('PMState_ID', mStatus_ID);
  //Self.SetFieldValueAsString('Description', mStatus_ID + ',' + Self.GetFieldValueAsString('PMState_ID'));
  //Self.SetFieldValueAsString('Description', Self.GetFieldValueAsString('PMState_ID'));
  if mStatus_ID = 'SDDEF00000' then
    Self.SetFieldValueAsString('FinishedBy_ID', mUser_ID);
end;


begin
end.