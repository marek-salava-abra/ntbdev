uses 'eu.spedos.generatepozvyp.fce';

{procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TBasicAction;
begin
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := 'Korekce';
  mAction.Hint := 'Korekce ceny';
  mAction.Category := 'tabList';
  mAction.OnExecute := @CheckRows;
end; }

Procedure CheckRows(sender:TComponent);
var
 mBO:TNxCustomBusinessObject;
 mSite:TSiteForm;
 mOS:TNxCustomObjectSpace;
 mLocalAmountWithoutVAT, mAmountWithoutVAT, mLocalAmount, mAmount:Extended;
begin
  mSite:=TComponent(sender).DynSite;
  mOS:=mSite.BaseObjectSpace;
  mBO:=TDynSiteForm(mSite).CurrentObject;
                   mAmount:=GetAmount(mOS,mBO.OID);
                   mAmountWithoutVAT:=GetAmountWithoutVAT(mOS, mBO.OID);
                   mLocalAmount:=GetLocalAmount(mOS, mBO.OID);
                   mLocalAmountWithoutVAT:=GetLocalAmountWithoutVAT(mOS,mBO.OID);
                   mBO.SetFieldValueAsFloat('Amount',mAmount+mbo.GetFieldValueAsFloat('RoundingAmount'));
                   mBO.SetFieldValueAsFloat('AmountWithoutVAT',mAmountWithoutVAT);
                   mBO.SetFieldValueAsFloat('LocalAmountWithoutVAT',mLocalAmountWithoutVAT);
                   mBO.SetFieldValueAsFloat('LocalAmount',mLocalAmount+mBO.GetFieldValueAsFloat('LocalRoundingAmount'));
  mBO.Save;
end;



begin
end.