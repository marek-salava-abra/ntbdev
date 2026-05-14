uses
  'eu.abra.lubi-InsolventniRejstrik.Commons',
  'eu.abra.lubi-InsolventniRejstrik.uLicence';

procedure _AfterNewRec_Hook(Self: TRollSiteForm);
var
  mEdit: TEdit;
begin
  mEdit:= TEdit(Self.FindChildControl('edCode'));
  if Assigned(mEdit) then
    mEdit.Field.AsString:= cEMail;
end;

procedure _CanDelete_Hook(Self: TBusRollSiteForm; var ACanDelete: Boolean);
begin
  try
    ACanDelete := Self.CurrentObject.GetFieldValueAsString('CODE') = cEMail;
  except
    ACanDelete:= False;
  end;
  if not ACanDelete then
    NxShowSimpleMessage('Mazat lze jen položku "E-Mail".', Self);
end;

{
Vyvolá se po pohybu na hlavním datasetu.
}
procedure _MainDatasetAfterScroll_Hook(Self: TBusRollSiteForm);
var
  mLabel: TLabel;
begin
  if Assigned(Self.CurrentObject) then begin
    mLabel:= TLabel(Self.FindChildControl('lblName'));
    if Assigned(mLabel) then
      if (Self.CurrentObject.GetFieldValueAsString('CODE') = cEMail) or
         (osNew in Self.CurrentObject.State) then
        mLabel.Caption:= 'E-Mail:' else
        mLabel.Caption:= 'Hodnota:'
  end;
end;

procedure actClear(Self: TAction);
var
  mFile, mSQL: string;
  mSite: TSiteForm;
  mOS: TNxCustomObjectSpace;
  mList: TStringList;
  i: integer;
  mBO: TNxCustomBusinessObject;
  s: string;
begin
  if not TestLicence(cIsVisual, s) then exit;
  mSite:= Self.Site;
  if CdConfirmMessageBox_YesRes('Insolvenční rejstřík', 'Touto funkcí dojde k vymazání uživatelského nastavení insolvenčního rejstříku a k nastavení výchozích hodnot. Opravdu si funkci přejete provést?', mSite) then begin
    mSQL := 'delete from defrolldata where clsid = ''%s''';
    mSQL := Format(mSQl, [cCLSIDInsolventIndexSettingsBussinesObject]);
    mOS.SQLExecute(mSQL);

    SetValueToStorageOS('InsolventIndex.InitSerrings', '', mOS, '');
    SetValueToStorageOS('InsolventIndex.NewSettings', '', mOS, '');
    CreateInitRecord(mOS);
    TBusRollSiteForm(mSite).RefreshData;
  end;
end;

procedure actRecalculate(Self: TAction);
var
  mFile, mSQL, mInfoLine, mStavFinal, mStav: string;
  mSite: TSiteForm;
  mOS: TNxCustomObjectSpace;
  mList, mInfoList: TStringList;
  i, mIntStav: integer;
  mBO: TNxCustomBusinessObject;
  s: string;
begin
  if not TestLicence(cIsVisual, s) then exit;
  mSite:= Self.Site;
  if CdConfirmMessageBox_YesRes('Insolvenční rejstřík', 'Funkce je určena k aktualizaci stavu všech záznamů insolvencí v databázi. Aktualizace zabere určitý čas, proto dopručujeme funkci spouštět v době malého zatížení Abry, kdy rychlost není kritická. Opravdu si nyní aktualizaci přejete provést?', mSite) then begin
    mList := TStringList.Create;
    mInfoList := TStringList.Create;
    try
      mOS := mSite.BaseObjectSpace;
      mSQL := 'select ID from defrolldata where clsid = ''%s'' and Hidden = ''N''';
      mSQL := Format(mSQl, [cCLSIDInsolventIndexBussinesObject]);
      mOS.SQLSelect(mSQL, mList);
      for i := 0 to mList.Count - 1 do begin
        mBO := mOS.CreateObject(cCLSIDInsolventIndexBussinesObject);
        try
          ShowDebugMessage('Load OID: ' + mList.Strings[i]);
          mBO.Load(mList.Strings[i], nil);
          mInfoList.Text := mBO.GetFieldValueAsString('X_ISIRDATA');
          // stav nastavuji podle posledniho radku
          mInfoLine := mInfoList[mInfoList.Count - 1];
          ShowDebugMessage('mInfoLine: ' + mInfoLine);
          // zjisteni stavu konkursu
          mStav := CdTokenEx(mInfoLine, ';');
          mStav := CdTokenEx(mInfoLine, ';');
          mStav := CdTokenEx(mInfoLine, ';');
          mStavFinal := CdTokenEx(mStav, ':');
          mStav := NxTrim(mStav, ' ');
          ShowDebugMessage('mStav**' + mStav + '**');
          mIntStav := GetStavKonkursu(mOS, mStav);
          ShowDebugMessage('mIntStav: ' + IntToStr(mIntStav));
          if mIntStav <> mBO.GetFieldValueAsInteger('X_StavKonkursu') then begin
            mSQL := 'update DefRollData set X_StavKonkursu = %s, Code = ''%s'' where ID = ''%s''';
            if mIntStav = 2 then
              mSQL := Format(mSQL, [IntToStr(mIntStav), 'N', mList.Strings[i]])
            else
              mSQL := Format(mSQL, [IntToStr(mIntStav), 'A', mList.Strings[i]]);
            ShowDebugMessage('Update SQL: ' + mSQL);
            mOS.SQLExecute(mSQL);
          end;
        finally
          mBO.Free;
        end;
      end;
    finally
      mList.Free;
      mInfoList.Free;
    end;
    NxShowSimpleMessage('Aktualizace insolvenčního rejstříku byla úspěšně dokončena.', mSite);
  end;
end;

procedure actExport(Self: TAction);
var
  mFile: string;
  mSite: TSiteForm;
  mSaveDialog: TSaveDialog;
  s: string;
begin
  if not TestLicence(cIsVisual, s) then exit;
  mSite:= Self.Site;
  mFile:= '';
  mSaveDialog := TSaveDialog.Create(mSite);
  try
    mSaveDialog.Title := 'Insolvenční rejstřík - výběr souboru pro export historie.';
    mSaveDialog.Filter :='Export historie insolvence|*.txt';
    mSaveDialog.DefaultExt := 'txt';
    mSaveDialog.FilterIndex := 0;
    if mSaveDialog.Execute then
      mFile:= mSaveDialog.FileName;
  finally
    mSaveDialog.Free;
  end;
  if mFile <> '' then
    XExport(mSite, mFile);
end;

procedure actImport(Self: TAction);
var
  mFile, mSQL: string;
  mOS: TNxCustomObjectSpace;
  mSite: TSiteForm;
  mOpenDialog: TOpenDialog;
  s: string;
begin
  if not TestLicence(cIsVisual, s) then exit;
  mSite:= Self.Site;
  if CdConfirmMessageBox_YesRes('Insolvenční rejstřík', 'Přejete si před importem odstranit všechny stávající záznamy insolvenčního rejstříku? Doporučeno - při importu dojde k úplné aktualizaci všech položek.'+cCrLf+'Funkce slouží k prvotnímu nahrání historie rejstříku!', mSite) then begin
    mOS := mSite.BaseObjectSpace;
    mSQL := 'delete from defrolldata where clsid = ''%s''';
    mSQL := Format(mSQl, [cCLSIDInsolventIndexBussinesObject]);
    mOS.SQLExecute(mSQL);
    mSQL := 'delete from InsolvenceLinks';
    mOS.SQLExecute(mSQL);

    SetValueToStorageOS('InsolventIndexPerson.LastRecord', '0', mSite.BaseObjectSpace, ''); // lubi musi byt nula !!
  end;

  mFile:= '';
  mOpenDialog := TOpenDialog.Create(mSite);
  try
    mOpenDialog.Title := 'Insolvenční rejstřík - výběr souboru pro import historie.';
    mOpenDialog.Filter :='Import historie insolvence|*.txt';
    mOpenDialog.FilterIndex := 0;
    mOpenDialog.DefaultExt := 'txt';
    if mOpenDialog.Execute then
      mFile:= mOpenDialog.FileName;
  finally
    mOpenDialog.Free;
  end;
  if mFile <> '' then
    XImport(mSite, mFile);
end;

procedure InitSite_Hook(Self: TSiteForm);
var
  mEdit: TEdit;
  mLabel: TLabel;
  mFieldDef: TFieldDef;
  mPanel: TPanel;
  i: Integer;
  mActL: TActionList;
  mAct: TAction;
begin
  PrepareDatabase(Self.BaseObjectSpace);

  CreateInitRecord(Self.BaseObjectSpace);
  mLabel:= TLabel(Self.FindChildControl('lblName'));
  if Assigned(mLabel) then
    mLabel.Caption:= 'Hodnota:';
    
  mEdit:= TEdit(Self.FindChildControl('edCode'));
  if Assigned(mEdit) then
    mEdit.Enabled:= False;
    
  mEdit:= TEdit(Self.FindChildControl('edName'));
  if Assigned(mEdit) then
  begin
    mFieldDef:= TFieldDef.Create(mEdit.DataSource.DataSet.FieldDefs, 'U_Data', ftWideString, 200, False, 301);
    with mFieldDef.CreateField(mEdit.DataSource.DataSet, nil, 'UData', False) do
    begin
      ReadOnly:= False;
      Size:= 200;
      FieldName:= 'U_Data';
      FieldKind:= fkData;
    end;
    mEdit.DataField:= 'U_Data';
    mEdit.Anchors:= [akLeft, akTop];
    mEdit.Width:= TWinControl(mEdit.Parent).Width - mEdit.Left - 15; //250;
    mEdit.Anchors:= [akLeft, akTop, akRight];
  end;
  
  mPanel:= TPanel(Self.FindChildControl('pnUserDefinedForm'));
  if mPanel <> nil then
    mPanel.Hide;

  mActL:= Self.GetMainActionList;
  for i:= 0 to mActL.ActionCount - 1 do
  begin
    if (mActL.Actions[i].Name = 'actPrintList') or
       (mActL.Actions[i].Name = 'actClone') then
         mActL.Actions[i].Category:= 'DISABLED';
  end;
  
  mAct:= Self.GetNewAction;
  mAct.Name:= 'actExportR';
  mAct.Caption:= 'Export historie rejst.';
  mAct.Hint:= 'Export historie rejstříku do souboru.';
  mAct.Category:= 'tabList';
  mAct.OnExecute:= @actExport;
  
  mAct:= Self.GetNewAction;
  mAct.Name:= 'actImportR';
  mAct.Caption:= 'Import historie rejst.';
  mAct.Hint:= 'Import historie rejstříku ze souboru.';
  mAct.Category:= 'tabList';
  mAct.OnExecute:= @actImport;

  mAct:= Self.GetNewAction;
  mAct.Name:= 'actClear';
  mAct.Caption:= 'Vyčistit nastavení';
  mAct.Hint:= 'Vyčistí uživatelské nastavení a nastaví na implicitní hodnoty.';
  mAct.Category:= 'tabList';
  mAct.OnExecute:= @actClear;

  mAct:= Self.GetNewAction;
  mAct.Name:= 'actRecalculate';
  mAct.Caption:= 'Přepočítat z historie';
  mAct.Hint:= 'Provede přepočet dle historie.';
  mAct.Category:= 'tabList';
  mAct.OnExecute:= @actRecalculate;
end;

begin
end.