{
procedure AfterSave_Hook(Self: TNxCustomBusinessObject);
var
  SQLString: String;
  slSQLResult: TStringList;
  boDoc: TNxCustomBusinessObject;
  boDocRow: TNxCustomBusinessObject;
  mcDocRows: TNxCustomBusinessMonikerCollection;
  mOS: TNxCustomObjectSpace;
  I: Integer;

begin
  mOS := Self.ObjectSpace;
  slSQLResult := TStringList.Create;
  boDoc := mOS.CreateObject(Class_LogStoreInput);
  boDocRow := mOS.CreateObject(Class_LogStoreInputRow);
  try
    SQLString := Format('SELECT LSD2.ID FROM LogStoreDocuments2 LSD2 WHERE LSD2.StoreDocRow_ID = %s', [QuotedStr(Self.OID)]);
    mOS.SQLSelect(SQLString, slSQLResult);
    if slSQLResult.Count = 1 then  // pokud odkaz neexistuje nebo existuje více řádků, nic neprovádíme
    begin
    try
      boDocRow.Load(slSQLResult.Strings(0), nil);
      boDoc.Load(boDocRow.GetFieldValueAsString('Parent_ID'), nil);
      mcDocRows := boDoc.GetLoadedCollectionMonikerForFieldCode(boDoc.GetFieldCode('Rows'));
      for I := 0 to mcDocRows.Count - 1 do
      begin
        boDocRow := mcDocRows.BusinessObject(I);
        if boDocRow.OID = slSQLResult.Strings(0) then
        begin
//          boDocRow.SetFieldValueAsFloat('Quantity', Self.GetFieldValueAsFloat('Quantity'));
          boDocRow.SetFieldValueAsFloat('InPositionQuantity', Self.GetFieldValueAsFloat('Quantity'));
        end;
      end;
      if boDoc.NeedSave then
      begin
        boDoc.Save;
      end;
    finally
      boDoc.Free;
      boDocRow.Free;
    end;

    end;
  finally
    slSQLResult.Free;
  end;
end;
}

begin
end.