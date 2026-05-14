uses
  'REST_SkladTerm.U_Const',
  'REST_SkladTerm.U_Translation',
  'StandardUnits.U_Form',
  'StandardUnits.U_FormShow',
  'StandardUnits.U_GetId',
  'StandardUnits.U_Prava',
  'REST_SkladTerm.U_API';

procedure TableButtonAction(Sender: TObject; AIndex: Integer);
var
  mSiteForm: TBusRollSiteForm;
  mOS: TNxCustomObjectSpace;
  mLog: TNxCustomLog;
  mMessage, mSql: String;
  mCount: Integer;

  function GetSql(AType: Integer): String;
  begin
    Result := '';
    case AType of
      0:
        case DB_TYPE of
          0: Result := REST_CreateTablesSql_FB;
          1: Result := REST_CreateTablesSql_MSSQL;
          2: Result := REST_CreateTablesSql_ORACLE;
        end;
      1:
        case DB_TYPE of
          0: Result := REST_DeleteTablesSql_FB;
          1: Result := REST_DeleteTablesSql_MSSQL;
          2: Result := REST_DeleteTablesSql_ORACLE;
        end;
      2:
        case DB_TYPE of
          0: Result := REST_ClearTablesSql_FB;
          1: Result := REST_ClearTablesSql_MSSQL;
          2: Result := REST_ClearTablesSql_ORACLE;
        end;
    end;
  end;

  function GetCheckExistenceSql: String;
  begin
    Result := '';
    case DB_TYPE of
      0: Result := REST_CheckTableExistenceSql_FB;
      1: Result := REST_CheckTableExistenceSql_MSSQL;
      2: Result := REST_CheckTableExistenceSql_ORACLE;
    end;
  end;
begin
  mSiteForm := TComponent(Sender).BusRollSite;

  if not Assigned(mSiteForm.CurrentObject) then
    exit;

  mOS := mSiteForm.BaseObjectSpace;

  // podle tlacitka urcuji akci
  case AIndex of
    0 : mMessage := getString('service_action_create_tables_message');
    1 : mMessage := getString('service_action_delete_tables_message');
    2 : mMessage := getString('service_action_clear_tables_message');
    else exit;
  end;

  mSql := getSql(AIndex);

  mLog := TNxCustomLog.Create(REST_LogName);
  try
    // dotaz, zda uzivatel opravdu chce provest akci
    if NxMessageBox(getString('title_service_action'), mMessage,
        mdConfirm, mdbYesNo, 0, 0, False, mSiteForm.GetSiteAppForm) = mrYes then
    begin
      // pokud jde o vytvareni, tak nejdrive zjistim, ze neexistuji
      if AIndex = 0 then
      begin
        mCount := SQLSelectInt(mOS, GetCheckExistenceSql);

        if mCount > 0 then
        begin
          NxShowSimpleMessage(getString('service_action_tables_existing'), mSiteForm);
          exit;
        end;
      end;
      mOS.SQLExecute(mSql);
      mLog.WriteEventFmt(logWarning, 'Servisni akce cislo %d, provedl: %s',
        [AIndex, NxGetActualUserID(mSiteForm.BaseObjectSpace)]);
      NxShowSimpleMessage(getString('title_service_action_success'), mSiteForm);
    end;
  finally
    mLog.Free;
  end;
end;

{
Vyvolává se po vytvoření instance formuláře.
}
procedure FormCreate_Hook(Self: TSiteForm);
var
  mAction: TMultiAction;
begin
  mAction := TMultiAction(Self.FindComponent('action_rest_tables'));
  if mAction = nil then
  begin
    mAction := Self.GetNewMultiAction;
    mAction.ShowControl   := True;
    mAction.ShowMenuItem  := True;
    mAction.Category      := 'tabList';
    mAction.Caption       := getString('service_action_create_tables_caption');
    mAction.Name          := 'action_rest_tables';
    //mAction.Hint          := getString('service_action_tables_button_hint');
    mAction.OnExecuteItem := @TableButtonAction;

    mAction.Items.Add(getString('service_action_create_tables_caption'));
    mAction.Items.Add(getString('service_action_delete_tables_caption'));
    mAction.Items.Add(getString('service_action_clear_tables_caption'));
  end;
end;


{
Vyvolává se po provedení inicializace agendy/formuláře. V tento okamžik je již na formuláři dostupný SiteContext.
}
procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TMultiAction;
begin
  if ROLE_CTECKA_SERVIS <> '' then
  begin
    if not haveActUsrRole(Self.BaseObjectSpace, ROLE_CTECKA_SERVIS, True) then
    begin
      mAction := TMultiAction(Self.FindComponent('action_rest_tables'));
      if Assigned(mAction) then
        mAction.Visible := False;
    end;
  end;
end;

begin
end.