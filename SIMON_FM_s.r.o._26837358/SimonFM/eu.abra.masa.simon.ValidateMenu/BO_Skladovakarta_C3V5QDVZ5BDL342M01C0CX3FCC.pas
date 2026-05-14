{
Umožňuje ovlivnit validaci.
}
procedure Validate_Hook(Self: TNxCustomBusinessObject; var AResult: Boolean);
var
 mPrice:Extended;
 mCount:integer;
begin
 if CFxNxRuntime.NxGetEnvironmentType=reRuntimeExe then begin
  if self.GetFieldValueAsBoolean('U_SendToES') then begin
   mPrice:=NxEvalObjectExprAsFloatDef(Self,'NxGetStoreCardUnitPriceDef('+Quotedstr('')+', '+Quotedstr('1L00000101')
               +', ' + QuotedStr(self.OID) + ','+Quotedstr('1000000101')+', '+Quotedstr(Self.GetFieldValueAsString('MainUnitCode'))+',false,'+QuotedStr('0000CZK000')+','+inttostr(trunc(Date))+')',0);
   mCount:=self.GetLoadedCollectionMonikerForFieldCode(self.GetFieldCode('Pictures')).Count;
   //if NxGetActualUserID_1(Self)='SUPER00000' then NxShowSimpleMessage(IntToStr(mCount),nil);
   if mCount=0 then begin
     NxShowSimpleMessage('Karta eshop, nemá obrázky, prosím doplnit, karta jde uložit',nil);
     //AResult:=False;
     //self.AddValidateError(self.GetFieldCode('Name'), 'Karta eshop, nemá obrázky, prosím doplnit, karta jde uložit');
     //AResult:=True;
   end;
   if mPrice=0 then begin
     NxShowSimpleMessage('Karta eshop, Cena je nulová, prosím opravit v ceníku, karta jde uložit',nil);
     //self.AddValidateError(self.GetFieldCode('Name'), 'Karta eshop, Cena je nulová, prosím opravit v ceníku, karta jde uložit');
     //AResult:=True;
   end;
   if NxIsEmptyOID(self.GetFieldValueAsString('StoreMenuItem_ID')) then begin
     self.AddValidateError(self.GetFieldCode('StoreMenuItem_ID'), 'Karta eshop, menu není posílané na eshop');
       AResult:=False;
   end;
    if not(NxIsEmptyOID(self.GetFieldValueAsString('StoreMenuItem_ID'))) then begin
      if not(self.GetFieldValueAsBoolean('StoreMenuItem_ID.X_AES_SEND')) then begin
       self.AddValidateError(self.GetFieldCode('StoreMenuItem_ID'), 'Karta eshop, menu není posílané na eshop');
       AResult:=false;
      end;
    end;
  end;
 end;
end;

begin
end.