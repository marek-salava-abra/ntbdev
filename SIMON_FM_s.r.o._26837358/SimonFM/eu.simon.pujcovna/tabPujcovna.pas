const cPujcovnaTab = 'Půjčovna';
      cPujcovnaAdd = 'Přidat';
      cPujcovnaDelete = 'Vymazat';
      cRentalDeviceBusinessObject = 'VFNPR04IPRQ41HGAGUTXNGLWYW';

procedure setPujcovnaEnabled(AWinControl: TWinControl; AEnabled: Boolean);
var i: Integer;
begin
  for i := 0 to AWinControl.ControlCount - 1 do
  begin
    AWinControl.Controls[i].Enabled:= AEnabled;
    if AWinControl.Controls[i] is TWinControl then
      setPujcovnaEnabled(TWinControl(AWinControl.Controls[i]), AEnabled);
  end;
end;

procedure btnPujcovnaCFirst(Sender: TSpeedButton);
begin
  TMemoryDataset(IntToObj(Sender.Tag)).First;
end;

procedure btnPujcovnaCPrior(Sender: TSpeedButton);
begin
  TMemoryDataset(IntToObj(Sender.Tag)).Prior;
end;

procedure btnPujcovnaCNext(Sender: TSpeedButton);
begin
  TMemoryDataset(IntToObj(Sender.Tag)).Next;
end;

procedure btnPujcovnaCLast(Sender: TSpeedButton);
begin
  TMemoryDataset(IntToObj(Sender.Tag)).Last;
end;

{
  Přidat
}
procedure addPujcovnaClick(Sender: TSpeedButton);
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
    mRentalDevice:TNxCustomBusinessObject;
begin
  mDataSet:= TMemoryDataset(IntToObj(Sender.Tag));
  mOLE:= GetAbraOLEApplication;
  mOLEStrings:= GetAbraOLEStrings;
  mAllowedIDs:= GetAbraOLEStrings;
  mSite:=NxFindSiteForm(sender);
  mOLE.SQLSelect(
    'SELECT ID FROM defrolldata WHERE CLSID=''11CZ0SV0RRW4PABA135VLXC3IO'' and hidden=''N'' ', mAllowedIDs);

  mRoll:= mOLE.GetRoll('D23V2QXJVDL4HD5DLBTSJ4D1X4', 2);
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
        mDataSet.FieldByName('RentalDevice_ID').AsString:= mOLEStrings.Strings[i];
        mRentalDevice:= TDynSiteForm(mSite).CurrentObject.ObjectSpace.CreateObject('11CZ0SV0RRW4PABA135VLXC3IO');
        mRentalDevice.Load(mOLEStrings.strings[i],nil);
        mDataSet.FieldByName('Jistina').AsFloat:=mRentalDevice.GetFieldValueAsFloat('U_RecommendDeposit');
        //mDataSet.FieldByName('Půjčovné').AsFloat:=mRentalDevice.GetFieldValueAsFloat('U_rentalamount');
        mDataSet.FieldByName('Půjčovné').AsFloat:=Trunc(Nxround(mRentalDevice.GetFieldValueAsFloat('U_rentalamount')*NxRound(TDynSiteForm(msite).CurrentObject.GetFieldValueAsDateTime('RealDuration$DATE'),ctArithmetic), ctArithmetic));
        mDataSet.FieldByName('Motohodiny').AsFloat:=0.0;
        mRentalDevice.free;
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

procedure delPujcovnaClick(Sender: TSpeedButton);
var mDataSet: TMemoryDataset;
begin
  mDataSet:= TMemoryDataset(IntToObj(Sender.Tag));
  mDataSet.Delete;
end;

{
  Počítané fieldy
}
procedure dsPujcovnaCalc(DataSet: TDataSet);
var mObjSpace: TNxCustomObjectSpace;
    mBO: TNxCustomBusinessObject;
begin
  try
  OutputDebugString(IntToStr(DataSet.Tag));
  mObjSpace:= TNxCustomObjectSpace(DataSet.Tag);
  mBO:= mObjSpace.CreateObject('11CZ0SV0RRW4PABA135VLXC3IO');
  try
    if not NxIsEmptyOID(DataSet.FieldByName('RentalDevice_ID').AsString) then
    begin
      OutputDebugString(DataSet.FieldByName('RentalDevice_ID').AsString);
      mBO.Load(DataSet.FieldByName('RentalDevice_ID').AsString, nil);
      DataSet.FieldByName('RentalDevice_ID_Name').AsString:= mBO.GetFieldValueAsString('Name');
      DataSet.FieldByName('RentalDevice_ID_Code').AsString:= mBO.GetFieldValueAsString('Code');
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
    mBO,  mBORentalDevice: TNxCustomBusinessObject;
    mGridLookupColumn : TNxMultiGridLookupColumn;
    mMon : TNxCustomBusinessMonikerCollection;
    mCurrentActivity : TNxCustomBusinessObject;
    mGrd : TMultiGrid;
    mComponent: TComponent;
begin
  mComponent:= ASite.FindComponent('lbxComponents');
  if mComponent = nil then exit;
  mListBox:= TListBox(mComponent);

  mCurrentActivity := TDynSiteForm(ASite).CurrentObject;

  if mCurrentActivity <> nil then


  i:= mListBox.Items.IndexOf('dsPujcovna');
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
      [cRentalDeviceBusinessObject, mCurrentActivity.OID]);}

    mSQL:= Format(
      'SELECT A.ID as ID '+
      ' FROM DefRollData A ' +
      ' WHERE A.CLSID=''%s'' AND A.X_Activity_ID=''%s''',
      [cRentalDeviceBusinessObject, mCurrentActivity.OID]);

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
      mBO:= ASite.BaseObjectSpace.CreateObject(cRentalDeviceBusinessObject);

      try
         mBORentalDevice:= ASite.BaseObjectSpace.CreateObject('11CZ0SV0RRW4PABA135VLXC3IO');
        try
          for i:= 0 to mResult.Count - 1 do
          begin
            mBO.Load(mResult[i], nil);

            mDataSet.Append;
            mDataSet.FieldByName('ID').AsString:= mResult[i];

            if not NxIsEmptyOID(mBO.GetFieldValueAsString('X_RentalDevice_ID')) then
            begin
               mBORentalDevice.Load(mBO.GetFieldValueAsString('X_RentalDevice_ID'), nil);
               mDataSet.FieldByName('RentalDevice_ID_Code').AsString:= mBORentalDevice.GetFieldValueAsString('Code');
              mDataSet.FieldByName('RentalDevice_ID').AsString:=  mBORentalDevice.OID;
              mDataSet.FieldByName('RentalDevice_ID_Name').AsString:=  mBORentalDevice.GetFieldValueAsString('Name');
            end;


            mDataSet.FieldByName('Jistina').AsFloat:= mBO.GetFieldValueAsFloat('U_RecommendDeposit');
            mDataSet.FieldByName('Půjčovné').AsFloat := mBO.GetFieldValueAsFloat('U_RentalAmount');
            mDataSet.FieldByName('Motohodiny').AsFloat := mBO.GetFieldValueAsFloat('U_motohodiny');
            //mDataSet.FieldByName('UnitRate').AsFloat := mBO.GetFieldValueAsFloat('X_EKO_UnitRate');
            mDataSet.Post;
          end;
        finally
           mBORentalDevice.Free();
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
      i:= mListBox.Items.IndexOf('grdPujcovna');

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
procedure SavePujcovnaRelations(ASite: TSiteForm; AOID: String; aBO: TNxCustomBusinessObject);
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

  i:= mListBox.Items.IndexOf('dsPujcovna');

  mDataSet:= TMemoryDataset(mListBox.Items.Objects(i));

  if mDataSet.State <> dsBrowse then
  begin
    if mDataSet.FieldByName('RentalDevice_ID').AsString <> '' then
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
        'WHERE A.CLSID=''%s'' AND A.X_Activity_ID=''%s''',
        [cRentalDeviceBusinessObject, AOID]);

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
          mBO:= ASite.BaseObjectSpace.CreateObject(cRentalDeviceBusinessObject);
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
      mBO:= ASite.BaseObjectSpace.CreateObject(cRentalDeviceBusinessObject);
      try
        mID:= mDataSet.FieldByName('ID').AsString;
        if mID = '0000000000' then
        begin
          mBO.New;
          mBO.Prefill;
        end
        else
          mBO.Load(mID, nil);

        mBO.SetFieldValueAsString('X_Activity_ID', AOID);
        mBO.SetFieldValueAsString('X_RentalDevice_ID', mDataSet.FieldByName('RentalDevice_ID').AsString);
        mBo.SetFieldValueAsFloat('U_RentalAmount',mDataSet.FieldByName('Půjčovné').AsFloat);
        mBo.SetFieldValueAsFloat('U_RecommendDeposit',mDataSet.FieldByName('Jistina').AsFloat);
        mBo.SetFieldValueAsFloat('U_motohodiny',mDataSet.FieldByName('Motohodiny').AsFloat);
        mbo.SetFieldValueAsString('U_Firm_ID',Abo.GetFieldValueAsString('Firm_ID'));
        mbo.SetFieldValueAsString('U_Person_ID',Abo.GetFieldValueAsString('Person_ID'));
        mbo.SetFieldValueAsDateTime('U_enddate', aBO.GetFieldValueAsDateTime('RealEnd$DATE'));



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
function AddPujcovnaTabSheet(APageControl: TPageControl): TTabSheet;
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
    Result.Caption:= cPujcovnaTab;
    Result.Name:= 'tabPujcovna';

    mBottomPnl:= TPanel.Create(Result);
    mBottomPnl.Parent:= Result;
    mBottomPnl.Align:= alBottom;
    mBottomPnl.Height:= 27;
    mBottomPnl.Name:= 'pnlEKOBottom';
    mBottomPnl.Caption:= '';

    mDataSet:= TMemoryDataset.Create(Result);
    mDataSet.Name:= 'dsPujcovna';

    mDataSet.FieldDefs.Add('ID', ftWideString, 10);
    mDataSet.FieldDefs.Add('RentalDevice_ID_Code', ftWideString, 10);
    mDataSet.FieldDefs.Add('RentalDevice_ID', ftWideString, 10);


    mDataSet.FieldDefs.Add('Jistina', ftFloat, 0);
    mDataSet.FieldDefs.Add('Půjčovné', ftFloat, 0);
    mDataSet.FieldDefs.Add('Motohodiny', ftFloat, 0);

    mDataSet.Tag:= ObjToInt(APageControl.Site.CompanyObjectSpace);
    mDataSet.onCalcFields:= @dsPujcovnaCalc;

    try
      mFieldDef:= TFieldDef.Create(mDataSet.FieldDefs, 'RentalDevice_ID_Name', ftWideString, 100, False, 300001);
      with mFieldDef.CreateField(mDataSet, nil, 'xRentalDevice_ID_Name', False) do
      begin
        Size:= 100;
        FieldKind:= fkCalculated;
        FieldName:= 'RentalDevice_ID_Name';
      end;

      mFieldDef:= TFieldDef.Create(mDataSet.FieldDefs, 'ID', ftWideString, 10, False, 300002);
      with mFieldDef.CreateField(mDataSet, nil, 'xID', False) do
      begin
        Size:= 10;
        FieldKind:= fkData;
        FieldName:= 'ID';
      end;

      mFieldDef:= TFieldDef.Create(mDataSet.FieldDefs, 'RentalDevice_ID_Code', ftWideString, 5, True, 300003);
      with mFieldDef.CreateField(mDataSet, nil, 'xRentalDevice_ID_Code', False) do
      begin
        Size:= 10;
        FieldKind:= fkData;
        FieldName:= 'RentalDevice_ID_Code';
      end;

      mFieldDef:= TFieldDef.Create(mDataSet.FieldDefs, 'RentalDevice_ID', ftWideString, 10, True, 300004);
      with mFieldDef.CreateField(mDataSet, nil, 'xRentalDevice_ID', False) do
      begin
        Size:= 10;
        FieldKind:= fkData;
        FieldName:= 'RentalDevice_ID';
      end;



      mFieldDef:= TFieldDef.Create(mDataSet.FieldDefs, 'Jistina', ftFloat, 0, True, 300012);
      with mFieldDef.CreateField(mDataSet, nil, 'xJistina', False) do
      begin
        FieldKind:= fkData;
        FieldName:= 'Jistina';
      end;

      mFieldDef:= TFieldDef.Create(mDataSet.FieldDefs, 'Půjčovné', ftFloat, 0, True, 300013);
      with mFieldDef.CreateField(mDataSet, nil, 'xPůjčovné', False) do
      begin
        FieldKind:= fkData;
        FieldName:= 'Půjčovné';
      end;

      mFieldDef:= TFieldDef.Create(mDataSet.FieldDefs, 'Motohodiny', ftFloat, 0, True, 300014);
      with mFieldDef.CreateField(mDataSet, nil, 'xMotohodiny', False) do
      begin
        FieldKind:= fkData;
        FieldName:= 'Motohodiny';
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
    mGrd.Name := 'grdPujcovna';
    mListBox.Items.AddObject(mGrd.Name, mGrd);

    // StoreCardUnit
    mGridColumn:= TNxMultiGridColumn.Create(mGrd);
    mGridColumn.Layout:= 0;
    mGridColumn.Width:= 180;
    mGridColumn.FieldName:= 'RentalDevice_ID_Code';
    mGridColumn.Name:= 'RentalDevice_ID_Code';
    mGridColumn.Caption:= 'Kód';
    mGridColumn.Order:= 0;
    mGridColumn.ReadOnly:= True;
    mGrd.AddColumn(mGridColumn);
    // Název skl. karty
    mGridColumn:= TNxMultiGridColumn.Create(mGrd);
    mGridColumn.Layout:= 0;
    mGridColumn.Width:= 180;
    mGridColumn.FieldName:= 'RentalDevice_ID_Name';
    mGridColumn.Name:= 'RentalDevice_ID_Name';
    mGridColumn.Caption:= 'Název zařízení';
    mGridColumn.Order:= 1;
    mGridColumn.ReadOnly:= True;
    mGrd.AddColumn(mGridColumn);

    // Jistina
    mGridColumn:= TNxMultiGridColumn.Create(mGrd);
    mGridColumn.Layout:= 0;
    mGridColumn.Width:= 70;
    mGridColumn.Order:= 7;
    mGridColumn.FieldName:= 'Jistina';
    mGridColumn.Caption:= 'Jistina';
    mGrd.AddColumn(mGridColumn);
    // Půjčovné

    mGridColumn:= TNxMultiGridColumn.Create(mGrd);
    mGridColumn.Layout:= 0;
    mGridColumn.Width:= 70;
    mGridColumn.Order:= 9;
    mGridColumn.FieldName:= 'Půjčovné';
    mGridColumn.Caption:= 'Půjčovné';
    mGrd.AddColumn(mGridColumn);

    mGridColumn:= TNxMultiGridColumn.Create(mGrd);
    mGridColumn.Layout:= 0;
    mGridColumn.Width:= 70;
    mGridColumn.Order:= 10;
    mGridColumn.FieldName:= 'Motohodiny';
    mGridColumn.Caption:= 'Motohodiny';
    //mGridColumn.
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
        mBtn[i].onClick:= @btnPujcovnaCFirst;
      end;
      if i = 1 then
      begin
        mBtn[i].Caption:= '<';
        mBtn[i].onClick:= @btnPujcovnaCPrior;
      end;
      if i = 2 then
      begin
        mBtn[i].Caption:= '>';
        mBtn[i].onClick:= @btnPujcovnaCNext;
      end;
      if i = 3 then
      begin
        mBtn[i].Caption:= '>|';
        mBtn[i].onClick:= @btnPujcovnaCLast;
      end;
      if i = 4 then
      begin
        mBtn[i].Width:= 80;
        mBtn[i].Caption:= cPujcovnaAdd;
        mBtn[i].onClick:= @addPujcovnaClick;
        mBtn[i].Tag:= ObjToInt(mDataSet);
        mBtn[i].Name:= 'btnAdd';
      end;
      if i = 5 then
      begin
        mBtn[i].Width:= 80;
        mBtn[i].Caption:= cPujcovnaDelete;
        mBtn[i].Tag:= ObjToInt(mDataSet);
        mBtn[i].onClick:= @delPujcovnaClick;
      end;
      x:= x + mBtn[i].Width;
    end;

    mDataSet.Open;
    setPujcovnaEnabled(Result, False);
  except
    OutputDebugString(ExceptionMessage);
  end;
end;

procedure MGColumnReadOnly(Sender: TNxMultiGridCustomColumn; var AReadOnly: Boolean);
begin
  AReadOnly:= False;
  //skladova karta nazev
  if Sender.Name = 'RentalDevice_ID_Name' then
    AReadOnly:= True;
end;

procedure PrintDocs(AObject: TNxCustomBusinessObject);
var
 mList, mRentList:Tstringlist;
 mSQL:String;
 mOS:TNxCustomObjectSpace;
 mJistina:Extended;
 mBO:TNxCustomBusinessObject;
 i:Integer;
begin
  if osNew in AObject.State then begin
      if AObject.GetFieldValueAsString('ActQueue_ID')='2000000101' then begin
      mJistina:=0;
       mRentList:=TStringList.Create;
       mSQL:= Format(
      'SELECT A.ID as ID '+
      ' FROM DefRollData A ' +
      ' WHERE A.CLSID=''%s'' AND A.X_Activity_ID=''%s''',
      [cRentalDeviceBusinessObject, AObject.OID]);
       mOS:=AObject.ObjectSpace;
       mBO:= mOS.CreateObject(cRentalDeviceBusinessObject);
       mOS.SQLSelect(mSQL,mRentList);
       if mRentList.Count>0 then begin
         for i:=0 to mRentList.Count-1 do begin
           mBO.Load(mRentList.strings[i], nil);
           mJistina:=mJistina+mbo.GetFieldValueAsFloat('U_jistina');
         end;
       end;
       mList:=TStringList.Create;
       mlist.add(AObject.OID);
       CFxReportManager.PrintByIDs(NxCreateContext_1(AObject),mList,'YAQO3JZE02Y4L1PJGSXVJE41A4','1I50000101',rtoPreview,pekPDF,'','');
       if mJistina>0 then CFxReportManager.PrintByIDs(NxCreateContext_1(AObject),mList,'YAQO3JZE02Y4L1PJGSXVJE41A4','1J50000101',rtoPreview,pekPDF,'','');
       mList.Free;
      end;
  end;
end;

begin
end.