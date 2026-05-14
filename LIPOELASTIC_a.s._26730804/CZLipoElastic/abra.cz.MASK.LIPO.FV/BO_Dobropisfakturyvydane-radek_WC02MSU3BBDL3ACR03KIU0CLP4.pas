{
Umožňuje ovlivnit validaci.
}
procedure Validate_Hook(Self: TNxCustomBusinessObject; var AResult: Boolean);
begin
    if not nxisemptyoid(self.GetFieldValueAsString('X_Duvod_vraceni')) then begin
         if self.GetFieldValueAsString('Parent_ID.ReasonDescription')='' then begin
                self.SetFieldValueAsString('Parent_ID.ReasonDescription',self.GetFieldValueAsString('X_Duvod_vraceni.Name'));
         end;

    end;

end;

begin
end.