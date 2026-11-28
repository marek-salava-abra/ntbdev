//konstanty je potřeba zkontrolovat a upravit podle podmínek klienta

const
  //číselníky
  cRollStoreCards = 'S3WZQKDB5FDL342M01C0CX3FCC';
  cRollCReasons = 'L0USEDLBCNSO1ACPEVR13FVRX4';
  //BO objecty
  cBORelRec = 'XVOYGQ5UJROOP4RYXY5E3H2LSK';
  //přepnutí jazykové verze
  mLang = 'CS';
  //mLang = 'SK';

var mCanLookup: Boolean; //příznak, kdy se smí zobrazovat názvy (kvůli rychlosti)
  mAfterInsertActive: Boolean; //příznak jestli funguje AfterInsert na datasetu
  mCacheRollValues: TStrings; //cache pro rychlejší zobrazování dat
  mCachePropertyNames: TStrings;
  mCacheStorecardTypes: TStrings;

procedure _MainDatasetBeforeScroll_Hook(Self: TDynSiteForm);
begin
  CheckParamsIsSave(Self);
end;

procedure FormCloseQuery_Hook(Self: TSiteForm; var CanClose: Boolean);
begin
  if CanClose then
    CanClose := IsPossibilityEndParams(Self);
end;

procedure _MainDatasetAfterScroll_Hook(Self: TDynSiteForm);
begin
  RefreshParams(Self);
end;

procedure InitSite_Hook(Self: TSiteForm);
var mControl: TControl;
  mListBox: TListBox;
begin
  mCacheRollValues := TStringList.Create;
  mCachePropertyNames := TStringList.Create;
  mCacheStorecardTypes := TStringList.Create;

  mControl := NxFindChildControl(Self.GetSiteAppForm, 'pgcDynamic');
  if mControl <> nil then begin
    mListBox := TListBox.Create(Self);
    mListBox.Parent := Self;
    mListBox.Name := 'lbxComponents';
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
    mListBox := TListBox(NxFindChildControl(NxFindSiteForm(APageControl), 'lbxComponents'));

    Result := TTabSheet.Create(APageControl);
    Result.PageControl := APageControl;
    Result.Caption := '&Položky reklamace';
    Result.Name := 'tabReclamations';
    APageControl.Pages[Result.PageIndex].PageIndex:=7;

    try
      mPrvileg := TNXParameters.Create;
      try
        GetEffectiveFunctionSecurityRights(Self.CompanyCache, Self.BaseObjectSpace, 'XP0SF1KD0L24ND21EZBS5Q0RAO', NxGetActualUserID(Self.BaseObjectSpace), mPrvileg);
        mSuper := false; //mPrvileg.ParamAsBoolean('G1TDNZSKTVCL33N2010DELDFKK:Supervisor', False);
        mPrvileg1 := GetRightsParam(mPrvileg, dtList, 'XP0SF1KD0L24ND21EZBS5Q0RAO').AsList;
        mPrvileg1 := GetRightsParam(mPrvileg1, dtList, 'XP0SF1KD0L24ND21EZBS5Q0RAO').AsList;
        mCanEdit := true; //(mSuper) or (GetRightsParam(mPrvileg1, dtBoolean, 'EJ2T4X04K1R43DN20ZUNOJEEOO').AsBoolean);
        mCanDelete := true; //(mSuper) or (GetRightsParam(mPrvileg1, dtBoolean, 'QMGZ4C2BFGEOF1ZAJDZPLH0BOK').AsBoolean);
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

      mFieldDef := TFieldDef.Create(mDataSet.FieldDefs, 'StoreCard_ID', ftString, 10, False, 300002);
      with mFieldDef.CreateField(mDataSet, nil, 'xStoreCard_ID', False) do begin
        Size := 10;
        FieldKind := fkData;
        FieldName := 'StoreCard_ID';
      end;
      mFieldDef := TFieldDef.Create(mDataSet.FieldDefs, 'StoreCard_ID_Name', ftString, 80, False, 300003);
      with mFieldDef.CreateField(mDataSet, nil, 'xStoreCard_ID_Name', False) do begin
        Size := 80;
        FieldKind := fkCalculated;
        FieldName := 'StoreCard_ID_Name';
      end;

      mFieldDef := TFieldDef.Create(mDataSet.FieldDefs, 'RReason_ID', ftString, 10, False, 300004);
      with mFieldDef.CreateField(mDataSet, nil, 'xRReason_ID', False) do begin
        Size := 10;
        FieldKind := fkData;
        FieldName := 'RReason_ID';
      end;

      mFieldDef := TFieldDef.Create(mDataSet.FieldDefs, 'RSolution', ftString, 50, False, 300005);
      with mFieldDef.CreateField(mDataSet, nil, 'xRSolution', False) do begin
        Size := 50;
        FieldKind := fkData;
        FieldName := 'RSolution';
      end;

      mFieldDef := TFieldDef.Create(mDataSet.FieldDefs, 'RSolution_Cache', ftString, 50, False, 3000012);
      with mFieldDef.CreateField(mDataSet, nil, 'xRSolution_Cache', False) do begin
        Size := 50;
        FieldKind := fkData;
        FieldName := 'RSolution_Cache';
      end;

      mFieldDef := TFieldDef.Create(mDataSet.FieldDefs, 'MarkForDelete', ftBoolean, 0, False, 300006);
      with mFieldDef.CreateField(mDataSet, nil, 'xMarkForDelete', False) do begin
        FieldKind := fkData;
        FieldName := 'MarkForDelete';
      end;

      mFieldDef := TFieldDef.Create(mDataSet.FieldDefs, 'PosIndex', ftString, 10, False, 300008);
      with mFieldDef.CreateField(mDataSet, nil, 'xPosIndex', False) do begin
        FieldKind := fkData;
        FieldName := 'PosIndex';
      end;

      mFieldDef := TFieldDef.Create(mDataSet.FieldDefs, 'RSolution_text', ftString, 100, False, 300012);
      with mFieldDef.CreateField(mDataSet, nil, 'xRSolution_text', False) do begin
        FieldKind := fkData;
        Size:= 100;
        FieldName := 'RSolution_text';
      end;

      mFieldDef := TFieldDef.Create(mDataSet.FieldDefs, 'RSolution_text_cache', ftString, 80, False, 300013);
      with mFieldDef.CreateField(mDataSet, nil, 'xRSolution_text_cache', False) do begin
        FieldKind := fkData;
        Size:= 100;
        FieldName := 'RSolution_text_cache';
      end;

      mFieldDef:= TFieldDef.Create(mDataSet.FieldDefs, 'Quantity', ftFloat, 0, True, 300009);
      with mFieldDef.CreateField(mDataSet, nil, 'xQuantity', False) do
      begin
        FieldKind:= fkData;
        FieldName:= 'Quantity';
      end;

      mFieldDef := TFieldDef.Create(mDataSet.FieldDefs, 'StoreCard_ID_Name_Cache', ftString, 80, False, 300010);
      with mFieldDef.CreateField(mDataSet, nil, 'xStoreCard_ID_Name_Cache', False) do begin
        FieldKind := fkData;
        Size := 80;
        FieldName := 'StoreCard_ID_Name_Cache';
      end;

      mFieldDef := TFieldDef.Create(mDataSet.FieldDefs, 'Activity_ID', ftString, 10, False, 300011);
      with mFieldDef.CreateField(mDataSet, nil, 'xActivity_ID', False) do begin
        FieldKind := fkData;
        Size := 10;
        FieldName := 'Activity_ID';
      end;

    except
      OutputDebugString(ExceptionMessage);
    end;

    mListBox.Items.AddObject(mDataSet.Name, mDataSet);
    mListBox.Items.AddObject(Result.Name, Result);
    mListBox.Items.AddObject(mParamsInfoName.Name, mParamsInfoName);

    mDataSource := TDataSource.Create(Result);
    mDataSource.Tag:=ObjToInt(Self);
    mDataSource.OnDataChange:=@dsParamsDataChange;
    mDataSource.DataSet := mDataSet;
    mDataSet.AfterInsert := @dsParamsAfterInsert;

    mGrd := TMultiGrid.Create(NxFindChildControl(NxFindSiteForm(APageControl), 'lbxComponents'));
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
    mGridColumn.Width := 40;
    mGrd.AddColumn(mGridColumn);

    mGridObjectRollColumn := TNxMultiGridObjectRollColumn.Create(mGrd);
    TNxMultiGridCustomColumn(mGridObjectRollColumn).Complete := True;
    TNxMultiGridCustomColumn(mGridObjectRollColumn).Layout := 0;
    TNxMultiGridCustomColumn(mGridObjectRollColumn).Line := 0;
    TNxMultiGridCustomColumn(mGridObjectRollColumn).FieldName := 'StoreCard_ID';
    TNxMultiGridCustomColumn(mGridObjectRollColumn).Caption := 'Karta';
    TNxMultiGridCustomColumn(mGridObjectRollColumn).Order := 1;
    TNxMultiGridCustomColumn(mGridObjectRollColumn).Width := 150;
    mGridObjectRollColumn.SecurityMask := 2;
    mGridObjectRollColumn.TextField := 'Code';
    mGrd.AddColumn(mGridObjectRollColumn);
    mGrd.OnGetColumnReadOnly := @scNameGetColumnReadOnly;
    mGridObjectRollColumn.ClassID := cRollStoreCards;

    mGridColumn := TNxMultiGridCustomColumn.Create(mGrd);
    mGridColumn.Layout := 0;
    mGridColumn.Order := 2;
    mGridColumn.Line := 0;
    mGridColumn.FieldName := 'StoreCard_ID_Name';
    mGridColumn.Caption := 'Název karty';
    mGridColumn.Name := 'gcStoreCard_ID_Name';
    mGridColumn.ReadOnly := True;
    mGridColumn.SetReadOnlyBackup;
    mGridColumn.Width := 200;
    mGridColumn.Elastic := True;
    mGrd.AddColumn(mGridColumn);

    mGridColumn:= TNxMultiGridColumn.Create(mGrd);
    mGridColumn.Layout:= 0;
    mGridColumn.Width:= 70;
    mGridColumn.Order:= 3;
    mGridColumn.Kind:=ckText;
    mGridColumn.FieldName:= 'Quantity';
    mGridColumn.Caption:= 'Počet';
    mGrd.AddColumn(mGridColumn);

    mGridObjectRollColumn := TNxMultiGridObjectRollColumn.Create(mGrd);
    TNxMultiGridCustomColumn(mGridObjectRollColumn).Complete := True;
    TNxMultiGridCustomColumn(mGridObjectRollColumn).Layout := 0;
    TNxMultiGridCustomColumn(mGridObjectRollColumn).Line := 0;
    TNxMultiGridCustomColumn(mGridObjectRollColumn).FieldName := 'RReason_ID';
    TNxMultiGridCustomColumn(mGridObjectRollColumn).Caption := 'Důvod reklamace';
    TNxMultiGridCustomColumn(mGridObjectRollColumn).Order := 4;
    TNxMultiGridCustomColumn(mGridObjectRollColumn).Width := 140;
    //mGridObjectRollColumn.SecurityMask := 2;
    mGridObjectRollColumn.TextField := 'Name';
    mGrd.AddColumn(mGridObjectRollColumn);
    mGrd.OnGetColumnReadOnly := @scNameGetColumnReadOnly;
    mGridObjectRollColumn.ClassID := cRollCReasons;

    mGridLookupColumn := TNxMultiGridLookupColumn.Create(mGrd);
    TNxMultiGridCustomColumn(mGridLookupColumn).Layout := 0;
    TNxMultiGridCustomColumn(mGridLookupColumn).Line := 0;
    TNxMultiGridCustomColumn(mGridLookupColumn).FieldName := 'RSolution';
    TNxMultiGridCustomColumn(mGridLookupColumn).Caption := 'Řešení reklamace';
    TNxMultiGridCustomColumn(mGridLookupColumn).Order := 7;
    TNxMultiGridCustomColumn(mGridLookupColumn).Width := 140;
    mGridLookupColumn.Values.add('Vrácení peněz=Vrácení peněz');
    mGridLookupColumn.Values.add('Výměna zboží=Výměna zboží');
    mGridLookupColumn.Values.add('Zaslat chybějící zboží=Zaslat chybějící zboží');
    mGridLookupColumn.Values.add('Ostatní=Ostatní');
    mGrd.AddColumn(mGridLookupColumn);

    mGridColumn:= TNxMultiGridColumn.Create(mGrd);
    mGridColumn.Layout:= 0;
    mGridColumn.Width:= 180;
    mGridColumn.Order:= 8;
    mGridColumn.Kind:=ckText;
    mGridColumn.FieldName:= 'RSolution_text';
    mGridColumn.Caption:= 'Řešení textem';
    mGrd.AddColumn(mGridColumn);

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
      {if i = 6 then begin
        mBtn[i].Width := 100;
        mBtn[i].Caption := 'Doplnit podle...';
        mBtn[i].onClick := @addFromClick;
        mBtn[i].Tag := ObjToInt(mDataSet);
        mBtn[i].Name := 'btnAddFrom';
      end;}
      x := x + mBtn[i].Width;
    end;

    mDataSet.Active := true;
    setParamsEnabled(Result, False);

    mAct := Self.GetNewAction;
    mAct.Name := 'actLSEdit';
    mAct.Caption := 'Editovat';
    mAct.Category := Result.Name;
    mAct.ShortCut := TextToShortCut('F4');
    mAct.OnExecute := @actLSEditExecute;
    if not mCanEdit then
      mAct.Tag := -1;
    mListBox.Items.AddObject('actLSEdit', mAct);

    mAct := Self.GetNewAction;
    mAct.Name := 'actLSRefresh';
    mAct.Caption := 'Občerstvit';
    mAct.Category := Result.Name;
    mAct.ShortCut := TextToShortCut('F11');
    mAct.OnExecute := @actLSRefreshExecute;
    mListBox.Items.AddObject('actLSRefresh', mAct);

    mAct := Self.GetNewAction;
    mAct.Name := 'actLSSave';
    mAct.Caption := 'Uložit';
    mAct.Category := Result.Name;
    mAct.KeepApart := True;
    mAct.Visible := False;
    mAct.Default := True;
    mAct.Enabled := false;
    mAct.OnExecute := @actLSSaveExecute;
    mListBox.Items.AddObject('actLSSave', mAct);

    mAct := Self.GetNewAction;
    mAct.Name := 'actLSCancel';
    mAct.Caption := 'Zrušit';
    mAct.Category := Result.Name;
    mAct.KeepApart := True;
    mAct.Visible := False;
    mAct.Enabled := false;
    mAct.ShortCut := TextToShortCut('ESC');
    mAct.OnExecute := @actLSCancelExecute;
    mListBox.Items.AddObject('actLSCancel', mAct);

    TPageControl(Self.FindComponent('pgcDynamic')).OnChange := @pgcDynamicChange;
    TPageControl(Self.FindComponent('pgcDynamic')).OnChanging := @pgcDynamicChanging;
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
  mLbl1.Caption := 'K reklamaci:';
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
      mSQL := 'Select PAR.ID as ID, PAR.X_Activity_ID as Activity_ID ,PAR.X_RStorecard_ID as Storecard_ID,' +
        ' PAR.X_PosIndex as PosIndex, PAR.X_RQuantity as Quantity, PAR.RSolution as RSolution,' +
        ' PAR.X_RReason_ID as RReason_ID, PAR.RSolution_text as RSolution_text' +
        ' from DefRollData PAR where PAR.CLSID=' + QuotedStr(cBORelRec) + ' and PAR.X_RStorecard_ID=' + QuotedStr(mStorecardID) + ' order by PAR.X_PosIndex';
      mObjSpace.SQLSelect2(mSQL, mTmpDts);
      if mTmpDts.Active then begin
        mTmpDts.First;
        while not mTmpDts.Eof do begin
          //if not ParamExists(mDataset, mTmpDts.FieldByName('StoreCard_ID').asstring) then begin
            mDataSet.Append;
            mDataSet.FieldByName('Activity_ID').AsString := mTmpDts.FieldByName('Activity_ID').asString;
            mDataSet.FieldByName('PosIndex').AsString := mTmpDts.FieldByName('PosIndex').asString;
            //mDataSet.FieldByName('StorecardType_ID').AsString := mTmpDts.FieldByName('StorecardType_ID').asString;
            mDataSet.FieldByName('StoreCard_ID').AsString := mTmpDts.FieldByName('StoreCard_ID').asString;
            mDataSet.FieldByName('RReason_ID').AsString := mTmpDts.FieldByName('RReason_ID').asString;
            mDataSet.FieldByName('RSolution').AsString := mTmpDts.FieldByName('RSolution').AsString;
            mDataSet.FieldByName('RSolution_text').AsString := mTmpDts.FieldByName('RSolution_text').AsString;
            mDataSet.FieldByName('Quantity').AsFloat := mTmpDts.FieldByName('Quantity').AsFloat;
            mDataSet.Post;
          //end;
          mTmpDts.Next;
        end;
      end;
    finally
      mTmpDts.free;
    end;
  end;
end;

{function ParamExists(ADts: TDataset; APropertyID: string): Boolean;
begin
  result := false;
  ADts.First;
  while not ADts.Eof do begin
    if ADts.FieldByName('StoreCard_ID').AsString = APropertyID then begin
      result := true;
      exit;
    end;
    ADts.Next;
  end;
end;}

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
    NxShowMessage(Application.Title, 'Nemáte oprávnění editace reklamací', mdInformation, False, mSite.GetSiteAppForm);
    Exit;
  end;
  mListBox := TListBox(NxFindChildControl(mSite, 'lbxComponents'));
  TAction(mListBox.Items.Objects(mListBox.Items.IndexOf('actLSEdit'))).Enabled := False;
  TAction(mListBox.Items.Objects(mListBox.Items.IndexOf('actLSRefresh'))).Enabled := False;
  TAction(mListBox.Items.Objects(mListBox.Items.IndexOf('actLSSave'))).Visible := True;
  TAction(mListBox.Items.Objects(mListBox.Items.IndexOf('actLSCancel'))).Visible := True;
  TAction(mListBox.Items.Objects(mListBox.Items.IndexOf('actLSSave'))).Enabled := True;
  TAction(mListBox.Items.Objects(mListBox.Items.IndexOf('actLSCancel'))).Enabled := True;

  setParamsEnabled(TWinControl(mListBox.Items.Objects(mListBox.Items.IndexOf('tabReclamations'))), True);
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
    mListBox := TListBox(NxFindChildControl(mSite, 'lbxComponents'));
    SaveChanges(mSite, mListBox);
  end;
end;

procedure actLSCancelExecute(Sender: TAction);
var mSite: TSiteForm;
  mListBox: TListBox;
begin
  if Sender.Enabled then begin
    mSite := NxFindSiteForm(Sender);
    mListBox := TListBox(NxFindChildControl(mSite, 'lbxComponents'));
    if NxMessageBox('Potvrzení', 'Opravdu zrušit provedené zmeny ?', mdConfirm, mdbYesNo, 1, nil, False, mSite.GetSiteAppForm) = mrNo then Exit;
    CancelChanges(mSite, mListBox);
  end;
end;


procedure SaveChanges(aSite: TSiteForm; aListBox: TListBox);
begin
  SaveParamsRelations(aSite);
  TAction(aListBox.Items.Objects(aListBox.Items.IndexOf('actLSEdit'))).Enabled := True;
  TAction(aListBox.Items.Objects(aListBox.Items.IndexOf('actLSRefresh'))).Enabled := True;
  TAction(aListBox.Items.Objects(aListBox.Items.IndexOf('actLSSave'))).Visible := False;
  TAction(aListBox.Items.Objects(aListBox.Items.IndexOf('actLSCancel'))).Visible := False;
  TAction(aListBox.Items.Objects(aListBox.Items.IndexOf('actLSSave'))).Enabled := False;
  TAction(aListBox.Items.Objects(aListBox.Items.IndexOf('actLSCancel'))).Enabled := False;

  setParamsEnabled(TWinControl(aListBox.Items.Objects(aListBox.Items.IndexOf('tabReclamations'))), False);
  //GlobParams.GetOrCreateParam(dtString, 'ParProperty_ID').AsString := '';
  RefreshParams(aSite);
end;

procedure SaveParamsRelations(ASite: TSiteForm);
var mListBox: TListBox;
  mDataSet: TMemoryDataSet;
  mID: string;
  mBO: TNxCustomBusinessObject;
  mMarkForDelete: Boolean;
  mOID: string;
begin
  mOID := TDynSiteForm(ASite).CurrentObject.OID;
  mListBox := TListBox(NxFindChildControl(ASite, 'lbxComponents'));
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
          mBO := ASite.BaseObjectSpace.CreateObject(cBORelRec);
          try
            mBO.Load(mID, nil);
            mBO.Delete;
          finally
            mBO.Free;
          end;
        end;
        if not (mMarkForDelete) then begin //Bude se vytvaret nebo upravovat...
          mBO := ASite.BaseObjectSpace.CreateObject(cBORelRec);
          try
            if NxIsEmptyOID(mID) then begin
              mBO.New;
              mBO.Prefill;
            end else
              mBO.Load(mID, nil);

            //GlobParams.GetOrCreateParam(dtString, 'ParProperty_ID').AsString := '';
            //GlobParams.GetOrCreateParam(dtString, 'ParStorecardType_ID').AsString := '';

            mBO.SetFieldValueAsString('Name', TDynSiteForm(ASite).CurrentObject.DisplayName);
            mBO.SetFieldValueAsString('X_activity_ID',mOID);
            mBO.SetFieldValueAsString('X_RStoreCard_ID',mDataSet.FieldByName('StoreCard_ID').AsString);
            mBO.SetFieldValueAsString('X_RSolution',mDataSet.FieldByName('RSolution').AsString);
            mBO.SetFieldValueAsString('X_RSolution_text',mDataSet.FieldByName('RSolution_text').AsString);
            mBO.SetFieldValueAsString('X_RReason_ID',mDataSet.FieldByName('RReason_ID').AsString);
            mBO.SetFieldValueAsString('X_PosIndex', mDataSet.FieldByName('PosIndex').AsString);
            mBO.SetFieldValueAsFloat('X_RQuantity', mDataSet.FieldByName('Quantity').AsFloat);
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
  TAction(aListBox.Items.Objects(aListBox.Items.IndexOf('actLSEdit'))).Enabled := True;
  TAction(aListBox.Items.Objects(aListBox.Items.IndexOf('actLSRefresh'))).Enabled := True;
  TAction(aListBox.Items.Objects(aListBox.Items.IndexOf('actLSSave'))).Visible := False;
  TAction(aListBox.Items.Objects(aListBox.Items.IndexOf('actLSCancel'))).Visible := False;
  TAction(aListBox.Items.Objects(aListBox.Items.IndexOf('actLSSave'))).Enabled := False;
  TAction(aListBox.Items.Objects(aListBox.Items.IndexOf('actLSCancel'))).Enabled := False;

  setParamsEnabled(TWinControl(aListBox.Items.Objects(aListBox.Items.IndexOf('tabReclamations'))), False);
  //GlobParams.GetOrCreateParam(dtString, 'ParProperty_ID').AsString := '';
  RefreshParams(aSite);
end;

procedure RefreshParams(ASite: TSiteForm);
var mListBox: TListBox;
  i: Integer;
  mDataSet: TMemoryDataSet;
  mSQL: string;
  mResult: TDataset;
  mOID: string;
  pgcDynamic: TPageControl;
  mSQLGetAllParams: string;
begin
 { mSQLGetAllParams := 'Select PAR.ID as ID,' +
    ' PAR.X_StorecardType_ID as StorecardType_ID, SCT.X_VALUE_' + mLang + ' as StorecardType_Name,' +
    ' PAR.X_Property_ID as Property_ID, PRO.X_VALUE_' + mLang + ' as Property_Name,' +
    ' PAR.X_RollValue as RollValue, ROV.X_VALUE_' + mLang + ' as RollValue_Name,' +
    ' PAR.X_DataType as DataType,' +
    ' PAR.X_PosIndex as PosIndex' +
    ' from DefRollData PAR ' +
    ' LEFT JOIN DefRollData SCT ON SCT.ID=PAR.X_StorecardType_ID and SCT.CLSID=' + QuotedStr(cBOSCTypeCLSID) +
    ' LEFT JOIN DefRollData PRO ON PRO.ID=PAR.X_Property_ID and PRO.CLSID=' + QuotedStr(cBOPropertyNameCLSID) +
    ' LEFT JOIN DefRollData ROV ON ROV.ID= PAR.X_RollValue and ROV.CLSID=' + QuotedStr(cBORollValueCLSID) +
    ' where PAR.CLSID=' + QuotedStr(cBORelRec) + ' and PAR.X_Storecard_ID=%s order by PAR.X_PosIndex'; }
  mSQLGetAllParams := 'Select PAR.ID as ID,' +
    ' PAR.X_Activity_ID as Activity_ID,' +
    ' PAR.X_RStorecard_ID as Storecard_ID,' +
    ' SC.Name as StoreCard_ID_Name,' +
    ' PAR.X_PosIndex as PosIndex,' +
    ' PAR.X_RQuantity as Quantity, ' +
    ' PAR.X_RSolution as RSolution, '+
    ' PAR.X_RSolution_text as RSolution_text, '+
    ' PAR.X_RReason_ID as RReason_ID '+
    ' from DefRollData PAR ' +
    ' left join StoreCards SC on SC.id=PAR.X_RStoreCard_ID '+
    ' where PAR.CLSID=' + QuotedStr(cBORelRec) + ' and PAR.X_Activity_ID=%s order by PAR.X_PosIndex';
  mListBox := TListBox(NxFindChildControl(ASite, 'lbxComponents'));
  if mListBox = nil then Exit;
  i := mListBox.Items.IndexOf('dsParams');
  if i = -1 then Exit;
  mDataSet := TMemoryDataSet(mListBox.Items.Objects(i));
  mDataSet.EmptyTable;
  if TDynSiteForm(ASite).CurrentObject = nil then Exit;

  pgcDynamic := TPageControl(ASite.FindComponent('pgcDynamic'));
  if pgcDynamic = nil then Exit;
  if pgcDynamic.ActivePage <> TTabSheet(pgcDynamic.FindChildControl('tabReclamations')) then Exit;

  TLabel(mListBox.Items.Objects(mListBox.Items.IndexOf('lblParamsInfoName'))).Caption :=
    TDynSiteForm(ASite).CurrentObject.DisplayName;

  mOID := TDynSiteForm(ASite).CurrentObject.OID;
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
        mDataSet.FieldByName('StoreCard_ID').AsString := mResult.FieldByName('StoreCard_ID').AsString;
        mDataSet.FieldByName('StoreCard_ID_Name_Cache').AsString := mResult.FieldByName('StoreCard_ID_Name').AsString;
        mDataSet.FieldByName('RSolution').AsString := mResult.FieldByName('RSolution').AsString;
        mDataSet.FieldByName('RSolution_text').AsString := mResult.FieldByName('RSolution_text').AsString;
        if not SameText(mResult.FieldByName('RSolution').AsString, 'Ostatní') then
          mDataSet.FieldByName('RSolution_text_cache').Clear;
        mDataSet.FieldByName('RSolution_Cache').AsString := mResult.FieldByName('RSolution').AsString;
        mDataSet.FieldByName('RReason_ID').AsString := mResult.FieldByName('RReason_ID').AsString;
        mDataSet.FieldByName('Activity_ID').AsString := mResult.FieldByName('Activity_ID').AsString;
        mDataSet.FieldByName('PosIndex').AsString := mResult.FieldByName('PosIndex').AsString;
        mDataSet.FieldByName('Quantity').AsFloat := mResult.FieldByName('Quantity').AsFloat;
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
    //GlobParams.GetOrCreateParam(dtString, 'ParProperty_ID').AsString := '';
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
  mStorecardTypeID, mCurrency, mRollValue: string;
  mSQL, mProducer_ID: string;
  mDts: TDataset;
  mStorecardTypeName, mPropertyName, mRollValueName: string;
  mPrice: Extended;
begin
  DataSet.FieldByName('StoreCard_ID_Name').AsString:=DataSet.FieldByName('StoreCard_ID_Name_Cache').AsString;
  //DataSet.FieldByName('RSolution').AsString:=DataSet.FieldByName('RSolution_Cache').AsString;
end;

procedure scNameGetColumnReadOnly(Sender: TNxMultiGridCustomColumn; var AReadOnly: Boolean);
var mDataSet: TDataSet;
begin
  {mDataSet := Sender.Grid.DataSource.DataSet;
  AReadOnly := False;

  if SameText(Sender.FieldName, 'RSolution_text') then
  begin
    if not SameText(Trim(VarToStr(mDataSet.FieldByName('RSolution').Value)), 'Ostatní') then
      AReadOnly := True;
  end;

  //if (Sender.Name = 'gcStoreCardType_ID_Name') then
  //  AReadOnly := True;

 // if (Sender.Name = 'gcStoreCard_ID_Name') then
 //   AReadOnly := True;

  //if (Sender.Name = 'gcStore_ID_Name') then
  //  AReadOnly := True;

 // if (Sender.Name = 'gcGoodsType_ID_Name') then
  //  AReadOnly := True; }
end;

procedure pgcDynamicChange(Sender: TPageControl);
begin
  RefreshParams(NxFindSiteForm(Sender));
end;

procedure pgcDynamicChanging(Sender: TPageControl;
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
  mListBox := TListBox(NxFindChildControl(aSite, 'lbxComponents'));
  if not (TAction(mListBox.Items.Objects(mListBox.Items.IndexOf('actLSEdit'))).Enabled) then begin
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
      Result := TAction(mListBox.Items.Objects(mListBox.Items.IndexOf('actLSEdit'))).Enabled;
    end;
  end;
end;

procedure actLSRefreshExecute(Sender: TAction);
begin
  RefreshParams(NxFindSiteForm(Sender));
end;

procedure dsParamsAfterInsert(DataSet: TDataSet);
var mPosIndex: string;
    //mProducer_ID: String;
begin
  if mAfterInsertActive then begin
    //DataSet.FieldByName('DataType').AsInteger := 4;
    DataSet.FieldByName('MarkForDelete').AsBoolean := false;
    DataSet.FieldByName('StoreCard_ID_Name_Cache').Clear;
    DataSet.FieldByName('RSolution_text_cache').Clear;
    DataSet.FieldByName('RSolution_Cache').Clear;
    mPosIndex := GetPosIndex(DataSet);

    DataSet.Edit;
    if DataSet.State in [dsInsert, dsEdit] then begin
      DataSet.FieldByName('PosIndex').AsString := mPosIndex;

      {mProducer_ID:=GetProducer(DataSet,DataSet.FieldByName('StoreCard_ID').AsString);
      NxShowSimpleMessage(mProducer_ID, nil);
      if not NxIsEmptyOID(mProducer_ID) then begin
        DataSet.FieldByName('Producer_ID').AsString := mProducer_ID;
      end;}
    end;
  end;
end;

// MATL
procedure dsParamsDataChange(Sender: TObject; Field: TField);
var
  mDataSet: TDataSet;
  mStoreCardID, mName, sol: string;
  mSite: TSiteForm;
  mSQL: string;
  mDts: TDataset;
  grd: TMultiGrid;
begin
  if Field = nil then Exit;
  if not (SameText(Field.FieldName, 'StoreCard_ID') or SameText(Field.FieldName, 'RSolution')) then Exit;

  mDataSet := TDataSource(Sender).DataSet;

  if SameText(Field.FieldName, 'StoreCard_ID') then
  begin
    mStoreCardID := mDataSet.FieldByName('StoreCard_ID').AsString;
    if NxIsEmptyOID(mStoreCardID) then Exit;

    mSite := TSiteForm(TDataSource(Sender).Tag);
    mSQL := 'SELECT sc.name as name from StoreCards sc ' +
            'where sc.ID = ' + QuotedStr(mStoreCardID) + ' AND sc.Hidden = ''N''';

    mDts := TMemoryDataSet.Create(nil);
    try
      mSite.BaseObjectSpace.SQLSelect2(mSQL, mDts);
      if mDts.Active and not mDts.IsEmpty then
      begin
        mName := Trim(VarToStr(mDts.FieldByName('name').Value));
        if mName <> '' then
        begin
          if not (mDataSet.State in [dsEdit, dsInsert]) then mDataSet.Edit;
          mDataSet.FieldByName('StoreCard_ID_Name_Cache').AsString := mName;
        end;
      end;
    finally
      mDts.Free;
    end;

    Exit;
  end;

  if SameText(Field.FieldName, 'RSolution') then
  begin
    if not (mDataSet.State in [dsEdit, dsInsert]) then mDataSet.Edit;

    sol := Trim(VarToStr(mDataSet.FieldByName('RSolution').Value));
    mDataSet.FieldByName('RSolution_Cache').AsString := sol;

    if not SameText(sol, 'Ostatní') then
    begin
      mDataSet.FieldByName('RSolution_text').Clear;
      mDataSet.FieldByName('RSolution_text_cache').Clear;
    end;

    try
      mSite := TSiteForm(TDataSource(Sender).Tag);
      grd   := TMultiGrid(NxFindChildControl(mSite, 'grdParams'));
      if Assigned(grd) then
      begin
        try
          grd.EditMode := False;
        except
          try grd.Hide; except end;
        end;
        grd.Invalidate;
        grd.Update;
      end;
    except
    end;

    Exit;

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
