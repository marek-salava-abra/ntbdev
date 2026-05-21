{
Vyvolává se po provedení inicializace agendy/formuláře. V tento okamžik je již na formuláři dostupný SiteContext.
}
procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TBasicAction;
begin
  mAction:= Self.GetNewAction;
  mAction.Name:= 'actCopyCountrcode';
  mAction.Caption:= '## Copy Countrycodes ##';
  mAction.Category:= 'tabList';
  mAction.OnExecute:= @CopyCountrycodes;
end;


procedure CopyCountrycodes(Sender: TComponent);
var
  mSite: TSiteForm;
  mOS: TNxCustomObjectSpace;
  mBO: TNxCustomBusinessObject;
  mList: TStringList;
  i: integer;
begin
  mSite:= Sender.Site;
  mOS:= mSite.BaseObjectSpace;

  mList:= TStringList.Create;
  try
    TBusRollSiteForm(mSite).FillListWithSelectedRows(mList);

    mBO:= mOS.CreateObject(Class_FirmOffice);
    try
      for i:= 0 to mList.Count -1 do
      begin
        mBO.Load(mList[i], nil);
        mBO.SetFieldValueAsString('Address_ID.CountryCode', mBO.GetFieldValueAsString('Parent_ID.ResidenceAddress_ID.Countrycode'));
        mBO.Save;
      end;
    finally
      mBO.Free;
    end;
  finally
    mList.Free;
  end;
end;

begin
end.