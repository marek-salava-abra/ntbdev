{
Vyvolává se před fyzickým uložením vlastních dat objektu do databáze.
}
procedure BeforeSave_Hook(Self: TNxCustomBusinessObject);
var
  mDQBO: TNxCustomBusinessObject;
  mTempStr: String;
begin
  if Self.GetFieldValueAsBoolean('VATDocument') then begin
    mDQBO := Self.GetMonikerForFieldCode(Self.GetFieldCode('DocQueue_ID')).BusinessObject;

    if not mDQBO.GetFieldValueAsBoolean('ToAccount') then begin
          if (Self.GetFieldValueAsString('VarSymbol') <> '00000000') and (Self.GetFieldValueAsString('VarSymbol') <> '') then begin
            Self.SetFieldValueAsString('X_VarSymb', Self.GetFieldValueAsString('VarSymbol'));
            Self.SetFieldValueAsString('VarSymbol', '');
            Self.SetFieldValueAsString('ExternalNumber', Self.GetFieldValueAsString('X_VarSymb'));
          end;
    end;
  end;
end;

begin
end.