uses 'EU.Aabra.Mask.Validace.lib';

procedure Validate_Hook(Self: TNxCustomBusinessObject; var AResult: Boolean);
begin
 if not(CFxNxRuntime.NxGetEnvironmentType=reWebServices) then begin


  if (NxCreateContext_1(self).GetCompanyCache.GetUserID='Supervisor') or (NxCreateContext_1(self).GetCompanyCache.GetUserID='abraadmin') then begin
           NxShowSimpleMessage('Upozornění: Doklad je již archivován. S vaším oprávněním je možné doklad měnit',nil)  ;
  end else begin
          if not nxisemptyoid(self.GetFieldValueAsString('X_PrintReport_ID')) then begin
                AResult := False;
                Self.AddValidateError(Self.GetFieldCode('Docdate$date'), 'Faktura je již archivovaná');
          end;
  end;

  if (self.GetFieldValueAsString('PaymentType_ID')='4000000101') and (self.GetFieldValueAsFloat('Amount')- self.GetFieldValueAsFloat('DepositAmount')=0) then begin
            AResult := False;
            Self.AddValidateError(Self.GetFieldCode('PaymentType_ID'), 'Pro dobírku nemůže být cena '
                                                     +  NxFloatToIBStr((self.GetFieldValueAsFloat('Amount')- self.GetFieldValueAsFloat('DepositAmount'))));
  end;


  if (self.GetFieldValueAsString('Docqueue_ID.code')='CFVV') and (self.GetFieldValueAsFloat('Amount')<>0) then begin
            AResult := False;
            Self.AddValidateError(Self.GetFieldCode('Firm_ID'), 'Jedná se o podklad pro clo , doklad musí být s nulovou cenou ' + chr(10) +
                                                    ' nyní je ' + NxFloatToIBStr((self.GetFieldValueAsFloat('Amount'))));
  end;

 end;

end;

begin
end.