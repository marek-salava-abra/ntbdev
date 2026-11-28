{
Vyvolává se po změně každé položky. A to pouze, pokud k této změně nedochází díky načítání objektu z databáze nebo díky vytváření kopie.
}
procedure AfterSetFieldValue_Hook(Self: TNxCustomBusinessObject; AFieldCode: Integer; AValue: TNxParameter; AOriginalValue: TNxParameter);
var
 mList:TStringList;

begin
  if (AFieldCode=self.GetFieldCode('StoreCard_ID')) and not(AValue.AsString=AOriginalValue.AsString) then begin
   if not(NxIsEmptyOID(self.GetFieldValueAsString('Parent_id.Firm_ID'))) then begin
      mList:=TStringList.Create;
      self.ObjectSpace.SQLSelect(format('select externalspecification from subsCRIBERS where firm_id=''%s'' and storecard_id=''%s'' ',
                  [self.GetFieldValueAsString('Parent_id.Firm_ID'),self.GetFieldValueAsString('StoreCard_ID')]),mList);
      if mlist.count>0 then begin
       if UpperCase(mlist.Strings[0])='NE' Then NxShowSimpleMessage('Karta '+self.GetFieldValueAsString('StoreCard_ID.Name')+' nelze použít pro firmu '+ self.GetFieldValueAsString('Parent_id.Firm_ID.Name'),nil);
      end;
   end;
  end;
end;

begin
end.