procedure AfterSetFieldValue_Hook(Self: TNxCustomBusinessObject; AFieldCode: Integer; AValue: TNxParameter; AOriginalValue: TNxParameter);
var
mCena: Extended;

begin
  if AFieldCode=self.GetFieldCode('StoreCard_ID') then begin
     if not(NxIsEmptyOID(self.GetFieldValueAsString('Storecard_ID'))) then begin
     //NxShowSimpleMessage(Self.GetFieldValueAsString('Qunit'),nil);
     //mcena:=GetPrice(self.ObjectSpace, self.GetFieldValueAsString('StoreCard_ID'), self.GetFieldValueAsString('Qunit'));
     mCena:=NxEvalObjectExprAsFloatDef(self,'NxGetStoreCardUnitPriceDef('+Quotedstr('')+', '+Quotedstr(self.GetFieldValueAsString('Store_ID'))+', ' + QuotedStr(self.GetFieldValueAsString('Storecard_ID')) + ','+Quotedstr('1000000101')+', '+Quotedstr(self.GetFieldValueAsString('Qunit'))+',false,'+QuotedStr('000CZK00000')+','+inttostr(trunc(Date))+')',0);
     mCena:=((100+Self.GetMonikerForFieldCode(self.getfieldcode('Storecard_ID')).BusinessObject.GetFieldValueAsFloat('VatRate'))/100)*mCena;
     Self.SetFieldValueAsFloat('U_cenasdph2',mCena);
     end;

   end;
   if AFieldCode=self.GetFieldCode('Qunit') then begin
     mCena:=NxEvalObjectExprAsFloatDef(self,'NxGetStoreCardUnitPriceDef('+Quotedstr('')+', '+Quotedstr(self.GetFieldValueAsString('Store_ID'))+', ' + QuotedStr(self.GetFieldValueAsString('Storecard_ID')) + ','+Quotedstr('1000000101')+', '+Quotedstr(self.GetFieldValueAsString('Qunit'))+',false,'+QuotedStr('000CZK00000')+','+inttostr(trunc(Date))+')',0);
     mCena:=((100+Self.GetMonikerForFieldCode(self.getfieldcode('Storecard_ID')).BusinessObject.GetFieldValueAsFloat('VatRate'))/100)*mCena;
     Self.SetFieldValueAsFloat('U_cenasdph2',mCena);

   end;
end;

function GetPrice(AOS : TNxCustomObjectSpace; AStorecard : string; AQunit : string) : Extended;
  const
    cSQL = 'SELECT SP2.Amount FROM StorePrices2 SP2 LEFT JOIN StorePrices SP ON SP.ID = SP2.Parent_ID WHERE SP2.Price_ID=''1000000101'' and '+
           ' SP.PriceList_ID=''1000000101'' and sp.StoreCard_ID=''%s'' and sp2.qunit=''%s'' ';

  Var
    mR : TStrings;
  begin
    Result := 0;
    mR := TStringlist.Create;
    try
      AOS.SQLSelect(Format(cSQL, [AStorecard, AQunit]), mR);
      if mR.Count > 0 then
        Result := StrToFloat(mR.strings[0]);
    finally
      mR.Free;
    end;
  end;


begin
end.