{
Vyvolává se po změně každé položky. A to pouze, pokud k této změně nedochází díky načítání objektu z databáze nebo díky vytváření kopie.
}
procedure AfterSetFieldValue_Hook(Self: TNxCustomBusinessObject; AFieldCode: Integer; AValue: TNxParameter; AOriginalValue: TNxParameter);
var
 mOffices:TNxCustomBusinessMonikerCollection;
 i:integer;
begin
  if (afieldcode=self.getfieldcode('X_BusTransaction_ID')) and not(AValue.AsString=AOriginalValue.AsString) then begin
     mOffices:=self.GetLoadedCollectionMonikerForFieldCode(self.GetFieldCode('FirmOffices'));
     for i:=0 to mOffices.count-1 do begin
        if mOffices.BusinessObject[i].GetFieldValueAsBoolean('SynchronizeAddress') then mOffices.BusinessObject[i].SetFieldValueAsString('X_BusTransaction_ID',self.GetFieldValueAsString('X_BusTransaction_ID'));

     end;
  end;
end;

begin
end.