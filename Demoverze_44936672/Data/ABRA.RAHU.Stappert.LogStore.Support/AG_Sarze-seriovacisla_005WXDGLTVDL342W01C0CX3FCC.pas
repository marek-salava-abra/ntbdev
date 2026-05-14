const
  cDebug = True;
  cBusinessObjectCLSID = Class_StoreBatch;

// tlačítko na seznamu agendy
procedure FormCreate_Hook(Self: TSiteForm);
var
  mAction: TBasicAction;
begin
  if cDebug then
  begin
    mAction := Self.GetNewAction;
    mAction.Name := 'btnTest';  // když není zavedeno, tlačítko při OnUpdate problikává
    mAction.ShowControl := True;
    mAction.ShowMenuItem := True;
    mAction.Caption := 'Testy (Ctrl+B)';
    mAction.Hint := 'Určeno pro testy';
    mAction.Category := 'tabList';
    mAction.ShortCut := TextToShortCut('Ctrl+B');
    mAction.OnExecute := @Test_OnExecute;
    mAction.OnUpdate:= @Test_OnUpdate;  // spouští se hodně často
  end;
end;

////////////////////////////////////////////////////////////////////////////////

//nastavení, kdy bude tlačítko k dispozici
procedure Test_OnUpdate(Sender: TObject);
var
  mSiteForm: TSiteForm;
begin
  if Sender is TComponent then
  begin
    mSiteForm := NxFindSiteForm(TComponent(Sender));
    if Assigned(mSiteForm) then
    begin
      // univerzální pro číselníky i agenty
      if mSiteForm is TDynSiteForm then
        TBasicAction(Sender).Enabled := (not TDynSiteForm(mSiteForm).Edit) and not TDynSiteForm(mSiteForm).ActiveDataset.IsEmpty;
      if mSiteForm is TBusRollSiteForm then
        TBasicAction(Sender).Enabled := (not TBusRollSiteForm(mSiteForm).Edit) and not TBusRollSiteForm(mSiteForm).DataSet.IsEmpty;
    end;
  end;
end;

////////////////////////////////////////////////////////////////////////////////

procedure Test_OnExecute(Sender: TObject);
var
  mSiteForm: TSiteForm;
  mOS: TNxCustomObjectSpace;
  IDs: TStringList;
  ResultText: String;
  ErrText: String;
  slResultText: TStringList;

begin
  OutputDebugString('-->> Test');
  if Sender is TComponent then
  begin
    mSiteForm := NxFindSiteForm(TComponent(Sender));
    if Assigned(mSiteForm) then
    begin
      mOS := mSiteForm.BaseObjectSpace;
      IDs := TStringList.Create;
      try
        // univerzální pro číselníky i agenty
        if mSiteForm is TDynSiteForm then
          TDynSiteForm(mSiteForm).FillListWithSelectedRows(IDs);
        if mSiteForm is TBusRollSiteForm then
          TBusRollSiteForm(mSiteForm).FillListWithSelectedRows(IDs);

        Test(mOS, IDs, ResultText, ErrText);  // hlavní procedura
        if ErrText <> '' then
        begin
          NxMessageBox('Chyba', ErrText, mdError, mdbOk, 0, 0, False, Nil);
        end;
        NxMessageBox('Výsledek', ResultText, mdInformation, mdbOk, 0, 0, False, Nil);

      finally
        IDs.Free;
      end;
    end;
  end;

  // občerstvení (ideální by bylo zachovat označení záznamů (RefreshAndRestoreLastSelectedItem))
  // univerzální pro číselníky i agenty
  if mSiteForm is TDynSiteForm then
    TDynSiteForm(mSiteForm).RefreshData;
  if mSiteForm is TBusRollSiteForm then
    TBusRollSiteForm(mSiteForm).RefreshData;

  // výpis výsledku do temp
  slResultText := TStringList.Create;
  try
    slResultText.Add(ResultText);
    slResultText.SaveToFile(NxGetTempDir + '\ABRA.RAHU.Test_' + FormatDateTime('YYYY-MM-DD_hh-mm-ss', Now) + '.txt');
  finally
    slResultText.Free;
  end;

  OutputDebugString('<<-- Test');
end;

////////////////////////////////////////////////////////////////////////////////

procedure Test(mOS: TNxCustomObjectSpace; IDs: TStringList; var ResultText: String; var ErrText: String);
var
  I: Integer;
  mBO: TNxCustomBusinessObject;
  slPositions: TStringList;

begin
  ResultText := '';
  ErrText := '';
  mBO := mOS.CreateObject(cBusinessObjectCLSID);
  try
    for I := 0 to IDs.Count - 1 do
    begin
      mBO.Load(IDs.Strings(I), nil);
      slPositions := TStringList.Create;
      try
        GetLogStorePositionsByStoreCard(mOS, mBO.OID, '', slPositions);
        ResultText := slPositions.Text;
      finally
        slPositions.Free;
      end;
    end;
  finally
    mBO.Free;
  end;
end;

////////////////////////////////////////////////////////////////////////////////

procedure GetLogStorePositionsByStoreCard(mOS: TNxCustomObjectSpace; AStoreBatch_ID, AStore_ID: String; slOutPositions: TStringList);
const
  cCardCategory_Z  = '1000000101';  // typ karty Z
  cCardCategory_ZZ = '2100000101';  // typ karty ZZ
  cCLSID_LSPTR = '4LCWOLMNI2X43A1XTKQSNEP5Z0';

var
  boStoreBatch: TNxCustomBusinessObject;
  boStoreCard: TNxCustomBusinessObject;

  X_Form: String;
  X_Size: Double;
  X_Size1: Double;

  SQLString: String;
  mdSQLResult: TMemoryDataset;

begin
  slOutPositions.Clear;
  boStoreBatch := mOS.CreateObject(Class_StoreBatch);
  boStoreCard := mOS.CreateObject(Class_StoreCard);
  mdSQLResult := TMemoryDataset.Create(nil);
  try
    boStoreBatch.Load(AStoreBatch_ID, nil);
    boStoreCard.Load(boStoreBatch.GetFieldValueAsString('StoreCard_ID'), nil);
    if boStoreCard.GetFieldValueAsString('StoreCardCategory_ID') = cCardCategory_Z then
    begin
      X_Form := boStoreCard.GetFieldValueAsString('X_Form');
//      X_Size := boStoreCard.GetFieldValueAsString('X_Size');
//      X_Size := !!!;
      X_Size1 := boStoreCard.GetFieldValueAsFloat('X_Size1');
      SQLString := Format('SELECT DRD.X_LSPTR_Type, DRD.X_LSPTR_AbsCond_X_Size, DRD.X_LSPTR_AbsCond_X_Size1 FROM DefRollData DRD WHERE DRD.CLSID = %s AND DRD.Hidden = ''N'' AND DRD.X_LSPTR_X_Form = %s', [QuotedStr(cCLSID_LSPTR), QuotedStr(X_Form)]);
      mOS.SQLSelect2(SQLString, mdSQLResult);
      if mdSQLResult.RecordCount = 0 then
      begin
        // !!! nedefinováno
      end
      else
      begin
        mdSQLResult.First;
        while not mdSQLResult.Eof do
        begin
          slOutPositions.Add(mdSQLResult.FieldByName('X_LSPTR_Type').AsString);
          mdSQLResult.Next;
        end
      end;
    end;
    if boStoreCard.GetFieldValueAsString('StoreCardCategory_ID') = cCardCategory_ZZ then
    begin
    end;
  finally
    boStoreCard.Free;
    boStoreBatch.Free;
    mdSQLResult.Free;
  end;
end;

////////////////////////////////////////////////////////////////////////////////

begin
end.