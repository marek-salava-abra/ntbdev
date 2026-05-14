{
Vyvolává se před fyzickým uložením vlastních dat objektu do databáze.
}
procedure BeforeSave_Hook(Self: TNxCustomBusinessObject);
var
 mQuantity, mDavka, mDiv, mMod:extended;
begin
  if (self.GetFieldValueAsFloat('StoreCard_ID.X_davka_sici')>0)
    and (self.GetFieldValueAsString('DocQueue_ID') in ['1O30000101']) then begin
    mDavka:=self.GetFieldValueAsFloat('StoreCard_ID.X_davka_sici');
    mDiv:=self.GetFieldValueAsFloat('Quantity') div mDavka;
    mMod:=self.GetFieldValueAsFloat('Quantity') mod mDavka;
    if mMod>0 then mQuantity:=(trunc(mDiv)+1)*mdavka else mQuantity:=trunc(mDiv)*mDavka;
    self.SetFieldValueAsFloat('CorrectedQuantity',mQuantity);
  end;
end;

begin
end.