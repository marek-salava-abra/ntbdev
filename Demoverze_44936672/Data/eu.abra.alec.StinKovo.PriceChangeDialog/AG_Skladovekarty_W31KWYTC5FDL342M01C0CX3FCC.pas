uses '.lib';
{
Vyvolává se po provedení inicializace agendy/formuláře. V tento okamžik je již na formuláři dostupný SiteContext.
}
procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TBasicAction;
begin
  mAction:= Self.GetNewAction;
  mAction.Name:= 'actRecalcPrices';
  mAction.Caption:= '## Přepočet cen ##';
  mAction.Category:= 'tabList';
  mAction.OnExecute:= @RecalculatePriceForStoreCards;
end;

procedure RecalculatePriceForStoreCards(Sender: TComponent);
var
  mSite: TSiteForm;
  mOS: TNxCustomObjectSpace;
  mPriceListBO, mValidityBO, mStorePriceBO, mNewStorePriceBO, mPriceRowBO: TNxCustomBusinessObject;
  mPriceValidityRows, mPriceRows: TNxCustomBusinessMonikerCollection;
  mStoreCardsList, mPriceListIDs, mStorePriceIDs, mPriceDefIDs: TStringList;
  mCoeficient: Extended;
  mValidFromDate: TDateTime;
  mStorePriceID, mValidityID, mSP_SQL, mLog: string;
  i, j, k, m: integer;
begin
  mSite:= Sender.Site;
  mOS:= mSite.BaseObjectSpace;

  mValidityID:= '';
  mLog:= '';

  mCoeficient:= 1.0;
  mValidFromDate:= 0;
  mPriceDefIDs:= TStringList.Create;
  mPriceListIDs:= TStringList.Create;
  mStoreCardsList:= TStringList.Create;
  try
    TBusRollSiteForm(mSite).FillListWithSelectedRows(mStoreCardsList);
    //Pro vybrané karty zobrazím dialog a vrátím si vyplněné hodnoty. Ceníky, Definice, koeficient a případně platnost
    if mStoreCardsList.Count > 0 then
      ShowPriceListForm(mSite, mStoreCardsList, mPriceListIDs, mPriceDefIDs, mCoeficient, mValidFromDate);

    //Pokud není vybrán žádný ceník, pak vypínám
    if mPriceListIDs.Count = 0 then exit;

    //Pokud není vybrána žádná definice, pak beru vše
    if mPriceDefIDs.Count = 0 then
      mOS.SQLSelect('SELECT ID FROM Pricedefinitions WHERE Hidden = ''N''', mPriceDefIDs);

    //Pro vybrané ceníky procházím všechny vybrané karty
    for i:= 0 to mPriceListIDs.Count -1 do
    begin
      //Pokud je zadáno datum platnosti, měla by se zkontrolovat a založit tato platnost.

       mValidityID:= mOS.SQLSelectFirstAsString(Format('SELECT ID FROM PriceListValidities WHERE Parent_ID = ''%s'' AND ValidFromDate$DATE = %s ', [mPriceListIDs[i], FloatToStr(mValidFromDate)]));
       if NxIsEmptyOID(mValidityID) then
       begin
        mPriceListBO:= mOS.CreateObject(Class_PriceList);
        try
          mPriceListBO.Load(mPriceListIDs[i], nil);
          mPriceValidityRows:= mPriceListBO.GetLoadedCollectionMonikerForFieldCode(mPriceListBO.GetFieldCode('Rows'));
          mValidityBO:= mPriceValidityRows.AddNewObject;
          mValidityBO.SetFieldValueAsDateTime('ValidFromDate$DATE', mValidFromDate);

          mValidityID:= mValidityBO.OID;
          mPriceListBO.Save
        finally
          mPriceListBO.Free;
        end;
      end;

      for j:= 0 to mStoreCardsList.Count -1 do
      begin
        mSP_SQL:= Format(
          ' SELECT DISTINCT SP.ID FROM StorePrices SP '+
          ' JOIN StorePrices2 SP2 ON SP2.Parent_ID = SP.ID '+
          ' LEFT JOIN PriceListValidities PLV ON PLV.ID = SP.PriceListValidity_ID '+
          ' WHERE DeletedFromPriceList = ''N'' '+
          ' AND StoreCard_ID = ''%s'' '+
          ' AND SP.PriceList_ID = ''%s'' '+
          ' AND PLV.ValidFromDate$Date <= %s '+
          ' ORDER BY PLV.ValidFromDate$Date DESC',
          [mStoreCardsList[j], mPriceListIDs[i], FloatToStr(mValidFromDate)]);

        mStorePriceID:= mOS.SQLSelectFirstAsString(mSP_SQL);

        //Případ kdy je tam karta přidána pouze v prnví platnosti a nemá na sobě validitu
        if NxIsEmptyOID(mStorePriceID) then
        begin
          mSP_SQL:= Format(
          ' SELECT DISTINCT SP.ID FROM StorePrices SP '+
          ' JOIN StorePrices2 SP2 ON SP2.Parent_ID = SP.ID '+
          ' LEFT JOIN PriceListValidities PLV ON PLV.ID = SP.PriceListValidity_ID '+
          ' WHERE DeletedFromPriceList = ''N'' '+
          ' AND StoreCard_ID = ''%s'' '+
          ' AND SP.PriceList_ID = ''%s'' '+
          //' AND PLV.ValidFromDate$Date <= %s '+
          ' ORDER BY PLV.ValidFromDate$Date DESC',
          [mStoreCardsList[j], mPriceListIDs[i], FloatToStr(mValidFromDate)]);

          mStorePriceID:= mOS.SQLSelectFirstAsString(mSP_SQL);
        end;

        //NxShowSimpleMessage(mStorePriceID, mSite);

        mStorePriceBO:= mOS.CreateObject(Class_StorePrice);
        mNewStorePriceBO:= mOS.CreateObject(Class_StorePrice);
        try
          mStorePriceBO.Load(mStorePriceID, nil);
          if mStorePriceBO.GetFieldValueAsString('PriceListValidity_ID') = mValidityID then
          begin
            //NxShowSimpleMessage('PriceListValidity_ID = mValidityID', mSite);
            mPriceRows:= mStorePriceBO.GetLoadedCollectionMonikerForFieldCode(mStorePriceBO.GetFieldCode('PriceRows'));
          end else
          begin
            //NxShowSimpleMessage('NewStorePriceBO', mSite);
            mNewStorePriceBO:= mStorePriceBO.Clone;
            mNewStorePriceBO.SetFieldValueAsString('PriceListValidity_ID', mValidityID);
            mPriceRows:= mNewStorePriceBO.GetLoadedCollectionMonikerForFieldCode(mNewStorePriceBO.GetFieldCode('PriceRows'));
          end;
          for k:= 0 to mPriceRows.Count -1 do
          begin
            mPriceRowBO:= mPriceRows.BusinessObject[k];
            for m:= 0 to mPriceDefIDs.Count -1 do
            begin
              if (mPriceRowBO.GetFieldValueAsString('Price_ID') = mPriceDefIDs[m]) and (mPriceRowBO.GetFieldValueAsFloat('Amount') > 0) then
                mPriceRowBO.SetFieldValueAsFloat('Amount', mPriceRowBO.GetFieldValueAsFloat('Amount') * mCoeficient);
            end;
          end;

          mStorePriceBO.Save;
          if osNew in mNewStorePriceBO.State then
            mNewStorePriceBO.Save;
        finally
          mStorePriceBO.Free;
          mNewStorePriceBO.Free;
          mNewStorePriceBO:= nil;
        end;
      end;
    end;
    if not NxIsBlank(mLog) then
    begin
      NxShowSimpleMessage('Během přecenění došlo k chybám, ty budou nyní zobrazeny', mSite);
      NxShowEditorSite(NxCreateContext(mOS), mLog, False);
    end else
      NxShowSimpleMessage('Přecenění proběhlo úspěšně!', mSite);
  finally
    mStoreCardsList.Free;
    mPriceListIDs.Free;
    mPriceDefIDs.Free;
  end;
end;


begin
end.