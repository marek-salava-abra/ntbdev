uses 'REST_Licence.libSecurity',
     'REST_Licence.libConst'
     ;

{
Vyvolává se před fyzickým uložením vlastních dat objektu do databáze.
}
procedure _NewWithoutIdentity_PreHook(Self: TNxCustomBusinessObject);
begin

end;

procedure BeforeSave_Hook(ASelf: TNxCustomBusinessObject);
var mHash : string;
begin
    mHash := ASelf.GetFieldValueAsString('U_GUID');
    mHash := getHASH(mHash);
    ASelf.SetFieldValueAsString('U_HASH', mHash);
end;

procedure Validate_Hook(ASelf: TNxCustomBusinessObject; var AResult: Boolean);
var
  mLicenseCount : Integer;
  mSQL: String;
  mResult : TStringList;
begin
  AResult := false;
  mLicenseCount := GetLicenceCount(ASelf.ObjectSpace);

  mResult := TStringList.Create;
  try
    mSQL := cRESTLicenseCount;
    ASelf.ObjectSpace.SQLSelect(mSql, mResult);
    if mResult.count = 1 then
    begin
      if osNew in ASelf.State then
      begin
        if (mLicenseCount >= StrToIntDef(mResult[0], 0) + 1) then
          AResult := true
      end else
      begin
        if (mLicenseCount >= StrToIntDef(mResult[0], 0)) then
          AResult := true
      end;
    end;

    if not AResult then
        ASelf.AddValidateError(ASelf.GetFieldCode('Code'), 'Nemáte dostatek licencí pro tento modul.');
  finally
    mResult.free;
  end;
end;

begin
end.