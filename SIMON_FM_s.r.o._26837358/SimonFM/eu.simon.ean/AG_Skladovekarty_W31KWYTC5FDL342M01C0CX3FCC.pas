procedure InitSite_Hook(Self: TBusRollSiteForm);
var
  mAction:TBasicAction;
begin
  if not Assigned(Self.BaseObjectSpace) then
    exit;

    mAction := Self.GetNewAction;
    mAction.ShowControl := True;
    mAction.ShowMenuItem := True;
    mAction.Caption := 'Doplní ean';
    mAction.Hint := 'Toto tlačítko doplní EAN';
    mAction.Category := 'tabList';
    mAction.OnExecute := @InsertEan;


end;

Procedure InsertEan(Sender:TComponent);
var
 mSite:TSiteForm;
 mBO, mUnit, mEAN:TNxCustomBusinessObject;
 mUnits,mEans:TNxCustomBusinessMonikerCollection;
 mEANString:String;
begin
 mSite:=TComponent(sender).BusRollSite;
 mBO:=TBusRollSiteForm(msite).CurrentObject;
 mEANString:=InputBox('Info','Sejměte EAN?','');
 if NxIsItEAN(mEANString) then begin
   mUnits:=mBO.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('StoreUnits'));
   mUnit:=mUnits.BusinessObject[0];
   mEans:=mUnit.GetLoadedCollectionMonikerForFieldCode(mUnit.GetFieldCode('StoreEANs'));
   mEAN:=mEans.AddNewObject;
   mEAN.SetFieldValueAsString('Ean',mEANString);

 end;
 if mBO.NeedSave then mBO.Save;
end;

begin
end.