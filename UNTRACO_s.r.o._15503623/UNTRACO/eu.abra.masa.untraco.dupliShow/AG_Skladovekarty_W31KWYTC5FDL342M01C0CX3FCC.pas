procedure _AfterCloneRec_Hook(Self: TRollSiteForm);

begin
  TBusRollSiteForm(Self).CurrentObject.SetFieldValueAsString('StoreAssortmentGroup_ID','');
  TBusRollSiteForm(self).DataSet.RefreshCurrentItem;
end;

begin
end.