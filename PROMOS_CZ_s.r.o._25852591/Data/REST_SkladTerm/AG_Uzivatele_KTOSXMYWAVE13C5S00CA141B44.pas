uses
  'REST_SkladTerm.U_Const',
  'REST_SkladTerm.U_Translation',
  'StandardUnits.U_Components',
  'StandardUnits.U_FormShow',
  'StandardUnits.U_GetId',
  'StandardUnits.U_Prava';

procedure DeleleFromTemporaryStorage(Sender: TComponent);
var
  mSiteForm: TBusRollSiteForm;
  mCount: Integer;
  mLog: TNxCustomLog;
begin
  mSiteForm := Sender.BusRollSite;

  if not Assigned(mSiteForm.CurrentObject) then
    exit;

  mLog := TNxCustomLog.Create(REST_LogName);
  try
    mCount := SQLSelectInt(mSiteForm.BaseObjectSpace,
      'select count(*)' + nxCrLf +
      'from ' + REST_TABLE_TemporaryStorage + nxCrLf +
      'where User_ID = ' + QuotedStr(mSiteForm.CurrentObject.OID ) + nxCrLf +
      '  and Status = 0'
    );

    if mCount = 0 then
      NxMessageBox(getString('reader_unblock'),
        Format(getString('reader_no_work_in_progress'), [mSiteForm.CurrentObject.GetFieldValueAsString('Name')]),
        mdInformation, mdbOk, 0, 0, False, mSiteForm.GetSiteAppForm)
    else begin
      if NxMessageBox(getString('reader_unblock'),
        Format(getString('reader_unblock_message'),
          [mSiteForm.CurrentObject.GetFieldValueAsString('Name'), mCount]),
        mdConfirm, mdbYesNo, 0, 0, False, mSiteForm.GetSiteAppForm) = mrYes then
      begin
        mSiteForm.BaseObjectSpace.SQLExecute(
          'update ' + REST_TABLE_TemporaryStorage + nxCrLf +
          'set Status = 2' + nxCrLf +
          'where User_ID = ' + QuotedStr(mSiteForm.CurrentObject.OID) + nxCrLf +
          '  and Status = 0'
        );
        mLog.WriteEventFmt(logWarning, 'Smazani rozpracovanych dokladu: uzivatel: %s, %s, smazal: %s',
          [mSiteForm.CurrentObject.OID, mSiteForm.CurrentObject.GetFieldValueAsString('Name'), NxGetActualUserID(mSiteForm.BaseObjectSpace)]);
      end;
    end;
  finally
    mLog.Free;
  end;
end;

procedure LogoutUser(Sender: TObject);
var
  mSiteForm: TBusRollSiteForm;
  mLog: TNxCustomLog;
  mCount: Integer;
begin
  mSiteForm := TComponent(Sender).BusRollSite;

  if not Assigned(mSiteForm.CurrentObject) then
    exit;

  mLog := TNxCustomLog.Create(REST_LogName);
  try
    mCount := SQLSelectInt(mSiteForm.BaseObjectSpace,
      'select count(*)' + nxCrLf +
      'from ' + REST_TABLE_LoggedUsers + nxCrLf +
      'where User_ID = ' + QuotedStr(mSiteForm.CurrentObject.OID)
    );

    // pokud neni zadny zaznam, tak zobrazim upozorneni
    if mCount < 1 then
    begin
      NxMessageBox(getString('title_service_action_logout'),
        Format(getString('message_service_action_logout_no_login'),
        [mSiteForm.CurrentObject.GetFieldValueAsString('Name')]),
        mdConfirm, mdbOk, 0, 0, False, mSiteForm.GetSiteAppForm);
      exit;
    end;

    if NxMessageBox(getString('title_service_action_logout'),
      Format(getString('message_service_action_logout'),
        [mSiteForm.CurrentObject.GetFieldValueAsString('Name')]),
      mdConfirm, mdbYesNo, 0, 0, False, mSiteForm.GetSiteAppForm) = mrYes then
    begin
      mSiteForm.BaseObjectSpace.SQLExecute(
        'delete from ' + REST_TABLE_LoggedUsers + nxCrLf +
        'where User_ID = ' + QuotedStr(mSiteForm.CurrentObject.OID)
      );
      mLog.WriteEventFmt(logWarning, 'Servisni odhlaseni ze ctecky: odhlasovany: %s, %s, odhlasil: %s',
        [mSiteForm.CurrentObject.OID, mSiteForm.CurrentObject.GetFieldValueAsString('Name'), NxGetActualUserID(mSiteForm.BaseObjectSpace)]);
      NxShowSimpleMessage(getString('message_service_action_logout_success'), mSiteForm.GetSiteAppForm);
    end;
  finally
    mLog.Free;
  end;
end;

procedure MoveTemporaryStorage(Sender: TObject);
var
  mSiteForm: TBusRollSiteForm;
  mLog: TNxCustomLog;
  mCount: Integer;
  mForm: TForm;
  mPanel: TPanel;
  mScenarios: TStringList;
  mRadios: TRadioGroup;
  mLabel: TLabel;
  mSql: String;
begin
  mSiteForm := TComponent(Sender).BusRollSite;

  if not Assigned(mSiteForm.CurrentObject) then
    exit;

  mScenarios := TStringList.Create;
  mLog := TNxCustomLog.Create(REST_LogName);
  try
    mScenarios.Delimiter := ',';
    mSql :=
      'select' + nxCrLf +
      '  DataType' + nxCrLf +
      'from ' + REST_TABLE_TemporaryStorage + nxCrLf +
      'where' + nxCrLf +
      '  (Status = 0 or Status = 4)' + nxCrLf +
      '  and User_ID = ' + QuotedStr(mSiteForm.CurrentObject.OID);
    mSiteForm.BaseObjectSpace.SQLSelect(mSql, mScenarios);

    // pokud neni zadny rozpracovany, tak upozornim
    // pokud je jeden, nabidnu rovnou presun
    // pokud je vice, tak zobrazim vyber
    if mScenarios.Count = 0 then
    begin
      // neni zadny doklad
      NxShowSimpleMessage(Format(getString('reader_no_work_in_progress'), [mSiteForm.CurrentObject.GetFieldValueAsString('Name')]), mSiteForm.GetSiteAppForm);
      exit;
    end
    else if mScenarios.Count = 1 then
    begin
      // presouvam jeden
      if NxMessageBox(getString('button_service_action_move'),
        Format(getString('message_service_action_move_one_document'),
        [mSiteForm.CurrentObject.GetFieldValueAsString('Name'), mScenarios.Strings(0)]),
        mdConfirm, mdbYesNo, 0, 0, False, mSiteForm.GetSiteAppForm) = mrYes then
      begin
        mSql :=
          'update ' + REST_TABLE_TemporaryStorage + nxCrLf +
          'set User_ID = ' + QuotedStr(USER_KONZULTANT) + nxCrLf +
          'where' + nxCrLf +
          '  (Status = 0 or Status = 4)' + nxCrLf +
          '  and User_ID = ' + QuotedStr(mSiteForm.CurrentObject.OID);
        mSiteForm.BaseObjectSpace.SQLExecute(mSql);
        mLog.WriteEventFmt(logWarning, 'Presun rozpracovaneho dokladu: uzivatel: %s, %s, presunul: %s',
          [mSiteForm.CurrentObject.OID, mSiteForm.CurrentObject.GetFieldValueAsString('Name'), NxGetActualUserID(mSiteForm.BaseObjectSpace)]);
        NxShowSimpleMessage(getString('message_service_action_move_succes'), mSiteForm);
        exit;
      end;
    end
    else
    begin
      // vyber z rozpracovanych
      mForm := Create_FormOKCancel(mSiteForm, mPanel, getString('message_service_action_move_title'), 305, 200);

      mLabel := TLabel(mForm.FindComponent('Popisek'));
      if not Assigned(mLabel) then
      begin
        mLabel := Create_Label(mForm, mPanel, 5, 5, 300, 70, 'Popisek', Format(getString('message_service_action_move_select_document'), [mSiteForm.CurrentObject.GetFieldValueAsString('Name')]));
        mLabel.WordWrap := True;
      end;

      mRadios := TRadioGroup(mForm.FindComponent('Scenarios'));
      if not Assigned(mRadios) then
        mRadios := Create_RadioGroup(mForm, mPanel, 75, 5, 250, 'Scenarios', 'Scénáře:', mScenarios.Text)
      else
      begin
        mRadios.Items := mScenarios;
        mRadios.Height := 10 + 20 * mRadios.Items.Count
      end;
      mRadios.ItemIndex := 0;

      mForm.Height := mRadios.Height + 170;

      if mForm.ShowModal(mSiteForm) = mrOk then
      begin
        if NxMessageBox(getString('button_service_action_move'),
          Format(getString('message_service_action_move_document'),
          [mSiteForm.CurrentObject.GetFieldValueAsString('Name'), mRadios.Items.Strings(mRadios.ItemIndex)]),
          mdConfirm, mdbYesNo, 0, 0, False, mSiteForm.GetSiteAppForm) = mrYes then
        begin
          mSql :=
            'update ' + REST_TABLE_TemporaryStorage + nxCrLf +
            'set User_ID = ' + QuotedStr(USER_KONZULTANT) + nxCrLf +
            'where' + nxCrLf +
            '  (Status = 0 or Status = 4)' + nxCrLf +
            '  and User_ID = ' + QuotedStr(mSiteForm.CurrentObject.OID) + nxCrLf +
            '  and DataType = ' + QuotedStr(mRadios.Items.Strings(mRadios.ItemIndex));
          mSiteForm.BaseObjectSpace.SQLExecute(mSql);
          mLog.WriteEventFmt(logWarning, 'Presun rozpracovaneho dokladu: uzivatel: %s, %s, scenar: %s, presunul: %s',
            [mSiteForm.CurrentObject.OID, mSiteForm.CurrentObject.GetFieldValueAsString('Name'), mRadios.Items.Strings(mRadios.ItemIndex),
              NxGetActualUserID(mSiteForm.BaseObjectSpace)]);
          NxShowSimpleMessage(getString('message_service_action_move_succes'), mSiteForm);
          exit;
        end;
      end;
    end;
  finally
    mScenarios.Free;
    mLog.Free;
  end;
end;

{
Vyvolává se po vytvoření instance formuláře.
}
procedure FormCreate_Hook(Self: TSiteForm);
var
  mAction, mAction2, mAction3: TAction;
begin
  // smazani rozpracovanych dokladu
  mAction := TAction(Self.FindComponent('action_rest_unblock'));
  if mAction = nil then
  begin
    mAction := Self.GetNewAction;
    mAction.ShowControl  := True;
    mAction.ShowMenuItem := True;
    mAction.Category     := 'tabList,tabDetail';
    mAction.Caption      := getString('reader_unblock');
    mAction.Name         := 'action_rest_unblock';
    mAction.Hint         := getString('message_service_action_delete_hint');
    mAction.onExecute    := @DeleleFromTemporaryStorage;
  end;

  // presun rozpracovaneho dokladu k jinemu uzivateli
  mAction2 := TAction(Self.FindComponent('action_rest_move'));
  if mAction2 = nil then
  begin
    mAction2 := Self.GetNewAction;
    mAction2.ShowControl  := True;
    mAction2.ShowMenuItem := True;
    mAction2.Category     := 'tabList,tabDetail';
    mAction2.Caption      := getString('button_service_action_move');
    mAction2.Name         := 'action_rest_move';
    mAction2.Hint         := getString('message_service_action_move_hint');
    mAction2.onExecute    := @MoveTemporaryStorage;
  end;

  // odhlaseni uzivatele ze ctecky
  if DuplicateLoginCheck then
  begin
    mAction3 := TAction(Self.FindComponent('action_rest_logout'));
    if mAction3 = nil then
    begin
      mAction3 := Self.GetNewAction;
      mAction3.ShowControl  := True;
      mAction3.ShowMenuItem := True;
      mAction3.Category     := 'tabList,tabDetail';
      mAction3.Caption      := getString('caption_logout');
      mAction3.Hint         := getString('hint_logout');
      mAction3.name         := 'action_rest_logout';
      mAction3.onExecute    := @LogoutUser;
    end;
  end;
end;


{
Vyvolává se po provedení inicializace agendy/formuláře. V tento okamžik je již na formuláři dostupný SiteContext.
}
procedure InitSite_Hook(Self: TSiteForm);
var
  mAction, mAction2, mAction3: TAction;
begin
  if ROLE_CTECKA_SERVIS <> '' then
  begin
    if not haveActUsrRole(Self.BaseObjectSpace, ROLE_CTECKA_SERVIS, True) then
    begin
      mAction := TAction(Self.FindComponent('action_rest_unblock'));
      if Assigned(mAction) then
        mAction.Visible := False;

      mAction2 := TAction(Self.FindComponent('action_rest_move'));
      if Assigned(mAction2) then
        mAction2.Visible := False;

      mAction3 := TAction(Self.FindComponent('action_rest_logout'));
      if Assigned(mAction3) then
        mAction3.Visible := False;
    end;
  end;
end;

begin
end.