{
Aktualizace definovatelné položky X_EKO_UzavrenaDohoda při změně firmy
}
procedure _AfterSetFieldValue_Hook(Self: TNxCustomBusinessObject; AFieldCode: Integer; AValue: TNxParameter; AOriginalValue: TNxParameter);
var
  mCode: integer;
  mFeeTransferAgreement: Boolean;
  mFirmBO: TNxCustomBusinessObject;
begin
  // Změnu provádíme pouze při editaci nového záznamu
  if (osNew in Self.State) then
  begin
    // Zjistíme kód položky Firm_ID
    if not NxIsemptyOID(Self.GetFieldValueAsString('Firm_ID')) then
    begin
      mCode := Self.GetFieldCode('Firm_ID');
      // Pokud se mění položka Firm_ID
      if AFieldCode = mCode then
      begin
        mFirmBO := Self.ObjectSpace.CreateObject(Class_Firm);
        mFirmBO.Load(Self.GetFieldValueAsString('Firm_ID'), nil);
        // Z firmy si načteme hodnotu definovatelné položky X_EKO_UzavrenaDohoda
        mFeeTransferAgreement := mFirmBO.GetFieldValueAsBoolean('X_EKO_UzavrenaDohoda');
        // Hodnotu položky X_EKO_UzavrenaDohoda z firmy přeneseme na doklad
        Self.SetFieldValueAsBoolean('X_EKO_UzavrenaDohoda', mFeeTransferAgreement)
      end;
    end;
  end;
end;

begin
end.