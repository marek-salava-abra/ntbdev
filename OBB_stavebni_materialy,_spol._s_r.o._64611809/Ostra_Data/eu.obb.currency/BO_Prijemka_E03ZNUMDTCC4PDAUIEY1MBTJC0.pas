procedure AfterSetFieldValue_Hook(Self: TNxCustomBusinessObject; AFieldCode: Integer; AValue: TNxParameter; AOriginalValue: TNxParameter);
var
 mUser:TNxCustomBusinessObject;
begin
  if (AFieldCode=self.GetFieldCode('Firm_ID')) and not(avalue.AsString=AOriginalValue.AsString) and not(NxIsEmptyOID(self.GetFieldValueAsString('Firm_ID.Currency_ID'))) then
   self.SetFieldValueAsString('Currency_ID',self.GetFieldValueAsString('Firm_ID.Currency_ID'));
  if (AFieldCode=self.GetFieldCode('Firm_ID')) and not(avalue.AsString=AOriginalValue.AsString) and not(NxIsEmptyOID(self.GetFieldValueAsString('Firm_ID.VATCountry_ID'))) then begin
     self.SetFieldValueAsInteger('TradeType',2);
     self.SetFieldValueAsString('Country_ID',self.GetFieldValueAsString('Firm_ID.VATCountry_ID'));
  end;
  if (AFieldCode=self.GetFieldCode('Firm_ID')) and not(avalue.AsString=AOriginalValue.AsString) and (NxIsEmptyOID(self.GetFieldValueAsString('Firm_ID.VATCountry_ID'))) then begin
     self.SetFieldValueAsInteger('TradeType',1);
     //self.SetFieldValueAsString('Country_ID',self.GetFieldValueAsString('Firm_ID.VATCountry_ID'));
  end;
end;



{
Umožňuje ovlivnit validaci.
}
procedure Validate_Hook(Self: TNxCustomBusinessObject; var AResult: Boolean);
var
 mRows:TNxCustomBusinessMonikerCollection;
 i:Integer;
 mUser, mRowBO:TNxCustomBusinessObject;
 mPrice:extended;
begin
 if osNew in self.state then begin
   mUser:=self.ObjectSpace.CreateObject(Class_SecurityUser);
  muser.load(NxGetActualUserID_1(self),nil);

   mRows:=Self.GetLoadedCollectionMonikerForFieldCode(self.GetFieldCode('Rows'));
   for i:=0 to mRows.Count-1 do begin
     mRowBO:=mRows.BusinessObject[i];
     mPrice:=GetPrice(self.ObjectSpace,mRowBO.GetFieldValueAsString('StoreCard_ID'),mRowBO.GetFieldValueAsString('Store_ID'));
     mPrice:=mprice*mRowBO.GetFieldValueAsFloat('StoreCard_ID.MainUnitRate');
     if (mPrice>0) and not(NxIsEmptyOID(mRowBO.GetFieldValueAsString('ProvideRow_ID')))  then begin

          if not(muser.GetFieldValueAsBoolean('U_CenyZahranicni')) then begin
            if (mRowBO.GetFieldValueAsFloat('LocalTAmount')/mRowBO.GetFieldValueAsFloat('Quantity'))>(3*mPrice) then begin
              self.AddValidateError(self.GetFieldCode('Description'),'Skladová cena na řádku '+IntToStr(mrowbo.GetFieldValueAsInteger('Posindex'))+' karta '+mRowBO.GetFieldValueAsString('StoreCard_ID.Name')+' je příliš vysoká. Pravděpodobně se jedná o špatně nastavenou měnu nebo špatně použitou skladovou kartu. Kontaktujte Terezu Bartošovou či Ivanu Schwarzovou');
              AResult:=false;
            end;
          end;
          if (muser.GetFieldValueAsBoolean('U_CenyZahranicni')) then begin
            if (mRowBO.GetFieldValueAsFloat('LocalTAmount')/mRowBO.GetFieldValueAsFloat('Quantity'))>(3*mPrice) then begin
              NxShowSimpleMessage('Skladová cena na řádku '+IntToStr(mrowbo.GetFieldValueAsInteger('Posindex'))+' karta '+mRowBO.GetFieldValueAsString('StoreCard_ID.Name')+' je příliš vysoká. Pravděpodobně se jedná o špatně nastavenou měnu nebo špatně použitou skladovou kartu. Kontaktujte Terezu Bartošovou či Ivanu Schwarzovou', nil);
              AResult:=True;
            end;
          end;
        end;

   end;
 end;
end;

function GetPrice(AOS : TNxCustomObjectSpace; AStoreCard_ID, aStore_ID : string) : Extended;
const
  cSQL = 'SELECT averagestoreprice FROM StoreSubCards WHERE StoreCard_ID=''%s'' and Store_ID=''%s'' ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    AOS.SQLSelect(Format(cSQL, [AStoreCard_ID,aStore_ID]), mList);
    if mList.Count > 0 then
      Result := StrToFloat(mList.Strings[0])
      else Result:=0;
  finally
    mList.Free;
  end;
end;

begin
end.