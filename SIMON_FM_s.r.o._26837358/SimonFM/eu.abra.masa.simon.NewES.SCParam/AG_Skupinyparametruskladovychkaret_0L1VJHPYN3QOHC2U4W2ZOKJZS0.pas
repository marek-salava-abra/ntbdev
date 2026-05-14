//konstanty je potřeba zkontrolovat a upravit podle podmínek klienta

const
  //číselníky
  cRollSCTypeCLSID = 'GBN12GNTN1AOR54HSBRYWJ3LSS';
  cRollPropertyNameCLSID = 'GTBN5PZAVZP41EHWQVCF4YCHHW';
  cRollRollValueCLSID = 'JF1P4PG3DFW4HG3MPZDJ1BLSQG';
  //BO objecty
  //cBOPropertyCLSID = 'CROP15BJD5VOB5AKA0X2MBJIVW';
  cBOPropertyCLSID = '2TIIQXNXIXK4B5CZUIZ20K2W10';
  cBOSCTypeCLSID = 'JJORYPKZ4P34HB3KXDE1S5TX34';
  cBOPropertyNameCLSID = '1FITSCLXY0W45123N0VSVNVMUW';
  cBORollValueCLSID = '1NPNI4M2JIVOFBV23CHPHFPN5W';
  cRelDef = '01';
  //přepnutí jazykové verze
  mLang = 'CS';
  //mLang = 'SK';

var mCanLookup: Boolean; //příznak, kdy se smí zobrazovat názvy (kvůli rychlosti)
  mAfterInsertActive: Boolean; //příznak jestli funguje AfterInsert na datasetu
  mCacheRollValues: TStrings; //cache pro rychlejší zobrazování dat
  mCachePropertyNames: TStrings;
  mCacheStorecardTypes: TStrings;

procedure _MainDatasetBeforeScroll_Hook(Self: TBusRollSiteForm);
begin
  CheckParamsIsSave(Self);
end;

procedure FormCloseQuery_Hook(Self: TSiteForm; var CanClose: Boolean);
begin
  if CanClose then
    CanClose := IsPossibilityEndParams(Self);
end;

procedure _MainDatasetAfterScroll_Hook(Self: TRollSiteForm);
begin
  RefreshParams(Self);
end;

procedure InitSite_Hook(Self: TSiteForm);
var mControl: TControl;
  mListBox: TListBox;
  mAction:TBasicAction;
begin
  mCacheRollValues := TStringList.Create;
  mCachePropertyNames := TStringList.Create;
  mCacheStorecardTypes := TStringList.Create;

  mControl := NxFindChildControl(Self.GetSiteAppForm, 'pgcDataViews');
  if mControl <> nil then begin
    mListBox := TListBox.Create(Self);
    mListBox.Parent := Self;
    mListBox.Name := 'DSCComponents';
    mListBox.Visible := False;
    mListBox.Items.addObject('ObjectSpace', Self.CompanyObjectSpace);
    mListBox.Items.addObject('Site', Self);
    AddParamsTabSheet(Self, TPageControl(mControl));
  end;
end;

procedure FormDestroy_Hook(Self: TSiteForm);
begin
  mCacheRollValues.free;
  mCacheRollValues := nil;
  mCachePropertyNames.free;
  mCachePropertyNames := nil;
  //mCacheStorecardTypes.free;
  //mCacheStorecardTypes := nil;
end;


function AddParamsTabSheet(Self: TSiteForm; APageControl: TPageControl): TTabSheet;
var mPnl: TPanel;
  mBottomPnl: TPanel;
  mGrd: TMultiGrid;
  mGridColumn: TNxMultiGridCustomColumn;
  mGridDateColumn: TNxMultiGridDateColumn;
  mGridLookupColumn: TNxMultiGridLookupColumn;
  mGridObjectRollColumn: TNxMultiGridObjectRollColumn;
  mBtn: array[0..6] of TButton;
  mCheckBox: TCheckBox;
  i, x: Integer;
  mDataSet: TMemoryDataSet;
  mDataSource: TDataSource;
  mListBox: TListBox;
  mFieldDef: TFieldDef;
  mField: TField;
  mAct: TAction;
  mPrvileg, mPrvileg1: TNXParameters;
  mSuper, mCanEdit, mCanDelete: Boolean;
  pnParamsTop: TPanel;
  mParamsInfoName: TLabel;
begin
  try
    mListBox := TListBox(NxFindChildControl(NxFindSiteForm(APageControl), 'DSCComponents'));

    Result := TTabSheet.Create(APageControl);
    Result.PageControl := APageControl;
    Result.Caption := '&Parametry';
    Result.Name := 'tabParamsDSC';

    try
      mPrvileg := TNXParameters.Create;
      try
        GetEffectiveFunctionSecurityRights(Self.CompanyCache, Self.BaseObjectSpace, 'XP0SF1KD0L24ND21EZBS5Q0RAO', NxGetActualUserID(Self.BaseObjectSpace), mPrvileg);
        mSuper := mPrvileg.ParamAsBoolean('G1TDNZSKTVCL33N2010DELDFKK:Supervisor', False);
        mPrvileg1 := GetRightsParam(mPrvileg, dtList, 'XP0SF1KD0L24ND21EZBS5Q0RAO').AsList;
        mPrvileg1 := GetRightsParam(mPrvileg1, dtList, 'XP0SF1KD0L24ND21EZBS5Q0RAO').AsList;
        //mCanEdit := (mSuper) or (GetRightsParam(mPrvileg1, dtBoolean, 'EJ2T4X04K1R43DN20ZUNOJEEOO').AsBoolean);
        //mCanDelete := (mSuper) or (GetRightsParam(mPrvileg1, dtBoolean, 'QMGZ4C2BFGEOF1ZAJDZPLH0BOK').AsBoolean);
        mCanEdit :=True;
        mCanDelete := True;
      finally
        mPrvileg.Free;
      end;
    except
      OutputDebugString(ExceptionMessage);
    end;

    mPnl := TPanel.Create(Result);
    mPnl.Parent := Result;
    mPnl.Align := alClient;
    mPnl.Name := 'pnlParams';
    mPnl.Caption := '';
    mPnl.BevelOuter := bvNone; //bvLowered;
    mPnl.BevelInner := bvNone;
    mPnl.BorderStyle := bsNone;
    mPnl.Color := -16777194;

    mParamsInfoName := CreateInfoPanel(Self, Result, mPnl);

    mBottomPnl := TPanel.Create(Result);
    mBottomPnl.Parent := mPnl;
    mBottomPnl.Align := alBottom;
    mBottomPnl.Height := 27;
    mBottomPnl.Name := 'pnlParamsBottom';
    mBottomPnl.Caption := '';
    mBottomPnl.BevelOuter := bvLowered;
    mBottomPnl.BevelInner := bvNone;
    mBottomPnl.BorderStyle := bsNone;

    mDataSet := TMemoryDataSet.Create(Result);
    mDataSet.Name := 'dsParams';
    mDataSet.Tag := ObjToInt(mListBox);
    mDataSet.OnFilterRecord := @dsParamsFilterRecord;
    mDataSet.Filtered := True;
    mDataSet.onCalcFields := @dsParamsCalc;

    //vytvoření polí datasetu
    try
      mFieldDef := TFieldDef.Create(mDataSet.FieldDefs, 'ID', ftString, 10, False, 300001);
      with mFieldDef.CreateField(mDataSet, nil, 'xID', False) do begin
        Size := 10;
        FieldKind := fkData;
        FieldName := 'ID';
      end;

      {mFieldDef := TFieldDef.Create(mDataSet.FieldDefs, 'StoreCardType_ID', ftString, 10, False, 300002);
      with mFieldDef.CreateField(mDataSet, nil, 'xStoreCardType_ID', False) do begin
        Size := 10;
        FieldKind := fkData;
        FieldName := 'StoreCardType_ID';
      end;
      mFieldDef := TFieldDef.Create(mDataSet.FieldDefs, 'StoreCardType_ID_Name', ftString, 100, False, 300003);
      with mFieldDef.CreateField(mDataSet, nil, 'xStoreCardType_ID_Name', False) do begin
        Size := 100;
        FieldKind := fkCalculated;
        FieldName := 'StoreCardType_ID_Name';
      end;}
      mFieldDef := TFieldDef.Create(mDataSet.FieldDefs, 'Property_ID', ftString, 10, False, 300004);
      with mFieldDef.CreateField(mDataSet, nil, 'xProperty_ID', False) do begin
        Size := 10;
        FieldKind := fkData;
        FieldName := 'Property_ID';
      end;
      mFieldDef := TFieldDef.Create(mDataSet.FieldDefs, 'Property_ID_Name', ftString, 100, False, 300005);
      with mFieldDef.CreateField(mDataSet, nil, 'xProperty_ID_Name', False) do begin
        Size := 100;
        FieldKind := fkCalculated;
        FieldName := 'Property_ID_Name';
      end;

      mFieldDef := TFieldDef.Create(mDataSet.FieldDefs, 'RollValue', ftString, 10, False, 300006);
      with mFieldDef.CreateField(mDataSet, nil, 'xRollValue', False) do begin
        Size := 10;
        FieldKind := fkData;
        FieldName := 'RollValue';
      end;

      mFieldDef := TFieldDef.Create(mDataSet.FieldDefs, 'RollValue_Name', ftString, 100, False, 300007);
      with mFieldDef.CreateField(mDataSet, nil, 'xRollValue_Name', False) do begin
        Size := 100;
        FieldKind := fkCalculated;
        FieldName := 'RollValue_Name';
      end;

      mFieldDef := TFieldDef.Create(mDataSet.FieldDefs, 'MarkForDelete', ftBoolean, 0, False, 300008);
      with mFieldDef.CreateField(mDataSet, nil, 'xMarkForDelete', False) do begin
        FieldKind := fkData;
        FieldName := 'MarkForDelete';
      end;

      mFieldDef := TFieldDef.Create(mDataSet.FieldDefs, 'DataType', ftInteger, 0, False, 300009);
      with mFieldDef.CreateField(mDataSet, nil, 'xDataType', False) do begin
        FieldKind := fkData;
        FieldName := 'DataType';
      end;

      mFieldDef := TFieldDef.Create(mDataSet.FieldDefs, 'PosIndex', ftString, 10, False, 300010);
      with mFieldDef.CreateField(mDataSet, nil, 'xPosIndex', False) do begin
        FieldKind := fkData;
        FieldName := 'PosIndex';
      end;
      {mFieldDef:= TFieldDef.Create(mDataSet.FieldDefs, 'ParamValue', ftString, 40, True, 300008);
      with mFieldDef.CreateField(mDataSet, nil, 'xParamValue', False) do
      begin
        FieldKind:= fkData;
        FieldName:= 'ParamValue';
      end; }
    except
      OutputDebugString(ExceptionMessage);
    end;

    mListBox.Items.AddObject(mDataSet.Name, mDataSet);
    mListBox.Items.AddObject(Result.Name, Result);
    mListBox.Items.AddObject(mParamsInfoName.Name, mParamsInfoName);

    mDataSource := TDataSource.Create(Result);
    mDataSource.DataSet := mDataSet;
    mDataSet.AfterInsert := @dsParamsAfterInsert;

    mGrd := TMultiGrid.Create(NxFindChildControl(NxFindSiteForm(APageControl), 'DSCComponents'));
    mGrd.Parent := mPnl;
    mGrd.Name := 'grdParams';
    TControl(mGrd).Align := alClient;
    mGrd.DataSource := mDataSource;
    mGrd.Tag := ObjToInt(mDataSet);

    mGridColumn := TNxMultiGridCustomColumn.Create(mGrd);
    mGridColumn.Layout := 0;
    mGridColumn.Line := 0;
    mGridColumn.Order := 0;
    mGridColumn.FieldName := 'PosIndex';
    mGridColumn.Caption := 'Poř.';
    mGridColumn.Width := 25;
    mGrd.AddColumn(mGridColumn);

    {mGridObjectRollColumn := TNxMultiGridObjectRollColumn.Create(mGrd);
    TNxMultiGridCustomColumn(mGridObjectRollColumn).Complete := True;
    TNxMultiGridCustomColumn(mGridObjectRollColumn).Layout := 0;
    TNxMultiGridCustomColumn(mGridObjectRollColumn).Line := 0;
    TNxMultiGridCustomColumn(mGridObjectRollColumn).FieldName := 'StoreCardType_ID';
    TNxMultiGridCustomColumn(mGridObjectRollColumn).Caption := 'Typ karty';
    TNxMultiGridCustomColumn(mGridObjectRollColumn).Order := 1;
    TNxMultiGridCustomColumn(mGridObjectRollColumn).Width := 70;
    mGridObjectRollColumn.SecurityMask := 2;
    mGridObjectRollColumn.TextField := 'Code';
    mGrd.AddColumn(mGridObjectRollColumn);
    mGrd.OnGetColumnReadOnly := @scNameGetColumnReadOnly;
    mGridObjectRollColumn.ClassID := cRollSCTypeCLSID;

    mGridColumn := TNxMultiGridCustomColumn.Create(mGrd);
    mGridColumn.Layout := 0;
    mGridColumn.Line := 0;
    mGridColumn.Order := 2;
    mGridColumn.FieldName := 'StoreCardType_ID_Name';
    mGridColumn.Caption := 'Název typu karty';
    mGridColumn.Name := 'gcStoreCardType_ID_Name';
    mGridColumn.ReadOnly := True;
    mGridColumn.Width := 200;
    mGrd.AddColumn(mGridColumn);}

    mGridObjectRollColumn := TNxMultiGridObjectRollColumn.Create(mGrd);
    TNxMultiGridCustomColumn(mGridObjectRollColumn).Complete := True;
    TNxMultiGridCustomColumn(mGridObjectRollColumn).Layout := 0;
    TNxMultiGridCustomColumn(mGridObjectRollColumn).Line := 0;
    TNxMultiGridCustomColumn(mGridObjectRollColumn).FieldName := 'Property_ID';
    TNxMultiGridCustomColumn(mGridObjectRollColumn).Caption := 'Kód';
    TNxMultiGridCustomColumn(mGridObjectRollColumn).Order := 3;
    TNxMultiGridCustomColumn(mGridObjectRollColumn).Width := 70;
    mGridObjectRollColumn.SecurityMask := 2;
    mGridObjectRollColumn.TextField := 'Code';
    mGrd.AddColumn(mGridObjectRollColumn);
    mGrd.OnGetColumnReadOnly := @scNameGetColumnReadOnly;
    mGridObjectRollColumn.ClassID := 'NINS0ND1D5N4NHTXYNU4QUPDVO';

    mGridColumn := TNxMultiGridCustomColumn.Create(mGrd);
    mGridColumn.Layout := 0;
    mGridColumn.Order := 4;
    mGridColumn.Line := 0;
    mGridColumn.FieldName := 'Property_ID_Name';
    mGridColumn.Caption := 'Název parametru';
    mGridColumn.Name := 'gcProperty_ID_Name';
    mGridColumn.ReadOnly := True;
    mGridColumn.Width := 100;
    mGridColumn.Elastic := true;
    mGrd.AddColumn(mGridColumn);

    {mGridObjectRollColumn := TNxMultiGridObjectRollColumn.Create(mGrd);
    TNxMultiGridCustomColumn(mGridObjectRollColumn).Complete := True;
    TNxMultiGridCustomColumn(mGridObjectRollColumn).Layout := 0;
    TNxMultiGridCustomColumn(mGridObjectRollColumn).Line := 0;
    TNxMultiGridCustomColumn(mGridObjectRollColumn).FieldName := 'RollValue';
    TNxMultiGridCustomColumn(mGridObjectRollColumn).Caption := 'Hodnota';
    TNxMultiGridCustomColumn(mGridObjectRollColumn).Order := 5;
    TNxMultiGridCustomColumn(mGridObjectRollColumn).Width := 70;
    mGridObjectRollColumn.SecurityMask := 2;
    mGridObjectRollColumn.TextField := 'Code';
    mGrd.AddColumn(mGridObjectRollColumn);
    mGrd.OnGetColumnReadOnly := @scNameGetColumnReadOnly;
    mGridObjectRollColumn.ClassID := cRollRollValueCLSID;

    mGridColumn := TNxMultiGridCustomColumn.Create(mGrd);
    mGridColumn.Layout := 0;
    mGridColumn.Order := 6;
    mGridColumn.Line := 0;
    mGridColumn.FieldName := 'RollValue_Name';
    mGridColumn.Caption := 'Název hodnoty';
    mGridColumn.Name := 'gcRollValue_Name';
    mGridColumn.ReadOnly := True;
    mGridColumn.Width := 100;
    mGrd.AddColumn(mGridColumn);  }

{
    mGridLookupColumn := TNxMultiGridLookupColumn.Create(mGrd);
    TNxMultiGridCustomColumn(mGridLookupColumn).Layout := 0;
    TNxMultiGridCustomColumn(mGridLookupColumn).Line := 0;
    TNxMultiGridCustomColumn(mGridLookupColumn).FieldName := 'DataType';
    TNxMultiGridCustomColumn(mGridLookupColumn).Caption := 'Datový typ';
    TNxMultiGridCustomColumn(mGridLookupColumn).Order := 7;
    TNxMultiGridCustomColumn(mGridLookupColumn).Width := 100;

    mGridLookupColumn.Values.add('Text=1');
    mGridLookupColumn.Values.add('Ano/Ne=2');
    mGridLookupColumn.Values.add('URL=3');
    mGridLookupColumn.Values.add('Číselník. hodnota=4');
    mGrd.AddColumn(mGridLookupColumn);

    mGridColumn:= TNxMultiGridColumn.Create(mGrd);
    mGridColumn.Layout:= 0;
    mGridColumn.Width:= 400;
    mGridColumn.Order:= 7;
    mGridColumn.FieldName:= 'ParamValue';
    mGridColumn.Caption:= 'Hodnota';
    mGrd.AddColumn(mGridColumn);

    mGridColumn:= TNxMultiGridColumn.Create(mGrd);
    mGridColumn.Layout:= 0;
    mGridColumn.Width:= 70;
    mGridColumn.Order:= 7;
    mGridColumn.FieldName:= 'Price';
    mGridColumn.Caption:= 'Cena';
    mGrd.AddColumn(mGridColumn); }
    x := 1;
    for i := 0 to 5 do begin
      mBtn[i] := TButton.Create(mBottomPnl);
      mBtn[i].Parent := mBottomPnl;
      mBtn[i].Left := x;
      mBtn[i].Top := 1;
      mBtn[i].Height := 25;
      mBtn[i].Width := 25;
      mBtn[i].Caption := '';
      mBtn[i].Tag := ObjToInt(mDataSet);
      mBtn[i].Name := 'navBtn_' + IntToStr(i);
      if i = 0 then begin
        mBtn[i].Caption := '|<';
        mBtn[i].onClick := @btnParamsFirst;
      end;
      if i = 1 then begin
        mBtn[i].Caption := '<';
        mBtn[i].onClick := @btnParamsPrior;
      end;
      if i = 2 then begin
        mBtn[i].Caption := '>';
        mBtn[i].onClick := @btnParamsNext;
      end;
      if i = 3 then begin
        mBtn[i].Caption := '>|';
        mBtn[i].onClick := @btnParamsLast;
      end;
      if i = 4 then begin
        mBtn[i].Width := 80;
        mBtn[i].Caption := 'Přidat';
        mBtn[i].onClick := @addParamsClick;
        mBtn[i].Tag := ObjToInt(mDataSet);
        mBtn[i].Name := 'btnAdd';
      end;
      if i = 5 then begin
        mBtn[i].Width := 80;
        mBtn[i].Caption := 'Vymazat';
        mBtn[i].Tag := ObjToInt(mDataSet);
        if not mCanDelete then
          mBtn[i].Tag := mBtn[i].Tag * (-1);
        mBtn[i].onClick := @delPackagesClick;
      end;
      if i = 6 then begin
        mBtn[i].Width := 100;
        mBtn[i].Caption := 'Doplnit podle...';
        mBtn[i].onClick := @addFromClick;
        mBtn[i].Tag := ObjToInt(mDataSet);
        mBtn[i].Name := 'btnAddFrom';
      end;
      x := x + mBtn[i].Width;
    end;

    mDataSet.Active := true;
    setParamsEnabled(Result, False);

    mAct := Self.GetNewAction;
    mAct.Name := 'm2actLSEdit';
    mAct.Caption := 'Editovat';
    mAct.Category := Result.Name;
    mAct.ShortCut := TextToShortCut('F4');
    mAct.OnExecute := @actLSEditExecute;
    if not mCanEdit then
      mAct.Tag := -1;
    mListBox.Items.AddObject('m2actLSEdit', mAct);

    mAct := Self.GetNewAction;
    mAct.Name := 'm2actLSRefresh';
    mAct.Caption := 'Občerstvit';
    mAct.Category := Result.Name;
    mAct.ShortCut := TextToShortCut('F11');
    mAct.OnExecute := @actLSRefreshExecute;
    mListBox.Items.AddObject('m2actLSRefresh', mAct);

    mAct := Self.GetNewAction;
    mAct.Name := 'm2actLSSave';
    mAct.Caption := 'Uložit';
    mAct.Category := Result.Name;
    mAct.KeepApart := True;
    mAct.Visible := False;
    mAct.Default := True;
    mAct.Enabled := false;
    mAct.OnExecute := @actLSSaveExecute;
    mListBox.Items.AddObject('m2actLSSave', mAct);

    mAct := Self.GetNewAction;
    mAct.Name := 'm2actLSCancel';
    mAct.Caption := 'Zrušit';
    mAct.Category := Result.Name;
    mAct.KeepApart := True;
    mAct.Visible := False;
    mAct.Enabled := false;
    mAct.ShortCut := TextToShortCut('ESC');
    mAct.OnExecute := @actLSCancelExecute;
    mListBox.Items.AddObject('m2actLSCancel', mAct);

    TPageControl(Self.FindComponent('pgcDataViews')).OnChange := @pgcDataViewsChange;
    TPageControl(Self.FindComponent('pgcDataViews')).OnChanging := @pgcDataViewsChanging;
  except
    OutputDebugString(ExceptionMessage);
  end;
end;


function GetRightsParam(AParam: TNXParameters; const ADataType: TNxDataType;
  const AName: string; const AKind: TNxParamKind = pkInput): TNxParameter;
var i: Integer;
begin
  Result := nil;
  for i := 0 to AParam.Count - 1 do
    if Copy(AParam.Params[i].Name, 1, 27) = AName + ':' then begin
      Result := AParam.Params[i];
      break;
    end;
end;

function CreateInfoPanel(mSite: TSiteForm; aTabSheet: TTabSheet; aParent: TPanel): TLabel;
var pnAncestorsInfo, pnParamsTop: TPanel;
  mLbl1, mParamsInfoName: TLabel;
begin
  pnParamsTop := TPanel.Create(aTabSheet);
  pnParamsTop.Parent := aParent;
  pnParamsTop.Align := alTop;
  pnParamsTop.Height := 25;
  pnParamsTop.Name := 'pnParamsTop';
  pnParamsTop.Caption := '';
  pnParamsTop.Color := -16777204;
  pnParamsTop.BevelOuter := bvLowered;
  pnParamsTop.BevelInner := bvNone;
  pnParamsTop.BorderStyle := bsNone;

  mLbl1 := TLabel.Create(pnParamsTop);
  mLbl1.Parent := pnParamsTop;
  mLbl1.Left := 8;
  mLbl1.Top := 5;
  mLbl1.Caption := 'Ke skupině:';
  mLbl1.Name := 'lblParamsInfo';
  mLbl1.Tag := -1; //nenastavovat enabled na false

  mParamsInfoName := TLabel.Create(pnParamsTop);
  mParamsInfoName.Parent := pnParamsTop;
  mParamsInfoName.Left := 73;
  mParamsInfoName.Top := 5;
  mParamsInfoName.Name := 'lblParamsInfoName';
  mParamsInfoName.Caption := '';
  mParamsInfoName.Font.Style := [fsBold];
  mParamsInfoName.Tag := -1; //nenastavovat enabled na false

  pnAncestorsInfo := TPanel(NxFindChildControl(mSite.GetSiteAppForm, 'pnAncestorsInfo'));
  if Assigned(pnAncestorsInfo) then begin
    OutputDebugString('PnlAssign....'); //
//    pnParamsTop.Assign(pnAncestorsInfo);
  end;
  Result := mParamsInfoName;
end;

procedure setParamsEnabled(AWinControl: TWinControl; AEnabled: Boolean);
var i: Integer;
begin
  if AWinControl.Name = 'pnList' then Exit; //Aby se nezakazal seznam když je zobrazovan na jinych agendach
  if AWinControl.Name = 'pnParamsTop' then Exit; //Aby se nezakazal nadpis ve Params-u
  for i := 0 to AWinControl.ControlCount - 1 do begin
    if (AWinControl.Controls[i].Name = 'grdParams') then begin // Grid nezakazujeme ale nastavime na ReadOnly
      AWinControl.Controls[i].Enabled := True;
      TMultiGrid(AWinControl.Controls[i]).ReadOnly := not AEnabled;
      if AEnabled then
        TMultiGrid(AWinControl.Controls[i]).Color := clWhite
      else
        TMultiGrid(AWinControl.Controls[i]).Color := -16777194;

      if AEnabled then
        TMultiGrid(AWinControl.Controls[i]).DataSource.DataSet.Refresh;
    end else
      if (AWinControl.Controls[i].Tag < 0) then
        AWinControl.Controls[i].Enabled := False else
        if (not (AWinControl.Controls[i] is TPanel)) then
          AWinControl.Controls[i].Enabled := AEnabled;
    if AWinControl.Controls[i] is TWinControl then
      setParamsEnabled(TWinControl(AWinControl.Controls[i]), AEnabled);
  end;
end;

procedure btnParamsFirst(Sender: TButton);
begin
  TDataSet(IntToObj(Sender.Tag)).First;
end;

procedure btnParamsPrior(Sender: TButton);
begin
  TDataSet(IntToObj(Sender.Tag)).Prior;
end;

procedure btnParamsNext(Sender: TButton);
begin
  TDataSet(IntToObj(Sender.Tag)).Next;
end;

procedure btnParamsLast(Sender: TButton);
begin
  TDataSet(IntToObj(Sender.Tag)).Last;
end;

procedure addParamsClick(Sender: TButton);
var mDataSet: TDataSet;
begin
  mDataSet := TDataSet(IntToObj(Sender.Tag));
  mDataSet.Append;
end;

procedure addFromClick(Sender: TButton);
var mDataSet: TDataSet;
  mStorecardID: string;
  mSQL: string;
  mListBox: TListBox;
  mObjSpace: TNxCustomObjectSpace;
  mTmpDts: TDataset;
begin
  mDataSet := TDataSet(IntToObj(Sender.Tag));
  if not Assigned(mDataSet) then exit;
  mListBox := TListBox(mDataSet.Tag);
  mObjSpace := TNxCustomObjectSpace(mListBox.Items.Objects(mListBox.Items.IndexOf('ObjectSpace')));
  if not Assigned(mObjSpace) then exit;
  mStorecardID := GetSCIDFromVisualRoll;
  if not NxIsEmptyOID(mStorecardID) then begin
    mTmpDts := TMemoryDataSet.Create(nil);
    try
      mSQL := 'Select PAR.ID as ID,' +
              ' PAR.X_Parameter_ID as Property_ID, D.Name as Property_Name,' +
              ' PAR.X_PosIndex as PosIndex, PAR.X_ParamValue as ParamValue' +
              ' from DefRollData PAR ' +
              ' LEFT JOIN DefrollData D ON d.ID=PAR.X_parameter_ID '+
              ' where PAR.CLSID=' + QuotedStr(cBOPropertyCLSID) + 'and PAR.X_rel_def='+QuotedStr(cRelDef)+' and PAR.X_Value_ID='+QuotedStr(mStorecardID)+' order by PAR.X_PosIndex';
      mObjSpace.SQLSelect2(mSQL, mTmpDts);
      if mTmpDts.Active then begin
        mTmpDts.First;
        while not mTmpDts.Eof do begin
          if not ParamExists(mDataset, mTmpDts.FieldByName('Property_ID').asstring) then begin
            mDataSet.Append;
            mDataSet.FieldByName('PosIndex').AsString := mTmpDts.FieldByName('PosIndex').asString;
            //mDataSet.FieldByName('StorecardType_ID').AsString := mTmpDts.FieldByName('StorecardType_ID').asString;
            mDataSet.FieldByName('Property_ID').AsString := mTmpDts.FieldByName('Property_ID').asString;
            mDataSet.FieldByName('ParamValue').AsString := mTmpDts.FieldByName('ParamValue').asString;

            mDataSet.Post;
          end;
          mTmpDts.Next;
        end;
      end;
    finally
      mTmpDts.free;
    end;
  end;
end;

function ParamExists(ADts: TDataset; APropertyID: string): Boolean;
begin
  result := false;
  ADts.First;
  while not ADts.Eof do begin
    if ADts.FieldByName('Property_ID').AsString = APropertyID then begin
      result := true;
      exit;
    end;
    ADts.Next;
  end;
end;

function GetSCIDFromVisualRoll: string;
var
  mRoll: Variant;
  mOLE: Variant;
begin
  mOLE := GetAbraOLEApplication;
  mRoll := mOLE.GetRoll('S3WZQKDB5FDL342M01C0CX3FCC', 1);
  result := '0000000000';
  result := mRoll.SelectDialog2(True, result);
  mOLE := nil;
end;

procedure delPackagesClick(Sender: TButton);
var mDataSet: TDataSet;
begin
  mDataSet := TDataSet(IntToObj(Sender.Tag));
  try
    mDataSet.Edit;
  except end;
  mDataSet.FieldByName('MarkForDelete').AsBoolean := True;
  mDataSet.Post;
  mDataSet.Refresh;
end;

procedure actLSEditExecute(Sender: TAction);
var mSite: TSiteForm;
  mListBox: TListBox;
begin
  mSite := NxFindSiteForm(Sender);
  if Sender.Tag = -1 then begin
    NxShowMessage(Application.Title, 'Nemáte oprávnění editace karet', mdInformation, False, mSite.GetSiteAppForm);
    Exit;
  end;
  mListBox := TListBox(NxFindChildControl(mSite, 'DSCComponents'));
  TAction(mListBox.Items.Objects(mListBox.Items.IndexOf('m2actLSEdit'))).Enabled := False;
  TAction(mListBox.Items.Objects(mListBox.Items.IndexOf('m2actLSRefresh'))).Enabled := False;
  TAction(mListBox.Items.Objects(mListBox.Items.IndexOf('m2actLSSave'))).Visible := True;
  TAction(mListBox.Items.Objects(mListBox.Items.IndexOf('m2actLSCancel'))).Visible := True;
  TAction(mListBox.Items.Objects(mListBox.Items.IndexOf('m2actLSSave'))).Enabled := True;
  TAction(mListBox.Items.Objects(mListBox.Items.IndexOf('m2actLSCancel'))).Enabled := True;

  setParamsEnabled(TWinControl(mListBox.Items.Objects(mListBox.Items.IndexOf('tabParamsDSC'))), True);
end;

procedure dsParamsFilterRecord(DataSet: TDataSet; var Accept: Boolean);
var mListBox: TListBox;
  mDate: TDate;
begin
  Accept := not DataSet.FieldByName('MarkForDelete').AsBoolean;
end;

procedure actLSSaveExecute(Sender: TAction);
var mSite: TSiteForm;
  mListBox: TListBox;
begin
  if Sender.Enabled then begin
    mSite := NxFindSiteForm(Sender);
    mListBox := TListBox(NxFindChildControl(mSite, 'DSCComponents'));
    SaveChanges(mSite, mListBox);
  end;
end;

procedure actLSCancelExecute(Sender: TAction);
var mSite: TSiteForm;
  mListBox: TListBox;
begin
  if Sender.Enabled then begin
    mSite := NxFindSiteForm(Sender);
    mListBox := TListBox(NxFindChildControl(mSite, 'DSCComponents'));
    if NxMessageBox('Potvrzení', 'Opravdu zrušit provedené změny ?', mdConfirm, mdbYesNo, 1, nil, False, mSite.GetSiteAppForm) = mrNo then Exit;
    CancelChanges(mSite, mListBox);
  end;
end;


procedure SaveChanges(aSite: TSiteForm; aListBox: TListBox);
begin
  SaveParamsRelations(aSite);
  TAction(aListBox.Items.Objects(aListBox.Items.IndexOf('m2actLSEdit'))).Enabled := True;
  TAction(aListBox.Items.Objects(aListBox.Items.IndexOf('m2actLSRefresh'))).Enabled := True;
  TAction(aListBox.Items.Objects(aListBox.Items.IndexOf('m2actLSSave'))).Visible := False;
  TAction(aListBox.Items.Objects(aListBox.Items.IndexOf('m2actLSCancel'))).Visible := False;
  TAction(aListBox.Items.Objects(aListBox.Items.IndexOf('m2actLSSave'))).Enabled := False;
  TAction(aListBox.Items.Objects(aListBox.Items.IndexOf('m2actLSCancel'))).Enabled := False;

  setParamsEnabled(TWinControl(aListBox.Items.Objects(aListBox.Items.IndexOf('tabParamsDSC'))), False);
  GlobParams.GetOrCreateParam(dtString, 'ParProperty_ID').AsString := '';
  RefreshParams(aSite);
end;

procedure SaveParamsRelations(ASite: TSiteForm);
var mListBox: TListBox;
  mDataSet: TMemoryDataSet;
  mID: string;
  mBO, mStoreCardBO: TNxCustomBusinessObject;
  mMarkForDelete: Boolean;
  mOID: string;
begin
  mOID := TBusRollSiteForm(ASite).CurrentObject.OID;
  mListBox := TListBox(NxFindChildControl(ASite, 'DSCComponents'));
  mDataSet := TMemoryDataSet(mListBox.Items.Objects(mListBox.Items.IndexOf('dsParams')));
  {if mDataSet.State <> dsBrowse then begin
    if mDataSet.FieldByName('StoreCardType_ID').AsString <> '' then
      mDataSet.Post else mDataSet.Cancel;
  end;}
  mDataSet.Filtered := False;
  try
    mDataSet.DisableControls;
    try
      mDataSet.First;
      while not mDataSet.Eof do begin
        mID := mDataSet.FieldByName('ID').AsString;
        mMarkForDelete := mDataSet.FieldByName('MarkForDelete').AsBoolean;
        if ((not NxIsEmptyOID(mID)) and (mMarkForDelete)) then begin // Bolo to tam a ma sa to vymazat
          mBO := ASite.BaseObjectSpace.CreateObject(cBOPropertyCLSID); // můj BO na vazby
          try
            mBO.Load(mID, nil);
            mBO.Delete;
          finally
            mBO.Free;
          end;
        end;
        if not (mMarkForDelete) then begin //Bude se vytvaret nebo upravovat...
          mBO := ASite.BaseObjectSpace.CreateObject(cBOPropertyCLSID);
          try
            if NxIsEmptyOID(mID) then begin
              mBO.New;
              mBO.Prefill;
            end else
              mBO.Load(mID, nil);

            GlobParams.GetOrCreateParam(dtString, 'ParProperty_ID').AsString := '';
            //GlobParams.GetOrCreateParam(dtString, 'ParStorecardType_ID').AsString := '';

            mBO.SetFieldValueAsString('X_Value_ID', mOID);
            //mBO.SetFieldValueAsString('X_StorecardType_ID', mDataSet.FieldByName('StorecardType_ID').AsString);
            mBO.SetFieldValueAsString('X_Parameter_ID', mDataSet.FieldByName('Property_ID').AsString);
            //mBO.SetFieldValueAsString('X_Product_ID', mStickerBO.GetFieldValueAsString('X_Product_ID'));
            mBO.SetFieldValueAsString('X_PosIndex', mDataSet.FieldByName('PosIndex').AsString);
            mBO.SetFieldValueAsString('X_rel_def', cRelDef);
            //mBo.SetFieldValueAsString('X_ParamValue',mDataSet.FieldByName('ParamValue').AsString);

            mBO.Save;
          finally
            mBO.Free;
          end;
        end;
        mDataSet.Next;
      end;
    finally
      mDataSet.EnableControls;
    end;
  finally
    mDataSet.Filtered := True;
  end;
end;

procedure CancelChanges(aSite: TSiteForm; aListBox: TListBox);
begin
  TAction(aListBox.Items.Objects(aListBox.Items.IndexOf('m2actLSEdit'))).Enabled := True;
  TAction(aListBox.Items.Objects(aListBox.Items.IndexOf('m2actLSRefresh'))).Enabled := True;
  TAction(aListBox.Items.Objects(aListBox.Items.IndexOf('m2actLSSave'))).Visible := False;
  TAction(aListBox.Items.Objects(aListBox.Items.IndexOf('m2actLSCancel'))).Visible := False;
  TAction(aListBox.Items.Objects(aListBox.Items.IndexOf('m2actLSSave'))).Enabled := False;
  TAction(aListBox.Items.Objects(aListBox.Items.IndexOf('m2actLSCancel'))).Enabled := False;

  setParamsEnabled(TWinControl(aListBox.Items.Objects(aListBox.Items.IndexOf('tabParamsDSC'))), False);
  GlobParams.GetOrCreateParam(dtString, 'ParProperty_ID').AsString := '';
  RefreshParams(aSite);
end;

procedure RefreshParams(ASite: TSiteForm);
var mListBox: TListBox;
  i: Integer;
  mDataSet: TMemoryDataSet;
  mSQL: string;
  mResult: TDataset;
  mOID: string;
  pgcDataViews: TPageControl;
  mSQLGetAllParams: string;
begin
  mSQLGetAllParams := 'Select PAR.ID as ID,' +
    ' PAR.X_Parameter_ID as Property_ID, D.Name as Property_Name,' +
    ' PAR.X_PosIndex as PosIndex, PAR.X_ParamValue as ParamValue' +
    ' from DefRollData PAR ' +
    ' LEFT JOIN DefrollData D ON d.ID=PAR.X_parameter_ID '+
    ' where PAR.CLSID=' + QuotedStr(cBOPropertyCLSID) + 'and PAR.X_rel_def='+QuotedStr(cRelDef)+' and PAR.X_Value_ID=%s order by PAR.X_PosIndex';

  mListBox := TListBox(NxFindChildControl(ASite, 'DSCComponents'));
  if mListBox = nil then Exit;
  i := mListBox.Items.IndexOf('dsParams');
  if i = -1 then Exit;
  mDataSet := TMemoryDataSet(mListBox.Items.Objects(i));
  mDataSet.EmptyTable;
  if TBusRollSiteForm(ASite).CurrentObject = nil then Exit;

  pgcDataViews := TPageControl(ASite.FindComponent('pgcDataViews'));
  if pgcDataViews = nil then Exit;
  if pgcDataViews.ActivePage <> TTabSheet(pgcDataViews.FindChildControl('tabParamsDSC')) then Exit;

  TLabel(mListBox.Items.Objects(mListBox.Items.IndexOf('lblParamsInfoName'))).Caption :=
    TBusRollSiteForm(ASite).CurrentObject.GetFieldValueAsString('Name');

  mOID := TBusRollSiteForm(ASite).CurrentObject.OID;
  mSQL := Format(mSQLGetAllParams, [QuotedStr(mOID)]);
  mResult := TMemoryDataSet.Create(nil);
  mAfterInsertActive := false;
  try
    ASite.BaseObjectSpace.SQLSelect2(mSQL, mResult);
    mDataSet.DisableControls;
    if mResult.Active then begin
      mResult.First;
      while not mResult.eof do begin
        mCanLookup := false;
        mDataSet.Append;
        mDataSet.FieldByName('ID').AsString := mResult.FieldByName('ID').AsString;
        //mDataSet.FieldByName('StorecardType_ID').AsString := mResult.FieldByName('StorecardType_ID').AsString;
        //GetCached(mCacheStorecardTypes, mResult.FieldByName('StorecardType_ID').AsString, mResult.FieldByName('StorecardType_Name').AsString);
        mDataSet.FieldByName('Property_ID').AsString := mResult.FieldByName('Property_ID').AsString;
        GetCached(mCachePropertyNames, mResult.FieldByName('Property_ID').AsString, mResult.FieldByName('Property_Name').AsString);
        //mDataSet.FieldByName('RollValue').AsString := mResult.FieldByName('RollValue').AsString;
        //GetCached(mCacheRollValues, mResult.FieldByName('RollValue').AsString, mResult.FieldByName('RollValue_Name').AsString);
        //mDataSet.FieldByName('DataType').AsInteger := mResult.FieldByName('DataType').AsInteger;
        mDataSet.FieldByName('PosIndex').AsString := mResult.FieldByName('PosIndex').AsString;
        //mDataSet.FieldByName('ParamValue').AsString:=mResult.FieldByName('ParamValue').AsString;
        mCanLookup := true;
        mDataSet.Post;
        mResult.Next;
      end;
    end;
  finally
    mDataSet.EnableControls;
    mDataSet.First;
    mResult.Free;
    mCanLookup := true;
    mAfterInsertActive := true;
    GlobParams.GetOrCreateParam(dtString, 'ParProperty_ID').AsString := '';
  end;
end;

//přidá záznam do Cache, pokud je již obsažen, vrátí jeho hodnotu

function GetCached(var ACache: TStrings; AID, AName: string): string;
var mIndex: Integer;
begin
  result := '';
  if not Assigned(ACache) then exit;
  mIndex := ACache.IndexOfName(AID);
  if mIndex = -1 then begin
    if (AID <> '') and (AName <> '') then
      ACache.Add(AID + '=' + AName)
  end else
    result := ACache.ValueFromIndex[mIndex];
end;

// Vrací názvy hodnot

procedure dsParamsCalc(DataSet: TDataSet);
var mObjSpace: TNxCustomObjectSpace;
  mBO: TNxCustomBusinessObject;
  mListBox: TListBox;
  mStorecardTypeID, mPropertyID, mRollValue: string;
  mSQL: string;
  mDts: TDataset;
  mStorecardTypeName, mPropertyName, mRollValueName: string;
begin
  if mCanLookup then begin
    mListBox := TListBox(DataSet.Tag);
    mObjSpace := TNxCustomObjectSpace(mListBox.Items.Objects(mListBox.Items.IndexOf('ObjectSpace')));

   { //typ karty
    try
      mStorecardTypeID := DataSet.FieldByName('StoreCardType_ID').AsString;
      GlobParams.GetOrCreateParam(dtString, 'ParStoreCardType_ID').AsString := mStorecardTypeID;
      if not NxIsEmptyOID(mStorecardTypeID) then begin
        mStorecardTypeName := GetCached(mCacheStorecardTypes, mStorecardTypeID, '');
        if mStorecardTypeName = '' then begin
          mBO := mObjSpace.CreateObject(cBOSCTypeCLSID);
          try
            mBO.Load(mStorecardTypeID, nil);
            DataSet.FieldByName('StoreCardType_ID_Name').AsString := mBO.GetFieldValueAsString('Name');
          finally
            mBO.Free;
          end;
        end else DataSet.FieldByName('StoreCardType_ID_Name').AsString := mStorecardTypeName;
      end else
        DataSet.FieldByName('StoreCardType_ID_Name').AsString := '';
    except
      DataSet.FieldByName('StoreCardType_ID_Name').AsString := '?';
    end; }

    //vlastnost karty
    try
      mPropertyID := DataSet.FieldByName('Property_ID').AsString;
      GlobParams.GetOrCreateParam(dtString, 'ParProperty_ID').AsString := mPropertyID;
      if not NxIsEmptyOID(mPropertyID) then begin
        mPropertyName := GetCached(mCachePropertyNames, mPropertyID, '');
        if mPropertyName = '' then begin
          mBO := mObjSpace.CreateObject('KCAWICC3H2O4DG0YEDMLO4X0PK');
          try
            mBO.Load(mPropertyID, nil);
            DataSet.FieldByName('Property_ID_Name').AsString := mBO.GetFieldValueAsString('Name');
          finally
            mBO.Free;
          end;
        end else DataSet.FieldByName('Property_ID_Name').AsString := mPropertyName;
      end else
        DataSet.FieldByName('Property_ID_Name').AsString := '';
    except
      DataSet.FieldByName('Property_ID_Name').AsString := '?';
    end;

    //hodnota vlastnosti
    try
      mRollValue := DataSet.FieldByName('RollValue').AsString;
      GlobParams.GetOrCreateParam(dtString, 'ParRollValue').AsString := mRollValue;
      if not NxIsEmptyOID(mRollValue) then begin
        mRollValueName := GetCached(mCacheRollValues, mRollValue, '');
        if mRollValueName = '' then begin
          mBO := mObjSpace.CreateObject(cBORollValueCLSID);
          try
            mBO.Load(mRollValue, nil);
            DataSet.FieldByName('RollValue_Name').AsString := mBO.GetFieldValueAsString('X_VALUE_' + mLang);
          finally
            mBO.Free;
          end;
        end else DataSet.FieldByName('RollValue_Name').AsString := mRollValueName;
      end else
        DataSet.FieldByName('RollValue_Name').AsString := '';
    except
      DataSet.FieldByName('RollValue_Name').AsString := '?';
    end;
  end;
end;

procedure scNameGetColumnReadOnly(Sender: TNxMultiGridCustomColumn; var AReadOnly: Boolean);
var mDataSet: TDataSet;
begin
  mDataSet := Sender.Grid.DataSource.DataSet;
  AReadOnly := False;

  //if (Sender.Name = 'gcStoreCardType_ID_Name') then
  //  AReadOnly := True;

  if (Sender.Name = 'gcProperty_ID_Name') then
    AReadOnly := True;

  if (Sender.Name = 'gcRollValue_Name') then
    AReadOnly := True;
end;

procedure pgcDataViewsChange(Sender: TPageControl);
begin
  RefreshParams(NxFindSiteForm(Sender));
end;

procedure pgcDataViewsChanging(Sender: TPageControl;
  var AllowChange: Boolean);
var mSite: TSiteForm;
  i: Integer;
begin
  if (AllowChange) then begin
    mSite := NxFindSiteForm(Sender);
    AllowChange := IsPossibilityEndParams(mSite);
  end;
end;

procedure CheckParamsIsSave(ASite: TSiteForm);
var mAllowChange: Boolean;
begin
  mAllowChange := IsPossibilityEndParams(ASite);
  if not mAllowChange then Abort;
end;

function IsPossibilityEndParams(ASite: TSiteForm): Boolean;
var i: Integer;
  mListBox: TListBox;
begin
  Result := True;
  mListBox := TListBox(NxFindChildControl(aSite, 'DSCComponents'));
  if not (TAction(mListBox.Items.Objects(mListBox.Items.IndexOf('m2actLSEdit'))).Enabled) then begin
    i := NxMessageBox('Potvrzení', 'Uložit změny ?', mdConfirm, mdbYesNoCancel, 1, nil, False, aSite.GetSiteAppForm);
    try
      try
        if i = mrYes then
          Result := true;
        if Result then
          case i of
            mrYes: SaveChanges(aSite, mListBox);
            mrNo: CancelChanges(aSite, mListBox);
            mrCancel: Result := False;
          end;
      except
        Result := False;
      end;
    finally
      Result := TAction(mListBox.Items.Objects(mListBox.Items.IndexOf('m2actLSEdit'))).Enabled;
    end;
  end;
end;

procedure actLSRefreshExecute(Sender: TAction);
begin
  RefreshParams(NxFindSiteForm(Sender));
end;

procedure dsParamsAfterInsert(DataSet: TDataSet);
var mPosIndex: string;
begin
  if mAfterInsertActive then begin
    DataSet.FieldByName('DataType').AsInteger := 4;
    DataSet.FieldByName('MarkForDelete').AsBoolean := false;
    mPosIndex := GetPosIndex(DataSet);
    DataSet.Edit;
    if DataSet.State in [dsInsert, dsEdit] then
      DataSet.FieldByName('PosIndex').AsString := mPosIndex;
  end;
end;

function GetPosIndex(ADataset: TDataset): string;
var mPosInt: Integer;
  mPosStr: string;
  mHigh: Integer;
  mPrevRecord: string;
begin
  result := '';
  mHigh := 0;
  mPrevRecord := ADataSet.GetBookmark;
  ADataSet.DisableControls;
  try
    ADataset.First;
    while not ADataset.Eof do begin
      if TryStrToInt(ADataset.FieldByName('PosIndex').asString, mPosInt) then begin
        if mPosInt > mHigh then mHigh := mPosInt;
      end;
      ADataset.Next;
    end;
  finally
    ADataset.EnableControls;
    if mPrevRecord <> '' then begin
      ADataSet.GoToBookmark(mPrevRecord);
      ADataSet.FreeBookmark(mPrevRecord);
    end;
    mPrevRecord := ''
  end;
  result := NxPadL(IntToStr(mHigh + 1), 2, '0');
end;


begin
end.
