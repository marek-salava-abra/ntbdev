{
Umožňuje ovlivnit validaci.
}
procedure Validate_Hook(Self: TNxCustomBusinessObject; var AResult: Boolean);
begin
  if nxisemptyoid(self.getfieldvalueasstring('X_E_ID')) then begin
        self.Setfieldvalueasstring('X_E_ID',self.oid)  ;
  end;
end;

begin
end.