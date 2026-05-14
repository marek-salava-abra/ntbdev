
{
Umožňuje ovlivnit validaci.
}
procedure Validate_Hook(Self: TNxCustomBusinessObject; var AResult: Boolean);
var
  mSQLSelect : string;
  mList: TStrings;
  mContext: TNxContext;
begin
  if NxIsBlank(Self.GetFieldValueAsString('Code')) then begin
    AResult := False;
    Self.AddValidateError(Self.GetFieldCode('Code'), 'Položka Kód musí být vyplněna.');
  end;
  if AResult and NxIsBlank(Self.GetFieldValueAsString('Name')) then begin
    AResult := False;
    Self.AddValidateError(Self.GetFieldCode('Name'), 'Položka Název musí být vyplněna.');
  end;
  if AResult and not NxIsBlank(Self.GetFieldValueAsString('Code')) then begin
    mSQLSelect := 'SELECT Code FROM StoreCards SC WHERE SC.Hidden=''N'' and Code = '
            +'''' + Self.GetFieldValueAsString('Code') + '''' + ' and SC.ID<>' + ''''+ Self.GetFieldValueAsString('ID') +'''';

    mList := TStringList.Create;
    try
      // Protoze nejsme v agende ale v businessobjektu musime si vytvorit
      // objekt TNxContext. Taky se pak musime postarat o jeho uvolneni.
      mContext := NxCreateContext_1(Self);
      try
        mContext.SQLSelect(mSQLSelect, mList);
        AResult := not (mList.Count > 0);
      finally
        mContext.Free;
      end;
    finally
      mList.Free;
    end;
    Self.AddValidateError(Self.GetFieldCode('Name'), 'Položka Kód musí být jedinečná.');
  end;
end;

begin
end.