{
Vyvolává se před fyzickým uložením vlastních dat objektu do databáze.
}
{
Vyvolává se před fyzickým uložením vlastních dat objektu do databáze.
}
procedure BeforeSave_Hook(Self: TNxCustomBusinessObject);
var
  mDPHIndexBO: TNxCustomBusinessObject;
  mDQBO: TNxCustomBusinessObject;
  mTempStr: String;
  mHeader: TNxCustomBusinessObject;
begin
  mHeader := TNxNotPositionedRowBusinessObject(Self).Header.BusinessObject;
  if mHeader.GetFieldValueAsBoolean('VATDocument') then begin
    mDQBO := mHeader.GetMonikerForFieldCode(mHeader.GetFieldCode('DocQueue_ID')).BusinessObject;
    mDPHIndexBO := Self.GetMonikerForFieldCode(Self.GetFieldCode('VatIndex_ID')).BusinessObject;

    if not mDQBO.GetFieldValueAsBoolean('ToAccount') then begin
      mTempStr := mDPHIndexBO.GetFieldValueAsString('X_FakeVatIndex_ID');
      if (mTempStr <> '') and (mTempStr <> '0000000000') then begin
        //odkaz na falesny VATINDEX je vyplneny
        //zazalohuju puvodni vatindex
        Self.SetFieldValueAsString('X_BackupVatIndex_ID', Self.GetFieldValueAsString('VatIndex_ID'));
        //nastavim falesny
        Self.SetFieldValueAsString('VatIndex_ID', mDPHIndexBO.GetFieldValueAsString('X_FakeVatIndex_ID'));
      end;
    end else begin
      //rada se uctuje
      //zkontroluju jestli je ulozeny zaloha vatindexu
      mTempStr := Self.GetFieldValueAsString('X_BackupVatIndex_ID');
      if (mTempStr <> '') and (mTempStr <> '0000000000') then begin
        //vatindex je zazalohovany presunu zalozni id do vatindex
        Self.SetFieldValueAsString('VatIndex_ID', Self.GetFieldValueAsString('X_BackupVatIndex_ID'));
        //vynuluju zalohu
        Self.SetFieldValueAsString('X_BackupVatIndex_ID', '');
      end;
    end;
  end;
end;

{
Umožňuje ovlivnit validaci.
}

begin
end.