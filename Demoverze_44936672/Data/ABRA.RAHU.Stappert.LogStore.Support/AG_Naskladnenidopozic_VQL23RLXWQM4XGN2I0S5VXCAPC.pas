uses
  'ABRA.RAHU.Stappert.LogStore.Support.Common';

////////////////////////////////////////////////////////////////////////////////

const
  cStoreLogPosition_Error_ID = 'PO00000101';

////////////////////////////////////////////////////////////////////////////////

procedure FormCreate_Hook(Self: TSiteForm);
var
  mAction: TBasicAction;
  mMAction: TMultiAction;

  mAList: TActionList;
  i: integer;

begin
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Name := 'actSetLogStorePosition';
  mAction.Caption := 'Doplnit pozice';
  mAction.Hint := 'Doplní automaticky pozice.';
  mAction.Category := 'tabDetail';
  mAction.ShortCut := TextToShortCut('CTRL+L');
  mAction.OnExecute := @SetLogStorePosition_OnExecute;
  mAction.OnUpdate := @SetLogStorePosition_OnUpdate;

  // skrytí funkce "Automaticky"
  mAList := Self.GetMainActionList;
  for i := 0 to mAList.ActionCount-1 do begin
    mAction := mALIst.Actions[i];
    if (mAction.Name = 'actPrefillPositions') then begin
      mAction.Visible := False;
      mAction.Category := 'DISABLED';
    end;
  end;
end;

////////////////////////////////////////////////////////////////////////////////

procedure SetLogStorePosition_OnUpdate(Sender: TObject);
var
  mSiteForm: TSiteForm;
begin
  if Sender is TComponent then begin
    mSiteForm := NxFindSiteForm(TComponent(Sender));
    if Assigned(mSiteForm) then begin
      // Pokud je SiteForm typu doklad, pretypujeme promennou
      //OutputDebugString('Nalezen nadřízený SiteForm.');
      if mSiteForm is TDynSiteForm then begin
        // akce je k dispozici pouze, kdyz je zahajena editace
        TBasicAction(Sender).Enabled := TDynSiteForm(mSiteForm).Edit;
      end;
    end;
  end;
end;

////////////////////////////////////////////////////////////////////////////////

procedure SetLogStorePosition_OnExecute(Sender: TObject);
var
  mDynSiteForm: TDynSiteForm;
  mForm: TForm;
  mRowsControl: TControl;
  mRowsDataSource: TDataSource;

  boDoc: TNxHeaderBusinessObject;
  monDocRows: TNxCustomBusinessMonikerCollection;

  boStoreCard: TNxCustomBusinessObject;
  boDocRow: TNxCustomBusinessObject;

  slStoreCard_Code,
  slRow_ID: TStrings;

  sTempStoreCard_Code,
  sTempRow_ID: String;

  iRowsCount,
  I,
  J: Integer;

  iTemp: Integer;

  RowDataSet: TDataSet;

begin
  if Sender is TComponent then begin
    //OutputDebugString('Sender je TComponent.');
    mDynSiteForm := TDynSiteForm(NxFindSiteForm(TComponent(Sender)));
    if Assigned(mDynSiteForm) then begin
      //OutputDebugString('Nalezen nadřízený SiteForm.');
      if mDynSiteForm is TDynSiteForm then begin

        // přístup k datasetu řádků - aby se nakonec dal udělat jejich Refresh
        mForm := NxGetSiteAppForm(mDynSiteForm);
        mRowsControl := NxFindChildControl(mForm, 'grdRows');
        mRowsDataSource := TMultiGrid(mRowsControl).DataSource;

        // Ziskame aktualni objekt (TNxCustomBusinessObject)
        boDoc := TNxHeaderBusinessObject(mDynSiteForm.CurrentObject);
        if Assigned(boDoc) then
        begin
          iRowsCount := boDoc.Rows.Count;
          monDocRows := boDoc.Rows;
          boStoreCard := mDynSiteForm.BaseObjectSpace.CreateObject('C3V5QDVZ5BDL342M01C0CX3FCC');
          slStoreCard_Code := TStringList.Create;
          slRow_ID := TStringList.Create;

          for I := 0 to iRowsCount - 1 do
          begin
            boDocRow := TNxRowBusinessObject(monDocRows.BusinessObject(I));

            if (NxIsEmptyOID(boDocRow.GetFieldValueAsString('StorePosition_ID'))) or (boDocRow.GetFieldValueAsString('StorePosition_ID') = cStoreLogPosition_Error_ID) then
            begin

              SetLogStorePositions(boDoc, boDocRow);

              {
              // zjištění názvů fildů
              for iTemp := 0 to TDataSet(mRowsDataSource.DataSet).FieldCount - 1 do
              begin
                OutputDebugString(TDataSet(mRowsDataSource.DataSet).Fields[iTemp].FieldName);
              end;
              }
            end;
          end;

          RowDataSet := TDataSet(mRowsDataSource.DataSet);
          // !!! pamatovat si aktivní řádek a na konci zajistit jeho zaktivnění, aby uživateli zůstal kurzor na místě
          RowDataSet.First;
          while not RowDataSet.Eof do
          begin
            RowDataSet.Edit;
            RowDataSet.Post;
            RowDataSet.Next;
          end;

          // refresh GUI
          mRowsDataSource.DataSet.Refresh;
        end;

      end;
    end;
  end;
end;

////////////////////////////////////////////////////////////////////////////////

begin
end.