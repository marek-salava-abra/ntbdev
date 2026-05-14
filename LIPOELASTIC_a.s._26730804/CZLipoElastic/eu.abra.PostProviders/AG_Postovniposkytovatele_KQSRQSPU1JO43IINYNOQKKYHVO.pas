uses
  'eu.abra.PostProviders.uConst',
  'eu.abra.PostProviders.uIniFile',
  'eu.abra.PostProviders.uXML',
  'eu.abra.PostProviders.uBalikobotFunc',
  'eu.abra.PostProviders.uLanguage';

{
Vyvolává se po provedení inicializace agendy/formuláře. V tento okamžik je již na formuláři dostupný SiteContext.
}
procedure InitSite_Hook(Self: TSiteForm);
begin
  if not cDebug then
    ExInitSiteImport_Hook(Self, cOnlyCreateFromXML)
  else
    ExInitSiteImport_Hook(Self, cAllXML);

  ExInitSiteCreateIniFile(Self);
end;


procedure _AfterSave_PostHook(Self: TRollSiteForm);
var mBO: TNxCustomBusinessObject;
begin
  mBO := TBusRollSiteForm(Self).CurrentObject;
  try
    mBO.Refresh;
    SettingTransfere(mBO);
  finally
    mBO.Free;
  end;
  TBusRollSiteForm(Self).RefreshData;
end;


procedure SettingTransfere(Self: TNxCustomBusinessObject);
var mMainProvider: string;
    mBOMainProvider, mBOProvider : TNxCustomBusinessObject;
    mListProviders : TStringList;
    i : Integer;
begin
  mBOMainProvider := nil;
  mListProviders := nil;
  try
    mListProviders := TStringList.Create();
    mMainProvider := GetFirstRecordFromSQL(Self.ObjectSpace,SQLGetMainProviderBB());
    if (mMainProvider <> '') and (mMainProvider = Self.OID) then
    begin
      //if TConfirmationDialog.Execute(nil, 'Přenos nastavení','Přejete si přenést nastavení do všech modulu služby Balíkobot?',0,nil) in [mrYes,mrYesToAll,mrAll] then
      if NxMessageBox(lng_msgtit_TransferConfig,lng_msg_TransferConfig ,mdConfirm,mdbYesNo,0,nil,false,nil) = mrYes then
      begin
        mBOMainProvider:= Self.ObjectSpace.CreateObject(Class_PDMPostProvider);
        mBOMainProvider.Load(mMainProvider, nil);
        Self.ObjectSpace.SQLSelect(SQLGetAllLicProviderModul(),mListProviders);
        for i:= 0 to mListProviders.Count -1 do
        begin


          if mListProviders[i] <> Self.OID then
          begin
            try
              mBOProvider := nil;
              mBOProvider:= Self.ObjectSpace.CreateObject(Class_PDMPostProvider);
              mBOProvider.Load(mListProviders[i], nil);
              mBOProvider.SetFieldValueAsString('X_PD_Export_ID',mBOMainProvider.GetFieldValueAsString('X_PD_Export_ID'));
              //mBOProvider.SetFieldValueAsString('X_PD_WS',mBOMainProvider.GetFieldValueAsString('X_PD_WS'));
              mBOProvider.SetFieldValueAsString('X_PD_WSUser',mBOMainProvider.GetFieldValueAsString('X_PD_WSUser'));
              mBOProvider.SetFieldValueAsString('X_PD_WSPass',mBOMainProvider.GetFieldValueAsString('X_PD_WSPass'));
              mBOProvider.SetFieldValueAsString('X_PD_DPD_FileDocQueue_ID',mBOMainProvider.GetFieldValueAsString('X_PD_DPD_FileDocQueue_ID'));
              mBOProvider.SetFieldValueAsString('X_PD_DPD_DocCategory_ID',mBOMainProvider.GetFieldValueAsString('X_PD_DPD_DocCategory_ID'));
              mBOProvider.SetFieldValueAsBoolean('X_PD_UseStores',mBOMainProvider.GetFieldValueAsBoolean('X_PD_UseStores'));
              mBOProvider.Save;
            finally
              if mBOProvider <> nil then
                mBOProvider.Free;
            end;
          end;
        end;
      end;

    end;
  finally
    if mListProviders <> nil then
      mListProviders.Free;
    if mBOMainProvider <> nil then
      mBOMainProvider.Free;
  end;

end;

begin
end.