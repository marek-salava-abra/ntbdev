{
Umožňuje ovlivnit validaci.
}
procedure Validate_Hook(Self: TNxCustomBusinessObject; var AResult: Boolean);
begin
  if self.GetFieldValueAsBoolean('U_Zamtarif') then begin
     if NxMessageBox('Dotaz','Uživatel má zaměstnanecký tarif, opravdu uložit?' , mdConfirm, mdbYesNo, 0, 0, False, nil)= mrNo then begin
      self.AddValidateError(self.GetFieldCode('U_ZamTarif'),'Chybka');
      AResult:=False;
     end;
  end;
  if self.GetFieldValueAsBoolean('U_esim') then begin
     if NxMessageBox('Dotaz','Uživatel má E-sim, opravdu uložit?' , mdConfirm, mdbYesNo, 0, 0, False, nil)= mrNo then begin
      self.AddValidateError(self.GetFieldCode('U_esim'),'Chybka');
      AResult:=False;
     end;
  end;
end;

begin
end.