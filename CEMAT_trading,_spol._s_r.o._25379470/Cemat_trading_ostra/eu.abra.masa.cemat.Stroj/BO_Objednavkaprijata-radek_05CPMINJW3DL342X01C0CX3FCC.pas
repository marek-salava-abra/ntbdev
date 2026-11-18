{
Vyvolává se po změně každé položky. A to pouze, pokud k této změně nedochází díky načítání objektu z databáze nebo díky vytváření kopie.
}
procedure AfterSetFieldValue_Hook(Self: TNxCustomBusinessObject; AFieldCode: Integer; AValue: TNxParameter; AOriginalValue: TNxParameter);
var
 mList:TStringList;
 i:Integer;
 mRows:TNxCustomBusinessMonikerCollection;
 mHeader:TNxCustomBusinessObject;
 mMachine_ID:String;
begin
  if ((AFieldCode=Self.GetFieldCode('StoreCard_ID')) or (AFieldCode=Self.GetFieldCode('RowType'))) and (self.GetFieldValueAsInteger('Posindex')>1) then begin
  mHeader:=self.GetMonikerForFieldCode(self.GetFieldCode('Parent_ID')).BusinessObject;
  mRows:=mHeader.GetLoadedCollectionMonikerForFieldCode(mHeader.GetFieldCode('Rows'));
  for i:=0 to mrows.Count-1 do begin
     if (self.GetFieldValueAsInteger('PosIndex')-1)=mrows.BusinessObject[i].GetFieldValueAsInteger('PosIndex') then mMachine_ID:=mrows.BusinessObject[i].GetFieldValueAsString('X_Machine_ID');


  end;
  if not(NxIsEmptyOID(mMachine_ID)) then self.SetFieldValueAsString('X_Machine_ID',mMachine_ID);

  end;
end;

begin
end.