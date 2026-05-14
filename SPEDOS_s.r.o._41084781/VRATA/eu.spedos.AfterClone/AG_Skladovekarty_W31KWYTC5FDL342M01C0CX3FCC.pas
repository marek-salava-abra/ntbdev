procedure _AfterCloneRec_Hook(Self: TRollSiteForm);
var
 mUnits, mEans:TNxCustomBusinessMonikerCollection;
 mUnitBO, mBO:TNxCustomBusinessObject;
 i,j:integer;
begin
  if Assigned(TBusRollSiteForm(self).CurrentObject) then begin
    mBO:=TBusRollSiteForm(self).CurrentObject;
    mUnits:=mBO.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('StoreUnits'));
    for i:=0 to mUnits.count-1 do begin
      mUnitBO:=mUnits.BusinessObject[i];
      mEans:=mUnitBO.GetLoadedCollectionMonikerForFieldCode(mUnitBO.GetFieldCode('StoreEANs'));
      for j:=0 to mEans.Count-1 do begin
       mEans.BusinessObject[j].SetFieldValueAsString('EAN','');
      end;
      mUnitBO.SetFieldValueAsString('EAN','');
    end;
    mbo.SetFieldValueAsString('EAN','');
    TBusRollSiteForm(Self).DataSet.RefreshCurrentItem;
  end;
end;

begin
end.