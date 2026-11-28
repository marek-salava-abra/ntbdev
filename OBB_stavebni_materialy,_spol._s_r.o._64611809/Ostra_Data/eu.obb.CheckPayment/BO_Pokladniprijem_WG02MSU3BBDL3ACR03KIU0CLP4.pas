{
Umožňuje ovlivnit validaci.
}
procedure Validate_Hook(Self: TNxCustomBusinessObject; var AResult: Boolean);
begin
  if osNew in self.State then begin
    if self.GetFieldValueAsBoolean('X_CheckPayment') and self.GetFieldValueAsBoolean('X_PayByCard') then begin
       if not(NxMessageBox('Dotaz','Zadali jste platbu kartou, skutečně úspěšně proběhla platba na částku '+NxFormatNumeric('0.00,',self.GetFieldValueAsFloat('Amount'))+' Kč na terminálu?' , mdConfirm, mdbYesNo, 0, 0, False, nil)= mrYes) then begin
       self.AddValidateError(self.GetFieldCode('X_PayByCard'),'Doklad nebyl uložen, proveďte platbu na terminálu nebo změňte způsob platby.');
       AResult:=False;
       end;

    end;
  end;
end;

begin
end.