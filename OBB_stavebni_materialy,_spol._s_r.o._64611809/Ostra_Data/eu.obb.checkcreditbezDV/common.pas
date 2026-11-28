const
  containerName = 'bomaContainer';
  cSQL_ZL = 'SELECT sum(ii.LocalPaidAmount-ii.LocalUsedAmount) from IssuedDInvoices ii join firms f on f.id=ii.firm_ID where (F.ID=''%s'' OR ((F.Firm_ID IS NOT NULL) AND (F.Firm_ID=''%s''))) ';
  cSQL_FV = 'SELECT sum(ii.LocalAmount-ii.localpaidamount) from issuedinvoices  ii join firms f on f.id=ii.firm_ID where (F.ID=''%s'' OR ((F.Firm_ID IS NOT NULL) AND (F.Firm_ID=''%s''))) and not (ii.id=''%s'') ';
  cSQL_DV = 'SELECT sum(ii.LocalAmount-ii.localpaidamount) from IssuedCreditNotes  ii join firms f on f.id=ii.firm_ID where (F.ID=''%s'' OR ((F.Firm_ID IS NOT NULL) AND (F.Firm_ID=''%s''))) ';
  cSQL_FP = 'SELECT sum(ri.LocalAmount-ri.localpaidamount-ri.LocalCreditAmount) from receivedinvoices ri join firms f on f.id=ri.firm_ID where (F.ID=''%s'' OR ((F.Firm_ID IS NOT NULL) AND (F.Firm_ID=''%s'')))  ';
  cSQL_DL = 'SELECT sum(SD2.LocalTAmount) from StoreDocuments sd left join StoreDocuments2 sd2 on SD2.parent_id=sd.id join firms f on f.id=sd.firm_id  where sd.IsAvailableForDelivery=''A'' and sd.documenttype=''21'' and (F.ID=''%s'' OR ((F.Firm_ID IS NOT NULL) AND (F.Firm_ID=''%s''))) ';
  cSQL_DL2 = 'SELECT sum(SD2.LocalTAmount) from StoreDocuments2 sd2 where sd2.id=''%s'' ';
  cSQL_AVP = 'SELECT averagestoreprice from storesubcards where StoreCard_ID=''%s'' and store_id=''%s'' ';

  gSQL =
  'select sum(zl) as zl, sum(fv) as fv, sum(dv) as dv, sum(fp) as fp, sum(dl) as dl, sum(dl2) as dl2 from ' + #13#10 +
  '  (select id ' + #13#10 +
  '  ,coalesce((SELECT sum(ii.LocalPaidAmount-ii.LocalUsedAmount) from dbo.IssuedDInvoices ii where ii.firm_id = f.id),0) as zl ' + #13#10 +
  '  ,coalesce((SELECT sum(ii.LocalAmount-ii.localpaidamount) from dbo.issuedinvoices  ii where f.id=ii.firm_ID and not(ii.id = ''%s'')),0) as fv ' + #13#10 +
  '  ,coalesce((SELECT sum(ii.LocalAmount-ii.localpaidamount) from dbo.IssuedCreditNotes  ii where f.id=ii.firm_ID),0) as dv ' + #13#10 +
  '  ,coalesce((SELECT sum(ri.LocalAmount-ri.localpaidamount-ri.LocalCreditAmount) from dbo.receivedinvoices ri where f.id=ri.firm_ID),0) as fp ' + #13#10 +
  '  ,coalesce((SELECT sum(SD2.LocalTAmount) from dbo.StoreDocuments sd left join dbo.StoreDocuments2 sd2 on SD2.parent_id=sd.id where f.id=sd.firm_id and sd.IsAvailableForDelivery=''A'' and sd.documenttype=''21''),0) as DL ' + #13#10 +
  '  ,coalesce((SELECT sum(SD2.LocalTAmount) from dbo.StoreDocuments sd left join dbo.StoreDocuments2 sd2 on SD2.parent_id=sd.id where f.id=sd.firm_id and sd.id in (Select distinct Provide_ID from issuedinvoices2 where parent_id = ''%s'') and sd.documenttype=''21''),0) as DL2  ' + #13#10 +
  '  from dbo.firms f ' + #13#10 +
  '  where (F.ID=''%s'' OR ((F.Firm_ID IS NOT NULL) AND (F.Firm_ID=''%s'')))) a ';

procedure AfterSiteOpen_Hook(Self: TSiteForm);
var
  mGrid: TMultiGrid;
  mPanel, mBomaPanel: TPanel;
  mButton: TSpeedButton;
  mDataset: TNxDataDataSet;
  mContainer: TNxObjectContainer;
  mUser: TNxCustomBusinessObject;
  i: Integer;
  mFirm: TNxFirmComboMovablePanel;
begin
//zaháčkování gridu
  mGrid := TMultiGrid(Self.FindChildControl('grdRows'));
  OutputDebugString('BOMA: procedure AfterSiteOpen_Hook');
  if Assigned(mGrid) then
  begin
    mGrid.DataSource.DataSet.AfterPost := @beforePostds;
    mGrid.DataSource.DataSet.AfterDelete := @beforeDeleteds;
  end;
//přidání našeho kontejneru
  mContainer := getContainer(Self, False);
  if not(Assigned(mContainer)) then
  begin
    mContainer := TNxObjectContainer.Create(Self);
    mContainer.Name := containerName;
    mUser:=Self.BaseObjectSpace.CreateObject(Class_SecurityUser);
    mUser.Load(NxGetActualUserID(Self.BaseObjectSpace),nil);
    OutputDebugString('User:' + VarToStr(mUser));
    mContainer.AddObject('currentUser', mUser);
  //tlačítko na zobrazení kreditu
    mPanel := TPanel(Self.FindChildControl('pnDetailsRowsBottom'));
    mBomaPanel := TPanel.Create(Self);
    mBomaPanel.Parent := mPanel;
    mBomaPanel.Name := 'pnBOMAPanel';
    mBomaPanel.Caption := ' ';
    mBomaPanel.Align := alRight;
    mBomaPanel.Width := 75;
    mButton := TSpeedButton.Create(Self);
    mButton.Parent := mBomaPanel;
    mButton.Name := 'sbBOMA';
    mButton.Caption := 'Kredit';
    mButton.OnClick := @sbBOMAClick;
    mButton.Align := alClient;
    mButton.Enabled := NxIsInEditMode(mGrid.DataSource.DataSet);
  end;
//ošetření změny firmy
  mFirm := TNxFirmComboMovablePanel(Self.FindChildControl('mpnFirm_ID'));
  if Assigned(mFirm) then
  begin
    mFirm.onInEditAdmit := @onFirmChange;
  end;
end;

procedure onFirmChange(Sender: TNxFirmComboMovablePanel);
var
  mContainer: TNxObjectContainer;
  mParams: TNxParameters;
  mBO: TNxCustomBusinessObject;
  mText: String;
  i: Integer;
begin
  OutputDebugString('onFirmChange');
 // if not(ARollValidationResult) then exit;
  mContainer := getContainer(Sender.Site);
  mBO := Sender.DynSite.CurrentObject;
  try
    try
      mParams := TNxParameters(mContainer.GetObject(mBO.CLSID + mBO.OID));
    except
      mParams := TNxParameters.Create;   //necháme, kdybychom opravovali stejný dokald, tak ať se nevytváří, ale pro jistotu nulujeme. Destrouy je s destroyem agendy
      mContainer.AddObject(mBO.CLSID + mBO.OID,mParams);
    end;
    fillCreditForFirm(mParams, mBO);
    mContainer.UpdateObject(mBO.CLSID + mBO.OID,mParams);
  finally
    mBO.Free;
  end;
end;

procedure _AfterEditRec_Hook(Self: TDynSiteForm);
var
  mContainer: TNxObjectContainer;
  mParams: TNxParameters;
  i: Integer;
  mBO, mRow: TNxCustomBusinessObject;
begin
  mContainer := getContainer(Self);
  if Assigned(mContainer) then
  begin
    mBO := Self.CurrentObject;
    try
      if not(NxIsEmptyOID(mBO.GetFieldValueAsString('Firm_ID'))) then
      begin
        try
          mParams := TNxParameters(mContainer.GetObject(mBO.CLSID + mBO.OID));
        except
          mParams := TNxParameters.Create;   //necháme, kdybychom opravovali stejný dokald, tak ať se nevytváří, ale pro jistotu nulujeme. Destrouy je s destroyem agendy
          mContainer.AddObject(mBO.CLSID + mBO.OID,mParams);
        end;
        fillCreditForFirm(mParams,mBO);
        mContainer.UpdateObject(mBO.CLSID + mBO.OID,mParams);
      end;
    finally
      mBO.Free;
    end;
  end else OutputDebugString('bomaContainer neexistuje');
end;

procedure fillCreditForFirm(mParams: TNxParameters; mBO: TNxCustomBusinessObject);
var
  mRow: TNxCustomBusinessObject;
  mRows: TNxCustomBusinessMonikerCollection;
  mResult: TStringList;
  mFirm_ID, mII_ID: TNxOID;
  i: Integer;
begin
  if mBO.CLSID = Class_IssuedInvoice then
    mII_ID := mBO.OID
  else
    mII_ID := '0000000000';
  mParams.GetOrCreateParam(dtFloat, 'zl', pkInputOutput).AsFloat := 0;
  mParams.GetOrCreateParam(dtFloat, 'fv', pkInputOutput).AsFloat := 0;
  mParams.GetOrCreateParam(dtFloat, 'dv', pkInputOutput).AsFloat := 0;
  mParams.GetOrCreateParam(dtFloat, 'fp', pkInputOutput).AsFloat := 0;
  mParams.GetOrCreateParam(dtFloat, 'dl', pkInputOutput).AsFloat := 0;
  mParams.GetOrCreateParam(dtFloat, 'dl2', pkInputOutput).AsFloat:= 0;
  mParams.GetOrCreateParam(dtFloat, 'credit', pkInputOutput).AsFloat := 0;

  mRows := mBO.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('Rows'));
  for i:= 0 to mRows.Count -1 do
  begin
    mRow := mRows.BusinessObject[i];
    if mRow.GetFieldValueAsInteger('RowType') = 3 then
    begin
      mParams.GetOrCreateParam(dtList, mRow.OID, pkInputOutput);
      mParams.ParamByName(mRow.OID).AsList.GetOrCreateParam(dtFloat, 'Quantity', pkInputOutput).AsFloat := mRow.GetFieldValueAsFloat('UnitQuantity');
      mParams.ParamByName(mRow.OID).AsList.GetOrCreateParam(dtString, 'StoreCard_ID', pkInputOutput).AsString := mRow.GetFieldValueAsString('StoreCard_ID');
    end;
  end;
  mFirm_ID := mBO.GetFieldValueAsString('Firm_ID');
  OutputDebugString(Format(gSQL, [mBO.OID, mBO.OID, mFirm_ID, mFirm_ID]));
  mResult := TStringList.Create;
  try
    mBO.ObjectSpace.SQLSelect(Format(gSQL, [mII_ID, mII_ID, mFirm_ID, mFirm_ID]), mResult);
    OutputDebugString('SQLResult: ' + mResult[0]);
    mParams.ParamByName('zl').AsFloat := NxIBStrToFloat(NxTrapStr(mResult[0], ';'));
    mParams.ParamByName('fv').AsFloat := NxIBStrToFloat(NxTrapStr(mResult[0], ';'));
    mParams.ParamByName('dv').AsFloat := NxIBStrToFloat(NxTrapStr(mResult[0], ';'));
    mParams.ParamByName('fp').AsFloat := NxIBStrToFloat(NxTrapStr(mResult[0], ';'));
    mParams.ParamByName('dl').AsFloat := NxIBStrToFloat(NxTrapStr(mResult[0], ';'));
    mParams.ParamByName('dl2').AsFloat := NxIBStrToFloat(NxTrapStr(mResult[0], ';'));
    mParams.ParamByName('credit').AsFloat := mBO.GetFieldValueAsFloat('Firm_ID.Credit');
  finally
    mResult.Free;
  end;
end;

procedure sbBOMAClick(Sender: TSpeedButton);
var
  mContainer: TNxObjectContainer;
  mParams: TNxParameters;
  mBO: TNxCustomBusinessObject;
  mText: String;
  i: Integer;
begin
  mContainer := getContainer(Sender.Site);
  mBO := Sender.DynSite.CurrentObject;
  try
    try
      //mParams := TNxParameters(mContainer.GetObject(mBO.CLSID + mBO.OID));
      try
        mParams := TNxParameters(mContainer.GetObject(mBO.CLSID + mBO.OID));
      except
        mParams := TNxParameters.Create;   //necháme, kdybychom opravovali stejný dokald, tak ať se nevytváří, ale pro jistotu nulujeme. Destrouy je s destroyem agendy
        mContainer.AddObject(mBO.CLSID + mBO.OID,mParams);
        fillCreditForFirm(mParams,mBO);
      end;

      mText := '';
      for i:=0 to mParams.Count -1 do
      begin
        if NxIsEmptyOID(mParams.Params[i].Name) then
          mText := mText + mParams.Params[i].Name + ': ' + mParams.Params[i].AsString + #13#10;
      end;
      NxShowMessage('Kredit', mText, mdInformation, False, Sender.Site.GetSiteAppForm);
    except
      //mParams := TNxParameters.Create;   //necháme, kdybychom opravovali stejnou FV, tak ať se nevytváří, ale pro jistotu nulujeme. Destrouy je s destroyem agendy
      //mContainer.AddObject(mBO.CLSID + mBO.OID,mParams);
      NxShowMessage('Informace','Informace o kreditu jsou dostupné jen v editaci dokladu', mdInformation, False, Sender.Site.GetSiteAppForm);
    end;
  finally
    mBO.Free;
  end;
end;

{
Vyvolává se před fyzickým zrušením instance.
}
procedure FormDestroy_Hook(Self: TSiteForm);
var
  mContainer: TNxObjectContainer;
  i: Integer;
begin
  mContainer := getContainer(Self, false);
  if Assigned(mContainer) then
  begin
    for i:=mContainer.Count -1 downto 0 do
    begin
      mContainer.GetObject1(i).Free;
      mContainer.DelObject1(i);
    end;
    //mContainer.Free;
  end else OutputDebugString('FormDestroy: bomaContainer neexistuje');
end;

procedure showParamValues(mParams: TNxParameters);
var i: Integer;
begin
  for i:=0 to mParams.Count -1 do
  begin
    if NxIsEmptyOID(mParams.Params[i].Name) then
      OutputDebugString(mParams.Params[i].Name + ': ' + mParams.Params[i].AsString);
  end;
end;

function GEtAvPrice(AOS : TNxCustomObjectSpace; aStoreCard_ID, aStore_ID : string) : Extended;
const
  cSQL = 'SELECT averagestoreprice from storesubcards where StoreCard_ID=''%s'' and store_id=''%s'' ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    AOS.SQLSelect(Format(cSQL, [aStoreCard_ID, astore_id]), mList);
    OutputDebugString(Format(cSQL, [aStoreCard_ID, astore_id]));
    if mList.Count > 0 then
      Result := StrToFloat(mList.Strings[0])
      else Result:=0;
  finally
    mList.Free;
  end;
end;

function getContainer(Self: TSiteForm; needContainer: Boolean = True): TNxObjectContainer;
var i: Integer; mContainer: TNxObjectContainer;
begin
  mContainer := nil;
  Result := nil;
  for i:=0 to Self.ComponentCount -1 do
  begin
    if Self.Components[i].Name = containerName then
    begin
      mContainer := TNxObjectContainer(Self.Components[i]);
      OutputDebugString(mContainer.ClassName);
    end;
  end;
  if needContainer and not(Assigned(mContainer)) then
  begin
    AfterSiteOpen_Hook(Self);
    mContainer:=getContainer(Self);
  end;
  Result := mContainer;
end;

begin
end.