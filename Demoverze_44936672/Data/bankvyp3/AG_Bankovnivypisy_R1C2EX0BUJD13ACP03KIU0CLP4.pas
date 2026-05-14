procedure FormCreate_Hook(Self: TSiteForm);
var
  mAction: TBasicAction;
begin
  // Vytvoříme nové tlačítko pro zadání textu do ExternalNumber
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := '## Nastavit ExternalNumber ##';
  mAction.Hint := 'Otevře dialog pro zadání textu, který bude vložen do ExternalNumber';
  mAction.Category := 'tabList';
  mAction.OnExecute := @SetExternalNumber;
end;

Procedure SetExternalNumber(sender: TComponent);
var
  mSite: TSiteForm;
  mObject: TNxCustomBusinessObject;
  mInputText: string;
begin
  mSite := TComponent(Sender).Site;
  
  // Získáme aktuální objekt
  mObject := TDynSiteForm(mSite).CurrentObject;
  
  if not NxIsEmptyOID(mObject.GetFieldValueAsString('ID')) then begin
    // Otevřeme dialog pro vstup textu
    mInputText := InputBox('Zadání ExternalNumber', 'Zadejte text pro ExternalNumber:', '');
    
    if mInputText <> '' then begin
      // Vložíme text do ExternalNumber pole
      mObject.SetFieldValueAsString('ExternalNumber', mInputText);
      mObject.Save;
      
      // Zobrazíme informaci o úspěšném uložení
      NxShowSimpleMessage('ExternalNumber byl nastaven na: ' + mInputText, mSite);
    end;
  end else begin
    NxShowSimpleMessage('Není vybrán žádný objekt', mSite);
  end;
end;

begin
end.