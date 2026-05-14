
procedure _AfterNewRec_Hook(Self: TDynSiteForm);
begin
  Self.CurrentObject.SetFieldValueAsBoolean('ActualizeSuppliers',true);
  TDynSiteForm(Self).Refresh;
end;

begin
end.