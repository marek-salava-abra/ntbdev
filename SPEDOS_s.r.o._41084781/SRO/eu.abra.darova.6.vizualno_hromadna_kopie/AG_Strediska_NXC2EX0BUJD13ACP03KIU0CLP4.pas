procedure MojeCopyOnUpdate(Sender: TAction);
var
  mSite: TBusRollSiteForm;
begin
  //OutputDebugString('Jsem v OnUpdate.');
  //OutputDebugString('Sender je '+Sender.ClassName+'.');
  // Zjistime, zda je Sender typu TComponent
  // Vyhledame SiteForm (TSiteForm) na kterem je dana akce
  mSite := TComponent(Sender).BusRollSite;
  if Assigned(mSite) then begin
    // Pokud je SiteForm typu ciselnik, pretypujeme promennou
    //OutputDebugString('Nalezen nadřízený SiteForm.');
    Sender.Enabled := Not mSite.DataSet.EOF and Not mSite.Edit;
  end;
end;

procedure MojeCopyOnExecute(Sender: TObject);
var
  mSite: TBusRollSiteForm;
  mObj, mObj2: TNxCustomBusinessObject;
  i: integer;
begin
  if Sender is TComponent then begin
    //OutputDebugString('Sender je TComponent.');
    mSite := TComponent(Sender).BusRollSite;
    if Assigned(mSite) then begin
      //OutputDebugString('Nalezen nadřízený SiteForm.');
      mObj := mSite.DataSet.CurrentObject;
      try
        if Assigned(mObj) then begin
          for i := 1 to 5 do begin
            // Vytvorime klon aktuálního objektu
            mObj2 := mObj.Clone;
            try
              // Klon ulozime
              mObj2.Save;
            finally
              // Uvolnime klon z pameti
              mObj2.Free;
            end;
          end;
          ShowMessage('Byly vytvořeno 5 kopií. Občerstvěte si seznam.');
        end;
      finally
        mObj.Free;
      end;
    end;
  end;
end;

procedure MultiAkceExecuteItem(Sender: TObject; Index: integer);
begin
  ShowMessage(Format('Akce č.%d', [Index]));
end;

procedure FormCreate_Hook(Self: TSiteForm);
var
  mAction: TAction;
  mMAction: TMultiAction;
begin
  // Vytorime novou jednoduchou akci
  mAction := Self.GetNewAction;
  // Nastavime, aby se tato akce zobrazovala jako tlacitko
  mAction.ShowControl := True;
  // Nastavime, aby se tato akce zobrazila v menu
  mAction.ShowMenuItem := True;
  // Nastavime nadpis tlacitka
  mAction.Caption := '5 kopií';
  // Nastavime hint
  mAction.Hint := 'Vytvoří 5 kopií aktuálního záznamu bez editace - seznam je potřeba občerstvit';
  // Nastavime, aby se tato akce nabizela na zalozkach Seznam a Detail
  mAction.Category := 'tabDetail, tabList';
  // Nastavime udalost, ktera se vykona pri spusteni teto akce
  mAction.OnExecute := @MojeCopyOnExecute;
  // Nastavime udalost, v niz muzeme nastavovat dostupnost teho akce
  mAction.OnUpdate := @MojeCopyOnUpdate;
  
  // Vytorime novou multiakci
  mMAction := Self.GetNewMultiAction;
  mMAction.ShowControl := True;
  mMAction.ShowMenuItem := True;
  mMAction.Caption := 'Multi Akce';
  mMAction.Hint := 'Ukázková multiakce.';
  mMAction.Category := 'tabDetail, tabList';
  mMAction.OnUpdate := @MojeCopyOnUpdate;
  mMAction.OnExecuteItem := @MultiAkceExecuteItem;
  mMAction.Items.Add('První');
  mMAction.Items.Add('Druhá');
  mMAction.Items.Add('Třetí');
  mMAction.Items.Add('Čtvrtá');
end;

begin
end.