{
Zakomentovano dokud nebude funkcni
uses
  'REST_SkladTerm.U_Const',
  'REST_SkladTerm.U_Translation',
  'StandardUnits.U_DataSet',
  'StandardUnits.U_Form',
  'StandardUnits.U_FormShow',
  'StandardUnits.U_GetId',
  'StandardUnits.U_OpenDialog',
  'StandardUnits.U_Prava';

// vytvori standardni uzivatelske stavy prechody
procedure CreateStatuses(Sender: TObject; AIndex: Integer);
var
  mSiteForm: TBusRollSiteForm;
  mOS: TNxCustomObjectSpace;
  mLog: TNxCustomLog;
  mMessage, mSql, mFileName, mUSFrom_ID, mUSTo_ID, mFromStatusField, mToStatusField, mInternalStatusField, mUserStatusTable, mUserStatusCodeField,
    mUserStatusSwitchRulesTable: String;
  mCount: Integer;
  mDataset, mUserStatusDS: TMemTable;
  mErrorList: TStringList;
  mUserStatus: TNxCustomBusinessObject;
begin
  mSiteForm := TComponent(Sender).BusRollSite;

  if not Assigned(mSiteForm.CurrentObject) then
    exit;

  mOS := mSiteForm.BaseObjectSpace;

  mLog := TNxCustomLog.Create(REST_LogName);
  mDataset := TMemTable.Create(nil);
  mErrorList := TStringList.Create;
  try
    // dialog otevreni souboru
    if(not OpenDialog(mSiteForm, mFileName, 'CSV soubory (*.csv)|*.csv|Všechny soubory (*.*)|*.*')) then
      exit;

    // vyplnim dataset
    DataSet_CreataHeader(mDataset, REST_UsesStatusesImportHeader);
    DataSet_LoadFromCSV1(mFileName, mDataset, 1, 2, TEncoding.ANSI, mErrorList, ',', '.', 'A', '"', '', mSiteForm, 1, false);

    if mDataset.RecordCount <= 0 then
    begin
      NxShowSimpleMessage(getString('service_empty_import_file'), mSiteForm);
      exit;
    end;

    // kontrola ze dataset obsahuje vsechna pole
    if not DataSet_FieldExist(mDataset, REST_UserStatusesImportField_CLSID) then
      exit;
    if not DataSet_FieldExist(mDataset, REST_UserStatusesImportField_Stav) then
      exit;
    if not DataSet_FieldExist(mDataset, REST_UserStatusesImportField_InterniStav) then
      exit;
    if not DataSet_FieldExist(mDataset, REST_UserStatusesImportField_PrechodZ) then
      exit;
    if not DataSet_FieldExist(mDataset, REST_UserStatusesImportField_PrechodNa) then
      exit;

    if ABRA then
    begin
      mUserStatusCodeField := 'Code';
      mUserStatusTable := 'PMStates';
      mUserStatusSwitchRulesTable := 'PMStatesTransitions';
      mInternalStatusField := 'SystemState';
      mFromStatusField := 'FromState_ID';
      mToStatusField := 'ToState_ID';
    end
    else
    begin
      mUserStatusCodeField := 'UserStatusCode';
      mUserStatusTable := 'UserStatuses';
      mUserStatusSwitchRulesTable := 'UserStatusesSwitchRules';
      mInternalStatusField := 'InternalStatus';
      mFromStatusField := 'UserStatusesFrom_ID';
      mToStatusField := 'UserStatusesTo_ID';
    end;

    // projdu dataset a budu vytvaret uzivatelske stavy a prechody
    mDataset.First;
    while not mDataset.Eof do
    begin
      try
        if Trim(mDataset.FieldByName(REST_UserStatusesImportField_CLSID).AsString) = '' then
          RaiseException('Není vyplněno CLSID');

        mUserStatusDS := TMemTable.Create(nil);
        try
          // stav, nebo prechod?
          if Trim(mDataset.FieldByName(REST_UserStatusesImportField_Stav).AsString) <> '' then
          begin
            // nejdrive zkontroluju, ze takovy stav uz neexistuje
            mSql :=
              'select' + nxCrLf +
              '  ID as "ID", ' + mInternalStatusField + ' as "InternalStatus"' + nxCrLf +
              'from ' + mUserStatusTable + nxCrLf +
              'where' + nxCrLf +
              '  CLSID = ' + QuotedStr(Trim(mDataset.FieldByName(REST_UserStatusesImportField_CLSID).AsString)) + nxCrLf +
              '  and ' + mUserStatusCodeField + ' = ' + QuotedStr(Trim(mDataset.FieldByName(REST_UserStatusesImportField_Stav).AsString));
            mOS.SQLSelect2(mSql, mUserStatusDS);

            // neexistuje, budu vytvaret
            if not mUserStatusDS.Active then
            begin
// ABRA Start
              mUserStatus := mOS.CreateObject(Class_PMState);
// ABRA End
              try
                mUserStatus.New;
                mUserStatus.Prefill;
                mUserStatus.SetFieldValueAsString('CLSID', Trim(mDataset.FieldByName(REST_UserStatusesImportField_CLSID).AsString));
                mUserStatus.SetFieldValueAsInteger(mInternalStatusField, mDataset.FieldByName(REST_UserStatusesImportField_InterniStav).AsInteger);
                mUserStatus.SetFieldValueAsString(mUserStatusCodeField, Trim(mDataset.FieldByName(REST_UserStatusesImportField_Stav).AsString));
                mUserStatus.Save;

                mDataset.Edit;
                mDataset.FieldByName(REST_UserStatusesImportField_ID).AsString := mUserStatus.OID;
                mDataset.Post;
              finally
                mUserStatus.Free;
              end;
            end
            else
            begin
              // pokud existuje, tak budu vracet jeho ID a pripadne upozorneni, ze ma jiny Interni stav
              mUserStatusDS.First;
              mDataset.Edit;
              mDataset.FieldByName(REST_UserStatusesImportField_ID).AsString := mUserStatusDS.FieldByName('ID').AsString;
              mDataset.Post;

              if mDataset.FieldByName(REST_UserStatusesImportField_InterniStav).AsInteger <> mUserStatusDS.FieldByName('InternalStatus').AsInteger then
                RaiseException('Stav již existuje a má jiný interní stav');
            end;
          end
          else if Trim(mDataset.FieldByName(REST_UserStatusesImportField_PrechodNa).AsString) <> '' then
          begin
            // resim prechod
            // nejdrive zkontroluju, ze takovy prechod uz neexistuje
            mSql :=
              'select' + nxCrLf +
              '  USS.ID as "ID", US.ID "USFrom", US2.ID "USTo"' + nxCrLf +
              'from ' + mUserStatusSwitchRulesTable + ' USS' + nxCrLf +
              'left join ' + mUserStatusTable + ' US on US.ID = USS.' + mFromStatusField + nxCrLf +
              'left join ' + mUserStatusTable + ' US2 on US2.ID = USS.' + mToStatusField + nxCrLf +
              'where' + nxCrLf +
              '  USS.CLSID = ' + QuotedStr(Trim(mDataset.FieldByName(REST_UserStatusesImportField_CLSID).AsString)) + nxCrLf +
              '  and US2.' + mUserStatusCodeField + ' = ' + QuotedStr(Trim(mDataset.FieldByName(REST_UserStatusesImportField_PrechodNa).AsString)) + nxCrLf;

              if Trim(mDataset.FieldByName(REST_UserStatusesImportField_PrechodZ).AsString) <> '' then
                mSql := mSql + '  and US.' + mUserStatusCodeField + ' = ' + QuotedStr(Trim(mDataset.FieldByName(REST_UserStatusesImportField_PrechodZ).AsString)) + nxCrLf
              else
                mSql := mSql + '  and US.ID is null' + nxCrLf;
            mOS.SQLSelect2(mSql, mUserStatusDS);

            // neexistuje, budu vytvaret
            if not mUserStatusDS.Active then
            begin
              // dohledam ID stavu pro vyplneni
              if Trim(mDataset.FieldByName(REST_UserStatusesImportField_PrechodZ).AsString) <> '' then
              begin
                mSql :=
                  'select' + nxCrLf +
                  '  ID' + nxCrLf +
                  'from ' + mUserStatusTable + nxCrLf +
                  'where' + nxCrLf +
                  '  ' + mUserStatusCodeField + ' = ' + QuotedStr(Trim(mDataset.FieldByName(REST_UserStatusesImportField_PrechodZ).AsString));
                // ABRA ma v tabulce stavu jine CLSID - ma tam CLSID pro CustomStoreDocument, my tam mame normalne CLSID konkretniho dokladu
                if ABRA then
                  mSql := mSql +
                    '  and CLSID = ''GF1U1H4R1ZE13HS401K0LEYWLS'''
                else
                  mSql := mSql +
                    '  and CLSID = ' + QuotedStr(Trim(mDataset.FieldByName(REST_UserStatusesImportField_CLSID).AsString));
                mUSFrom_ID := SQLSelectStr(mOS, mSql);
              end
              else
                mUSFrom_ID := '';

              mSql :=
                'select' + nxCrLf +
                '  ID' + nxCrLf +
                'from ' + mUserStatusTable + nxCrLf +
                'where' + nxCrLf +
                '  ' + mUserStatusCodeField + ' = ' + QuotedStr(Trim(mDataset.FieldByName(REST_UserStatusesImportField_PrechodNa).AsString));
              // ABRA ma v tabulce stavu jine CLSID - ma tam CLSID pro CustomStoreDocument, my tam mame normalne CLSID konkretniho dokladu
              if ABRA then
                mSql := mSql +
                  '  and CLSID = ''GF1U1H4R1ZE13HS401K0LEYWLS'''
              else
                mSql := mSql +
                  '  and CLSID = ' + QuotedStr(Trim(mDataset.FieldByName(REST_UserStatusesImportField_CLSID).AsString));
              mUSTo_ID := SQLSelectStr(mOS, mSql);

// ABRA Start
              mUserStatus := mOS.CreateObject(Class_PMStatesTransition);
// ABRA End
              try
                mUserStatus.New;
                mUserStatus.Prefill;
                mUserStatus.SetFieldValueAsString('CLSID', Trim(mDataset.FieldByName(REST_UserStatusesImportField_CLSID).AsString));
                mUserStatus.SetFieldValueAsString(mFromStatusField, mUSFrom_ID);
                mUserStatus.SetFieldValueAsString(mToStatusField, mUSTo_ID);
                mUserStatus.Save;

                mDataset.Edit;
                mDataset.FieldByName(REST_UserStatusesImportField_ID).AsString := mUserStatus.OID;
                mDataset.Post;
              finally
                mUserStatus.Free;
              end;
            end
            else
            begin
              // pokud existuje, tak budu vracet jeho ID a pripadne upozorneni, ze ma jiny Interni stav
              mUserStatusDS.First;
              mDataset.Edit;
              mDataset.FieldByName(REST_UserStatusesImportField_ID).AsString := mUserStatusDS.FieldByName('ID').AsString;
              mDataset.Post;
            end;
          end
          else
            RaiseException('Není vyplněno žádné z poli: Stav, PrechodZ, PrechodNa');
        finally
          mUserStatusDS.Free;
        end;

        // pokud nebyla chyba, tak vyplnim prazdne varovani
        mDataset.Edit;
        mDataset.FieldByName(REST_UserStatusesImportField_Varovani).AsString := '';
        mDataset.Post;
      except
        mDataset.Edit;
        mDataset.FieldByName(REST_UserStatusesImportField_Varovani).AsString := ExceptionMessage;
        mDataset.Post;
      end;

      mDataset.Next;
    end;

    // ulozim vysledek
    DataSet_SaveToCSV(mDataset, ExtractFilePath(mFileName) + '\' + ExtractFileName(mFileName) + '-result.csv', True, ',');

    NxShowSimpleMessage(getString('service_import_finished'), mSiteForm);
  finally
    mLog.Free;
    mDataset.Free;
    mErrorList.Free;
  end;
end;

// Vyvolává se po vytvoření instance formuláře.
procedure FormCreate_Hook(Self: TSiteForm);
var
  mAction: TAction;
begin
  mAction := Self.GetNewAction;
  mAction.ShowControl   := True;
  mAction.ShowMenuItem  := True;
  mAction.Category      := 'tabList';
  mAction.Caption       := getString('service_action_create_statuses_caption');
  mAction.Name          := 'action_rest_create_statuses';
  mAction.Hint          := getString('service_action_create_statuses_hint');
  mAction.OnExecute     := @CreateStatuses;
end;

// Vyvolává se po provedení inicializace agendy/formuláře. V tento okamžik je již na formuláři dostupný SiteContext.
procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TAction;
begin
  if ROLE_CTECKA_SERVIS <> '' then
  begin
    if not haveActUsrRole(Self.BaseObjectSpace, ROLE_CTECKA_SERVIS, True) then
    begin
      mAction := TAction(Self.FindComponent('action_rest_create_statuses'));
      if Assigned(mAction) then
        mAction.Visible := False;
    end;
  end;
end;}

begin
end.