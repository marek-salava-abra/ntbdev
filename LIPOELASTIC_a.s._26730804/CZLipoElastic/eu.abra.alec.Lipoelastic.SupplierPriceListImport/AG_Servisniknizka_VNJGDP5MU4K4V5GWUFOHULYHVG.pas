{uses 'eu.abra.alec.Lipoelastic.SupplierPriceListImport.form';

procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TMultiAction;
begin
  mAction := Self.GetNewMultiAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := 'Form test';
  mAction.Items.Add('Form test');
  //mAction.Items.Add('EKO-KOM - Obaly');
  mAction.Category := 'tabList';
  mAction.OnExecute := @actShowForm;
end;

procedure actShowForm(Sender: TComponent);
Var
  mInputStr: String;
  mDateTime: TDateTime;
  mSite: TSiteForm;
begin
  mSite:= Sender.Site;
  ShowForm(mSite, mInputStr, mDateTime);
end;
}

begin
end.