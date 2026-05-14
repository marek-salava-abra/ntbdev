uses 'EU.Aabra.Mask.Validace.lib';
const
  CLSID_SecurityUser='';

  {
Vyvolává se bezprostředně před provedením softvalidace objektu.
}
procedure BeforeSoftValidate_Hook(Self: TNxCustomBusinessObject);
begin
 { if osNew in self.State then begin
 //     if self.getFieldValueAsDateTime('X_Termin_dodani')=0 then self.SetFieldValueAsDateTime('X_Termin_dodani',Date);
  end;
  //if self.GetFieldValueAsString('X_Poznam_exp')='' then begin
        if  RightStr(self.getFieldValueAsString('X_Poznam_exp'),Length(self.GetFieldValueAsString('Firm_ID.X_Poznam_exp')))= self.GetFieldValueAsString('Firm_ID.X_Poznam_exp') then begin
        end else begin
              self.setFieldValueAsString('X_Poznam_exp', self.getFieldValueAsString('X_Poznam_exp') + ' , ' +self.GetFieldValueAsString('Firm_ID.X_Poznam_exp')) ;
        end;

  //end;

  }
end;


{
Vyvolává se poté, co se provede na objektu metoda New.
}
procedure New_Hook(Self: TNxCustomBusinessObject);
begin
  self.SetFieldValueAsBoolean('PricesWithVAT',false);
 // if self.getFieldValueAsString('Currency_ID') = '0000CZK000' then  self.SetFieldValueAsinteger('TotalRounding',(257))
 //        else self.SetFieldValueAsinteger('TotalRounding',(0)) ;

end;

procedure Prefill_Hook(Self: TNxCustomBusinessObject; AFieldCode: Integer; AValue: TNxParameter; AOriginalValue: TNxParameter);
var
mDocQueue_ID: string;


begin
  mDocQueue_ID:=(Self.GetMonikerForFieldCode(Self.GetFieldCode('CreatedBy_ID')).BusinessObject.GetFieldValueAsString('X_OP'));
  self.SetFieldValueAsBoolean('PricesWithVAT',false);
//if mDocQueue_ID<> '' then Self.SetFieldValueAsString('DocQueue_ID',mDocQueue_ID);

 //if self.getFieldValueAsString('Currency_ID') = '0000CZK000' then  self.SetFieldValueAsinteger('TotalRounding',(257))
 //        else self.SetFieldValueAsinteger('TotalRounding',(0)) ;





end;


procedure AfterSetFieldValue_Hook(Self: TNxCustomBusinessObject; AFieldCode: Integer; AValue: TNxParameter; AOriginalValue: TNxParameter);
var
  mCode,mcode1,mcode2: integer;
  mr:tstringlist;
begin
  mCode := Self.GetFieldCode('Docqueue_ID');
  mCode1 := Self.GetFieldCode('Firm_ID');
  mCode2 := Self.GetFieldCode('Currency_ID');
  // Pokud se meni polozka Nazev
  if (AFieldCode = mCode) or (AFieldCode = mCode1) then begin
  //NxShowSimpleMessage(
     if (self.GetFieldValueAsString('Docqueue_ID')='1T00000101') and (not nxisblank(self.GetFieldValueAsString('Firm_id.U_Smlouva'))) then begin
         self.SetFieldValueAsString('Externalnumber',self.GetFieldValueAsString('Firm_id.U_Smlouva'));
     end ;

       if (AFieldCode = mCode1) then begin
          self.SetFieldValueAsBoolean('IsFinancialDiscount',self.getFieldValueAsBoolean('Firm_ID.X_IsFinancialDiscount'))
       end;


  end;
  if (AFieldCode = mCode) then begin
  //NxShowSimpleMessage(
     if avalue.AsString <> AOriginalValue.AsString then begin
         self.SetFieldValueAsBoolean('PricesWithVAT',self.GetFieldValueAsBoolean('Docqueue_ID.X_PricesWithVAT'));
         if avalue.AsString='1S00000101' then begin
             if self.getFieldValueAsFloat('U_Kartony')=0 then self.setFieldValueAsFloat('U_Kartony',1)

         end;
     end
  end;




{   if (AFieldCode = mCode1) then begin
      if nxisemptyoid(self.GetFieldValueAsString('Firm_ID.VatCountry_ID')) then begin
         self.setFieldValueAsInteger('tradetype',1);
         //NxShowSimpleMessage('Neni vyplněna zeme',nil);
      end else begin
         if self.GetFieldValueAsString('Firm_ID.VatCountry_ID') = '00000CZ000' then begin
            self.setFieldValueAsInteger('TradeType',1);
            //NxShowSimpleMessage('Země je cz',nil);
         end else begin
                    //NxShowSimpleMessage(self.GetFieldValueAsString('Firm_ID.VatCountry_ID'),nil);
                   mr:=tstringlist.create;
                   try
                      self.ObjectSpace.SQLSelect('select id from countries2 where Parent_ID=' + quotedstr(self.GetFieldValueAsString('Firm_ID.VatCountry_ID'))  +  ' order by DateOfChange$Date desc',mr);

                      if mr.count=0 then begin
                             self.setFieldValueAsInteger('TradeType',3);
                            // NxShowSimpleMessage('mimo eu',nil);
                      end else begin
                        // NxShowSimpleMessage('nalezen záznam',nil);
                        // if mr.Strings[0]='A' then begin
                             self.setFieldValueAsInteger('TradeType',2);
                             //NxShowSimpleMessage('EU',nil);
                        // end;
                      end;
                   finally
                      mr.free;
                   end
         end;
      end;
  //NxShowSimpleMessage(
     //NxShowSimpleMessage('Tradetype',nil);
  end;    }

 if (AFieldCode = mCode2) then begin
  //NxShowSimpleMessage(
     if avalue.AsString = '0000CZK000' then   begin
        //NxShowSimpleMessage( avalue.AsString + ' - zaokrouhlit',nil);
        // self.SetFieldValueAsinteger('TotalRounding',(257))
         end else begin
        // self.SetFieldValueAsinteger('TotalRounding',(0)) ;
         //NxShowSimpleMessage( avalue.AsString + ' - nezaokrouhlovat',nil);
     end;

  end;
end;


begin
end.