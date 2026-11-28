{
Vyvolává se po změně každé položky. A to pouze, pokud k této změně nedochází díky načítání objektu z databáze nebo díky vytváření kopie.
}
procedure AfterSetFieldValue_Hook(Self: TNxCustomBusinessObject; AFieldCode: Integer; AValue: TNxParameter; AOriginalValue: TNxParameter);
var
 mList:TStringList;
 i:Integer;
 mRows:TNxCustomBusinessMonikerCollection;
 mHeader:TNxCustomBusinessObject;
 mStock_ID:String;
begin
  if (AFieldCode=Self.GetFieldCode('StoreCard_ID')) and (self.GetFieldValueAsInteger('Posindex')>1) then begin
  mHeader:=self.GetMonikerForFieldCode(self.GetFieldCode('Parent_ID')).BusinessObject;
  mRows:=mHeader.GetLoadedCollectionMonikerForFieldCode(mHeader.GetFieldCode('Rows'));
  for i:=0 to mrows.Count-1 do begin
     if (self.GetFieldValueAsInteger('PosIndex')-1)=mrows.BusinessObject[i].GetFieldValueAsInteger('PosIndex') then mStock_ID:=mrows.BusinessObject[i].GetFieldValueAsString('X_StockType_ID');


  end;
  if not(NxIsEmptyOID(mStock_ID)) then self.SetFieldValueAsString('X_StockType_ID',mStock_ID);

  end;
end;

begin
end.