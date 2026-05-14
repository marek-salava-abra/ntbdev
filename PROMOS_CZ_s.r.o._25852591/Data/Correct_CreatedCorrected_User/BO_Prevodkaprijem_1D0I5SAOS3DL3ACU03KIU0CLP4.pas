uses
  'Correct_CreatedCorrected_User.U_Func';

{
Umožňuje nastavit do Vytvořil/Změnil jiné hodnoty než aktuálně přihlášeného uživatele a aktuální čas
}
procedure _GetCreatedCorrectedUserAndDate_Hook(Self: TNxCustomBusinessObject; var AUser_ID: TNxOID; var ADateTime: TDateTime);
begin
  AUser_ID:= GetCurrentUser(Self);
end;



begin
end.