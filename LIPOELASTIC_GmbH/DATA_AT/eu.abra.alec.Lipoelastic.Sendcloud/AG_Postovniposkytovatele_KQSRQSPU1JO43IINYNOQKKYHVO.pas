uses '.API';

{
Vyvolává se po provedení inicializace agendy/formuláře. V tento okamžik je již na formuláři dostupný SiteContext.
}
procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TBasicAction;
begin
  mAction:= Self.GetNewAction;
  mAction.Name:= 'actSynchronizeShippingMethods';
  mAction.Caption:= '## Sync Sendcloud Ship. methods ##';
  mAction.Category:= 'tabList';
  mAction.OnExecute:= @SynchronizeShippingMethods;
end;


procedure SynchronizeShippingMethods(Sender: TComponent);
var
  mJSON: TJSONSuperObject;
  mSite: TSiteForm;
  mOS: TNxCustomObjectSpace;
  mPostProviderBO, mContentTypeBO, mPPRow: TNxCustomBusinessObject;
  mPostProviderRows: TNxCustomBusinessMonikerCollection;
  mStatusCode, mLog, mCode, mName, mPostProvider_ID, mContentType_ID: string;
  mCarrier, mCarrierName, mMethodName, mMethod_ID, mCurrentProvider_ID: string;
  mContentFound: Boolean;
  mProviderContentList: TStringList;
  i, j, k: integer;
begin
  mSite:= Sender.Site;
  mOS:= mSite.BaseObjectSpace;

  mStatusCode:= '';
  mLog:= '';

  mJSON:= TJSONSuperObject.Create;
  mProviderContentList:= TStringList.Create;
  mProviderContentList.Sorted:= True;
  mProviderContentList.Duplicates:= dupIgnore;
  try
    mJSON:= CallAPI(mOS, 'GET', 'shipping-products/?from_country=AT', mStatusCode, mLog, nil, false);

    if mStatusCode <> '200' then
    begin
      NxShowSimpleMessage('Error occured while synchronizing. Status: '+mStatusCode+' Log: '+mLog, mSite);
      exit;
    end;

    for i:= 0 to mJSON.AsArray.Length -1 do
    begin
      mCarrier:=      mJSON.AsArray.O[i].S['carrier'];
      mCarrierName:=  mJSON.AsArray.O[i].S['name'];
      //dohledám nebo založím poštovní poskytovatele
      mPostProvider_ID:= GetOrCreatePostProviderID(mOS, mCarrier, mCarrierName);

      for j:= 0 to mJSON.AsArray.O[i].A['methods'].Length -1 do
      begin
        mMethod_ID:= IntToStr(mJSON.AsArray.O[i].A['methods'].O[j].I['id']);
        mMethodName:= mJSON.AsArray.O[i].A['methods'].O[j].S['name'];
        //dohledám nebo založím obsahy pošty - pokud selžu ukončuji.
        mContentType_ID:= GetOrCreateContentTypeID(mOS, mMethod_ID, mMethodName);

        if NxIsEmptyOID(mPostProvider_ID) then
        begin
          NxShowSimpleMessage('Failed to create PostProvider. Synchronization stopped.', mSite);
          exit;
        end;

        if NxIsEmptyOID(mContentType_ID) then
        begin
          NxShowSimpleMessage('Failed to create ContentType. Synchronization stopped.', mSite);
          exit;
        end;
        //poskládám si list s ID poštovního poskytovatele a obsahu pošty
        mProviderContentList.Add(mPostProvider_ID + '=' + mContentType_ID);
      end;
    end;

    //Projdu list s párama IDček a vždy nahraju poskytovatele, vymažu obsah a nahraju obsah aktuální
    mCurrentProvider_ID:= '';

    try
      for i:= 0 to mProviderContentList.Count -1 do
      begin
        mPostProvider_ID:= mProviderContentList.Names[i];

        if mPostProvider_ID <> mCurrentProvider_ID then
        begin
          if Assigned(mPostProviderBO) then
          begin
            mPostProviderBO.Save;
            mPostProviderBO.Free;
          end;

          mPostProviderBO:= mOS.CreateObject(Class_PDMPostProvider);
          mPostProviderBO.Load(mPostProvider_ID, nil);

          mPostProviderRows:= mPostProviderBO.GetLoadedCollectionMonikerForFieldCode(mPostProviderBO.GetFieldCode('Rows'));
          for k:= 0 to mPostProviderRows.count -1 do
            mPostProviderRows.BusinessObject[k].MarkForDelete;

          mCurrentProvider_ID:= mPostProvider_ID;
        end;

        mPPRow:= mPostProviderRows.AddNewObject;
        mPPRow.SetFieldValueAsString('IssuedContentType_ID', mProviderContentList.ValueFromIndex[i]);
        mPPRow.SetFieldValueAsString('PriceList_ID', cPDM_PRICELIST_ID);
      end;
      if Assigned(mPostProviderBO) then
        mPostProviderBO.Save;
    finally
      mPostProviderBO.Free;
    end;

    NxShowSimpleMessage('Synchronization complete.', mSite);

  finally
    mJSON.Free;
    mProviderContentList.Free;
  end;
end;


function GetOrCreatePostProviderID(AOS: TNxCustomObjectSpace; const ACarrierCode, mCarrierName: string;):string;
var
  mBO: TNxCustomBusinessObject;
  mPostProvider_ID: string;
begin
  Result:= '';
  mPostProvider_ID:= AOS.SQLSelectFirstAsString('SELECT ID FROM PDMPostProviders WHERE Hidden = ''N'' AND Code = '+QuotedStr(ACarrierCode));

  if NxIsEmptyOID(mPostProvider_ID) then
  begin
    mBO:= AOS.CreateObject(Class_PDMPostProvider);
    try
      mBO.New;
      mBO.SetFieldValueAsString('Code', NxLeft(ACarrierCode, 10));
      mBO.SetFieldValueAsString('Name', mCarrierName);
      mBO.SetFieldValueAsString('X_SendcloudCode', ACarrierCode);
      //mBO.SetFieldValueAsBoolean('OneClosing', True);
      mBO.Save;
      mPostProvider_ID:= mBO.OID;
    finally
      mBO.Free;
    end;
  end;
  Result:= mPostProvider_ID;
end;


function GetOrCreateContentTypeID(AOS: TNxCustomObjectSpace; const AContentTypeID, mContentTypeName: string;):string;
var
  mBO: TNxCustomBusinessObject;
  mContentType_ID: string;
begin
  Result:= '';
  mContentType_ID:= AOS.SQLSelectFirstAsString('SELECT ID FROM PDMIssuedContentTypes WHERE Hidden = ''N'' AND Code = '+QuotedStr(AContentTypeID));

  if NxIsEmptyOID(mContentType_ID) then
  begin
    mBO:= AOS.CreateObject(Class_PDMIssuedContentType);
    try
      mBO.New;
      mBO.SetFieldValueAsString('Code', AContentTypeID);
      mBO.SetFieldValueAsString('Name', mContentTypeName);
      mBO.Save;
      mContentType_ID:= mBO.OID;
    finally
      mBO.Free;
    end;
  end;
  Result:= mContentType_ID;
end;



begin
end.