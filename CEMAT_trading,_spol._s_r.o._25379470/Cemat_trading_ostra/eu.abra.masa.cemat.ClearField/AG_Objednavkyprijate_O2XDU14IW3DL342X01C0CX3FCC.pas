procedure _AfterCloneRec_Hook(Self: TDynSiteForm);
begin
  TDynSiteForm(Self).CurrentObject.SetFieldValueAsDateTime('U_Cas_montaze',0);
  TDynSiteForm(Self).CurrentObject.SetFieldValueAsBoolean('U_servis_zakazka',False);
  TDynSiteForm(Self).CurrentObject.SetFieldValueAsInteger('U_Datum_lisovani',0);
  TDynSiteForm(Self).CurrentObject.SetFieldValueAsInteger('U_Misto_lisu',0);
  TDynSiteForm(Self).CurrentObject.SetFieldValueAsDateTime('U_Datum_fakturace',0);
  TDynSiteForm(Self).CurrentObject.SetFieldValueAsInteger('U_Stav',0);
  TDynSiteForm(Self).CurrentObject.SetFieldValueAsString('PaymentType_ID','1000000101');
  {TDynSiteForm(Self).CurrentObject.SetFieldValueAsString('U_name','');
  TDynSiteForm(Self).CurrentObject.SetFieldValueAsString('U_Street','');
  TDynSiteForm(Self).CurrentObject.SetFieldValueAsString('U_City_postcode','');
  TDynSiteForm(Self).CurrentObject.SetFieldValueAsString('U_postcode','');
  TDynSiteForm(Self).CurrentObject.SetFieldValueAsString('X_FirmOffice_ID','');
  TDynSiteForm(Self).CurrentObject.SetFieldValueAsString('X_Firm_ID','');}
  TDynSiteForm(self).ActiveDataSet.RefreshCurrentItem;
end;

begin
end.