{
Vyvolává se po změně každé položky. A to pouze, pokud k této změně nedochází díky načítání objektu z databáze nebo díky vytváření kopie.
}
procedure AfterSetFieldValue_Hook(Self: TNxCustomBusinessObject; AFieldCode: Integer; AValue: TNxParameter; AOriginalValue: TNxParameter);
var
  mHead, mFirm : TNxCustomBusinessObject;
  mMon: TNxCustomBusinessMonikerCollection;
begin
  if (Self.GetFieldCode('StoreCard_ID') = AFieldCode) then begin
    if NxIsEmptyOID(Self.GetFieldValueAsString('BusTransaction_ID')) then begin
      mHead := Self.GetMonikerForFieldCode(Self.GetFieldCode('Parent_ID')).BusinessObject;
      mFirm := mHead.GetMonikerForFieldCode(mHead.GetFieldCode('Firm_ID')).BusinessObject;
      if not NxIsEmptyOID(mFirm.GetFieldValueAsString('U_BusTransaction_ID')) then begin
        Self.SetFieldValueAsString('BusTransaction_ID', mFirm.GetFieldValueAsString('U_BusTransaction_ID'));
      end;
    end;
  end;
end;



begin
end.