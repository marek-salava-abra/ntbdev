
const
  constJanekBarCode = '8591746';


function GenIntEAN(ABO : TNxCustomBusinessObject; APrefix : String) : string;
var
  mContext: TNxContext;
  mList: TStrings;
  mSQLSelect : string;
  mEAN : string;
  mEANPrefix, tmpS : string;
  mNumEAN : Longint;
  mEANLen, mPrefixLength : integer;
const
  cSQL =  'SELECT FIRST 1 E.ean FROM janek_eans E '+
          'LEFT JOIN storeeans SE ON SE.ean = E.ean '+
          'WHERE SE.ean is null '+
          'ORDER BY E.ean ';
begin
  Result := '';

    mSQLSelect := cSQL;
    mList := TStringList.Create;
    try
      mContext := NxCreateContext_1(ABO);
      try
        mContext.SQLSelect(mSQLSelect, mList);
      finally
        mContext.Free;
      end;
      if (mList.Count > 0) then begin
//      ShowMessage(mList.Strings[0]);
        mEAN := mList.Strings[0];
        mEAN := Trim(mEAN);
        mEAN := NxLeft(mEAN, 12);
        NxCorrectEAN13(mEAN);
        Result := mEAN;
      end;
    finally
      mList.Free;
    end;
end;

function GenIntEAN_inter(ABO : TNxCustomBusinessObject; APrefix : String) : string;
var
  mContext: TNxContext;
  mList: TStrings;
  mSQLSelect : string;
  mEAN : string;
  mEANPrefix, tmpS : string;
  mNumEAN : Longint;
  mEANLen, mPrefixLength : integer;
const
  cSQL =  'SELECT max(cast(ib_string_left(ean, 12) as varchar(12)) ) FROM StoreUnits WHERE ean like ''%s'' ';
begin
  Result := '';
  mPrefixLength := Length(APrefix);
  tmpS := NxPadR(APrefix, 13, '_');

    mSQLSelect := Format(cSQL, [tmpS]);
//    ShowMessage(mSQLSelect);
    mList := TStringList.Create;
    try
      mContext := NxCreateContext_1(ABO);
      try
        mContext.SQLSelect(mSQLSelect, mList);
      finally
        mContext.Free;
      end;
      if (mList.Count > 0) then begin
        mEAN := mList.Strings[0];
        mEAN := Trim(mEAN);
        mEANPrefix := NxLeft(mEAN, mPrefixLength);
        mEANLen := Length(mEAN);
        mEAN := NxRight(mEAN, mEANLen - mPrefixLength);
        mNumEAN := StrToInt(mEAN);
        mNumEAN := mNumEAN + 1;
        mEAN := IntToStr(mNumEAN);
        mEAN := NxPadL(mEAN, mEANLen - mPrefixLength, '0');
        mEAN := mEANPrefix + mEAN;
        NxCorrectEAN13(mEAN);
        Result := mEAN;
      end;
    finally
      mList.Free;
    end;
end;






procedure FormCreate_Hook(Self: TSiteForm);
var
  mMultiAction: TMultiAction;
begin
  mMultiAction := Self.GetNewMultiAction;
  mMultiAction.ShowControl := True;
  mMultiAction.ShowMenuItem := True;
  mMultiAction.Caption := 'Generuj EAN';
  mMultiAction.Hint := 'Vygeneruje EAN';
  mMultiAction.Items.Add('EAN (interní)');
  mMultiAction.Category := 'tabList';
  mMultiAction.OnExecuteItem := @ImportOnExecute;
  //mMultiAction.OnUpdate := @ImportOnUpdate;



end;


procedure ImportOnUpdate(Sender: TObject);
begin
  TBasicAction(Sender).Enabled := True;
end;


procedure ImportOnExecute(Sender: TObject; AIndex : integer);
var
  mSite: TSiteForm;
  mBO : TNxCustomBusinessObject;
  mMainUnitCode : string;
  mUnits : TNxCustomBusinessMonikerCollection;
  i,j : integer;
  mUnit : TNxCustomBusinessObject;
  mEAN : string;

  mDBGrid : TDBGrid;
  mBookmark : TBookmarkList;
  mActualRow : TBookmark;
  mControl : TControl;
  mIDs:TStringList

begin
  if Sender is TComponent then begin
    mSite := TComponent(Sender).BusRollSite;
    if not (mSite is TBusRollSiteForm) then begin
      NxShowMessage('INFO','nejsem dynsite',mdInformation,false,msite);
      exit;
    end;

    mControl := NxFindChildControl(mSite.MainPanel, 'grdList');
    if not (mControl is TDBGrid) then begin
      ShowMessage('Neni TDBGrid');
      exit;
    end;
    mDBGrid := TDBGrid(mControl);

    if not Assigned(mDBGrid) then begin
      ShowMessage('Neni dbgrid');
      exit;
    end;

    mBookmark := mDBGrid.SelectedRows;
    if not Assigned(mBookmark) then
      ShowMessage('Nemam bookmark!');


    if mBookmark.Count = 0 then begin
      NXShowMessage('Info','Není označen žádný záznam!',mdWarning,false,msite);
      exit;
    end;
    mIDs:=TStringList.create;
     TBusRollSiteForm(msite).FillListWithSelectedRows(mids);

    if MessageDlg('Přejete si prohést hromadou změnu EAN kódu?', mtInformation, [mbCancel, mbOK], 0) = mrOK then begin
      //mActualRow := mDBGrid.DataSource.DataSet.GetBookmark;
      for i := 0 to mIDs.Count - 1 do begin
        //mDBGrid.DataSource.DataSet.GotoBookmark(mBookMark.items(i));

        mbo:=TBusRollSiteForm(msite).CurrentObject.ObjectSpace.CreateObject(Class_StoreCard);
        mBO.Load(mids.Strings[i],nil);
        if true or NxIsBlank(mBO.GetFieldValueAsString('EAN')) then begin
          mMainUnitCode := mBO.GetFieldValueAsString('MainUnitCode');
          mUnits := mBO.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('StoreUnits'));
          for j := 0 to mUnits.count - 1 do begin
            mUnit := mUnits.BusinessObject[j];
            if mUnit.GetFieldValueAsString('Code') = mMainUnitCode then begin
//              ShowMessage('generuji...' + IntToStr(AIndex));
              if AIndex = 0 then
                mEAN := GenIntEAN_inter(mBO, '200055');


              //mUnit.SetFieldValueAsString('U_OldEAN', mUnit.GetFieldValueAsString('EAN'));
              mUnit.SetFieldValueAsString('EAN', mEAN);
              mBO.SetFieldValueAsString('EAN', mEAN);
            end;
          end;
        end;
        mBO.Save;
      end;
      mDBGrid.DataSource.DataSet.GotoBookmark(mActualRow);
      mDBGrid.DataSource.DataSet.Refresh;
    end;
  end;
end;



procedure NewQualityCardExecute(Sender: TObject; AIndex : integer);
var
  mSite: TSiteForm;
  mOrigBO, mNewBO, mUnit : TNxCustomBusinessObject;

  mDBGrid : TDBGrid;
  mBookmark : TBookmarkList;
  mActualRow : TBookmark;
  mControl : TControl;
  i, j : integer;
  mMainUnitCode, mEAN, mSuffixCode : string;
  mUnits : TNxCustomBusinessMonikerCollection;

begin
  if Sender is TComponent then begin
    mSite := TComponent(Sender).BusRollSite;
    if not (mSite is TRollSiteForm) then begin
      ShowMessage('nejsem dynsite');
      exit;
    end;

    mControl := NxFindChildControl(mSite.MainPanel, 'grdList');
    if not (mControl is TDBGrid) then begin
      ShowMessage('Neni TDBGrid');
      exit;
    end;
    mDBGrid := TDBGrid(mControl);

    if not Assigned(mDBGrid) then begin
      ShowMessage('Neni dbgrid');
      exit;
    end;

    mBookmark := mDBGrid.SelectedRows;
    if not Assigned(mBookmark) then
      ShowMessage('Nemam bookmark!');


    if mBookmark.Count = 0 then begin
      ShowMessage('Není označen žádný záznam!');
      exit;
    end;

      case AIndex of
        0 : mSuffixCode := '2';
        1 : mSuffixCode := '3';
        else
              RaiseException('Nepodporovaný typ operace!');
      end;

    if MessageDlg(Format('Přejete si pro označené karty založit nové karty jiné (%s) jakosti?', [mSuffixCode]), mtInformation, [mbCancel, mbOK], 0) = mrOK then begin
      mActualRow := mDBGrid.DataSource.DataSet.GetBookmark;
      for i := 0 to mBookMark.Count - 1 do begin
        mDBGrid.DataSource.DataSet.GotoBookmark(mBookMark.items(i));
        mOrigBO := TBusRollSiteForm(mSite).CurrentObject;
        mNewBO := mOrigBO.Clone;
        try
          mNewBO.New;
          mNewBO.Prefill;
          mNewBO.Assign(mOrigBO);
          mNewBO.SetFieldValueAsString('Code', Format('%s.%s', [mOrigBO.GetFieldValueAsString('Code'), mSuffixCode]));
          mNewBO.SetFieldValueAsString('Name', Format('%s (%sj)', [mOrigBO.GetFieldValueAsString('Name'), mSuffixCode]));
          mMainUnitCode := mNewBO.GetFieldValueAsString('MainUnitCode');
          mUnits := mNewBO.GetCollectionMonikerForFieldCode(mNewBO.GetFieldCode('StoreUnits'));
          for j := 0 to mUnits.count - 1 do begin
            mUnit := mUnits.BusinessObject[j];
            if mUnit.GetFieldValueAsString('Code') = mMainUnitCode then begin
              mEAN := GenIntEAN(mNewBO, constJanekBarCode);
              mUnit.SetFieldValueAsString('EAN', mEAN);
            end;
          end;
          if NxIsEmptyOID(getStoreCard_ID(mOrigBO.ObjectSpace, mNewBO.GetFieldValueAsString('Code'))) then
            mNewBO.Save;
        finally
          mNewBO.Free;
        end;
      end;
    end;
  end;
end;


function getStoreCard_ID(AOS: TNxCustomObjectSpace; ACode: String):String;
const
  cSQL = 'SELECT Q.ID FROM StoreCards Q ' +
         ' WHERE Q.Code=''%s''';
var
  mList : TStringList;
begin
  Result := '';
  mList := TStringList.create;
  try
    AOS.SQLSelect(Format(cSQL, [ACode]), mList);
    if mList.Count > 0 then
      Result := mList.Strings[0]
  finally
    mList.Free;
  end;
end;


begin
end.