////////////////////////////////////////////////////////////////////////////////
function MSSQL_Create: TSQLConnection;
begin
  result:= TSQLConnection.create;
end;//MSSQL_Create
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//muze vyvolat vyjimku pokud se nepripoji
procedure MSSQL_InitConection(Connection: TSQLConnection; Server, DB, User, Passwd: string);
begin
  Connection.Driver := dbMSSQL;
  Connection.Params :=
    'SERVER NAME=' + Server + #13#10 +
    'DATABASE=' + DB + #13#10 +
    'USER NAME=' + User + #13#10 +
    'PASSWORD=' + Passwd;
  Connection.Connect;
end;//MSSQL_InitConection
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
procedure MSSQL_ExecuteCommand(Connection: TSQLConnection; SQL: string);
begin
  Connection.ExecSQL(SQL);
end;//MSSQL_ExecuteCommand
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//vysledek si preplnim do TDataSet
// !! musi mit stejnou strukturu jako vysledek doazu !!!
procedure MSSQL_Select(Connection: TSQLConnection; SQL: string; DS: TDataSet);
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
end;//MSSQL_ExecuteCommand
////////////////////////////////////////////////////////////////////////////////

begin
end.