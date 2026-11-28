

procedure AfterSave_Hook(Self: TNxCustomBusinessObject);

begin
   if Self.GetFieldValueAsBoolean('EET') then
       TNxEETTurnover(Self.GetMonikerForFieldCode(Self.GetFieldCode('EETTurnover_ID')).BusinessObject).Process(nil);
end;


begin
end.
