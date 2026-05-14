procedure FormCreate_Hook(Self: TSiteForm);
var
  mAction: TBasicAction;
begin


  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := 'TWN';
  mAction.Hint := 'Doplní TWN';
  mAction.Category := 'tabList';
  mAction.OnExecute := @FillTW;

end;




procedure FillTW(Sender: TObject);
var
 msite: TSiteForm;
 mOS:TNxCustomObjectSpace;
 mRows:TNxCustomBusinessMonikerCollection;
 mAdditionalCosts:TNxCustomBusinessMonikerCollection;
 mBO, mrowBO:TNxCustomBusinessObject;
 i:Integer;
begin
 mSite:=TComponent(Sender).DynSite;
 mBO:=TDynSiteForm(msite).CurrentObject;
 if Assigned(mBO) then begin
    if NxMessageBox('Dotaz', 'Rozpustit % TWN?', mdConfirm, mdbYesNo, 0, 0, False, msite)=mrYes then begin
      mRows:=mBO.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('Rows'));
      for i:=0 to mrows.count-1 do begin
        mrowBO:=mrows.BusinessObject[i];
        mrowBO.SetFieldValueAsFloat('AdditionalCosts_ID.SpendingTaxTariff',mrowbo.GetFieldValueAsFloat('StoreCard_ID.SpendingTaxTariff'));
        mrowBO.SetFieldValueAsFloat('AdditionalCosts_ID.SpendingTaxAmount',mrowbo.GetFieldValueAsFloat('StoreCard_ID.SpendingTaxTariff')*0.01*mrowbo.GetFieldValueAsFloat('UnitPrice')*mrowbo.GetFieldValueAsFloat('Quantity'));
        mrowBO.SetFieldValueAsBoolean('AdditionalCosts_ID.SpendingTaxIsLocal',False);
        {mrowBO.SetFieldValueAsFloat('AdditionalCosts_ID.CustomsTariff',mrowbo.GetFieldValueAsFloat('StoreCard_ID.CustomsTariff'));
        mrowBO.SetFieldValueAsFloat('AdditionalCosts_ID.CustomsAmount',mrowbo.GetFieldValueAsFloat('StoreCard_ID.CustomsTariff')*0.01*mrowbo.GetFieldValueAsFloat('UnitPrice')*mrowbo.GetFieldValueAsFloat('Quantity'));
        mrowBO.SetFieldValueAsBoolean('AdditionalCosts_ID.CustomsIsLocal',False);  }
      end;
      mbo.save;
      TDynSiteForm(msite).RefreshData;
      NxShowSimpleMessage('Doplněno',msite);
    end;
 end;
end;
begin
end.