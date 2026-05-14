{
Umožňuje ovlivnit validaci.
}
procedure Validate_Hook(Self: TNxCustomBusinessObject; var AResult: Boolean);
begin
  if (CFxNxRuntime.NxGetEnvironmentType in [reOLEAutomation, reWebServices]) or (NxGetActualUserID_1(Self)='1R10000101') then begin
   if not(self.GetFieldValueAsString('JobOrdersRoutines_ID.Parent_ID.Owner_ID.Parent_ID.DocQueue_ID.Code')='VYPR') then begin
    if (self.GetFieldValueAsDateTime('FinishedAt$Date')>0) then begin
      if self.GetFieldValueAsFloat('Quantity')=0 then begin
        self.SetFieldValueAsFloat('TotalTime',0.001);
      end else begin
        self.SetFieldValueAsFloat('TotalTime',self.GetFieldValueAsFloat('Quantity')*self.GetFieldValueAsFloat('JobOrdersRoutines_ID.TAC'));
        self.SetFieldValueAsFloat('Duration',self.GetFieldValueAsFloat('Quantity')*self.GetFieldValueAsFloat('JobOrdersRoutines_ID.TAC')/3600);
      end;
    end;
   end;
  end;
end;

begin
end.