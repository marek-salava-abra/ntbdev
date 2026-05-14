uses
  'eu.abra.mavy.LabelPrinter.API.CreatePDM';

procedure MassGenerateOnExecute(Sender: TMultiAction; Index: integer);
begin
  if Index = 0 then begin
    MassCreateDocs(Sender.DynSite, 'O3BDOKTWEFD13ACM03KIU0CLP4');
  end;
  if Index = 1 then begin
    ShowSelectedForm(Sender.DynSite, nil, 'O3BDOKTWEFD13ACM03KIU0CLP4');
  end;
end;

procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TMultiAction;
begin
  if CheckLicence(Self.SiteContext) then begin
    mAction := Self.GetNewMultiAction;
    mAction.ShowControl := True;
    mAction.ShowMenuItem := True;
    mAction.Name := 'actPDM';
    mAction.Caption := 'Vytvořit balíky';
    mAction.Items.Text := 'Hromadná tvorba balíků'#13#10'Zobrazit balíky';
    mAction.Hint := 'Funkce balíků';
    mAction.Category := 'tabList;tabDetail';
    mAction.OnExecuteItem := @MassGenerateOnExecute;
    mAction.OnUpdate := @btnOnUpdate;
  end;
end;

procedure btnOnUpdate(Sender: TMultiAction);
var
  mSite: TDynSiteForm;
begin
  mSite := Sender.DynSite;
  if Assigned(mSite) then
  begin
    // akce je k dispozici pouze v pripade, ze je v datasetu nejaky zaznam
    // a v pripade, ze neni zahajena editace
    Sender.Enabled := Not mSite.ActiveDataSet.EOF and Not mSite.Edit;
  end;
end;

begin
end.