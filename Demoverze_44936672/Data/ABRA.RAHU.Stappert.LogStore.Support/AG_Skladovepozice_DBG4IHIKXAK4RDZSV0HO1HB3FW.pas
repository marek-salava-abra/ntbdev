procedure InitSite_Hook(Self: TSiteForm);
var
  I: Integer;
  mGrid: TDBGrid;
  mWinControl: TWinControl;
  mDataSource: TDataSource;
  mDataSet: TDataSet;
  mField: TField;
  mColumn: TColumn;

begin
  mWinControl := TWinControl(NxFindChildControl(Self.GetSiteAppForm, 'tabContents'));
  if Assigned(mWinControl) then
  begin
    mWinControl := TWinControl(NxFindChildControl(mWinControl, 'pnContent'));
    if Assigned(mWinControl) then
    begin
      mGrid := TDBGrid(NxFindChildControl(mWinControl, 'grdContents'));
      if Assigned(mGrid) then
      begin

        // přístup k datasetu řádků - aby se nakonec dal udělat jejich Refresh
        mDataSource := mGrid.DataSource;
        mDataSet := mDataSource.DataSet;

        for I := 0 to mGrid.Columns.Count - 1 do
        begin
          mColumn := mGrid.Columns.Items[I];
          mField := mColumn.Field;
          OutputDebugString(mField.FieldName);
          if not NxIsNumeric(mField.FieldName) then // !!! proč je někdy numeric?
          begin
            if mField.FieldName = 'StoreCard_ID.Name' then
            begin
              mColumn.Width := 400;
            end;
          end;
        end;
      end;
    end;
  end;
end;

begin
end.