const cNahradyTab = 'Související produkty';
      cNahradyAdd = 'Přidat';
      cNahradyDelete = 'Vymazat';
      cNahradyDetail = 'Detail';
      cReplacementBusinessObject = 'E0AU5EE55XVOTDWIIOPHAZPUFC';

procedure setNahradyEnabled(AWinControl: TWinControl; AEnabled: Boolean);
var i: Integer;
begin
  for i := 0 to AWinControl.ControlCount - 1 do
  begin
    AWinControl.Controls[i].Enabled:= AEnabled;
    if AWinControl.Controls[i] is TWinControl then
      setNahradyEnabled(TWinControl(AWinControl.Controls[i]), AEnabled);
  end;
end;

procedure btnNahradyCFirst(Sender: TSpeedButton);
begin
  TMemoryDataset(IntToObj(Sender.Tag)).First;
end;

procedure btnNahradyCPrior(Sender: TSpeedButton);
begin
  TMemoryDataset(IntToObj(Sender.Tag)).Prior;
end;

procedure btnNahradyCNext(Sender: TSpeedButton);
begin
  TMemoryDataset(IntToObj(Sender.Tag)).Next;
end;

procedure btnNahradyCLast(Sender: TSpeedButton);
begin
  TMemoryDataset(IntToObj(Sender.Tag)).Last;
end;

{
  Přidat
}
procedure addNahradyClick(Sender: TSpeedButton);
var mDataSet: TMemoryDataset;
    mAllowedIDs, mOLE, mOLEStrings, mRoll: Variant;
    mExistStoreCard: TStringList;
    i: Integer;
    mSite:TSiteForm;

    mPrefTyp : Integer;
    mPrefUziti : Integer;
    mPrefUvedeni : Integer;
    mPrefZpoplatneny : Integer;
    mPrefOpakovan : Integer;
    mReplacement:TNxCustomBusinessObject;
begin
  mDataSet:= TMemoryDataset(IntToObj(Sender.Tag));
  mOLE:= GetAbraOLEApplication;
  mOLEStrings:= GetAbraOLEStrings;
  mAllowedIDs:= GetAbraOLEStrings;
  mSite:=NxFindSiteForm(sender);
  mOLE.SQLSelect(
    'SELECT ID FROM StoreCards WHERE hidden=''N'' ', mAllowedIDs);

  mRoll:= mOLE.GetRoll('S3WZQKDB5FDL342M01C0CX3FCC', 2);
  mRoll.Params.add('_Allowed=' + mAllowedIDs.CommaText);

  if mRoll.MultiSelectDialog(False, mOLEStrings) then
  begin
    mExistStoreCard:= TStringList.Create();
    try
      for i:= 0 to mOLEStrings.Count - 1 do
      begin
        //mPrefTyp := mDataSet.FieldByName('TypObchodu').AsInteger;
        //mPrefUziti := mDataSet.FieldByName('ZpusobUziti').AsInteger;
        //mPrefUvedeni := mDataSet.FieldByName('ZpusobUvedeni').AsInteger;
        //mPrefZpoplatneny := mDataSet.FieldByName('ZpoplatneniObalu').AsInteger;
        //mPrefOpakovan := mDataSet.FieldByName('OpakovanePouzivany').AsInteger;

        mDataSet.Append;
        mDataSet.FieldByName('ID').AsString:= '0000000000';
        mDataSet.FieldByName('Replacement_ID').AsString:= mOLEStrings.Strings[i];
        //mReplacement:= TDynSiteForm(mSite).CurrentObject.ObjectSpace.CreateObject(Class_StoreCard);
        //mReplacement.Load(mOLEStrings.strings[i],nil);
        //mDataSet.FieldByName('Popis').AsString:=mReplacement.GetFieldValueAsString('X_note');
        //mReplacement.free;
        // Předvyplnění podle posledního
        //mDataSet.FieldByName('TypObchodu').AsInteger := mPrefTyp;
        //mDataSet.FieldByName('ZpusobUziti').AsInteger := mPrefUziti;
        //mDataSet.FieldByName('ZpusobUvedeni').AsInteger := mPrefUvedeni;
        //mDataSet.FieldByName('ZpoplatneniObalu').AsInteger := mPrefZpoplatneny;
        //mDataSet.FieldByName('OpakovanePouzivany').AsInteger := mPrefOpakovan;

        mDataSet.Post;
      end;
      mDataSet.Refresh;
    finally
      mExistStoreCard.Free;
    end;
  end;
end;

procedure delNahradyClick(Sender: TSpeedButton);
var mDataSet: TMemoryDataset;
begin
  mDataSet:= TMemoryDataset(IntToObj(Sender.Tag));
  mDataSet.Delete;
end;

procedure detailNahradyClick(Sender: TSpeedButton);
var mDataSet: TMemoryDataset;
    mPars:TNxParameters;
    msite:TSiteForm;
begin
  mDataSet:= TMemoryDataset(IntToObj(Sender.Tag));
  msite:=NxFindSiteForm(TComponent(Sender));
  mPars := TNxParameters.Create;
  mPars.GetOrCreateParam(dtString, '_Allowed', pkInput).AsString :=mdataset.FieldByName('Replacement_ID').AsString;
  mPars.NewFromDataType(dtBoolean, '_InOtherSlot', pkInput).AsBoolean := True;
  NxShowRoll(msite.SiteContext,'S3WZQKDB5FDL342M01C0CX3FCC',mPars,0,'',Nil);
  mpars.free;
  //NxShowSimpleMessage(mdataset.FieldByName('Replacement_ID').AsString,nil);
end;

{
  Počítané fieldy
}
procedure dsNahradyCalc(DataSet: TDataSet);
var mObjSpace: TNxCustomObjectSpace;
    mBO: TNxCustomBusinessObject;
begin
  try
  OutputDebugString(IntToStr(DataSet.Tag));
  mObjSpace:= TNxCustomObjectSpace(DataSet.Tag);
  mBO:= mObjSpace.CreateObject(Class_StoreCard);
  try
    if not NxIsEmptyOID(DataSet.FieldByName('Replacement_ID').AsString) then
    begin
      OutputDebugString(DataSet.FieldByName('Replacement_ID').AsString);
      mBO.Load(DataSet.FieldByName('Replacement_ID').AsString, nil);
      DataSet.FieldByName('Replacement_ID_Name').AsString:= mBO.GetFieldValueAsString('Name');
      DataSet.FieldByName('Replacement_ID_Code').AsString:= mBO.GetFieldValueAsString('Code');
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
    mBO,  mBOReplacement: TNxCustomBusinessObject;
    mGridLookupColumn : TNxMultiGridLookupColumn;
    mMon : TNxCustomBusinessMonikerCollection;
    mCurrentStoreCard : TNxCustomBusinessObject;
    mGrd : TMultiGrid;
    mComponent: TComponent;
begin
  mComponent:= ASite.FindComponent('lbxComponents');
  if mComponent = nil then exit;
  mListBox:= TListBox(mComponent);

  mCurrentStoreCard := TBusRollSiteForm(ASite).CurrentObject;

  if mCurrentStoreCard <> nil then


  i:= mListBox.Items.IndexOf('dsNahrady');
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
      ' A.X_EKO_UnitQuantity as UnitQuantity, '+
      ' A.X_EKO_Hmotnost as Hmotnost, '+
      ' A.X_EKO_Quantity as Quantity, '+
      ' A.X_EKO_UnitRate as UnitRate '+
      ' FROM DefRollData A ' +
      ' LEFT JOIN STORECARDS SC ON SC.ID = A.X_EKO_ContainerStoreCard_ID ' +
      ' WHERE A.CLSID=''%s'' AND A.X_EKO_StoreCard_ID=''%s''',
      [cReplacementBusinessObject, mCurrentStoreCard.OID]);}

    mSQL:= Format(
      'SELECT A.ID as ID '+
      ' FROM DefRollData A ' +
      ' WHERE A.CLSID=''%s'' AND A.X_StoreCard_ID=''%s''',
      [cReplacementBusinessObject, mCurrentStoreCard.OID]);

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
      mBO:= ASite.BaseObjectSpace.CreateObject(cReplacementBusinessObject);

      try
         mBOReplacement:= ASite.BaseObjectSpace.CreateObject(Class_StoreCard);
        try
          for i:= 0 to mResult.Count - 1 do
          begin
            mBO.Load(mResult[i], nil);

            mDataSet.Append;
            mDataSet.FieldByName('ID').AsString:= mResult[i];


            if not NxIsEmptyOID(mBO.GetFieldValueAsString('X_Replacement_ID')) then
            begin
               mBOReplacement.Load(mBO.GetFieldValueAsString('X_Replacement_ID'), nil);
              mDataSet.FieldByName('Replacement_ID').AsString:=  mBOReplacement.OID;
              mDataSet.FieldByName('Replacement_ID_Code').AsString:= mBOReplacement.GetFieldValueAsString('Code');
              mDataSet.FieldByName('Replacement_ID_Name').AsString:=  mBOReplacement.GetFieldValueAsString('Name');
            end;
            mDataSet.Post;
          end;
        finally
           mBOReplacement.Free();
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
      i:= mListBox.Items.IndexOf('grdNahrady');

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
procedure SaveNahradyRelations(ASite: TSiteForm; AOID: String; aBO: TNxCustomBusinessObject);
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

  i:= mListBox.Items.IndexOf('dsNahrady');

  mDataSet:= TMemoryDataset(mListBox.Items.Objects(i));

  if mDataSet.State <> dsBrowse then
  begin
    if mDataSet.FieldByName('Replacement_ID').AsString <> '' then
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
        'WHERE A.CLSID=''%s'' AND A.X_StoreCard_ID=''%s''',
        [cReplacementBusinessObject, AOID]);

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
          mBO:= ASite.BaseObjectSpace.CreateObject(cReplacementBusinessObject);
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
      mBO:= ASite.BaseObjectSpace.CreateObject(cReplacementBusinessObject);
      try
        mID:= mDataSet.FieldByName('ID').AsString;
        if mID = '0000000000' then
        begin
          mBO.New;
          mBO.Prefill;
        end
        else
          mBO.Load(mID, nil);

        mBO.SetFieldValueAsString('X_StoreCard_ID', AOID);
        mBO.SetFieldValueAsString('X_Replacement_ID', mDataSet.FieldByName('Replacement_ID').AsString);




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
function AddNahradyTabSheet(APageControl: TPageControl): TTabSheet;
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
    Result.Caption:= cNahradyTab;
    Result.Name:= 'tabRP';

    mBottomPnl:= TPanel.Create(Result);
    mBottomPnl.Parent:= Result;
    mBottomPnl.Align:= alBottom;
    mBottomPnl.Height:= 27;
    mBottomPnl.Name:= 'pnlEKOBottom';
    mBottomPnl.Caption:= '';

    mDataSet:= TMemoryDataset.Create(Result);
    mDataSet.Name:= 'dsNahrady';

    mDataSet.FieldDefs.Add('ID', ftWideString, 10);
    mDataSet.FieldDefs.Add('Replacement_ID_Code', ftWideString, 10);
    mDataSet.FieldDefs.Add('Replacement_ID', ftWideString, 10);


    //mDataSet.FieldDefs.Add('Poznámka', ftWideString, 100);
    //mDataSet.FieldDefs.Add('Půjčovné', ftFloat, 0);
    //mDataSet.FieldDefs.Add('Motohodiny', ftFloat, 0);

    mDataSet.Tag:= ObjToInt(APageControl.Site.CompanyObjectSpace);
    mDataSet.onCalcFields:= @dsNahradyCalc;

    try
      mFieldDef:= TFieldDef.Create(mDataSet.FieldDefs, 'Replacement_ID_Name', ftWideString, 100, False, 300001);
      with mFieldDef.CreateField(mDataSet, nil, 'xReplacement_ID_Name', False) do
      begin
        Size:= 100;
        FieldKind:= fkCalculated;
        FieldName:= 'Replacement_ID_Name';
      end;

      mFieldDef:= TFieldDef.Create(mDataSet.FieldDefs, 'ID', ftWideString, 10, False, 300002);
      with mFieldDef.CreateField(mDataSet, nil, 'xID', False) do
      begin
        Size:= 10;
        FieldKind:= fkData;
        FieldName:= 'ID';
      end;

      mFieldDef:= TFieldDef.Create(mDataSet.FieldDefs, 'Replacement_ID_Code', ftWideString, 5, True, 300003);
      with mFieldDef.CreateField(mDataSet, nil, 'xReplacement_ID_Code', False) do
      begin
        Size:= 10;
        FieldKind:= fkData;
        FieldName:= 'Replacement_ID_Code';
      end;

      mFieldDef:= TFieldDef.Create(mDataSet.FieldDefs, 'Replacement_ID', ftWideString, 10, True, 300004);
      with mFieldDef.CreateField(mDataSet, nil, 'xReplacement_ID', False) do
      begin
        Size:= 10;
        FieldKind:= fkData;
        FieldName:= 'Replacement_ID';
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
    mGrd.Name := 'grdNahrady';
    mListBox.Items.AddObject(mGrd.Name, mGrd);

    // StoreCardUnit
    mGridColumn:= TNxMultiGridColumn.Create(mGrd);
    mGridColumn.Layout:= 0;
    mGridColumn.Width:= 180;
    mGridColumn.FieldName:= 'Replacement_ID_Code';
    mGridColumn.Name:= 'Replacement_ID_Code';
    mGridColumn.Caption:= 'Kód';
    mGridColumn.Order:= 0;
    mGridColumn.ReadOnly:= True;
    mGrd.AddColumn(mGridColumn);
    // Název skl. karty
    mGridColumn:= TNxMultiGridColumn.Create(mGrd);
    mGridColumn.Layout:= 0;
    mGridColumn.Width:= 180;
    mGridColumn.FieldName:= 'Replacement_ID_Name';
    mGridColumn.Name:= 'Replacement_ID_Name';
    mGridColumn.Caption:= 'Název náhrady';
    mGridColumn.Order:= 1;
    mGridColumn.ReadOnly:= True;
    mGrd.AddColumn(mGridColumn);


    // Půjčovné



    x:= 1;
    for i:= 0 to 6 do
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
        mBtn[i].onClick:= @btnNahradyCFirst;
      end;
      if i = 1 then
      begin
        mBtn[i].Caption:= '<';
        mBtn[i].onClick:= @btnNahradyCPrior;
      end;
      if i = 2 then
      begin
        mBtn[i].Caption:= '>';
        mBtn[i].onClick:= @btnNahradyCNext;
      end;
      if i = 3 then
      begin
        mBtn[i].Caption:= '>|';
        mBtn[i].onClick:= @btnNahradyCLast;
      end;
      if i = 4 then
      begin
        mBtn[i].Width:= 80;
        mBtn[i].Caption:= cNahradyAdd;
        mBtn[i].onClick:= @addNahradyClick;
        mBtn[i].Tag:= ObjToInt(mDataSet);
        mBtn[i].Name:= 'btnAdd';
      end;
      if i = 5 then
      begin
        mBtn[i].Width:= 80;
        mBtn[i].Caption:= cNahradyDelete;
        mBtn[i].Tag:= ObjToInt(mDataSet);
        mBtn[i].onClick:= @delNahradyClick;
      end;
      if i = 6 then
      begin
        mBtn[i].Width:= 80;
        mBtn[i].Caption:= cNahradyDetail;
        mBtn[i].Tag:= ObjToInt(mDataSet);
        mBtn[i].onClick:= @detailNahradyClick;
      end;
      x:= x + mBtn[i].Width;
    end;

    mDataSet.Open;
    setNahradyEnabled(Result, False);
  except
    OutputDebugString(ExceptionMessage);
  end;
end;

procedure MGColumnReadOnly(Sender: TNxMultiGridCustomColumn; var AReadOnly: Boolean);
begin
  AReadOnly:= False;
  //skladova karta nazev
  if Sender.Name = 'Replacement_ID_Name' then
    AReadOnly:= True;
end;

begin
end.