procedure _AfterNewRec_Hook(Self: TDynSiteForm);
begin
  Self.CurrentObject.SetFieldValueAsBoolean('ActualizeSuppliers',true);
end;

begin
end.