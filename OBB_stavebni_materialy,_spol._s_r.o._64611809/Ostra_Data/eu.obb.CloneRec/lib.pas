procedure _AfterCloneRec_Hook(Self: TDynSiteForm);
begin
  TDynSiteForm(Self).CurrentObject.SetFieldValueAsDateTime('DocDate$Date',Date);
  TDynSiteForm(self).ActiveDataSet.RefreshCurrentItem;
end;

begin
end.