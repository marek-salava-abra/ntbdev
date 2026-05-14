
// vytvoření spojení na MSSQL přes TSQLConnection

procedure MSSQLConnect(var mConn: TSQLConnection; mParams: string;);
begin
  mConn.Driver := dbMSSQL;
  mConn.Params := mParams;
  mConn.Connect;
end;


// načtení první položky prvního sloupce

function MSSQLSelectValue(mConn: TSQLConnection; query : String;): String;
var
  mDataSet: TSQLDataset;
begin
  Result := '';
  mDataSet := mConn.OpenNewDataset(query);
  try
    if (not mDataSet.EOF) and (mDataSet.FieldCount > 0) then begin
      mDataSet.First;
      Result := mDataSet.Fields[0].AsString;
    end;
  finally
    mDataSet.Free;
  end;
end;

// načtení seznamu položek jednoho sloupce

procedure MSSQLSelectValues(mConn: TSQLConnection; query : String; var AResult: TStringList);
var
  mDataSet: TSQLDataset;
begin
  AResult.Clear;
  mDataSet := mConn.OpenNewDataset(query);
  try
    if (not mDataSet.EOF) and (mDataSet.FieldCount > 0) then begin
      mDataSet.First;
      while not mDataSet.EOF do begin
        AResult.Add(mDataSet.Fields[0].AsString);
        mDataSet.Next;
      end;
    end;
  finally
    mDataSet.Free;
  end;
end;


begin
end.