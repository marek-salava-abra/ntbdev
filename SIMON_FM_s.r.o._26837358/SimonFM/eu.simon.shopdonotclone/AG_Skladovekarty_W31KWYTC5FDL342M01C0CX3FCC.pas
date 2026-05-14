procedure _AfterCloneRec_Hook(Self: TRollSiteForm);
begin
  if TBusRollSiteForm(self).CurrentObject.GetFieldValueAsBoolean('U_SendToES') then begin
    NxShowSimpleMessage('Karta eshop, nejde kopírovat, zrušte změny',Self);
    TBusRollSiteForm(self).CurrentObject.SetFieldValueAsBoolean('U_SendToES',false);
    TBusRollSiteForm(self).CurrentObject.SetFieldValueAsBoolean('X_ESCard',false);
  end;
end;

begin
end.