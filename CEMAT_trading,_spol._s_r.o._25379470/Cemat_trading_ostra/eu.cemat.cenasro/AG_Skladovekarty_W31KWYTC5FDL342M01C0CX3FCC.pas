procedure _AfterCloneRec_Hook(Self: TRollSiteForm);
var
 mBO:TNxCustomBusinessObject;
begin
 mbo:=TBusRollSiteForm(Self).CurrentObject;
  mbo.SetFieldValueAsFloat('X_Price',0);
end;

begin
end.