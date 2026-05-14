uses
  'eu.abra.lubi-InsolventniRejstrik.Commons',
  'eu.abra.lubi-InsolventniRejstrik.uLicence';

// aktualizace oznacenych podle webu ISIR
procedure actHTMLActualizeClick(Sender: TAction);
var
  mSite: TSiteForm;
  mList: TStringList;
  i: integer;
  s: string;
begin
  if not TestLicence(cIsVisual, s) then exit;
  mSite:= Sender.Site;
  if mSite <> nil then begin
    if CdConfirmMessageBox_YesRes('Insolvenční rejstřík', 'Funkce je určena k aktualizaci stavu všech označených záznamů insolvence podle dotazu na web ISIR dle IČ. Přejete si funkci spustit?', mSite) then begin
      mList := TStringList.Create;
      try
        mSite.List.GetSelectedId(mList);
        for i := 0 to mList.Count - 1 do begin
          ActualizeItemFromWeb(mSite.BaseObjectSpace, mList[i]);
        end;
        ShowMessage('Aktualizace provedena.');
      finally
        mList.Free;
      end;
    end;
  end;
end;

procedure actImportClick(Sender: TAction);
var
  mSite: TSiteForm;
  mLastID: string;
  s: string;
begin
  if not TestLicence(cIsVisual, s) then exit;
  mSite:= Sender.Site;
  if mSite <> nil then
  begin
    mLastID := GetValueFromStorageOS('InsolventIndex.LastRecord', mSite.BaseObjectSpace, '');
    if mLastID = '' then
      mLastID := '0';
    if (StrToIntDef(mLastID, 0) = 0) then
      if not CdConfirmMessageBox_YesRes('Insolvenční rejstřík', 'Nebyla nalezena historie insolvenčního rejstříku.'+cCrLf+'Proveďte import historie v agendě Insolvenční rejstřík - nastavení.', mSite) then
        exit;
    ImportInsolventIndex(mSite.BaseObjectSpace, mSite);
  end;
end;

{
Vyvolává se po vytvoření instance formuláře.
}
procedure FormCreate_Hook(Self: TSiteForm);
var
  mAct, mAct2: TAction;
  mActL: TActionList;
  i: Integer;
begin
  mActL:= Self.GetMainActionList;
  // LUBI VRATIT !!!!!!!!!!!
  for i:= 0 to mActL.ActionCount - 1 do
    if (mActL.Actions[i].Name <> 'actEdit') and
       (mActL.Actions[i].Name <> 'actPrintList') and
       (mActL.Actions[i].Name <> 'actFilter') and
       (mActL.Actions[i].Name <> 'actRefresh') then
      mActL.Actions[i].Category:= 'DISABLED';

  mAct:= Self.GetNewAction;
  mAct.Name:= 'actImport';
  mAct.Caption:= 'Aktualizace ins. rejst.';
  mAct.Hint := 'Provede aktualizaci historie insolvenčního rejstříku pomocí WS.';
  mAct.Category:= 'tabList';
  mAct.OnExecute:= @actImportClick;
  
  mAct2:= Self.GetNewAction;
  mAct2.Name:= 'actWebActualize';
  mAct2.Caption:= 'WEB ISIR aktualizace';
  mAct2.Hint := 'Provede aktualizaci označených záznamů podle webu ISIR - servisní funkce';
  mAct2.Category:= 'tabList';
  mAct2.OnExecute:= @actHTMLActualizeClick;
end;

{
Vyvolává se po provedení inicializace agendy/formuláře. V tento okamžik je již na formuláři dostupný SiteContext.
}
procedure InitSite_Hook(Self: TSiteForm);
var
  mEdit: TEdit;
  mLabel: TLabel;
  mFieldDef: TFieldDef;
begin
  PrepareDatabase(Self.BaseObjectSpace);
  mLabel:= TLabel(Self.FindChildControl('lblCode'));
  if Assigned(mLabel) then
    mLabel.Caption:= 'IČ:';
  mLabel:= TLabel(Self.FindChildControl('lblName'));
  if Assigned(mLabel) then
    mLabel.Caption:= 'Příznak:';

  mEdit:= TEdit(Self.FindChildControl('edCode'));
  if Assigned(mEdit) then
  begin
    mFieldDef:= TFieldDef.Create(mEdit.DataSource.DataSet.FieldDefs, 'X_OrgIdentNumber', ftWideString, 10, False, 301);
    with mFieldDef.CreateField(mEdit.DataSource.DataSet, nil, 'XOrgIdentNumber', False) do
    begin
      ReadOnly:= False;
      Size:= 10;
      FieldName:= 'X_OrgIdentNumber';
      FieldKind:= fkData;
    end;
    mEdit.DataField:= 'X_OrgIdentNumber';
  end;
  mEdit:= TEdit(Self.FindChildControl('edName'));
  if Assigned(mEdit) then
  begin
    mEdit.DataField:= 'Code';
    mEdit.Width:= 20;
  end;
end;

begin
end.