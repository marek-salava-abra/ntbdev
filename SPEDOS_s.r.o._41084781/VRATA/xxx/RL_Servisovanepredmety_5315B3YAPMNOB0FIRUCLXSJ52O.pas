procedure InFilter_Hook(Self: TNxBusinessRoll; AParams: TNxParameters; ARowCookie: integer; var AResult: Boolean);
var
  mID, mPart: string;
begin
  // Pokud existuje parametr se jmenem "Pokus" neco resime ...
  if AParams.ParamExist('Filter') then begin
    mID := Self.Package.GetKeyByName('X_ROW_ID', ARowCookie);
    mPart := AParams.ParamAsString('Filter', '');
    // Zjistime, zda nazev zakazky obsahuje znak predany v parametru Pokus
    // Pokud ano, tak tento zaznam ciselniku vyhovuje filtru.
    AResult := (Pos(mPart, mID) > 0);
  end;
end;

begin
end.