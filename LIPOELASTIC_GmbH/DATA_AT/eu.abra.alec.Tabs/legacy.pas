{
function AddTDBGrid(const AParent: TPanel; const AName: string): TDBGrid;
var
  mCol: TNxMultiGridCustomColumn;
  mBoolCol: TNxMultiGridBooleanColumn;
  mTMemoryDS: TMemoryDataset;
begin
  Result := TDBGrid.Create(AParent);
  Result.Name := AName;
  Result.Parent := AParent;
  Result.Align := alClient;
  //Result.DataSource := mDataSource;
  Result.Enabled:= true;
  Result.MultiSelect:= true;
  Result.ReadOnly:= true;

end;


function CreateMultiGrid(const AParent: TWinControl; const AName: string; const ADataSet: TDataSet): TMultiGrid;
var
  DS: TDataSource;
begin
  Result := TMultiGrid.Create(AParent);
  Result.Parent := AParent;
  Result.Align := alClient;
  Result.Name := AName;

  Result.ReadOnly := True;
  //Result.MultiSelect := True;

  DS := TDataSource.Create(Result);
  DS.DataSet := ADataSet;
  Result.DataSource := DS;
end;
}

begin
end.