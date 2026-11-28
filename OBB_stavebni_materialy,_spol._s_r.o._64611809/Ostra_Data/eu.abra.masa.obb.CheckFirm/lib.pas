procedure Validate_Hook(Self: TNxCustomBusinessObject; var AResult: Boolean);
var
 mFakeFirmBO, mFirmBO:TNxCustomBusinessObject;
 aErr, mOrigVAT, mFakeVAT:string;
 AProxyServer: string;
 AProxyUsername: string;
 AProxyPassword: string;
 AProxyPort: Integer;
 ACheckResult: Integer;
 ACheckResultText: string;
 ALastCheckDateTime: TDateTime;
 AMessage: string;
 AForceNewCheck: Boolean;
begin
  if (CFxNxRuntime.NxGetEnvironmentType=reRuntimeExe) and not(NxGetActualUserID_1(self)='~000001Z03') then begin
    if not(self.GetFieldValueAsString('Firm_ID') in ['1IA0000101','K200000101','#000004N1W','#00000420Z','W020000101','#7O40000101','~000006EOJ','H300000101','#000004210']) then begin
       mOrigVAT:=self.GetFieldValueAsString('Firm_ID.VATIdentNumber');
       if NxIsBlank(mOrigVAT) and not(NxIsBlank(self.GetFieldValueAsString('Firm_ID.OrgIdentNumber')))
        and (NxIsBlank(self.GetFieldValueAsString('Firm_ID.ResidenceAddress_ID.CountryCode')) or
            (self.GetFieldValueAsString('Firm_ID.ResidenceAddress_ID.CountryCode')='CZ')) then begin
         try
           mFakeFirmBO:=self.ObjectSpace.CreateObject(Class_Firm);
           mFakeFirmBO.New;
           mFakeFirmBO.prefill;
           mFakeFirmBO.SetFieldValueAsString('OrgIdentNumber',self.GetFieldValueAsString('Firm_ID.OrgIdentNumber'));
           try
            TNxFirm(mFakeFirmBO).GetARESCZData(aErr);
            CFxLog.SaveLog(NxCreateContext(self.ObjectSpace),'LS','Kontrola ARES '+self.GetFieldValueAsString('Firm_ID.OrgIdentNumber'),'Řádek 28'+NxCrlf+aErr,ltScripting,Now);
           except
             CFxLog.SaveLog(NxCreateContext(self.ObjectSpace),'LS','Chyba ARES '+self.GetFieldValueAsString('Firm_ID.OrgIdentNumber'),'Řádek 30'+NxCrlf+aErr+NxCrlf+ExceptionMessage,ltScripting,Now);
           end;
           mFakeVAT:=mFakeFirmBO.GetFieldValueAsString('VATIdentNumber');

             if not(SameText(mOrigVAT,mFakeVAT)) then begin
              AResult:=false;
              self.AddValidateError(self.GetFieldCode('Firm_ID'),'Firma je plátcem DPH, ale v Abře nemáme DPH vyplněno. Kontaktujte finanční ředitelku s žádostí o aktualizaci firmy. Doklad nemůžu uložit. '+NxCrLf+'Firma má v ARES DIČ: '+mFakeFirmBO.GetFieldValueAsString('VATIdentNumber'));
             end;
         finally
           if Assigned(mFakeFirmBO) then mFakeFirmBO.free;
         end;
      end;
     if not(NxIsBlank(mOrigVAT)) and (AnsiLeftStr(mOrigVAT,2)='CZ') then begin
       try
           mFakeFirmBO:=self.ObjectSpace.CreateObject(Class_Firm);
           mFakeFirmBO.New;
           mFakeFirmBO.prefill;
           mFakeFirmBO.SetFieldValueAsString('OrgIdentNumber',self.GetFieldValueAsString('Firm_ID.OrgIdentNumber'));
           try
            TNxFirm(mFakeFirmBO).GetARESCZData(aErr);
            CFxLog.SaveLog(NxCreateContext(self.ObjectSpace),'LS','Kontrola ARES '+self.GetFieldValueAsString('Firm_ID.OrgIdentNumber'),'Řádek 50'+NxCrlf+aErr,ltScripting,Now);
           except
             CFxLog.SaveLog(NxCreateContext(self.ObjectSpace),'LS','Chyba ARES '+self.GetFieldValueAsString('Firm_ID.OrgIdentNumber'),'Řádek 52'+NxCrlf+aErr+NxCrlf+ExceptionMessage,ltScripting,Now);
           end;
           mFakeVAT:=mFakeFirmBO.GetFieldValueAsString('VATIdentNumber');

             if not(SameText(mOrigVAT,mFakeVAT)) then begin
              AResult:=false;
              self.AddValidateError(self.GetFieldCode('Firm_ID'),'Firma není plátcem DPH, ale v Abře máme DPH vyplněno. Kontaktujte finanční ředitelku s žádostí o aktualizaci firmy.Doklad nemůžu uložit. '+NxCrLf+
                                    'Firma má v ARES DIČ: '+mFakeFirmBO.GetFieldValueAsString('VATIdentNumber')+NxCrlf+
                                    'Firma má v ABRA DIČ: '+self.GetFieldValueAsString('Firm_ID.VATIdentNumber'));
             end;
         finally
           if Assigned(mFakeFirmBO) then mFakeFirmBO.free;
         end;
     end;
   end;
  end;
end;


begin
end.