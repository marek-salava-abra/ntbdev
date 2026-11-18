procedure _AfterCloneRec_Hook(Self: TDynSiteForm);
begin
  TDynSiteForm(self).CurrentObject.SetFieldValueAsBoolean('U_prenos',true);
end;


begin
end.