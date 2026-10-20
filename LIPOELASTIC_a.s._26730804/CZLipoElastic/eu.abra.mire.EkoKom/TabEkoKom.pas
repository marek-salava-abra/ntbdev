const cEKOKOMTab = 'EKO-KOM';
      cEKOKOMAdd = 'Přidat';
      cEKOKOMDelete = 'Vymazat';
      cContainerBusinessObject = '3DROIEGQRFMOH4ZT4I53BZCXKO';

procedure setEkoKomEnabled(AWinControl: TWinControl; AEnabled: Boolean);
var i: Integer;
begin
  for i := 0 to AWinControl.ControlCount - 1 do
  begin
    AWinControl.Controls[i].Enabled:= AEnabled;
    if AWinControl.Controls[i] is TWinControl then
      setEkoKomEnabled(TWinControl(AWinControl.Controls[i]), AEnabled);
  end;
end;

procedure btnEKOKOMCFirst(Sender: TSpeedButton);
begin
  TMemoryDataset(IntToObj(Sender.Tag)).First;
end;

procedure btnEKOKOMCPrior(Sender: TSpeedButton);
begin
  TMemoryDataset(IntToObj(Sender.Tag)).Prior;
end;

procedure btnEKOKOMCNext(Sender: TSpeedButton);
begin
  TMemoryDataset(IntToObj(Sender.Tag)).Next;
end;

procedure btnEKOKOMCLast(Sender: TSpeedButton);
begin
  TMemoryDataset(IntToObj(Sender.Tag)).Last;
end;

{
  Přidat
}
procedure addEKOKOMClick(Sender: TSpeedButton);
var mDataSet: TMemoryDataset;
    mAllowedIDs, mOLE, mOLEStrings, mRoll: Variant;
    mExistStoreCard: TStringList;
    i: Integer;

    mPrefTyp: Integer;
    mPrefUziti: Integer;
    mPrefUvedeni: Integer;
    mPrefZpoplatneny: Integer;
    mPrefOpakovan: Integer;
    mPrefPuvod: Integer;
    mPrefMaterialKompozitu: Integer;
    mPrefLittering: Integer;
begin
  mDataSet:= TMemoryDataset(IntToObj(Sender.Tag));
  mOLE:= GetAbraOLEApplication;
  mOLEStrings:= GetAbraOLEStrings;
  mAllowedIDs:= GetAbraOLEStrings;

  mOLE.SQLSelect(
    'SELECT ID FROM StoreCards WHERE Category = 4', mAllowedIDs);

  mRoll:= mOLE.GetRoll('S3WZQKDB5FDL342M01C0CX3FCC', 2);
  mRoll.Params.add('_Allowed=' + mAllowedIDs.CommaText);

  if mRoll.MultiSelectDialog(False, mOLEStrings) then
  begin
    mExistStoreCard:= TStringList.Create();
    try
      for i:= 0 to mOLEStrings.Count - 1 do
      begin
        mPrefTyp := mDataSet.FieldByName('TypObchodu').AsInteger;
        mPrefUziti := mDataSet.FieldByName('ZpusobUziti').AsInteger;
        mPrefUvedeni := mDataSet.FieldByName('ZpusobUvedeni').AsInteger;
        mPrefZpoplatneny := mDataSet.FieldByName('ZpoplatneniObalu').AsInteger;
        mPrefOpakovan := mDataSet.FieldByName('OpakovanePouzivany').AsInteger;
        mPrefLittering := mDataSet.FieldByName('LitteringovyObal').AsInteger;
        mPrefPuvod := mDataSet.FieldByName('PuvodMaterialu').AsInteger;
        mPrefMaterialKompozitu := mDataSet.FieldByName('MaterialKompozitu').AsInteger;

        mDataSet.Append;
        mDataSet.FieldByName('ID').AsString:= '0000000000';
        mDataSet.FieldByName('ContainerStoreCard_ID').AsString:= mOLEStrings.Strings[i];
        // Předvyplnění podle posledního
        mDataSet.FieldByName('TypObchodu').AsInteger := mPrefTyp;
        mDataSet.FieldByName('ZpusobUziti').AsInteger := mPrefUziti;
        mDataSet.FieldByName('ZpusobUvedeni').AsInteger := mPrefUvedeni;
        mDataSet.FieldByName('ZpoplatneniObalu').AsInteger := mPrefZpoplatneny;
        mDataSet.FieldByName('OpakovanePouzivany').AsInteger := mPrefOpakovan;
        mDataSet.FieldByName('LitteringovyObal').AsInteger := mPrefLittering;
        mDataSet.FieldByName('PuvodMaterialu').AsInteger := mPrefPuvod;
        mDataSet.FieldByName('MaterialKompozitu').AsInteger := mPrefMaterialKompozitu;
        mDataSet.Post;
      end;
      mDataSet.Refresh;
    finally
      mExistStoreCard.Free;
    end;
  end;
end;

procedure delEKOKOMClick(Sender: TSpeedButton);
var mDataSet: TMemoryDataset;
begin
  mDataSet:= TMemoryDataset(IntToObj(Sender.Tag));
  mDataSet.Delete;
end;

{
  Počítané fieldy
}
procedure dsEKOKOMCalc(DataSet: TDataSet);
var mObjSpace: TNxCustomObjectSpace;
    mBO: TNxCustomBusinessObject;
begin
  try
  OutputDebugString(IntToStr(DataSet.Tag));
  mObjSpace:= TNxCustomObjectSpace(DataSet.Tag);
  mBO:= mObjSpace.CreateObject(Class_StoreCard);
  try
    if not NxIsEmptyOID(DataSet.FieldByName('ContainerStoreCard_ID').AsString) then
    begin
      OutputDebugString(DataSet.FieldByName('ContainerStoreCard_ID').AsString);
      mBO.Load(DataSet.FieldByName('ContainerStoreCard_ID').AsString, nil);
      DataSet.FieldByName('ContainerStoreCard_ID_Name').AsString:= mBO.GetFieldValueAsString('Name');
    end;
  finally
    mBO.Free;
  end;
  except
    OutputDebugString(ExceptionMessage);
  end;
end;

{
  Refresh
}
procedure RefreshContainers(ASite: TSiteForm);
var mListBox: TListBox;
    i: Integer;
    j: Integer;
    str : string;
    mDataSet: TMemoryDataset;
    mSQL: string;
    mResult: TStringList;
    mBO, mBOStorCard: TNxCustomBusinessObject;
    mGridLookupColumn : TNxMultiGridLookupColumn;
    mMon : TNxCustomBusinessMonikerCollection;
    mCurrentStoreCard : TNxCustomBusinessObject;
    mGrd : TMultiGrid;
    mComponent: TComponent;
begin
  mComponent:= ASite.FindComponent('lbxComponents');
  if mComponent = nil then exit;

  mListBox:= TListBox(mComponent);

  i:= mListBox.Items.IndexOf('StoreCardUnit');

  if i < 0 then
    Exit;

  mGridLookupColumn := TNxMultiGridLookupColumn(mListBox.Items.Objects(i));
  mCurrentStoreCard := TBusRollSiteForm(ASite).CurrentObject;

  if mCurrentStoreCard <> nil then
  begin
    mGridLookupColumn.Values.Clear();
    mMon := mCurrentStoreCard.GetLoadedCollectionMonikerForFieldCode(mCurrentStoreCard.GetFieldCode('StoreUnits'));

    for j := 0 to mMon.Count - 1 do
    begin
      str := mMon.BusinessObject[j].GetFieldValueAsString('Code');
      mGridLookupColumn.Values.Insert(0, str + '=' + str);
    end;
  end
  else
  begin
    exit;
  end;

  i:= mListBox.Items.IndexOf('dsEKOKOM');
  mDataSet:= TMemoryDataset(mListBox.Items.Objects(i));
  mDataSet.DisableControls;
  try
    if not mDataSet.Active then
      mDataSet.Open;

    if (mDataSet.RecordCount > 0) then
      mDataSet.EmptyTable;

//TODO nacteni predelat pomoci SQL dotazu viz nize
{    mSQL:= Format(
      'SELECT A.ID as ID, '+
      ' A.X_EKO_StoreCardUnit as StoreCardUnit, '+
      ' A.X_EKO_ContainerStoreCard_ID as ContainerStoreCard_ID, '+
      ' SC.Name as ContainerStoreCard_ID_Name, '+
      ' A.X_EKO_TypObchodu as TypObchodu, '+
      ' A.X_EKO_ZpusobUziti as ZpusobUziti, '+
      ' A.X_EKO_ZpusobUvedeni as ZpusobUvedeni, '+
      ' A.X_EKO_ZpoplatneniObalu as ZpoplatneniObalu, '+
      ' A.X_EKO_OpakovanePouzivany as OpakovanePouzivany, '+
      ' A.X_EKO_LitteringovyObal as LitteringovyObal, '+
      ' A.X_EKO_UnitQuantity as UnitQuantity, '+
      ' A.X_EKO_Hmotnost as Hmotnost, '+
      ' A.X_EKO_Quantity as Quantity, '+
      ' A.X_EKO_UnitRate as UnitRate '+
      ' FROM DefRollData A ' +
      ' LEFT JOIN STORECARDS SC ON SC.ID = A.X_EKO_ContainerStoreCard_ID ' +
      ' WHERE A.CLSID=''%s'' AND A.X_EKO_StoreCard_ID=''%s''',
      [cContainerBusinessObject, mCurrentStoreCard.OID]);}

    mSQL:= Format(
      'SELECT A.ID as ID '+
      ' FROM DefRollData A ' +
      ' WHERE A.CLSID=''%s'' AND A.X_EKO_StoreCard_ID=''%s''',
      [cContainerBusinessObject, mCurrentStoreCard.OID]);

{    if (mDataSet.Active) then begin
      mDataSet.Edit;
      mDataSet.Fields.Clear;
    end;
    ASite.BaseObjectSpace.SQLSelect2(mSQL, mDataSet);
    if (not mDataSet.Active) and (mDataSet.RecordCount > 0) then
      mDataSet.Open;}

    mResult:= TStringList.Create;

    try
      ASite.BaseObjectSpace.SQLSelect(mSQL, mResult);
      mBO:= ASite.BaseObjectSpace.CreateObject(cContainerBusinessObject);

      try
        mBOStorCard:= ASite.BaseObjectSpace.CreateObject(Class_StoreCard);
        try
          for i:= 0 to mResult.Count - 1 do
          begin
            mBO.Load(mResult[i], nil);

            mDataSet.Append;
            mDataSet.FieldByName('ID').AsString:= mResult[i];
            mDataSet.FieldByName('StoreCardUnit').AsString:= mBO.GetFieldValueAsString('X_EKO_StoreCardUnit');

            if not NxIsEmptyOID(mBO.GetFieldValueAsString('X_EKO_ContainerStoreCard_ID')) then
            begin
              mBOStorCard.Load(mBO.GetFieldValueAsString('X_EKO_ContainerStoreCard_ID'), nil);
              mDataSet.FieldByName('ContainerStoreCard_ID').AsString:= mBOStorCard.OID;
              mDataSet.FieldByName('ContainerStoreCard_ID_Name').AsString:= mBOStorCard.GetFieldValueAsString('Name');
            end;

            mDataSet.FieldByName('TypObchodu').AsInteger:= mBO.GetFieldValueAsInteger('X_EKO_TypObchodu');
            mDataSet.FieldByName('ZpusobUziti').AsInteger:= mBO.GetFieldValueAsInteger('X_EKO_ZpusobUziti');
            mDataSet.FieldByName('ZpusobUvedeni').AsInteger:= mBO.GetFieldValueAsInteger('X_EKO_ZpusobUvedeni');
            mDataSet.FieldByName('ZpoplatneniObalu').AsInteger:= mBO.GetFieldValueAsInteger('X_EKO_ZpoplatneniObalu');
            mDataSet.FieldByName('OpakovanePouzivany').AsInteger:= mBO.GetFieldValueAsInteger('X_EKO_OpakovanePouzivany');
            mDataSet.FieldByName('LitteringovyObal').AsInteger:= mBO.GetFieldValueAsInteger('X_EKO_LitteringovyObal');
            mDataSet.FieldByName('UnitQuantity').AsFloat := mBO.GetFieldValueAsFloat('X_EKO_UnitQuantity');
            mDataSet.FieldByName('Hmotnost').AsFloat:= mBO.GetFieldValueAsFloat('X_EKO_Hmotnost');
            mDataSet.FieldByName('Quantity').AsFloat := mBO.GetFieldValueAsFloat('X_EKO_Quantity');
            mDataSet.FieldByName('UnitRate').AsFloat := mBO.GetFieldValueAsFloat('X_EKO_UnitRate');
            mDataSet.FieldByName('PuvodMaterialu').AsInteger:= mBO.GetFieldValueAsInteger('X_EKO_PuvodMaterialu');
            mDataSet.FieldByName('MaterialKompozitu').AsInteger:= mBO.GetFieldValueAsInteger('X_EKO_MaterialKompozitu');
            mDataSet.Post;
          end;
        finally
          mBOStorCard.Free();
        end;
      finally
        mBO.Free;
      end;
    finally
      mResult.Free;
    end;
  finally
    mDataSet.EnableControls;
    if mDataSet.RecordCount > 0 then begin
      mDataSet.First;
      i:= mListBox.Items.IndexOf('grdEKOKOM');

      if i >= 0 then begin
        mGrd :=  TMultiGrid(mListBox.Items.Objects(i));
        mGrd.RepaintGrid;
      end;

    end;
  end;
end;

{
  Uložení datasetu
}
procedure SaveEKOKOMRelations(ASite: TSiteForm; AOID: String);
var
  mListBox: TListBox;
  i: Integer;
  mDataSet: TMemoryDataset;
  mSQL, mID: string;
  mBO: TNxCustomBusinessObject;
  mOldIDs, mNewIDs: TStringList;
  mComponent: TComponent;
begin
  mComponent:= ASite.FindComponent('lbxComponents');
  if mComponent = nil then exit;

  mListBox:= TListBox(mComponent);

  i:= mListBox.Items.IndexOf('dsEKOKOM');

  mDataSet:= TMemoryDataset(mListBox.Items.Objects(i));

  if mDataSet.State <> dsBrowse then
  begin
    if mDataSet.FieldByName('ContainerStoreCard_ID').AsString <> '' then
      mDataSet.Post;
  end;

  mDataSet.DisableControls;

  try
    // Nejdrive z databazi co se vymazalo....
    mOldIDs:= TStringList.Create;
    mNewIDs:= TStringList.Create;

    try
      // Načtení uložených obalů
      mSQL:= Format(
        'SELECT A.ID FROM DefRollData A ' +
        'WHERE A.CLSID=''%s'' AND A.X_EKO_StoreCard_ID=''%s''',
        [cContainerBusinessObject, AOID]);

      ASite.BaseObjectSpace.SQLSelect(mSQL, mOldIDs); // Tady jsou v+sechny ID které jsou v databaze
      mDataSet.First;

      // Načtení nových obalů
      while not mDataSet.Eof do
      begin
        mID:= mDataSet.FieldByName('ID').AsString;
        if mID <> '0000000000' then
          mNewIDs.Add(mID);
        mDataSet.Next;
      end;
      mNewIDs.Sort;

      // Smazání obalů, které nejsou v datasetu
      for i:= 0 to mOldIDs.Count - 1 do
      begin
        if mNewIDs.IndexOf(mOldIDs[i]) = -1 then
        begin
          mBO:= ASite.BaseObjectSpace.CreateObject(cContainerBusinessObject);
          try
            mBO.Load(mOldIDs[i], nil);
            mBO.Delete;
          finally
            mBO.Free;
          end;
        end;
      end;
    finally
      mOldIDs.Free;
      mNewIDs.Free;
    end;

    // Uložení obalů z datasetu
    mDataSet.First;

    while not mDataSet.Eof do
    begin
      mBO:= ASite.BaseObjectSpace.CreateObject(cContainerBusinessObject);
      try
        mID:= mDataSet.FieldByName('ID').AsString;
        if mID = '0000000000' then
        begin
          mBO.New;
          mBO.Prefill;
        end
        else
          mBO.Load(mID, nil);

        mBO.SetFieldValueAsString('X_EKO_StoreCard_ID', AOID);
        mBO.SetFieldValueAsString('X_EKO_StoreCardUnit', mDataSet.FieldByName('StoreCardUnit').AsString);
        mBO.SetFieldValueAsString('X_EKO_ContainerStoreCard_ID', mDataSet.FieldByName('ContainerStoreCard_ID').AsString);
        mBO.SetFieldValueAsInteger('X_EKO_TypObchodu', mDataSet.FieldByName('TypObchodu').AsInteger);
        mBO.SetFieldValueAsInteger('X_EKO_ZpusobUziti', mDataSet.FieldByName('ZpusobUziti').AsInteger);
        mBO.SetFieldValueAsInteger('X_EKO_ZpusobUvedeni', mDataSet.FieldByName('ZpusobUvedeni').AsInteger);
        mBO.SetFieldValueAsInteger('X_EKO_ZpoplatneniObalu', mDataSet.FieldByName('ZpoplatneniObalu').AsInteger);
        mBO.SetFieldValueAsInteger('X_EKO_OpakovanePouzivany', mDataSet.FieldByName('OpakovanePouzivany').AsInteger);
        mBO.SetFieldValueAsInteger('X_EKO_LitteringovyObal', mDataSet.FieldByName('LitteringovyObal').AsInteger);
        mBO.SetFieldValueAsFloat('X_EKO_UnitQuantity', mDataSet.FieldByName('UnitQuantity').AsFloat);
        mBO.SetFieldValueAsFloat('X_EKO_Hmotnost', mDataSet.FieldByName('Hmotnost').AsFloat);
        mBO.SetFieldValueAsFloat('X_EKO_Quantity', mDataSet.FieldByName('Quantity').AsFloat);
        mBO.SetFieldValueAsFloat('X_EKO_UnitRate', mDataSet.FieldByName('UnitRate').AsFloat);
        mBO.SetFieldValueAsInteger('X_EKO_PuvodMaterialu', mDataSet.FieldByName('PuvodMaterialu').AsInteger);
        mBO.SetFieldValueAsInteger('X_EKO_MaterialKompozitu', mDataSet.FieldByName('MaterialKompozitu').AsInteger);
        mBO.Save;
      finally
        mBO.Free;
      end;
      mDataSet.Next;
    end;
  finally
    mDataSet.EnableControls;
  end;
end;

procedure grdDlbLClik(Sender: TMultiGrid);
var mDataSet: TMemoryDataset;
begin
  mDataSet:= TMemoryDataset(IntToObj(Sender.Tag));
  if mDataSet.State = dsBrowse then
    mDataSet.Edit else
    mDataSet.Post;
end;

{
  Vytvoření záložky s datasetem
}
function AddEKOKOMTabSheet(APageControl: TPageControl): TTabSheet;
var mBottomPnl: TPanel;
    mGrd: TMultiGrid;
    mGridColumn: TNxMultiGridColumn;
    mGridDateColumn: TNxMultiGridDateColumn;
    mGridLookupColumn: TNxMultiGridLookupColumn;
    mBtn: array [0..6] of TSpeedButton;
    i, x: Integer;
    h: Integer;
    mDataSet: TMemoryDataset;
    mDataSource: TDataSource;
    mListBox: TListBox;
    mFieldDef: TFieldDef;
begin
  try
    mListBox:= TListBox.Create(APageControl.Site);
    mListBox.Parent:= APageControl.Site;
    mListBox.Name:= 'lbxComponents';
    mListBox.Visible:= False;

    Result:= TTabSheet.Create(APageControl);
    Result.PageControl:= APageControl;
    Result.Caption:= cEKOKOMTab;
    Result.Name:= 'tabEKOKOM';

    mBottomPnl:= TPanel.Create(Result);
    mBottomPnl.Parent:= Result;
    mBottomPnl.Align:= alBottom;
    mBottomPnl.Height:= 27;
    mBottomPnl.Name:= 'pnlEKOBottom';
    mBottomPnl.Caption:= '';

    mDataSet:= TMemoryDataset.Create(Result);
    mDataSet.Name:= 'dsEKOKOM';

    mDataSet.FieldDefs.Add('ID', ftWideString, 10);
    mDataSet.FieldDefs.Add('StoreCardUnit', ftWideString, 5);
    mDataSet.FieldDefs.Add('ContainerStoreCard_ID', ftWideString, 10);

    mDataSet.FieldDefs.Add('TypObchodu', ftInteger, 0);
    mDataSet.FieldDefs.Add('ZpusobUziti', ftInteger, 0);
    mDataSet.FieldDefs.Add('ZpoplatneniObalu', ftInteger, 0);
    mDataSet.FieldDefs.Add('OpakovanePouzivany', ftInteger, 0);
    mDataSet.FieldDefs.Add('LitteringovyObal', ftInteger, 0);
    mDataSet.FieldDefs.Add('UnitQuantity', ftFloat, 0);
    mDataSet.FieldDefs.Add('Hmotnost', ftFloat, 0);
    mDataSet.FieldDefs.Add('Quantity', ftFloat, 0);
    mDataSet.FieldDefs.Add('UnitRate', ftFloat, 0);

    mDataSet.Tag:= ObjToInt(APageControl.Site.CompanyObjectSpace);
    mDataSet.onCalcFields:= @dsEKOKOMCalc;

    try
      mFieldDef:= TFieldDef.Create(mDataSet.FieldDefs, 'ContainerStoreCard_ID_Name', ftWideString, 100, False, 300001);
      with mFieldDef.CreateField(mDataSet, nil, 'xContainerStoreCard_ID_Name', False) do
      begin
        Size:= 100;
        FieldKind:= fkCalculated;
        FieldName:= 'ContainerStoreCard_ID_Name';
      end;

      mFieldDef:= TFieldDef.Create(mDataSet.FieldDefs, 'ID', ftWideString, 10, False, 300002);
      with mFieldDef.CreateField(mDataSet, nil, 'xID', False) do
      begin
        Size:= 10;
        FieldKind:= fkData;
        FieldName:= 'ID';
      end;

      mFieldDef:= TFieldDef.Create(mDataSet.FieldDefs, 'StoreCardUnit', ftWideString, 5, True, 300003);
      with mFieldDef.CreateField(mDataSet, nil, 'xStoreCardUnit', False) do
      begin
        Size:= 10;
        FieldKind:= fkData;
        FieldName:= 'StoreCardUnit';
      end;

      mFieldDef:= TFieldDef.Create(mDataSet.FieldDefs, 'ContainerStoreCard_ID', ftWideString, 10, True, 300004);
      with mFieldDef.CreateField(mDataSet, nil, 'xContainerStoreCard_ID', False) do
      begin
        Size:= 10;
        FieldKind:= fkData;
        FieldName:= 'ContainerStoreCard_ID';
      end;

      mFieldDef:= TFieldDef.Create(mDataSet.FieldDefs, 'TypObchodu', ftInteger, 0, True, 300005);
      with mFieldDef.CreateField(mDataSet, nil, 'xTypObchodu', False) do
      begin
        FieldKind:= fkData;
        FieldName:= 'TypObchodu';
      end;

      mFieldDef:= TFieldDef.Create(mDataSet.FieldDefs, 'ZpusobUziti', ftInteger, 0, True, 300007);
      with mFieldDef.CreateField(mDataSet, nil, 'xZpusobUziti', False) do
      begin
        FieldKind:= fkData;
        FieldName:= 'ZpusobUziti';
      end;

      mFieldDef:= TFieldDef.Create(mDataSet.FieldDefs, 'ZpusobUvedeni', ftInteger, 0, True, 300008);
      with mFieldDef.CreateField(mDataSet, nil, 'xZpusobUvedeni', False) do
      begin
        FieldKind:= fkData;
        FieldName:= 'ZpusobUvedeni';
      end;

      mFieldDef:= TFieldDef.Create(mDataSet.FieldDefs, 'ZpoplatneniObalu', ftInteger, 0, True, 300009);
      with mFieldDef.CreateField(mDataSet, nil, 'xZpoplatneniObalu', False) do
      begin
        FieldKind:= fkData;
        FieldName:= 'ZpoplatneniObalu';
      end;

      mFieldDef:= TFieldDef.Create(mDataSet.FieldDefs, 'OpakovanePouzivany', ftInteger, 0, True, 300010);
      with mFieldDef.CreateField(mDataSet, nil, 'xOpakovanePouzivany', False) do
      begin
        FieldKind:= fkData;
        FieldName:= 'OpakovanePouzivany';
      end;

      mFieldDef:= TFieldDef.Create(mDataSet.FieldDefs, 'LitteringovyObal', ftInteger, 0, True, 300011);
      with mFieldDef.CreateField(mDataSet, nil, 'xLitteringovyObal', False) do
      begin
        FieldKind:= fkData;
        FieldName:= 'LitteringovyObal';
      end;

      mFieldDef:= TFieldDef.Create(mDataSet.FieldDefs, 'UnitQuantity', ftFloat, 0, True, 300012);
      with mFieldDef.CreateField(mDataSet, nil, 'xUnitQuantity', False) do
      begin
        FieldKind:= fkData;
        FieldName:= 'UnitQuantity';
      end;

      mFieldDef:= TFieldDef.Create(mDataSet.FieldDefs, 'Hmotnost', ftFloat, 0, True, 300013);
      with mFieldDef.CreateField(mDataSet, nil, 'xHmotnost', False) do
      begin
        FieldKind:= fkData;
        FieldName:= 'Hmotnost';
      end;

      mFieldDef:= TFieldDef.Create(mDataSet.FieldDefs, 'Quantity', ftFloat, 0, True, 300014);
      with mFieldDef.CreateField(mDataSet, nil, 'xQuantity', False) do
      begin
        FieldKind:= fkData;
        FieldName:= 'Quantity';
      end;

      mFieldDef:= TFieldDef.Create(mDataSet.FieldDefs, 'UnitRate', ftFloat, 0, True, 300014);
      with mFieldDef.CreateField(mDataSet, nil, 'xUnitRate', False) do
      begin
        FieldKind:= fkData;
        FieldName:= 'UnitRate';
      end;

      mFieldDef:= TFieldDef.Create(mDataSet.FieldDefs, 'PuvodMaterialu', ftInteger, 0, True, 300015);
      with mFieldDef.CreateField(mDataSet, nil, 'xPuvodMaterialu', False) do
      begin
        FieldKind:= fkData;
        FieldName:= 'PuvodMaterialu';
      end;

      mFieldDef:= TFieldDef.Create(mDataSet.FieldDefs, 'MaterialKompozitu', ftInteger, 0, True, 300016);
      with mFieldDef.CreateField(mDataSet, nil, 'xMaterialKompozitu', False) do
      begin
        FieldKind:= fkData;
        FieldName:= 'MaterialKompozitu';
      end;

    except
      OutputDebugString(ExceptionMessage);
    end;

    mListBox.Items.AddObject(mDataSet.Name, mDataSet);
    mListBox.Items.AddObject(Result.Name, Result);

    mDataSource:= TDataSource.Create(Result);
    mDataSource.DataSet:= mDataSet;

    mGrd:= TMultiGrid.Create(Result);
    mGridColumn:= TNxMultiGridColumn.Create(mGrd);
    mGridDateColumn:= TNxMultiGridDateColumn.Create(mGrd);
    mGridLookupColumn:= TNxMultiGridLookupColumn.Create(mGrd);

    mGrd.Parent:= Result;
    mGrd.OnDblClick:= @grdDlbLClik;
    mGrd.OnGetColumnReadOnly:= @MGColumnReadOnly;
  //  mGrd.OnKeyPress:= @grdKeyPress;
    mGrd.Align:= alClient;
    mGrd.DataSource:= mDataSource;

    mGrd.Tag:= ObjToInt(mDataSet);
    mGrd.Name := 'grdEKOKOM';
    mListBox.Items.AddObject(mGrd.Name, mGrd);

    // StoreCardUnit
    mGridLookupColumn:= TNxMultiGridLookupColumn.Create(mGrd);
    TNxMultiGridCustomColumn(mGridLookupColumn).Width:= TNxMultiGridCustomColumn(mGridLookupColumn).Width + 30;
    TNxMultiGridCustomColumn(mGridLookupColumn).Layout:= 0;
    TNxMultiGridCustomColumn(mGridLookupColumn).Width:= 60;
    TNxMultiGridCustomColumn(mGridLookupColumn).FieldName:= 'StoreCardUnit';
    TNxMultiGridCustomColumn(mGridLookupColumn).Caption:= 'Jednotka';
    TNxMultiGridCustomColumn(mGridLookupColumn).Order:= 0;
    mGridLookupColumn.Values.add('?=?');
    mGrd.AddColumn(mGridLookupColumn);
    mListBox.Items.AddObject(TNxMultiGridCustomColumn(mGridLookupColumn).FieldName, mGridLookupColumn);
    // Název skl. karty
    mGridColumn:= TNxMultiGridColumn.Create(mGrd);
    mGridColumn.Layout:= 0;
    mGridColumn.Width:= 180;
    mGridColumn.FieldName:= 'ContainerStoreCard_ID_Name';
    mGridColumn.Name:= 'ContainerStoreCard_ID_Name';
    mGridColumn.Caption:= 'Název skl. karty obalu';
    mGridColumn.Order:= 1;
    mGridColumn.ReadOnly:= True;
    mGrd.AddColumn(mGridColumn);
    // MaterialKompozitu
    mGridLookupColumn:= TNxMultiGridLookupColumn.Create(mGrd);
    TNxMultiGridCustomColumn(mGridLookupColumn).Width:= TNxMultiGridCustomColumn(mGridLookupColumn).Width + 30;
    TNxMultiGridCustomColumn(mGridLookupColumn).Layout:= 0;
    TNxMultiGridCustomColumn(mGridLookupColumn).Width:= 85;
    TNxMultiGridCustomColumn(mGridLookupColumn).FieldName:= 'MaterialKompozitu';
    TNxMultiGridCustomColumn(mGridLookupColumn).Caption:= 'Materiál kompozitu';
    TNxMultiGridCustomColumn(mGridLookupColumn).Order:= 2;
    mGridLookupColumn.Values.add('Ne=0');
    mGridLookupColumn.Values.add('Ano=1');
    mGrd.AddColumn(mGridLookupColumn);
    // TypObchodu
    mGridLookupColumn:= TNxMultiGridLookupColumn.Create(mGrd);
    TNxMultiGridCustomColumn(mGridLookupColumn).Width:=TNxMultiGridCustomColumn(mGridLookupColumn).Width + 30;
    TNxMultiGridCustomColumn(mGridLookupColumn).Layout:= 0;
    TNxMultiGridCustomColumn(mGridLookupColumn).Width:= 60;
    TNxMultiGridCustomColumn(mGridLookupColumn).FieldName:= 'TypObchodu';
    TNxMultiGridCustomColumn(mGridLookupColumn).Caption:= 'Typ obchodu';
    TNxMultiGridCustomColumn(mGridLookupColumn).Order:= 3;
    mGridLookupColumn.Values.add('Obchodní=0');
    mGridLookupColumn.Values.add('Průmyslové=1');
    mGridLookupColumn.Values.add('Vyhodnotit výraz=2');
    mGrd.AddColumn(mGridLookupColumn);
    // ZpusobUziti
    mGridLookupColumn:= TNxMultiGridLookupColumn.Create(mGrd);
    TNxMultiGridCustomColumn(mGridLookupColumn).Width:= TNxMultiGridCustomColumn(mGridLookupColumn).Width + 30;
    TNxMultiGridCustomColumn(mGridLookupColumn).Layout:= 0;
    TNxMultiGridCustomColumn(mGridLookupColumn).Width:= 60;
    TNxMultiGridCustomColumn(mGridLookupColumn).FieldName:= 'ZpusobUziti';
    TNxMultiGridCustomColumn(mGridLookupColumn).Caption:= 'Způsob užití';
    TNxMultiGridCustomColumn(mGridLookupColumn).Order:= 4;
    mGridLookupColumn.Values.add('Prodejní=0');
    mGridLookupColumn.Values.add('Skupinové=1');
    mGridLookupColumn.Values.add('Přepravní=2');
    mGrd.AddColumn(mGridLookupColumn);
    // ZpusobUvedeni
    mGridLookupColumn:= TNxMultiGridLookupColumn.Create(mGrd);
    TNxMultiGridCustomColumn(mGridLookupColumn).Width:= TNxMultiGridCustomColumn(mGridLookupColumn).Width + 30;
    TNxMultiGridCustomColumn(mGridLookupColumn).Layout:= 0;
    TNxMultiGridCustomColumn(mGridLookupColumn).Width:= 90;
    TNxMultiGridCustomColumn(mGridLookupColumn).FieldName:= 'ZpusobUvedeni';
    TNxMultiGridCustomColumn(mGridLookupColumn).Caption:= 'Způsob uvedení';
    TNxMultiGridCustomColumn(mGridLookupColumn).Order:= 5;
    mGridLookupColumn.Values.add('Vyrobené v ČR=0');
    mGridLookupColumn.Values.add('Importované do ČR=1');
    mGridLookupColumn.Values.add('Nakoupené na vnitřním trhu ČR=2');
    mGrd.AddColumn(mGridLookupColumn);
    // PuvodMaterialu
    mGridLookupColumn:= TNxMultiGridLookupColumn.Create(mGrd);
    TNxMultiGridCustomColumn(mGridLookupColumn).Width:= TNxMultiGridCustomColumn(mGridLookupColumn).Width + 30;
    TNxMultiGridCustomColumn(mGridLookupColumn).Layout:= 0;
    TNxMultiGridCustomColumn(mGridLookupColumn).Width:= 70;
    TNxMultiGridCustomColumn(mGridLookupColumn).FieldName:= 'PuvodMaterialu';
    TNxMultiGridCustomColumn(mGridLookupColumn).Caption:= 'Původ';
    TNxMultiGridCustomColumn(mGridLookupColumn).Order:= 6;
    mGridLookupColumn.Values.add('Primární=0');
    mGridLookupColumn.Values.add('Recyklát=1');
    mGrd.AddColumn(mGridLookupColumn);
    // ZpoplatneniObalu
    mGridLookupColumn:= TNxMultiGridLookupColumn.Create(mGrd);
    TNxMultiGridCustomColumn(mGridLookupColumn).Width:= TNxMultiGridCustomColumn(mGridLookupColumn).Width + 30;
    TNxMultiGridCustomColumn(mGridLookupColumn).Layout:= 0;
    TNxMultiGridCustomColumn(mGridLookupColumn).Width:= 70;
    TNxMultiGridCustomColumn(mGridLookupColumn).FieldName:= 'ZpoplatneniObalu';
    TNxMultiGridCustomColumn(mGridLookupColumn).Caption:= 'Zpoplatnění';
    TNxMultiGridCustomColumn(mGridLookupColumn).Order:= 7;
    mGridLookupColumn.Values.add('Zpoplatněný=0');
    mGridLookupColumn.Values.add('Předplacený=1');
    mGridLookupColumn.Values.add('Neplacený=2');
    mGrd.AddColumn(mGridLookupColumn);
    // OpakovanePouzivany
    mGridLookupColumn:= TNxMultiGridLookupColumn.Create(mGrd);
    TNxMultiGridCustomColumn(mGridLookupColumn).Width:= TNxMultiGridCustomColumn(mGridLookupColumn).Width + 30;
    TNxMultiGridCustomColumn(mGridLookupColumn).Layout:= 0;
    TNxMultiGridCustomColumn(mGridLookupColumn).Width:= 85;
    TNxMultiGridCustomColumn(mGridLookupColumn).FieldName:= 'OpakovanePouzivany';
    TNxMultiGridCustomColumn(mGridLookupColumn).Caption:= 'Opakovaně používaný';
    TNxMultiGridCustomColumn(mGridLookupColumn).Order:= 8;
    mGridLookupColumn.Values.add('Ne=0');
    mGridLookupColumn.Values.add('Ano=1');
    mGrd.AddColumn(mGridLookupColumn);
    // LitteringovyObal
    mGridLookupColumn:= TNxMultiGridLookupColumn.Create(mGrd);
    TNxMultiGridCustomColumn(mGridLookupColumn).Width:= TNxMultiGridCustomColumn(mGridLookupColumn).Width + 45;
    TNxMultiGridCustomColumn(mGridLookupColumn).Layout:= 0;
    TNxMultiGridCustomColumn(mGridLookupColumn).Width:= 95;
    TNxMultiGridCustomColumn(mGridLookupColumn).FieldName:= 'LitteringovyObal';
    TNxMultiGridCustomColumn(mGridLookupColumn).Caption:= 'Litteringový obal';
    TNxMultiGridCustomColumn(mGridLookupColumn).Order:= 9;
    mGridLookupColumn.Values.add('Ne=0');
    mGridLookupColumn.Values.add('Nádoby na nápoje=1');
    mGridLookupColumn.Values.add('Sáčky a balení na potraviny=2');
    mGridLookupColumn.Values.add('Nápojové kelímky vyrobené z plastu=3');
    mGridLookupColumn.Values.add('Nápojové kelímky částečně vyrobené z plastu=4');
    mGridLookupColumn.Values.add('Nádoby na potraviny vyrobené z plastu=5');
    mGridLookupColumn.Values.add('Nádoby na potraviny částečně vyrobené z plastu=6');
    mGridLookupColumn.Values.add('Plastové odnosné tašky lehké 10 < 50 mikronů=7');
    mGridLookupColumn.Values.add('Plastové odnosné tašky < 15 mikronů=8');
    mGrd.AddColumn(mGridLookupColumn);
    // Hmotnost
    mGridColumn:= TNxMultiGridColumn.Create(mGrd);
    mGridColumn.Layout:= 0;
    mGridColumn.Width:= 70;
    mGridColumn.Order:= 10;
    mGridColumn.FieldName:= 'Hmotnost';
    mGridColumn.Caption:= 'Hmotnost [g]';
    mGrd.AddColumn(mGridColumn);
    // UnitQuantity
    mGridColumn:= TNxMultiGridColumn.Create(mGrd);
    mGridColumn.Layout:= 0;
    mGridColumn.Width:= 70;
    mGridColumn.Order:= 11;
    mGridColumn.FieldName:= 'UnitQuantity';
    mGridColumn.Caption:= 'Počet';
    mGrd.AddColumn(mGridColumn);

    // Quantity
    mGridColumn:= TNxMultiGridColumn.Create(mGrd);
    mGridColumn.Layout:= 0;
    mGridColumn.Width:= 70;
    mGridColumn.Order:= 12;
    mGridColumn.FieldName:= 'Quantity';
    mGridColumn.Caption:= 'Množství';
    mGrd.AddColumn(mGridColumn);

    // UnitRate
    mGridColumn:= TNxMultiGridColumn.Create(mGrd);
    mGridColumn.Layout:= 0;
    mGridColumn.Width:= 70;
    mGridColumn.Order:= 13;
    mGridColumn.FieldName:= 'UnitRate';
    mGridColumn.Caption:= 'Vztah';
    mGrd.AddColumn(mGridColumn);

    x:= 1;
    for i:= 0 to 5 do
    begin
      mBtn[i]:= TSpeedButton.Create(mBottomPnl);
      mBtn[i].Parent:= mBottomPnl;
      mBtn[i].Left:= x;
      mBtn[i].Top:= 1;
      mBtn[i].Height:= 25;
      mBtn[i].Width:= 25;
      mBtn[i].Caption:= '';
      mBtn[i].Flat:= True;
      mBtn[i].Tag:= ObjToInt(mDataSet);
      if i = 0 then
      begin
        mBtn[i].Caption:= '|<';
        mBtn[i].onClick:= @btnEKOKOMCFirst;
      end;
      if i = 1 then
      begin
        mBtn[i].Caption:= '<';
        mBtn[i].onClick:= @btnEKOKOMCPrior;
      end;
      if i = 2 then
      begin
        mBtn[i].Caption:= '>';
        mBtn[i].onClick:= @btnEKOKOMCNext;
      end;
      if i = 3 then
      begin
        mBtn[i].Caption:= '>|';
        mBtn[i].onClick:= @btnEKOKOMCLast;
      end;
      if i = 4 then
      begin
        mBtn[i].Width:= 80;
        mBtn[i].Caption:= cEKOKOMAdd;
        mBtn[i].onClick:= @addEKOKOMClick;
        mBtn[i].Tag:= ObjToInt(mDataSet);
        mBtn[i].Name:= 'btnAdd';
      end;
      if i = 5 then
      begin
        mBtn[i].Width:= 80;
        mBtn[i].Caption:= cEKOKOMDelete;
        mBtn[i].Tag:= ObjToInt(mDataSet);
        mBtn[i].onClick:= @delEKOKOMClick;
      end;
      x:= x + mBtn[i].Width;
    end;

    mDataSet.Open;
    setEKOKOMEnabled(Result, False);
  except
    OutputDebugString(ExceptionMessage);
  end;
end;

procedure MGColumnReadOnly(Sender: TNxMultiGridCustomColumn; var AReadOnly: Boolean);
begin
  AReadOnly:= False;
  //skladova karta nazev
  if Sender.Name = 'ContainerStoreCard_ID_Name' then
    AReadOnly:= True;
end;

begin
end.