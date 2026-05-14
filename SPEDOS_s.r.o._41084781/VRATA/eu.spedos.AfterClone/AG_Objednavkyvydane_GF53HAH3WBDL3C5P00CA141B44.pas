procedure _AfterCloneRec_Hook(Self: TDynSiteForm);
begin
  Self.CurrentObject.SetFieldValueAsBoolean('Confirmed',false);
  Self.CurrentObject.SetFieldValueAsBoolean('Closed',false);
  Self.CurrentObject.SetFieldValueAsBoolean('Issued',false);
  Self.ActiveDataSet.RefreshCurrentItem;
end;

begin
end.