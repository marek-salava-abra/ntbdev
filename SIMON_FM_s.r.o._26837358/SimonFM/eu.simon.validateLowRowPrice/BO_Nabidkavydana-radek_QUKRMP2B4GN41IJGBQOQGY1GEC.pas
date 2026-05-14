procedure Validate_Hook(Self: TNxCustomBusinessObject; var AResult: Boolean);
var
 mPrice:Extended;
begin
 if not((NxGetActualUserID_1(self)='2V10000101') or (NxGetActualUserID_1(self)='D000000101')) then begin
  if self.GetFieldValueAsInteger('RowType')=3 then begin
    if self.GetFieldValueAsBoolean('StoreCard_ID.U_MinPriceValidate') then begin
       mPrice:=NxEvalObjectExprAsFloatDef(Self,'NxGetStoreCardUnitPriceDef('+Quotedstr(self.GetFieldValueAsString('Parent_ID.Firm_ID'))+', '+Quotedstr(self.GetFieldValueAsString('Store_ID'))
               +', ' + QuotedStr(self.GetFieldValueAsString('StoreCard_ID')) + ','+Quotedstr('1000000101')+', '+Quotedstr(Self.GetFieldValueAsString('Qunit'))+',false,'+QuotedStr(self.GetFieldValueAsString('Parent_id.Currency_ID'))+','+inttostr(trunc(Date))+')',0);
        {NxShowSimpleMessage('Ceník '+FloatToStr(mPrice)+#13+#10+
                            'Výpočet '+FloatToStr((mprice*((100-self.GetFieldValueAsFloat('StoreCard_ID.U_procentoMax'))/100)))+#13+#10+
                            'Řádek jednotková '+ FloatToStr((self.GetFieldValueAsFloat('TamountWithoutVat')/self.GetFieldValueAsFloat('UnitQuantity'))),nil); }
        if (mprice*((100-self.GetFieldValueAsFloat('StoreCard_ID.U_procentoMax'))/100))>(self.GetFieldValueAsFloat('TamountWithoutVat')/self.GetFieldValueAsFloat('UnitQuantity')) then begin
        self.AddValidateError(self.GetFieldCode('UnitPrice'),
        'Překročili jste maximální povolenou slevu pro: '+self.GetFieldValueAsString('StoreCard_ID.Code')+' '+self.GetFieldValueAsString('StoreCard_ID.Name') +' Doklad nebude uložen');
        AResult:=False;

        end;
    end;
  end;
  end;
end;


begin
end.