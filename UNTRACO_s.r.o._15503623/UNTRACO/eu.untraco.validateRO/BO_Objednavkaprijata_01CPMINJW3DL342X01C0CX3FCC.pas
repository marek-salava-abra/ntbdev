{
Umožňuje ovlivnit validaci.
}
procedure Validate_Hook(Self: TNxCustomBusinessObject; var AResult: Boolean);
var
 mBool:Boolean;
begin
  self.GetOriginalValue_3('Closed',mbool);
  if not(mbool) and self.GetFieldValueAsBoolean('Closed') then begin
    if (self.GetFieldValueAsString('TransportationType_ID')='00000O1000') then
     self.SetFieldValueAsString('U_Stav_ID','5300000101')
     else self.SetFieldValueAsString('U_Stav_ID','6300000101');



  end;
end;

begin
end.