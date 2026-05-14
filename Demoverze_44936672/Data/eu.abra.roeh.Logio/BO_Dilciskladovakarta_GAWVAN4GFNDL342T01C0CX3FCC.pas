
{
Umožňuje ovlivnit validaci.
}
procedure Validate_Hook(Self: TNxCustomBusinessObject; var AResult: Boolean);

begin
    if  (not Self.GetFieldValueAsBoolean('X_AnalyzedCard')) and (Self.GetFieldValueAsString('Store_Id.X_DirectStore')= '0000000000') then begin
      AResult := False;
      Self.AddValidateError(Self.GetFieldCode('X_AnalyzedCard'), 'Dílčí skladová karta z hlevního skladu musí být analyzovaná. '+
          #13#10+'Chcete-li kartu vyřadit zcela z analýzy, změnu proveďte na hlavní kartě!');
    end;
end;

begin
end.