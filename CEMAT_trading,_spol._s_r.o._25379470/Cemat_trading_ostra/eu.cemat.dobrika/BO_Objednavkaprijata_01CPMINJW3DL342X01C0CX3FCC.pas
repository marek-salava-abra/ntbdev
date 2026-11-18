

{
Vyvolává se po změně každé položky. A to pouze, pokud k této změně nedochází díky načítání objektu z databáze nebo díky vytváření kopie.

procedure AfterSetFieldValue_Hook(Self: TNxCustomBusinessObject; AFieldCode: Integer; AValue: TNxParameter; AOriginalValue: TNxParameter);
var
 mRowBo:TNxCustomBusinessObject;
begin
  if (AFieldCode=self.GetFieldCode('PAymenttype_ID')) and (self.GetFieldValueAsString('PaymentType_ID.Code')='D1') then begin
    if self.GetLoadedCollectionMonikerForFieldCode(self.GetFieldCode('Rows')).count=0 then begin
     mRowBo:=self.GetLoadedCollectionMonikerForFieldCode(self.GetFieldCode('Rows')).AddNewObject;
     mRowBo.SetFieldValueAsInteger('RowType',3);

    end;
  end;
end;
}
begin
end.