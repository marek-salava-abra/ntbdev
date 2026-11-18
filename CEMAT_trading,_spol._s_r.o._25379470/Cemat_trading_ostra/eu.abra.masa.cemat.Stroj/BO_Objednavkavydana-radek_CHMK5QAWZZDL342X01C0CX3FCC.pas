{
Vyvolává se po změně každé položky. A to pouze, pokud k této změně nedochází díky načítání objektu z databáze nebo díky vytváření kopie.
}
procedure AfterSetFieldValue_Hook(Self: TNxCustomBusinessObject; AFieldCode: Integer; AValue: TNxParameter; AOriginalValue: TNxParameter);
var
 mList:TStringList;
 i:Integer;
 mRows:TNxCustomBusinessMonikerCollection;
 mHeader:TNxCustomBusinessObject;
 mDate:extended;
begin
  if ((AFieldCode=Self.GetFieldCode('StoreCard_ID')) or (AFieldCode=Self.GetFieldCode('RowType')) or (AFieldCode=Self.GetFieldCode('Store_ID'))) and (self.GetFieldValueAsInteger('Posindex')>1) then begin
  mHeader:=self.GetMonikerForFieldCode(self.GetFieldCode('Parent_ID')).BusinessObject;
  mRows:=mHeader.GetLoadedCollectionMonikerForFieldCode(mHeader.GetFieldCode('Rows'));
  for i:=0 to mrows.Count-1 do begin
     if (self.GetFieldValueAsInteger('PosIndex')-1)=mrows.BusinessObject[i].GetFieldValueAsInteger('PosIndex') then mDate:=mrows.BusinessObject[i].GetFieldValueAsDateTime('X_PaymentDate');


  end;
  if mDate>0 then self.SetFieldValueAsDateTime('X_PaymentDate',mDate);

  end;
end;

begin
end.