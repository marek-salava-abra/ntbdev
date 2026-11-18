procedure PayOnChange(Sender: TObjectComboEdit);
var
 mSite:TSiteForm;
 mOS:TNxCustomObjectSpace;
 mControl: TControl;
 mDataset: TNxRowsObjectDataSet;
 mRow: TNxCustomBusinessObject;
begin
   mSite := TComponent(Sender).Site;
   if Sender.DataText='4000000101' then begin
     try
       NxShowSimpleMessage('test',mSite);
     finally
     end;
   end;
end;

procedure FindMovablePanel(AParent: TWinControl; AName: String);
var
  mControl: TControl;
begin
  mControl := NxFindChildControl(AParent, AName);
  if Assigned(mControl) then
  begin
    FindPaymentType(mControl);
  end;
end;

// Rekurze - vyhledá všechny prvky na panelu. -> Díky varantnímu formuláři -> Nejde se dostatna prvky přímo.
procedure FindPaymentType(AComponent: TComponent);
var
  i: Integer;
begin
  for i := AComponent.ComponentCount-1 downto 0 do
  begin
    FindPaymentType(AComponent.Components(i));
  end;

  if AComponent is TObjectComboEdit then
  if TObjectComboEdit(TControl(AComponent)).Enabled then  // Volej pouze u rozeditovaného dokladu
  begin
    TObjectComboEdit(TControl(AComponent)).OnChange:= @PayOnChange;
  end;
end;

{
Vyvolává se po provedení inicializace agendy/formuláře. V tento okamžik je již na formuláři dostupný SiteContext.
}
procedure InitSite_Hook(Self: TSiteForm);
begin
  FindMovablePanel(Self.GetSiteAppForm, 'mpnPaymentType_ID');
end;

begin
end.