uses
  'eu.abra.PostProviders.uConstCustomScript',
  'eu.abra.PostProviders.uPrint';

{
Vyvolává se bezprostředně po provedení softvalidace objektu.
}
procedure AfterSoftValidate_Hook(Self: TNxCustomBusinessObject);
var
  mValidateErrors: TStringList;
  i: integer;
begin
  //pro ceskou postu to nechame tak jak to je vymysleno systemove
  if (Self.GetFieldValueAsInteger('PostProvider_ID.X_PD_Driver') in [cDriverCP, cDriverNone]) then
    exit;
  //jako softvalidace je take ze vybrana provozovna neni urcena pro korespondenci, tuto chybu vsak preskakujeme
  if (not Self.GetFieldValueAsBoolean('FirmOffice_ID.MassCorrespondence')) and (Self.GetFieldValueAsInteger('TargetAddressType') = 1)then begin
    mValidateErrors := TStringList.Create;
    try
      Self.GetValidateErrors(mValidateErrors);
      i := 0;
      while i < mValidateErrors.Count do begin
        if (mValidateErrors.Names[i] = 'FirmOffice_ID') then
          mValidateErrors.Delete(i)
        else
          i:= i + 1;
      end;
      Self.ClearValidateErrors;
      for i:= 0 to mValidateErrors.Count - 1 do begin
        Self.AddValidateError(Self.GetFieldCode(mValidateErrors.Names[i]), mValidateErrors.ValueFromIndex[i]);
      end;
    finally
      mValidateErrors.Free;
    end;
  end;
end;




begin
end.