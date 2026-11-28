{
Vyvolává se po změně každé položky. A to pouze, pokud k této změně nedochází díky načítání objektu z databáze nebo díky vytváření kopie.
}
procedure AfterSetFieldValue_Hook(Self: TNxCustomBusinessObject; AFieldCode: Integer; AValue: TNxParameter; AOriginalValue: TNxParameter);
begin
  if (AFieldCode=self.GetFieldCode('Firm_ID')) and not(avalue.AsString=AOriginalValue.AsString) and not(NxIsEmptyOID(self.GetFieldValueAsString('Firm_ID.Currency_ID'))) then
   self.SetFieldValueAsString('U_Currency_ID',self.GetFieldValueAsString('Firm_ID.Currency_ID'));
  if (AFieldCode=self.GetFieldCode('Firm_ID')) and not(avalue.AsString=AOriginalValue.AsString) and (NxIsEmptyOID(self.GetFieldValueAsString('Firm_ID.Currency_ID'))) then
   self.SetFieldValueAsString('U_Currency_ID','0000CZK000');

  if (AFieldCode=self.GetFieldCode('Firm_ID')) and not(avalue.AsString=AOriginalValue.AsString) and not(NxIsEmptyOID(self.GetFieldValueAsString('Firm_ID.VATCountry_ID'))) then begin
    if not(self.GetFieldValueAsString('Firm_ID.VATCountry_ID.code')='CZ') then begin
     self.SetFieldValueAsInteger('TradeType',2);
     self.SetFieldValueAsString('Country_ID',self.GetFieldValueAsString('Firm_ID.VATCountry_ID'));
    end;
  end;
  if (AFieldCode=self.GetFieldCode('Firm_ID')) and not(avalue.AsString=AOriginalValue.AsString) and (NxIsEmptyOID(self.GetFieldValueAsString('Firm_ID.VATCountry_ID'))) then begin
     self.SetFieldValueAsInteger('TradeType',1);
     //self.SetFieldValueAsString('Country_ID',self.GetFieldValueAsString('Firm_ID.VATCountry_ID'));
  end;
  if (AFieldCode=self.GetFieldCode('U_Currency_ID')) and not(avalue.AsString=AOriginalValue.AsString) then
  self.SetFieldValueAsString('Currency_ID',self.GetFieldValueAsString('U_Currency_ID'));
end;



{
Umožňuje ovlivnit validaci.
}
procedure Validate_Hook(Self: TNxCustomBusinessObject; var AResult: Boolean);
var
 mRows:TNxCustomBusinessMonikerCollection;
 i:integer;
 mUser:TNxCustomBusinessObject;
begin
  mUser:=self.ObjectSpace.CreateObject(Class_SecurityUser);
  muser.load(NxGetActualUserID_1(self),nil);
    if not(muser.GetFieldValueAsBoolean('U_CenyZahranicni')) then begin
      if not(self.GetFieldValueAsString('Currency_ID')='0000CZK000') then begin
       //NxShowSimpleMessage(self.GetFieldValueAsString('Currency_ID.Code'),nil);
       mRows:=self.GetLoadedCollectionMonikerForFieldCode(self.GetFieldCode('rows'));
       for i:=0 to mrows.Count-1 do begin
        mRows.BusinessObject[i].SetFieldValueAsFloat('UnitPrice',0);
        mRows.BusinessObject[i].SetFieldValueAsFloat('TotalPrice',0);

       end;
      end;
    end;
  mUser.free;
end;

begin
end.