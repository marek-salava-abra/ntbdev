procedure _AfterCloneRec_Hook(Self: TDynSiteForm);
Var
 mRows:TNxCustomBusinessMonikerCollection;
 k:Integer;
 mbo:TNxCustomBusinessObject;
begin
  mbo:=TDynSiteForm(Self).CurrentObject;
  mbo.SetFieldValueAsBoolean('U_prenos',true);
  mbo.SetFieldValueAsDateTime('U_Datum_fakturace',0);
  mbo.SetFieldValueAsInteger('U_stav',0);
  mRows:=mbo.GetLoadedCollectionMonikerForFieldCode(mbo.GetFieldCode('Rows'));
  for k:=0 to mRows.Count-1 do begin
      mRows.BusinessObject[k].SetFieldValueAsString('X_BusOrder_ID',mRows.BusinessObject[k].GetFieldValueAsString('BusOrder_ID'));

  end;
end;


begin
end.