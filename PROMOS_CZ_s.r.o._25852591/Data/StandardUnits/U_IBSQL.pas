////////////////////////////////////////////////////////////////////////////////
function IB_Create: TSQLConnection;
begin
  result:= TSQLConnection.Create;
end;//IB_Create
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//muze vyvolat vyjimku pokud se nepripoji
procedure IB_InitConection(Connection: TSQLConnection; Server, User, Passwd: String);
begin
  Connection.Driver := dbFirebird;
  Connection.Params :=
    'SERVER NAME=' + Server + #13#10 +
    'ISC_DPB_USER_NAME=' + User + #13#10 +
    'ISC_DPB_PASSWORD=' + Passwd;
  Connection.Connect;
end;//IB_InitConection
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
procedure IB_ExecuteCommand(Connection: TSQLConnection; SQL: String);
begin
  Connection.ExecSQL(SQL);
end;//IB_ExecuteCommand
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//vysledek si preplnim do TMemoryDataset
// !! musi mit stejnou strukturu jako vysledek doazu !!!
procedure IB_Select(Connection: TSQLConnection; SQL: string; DS: TDataSet);
var
  i: integer;
  mDataSet: TSQLDataset;
begin
  mDataSet := Connection.NewDataset;
  try
    mDataSet.SQL := SQL;
    mDataSet.Open;

    //projdu vysledek
    while not mDataSet.EOF do
    begin
      //preplnim mDataSet do DS
      DS.Append;
      for i := 0 to DS.FieldList.Count - 1 do
      begin
        case DS.FieldList.Fields[i].DataType of
          ftDateTime,
          ftDate     : DS.FieldList.Fields[i].AsDateTime:= mDataSet.FieldList.Fields[i].AsDateTime;
          ftFloat    : DS.FieldList.Fields[i].AsFloat   := mDataSet.FieldList.Fields[i].AsFloat;
          ftInteger  : DS.FieldList.Fields[i].AsInteger := mDataSet.FieldList.Fields[i].AsInteger;
          else         DS.FieldList.Fields[i].AsString  := mDataSet.FieldList.Fields[i].AsString;
        end;
      end;
      DS.Post;
      mDataSet.Next;
    end;
  finally
    mDataSet.Free;
  end;
end;//IB_Select
////////////////////////////////////////////////////////////////////////////////

begin
end.